import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:nex_planner/config.dart';

class StudyAILogic {
  File? _image;
  List<String> _questions = [];
  bool _isLoading = false;

  File? get image => _image;
  List<String> get questions => _questions;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await performOCR(_image!);
    }
  }

  Future<void> performOCR(File image) async {
    await dotenv.load(fileName: ".env");
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String extractedText = recognizedText.text;
    await createQuestionsFromText('generate exam like question from this text, could include choice , or even blanc space questions: $extractedText');

    textRecognizer.close();
  }

  Future<void> _sendRequestToAI(String prompt) async {
    _isLoading = true;

    String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${Config.apiKey}';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;

      _questions = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } else {
      print('Failed to communicate with AI: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    _isLoading = false;
  }

  Future<void> createQuestionsFromText(String prompt) async {
    await _sendRequestToAI(prompt);
  }

  Future<void> chatWithAI(String prompt) async {
    await _sendRequestToAI(prompt);
  }

  void clearQuestions() {
    _questions.clear();
  }
}