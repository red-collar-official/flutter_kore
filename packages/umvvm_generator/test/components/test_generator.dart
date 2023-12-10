import 'package:build/build.dart';
import 'package:build_test/build_test.dart';

import 'temp_writer.dart';

Future<void> testGenerator(
  String name,
  Builder builder,
  Map<String, String> inputs, {
  String? run,
  Map<String, Object>? outputs,
}) async {
  final writer = TempAssetWriter(name);

  try {
    await testBuilder(
      builder,
      inputs.map((key, value) => MapEntry('generated|lib/$key', value)),
      reader: await PackageAssetReader.currentIsolate(),
      writer: writer,
      outputs: outputs,
    );
  } finally {
    writer.dispose();
  }
}
