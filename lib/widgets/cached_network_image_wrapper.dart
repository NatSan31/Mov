import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';

class CachedImageWrapper extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  // Caché estático en memoria para evitar re-decodificar Base64 en cada cuadro
  static final Map<String, Uint8List> _base64Cache = {};

  const CachedImageWrapper({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // 1. Soporte para imágenes codificadas en Base64 con caché y gaplessPlayback (Cero parpadeos)
    if (imageUrl.startsWith('data:image')) {
      try {
        Uint8List? bytes = _base64Cache[imageUrl];
        if (bytes == null) {
          final commaIndex = imageUrl.indexOf(',');
          final base64String = commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : imageUrl;
          bytes = base64Decode(base64String);
          _base64Cache[imageUrl] = bytes;
        }

        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true, // Evita parpadeos en negro durante reconstrucciones
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (e) {
        imageWidget = _buildPlaceholder();
      }
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // 2. URLs de Firebase Storage o Unsplash con persistencia en caché local
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey.withOpacity(0.15),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade900,
      child: const Icon(Icons.person, color: Colors.white54, size: 26),
    );
  }
}
