import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../providers/dictionary_provider.dart';

class AddWordScreen extends StatefulWidget {
  final Future<bool> Function(Word) onWordAdded;
  final DictionaryType dictionaryType; // Тип словника передається сюди

  const AddWordScreen({
    required this.onWordAdded,
    required this.dictionaryType, // Отримуємо тип
    super.key,
  });

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _translationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  // Допоміжні змінні для налаштувань UI на основі типу
  int? _maxLength;
  bool _descriptionAllowed = true;

  @override
  void initState() {
    super.initState();
    // Визначаємо налаштування на основі типу словника
    switch (widget.dictionaryType) {
      case DictionaryType.word:
        _maxLength = 14;
        _descriptionAllowed = true;
        break;
      case DictionaryType.phrase:
        _maxLength = 23;
        _descriptionAllowed = false;
        break;
      case DictionaryType.sentence:
        _maxLength = null; // Без обмежень
        _descriptionAllowed = false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Створюємо список форматерів довжини, якщо є обмеження
    final lengthFormatters =
        _maxLength != null
            ? [LengthLimitingTextInputFormatter(_maxLength)]
            : <TextInputFormatter>[]; // Порожній список, якщо немає обмежень

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNewWord)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Поле Термін/Слово ---
            TextFormField(
              controller: _termController,
              maxLength: _maxLength, // Динамічний maxLength
              inputFormatters: lengthFormatters, // Динамічні форматери
              decoration: InputDecoration(
                labelText: l10n.word, // Можливо, варто змінити на "Термін"?
                // Приховуємо лічильник, якщо є обмеження (щоб не дублювати)
                counterText: _maxLength != null ? "" : null,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n
                      .pleaseEnterWord; // "Будь ласка, введіть слово/термін"
                }
                // Валідація довжини, якщо є обмеження
                if (_maxLength != null && value.length > _maxLength!) {
                  // Використовуємо новий рядок локалізації
                  return l10n.maxLengthValidation(_maxLength!);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Поле Переклад ---
            TextFormField(
              controller: _translationController,
              maxLength: _maxLength, // Динамічний maxLength
              inputFormatters: lengthFormatters, // Динамічні форматери
              decoration: InputDecoration(
                labelText: l10n.translation,
                counterText: _maxLength != null ? "" : null,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTranslation;
                }
                // Валідація довжини
                if (_maxLength != null && value.length > _maxLength!) {
                  return l10n.maxLengthValidation(_maxLength!);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Поле Опис (умовне) ---
            if (_descriptionAllowed) // Показуємо тільки якщо дозволено типом
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      l10n.descriptionOptional, // Позначити як необов'язковий
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                // Тут валідатор не потрібен, бо поле необов'язкове
              ),
            // Додаємо відступ після опису, якщо він був показаний
            if (_descriptionAllowed) const SizedBox(height: 24),
            // Якщо опису немає, можна зменшити відступ перед кнопкою
            if (!_descriptionAllowed) const SizedBox(height: 16),

            // --- Кнопка Зберегти ---
            ElevatedButton(
              onPressed: _isSaving ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isSaving
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                      : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Перевіряємо валідність форми перед збереженням
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() {
        _isSaving = true;
      });

      // Створюємо об'єкт Word
      final newWord = Word(
        term: _termController.text.trim(),
        translation: _translationController.text.trim(),
        // Додаємо опис тільки якщо поле було видимим і має текст
        description:
            _descriptionAllowed && _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null, // Інакше null
      );

      // Викликаємо callback для додавання слова через провайдер
      final bool addedSuccessfully = await widget.onWordAdded(newWord);

      if (!mounted) return; // Перевірка після асинхронної операції

      if (addedSuccessfully) {
        Navigator.of(context).pop(); // Повертаємось назад при успіху
      } else {
        // Показуємо помилку від провайдера, якщо вона є
        final error =
            Provider.of<DictionaryProvider>(context, listen: false).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? AppLocalizations.of(context)!.failedToAddWord,
            ),
            backgroundColor:
                Theme.of(
                  context,
                ).colorScheme.error, // Використовуємо колір помилки теми
          ),
        );
        // Очищуємо помилку в провайдері після показу
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }

      // Завершуємо індикацію збереження
      setState(() {
        _isSaving = false;
      });
    }
  }
}
