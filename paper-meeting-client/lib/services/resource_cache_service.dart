import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CacheWarmupResult {
  const CacheWarmupResult({
    required this.completed,
    required this.total,
    required this.cachedByUrl,
  });

  final int completed;
  final int total;
  final Map<String, String> cachedByUrl;
}

class ResourceCacheService {
  Future<String?> getCachedFilePath(String url) async {
    final file = await _resolveCacheFile(url);
    return await file.exists() ? file.path : null;
  }

  Future<String> cacheResource(String url) async {
    final file = await _resolveCacheFile(url);
    if (await file.exists()) {
      return file.path;
    }
    await file.parent.create(recursive: true);
    final response = await http.get(Uri.parse(url), headers: const <String, String>{'Accept': '*/*'});
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('下载失败，HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  Future<CacheWarmupResult> warmupResources(
    List<String> urls, {
    void Function(double progress)? onProgress,
  }) async {
    final normalized = urls.where((item) => item.trim().isNotEmpty).toSet().toList();
    final cached = <String, String>{};
    if (normalized.isEmpty) {
      onProgress?.call(1);
      return const CacheWarmupResult(completed: 0, total: 0, cachedByUrl: <String, String>{});
    }
    var completed = 0;
    for (final url in normalized) {
      try {
        final path = await cacheResource(url);
        cached[url] = path;
      } finally {
        completed += 1;
        onProgress?.call(completed / normalized.length);
      }
    }
    return CacheWarmupResult(completed: completed, total: normalized.length, cachedByUrl: cached);
  }

  Future<File> _resolveCacheFile(String url) async {
    final baseDir = await getApplicationCacheDirectory();
    final uri = Uri.parse(url);
    final extension = _guessExtension(uri);
    final encoded = base64Url.encode(utf8.encode(url));
    return File('${baseDir.path}${Platform.pathSeparator}meeting_resources${Platform.pathSeparator}$encoded$extension');
  }

  String _guessExtension(Uri uri) {
    final path = uri.path.toLowerCase();
    final index = path.lastIndexOf('.');
    if (index == -1) {
      return '.bin';
    }
    return path.substring(index);
  }
}
