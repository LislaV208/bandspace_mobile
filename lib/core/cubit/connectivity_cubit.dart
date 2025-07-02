import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/connectivity_service.dart';

// Connectivity State
class ConnectivityState extends Equatable {
  final ConnectionStatus status;
  final DateTime? lastOnlineTime;
  final bool isRetrying;
  final String? errorMessage;

  const ConnectivityState({
    required this.status,
    this.lastOnlineTime,
    this.isRetrying = false,
    this.errorMessage,
  });

  factory ConnectivityState.initial() {
    return const ConnectivityState(
      status: ConnectionStatus.unknown,
    );
  }

  ConnectivityState copyWith({
    ConnectionStatus? status,
    DateTime? lastOnlineTime,
    bool? isRetrying,
    String? errorMessage,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      lastOnlineTime: lastOnlineTime ?? this.lastOnlineTime,
      isRetrying: isRetrying ?? this.isRetrying,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isOnline => status == ConnectionStatus.online;
  bool get isOffline => status == ConnectionStatus.offline;
  bool get isUnknown => status == ConnectionStatus.unknown;

  String get statusText {
    switch (status) {
      case ConnectionStatus.online:
        return 'Online';
      case ConnectionStatus.offline:
        return 'Tryb offline';
      case ConnectionStatus.unknown:
        return 'Sprawdzanie połączenia...';
    }
  }

  @override
  List<Object?> get props => [status, lastOnlineTime, isRetrying, errorMessage];
}

// Connectivity Cubit
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<ConnectionStatus>? _connectivitySubscription;

  ConnectivityCubit({ConnectivityService? connectivityService})
      : _connectivityService = connectivityService ?? ConnectivityService(),
        super(ConnectivityState.initial());

  Future<void> initialize() async {
    try {
      await _connectivityService.initialize();
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivityService.connectionStatusStream.listen(
        _onConnectivityChanged,
        onError: (error) {
          emit(state.copyWith(
            status: ConnectionStatus.offline,
            errorMessage: 'Błąd połączenia: $error',
          ));
        },
      );

      // Check initial status
      final initialStatus = await _connectivityService.checkConnectivity();
      _onConnectivityChanged(initialStatus);
    } catch (error) {
      emit(state.copyWith(
        status: ConnectionStatus.offline,
        errorMessage: 'Nie można zainicjalizować monitorowania połączenia',
      ));
    }
  }

  void _onConnectivityChanged(ConnectionStatus status) {
    final DateTime now = DateTime.now();
    
    emit(state.copyWith(
      status: status,
      lastOnlineTime: status == ConnectionStatus.online ? now : state.lastOnlineTime,
      isRetrying: false,
      errorMessage: null,
    ));
  }

  Future<void> checkConnection() async {
    if (state.isRetrying) return;

    emit(state.copyWith(isRetrying: true));
    
    try {
      final status = await _connectivityService.checkConnectivity();
      _onConnectivityChanged(status);
    } catch (error) {
      emit(state.copyWith(
        isRetrying: false,
        errorMessage: 'Błąd sprawdzania połączenia',
      ));
    }
  }

  Future<void> retryConnection() async {
    if (state.isRetrying) return;

    emit(state.copyWith(isRetrying: true));
    
    try {
      final hasConnection = await _connectivityService.retryConnection();
      if (hasConnection) {
        _onConnectivityChanged(ConnectionStatus.online);
      } else {
        emit(state.copyWith(
          status: ConnectionStatus.offline,
          isRetrying: false,
          errorMessage: 'Nie można nawiązać połączenia',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: ConnectionStatus.offline,
        isRetrying: false,
        errorMessage: 'Błąd podczas ponownego łączenia',
      ));
    }
  }

  String? getTimeSinceLastOnline() {
    if (state.lastOnlineTime == null) return null;
    
    final difference = DateTime.now().difference(state.lastOnlineTime!);
    
    if (difference.inMinutes < 1) {
      return 'przed chwilą';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min temu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} godz. temu';
    } else {
      return '${difference.inDays} dni temu';
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    return super.close();
  }
}