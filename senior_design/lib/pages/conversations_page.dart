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
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  Map<String, Map<String, String>> _userDetailsCache = {};

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeUser() async {
    _userId = await _getUserId();
    setState(() {
      _conversationsRef = FirebaseDatabase.instance
          .ref('conversations')
          .orderByChild('participants/$_userId')
          .equalTo(true);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<String?> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<Map<String, String>> _getUserDetails(String userId) async {
    if (_userDetailsCache.containsKey(userId)) {
      return _userDetailsCache[userId]!;
    }

    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    DatabaseEvent event = await userRef.once();
    Map<String, dynamic> userData = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>? ?? {});
    String name = userData['name'] as String? ?? 'Unknown';
    String imageUrl = userData['imageUrl'] as String? ?? '';

    _userDetailsCache[userId] = {'name': name, 'imageUrl': imageUrl};
    return _userDetailsCache[userId]!;
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return "";

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var now = DateTime.now();
    var difference = now.difference(date);

    if (difference.inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteConversation(String conversationId, Map<String, dynamic> participants) async {
    await FirebaseDatabase.instance.ref('conversations/$conversationId').remove();
    for (String participantId in participants.keys) {
      await FirebaseDatabase.instance.ref('users/$participantId/conversations/$conversationId').remove();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Conversation deleted')),
    );
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _unfocusTextField() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusTextField,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
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
            child: AppBar(
              title: Text('Conversations',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0)),
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    height: 36.0,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add, color: Colors.white, size: 16.0),
                      label: Text(
                        'Add New',
                        style: TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        backgroundColor: Color(0xFFFF0080),
                      ),
                      onPressed: () {
                        if (_userId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewConversationPage(userId: _userId!)),
                          );
                        } else {
                          print('User ID not found');
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(),
                  ),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
            ),
            Expanded(
              child: _userId == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder<DatabaseEvent>(
                      stream: _conversationsRef.onValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading conversations"));
                        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                          var snapshotData = snapshot.data!.snapshot.value;
                          if (snapshotData is Map<dynamic, dynamic>) {
                            var entries = snapshotData.entries.toList()
                              ..sort((a, b) {
                                var aMessages = Map<String, dynamic>.from(a.value['messages'] ?? {});
                                var bMessages = Map<String, dynamic>.from(b.value['messages'] ?? {});
                                var aLastMessageTime = aMessages.values.isNotEmpty
                                    ? aMessages.entries.map((e) => e.value['timestamp']).reduce((a, b) => a > b ? a : b)
                                    : null;
                                var bLastMessageTime = bMessages.values.isNotEmpty
                                    ? bMessages.entries.map((e) => e.value['timestamp']).reduce((a, b) => a > b ? a : b)
                                    : null;
                                if (aLastMessageTime == null && bLastMessageTime == null) return 0;
                                if (aLastMessageTime == null) return 1;
                                if (bLastMessageTime == null) return -1;
                                return bLastMessageTime.compareTo(aLastMessageTime);
                              });

                            if (_searchQuery.isNotEmpty) {
                              entries = entries.where((entry) {
                                var participants = Map<String, dynamic>.from(entry.value['participants']);
                                var otherParticipantId = participants.keys.firstWhere((id) => id != _userId);
                                var userDetails = _userDetailsCache[otherParticipantId];
                                if (userDetails == null) {
                                  _getUserDetails(otherParticipantId).then((details) {
                                    setState(() {
                                      _userDetailsCache[otherParticipantId] = details;
                                    });
                                  });
                                  return false;
                                }
                                var name = userDetails['name']?.toLowerCase() ?? '';
                                return name.contains(_searchQuery);
                              }).toList();
                            }

                            return ListView(
                              children: entries.map((entry) {
                                var key = entry.key;
                                var value = Map<String, dynamic>.from(entry.value);
                                var lastMessageEntry = value['messages'] != null && value['messages'].isNotEmpty
                                    ? Map<String, dynamic>.from(value['messages'].entries.map((e) => e.value).reduce((a, b) => a['timestamp'] > b['timestamp'] ? a : b))
                                    : {};
                                var lastMessage = lastMessageEntry['text'] ?? 'No messages yet';
                                var lastMessageTime = lastMessageEntry['timestamp'];
                                var lastMessageSender = lastMessageEntry['senderId'] ?? '';
                                var participants = Map<String, dynamic>.from(value['participants']);
                                var otherParticipantId = participants.keys.firstWhere((id) => id != _userId);

                                var userDetails = _userDetailsCache[otherParticipantId];
                                if (userDetails == null) {
                                  _getUserDetails(otherParticipantId).then((details) {
                                    setState(() {
                                      _userDetailsCache[otherParticipantId] = details;
                                    });
                                  });
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[200],
                                      child: CircularProgressIndicator(),
                                    ),
                                    title: Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    subtitle: Text(lastMessage, style: TextStyle(fontSize: 16)),
                                  );
                                }

                                var lastMessagePrefix = lastMessageSender == _userId ? 'You: ' : '${userDetails['name']}: ';
                                return ListTile(
                                  leading: GestureDetector(
                                    onTap: () => _showFullImage(context, userDetails['imageUrl']!),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: userDetails['imageUrl']!.isEmpty
                                          ? AssetImage("assets/default_user_avatar.png") as ImageProvider
                                          : NetworkImage(userDetails['imageUrl']!),
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(userDetails['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text(_formatTimestamp(lastMessageTime), style: TextStyle(fontSize: 14, color: Colors.grey)),
                                    ],
                                  ),
                                  subtitle: lastMessage == "No messages yet"
                                      ? Text('No messages yet', style: TextStyle(fontSize: 16))
                                      : Text('$lastMessagePrefix$lastMessage', style: TextStyle(fontSize: 16)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ChatPage(conversationId: key)),
                                    );
                                  },
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Delete Conversation',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          content: Text("Are you sure you want to delete this conversation?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),),
                                                ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteConversation(key, participants);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Delete",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),),
                                            ),
                                          ],
                                        );
                                      },
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
            ),
          ],
        ),
      ),
    );
  }
}
