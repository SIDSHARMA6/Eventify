/**
 * Firebase User Setup Script
 * Creates admin and creator accounts for Eventify app
 * 
 * Prerequisites:
 * 1. npm install firebase-admin
 * 2. Download serviceAccountKey.json from Firebase Console
 * 3. Place serviceAccountKey.json in project root
 * 
 * Run: node setup-firebase-users.js
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// Download serviceAccountKey.json from:
// Firebase Console → Project Settings → Service Accounts → Generate New Private Key
try {
  const serviceAccount = require('./serviceAccountKey.json');
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  
  console.log('✅ Firebase Admin SDK initialized\n');
} catch (error) {
  console.error('❌ Error: serviceAccountKey.json not found!');
  console.error('Download it from Firebase Console → Project Settings → Service Accounts');
  process.exit(1);
}

const auth = admin.auth();
const db = admin.firestore();

// User configurations
const users = [
  {
    email: 'admin@eventify.com',
    password: 'Admin@123456',
    displayName: 'Admin User',
    role: 'admin'
  },
  {
    email: 'creator@eventify.com',
    password: 'Creator@123456',
    displayName: 'Creator User',
    role: 'creator'
  }
];

async function createUser(userData) {
  try {
    // Check if user already exists
    try {
      const existingUser = await auth.getUserByEmail(userData.email);
      console.log(`⚠️  User ${userData.email} already exists (UID: ${existingUser.uid})`);
      
      // Update Firestore document
      await db.collection('users').doc(existingUser.uid).set({
        email: userData.email,
        role: userData.role,
        displayName: userData.displayName,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
      
      console.log(`✅ Updated Firestore document for ${userData.email}\n`);
      return existingUser.uid;
    } catch (error) {
      // User doesn't exist, create new one
      if (error.code === 'auth/user-not-found') {
        const userRecord = await auth.createUser({
          email: userData.email,
          password: userData.password,
          displayName: userData.displayName,
          emailVerified: true
        });
        
        console.log(`✅ Created user: ${userData.email} (UID: ${userRecord.uid})`);
        
        // Add user document to Firestore
        await db.collection('users').doc(userRecord.uid).set({
          email: userData.email,
          role: userData.role,
          displayName: userData.displayName,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`✅ Created Firestore document for ${userData.email}\n`);
        return userRecord.uid;
      }
      throw error;
    }
  } catch (error) {
    console.error(`❌ Error creating ${userData.email}:`, error.message);
    throw error;
  }
}

async function setupUsers() {
  console.log('🚀 Starting Firebase user setup...\n');
  
  try {
    const createdUsers = [];
    
    for (const userData of users) {
      const uid = await createUser(userData);
      createdUsers.push({ ...userData, uid });
    }
    
    console.log('═══════════════════════════════════════════════════');
    console.log('✅ Setup Complete!');
    console.log('═══════════════════════════════════════════════════\n');
    
    console.log('📋 Login Credentials:\n');
    createdUsers.forEach(user => {
      console.log(`${user.role.toUpperCase()}:`);
      console.log(`  Email: ${user.email}`);
      console.log(`  Password: ${user.password}`);
      console.log(`  UID: ${user.uid}`);
      console.log('');
    });
    
    console.log('═══════════════════════════════════════════════════');
    console.log('Next Steps:');
    console.log('1. Deploy Firestore rules: firebase deploy --only firestore:rules');
    console.log('2. Test login in admin app');
    console.log('═══════════════════════════════════════════════════');
    
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Setup failed:', error);
    process.exit(1);
  }
}

// Run setup
setupUsers();
