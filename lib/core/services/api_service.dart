// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/models.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    print('STATUS CODE: ${response.statusCode}');
    print('RAW BODY: ${response.body}');
    final body = jsonDecode(response.body);
    print('DECODED BODY: $body');
    print('TYPE: ${body.runtimeType}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    throw ApiException(
      message: parseMessage(body['message']),
      statusCode: response.statusCode,
    );
  }
  String parseMessage(dynamic message) {
    if (message is List) {
      return message.join(', ');
    }
    return message?.toString() ?? 'Error desconocido';
  }
  // ==================== AUTH ====================

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handleResponse(response);
    return AuthResponse.fromJson(data);
  }

  Future<UserModel> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode(userData),
    );
    final data = await _handleResponse(response);
    return UserModel.fromJson(data);
  }

  Future<bool> verifyToken() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/verify'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/logout'),
        headers: await _headers(),
      );
    } catch (_) {}
  }

  Future<AuthResponse> loginWithGoogleMobile(String idToken) async {
    debugPrint('📤 Enviando request a /auth/google/mobile');
    debugPrint('📦 Body: {"idToken": "${idToken.substring(0, 50)}...", "action": "login"}');

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/google/mobile'),
        headers: await _headers(auth: false),
        body: jsonEncode({
          'idToken': idToken,
          'action': 'login'
        }),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      final data = await _handleResponse(response);
      return AuthResponse.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error en loginWithGoogleMobile: $e');
      rethrow;
    }
  }

  Future<AuthResponse> registerWithGoogleMobile(String idToken) async {
    debugPrint('📤 Enviando request a /auth/google/mobile para registro');

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/google/mobile'),
        headers: await _headers(auth: false),
        body: jsonEncode({
          'idToken': idToken,
          'action': 'register'
        }),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      final data = await _handleResponse(response);
      return AuthResponse.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error en registerWithGoogleMobile: $e');
      rethrow;
    }
  }
  // ==================== MATCHES ====================

  Future<List<MatchModel>> getPendingReceivedMatches({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/matches/pending/received?page=$page&limit=$limit'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    final list = data['data'] ?? [];
    return (list as List).map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<List<MatchModel>> getSentMatches({
    int page = 1,
    int limit = 20,
    String status = 'all',
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/matches/pending/sent?page=$page&limit=$limit&status=$status'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    print('SENT MATCHES DATA: ${data}');
    final list = data['data'] ?? [];
    return (list as List).map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<List<MatchModel>> getConfirmedMatches({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/matches/confirmed?page=$page&limit=$limit'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    final list = data['data'] ?? [];
    return (list as List).map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<void> acceptMatch(String matchId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/matches/$matchId/accept'),
      headers: await _headers(),
    );
  }

  Future<void> rejectMatch(String matchId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/matches/$matchId/reject'),
      headers: await _headers(),
    );
  }

  // ==================== SWIPE ====================

  Future<List<RecommendedUser>> getRecommendations({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/swipe/recommendations?limit=$limit'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    final list = data['recommendations'] ?? data['data'] ?? data['users'] ?? [];
    return (list as List).map((e) => RecommendedUser.fromJson(e)).toList();
  }

  Future<SwipeActionResult> swipeAction({
    required String targetUserId,
    required String action, // 'like' or 'pass'
    double matchScore = 0,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/swipe/action'),
      headers: await _headers(),
      body: jsonEncode({
        'targetUserId': targetUserId,
        'action': action,
        'matchScore': matchScore,
      }),
    );
    final data = await _handleResponse(response);
    return SwipeActionResult.fromJson(data);
  }

  Future<void> syncProfile() async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/swipe/sync-profile'),
      headers: await _headers(),
    );
  }
  Future<void> upsertProfile(Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/users/profile'),
      headers: await _headers(), // con auth token
      body: jsonEncode(body),
    );
    debugPrint('UPSERT STATUS: ${response.statusCode}');
    debugPrint('UPSERT BODY: ${response.body}');
    await _handleResponse(response);
  }
  // ==================== MESSAGES ====================

  Future<String> createChat(String matchId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/messages/chats/$matchId'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    return data['chatId']?.toString() ?? '';
  }

  Future<List<MessageModel>> getMessages(String chatId, {int page = 1, int limit = 50}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/messages/chats/$chatId?page=$page&limit=$limit'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    final list = data['messages'] ?? data['data'] ?? [];
    return (list as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(String chatId, List<String> messageIds) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/messages/chats/$chatId/read'),
      headers: await _headers(),
      body: jsonEncode({'messageIds': messageIds}),
    );
  }

  Future<void> deleteMessage(String messageId) async {
    await http.delete(
      Uri.parse('${AppConstants.baseUrl}/messages/$messageId'),
      headers: await _headers(),
    );
  }

  Future<int> getUnreadCount(String chatId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/messages/chats/$chatId/unread-count'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    return data['unreadCount'] ?? 0;
  }
}


class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException({required this.message, required this.statusCode});
  
  @override
  String toString() => 'ApiException($statusCode): $message';
}
