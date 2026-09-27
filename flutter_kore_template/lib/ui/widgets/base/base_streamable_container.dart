import 'package:flutter_kore/flutter_kore_widgets.dart';
import 'package:flutter_kore_template/ui/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kore/flutter_kore.dart';

abstract class const BaseStreamContainer<T>({
  super.key,
  required final Widget? header,
  required final StateStream<StatefulData<T>?> stream,
  required final Future<void> Function()? onRefresh,
  required final Future<void> Function()? onLoadMore,
  final List<Widget>? loadingSlivers,
  final Widget? loadingView,
  required final Widget errorView,
  required final int Function(T) length,
  required final Widget Function(BuildContext, int, T) builder,
  required final EdgeInsets padding,
  required final Widget? title,
  required final List<Widget> Function(int, T?)? bottomSlivers,
  required final bool showHeaderWhenEmpty,
  required final bool showTitleWhenEmpty,
  required final Widget? emptyView,
  required final bool Function(int)? showTitle,
  required final bool enableRefreshWhenError,
  required final bool asSliver,
  required final bool Function(T)? isFinish,
  final ScrollController? scrollController,
  final ScrollPhysics physics = const BouncingScrollPhysics(),
}) extends StatefulWidget;

abstract class BaseStreamContainerState<T, W extends BaseStreamContainer<T>>
    extends State<W> {
  var isLoadingMore = false;
  var currentListLength = 0;

  @override
  Widget build(BuildContext context) {
    return KoreStreamBuilder(
      streamWrap: widget.stream,
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
      ?widget.header,
      if (widget.onRefresh != null) _refreshControl(),
      if (widget.title != null && showTitle) widget.title!,
      SliverPadding(padding: widget.padding, sliver: content(result)),
      if (isLoadingMore) const SliverToBoxAdapter(child: UILoadMoreControl()),
      if (widget.bottomSlivers != null)
        ...widget.bottomSlivers!(widget.length(result), result),
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
    if (widget.onRefresh != null && widget.enableRefreshWhenError)
      _refreshControl(),
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
