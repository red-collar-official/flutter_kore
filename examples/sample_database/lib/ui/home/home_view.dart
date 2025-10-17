import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/ui/posts_list/posts_list_view.dart';
import 'package:flutter_kore/flutter_kore_widgets.dart';

import 'components/bottom_navigation.dart';
import 'home_view_model.dart';
import 'home_view_state.dart';

class HomeView extends BaseWidget {
  const HomeView({
    super.key,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeViewWidgetState();
  }
}

class _HomeViewWidgetState
    extends NavigationView<HomeView, HomeViewState, HomeViewModel> {
  late final Map<AppTab, Widget> tabViews = {
    AppTabs.posts: const PostsListView(),
    AppTabs.likedPosts: const PostsListView(),
  };

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: KoreStreamBuilder<AppTab?>(
        streamWrap: viewModel.currentTab,
        builder: (context, snapshot) {
          return Stack(
            children: AppTabs.tabs
                .map((tab) => tabNavigationContainer(
                      offstage: snapshot.data?.index != tab.index,
                      navigationKey: viewModel.getNavigatorKey(tab),
                      view: tabViews[tab]!,
                      name: tab.name,
                      tab: tab,
                    ))
                .toList(),
          );
        },
      ),
      bottomNavigationBar: KoreStreamBuilder<AppTab?>(
        streamWrap: viewModel.currentTab,
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

  Widget tabNavigationContainer({
    required bool offstage,
    required GlobalKey<NavigatorState> navigationKey,
    required Widget view,
    required String name,
    required dynamic tab,
  }) {
    return Offstage(
      offstage: offstage,
      child: HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: TabNavigationInitializer(
          initialRoute: name,
          navigatorKey: navigationKey,
          initialView: view,
        ),
      ),
    );
  }

  @override
  HomeViewModel createViewModel() {
    return HomeViewModel();
  }
}
