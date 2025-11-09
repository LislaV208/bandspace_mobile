import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/shared/utils/error_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logError(
      error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log(
      '${bloc.runtimeType}: $event',
      name: 'BlocObserver',
    );
  }
}
