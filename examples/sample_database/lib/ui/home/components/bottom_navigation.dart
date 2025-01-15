import 'package:flutter/material.dart';
import 'package:sample_database/domain/data/app_tab.dart';

typedef OnTabChangedCallback = void Function(AppTab appTab);

class BottomNavigationItemData {
  final AppTab appTabValue;

  const BottomNavigationItemData(
    this.appTabValue,
  );
}

class BottomNavigation extends StatelessWidget {
  final AppTab currentTab;
  final OnTabChangedCallback onTabChanged;
  final List<BottomNavigationItemData> items;

  const BottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, right: 12, left: 12, bottom: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items
              .map(
                (tabItem) => GestureDetector(
                  onTap: () {
                    onTabChanged(tabItem.appTabValue);
                  },
                  child: BottomNavigationItem(
                    appTab: tabItem.appTabValue,
                    selected: currentTab.index == tabItem.appTabValue.index,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  final bool selected;
  final AppTab appTab;

  const BottomNavigationItem({
    super.key,
    required this.appTab,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          if (selected)
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: SizedBox(
        width: 62.2,
        height: 49,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.antiAlias,
          children: [
            Positioned.fill(
              child: buildIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIcon() {
    return Column(
      children: [
        Icon(
          appTab.icon,
          color: selected ? Colors.green : Colors.black,
          size: 20,
        ),
      ],
    );
  }
}
