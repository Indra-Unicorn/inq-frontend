class Category {
  final String name;
  final int rank;
  final String image;
  final String description;

  const Category({
    required this.name,
    required this.rank,
    required this.image,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      rank: json['rank'] as int,
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  /// Display name with first letter capitalised (API returns lowercase).
  String get displayName =>
      name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';
}
