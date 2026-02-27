# Eventify

A Flutter-based event management application that allows users to discover, create, and manage events.

## Features

- User authentication with Firebase
- Event discovery and browsing
- Event creation and management
- QR code generation for events
- Calendar integration
- Event sharing capabilities
- Real-time updates with Firestore
- Push notifications

## Tech Stack

- Flutter SDK (>=3.6.1)
- Firebase (Auth, Firestore, Storage, Messaging)
- Provider for state management
- Material Design UI

## Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase project configured
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/SIDSHARMA6/Eventify.git
cd Eventify
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add your `google-services.json` to `android/app/`
- Add your `GoogleService-Info.plist` to `ios/Runner/`
- Update `lib/firebase_options.dart` with your Firebase configuration

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── app.dart              # Main app widget
├── main.dart             # Entry point
├── models/               # Data models
├── providers/            # State management
├── screens/              # UI screens
├── services/             # Business logic
└── widgets/              # Reusable components
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and not licensed for public use.
