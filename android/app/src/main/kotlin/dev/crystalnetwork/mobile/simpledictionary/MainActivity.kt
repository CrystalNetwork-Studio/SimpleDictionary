package dev.crystalnetwork.mobile.simpledictionary

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.FileOutputStream
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dev.crystalnetwork.mobile.simpledictionary/storage"
    private val TAG = "MainActivity"
    private val READ_REQUEST_CODE = 42
    private val WRITE_REQUEST_CODE = 43
    private val DIRECTORY_REQUEST_CODE = 44 // New request code for selecting a directory

    // For storing results to pass back to Flutter
    private var pendingResult: MethodChannel.Result? = null
    private var pendingOperation: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up method channel for communicating with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            pendingResult = result
            pendingOperation = call.method

            when (call.method) {
                "openDocumentForRead" -> {
                    val mimeTypes = call.argument<List<String>>("mimeTypes") ?: listOf("*/*")
                    openDocumentForRead(mimeTypes)
                }
                "createDocumentForWrite" -> {
                    // This method allows creating a file anywhere the user picks via the system dialog
                    val fileName = call.argument<String>("fileName") ?: "document.json"
                    val mimeType = call.argument<String>("mimeType") ?: "application/json"
                    createDocumentForWrite(fileName, mimeType)
                }
                "selectExportDirectory" -> {
                    // This method allows the user to pick a directory for future exports
                    selectExportDirectory()
                }
                "createFileInDirectory" -> {
                    // This method creates a file inside a previously selected directory
                    val directoryUriString = call.argument<String>("directoryUri")
                    val fileName = call.argument<String>("fileName") ?: "document.json"
                    val mimeType = call.argument<String>("mimeType") ?: "application/json"
                    if (directoryUriString != null) {
                        createFileInDirectory(directoryUriString, fileName, mimeType, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Directory URI must be provided", null)
                        pendingResult = null // Clear state immediately if args are bad
                        pendingOperation = null
                    }
                }
                "writeToUri" -> {
                    val uri = call.argument<String>("uri")
                    val content = call.argument<String>("content")
                    if (uri != null && content != null) {
                        writeToUri(Uri.parse(uri), content, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "URI and content must be provided", null)
                        pendingResult = null // Clear state immediately if args are bad
                        pendingOperation = null
                    }
                }
                "readFromUri" -> {
                    val uri = call.argument<String>("uri")
                    if (uri != null) {
                        readFromUri(Uri.parse(uri), result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "URI must be provided", null)
                        pendingResult = null // Clear state immediately if args are bad
                        pendingOperation = null
                    }
                }
                "checkPermission" -> {
                     // SAF methods don't require explicit storage permissions on modern Android
                    result.success(true)
                    pendingResult = null // Clear state immediately as no async operation started
                    pendingOperation = null
                }
                "requestPermission" -> {
                    // SAF methods don't require explicit storage permissions on modern Android
                    result.success(true)
                     pendingResult = null // Clear state immediately as no async operation started
                    pendingOperation = null
                }
                else -> {
                    result.notImplemented()
                    pendingResult = null // Clear state immediately
                    pendingOperation = null
                }
            }
        }
    }

    /**
     * Launches system picker to select a document for reading.
     */
    private fun openDocumentForRead(mimeTypes: List<String>) {
        // Create an intent for opening documents
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = if (mimeTypes.size == 1) mimeTypes[0] else "*/*"

            // Allow multiple mime types
            if (mimeTypes.size > 1) {
                putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
            }

            // Ensure we can open the file again later if needed
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        }

        try {
            startActivityForResult(intent, READ_REQUEST_CODE)
        } catch (e: Exception) {
            Log.e(TAG, "Error launching file picker for read", e)
            pendingResult?.error("INTENT_ERROR", "Error launching file picker: ${e.message}", null)
            pendingResult = null
            pendingOperation = null
        }
    }

    /**
     * Launches system picker to select a location and name to create a new document.
     */
    private fun createDocumentForWrite(fileName: String, mimeType: String) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)

            // Ensure we can save to this file again later
            flags = Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        }

        try {
            startActivityForResult(intent, WRITE_REQUEST_CODE)
        } catch (e: Exception) {
            Log.e(TAG, "Error launching file saver", e)
            pendingResult?.error("INTENT_ERROR", "Error launching file saver: ${e.message}", null)
            pendingResult = null
            pendingOperation = null
        }
    }

     /**
     * Launches system picker to select a directory tree for persistent access.
     */
    private fun selectExportDirectory() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            // Ensure we can write to the selected directory later
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        }

        try {
            startActivityForResult(intent, DIRECTORY_REQUEST_CODE)
        } catch (e: Exception) {
            Log.e(TAG, "Error launching directory picker", e)
            pendingResult?.error("INTENT_ERROR", "Error launching directory picker: ${e.message}", null)
            pendingResult = null
            pendingOperation = null
        }
    }

    /**
     * Creates a new file within a given directory URI.
     * Requires a persistent URI permission for the directory.
     */
    private fun createFileInDirectory(directoryUriString: String, fileName: String, mimeType: String, result: MethodChannel.Result) {
        try {
            val directoryUri = Uri.parse(directoryUriString)
            val newFileUri = DocumentsContract.createDocument(contentResolver, directoryUri, mimeType, fileName)

            if (newFileUri != null) {
                 // No need to take persistent permission on the new file URI, as the directory permission covers it.
                 // But we should verify we have permissions for the directory itself.
                 // If the selectExportDirectory took persistable permission, we're good.

                // Return the URI of the newly created file
                result.success(newFileUri.toString())
            } else {
                result.error("CREATE_ERROR", "Failed to create document in directory", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating file in directory: $directoryUriString", e)
            result.error("CREATE_ERROR", "Error creating file: ${e.message}", null)
        } finally {
            // Clear state after the operation completes (synchronously)
            pendingResult = null
            pendingOperation = null
        }
    }


    /**
     * Reads content from a given URI.
     */
    private fun readFromUri(uri: Uri, result: MethodChannel.Result) {
        try {
            contentResolver.openInputStream(uri)?.use { inputStream ->
                BufferedReader(InputStreamReader(inputStream)).use { reader ->
                    val content = StringBuilder()
                    var line: String?
                    while (reader.readLine().also { line = it } != null) {
                        content.append(line)
                        // Add newline back, as readLine() strips it
                        content.append('\n')
                    }

                    // Remove the last newline added by the loop if the original file didn't end with one
                    // Or if the file was empty
                     if (content.isNotEmpty() && content.last() == '\n') {
                         content.deleteCharAt(content.length - 1)
                     }


                    result.success(content.toString())
                }
            } ?: run {
                result.error("READ_ERROR", "Could not open input stream for URI: $uri", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error reading from URI: $uri", e)
            result.error("READ_ERROR", "Error reading file: ${e.message}", null)
        } finally {
             // Clear state after the operation completes (synchronously)
            pendingResult = null
            pendingOperation = null
        }
    }

    /**
     * Writes content to a given URI.
     */
    private fun writeToUri(uri: Uri, content: String, result: MethodChannel.Result) {
        try {
            // Use "wt" mode (write, truncate) to overwrite existing content
            contentResolver.openOutputStream(uri, "wt")?.use { outputStream ->
                outputStream.write(content.toByteArray())
                outputStream.flush() // Ensure all data is written
                result.success(true)
            } ?: run {
                result.error("WRITE_ERROR", "Could not open output stream for URI: $uri", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error writing to URI: $uri", e)
            result.error("WRITE_ERROR", "Error writing file: ${e.message}", null)
        } finally {
             // Clear state after the operation completes (synchronously)
            pendingResult = null
            pendingOperation = null
        }
    }

    // Note: Traditional storage permissions (READ/WRITE_EXTERNAL_STORAGE) are not required
    // for using Storage Access Framework (ACTION_OPEN_DOCUMENT, ACTION_CREATE_DOCUMENT, ACTION_OPEN_DOCUMENT_TREE)
    // on Android 4.4 (KitKat) and above. The SAF intents handle permissions via URIs.
    // The checkPermission and requestPermission methods below are largely unnecessary for the SAF methods
    // but are kept to match the original structure, though their logic might be simplified or removed
    // if the app *only* uses SAF for storage access.

    private fun checkStoragePermission(): Boolean {
        // With SAF, URI permissions are granted by the system picker, not via runtime permissions.
        // This method is effectively moot for SAF operations.
        // Returning true as SAF grants access on successful selection.
        return true
    }

    private fun requestStoragePermission(result: MethodChannel.Result) {
         // With SAF, permission is granted via user interaction with the picker, not runtime permission request.
        // This method is effectively moot for SAF operations.
        // Returning true to indicate that the "request" flow is handled by the picker implicitly.
        result.success(true)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            READ_REQUEST_CODE -> {
                if (resultCode == RESULT_OK && data != null) {
                    val uri = data.data
                    uri?.let {
                        // Take persistent permission for the picked URI
                        try {
                             contentResolver.takePersistableUriPermission(
                                it,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION
                            )
                            if (pendingOperation == "openDocumentForRead" && pendingResult != null) {
                                // If the request was specifically to open and read, do it now
                                // readFromUri will clear pendingResult/pendingOperation
                                readFromUri(it, pendingResult!!)
                            } else {
                                // Otherwise, just return the URI string
                                pendingResult?.success(it.toString())
                                // Clear pending state after success
                                pendingResult = null
                                pendingOperation = null
                            }
                        } catch (e: SecurityException) {
                             Log.e(TAG, "Failed to take persistable read URI permission for $it", e)
                             pendingResult?.error("PERMISSION_DENIED", "Failed to take persistable read URI permission", null)
                             pendingResult = null
                             pendingOperation = null
                        }

                    } ?: run {
                         pendingResult?.error("NO_URI", "No URI returned from file picker for read", null)
                         pendingResult = null
                         pendingOperation = null
                    }
                } else {
                    // Handle user cancellation or other result codes
                    pendingResult?.error("USER_CANCELED", "File selection canceled for read", null)
                    // Clear pending state regardless of success/failure
                    pendingResult = null
                    pendingOperation = null
                }
            }
            WRITE_REQUEST_CODE -> {
                if (resultCode == RESULT_OK && data != null) {
                    val uri = data.data
                    uri?.let {
                        // Take persistent permission for the created URI
                        try {
                            contentResolver.takePersistableUriPermission(
                                it,
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                            )
                            // Return the URI string for writing later
                            pendingResult?.success(it.toString())
                        } catch (e: SecurityException) {
                             Log.e(TAG, "Failed to take persistable write URI permission for $it", e)
                             pendingResult?.error("PERMISSION_DENIED", "Failed to take persistable write URI permission", null)
                        } finally {
                           // Clear pending state after success or permission error
                           pendingResult = null
                           pendingOperation = null
                        }
                    } ?: run {
                         pendingResult?.error("NO_URI", "No URI returned from file saver", null)
                         pendingResult = null
                         pendingOperation = null
                    }
                } else {
                    // Handle user cancellation or other result codes
                    pendingResult?.error("USER_CANCELED", "File creation canceled", null)
                    // Clear pending state regardless of success/failure
                    pendingResult = null
                    pendingOperation = null
                }
            }
             DIRECTORY_REQUEST_CODE -> {
                if (resultCode == RESULT_OK && data != null) {
                    val uri = data.data
                    uri?.let {
                        // Take persistent permission for the selected directory tree
                        // This grants access to the directory and its contents
                         try {
                             contentResolver.takePersistableUriPermission(
                                it,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                            )
                             // Return the directory URI string
                             pendingResult?.success(it.toString())
                         } catch (e: SecurityException) {
                            Log.e(TAG, "Failed to take persistable URI permission for directory $it", e)
                            pendingResult?.error("PERMISSION_DENIED", "Failed to take persistable URI permission for directory", null)
                         } finally {
                            // Clear pending state after success or permission error
                            pendingResult = null
                            pendingOperation = null
                         }
                    } ?: run {
                         pendingResult?.error("NO_URI", "No directory URI returned from picker", null)
                         pendingResult = null
                         pendingOperation = null
                    }
                } else {
                    // Handle user cancellation or other result codes
                    pendingResult?.error("USER_CANCELED", "Directory selection canceled", null)
                     // Clear pending state regardless of success/failure
                    pendingResult = null
                    pendingOperation = null
                }
            }
        }
    }

     // Note on clearPendingState():
     // The pendingResult and pendingOperation are cleared *after* the async operation (onActivityResult)
     // completes and delivers a result or error. For synchronous operations like checkPermission or
     // bad arguments validation, they should be cleared immediately. Added checks for this.
}
