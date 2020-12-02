import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avalonapp/models/player.dart';

class DatabaseService {
  String game_key;
  CollectionReference gamesCollection;
  DatabaseService({this.game_key});

  void connectToGame() {
    gamesCollection = FirebaseFirestore.instance.collection(game_key);
  }

  void disconnectFromGame() {
    gamesCollection = null;
    game_key = null;
  }

  Future<void> updateUserData(String username, String player_no) async {
    return await gamesCollection
        .doc(player_no)
        .set({'username': username, 'player': player_no});
  }

  void deleteCollection() {
    gamesCollection.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
      ;
    });
  }

  void deleteDocument(int player_no) {
    gamesCollection.doc(player_no.toString()).delete();
  }

  List<Player> _playerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Player(
          username: doc.data()['username'] ?? '',
          player_no: doc.data()['player'] ?? '0');
    }).toList();
  }

  Stream<List<Player>> get players {
    return gamesCollection.snapshots().map((_playerListFromSnapshot));
  }

  Future<bool> checkRoom() async {
    print(game_key);
    final snapshot =
        await FirebaseFirestore.instance.collection(game_key).get();
    if (snapshot.docs.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkUserName(String username) async {
    QuerySnapshot _query = await FirebaseFirestore.instance
        .collection(game_key)
        .where('username', isEqualTo: username)
        .get();

    if (_query.docs.length > 0) {
      // the ID exists
      return true;
    } else {
      return false;
    }
  }
}
