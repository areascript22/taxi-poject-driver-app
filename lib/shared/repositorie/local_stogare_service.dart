import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static late Box box;

  static Future<void> setupHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox('myBox');
  }

  // Función para guardar el bool isThereDataInDB
  static Future<void> saveIsThereDataInDB(bool value) async {
    await box.put('isThereDataInDB', value);
  }

  // Función para recuperar el bool isThereDataInDB
  static bool getIsThereDataInDB() {
    return box.get('isThereDataInDB', defaultValue: false);
  }

  // Función para limpiar (eliminar) el valor de isThereDataInDB
  static Future<void> clearIsThereDataInDB() async {
    await box.delete('isThereDataInDB');
  }
}
