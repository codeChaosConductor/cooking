import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

// A cache for our cache handlers.
// So we don't have multiple instances writing to the same file
Map<String, Cache> _caches = {};

/// Utility class to handle cache files.
///
/// Create or get an existing cache handler by using `Cache.of(String)`.
///
/// For example:
/// ```dart
/// var website = Cache.of('website.json');
/// if (website.exists) {
///   website.read().then((value) {
///     debugPrint(value);
///   });
/// }
/// ```
class Cache {
  final String file;

  factory Cache.of(String file) {
    if (!_caches.containsKey(file)) {
      _caches[file] = Cache._internal(file);
    }

    return _caches[file]!;
  }

  Cache._internal(this.file);

  static Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$file');
  }

  /// Returns whether the given cache file exists or not.
  Future<bool> get exists async {
    final file = await _localFile;
    return file.exists();
  }

  /// Reads contents from a file using utf8 encoding.
  ///
  /// For an example usage see [Cache].
  Future<String> read() async {
    try {
      final file = await _localFile;

      // Read the file
      return file.readAsString();
    } catch (e) {
      // If encountering an error, return ''
      return '';
    }
  }

  /// Writes [value] into a file using utf8 encoding.
  Future<File> write(String value) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(value, flush: true);
  }
}
