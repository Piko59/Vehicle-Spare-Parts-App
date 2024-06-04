import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'other_user_profile_page.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  ChatPage({required this.conversationId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> messages = [];
  String? currentUserId;
  ScrollController _scrollController = ScrollController();
  String? editingMessageId;
  bool _isEditing = false;
  String? otherUserId;
  String? otherName;
  XFile? _selectedImage;
  String? otherUserProfileImage;
  String onlineStatus = "offline";
  String typingStatus = "";
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _setUserOnlineStatus(true);

    FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
      bool isConnected = event.snapshot.value as bool;
      if (isConnected) {
        _setUserOnlineStatus(true);
      } else {
        _setUserOnlineStatus(false);
      }
    });

    _messagesRef.child('conversations/${widget.conversationId}/messages').orderByChild('timestamp').onValue.listen((event) {
      var snapshot = event.snapshot.value;
      if (snapshot != null) {
        var newMessages = Map<String, dynamic>.from(snapshot as Map);
        bool atBottomBeforeUpdate = _scrollController.offset >= _scrollController.position.maxScrollExtent;

        setState(() {
          messages = newMessages.entries.map((e) => {
            "text": e.value['text'],
            "imageUrl": e.value['imageUrl'],
            "senderId": e.value['senderId'],
            "isMe": e.value['senderId'] == currentUserId,
            "timestamp": e.value['timestamp'],
            "id": e.key,
          }).toList();
          messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        });

        if (atBottomBeforeUpdate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 100);
            }
          });
        }
      }
    });

    _getOtherUserDetails();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _setUserOnlineStatus(false);
    _setTypingStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _setUserOnlineStatus(false);
      _setTypingStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      _setUserOnlineStatus(true);
    }
  }

  void _setUserOnlineStatus(bool isOnline) {
    _messagesRef.child('users/$currentUserId/online').set(isOnline);
  }

  void _getOtherUserDetails() async {
    DataSnapshot participantsSnapshot = await _messagesRef.child('conversations/${widget.conversationId}/participants').get();
    if (participantsSnapshot.exists) {
      Map participants = participantsSnapshot.value as Map;
      otherUserId = participants.keys.firstWhere((key) => key != currentUserId);

      DataSnapshot userSnapshot = await _messagesRef.child('users/$otherUserId').get();
      if (userSnapshot.exists) {
        var userData = userSnapshot.value as Map;
        setState(() {
          otherName = userData['name'];
          otherUserProfileImage = userData['imageUrl'];
        });

        _messagesRef.child('users/$otherUserId/online').onValue.listen((event) {
          setState(() {
            onlineStatus = event.snapshot.value == true ? "online" : "offline";
          });
        });

        _messagesRef.child('conversations/${widget.conversationId}/typing/$otherUserId').onValue.listen((event) {
          setState(() {
            typingStatus = event.snapshot.value == true ? "typing..." : "";
          });
        });
      }
    }
  }

  void _sendMessage() async {
    if (_selectedImage != null) {
      var fileName = DateTime.now().millisecondsSinceEpoch.toString();
      var ref = _storage.ref().child('chat_images/$fileName');
      await ref.putFile(File(_selectedImage!.path));
      var imageUrl = await ref.getDownloadURL();

      var newMessageId = _messagesRef.child('conversations/${widget.conversationId}/messages').push().key;
      _messagesRef.child('conversations/${widget.conversationId}/messages/$newMessageId').set({
        'imageUrl': imageUrl,
        'senderId': currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else if (_controller.text.isNotEmpty) {
      if (editingMessageId != null) {
        _messagesRef.child('conversations/${widget.conversationId}/messages/$editingMessageId').update({
          'text': _controller.text,
        });
        setState(() {
          editingMessageId = null;
          _isEditing = false;
        });
      } else {
        var newMessageId = _messagesRef.child('conversations/${widget.conversationId}/messages').push().key;
        _messagesRef.child('conversations/${widget.conversationId}/messages/$newMessageId').set({
          'text': _controller.text,
          'senderId': currentUserId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
    _controller.clear();
    _selectedImage = null;
    _setTypingStatus(false);
    scrollToBottom();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteMessage(String messageId) {
    _messagesRef.child('conversations/${widget.conversationId}/messages/$messageId').remove();
  }

  void _editMessage(String messageId) {
    var message = messages.firstWhere((msg) => msg['id'] == messageId);
    _controller.text = message['text'];
    editingMessageId = messageId;
    setState(() {
      _isEditing = true;
    });
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> message) {
    if (message['senderId'] == currentUserId) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message['id']);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message['id']);
                },
              ),
            ],
          );
        }
      );
    }
  }

  String formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(date);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  void _setTypingStatus(bool isTyping) {
    _messagesRef.child('conversations/${widget.conversationId}/typing/$currentUserId').set(isTyping);
  }

  void _startTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(seconds: 1), () {
      _setTypingStatus(false);
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    if (message['text'] != null) {
      return Text(
        message['text'],
        style: TextStyle(
          color: message['isMe'] ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      );
    } else if (message['imageUrl'] != null) {
      return Image.network(
        message['imageUrl'],
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return SizedBox(
              width: 150,
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          }
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: InkWell(
          onTap: () {
            if (otherUserId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserProfilePage(userId: otherUserId!),
                ),
              );
            }
          },
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
          ),
        ),
        toolbarHeight: 65,
        leadingWidth: 300,
leading: GestureDetector(
  onTap: () {
    if (otherUserId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtherUserProfilePage(userId: otherUserId!),
        ),
      );
    }
  },
  child: Row(
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      if (otherUserProfileImage != null)
        GestureDetector(
          onTap: () {
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
                        image: NetworkImage(otherUserProfileImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircleAvatar(
              backgroundImage: NetworkImage(otherUserProfileImage!),
            ),
          ),
        ),
      SizedBox(width: 10),
      GestureDetector(
        onTap: () {
          if (otherUserId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherUserProfilePage(userId: otherUserId!),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${otherName ?? 'Loading...'}",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              typingStatus.isNotEmpty ? typingStatus : onlineStatus,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  ),
),

        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                return Align(
                  alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: InkWell(
                    onLongPress: () => _showMessageOptions(context, message),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: message['isMe'] ? Color(0xFF5BBCFF) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                        border: message['id'] == editingMessageId ? Border.all(color: Colors.red, width: 4) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildMessage(message),
                          Text(
                            formatTimestamp(message['timestamp']),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(_selectedImage!.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      _setTypingStatus(text.isNotEmpty);
                      _startTypingTimer();
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.send),
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
