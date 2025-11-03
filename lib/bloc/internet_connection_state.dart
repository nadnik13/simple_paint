import 'package:equatable/equatable.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class InternetConnectionState extends Equatable {
  final ConnectionStatus status;
  final String? errorMessage;
  final DateTime lastChecked;
  final bool isVisible;
  final DateTime? connectedAt;

  const InternetConnectionState({
    required this.status,
    this.errorMessage,
    required this.lastChecked,
    this.isVisible = false,
    this.connectedAt,
  });

  factory InternetConnectionState.initial() {
    return InternetConnectionState(
      status: ConnectionStatus.connected,
      lastChecked: DateTime.now(),
      isVisible: false,
    );
  }

  InternetConnectionState connected({bool? isVisible}) {
    final now = DateTime.now();
    return InternetConnectionState(
      status: ConnectionStatus.connected,
      lastChecked: now,
      connectedAt: connectedAt ?? now,
      isVisible: isVisible ?? true,
    );
  }

  InternetConnectionState connecting() {
    return InternetConnectionState(
      status: ConnectionStatus.connecting,
      lastChecked: DateTime.now(),
      isVisible: true,
      connectedAt: connectedAt,
    );
  }

  InternetConnectionState disconnected([String? error]) {
    return InternetConnectionState(
      status: ConnectionStatus.disconnected,
      errorMessage: error,
      lastChecked: DateTime.now(),
      isVisible: true,
      connectedAt: null,
    );
  }

  InternetConnectionState hide() {
    return InternetConnectionState(
      status: status,
      errorMessage: errorMessage,
      lastChecked: lastChecked,
      isVisible: false,
      connectedAt: connectedAt,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;

  bool get isConnecting => status == ConnectionStatus.connecting;

  bool get isDisconnected => status == ConnectionStatus.disconnected;

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    lastChecked,
    isVisible,
    connectedAt,
  ];

  @override
  String toString() {
    return 'InternetConnectionState(status: $status, errorMessage: $errorMessage, lastChecked: $lastChecked)';
  }
}
