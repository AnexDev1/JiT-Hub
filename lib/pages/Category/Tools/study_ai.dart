import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../services/study_ai_logic.dart';

class StudyAI extends StatefulWidget {
  const StudyAI({super.key});

  @override
  _StudyAIState createState() => _StudyAIState();
}

class _StudyAIState extends State<StudyAI> {
  final StudyAILogic _logic = StudyAILogic();
  final TextEditingController _inputController = TextEditingController();
  bool _isImageInput = false;

  void _submitInput() async {
    String inputText = _inputController.text;
    if (inputText.isNotEmpty) {
      setState(() {
        _logic.isLoading = true;
      });
      if (_isImageInput) {
        await _logic.createQuestionsFromText('generate exam like question from this text, could include choice , or even blanc space questions: $inputText');
      } else {
        await _logic.createQuestionsFromText(inputText);
      }
      setState(() {
        _inputController.clear();
        _isImageInput = false;
        _logic.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study AI'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Clear') {
                setState(() {
                  _logic.clearQuestions();
                });
              }
              // Implement other options later
            },
            itemBuilder: (BuildContext context) {
              return {'Clear', 'Save', 'Share'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _logic.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logic.questions.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: _isImageInput
                    ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MarkdownBody(
                      data: _logic.questions.join('\n\n'),
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                )
                    : MarkdownBody(
                  data: _logic.questions.join('\n\n'),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitInput,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    await _logic.pickImage();
                    setState(() {
                      _isImageInput = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}