class Group {
  final String id;
  final String name;
  final List<String> permissions;
  final List<String> memberIds;

  const Group({
    required this.id,
    required this.name,
    required this.permissions,
    required this.memberIds,
  });

  // Create a copy with updated fields
  Group copyWith({
    String? id,
    String? name,
    List<String>? permissions,
    List<String>? memberIds,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  factory Group.fromJson(Map<String, dynamic> json, String id) {
    return Group(
      id: id,
      name: json['name'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      memberIds: List<String>.from(json['member_ids'] ?? []),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'permissions': permissions,
      'member_ids': memberIds,
    };
  }
}
