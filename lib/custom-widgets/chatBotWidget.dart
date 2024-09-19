import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:movie_it/services/database_services.dart';

class chatBotWidget extends StatefulWidget {
  const chatBotWidget({Key? key}) : super(key: key);

  @override
  State<chatBotWidget> createState() => _chatBotWidgetState();
}

class _chatBotWidgetState extends State<chatBotWidget> {
  DatabaseServices dbs = DatabaseServices();
  String prompt = '';
  var apiKey = dotenv.env['API_KEY'].toString();
  final TextEditingController _chatTextController = TextEditingController();

  List<Map<String, String>> messages = [];

  void _sendMessage(StateSetter setModalState) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [Content.text(prompt)];
    var response = model.generateContentStream(content);
    String fullResponse = '';
    await for (final chunk in response) {
      fullResponse += chunk.text!;
    }
    setModalState(() {
      messages.add({'sender': 'Gemini', 'text': fullResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: Colors.blueGrey[700],
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Chat Bot',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Expanded(
                            child: ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return ListTile(
                                  title: Text(message['sender']!),
                                  subtitle: message['sender'] == 'Gemini'
                                      ? MarkdownBody(data: message['text']!)
                                      : Text(message['text']!),
                                  leading: CircleAvatar(
                                    child: Icon(Icons.chat_bubble),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            controller: _chatTextController,
                            decoration: InputDecoration(
                              hintText: 'Mesajınızı buraya yazın...',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () async {
                                  setModalState(() {
                                    prompt = _chatTextController.text;
                                    messages.add({
                                      'sender': 'Ben',
                                      'text': _chatTextController.text
                                    });
                                  });
                                  _sendMessage(setModalState);
                                  _chatTextController.clear();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: const Icon(Icons.chat_rounded),
    );
  }
}
