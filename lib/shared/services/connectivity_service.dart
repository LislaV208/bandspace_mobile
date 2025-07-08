import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus {
  online,
  offline,
  unknown,
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamController<ConnectionStatus> _connectionStatusController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  ConnectionStatus _currentStatus = ConnectionStatus.unknown;

  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  ConnectionStatus get currentStatus => _currentStatus;

  bool get isOnline => _currentStatus == ConnectionStatus.online;
  bool get isOffline => _currentStatus == ConnectionStatus.offline;

  Future<void> initialize() async {
    _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
    
    // Check initial connectivity status
    await _updateConnectionStatus(await _connectivity.checkConnectivity());
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        _updateConnectionStatus([ConnectivityResult.none]);
      },
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final bool hasConnection = results.any((result) => 
        result != ConnectivityResult.none);
    
    if (hasConnection) {
      // Double-check with actual network request
      final bool hasInternetAccess = await _hasInternetAccess();
      _currentStatus = hasInternetAccess 
          ? ConnectionStatus.online 
          : ConnectionStatus.offline;
    } else {
      _currentStatus = ConnectionStatus.offline;
    }
    
    _connectionStatusController.add(_currentStatus);
  }

  Future<bool> _hasInternetAccess() async {
    try {
      // Try to resolve a reliable hostname
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<ConnectionStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(results);
    return _currentStatus;
  }

  Future<bool> retryConnection({int maxRetries = 3, Duration delay = const Duration(seconds: 2)}) async {
    for (int i = 0; i < maxRetries; i++) {
      await checkConnectivity();
      if (isOnline) return true;
      
      if (i < maxRetries - 1) {
        await Future.delayed(delay);
      }
    }
    return false;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}