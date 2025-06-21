import 'package:agent_ai_calender/models/height_screen.dart';
import 'package:agent_ai_calender/services/realtimedb_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PromptPage extends StatefulWidget {
  const PromptPage({super.key});

  @override
  State<PromptPage> createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  RealtimeDatabase realDb = RealtimeDatabase();
  final promptController = TextEditingController();
  Future<void> sendPrompt() async {
    http.Response res = await realDb.updatePrompt(
      promptController.text.trim(),
    );
    if (res.statusCode == 200) {
      promptController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt'),
        backgroundColor: Colors.grey[200],
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            Container(
              color: Colors.grey[200],
              height: HeightScreen(context).getHeight(),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: EdgeInsets.all(24),
                      child: Stack(
                        children: [
                          TextField(
                            controller: promptController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                left: 16,
                                top: 16,
                                right: 46,
                                bottom: 16,
                              ),
                              filled: true,
                              fillColor: Colors.grey[300],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.black),
                              ),
                              hintText: 'Tanyakan apa saja',
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 6,
                            child: IconButton(
                              onPressed: () {
                                sendPrompt();
                              },
                              icon: Icon(
                                Icons.send,
                                color: Colors.black,
                              ),
                              style: IconButton.styleFrom(
                                elevation: 4.0,
                                padding: EdgeInsets.all(16.0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
