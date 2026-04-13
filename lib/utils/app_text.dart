import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// Bilingual Text Helper
/// All app text in English and Japanese
class AppText {
  // listen: false — safe to call from build methods AND callbacks.
  // Widgets get reactivity by calling context.watch<LanguageProvider>() in their build().
  static String _getText(BuildContext context, String en, String ja) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return languageProvider.currentLanguage == 'en' ? en : ja;
  }

  // Bottom Navigation
  static String events(BuildContext context) =>
      _getText(context, 'Events', 'イベント');
  static String tickets(BuildContext context) =>
      _getText(context, 'Tickets', 'チケット');
  static String profile(BuildContext context) =>
      _getText(context, 'Profile', 'プロフィール');

  // Home Screen
  static String discoverEvents(BuildContext context) =>
      _getText(context, 'Join Recommended Events', 'おすすめイベントに参加');
  static String eventsCount(BuildContext context, int count) =>
      _getText(context, '$count events', '$count イベント');
  static String whoYouMeet(BuildContext context) =>
      _getText(context, "Who You'll Meet", '参加者');
  static String latestBookings(BuildContext context) =>
      _getText(context, 'Latest Bookings', '最新の予約');
  static String eventCalendar(BuildContext context) =>
      _getText(context, 'Event Calendar', 'イベントカレンダー');
  static String all(BuildContext context) => _getText(context, 'All', 'すべて');
  static String close(BuildContext context) =>
      _getText(context, 'Close', '閉じる');
  static String cancel(BuildContext context) =>
      _getText(context, 'Cancel', 'キャンセル');

  // Event Details
  static String eventDetails(BuildContext context) =>
      _getText(context, 'Event Details', 'イベント詳細');
  static String reserveTicket(BuildContext context) =>
      _getText(context, 'Reserve Ticket (Pay at venue)', 'チケット予約（会場払い）');
  static String soldOut(BuildContext context) =>
      _getText(context, 'Sold Out', '完売');
  static String male(BuildContext context) => _getText(context, 'Male', '男性');
  static String female(BuildContext context) =>
      _getText(context, 'Female', '女性');
  static String free(BuildContext context) => _getText(context, 'Free', '無料');
  static String venue(BuildContext context) => _getText(context, 'Venue', '会場');
  static String viewMap(BuildContext context) =>
      _getText(context, 'View Map', '地図を見る');
  static String shareApp(BuildContext context) =>
      _getText(context, 'Share Event', 'イベントを共有する');
  static String shareEventText(BuildContext context, String title) => _getText(
      context,
      'Check out $title on Best Evento!\nhttps://officialbestevent.wixsite.com/bestevento',
      'Best Eventoで「$title」をチェック！\nhttps://officialbestevent.wixsite.com/bestevento');
  static String venueAddress(BuildContext context) =>
      _getText(context, 'Venue Address', '会場住所');
  static String addToCalendar(BuildContext context) =>
      _getText(context, 'Add to Calendar', 'カレンダーに追加');
  static String pricing(BuildContext context) =>
      _getText(context, 'Pricing', '料金');
  static String aboutEvent(BuildContext context) =>
      _getText(context, 'About Event', 'イベントについて');
  static String mapUnavailable(BuildContext context) => _getText(
      context, 'Map link unavailable or insecure', 'マップリンクが利用できないか安全ではありません');
  static String mapError(BuildContext context, String err) =>
      _getText(context, 'Could not open map: $err', 'マップを開けませんでした: $err');
  static String reminderScheduled(BuildContext context) => _getText(
      context, 'Scheduled reminder & synced!', 'カレンダーに追加され、リマインダーが設定されました！');
  static String ticketBooked(BuildContext context) =>
      _getText(context, 'Ticket Booked', 'チケット取得済み');

  // Booking
  static String bookTicket(BuildContext context) =>
      _getText(context, 'Book Ticket', 'チケット予約');
  static String yourName(BuildContext context) =>
      _getText(context, 'Your Name', 'お名前');
  static String selectGender(BuildContext context) =>
      _getText(context, 'Select Gender', '性別を選択');
  static String confirmBooking(BuildContext context) =>
      _getText(context, 'Confirm Booking', '予約確定');

  // My Tickets
  static String myTickets(BuildContext context) =>
      _getText(context, 'My Tickets', 'マイチケット');
  static String noTicketsYet(BuildContext context) =>
      _getText(context, 'No tickets yet', 'チケットがありません');
  static String browseEvents(BuildContext context) =>
      _getText(context, 'Browse Events', 'イベントを見る');
  static String payAtVenue(BuildContext context) =>
      _getText(context, 'Pay at Venue', '会場払い');
  static String ticketId(BuildContext context) =>
      _getText(context, 'Ticket ID', 'チケットID');
  static String share(BuildContext context) => _getText(context, 'Share', '共有');
  static String cancelTickets(BuildContext context) =>
      _getText(context, 'Cancel Tickets', 'チケットキャンセル');
  static String cancelTicket(BuildContext context) =>
      _getText(context, 'Cancel Ticket', 'チケットキャンセル');
  static String viewTicket(BuildContext context) =>
      _getText(context, 'View Ticket', 'チケットを見る');
  static String cancelling(BuildContext context) =>
      _getText(context, 'Cancelling...', 'キャンセル中...');
  static String myTicketsTitle(BuildContext context) => _getText(
      context, 'My Tickets - Best Evento 🎉', 'マイチケット - Best Evento 🎉');

  // Profile
  static String language(BuildContext context) =>
      _getText(context, 'Language', '言語');
  static String theme(BuildContext context) =>
      _getText(context, 'Theme', 'テーマ');
  static String lightMode(BuildContext context) =>
      _getText(context, 'Light Mode', 'ライトモード');
  static String darkMode(BuildContext context) =>
      _getText(context, 'Dark Mode', 'ダークモード');
  static String loginWithCreator(BuildContext context) =>
      _getText(context, 'Login with Creator', 'クリエイターログイン');
  static String loginWithAdmin(BuildContext context) =>
      _getText(context, 'Login with Admin', '管理者ログイン');
  static String aboutApp(BuildContext context) =>
      _getText(context, 'About App', 'アプリについて');
  static String privacyPolicy(BuildContext context) =>
      _getText(context, 'Privacy Policy', 'プライバシーポリシー');
  static String eventCollaboration(BuildContext context) =>
      _getText(context, 'Event Collaboration Request', 'イベントコラボレーション依頼');
  static String commercialDisclosure(BuildContext context) =>
      _getText(context, 'Commercial Disclosure', '特定商取引法に基づく表記');
  static String cancellationPolicy(BuildContext context) =>
      _getText(context, 'Cancellation Policy', 'キャンセルポリシー');
  static String contactUs(BuildContext context) =>
      _getText(context, 'Contact Us', 'お問い合わせ');
  static String faq(BuildContext context) => _getText(context, 'FAQ', 'よくある質問');
  static String version(BuildContext context) =>
      _getText(context, 'Version', 'バージョン');

  // Creator
  static String creatorLogin(BuildContext context) =>
      _getText(context, 'Creator Login', 'クリエイターログイン');
  static String creatorDashboard(BuildContext context) =>
      _getText(context, 'Creator Dashboard', 'クリエイターダッシュボード');
  static String createEvent(BuildContext context) =>
      _getText(context, 'Create Event', 'イベント作成');
  static String editEvent(BuildContext context) =>
      _getText(context, 'Edit Event', 'イベント編集');
  static String deleteEvent(BuildContext context) =>
      _getText(context, 'Delete Event', 'イベント削除');
  static String eventStats(BuildContext context) =>
      _getText(context, 'Event Statistics', 'イベント統計');
  static String myEvents(BuildContext context) =>
      _getText(context, 'My Events', 'マイイベント');
  static String recurringEvent(BuildContext context) =>
      _getText(context, 'Recurring Event', '定期イベント');
  static String makeRecurring(BuildContext context) =>
      _getText(context, 'Make Recurring', '定期的にする');

  static String hiding(BuildContext context) =>
      _getText(context, 'Hiding...', '非表示中...');
  static String showing(BuildContext context) =>
      _getText(context, 'Showing...', '表示中...');
  static String duplicating(BuildContext context) =>
      _getText(context, 'Duplicating...', '複製中...');
  static String eventHidden(BuildContext context) =>
      _getText(context, 'Event hidden', 'イベントを非表示にしました');
  static String eventVisible(BuildContext context) =>
      _getText(context, 'Event visible', 'イベントを表示しました');
  static String deletingEvent(BuildContext context) =>
      _getText(context, 'Deleting event...', 'イベントを削除中...');

  // Admin

  static String adminLogin(BuildContext context) =>
      _getText(context, 'Admin Login', '管理者ログイン');
  static String adminDashboard(BuildContext context) =>
      _getText(context, 'Admin Dashboard', '管理者ダッシュボード');
  static String manageEvents(BuildContext context) =>
      _getText(context, 'Manage Events', 'イベント管理');
  static String manageCreators(BuildContext context) =>
      _getText(context, 'Manage Creators', 'クリエイター管理');
  static String manageLocations(BuildContext context) =>
      _getText(context, 'Manage Locations', 'ロケーション管理');
  static String analytics(BuildContext context) =>
      _getText(context, 'Analytics', '分析');

  static String adminDashboardSubtitle(BuildContext context) => _getText(
      context, 'Manage events, creators & tickets', 'イベント、クリエイター、チケットの管理');

  // Common
  static String email(BuildContext context) =>
      _getText(context, 'Email', 'メール');
  static String password(BuildContext context) =>
      _getText(context, 'Password', 'パスワード');
  static String login(BuildContext context) =>
      _getText(context, 'Login', 'ログイン');
  static String logout(BuildContext context) =>
      _getText(context, 'Logout', 'ログアウト');
  static String save(BuildContext context) => _getText(context, 'Save', '保存');
  static String delete(BuildContext context) =>
      _getText(context, 'Delete', '削除');
  static String edit(BuildContext context) => _getText(context, 'Edit', '編集');
  static String back(BuildContext context) => _getText(context, 'Back', '戻る');
  static String ok(BuildContext context) => _getText(context, 'OK', 'OK');
  static String yes(BuildContext context) => _getText(context, 'Yes', 'はい');
  static String no(BuildContext context) => _getText(context, 'No', 'いいえ');
  static String loading(BuildContext context) =>
      _getText(context, 'Loading...', '読み込み中...');
  static String error(BuildContext context) =>
      _getText(context, 'Error', 'エラー');
  static String success(BuildContext context) =>
      _getText(context, 'Success', '成功');

  // Languages
  static String english(BuildContext context) =>
      _getText(context, 'English', 'English');
  static String japanese(BuildContext context) =>
      _getText(context, 'Japanese', '日本語');

  // Messages
  static String bookingSuccess(BuildContext context) =>
      _getText(context, 'Ticket booked successfully!', 'チケットの予約が完了しました！');
  static String bookingError(BuildContext context) => _getText(
      context,
      'Failed to book ticket. Please try again.',
      'チケットの予約に失敗しました。もう一度お試しください。');
  static String alreadyBooked(BuildContext context) => _getText(context,
      'You already have a ticket for this event.', 'このイベントのチケットは既に予約済みです。');
  static String cancelConfirm(BuildContext context) => _getText(
      context,
      'Are you sure you want to cancel this ticket?',
      'このチケットをキャンセルしてもよろしいですか？');

  // Dialog Confirmations
  static String confirmLogout(BuildContext context) =>
      _getText(context, 'Do you want to logout?', 'ログアウトしますか？');
  static String confirmDeleteEvent(BuildContext context) => _getText(context,
      'Are you sure you want to delete this event?', 'このイベントを削除してもよろしいですか？');
  static String confirmDeleteLocation(BuildContext context) => _getText(
      context,
      'Are you sure you want to delete this location?',
      'このロケーションを削除してもよろしいですか？');
  static String confirmDeleteCreator(BuildContext context, String email) =>
      _getText(
          context,
          'Are you sure you want to delete $email?\n\nAll events created by this creator will also be deleted.',
          '$emailを削除してもよろしいですか？\n\nこのクリエイターが作成したすべてのイベントも削除されます。');
  static String confirmDeleteEventWithTickets(
          BuildContext context, String title) =>
      _getText(
          context,
          'Are you sure you want to delete "$title"?\n\nThis will also delete all tickets for this event.',
          '「$title」を削除してもよろしいですか？\n\nこのイベントのすべてのチケットも削除されます。');

  // Admin Dashboard
  static String totalEvents(BuildContext context) =>
      _getText(context, 'Total Events', '総イベント数');
  static String totalTickets(BuildContext context) =>
      _getText(context, 'Total Tickets', '総チケット数');
  static String quickActions(BuildContext context) =>
      _getText(context, 'Quick Actions', 'クイックアクション');
  static String createNewEvent(BuildContext context) =>
      _getText(context, 'Create a new event', '新しいイベントを作成');
  static String scanTicketQR(BuildContext context) =>
      _getText(context, 'Scan Ticket QR Code', 'チケットQRコードをスキャン');
  static String checkInAttendees(BuildContext context) =>
      _getText(context, 'Check-in attendees', '参加者チェックイン');
  static String manageEventCreators(BuildContext context) =>
      _getText(context, 'Manage event creators', 'イベントクリエイターを管理');
  static String locationsCount(BuildContext context, int count) =>
      _getText(context, '$count locations', '$count ロケーション');
  static String eventsCountSimple(BuildContext context, int count) =>
      _getText(context, '$count events', '$count イベント');

  // Creator Management
  static String addCreator(BuildContext context) =>
      _getText(context, 'Add Creator', 'クリエイターを追加');
  static String editCreator(BuildContext context) =>
      _getText(context, 'Edit Creator', 'クリエイターを編集');
  static String resetPassword(BuildContext context) =>
      _getText(context, 'Reset Password', 'パスワードをリセット');
  static String deleteCreator(BuildContext context) =>
      _getText(context, 'Delete Creator', 'クリエイターを削除');
  static String noCreatorsYet(BuildContext context) =>
      _getText(context, 'No creators yet', 'クリエイターがいません');
  static String creatorsMustBeAddedFromConsole(BuildContext context) =>
      _getText(context, 'Creators must be added from Firebase Console',
          'クリエイターはFirebase Consoleから追加してください');
  static String deletingCreator(BuildContext context) =>
      _getText(context, 'Deleting creator...', '削除中...');
  static String tapToAddCreator(BuildContext context) =>
      _getText(context, 'Tap + to add a creator', '+をタップしてクリエイターを追加');
  static String add(BuildContext context) => _getText(context, 'Add', '追加');
  static String reset(BuildContext context) =>
      _getText(context, 'Reset', 'リセット');
  static String creatorId(BuildContext context, String id) =>
      _getText(context, 'Creator ID: $id', 'クリエイターID: $id');
  static String creatorDeletedSuccess(BuildContext context) => _getText(
      context,
      'Creator and all their events deleted successfully',
      'クリエイターとすべてのイベントが削除されました');
  static String newPassword(BuildContext context) =>
      _getText(context, 'New Password', '新しいパスワード');
  static String confirmPassword(BuildContext context) =>
      _getText(context, 'Confirm Password', 'パスワードを確認');
  static String resetPasswordFor(BuildContext context, String email) =>
      _getText(context, 'Reset password for $email', '$emailのパスワードをリセット');

  // Location Management
  static String addLocation(BuildContext context) =>
      _getText(context, 'Add Location', 'ロケーションを追加');
  static String editLocation(BuildContext context) =>
      _getText(context, 'Edit Location', 'ロケーションを編集');
  static String deleteLocation(BuildContext context) =>
      _getText(context, 'Delete Location', 'ロケーションを削除');
  static String noLocationsYet(BuildContext context) =>
      _getText(context, 'No locations yet', 'ロケーションがありません');
  static String nameEnglish(BuildContext context) =>
      _getText(context, 'Name (English)', '名前（英語）');
  static String nameJapanese(BuildContext context) =>
      _getText(context, 'Name (Japanese)', '名前（日本語）');

  // Event Management
  static String noEventsYet(BuildContext context) =>
      _getText(context, 'No events yet', 'イベントがありません');
  static String eventDuplicatedSuccess(BuildContext context) =>
      _getText(context, 'Event duplicated successfully', 'イベントが複製されました');
  static String eventHiddenSuccess(BuildContext context) =>
      _getText(context, 'Event hidden successfully', 'イベントが非表示になりました');
  static String eventShownSuccess(BuildContext context) =>
      _getText(context, 'Event shown successfully', 'イベントが表示されました');
  static String show(BuildContext context) => _getText(context, 'Show', '表示');
  static String hide(BuildContext context) => _getText(context, 'Hide', '非表示');
  static String duplicate(BuildContext context) =>
      _getText(context, 'Duplicate', '複製');
  static String openMap(BuildContext context) =>
      _getText(context, 'Open Map', '地図を開く');

  // QR Scanner
  static String toggleFlash(BuildContext context) =>
      _getText(context, 'Toggle Flash', 'フラッシュ切替');
  static String switchCamera(BuildContext context) =>
      _getText(context, 'Switch Camera', 'カメラ切替');
  static String scanInstruction(BuildContext context) => _getText(context,
      'Position the QR code within the frame to scan', 'QRコードをフレーム内に配置してスキャン');
  static String invalidTicket(BuildContext context) =>
      _getText(context, 'Invalid Ticket', '無効なチケット');
  static String ticketNotFound(BuildContext context) => _getText(
      context,
      'Ticket not found. Please check the QR code.',
      'チケットが見つかりません。QRコードを確認してください。');
  static String checkInSuccessful(BuildContext context) =>
      _getText(context, 'Check-in Successful', 'チェックイン成功');
  static String ticketDetails(BuildContext context, String id, String name,
          String gender, String event) =>
      _getText(
          context,
          'Ticket ID: $id\nName: $name\nGender: $gender\nEvent: $event',
          'チケットID: $id\n名前: $name\n性別: $gender\nイベント: $event');
  static String alreadyCheckedIn(BuildContext context) =>
      _getText(context, 'Already Checked In', 'チェックイン済み');
  static String alreadyCheckedInAt(BuildContext context, String time) =>
      _getText(context, 'This ticket was already checked in at $time',
          'このチケットは$timeにチェックイン済みです');

  // Create Event
  static String repeatThisEvent(BuildContext context) =>
      _getText(context, 'Repeat this event', 'このイベントを繰り返す');
  static String dateChanged(BuildContext context) =>
      _getText(context, 'Date Changed', '日付が変更されました');
  static String yesDeleteTickets(BuildContext context) =>
      _getText(context, 'Yes, Delete Tickets', 'はい、チケットを削除');
  static String addDateTime(BuildContext context) =>
      _getText(context, 'Add Date & Time', '日時を追加');
  static String selectImageEn(BuildContext context) =>
      _getText(context, 'Select Image (English)', '画像を選択（英語）');
  static String selectImageJa(BuildContext context) =>
      _getText(context, 'Select Image (Japanese)', '画像を選択（日本語）');
  static String atLeastOneImageReq(BuildContext context) =>
      _getText(context, 'At least one image is required', '少なくとも1枚の画像が必要です');
  static String maxImagesReached(BuildContext context) =>
      _getText(context, 'Maximum 10 images reached', '最大10枚の画像に達しました');
  static String pickImageMax(BuildContext context, int count, int max) =>
      _getText(context, 'Pick Image ($count/$max) - Max 3MB',
          '画像を選択 ($count/$max) - 最大 3MB');

  // Profile & Contact
  static String line(BuildContext context) => _getText(context, 'LINE', 'LINE');
  static String openLine(BuildContext context) =>
      _getText(context, 'Open LINE', 'LINEを開く');
  static String noEmailApp(BuildContext context) =>
      _getText(context, 'No email app found', 'メールアプリが見つかりません');
  static String lineAppNotFound(BuildContext context) =>
      _getText(context, 'LINE app not found', 'LINEアプリが見つかりません');

  static String whatsapp(BuildContext context) =>
      _getText(context, 'WhatsApp', 'WhatsApp');
  static String openWhatsapp(BuildContext context) =>
      _getText(context, 'Open WhatsApp', 'WhatsAppを開く');
  static String whatsappAppNotFound(BuildContext context) =>
      _getText(context, 'WhatsApp app not found', 'WhatsAppアプリが見つかりません');

  // Error Messages

  static String pleaseFillAllFields(BuildContext context) =>
      _getText(context, 'Please fill all fields', 'すべてのフィールドを入力してください');
  static String emailCannotBeEmpty(BuildContext context) =>
      _getText(context, 'Email cannot be empty', 'メールアドレスを入力してください');
  static String passwordsDoNotMatch(BuildContext context) =>
      _getText(context, 'Passwords do not match', 'パスワードが一致しません');
  static String passwordResetSuccess(BuildContext context) =>
      _getText(context, 'Password reset successfully', 'パスワードがリセットされました');
  static String pleaseEnterEnglishName(BuildContext context) =>
      _getText(context, 'Please enter English name', '英語名を入力してください');

  // Stats
  static String totalBookings(BuildContext context) =>
      _getText(context, 'Total Bookings', '総予約数');
  static String allTickets(BuildContext context) =>
      _getText(context, 'All Tickets', '全チケット');
  static String deleteTicket(BuildContext context) =>
      _getText(context, 'Delete Ticket', 'チケットを削除');
  static String keepTicket(BuildContext context) =>
      _getText(context, 'Keep', '保持');

  // About App Screen
  static String about(BuildContext context) =>
      _getText(context, 'About', 'について');
  static String aboutDescription(BuildContext context) => _getText(
      context,
      'Best Evento is an event discovery and ticketing app that connects people with amazing local events.',
      'Best Eventoは、素晴らしい地元のイベントと人々をつなぐイベント発見・チケット販売アプリです。');
  static String languages(BuildContext context) =>
      _getText(context, 'Languages', '言語');
  static String contact(BuildContext context) =>
      _getText(context, 'Contact', '連絡先');
  static String copyright(BuildContext context) =>
      _getText(context, 'Copyright', '著作権');
  static String copyrightText(BuildContext context) => _getText(
      context,
      '© ${DateTime.now().year} Best Evento. All rights reserved.',
      '© ${DateTime.now().year} Best Evento. All rights reserved.');
  static String madeWithLove(BuildContext context) =>
      _getText(context, 'Made with ❤️ in Japan', '日本で❤️を込めて作成');
  static String versionLabel(BuildContext context) =>
      _getText(context, 'Version', 'バージョン');
  static String noBookingsYet(BuildContext context) =>
      _getText(context, 'No bookings yet', 'まだ予約がありません');
  static String recentBookingsEmpty(BuildContext context) =>
      _getText(context, 'Recent bookings will appear here.', 'ここに最新の予約が表示されます');
  static String recentBookings(BuildContext context) =>
      _getText(context, 'Recent Bookings', '最近の予約');
  static String scanned(BuildContext context) =>
      _getText(context, 'Scanned', 'スキャン済み');
  static String femaleRemaining(BuildContext context) =>
      _getText(context, 'Female Remaining', '女性の残り');
  static String femaleBookings(BuildContext context) =>
      _getText(context, 'Female Bookings', '女性の予約');
  static String maleRemaining(BuildContext context) =>
      _getText(context, 'Male Remaining', '男性の残り');
  static String maleBookings(BuildContext context) =>
      _getText(context, 'Male Bookings', '男性の予約');
  static String tapToViewAll(BuildContext context) =>
      _getText(context, 'Tap to view all', 'タップしてすべて表示');
  static String statusHidden(BuildContext context) =>
      _getText(context, 'HIDDEN', '非表示');
  static String statusDuplicated(BuildContext context) =>
      _getText(context, 'DUPLICATED', '複製済み');
  static String statusPastFuture(BuildContext context) =>
      _getText(context, 'PAST/FUTURE', '過去/未来');
  static String statusActive(BuildContext context) =>
      _getText(context, 'ACTIVE', '公開中');
  static String eventsCreatedCount(BuildContext context, int count) =>
      _getText(context, '$count events created', '$count イベント作成済み');
  static String noEventsCreatedYet(BuildContext context) =>
      _getText(context, 'No events created yet', '作成したイベントはまだありません');

  static String englishVersion(BuildContext context) =>
      _getText(context, 'English Version', '英語版');
  static String japaneseVersion(BuildContext context) =>
      _getText(context, 'Japanese Version', '日本語版');
  static String titleEnglish(BuildContext context) =>
      _getText(context, 'Title (English) *', 'タイトル (英語) *');
  static String locationEnglish(BuildContext context) =>
      _getText(context, 'Location (English) *', '場所 (英語) *');
  static String titleJapanese(BuildContext context) =>
      _getText(context, 'Title (Japanese)', 'タイトル (日本語)');
  static String venueDetails(BuildContext context) =>
      _getText(context, 'Venue Details', '会場詳細');
  static String venueNameEnglish(BuildContext context) =>
      _getText(context, 'Venue Name (English) *', '会場名 (英語) *');
  static String eventDateLabel(BuildContext context) =>
      _getText(context, 'Event Date', '開催日');
  static String startTimeLabel(BuildContext context) =>
      _getText(context, 'Start Time', '開始時間');
  static String endDateLabel(BuildContext context) =>
      _getText(context, 'End Date', '終了日');
  static String endTimeLabel(BuildContext context) =>
      _getText(context, 'End Time', '終了時間');
  static String malePriceLabel(BuildContext context) =>
      _getText(context, 'Male Price (¥) *', '男性料金 (¥) *');
  static String femalePriceLabel(BuildContext context) =>
      _getText(context, 'Female Price (¥) *', '女性料金 (¥) *');
  static String maleLimitLabel(BuildContext context) =>
      _getText(context, 'Male Limit *', '男性の制限 *');
  static String femaleLimitLabel(BuildContext context) =>
      _getText(context, 'Female Limit *', '女性の制限 *');
  static String hideEventLabel(BuildContext context) =>
      _getText(context, 'Hide Event', 'イベントを非表示にする');
  static String hideEventDesc(BuildContext context) => _getText(
      context, 'Hide this event from regular users', 'このイベントを一般ユーザーから隠します');
  static String recurringEventLabel(BuildContext context) =>
      _getText(context, 'Recurring Event', '定期イベント');

  static String allFilter(BuildContext context) =>
      _getText(context, 'All', 'すべて');
  static String activeFilter(BuildContext context) =>
      _getText(context, 'Active', '有効');
  static String totalLabel(BuildContext context) =>
      _getText(context, 'Total', '合計');

  static String ticketIdPrefix(BuildContext context, String id) =>
      _getText(context, 'Ticket ID: $id', 'チケットID: $id');

  static String adminAccessOnly(BuildContext context) =>
      _getText(context, 'Admin access only', '管理者アクセスのみ');
  static String adminLoginTitle(BuildContext context) =>
      _getText(context, 'Admin Login', '管理者ログイン');
  static String adminPortal(BuildContext context) =>
      _getText(context, 'Admin Portal', '管理者ポータル');
  static String exitAppTitle(BuildContext context) =>
      _getText(context, 'Exit App', 'アプリを終了');
  static String exitAppDesc(BuildContext context) =>
      _getText(context, 'Do you want to exit the app?', 'アプリを終了しますか？');
  static String webViewTitle(
          BuildContext context, String titleEn, String titleJa) =>
      _getText(context, titleEn, titleJa);
}
