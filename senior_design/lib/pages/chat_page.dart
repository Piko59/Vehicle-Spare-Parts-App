import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  ChatPage({required this.conversationId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> messages = [];
  String? currentUserId;
  ScrollController _scrollController = ScrollController();
  String? editingMessageId;
  bool _isEditing = false;
  String? otherUserId;
  String? otherUsername;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
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

  void _getOtherUserDetails() async {
    DataSnapshot participantsSnapshot = await _messagesRef.child('conversations/${widget.conversationId}/participants').get();
    if (participantsSnapshot.exists) {
      Map participants = participantsSnapshot.value as Map;
      otherUserId = participants.keys.firstWhere((key) => key != currentUserId);

      DataSnapshot userSnapshot = await _messagesRef.child('users/$otherUserId/username').get();
      if (userSnapshot.exists) {
        setState(() {
          otherUsername = userSnapshot.value as String?;
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
                title: Text('Düzenle'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message['id']);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Sil'),
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

  Widget _buildMessage(Map<String, dynamic> message) {
    if (message['text'] != null) {
      return Text(
        message['text'],
        style: TextStyle(
          color: message['isMe'] ? Colors.white : Colors.black,
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
        title: Text(
          "${otherUsername ?? 'Loading...'}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF00A9B7),
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
                        color: message['isMe'] ? Color(0xFF00A9B7) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                        border: message['id'] == editingMessageId ? Border.all(color: Colors.red, width: 2) : null,
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
                    decoration: InputDecoration(
                      hintText: "Bir mesaj yaz",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    maxLines: null,
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
