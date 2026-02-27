# 🌱 HOW TO POPULATE FIREBASE CONSOLE

Your Firebase Console is empty because no data has been written yet. 
Follow these steps to upload dummy data and see your collections.

## 1. Enable Firebase in App
Open `lib/main.dart` and **uncomment** the Firebase initialization code:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // UNCOMMENT THESE LINES:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EventifyApp());
}
```

## 2. Enable Firebase Mode
Open `lib/providers/event_provider.dart` and change:

```dart
bool _useFirebase = true; // Set to TRUE
```

## 3. Run the App
Run the app on your emulator or device:
```bash
flutter run
```

## 4. Run the Seeding Tool
1. Navigate to **Profile Tab**.
2. Tap **"Log in as Admin"**.
3. Login with any email/password (since we are in test mode).
4. On the Admin Dashboard, click the **Orange "Seed Database (Dev Only)" Button** in the bottom right.
   - Wait for the "Success" message.

## 5. Check Console
Go to your Firebase Console and refresh the page. You will now see:
- `events` collection
- `users` collection
- `locations` collection

🎉 **Your backend is now populated!**
