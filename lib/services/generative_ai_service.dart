import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../model/chat_message.dart';

class GenerativeAIService {
  final String apiKey;
  GenerativeModel? _visionModel;
  GenerativeModel? _textModel;
  bool _isInitialized = false;
  String? _initError;

  final List<ChatMessage> _chatHistory = [];
  final StreamController<String> _streamController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _streamController.stream;

  GenerativeAIService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      _initError = 'API key is empty';
      debugPrint('AI service initialization failed: $_initError');
      return;
    }

    _initializeModels();
  }
  List<ChatMessage> get chatHistory => _chatHistory;
  void _initializeModels() {
    try {
      // Vision model for ID card processing
      _visionModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        ),
        systemInstruction: Content('system',  [
          TextPart('You are a helpful AI assistant that processes images and provides detailed responses.')
        ])
      );

      // Text model
      _textModel = GenerativeModel(
        model: 'gemini-2.0-flash',  // Use gemini-pro instead of gemini-2.0-flash
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 4096,
          responseMimeType: 'text/plain',
        ),
        systemInstruction: Content('system', [
          TextPart('You are a helpful AI assistant that provides useful information and responds to queries conversationally.')
        ]),
      );

      _isInitialized = true;
      debugPrint('AI models successfully initialized');
    } catch (e) {
      _isInitialized = false;
      _initError = e.toString();
      debugPrint('Failed to initialize models: $e');
    }
  }

  // Process ID card images
  Future<Map<String, dynamic>> processIDCard(File imageFile) async {
    if (!_isInitialized || _visionModel == null) {
      return {
        'isLegitimate': false,
        'reasoning': 'AI service has not been initialized. Check your API key.',
      };
    }

    try {
      final bytes = await imageFile.readAsBytes();
      debugPrint('Image loaded: ${bytes.length} bytes');

      const String prompt = '''
    You are an ID verification expert. Analyze this student ID card and:
    1. Extract the university name
    2. Extract the full student name (separate into first and middle names if available)
    3. Extract the department/program (including degree like B.Sc or M.A if shown)
    4. Extract the student ID number (usually starting with "RU" or "EU")
    5. Verify if this appears to be a legitimate ID card by checking:
       - Is it from Jimma University?
       - Is it machine-printed (not handwritten)?
       - Does it have official markings, logo, or stamps?
       - Does it have a consistent design/layout?
       - Is the text professionally printed (not markers or pen)?
    If user is not from jimma university , the model should tell them that its aware that they are not from jimma university. but it will still let them use the app.
    Respond in valid JSON format only with the following structure:
    {
      "universityName": "full university name",
      "studentName": "full student name",
      "firstName": "first name only",
      "middleName": "middle name only",
      "department": "department/program with degree",
      "studentID": "student ID number",
      "isJimmaUniversity": true/false,
      "isLegitimate": true/false,
      "confidenceScore": 0-100,
      "reasoning": "detailed explanation of legitimacy assessment"
    }
    ''';

      final content = Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', bytes),
      ]);

      debugPrint('Sending request to vision model...');
      final response = await _visionModel!.generateContent([content]);
      final text = response.text;

      if (text != null) {
        debugPrint('Response received: ${text.length > 100 ? text.substring(0, 100) + "..." : text}');
        final jsonStr = _extractJsonFromResponse(text);
        return _parseJsonResponse(jsonStr);
      } else {
        return {
          'isLegitimate': false,
          'reasoning': 'Empty response from AI',
        };
      }
    } catch (e) {
      debugPrint('Error processing ID card: $e');
      return {
        'isLegitimate': false,
        'reasoning': 'Failed to process image: ${e.toString()}',
      };
    }
  }

  // Improved JSON extraction that doesn't use complex regex
  String _extractJsonFromResponse(String text) {
    // Find the first occurrence of an opening brace
    int start = text.indexOf('{');
    if (start == -1) return '{}';

    // Find the matching closing brace
    int openBraces = 1;
    int end = start + 1;

    while (end < text.length && openBraces > 0) {
      if (text[end] == '{') openBraces++;
      else if (text[end] == '}') openBraces--;
      end++;
    }

    if (openBraces == 0) {
      return text.substring(start, end);
    }

    return '{}';
  }

  Map<String, dynamic> _parseJsonResponse(String jsonStr) {
    try {
      if (jsonStr.trim().isNotEmpty) {
        Map<String, dynamic> result = json.decode(jsonStr);

        return {
          'universityName': result['universityName']?.toString() ?? '',
          'studentName': result['studentName']?.toString() ?? '',
          'firstName': result['firstName']?.toString() ?? '',
          'middleName': result['middleName']?.toString() ?? '',
          'department': result['department']?.toString() ?? '',
          'studentID': result['studentID']?.toString() ?? '',
          'isLegitimate': result['isLegitimate'] == true,
          'confidenceScore': result['confidenceScore'] ?? 0,
          'reasoning': result['reasoning']?.toString() ?? 'No reasoning provided',
        };
      } else {
        return {
          'isLegitimate': false,
          'reasoning': 'Empty JSON response',
        };
      }
    } catch (e) {
      debugPrint('JSON parsing error: $e');
      return {
        'isLegitimate': false,
        'reasoning': 'Failed to parse ID results: $e',
      };
    }
  }

  // Summarize text using the text model
  Future<String> summarizeText(String inputText) async {
    if (!_isInitialized || _textModel == null) {
      return 'AI service has not been initialized. Check your API key.';
    }

    try {
      final chat = _textModel!.startChat();
      final content = Content.text(inputText);
      final response = await chat.sendMessage(content);
      return response.text ?? 'Failed to generate summary';
    } catch (e) {
      return 'Error summarizing text: ${e.toString()}';
    }
  }

  String? get initError => _initError;
  bool get isInitialized => _isInitialized;
}