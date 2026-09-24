import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../utils/relative_date.dart';
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
          screenshotPath: Value(order.screenshotPath),
        ),
      );
      if (inserted) savedCount++;
    }
    if (!mounted) return;
    Navigator.of(context).pop(savedCount);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: ScreenTitle(s.screenshotReviewTitle),
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
                s.reviewAndCorrectPrompt,
                style: AppTextStyles.bodyMuted,
              ),
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? Center(
                    child: Text(s.nothingLeftToSave,
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
                  : Text(s.confirmAndSave(_validCount)),
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
                S(context).couldntReadScreenshotEntry,
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
                    if (order.orderRef != null)
                      S(context).orderNumberInline(order.orderRef!),
                  ].join(' • '),
                  style: AppTextStyles.bodyMuted,
                ),
                if (order.dateMissing)
                  Text(S(context).dateNotOnScreenshot,
                      style: AppTextStyles.bodyMuted.copyWith(color: AppColors.redAlert))
                else
                  Text(formatRelativeDate(order.timestamp, S(context)),
                      style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          Text('₹${order.totalPay.toStringAsFixed(0)}',
              style: AppTextStyles.statNumber),
          const SizedBox(width: AppSpacing.xs),
          order.dateMissing
              ? const Icon(Icons.edit_calendar, color: AppColors.redAlert)
              : const Icon(Icons.check_circle, color: AppColors.primaryGreen),
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
  late DateTime _timestamp = widget.order.timestamp;
  late bool _dateMissing = widget.order.dateMissing;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp.isAfter(DateTime.now()) ? DateTime.now() : _timestamp,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    final t = time ?? TimeOfDay.fromDateTime(_timestamp);
    setState(() {
      _timestamp = DateTime(date.year, date.month, date.day, t.hour, t.minute);
      _dateMissing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
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
            Text(s.editOrder, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<GigPlatform>(
              initialValue: _platform,
              decoration: InputDecoration(labelText: s.platformLabel),
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
                  child: _NumberField(label: s.basePayLabel, controller: _basePay),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NumberField(label: s.incentiveLabel, controller: _incentive),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _NumberField(label: s.tipLabel, controller: _tip),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NumberField(
                    label: s.distanceKmLabel,
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
                      label: s.durationMinLabel, controller: _duration),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _zone,
                    decoration: InputDecoration(labelText: s.zoneLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _orderRef,
              decoration: InputDecoration(labelText: s.orderNumberFieldLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: s.orderDateLabel,
                  suffixIcon: const Icon(Icons.edit_calendar),
                  errorText: _dateMissing ? s.dateNotOnScreenshot : null,
                ),
                child: Text(formatRelativeDate(_timestamp, s)),
              ),
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
                  ..timestamp = _timestamp
                  ..dateMissing = _dateMissing
                  ..parseFailed = false;
                Navigator.of(context).pop(widget.order);
              },
              child: Text(s.saveChanges),
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
