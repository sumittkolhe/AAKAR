enum UserRole { child, parent, therapist }

abstract class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson();
  
  static User fromJson(Map<String, dynamic> json) {
    if (json['role'] == null) {
      throw Exception('Role is missing in JSON');
    }
    
    // Handle enum/string conversion properly
    final roleStr = json['role'].toString().replaceAll('UserRole.', '');
    final role = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => UserRole.child, // Default fallback
    );
    
    switch (role) {
      case UserRole.child:
        return ChildUser.fromJson(json);
      case UserRole.parent:
        return ParentUser.fromJson(json);
      case UserRole.therapist:
        return TherapistUser.fromJson(json);
    }
  }
}

class ChildUser extends User {
  final String parentId;
  final int age;
  final int totalXP;
  final int streaks;

  ChildUser({
    required String id,
    required String name,
    required String email,
    required this.parentId,
    this.age = 0,
    this.totalXP = 0,
    this.streaks = 0,
  }) : super(id: id, name: name, email: email, role: UserRole.child);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.toString(),
    'parentId': parentId,
    'age': age,
    'totalXP': totalXP,
    'streaks': streaks,
  };

  factory ChildUser.fromJson(Map<String, dynamic> json) {
    return ChildUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      parentId: json['parentId'] ?? '',
      age: json['age'] ?? 0,
      totalXP: json['totalXP'] ?? 0,
      streaks: json['streaks'] ?? 0,
    );
  }
}

class ParentUser extends User {
  final List<String> childIds;

  ParentUser({
    required String id,
    required String name,
    required String email,
    this.childIds = const [],
  }) : super(id: id, name: name, email: email, role: UserRole.parent);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.toString(),
    'childIds': childIds,
  };

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    return ParentUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      childIds: List<String>.from(json['childIds'] ?? []),
    );
  }
}

class TherapistUser extends User {
  final List<String> assignedChildIds;
  final String clinicName;

  TherapistUser({
    required String id,
    required String name,
    required String email,
    this.assignedChildIds = const [],
    this.clinicName = '',
  }) : super(id: id, name: name, email: email, role: UserRole.therapist);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.toString(),
    'assignedChildIds': assignedChildIds,
    'clinicName': clinicName,
  };

  factory TherapistUser.fromJson(Map<String, dynamic> json) {
    return TherapistUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      assignedChildIds: List<String>.from(json['assignedChildIds'] ?? []),
      clinicName: json['clinicName'] ?? '',
    );
  }
}
