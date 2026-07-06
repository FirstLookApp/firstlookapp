import 'package:flutter/material.dart';

class AppPaginatedListView extends StatelessWidget {
  const AppPaginatedListView({
    required this.itemCount,
    required this.itemBuilder,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (!hasMore || isLoadingMore) {
          return false;
        }

        final double threshold = notification.metrics.maxScrollExtent - 160;
        if (notification.metrics.pixels >= threshold) {
          onLoadMore();
        }

        return false;
      },
      child: ListView.builder(
        itemCount: hasMore ? itemCount + 1 : itemCount,
        itemBuilder: (BuildContext context, int index) {
          if (index >= itemCount) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return itemBuilder(context, index);
        },
      ),
    );
  }
}
