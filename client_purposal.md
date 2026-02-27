Event App Requirements 

Color scheme/palette of the app: 
Color palette: GRADIENTS OF Deep indigo (From light to Dark shades) (#1e1b4b) as  Main color. 

Just for reference: soft rose (#fce7f3), warm white (#fafafa), gold accent (#d4a373)

Build an event-based app with two interfaces: English and Japanese. Admin should be able to change the event content and images independently for each language. Specifically, English page and Japanese page images (aka posters) must be different.


User Authentication:
No authentication needed.
Users does not need any authentication required to open the app.
Users should be able to view events without any email registration required for the app.


Admin features:
Create, HIde, Duplicate, Delete Events. Must be able to view statistics how many men and how many women are attending.

Hidden Events Visibility Control : Events marked as Hidden in the admin settings must not be visible to regular users anywhere in the app. Hidden events should be accessible only from the admin interface.

Event Card Interaction & Navigation Behavior：
Tapping or swiping the left and right arrow controls on an event image must only scroll the images (previous/next image).
The arrow interactions must not trigger navigation to the event details page.
Navigation to the Event Details page should occur only when the user taps or clicks on one of the following elements:
Event Title
Event Date or Time
Event Venue / Location
Tapping on the event image itself or using image navigation controls must not redirect the user to the event details page

Event Description Page Image Style :
The image deck should not play on the main page.
Show images from top to bottom: one image → then the next → and so on
Images should be optimized for vertical viewing and full readability.
Horizontal carousels or side-swipe behavior must not be used on the event description page

Location Selector:
Add a Location selector. The selector should allow users to choose a city. Each event must have a Location Tag assigned to it. The list of cities displayed should be clearly shown as the current location.
When a city is selected:
Only events with the matching Location Tag are displayed. 
The selected city name should be clearly shown as the current location.
The location selector Language Logic and Expected Behaviour:
If the page language is Japanese, show only Japanese location names.
If the page language is English, show only English location names.
Similarly,
if the Japanese location is selected show the Japanese Language page
If the English location is selected show the English Language page.

Contact Icon:
For users, in case they need to ask something. That takes them to a link on internet, where they can send admin a message.

Event Creation:
Upto 10 images can be added in the same event display screen which is scrolled automatically from left to right. Each event photo has multiple photos and the scrolling button is displayed on left and right, one is able to see it and click it.


Event Tags: 

The main event photo should display two tags: Location and Price. 
Location tag: A city name that can be manually changed (e.g., Tokyo, Osaka, Nagoya). 
Location tag can be different based on the language type. For example A English language page and a Japanese language page can have a different location tag based on the Language.
Price tag: A price display with gender-based icons: Blue male icon 👨🏻‍💼 with price (e.g., 0–100¥) and Pink female icon 👩🏻‍💼 with price (e.g., Free–100¥). 
Example display on the event photo: Osaka 👨🏻‍💼 100¥ 👩🏻‍💼 Free

Event time:
Each event currently displays a Start Time with a time icon. Add a separate End Time field with its own distinct time icon.
Similar to English event dates, The Japanese dates should be able to display the day in Japanese character, for example 金、土、日

Venue location: 
Searchable on Google Maps, or
Ability to paste a direct Google Maps link if the location does not exist on Google Maps

Event Registration & Ticket behaviour : 
A Ticket feature which displays “Pay at venue” / "現地払い".  Just adjacent to "Reserve Ticekt" /”チッケトを予約”(no real payment involved, only to give the feeling of having a ticket, best to have this icon 🎟️).
-Ticket Limits: Admin has the Ability to set ticket limits by gender (e.g., 100 tickets for women; once full, women cannot select tickets).
-The ticket should include the original event image, event name and time of the event. Do not display the venue. 
-Each user is allowed to reserve only one ticket per event.
- A user is not able to see the remaining no. of tickets.
-Users must enter their name and select a gender icon (male/female). This is required to monitor how many males and females have joined an event.
-The system must prevent multiple reservations by the same user for the same event.
-After a ticket reservation, the user must be automatically redirected to the “My Tickets” page, where the reserved ticket details are displayed.
-One user should not be able to obtain more than one ticket for the same event-A user is able to cancel his attendance by deleting his ticket. 
-A user is able to regenerate a deleted ticket.

Admin Statistics
-The admin statistics should reflect and update the ticket behaviour of individual app. 
For example:
a) Admin Stastics shows attendance if a ticket is generated.
b) If a person deletes his tickets, then his attendance should not be counted in admin statistics for the event.
c) And if he regenerates the ticket his attendance can be counted.

Event Calendar View & Event Linking：
The app must display a separate Event Calendar view positioned below the list of all events.
The calendar must visually indicate dates that have one or more events.
Each event shown in the calendar must be clickable/tappable.
Selecting a date or event in the calendar must link directly to the corresponding event details page.
The calendar and event list must stay synchronized, so any event shown in the list is also reflected in the calendar.
The calendar must be responsive and easy to interact with on mobile devices.

Recent Activity / Latest Booking Status Section (Privacy-Safe):
Display a “Latest Booking Status” section positioned below the list of events on the main events page.
This section must show the latest  ticket reservations across all events.
Just show and update only the recent 3 bookings.
Each entry should display only:
Event name
Time of booking （Behave and show the Japan time Zone only)  In the Latest Booking section: Display the exact timestamp when a user books a ticket.Time should include:Hour and minute (and seconds if possible)Correct local timezone
No user names, profile details, or personal identifiers should be shown.
Newly added bookings must be highlighted with a “New” label or badge to attract attention.
The list should auto-update when new reservations are made.
The section must be mobile-friendly, visually distinct, and easy to scan.
This section is inline content, not a separate tab, icon, or navigation item.

Event Calendar View & Event Linking：
The app must display a separate Event Calendar view positioned below the list of all events.
The calendar must visually indicate dates that have one or more events.
Each event shown in the calendar must be clickable/tappable.
Selecting a date or event in the calendar must link directly to the corresponding event details page.
The calendar and event list must stay synchronized, so any event shown in the list is also reflected in the calendar.
The calendar must be responsive and easy to interact with on mobile devices.


Recent Activity / Latest Booking Status Section (Privacy-Safe):
Display a “Latest Booking Status” section positioned below the list of events on the main events page.
This section must show the latest  ticket reservations across all events.
Just show and update only the recent 3 bookings.
Each entry should display only:
Event name
Time of booking （Behave and show the Japan time Zone only)  In the Latest Booking section: Display the exact timestamp when a user books a ticket.Time should include:Hour and minute (and seconds if possible)Correct local timezone
No user names, profile details, or personal identifiers should be shown.
Newly added bookings must be highlighted with a “New” label or badge to attract attention.
The list should auto-update when new reservations are made.
The section must be mobile-friendly, visually distinct, and easy to scan.
This section is inline content, not a separate tab, icon, or navigation item.

Event Management:
Admin is able to grant "Event Creator" access to email accounts it wishes.
Those "Event Creator" aka email account have permission only to the event they create and do not modify, delete any other event which they have not created.
"Event Creator" can only see the statistics of the events they have created.
Admin Creates accounts for the "Event Creator" (email/password).
"Event Creator" can log in by the email/password for them.
"Event Creator" can change the password of their account.

Event Creator Access:
Event Creators log in by the 

Reminder Notification:
In-app reminders only 

Three hours before the event
One day before the event

User Tracking:
For one ticket per event rule, admin tracts the authentication by local storage (User can book again if they clear data)
Push Notifcations: