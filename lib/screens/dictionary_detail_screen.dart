import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/data/dictionary.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';
import 'package:simpledictionary/screens/add_word_screen.dart';
import 'package:simpledictionary/widgets/edit_word_dialog.dart';

enum SortOrder { alphabetical, lastAdded }

class DictionaryDetailScreen extends StatefulWidget {
  final Dictionary dictionary;

  const DictionaryDetailScreen({required this.dictionary, super.key});

  @override
  State<DictionaryDetailScreen> createState() => _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
  // Стан для поточного порядку сортування
  SortOrder _sortOrder = SortOrder.alphabetical;

  List<Word> _getSortedWords(Dictionary dictionary, SortOrder sortOrder) {
    List<Word> words = List.from(dictionary.words);
    if (sortOrder == SortOrder.alphabetical) {
      words.sort(
        (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
      );
    }
    return words;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        // --- Отримання актуального стану словника ---
        Dictionary? currentDict;
        try {
          // Шукаємо словник у провайдері за іменем, яке було передано спочатку
          // Це важливо, якщо ім'я словника змінилося під час перебування на екрані
          currentDict = provider.dictionaries.firstWhere(
            (d) => d.name == widget.dictionary.name,
          );
        } catch (e) {
          // Обробка випадку, коли словник не знайдено (можливо, видалено)
          debugPrint(
            "Dictionary '${widget.dictionary.name}' not found in provider. It might have been deleted.",
          );
          // Показуємо Scaffold з повідомленням про помилку
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.dictionary.name),
            ), // Можна показати стару назву
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization.dictionaryNotFound, // "Словник не знайдено"
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization
                        .dictionaryMightBeDeleted, // "Можливо, його було видалено."
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localization.goBack), // "Назад"
                  ),
                ],
              ),
            ),
          );
        }
        // --- Кінець отримання актуального стану словника ---

        // Отримуємо відсортований список слів
        final List<Word> sortedWords = _getSortedWords(currentDict, _sortOrder);
        final DictionaryType dictionaryType =
            currentDict.type; // Тип поточного словника

        // Будуємо основний Scaffold
        return Scaffold(
          appBar: AppBar(
            // Відображаємо актуальну назву словника
            title: Text(currentDict.name),
            actions: [
              // Кнопка для зміни сортування
              IconButton(
                icon: Icon(
                  _sortOrder == SortOrder.alphabetical
                      ? Icons
                          .sort_by_alpha // Іконка для алфавітного сортування
                      : Icons
                          .access_time, // Іконка для сортування за часом додавання
                ),
                onPressed: () {
                  // Змінюємо порядок сортування при натисканні
                  setState(() {
                    _sortOrder =
                        _sortOrder == SortOrder.alphabetical
                            ? SortOrder.lastAdded
                            : SortOrder.alphabetical;
                  });
                },
                // Динамічна підказка для кнопки
                tooltip:
                    _sortOrder == SortOrder.alphabetical
                        ? localization
                            .sortByLastAdded // "Сортувати за останніми доданими"
                        : localization
                            .sortByAlphabetical, // "Сортувати за алфавітом"
              ),
            ],
          ),
          // Тіло Scaffold
          body:
              sortedWords.isEmpty
                  // Випадок, коли словник порожній
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localization.dictionaryEmpty, // "Словник порожній"
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localization
                              .addWordsByPressingButton, // "Додайте слова, натиснувши кнопку '+'"
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                  // Випадок, коли у словнику є слова - відображаємо список
                  : WordsList(
                    currentDict: currentDict, // Передаємо актуальний словник
                    words: sortedWords, // Передаємо відсортований список
                    // Callback, що викликається при натисканні на картку слова
                    onEditWord: (context, dictionary, word) {
                      // Викликаємо функцію для показу діалогу редагування
                      _showEditWordDialog(context, dictionary, word);
                    },
                  ),
          // Плаваюча кнопка для додавання нового слова
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Перехід на екран додавання слова
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddWordScreen(
                        // Передаємо тип словника на екран додавання
                        dictionaryType: dictionaryType,
                        // Callback, що викликається при успішному додаванні слова
                        onWordAdded: (newWord) async {
                          // Отримуємо провайдер (listen: false, бо дія відбувається поза build)
                          final dictProvider = Provider.of<DictionaryProvider>(
                            context,
                            listen: false,
                          );
                          dictProvider
                              .clearError(); // Очищуємо можливі попередні помилки
                          // Викликаємо метод провайдера для додавання слова
                          return await dictProvider.addWordToDictionary(
                            currentDict!
                                .name, // Використовуємо актуальне ім'я словника
                            newWord,
                            context:
                                context, // Передаємо context для локалізації помилок
                          );
                        },
                      ),
                ),
              );
            },
            tooltip: localization.addNewWord, // "Додати нове слово"
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // Функція для показу діалогового вікна редагування слова
  void _showEditWordDialog(
    BuildContext context,
    Dictionary currentDictionary, // Актуальний об'єкт словника
    Word word, // Конкретне слово для редагування
  ) {
    final localization = AppLocalizations.of(context)!;
    // Отримуємо провайдер перед показом діалогу (безпечно)
    final provider = Provider.of<DictionaryProvider>(context, listen: false);

    // Знаходимо АКТУАЛЬНИЙ індекс слова в НЕсортованому списку провайдера
    // Це критично, оскільки індекс у відсортованому списку може бути іншим!
    final actualIndex = currentDictionary.words.indexWhere(
      (w) => w.term == word.term && w.translation == word.translation,
      // Припускаємо, що комбінація терміна і перекладу унікальна,
      // або використовуємо порівняння об'єктів, якщо Word має оператор ==
      // (w == word)
    );

    // Перевіряємо, чи слово знайдено (могло бути видалено паралельно)
    if (actualIndex == -1) {
      if (mounted) {
        // Перевіряємо, чи віджет ще активний
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localization.failedToFindWordForEdit,
            ), // "Не вдалося знайти слово для редагування"
            backgroundColor: Colors.orange, // Попередження
          ),
        );
      }
      return; // Не показуємо діалог, якщо слово не знайдено
    }

    // Показуємо діалог
    showDialog<EditWordDialogResult>(
      context: context,
      barrierDismissible: false, // Не закривати діалог при натисканні поза ним
      builder: (dialogContext) {
        // Діалог редагування слова
        return EditWordDialog(
          initialWord: word, // Передаємо початкове слово
          dictionaryName: currentDictionary.name, // Актуальна назва словника
          wordIndex: actualIndex, // Передаємо правильний індекс
          // Передаємо тип словника для валідації та UI всередині діалогу
          dictionaryType: currentDictionary.type,
          // Callback при успішному оновленні слова
          onWordUpdated: (indexFromDialog, updatedWord) async {
            provider.clearError(); // Очищуємо помилки перед дією
            // Викликаємо метод провайдера для оновлення
            bool success = await provider.updateWordInDictionary(
              currentDictionary.name,
              indexFromDialog, // Індекс з діалогу (має бути = actualIndex)
              updatedWord,
              context: dialogContext, // Контекст для локалізації помилок
            );
            return success;
          },
          // Callback при успішному видаленні слова
          onWordDeleted: (indexFromDialog) async {
            provider.clearError();
            // Зберігаємо термін для повідомлення перед видаленням
            final wordTermToDelete =
                currentDictionary.words[indexFromDialog].term;
            // Викликаємо метод провайдера для видалення
            bool success = await provider.removeWordFromDictionary(
              currentDictionary.name,
              indexFromDialog,
              context: dialogContext,
            );
            // Повертаємо термін, якщо видалення успішне, інакше null
            return success ? wordTermToDelete : null;
          },
        );
      },
    ).then((result) {
      // Обробка результату після закриття діалогу
      // Перевіряємо, чи віджет ще активний і чи є результат
      if (!mounted || result == null) return;

      // Використовуємо локалізацію, отриману раніше (безпечно)
      // Показуємо відповідне повідомлення користувачу
      switch (result.status) {
        case EditWordDialogStatus.saved:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localization.wordUpdatedSuccessfully,
              ), // "Слово успішно оновлено"
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case EditWordDialogStatus.deleted:
          if (result.deletedWordTerm != null) {
            // Повідомлення з іменем видаленого слова
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localization.wordDeletedWithName(result.deletedWordTerm!),
                ), // "Слово '{term}' видалено"
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // Загальне повідомлення про видалення (якщо термін не отримано)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localization.wordDeleted), // "Слово видалено"
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;
        case EditWordDialogStatus.cancelled:
          // Нічого не робимо при скасуванні
          break;
        case EditWordDialogStatus.error:
          // Помилка вже повинна була бути оброблена в діалозі або провайдері
          // Можна додати загальний fallback SnackBar тут, якщо потрібно
          /*
          final errorMsg = Provider.of<DictionaryProvider>(context, listen: false).error ?? localization.operationFailed; // Потрібен рядок 'operationFailed'
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
          Provider.of<DictionaryProvider>(context, listen: false).clearError();
          */
          break;
      }
    });
  }
} // Кінець _DictionaryDetailScreenState

// Віджет для відображення списку слів
class WordsList extends StatelessWidget {
  final Dictionary currentDict; // Поточний словник
  final List<Word> words; // Список слів для відображення (вже відсортований)
  // Callback при натисканні на слово
  final void Function(BuildContext context, Dictionary dictionary, Word word)
  onEditWord;

  const WordsList({
    required this.currentDict,
    required this.words,
    required this.onEditWord,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Додаємо відступи навколо списку
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: words.length, // Кількість елементів у списку
      itemBuilder: (context, index) {
        final word = words[index]; // Отримуємо слово за індексом
        // Створюємо унікальний ключ для картки (допомагає Flutter оновлювати правильно)
        final wordKey = ValueKey(
          '${currentDict.name}_${word.term}_${word.translation}',
        );
        // Повертаємо віджет картки для кожного слова
        return WordCard(
          key: wordKey,
          word: word,
          dictionaryType: currentDict.type, // Передаємо тип словника
          // Передаємо callback, який буде викликаний при натисканні
          onEdit: () => onEditWord(context, currentDict, word),
        );
      },
    );
  }
}

// Віджет для відображення окремої картки слова
class WordCard extends StatelessWidget {
  final Word word;
  final DictionaryType dictionaryType;
  final Function() onEdit; // Callback при натисканні

  const WordCard({
    required this.word,
    required this.dictionaryType,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // --- Визначення вирівнювання та видимості опису на основі типу ---
    TextAlign alignment;
    CrossAxisAlignment crossAxisAlignmentItemAlignment; // Для Column
    Alignment rowChildAlignment; // Для Align всередині Row
    bool descriptionVisible = false; // За замовчуванням опис не показуємо

    switch (dictionaryType) {
      case DictionaryType.word:
        alignment = TextAlign.center;
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.center;
        rowChildAlignment = Alignment.center;
        // Опис видимий, якщо він є і не порожній
        descriptionVisible =
            word.description != null && word.description!.isNotEmpty;
        break;
      case DictionaryType.phrase:
      case DictionaryType.sentence:
        alignment = TextAlign.start; // Вирівнювання зліва
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.start;
        rowChildAlignment = Alignment.centerLeft;
        descriptionVisible = false; // Опис завжди прихований для фраз/речень
        break;
    }
    // --- Кінець визначення ---

    return Card(
      margin: const EdgeInsets.only(bottom: 12), // Відступ знизу між картками
      elevation: 1, // Невелика тінь
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Закруглені кути
      child: InkWell(
        onTap: onEdit, // Викликаємо callback редагування при натисканні
        borderRadius: BorderRadius.circular(
          12,
        ), // Область реакції на натискання
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          // Основна колонка для терміну/перекладу та опису
          child: Column(
            crossAxisAlignment:
                crossAxisAlignmentItemAlignment, // Вирівнювання елементів колонки
            children: [
              // Використовуємо IntrinsicHeight, щоб елементи Row мали однакову висоту
              IntrinsicHeight(
                child: Row(
                  // Вертикальне вирівнювання елементів рядка по центру
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Термін ---
                    Expanded(
                      child: Align(
                        alignment: rowChildAlignment, // Динамічне вирівнювання
                        child: Text(
                          word.term,
                          textAlign: alignment, // Вирівнювання тексту
                          style: textTheme.titleMedium?.copyWith(
                            color:
                                theme
                                    .colorScheme
                                    .primary, // Акцентний колір для терміну
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: null, // Дозволяємо перенос рядків
                          softWrap: true,
                        ),
                      ),
                    ),
                    // --- Роздільник ---
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      // Вертикальний роздільник між терміном і перекладом
                      child: VerticalDivider(thickness: 1, width: 1),
                    ),
                    // --- Переклад ---
                    Expanded(
                      child: Align(
                        alignment: rowChildAlignment, // Динамічне вирівнювання
                        child: Text(
                          word.translation,
                          textAlign: alignment, // Вирівнювання тексту
                          style: textTheme.titleMedium,
                          maxLines: null, // Дозволяємо перенос рядків
                          softWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // --- Умовне відображення опису ---
              if (descriptionVisible) ...[
                const Divider(
                  height: 20,
                  thickness: 0.5,
                ), // Роздільник перед описом
                // Вирівнюємо текст опису завжди зліва
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    word.description!, // Використовуємо !, бо перевірили на null раніше
                    style: textTheme.bodyMedium?.copyWith(
                      // Трохи приглушений колір для опису
                      color: textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.start, // Вирівнювання тексту опису
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
