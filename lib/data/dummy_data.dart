class DummyData {
  static List<Map<String, dynamic>> events = [
    {
      'id': '1',
      'title_en': 'Saturday Night Meetup',
      'title_ja': '土曜日の夜の集まり',
      'description_en':
          'Join us for an amazing evening of networking and fun! Meet new people, enjoy great food, and create lasting memories.\n\n**Important:** Please arrive on time.\n*Dress code:* Smart casual\n\nWebsite: https://example.com',
      'description_ja':
          '素晴らしい夜のネットワーキングと楽しみにご参加ください！新しい人々と出会い、美味しい料理を楽しみ、lasting memoriesを作りましょう。',
      'images_en': [
        'assets/e1.jpg',
        'assets/e2.jpg',
        'assets/e3.jpg',
        'assets/e4.jpg',
      ],
      'images_ja': [
        'assets/e1.jpg',
        'assets/e2.jpg',
        'assets/e3.jpg',
        'assets/e4.jpg',
      ],
      'location_en': 'Tokyo',
      'location_ja': '東京',
      'date': '2026-02-28',
      'startTime': '18:10',
      'endTime': '23:00',
      'endDate': '2026-02-28',
      'venueName': 'Shibuya Event Hall',
      'venueName_en': 'Shibuya Event Hall',
      'venueName_ja': '渋谷イベントホール',
      'venueAddress_en': '1-2-3 Shibuya, Shibuya-ku, Tokyo 150-0002',
      'venueAddress_ja': '東京都渋谷区渋谷1-2-3 150-0002',
      'mapLink': 'https://maps.google.com/?q=Shibuya+Event+Hall',
      'malePrice': 100,
      'femalePrice': 0,
      'maleLimit': 50,
      'femaleLimit': 50,
      'maleBooked': 15,
      'femaleBooked': 20,
    },
    {
      'id': '2',
      'title_en': 'Sunday Brunch Social',
      'title_ja': '日曜日のブランチソーシャル',
      'description_en':
          'Enjoy a relaxing Sunday brunch with fellow expats and locals. Great food, great company!',
      'description_ja':
          '仲間の外国人や地元の人々と一緒にリラックスした日曜日のブランチをお楽しみください。素晴らしい料理、素晴らしい仲間！',
      'images_en': [
        'assets/e2.jpg',
        'assets/e3.jpg',
        'assets/e4.jpg',
        'assets/e1.jpg',
      ],
      'images_ja': [
        'assets/e2.jpg',
        'assets/e3.jpg',
        'assets/e4.jpg',
        'assets/e1.jpg',
      ],
      'location_en': 'Osaka',
      'location_ja': '大阪',
      'date': '2026-03-05',
      'startTime': '11:00',
      'endTime': '14:00',
      'endDate': '2026-03-05',
      'venueName': 'Namba Cafe',
      'venueName_en': 'Namba Cafe',
      'venueName_ja': '難波カフェ',
      'venueAddress_en': '4-5-6 Namba, Chuo-ku, Osaka 542-0076',
      'venueAddress_ja': '大阪府大阪市中央区難波4-5-6 542-0076',
      'mapLink': 'https://maps.google.com/?q=Namba+Cafe',
      'malePrice': 50,
      'femalePrice': 50,
      'maleLimit': 30,
      'femaleLimit': 30,
      'maleBooked': 10,
      'femaleBooked': 12,
    },
  ];

  static List<Map<String, dynamic>> tickets = [];

  static List<Map<String, dynamic>> locations = [
    {'name_en': 'All', 'name_ja': 'すべて'},
    {'name_en': 'Tokyo', 'name_ja': '東京'},
    {'name_en': 'Osaka', 'name_ja': '大阪'},
    {'name_en': 'Kyoto', 'name_ja': '京都'},
    {'name_en': 'Yokohama', 'name_ja': '横浜'},
  ];

  static List<Map<String, dynamic>> latestBookings = [
    {
      'eventName_en': 'Saturday Night Meetup',
      'eventName_ja': '土曜日の夜の集まり',
      'timestamp': '2026-02-14 14:30:45',
    },
    {
      'eventName_en': 'Sunday Brunch Social',
      'eventName_ja': '日曜日のブランチソーシャル',
      'timestamp': '2026-02-14 13:22:15',
    },
    {
      'eventName_en': 'Saturday Night Meetup',
      'eventName_ja': '土曜日の夜の集まり',
      'timestamp': '2026-02-14 12:10:30',
    },
  ];

  // Helper to add booking to latest bookings (keeps only last 3)
  static void addLatestBooking(Map<String, dynamic> booking) {
    latestBookings.insert(0, booking);
    if (latestBookings.length > 3) {
      latestBookings = latestBookings.take(3).toList();
    }
  }
}
