import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

abstract class RoutesBase {
  final routeLinkHandlers = <String, dynamic>{};
  final regexHandlers = <String, LinkMapper>{};

  void initializeLinkHandlers();

  bool _checkSubroute(String rule, String paramKey, List<String> paramValue) {
    final correctedRule = rule.replaceAll(' ', '');

    if (correctedRule.contains('=')) {
      if (paramValue.length == 1) {
        return correctedRule == '$paramKey=${paramValue[0].toString()}';
      }

      final correctedList = paramValue.toString().replaceAll(' ', '');

      return correctedRule == '$paramKey=$correctedList';
    } else {
      return paramKey == correctedRule || correctedRule == '$paramKey?';
    }
  }

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

  Map<String, int> findPossibleRoutes(
    Map<String, List<String>> query,
    Map possibleSubroutes,
  ) {
    final decisionSubroutes = <String, int>{};

    if (query.isNotEmpty) {
      final suggestions = possibleSubroutes.keys.map((element) {
        final subroute = element as String;

        if (subroute.contains('|')) {
          var canBeSelectedQueryParams = 0;
          final alreadyChecked = <String>[];
          final rules = subroute.split('|');

          for (final rule in rules) {
            for (final queryParam in query.entries) {
              if (alreadyChecked.contains(queryParam.key)) {
                continue;
              }

              if (_checkSubroute(rule, queryParam.key, queryParam.value)) {
                canBeSelectedQueryParams++;
                alreadyChecked.add(queryParam.key);
              }
            }
          }

          return MapEntry(subroute, canBeSelectedQueryParams);
        } else {
          for (final queryParam in query.entries) {
            if (_checkSubroute(subroute, queryParam.key, queryParam.value)) {
              return MapEntry(subroute, 1);
            }
          }

          return MapEntry(subroute, 0);
        }
      });

      for (final element in suggestions) {
        decisionSubroutes[element.key] = element.value;
      }
    }

    return decisionSubroutes;
  }
}
