import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../models/evidence_type.dart';
import '../models/letter_template.dart';
import '../models/platform.dart';
import '../models/rider_profile.dart';
import '../services/gemini_vision_service.dart';
import '../services/letter_content.dart';
import '../services/letter_pdf_export.dart';
import '../services/letter_pdf_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency.dart';
import '../widgets/screen_title.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

/// Fill-in form for one letter template (Phase 7): rider name (pre-filled
/// from [RiderProfile], saved back on generate), language, platform, and
/// whatever fields that template needs — optionally auto-filled by picking
/// a real Order or Notice-type Evidence item rather than typing by hand.
class LetterFormScreen extends StatefulWidget {
  const LetterFormScreen({super.key, required this.type});

  final LetterTemplateType type;

  @override
  State<LetterFormScreen> createState() => _LetterFormScreenState();
}

class _LetterFormScreenState extends State<LetterFormScreen> {
  final _nameController = TextEditingController();
  final _orderRefController = TextEditingController();
  final _orderDateController = TextEditingController();
  final _orderAmountController = TextEditingController();
  final _blockDateController = TextEditingController();
  final _detailsController = TextEditingController();

  GigPlatform _platform = GigPlatform.swiggy;
  LetterLanguage _lang = LetterLanguage.english;
  bool _generating = false;
  bool _readingNoticeDate = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderRefController.dispose();
    _orderDateController.dispose();
    _orderAmountController.dispose();
    _blockDateController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await RiderProfile.load();
    if (!mounted) return;
    setState(() => _nameController.text = profile.name);
  }

  Future<void> _pickOrder() async {
    final orders = await AppDatabase.instance.recentOrders();
    if (!mounted) return;
    final picked = await showModalBottomSheet<Order>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderPickerSheet(orders: orders),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _platform = GigPlatform.fromKey(picked.platform);
      _orderRefController.text = picked.orderRef ?? '';
      _orderDateController.text = _formatDate(picked.timestamp);
      _orderAmountController.text =
          (picked.basePay + picked.incentive + picked.tip).toStringAsFixed(0);
    });
  }

  Future<void> _pickNotice() async {
    final all = await AppDatabase.instance.watchAllEvidence().first;
    final notices =
        all.where((e) => e.type == EvidenceType.notice.name).toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<EvidenceItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NoticePickerSheet(notices: notices),
    );
    if (picked == null || !mounted) return;

    // A notice added by hand is stamped with the day it was added, not the
    // day the ID was blocked — so read the date printed on the notice
    // itself (once; it's cached on the row after that).
    var date = picked.documentDate;
    if (date == null) {
      setState(() => _readingNoticeDate = true);
      try {
        date = await GeminiVisionService()
            .readDocumentDate(await File(picked.filePath).readAsBytes());
        if (date != null) {
          await AppDatabase.instance.setEvidenceDocumentDate(picked.id, date);
        }
      } catch (e) {
        debugPrint('AsliKamai: reading notice date failed: $e');
      }
      if (!mounted) return;
      setState(() => _readingNoticeDate = false);
      if (date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S(context).noticeDateUnreadable)),
        );
      }
    }
    setState(() => _blockDateController.text =
        _formatDate(date ?? picked.capturedAt));
  }

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) return false;
    switch (widget.type) {
      case LetterTemplateType.deductionExplanation:
        return _orderRefController.text.trim().isNotEmpty &&
            _orderDateController.text.trim().isNotEmpty &&
            _orderAmountController.text.trim().isNotEmpty;
      case LetterTemplateType.idBlockReasons:
        return _blockDateController.text.trim().isNotEmpty;
      case LetterTemplateType.grievanceFiling:
        return _detailsController.text.trim().isNotEmpty;
    }
  }

  Future<void> _generate() async {
    if (!_isValid || _generating) return;
    setState(() => _generating = true);
    try {
      final name = _nameController.text.trim();
      await RiderProfile.saveName(name);

      final data = LetterData(
        riderName: name,
        platform: _platform.label,
        todayDate: _formatDate(DateTime.now()),
        orderRef: _orderRefController.text.trim(),
        orderDate: _orderDateController.text.trim(),
        orderAmount: _orderAmountController.text.trim(),
        blockDate: _blockDateController.text.trim(),
        details: _detailsController.text.trim(),
      );
      final body = buildLetterBody(type: widget.type, lang: _lang, data: data);
      final bytes = await buildLetterPdf(type: widget.type, lang: _lang, body: body);
      final fileName =
          '${widget.type.name}_${_lang.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = await saveLetterPdf(bytes: bytes, fileName: fileName);

      await AppDatabase.instance.insertLetter(
        LettersCompanion.insert(
          templateId: widget.type.name,
          lang: _lang.name,
          filePath: path,
          generatedAt: DateTime.now(),
        ),
      );

      await Printing.layoutPdf(onLayout: (_) => bytes, name: fileName);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.letterTemplateLabel(widget.type.name))),
      body: SafeArea(
        // Pushed routes sit outside RootShell's SafeArea; without this,
        // Android 15+ edge-to-edge draws the bottom under the nav bar.
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.redAlert.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.redAlert.withValues(alpha: 0.3)),
              ),
              child: Text(
                s.letterFormNotLegalAdvice,
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: s.yourName),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<GigPlatform>(
              initialValue: _platform,
              decoration: InputDecoration(labelText: s.platformLabel),
              items: GigPlatform.values
                  .where((p) => p != GigPlatform.other)
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v ?? _platform),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(s.language, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final lang in LetterLanguage.selectable)
                  ChoiceChip(
                    label: Text(lang.label),
                    selected: _lang == lang,
                    onSelected: (_) => setState(() => _lang = lang),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ..._templateFields(s),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isValid && !_generating ? _generate : null,
              child: _generating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : Text(s.generateAndPreview),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _templateFields(Strings s) {
    switch (widget.type) {
      case LetterTemplateType.deductionExplanation:
        return [
          OutlinedButton.icon(
            onPressed: _pickOrder,
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(s.referenceAnOrder),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _orderRefController,
            decoration: InputDecoration(labelText: s.orderNumberFieldLabel),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _orderDateController,
            decoration: InputDecoration(labelText: s.orderDateLabel),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _orderAmountController,
            decoration: InputDecoration(labelText: s.amountPaidLabel),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ];
      case LetterTemplateType.idBlockReasons:
        return [
          OutlinedButton.icon(
            onPressed: _readingNoticeDate ? null : _pickNotice,
            icon: _readingNoticeDate
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.warning_amber_rounded),
            label: Text(
              _readingNoticeDate ? s.readingNoticeDate : s.referenceANotice,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _blockDateController,
            decoration: InputDecoration(labelText: s.dateIdBlocked),
            onChanged: (_) => setState(() {}),
          ),
        ];
      case LetterTemplateType.grievanceFiling:
        return [
          TextField(
            controller: _detailsController,
            decoration: InputDecoration(
              labelText: s.describeIssue,
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            onChanged: (_) => setState(() {}),
          ),
        ];
    }
  }
}

class _OrderPickerSheet extends StatelessWidget {
  const _OrderPickerSheet({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S(context).pickAnOrder, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(S(context).noOrdersImportedYet, style: AppTextStyles.bodyMuted),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    final o = orders[i];
                    final platform = GigPlatform.fromKey(o.platform);
                    final total = o.basePay + o.incentive + o.tip;
                    return ListTile(
                      leading: Icon(platform.icon, color: platform.color),
                      title: Text('${platform.label} • ${o.orderRef ?? S(context).noRef}'),
                      subtitle: Text(_formatDate(o.timestamp)),
                      trailing: Text(formatRupees(total)),
                      onTap: () => Navigator.of(context).pop(o),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoticePickerSheet extends StatelessWidget {
  const _NoticePickerSheet({required this.notices});

  final List<EvidenceItem> notices;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S(context).pickANotice, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            if (notices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  S(context).noNoticesSaved,
                  style: AppTextStyles.bodyMuted,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notices.length,
                  itemBuilder: (context, i) {
                    final e = notices[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(e.filePath),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(_formatDate(e.documentDate ?? e.capturedAt)),
                      subtitle: e.notes != null ? Text(e.notes!) : null,
                      onTap: () => Navigator.of(context).pop(e),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
