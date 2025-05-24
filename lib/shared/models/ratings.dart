class Ratings {
  final double rating;
  final int ratingCount;
  final double totalRatingScore;

  Ratings({
    required this.rating,
    required this.ratingCount,
    required this.totalRatingScore,
  });

  factory Ratings.fromMap(Map<String, dynamic> map) {
    return Ratings(
      rating: map['rating'] != null ? map['rating'].toDouble() : 0,
      ratingCount: map['ratingCount'] ?? 0,
      totalRatingScore: map['totalRatingScore']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'ratingCount': ratingCount,
      'totalRatingScore': totalRatingScore,
    };
  }
}
