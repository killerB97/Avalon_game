import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avalonapp/models/player.dart';
import 'package:avalonapp/models/settings.dart';

class DatabaseService {
  String game_key;
  CollectionReference gamesCollection;
  CollectionReference gameSettings;
  DatabaseService({this.game_key});

  // Establish connectiomn to a game
  void connectToGame() {
    gamesCollection = FirebaseFirestore.instance.collection(game_key);
    gameSettings = FirebaseFirestore.instance.collection('Game Settings');
  }

  // Disconnect from a game
  void disconnectFromGame() {
    gamesCollection = null;
    game_key = null;
  }

  // Add a player to the game
  Future<void> updateUserData(String username, String player_no,
      {String character = ''}) async {
    return await gamesCollection
        .doc(player_no)
        .set({'username': username, 'role': character});
  }

// Update Game Settings
  Future<void> updateGameSettings(
      {bool locked = false, bool start = false, int numPlayers = 0}) async {
    return await gameSettings
        .doc(game_key)
        .set({'locked': locked, 'start': start, 'no_player': numPlayers});
  }

  // Delete a game
  void deleteCollection() {
    gamesCollection.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  void deleteDocument(int player_no) {
    gamesCollection.doc(player_no.toString()).delete();
  }

  // Get list of all players through a stream
  List<Player> _playerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Player(username: doc.data()['username'] ?? '');
    }).toList();
  }

  gameSetting _settingFromSnapshot(DocumentSnapshot snapshot) {
    return gameSetting(
        locked: snapshot.data()['locked'] ?? false,
        start: snapshot.data()['start'] ?? false,
        no_player: snapshot.data()['no_player'] ?? 0);
  }

  // Map list of PLayer object to a List
  Stream<List<Player>> get players {
    return gamesCollection.snapshots().map((_playerListFromSnapshot));
  }

  Stream<gameSetting> get settings {
    return gameSettings.doc(game_key).snapshots().map((_settingFromSnapshot));
  }

  // Check if room is empty or not
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

  // Check for existing Username
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

  // get number of players in the game
  Future<int> getNumberPlayers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection(game_key).get();
    print('the no:' + snapshot.docs.length.toString());
    return snapshot.docs.length;
  }

  // get name of character by documentid
  Future<String> getCharacterName(String docid) async {
    var role = await gamesCollection.doc(docid).get();
    if (role.exists == true) {
      return role.data()['role'];
    } else {
      return null;
    }
  }

  // Update player character
  Future<List<String>> allocateRole(List<String> roles) async {
    List<String> player_list = [];
    //roles.shuffle();
    int docid = 1;
    int tracker = 0;
    while (tracker != roles.length) {
      var role = await gamesCollection.doc((docid).toString()).get();
      if (role.exists == true) {
        gamesCollection
            .doc((docid).toString())
            .update({'role': roles[tracker]});
        player_list.add(docid.toString());
      }
      docid++;
      tracker++;
    }
    print('Done with allocation');
    return player_list;
  }

// Check if room locked
  Future<bool> checkLocked(String docid) async {
    var lock = await FirebaseFirestore.instance
        .collection('Game Settings')
        .doc(docid)
        .get();
    if (lock.exists == true) {
      return lock.data()['locked'];
    } else
      return false;
  }

// Get User Name by document ID
  Future<String> getUserName(String docid) async {
    var role = await gamesCollection.doc(docid).get();
    if (role.exists == true) {
      return role.data()['username'];
    } else {
      return null;
    }
  }

// Get Usernames of shuffled Dependecies
  Future<List<String>> getDependentChar(
      List<String> dependencies, Map charMap) async {
    List<String> userList = [];
    print(dependencies);
    print(charMap);
    dependencies.shuffle();
    for (String char in dependencies) {
      print(char);
      if (charMap.containsKey(char)) {
        for (String docid in charMap[char]) {
          String user = await getUserName(docid);
          userList.add(user);
        }
      }
    }
    print(userList);
    return userList;
  }
}
