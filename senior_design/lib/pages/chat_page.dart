import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  ChatPage({required this.conversationId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> messages = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _messagesRef.child('conversations/${widget.conversationId}/messages').orderByChild('timestamp').onValue.listen((event) {
      var snapshot = event.snapshot.value;
      if (snapshot != null) {
        var newMessages = Map<String, dynamic>.from(snapshot as Map);
        setState(() {
          // Mesajları zaman damgasına göre sıralayarak ve liste yapısını güncelleyerek ekliyoruz
          messages = newMessages.entries.map((e) => {
            "text": e.value['text'],
            "senderId": e.value['senderId'],
            "isMe": e.value['senderId'] == currentUserId,
            "timestamp": e.value['timestamp'],
          }).toList();
          // Zaman damgasına göre sıralama
          messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        });
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      var newMessageId = _messagesRef.child('conversations/${widget.conversationId}/messages').push().key;
      _messagesRef.child('conversations/${widget.conversationId}/messages/$newMessageId').set({
        'text': _controller.text,
        'senderId': currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _controller.clear();
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
