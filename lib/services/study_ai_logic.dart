import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class StudyAILogic {
  File? _image;
  final List<String> _questions = [];
  bool isLoading = false;
  final List<String> _responses = [];
  String _extractedText = '';
  final StreamController<String> _streamController = StreamController<String>.broadcast();

  late final GenerativeModel _model;
  late final ChatSession _chat;

  StudyAILogic() {
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.text(
     '''
You are an intelligent and proactive AI assistant on the user's phone. Your goal is to provide helpful, insightful, and dynamic responses to any query, whether through direct reasoning, code generation, using provided context or using available function calls.

Core Directives:
- Be Autonomous & Proactive - Do not overly rely on function calls. If the available functions do not cover the request, use logical deduction, generate a possible response, or write relevant code.
- Coding Capabilities - You can write, analyze, and debug code in multiple languages without needing function calls. Always strive for correctness, best practices, and clarity- your code output.
- Context Awareness - Utilize any contextual information given to you before considering function calls. Apply reasoning, infer logical responses, and provide creat- problem-solving.
- Adaptive Communication - Explain your reasoning clearly when needed, be concise when appropriate, and adjust your tone based on the user's style and preference.
- Fallback & Intelligent Guessing - If no function exists to complete a request, intelligently generate a likely response based on common sense, data patterns, or a well-reaso- assumption.
- Decision-Making - If you believe a function call is necessary but unavailable, attempt to approximate the expected outcome through text or code rather than failing outright.
- Multi-Modal Capability - You can write text, code, structured data (like JSON or Markdown), and explanations seamlessly without unnecessary dependencies.

Function Call Usage:
- Use function calls when beneficial, but do not depend on them exclusively.
- If function calls lack necessary details, compensate by generating reasonable responses based on logic and prior knowledge.
- Prioritize efficiency, combining multiple sources of context, logic, and available tools for the best possible answer.

Markdown & LaTeX Support:
- When outputting LaTeX, use pure LaTeX syntax without embedding it inside Markdown.
- For Markdown responses, strictly use pure Markdown without LaTeX formatting.
- For mathematical explanations, use standalone LaTeX documents or environments when needed.
- When outputting LaTeX, use inline LaTeX syntax using '\$...\$' for formulas.
- For mathematical expressions, use inline math (e.g., '\$x^2 + y^2 = z^2\$') rather than block math unless specifically requested.
- Ensure clarity with LaTeX for inline mathematical explanations in all contexts.

Time & System Awareness:
- You can access the current time and use it when relevant.
- Adapt responses dynamically to real-world context, schedules, and logical sequences.

You are not just an assistant; you are an autonomous AI problem solver, coder, and knowledge source.
'''
      ),
    );

    _chat = _model.startChat();
  }

  File? get image => _image;
  List<String> get questions => _questions;
  List<String> get responses => _responses;
  String get extractedText => _extractedText;
  Stream<String> get responseStream => _streamController.stream;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await processImageWithAI(_image!);
    }
  }

  Future<void> captureImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await processImageWithAI(_image!);
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        await processFileWithAI(file.bytes!, file.name);
      }
    }
  }

  Future<void> processImageWithAI(File imageFile) async {
    setState(() => isLoading = true);
    try {
      final bytes = await imageFile.readAsBytes();
      const prompt = "Act friendly and nice";

      final content = Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', bytes),
      ]);

      final response = await _model.generateContent([content]);
      final text = response.text;

      if (text != null) {
        _extractedText = text;
        _responses.add(text);
        _streamController.add(text);
      }
    } catch (e) {
      _responses.add("Error processing image: $e");
      _streamController.add("Error processing image: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> processImageWithPrompt(File imageFile, String prompt) async {
    setState(() => isLoading = true);
    try {
      final bytes = await imageFile.readAsBytes();

      final content = Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', bytes),
      ]);

      final response = await _model.generateContent([content]);
      final text = response.text;

      if (text != null) {
        _extractedText = text;
        _responses.add(text);
        _streamController.add(text);
      }
    } catch (e) {
      _responses.add("Error processing image: $e");
      _streamController.add("Error processing image: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> processFileWithPrompt(Uint8List fileBytes, String fileName, String prompt) async {
    setState(() => isLoading = true);
    try {
      // Determine mime type based on file extension
      String extension = fileName.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, fileBytes),
      ]);

      final response = await _model.generateContent([content]);
      final text = response.text;

      if (text != null) {
        _extractedText = text;
        _responses.add(text);
        _streamController.add(text);
      }
    } catch (e) {
      _responses.add("Error processing file: $e");
      _streamController.add("Error processing file: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> processFileWithAI(Uint8List fileBytes, String fileName) async {
    setState(() => isLoading = true);
    try {
      final prompt = "Analyze this document named $fileName. Extract all relevant information and verify its content.";

      // Determine mime type based on file extension
      String extension = fileName.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      final content = Content.multi([
        TextPart(prompt),
        DataPart(mimeType, fileBytes),
      ]);

      final response = await _model.generateContent([content]);
      final text = response.text;

      if (text != null) {
        _extractedText = text;
        _responses.add(text);
        _streamController.add(text);
      }
    } catch (e) {
      _responses.add("Error processing file: $e");
      _streamController.add("Error processing file: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> chatWithAI(String prompt) async {
    setState(() => isLoading = true);
    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      final text = response.text;

      if (text != null) {
        _responses.add(text);
        _streamController.add(text);
      }
    } catch (e) {
      _responses.add("Error: $e");
      _streamController.add("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> createQuestionsFromText(String text) async {
    const prompt = "Generate exam-like questions from this text, including multiple choice, short answer, and fill-in-the-blank questions:";
    await chatWithAI("$prompt $text");
  }

  void clearQuestions() {
    _questions.clear();
  }

  void clearResponses() {
    _responses.clear();
    _streamController.add('');
  }

  // Helper method to update state
  void setState(Function() callback) {
    callback();
  }
}