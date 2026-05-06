// Quick API URL Configuration Script
// Run this in your app to set the API URL

import 'package:get_storage/get_storage.dart';

void setApiUrl(String url) {
  final storage = GetStorage();
  storage.write('api_base_url', url);
  print('API URL set to: $url');
  print('Restart the app to apply changes.');
}

// Usage examples:
// setApiUrl('http://10.0.2.2:8000/api'); // Local Android
// setApiUrl('http://localhost:8000/api'); // Local iOS
// setApiUrl('https://staging.yourdomain.com/api'); // Staging