class HomeBanner {
  final String image;
  final String? link;

  HomeBanner({required this.image, this.link});

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      image: json['image'] as String? ?? '',
      link: json['link'] as String?,
    );
  }
}
