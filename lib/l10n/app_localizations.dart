import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'A simple application for creating and managing personal dictionaries.'**
  String get aboutAppDescription;

  /// No description provided for @aboutAppNotReady.
  ///
  /// In en, this message translates to:
  /// **'About app info is not ready yet.'**
  String get aboutAppNotReady;

  /// No description provided for @addDictionary.
  ///
  /// In en, this message translates to:
  /// **'Add Dictionary'**
  String get addDictionary;

  /// No description provided for @addNewWord.
  ///
  /// In en, this message translates to:
  /// **'Add New Word'**
  String get addNewWord;

  /// No description provided for @addWordsByPressingButton.
  ///
  /// In en, this message translates to:
  /// **'Add words by pressing the \'+\' button at the bottom of the screen'**
  String get addWordsByPressingButton;

  /// No description provided for @anotherWordWithSameTermExists.
  ///
  /// In en, this message translates to:
  /// **'Another word with the same term \"{term}\" / \"{translation}\" already exists.'**
  String anotherWordWithSameTermExists(Object term, Object translation);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @baseDictionaryDirectoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Base \'Dictionary\' directory created at: {baseDirPath}'**
  String baseDictionaryDirectoryCreated(Object baseDirPath);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cannotDeleteMainDictionaryDirectory.
  ///
  /// In en, this message translates to:
  /// **'Error: Cannot delete the main \'Dictionary\' directory. Dictionary name is blank.'**
  String get cannotDeleteMainDictionaryDirectory;

  /// No description provided for @checkingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Checking availability...'**
  String get checkingAvailability;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteWord.
  ///
  /// In en, this message translates to:
  /// **'Delete word \"{wordName}\"?'**
  String confirmDeleteWord(Object wordName);

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createDictionary.
  ///
  /// In en, this message translates to:
  /// **'Create Dictionary'**
  String get createDictionary;

  /// No description provided for @criticalErrorFailedToDeleteOldDictionary.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: Failed to delete old directory \'{oldName}\' after renaming to \'{newName}\'. Manual cleanup might be needed.'**
  String criticalErrorFailedToDeleteOldDictionary(Object newName, Object oldName);

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteDictionary.
  ///
  /// In en, this message translates to:
  /// **'Delete Dictionary?'**
  String get deleteDictionary;

  /// No description provided for @deleteDictionaryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the dictionary \"{dictionaryName}\"? This action cannot be undone.'**
  String deleteDictionaryConfirmation(Object dictionaryName);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @dictionaries.
  ///
  /// In en, this message translates to:
  /// **'Dictionaries'**
  String get dictionaries;

  /// No description provided for @dictionariesCount.
  ///
  /// In en, this message translates to:
  /// **'Dictionaries: {count}'**
  String dictionariesCount(Object count);

  /// No description provided for @dictionaryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Dictionary with this name exists.'**
  String get dictionaryAlreadyExists;

  /// No description provided for @dictionaryCreated.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \"{dictionaryName}\" created.'**
  String dictionaryCreated(Object dictionaryName);

  /// No description provided for @dictionaryDeletedWithName.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \"{dictionaryName}\" deleted.'**
  String dictionaryDeletedWithName(Object dictionaryName);

  /// No description provided for @dictionaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Dictionary is empty'**
  String get dictionaryEmpty;

  /// No description provided for @dictionaryFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Dictionary file not found for \'{dictionaryName}\' at: {filePath}'**
  String dictionaryFileNotFound(Object dictionaryName, Object filePath);

  /// No description provided for @dictionaryMightBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'It might have been deleted.'**
  String get dictionaryMightBeDeleted;

  /// No description provided for @dictionaryName.
  ///
  /// In en, this message translates to:
  /// **'Dictionary Name'**
  String get dictionaryName;

  /// No description provided for @dictionaryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter dictionary name'**
  String get dictionaryNameHint;

  /// No description provided for @dictionaryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dictionary Name'**
  String get dictionaryNameLabel;

  /// No description provided for @dictionaryNameNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Dictionary name cannot be empty.'**
  String get dictionaryNameNotEmpty;

  /// No description provided for @dictionaryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Dictionary not found.'**
  String get dictionaryNotFound;

  /// No description provided for @dictionaryNotFoundForDeletion.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \'{dictionaryName}\' not found for deletion.'**
  String dictionaryNotFoundForDeletion(Object dictionaryName);

  /// No description provided for @dictionaryNotFoundForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \'{dictionaryName}\' not found for update.'**
  String dictionaryNotFoundForUpdate(Object dictionaryName);

  /// No description provided for @dictionaryNotFoundForWordUpdate.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \'{dictionaryName}\' not found for word update.'**
  String dictionaryNotFoundForWordUpdate(Object dictionaryName);

  /// No description provided for @dictionarySavedTo.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \'{dictionaryName}\' saved to: {filePath}'**
  String dictionarySavedTo(Object dictionaryName, Object filePath);

  /// No description provided for @dictionaryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \"{dictionaryName}\" updated.'**
  String dictionaryUpdated(Object dictionaryName);

  /// No description provided for @dictionaryUpdatedWithName.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \"{dictionaryName}\" updated.'**
  String dictionaryUpdatedWithName(Object dictionaryName);

  /// No description provided for @directoryForDictionaryCreated.
  ///
  /// In en, this message translates to:
  /// **'Directory for dictionary \'{dictionaryName}\' created at: {directoryPath}'**
  String directoryForDictionaryCreated(Object dictionaryName, Object directoryPath);

  /// No description provided for @directoryForDictionaryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Directory for dictionary \'{dictionaryName}\' not found at: {directoryPath}'**
  String directoryForDictionaryNotFound(Object dictionaryName, Object directoryPath);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editDictionary.
  ///
  /// In en, this message translates to:
  /// **'Edit Dictionary'**
  String get editDictionary;

  /// No description provided for @editWord.
  ///
  /// In en, this message translates to:
  /// **'Edit Word'**
  String get editWord;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @errorCheckingExistence.
  ///
  /// In en, this message translates to:
  /// **'Error checking dictionary existence: {error}'**
  String errorCheckingExistence(Object error);

  /// No description provided for @errorCreatingDictionary.
  ///
  /// In en, this message translates to:
  /// **'Failed to create dictionary.'**
  String get errorCreatingDictionary;

  /// No description provided for @errorDeletingDictionary.
  ///
  /// In en, this message translates to:
  /// **'Error deleting dictionary \'{dictionaryName}\''**
  String errorDeletingDictionary(Object dictionaryName);

  /// No description provided for @errorDeletingDictionaryDirectory.
  ///
  /// In en, this message translates to:
  /// **'Error deleting dictionary \'{dictionaryName}\': {error}'**
  String errorDeletingDictionaryDirectory(Object dictionaryName, Object error);

  /// No description provided for @errorListingDictionaryDirectories.
  ///
  /// In en, this message translates to:
  /// **'Error listing dictionary directories: {error}'**
  String errorListingDictionaryDirectories(Object error);

  /// No description provided for @errorLoadingDictionaries.
  ///
  /// In en, this message translates to:
  /// **'Error loading dictionaries'**
  String get errorLoadingDictionaries;

  /// No description provided for @errorLoadingDictionary.
  ///
  /// In en, this message translates to:
  /// **'Error loading dictionary \'{dictionaryName}\': {error}'**
  String errorLoadingDictionary(Object dictionaryName, Object error);

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings: {error}'**
  String errorLoadingSettings(Object error);

  /// No description provided for @errorRemovingWord.
  ///
  /// In en, this message translates to:
  /// **'Error removing word from \'{dictionaryName}\' at index {wordIndex}'**
  String errorRemovingWord(Object dictionaryName, Object wordIndex);

  /// No description provided for @errorSavingDictionary.
  ///
  /// In en, this message translates to:
  /// **'Error saving dictionary \'{dictionaryName}\': {error}'**
  String errorSavingDictionary(Object dictionaryName, Object error);

  /// No description provided for @errorSavingThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Error saving theme mode: {error}'**
  String errorSavingThemeMode(Object error);

  /// No description provided for @errorUpdatingWord.
  ///
  /// In en, this message translates to:
  /// **'Error updating word in \'{dictionaryName}\' at index {wordIndex}'**
  String errorUpdatingWord(Object dictionaryName, Object wordIndex);

  /// No description provided for @errorValidatingName.
  ///
  /// In en, this message translates to:
  /// **'Error validating name: {error}'**
  String errorValidatingName(Object error);

  /// No description provided for @errorValidatingNameDialog.
  ///
  /// In en, this message translates to:
  /// **'Error validating dictionary name.'**
  String get errorValidatingNameDialog;

  /// No description provided for @failedToDeleteWord.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete word.'**
  String get failedToDeleteWord;

  /// No description provided for @failedToFindWordForEdit.
  ///
  /// In en, this message translates to:
  /// **'Failed to find word for editing/deleting.'**
  String get failedToFindWordForEdit;

  /// No description provided for @failedToAddWord.
  ///
  /// In en, this message translates to:
  /// **'Failed to add word.'**
  String get failedToAddWord;

  /// No description provided for @failedToUpdateDictionary.
  ///
  /// In en, this message translates to:
  /// **'Failed to update dictionary.'**
  String get failedToUpdateDictionary;

  /// No description provided for @failedToUpdateWord.
  ///
  /// In en, this message translates to:
  /// **'Failed to update word.'**
  String get failedToUpdateWord;

  /// No description provided for @folderColor.
  ///
  /// In en, this message translates to:
  /// **'Folder Color'**
  String get folderColor;

  /// No description provided for @foundDictionaryDirectories.
  ///
  /// In en, this message translates to:
  /// **'Found dictionary directories: {dirNames}'**
  String foundDictionaryDirectories(Object dirNames);

  /// No description provided for @importExportDictionaries.
  ///
  /// In en, this message translates to:
  /// **'Import / Export Dictionaries'**
  String get importExportDictionaries;

  /// No description provided for @invalidWordIndexForDictionary.
  ///
  /// In en, this message translates to:
  /// **'Invalid word index {wordIndex} for dictionary \'{dictionaryName}\'. Max index is {maxIndex}.'**
  String invalidWordIndexForDictionary(Object dictionaryName, Object maxIndex, Object wordIndex);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDrawer.
  ///
  /// In en, this message translates to:
  /// **'Language: English'**
  String get languageDrawer;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @maxLength20.
  ///
  /// In en, this message translates to:
  /// **'Maximum 20 characters'**
  String get maxLength20;

  /// No description provided for @maxLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Maximum length is {maxLength} characters'**
  String maxLengthValidation(Object maxLength);

  /// No description provided for @myDictionaries.
  ///
  /// In en, this message translates to:
  /// **'My Dictionaries'**
  String get myDictionaries;

  /// No description provided for @oopsImportExportNotReady.
  ///
  /// In en, this message translates to:
  /// **'Import/Export feature is not ready yet. :('**
  String get oopsImportExportNotReady;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @pleaseEnterTranslation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a translation'**
  String get pleaseEnterTranslation;

  /// No description provided for @pleaseEnterWord.
  ///
  /// In en, this message translates to:
  /// **'Please enter a word'**
  String get pleaseEnterWord;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sortByAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Sort Alphabetically'**
  String get sortByAlphabetical;

  /// No description provided for @sortByLastAdded.
  ///
  /// In en, this message translates to:
  /// **'Sort by Last Added'**
  String get sortByLastAdded;

  /// No description provided for @successfullyDeletedDictionary.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted dictionary \'{dictionaryName}\' at: {directoryPath}'**
  String successfullyDeletedDictionary(Object dictionaryName, Object directoryPath);

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @updateDictionary.
  ///
  /// In en, this message translates to:
  /// **'Update Dictionary'**
  String get updateDictionary;

  /// No description provided for @updateWord.
  ///
  /// In en, this message translates to:
  /// **'Update Word'**
  String get updateWord;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get word;

  /// No description provided for @wordAndTranslationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Word and translation length cannot exceed 20 characters.'**
  String get wordAndTranslationMaxLength;

  /// No description provided for @wordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Word deleted'**
  String get wordDeleted;

  /// No description provided for @wordDeletedWithName.
  ///
  /// In en, this message translates to:
  /// **'Word \"{wordName}\" deleted'**
  String wordDeletedWithName(String word, Object wordName);

  /// No description provided for @wordOrTranslationCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Word and translation cannot be empty.'**
  String get wordOrTranslationCannotBeEmpty;

  /// No description provided for @wordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Word updated successfully!'**
  String get wordUpdatedSuccessfully;

  /// No description provided for @dictionaryType.
  ///
  /// In en, this message translates to:
  /// **'Dictionary Type'**
  String get dictionaryType;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get words;

  /// No description provided for @sentence.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get sentence;

  /// No description provided for @sentences.
  ///
  /// In en, this message translates to:
  /// **'Sentences'**
  String get sentences;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get goBack;

  /// No description provided for @importDictionary.
  ///
  /// In en, this message translates to:
  /// **'Import Dictionary'**
  String get importDictionary;

  /// No description provided for @exportDictionary.
  ///
  /// In en, this message translates to:
  /// **'Export Dictionary'**
  String get exportDictionary;

  /// No description provided for @selectDictionaryToExport.
  ///
  /// In en, this message translates to:
  /// **'Select dictionary to export'**
  String get selectDictionaryToExport;

  /// No description provided for @selectExportLocation.
  ///
  /// In en, this message translates to:
  /// **'Select export location'**
  String get selectExportLocation;

  /// No description provided for @selectDictionaryFileToImport.
  ///
  /// In en, this message translates to:
  /// **'Select dictionary file to import (.json)'**
  String get selectDictionaryFileToImport;

  /// No description provided for @dictionaryExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \"{dictionaryName}\" exported successfully to {filePath}'**
  String dictionaryExportedSuccess(Object dictionaryName, Object filePath);

  /// No description provided for @dictionaryExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export dictionary \"{dictionaryName}\": {error}'**
  String dictionaryExportFailed(Object dictionaryName, Object error);

  /// No description provided for @dictionaryImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Dictionary \"{dictionaryName}\" imported successfully.'**
  String dictionaryImportedSuccess(Object dictionaryName);

  /// No description provided for @dictionaryImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import dictionary: {error}'**
  String dictionaryImportFailed(Object error);

  /// No description provided for @importNameConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Name Conflict'**
  String get importNameConflictTitle;

  /// No description provided for @importNameConflictContent.
  ///
  /// In en, this message translates to:
  /// **'A dictionary named \"{dictionaryName}\" already exists. What would you like to do?'**
  String importNameConflictContent(Object dictionaryName);

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get overwrite;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @invalidDictionaryFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid dictionary file format or content.'**
  String get invalidDictionaryFile;

  /// No description provided for @errorReadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error reading file: {error}'**
  String errorReadingFile(Object error);

  /// No description provided for @noDictionariesToExport.
  ///
  /// In en, this message translates to:
  /// **'No dictionaries available to export.'**
  String get noDictionariesToExport;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @filePickerOperationCancelled.
  ///
  /// In en, this message translates to:
  /// **'File selection cancelled.'**
  String get filePickerOperationCancelled;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import Error'**
  String get importError;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export Error'**
  String get exportError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied.'**
  String get permissionDenied;

  /// No description provided for @holdToEdit.
  ///
  /// In en, this message translates to:
  /// **'Hold to edit...'**
  String get holdToEdit;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
