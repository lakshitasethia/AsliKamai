import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/platform.dart';
import '../models/rate_cut_alert.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency.dart';
import '../utils/relative_date.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';

/// "View Full Details" for a detected rate cut (mockup screen 3's alert
/// card, build_execution.md Phase 5): before/after ₹/km and the this-week
/// orders used as evidence.
class RateCutDetailsScreen extends StatelessWidget {
  const RateCutDetailsScreen({super.key, required this.alert});

  final RateCutAlert alert;

  @override
  Widget build(BuildContext context) {
    final platform = GigPlatform.fromKey(alert.platform);
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Rate Cut Alert')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Row(
            children: [
              Icon(platform.icon, color: platform.color),
              const SizedBox(width: AppSpacing.sm),
              Text(platform.label, style: AppTextStyles.screenTitle),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last week', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${formatRupees(alert.lastWeekRatePerKm)}/km',
                        style: AppTextStyles.statNumber,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.mutedGrey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('This week', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${formatRupees(alert.thisWeekRatePerKm)}/km',
                        style: AppTextStyles.statNumber
                            .copyWith(color: AppColors.redAlert),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'That\'s a ${alert.dropPercent.toStringAsFixed(0)}% drop in pay '
            'per kilometre on ${platform.label} compared to last week.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Evidence (this week\'s orders)', style: AppTextStyles.sectionHeader),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < alert.evidenceOrders.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.cardBorder),
                  _EvidenceTile(order: alert.evidenceOrders[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final distanceKm = order.distanceKm;
    final totalPay = order.basePay + order.incentive + order.tip;
    final ratePerKm =
        distanceKm != null && distanceKm > 0 ? totalPay / distanceKm : null;

    return ListTile(
      title: Text(
        distanceKm == null
            ? formatRupees(totalPay)
            : '${formatRupees(totalPay)} • ${distanceKm.toStringAsFixed(1)} km',
        style: AppTextStyles.body,
      ),
      subtitle: Text(
        formatRelativeDate(order.timestamp),
        style: AppTextStyles.bodyMuted,
      ),
      trailing: ratePerKm == null
          ? null
          : Text('${formatRupees(ratePerKm)}/km', style: AppTextStyles.sectionHeader),
    );
  }
}
