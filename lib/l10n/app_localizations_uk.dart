// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get myDictionaries => 'Мої словники';

  @override
  String get addDictionary => 'Додати словник';

  @override
  String get settings => 'Налаштування';

  @override
  String get appearance => 'Вигляд';

  @override
  String get theme => 'Тема';

  @override
  String get systemDefault => 'Системна';

  @override
  String get light => 'Світла';

  @override
  String get dark => 'Темна';

  @override
  String get dataManagement => 'Керування Даними';

  @override
  String get importExportDictionaries => 'Імпорт / Експорт словників';

  @override
  String get dictionaries => 'Словники';

  @override
  String get language => 'Мова';

  @override
  String get version => 'Версія';

  @override
  String get dictionaryName => 'Назва словника';

  @override
  String get create => 'Створити';

  @override
  String get cancel => 'Відмінити';

  @override
  String get dictionaryNameNotEmpty => 'Назва словника не може бути порожньою';

  @override
  String get dictionaryAlreadyExists => 'Словник з такою назвою вже існує.';

  @override
  String dictionaryCreated(Object dictionaryName) {
    return 'Словник \"$dictionaryName\" створено.';
  }

  @override
  String get errorCreatingDictionary => 'Не вдалося створити словник.';

  @override
  String get deleteDictionary => 'Видалити словник?';

  @override
  String deleteDictionaryConfirmation(Object dictionaryName) {
    return 'Ви впевнені, що хочете видалити словник \"$dictionaryName\"? Цю дію неможливо скасувати.';
  }

  @override
  String get delete => 'Видалити';

  @override
  String get word => 'Слово';

  @override
  String get translation => 'Переклад';

  @override
  String get description => 'Опис';

  @override
  String get addNewWord => 'Додати нове слово';

  @override
  String get save => 'Зберегти';

  @override
  String get pleaseEnterWord => 'Будь ласка, введіть слово';

  @override
  String get pleaseEnterTranslation => 'Будь ласка, введіть переклад';

  @override
  String get maxLength20 => 'Максимум 20 символів';

  @override
  String get failedToAddWord => 'Не вдалося додати слово.';

  @override
  String get dictionaryEmpty => 'Словник порожній';

  @override
  String get addWordsByPressingButton => 'Додайте слова, натиснувши кнопку \"+\" внизу екрана';

  @override
  String get sortByAlphabetical => 'Сортувати за алфавітом';

  @override
  String get sortByLastAdded => 'Сортувати за останніми доданими';

  @override
  String get editWord => 'Редагувати слово';

  @override
  String get updateWord => 'Оновити слово';

  @override
  String get wordUpdatedSuccessfully => 'Слово успішно оновлено!';

  @override
  String get wordDeleted => 'Слово видалено';

  @override
  String wordDeletedWithName(Object wordName) {
    return 'Слово \"$wordName\" видалено';
  }

  @override
  String get failedToFindWordForEdit => 'Не вдалося знайти слово для редагування/видалення.';

  @override
  String get confirmDeletion => 'Підтвердити видалення';

  @override
  String confirmDeleteWord(Object wordName) {
    return 'Видалити слово \"$wordName\"?';
  }

  @override
  String get oopsImportExportNotReady => 'Функція Імпорту/Експорту ще не готова. :(';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get aboutApp => 'Про додаток';

  @override
  String get aboutAppNotReady => 'Інформація про додаток ще не доробленна.';

  @override
  String get editDictionary => 'Редагувати словник';

  @override
  String get updateDictionary => 'Оновити словник';

  @override
  String dictionaryUpdated(Object dictionaryName) {
    return 'Словник \"$dictionaryName\" оновлено.';
  }

  @override
  String get failedToUpdateDictionary => 'Не вдалося оновити словник.';

  @override
  String errorValidatingName(Object error) {
    return 'Помилка перевірки імені: $error';
  }

  @override
  String errorCheckingExistence(Object error) {
    return 'Помилка перевірки існування словника: $error';
  }

  @override
  String anotherWordWithSameTermExists(Object term, Object translation) {
    return 'Інше слово з таким же терміном \"$term\" / \"$translation\" вже існує.';
  }

  @override
  String get wordOrTranslationCannotBeEmpty => 'Слово та переклад не можуть бути порожніми.';

  @override
  String get wordAndTranslationMaxLength20 => 'Довжина слова та перекладу не може перевищувати 20 символів.';

  @override
  String errorUpdatingWord(Object dictionaryName, Object wordIndex) {
    return 'Помилка оновлення слова в \'$dictionaryName\' за індексом $wordIndex';
  }

  @override
  String errorRemovingWord(Object dictionaryName, Object wordIndex) {
    return 'Помилка видалення слова з \'$dictionaryName\' за індексом $wordIndex';
  }

  @override
  String errorDeletingDictionary(Object dictionaryName) {
    return 'Помилка видалення словника \'$dictionaryName\'';
  }

  @override
  String get errorLoadingDictionaries => 'Помилка завантаження словників';

  @override
  String criticalErrorFailedToDeleteOldDictionary(Object newName, Object oldName) {
    return 'КРИТИЧНО: Не вдалося видалити стару версію словника. \'$oldName\' після перейменування на \'$newName\'. Можливо, потрібне ручне очищення.';
  }

  @override
  String dictionaryNotFoundForUpdate(Object dictionaryName) {
    return 'Словник \'$dictionaryName\' не знайдено для оновлення.';
  }

  @override
  String dictionaryNotFoundForDeletion(Object dictionaryName) {
    return 'Словник \'$dictionaryName\' не знайдено для видалення.';
  }

  @override
  String invalidWordIndexForDictionary(Object dictionaryName, Object maxIndex, Object wordIndex) {
    return 'Невірний індекс слова $wordIndex для словника \'$dictionaryName\'. Максимальний індекс: $maxIndex.';
  }

  @override
  String dictionaryNotFoundForWordUpdate(Object dictionaryName) {
    return 'Словник \'$dictionaryName\' не знайдено для оновлення слова.';
  }

  @override
  String dictionaryFileNotFound(Object dictionaryName, Object filePath) {
    return 'Файл словника не знайдено для \'$dictionaryName\' за шляхом: $filePath';
  }

  @override
  String errorLoadingDictionary(Object dictionaryName, Object error) {
    return 'Помилка завантаження словника \'$dictionaryName\': $error';
  }

  @override
  String directoryForDictionaryCreated(Object dictionaryName, Object directoryPath) {
    return 'Каталог для словника \'$dictionaryName\' створено за шляхом: $directoryPath';
  }

  @override
  String dictionarySavedTo(Object dictionaryName, Object filePath) {
    return 'Словник \'$dictionaryName\' збережено до: $filePath';
  }

  @override
  String errorSavingDictionary(Object dictionaryName, Object error) {
    return 'Помилка збереження словника \'$dictionaryName\': $error';
  }

  @override
  String baseDictionaryDirectoryCreated(Object baseDirPath) {
    return 'Базовий каталог \'Dictionary\' створено за шляхом: $baseDirPath';
  }

  @override
  String errorListingDictionaryDirectories(Object error) {
    return 'Помилка переліку каталогів словників: $error';
  }

  @override
  String foundDictionaryDirectories(Object dirNames) {
    return 'Знайдено каталоги словників: $dirNames';
  }

  @override
  String successfullyDeletedDictionary(Object dictionaryName, Object directoryPath) {
    return 'Словник \'$dictionaryName\' успішно видалено за шляхом: $directoryPath';
  }

  @override
  String directoryForDictionaryNotFound(Object dictionaryName, Object directoryPath) {
    return 'Каталог для словника \'$dictionaryName\' не знайдено за шляхом: $directoryPath';
  }

  @override
  String errorDeletingDictionaryDirectory(Object dictionaryName, Object error) {
    return 'Помилка видалення каталогу словника \'$dictionaryName\': $error';
  }

  @override
  String get cannotDeleteMainDictionaryDirectory => 'Помилка: Неможливо видалити головний каталог \'Dictionary\'. Назва словника порожня.';

  @override
  String errorLoadingSettings(Object error) {
    return 'Помилка завантаження налаштувань: $error';
  }

  @override
  String errorSavingThemeMode(Object error) {
    return 'Помилка збереження теми: $error';
  }

  @override
  String dictionariesCount(Object count) {
    return 'Словники: $count';
  }

  @override
  String get languageDrawer => 'Мова: Українська';

  @override
  String get dictionaryNotFound => 'Словник не знайдено.';

  @override
  String get dictionaryMightBeDeleted => 'Можливо, його було видалено.';

  @override
  String get createDictionary => 'Створити словник';

  @override
  String get dictionaryNameLabel => 'Назва словника';

  @override
  String get dictionaryNameHint => 'Введіть назву словника';

  @override
  String get folderColor => 'Колір папки';

  @override
  String get checkingAvailability => 'Перевірка доступності...';

  @override
  String get errorValidatingNameDialog => 'Помилка перевірки назви словника.';

  @override
  String dictionaryUpdatedWithName(Object dictionaryName) {
    return 'Словник \"$dictionaryName\" оновлено.';
  }

  @override
  String dictionaryDeletedWithName(Object dictionaryName) {
    return 'Словник \"$dictionaryName\" видалено.';
  }

  @override
  String get edit => 'Редагувати';

  @override
  String get options => 'Опції';

  @override
  String get failedToDeleteWord => 'Не вдалося видалити слово.';

  @override
  String get descriptionOptional => 'Опис (необов\'язково)';

  @override
  String get failedToUpdateWord => 'Не вдалося оновити слово.';
}
