import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Base class for route declarations
///
/// Must be extented by Routes, Dialogs, BottomSheets
/// or any custom route container
abstract class RoutesBase {
  /// Handlers for url paths and queries
  final routeLinkHandlers = <String, dynamic>{};

  /// Map of regex link mappers
  /// Used if no [LinkHandler] found in [routeLinkHandlers]
  final regexHandlers = <String, LinkMapper>{};

  /// Adds all routes to [routeLinkHandlers] and [regexHandlers]
  void initializeLinkHandlers();

  /// Checks if subroute matches given rule
  bool _checkSubroute(String rule, String paramKey, List<String> paramValue) {
    final correctedRule = rule.replaceAll(' ', '');

    if (correctedRule.contains('=')) {
      if (paramValue.length == 1) {
        return correctedRule == '$paramKey=${paramValue[0].toString()}';
      }

      final correctedList = paramValue.toString().replaceAll(' ', '');

      return correctedRule == '$paramKey=$correctedList';
    } else {
      return paramKey == correctedRule;
    }
  }

  /// Finds handler given url in [regexHandlers]
  LinkHandler? handlerForRegex(String url) {
    if (regexHandlers.isNotEmpty) {
      for (final regexValue in regexHandlers.entries) {
        final regex = RegExp(regexValue.key);

        if (regex.hasMatch(url)) {
          return GenericLinkHandler(mapper: regexHandlers[regexValue.key]!);
        }
      }
    } else {
      return null;
    }

    return null;
  }

  /// Tries to find [LinkHandler] in [routeLinkHandlers]
  LinkHandler? handlerForLink(String url) {
    final uriPath = Uri.parse(
      url.endsWith('/') ? url.substring(0, url.length - 1) : url,
    );

    final selectedRule = findDeclarationObject(uriPath.pathSegments);

    if (selectedRule is! Map) {
      return selectedRule;
    }

    final decisionSubroutes = findPossibleRoutes(
      uriPath.queryParametersAll,
      uriPath.fragment,
      selectedRule,
    );

    if (decisionSubroutes.isEmpty) {
      return selectedRule[''];
    } else {
      final latestSelected = findBestMatch(selectedRule, decisionSubroutes);

      if (latestSelected is LinkHandler) {
        return latestSelected;
      }

      // this must never happen

      // coverage:ignore-start
      return selectedRule[''];
      // coverage:ignore-end
    }
  }

  /// Finds best match for given rule in possible subroutes
  dynamic findBestMatch(
    Map selectedRule,
    Map<String, dynamic> decisionSubroutes,
  ) {
    final entries = decisionSubroutes.entries.toList();

    // ignore: cascade_invocations
    entries.sort(
      (first, second) => -first.value.compareTo(second.value),
    );

    var latestSelected = selectedRule[entries[0].key];
    final maxValue = entries[0].value;
    int index = 1;
    var maxEquals = 0;

    while (index < entries.length && entries[index].value == maxValue) {
      final matches = entries[index]
          .key
          .characters
          .where(
            (element) => element == '=',
          )
          .length;

      if (matches > maxEquals) {
        maxEquals = matches;
        latestSelected = selectedRule[entries[index].key];
      }

      index++;
    }

    return latestSelected;
  }

  /// Finds declaration of query mappers for given segments list
  dynamic findDeclarationObject(List<String> segments) {
    Map currentMapOfSubRoutes = routeLinkHandlers;

    for (final segment in segments) {
      var handlersObject = currentMapOfSubRoutes[segment];

      handlersObject ??= currentMapOfSubRoutes['*'];

      if (handlersObject == null) {
        return null;
      }

      if (handlersObject is LinkHandler) {
        return handlersObject;
      }

      currentMapOfSubRoutes = handlersObject as Map;
    }

    return currentMapOfSubRoutes[''];
  }

  /// Rates all route handlers for given query and possible subroutes
  ///
  /// More matches for query params -> bigger rate value
  Map<String, int> findPossibleRoutes(
    Map<String, List<String>> query,
    String fragment,
    Map possibleSubroutes,
  ) {
    final decisionSubroutes = <String, int>{};

    if (query.isEmpty) {
      return decisionSubroutes;
    }

    final suggestions = possibleSubroutes.keys.map((element) {
      final subroute = element as String;

      if (!subroute.contains('|')) {
        for (final queryParam in query.entries) {
          if (_checkSubroute(subroute, queryParam.key, queryParam.value)) {
            return MapEntry(subroute, 1);
          }
        }

        return MapEntry(subroute, 0);
      }

      var canBeSelectedQueryParams = 0;
      final alreadyChecked = <String>[];
      final rules = subroute.split('|');

      for (final rule in rules) {
        var queryCheckResult = 0;

        if (rule.startsWith('#')) {
          final ruleKey = rule.split('=')[0];

          if (alreadyChecked.contains(ruleKey)) {
            continue;
          }

          final requiredRules = rules.where(
            (element) => element.contains('$ruleKey='),
          );

          var ruleIsSatisfied = false;

          for (final requiredRule in requiredRules) {
            if (requiredRule.substring(2) == fragment) {
              ruleIsSatisfied = true;
              break;
            }
          }

          if (!ruleIsSatisfied) {
            canBeSelectedQueryParams = 0;
            break;
          } else {
            canBeSelectedQueryParams++;
            alreadyChecked.add(ruleKey);
          }
        } else if (rule.contains('=')) {
          final ruleKey = rule.split('=')[0];

          if (alreadyChecked.contains(ruleKey)) {
            continue;
          }

          final requiredRules = rules.where(
            (element) => element.contains('$ruleKey='),
          );

          var ruleIsSatisfied = false;

          for (final requiredRule in requiredRules) {
            if (query.entries.where((element) {
              final formattedQuery = element.value.length != 1
                  ? '${element.key}=${element.value}'
                  : '${element.key}=${element.value[0]}';

              return requiredRule == formattedQuery;
            }).isNotEmpty) {
              ruleIsSatisfied = true;
              break;
            }
          }

          if (!ruleIsSatisfied) {
            canBeSelectedQueryParams = 0;
            break;
          } else {
            canBeSelectedQueryParams++;
            alreadyChecked.add(ruleKey);
          }
        } else {
          for (final queryParam in query.entries) {
            if (alreadyChecked.contains(queryParam.key)) {
              continue;
            }

            final routeCheckResult = _checkSubroute(
              rule,
              queryParam.key,
              queryParam.value,
            );

            if (routeCheckResult) {
              queryCheckResult++;
              canBeSelectedQueryParams++;
              alreadyChecked.add(queryParam.key);
            }
          }

          if (queryCheckResult == 0 && !rule.contains('?')) {
            canBeSelectedQueryParams = 0;
            break;
          }
        }

        queryCheckResult = 0;
      }

      return MapEntry(subroute, canBeSelectedQueryParams);
    });

    for (final element in suggestions) {
      decisionSubroutes[element.key] = element.value;
    }

    return decisionSubroutes;
  }
}
