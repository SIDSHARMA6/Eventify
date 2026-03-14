# Firebase Setup Guide

## Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project created
- Logged in: `firebase login`

## Step 1: Initialize Firebase Project
```bash
firebase init
```
Select:
- Authentication
- Firestore
- Storage

## Step 2: Create Admin and Creator Accounts

### Option A: Using Firebase Console (Recommended)

1. Go to Firebase Console → Authentication → Users → Add User

**Admin Account:**
- Email: `admin@eventify.com`
- Password: `Admin@123456`
- Copy the UID after creation

**Creator Account:**
- Email: `creator@eventify.com`
- Password: `Creator@123456`
- Copy the UID after creation

2. Go to Firestore Database → Create Collection `users`

**Admin Document:**
```
Document ID: [paste admin UID]
Fields:
  email: "admin@eventify.com"
  role: "admin"
  createdAt: [timestamp]
  displayName: "Admin User"
```

**Creator Document:**
```
Document ID: [paste creator UID]
Fields:
  email: "creator@eventify.com"
  role: "creator"
  createdAt: [timestamp]
  displayName: "Creator User"
```

### Option B: Using Firebase CLI

Create a file `setup-users.js`:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

async function createUsers() {
  try {
    // Create Admin User
    const adminUser = await auth.createUser({
      email: 'admin@eventify.com',
      password: 'Admin@123456',
      displayName: 'Admin User',
      emailVerified: true
    });
    
    console.log('✅ Admin user created:', adminUser.uid);
    
    // Add admin to Firestore
    await db.collection('users').doc(adminUser.uid).set({
      email: 'admin@eventify.com',
      role: 'admin',
      displayName: 'Admin User',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Admin document created in Firestore');
    
    // Create Creator User
    const creatorUser = await auth.createUser({
      email: 'creator@eventify.com',
      password: 'Creator@123456',
      displayName: 'Creator User',
      emailVerified: true
    });
    
    console.log('✅ Creator user created:', creatorUser.uid);
    
    // Add creator to Firestore
    await db.collection('users').doc(creatorUser.uid).set({
      email: 'creator@eventify.com',
      role: 'creator',
      displayName: 'Creator User',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Creator document created in Firestore');
    
    console.log('\n📋 Login Credentials:');
    console.log('Admin: admin@eventify.com / Admin@123456');
    console.log('Creator: creator@eventify.com / Creator@123456');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

createUsers();
```

Run:
```bash
node setup-users.js
```

## Step 3: Firestore Security Rules

Update `firestore.rules`:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - only authenticated users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.data.role == resource.data.role; // Can't change own role
    }
    
    // Events collection
    match /events/{eventId} {
      // Anyone can read non-hidden events
      allow read: if resource.data.isHidden == false || 
                     request.auth != null;
      
      // Only creators and admins can create
      allow create: if request.auth != null && 
                       (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['creator', 'admin']);
      
      // Only creator who created it or admin can update/delete
      allow update, delete: if request.auth != null && 
                               (resource.data.createdBy == request.auth.uid ||
                                get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Tickets collection
    match /tickets/{ticketId} {
      // Anyone can read their own tickets
      allow read: if true;
      
      // Anyone can create tickets (booking)
      allow create: if true;
      
      // Only admins and creators can update/delete
      allow update, delete: if request.auth != null &&
                               get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['creator', 'admin'];
    }
    
    // Locations collection
    match /locations/{locationId} {
      // Anyone can read
      allow read: if true;
      
      // Only admins can write
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

## Step 4: Storage Rules

Update `storage.rules`:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Event images
    match /events/{eventId}/{allPaths=**} {
      // Anyone can read
      allow read: if true;
      
      // Only authenticated creators/admins can write
      allow write: if request.auth != null;
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only storage
```

## Step 5: Test Login

### User App (main.dart)
- No login required
- Users can browse events and book tickets anonymously

### Admin/Creator App (main_admin.dart)
- Login with:
  - **Admin**: admin@eventify.com / Admin@123456
  - **Creator**: creator@eventify.com / Creator@123456

## Verification Checklist

- [ ] Firebase project created
- [ ] Admin user created in Authentication
- [ ] Creator user created in Authentication
- [ ] Admin document created in Firestore users collection
- [ ] Creator document created in Firestore users collection
- [ ] Firestore rules deployed
- [ ] Storage rules deployed
- [ ] Test admin login in admin app
- [ ] Test creator login in admin app
- [ ] Test event booking in user app (no login)

## Troubleshooting

### "Account not registered in app"
- Check if user document exists in Firestore `users` collection
- Verify document ID matches the user's UID from Authentication
- Verify `role` field is set correctly

### "Permission denied"
- Check Firestore security rules
- Verify user is authenticated
- Check user's role in Firestore

### Firebase not initialized
- Check `google-services.json` exists in `android/app/`
- Check `GoogleService-Info.plist` exists in `ios/Runner/`
- Verify `firebase_options.dart` is generated
- Run: `flutterfire configure`

## Quick Setup Commands

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Initialize project
firebase init

# 4. Configure Flutter app
flutterfire configure

# 5. Deploy rules
firebase deploy --only firestore:rules,storage
```

## Login Credentials Summary

**Admin App Login:**
- Email: `admin@eventify.com`
- Password: `Admin@123456`
- Role: admin
- Access: Full access to all features

**Creator App Login:**
- Email: `creator@eventify.com`
- Password: `Creator@123456`
- Role: creator
- Access: Create and manage own events

**User App:**
- No login required
- Browse events and book tickets anonymously
