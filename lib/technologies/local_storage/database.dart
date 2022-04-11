import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/clothing/clothing.dart';

class Database {
  static const String closetBoxName = 'closet';
  static const String outfitCacheBoxName = 'outfit_cache';

  static Future initDatabase() async {
    await Hive.initFlutter();

    // Adapters
    Hive.registerAdapter(ClothingAdapter());
    //Hive.registerAdapter(WeatherAdapter());

    // Boxes
    await Hive.openBox<Clothing>(closetBoxName);
    //await Hive.openBox<Clothing>('outfit_today');
    //await Hive.openBox<Clothing>('favorites');
    //await Hive.openBox<Clothing>('weather');
  }

  static Future openOutfitCache() async {
    await Hive.openBox<Map<dynamic, dynamic>>(outfitCacheBoxName);
  }

  static Future closeOutfitCache() async {
    await Hive.box<Map<dynamic, dynamic>>(outfitCacheBoxName).close();
  }

  static Future closeDatabase() async {
    await Hive.close();
  }
}
