import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/clothing/clothing.dart';

class ClosetService {
  static String boxName = "closet";

  List<Clothing> getAllClothing() {
    return Hive.box<Clothing>(boxName).values.toList();
  }

  Future<int> saveAndGetId(Clothing clothing) async {
    return await Hive.box<Clothing>(boxName).add(clothing);
  }

  void save(Clothing clothing) {
    Hive.box<Clothing>(boxName).add(clothing);
  }

  Future delete({int? key, Clothing? clothing}) async {
    int clothingKey = key ?? -1;

    if (clothing != null) {
      clothingKey = clothing.key;
    }

    await Hive.box<Clothing>(boxName).delete(clothingKey);
  }

  List<Clothing> findClothingType(int type) {
    var result = getAllClothing().where((c) => c.type == type).toList();
    return result;
  }

  List<Clothing> findClothing(int temperature, int part, int style) {
    var result = getAllClothing()
        .where((c) => c.part == part && c.temperatures.contains(temperature) && c.styles.contains(style))
        .toList();
    return result;
  }

  ValueListenable<Box<Clothing>> listenable() {
    return Hive.box<Clothing>(boxName).listenable();
  }
}
