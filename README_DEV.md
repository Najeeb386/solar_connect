# Solar Partner App - Development Setup

## 🚨 API Server Issue

The production API server (`https://solarpartner.pk`) is currently **down** (DNS resolution error). The app has been configured to use mock data for development.

## 🔧 Quick Start

1. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Test with mock data:**
   - The app is currently set to use mock API responses
   - All features work with sample data

3. **Switch to real API:**
   - Edit `lib/main.dart`
   - Uncomment and set your local server URL:
   ```dart
   ApiClient().setCustomApiUrl('http://10.0.2.2:8000/api'); // Android
   // OR
   ApiClient().setCustomApiUrl('http://localhost:8000/api'); // iOS/Web
   ```

## 🛠️ Setting Up Local API Server

1. **Install Laravel & PHP:**
   ```bash
   # Install PHP 8.1+, Composer, MySQL
   # Clone your Laravel project
   git clone <your-repo>
   cd <your-project>
   composer install
   php artisan migrate
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **Update Flutter app:**
   - Find your local IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Update `lib/main.dart` with your IP:
   ```dart
   ApiClient().setCustomApiUrl('http://192.168.1.100:8000/api');
   ```

3. **For Android emulator:**
   ```dart
   ApiClient().setCustomApiUrl('http://10.0.2.2:8000/api');
   ```

## 📱 API Configuration (Alternative)

Long-press the Solar Partner logo on the login screen to access API configuration and change the URL dynamically.

## ✅ Features Working

- ✅ User authentication (login/signup)
- ✅ Dashboard with stats
- ✅ Program listings with rewards
- ✅ Wallet balance display
- ✅ Claim history
- ✅ Profile management
- ✅ Navigation between modules

## 🔍 Troubleshooting

### DNS/Network Errors
- Check if your local server is running
- Verify the API URL in `lib/main.dart`
- Use `ping solarpartner.pk` to test connectivity

### Build Issues
- Run `flutter clean && flutter pub get`
- Check Android SDK installation
- Verify keystore configuration

### Hot Reload Issues
- Restart the app completely
- Clear browser cache
- Use `flutter run --debug` instead of hot reload

## 📞 Support

Contact your backend team to fix the production server, or set up a local development environment using the instructions above.