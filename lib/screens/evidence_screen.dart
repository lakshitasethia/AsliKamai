import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../models/evidence_type.dart';
import '../services/evidence_pdf_export.dart';
import '../services/image_hash.dart';
import '../services/screenshot_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/relative_date.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_title.dart';
import 'evidence_detail_screen.dart';

/// Evidence Locker tab (mockup screen 5, build_execution.md Phase 6):
/// tamper-evident document storage — block/suspension notices, support
/// tickets, payout statements — each hashed at capture time, viewable by
/// category, exportable to a single PDF.
class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 4, vsync: this);
  final _picker = ImagePicker();
  bool _exporting = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addDocuments() async {
    List<XFile> files;
    try {
      // No imageQuality: that re-encodes to a lossy JPEG, so the stored
      // SHA-256 could never be matched against the rider's original file —
      // useless as tamper-evident proof in a dispute.
      files = await _picker.pickMultiImage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S(context).couldntOpenGallery)),
      );
      return;
    }
    if (files.isEmpty) return;
    if (!mounted) return;

    final type = await showModalBottomSheet<EvidenceType>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _TypePickerSheet(),
    );
    if (type == null || !mounted) return;

    var savedCount = 0;
    for (final file in files) {
      final bytes = await File(file.path).readAsBytes();
      final hash = hashImageBytes(bytes);
      final path = await saveScreenshot(bytes: bytes, hash: hash);
      final inserted = await AppDatabase.instance.insertEvidenceIfNew(
        EvidenceItemsCompanion.insert(
          type: type.name,
          filePath: path,
          fileHash: hash,
          capturedAt: DateTime.now(),
        ),
      );
      if (inserted) savedCount++;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedCount == 0
              ? S(context).alreadySavedNoNew
              : S(context).addedDocuments(savedCount),
        ),
      ),
    );
  }

  Future<void> _exportToPdf(List<EvidenceItem> items) async {
    if (items.isEmpty || _exporting) return;
    setState(() => _exporting = true);
    try {
      final bytes = await buildEvidencePdf(items);
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: 'AsliKamai_Evidence.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S(context).couldntExportPdf)),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(s.evidenceLockerTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: s.tabAll),
            for (final type in EvidenceType.values)
              Tab(text: s.evidenceTypeLabel(type.name)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: _addDocuments,
            tooltip: s.addDocument,
          ),
        ],
      ),
      body: StreamBuilder<List<EvidenceItem>>(
        stream: AppDatabase.instance.watchAllEvidence(),
        builder: (context, snapshot) {
          final all = snapshot.data;
          if (all == null) return const SizedBox.shrink();

          return TabBarView(
            controller: _tabController,
            children: [
              _EvidenceList(
                items: all,
                exporting: _exporting,
                onExport: () => _exportToPdf(all),
                onAdd: _addDocuments,
              ),
              for (final type in EvidenceType.values)
                _EvidenceList(
                  items: all.where((e) => e.type == type.name).toList(),
                  exporting: _exporting,
                  onExport: () => _exportToPdf(
                    all.where((e) => e.type == type.name).toList(),
                  ),
                  onAdd: _addDocuments,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EvidenceList extends StatelessWidget {
  const _EvidenceList({
    required this.items,
    required this.exporting,
    required this.onExport,
    required this.onAdd,
  });

  final List<EvidenceItem> items;
  final bool exporting;
  final VoidCallback onExport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.lock_outline_rounded,
        title: S(context).noEvidenceYet,
        message: S(context).addDocumentsFromGallery,
        actionLabel: S(context).addDocument,
        onAction: onAdd,
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _EvidenceTile(item: items[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            0,
            AppSpacing.screenPadding,
            AppSpacing.md,
          ),
          child: OutlinedButton.icon(
            onPressed: exporting ? null : onExport,
            icon: exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(S(context).exportToPdf(items.length)),
          ),
        ),
      ],
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.item});

  final EvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final type = EvidenceType.fromKey(item.type);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EvidenceDetailScreen(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.file(File(item.filePath), fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(type.icon, size: 14, color: AppColors.primaryGreen),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          S(context).evidenceTypeLabel(type.name),
                          style: AppTextStyles.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatRelativeDate(item.capturedAt, S(context)),
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePickerSheet extends StatelessWidget {
  const _TypePickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S(context).saveAs, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            for (final type in EvidenceType.values)
              ListTile(
                leading: Icon(type.icon, color: AppColors.primaryGreen),
                title: Text(S(context).evidenceTypeLabel(type.name)),
                onTap: () => Navigator.of(context).pop(type),
              ),
          ],
        ),
      ),
    );
  }
}
