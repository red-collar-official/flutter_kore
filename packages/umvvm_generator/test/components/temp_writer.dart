import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:path/path.dart' as path;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';

class TempAssetWriter implements RecordingAssetWriter {
  @override
  final Map<AssetId, List<int>> assets = {};

  late final Directory dir;

  List<File> files = [];

  TempAssetWriter(String namePrefix) {
    final id = Random().nextInt(1e6.round());

    dir = Directory.fromUri(
      Uri.parse(
        path.join(Directory.systemTemp.path, '${namePrefix.split('.')[0]}_$id'),
      ),
    );

    dir.createSync();
  }

  Future<dynamic> run(String code, String importFile) async {
    return _run('''
      import 'dart:isolate';
      import 'dart:async';
      import 'package:test/test.dart';
      import './$importFile';
      
      void main(dynamic args, SendPort port) async {
        await runZonedGuarded(() async {
          var result = await run();
          port.send(result);
        }, (e, s) {
          throw e;
        });
      }
      
      FutureOr<dynamic> run() async {
        $code
      }
    ''').last;
  }

  Stream<dynamic> _run(String code) async* {
    final main = File(path.join(dir.path, 'lib/main.dart'));

    // ignore: cascade_invocations
    main.writeAsStringSync(code);

    final port = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();

    final isolate = await Isolate.spawnUri(
      main.uri,
      [],
      port.sendPort,
      packageConfig: Uri.parse(path.join(
        Directory.current.path,
        '.dart_tool/package_config.json',
      )),
    );

    isolate
      ..addErrorListener(errorPort.sendPort)
      ..addOnExitListener(exitPort.sendPort);

    final results = StreamController.broadcast();

    final sub = port.listen(results.add);

    errorPort.listen((message) {
      final listMessage = message as List<Object?>;
      final error = listMessage[0] as String;
      final stack = listMessage[1] as String;

      results.addError(error, StackTrace.fromString(stack));
    });

    unawaited(exitPort.first.whenComplete(() {
      sub.cancel();
      results.close();
    }));

    yield* results.stream;
  }

  Future<dynamic> exec(String statement, String inputFile) {
    return execAll([statement], inputFile).first;
  }

  Stream<dynamic> execAll(List<String> statements, String inputFile) {
    return _run('''
      import 'dart:isolate';
      import './$inputFile';
      
      void main(dynamic args, SendPort port) {
        ${statements.map((s) => 'port.send($s);').join('\n')}
      }
    ''');
  }

  @override
  Future writeAsBytes(AssetId id, List<int> bytes) async {
    assets[id] = bytes;
    final file = File(path.join(dir.path, id.path));
    final subdir = Directory(path.dirname(file.path));

    // ignore: cascade_invocations
    subdir.createSync(recursive: true);

    file.writeAsBytesSync(bytes);
    files.add(file);
  }

  @override
  Future writeAsString(
    AssetId id,
    String contents, {
    Encoding encoding = utf8,
  }) async {
    return writeAsBytes(id, encoding.encode(contents));
  }

  void dispose() {
    try {
      dir.deleteSync(recursive: true);
    } catch(e) {
      // ignore
    }
  }
}
