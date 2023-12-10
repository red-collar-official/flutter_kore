import 'package:build/build.dart';
import 'package:test/test.dart';
import 'package:umvvm_generator/collectors/builders.dart';
import 'package:umvvm_generator/generators/builders.dart';

import 'components/test_generator.dart';

void main() {
  group('MainApiGenerator tests', () {
    test('Test code generation', () async {
      await testGenerator(
        'test_api.dart',
        generateApiCollector(BuilderOptions.empty),
        {
          'test_api.dart': '''
import 'package:umvvm/annotations/api.dart';

@api
class PostsApi {
}
          ''',
        },
        outputs: {'generated|lib/test_api.api.json': '[{"name":"PostsApi"}]'},
      );

      await testGenerator(
        'test_api_main.dart',
        generateMainApi(BuilderOptions.empty),
        {
          'test_api.api.json': '[{"name":"PostsApi"}]',
          'test_api_main.dart': '''
import 'package:umvvm/annotations/main_api.dart';

part 'test_api_main.api.dart';

@mainApi
class Apis with ApisGen {}

final apis = Apis();
          ''',
        },
        outputs: {
          'generated|lib/test_api_main.api.dart': '''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_api_main.dart';

// **************************************************************************
// MainApiGenerator
// **************************************************************************

mixin ApisGen {
  PostsApi? _posts;
  PostsApi get posts => _posts ??= PostsApi();
  @visibleForTesting
  set posts(value) => _posts = value;
}
'''
        },
      );
    });
  });
}
