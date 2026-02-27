class Event {
  final String id;
  final String titleEn;
  final String titleJa;
  final String descriptionEn;
  final String descriptionJa;
  final List<String> imagesEn;
  final List<String> imagesJa;
  final String locationEn;
  final String locationJa;
  final String date;
  final String startTime;
  final String endTime;
  final String venueName;
  final String mapLink;
  final int malePrice;
  final int femalePrice;
  final int maleLimit;
  final int femaleLimit;
  final int maleBooked;
  final int femaleBooked;
  final bool isHidden;

  Event({
    required this.id,
    required this.titleEn,
    required this.titleJa,
    required this.descriptionEn,
    required this.descriptionJa,
    required this.imagesEn,
    required this.imagesJa,
    required this.locationEn,
    required this.locationJa,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venueName,
    required this.mapLink,
    required this.malePrice,
    required this.femalePrice,
    required this.maleLimit,
    required this.femaleLimit,
    required this.maleBooked,
    required this.femaleBooked,
    this.isHidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_ja': titleJa,
      'description_en': descriptionEn,
      'description_ja': descriptionJa,
      'images_en': imagesEn,
      'images_ja': imagesJa,
      'location_en': locationEn,
      'location_ja': locationJa,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'venueName': venueName,
      'mapLink': mapLink,
      'malePrice': malePrice,
      'femalePrice': femalePrice,
      'maleLimit': maleLimit,
      'femaleLimit': femaleLimit,
      'maleBooked': maleBooked,
      'femaleBooked': femaleBooked,
      'isHidden': isHidden,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      titleEn: map['title_en'],
      titleJa: map['title_ja'],
      descriptionEn: map['description_en'],
      descriptionJa: map['description_ja'],
      imagesEn: List<String>.from(map['images_en']),
      imagesJa: List<String>.from(map['images_ja']),
      locationEn: map['location_en'],
      locationJa: map['location_ja'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      venueName: map['venueName'],
      mapLink: map['mapLink'],
      malePrice: map['malePrice'],
      femalePrice: map['femalePrice'],
      maleLimit: map['maleLimit'],
      femaleLimit: map['femaleLimit'],
      maleBooked: map['maleBooked'],
      femaleBooked: map['femaleBooked'],
      isHidden: map['isHidden'] ?? false,
    );
  }
}
