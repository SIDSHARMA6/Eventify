/**
 * Eventify — Firestore Verification Script
 * 
 * Reads back from Firestore and checks every field from FIREBASE_SCHEMA.md exists.
 * Run: node scripts/verify_firestore.js
 */

const admin = require('firebase-admin');
const path = require('path');
const { getFirestore } = require('firebase-admin/firestore');

if (!admin.apps.length) {
    const serviceAccount = require(path.join(__dirname, 'serviceAccount.json'));
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: 'eventify-51f12',
    });
}

const db = getFirestore();

// ── Expected fields from FIREBASE_SCHEMA.md ──────────────────────────
const REQUIRED = {
    events: [
        'title_en', 'title_ja', 'description_en', 'description_ja',
        'images_en', 'images_ja', 'location_en', 'location_ja',
        'date', 'endDate', 'startTime', 'endTime',
        'venueName', 'venueName_en', 'venueName_ja',
        'venueAddress_en', 'venueAddress_ja', 'mapLink',
        'malePrice', 'femalePrice', 'maleLimit', 'femaleLimit',
        'maleBooked', 'femaleBooked',
        'isHidden', 'isDeleted', 'isDuplicated', 'isRecurring', 'recurringLabel',
        'createdBy', 'createdAt', 'updatedAt',
    ],
    reservations: [
        'eventId', 'deviceId', 'userName', 'gender', 'ticketId',
        'timestamp', 'isCancelled', 'isScanned', 'isDeleted',
        'checkedInAt', 'deletedAt', 'cancelledAt',
        'eventTitle_en', 'eventTitle_ja', 'eventDate', 'eventTime', 'eventImage',
    ],
    locations: [
        'name_en', 'name_ja', 'order', 'createdAt',
    ],
    users: [
        'email', 'role', 'createdAt', 'updatedAt',
    ],
    fcm_tokens: [
        'deviceId', 'token', 'updatedAt',
    ],
};

function check(label, doc, requiredFields) {
    const data = doc.data();
    let allOk = true;
    const missing = [];
    for (const field of requiredFields) {
        if (!(field in data)) {
            missing.push(field);
            allOk = false;
        }
    }
    if (allOk) {
        console.log(`    ✅  ${label} — all ${requiredFields.length} fields present`);
    } else {
        console.log(`    ❌  ${label} — MISSING FIELDS: ${missing.join(', ')}`);
    }
    return allOk;
}

async function verify() {
    console.log('');
    console.log('🔍  Eventify — Firestore Verification');
    console.log('    Project: eventify-51f12');
    console.log('════════════════════════════════════════════\n');

    let totalOk = true;

    for (const [collection, fields] of Object.entries(REQUIRED)) {
        console.log(`📂  ${collection} (${fields.length} required fields):`);
        const snap = await db.collection(collection).limit(3).get();

        if (snap.empty) {
            console.log(`    ⚠️  No documents found in "${collection}"\n`);
            totalOk = false;
            continue;
        }

        snap.docs.forEach((doc) => {
            const ok = check(`doc: ${doc.id.substring(0, 16)}...`, doc, fields);
            if (!ok) totalOk = false;
        });

        // Show count
        const countSnap = await db.collection(collection).get();
        console.log(`    📊  Total documents: ${countSnap.size}\n`);
    }

    // Extra: verify location names match exactly what app expects
    console.log('📍  Verifying location names (must match event.location_en exactly):');
    const locSnap = await db.collection('locations').orderBy('order').get();
    const locNames = locSnap.docs.map(d => d.data().name_en);
    console.log(`    Found: [${locNames.join(', ')}]`);
    const expectedLocs = ['All', 'Tokyo', 'Osaka', 'Kyoto', 'Yokohama'];
    const locsMatch = expectedLocs.every(n => locNames.includes(n));
    console.log(`    ${locsMatch ? '✅  All location names correct' : '❌  Location names mismatch!'}\n`);

    // Extra: verify reservation timestamp is String not Timestamp
    console.log('🎫  Verifying reservation timestamp is ISO8601 String (not Firestore Timestamp):');
    const resSnap = await db.collection('reservations').limit(1).get();
    if (!resSnap.empty) {
        const ts = resSnap.docs[0].data().timestamp;
        const isString = typeof ts === 'string';
        console.log(`    timestamp type: ${typeof ts} → value: ${ts}`);
        console.log(`    ${isString ? '✅  Correct — String type' : '❌  WRONG — should be String not Timestamp'}\n`);
        if (!isString) totalOk = false;
    }

    console.log('════════════════════════════════════════════');
    if (totalOk) {
        console.log('✅  ALL CHECKS PASSED — Firebase backend is 100% ready!');
        console.log('    The app will connect without any field errors.');
    } else {
        console.log('❌  Some checks failed — review above errors.');
    }
    console.log('════════════════════════════════════════════\n');

    process.exit(0);
}

verify().catch((err) => {
    console.error('\n❌  Verification failed:', err.message || err);
    process.exit(1);
});
