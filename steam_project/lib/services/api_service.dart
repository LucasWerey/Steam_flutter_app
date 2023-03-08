import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/game.dart';

Future<List<int>> fetchAppIds() async {
  final response = await http.get(Uri.parse(
      'https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/?'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final ranks = data['response']['ranks'];
    return ranks.map<int>((rank) => rank['appid'] as int).toList();
  } else {
    throw Exception('Failed to load app IDs');
  }
}

Future<Map<String, dynamic>> fetchAppDetails(int appId) async {
  final response = await http.get(
      Uri.parse('https://store.steampowered.com/api/appdetails?appids=$appId'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final appDetails = data['$appId']['data'];

    final priceOverview = appDetails['price_overview'];
    final price =
        priceOverview != null ? priceOverview['final_formatted'] : 'N/A';

    return {
      'name': appDetails['name'] ?? 'N/A',
      'image': appDetails['header_image'],
      'background': appDetails['background'],
      'developers': appDetails['developers'],
      'free': appDetails['is_free'] == true ? 'Gratuit' : price
    };
  } else {
    throw Exception('Failed to load app details');
  }
}

Future<Game> fetchGame(int appId) async {
  final response = await http.get(
      Uri.parse('https://store.steampowered.com/api/appdetails?appids=$appId'));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body)['$appId']['data'];
    bool isFree = json['is_free'];

    String? final_formatted;
    if (!isFree) {
      final_formatted = json['price_overview'] != null
          ? json['price_overview']['final_formatted']
          : 'N/A';
    }

    return Game(
      steam_appid: json['steam_appid'].toString(),
      name: json['name'],
      isFree: isFree,
      shortDescription: json['short_description'],
      description: json['about_the_game'],
      headerImage: json['header_image'],
      developers: List<String>.from(json['developers']),
      backgroundRaw: json['background_raw'],
      background: json['background'] ?? '',
      final_formatted: final_formatted,
    );
  } else {
    throw Exception('Failed to fetch game');
  }
}

Future<List<Map<String, dynamic>>> fetchGameReview(int appId) async {
  final res = await http.get(
      Uri.parse('https://store.steampowered.com/appreviews/$appId?json=1'));
  if (res.statusCode == 200) {
    final data = json.decode(res.body);
    final reviews = data['reviews'];
    final querySummary = data['query_summary'];
    final reviewSocre = querySummary['review_score'];
    final reviewSocreDesc = querySummary['review_score_desc'];
    final result = <Map<String, dynamic>>[];
    for (final review in reviews) {
      final authorId = review['author']['steamid'];
      final reviewText = review['review'];
      result.add({
        'steamid': authorId,
        'review_score': reviewSocre,
        'review_score_desc': reviewSocreDesc,
        'review': reviewText,
      });
    }
    return result;
  } else {
    throw Exception('Failed to fetch game reviews');
  }
}