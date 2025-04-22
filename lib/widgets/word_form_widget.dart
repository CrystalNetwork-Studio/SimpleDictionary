import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../providers/dictionary_provider.dart';

/// A reusable form widget for adding or editing words in dictionaries.
class WordFormWidget extends StatefulWidget {
  /// The initial word data (null for new words)
  final Word? initialWord;

  /// The type of dictionary this word belongs to
  final DictionaryType dictionaryType;

  /// Whether the form is in edit mode
  final bool isEditMode;

  /// Callback when save button is pressed
  final Future<bool> Function(Word word) onSave;

  /// Callback when delete button is pressed (only in edit mode)
  final Future<String?> Function()? onDelete;

  /// Optional maximum length for term and translation fields
  final int? maxLength;

  const WordFormWidget({
    required this.dictionaryType,
    required this.onSave,
    this.initialWord,
    this.isEditMode = false,
    this.onDelete,
    this.maxLength,
    super.key,
  });

  @override
  State<WordFormWidget> createState() => _WordFormWidgetState();
}

class _WordFormWidgetState extends State<WordFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _termController;
  late TextEditingController _translationController;
  late TextEditingController _descriptionController;

  bool _isSaving = false;
  bool _isDeleting = false;
  String? _localError;

  int? _effectiveMaxLength;
  bool _descriptionAllowed = true;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with initial values if in edit mode
    _termController = TextEditingController(
      text: widget.initialWord?.term ?? '',
    );
    _translationController = TextEditingController(
      text: widget.initialWord?.translation ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialWord?.description ?? '',
    );

    // Set up text field constraints based on dictionary type
    _setupFieldConstraints();

    // Add listeners for length limiting
    _addTextControllerListeners();
  }

  void _setupFieldConstraints() {
    switch (widget.dictionaryType) {
      case DictionaryType.word:
        _effectiveMaxLength = widget.maxLength ?? 14;
        _descriptionAllowed = true;
        break;
      case DictionaryType.phrase:
        _effectiveMaxLength = widget.maxLength ?? 23;
        _descriptionAllowed = true;
        break;
      case DictionaryType.sentence:
        _effectiveMaxLength = widget.maxLength;
        _descriptionAllowed = false;
        break;
    }
  }

  void _addTextControllerListeners() {
    // Add listeners to enforce max length constraints
    _termController.addListener(() {
      _enforceMaxLength(_termController);
    });

    _translationController.addListener(() {
      _enforceMaxLength(_translationController);
    });
  }

  void _enforceMaxLength(TextEditingController controller) {
    final text = controller.text;
    if (_effectiveMaxLength != null && text.length > _effectiveMaxLength!) {
      controller.value = controller.value.copyWith(
        text: text.substring(0, _effectiveMaxLength!),
        selection: TextSelection.collapsed(offset: _effectiveMaxLength!),
      );
    }
  }

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lengthFormatters = _effectiveMaxLength != null
        ? [LengthLimitingTextInputFormatter(_effectiveMaxLength)]
        : <TextInputFormatter>[];

    final bool canInteract = !_isSaving && !_isDeleting;
    final errorColor = Theme.of(context).colorScheme.error;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Material(
      color: Colors.transparent,
      child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _termController,
            maxLength: _effectiveMaxLength,
            inputFormatters: lengthFormatters,
            decoration: InputDecoration(
              labelText: l10n.word,
              counterText: _effectiveMaxLength != null ? "" : null,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterWord;
              }
              if (_effectiveMaxLength != null && value.length > _effectiveMaxLength!) {
                return l10n.maxLengthValidation(_effectiveMaxLength!);
              }
              if (value.contains('\n') || value.contains('/n')) {
                return l10n.noNewlinesAllowed;
              }
              return null;
            },
            enabled: canInteract,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _translationController,
            maxLength: _effectiveMaxLength,
            inputFormatters: lengthFormatters,
            decoration: InputDecoration(
              labelText: l10n.translation,
              counterText: _effectiveMaxLength != null ? "" : null,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterTranslation;
              }
              if (_effectiveMaxLength != null && value.length > _effectiveMaxLength!) {
                return l10n.maxLengthValidation(_effectiveMaxLength!);
              }
              if (value.contains('\n') || value.contains('/n')) {
                return l10n.noNewlinesAllowed;
              }
              return null;
            },
            enabled: canInteract,
          ),
          const SizedBox(height: 16),
          if (_descriptionAllowed)
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.descriptionOptional,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: canInteract,
              validator: (value) {
                if (value != null && (value.contains('\n') || value.contains('/n'))) {
                  return l10n.noNewlinesAllowed;
                }
                return null;
              },
            ),
          if (_descriptionAllowed) const SizedBox(height: 24),
          if (!_descriptionAllowed) const SizedBox(height: 16),

          // Error message display
          if (_localError != null) ...[
            const SizedBox(height: 16),
            Text(
              _localError!,
              style: TextStyle(color: errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.isEditMode && widget.onDelete != null)
                  IconButton(
                    onPressed: canInteract ? _handleDelete : null,
                    icon: _isDeleting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: errorColor,
                            ),
                          )
                        : Icon(Icons.delete_outline, color: errorColor),
                    tooltip: l10n.delete,
                  )
                else
                  const SizedBox(),

                ElevatedButton(
                  onPressed: canInteract ? _submitForm : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: onPrimaryColor,
                          ),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSaving && !_isDeleting) {
      setState(() {
        _isSaving = true;
        _localError = null;
      });

      final word = Word(
        term: _termController.text.trim(),
        translation: _translationController.text.trim(),
        description: _descriptionAllowed && _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      try {
        final success = await widget.onSave(word);

        if (!mounted) return;

        if (success) {
          // Let the parent handle navigation
          return;
        } else {
          // Show error from provider
          final error = Provider.of<DictionaryProvider>(context, listen: false).error;
          setState(() {
            _localError = error ?? AppLocalizations.of(context)!.failedToUpdateWord;
            _isSaving = false;
          });
          Provider.of<DictionaryProvider>(context, listen: false).clearError();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _localError = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    if (widget.onDelete == null || !widget.isEditMode) return;

    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.confirmDeleteWord(_termController.text.trim())),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
      _localError = null;
    });

    try {
      final deletedTerm = await widget.onDelete!();

      if (!mounted) return;

      if (deletedTerm != null) {
        // Let the parent handle navigation and success message
        return;
      } else {
        // Show error from provider
        final error = Provider.of<DictionaryProvider>(context, listen: false).error;
        setState(() {
          _localError = error ?? l10n.failedToDeleteWord;
          _isDeleting = false;
        });
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localError = e.toString();
        _isDeleting = false;
      });
    }
  }
}
