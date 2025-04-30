import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace?)? error;
  final bool skipLoadingOnRefresh;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.skipLoadingOnRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading:
          loading ?? () => const Center(child: CircularProgressIndicator()),
      error: error ?? _defaultErrorWidget,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
    );
  }

  Widget _defaultErrorWidget(Object error, StackTrace? stackTrace) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
