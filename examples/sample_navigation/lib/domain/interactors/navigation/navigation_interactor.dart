import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/global/events.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/bottom_sheets/bottom_sheet_names.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs/dialog_names.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/route_names.dart';

import 'navigation_state.dart';

@singletonInteractor
class NavigationInteractor extends BaseNavigationInteractor<NavigationState,
    Map<String, dynamic>, AppTab, RouteNames, DialogNames, BottomSheetNames> {
  @override
  RouteNames get initialRoute => RouteNames.home;

  @override
  Future<void> onBottomSheetOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onDialogOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onRouteOpened(Widget child, UIRouteSettings route) async {
    if (route.global) {
      app.eventBus.send(GlobalRoutePushedEvent(replace: route.replace));
    }
  }

  @override
  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState initialState(Map<String, dynamic>? input) =>
      NavigationState(currentTab: AppTabs.posts);
}
