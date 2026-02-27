# 📱 Eventify - Complete Implementation Guide
## Bilingual Event Booking App (Flutter + Firebase)

---

# 1. SYSTEM ARCHITECTURE OVERVIEW

## Technology Stack
- **Frontend**: Flutter (Android & iOS)
- **Backend**: Firebase Firestore, Firebase Storage, Firebase Authentication, Firebase Cloud Messaging
- **Local Storage**: SharedPreferences (device tracking & reminders)
- **State Management**: Provider + ChangeNotifier
- **Localization**: flutter_localizations + intl

## Architecture Pattern
- **MVVM (Model-View-ViewModel)** with Provider
- **Repository Pattern** for data layer
- **Service Layer** for business logic

## Core Modules
1. Authentication Module (Admin & Creator only)
2. Event Management Module
3. Ticket Booking Module
4. Notification Module
5. Localization Module
6. Analytics Module

---

# 2. FLUTTER FOLDER STRUCTURE

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── theme.dart
│   ├── routes.dart
│   └── constants.dart
├── core/
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   └── device_service.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── enums/
│       ├── user_role.dart
│       └── gender.dart
├── data/
│   ├── models/
│   │   ├── event_model.dart
│   │   ├── ticket_model.dart
│   │   ├── user_model.dart
│   │   ├── location_model.dart
│   │   └── booking_model.dart
│   └── repositories/
│       ├── event_repository.dart
│       ├── ticket_repository.dart
│       ├── user_repository.dart
│       └── location_repository.dart
├── providers/
│   ├── auth_provider.dart
│   ├── event_provider.dart
│   ├── ticket_provider.dart
│   ├── language_provider.dart
│   └── location_provider.dart
├── presentation/
│   ├── screens/
│   │   ├── user/
│   │   │   ├── home_screen.dart
│   │   │   ├── event_details_screen.dart
│   │   │   ├── my_tickets_screen.dart
│   │   │   └── booking_screen.dart
│   │   ├── creator/
│   │   │   ├── creator_login_screen.dart
│   │   │   ├── creator_dashboard_screen.dart
│   │   │   ├── create_event_screen.dart
│   │   │   └── event_stats_screen.dart
│   │   └── admin/
│   │       ├── admin_login_screen.dart
│   │       ├── admin_dashboard_screen.dart
│   │       ├── manage_events_screen.dart
│   │       ├── manage_creators_screen.dart
│   │       └── analytics_screen.dart
│   ├── widgets/
│   │   ├── event_card.dart
│   │   ├── image_carousel.dart
│   │   ├── ticket_card.dart
│   │   ├── event_calendar.dart
│   │   ├── latest_bookings.dart
│   │   ├── location_dropdown.dart
│   │   └── language_toggle.dart
│   └── dialogs/
│       ├── booking_dialog.dart
│       └── confirmation_dialog.dart
└── l10n/
    ├── app_en.arb
    └── app_ja.arb
```

---

# 3. FIRESTORE DATABASE SCHEMA

## Collection: `events`
```json
{
  "id": "auto-generated",
  "title_en": "string",
  "title_ja": "string",
  "description_en": "string",
  "description_ja": "string",
  "images_en": ["url1", "url2", ...],
  "images_ja": ["url1", "url2", ...],
  "location_en": "string",
  "location_ja": "string",
  "date": "timestamp",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "venueName": "string",
  "mapLink": "string",
  "malePrice": "number",
  "femalePrice": "number",
  "maleLimit": "number",
  "femaleLimit": "number",
  "maleBooked": "number",
  "femaleBooked": "number",
  "isHidden": "boolean",
  "createdBy": "userId",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Collection: `reservations`
```json
{
  "id": "auto-generated",
  "eventId": "string",
  "deviceId": "string",
  "userName": "string",
  "gender": "male|female",
  "timestamp": "timestamp",
  "ticketId": "string",
  "isCancelled": "boolean"
}
```

## Collection: `users`
```json
{
  "id": "uid from Firebase Auth",
  "email": "string",
  "role": "admin|creator",
  "createdAt": "timestamp"
}
```

## Collection: `locations`
```json
{
  "id": "auto-generated",
  "name_en": "string",
  "name_ja": "string",
  "order": "number"
}
```

## Collection: `fcm_tokens`
```json
{
  "deviceId": "string",
  "token": "string",
  "updatedAt": "timestamp"
}
```

---
# 4. FIREBASE SECURITY RULES

## Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isCreator() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'creator';
    }
    
    function isEventOwner(eventId) {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/events/$(eventId)).data.createdBy == request.auth.uid;
    }
    
    // Events collection
    match /events/{eventId} {
      // Users can read non-hidden events
      allow read: if !resource.data.isHidden || isAdmin() || isEventOwner(eventId);
      
      // Admin can create/update/delete any event
      allow create, update, delete: if isAdmin();
      
      // Creator can create events
      allow create: if isCreator();
      
      // Creator can update/delete only their own events
      allow update, delete: if isCreator() && isEventOwner(eventId);
    }
    
    // Reservations collection
    match /reservations/{reservationId} {
      // Anyone can read their own reservations
      allow read: if true;
      
      // Anyone can create reservation
      allow create: if true;
      
      // Users can cancel their own reservations
      allow update, delete: if resource.data.deviceId == request.resource.data.deviceId;
      
      // Admin can manage all reservations
      allow read, write: if isAdmin();
    }
    
    // Users collection
    match /users/{userId} {
      // Only admin can read/write users
      allow read, write: if isAdmin();
      
      // Users can read their own profile
      allow read: if isAuthenticated() && request.auth.uid == userId;
      
      // Users can update their own password (handled by Firebase Auth)
    }
    
    // Locations collection
    match /locations/{locationId} {
      // Anyone can read locations
      allow read: if true;
      
      // Only admin can write locations
      allow write: if isAdmin();
    }
    
    // FCM tokens collection
    match /fcm_tokens/{tokenId} {
      allow read, write: if true;
    }
  }
}
```

## Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /events/{eventId}/{allPaths=**} {
      // Anyone can read event images
      allow read: if true;
      
      // Only authenticated users (admin/creator) can upload
      allow write: if request.auth != null;
    }
  }
}
```

---

# 5. ROLE-BASED ACCESS LOGIC

## User Role Enum
```dart
enum UserRole {
  user,
  creator,
  admin
}
```

## Auth Service Implementation
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<UserRole?> getUserRole(String uid) async {
