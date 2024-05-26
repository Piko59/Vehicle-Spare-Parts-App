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

  Future<String> _getUserName(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId/username');
    DatabaseEvent event = await userRef.once();
    return event.snapshot.value as String? ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        backgroundColor: Color(0xFF00A9B7), // Yeni renk burada ayarlandı
        iconTheme: IconThemeData(color: Colors.white), // AppBar'daki ikonların rengini beyaz yapar
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), // Başlığı beyaz yapar
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
              // Mesajları zaman damgasına göre sıralayın
              var sortedConversations = snapshotData.entries.toList()
                ..sort((a, b) {
                  var aMessages = a.value['messages'] ?? {};
                  var bMessages = b.value['messages'] ?? {};
                  var aLastMessageTime = aMessages.values.isNotEmpty ? aMessages.values.last['timestamp'] : 0;
                  var bLastMessageTime = bMessages.values.isNotEmpty ? bMessages.values.last['timestamp'] : 0;
                  return bLastMessageTime.compareTo(aLastMessageTime);
                });

              return ListView(
                children: sortedConversations.map((entry) {
                  var key = entry.key;
                  var value = Map<String, dynamic>.from(entry.value);
                  var lastMessage = value['messages']?.values?.last['text'] ?? 'No messages yet';
                  var participants = Map<String, dynamic>.from(value['participants']);
                  var otherUserId = participants.keys.firstWhere((id) => id != widget.userId, orElse: () => '');

                  return FutureBuilder<String>(
                    future: _getUserName(otherUserId),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/default_user_image.jpg'),
                          ),
                          title: Text('Loading...'),
                          subtitle: Text(lastMessage),
                        );
                      } else if (userSnapshot.hasError) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/default_user_image.jpg'),
                          ),
                          title: Text('Error loading name'),
                          subtitle: Text(lastMessage),
                        );
                      } else {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/default_user_image.jpg'),
                          ),
                          title: Text(userSnapshot.data ?? 'Unknown'),
                          subtitle: Text(lastMessage),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatPage(conversationId: key)),
                            );
                          },
                        );
                      }
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
