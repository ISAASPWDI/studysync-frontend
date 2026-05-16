// lib/core/models/models.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? university;
  final String? career;
  final String? semester;
  final String? district;
  final List<String> technicalSkills;
  final List<String> interestAreas;
  final List<String> studyGoals;
  final String? availability;
  final String? groupSize;
  final String? bio;
  final bool onboardingCompleted;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.university,
    this.career,
    this.semester,
    this.district,
    this.technicalSkills = const [],
    this.interestAreas = const [],
    this.studyGoals = const [],
    this.availability,
    this.groupSize,
    this.bio,
    this.onboardingCompleted = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? university,
    String? career,
    String? semester,
    String? district,
    List<String>? technicalSkills,
    List<String>? interestAreas,
    List<String>? studyGoals,
    String? availability,
    String? groupSize,
    String? bio,
    bool? onboardingCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      university: university ?? this.university,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      district: district ?? this.district,
      technicalSkills: technicalSkills ?? this.technicalSkills,
      interestAreas: interestAreas ?? this.interestAreas,
      studyGoals: studyGoals ?? this.studyGoals,
      availability: availability ?? this.availability,
      groupSize: groupSize ?? this.groupSize,
      bio: bio ?? this.bio,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final skills = json['skills'] as Map<String, dynamic>?;
    final objectives = json['objectives'] as Map<String, dynamic>?;
    final location = profile?['location'] as Map<String, dynamic>?;

    String name = '';
    if (json['firstName'] != null || json['lastName'] != null) {
      final first = json['firstName']?.toString() ?? '';
      final last = json['lastName']?.toString() ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty && json['email'] != null) {
        name = json['email'].toString().split('@').first;
      }
    } else if (profile?['firstName'] != null || profile?['lastName'] != null) {
      final first = profile?['firstName']?.toString() ?? '';
      final last = profile?['lastName']?.toString() ?? '';
      name = '$first $last'.trim();
    } else if (json['email'] != null) {
      name = json['email'].toString().split('@').first;
    } else if (json['name'] != null) {
      name = json['name'].toString();
    }

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: name,
      email: json['email'] ?? '',
      avatarUrl: profile?['profilePicture'] ??
          json['avatarUrl'] ??
          json['photoURL'] ??
          json['picture'] ??
          json['avatar'],
      university: profile?['university'] ?? json['university'],
      career: profile?['faculty'] ?? json['career'],
      semester: (profile?['semester'] ?? json['semester'])?.toString(),
      district:
      location?['district'] ?? location?['city'] ?? json['district'],
      technicalSkills: List<String>.from(
          skills?['technical'] ?? json['technicalSkills'] ?? []),
      interestAreas: List<String>.from(
          skills?['interests'] ?? json['interestAreas'] ?? []),
      studyGoals: List<String>.from(
          objectives?['primary'] ?? json['studyGoals'] ?? []),
      availability:
      objectives?['timeAvailability'] ?? json['availability'],
      groupSize:
      objectives?['preferredGroupSize'] ?? json['groupSize'],
      bio: profile?['bio'] ?? json['bio'],
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }

  static String _parseName(
      Map<String, dynamic> json, Map<String, dynamic>? profile) {
    if (json['name'] != null && json['name'].toString().isNotEmpty) {
      return json['name'];
    }
    final first = profile?['firstName'] ?? json['firstName'] ?? '';
    final last = profile?['lastName'] ?? json['lastName'] ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return json['fullName'] ?? json['email'] ?? '';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': name.split(' ').first,
    'lastName':
    name.contains(' ') ? name.substring(name.indexOf(' ') + 1) : '',
    'email': email,
    'avatarUrl': avatarUrl,
    'university': university,
    'career': career,
    'semester': semester,
    'district': district,
    'technicalSkills': technicalSkills,
    'interestAreas': interestAreas,
    'studyGoals': studyGoals,
    'availability': availability,
    'groupSize': groupSize,
    'bio': bio,
    'onboardingCompleted': onboardingCompleted,
  };
}

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

// ============================================================
// RecommendedUser — refleja exactamente el DTO de NestJS:
// {
//   userId, name, age, location, university, faculty, semester,
//   bio, profilePicture, skills (List), interests (List),
//   objectives (List), timeAvailability, preferredGroupSize,
//   matchScore, distance, isOnline, lastActive,
//   showAge, showLocation, showSemester
// }
// ============================================================
class RecommendedUser {
  final String userId;
  final String name;
  final int age;
  final String? location;       // district / ciudad
  final String? university;
  final String? faculty;        // carrera
  final int semester;
  final String? bio;
  final String? avatarUrl;      // viene como "profilePicture" en JSON
  final List<String> technicalSkills;  // viene como "skills" (lista plana)
  final List<String> interestAreas;    // viene como "interests"
  final List<String> objectives;
  final String timeAvailability;
  final String preferredGroupSize;
  final double matchScore;
  final double distance;
  final bool isOnline;
  final DateTime? lastActive;
  final bool showAge;
  final bool showLocation;
  final bool showSemester;

  RecommendedUser({
    required this.userId,
    required this.name,
    this.age = 0,
    this.location,
    this.university,
    this.faculty,
    this.semester = 0,
    this.bio,
    this.avatarUrl,
    this.technicalSkills = const [],
    this.interestAreas = const [],
    this.objectives = const [],
    this.timeAvailability = 'No especificado',
    this.preferredGroupSize = 'No especificado',
    this.matchScore = 0,
    this.distance = 0,
    this.isOnline = false,
    this.lastActive,
    this.showAge = true,
    this.showLocation = true,
    this.showSemester = true,
  });

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    // El backend devuelve un objeto PLANO (no anidado)
    // "skills" es una List<String> directa
    final rawSkills = json['skills'];

    return RecommendedUser(
      userId: json['userId']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      name: json['name']?.toString().isNotEmpty == true
          ? json['name'].toString()
          : 'Usuario',
      age: (json['age'] as num?)?.toInt() ?? 0,
      location: json['location'] as String?,
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      semester: (json['semester'] as num?)?.toInt() ?? 0,
      bio: json['bio'] as String?,
      // "profilePicture" en JSON → avatarUrl en el modelo
      avatarUrl: json['profilePicture'] as String? ??
          json['avatarUrl'] as String? ??
          json['picture'] as String?,
      // "skills" es lista plana desde NestJS
      technicalSkills: rawSkills is List
          ? List<String>.from(rawSkills)
          : rawSkills is Map
          ? List<String>.from((rawSkills as Map)['technical'] ?? [])
          : [],
      // "interests" en JSON → interestAreas en el modelo
      interestAreas: List<String>.from(
          json['interests'] ?? json['interestAreas'] ?? []),
      objectives:
      List<String>.from(json['objectives'] ?? []),
      timeAvailability:
      json['timeAvailability'] as String? ?? 'No especificado',
      preferredGroupSize:
      json['preferredGroupSize'] as String? ?? 'No especificado',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] as bool? ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'].toString())
          : null,
      showAge: json['showAge'] as bool? ?? true,
      showLocation: json['showLocation'] as bool? ?? true,
      showSemester: json['showSemester'] as bool? ?? true,
    );
  }
}

class SwipeActionResult {
  final bool isMatch;
  final String? matchId;
  final String message;

  SwipeActionResult({
    required this.isMatch,
    this.matchId,
    required this.message,
  });

  factory SwipeActionResult.fromJson(Map<String, dynamic> json) {
    return SwipeActionResult(
      isMatch: json['isMatch'] as bool? ?? json['matched'] as bool? ?? false,
      matchId: json['matchId']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}

// Clase específica para el otherUser que viene en matches
// El backend (mapToOtherUserDTO) devuelve campos planos
class MatchUser {
  final String id;
  final String name;
  final String? avatarUrl;   // viene como "picture"
  final String? subject;     // primera skill técnica
  final String? university;
  final bool isOnline;
  final String? bio;

  MatchUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.subject,
    this.university,
    this.isOnline = false,
    this.bio,
  });

  factory MatchUser.fromJson(Map<String, dynamic> json) {
    return MatchUser(
      id:          json['id']?.toString() ?? '',
      name:        json['name']?.toString() ?? 'Usuario',
      avatarUrl:   json['picture'] as String?,   // el backend manda "picture"
      subject:     json['subject'] as String?,
      university:  json['university'] as String?,
      isOnline:    json['isOnline'] as bool? ?? false,
      bio:         json['bio'] as String?,
    );
  }
}

// Reemplaza MatchModel completo:
class MatchModel {
  final String id;
  final String matchId;
  final MatchUser otherUser;   // ← ahora usa MatchUser, no UserModel
  final String status;
  final DateTime createdAt;
  final String? lastMessage;
  final double? matchScore;

  MatchModel({
    required this.id,
    required this.matchId,
    required this.otherUser,
    required this.status,
    required this.createdAt,
    this.lastMessage,
    this.matchScore,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ??
        json['matchId']?.toString() ??
        json['_id']?.toString() ??
        '';
    return MatchModel(
      id:          rawId,
      matchId:     rawId,
      otherUser:   MatchUser.fromJson(
          json['otherUser'] as Map<String, dynamic>? ?? {}),
      status:      json['status']?.toString() ?? 'pending',
      createdAt:   DateTime.tryParse(
          json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastMessage: json['lastMessage'] as String?,
      matchScore:  (json['matchScore'] as num?)?.toDouble(),
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool read;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.read = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      content: json['content'] ?? json['message'] ?? '',
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      read: json['read'] as bool? ?? false,
    );
  }
}

class ChatModel {
  final String id;
  final String matchId;
  final UserModel otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.matchId,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      matchId: json['matchId']?.toString() ?? '',
      otherUser:
      UserModel.fromJson(json['otherUser'] ?? json['user'] ?? {}),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}