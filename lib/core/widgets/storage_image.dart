import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Loads images from solarpartner.pk/storage/ via the /api/media/ proxy.
/// CDN strips CORS headers for image/png but passes them for application/json.
/// The proxy returns base64 JSON → we decode and display as Image.memory.
class StorageImage extends StatefulWidget {
  final String? url;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const StorageImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  });

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  // App-wide in-memory cache: mediaUrl → decoded bytes
  static final Map<String, Uint8List> _cache = {};

  Uint8List? _bytes;
  bool _loading = true;
  bool _error = false;

  static const _storageBase = 'https://solarpartner.pk/storage/';
  static const _mediaEndpoint = 'https://solarpartner.pk/api/media';

  String _toMediaUrl(String url) {
    // e.g. https://solarpartner.pk/storage/products/xyz.png
    //   →  https://solarpartner.pk/api/media?p=products/xyz.png
    // Path in query param (not URL path) to avoid CDN image interception.
    // Do NOT encode slashes — Dio on Flutter Web may double-encode %2F.
    if (url.startsWith(_storageBase)) {
      final path = url.substring(_storageBase.length);
      return '$_mediaEndpoint?p=$path';
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(StorageImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      setState(() { _loading = true; _error = false; _bytes = null; });
      _load();
    }
  }

  Future<void> _load() async {
    final rawUrl = widget.url;
    if (rawUrl == null || rawUrl.isEmpty) {
      if (mounted) setState(() { _loading = false; _error = true; });
      return;
    }

    final mediaUrl = _toMediaUrl(rawUrl);

    // Hit cache first
    if (_cache.containsKey(mediaUrl)) {
      if (mounted) setState(() { _bytes = _cache[mediaUrl]; _loading = false; });
      return;
    }

    try {
      final res = await Dio().get<Map<String, dynamic>>(
        mediaUrl,
        options: Options(responseType: ResponseType.json, sendTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)),
      );
      final b64 = res.data?['data'] as String?;
      if (b64 == null) throw Exception('No data');
      final bytes = base64Decode(b64);
      _cache[mediaUrl] = bytes;
      if (mounted) setState(() { _bytes = bytes; _loading = false; });
    } catch (e) {
      // ignore: avoid_print
      print('[StorageImage] failed to load $mediaUrl: $e');
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1565C0)),
              ),
            ),
          );
    }
    if (_error || _bytes == null) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade100,
            child: Center(
              child: Icon(Icons.inventory_2_outlined, size: 28, color: Colors.grey.shade400),
            ),
          );
    }
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );
  }
}
