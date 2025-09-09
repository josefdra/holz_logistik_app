void main() {
  // Example API key - replace with your actual format
  final apiKey = 'db1-abc123-def456-ghi789';
  
  final parts = apiKey.split('-');
  final dbName = parts.first; // "db1"
  final key = parts.skip(1).join('-'); // "abc123-def456-ghi789"
  
  print('Original API Key: $apiKey');
  print('Database Name: $dbName');
  print('Key Part: $key');
  print('All Parts: $parts');
  
  // Test with different formats
  print('\n--- Testing different formats ---');
  
  final testKeys = [
    'production-key123-secret456',
    'dev-simple-key',
    'staging-a-b-c-d-e',
    'single'
  ];
  
  for (final testKey in testKeys) {
    final testParts = testKey.split('-');
    final testDbName = testParts.first;
    final testKeyPart = testParts.skip(1).join('-');
    
    print('\nAPI Key: $testKey');
    print('DB Name: $testDbName');
    print('Key: $testKeyPart');
  }
}