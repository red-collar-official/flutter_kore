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
import 'package:umvvm/arch/navigation/annotations/annotations.dart';
import 'package:umvvm_generator/collectors/main_app_visitor.dart';
import 'package:umvvm_generator/collectors/models/api_json_model.dart';
import 'package:umvvm_generator/collectors/models/instance_json_model.dart';
import 'package:umvvm_generator/generators/annotated_function_visitor.dart';

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
          final currentMap = pathsMap[routeKey][''] as Map;

          if (queryMap.isEmpty) {
            if (currentMap.containsKey('')) {
              throw Exception(
                'Multiple handlers detected for the same route: $newParser for $routeKey with path params: $pathsMap and query params $queryMap',
              );
            }

            currentMap.addAll({
              '': newParser,
            });
          } else {
            for (final entry in queryMap.entries) {
              if (currentMap.containsKey(entry.key)) {
                throw Exception(
                  'Multiple handlers detected for the same route: $newParser for $routeKey with path params: $pathsMap and query params $queryMap',
                );
              }
            }

            currentMap.addAll({
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
      final currentMap = correctedPathsMap[''] as Map;

      if (queryMap.isEmpty) {
        if (currentMap.containsKey('')) {
          throw Exception(
            'Multiple handlers detected for the same route: $newParser for $routeKey with path params: $pathsMap and query params $queryMap',
          );
        }

        currentMap.addAll({
          '': newParser,
        });
      } else {
        for (final entry in queryMap.entries) {
          if (currentMap.containsKey(entry.key)) {
            throw Exception(
              'Multiple handlers detected for the same route: $newParser for $routeKey with path params: $pathsMap and query params $queryMap',
            );
          }
        }

        currentMap.addAll({
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
      '// ignore_for_file: unnecessary_parenthesis, unused_local_variable, prefer_final_locals, unnecessary_string_interpolations, join_return_with_assignment, unnecessary_raw_strings',
    );

    methodsVisitor.annotatedMethods.forEach((key, value) {
      final paths = value
              .peek('paths')
              ?.listValue
              .map((e) => e.toStringValue())
              .toList() ??
          [];
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

      final query = value
              .peek('query')
              ?.listValue
              .map((e) => e.toStringValue())
              .toList() ??
          [];

      final possibleFragments = value
              .peek('possibleFragments')
              ?.listValue
              .map((e) => e.toStringValue()) ??
          [];

      final customHandler = value
          .peek('customHandler')
          ?.typeValue
          .getDisplayString(withNullability: false);

      final queriesForPathValue = value.peek('queriesForPath')?.listValue;
      final possibleFragmentsForPathValue =
          value.peek('possibleFragmentsForPath')?.listValue;

      for (int index = 0; index < paths.length; index++) {
        final path = paths[index];

        handlerIndex++;

        var queryForPath = query;
        var possibleFragmentsForPath = possibleFragments;

        if (queriesForPathValue != null) {
          queryForPath = queriesForPathValue[index]
                  .toListValue()
                  ?.map((e) => e.toStringValue())
                  .toList() ??
              [];
        }

        if (possibleFragmentsForPathValue != null) {
          possibleFragmentsForPath = possibleFragmentsForPathValue[index]
                  .toListValue()
                  ?.map((e) => e.toStringValue())
                  .toList() ??
              [];
        }

        if (path != null) {
          final codedPath = path.replaceAll(RegExp(':{.+?(?=})}'), '*');

          final queryHandlersMap = {};

          var resultRule = '';

          if (possibleFragmentsForPath.isNotEmpty) {
            for (final fragment in possibleFragmentsForPath) {
              queryForPath.add('#=$fragment');
            }
          }

          if (queryForPath.isNotEmpty) {
            for (final element in queryForPath) {
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

          addLinkHandlerToMap(
            codedPath,
            pathsMap,
            queryHandlersMap,
            newParser,
          );
        }

        if (path == null || customHandler != null) {
          continue;
        }

        final uriPath = Uri.parse(path);
        final segments = uriPath.pathSegments;

        var parseParamsUrlString = '';

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
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      $parseParamsUrlString
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
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
            'r\'$regex\': $customMapperType(),',
          );
        }
      }
    }

    return classBuffer.toString();
  }
}

class MainNavigationInteractorGenerator
    extends GeneratorForAnnotation<AppNavigation> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final visitor = MainAppVisitor();

    element.visitChildren(visitor);

    final classBuffer = StringBuffer();

    var appTabValue = 'void';

    final tabsValue = annotation.peek('tabs')?.typeValue.getDisplayString(
          withNullability: false,
        );

    if (tabsValue != null) {
      appTabValue = tabsValue;
    }

    var deeplinkValue = 'BaseDeepLinksInteractor';

    final deeplink = annotation.peek('deepLinks')?.typeValue.getDisplayString(
          withNullability: false,
        );

    if (deeplink != null) {
      deeplinkValue = deeplink;
    }

    classBuffer.writeln('''
abstract class ${visitor.className?.split("<")[0]}Declaration<NavigationState> extends BaseNavigationInteractor<
    NavigationState,
    Map<String, dynamic>,
    $appTabValue,
    Routes,
    Dialogs,
    BottomSheets,
    RouteNames,
    DialogNames,
    BottomSheetNames,
    $deeplinkValue> {
  final _routes = Routes();
  final _dialogs = Dialogs();
  final _bottomSheets = BottomSheets();

  @override
  BottomSheets get bottomSheets => _bottomSheets;
  @override
  Dialogs get dialogs => _dialogs;
  @override
  Routes get routes => _routes;
}
''');

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
