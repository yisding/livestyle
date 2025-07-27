import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Mock image provider that returns a simple colored image instead of loading from network
class MockImageProvider extends ImageProvider<MockImageProvider> {
  final String url;
  final Color color;

  const MockImageProvider(this.url, {this.color = Colors.grey});

  @override
  Future<MockImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(MockImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  Future<ImageInfo> _loadAsync(MockImageProvider key) async {
    // Create a simple 100x100 colored image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), paint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(100, 100);
    
    return ImageInfo(image: image);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MockImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}

/// Extension to replace NetworkImage with MockImageProvider in tests
extension NetworkImageMock on NetworkImage {
  MockImageProvider toMock() => MockImageProvider(url);
}