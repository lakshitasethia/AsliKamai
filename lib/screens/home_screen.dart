import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/week_range.dart';
import '../models/weekly_dashboard_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

/// Weekly Dashboard tab (mockup screen 3): the "3-second glance" home
/// screen — net earnings, ₹/hr, ₹/km, best/worst hour and zone, and
/// whether chasing incentives was worth it, all computed from this week's
/// imported orders.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeekRange _week = WeekRange(DateTime.now());
  late Future<WeeklyDashboardData> _dataFuture = _load();

  Future<WeeklyDashboardData> _load() async {
    final db = AppDatabase.instance;
    final orders = await db.ordersInRange(_week.start, _week.end);
    final expenses = await db.expensesInRange(_week.start, _week.end);
    return WeeklyDashboardData.fromOrders(
      weekStart: _week.start,
      weekEnd: _week.end,
      orders: orders,
      expenses: expenses,
    );
  }

  void _goToWeek(WeekRange week) {
    setState(() {
      _week = week;
      _dataFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _AppTitle(),
        actions: const [
          _OfflinePill(),
          SizedBox(width: 4),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings_outlined, color: AppColors.charcoal),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _goToWeek(_week),
        child: FutureBuilder<WeeklyDashboardData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            return Column(
              children: [
                _WeekNavigator(
                  week: _week,
                  onPrevious: () => _goToWeek(_week.previous()),
                  onNext: _week.isCurrentWeek
                      ? null
                      : () => _goToWeek(_week.next()),
                ),
                Expanded(
                  child: !snapshot.hasData
                      ? const SizedBox.shrink()
                      : snapshot.data!.isEmpty
                          ? const EmptyState(
                              icon: Icons.bar_chart_rounded,
                              title: 'No data yet',
                              message:
                                  'Import screenshots to see your weekly summary.',
                            )
                          : _DashboardBody(data: snapshot.data!),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.week,
    required this.onPrevious,
    required this.onNext,
  });

  final WeekRange week;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                week.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionHeader,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final WeeklyDashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      children: [
        _NetEarningsHeroCard(data: data),
        const SizedBox(height: AppSpacing.md),
        if (data.bestHour != null || data.worstHour != null) ...[
          Row(
            children: [
              if (data.bestHour != null)
                Expanded(
                  child: _HourCard(
                    label: 'Best Hour',
                    rate: data.bestHour!,
                    color: AppColors.primaryGreen,
                  ),
                ),
              if (data.bestHour != null && data.worstHour != null)
                const SizedBox(width: AppSpacing.sm),
              if (data.worstHour != null)
                Expanded(
                  child: _HourCard(
                    label: 'Worst Hour',
                    rate: data.worstHour!,
                    color: AppColors.mutedGrey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (data.topZones.isNotEmpty) ...[
          const SectionHeader('Best Zones'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.topZones.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.cardBorder),
                  _ZoneTile(rank: i + 1, zone: data.topZones[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (data.totalIncentive > 0) ...[
          const SectionHeader('Was the incentive worth it?'),
          _IncentiveCard(data: data),
        ],
      ],
    );
  }
}

class _NetEarningsHeroCard extends StatelessWidget {
  const _NetEarningsHeroCard({required this.data});

  final WeeklyDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Earnings',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(formatRupees(data.net), style: AppTextStyles.bigNumber),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  [
                    if (data.netPerHour != null)
                      '${formatRupees(data.netPerHour!)}/hr',
                    if (data.netPerKm != null)
                      '${formatRupees(data.netPerKm!)}/km',
                  ].join('  •  '),
                  style: AppTextStyles.body.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat(label: 'Gross', value: formatRupees(data.gross)),
              const SizedBox(height: AppSpacing.sm),
              _MiniStat(label: 'Costs', value: formatRupees(data.costs)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.label
              .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
        ),
        Text(
          value,
          style: AppTextStyles.sectionHeader.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

class _HourCard extends StatelessWidget {
  const _HourCard({required this.label, required this.rate, required this.color});

  final String label;
  final HourlyRate rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Text(rate.label, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${formatRupees(rate.ratePerHour)}/hr',
            style: AppTextStyles.statNumber.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({required this.rank, required this.zone});

  final int rank;
  final ZoneRate zone;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
        child: Text(
          '$rank',
          style: AppTextStyles.label.copyWith(color: AppColors.primaryGreen),
        ),
      ),
      title: Text(zone.zone, style: AppTextStyles.body),
      trailing: Text(
        '${formatRupees(zone.ratePerKm)}/km',
        style: AppTextStyles.sectionHeader,
      ),
    );
  }
}

class _IncentiveCard extends StatelessWidget {
  const _IncentiveCard({required this.data});

  final WeeklyDashboardData data;

  @override
  Widget build(BuildContext context) {
    final upliftPercent = data.incentiveUpliftPercent;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('With incentive', style: AppTextStyles.label),
                Row(
                  children: [
                    Text(formatRupees(data.net), style: AppTextStyles.statNumber),
                    if (upliftPercent != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '(↑${upliftPercent.toStringAsFixed(0)}%)',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primaryGreen),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.cardBorder),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Without', style: AppTextStyles.label),
                Text(
                  formatRupees(data.netWithoutIncentive),
                  style: AppTextStyles.statNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('AsliKamai', style: Theme.of(context).textTheme.titleLarge),
        Text(
          'असली कमाई',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.mutedGrey),
        ),
      ],
    );
  }
}

class _OfflinePill extends StatelessWidget {
  const _OfflinePill();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.mutedGrey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Offline',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.mutedGrey),
        ),
      ],
    );
  }
}
