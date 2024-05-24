import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  ChatPage({required this.conversationId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  // Mesajlar ve gönderici bilgisi ile birlikte tutuluyor
  List<Map<String, dynamic>> messages = [
    {"text": "Merhaba!", "isMe": false},
    {"text": "Nasılsın?", "isMe": true},
    {"text": "Ben de iyiyim, teşekkürler!", "isMe": false}
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        // Yeni mesaj ekleniyor ve bu mesajın kullanıcı tarafından gönderildiği işaretleniyor
        messages.add({"text": _controller.text, "isMe": true});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat - ${widget.conversationId}"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                // Mesajın kim tarafından gönderildiğine bağlı olarak hizalama değişiyor
                return Align(
                  alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Bir mesaj yaz",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
