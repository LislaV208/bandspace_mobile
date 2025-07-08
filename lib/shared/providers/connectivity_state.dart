import 'package:equatable/equatable.dart';

/// Stan połączenia z internetem
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

/// Stan gdy połączenie jest dostępne
class ConnectivityConnected extends ConnectivityState {
  const ConnectivityConnected();
}

/// Stan gdy połączenie jest niedostępne
class ConnectivityDisconnected extends ConnectivityState {
  const ConnectivityDisconnected();
}

/// Stan początkowy - nieznany stan połączenia
class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}