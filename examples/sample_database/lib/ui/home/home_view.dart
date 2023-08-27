import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/ui/posts_list/posts_list_view.dart';

import 'components/bottom_navigation.dart';
import 'home_view_model.dart';
import 'home_view_state.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewWidgetState();
  }
}

class _HomeViewWidgetState
    extends TabNavigationRootView<HomeView, HomeViewState, HomeViewModel> {
  late final Map<AppTab, Widget> tabViews = {
    AppTabs.posts: PostsListView(),
    AppTabs.likedPosts: PostsListView(),
  };

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<AppTab?>(
        stream: viewModel.currentTabStream,
        initialData: viewModel.initialTab,
        builder: (context, snapshot) {
          return Stack(
            children: AppTabs.tabs
                .map((tab) => tabNavigationContainer(
                      offstage: snapshot.data?.index != tab.index,
                      navigationKey: viewModel.getNavigatorKey(tab),
                      view: tabViews[tab]!,
                      name: tab.name,
                    ))
                .toList(),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<AppTab?>(
        stream: viewModel.currentTabStream,
        initialData: viewModel.initialTab,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const SizedBox.shrink();
          }

          return BottomNavigation(
            currentTab: snapshot.data!,
            onTabChanged: viewModel.changeTab,
            items: tabViews.keys.map((tab) {
              return BottomNavigationItemData(tab);
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  HomeViewModel createViewModel() {
    return HomeViewModel();
  }
}
