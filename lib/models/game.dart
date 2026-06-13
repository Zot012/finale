import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  final String name;
  final int appid;
  @JsonKey(name: 'header_image')
  final String headerImage;
  @JsonKey(name: 'large_capsule_image')
  final String largeCapsuleImage;
  @JsonKey(name: 'small_capsule_image')
  final String smallCapsuleImage;
  final double price;
  @JsonKey(name: 'discount_percent')
  final int discountPercent;
  final bool discounted;
  @JsonKey(name: 'original_price')
  final double originalPrice;
  @JsonKey(name: 'final_price')
  final double finalPrice;
  final String currency;
  @JsonKey(name: 'windows_available')
  final bool windowsAvailable;
  @JsonKey(name: 'mac_available')
  final bool macAvailable;
  @JsonKey(name: 'linux_available')
  final bool linuxAvailable;
  @JsonKey(name: 'streamingvideo_available')
  final bool streamingvideoAvailable;
  final double rating;
  final String released;
  @JsonKey(name: 'required_age')
  final int requiredAge;
  final String description;
  final List<String> screenshots;
  final List<String> genres;
  final List<String> developers;
  final List<String> categories;
  @JsonKey(name: 'review_score_desc')
  final String reviewScoreDesc;
  @JsonKey(name: 'review_total')
  final int reviewTotal;
  @JsonKey(name: 'review_positive_percent')
  final int reviewPositivePercent;
  final int players;
  @JsonKey(name: 'steam_url')
  final String steamUrl;

  Game({
    required this.name,
    required this.appid,
    required this.headerImage,
    this.largeCapsuleImage = '',
    this.smallCapsuleImage = '',
    required this.price,
    required this.discountPercent,
    this.discounted = false,
    this.originalPrice = 0.0,
    this.finalPrice = 0.0,
    this.currency = '',
    this.windowsAvailable = false,
    this.macAvailable = false,
    this.linuxAvailable = false,
    this.streamingvideoAvailable = false,
    required this.rating,
    required this.released,
    this.requiredAge = 0,
    required this.description,
    this.screenshots = const [],
    this.genres = const [],
    this.developers = const [],
    this.categories = const [],
    this.reviewScoreDesc = '',
    this.reviewTotal = 0,
    this.reviewPositivePercent = 0,
    this.players = 0,
    this.steamUrl = '',
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);
}
