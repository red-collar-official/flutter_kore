// ignore_for_file: avoid_print, use_string_buffers

import 'dart:async';
import 'dart:convert';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:build/src/builder/build_step.dart';
// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:umvvm/annotations/main_api.dart';
import 'package:umvvm/annotations/main_app.dart';
import 'package:umvvm/arch/navigation/annotations/routes.dart';
import 'package:umvvm/collectors/models/api_json_model.dart';
import 'package:umvvm/collectors/models/instance_json_model.dart';
import 'package:umvvm/generators/annotated_function_visitor.dart';
import 'package:umvvm/generators/main_app_visitor.dart';

class MainAppGenerator extends GeneratorForAnnotation<MainApp> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final className = '${getClassName(element)}Gen';
    final classBuffer = StringBuffer();

    final instanceJsons = Glob('lib/**.mvvm.json');

    final jsonData = <Map>[];

    await for (final id in buildStep.findAssets(instanceJsons)) {
      final json = jsonDecode(await buildStep.readAsString(id));
      jsonData.addAll([...json]);
    }

    final instances = <InstanceJsonModel>[];

    for (final json in jsonData) {
      instances.add(InstanceJsonModel.fromJson(json));
    }

    // @override
    // List<Type> get singletons => [
    //     AutharizationInteractor,
    //     UserDefaultsInteractor,
    //     NavigationInteractor,
    //   ];

    generateConnectorsForInstanceType(
      classBuffer,
      instances,
    );

    // ignore: cascade_invocations
    classBuffer.writeln('class Connectors {');

    generateConnectorCallsForInstanceType(
      classBuffer,
      instances,
    );

    classBuffer
      ..writeln('}')
      ..writeln();

    if (annotation.peek('navigationInteractorType') == null) {
      classBuffer.writeln(
        'mixin $className on UMvvmApp {',
      );
    } else {
      classBuffer.writeln(
        'mixin $className on UMvvmApp<${annotation.peek('navigationInteractorType')!.typeValue.getDisplayString(withNullability: false)}> {',
      );
    }

    // ignore: cascade_invocations
    classBuffer
      ..writeln('final connectors = Connectors();')
      ..writeln()
      ..writeln('@override')
      ..writeln('List<Connector> get singletonInstances => [');

    // ignore: prefer_foreach
    for (final element in instances) {
      if (element.singleton && !element.lazy && !element.part) {
        classBuffer.writeln(
          'connectors.${uncapitalize(element.name)}Connector(),',
        );
      }
    }

    // @override
    // void registerBuilders() {
    //   interactors
    //     ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
    //     ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
    //     ..addBuilder<PostsInteractor>(() => PostsInteractor())
    //     ..addBuilder<ShareInteractor>(() => ShareInteractor())
    //     ..addBuilder<PostInteractor>(() => PostInteractor())
    //     ..addBuilder<NavigationInteractor>(() => NavigationInteractor());
    // }

    classBuffer
      ..writeln('  ];')
      ..writeln()
      ..writeln('@override')
      ..writeln('void registerInstances() {');
    if (instances.isNotEmpty) {
      classBuffer.writeln('instances');
    }

    for (final element in instances) {
      classBuffer
          .writeln('..addBuilder<${element.name}>(() => ${element.name}())');
    }

    if (instances.isNotEmpty) {
      classBuffer.writeln(';');
    }

    classBuffer
      ..writeln('}')
      ..writeln('}');

    String printMessage = '';

    printMessage += 'Generated Mvvm app\n\n';
    printMessage += 'Instances count: ${instances.length}';
    print(printMessage);

    return classBuffer.toString();
  }

  String getClassName(Element element) {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    return visitor.className ?? '';
  }

  void generateConnectorsForInstanceType(
    StringBuffer classBuffer,
    List<InstanceJsonModel> instances,
  ) {
    for (final element in instances) {
      final nameOfElementClass = element.name;
      final nameOfInputType = element.inputType;
      final asyncValue = element.async;
      final awaitInitializationValue = element.awaitInitialization;
      final orderValue = element.initializationOrder;
      final partValue = element.part;

      String overridesString = '';

      if (!partValue) {
        if (orderValue != null) {
          overridesString += '''
  @override
  int? get order => $orderValue;
''';
        }

        if (awaitInitializationValue || orderValue != null) {
          overridesString += '''
  @override
  bool get awaitInitialization => $awaitInitializationValue;
''';
        }
      }

      String baseClassString = '';

      if (partValue) {
        if (asyncValue) {
          baseClassString = 'AsyncPartConnectorCall';
        } else {
          baseClassString = 'PartConnectorCall';
        }
      } else if (asyncValue) {
        baseClassString = 'AsyncConnectorCall';
      } else {
        baseClassString = 'ConnectorCall';
      }

      classBuffer
        ..writeln(
          'class ${nameOfElementClass}Connector extends $baseClassString<$nameOfElementClass, $nameOfInputType?> {$overridesString}',
        )
        ..writeln();
    }
  }

  void generateConnectorCallsForInstanceType(
    StringBuffer classBuffer,
    List<InstanceJsonModel> collection,
  ) {
    for (final element in collection) {
      generateConnectorCallForElement(classBuffer, element);
    }
  }

  void generateConnectorCallForElement(
    StringBuffer classBuffer,
    InstanceJsonModel element,
  ) {
    final nameOfElementClass = element.name;

    classBuffer.writeln(
      'late final ${uncapitalize(nameOfElementClass)}Connector = ${nameOfElementClass}Connector();',
    );
  }

  String uncapitalize(String input) {
    return '${input[0].toLowerCase()}${input.substring(1)}';
  }
}

class MainNavigationGenerator extends GeneratorForAnnotation<RoutesAnnotation> {
  String capitalize(String input) {
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  void addLinkHandlerToMap(
    String routeKey,
    Map pathsMap,
    Map queryMap,
    String newParser,
  ) {
    if (!routeKey.contains('/')) {
      if (pathsMap[routeKey] == null) {
        pathsMap[routeKey] = {
          '': queryMap.isEmpty ? newParser : queryMap,
        };
      } else if (pathsMap[routeKey][''] == null) {
        pathsMap[routeKey][''] = queryMap.isEmpty ? newParser : queryMap;
      } else {
        if (pathsMap[routeKey][''] is String) {
          if (queryMap.isNotEmpty) {
            pathsMap[routeKey][''] = {
              '': pathsMap[routeKey][''],
              ...queryMap,
            };
          }
        } else {
          if (queryMap.isEmpty) {
            pathsMap[routeKey][''].addAll({
              '': newParser,
            });
          } else {
            pathsMap[routeKey][''].addAll({
              ...queryMap,
            });
          }
        }
      }

      return;
    }

    var correctedPathsMap = pathsMap;
    final segments = routeKey.split('/');

    for (final segment in segments) {
      if (correctedPathsMap[segment] == null) {
        correctedPathsMap[segment] = {};
      } else if (correctedPathsMap[segment] is String) {
        correctedPathsMap[segment] = {
          '': correctedPathsMap[segment],
        };
      }

      correctedPathsMap = correctedPathsMap[segment];
    }

    if (correctedPathsMap[''] is String) {
      if (queryMap.isNotEmpty) {
        correctedPathsMap[''] = {
          '': correctedPathsMap[''],
          ...queryMap,
        };
      }
    } else if (correctedPathsMap[''] is Map) {
      if (queryMap.isEmpty) {
        correctedPathsMap[''].addAll({
          '': newParser,
        });
      } else {
        correctedPathsMap[''].addAll({
          ...queryMap,
        });
      }
    } else {
      correctedPathsMap[''] = queryMap.isEmpty ? newParser : queryMap;
    }
  }

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    String? getParameterInitializationCode(String valueString) {
      return '$valueString;';
    }

    final visitor = MainAppVisitor();
    final methodsVisitor = AnnotatedFunctionVisitor();

    element
      ..visitChildren(visitor)
      ..visitChildren(methodsVisitor);

    final isDialog = annotation.peek('dialogs')?.boolValue ?? false;
    final isBottomSheet = annotation.peek('bottomSheets')?.boolValue ?? false;

    final className = visitor.className;
    final classBuffer = StringBuffer();

    var linkHandlerBaseClass = 'RouteLinkHandler';
    var namesEnumClass = 'RouteNames';
    var routesBaseClass = 'routes';

    if (isDialog) {
      linkHandlerBaseClass = 'DialogLinkHandler';
      namesEnumClass = 'DialogNames';
      routesBaseClass = 'dialogs';
    } else if (isBottomSheet) {
      linkHandlerBaseClass = 'BottomSheetLinkHandler';
      namesEnumClass = 'BottomSheetNames';
      routesBaseClass = 'bottomSheets';
    }

    final linkHandlersMap = {};

    classBuffer.writeln(
      '// ignore_for_file: unnecessary_parenthesis, unused_local_variable, prefer_final_locals, unnecessary_string_interpolations, join_return_with_assignment',
    );

    methodsVisitor.annotatedMethods.forEach((key, value) {
      final paths =
          value.peek('paths')?.listValue.map((e) => e.toStringValue()) ?? [];
      final regexes = value.peek('regexes')?.listValue;

      if (paths.isNotEmpty && regexes != null) {
        throw Exception('Cant add paths and regexes to the same route $key');
      }

      final requiresState = (methodsVisitor
                  .annotatedMethodsData[key]?.parameters
                  .where((element) => element.name == 'state') ??
              [])
          .isNotEmpty;

      if (regexes != null) {
        return;
      }

      var handlerIndex = 0;

      for (final path in paths) {
        handlerIndex++;

        final customHandler = value
            .peek('customHandler')
            ?.typeValue
            .getDisplayString(withNullability: false);
        final query =
            value.peek('query')?.listValue.map((e) => e.toStringValue()) ?? [];

        if (path != null) {
          final codedPath = path.replaceAll(RegExp(':{.+?(?=})}'), '*');

          final queryHandlersMap = {};

          if (query.isNotEmpty) {
            var resultRule = '';

            for (final element in query) {
              if (element!.contains('=') && element.contains('|')) {
                final splittedByKeyValues = element.split('=');

                final key = splittedByKeyValues[0];
                final values = splittedByKeyValues[1].split('|');

                for (final element in values) {
                  resultRule += '$key=$element|';
                }
              } else {
                resultRule += '$element|';
              }
            }

            resultRule = resultRule.substring(0, resultRule.length - 1);

            if (customHandler != null) {
              queryHandlersMap[resultRule] = customHandler;
            } else {
              queryHandlersMap[resultRule] =
                  '${capitalize(key)}LinkHandler$handlerIndex';
            }
          }

          final pathsMap = linkHandlersMap;

          String newParser;

          if (customHandler != null) {
            newParser = customHandler;
          } else {
            newParser = '${capitalize(key)}LinkHandler$handlerIndex';
          }

          try {
            addLinkHandlerToMap(
              codedPath,
              pathsMap,
              queryHandlersMap,
              newParser,
            );
          } catch (e, trace) {
            print(e);
            print(trace);
          }
        }

        if (path == null || customHandler != null) {
          return;
        }

        final uriPath = Uri.parse(path);
        final segments = uriPath.pathSegments;

        var patternQueryString = 'final patternQuery = [\n';
        var parseParamsUrlString = '';
        var parseParamsQueryString = '';

        for (final element in segments) {
          if (!element.contains(':{')) {
            continue;
          }

          final paramName = element.replaceAll(RegExp('[:{}]'), '');

          final paramInitialization = getParameterInitializationCode(
            'segments[index]',
          );

          parseParamsUrlString += '''
if (pathSegmentPattern == '$element') {
  pathParams['$paramName'] = $paramInitialization
}
''';
        }

        for (final element in query) {
          var queryElement = element!.replaceAll('?', '');

          if (queryElement.contains('=')) {
            queryElement = queryElement.split('=')[0];
          }

          patternQueryString += '\'$queryElement\',';
          patternQueryString += '\n';

          final paramInitialization = getParameterInitializationCode(
            'queryParams[queryParam] ?? []',
          );

          parseParamsQueryString += '''
queryParamsForView['$queryElement'] = $paramInitialization
''';
        }

        patternQueryString += '\n];';

        classBuffer
          ..writeln(
            'class ${capitalize(key)}LinkHandler$handlerIndex extends $linkHandlerBaseClass {',
          )
          ..writeln(
            '''
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('$path');
    $patternQueryString
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      $parseParamsUrlString
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      $parseParamsQueryString
    }

    ${requiresState ? 'final anchor = uriPath.fragment;' : ''}

    final route = app.navigation.$routesBaseClass.$key(
      pathParams: pathParams,
      queryParams: queryParamsForView,
      ${requiresState ? 'state: anchor,' : ''}
    );

    return route;
  }
}
''',
          );
      }
    });

    classBuffer
      ..writeln()
      ..writeln('enum $namesEnumClass {');

    for (final method in methodsVisitor.allMethods) {
      classBuffer.writeln('$method,');
    }

    classBuffer
      ..writeln('}')
      ..writeln()
      ..writeln('mixin ${className}Gen on RoutesBase {')
      ..writeln()
      ..writeln('@override')
      ..writeln('void initializeLinkHandlers() {')
      ..writeln('routeLinkHandlers.addAll({')
      ..writeln(generateLinksMap(linkHandlersMap))
      ..writeln('});')
      ..writeln('regexHandlers.addAll({')
      ..writeln(generateRegexMapper(methodsVisitor.annotatedMethods.values))
      ..writeln('});')
      ..writeln('}')
      ..writeln('}')
      ..writeln();

    String printMessage = '';

    printMessage += 'Generated Navigation for app\n\n';
    printMessage += '$className count: ${methodsVisitor.allMethods.length}';
    print(printMessage);

    return classBuffer.toString();
  }

  String generateLinksMap(Map linkHandlersMap) {
    final classBuffer = StringBuffer();

    if (linkHandlersMap.values.whereType<Map>().isNotEmpty) {
      linkHandlersMap.forEach((key, value) {
        if (value is Map) {
          classBuffer.writeln(
            '\'$key\': {${generateLinksMap(value)}},',
          );
        } else {
          classBuffer.writeln('\'$key\': $value(),');
        }
      });
    } else {
      linkHandlersMap.forEach((key, value) {
        classBuffer.writeln('\'$key\': $value(),');
      });
    }

    return classBuffer.toString();
  }

  String generateRegexMapper(Iterable<ConstantReader> annotatedMethods) {
    final classBuffer = StringBuffer();

    for (final method in annotatedMethods) {
      final regexes =
          method.peek('regexes')?.listValue.map((e) => e.toStringValue());
      final customMapperType = method
          .peek('customParamsMapper')
          ?.typeValue
          .getDisplayString(withNullability: false);

      if (regexes != null) {
        for (final regex in regexes) {
          classBuffer.writeln(
            '\'$regex\': $customMapperType(),',
          );
        }
      }
    }

    return classBuffer.toString();
  }
}

class MainApiGenerator extends GeneratorForAnnotation<MainApiAnnotation> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final className = '${visitor.className}Gen';
    final classBuffer = StringBuffer();

    // class Apis {
    //   static PostsApi? _posts;
    //   static PostsApi get posts => _posts ??= PostsApi();
    //   @visibleForTesting
    //   static set posts(value) => _posts = value;
    // }

    // ignore: cascade_invocations
    classBuffer.writeln('mixin $className {');

    final apisJsons = Glob('lib/**.api.json');

    final jsonData = <Map>[];

    await for (final id in buildStep.findAssets(apisJsons)) {
      final json = jsonDecode(await buildStep.readAsString(id));
      jsonData.addAll([...json]);
    }

    final apis = <ApiJsonModel>[];

    for (final json in jsonData) {
      apis.add(ApiJsonModel.fromJson(json));
    }

    // ignore: prefer_foreach
    for (final element in apis) {
      final elementName = element.name;
      final elementShortName = elementName.toLowerCase().split('api')[0];

      classBuffer
        ..writeln('$elementName? _$elementShortName;')
        ..writeln(
            '$elementName get $elementShortName => _$elementShortName ??= $elementName();')
        ..writeln('@visibleForTesting')
        ..writeln(
            'set $elementShortName(value) => _$elementShortName = value;');
    }

    classBuffer.writeln('}');

    String printMessage = '';

    printMessage += 'Generated Apis for app\n\n';
    printMessage += 'Apis count: ${apis.length}';

    print(printMessage);

    return classBuffer.toString();
  }
}
