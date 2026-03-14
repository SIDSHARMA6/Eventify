/**
 * Eventify — Firestore Seed Script
 *
 * SETUP (one-time):
 *   1. Go to Firebase Console → Project Settings → Service Accounts
 *   2. Click "Generate new private key" → save as serviceAccount.json in this folder
 *   3. Run: node scripts/seed_firestore.js
 *
 * Fields match FIREBASE_SCHEMA.md exactly.
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

// ── Service account auth ─────────────────────────────────────────────
const serviceAccountPath = path.join(__dirname, 'serviceAccount.json');
if (!fs.existsSync(serviceAccountPath)) {
    console.error('❌  serviceAccount.json not found!');
    console.error('');
    console.error('  STEPS TO GET IT:');
    console.error('  1. Open: https://console.firebase.google.com/project/eventify-51f12/settings/serviceaccounts/adminsdk');
    console.error('  2. Click "Generate new private key"');
    console.error('  3. Save the downloaded file as: scripts/serviceAccount.json');
    console.error('  4. Run this script again: node scripts/seed_firestore.js');
    process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'eventify-51f12',
});

const db = getFirestore();

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
function futureDate(daysFromNow) {
    const d = new Date();
    d.setDate(d.getDate() + daysFromNow);
    return d.toISOString().substring(0, 10); // "YYYY-MM-DD"
}

// ─────────────────────────────────────────────
// 1. LOCATIONS
// ─────────────────────────────────────────────
const locations = [
    { name_en: 'All', name_ja: 'すべて', order: 0 },
    { name_en: 'Tokyo', name_ja: '東京', order: 1 },
    { name_en: 'Osaka', name_ja: '大阪', order: 2 },
    { name_en: 'Kyoto', name_ja: '京都', order: 3 },
    { name_en: 'Yokohama', name_ja: '横浜', order: 4 },
];

// ─────────────────────────────────────────────
// 2. EVENTS
// All 27 fields from FIREBASE_SCHEMA.md
// ─────────────────────────────────────────────
const ADMIN_UID = 'admin'; // Will be replaced once real admin user is created in Firebase Auth

const events = [
    {
        title_en: 'Saturday Night Meetup Tokyo',
        title_ja: '土曜日の夜の集まり 東京',
        description_en: 'Join us for an amazing evening full of connections, conversations, and fun! Meet interesting people from all walks of life in the heart of Tokyo.',
        description_ja: '素晴らしい夜をお楽しみください！東京の中心で多彩な人々と出会い、会話を楽しみましょう。',
        images_en: ['https://picsum.photos/seed/ev1a/800/600', 'https://picsum.photos/seed/ev1b/800/600'],
        images_ja: ['https://picsum.photos/seed/ev1ja/800/600'],
        location_en: 'Tokyo',
        location_ja: '東京',
        date: futureDate(7),
        endDate: futureDate(7),
        startTime: '18:00',
        endTime: '23:00',
        venueName: 'Shibuya Event Hall',        // legacy fallback — keep always
        venueName_en: 'Shibuya Event Hall',
        venueName_ja: '渋谷イベントホール',
        venueAddress_en: '2-1 Dogenzaka, Shibuya-ku, Tokyo 150-0043',
        venueAddress_ja: '〒150-0043 東京都渋谷区道玄坂2-1',
        mapLink: 'https://maps.google.com/?q=Shibuya+Tokyo',
        malePrice: 1000,
        femalePrice: 0,
        maleLimit: 30,
        femaleLimit: 30,
        maleBooked: 0,
        femaleBooked: 0,
        isHidden: false,
        isDeleted: false,
        isDuplicated: false,
        isRecurring: false,
        recurringLabel: '',
        createdBy: ADMIN_UID,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
    },
    {
        title_en: 'Osaka Weekend Social',
        title_ja: '大阪ウィークエンドソーシャル',
        description_en: 'Great social event in Osaka! Network, meet new people, and enjoy a wonderful evening in Japan\'s most vibrant city.',
        description_ja: '大阪での素晴らしいソーシャルイベント。新しい人々と出会い、楽しい夜を過ごしましょう。',
        images_en: ['https://picsum.photos/seed/ev2a/800/600'],
        images_ja: ['https://picsum.photos/seed/ev2ja/800/600'],
        location_en: 'Osaka',
        location_ja: '大阪',
        date: futureDate(14),
        endDate: futureDate(14),
        startTime: '19:00',
        endTime: '23:30',
        venueName: 'Namba Event Space',
        venueName_en: 'Namba Event Space',
        venueName_ja: 'なんばイベントスペース',
        venueAddress_en: '3-1-1 Namba, Naniwa-ku, Osaka 556-0011',
        venueAddress_ja: '〒556-0011 大阪府大阪市浪速区難波3-1-1',
        mapLink: 'https://maps.google.com/?q=Namba+Osaka',
        malePrice: 1500,
        femalePrice: 500,
        maleLimit: 25,
        femaleLimit: 25,
        maleBooked: 0,
        femaleBooked: 0,
        isHidden: false,
        isDeleted: false,
        isDuplicated: false,
        isRecurring: false,
        recurringLabel: '',
        createdBy: ADMIN_UID,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
    },
    {
        title_en: 'Kyoto Cultural Evening',
        title_ja: '京都文化の夜',
        description_en: 'Experience the cultural charm of Kyoto while meeting wonderful people. Traditional setting, modern connections.',
        description_ja: '京都の文化的な魅力を体験しながら素晴らしい人々と出会いましょう。伝統ある雰囲気でモダンなつながりを。',
        images_en: ['https://picsum.photos/seed/ev3a/800/600', 'https://picsum.photos/seed/ev3b/800/600'],
        images_ja: ['https://picsum.photos/seed/ev3ja/800/600'],
        location_en: 'Kyoto',
        location_ja: '京都',
        date: futureDate(21),
        endDate: futureDate(21),
        startTime: '17:30',
        endTime: '22:00',
        venueName: 'Gion Meeting House',
        venueName_en: 'Gion Meeting House',
        venueName_ja: '祇園ミーティングハウス',
        venueAddress_en: '1-1 Gionmachi Kitagawa, Higashiyama-ku, Kyoto 605-0073',
        venueAddress_ja: '〒605-0073 京都府京都市東山区祇園町北側1-1',
        mapLink: 'https://maps.google.com/?q=Gion+Kyoto',
        malePrice: 2000,
        femalePrice: 1000,
        maleLimit: 20,
        femaleLimit: 20,
        maleBooked: 0,
        femaleBooked: 0,
        isHidden: false,
        isDeleted: false,
        isDuplicated: false,
        isRecurring: false,
        recurringLabel: '',
        createdBy: ADMIN_UID,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
    },
    {
        title_en: 'Yokohama Bay Night',
        title_ja: '横浜ベイナイト',
        description_en: 'An unforgettable evening by Yokohama Bay. Stunning views, great atmosphere, and amazing people to meet.',
        description_ja: '横浜湾沿いの忘れられない夜。素晴らしい景色、最高の雰囲気、そして素敵な出会いを。',
        images_en: ['https://picsum.photos/seed/ev4a/800/600'],
        images_ja: [],
        location_en: 'Yokohama',
        location_ja: '横浜',
        date: futureDate(10),
        endDate: futureDate(10),
        startTime: '18:30',
        endTime: '22:30',
        venueName: 'Minato Mirai Hall',
        venueName_en: 'Minato Mirai Hall',
        venueName_ja: 'みなとみらいホール',
        venueAddress_en: '1-1 Minato Mirai, Nishi-ku, Yokohama 220-0012',
        venueAddress_ja: '〒220-0012 神奈川県横浜市西区みなとみらい1-1',
        mapLink: 'https://maps.google.com/?q=Minato+Mirai+Yokohama',
        malePrice: 1000,
        femalePrice: 0,
        maleLimit: 40,
        femaleLimit: 40,
        maleBooked: 0,
        femaleBooked: 0,
        isHidden: false,
        isDeleted: false,
        isDuplicated: false,
        isRecurring: true,
        recurringLabel: 'Weekly',
        createdBy: ADMIN_UID,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
    },
    {
        title_en: 'Tokyo Hidden Gem Night',
        title_ja: '東京の隠れた名所ナイト',
        description_en: 'Explore Tokyo\'s hidden gems with like-minded adventurers. Secret venue revealed 24 hours before the event!',
        description_ja: '志を同じくする探検家と東京の隠れた名所を探求。会場は開催24時間前に公開！',
        images_en: ['https://picsum.photos/seed/ev5a/800/600'],
        images_ja: [],
        location_en: 'Tokyo',
        location_ja: '東京',
        date: futureDate(30),
        endDate: futureDate(30),
        startTime: '20:00',
        endTime: '00:00',
        venueName: 'Secret Venue Tokyo',
        venueName_en: 'Secret Venue Tokyo',
        venueName_ja: 'シークレット会場 東京',
        venueAddress_en: 'Revealed 24h before the event',
        venueAddress_ja: '開催24時間前に公開',
        mapLink: 'https://maps.google.com/?q=Tokyo',
        malePrice: 2000,
        femalePrice: 1500,
        maleLimit: 15,
        femaleLimit: 15,
        maleBooked: 0,
        femaleBooked: 0,
        isHidden: false,
        isDeleted: false,
        isDuplicated: false,
        isRecurring: false,
        recurringLabel: '',
        createdBy: ADMIN_UID,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
    },
];

// ─────────────────────────────────────────────
// MAIN SEED FUNCTION
// ─────────────────────────────────────────────
async function seed() {
    console.log('');
    console.log('🌱  Eventify — Firestore Seed Script');
    console.log('    Project: eventify-51f12');
    console.log('════════════════════════════════════════════\n');

    // ── 1. Locations ──────────────────────────────────────
    console.log('📍  Seeding locations...');
    const existingLocs = await db.collection('locations').limit(1).get();
    if (!existingLocs.empty) {
        console.log('    ⚠️  Locations already exist — skipping to avoid duplicates\n');
    } else {
        const locBatch = db.batch();
        for (const loc of locations) {
            const ref = db.collection('locations').doc();
            locBatch.set(ref, { ...loc, createdAt: FieldValue.serverTimestamp() });
        }
        await locBatch.commit();
        console.log(`    ✅  ${locations.length} locations created\n`);
    }

    // ── 2. Events ─────────────────────────────────────────
    console.log('📅  Seeding events...');
    const existingEvents = await db.collection('events').limit(1).get();
    if (!existingEvents.empty) {
        console.log('    ⚠️  Events already exist — skipping to avoid duplicates\n');
    } else {
        const createdEventIds = [];
        for (const event of events) {
            const ref = await db.collection('events').add(event);
            createdEventIds.push({ id: ref.id, data: event });
            console.log(`    ✅  "${event.title_en}" → ${ref.id}`);
        }
        console.log('');

        // ── 3. One sample reservation ────────────────────────
        console.log('🎫  Seeding sample reservation...');
        const firstEvent = createdEventIds[0];
        const reservation = {
            eventId: firstEvent.id,
            deviceId: 'SAMPLE00DEVICE001',
            userName: 'Tanaka Hanako',
            gender: 'female',
            ticketId: 'TICKET-000001',
            timestamp: new Date().toISOString(),    // ISO8601 String — LatestBookings uses DateTime.parse()
            isCancelled: false,
            isScanned: false,
            isDeleted: false,
            checkedInAt: null,
            deletedAt: null,
            cancelledAt: null,
            // Denormalized from event — TicketCard reads these directly
            eventTitle_en: firstEvent.data.title_en,
            eventTitle_ja: firstEvent.data.title_ja,
            eventDate: firstEvent.data.date,
            eventTime: firstEvent.data.startTime,
            eventImage: firstEvent.data.images_en[0] || null,
        };
        const resRef = await db.collection('reservations').add(reservation);
        console.log(`    ✅  Sample reservation → ${resRef.id}\n`);
    }

    // ── 4. fcm_tokens placeholder ─────────────────────────
    console.log('🔔  Initializing fcm_tokens collection...');
    await db.collection('fcm_tokens').doc('_placeholder').set({
        deviceId: '_placeholder',
        token: 'placeholder-delete-me',
        updatedAt: FieldValue.serverTimestamp(),
    });
    console.log('    ✅  fcm_tokens collection ready\n');

    // ── 5. users placeholder ──────────────────────────────
    console.log('👤  Initializing users collection...');
    const existingUsers = await db.collection('users').limit(1).get();
    if (!existingUsers.empty) {
        console.log('    ⚠️  Users already exist — skipping\n');
    } else {
        await db.collection('users').doc('_placeholder').set({
            email: 'placeholder@delete.me',
            role: 'creator',
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        });
        console.log('    ✅  users collection ready\n');
    }

    console.log('════════════════════════════════════════════');
    console.log('✅  SEED COMPLETE!\n');
    console.log('Collections seeded:');
    console.log('  • locations    → 5 docs (All, Tokyo, Osaka, Kyoto, Yokohama)');
    console.log('  • events       → 5 docs (sample events across all cities)');
    console.log('  • reservations → 1 doc  (sample ticket)');
    console.log('  • fcm_tokens   → 1 doc  (delete _placeholder)');
    console.log('  • users        → 1 doc  (delete _placeholder)\n');
    console.log('⚠️  NEXT STEPS:');
    console.log('  1. Firebase Console → Authentication → Add users:');
    console.log('     admin@yourapp.com  (role: admin)');
    console.log('     creator@yourapp.com (role: creator)');
    console.log('  2. Firebase Console → Firestore → users collection:');
    console.log('     Add doc with id = Firebase Auth UID, fields: email, role, createdAt');
    console.log('  3. Delete _placeholder docs from users and fcm_tokens');
    console.log('  4. Test the app — all screens should load data correctly');
    console.log('════════════════════════════════════════════\n');

    process.exit(0);
}

seed().catch((err) => {
    console.error('\n❌  Seed failed:', err.message || err);
    process.exit(1);
});
