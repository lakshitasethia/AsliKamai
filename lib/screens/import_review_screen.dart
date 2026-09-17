import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../models/parsed_order.dart';
import '../models/platform.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';

/// Screenshot Review screen (mockup screen 2): one card per imported
/// screenshot, tap to correct any field, then "Confirm & Save (N orders)".
class ImportReviewScreen extends StatefulWidget {
  const ImportReviewScreen({super.key, required this.parsedOrders});

  final List<ParsedOrder> parsedOrders;

  @override
  State<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends State<ImportReviewScreen> {
  late final List<ParsedOrder> _orders = List.of(widget.parsedOrders);
  bool _saving = false;

  int get _validCount => _orders.where((o) => !o.parseFailed).length;

  Future<void> _editOrder(int index) async {
    final edited = await showModalBottomSheet<ParsedOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderEditSheet(order: _orders[index]),
    );
    if (edited != null) {
      setState(() => _orders[index] = edited);
    }
  }

  void _removeOrder(int index) {
    setState(() => _orders.removeAt(index));
  }

  Future<void> _confirmAndSave() async {
    setState(() => _saving = true);
    final db = AppDatabase.instance;
    var savedCount = 0;
    for (final order in _orders.where((o) => !o.parseFailed)) {
      final inserted = await db.insertOrderIfNew(
        OrdersCompanion.insert(
          platform: order.platform.name,
          orderRef: Value(order.orderRef),
          timestamp: order.timestamp,
          basePay: order.basePay,
          incentive: Value(order.incentive),
          tip: Value(order.tip),
          distanceKm: Value(order.distanceKm),
          durationMin: Value(order.durationMin),
          zone: Value(order.zone),
          sourceScreenshotHash: Value(order.sourceScreenshotHash),
        ),
      );
      if (inserted) savedCount++;
    }
    if (!mounted) return;
    Navigator.of(context).pop(savedCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const ScreenTitle('Screenshot Review (OCR)'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Review and correct the details. We\'ll save these to '
                'your weekly report.',
                style: AppTextStyles.bodyMuted,
              ),
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? Center(
                    child: Text('Nothing left to save.',
                        style: AppTextStyles.bodyMuted),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: _orders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _OrderReviewCard(
                      order: _orders[i],
                      onTap: () => _editOrder(i),
                      onRemove: () => _removeOrder(i),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ElevatedButton(
              onPressed: (_validCount == 0 || _saving) ? null : _confirmAndSave,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Confirm & Save ($_validCount '
                      '${_validCount == 1 ? 'order' : 'orders'})',
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _OrderReviewCard extends StatelessWidget {
  const _OrderReviewCard({
    required this.order,
    required this.onTap,
    required this.onRemove,
  });

  final ParsedOrder order;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (order.parseFailed) {
      return AppCard(
        onTap: onTap,
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.redAlert),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Couldn\'t read this screenshot. Tap to enter manually, '
                'or remove it.',
                style: AppTextStyles.body,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.mutedGrey),
              onPressed: onRemove,
            ),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: order.platform.color.withValues(alpha: 0.15),
            child: Icon(order.platform.icon, color: order.platform.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.platform.label, style: AppTextStyles.sectionHeader),
                Text(
                  [
                    if (order.distanceKm != null)
                      '${order.distanceKm!.toStringAsFixed(1)} km',
                    if (order.durationMin != null) '${order.durationMin} min',
                    if (order.orderRef != null) 'Order # ${order.orderRef}',
                  ].join(' • '),
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
          Text('₹${order.totalPay.toStringAsFixed(0)}',
              style: AppTextStyles.statNumber),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.check_circle, color: AppColors.primaryGreen),
        ],
      ),
    );
  }
}

class _OrderEditSheet extends StatefulWidget {
  const _OrderEditSheet({required this.order});

  final ParsedOrder order;

  @override
  State<_OrderEditSheet> createState() => _OrderEditSheetState();
}

class _OrderEditSheetState extends State<_OrderEditSheet> {
  late GigPlatform _platform = widget.order.platform;
  late final _basePay =
      TextEditingController(text: widget.order.basePay.toStringAsFixed(0));
  late final _incentive =
      TextEditingController(text: widget.order.incentive.toStringAsFixed(0));
  late final _tip =
      TextEditingController(text: widget.order.tip.toStringAsFixed(0));
  late final _distance = TextEditingController(
      text: widget.order.distanceKm?.toStringAsFixed(1) ?? '');
  late final _duration =
      TextEditingController(text: widget.order.durationMin?.toString() ?? '');
  late final _zone = TextEditingController(text: widget.order.zone ?? '');
  late final _orderRef =
      TextEditingController(text: widget.order.orderRef ?? '');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.md,
        // viewInsets covers the keyboard; viewPadding covers the system nav
        // bar — a bottom sheet gets neither for free, unlike a Scaffold body.
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit order', style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<GigPlatform>(
              initialValue: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              items: GigPlatform.values
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v ?? _platform),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _NumberField(label: 'Base pay (₹)', controller: _basePay),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NumberField(label: 'Incentive (₹)', controller: _incentive),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _NumberField(label: 'Tip (₹)', controller: _tip),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NumberField(
                    label: 'Distance (km)',
                    controller: _distance,
                    allowDecimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                      label: 'Duration (min)', controller: _duration),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _zone,
                    decoration: const InputDecoration(labelText: 'Zone'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _orderRef,
              decoration: const InputDecoration(labelText: 'Order #'),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                widget.order
                  ..platform = _platform
                  ..basePay = double.tryParse(_basePay.text) ?? 0
                  ..incentive = double.tryParse(_incentive.text) ?? 0
                  ..tip = double.tryParse(_tip.text) ?? 0
                  ..distanceKm = double.tryParse(_distance.text)
                  ..durationMin = int.tryParse(_duration.text)
                  ..zone = _zone.text.isEmpty ? null : _zone.text
                  ..orderRef = _orderRef.text.isEmpty ? null : _orderRef.text
                  ..parseFailed = false;
                Navigator.of(context).pop(widget.order);
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    this.allowDecimal = false,
  });

  final String label;
  final TextEditingController controller;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(labelText: label),
    );
  }
}
