# Best Evento - Event Management App

A Flutter-based event management application with user, creator, and admin roles. Features include event booking, QR code tickets, FCM notifications, and multi-language support (English/Japanese).

## Features

### User Features
- Browse and filter events by location
- View event details with immersive UI
- Book tickets with QR codes
- Calendar view with event reminders
- Multi-language support (English/Japanese)
- Light/Dark mode
- FCM push notifications

### Creator Features
- Create and manage events
- Upload event images (Cloudinary integration)
- Track ticket sales and bookings
- QR code scanner for check-ins
- Event statistics dashboard

### Admin Features
- Manage creators and events
- View all bookings and tickets
- Manage locations
- System-wide controls

## Tech Stack

- **Framework**: Flutter 3.6+
- **Backend**: Firebase (Auth, Firestore, FCM)
- **Image Hosting**: Cloudinary
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: Firebase Cloud Messaging + flutter_local_notifications

## Setup Instructions

### Prerequisites
- Flutter SDK 3.6 or higher
- Android Studio / VS Code
- Firebase project
- Cloudinary account

### Installation

1. Clone the repository
```bash
git clone <your-repo-url>
cd eventify
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a Firebase project
   - Add Android/iOS apps
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Run `flutterfire configure` to generate `firebase_options.dart`

4. Configure Cloudinary
   - Update `lib/services/cloudinary_service.dart` with your credentials:
     - `_cloudName`
     - `_uploadPreset` (create unsigned preset in Cloudinary dashboard)

5. Run the app
```bash
flutter run
```

## Firebase Setup

### Firestore Collections

1. **users**
   - `email`: string
   - `role`: string (admin/creator/user)
   - `createdAt`: timestamp

2. **events**
   - Event details (title, description, date, time, location, etc.)
   - Pricing and capacity
   - Images (English/Japanese)

3. **reservations**
   - Ticket bookings
   - QR codes
   - Check-in status

4. **locations**
   - Location names (English/Japanese)

5. **fcm_tokens**
   - Device FCM tokens for push notifications

### Firestore Security Rules
See `firestore.rules` for complete security configuration.

### Creating Admin User
1. Go to Firebase Console > Authentication
2. Add user with email/password
3. Go to Firestore > users collection
4. Create document with user UID as ID
5. Set fields:
   - `email`: admin email
   - `role`: "admin"
   - `createdAt`: current timestamp

### Creating Creator User
Same as admin but set `role: "creator"`

## Project Structure

```
lib/
├── config/          # App configuration (theme, routes, constants)
├── providers/       # State management (auth, language, theme)
├── screens/         # UI screens (user, creator, admin)
├── services/        # Business logic (Firebase, notifications, etc.)
├── utils/           # Helper functions and utilities
├── widgets/         # Reusable UI components
├── app.dart         # Main app widget
├── main.dart        # User app entry point
└── main_admin.dart  # Admin app entry point
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Environment Variables

Create example files for sensitive data:
- `android/app/google-services.json.example`
- `ios/Runner/GoogleService-Info.plist.example`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is private and proprietary.

## Support

For issues and questions, please create an issue in the repository.
