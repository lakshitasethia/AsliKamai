import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../models/expense_category.dart';
import '../services/speech_service.dart';
import '../services/voice_expense_parser.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency.dart';
import '../utils/relative_date.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_title.dart';

/// Costs tab — voice-first expense entry (mockup screen 4): tap the mic,
/// say e.g. "petrol 300", and it's logged. Falls back to typing when voice
/// isn't available or doesn't parse cleanly.
class CostsScreen extends StatefulWidget {
  const CostsScreen({super.key});

  @override
  State<CostsScreen> createState() => _CostsScreenState();
}

enum _MicState { idle, initializing, listening, unavailable }

class _CostsScreenState extends State<CostsScreen> {
  final _speech = SpeechService();
  final _manualController = TextEditingController();
  _MicState _micState = _MicState.idle;
  String _liveTranscript = '';

  @override
  void dispose() {
    _speech.stopListening();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_micState == _MicState.listening) {
      await _speech.stopListening();
      if (mounted) setState(() => _micState = _MicState.idle);
      return;
    }

    setState(() => _micState = _MicState.initializing);
    final available = await _speech.init(
      onStatus: _handleSpeechStatus,
      onError: _handleSpeechError,
    );
    if (!mounted) return;

    if (!available) {
      setState(() => _micState = _MicState.unavailable);
      return;
    }

    setState(() {
      _micState = _MicState.listening;
      _liveTranscript = '';
    });

    await _speech.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() => _liveTranscript = text);
        if (isFinal) {
          setState(() => _micState = _MicState.idle);
          if (text.trim().isNotEmpty) _handleRecognizedText(text);
        }
      },
    );
  }

  /// Independent of [_handleRecognizedText]/[onResult]: the recognizer can
  /// stop listening (timeout, silence, platform-initiated) without ever
  /// delivering a final result, which would otherwise leave the UI stuck
  /// showing "Listening..." forever.
  void _handleSpeechStatus(String status) {
    if (!mounted) return;
    if ((status == 'notListening' || status == 'done') &&
        _micState == _MicState.listening) {
      setState(() => _micState = _MicState.idle);
    }
  }

  void _handleSpeechError(String errorMsg) {
    if (!mounted) return;
    setState(() => _micState = _MicState.idle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S(context).couldntHearThat)),
    );
  }

  void _handleRecognizedText(String text) {
    final parsed = parseExpensePhrase(text);
    if (parsed == null) {
      _manualController.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S(context).couldntMakeOutAmount(text))),
      );
      return;
    }
    _saveExpense(parsed);
  }

  Future<void> _saveExpense(ParsedExpense parsed) async {
    await AppDatabase.instance.insertExpense(
      ExpensesCompanion.insert(
        category: parsed.category.name,
        amount: parsed.amount,
        rawText: Value(parsed.rawText),
        timestamp: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S(context).addedExpense(
            S(context).expenseCategoryLabel(parsed.category.name),
            parsed.amount.toStringAsFixed(0),
          ),
        ),
      ),
    );
  }

  void _submitManualEntry() {
    final text = _manualController.text;
    final parsed = parseExpensePhrase(text);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S(context).enterAmountExample)),
      );
      return;
    }
    _saveExpense(parsed);
    _manualController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.addExpenseTitle)),
      body: StreamBuilder<List<Expense>>(
        stream: AppDatabase.instance.watchRecentExpenses(limit: 100),
        builder: (context, snapshot) {
          final expenses = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                _MicButton(state: _micState, onTap: _toggleListening),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _micStateLabel(s),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualController,
                        decoration: InputDecoration(
                          hintText: s.orTypeExample,
                        ),
                        onSubmitted: (_) => _submitManualEntry(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: _submitManualEntry,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (expenses.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.recent, style: AppTextStyles.label),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: expenses.take(3).map((e) {
                      final cat = ExpenseCategory.fromKey(e.category);
                      return Chip(
                        avatar: Icon(cat.icon, size: 16, color: AppColors.primaryGreen),
                        label: Text(
                          '${s.expenseCategoryLabel(cat.name)} ${formatRupees(e.amount)}',
                        ),
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.cardBorder),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.allExpenses, style: AppTextStyles.label),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < expenses.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: AppColors.cardBorder),
                          _ExpenseTile(expense: expenses[i]),
                        ],
                      ],
                    ),
                  ),
                ] else if (_micState != _MicState.listening) ...[
                  const SizedBox(height: AppSpacing.xl),
                  EmptyState(
                    icon: Icons.mic_none_rounded,
                    title: s.noExpensesYet,
                    message: s.tapMicToAddFirst,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _micStateLabel(Strings s) {
    switch (_micState) {
      case _MicState.idle:
        return s.tapAndSpeakExample;
      case _MicState.initializing:
        return s.starting;
      case _MicState.listening:
        return _liveTranscript.isEmpty ? s.listening : _liveTranscript;
      case _MicState.unavailable:
        return s.voiceNotAvailable;
    }
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.state, required this.onTap});

  final _MicState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final listening = state == _MicState.listening;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: listening ? AppColors.redAlert : AppColors.primaryGreen,
          boxShadow: listening
              ? [
                  BoxShadow(
                    color: AppColors.redAlert.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Icon(
          listening ? Icons.stop : Icons.mic,
          color: AppColors.white,
          size: 48,
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  Future<void> _edit(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExpenseEditSheet(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.fromKey(expense.category);
    return ListTile(
      onTap: () => _edit(context),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
        child: Icon(category.icon, color: AppColors.primaryGreen),
      ),
      title: Text(S(context).expenseCategoryLabel(category.name), style: AppTextStyles.body),
      subtitle: Text(formatRelativeDate(expense.timestamp), style: AppTextStyles.bodyMuted),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatRupees(expense.amount), style: AppTextStyles.sectionHeader),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.mutedGrey),
            onPressed: () => AppDatabase.instance.deleteExpense(expense.id),
          ),
        ],
      ),
    );
  }
}

class _ExpenseEditSheet extends StatefulWidget {
  const _ExpenseEditSheet({required this.expense});

  final Expense expense;

  @override
  State<_ExpenseEditSheet> createState() => _ExpenseEditSheetState();
}

class _ExpenseEditSheetState extends State<_ExpenseEditSheet> {
  late ExpenseCategory _category = ExpenseCategory.fromKey(widget.expense.category);
  late final _amount =
      TextEditingController(text: widget.expense.amount.toStringAsFixed(0));

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S(context).enterValidAmount)));
      return;
    }
    await AppDatabase.instance.updateExpense(
      widget.expense.id,
      ExpensesCompanion(
        category: Value(_category.name),
        amount: Value(amount),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await AppDatabase.instance.deleteExpense(widget.expense.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S(context).editExpense, style: AppTextStyles.screenTitle),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<ExpenseCategory>(
            initialValue: _category,
            decoration: InputDecoration(labelText: S(context).category),
            items: ExpenseCategory.values
                .map((c) => DropdownMenuItem(
                    value: c, child: Text(S(context).expenseCategoryLabel(c.name))))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: S(context).amountRupees),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(onPressed: _save, child: Text(S(context).saveChanges)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _delete,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.redAlert),
            child: Text(S(context).delete),
          ),
        ],
      ),
    );
  }
}
