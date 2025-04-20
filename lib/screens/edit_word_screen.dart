import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Переконайтеся, що ці імпорти вказують на ваші реальні файли
import '../data/dictionary.dart'; // Потрібно для Word та DictionaryType
import '../l10n/app_localizations.dart'; // Потрібно для AppLocalizations
import '../providers/dictionary_provider.dart'; // Потрібно для DictionaryProvider

// --- Клас результату діалогу ---
// Визначає, що повертається при закритті діалогу через дії (збереження/видалення)
class EditWordDialogResult {
  final EditWordDialogStatus status;
  final String? deletedWordTerm; // Термін видаленого слова (для сповіщень)

  EditWordDialogResult(this.status, {this.deletedWordTerm});
}

// --- Статуси результату діалогу ---
// Визначають результат операції в діалозі
enum EditWordDialogStatus {
  saved, // Слово було успішно оновлено
  deleted, // Слово було успішно видалено
  error, // Сталася помилка під час операції (не використовується для повернення, але може бути корисним)
  // Статус 'cancelled' більше не потрібен, оскільки скасування обробляється як null-результат showDialog
}

// --- Віджет діалогу редагування ---
class EditWordDialog extends StatefulWidget {
  // Вхідні параметри для віджета
  final String dictionaryName; // Назва словника (для контексту або логування)
  final int wordIndex; // Індекс слова, що редагується
  final Word initialWord; // Початкові дані слова
  final Future<bool> Function(int, Word)
  onWordUpdated; // Асинхронна функція для оновлення слова
  final Future<String?> Function(int)
  onWordDeleted; // Асинхронна функція для видалення слова
  final DictionaryType
  dictionaryType; // Тип словника (впливає на поля та валідацію)

  const EditWordDialog({
    required this.dictionaryName,
    required this.wordIndex,
    required this.initialWord,
    required this.onWordUpdated,
    required this.onWordDeleted,
    required this.dictionaryType,
    super.key, // Ключ віджета
  });

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  // Ключ для доступу до стану форми
  final _formKey = GlobalKey<FormState>();
  // Контролери для текстових полів
  late TextEditingController _termController;
  late TextEditingController _translationController;
  late TextEditingController _descriptionController;
  // Прапорці стану для керування UI (блокування кнопок, показ індикаторів)
  bool _isSaving = false;
  bool _isDeleting = false;
  // Рядок для відображення локальних помилок в діалозі
  String? _localError;

  @override
  void initState() {
    super.initState();
    // Ініціалізація контролерів початковими значеннями слова
    _termController = TextEditingController(text: widget.initialWord.term);
    _translationController = TextEditingController(
      text: widget.initialWord.translation,
    );
    _descriptionController = TextEditingController(
      // Використовуємо порожній рядок, якщо опис null
      text: widget.initialWord.description ?? '',
    );
  }

  @override
  void dispose() {
    // Очищення контролерів при знищенні віджета для уникнення витоків пам'яті
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Отримання доступу до залежностей (Провайдер та Локалізація)
    // Провайдер отримується без прослуховування змін (listen: false),
    // оскільки він використовується лише для виклику методів та отримання помилок.
    final dictionaryProvider = Provider.of<DictionaryProvider>(
      context,
      listen: false,
    );
    // Локалізація для текстів UI
    final localization = AppLocalizations.of(context)!;

    // Визначення стану UI на основі прапорців та типу словника
    final bool canInteract =
        !_isSaving && !_isDeleting; // Чи можна взаємодіяти з полями/кнопками
    final bool isSentence = widget.dictionaryType == DictionaryType.sentence;
    final bool isWord = widget.dictionaryType == DictionaryType.word;
    // Кольори для стилізації (помилка та текст на кнопці)
    final Color errorColor = Theme.of(context).colorScheme.error;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    // Побудова AlertDialog
    return AlertDialog(
      // Заголовок: Текст зліва, кнопка видалення справа
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(localization.editWord), // Текст заголовку
          // Кнопка-іконка для видалення
          IconButton(
            // Умовний рендеринг: індикатор завантаження або іконка кошика
            icon:
                _isDeleting
                    ? SizedBox(
                      width: 24, // Стандартний розмір іконки
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: errorColor,
                      ),
                    )
                    : Icon(Icons.delete_outline, color: errorColor),
            tooltip: localization.delete, // Підказка при наведенні
            // Викликати функцію видалення, якщо можна взаємодіяти
            onPressed:
                canInteract ? () => _handleDelete(dictionaryProvider) : null,
          ),
        ],
      ),
      // Вміст діалогу: форма з полями вводу
      content: Form(
        key: _formKey, // Прив'язка ключа до форми для валідації
        child: SingleChildScrollView(
          // Дозволяє прокрутку контенту
          child: Column(
            mainAxisSize: MainAxisSize.min, // Займати мінімальну висоту
            children: [
              // Поле для введення терміну/фрази
              TextFormField(
                controller: _termController,
                maxLength: isWord ? 23 : null, // Обмеження довжини для слів
                inputFormatters:
                    isWord
                        ? [
                          LengthLimitingTextInputFormatter(23),
                        ] // Форматер для обмеження вводу
                        : null,
                decoration: InputDecoration(
                  labelText: localization.word, // Назва поля
                  counterText: "", // Приховати стандартний лічильник символів
                  border: const OutlineInputBorder(), // Рамка навколо поля
                ),
                // Валідація поля
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization
                        .pleaseEnterWord; // Помилка, якщо поле порожнє
                  }
                  // Додаткова перевірка довжини (хоча форматер вже обмежує)
                  if (isWord && value.length > 23) {
                    return localization.maxLength23;
                  }
                  return null; // Немає помилки
                },
                enabled: canInteract, // Поле активне, якщо можна взаємодіяти
              ),
              const SizedBox(height: 16), // Вертикальний відступ
              // Поле для введення перекладу
              TextFormField(
                controller: _translationController,
                maxLength: isWord ? 23 : null,
                inputFormatters:
                    isWord ? [LengthLimitingTextInputFormatter(23)] : null,
                decoration: InputDecoration(
                  labelText: localization.translation,
                  counterText: "",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.pleaseEnterTranslation;
                  }
                  if (isWord && value.length > 23) {
                    return localization.maxLength23;
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),

              // Поле для введення опису (тільки якщо тип словника - word)
              if (!isSentence)
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: localization.descriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3, // Дозволити кілька рядків тексту
                  enabled: canInteract,
                  // Немає валідатора, оскільки поле необов'язкове
                ),

              // Область для відображення помилок, що виникли під час збереження/видалення
              if (_localError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _localError!,
                  style: TextStyle(
                    color: errorColor,
                  ), // Текст помилки червоним кольором
                  textAlign: TextAlign.center, // Вирівнювання по центру
                ),
              ],
            ],
          ),
        ),
      ),
      // Дії діалогу: містить лише кнопку "Зберегти"
      actions: <Widget>[
        // Кнопка для збереження змін
        ElevatedButton(
          // Викликати функцію збереження, якщо можна взаємодіяти
          onPressed: canInteract ? () => _submitForm(dictionaryProvider) : null,
          // Умовний рендеринг: індикатор завантаження або текст "Зберегти"
          child:
              _isSaving
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onPrimaryColor,
                    ),
                  )
                  : Text(localization.save),
        ),
      ],
      // Вирівнювання кнопок дій (в даному випадку однієї кнопки) по правому краю
      actionsAlignment: MainAxisAlignment.end,
    );
  }

  // --- Асинхронні методи для обробки дій ---

  // Метод для обробки видалення слова
  Future<void> _handleDelete(DictionaryProvider provider) async {
    final localization = AppLocalizations.of(context)!; // Отримати локалізацію

    // Показати діалог підтвердження видалення
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(localization.confirmDeletion),
            content: Text(
              localization.confirmDeleteWord(widget.initialWord.term),
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      ctx,
                    ).pop(false), // Закрити, повернути false
                child: Text(localization.cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.error, // Червоний текст
                ),
                onPressed:
                    () =>
                        Navigator.of(ctx).pop(true), // Закрити, повернути true
                child: Text(localization.delete),
              ),
            ],
          ),
    );

    // Якщо користувач не підтвердив (натиснув "Скасувати" або поза діалогом), вийти
    if (confirm != true) {
      return;
    }

    // Почати процес видалення: оновити стан UI
    setState(() {
      _isDeleting = true; // Показати індикатор на кнопці видалення
      _localError = null; // Очистити попередні помилки
    });

    // Викликати зовнішню функцію `onWordDeleted`, передану у віджет
    final String? deletedTerm = await widget.onWordDeleted(widget.wordIndex);

    // Перевірити, чи віджет все ще в дереві після асинхронної операції
    if (!mounted) return;

    // Обробка результату видалення
    if (deletedTerm != null) {
      // Успіх: закрити діалог редагування та повернути результат 'deleted'
      Navigator.of(context).pop(
        EditWordDialogResult(
          EditWordDialogStatus.deleted,
          deletedWordTerm: deletedTerm, // Передати термін видаленого слова
        ),
      );
    } else {
      // Помилка: отримати повідомлення про помилку (з провайдера, якщо є, або стандартне)
      final errorMsg = provider.error ?? localization.failedToDeleteWord;
      setState(() {
        _localError = errorMsg; // Відобразити помилку в діалозі
        _isDeleting = false; // Зупинити індикатор, розблокувати кнопки
      });
      provider.clearError(); // Очистити помилку в провайдері
    }
  }

  // Метод для обробки збереження (оновлення) слова
  Future<void> _submitForm(DictionaryProvider provider) async {
    final localization = AppLocalizations.of(context)!; // Отримати локалізацію

    // Перевірити валідність форми та чи не виконується інша операція
    if (_formKey.currentState!.validate() && !_isSaving && !_isDeleting) {
      // Почати процес збереження: оновити стан UI
      setState(() {
        _isSaving = true; // Показати індикатор на кнопці збереження
        _localError = null; // Очистити попередні помилки
      });

      // Створити об'єкт `Word` з оновленими даними з полів форми
      final updatedWord = Word(
        term: _termController.text.trim(), // Обрізати зайві пробіли
        translation: _translationController.text.trim(),
        // Опис береться з контролера, якщо це не речення; порожній опис стає null
        description:
            widget.dictionaryType != DictionaryType.sentence
                ? (_descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim())
                : null, // Для речень опис не зберігається
      );

      // Викликати зовнішню функцію `onWordUpdated`, передану у віджет
      final bool updatedSuccessfully = await widget.onWordUpdated(
        widget.wordIndex,
        updatedWord,
      );

      // Перевірити, чи віджет все ще в дереві після асинхронної операції
      if (!mounted) return;

      // Обробка результату оновлення
      if (updatedSuccessfully) {
        // Успіх: закрити діалог редагування та повернути результат 'saved'
        Navigator.of(
          context,
        ).pop(EditWordDialogResult(EditWordDialogStatus.saved));
      } else {
        // Помилка: отримати повідомлення про помилку (з провайдера, якщо є, або стандартне)
        final errorMsg = provider.error ?? localization.failedToUpdateWord;
        setState(() {
          _localError = errorMsg; // Відобразити помилку в діалозі
          _isSaving = false; // Зупинити індикатор, розблокувати кнопки
        });
        provider.clearError(); // Очистити помилку в провайдері
      }
    }
  }
}
