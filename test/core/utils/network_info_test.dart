import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tech_task/core/utils/network_info.dart';

void main() {
  group('NetworkInfo', () {
    late NetworkInfoImpl networkInfo;

    setUp(() {
      networkInfo = NetworkInfoImpl();
    });

    test('should return true for isConnected', () async {
      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, true);
    });
  });
}

