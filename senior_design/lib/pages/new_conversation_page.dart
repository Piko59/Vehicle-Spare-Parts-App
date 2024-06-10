import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chat_page.dart';

class NewConversationPage extends StatefulWidget {
  final String userId;

  NewConversationPage({required this.userId});

  @override
  _NewConversationPageState createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  late Query _usersRef;
  late Query _userConversationsRef;
  Set<String> _existingConversationUserIds = {};
  bool _isLoading = true;
  List<Map<String, String>> _usersDetails = [];

  @override
  void initState() {
    super.initState();
    _usersRef = FirebaseDatabase.instance.ref('users');
    _userConversationsRef = FirebaseDatabase.instance.ref('users/${widget.userId}/conversations');
    _loadExistingConversations();
  }

  Future<void> _loadExistingConversations() async {
    DatabaseEvent event = await _userConversationsRef.once();
    if (event.snapshot.value != null) {
      var conversations = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>? ?? {});
      for (var conversationId in conversations.keys) {
        DatabaseEvent conversationEvent = await FirebaseDatabase.instance.ref('conversations/$conversationId/participants').once();
        var participants = Map<String, dynamic>.from(conversationEvent.snapshot.value as Map<dynamic, dynamic>? ?? {});
        participants.forEach((participantId, _) {
          if (participantId != widget.userId) {
            _existingConversationUserIds.add(participantId);
          }
        });
      }
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    DatabaseEvent event = await _usersRef.once();
    if (event.snapshot.value != null) {
      var users = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>? ?? {});
      for (var userId in users.keys) {
        if (userId != widget.userId && !_existingConversationUserIds.contains(userId)) {
          var userDetails = await _getUserDetails(userId);
          _usersDetails.add(userDetails);
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, String>> _getUserDetails(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    DatabaseEvent event = await userRef.once();
    Map<String, dynamic> userData = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>? ?? {});
    String name = userData['name'] as String? ?? 'Unknown';
    String imageUrl = userData['imageUrl'] as String? ?? 'assets/default_user_avatar.png';
    return {'userId': userId, 'name': name, 'imageUrl': imageUrl};
  }

  Future<void> _createConversation(String otherUserId) async {
    DatabaseReference conversationRef = FirebaseDatabase.instance.ref('conversations').push();
    String conversationId = conversationRef.key!;
    
    await conversationRef.set({
      'participants': {
        widget.userId: true,
        otherUserId: true,
      },
      'messages': {},
    });

    await FirebaseDatabase.instance.ref('users/${widget.userId}/conversations/$conversationId').set(true);
    await FirebaseDatabase.instance.ref('users/$otherUserId/conversations/$conversationId').set(true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(conversationId: conversationId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFFF76CE),
                  Color(0xFFA3D8FF),
                ],
              ),
            ),
          ),
          title: Text("New Conversation"),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _usersDetails.length,
              itemBuilder: (context, index) {
                var userDetails = _usersDetails[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: userDetails['imageUrl']!.startsWith('assets/')
                        ? AssetImage(userDetails['imageUrl']!) as ImageProvider
                        : NetworkImage(userDetails['imageUrl']!),
                  ),
                  title: Text(userDetails['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text("Tap to start a conversation", style: TextStyle(fontSize: 14)),
                  onTap: () => _createConversation(userDetails['userId']!),
                  trailing: Icon(Icons.arrow_forward, color: Color(0xFFFF0080)),
                );
              },
            ),
    );
  }
}