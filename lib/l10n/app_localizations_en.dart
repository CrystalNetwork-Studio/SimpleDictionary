// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutAppDescription => 'A simple application for creating and managing personal dictionaries.';

  @override
  String get aboutAppNotReady => 'About app info is not ready yet.';

  @override
  String get addDictionary => 'Add Dictionary';

  @override
  String get addNewWord => 'Add New Word';

  @override
  String get addWordsByPressingButton => 'Add words by pressing the \'+\' button at the bottom of the screen';

  @override
  String anotherWordWithSameTermExists(Object term, Object translation) {
    return 'Another word with the same term \"$term\" / \"$translation\" already exists.';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get author => 'Author';

  @override
  String baseDictionaryDirectoryCreated(Object baseDirPath) {
    return 'Base \'Dictionary\' directory created at: $baseDirPath';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cannotDeleteMainDictionaryDirectory => 'Error: Cannot delete the main \'Dictionary\' directory. Dictionary name is blank.';

  @override
  String get checkingAvailability => 'Checking availability...';

  @override
  String get company => 'Company';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String confirmDeleteWord(Object wordName) {
    return 'Delete word \"$wordName\"?';
  }

  @override
  String get create => 'Create';

  @override
  String get createDictionary => 'Create Dictionary';

  @override
  String criticalErrorFailedToDeleteOldDictionary(Object newName, Object oldName) {
    return 'CRITICAL: Failed to delete old directory \'$oldName\' after renaming to \'$newName\'. Manual cleanup might be needed.';
  }

  @override
  String get dark => 'Dark';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get delete => 'Delete';

  @override
  String get deleteDictionary => 'Delete Dictionary?';

  @override
  String deleteDictionaryConfirmation(Object dictionaryName) {
    return 'Are you sure you want to delete the dictionary \"$dictionaryName\"? This action cannot be undone.';
  }

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get dictionaries => 'Dictionaries';

  @override
  String dictionariesCount(Object count) {
    return 'Dictionaries: $count';
  }

  @override
  String get dictionaryAlreadyExists => 'Dictionary with this name already exists.';

  @override
  String dictionaryCreated(Object dictionaryName) {
    return 'Dictionary \"$dictionaryName\" created.';
  }

  @override
  String dictionaryDeletedWithName(Object dictionaryName) {
    return 'Dictionary \"$dictionaryName\" deleted.';
  }

  @override
  String get dictionaryEmpty => 'Dictionary is empty';

  @override
  String dictionaryFileNotFound(Object dictionaryName, Object filePath) {
    return 'Dictionary file not found for \'$dictionaryName\' at: $filePath';
  }

  @override
  String get dictionaryMightBeDeleted => 'It might have been deleted.';

  @override
  String get dictionaryName => 'Dictionary Name';

  @override
  String get dictionaryNameHint => 'Enter dictionary name';

  @override
  String get dictionaryNameLabel => 'Dictionary Name';

  @override
  String get dictionaryNameNotEmpty => 'Dictionary name cannot be empty.';

  @override
  String get dictionaryNotFound => 'Dictionary not found.';

  @override
  String dictionaryNotFoundForDeletion(Object dictionaryName) {
    return 'Dictionary \'$dictionaryName\' not found for deletion.';
  }

  @override
  String dictionaryNotFoundForUpdate(Object dictionaryName) {
    return 'Dictionary \'$dictionaryName\' not found for update.';
  }

  @override
  String dictionaryNotFoundForWordUpdate(Object dictionaryName) {
    return 'Dictionary \'$dictionaryName\' not found for word update.';
  }

  @override
  String dictionarySavedTo(Object dictionaryName, Object filePath) {
    return 'Dictionary \'$dictionaryName\' saved to: $filePath';
  }

  @override
  String dictionaryUpdated(Object dictionaryName) {
    return 'Dictionary \"$dictionaryName\" updated.';
  }

  @override
  String dictionaryUpdatedWithName(Object dictionaryName) {
    return 'Dictionary \"$dictionaryName\" updated.';
  }

  @override
  String directoryForDictionaryCreated(Object dictionaryName, Object directoryPath) {
    return 'Directory for dictionary \'$dictionaryName\' created at: $directoryPath';
  }

  @override
  String directoryForDictionaryNotFound(Object dictionaryName, Object directoryPath) {
    return 'Directory for dictionary \'$dictionaryName\' not found at: $directoryPath';
  }

  @override
  String get edit => 'Edit';

  @override
  String get editDictionary => 'Edit Dictionary';

  @override
  String get editWord => 'Edit Word';

  @override
  String errorCheckingExistence(Object error) {
    return 'Error checking dictionary existence: $error';
  }

  @override
  String get errorCreatingDictionary => 'Failed to create dictionary.';

  @override
  String errorDeletingDictionary(Object dictionaryName) {
    return 'Error deleting dictionary \'$dictionaryName\'';
  }

  @override
  String errorDeletingDictionaryDirectory(Object dictionaryName, Object error) {
    return 'Error deleting dictionary \'$dictionaryName\': $error';
  }

  @override
  String errorListingDictionaryDirectories(Object error) {
    return 'Error listing dictionary directories: $error';
  }

  @override
  String get errorLoadingDictionaries => 'Error loading dictionaries';

  @override
  String errorLoadingDictionary(Object dictionaryName, Object error) {
    return 'Error loading dictionary \'$dictionaryName\': $error';
  }

  @override
  String errorLoadingSettings(Object error) {
    return 'Error loading settings: $error';
  }

  @override
  String errorRemovingWord(Object dictionaryName, Object wordIndex) {
    return 'Error removing word from \'$dictionaryName\' at index $wordIndex';
  }

  @override
  String errorSavingDictionary(Object dictionaryName, Object error) {
    return 'Error saving dictionary \'$dictionaryName\': $error';
  }

  @override
  String errorSavingThemeMode(Object error) {
    return 'Error saving theme mode: $error';
  }

  @override
  String errorUpdatingWord(Object dictionaryName, Object wordIndex) {
    return 'Error updating word in \'$dictionaryName\' at index $wordIndex';
  }

  @override
  String errorValidatingName(Object error) {
    return 'Error validating name: $error';
  }

  @override
  String get errorValidatingNameDialog => 'Error validating dictionary name.';

  @override
  String get failedToDeleteWord => 'Failed to delete word.';

  @override
  String get failedToFindWordForEdit => 'Failed to find word for editing/deleting.';

  @override
  String get failedToAddWord => 'Failed to add word.';

  @override
  String get failedToUpdateDictionary => 'Failed to update dictionary.';

  @override
  String get failedToUpdateWord => 'Failed to update word.';

  @override
  String get folderColor => 'Folder Color';

  @override
  String foundDictionaryDirectories(Object dirNames) {
    return 'Found dictionary directories: $dirNames';
  }

  @override
  String get importExportDictionaries => 'Import / Export Dictionaries';

  @override
  String invalidWordIndexForDictionary(Object dictionaryName, Object maxIndex, Object wordIndex) {
    return 'Invalid word index $wordIndex for dictionary \'$dictionaryName\'. Max index is $maxIndex.';
  }

  @override
  String get language => 'Language';

  @override
  String get languageDrawer => 'Language: English';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get license => 'License';

  @override
  String get light => 'Light';

  @override
  String get maxLength20 => 'Maximum 20 characters';

  @override
  String get myDictionaries => 'My Dictionaries';

  @override
  String get oopsImportExportNotReady => 'Import/Export feature is not ready yet. :(';

  @override
  String get options => 'Options';

  @override
  String get pleaseEnterTranslation => 'Please enter a translation';

  @override
  String get pleaseEnterWord => 'Please enter a word';

  @override
  String get save => 'Save';

  @override
  String get settings => 'Settings';

  @override
  String get sortByAlphabetical => 'Sort Alphabetically';

  @override
  String get sortByLastAdded => 'Sort by Last Added';

  @override
  String successfullyDeletedDictionary(Object dictionaryName, Object directoryPath) {
    return 'Successfully deleted dictionary \'$dictionaryName\' at: $directoryPath';
  }

  @override
  String get systemDefault => 'System Default';

  @override
  String get theme => 'Theme';

  @override
  String get translation => 'Translation';

  @override
  String get updateDictionary => 'Update Dictionary';

  @override
  String get updateWord => 'Update Word';

  @override
  String get version => 'Version';

  @override
  String get word => 'Word';

  @override
  String get wordAndTranslationMaxLength20 => 'Word and translation length cannot exceed 20 characters.';

  @override
  String get wordDeleted => 'Word deleted';

  @override
  String wordDeletedWithName(Object wordName) {
    return 'Word \"$wordName\" deleted';
  }

  @override
  String get wordOrTranslationCannotBeEmpty => 'Word and translation cannot be empty.';

  @override
  String get wordUpdatedSuccessfully => 'Word updated successfully!';
}
