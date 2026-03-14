// Quick Firebase user creation script
// Run: node create-users.js

const admin = require('firebase-admin');

// You need to get this from Firebase Console
// Go to: Project Settings > Service Accounts > Generate New Private Key
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

async function createUsers() {
  try {
    // Create Admin
    const admin1 = await auth.createUser({
      email: 'admin@eventify.com',
      password: 'Admin@123456',
      displayName: 'Admin User',
      emailVerified: true
    });
    
    await db.collection('users').doc(admin1.uid).set({
      email: 'admin@eventify.com',
      role: 'admin',
      displayName: 'Admin User',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Admin created:', admin1.uid);
    
    // Create Creator
    const creator = await auth.createUser({
      email: 'creator@eventify.com',
      password: 'Creator@123456',
      displayName: 'Creator User',
      emailVerified: true
    });
    
    await db.collection('users').doc(creator.uid).set({
      email: 'creator@eventify.com',
      role: 'creator',
      displayName: 'Creator User',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✅ Creator created:', creator.uid);
    console.log('\nLogin with:');
    console.log('Admin: admin@eventify.com / Admin@123456');
    console.log('Creator: creator@eventify.com / Creator@123456');
    
  } catch (error) {
    console.error('Error:', error.message);
  }
  process.exit();
}

createUsers();
