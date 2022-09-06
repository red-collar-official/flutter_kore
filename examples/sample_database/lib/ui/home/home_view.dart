import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample/domain/data/app_tab.dart';
import 'package:sample/ui/posts_list/posts_list_view.dart';

import 'components/bottom_navigation.dart';
import 'home_view_model.dart';
import 'home_view_state.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewWidgetState();
  }
}

class _HomeViewWidgetState extends BaseView<HomeView, HomeViewState, HomeViewModel> {
  late final Map<AppTab, Widget> tabs = {
    AppTabs.posts: PostsListView(),
    AppTabs.likedPosts: PostsListView(),
  };

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<AppTab?>(
        stream: viewModel.currentTabStream,
        initialData: viewModel.initialTab,
        builder: (context, snapshot) {
          return Stack(
            children: AppTabs.tabs.map((tab) => _buildOffstageNavigator(tab, snapshot.data)).toList(),
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
            items: tabs.keys.map((tab) {
              return BottomNavigationItemData(tab);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOffstageNavigator(AppTab appTab, AppTab? current) {
    return Offstage(
      offstage: current?.index != appTab.index,
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Navigator(
          initialRoute: appTab.name,
          key: viewModel.getNavigatorKey(appTab),
          onGenerateRoute: (settings) {
            if (settings.name == appTab.name) {
              return MaterialPageRoute(
                builder: (context) => tabs[appTab]!,
              );
            }

            return null;
          },
        ),
      ),
    );
  }

  @override
  HomeViewModel createViewModel() {
    return HomeViewModel();
  }

  @override
  HomeViewState get initialState => HomeViewState();
}
