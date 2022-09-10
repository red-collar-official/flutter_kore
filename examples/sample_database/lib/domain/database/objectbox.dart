// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sample_database/domain/data/post.dart';

import '../../objectbox.g.dart';

class ObjectBox {
  late final Store store;
  late final Box<Post> postsBox;

  ObjectBox._create(this.store) {
    postsBox = Box<Post>(store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  static Future<ObjectBox> createTest() async {
    final dir = Directory('testdata');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }

    final modelDefinition = getObjectBoxModel();

    try {
      final store = Store(modelDefinition, directory: dir.path);
      return ObjectBox._create(store);
    } catch (ex) {
      print('$dir exists: ${dir.existsSync()}');
      print('Store is open in directory: ${Store.isOpen(dir.path)}');
      print('Model Info: ${modelDefinition.model.toMap(forModelJson: true)}');
      rethrow;
    }
  }
}
