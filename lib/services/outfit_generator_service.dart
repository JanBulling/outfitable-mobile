import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:outfitable_mobile_app/technologies/local_storage/database.dart';

import '../models/clothing/clothing.dart';
import '../models/clothing/outfit.dart';

class OutfitGeneratorService {
  static String boxName = "closet";

  List<Clothing> findClothing(int temperature, int part, int style) {
    var allClothing = Hive.box<Clothing>(Database.closetBoxName)
        .values
        .where((c) => c.part == part && c.temperatures.contains(temperature) && c.styles.contains(style))
        .toList();

    return allClothing;
  }

  Outfit? findOutfitInCache(int dailySeed) {
    var box = Hive.box<Map<dynamic, dynamic>>(Database.outfitCacheBoxName);

    print("BOX: ${box.keys}, ${box.values}, ${box.length}");

    var result = box.get(dailySeed);

    if (result == null) return null;

    return Outfit.fromJson(Map<String, dynamic>.from(result));
  }

  void savOutfitInCache(Outfit outfit, int dailySeed) {
    Hive.box<Map>(Database.outfitCacheBoxName).put(dailySeed, outfit.toJson());
  }

  Future deleteOldOutfitFromCache() async {
    var box = Hive.box<Map>(Database.outfitCacheBoxName);
    var keys = box.keys;
    if (keys.length <= 3) return;

    List<int> deleteKeys = [];

    while (deleteKeys.length < keys.length - 3) {
      int oldestKey = keys.first;
      for (int key in keys) {
        if (key < oldestKey) {
          oldestKey = key;
        }
      }

      deleteKeys.add(oldestKey);
    }

    await box.delete(deleteKeys);
  }
}
