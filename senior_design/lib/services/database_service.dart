import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> createConversationIfNotExist(String userId1, String userId2, String username1, String username2) async {
    var conversationQuery = _db.child('conversations')
        .orderByChild('participants/$userId1')
        .equalTo(true)
        .ref
        .orderByChild('participants/$userId2')
        .equalTo(true);

    var snapshot = await conversationQuery.once();

    if (snapshot.snapshot.value == null) {
      String conversationId = _db.child('conversations').push().key!;
      await _db.child('conversations/$conversationId').set({
        'participants': {
          userId1: true,
          userId2: true
        },
        'participantNames': {
          userId1: username1,
          userId2: username2
        }
      });
    }
  }

  Stream<DatabaseEvent> getUserConversations(String userId) {
    return _db.child('conversations')
        .orderByChild('participants/$userId')
        .equalTo(true)
        .onValue;
  }

}
