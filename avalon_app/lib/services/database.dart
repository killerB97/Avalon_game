import 'package:avalonapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avalonapp/models/player.dart';
import 'package:avalonapp/models/settings.dart';
import 'package:avalonapp/models/teams.dart';
import 'package:avalonapp/models/policy.dart';
import 'package:avalonapp/models/player_roles.dart';

class DatabaseService {
  String game_key;
  CollectionReference gamesCollection;
  CollectionReference gameSettings;
  CollectionReference gameQuest;
  CollectionReference gamePolicy;
  CollectionReference voteTrack;
  DatabaseService({this.game_key});
  String roundInfo;

  // Establish connectiomn to a game
  void connectToGame() {
    gamesCollection = FirebaseFirestore.instance.collection(game_key);
    gameSettings = FirebaseFirestore.instance.collection('Game Settings');
    gameQuest = FirebaseFirestore.instance.collection('Game Quest');
    voteTrack = FirebaseFirestore.instance.collection('Vote Tracker');
    gamePolicy = FirebaseFirestore.instance.collection('Game Policy');
  }

  // Disconnect from a game
  void disconnectFromGame() {
    gamesCollection.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
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
      {bool locked = false,
      bool start = false,
      int numPlayers = 0,
      int seed = 0}) async {
    return await gameSettings.doc(game_key).set({
      'locked': locked,
      'start': start,
      'no_player': numPlayers,
      'seed': seed
    });
  }

// Update Game Settings
  Future<void> updateGameQuest(
      {List<String> teams = const [],
      String winner = '',
      bool lock = false}) async {
    return await gameQuest
        .doc(game_key)
        .set({'teams': teams, 'winner': winner, 'lock': lock});
  }

  Future<void> voteTracker(
      {String rounds = null,
      int ayeNo = 0,
      int nayNo = 0,
      List<String> ayeUsers = const [],
      List<String> nayUsers = const []}) async {
    roundInfo = rounds;
    return await voteTrack.doc(game_key).set({
      rounds: {
        'aye': ayeNo,
        'nay': nayNo,
        'ayeUsers': ayeUsers,
        'nayUsers': nayUsers
      }
    });
  }

  Future<void> updateVoteTracker(
      {String rounds = null,
      int ayeNo = 0,
      int nayNo = 0,
      List<String> ayeUsers = const [],
      List<String> nayUsers = const []}) async {
    roundInfo = rounds;
    return await voteTrack.doc(game_key).update({
      rounds: {
        'aye': ayeNo,
        'nay': nayNo,
        'ayeUsers': ayeUsers,
        'nayUsers': nayUsers
      }
    });
  }

  Future<void> updateGameQuestLock({bool lock = false}) async {
    return await gameQuest.doc(game_key).update({'lock': lock});
  }

  Future<void> updateGameQuestWinner({String winner = ''}) async {
    return await gameQuest.doc(game_key).update({'winner': winner});
  }

  Future<void> updateGameQuestAye(
      {String rounds = null, dynamic currUser = null}) async {
    roundInfo = rounds;
    return await voteTrack.doc(game_key).update({
      rounds + '.aye': FieldValue.increment(1),
      rounds + '.ayeUsers': FieldValue.arrayUnion([currUser])
    });
  }

  Future<void> updateGameQuestNay(
      {String rounds = null, dynamic currUser = null}) async {
    roundInfo = rounds;
    return await voteTrack.doc(game_key).update({
      rounds + '.nay': FieldValue.increment(1),
      rounds + '.nayUsers': FieldValue.arrayUnion([currUser])
    });
  }

// Update Game Settings
  Future<void> updateGamePolicy({int pass = 0, int fail = 0}) async {
    return await gamePolicy.doc(game_key).set({
      'pass': pass,
      'fail': fail,
    });
  }

  Future<void> updateGamePolicyPass({String rounds = null}) async {
    return await gamePolicy.doc(game_key).update({
      'pass': FieldValue.increment(1),
    });
  }

  Future<void> updateGamePolicyFail({String rounds = null}) async {
    return await gamePolicy.doc(game_key).update({
      'fail': FieldValue.increment(1),
    });
  }

  // Delete a game
  void deleteCollection() {
    gamesCollection.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    gameSettings.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        if (doc.id == game_key) {
          doc.reference.delete();
        }
      }
    });
    gameQuest.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        if (doc.id == game_key) {
          doc.reference.delete();
        }
      }
    });
    voteTrack.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        if (doc.id == game_key) {
          doc.reference.delete();
        }
      }
    });
    gamePolicy.get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        if (doc.id == game_key) {
          doc.reference.delete();
        }
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

  Teams _teamsFromSnapshot(DocumentSnapshot snapshot) {
    return Teams(
        teams: snapshot.data()['teams'] ?? [],
        locked: snapshot.data()['lock'] ?? false,
        winner: snapshot.data()['winner'] ?? '');
  }

  Groups _groupsFromSnapshot(DocumentSnapshot snapshot) {
    return Groups(
      ayeGroup: snapshot.data()[roundInfo]['ayeUsers'] ?? [],
      nayGroup: snapshot.data()[roundInfo]['nayUsers'] ?? [],
      ayeCount: snapshot.data()[roundInfo]['aye'] ?? 0,
      nayCount: snapshot.data()[roundInfo]['nay'] ?? 0,
    );
  }

  Policy _policyFromSnapshot(DocumentSnapshot snapshot) {
    return Policy(
      passCount: snapshot.data()['pass'] ?? 0,
      failCount: snapshot.data()['fail'] ?? 0,
    );
  }

  gameSetting _settingFromSnapshot(DocumentSnapshot snapshot) {
    return gameSetting(
        locked: snapshot.data()['locked'] ?? false,
        start: snapshot.data()['start'] ?? false,
        no_player: snapshot.data()['no_player'] ?? 0,
        seed: snapshot.data()['seed'] ?? 0);
  }

  // Map list of PLayer object to a List
  Stream<List<Player>> get players {
    return gamesCollection.snapshots().map((_playerListFromSnapshot));
  }

  Stream<gameSetting> get settings {
    return gameSettings.doc(game_key).snapshots().map((_settingFromSnapshot));
  }

  Stream<Teams> get teams {
    return gameQuest.doc(game_key).snapshots().map((_teamsFromSnapshot));
  }

  Stream<Groups> get groups {
    return voteTrack.doc(game_key).snapshots().map((_groupsFromSnapshot));
  }

  Stream<Policy> get policy {
    return gamePolicy.doc(game_key).snapshots().map((_policyFromSnapshot));
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

  Future<bool> checkSettings() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Game Settings').get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      if (doc.id == game_key) {
        return true;
      }
    }
    return false;
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
  Future<playerRole> allocateRole(List<String> roles) async {
    List<String> player_list = [];
    roles.shuffle();
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
    return playerRole(player_list: player_list, role_list: roles);
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
  Future<List<String>> getUserNames(List<String> player_list) async {
    List<String> users = [];
    for (int i = 0; i < player_list.length; i++) {
      var role = await gamesCollection.doc(player_list[i]).get();
      if (role.exists == true) {
        users.add(role.data()['username']);
      } else {
        users.add('');
      }
    }
    return users;
  }

// Get Usernames of shuffled Dependecies
  Future<List<String>> getDependentChar(List<String> dependencies, Map charMap,
      List<String> users, List<String> player_list) async {
    List<String> userList = [];
    print(dependencies);
    print(charMap);
    dependencies.shuffle();
    for (String char in dependencies) {
      print(char);
      if (charMap.containsKey(char)) {
        for (String docid in charMap[char]) {
          String user = users[player_list.indexOf(docid)];
          userList.add(user);
        }
      }
    }
    print(userList);
    return userList;
  }
}
