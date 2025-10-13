import 'package:umvvm/umvvm_widgets.dart';
import 'package:umvvm_template/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umvvm/umvvm.dart';

abstract class BaseStreamContainer<T> extends StatefulWidget {
  const BaseStreamContainer({
    super.key,
    required this.header,
    required this.stream,
    required this.onRefresh,
    required this.onLoadMore,
    this.loadingSlivers,
    this.loadingView,
    required this.errorView,
    required this.length,
    required this.builder,
    required this.padding,
    required this.title,
    required this.currentData,
    required this.bottomSlivers,
    required this.showHeaderWhenEmpty,
    required this.showTitleWhenEmpty,
    required this.emptyView,
    required this.showTitle,
    required this.enableRefreshWhenError,
    required this.asSliver,
    required this.isFinish,
    this.scrollController,
    this.physics = const BouncingScrollPhysics(),
  });

  final Widget? header;
  final Stream<StatefulData<T>?> stream;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final List<Widget>? loadingSlivers;
  final Widget? loadingView;
  final Widget errorView;
  final Widget? emptyView;
  final int Function(T) length;
  final Widget Function(BuildContext, int, T) builder;
  final EdgeInsets padding;
  final Widget? title;
  final StatefulData<T>? Function()? currentData;
  final List<Widget> Function(int, T?)? bottomSlivers;
  final bool showHeaderWhenEmpty;
  final bool showTitleWhenEmpty;
  final bool enableRefreshWhenError;
  final bool Function(int)? showTitle;
  final bool asSliver;
  final bool Function(T)? isFinish;
  final ScrollController? scrollController;
  final ScrollPhysics physics;
}

abstract class BaseStreamContainerState<T, W extends BaseStreamContainer<T>> extends State<W> {
  bool isLoadingMore = false;
  int currentListLength = 0;

  @override
  Widget build(BuildContext context) {
    return UmvvmStreamBuilder<StatefulData<T>?>(
      stream: widget.stream,
      // ignore: prefer_null_aware_operators
      initialData: widget.currentData != null ? widget.currentData! : null,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (widget.asSliver) {
            return SliverToBoxAdapter(child: widget.loadingView);
          }
        }

        if (widget.asSliver) {
          final data = snapshot.data!;

          switch (data) {
            case LoadingData():
              return SliverToBoxAdapter(child: widget.loadingView);
            case SuccessData(:final result):
              if (widget.length(result) == 0 && widget.emptyView != null) {
                return SliverToBoxAdapter(child: widget.emptyView);
              }

              return SliverPadding(
                padding: widget.padding,
                sliver: content(result),
              );
            case ErrorData(error: final _):
              return SliverToBoxAdapter(child: widget.errorView);
          }
        }

        List<Widget> slivers;

        if (!snapshot.hasData) {
          slivers = widget.loadingSlivers!;
        } else {
          final data = snapshot.data!;

          switch (data) {
            case LoadingData():
              slivers = widget.loadingSlivers!;
            case SuccessData(:final result):
              if (widget.length(result) == 0 && widget.emptyView != null) {
                slivers = _emptyView();
              } else {
                slivers = _dataView(result);
              }
            case ErrorData(error: final _):
              slivers = _errorView();
          }
        }

        return _mainScroll(slivers);
      },
    );
  }

  Widget _mainScroll(List<Widget> slivers) {
    return CustomScrollView(
      controller: widget.scrollController,
      physics: widget.physics,
      slivers: slivers,
    );
  }

  List<Widget> _dataView(T result) {
    bool showTitle;

    if (widget.showTitle != null) {
      showTitle = widget.showTitle!(widget.length(result));
    } else {
      showTitle = true;
    }

    return [
      if (widget.header != null) widget.header!,
      if (widget.onRefresh != null) _refreshControl(),
      if (widget.title != null && showTitle) widget.title!,
      SliverPadding(
        padding: widget.padding,
        sliver: content(result),
      ),
      if (isLoadingMore)
        const SliverToBoxAdapter(
          child: UILoadMoreControl(),
        ),
      if (widget.bottomSlivers != null) ...widget.bottomSlivers!(widget.length(result), result),
    ];
  }

  List<Widget> _emptyView() => [
        if (widget.header != null && widget.showHeaderWhenEmpty) widget.header!,
        if (widget.onRefresh != null) _refreshControl(),
        if (widget.title != null && widget.showTitleWhenEmpty) widget.title!,
        widget.emptyView!,
        if (widget.bottomSlivers != null) ...widget.bottomSlivers!(0, null),
      ];

  List<Widget> _errorView() => [
        if (widget.header != null && widget.showHeaderWhenEmpty) widget.header!,
        if (widget.onRefresh != null && widget.enableRefreshWhenError) _refreshControl(),
        if (widget.title != null && widget.showTitleWhenEmpty) widget.title!,
        widget.errorView,
        if (widget.bottomSlivers != null) ...widget.bottomSlivers!(0, null),
      ];

  void processLoadMoreCallback(T object) {
    if (widget.isFinish!(object) || isLoadingMore) {
      return;
    }

    isLoadingMore = true;
    currentListLength = widget.length(object);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {});
      }

      widget.onLoadMore!().then((value) {
        if (mounted) {
          setState(() {
            isLoadingMore = false;
          });
        }
      });
    });
  }

  Widget content(T object);

  Widget itemBuilder(T object, int index) {
    if (widget.onLoadMore != null) {
      if (index == widget.length(object) - 1) {
        processLoadMoreCallback(object);
      }
    }

    return widget.builder(context, index, object);
  }

  Widget _refreshControl() => UIRefreshControl(
        onRefresh: () => widget.onRefresh!().then((_) {
          HapticFeedback.lightImpact();
        }),
      );
}
