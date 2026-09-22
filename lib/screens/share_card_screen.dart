import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../models/rider_profile.dart';
import '../models/week_range.dart';
import '../models/weekly_dashboard_data.dart';
import '../services/share_card_export.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_title.dart';

/// Share Card (mockup screen 7, build_execution.md Phase 8): "Meri Asli
/// Kamai this week" — a shareable stat image for the rider's WhatsApp
/// group, built from the same week's dashboard data as the Home tab.
/// Anonymous by default (research.md §3.9): the rider's name is only drawn
/// on the card if they turn "Include my name" on.
class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({super.key});

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final _boundaryKey = GlobalKey();
  final _week = WeekRange(DateTime.now());
  bool _includeName = false;
  bool _sharing = false;
  String _riderName = '';
  late final Future<WeeklyDashboardData> _dataFuture = _load();

  Future<WeeklyDashboardData> _load() async {
    final db = AppDatabase.instance;
    final orders = await db.ordersInRange(_week.start, _week.end);
    final expenses = await db.expensesInRange(_week.start, _week.end);
    final profile = await RiderProfile.load();
    if (mounted) setState(() => _riderName = profile.name);
    return WeeklyDashboardData.fromOrders(
      weekStart: _week.start,
      weekEnd: _week.end,
      orders: orders,
      expenses: expenses,
    );
  }

  Future<void> _share(WeeklyDashboardData data) async {
    setState(() => _sharing = true);
    try {
      final path = await exportShareCardPng(_boundaryKey);
      if (!mounted) return;
      final rate = data.netPerHour;
      final s = S(context);
      final caption =
          rate == null ? s.shareCaptionNoRate : s.shareCaption(formatRupees(rate));
      await Share.shareXFiles([XFile(path)], text: caption);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.shareCard)),
      body: SafeArea(
        // Pushed routes sit outside RootShell's SafeArea; without this,
        // Android 15+ edge-to-edge draws the bottom under the nav bar.
        top: false,
        child: FutureBuilder<WeeklyDashboardData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final data = snapshot.data!;
            if (data.isEmpty) {
              return EmptyState(
                icon: Icons.share_outlined,
                title: s.nothingToShareYet,
                message: s.importScreenshotsFirst,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Center(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: _ShareCard(
                      data: data,
                      week: _week,
                      riderName: _includeName ? _riderName : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.includeMyName),
                  subtitle: Text(
                    _riderName.isEmpty ? s.setYourNameHint : s.includeMyNameOff,
                    style: AppTextStyles.bodyMuted,
                  ),
                  value: _includeName && _riderName.isNotEmpty,
                  onChanged: _riderName.isEmpty
                      ? null
                      : (v) => setState(() => _includeName = v),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: _sharing ? null : () => _share(data),
                  icon: _sharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.share_outlined),
                  label: Text(_sharing ? s.preparingEllipsis : s.shareButton),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.data, required this.week, this.riderName});

  final WeeklyDashboardData data;
  final WeekRange week;
  final String? riderName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, Color(0xFF0B4A3A)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Meri Asli Kamai',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          Text(
            'असली कमाई इस हफ़्ते',
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.netPerHour != null) ...[
            Text(
              '${formatRupees(data.netPerHour!)}/hr',
              style: AppTextStyles.bigNumber.copyWith(fontSize: 40),
            ),
            Text(
              S(context).netAfterCosts,
              style: AppTextStyles.body.copyWith(color: AppColors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: _CardStat(
                  label: S(context).shareCardNetEarnings,
                  value: formatRupees(data.net),
                ),
              ),
              Expanded(
                child: _CardStat(
                  label: S(context).distance,
                  value: '${data.totalKm.toStringAsFixed(0)} km',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.white.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            week.label,
            style: AppTextStyles.label.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
          ),
          if (riderName != null && riderName!.isNotEmpty)
            Text(
              riderName!,
              style: AppTextStyles.label.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'AsliKamai',
            style: AppTextStyles.label.copyWith(
              color: AppColors.warmYellow,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  const _CardStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
        ),
        Text(
          value,
          style: AppTextStyles.sectionHeader.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
