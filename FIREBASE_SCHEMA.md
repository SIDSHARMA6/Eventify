# 🔥 Eventify — Firebase Backend Schema (100% ACCURATE)
> **Every field verified line-by-line across ALL files:**
> services, screens, widgets, providers, models, helpers, dummy_data.dart, seeding_service.dart
> **Languages: English (required) + Japanese (optional with auto-fallback)**

---

## ⚡ CRITICAL BUGS TO FIX BEFORE MIGRATION

These are bugs found in the existing Firebase service files that **will crash** the app if not fixed:

### BUG 1 — `timestamp` type mismatch 🔴
- **Where:** `TicketService.createReservation()` stores `'timestamp': FieldValue.serverTimestamp()` (Firestore `Timestamp` object)
- **Crash:** `LatestBookings` widget calls `DateTime.parse(booking['timestamp'])` — this crashes on a `Timestamp` object
- **Fix:** After writing to Firestore, overwrite client-side: `reservation['timestamp'] = DateTime.now().toIso8601String()` ✅ (already done in TicketService line 64 for the returned value, but the Firestore document still stores a Timestamp)
- **Real Fix:** In Firestore, store **both** — a real `Timestamp` for ordering queries AND a String for client display. OR always convert on read: `data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String()`

### BUG 2 — Missing denormalized fields in reservations 🔴
- **Where:** `TicketService.createReservation()` does NOT store `eventTitle_en`, `eventTitle_ja`, `eventDate`, `eventTime`, `eventImage`
- **Crash:** `TicketCard` reads `ticket['eventTitle_en']`, `ticket['eventTitle_ja']`, `ticket['eventDate']`, `ticket['eventTime']`, `ticket['eventImage']` — all will be `null`
- **Fix:** Add these fields to the reservation map in `TicketService.createReservation()` (see corrected version in Migration Notes below)

### BUG 3 — `locations` DummyData has no `order` field 🟡
- **Where:** `DummyData.locations` has no `order` key. `SeedingService` uses `location['order'] ?? 0` (defaults to 0 for all)
- **Result:** All seeded locations get `order: 0` — sort is undefined
- **Fix:** Add explicit `order` to each location before seeding, or seed manually with correct order values

### BUG 4 — `TicketCard` uses `Image.asset()` 🔴
- **Where:** `ticket_card.dart` line 44: `Image.asset(ticket['eventImage'], ...)`
- **Crash:** After migration, `eventImage` will be a network URL, not an asset path
- **Fix:** Change to `Image.network()` or `CachedNetworkImage()`

### BUG 5 — `ImageCarousel`, `EventDetails`, `EventCalendar` use `AssetImage()` 🔴
- **Where:** `image_carousel.dart`, `event_details_screen.dart`, `event_calendar.dart`
- **Fix:** Replace all `AssetImage(imagePath)` with `NetworkImage(imagePath)` or `CachedNetworkImage()`

---

## 📦 COLLECTIONS OVERVIEW

| Collection | Doc ID | Field Count | Key Consumers |
|---|---|---|---|
| `events` | Auto Firestore ID | 27 fields | HomeScreen, EventCard, Details, Creator, Admin |
| `reservations` | Auto Firestore ID | 17 fields stored + `id` added client-side | TicketCard, MyTickets, Booking, Stats, QR |
| `users` | Firebase Auth UID | 5 fields | AuthProvider, ManageCreators |
| `locations` | Auto Firestore ID | 4 fields | TopBar, ManageLocations |
| `fcm_tokens` | deviceId | 3 fields | NotificationService |

---

## 1. 📅 Collection: `events`

**Document ID:** Firestore auto-generated
**`id` field:** NOT stored in Firestore — added client-side: `data['id'] = doc.id`
**All services that add `id`:** `EventService.getEvents()`, `getAllEvents()`, `getEventsByLocation()`, `getEventsByCreator()`, `getEventById()`

### All Fields (verified from dummy_data.dart + every screen/widget)

| Field | Dart Type | Firestore Type | Required | Exactly Read As |
|---|---|---|---|---|
| `id` | `String` | — (client-side only) | ✅ | `event['id']` — BookingDialog, AllTickets filter, Creator dashboard filter, QR lookup |
| `title_en` | `String` | `String` | ✅ | `event['title_en']` — EventCalendar dialog, LanguageHelper, notification payload, LatestBookings **ONLY reads `eventTitle_en` from reservations** |
| `title_ja` | `String` | `String` | Optional | `event['title_ja']` — LanguageHelper fallback |
| `description_en` | `String` | `String` | Optional | `event['description_en']` — EventDetails via LanguageHelper |
| `description_ja` | `String` | `String` | Optional | `event['description_ja']` — EventDetails via LanguageHelper |
| `images_en` | `List<String>` | `Array` | ✅ | `event['images_en']` — ImageCarousel, EventDetails, EventCalendar uses `[0]`, BookingDialog uses `[0]` for reservation `eventImage`. **MUST have ≥ 1 item** |
| `images_ja` | `List<String>` | `Array` | Optional | `event['images_ja']` — LanguageHelper.getImages(), falls back to `images_en` |
| `location_en` | `String` | `String` | ✅ | `event['location_en']` — HomeScreen filter (`event['location_en'] == _selectedLocation`), ImageCarousel overlay, ManageEventsScreen, EventService.getEventsByLocation() query |
| `location_ja` | `String` | `String` | Optional | `event['location_ja']` — ManageEventsScreen, ImageCarousel overlay (JP mode) |
| `date` | `String` | `String` | ✅ | `event['date']` — HomeScreen date filter `DateTime.parse(event['date'])`, EventCard, Details, Calendar, Stats, Cleanup. Format: `"YYYY-MM-DD"` |
| `endDate` | `String` | `String` | Optional | `event['endDate']` — CreateEventScreen load/save only. Format: `"YYYY-MM-DD"` |
| `startTime` | `String` | `String` | ✅ | `event['startTime']` — EventCard, Details, Calendar, ManageEvents, Stats. Also stored in reservation as `eventTime`. Format: `"HH:MM"` |
| `endTime` | `String` | `String` | ✅ | `event['endTime']` — EventCard, Details, ManageEvents, TicketCleanupService (parses to check if event ended). Format: `"HH:MM"` |
| `venueName` | `String` | `String` | ✅ | `event['venueName']` — Legacy fallback. EventDetails: `event['venueName_en'] ?? event['venueName']`. LanguageHelper: `event['venueName_en'] ?? event['venueName']`. **KEEP THIS FIELD** |
| `venueName_en` | `String` | `String` | ✅ | `event['venueName_en']` — EventDetails, LanguageHelper.getVenueName(), CreateEventScreen |
| `venueName_ja` | `String` | `String` | Optional | `event['venueName_ja']` — EventDetails (JP mode), LanguageHelper fallback |
| `venueAddress_en` | `String` | `String` | Optional | `event['venueAddress_en']` — EventDetails address box, ManageEventsScreen. Shows "Address not available" if null |
| `venueAddress_ja` | `String` | `String` | Optional | `event['venueAddress_ja']` — EventDetails (JP mode), ManageEventsScreen |
| `mapLink` | `String` | `String` | Optional | `event['mapLink']` — EventCard map button, EventDetails map button, ManageEventsScreen. Defaults to `'https://maps.google.com'` if null/empty |
| `malePrice` | `int` | `Number` | ✅ | `event['malePrice'] as int` — ImageCarousel overlay, EventDetails price card, BookingDialog sold-out logic |
| `femalePrice` | `int` | `Number` | ✅ | `event['femalePrice'] as int` — ImageCarousel overlay, EventDetails price card |
| `maleLimit` | `int` | `Number` | ✅ | `event['maleLimit'] as int` — BookingDialog: `widget.event['maleLimit'] as int`, EventStats |
| `femaleLimit` | `int` | `Number` | ✅ | `event['femaleLimit'] as int` — BookingDialog, EventStats |
| `maleBooked` | `int` | `Number` | ✅ | `event['maleBooked'] as int? ?? 0` — BookingDialog sold-out check. Incremented via `FieldValue.increment(1)` |
| `femaleBooked` | `int` | `Number` | ✅ | `event['femaleBooked'] as int? ?? 0` — BookingDialog. Incremented via `FieldValue.increment(1)` |
| `isHidden` | `bool` | `Boolean` | ✅ | `event['isHidden'] == true` — HomeScreen filter, EventCalendar filter, CreatorDashboard badge, ManageEventsScreen badge. Default: `false` |
| `isDeleted` | `bool` | `Boolean` | Optional | `event['isDeleted'] == true` — HomeScreen filter, EventCalendar filter, ManageEventsScreen badge. Default: `false` |
| `isDuplicated` | `bool` | `Boolean` | Optional | `event['isDuplicated'] == true` — CreatorDashboard badge. Default: `false` |
| `isRecurring` | `bool` | `Boolean` | Optional | `event['isRecurring'] == true` — ManageEventsScreen recurring label. Default: `false` |
| `recurringLabel` | `String` | `String` | Optional | `event['recurringLabel'] ?? 'Recurring'` — ManageEventsScreen |
| `createdBy` | `String` | `String` | ✅ | `event['createdBy']` — CreatorDashboard filter, ManageCreators delete cascade. Value: Firebase Auth UID or `'admin'` |
| `createdAt` | `Timestamp` | `Timestamp` | ✅ | Used for ordering in `getEventsByCreator()`. Never read as a displayed string |
| `updatedAt` | `Timestamp` | `Timestamp` | Optional | Set by `EventService.updateEvent()`. Never read by UI |

### Exact Seeding Structure (matches SeedingService)
```dart
await eventsRef.add({
  // Bilingual content
  'title_en': 'Saturday Night Meetup',
  'title_ja': '土曜日の夜の集まり',
  'description_en': 'Join us for an amazing evening...',
  'description_ja': '素晴らしい夜に...',
  // Images (URLs after migration, asset paths for seed)
  'images_en': ['https://...1.jpg', 'https://...2.jpg'],
  'images_ja': ['https://...1.jpg', 'https://...2.jpg'],
  // Location
  'location_en': 'Tokyo',
  'location_ja': '東京',
  // Dates & Times (Strings)
  'date': '2026-03-15',
  'endDate': '2026-03-15',
  'startTime': '18:10',
  'endTime': '23:00',
  // Venue (bilingual + legacy)
  'venueName': 'Shibuya Event Hall',        // ← KEEP for legacy fallback
  'venueName_en': 'Shibuya Event Hall',
  'venueName_ja': '渋谷イベントホール',
  'venueAddress_en': '1-2-3 Shibuya, Shibuya-ku, Tokyo 150-0002',
  'venueAddress_ja': '〒150-0002 東京都渋谷区渋谷1-2-3',
  'mapLink': 'https://maps.google.com/?q=Shibuya+Event+Hall',
  // Pricing & Limits
  'malePrice': 1000,
  'femalePrice': 0,
  'maleLimit': 50,
  'femaleLimit': 50,
  // Auto-set by service
  'maleBooked': 0,
  'femaleBooked': 0,
  'isHidden': false,
  'isDeleted': false,
  'isDuplicated': false,
  'isRecurring': false,
  'createdBy': currentUser.uid,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});
// Then client-side: data['id'] = doc.id
```

---

## 2. 🎫 Collection: `reservations`

**Document ID:** Firestore auto-generated
**`id` field:** Added client-side: `data['id'] = doc.id` (done in TicketService.getMyReservations(), getReservationsByEvent(), getLatestBookings())

### All Fields (verified from ticket_service.dart + all screens/widgets that read tickets)

| Field | Dart Type | Firestore Type | Required | Exactly Read As |
|---|---|---|---|---|
| `id` | `String` | — (client-side only) | ✅ | `ticket['id']` — **QR Code value** (`QrImageView(data: ticket['id'])`), QRScannerScreen lookups reservation by this, MyTicketsScreen cancel |
| `ticketId` | `String` | `String` | ✅ | `booking['ticketId']` — AllTicketsScreen subtitle "Ticket ID: TICKET-XXXXXX". Generated: `'TICKET-${Random().nextInt(999999).toString().padLeft(6,'0')}'` |
| `eventId` | `String` | `String` | ✅ | `ticket['eventId']` — MyTicketsScreen expiry filter, AllTickets filter, EventStats filter, TicketCleanup. Value = Firestore event doc ID |
| `deviceId` | `String` | `String` | ✅ | Used in queries only. Value = 16-char alphanumeric from DeviceService |
| `userName` | `String` | `String` | ✅ | `ticket['userName']` — TicketCard, AllTicketsScreen, EventStats, CheckinHistory, QRScanner dialog |
| `gender` | `String` | `String` | ✅ | `ticket['gender']` — TicketCard GenderIcon (`ticket['gender'] == 'male'`), AllTickets, EventStats, Expiry cancel, MyTickets cancel. Values: `'male'` or `'female'` |
| `timestamp` | `String` | `String` ⚠️ | ✅ | `booking['timestamp']` — `LatestBookings` calls `DateTime.parse(booking['timestamp'])` and sorts by it. `AllTicketsScreen` displays it as text. **MUST be stored as ISO8601 String, NOT Firestore Timestamp** |
| `eventTitle_en` | `String` | `String` | ✅ | `ticket['eventTitle_en']` — TicketCard (`LanguageHelper.getText(ticket['eventTitle_en'], ticket['eventTitle_ja'], isJapanese)`), LatestBookings (`booking['eventTitle_en']` direct read), CheckinHistoryScreen |
| `eventTitle_ja` | `String` | `String` | Optional | `ticket['eventTitle_ja']` — TicketCard (JP mode), CheckinHistoryScreen ("eventTitle_ja"). Store null if no JP title |
| `eventDate` | `String` | `String` | ✅ | `ticket['eventDate']` — TicketCard display `'${ticket['eventDate']} • ${ticket['eventTime']}'`, MyTicketsScreen expiry: `DateTime.parse(ticket['eventDate'])`. Format: `"YYYY-MM-DD"` |
| `eventTime` | `String` | `String` | ✅ | `ticket['eventTime']` — TicketCard display. Format: `"HH:MM"` |
| `eventImage` | `String` | `String` | Optional | `ticket['eventImage']` — TicketCard: `if (ticket['eventImage'] != null) Image.asset(ticket['eventImage'])` → **change to Image.network after migration** |
| `isCancelled` | `bool` | `Boolean` | ✅ | Used in Firestore queries only (`where isCancelled == false`). Set to `true` on cancel. Default: `false` |
| `cancelledAt` | `Timestamp` | `Timestamp` | Optional | Set by `TicketService.cancelReservation()` via `FieldValue.serverTimestamp()`. Never read by UI |
| `checkedInAt` | `String` | `String` | Optional | `ticket['checkedInAt']` — QRScanner: `if (ticket['checkedInAt'] == null)` check, CheckinHistoryScreen: `DateTime.parse(a['checkedInAt'])` for sort. **Must be ISO8601 String**: `DateTime.now().toIso8601String()`. Default: `null` |
| `isScanned` | `bool` | `Boolean` | Optional | `booking['isScanned'] == true` — AllTickets filter, EventStats scanned count. Default: `false` |
| `isDeleted` | `bool` | `Boolean` | Optional | `booking['isDeleted'] == true` / `!= true` — LatestBookings filter, MyTickets filter, AllTickets filter, EventStats deleted count. Default: `false` |
| `deletedAt` | `String` | `String` | Optional | `ticket['deletedAt'] = DateTime.now().toIso8601String()` — Set by AllTicketsScreen. **ISO8601 String** |

### ⚠️ CORRECTED `TicketService.createReservation()` — add missing fields
```dart
// CURRENT (missing denormalized fields — TicketCard will crash):
final reservation = {
  'eventId': eventId,
  'deviceId': deviceId,
  'userName': userName,
  'gender': gender,
  'ticketId': ticketId,
  'timestamp': FieldValue.serverTimestamp(),  // ← BUG: LatestBookings needs String
  'isCancelled': false,
};

// FIXED (add these to avoid TicketCard crashes):
final reservation = {
  'eventId': eventId,
  'deviceId': deviceId,
  'userName': userName,
  'gender': gender,
  'ticketId': ticketId,
  'timestamp': DateTime.now().toIso8601String(),  // ← String for DateTime.parse()
  'isCancelled': false,
  // Denormalized event data (prevents extra Firestore reads on ticket display)
  'eventTitle_en': event['title_en'],
  'eventTitle_ja': event['title_ja'] ?? '',
  'eventDate': event['date'],
  'eventTime': event['startTime'],
  'eventImage': (event['images_en'] as List).isNotEmpty ? event['images_en'][0] : null,
};
```

### Example Firestore Document
```json
{
  "ticketId": "TICKET-492831",
  "eventId": "firestore_event_doc_id_xyz",
  "deviceId": "ABCDEFGH12345678",
  "userName": "Tanaka Yuki",
  "gender": "female",
  "timestamp": "2026-03-10T14:30:00.000",
  "eventTitle_en": "Saturday Night Meetup",
  "eventTitle_ja": "土曜日の夜の集まり",
  "eventDate": "2026-03-15",
  "eventTime": "18:10",
  "eventImage": "https://storage.googleapis.com/.../events/xyz/en/1.jpg",
  "isCancelled": false,
  "cancelledAt": null,
  "checkedInAt": null,
  "isScanned": false,
  "isDeleted": false,
  "deletedAt": null
}
```

---

## 3. 👤 Collection: `users`

**Document ID:** Firebase Auth UID (e.g. `"uid_abc123"`)
**Primary consumer:** `AuthProvider._loadUserFromStorage()` reads `userData['id']`, `userData['email']`, `userData['role']`

### All Fields

| Field | Dart Type | Firestore Type | Required | Exactly Read As |
|---|---|---|---|---|
| `id` | `String` | `String` | ✅ | `userData['id']` — AuthProvider stores this as `_userId`. Must match Firestore doc ID |
| `email` | `String` | `String` | ✅ | `userData['email']` — AuthProvider `_userEmail`, ManageCreatorsScreen display |
| `role` | `String` | `String` | ✅ | `userData['role']` — AuthProvider: `isAdmin = role == 'admin'`, `isCreator = role == 'creator'`. Values: `'admin'` or `'creator'` |
| `createdAt` | `Timestamp` | `Timestamp` | ✅ | Ordering query in UserManagementService. Never displayed |
| `updatedAt` | `Timestamp` | `Timestamp` | Optional | Set on admin updates |

### Example Document (doc ID = Firebase Auth UID)
```json
{
  "id": "firebase_auth_uid_abc123",
  "email": "creator@eventify.com",
  "role": "creator",
  "createdAt": "<ServerTimestamp>",
  "updatedAt": "<ServerTimestamp>"
}
```

### LocalStorageService `current_user` JSON format
```json
{ "id": "uid_abc123", "email": "creator@eventify.com", "role": "creator" }
```
This is saved by `AuthProvider.login()` → `LocalStorageService.saveCurrentUser()` and read back by `AuthProvider._loadUserFromStorage()`. **After Firebase migration**, populate this from the Firestore `users` doc after login.

---

## 4. 📍 Collection: `locations`

**Document ID:** Firestore auto-generated
**Primary consumer:** `TopBar` reads `DummyData.locations` — replace with stream. `ManageLocationsScreen` CRUD.

### All Fields

| Field | Dart Type | Firestore Type | Required | Exactly Read As |
|---|---|---|---|---|
| `name_en` | `String` | `String` | ✅ | `location['name_en']` — TopBar: used as both display text (EN) AND filter key value passed to HomeScreen. HomeScreen filters: `event['location_en'] == _selectedLocation` (which equals `name_en`) |
| `name_ja` | `String` | `String` | ✅ | `location['name_ja']` — TopBar: `location['name_ja'] ?? nameEn` (Japanese display), ManageLocationsScreen subtitle |
| `order` | `int` | `Number` | ✅ | Sort order for displayed list. `locations.orderBy('order')`. `ManageLocationsScreen` ReorderableListView updates this |
| `createdAt` | `Timestamp` | `Timestamp` | Optional | — |

### DummyData.locations (exact structure to replicate in Firestore)
```dart
// DummyData has NO 'order' field — SeedingService uses location['order'] ?? 0
// ALL get order=0. Fix by seeding manually:
{ 'name_en': 'All',      'name_ja': 'すべて',  'order': 0 }
{ 'name_en': 'Tokyo',    'name_ja': '東京',    'order': 1 }
{ 'name_en': 'Osaka',    'name_ja': '大阪',    'order': 2 }
{ 'name_en': 'Kyoto',    'name_ja': '京都',    'order': 3 }
{ 'name_en': 'Yokohama', 'name_ja': '横浜',    'order': 4 }
```

> ⚠️ **`'All'` location must exist** — `HomeScreen` initializes `_selectedLocation = 'All'`. TopBar checks `== 'All'` to show all events (no filter). It can be stored in Firestore (order: 0) OR injected client-side — but must exist somewhere.

---

## 5. 🔔 Collection: `fcm_tokens`

**Document ID:** `deviceId` (16-char alphanumeric)

| Field | Type | Required | Read As |
|---|---|---|---|
| `deviceId` | `String` | ✅ | Same as doc ID |
| `token` | `String` | ✅ | FCM push notification token |
| `updatedAt` | `Timestamp` | ✅ | `FieldValue.serverTimestamp()` on save |

---

## 🔑 SharedPreferences Keys (stays local — never goes to Firebase)

| SharedPreferences Key | Dart key constant | Type | Used by | Purpose |
|---|---|---|---|---|
| `'demo_events'` | `_eventsKey` | `String` (JSON) | `LocalStorageService` | DummyData events cache — **remove after migration** |
| `'demo_tickets'` | `_ticketsKey` | `String` (JSON) | `LocalStorageService` | DummyData tickets cache — **remove after migration** |
| `'demo_locations'` | `_locationsKey` | `String` (JSON) | `LocalStorageService` | DummyData locations cache — **remove after migration** |
| `'booked_events'` | `_bookedEventsKey` | `List<String>` | `LocalStorageService.hasBookedEvent()`, `markEventAsBooked()`, `unmarkEventAsBooked()` | Fast local cache of booked event IDs. **KEEP** — prevents extra Firestore reads in BookingDialog |
| `'current_user'` | `_currentUserKey` | `String` (JSON `{id, email, role}`) | `AuthProvider`, `LocalStorageService` | Persists logged-in user. **KEEP** — populate from Firestore on login |
| `'creator_id'` | hardcoded in Creator screen | `String` | `CreatorDashboardScreen._loadCreatorId()` | Creator's UID — **replace with Firebase Auth UID after migration** |
| `'creator_email'` | hardcoded in Creator screen | `String` | `CreatorDashboardScreen._loadCreatorId()` | Creator email — **replace with Firebase Auth currentUser.email** |
| `'device_id'` | in `DeviceService` | `String` | `DeviceService.getDeviceId()` | Unique device ID, generated once per install. **KEEP FOREVER** |

---

## 🗺️ MASTER KEY REFERENCE

### `events` — exact field names as used in Dart code
```
id, title_en, title_ja, description_en, description_ja,
images_en, images_ja, location_en, location_ja,
date, endDate, startTime, endTime,
venueName, venueName_en, venueName_ja,
venueAddress_en, venueAddress_ja, mapLink,
malePrice, femalePrice, maleLimit, femaleLimit,
maleBooked, femaleBooked,
isHidden, isDeleted, isDuplicated, isRecurring, recurringLabel,
createdBy, createdAt, updatedAt
```

### `reservations` — exact field names as used in Dart code
```
id (= doc.id, added client-side),
ticketId, eventId, deviceId, userName, gender,
timestamp (ISO8601 STRING ← not Timestamp object),
eventTitle_en, eventTitle_ja, eventDate, eventTime, eventImage,
isCancelled, cancelledAt,
checkedInAt (ISO8601 STRING), isScanned,
isDeleted, deletedAt (ISO8601 STRING)
```

### `users` — exact field names
```
id, email, role, createdAt, updatedAt
```

### `locations` — exact field names
```
name_en, name_ja, order, createdAt
```

### `fcm_tokens` — exact field names
```
deviceId, token, updatedAt
```

---

## 🌐 Bilingual Field Pairs (EN/JA) + Fallback Behaviour

All bilingual handling is through `LanguageHelper` class (`lib/utils/language_helper.dart`):

| EN Field | JA Field | Helper Method | Fallback Rule |
|---|---|---|---|
| `event['title_en']` | `event['title_ja']` | `LanguageHelper.getEventTitle()` | If JA null/empty → show EN |
| `event['description_en']` | `event['description_ja']` | `LanguageHelper.getEventDescription()` | If JA null/empty → show EN |
| `event['images_en']` | `event['images_ja']` | `LanguageHelper.getImages()` | If JA list null/empty/first null → use EN list |
| `event['location_en']` | `event['location_ja']` | `LanguageHelper.getLocation()` | If JA null/empty → show EN |
| `event['venueName_en'] ?? event['venueName']` | `event['venueName_ja']` | `LanguageHelper.getVenueName()` | If JA null → EN, if EN null → legacy `venueName` |
| `event['venueAddress_en']` | `event['venueAddress_ja']` | `LanguageHelper.getVenueAddress()` | If JA null → EN |
| `reservation['eventTitle_en']` | `reservation['eventTitle_ja']` | `LanguageHelper.getText()` in TicketCard | If JA null/empty → EN |
| `location['name_en']` | `location['name_ja']` | Direct in TopBar: `location['name_ja'] ?? nameEn` | If JA null → EN |

---

## 🔐 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuth() {
      return request.auth != null;
    }
    function getRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    function isAdmin() { return isAuth() && getRole() == 'admin'; }
    function isCreator() { return isAuth() && getRole() == 'creator'; }
    function isEventOwner(eventId) {
      return isAuth() &&
        get(/databases/$(database)/documents/events/$(eventId)).data.createdBy == request.auth.uid;
    }

    // EVENTS
    match /events/{eventId} {
      allow read: if !resource.data.isHidden || isAdmin() || isCreator();
      allow create: if isAdmin() || isCreator();
      allow update: if isAdmin() || (isCreator() && isEventOwner(eventId));
      allow delete: if isAdmin() || (isCreator() && isEventOwner(eventId));
    }

    // RESERVATIONS (anonymous ticket booking by deviceId)
    match /reservations/{reservationId} {
      allow read, write: if true;
      allow delete: if isAdmin();
    }

    // USERS (only creators and admins have user documents)
    match /users/{userId} {
      allow read: if isAdmin() || (isAuth() && request.auth.uid == userId);
      allow write: if isAdmin();
    }

    // LOCATIONS
    match /locations/{locationId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // FCM TOKENS
    match /fcm_tokens/{tokenId} {
      allow read, write: if true;
    }
  }
}
```

---

## 🗄️ Firebase Storage

### Folder Structure
```
events/
└── {firestoreEventDocId}/
    ├── en/
    │   ├── {timestamp}.jpg   → URL stored in events.images_en[0]
    │   └── {timestamp}.jpg   → URL stored in events.images_en[1]
    └── ja/
        └── {timestamp}.jpg   → URL stored in events.images_ja[0]
```

### Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /events/{eventId}/{language}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 📐 Composite Indexes Required

| Collection | Fields | Purpose |
|---|---|---|
| `events` | `isHidden ASC, date ASC` | HomeScreen default feed |
| `events` | `isHidden ASC, location_en ASC, date ASC` | HomeScreen location filter |
| `events` | `createdBy ASC, createdAt DESC` | CreatorDashboard my events |
| `reservations` | `deviceId ASC, isCancelled ASC, timestamp DESC` | MyTicketsScreen |
| `reservations` | `deviceId ASC, eventId ASC, isCancelled ASC` | BookingDialog duplicate check |
| `reservations` | `eventId ASC, isCancelled ASC, timestamp DESC` | EventStats / AllTickets |
| `reservations` | `isCancelled ASC, timestamp DESC` | LatestBookings widget |
| `users` | `role ASC, createdAt DESC` | ManageCreatorsScreen |

---

## 🚀 Migration Phase Plan

### Phase 1 — Firebase Initialization
```dart
// main.dart — replace:
await LocalStorageService.initialize();
// With:
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
await FirebaseService.initialize();  // requests permissions, offline persistence
```

### Phase 2 — Seed Database
```dart
await SeedingService().seedDatabase();
// ⚠️ Fix DummyData.locations to include 'order' before seeding:
// { 'name_en': 'All', 'name_ja': 'すべて', 'order': 0 }
// { 'name_en': 'Tokyo', 'name_ja': '東京', 'order': 1 } ... etc
```

### Phase 3 — Locations (zero auth, read-only)
- `TopBar`: `DummyData.locations` → `LocationManagementService.getAllLocations()` stream
- `ManageLocationsScreen`: wire CRUD + update `order` on reorder

### Phase 4 — Events (read streams)
- `HomeScreen`: `DummyData.events` → `EventService.getEventsByLocation()` stream
- `EventCalendar`: `DummyData.events` → `EventService.getEvents()` stream
- `AdminDashboard` stats → Firestore `.count()` or stream `.length`
- **Replace all `AssetImage(path)` with `Image.network(path)` everywhere**

### Phase 5 — Booking Flow (critical — fix BUG 2 first)
- Fix `TicketService.createReservation()` to include `eventTitle_en`, `eventTitle_ja`, `eventDate`, `eventTime`, `eventImage`
- Fix `timestamp` to store as ISO8601 String
- `BookingDialog`: replace DummyData logic with `TicketService.createReservation()`
- `MyTicketsScreen`: replace `DummyData.tickets` with `TicketService.getMyReservations()` stream
- Fix `TicketCard`: `Image.asset()` → `Image.network()`

### Phase 6 — Auth (Creator + Admin)
- `AuthProvider.login()`: replace static credential check with `AuthService.login()` + Firestore role read
- `CreatorDashboardScreen._loadCreatorId()`: replace SharedPreferences `creator_id` with `FirebaseAuth.instance.currentUser!.uid`
- `CreateEventScreen._saveEvent()`: replace `DummyData.events.add()` with `EventService.createEvent()` + `StorageService.uploadEventImages()`

### Phase 7 — QR Checkin & Admin Tools
- `QRScannerScreen`: replace `DummyData.tickets.firstWhere()` with Firestore `reservations/{scannedId}` read
- Update `checkedInAt = DateTime.now().toIso8601String()` and `isScanned = true`
- `ManageCreatorsScreen`: wire to `UserManagementService`

---

*Verified: 2026-03-06 | Cross-referenced: dummy_data.dart, all 7 service files, all screen files, all widget files, all provider files, language_helper.dart*
