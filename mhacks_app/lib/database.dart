import 'player.dart';
import 'shop.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataBase {
  final int USER_ID = 1;

  late Player storedPlayer;
  // currency, stats, achievements
  late Map<String, ItemStat> storedShopOptions;
  // hashmap of items currently in the store (everything else is static)
  late List<Task> storedTasks;
  // each task contains due date, task info, and an associated enemy
  static String url =
      "https://compute.googleapis.com/compute/v1/projects/task-monster/zones/zone/user-database/";
  // the url resource this database is tied to (needs USER_ID at the end)

  DataBase({
    required this.storedPlayer,
    required this.storedShopOptions,
    required this.storedTasks,
  });

  // returns the current player
  Player get player => storedPlayer;

  // returns the current shop
  Shop get shop => Shop(storedShopOptions);

  // returns the current task list
  List<Task> get tasks => storedTasks;

  factory DataBase.fromJson(Map<String, dynamic> json) {
    return DataBase(
      storedPlayer: Player.fromJson(json['storedPlayer']),
      storedShopOptions: Map<String, ItemStat>.from(json['storedShopOptions']),
      storedTasks: List<Task>.from(json['storedTasks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storedPlayer': storedPlayer.toJson(),
      'storedShopOptions': storedShopOptions.toString(),
      'storedTasks': storedTasks.toString(),
    };
  }

  Future<void> updateDatabase() async {
    var url = Uri.parse(DataBase.url);
    var response = await http
        .put(url, body: {'title': 'foo', 'body': 'bar', 'userId': '1'});

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var db = DataBase.fromJson(jsonResponse);
      print("retrieved database for user $USER_ID");
      print(db.storedPlayer);
      print(db.storedShopOptions);
      print(db.storedTasks);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> updateCloud() async {
    var url = Uri.parse(DataBase.url + USER_ID.toString());
    var response = await http.put(url, body: toJson());

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}

void dbtest() {
  Player player1 = Player();
  Map<String, ItemStat> shop = Shop.master;
  DataBase db =
      DataBase(storedPlayer: player1, storedShopOptions: shop, storedTasks: []);
  db.updateCloud();
  db.updateDatabase();
}
