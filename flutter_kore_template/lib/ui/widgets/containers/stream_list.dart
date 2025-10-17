import 'package:flutter_kore_template/ui/widgets/base/base_streamable_container.dart';
import 'package:flutter_kore_template/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class StreamList<T> extends BaseStreamContainer<T> {
  const StreamList({
    super.key,
    super.header,
    required super.stream,
    super.onRefresh,
    super.onLoadMore,
    super.loadingView,
    required super.errorView,
    required super.length,
    required super.builder,
    required super.padding,
    super.title,
    super.currentData,
    super.loadingSlivers,
    super.bottomSlivers,
    super.showHeaderWhenEmpty = true,
    super.showTitleWhenEmpty = true,
    super.emptyView,
    super.showTitle,
    super.enableRefreshWhenError = false,
    super.asSliver = false,
    super.isFinish,
    super.scrollController,
    super.physics = const RefreshScrollPhysics(),
  });

  @override
  State<StreamList> createState() => _StreamListViewState<T>();
}

class _StreamListViewState<T>
    extends BaseStreamContainerState<T, StreamList<T>> {
  @override
  Widget content(T object) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return itemBuilder(object, index);
      }, childCount: widget.length(object)),
    );
  }
}
