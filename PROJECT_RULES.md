# 📋 PROJECT RULES & GUIDELINES

## 🎯 Core Principles

### 1. **NEVER DO COMPLEX** ⚠️
- Keep code simple and clean
- No over-engineering
- Straightforward solutions only

### 2. **Bilingual Support (English + Japanese)** 🌏
- Every text must have EN + JP versions
- Use language provider to switch
- All UI text, labels, buttons in both languages

### 3. **Theme System (Light + Dark)** 🎨
- **ONLY change colors in `theme.dart`**
- Whole project changes automatically
- No hardcoded colors in individual classes
- Support light and dark modes
- Client can change theme by editing one file only

### 4. **Responsive Design** 📱
- Must work on: Android, iOS
- Must work on: Small screens, Large screens, Tablets
- Use MediaQuery for responsive sizing
- Test on different screen sizes

### 5. **Clean Code** ✨
- Proper naming conventions
- Comments where needed
- Organized imports
- No duplicate code
- Follow Dart best practices

### 6. **Physics Bouncing Scroll** 🎯
- Use BouncingScrollPhysics() everywhere
- Smooth, natural scrolling
- iOS-style bounce effect

### 7. **Dummy Data for Now** 🔧
- **NO Firebase connection yet**
- Use dummy/mock data
- App should work completely offline
- Demo purposes only
- Firebase code ready but not connected

---

## 🎨 UI DESIGN (From Screenshots)

### **Bottom Navigation (3 Tabs)**
```
1. Events Tab (Calendar icon)
2. Tickets Tab (Ticket icon)
3. Profile Tab (Person icon) ← NEW!
```

### **Profile Tab Structure**
```
Profile Screen
├── User Info Section (if logged in)
├── Login with Creator (Button)
│   └── Navigate to Creator Login Screen
├── Login with Admin (Button)
│   └── Navigate to Admin Login Screen
└── Settings/Language Toggle
```

### **Navigation Flow**
```
Bottom Nav → Profile Tab
  ↓
  Tap "Login with Creator"
  ↓
  Creator Login Screen
  ↓
  Creator Dashboard

OR

Bottom Nav → Profile Tab
  ↓
  Tap "Login with Admin"
  ↓
  Admin Login Screen
  ↓
  Admin Dashboard
```

---

## 📱 Screen Structure

### **User Screens (No Login)**
1. **Home Screen** (Events Tab)
   - Top bar: Logo, Location, Language, Notification, Contact
   - Event cards with carousel
   - Latest bookings
   - Calendar

2. **Event Details Screen**
   - Vertical images
   - Event info
   - Reserve button

3. **My Tickets Screen** (Tickets Tab)
   - Ticket cards
   - Cancel/Share buttons

4. **Profile Screen** (Profile Tab) ← NEW!
   - Login with Creator button
   - Login with Admin button
   - Language toggle
   - Theme toggle (optional)

### **Creator Screens (Login Required)**
1. **Creator Login Screen**
2. **Creator Dashboard**
3. **Create Event Screen**
4. **Event Stats Screen**

### **Admin Screens (Login Required)**
1. **Admin Login Screen**
2. **Admin Dashboard**
3. **Manage Events Screen**
4. **Manage Creators Screen**
5. **Manage Locations Screen**

---

## 🎨 Theme Requirements

### **theme.dart Structure**
```dart
class AppTheme {
  // Colors - ONLY place to define colors
  static const primaryColor = Colors.indigo;
  static const secondaryColor = Colors.indigoAccent;
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    // ... all light theme colors
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    // ... all dark theme colors
  );
}
```

### **Usage in Code**
```dart
// ✅ CORRECT - Use theme colors
Container(
  color: Theme.of(context).primaryColor,
)

// ❌ WRONG - No hardcoded colors
Container(
  color: Colors.indigo, // DON'T DO THIS!
)
```

---

## 🌏 Bilingual Requirements

### **Language Provider**
```dart
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en'; // 'en' or 'ja'
  
  String get currentLanguage => _currentLanguage;
  
  void switchLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ja' : 'en';
    notifyListeners();
  }
  
  String getText(String en, String ja) {
    return _currentLanguage == 'en' ? en : ja;
  }
}
```

### **Usage in Code**
```dart
// ✅ CORRECT - Use language provider
Text(
  Provider.of<LanguageProvider>(context).getText(
    'Discover Events', // English
    'イベントを探す',    // Japanese
  ),
)

// Or create a helper
Text(AppText.discoverEvents(context))
```

---

## 📱 Responsive Requirements

### **Use MediaQuery**
```dart
class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isSmallScreen(BuildContext context) => width(context) < 600;
  static bool isMediumScreen(BuildContext context) => width(context) >= 600 && width(context) < 1200;
  static bool isLargeScreen(BuildContext context) => width(context) >= 1200;
}
```

### **Usage**
```dart
// ✅ CORRECT - Responsive sizing
Container(
  width: Responsive.width(context) * 0.9,
  padding: EdgeInsets.all(Responsive.isSmallScreen(context) ? 8 : 16),
)

// ❌ WRONG - Fixed sizes
Container(
  width: 300, // DON'T DO THIS!
)
```

---

## 🎯 Scroll Physics

### **Always Use BouncingScrollPhysics**
```dart
// ✅ CORRECT
ListView(
  physics: BouncingScrollPhysics(),
  children: [...],
)

SingleChildScrollView(
  physics: BouncingScrollPhysics(),
  child: ...,
)

// Set globally in theme
MaterialApp(
  theme: ThemeData(
    platform: TargetPlatform.iOS, // Enables bouncing by default
  ),
)
```

---

## 🔧 Dummy Data Structure

### **No Firebase - Use Local Data**
```dart
// Example: Dummy events
class DummyData {
  static List<Map<String, dynamic>> events = [
    {
      'id': '1',
      'title_en': 'Saturday Night Meetup',
      'title_ja': '土曜日の夜の集まり',
      'description_en': 'Join us for an amazing evening...',
      'description_ja': '素晴らしい夜にご参加ください...',
      'images_en': [
        'https://picsum.photos/400/300?random=1',
        'https://picsum.photos/400/300?random=2',
      ],
      'images_ja': [
        'https://picsum.photos/400/300?random=3',
        'https://picsum.photos/400/300?random=4',
      ],
      'location_en': 'Tokyo',
      'location_ja': '東京',
      'date': '2026-02-28',
      'startTime': '18:10',
      'endTime': '23:00',
      'venueName': 'Shibuya Event Hall',
      'malePrice': 100,
      'femalePrice': 0,
      'maleLimit': 50,
      'femaleLimit': 50,
      'maleBooked': 15,
      'femaleBooked': 20,
    },
    // More dummy events...
  ];
  
  static List<Map<String, dynamic>> tickets = [];
  static List<Map<String, dynamic>> locations = [
    {'name_en': 'All', 'name_ja': 'すべて'},
    {'name_en': 'Tokyo', 'name_ja': '東京'},
    {'name_en': 'Osaka', 'name_ja': '大阪'},
  ];
}
```

---

## ❓ QUESTIONS FOR CLIENT

### 1. **Profile Tab Icon**
What icon should we use for Profile tab?
- Person icon?
- Menu icon?
- Settings icon?

### 2. **Profile Screen Content**
What should show on Profile screen besides login buttons?
- User info (if logged in)?
- Settings?
- Language toggle?
- Theme toggle?
- About app?

### 3. **Theme Toggle**
Should users be able to switch between light/dark mode in the app?
- Yes - Add toggle in Profile screen
- No - Only light mode for now

### 4. **Default Language**
What should be the default language when app opens?
- English
- Japanese
- Device language

### 5. **Color Scheme**
Confirm the color scheme:
- Primary: Indigo (as per screenshots)?
- Any specific color codes?

---

## ✅ UPDATED FOLDER STRUCTURE

```
lib/
├── main.dart
├── app.dart
│
├── config/
│   ├── theme.dart              # ONLY place for colors (light + dark)
│   ├── routes.dart
│   └── constants.dart
│
├── data/                        # NEW - Dummy data
│   └── dummy_data.dart
│
├── models/
│   ├── event.dart
│   ├── ticket.dart
│   ├── user_model.dart
│   └── location.dart
│
├── services/                    # Code ready, not connected
│   ├── firebase_service.dart   # (Not connected)
│   ├── auth_service.dart       # (Dummy auth)
│   ├── event_service.dart      # (Use dummy data)
│   ├── ticket_service.dart     # (Use dummy data)
│   └── ...
│
├── providers/
│   ├── auth_provider.dart
│   ├── event_provider.dart
│   ├── language_provider.dart  # EN/JP switch
│   ├── theme_provider.dart     # Light/Dark switch
│   └── location_provider.dart
│
├── screens/
│   ├── user/
│   │   ├── home_screen.dart
│   │   ├── event_details_screen.dart
│   │   ├── my_tickets_screen.dart
│   │   ├── profile_screen.dart  # NEW - Profile tab
│   │   └── booking_dialog.dart
│   │
│   ├── creator/
│   │   ├── creator_login_screen.dart
│   │   ├── creator_dashboard_screen.dart
│   │   ├── create_event_screen.dart
│   │   └── event_stats_screen.dart
│   │
│   └── admin/
│       ├── admin_login_screen.dart
│       ├── admin_dashboard_screen.dart
│       ├── manage_events_screen.dart
│       ├── manage_creators_screen.dart
│       └── manage_locations_screen.dart
│
├── widgets/
│   ├── event_card.dart
│   ├── ticket_card.dart
│   ├── image_carousel.dart
│   ├── bottom_nav.dart         # 3 tabs: Events, Tickets, Profile
│   ├── top_bar.dart
│   ├── event_calendar.dart
│   └── latest_bookings.dart
│
└── utils/
    ├── constants.dart
    ├── helpers.dart
    ├── responsive.dart          # NEW - Responsive helpers
    ├── app_text.dart            # NEW - Bilingual text
    └── validators.dart
```

---

## 🚀 DEVELOPMENT APPROACH

### **Phase 1: Setup (Current)**
1. ✅ Create folder structure
2. ✅ Update pubspec.yaml
3. ⏳ Create theme.dart (light + dark)
4. ⏳ Create language_provider.dart
5. ⏳ Create dummy_data.dart
6. ⏳ Create responsive.dart
7. ⏳ Create app_text.dart

### **Phase 2: Bottom Navigation & Base**
1. Create bottom_nav.dart (3 tabs)
2. Create home_screen.dart (Events tab)
3. Create my_tickets_screen.dart (Tickets tab)
4. Create profile_screen.dart (Profile tab)

### **Phase 3: User Screens**
1. Implement home screen with dummy events
2. Implement event details
3. Implement booking flow
4. Implement tickets display

### **Phase 4: Creator & Admin**
1. Profile screen with login buttons
2. Creator login & dashboard
3. Admin login & dashboard
4. Management screens

---

## 📝 NOTES

- **No Firebase connection** - All dummy data
- **Theme in one place** - Easy to change colors
- **Bilingual everywhere** - EN + JP
- **Responsive** - Works on all screens
- **Clean code** - Simple and maintainable
- **Bouncing scroll** - Smooth UX
- **Profile tab** - Access to Creator/Admin login

---

**Status**: Rules documented ✅  
**Next**: Answer questions & start coding  
**Date**: February 14, 2026
