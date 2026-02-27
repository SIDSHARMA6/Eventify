class Ticket {
  final String id;
  final String eventId;
  final String eventTitleEn;
  final String eventTitleJa;
  final String eventDate;
  final String eventTime;
  final String userName;
  final String gender;
  final String timestamp;

  Ticket({
    required this.id,
    required this.eventId,
    required this.eventTitleEn,
    required this.eventTitleJa,
    required this.eventDate,
    required this.eventTime,
    required this.userName,
    required this.gender,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle_en': eventTitleEn,
      'eventTitle_ja': eventTitleJa,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'userName': userName,
      'gender': gender,
      'timestamp': timestamp,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      eventId: map['eventId'],
      eventTitleEn: map['eventTitle_en'],
      eventTitleJa: map['eventTitle_ja'],
      eventDate: map['eventDate'],
      eventTime: map['eventTime'],
      userName: map['userName'],
      gender: map['gender'],
      timestamp: map['timestamp'],
    );
  }
}
