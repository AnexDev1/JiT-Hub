import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class StudyAILogic {
  File? _image;
  final List<String> _questions = [];
  bool isLoading = false;
  final List<String> _responses = [];
  String _extractedText = '';
  final StreamController<String> _streamController = StreamController<String>.broadcast();

  File? get image => _image;
  List<String> get questions => _questions;
  List<String> get responses => _responses;
  String get extractedText => _extractedText;
  Stream<String> get responseStream => _streamController.stream;

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

    _extractedText = recognizedText.text;
    textRecognizer.close();

    // Generate questions from extracted text
    await createQuestionsFromText('generate exam like question from this text, could include choice, short answer or even blank space questions: $_extractedText');
  }

  Future<void> _sendRequestToAI(String prompt) async {
    isLoading = true;

    Gemini.instance.promptStream(parts: [
      Part.text(prompt)
    ]).listen((value) {
      final output = value?.output ?? '';
      _responses.add(output);
      _streamController.add(output);
    });

    isLoading = false;
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

  void clearResponses() {
    _responses.clear();
  }
}