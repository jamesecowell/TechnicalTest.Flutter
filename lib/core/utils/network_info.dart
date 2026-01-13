/// Interface for checking network connectivity
/// This can be implemented using packages like connectivity_plus or internet_connection_checker
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Simple implementation that always returns true
/// In a real app, this would use a package like connectivity_plus
/// For now, we rely on HTTP client error handling for network detection
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For now, we assume connection is available
    // HTTP client will handle actual network errors
    // This can be enhanced later with connectivity_plus package
    return true;
  }
}

