import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../services/study_ai_logic.dart';

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
    // Add welcome message
    _logic.responses.add("Hello! I'm your Study AI assistant. How can I help you today?");
  }

  void _submitInput() async {
    String inputText = _inputController.text.trim();
    if (inputText.isEmpty) return;

    // Add user message to chat
    _logic.responses.add('User: $inputText');

    // Clear input field and show typing indicator
    setState(() {
      _inputController.clear();
      _isGenerating = true;
    });

    _scrollToEnd();

    try {
      if (_pendingImageFile != null || _pendingFileBytes != null) {
        // Process attachment with the user's prompt
        if (_pendingImageFile != null) {
          await _logic.processImageWithPrompt(_pendingImageFile!, inputText);
          _pendingImageFile = null;
        } else if (_pendingFileBytes != null) {
          await _logic.processFileWithPrompt(_pendingFileBytes!, _pendingFileName, inputText);
          _pendingFileBytes = null;
          _pendingFileName = '';
        }
      } else {
        // Regular text chat
        await _logic.chatWithAI(inputText);
      }
    } finally {
      setState(() {
        _isGenerating = false;
        _pendingAttachmentType = '';
      });
      _scrollToEnd();
    }
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
        _logic.responses.add('User: [Image from camera]');
      });
      _scrollToEnd();
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
        _logic.responses.add('User: [Image from gallery]');
      });
      _scrollToEnd();
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
          _logic.responses.add('User: [File: ${file.name}]');
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

      if (_logic.responses.isNotEmpty &&
          (_logic.responses.last.contains('[Image from') ||
              _logic.responses.last.contains('[File:'))) {
        _logic.responses.removeLast();
      }
    });
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New conversation',
            onPressed: () {
              setState(() {
                _logic.clearQuestions();
                _logic.clearResponses();
                _removeAttachment();
                // Add welcome message
                _logic.responses.add("Hello! I'm your Study AI assistant. How can I help you today?");
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Clear') {
                setState(() {
                  _logic.clearQuestions();
                  _logic.clearResponses();
                  _removeAttachment();
                  // Add welcome message
                  _logic.responses.add("Hello! I'm your Study AI assistant. How can I help you today?");
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
          // Attachment preview area
          if (_pendingAttachmentType.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Attachment preview
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _pendingImageFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _pendingImageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      _pendingAttachmentType == 'file'
                          ? Icons.insert_drive_file
                          : Icons.image,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Attachment info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pendingFileName.isNotEmpty
                              ? _pendingFileName
                              : _pendingAttachmentType == 'camera'
                              ? 'Camera Photo'
                              : 'Gallery Image',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add a message to process this attachment',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Remove button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _removeAttachment,
                    color: Colors.red[400],
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _logic.responses.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                // AI is generating response
                if (_isGenerating && index == _logic.responses.length) {
                  return _buildAITypingIndicator();
                }

                // Regular message
                final response = _logic.responses[index];
                final isUser = response.startsWith('User: ');
                final message = isUser ? response.substring(6) : response;

                return _buildMessageBubble(isUser, message);
              },
            ),
          ),

          // Input area with nice shadow
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
                  // Input field with attachment buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Attachment buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              tooltip: 'Take photo',
                              onPressed: _handleCamera,
                              color: Colors.grey[600],
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.image),
                              tooltip: 'Upload image',
                              onPressed: _handleGallery,
                              color: Colors.grey[600],
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.attach_file),
                              tooltip: 'Attach file',
                              onPressed: _handleFile,
                              color: Colors.grey[600],
                              iconSize: 20,
                            ),
                          ],
                        ),

                        // Text input field
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              hintText: _pendingAttachmentType.isNotEmpty
                                  ? 'Describe what to do with this attachment...'
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

                        // Send button
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

                  // Powered by label
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

  Widget _buildMessageBubble(bool isUser, String message) {
    // Handle message content types
    bool isImageAttachment = message.contains('[Image from');
    bool isFileAttachment = message.contains('[File:');

    // Display different content based on attachment type
    if (isImageAttachment && _pendingImageFile != null && _pendingAttachmentType.isNotEmpty) {
      // Show actual image preview
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      _pendingImageFile!,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: _removeAttachment,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                  child: Text(
                    'Tap to send with a message',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else if (isFileAttachment) {
      // File attachment
      String fileName = message.contains('[File:')
          ? message.split('[File: ')[1].split(']')[0]
          : 'File';

      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12.0),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: isUser ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isUser ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
              if (_pendingAttachmentType.isNotEmpty && _pendingFileBytes != null)
                GestureDetector(
                  onTap: _removeAttachment,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.white24 : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: isUser ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      // Regular text message
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          margin: EdgeInsets.only(
            top: 4.0,
            bottom: 4.0,
            left: isUser ? 60.0 : 0,
            right: isUser ? 0 : 60.0,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 16.0,
                color: isUser ? Colors.white : Colors.black,
              ),
              h1: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: isUser ? Colors.white : Colors.black,
              ),
              code: TextStyle(
                backgroundColor: isUser
                    ? Colors.blue[800]
                    : Colors.grey[200],
                color: isUser ? Colors.white : Colors.black87,
                fontFamily: 'monospace',
              ),
              codeblockDecoration: BoxDecoration(
                color: isUser
                    ? Colors.blue[800]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
  }
}