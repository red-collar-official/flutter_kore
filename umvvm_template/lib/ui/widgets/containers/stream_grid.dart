import 'package:umvvm_template/ui/widgets/base/base_streamable_container.dart';
import 'package:umvvm_template/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class StreamGrid<T> extends BaseStreamContainer<T> {
  const StreamGrid({
    super.key,
    super.header,
    required super.stream,
    super.onRefresh,
    super.onLoadMore,
    super.loadingView,
    required super.errorView,
    required this.gridDelegate,
    required super.length,
    required super.builder,
    required super.padding,
    super.title,
    super.currentData,
    super.bottomSlivers,
    super.showHeaderWhenEmpty = true,
    super.showTitleWhenEmpty = true,
    super.emptyView,
    super.showTitle,
    super.enableRefreshWhenError = false,
    super.asSliver = false,
    super.isFinish,
    super.loadingSlivers,
    super.scrollController,
    super.physics = const RefreshScrollPhysics(),
  });

  final SliverGridDelegateWithFixedCrossAxisCount gridDelegate;

  @override
  State<StreamGrid> createState() => _StreamGridViewState<T>();
}

class _StreamGridViewState<T> extends BaseStreamContainerState<T, StreamGrid<T>> {
  @override
  Widget content(T object) {
    return SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return itemBuilder(object, index);
        },
        childCount: widget.length(object),
      ),
    );
  }
}
