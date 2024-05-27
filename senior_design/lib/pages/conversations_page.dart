import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chat_page.dart';
import 'new_conversation_page.dart';

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late Query _conversationsRef;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId().then((userId) {
      setState(() {
        _userId = userId;
        _conversationsRef = FirebaseDatabase.instance
            .ref('conversations')
            .orderByChild('participants/$_userId')
            .equalTo(true);
      });
    });
  }

  Future<String?> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<Map<String, String>> _getUserDetails(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    DatabaseEvent event = await userRef.once();
    Map<String, dynamic> userData = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>? ?? {});
    String username = userData['username'] as String? ?? 'Unknown';
    String imageUrl = userData['imageUrl'] as String? ?? 'assets/default_user_image.jpg';
    return {'username': username, 'imageUrl': imageUrl};
  }

  String _formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.black,
              child: Image(
                image: imageUrl.startsWith('assets/')
                    ? AssetImage(imageUrl) as ImageProvider
                    : NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF00A9B7),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (_userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewConversationPage(userId: _userId!)),
                );
              } else {
                // Kullanıcı kimliği alınamadı hatası göster
                print('User ID not found');
              }
            },
          )
        ],
      ),
      body: _userId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DatabaseEvent>(
              stream: _conversationsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading conversations"));
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  var snapshotData = snapshot.data!.snapshot.value;
                  if (snapshotData is Map<dynamic, dynamic>) {
                    var sortedConversations = snapshotData.entries.toList()
                      ..sort((a, b) {
                        var aMessages = Map<String, dynamic>.from(a.value['messages'] ?? {});
                        var bMessages = Map<String, dynamic>.from(b.value['messages'] ?? {});
                        var aLastMessageTime = aMessages.values.isNotEmpty ? aMessages.entries.map((e) => e.value['timestamp']).reduce((a, b) => a > b ? a : b) : 0;
                        var bLastMessageTime = bMessages.values.isNotEmpty ? bMessages.entries.map((e) => e.value['timestamp']).reduce((a, b) => a > b ? a : b) : 0;
                        return bLastMessageTime.compareTo(aLastMessageTime);
                      });

                    return ListView(
                      children: sortedConversations.map((entry) {
                        var key = entry.key;
                        var value = Map<String, dynamic>.from(entry.value);
                        var lastMessageEntry = Map<String, dynamic>.from(value['messages']?.entries.map((e) => e.value).reduce((a, b) => a['timestamp'] > b['timestamp'] ? a : b) ?? {});
                        var lastMessage = lastMessageEntry['text'] ?? 'No messages yet';
                        var lastMessageTime = lastMessageEntry['timestamp'] ?? 0;
                        var lastMessageSender = lastMessageEntry['senderId'] ?? '';
                        var participants = Map<String, dynamic>.from(value['participants']);
                        var otherUserId = participants.keys.firstWhere((id) => id != _userId, orElse: () => '');

                        return FutureBuilder<Map<String, String>>(
                          future: _getUserDetails(otherUserId),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/default_user_image.jpg'),
                                ),
                                title: Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                subtitle: Text(lastMessage, style: TextStyle(fontSize: 16)),
                              );
                            } else if (userSnapshot.hasError) {
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/default_user_image.jpg'),
                                ),
                                title: Text('Error loading name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                subtitle: Text(lastMessage, style: TextStyle(fontSize: 16)),
                              );
                            } else {
                              var userDetails = userSnapshot.data!;
                              var lastMessagePrefix = lastMessageSender == _userId ? 'You: ' : '${userDetails['username']}: ';
                              return ListTile(
                                leading: GestureDetector(
                                  onTap: () => _showFullImage(context, userDetails['imageUrl']!),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: userDetails['imageUrl']!.startsWith('assets/')
                                        ? AssetImage(userDetails['imageUrl']!) as ImageProvider
                                        : NetworkImage(userDetails['imageUrl']!),
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(userDetails['username']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(_formatTimestamp(lastMessageTime), style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                                subtitle: Text('$lastMessagePrefix$lastMessage', style: TextStyle(fontSize: 16)),
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
