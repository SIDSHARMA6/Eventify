Here is the new project 
Tell me detailed 
App Requirements in Description - Image 1App Requirements in Description - Image 2App Requirements in Description - Image 3
Back

English
App Requirements in Description
Saturday, February 28, 2026

👨🏻‍💼
0-100Yen
👩🏻‍💼
Free
per ticket

Date

Feb 28

Time

06:10 PM - 11:00 PM

Venue

Osaka

About This Event
Event App Requirements Flutter + Firebase + Post Assistance on PlayStore and iOS

App Prototoypes
https://event-flow-app.base44.app/
https://myevent.base44.app/
https://eventifyapp.base44.app/


1. Color scheme/palette of the app:
Indigo

2: Bilingual Event APP
Build an event-based app with two interfaces: English and Japanese. Admin should be able to change the event content and images independently for each language. Specifically, English page and Japanese page images (aka posters) must be different.

3. User Authentication:
No authentication needed.
Users does not need any authentication required to open the app.
Users should be able to view events without any email registration required for the app.

4. Admin features:
Create, HIde, Duplicate, Delete Events. Must be able to view statistics how many men and how many women are attending.
Hidden Events Visibility Control :
Events marked as Hidden in the admin settings must not be visible to regular users anywhere in the app. Hidden events should be accessible only from the admin interface.

5. Event Management/Event Creator:
Admin is able to grant "Event Creator" access to email accounts it wishes.
Those "Event Creator" aka email account have permission only to the event they create and do not modify, delete any other event which they have not created.
"Event Creator" can only see the statistics of the events they have created.
Admin Creates accounts for the "Event Creator" (email/password).
"Event Creator" can log in by the email/password for them.
"Event Creator" can change the password of their account.

6. Contact Icon:
For users, in case they need to ask something. That takes them to a link on internet, where they can send admin a message.

7. Event Card Interaction & Navigation Behavior：
Tapping or swiping the left and right arrow controls on an event image must only scroll the images (previous/next image).
The arrow interactions must not trigger navigation to the event details page.
Navigation to the Event Details page should occur only when the user taps or clicks on one of the following elements:
Event Title
Event Date or Time
Event Venue / Location
Tapping on the event image itself or using image navigation controls must not redirect the user to the event details page

8. Event Description Page Image Style :
The image deck should not play on the main page.
Show images from top to bottom: one image → then the next → and so on
Images should be optimized for vertical viewing and full readability.
Horizontal carousels or side-swipe behavior must not be used on the event description page

9. Location Selector:
The selector should allow users to choose a city. Each event must have a Location Tag assigned to it. The list of cities displayed should be clearly shown as the current location.
When a city is selected:
Only events with the matching Location Tag are displayed.
The selected city name should be clearly shown as the current location.

The location selector Language Logic and Expected Behaviour:
If the page language is Japanese, show only Japanese location names.
If the page language is English, show only English location names.
Similarly,
if the Japanese location is selected show the Japanese Language page
If the English location is selected show the English Language page.


10. Event Creation:
Upto 9 images can be added in the same event display screen which is scrolled automatically from left to right. Each event photo has multiple photos and the scrolling button is displayed on left and right, one is able to see it and click it.

11. Event Tags:
The main event photo should display two tags: Location and Price.
Location tag: A city name that can be manually changed (e.g., Tokyo, Osaka, Nagoya).
Location tag can be different based on the language type. For example A English language page and a Japanese language page can have a different location tag based on the Language.
Price tag: A price display with gender-based icons: Blue male icon 👨🏻‍💼 with price (e.g., 0–100¥) and Pink female icon 👩🏻‍💼 with price (e.g., Free–100¥). Example display on the event photo: Osaka 👨🏻‍💼 100¥ 👩🏻‍💼 Free

12. Event time:
Each event currently displays a Start Time with a time icon. Add a separate End Time field with its own distinct time icon.
Similar to English event dates, The Japanese dates must be able to display the day in Japanese character, for example 金、土、日

13. Venue location:
Searchable on Google Maps, or
Ability to paste a direct Google Maps link if the location does not exist on Google Maps.

14. Event Registration & Ticket behaviour
A Ticket feature which displays Pay at venue” / 現地払い. Just adjacent to Reserve Ticekt/チッケトを予約 (no real payment involved, only to give the feeling of having a ticket, best to have this icon 🎟️).

Ticket Limits: Admin has the Ability to set ticket limits by gender (e.g., 100 tickets for women; once full, women cannot select tickets).
-The ticket should include the original event image, event name and time of the event. Do not display the venue. -Each user is allowed to reserve only one ticket per event.
- A user is not able to see the remaining no. of tickets.
-Users must enter their name and select a gender icon (male/female). This is required to monitor how many males and females have joined an event.
-The system must prevent multiple reservations by the same user for the same event.
-After a ticket reservation, the user must be automatically redirected to the “My Tickets” page, where the reserved ticket details are displayed.
-One user should not be able to obtain more than one ticket for the same event-A user is able to cancel his attendance by deleting his ticket.

User Tracking:
For one ticket per event rule, admin tracts the authentication by local storage (User can book again if they clear data) -The admin statistics should reflect and update the ticket behaviour of individual app. For example: a) Admin Stastics shows attendance if a ticket is generated.
b) If a person deletes his tickets, then his attendance should not be counted in admin statistics for the event.
c) And if he regenerates the ticket his attendance can be counted.


16. Event Calendar View & Event Linking
The app must display a separate Event Calendar view positioned below the list of all events.
The calendar must visually indicate dates that have one or more events.
Each event shown in the calendar must be clickable/tappable.
Selecting a date or event in the calendar must link directly to the corresponding event details page.
The calendar and event list must stay synchronized, so any event shown in the list is also reflected in the calendar.
The calendar must be responsive and easy to interact with on mobile devices.


16. Recent Activity / Latest Booking Status Section (Privacy-Safe):
Display a “Latest Booking Status” section positioned below the list of events on the main events page.
This section must show the latest ticket reservations across all events.
Just show and update only the recent 3 bookings.
Each entry should display only:
Event name
Time of booking （Behave and show the Japan time Zone only) In the Latest Booking section: Display the exact timestamp when a user books a ticket.Time should include:Hour and minute (and seconds if possible)Correct local timezone
No user names, profile details, or personal identifiers should be shown.
Newly added bookings must be highlighted with a “New” label or badge to attract attention.
The list should auto-update when new reservations are made.
The section must be mobile-friendly, visually distinct, and easy to scan.
This section is inline content, not a separate tab, icon, or navigation item.

17. Reminder Notification:
In-app reminders only (Ability at user end to deselect the reminders)
Three hours before the event
One day before the event

18. Push Notifcations:
Consultation Needed
View on Map
Reserve Ticket (Pay at venue)
ok so i talk with the cleint and he said that 
app with two lang japan and english,dropdown of location set by firebase ,
three roles in single app 
user,creator,admin
user comes no auth direct come on even ticket the slot book the slot and he get ticket template that he can show at physical event and pay the ticket fees,
but one device one ticket generate,
male ticket,female ticket coount,
event has location,event name,10 images,ticket prices for male and female ,
date time, and mid latets bookings where he can see his bookings,
bottam even calender where he can schedule,user can share tickets to whatsapp so that user come to app to book tickert,

then for creator just direct login with email and passs he can create event crud, but he cant crud with other creators,
for admin login email /pass he can manage cretor,user,all events ,crud,hide,total user,total tickets,tracking,hide,
we use fcm for notifcation for events ,new event coming,your booked event is tommowr etc etc,


read this this is from the client now compare it with provided above 18 points
Below is a clean, developer-ready .md specification you can give to Kiro (or any AI/dev) so the app can be implemented correctly without missing anything.

It combines:

✅ Original 18 requirements
✅ Client clarifications
✅ Role logic
✅ Firebase + Flutter architecture

# 📱 Bilingual Event App Specification
## Flutter + Firebase Implementation Guide

This document defines the complete requirements to build a bilingual event booking app with three roles: **User, Event Creator, and Admin**.

The implementation must follow this document strictly.

---

# 🎯 PROJECT OVERVIEW

A social event application where users can browse events, reserve a ticket (pay at venue), and attend meetups. The app supports English and Japanese languages and includes role-based management.

---

# 🧱 TECHNOLOGY STACK

## Frontend
- Flutter (Android & iOS)

## Backend
- Firebase Firestore (database)
- Firebase Storage (images)
- Firebase Authentication (Admin & Creator only)
- Firebase Cloud Messaging (notifications)

## Local Storage
- SharedPreferences (ticket tracking & reminders)

---

# 🌐 LANGUAGE SUPPORT (Bilingual)

## Requirements
- App supports **English and Japanese**
- Admin can manage content independently per language
- Posters/images can be different per language
- Location names differ per language

## Firestore Fields Example


title_en
title_ja
description_en
description_ja
images_en[]
images_ja[]
location_en
location_ja


---

# 👥 USER ROLES

## 1️⃣ USER (No Authentication)

### Access
- No login required
- Can open app directly

### Capabilities
- View events
- Select city/location
- Reserve ticket (one per event per device)
- View & cancel ticket
- Share ticket via WhatsApp
- Receive reminders & notifications
- View latest bookings section
- Use calendar to explore events

---

## 2️⃣ EVENT CREATOR

### Authentication
- Login via email & password (Firebase Auth)

### Permissions
- Create events
- Edit own events only
- Delete own events
- View statistics of own events
- Change password

### Restrictions
- Cannot modify events created by others

---

## 3️⃣ ADMIN

### Authentication
- Login via email & password

### Permissions
- Manage all events (create/edit/delete/duplicate/hide)
- Manage event creators
- Hide events from users
- View analytics & tracking:
  - total users
  - total tickets
  - male/female counts
- Access hidden events

---

# 📍 LOCATION SELECTOR

## Requirements
- Location list stored in Firebase
- User selects a city → only matching events shown
- Selected city shown as current location

### Language Logic
- Japanese page → show Japanese location names
- English page → show English names

---

# 🗓 EVENT STRUCTURE

Each event must include:

- event name (EN/JP)
- location tag (EN/JP)
- up to 10 images
- event description
- date
- start time
- end time
- venue map link or Google Maps URL
- male ticket price
- female ticket price
- male ticket limit
- female ticket limit
- hidden flag
- createdBy (creator id)

---

# 🖼 EVENT IMAGE RULES

## Event Card
- Horizontal scroll with arrows
- Arrow click only scrolls images
- Image tap does NOT open details page

## Event Details Page
- Images stacked vertically
- No carousel or horizontal swipe

---

# 🏷 EVENT TAG DISPLAY

Displayed on event card image:



City 👨🏻‍💼 MalePrice 👩🏻‍💼 FemalePrice


Example:


Osaka 👨🏻‍💼 100¥ 👩🏻‍💼 Free


---

# 🎟 TICKET RESERVATION SYSTEM

## Booking Rules
- One ticket per device per event
- User enters:
  - name
  - gender (male/female)
- Gender limits enforced
- Pay at venue (no online payment)

## After Booking
- Ticket generated
- Redirect to "My Tickets"
- Ticket shows:
  - event image
  - event name
  - date & time
- Venue NOT shown on ticket

## Cancel Ticket
- User may cancel ticket
- Admin statistics update accordingly

## Device Tracking
- Use local storage/device ID
- Clearing app data allows rebooking

---

# 👨‍👩‍👧 GENDER LIMIT CONTROL

Admin sets limits:
- Male tickets
- Female tickets

If limit reached → block booking.

---

# 📤 TICKET SHARING

User can share ticket via WhatsApp.

Ticket should include:
- event name
- date & time
- ticket image/template

---

# 🆕 LATEST BOOKING STATUS SECTION

Display last **3 bookings**.

## Show:
- event name
- booking time (Japan timezone)
- NEW badge for recent booking

## Do NOT show:
- user names
- personal info

Auto-update when new booking occurs.

---

# 📅 EVENT CALENDAR VIEW

## Requirements
- Positioned below event list
- Show dates with events
- Click date → open event details
- Calendar syncs with event list
- Mobile responsive

---

# 🔔 REMINDER SYSTEM (IN-APP)

User can enable/disable reminders.

Reminders:
- 1 day before event
- 3 hours before event

---

# 🔔 PUSH NOTIFICATIONS (FCM)

Send notifications for:
- new events
- event reminders
- event tomorrow alerts
- event updates

---

# 📊 ADMIN ANALYTICS

Admin dashboard must show:

- total events
- total users (device count)
- total tickets
- male count
- female count
- attendance changes (live updates)

---

# 👁 HIDDEN EVENTS

- Hidden events not visible to users
- Only admin can access them

---

# 📞 CONTACT ICON

A contact icon opens external link to message admin.

---

# 📍 VENUE LOCATION

- Google Maps searchable location OR
- paste direct maps link

---

# 🎨 THEME

Primary color: **Indigo**

---

# 📦 FIRESTORE COLLECTION STRUCTURE

## events


id
title_en
title_ja
description_en
description_ja
images_en[]
images_ja[]
location_tag
date
start_time
end_time
male_price
female_price
male_limit
female_limit
isHidden
createdBy
map_link


## reservations


id
eventId
deviceId
name
gender
timestamp


## users


id
role (admin / creator)
email


## locations


name_en
name_ja


---

# ⚠️ CRITICAL RULES

✔ No login required for users  
✔ One device = one ticket per event  
✔ Creator cannot modify others' events  
✔ Hidden events invisible to users  
✔ Gender limits enforced  
✔ Bilingual content fully supported  

---

# ✅ FINAL GOAL

Deliver a production-ready bilingual event app with:

✔ event browsing  
✔ ticket reservation  
✔ calendar & booking activity  
✔ role-based management  
✔ push notifications  
✔ WhatsApp ticket sharing  
Perfect 👍 — these screens clearly show the final UI direction.

Based on:

✅ your screenshots
✅ original 18 requirements
✅ client clarifications
✅ actual UI layout

Below is a FINAL UI + FLOW SPEC that Kiro must follow to implement the app exactly.

This removes ambiguity and prevents mistakes.

📱 FINAL UI IMPLEMENTATION SPEC (Based on Screens)
🎨 App Theme

Primary color: Indigo / Purple

Clean rounded cards

Soft shadows

Minimal modern UI

🏠 MAIN HOME SCREEN (Events Tab)
🔝 Top Bar
Left

✅ App Logo + Name (Eventify)

Center

✅ Location dropdown (from Firebase)

default: All

shows city list

Right

✅ Language toggle (English / Japanese)
✅ Notification icon
✅ Chat/Contact icon (optional)

📌 SECTION: Discover Upcoming Events

Shows event count.

Example:

Discover Upcoming Events
2 events

🎴 EVENT CARD DESIGN

Each event card contains:

🖼 Image Slider

horizontal image scroll

left/right arrows

arrows scroll only images

image tap DOES NOT open details

👥 Who You'll Meet (Static Info Block)

Shows:

Travelers

Expats

Local Japanese

(This is informational content — static section.)

🏷 Tags Over Image

Overlay tags:

Osaka 👨🏻‍💼 0–100¥   👩🏻‍💼 Free

Tag Rules

✔ location
✔ male price
✔ female price

📄 Event Info

Below image:

✔ Event Title
✔ Date & Time
✔ Venue

Tapping these opens Event Details Page.

🆕 LATEST BOOKINGS SECTION
📍 Positioned BELOW event list
Title

✨ Latest Bookings

Show last 3 bookings

Each item shows:

✔ event name
✔ booking time (Japan timezone)

❌ no user names

New booking highlight

Badge: NEW

📅 EVENT CALENDAR SECTION
Positioned below Latest Bookings
Features

✔ month view
✔ highlight event dates
✔ tap date → open event
✔ arrows to change month

Must sync with event list.

🎟 MY TICKETS SCREEN
Header

"My Tickets"

If empty

Show:
✔ ticket icon
✔ "No tickets yet"
✔ Browse Events button

When ticket exists

Display ticket card:

✔ event image
✔ event name
✔ date & time
✔ QR code (optional but recommended)
✔ cancel ticket button
✔ share button (WhatsApp)

🎟 TICKET TEMPLATE DESIGN

Must include:

✔ event name
✔ date & time
✔ ticket holder name
✔ gender icon
✔ ticket ID / QR (optional)

❌ venue not shown

Used for entry at physical event.

📄 EVENT DETAILS PAGE
Layout
🖼 Images

✔ vertical stacked images
✔ no carousel
✔ full width

📍 Details

✔ title
✔ date
✔ start & end time
✔ venue
✔ map link
✔ description

🎟 Reserve Ticket Button

Button text:

English:

Reserve Ticket (Pay at venue)


Japanese:

チケット予約（現地払い）

🎟 BOOKING FLOW

1️⃣ Tap Reserve
2️⃣ Enter name
3️⃣ Select gender
4️⃣ Confirm booking
5️⃣ Redirect to My Tickets
6️⃣ Ticket saved

👤 LOCATION DROPDOWN BEHAVIOR

loaded from Firebase

shows city list

filters events

language based names

🌐 LANGUAGE SWITCH

Switch changes:

✔ UI text
✔ event content
✔ images
✔ location names

👨‍💻 CREATOR PANEL (Inside App)

Creator login → dashboard:

✔ create event
✔ upload images
✔ set prices & limits
✔ edit own events
✔ view stats

🧑‍💼 ADMIN PANEL (Inside App)

Admin dashboard:

✔ manage all events
✔ manage creators
✔ hide events
✔ analytics
✔ tracking

🔔 NOTIFICATIONS

Use Firebase Cloud Messaging.

Send:
✔ new event alerts
✔ reminder notifications
✔ event tomorrow reminder

⚠️ UX RULES (VERY IMPORTANT)

✔ image arrows only scroll images
✔ image tap does NOT open details
✔ only title/date/location open details
✔ hidden events invisible to users
✔ one device one ticket
✔ gender limits enforced

📦 FIRESTORE COLLECTIONS
events
reservations
users
locations
notifications (optional)
✅ FINAL APP FLOW
USER FLOW

Open app → select city → browse events → book ticket → receive reminder → attend event.

CREATOR FLOW

Login → create event → view bookings.

ADMIN FLOW

Login → manage events & creators → view analytics.

🎯 FINAL IMPLEMENTATION GOAL

Build a production-ready event booking app with:

✔ bilingual support
✔ role-based system
✔ ticket booking & sharing
✔ calendar & booking feed
✔ notifications
✔ admin & creator management