import 'dart:developer' as developer;
import '../models/challenge.dart';
import 'api_service.dart';

class ChallengeService {
  final ApiService _api;

  ChallengeService(this._api);

  Future<List<Challenge>> getOpenChallenges(String token) async {
    final response = await _api.get('/challenges', token);
    final list = response['data'] as List<dynamic>;
    return list
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Challenge>> getMyChallenges(String token) async {
    final response = await _api.get('/challenges/my', token);
    final list = response['data'] as List<dynamic>;
    return list
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Challenge> getChallengeDetails(int id, String token) async {
    final response = await _api.get('/challenges/$id', token);
    return Challenge.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Challenge> create(Map<String, dynamic> data, String token) async {
    final response = await _api.post('/challenges', data, token);
    return Challenge.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Challenge> join(int id, int position, String token) async {
    final response = await _api.post('/challenges/$id/join', {'position': position}, token);
    return Challenge.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<String> invite(int id, String phone, int position, String token) async {
    final response = await _api.post(
      '/challenges/$id/invite',
      {'phone': phone, 'position': position},
      token,
    );
    return response['message'] as String;
  }

  Future<Challenge> accept(int id, String token) async {
    final response = await _api.post('/challenges/$id/accept', {}, token);
    return Challenge.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<String> decline(int id, String token) async {
    final response = await _api.post('/challenges/$id/decline', {}, token);
    return response['message'] as String;
  }

  Future<String> start(int id, String token) async {
    final response = await _api.post('/challenges/$id/start', {}, token);
    return response['message'] as String;
  }

  Future<Challenge> submitScore(int id, List<Map<String, int>> sets, String token) async {
    final response = await _api.post('/challenges/$id/score', {'sets': sets}, token);
    return Challenge.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<String> cancel(int id, String token) async {
    final response = await _api.post('/challenges/$id/cancel', {}, token);
    return response['message'] as String;
  }

  Future<String> leave(int id, String token) async {
    final response = await _api.post('/challenges/$id/leave', {}, token);
    return response['message'] as String;
  }

  Future<List<Map<String, dynamic>>> searchPlayers(String phone, String token) async {
    final response = await _api.post('/challenges/search-player', {'phone': phone}, token);
    final list = response['data'] as List<dynamic>;
    return list.map((p) => p as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getClubs(String token) async {
    final response = await _api.get('/challenges/clubs', token);
    final list = response['data'] as List<dynamic>;
    return list.map((c) => c as Map<String, dynamic>).toList();
  }
}
