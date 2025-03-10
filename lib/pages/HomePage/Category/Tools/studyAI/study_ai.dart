// dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../../../model/chat_message.dart';
import '../../../../../services/study_ai_logic.dart';

class StudyAI extends StatefulWidget {
  const StudyAI({super.key});

  @override
  _StudyAIState createState() => _StudyAIState();
}

class _StudyAIState extends State<StudyAI> with TickerProviderStateMixin {
  final StudyAILogic _logic = StudyAILogic();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  // Attachment related properties
  File? _pendingImageFile;
  Uint8List? _pendingFileBytes;
  String _pendingFileName = '';
  String _pendingAttachmentType = '';

  @override
  void initState() {
    super.initState();
    // Add welcome message as ChatMessage
    _logic.responses.add(
      ChatMessage(
        from: "ai",
        content: "Hello! I'm your Study AI assistant. How can I help you today?",
      ),
    );
  }



  Future<void> _handleCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _pendingImageFile = File(pickedFile.path);
        _pendingFileBytes = null;
        _pendingAttachmentType = 'camera';

      });
      _scrollToEnd();
    }
  }


  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
  Future<void> _handleGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _pendingImageFile = File(pickedFile.path);
        _pendingFileBytes = null;
        _pendingAttachmentType = 'gallery';
      });
    }
  }

  Future<void> _handleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _pendingFileBytes = file.bytes!;
          _pendingFileName = file.name;
          _pendingImageFile = null;
          _pendingAttachmentType = 'file';
        });
        _scrollToEnd();
      }
    }
  }

  void _removeAttachment() {
    setState(() {
      _pendingImageFile = null;
      _pendingFileBytes = null;
      _pendingFileName = '';
      _pendingAttachmentType = '';


    });
  }
  void _submitInput() async {
    String inputText = _inputController.text.trim();
    if (inputText.isEmpty && _pendingImageFile == null && _pendingFileBytes == null) return;

    Uint8List? attachmentData;
    String? mimeType;
    String? fileName;
    File? tempImageFile;

    // Store temporary references before clearing
    if (_pendingImageFile != null) {
      tempImageFile = _pendingImageFile;
      attachmentData = await _pendingImageFile!.readAsBytes();
      mimeType = 'image/jpeg';
    } else if (_pendingFileBytes != null) {
      attachmentData = _pendingFileBytes;
      mimeType = 'application/octet-stream';
      fileName = _pendingFileName;
    }

    // Add attachment as a separate message if present
    if (attachmentData != null) {
      ChatMessage attachmentMessage = ChatMessage(
        from: "user",
        content: "",
        attachmentBytes: attachmentData,
        mime: mimeType,
        fileName: fileName,
      );

      // Add image message
      _logic.responses.add(attachmentMessage);
    }

    // Add text message if present
    if (inputText.isNotEmpty) {
      ChatMessage textMessage = ChatMessage(
        from: "user",
        content: inputText,
        attachmentBytes: null,
        mime: null,
        fileName: null,
      );

      // Add text message
      _logic.responses.add(textMessage);
    }

    // Clear inputs and preview immediately
    setState(() {
      _inputController.clear();
      _pendingImageFile = null;
      _pendingFileBytes = null;
      _pendingFileName = '';
      _pendingAttachmentType = '';
      _isGenerating = true;
    });

    _scrollToEnd();

    try {
      if (attachmentData != null) {
        if (tempImageFile != null) {
          if (inputText.isNotEmpty) {
            await _logic.processImageWithPrompt(tempImageFile, inputText);
          } else {
            await _logic.processImageWithAI(tempImageFile);
          }
        } else if (fileName != null) {
          await _logic.processFileWithPrompt(attachmentData, fileName, inputText);
        }
      } else if (inputText.isNotEmpty) {
        await _logic.chatWithAI(inputText);
      }
    } catch (e) {
      print("Error processing AI request: $e");
      // Optionally add error message to chat
      _logic.responses.add(
        ChatMessage(
          from: "system",
          content: "Error processing request: ${e.toString()}",
        ),
      );
    } finally {
      // Always reset generating flag when done
      setState(() {
        _isGenerating = false;
      });
      _scrollToEnd();
    }
  }
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  void _showAttachmentOptions() {
    // Get the position and size of the input field container
    final RenderBox inputBox = context.findRenderObject() as RenderBox;
    final Offset position = inputBox.localToGlobal(Offset.zero);
    final Size size = inputBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx + 16, // Offset from left edge
          position.dy + size.height , // Position BELOW the input field
          position.dx + 24,
          position.dy + size.height + 10
      ),
      items: [
        PopupMenuItem<String>(
          value: 'camera',
          child: Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Camera'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'gallery',
          child: Row(
            children: [
              Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Gallery'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'file',
          child: Row(
            children: [
              Icon(
                Icons.attach_file,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('File'),
            ],
          ),
        ),
      ],
    ).then((String? value) {
      if (value != null) {
        switch (value) {
          case 'camera':
            _handleCamera();
            break;
          case 'gallery':
            _handleGallery();
            break;
          case 'file':
            _handleFile();
            break;
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Study AI'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [

          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Clear') {
                setState(() {
                  _logic.clearQuestions();
                  _logic.clearResponses();
                  _removeAttachment();
                  _logic.responses.add(
                    ChatMessage(
                      from: "ai",
                      content: "Hello! I'm your Study AI assistant. How can I help you today?",
                    ),
                  );
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Clear',
                  child: ListTile(
                    leading: Icon(Icons.clear),
                    title: Text('Clear'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Save',
                  child: ListTile(
                    leading: Icon(Icons.save),
                    title: Text('Save'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _logic.responses.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isGenerating && index == _logic.responses.length) {
                  return _buildAITypingIndicator();
                }
                ChatMessage response = _logic.responses[index];
                return _buildMessageBubble(response);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: SafeArea(
              child: Column(
                children: [
                  // Attachment preview area
                  if (_pendingImageFile != null || _pendingFileBytes != null)
                    _buildAttachmentPreview(),
                  // Input area
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon:const Icon(Icons.add_circle_outline),
                              tooltip: 'Take photo',
                              onPressed: _showAttachmentOptions,
                              color: Colors.grey[600],
                              iconSize: 24,
                            ),
                          ],
                        ),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              hintText: _pendingAttachmentType.isNotEmpty
                                  ? 'Add your question...'
                                  : 'Ask me anything...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                            ),
                            minLines: 1,
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _submitInput(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                          child: FloatingActionButton.small(
                            onPressed: _submitInput,
                            elevation: 0,
                            child: const Icon(Icons.send),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Powered by Google Gemini',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Icon(
                    _pendingAttachmentType == 'gallery' || _pendingAttachmentType == 'camera'
                        ? Icons.image
                        : Icons.attach_file,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pendingAttachmentType == 'gallery' || _pendingAttachmentType == 'camera'
                          ? 'Image Attachment'
                          : _pendingFileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: _removeAttachment,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_pendingImageFile != null)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Image.file(
                  _pendingImageFile!,
                  fit: BoxFit.contain,
                ),
              ),
            if (_pendingFileBytes != null && _pendingAttachmentType == 'file')
              Container(
                height: 120,
                color: Colors.grey[100],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFileIcon(_pendingFileName),
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pendingFileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildAITypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.only(top: 4.0, bottom: 16.0, right: 60.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Generating response',
                  speed: const Duration(milliseconds: 80),
                ),
              ],
              isRepeatingAnimation: true,
              totalRepeatCount: 10,
            ),
            const SizedBox(width: 8),
            _buildDotAnimation(),
          ],
        ),
      ),
    );
  }
  Widget _buildDotAnimation() {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          WavyAnimatedText('...'),
        ],
        isRepeatingAnimation: true,
        repeatForever: true,
      ),
    );
  }
  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.from == "user";

    // For messages with image attachments
    if (message.attachmentBytes != null) {
      if (message.mime?.startsWith('image') == true) {
        // Handle images (keep existing code)
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              top: 4.0,
              bottom: 4.0,
              left: isUser ? 60.0 : 0,
              right: isUser ? 0 : 60.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(16),
                    bottom: message.content.isEmpty ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Image.memory(
                    message.attachmentBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
                if (message.content.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).colorScheme.primary : Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
        // NEW CODE: Handle non-image files (documents, etc.)
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              top: 4.0,
              bottom: 4.0,
              left: isUser ? 60.0 : 0,
              right: isUser ? 0 : 60.0,
            ),
            decoration: BoxDecoration(
              color: isUser ? Theme.of(context).colorScheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon(message.fileName ?? 'unknown'),
                    size: 32,
                    color: isUser ? Colors.white : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.fileName ?? 'File',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (message.content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    // For text-only messages (keep existing code)
    else {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            top: 4.0,
            bottom: 4.0,
            left: isUser ? 60.0 : 0,
            right: isUser ? 0 : 60.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: isUser
              ? Text(
            message.content,
            style: const TextStyle(color: Colors.white),
          )
              : MarkdownBody(
            data: message.content,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 14),
              code: TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey[200],
              ),
              codeblockDecoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
  }
}