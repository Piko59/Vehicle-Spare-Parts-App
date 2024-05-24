import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chat_page.dart'; // ChatPage sayfasının import edilmesi
import 'new_conversation_page.dart'; // ChatPage sayfasının import edilmesi


class ConversationsPage extends StatefulWidget {
  final String userId;

  ConversationsPage({required this.userId});

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late Query _conversationsRef;

  @override
  void initState() {
    super.initState();
    _conversationsRef = FirebaseDatabase.instance
        .ref('conversations')
        .orderByChild('participants/${widget.userId}')
        .equalTo(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Burada kullanıcı yeni bir konuşma başlatma sayfasına yönlendirilebilir
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewConversationPage(userId: widget.userId)),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _conversationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading conversations"));
          } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            // Güvenli bir şekilde Map'e dönüştür
            var snapshotData = snapshot.data!.snapshot.value;
            if (snapshotData is Map<dynamic, dynamic>) {
              return ListView(
                children: snapshotData.entries.map((entry) {
                  var key = entry.key;
                  var value = Map<String, dynamic>.from(entry.value);
                  var lastMessage = value['messages']?.values?.last['text'] ?? 'No messages yet';
                  var participantNames = Map<String, String>.from(value['participantNames']);
                  var otherUserId = participantNames.keys.firstWhere((id) => id != widget.userId, orElse: () => '');
                  var participantName = participantNames[otherUserId] ?? 'Unknown';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/default_user.png'), 
                    ),
                    title: Text(participantName),
                    subtitle: Text(lastMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage(conversationId: key)),
                      );
                    },
                  );
                }).toList(),
              );
            }
          }
          return Center(child: Text("No conversations found"));
        },
      ),
    );
  }
}