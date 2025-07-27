import 'package:build/build.dart';
import 'package:build_test/build_test.dart';

Future<void> testGenerator(
  String name,
  Builder builder,
  Map<String, String> inputs, {
  Map<String, Object>? outputs,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_package');
  await readerWriter.testing.loadIsolateSources();

  await testBuilder(
    builder,
    inputs.map((key, value) => MapEntry('generated|lib/$key', value)),
    outputs: outputs,
    readerWriter: readerWriter,
  );
}
