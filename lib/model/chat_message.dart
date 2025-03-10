// dart
import 'dart:typed_data';

class ChatMessage {
  final String from;  // e.g. "user" or "ai"
  final String content;
  final Uint8List? attachmentBytes;
  final String? mime;
  final String? fileName;

  ChatMessage({
    required this.from,
    required this.content,
    this.attachmentBytes,
    this.mime,
    this.fileName,
  });
}