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
      rating: map['rating'].toDouble(),
      ratingCount: map['ratingCount'],
      totalRatingScore: map['totalRatingScore'].toDouble(),
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
