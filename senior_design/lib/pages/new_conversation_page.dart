import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/database_service.dart'; // Varsayılan DatabaseService yolu

class NewConversationPage extends StatefulWidget {
  final String userId;

  NewConversationPage({required this.userId});

  @override
  _NewConversationPageState createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  late DatabaseReference _usersRef;

  @override
  void initState() {
    super.initState();
    _usersRef = FirebaseDatabase.instance.ref('users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start New Conversation"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _usersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading users"));
          } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            var snapshotData = snapshot.data!.snapshot.value;
            if (snapshotData is Map<dynamic, dynamic>) {
              List<Widget> userList = [];
              snapshotData.forEach((key, user) {
                if (key != widget.userId) { // Kendi kendine konuşma başlatmasını önle
                  userList.add(
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/default_user.png'), // Geçici profil fotoğrafı
                      ),
                      title: Text(user['username']),
                      onTap: () {
                        DatabaseService().createConversationIfNotExist(
                          widget.userId, key, 'Current User Name', user['username']
                        );
                        Navigator.pop(context); // Eğer yeni konuşma başlatılırsa veya mevcut konuşma varsa geri dön
                      },
                    )
                  );
                }
              });
              return ListView(children: userList);
            } else {
              return Center(child: Text("Users data is not in the expected format"));
            }
          } else {
            return Center(child: Text("No users found"));
          }
        },
      ),
    );
  }
}
