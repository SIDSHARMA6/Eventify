class Location {
  final String id;
  final String nameEn;
  final String nameJa;
  final int order;

  Location({
    required this.id,
    required this.nameEn,
    required this.nameJa,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ja': nameJa,
      'order': order,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      nameEn: map['name_en'],
      nameJa: map['name_ja'],
      order: map['order'],
    );
  }
}
