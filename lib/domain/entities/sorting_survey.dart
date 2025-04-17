import 'package:cloud_firestore/cloud_firestore.dart';

enum SortingSurveyStatus {
  draft,
  published,
  closed,
}

enum SurveySortOrder {
  newestFirst,
  oldestFirst,
  alphabetical,
  status,
}

class SortingSurvey {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final SortingSurveyStatus status;
  final String creatorId;
  final String creatorName;
  final List<String> respondentsUsers;
  final List<String> respondentsGroups;
  final List<String> editorUsers;
  final List<String> editorGroups;
  final List<Map<String, dynamic>> parameters;
  final Map<String, dynamic> responses;
  final int? maxPreferences;
  final bool askBiologicalSex;

  const SortingSurvey({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.creatorId,
    required this.creatorName,
    required this.respondentsUsers,
    required this.respondentsGroups,
    required this.editorUsers,
    required this.editorGroups,
    required this.parameters,
    required this.responses,
    this.maxPreferences,
    required this.askBiologicalSex,
  });

  factory SortingSurvey.fromMap(Map<String, dynamic> map, String docId) {
    return SortingSurvey(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      status: _mapStatusFromString(map['status'] ?? 'draft'),
      creatorId: map['creator_id'] ?? '',
      creatorName: map['creator_name'] ?? '',
      respondentsUsers: List<String>.from(map['respondents_users'] ?? []),
      respondentsGroups: List<String>.from(map['respondents_groups'] ?? []),
      editorUsers: List<String>.from(map['editor_users'] ?? []),
      editorGroups: List<String>.from(map['editor_groups'] ?? []),
      parameters: List<Map<String, dynamic>>.from(map['parameters'] ?? []),
      responses: map['responses'] ?? {},
      maxPreferences: map['max_preferences'],
      askBiologicalSex: map['ask_biological_sex'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_at': Timestamp.fromDate(createdAt),
      'status': _mapStatusToString(status),
      'creator_id': creatorId,
      'creator_name': creatorName,
      'respondents_users': respondentsUsers,
      'respondents_groups': respondentsGroups,
      'editor_users': editorUsers,
      'editor_groups': editorGroups,
      'parameters': parameters,
      'responses': responses,
      'max_preferences': maxPreferences,
      'ask_biological_sex': askBiologicalSex,
    };
  }

  static SortingSurveyStatus _mapStatusFromString(String status) {
    switch (status) {
      case 'published':
        return SortingSurveyStatus.published;
      case 'closed':
        return SortingSurveyStatus.closed;
      case 'draft':
      default:
        return SortingSurveyStatus.draft;
    }
  }

  static String _mapStatusToString(SortingSurveyStatus status) {
    switch (status) {
      case SortingSurveyStatus.published:
        return 'published';
      case SortingSurveyStatus.closed:
        return 'closed';
      case SortingSurveyStatus.draft:
        return 'draft';
    }
  }

  SortingSurvey copyWith({
    String? title,
    String? description,
    DateTime? createdAt,
    SortingSurveyStatus? status,
    String? creatorId,
    String? creatorName,
    List<String>? respondentsUsers,
    List<String>? respondentsGroups,
    List<String>? editorUsers,
    List<String>? editorGroups,
    List<Map<String, dynamic>>? parameters,
    Map<String, dynamic>? responses,
    int? maxPreferences,
    bool? askBiologicalSex,
  }) {
    return SortingSurvey(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      respondentsUsers: respondentsUsers ?? this.respondentsUsers,
      respondentsGroups: respondentsGroups ?? this.respondentsGroups,
      editorUsers: editorUsers ?? this.editorUsers,
      editorGroups: editorGroups ?? this.editorGroups,
      parameters: parameters ?? this.parameters,
      responses: responses ?? this.responses,
      maxPreferences: maxPreferences ?? this.maxPreferences,
      askBiologicalSex: askBiologicalSex ?? this.askBiologicalSex,
    );
  }
}
