class EmployeeModel {
  final String id;
  final String companyId;
  final String name;
  final String employeeId;
  final String? department;
  final String? designation;
  final bool isFaceRegistered;
  final bool isActive;
  final String? email;
  final String role;

  const EmployeeModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.employeeId,
    this.department,
    this.designation,
    required this.isFaceRegistered,
    required this.isActive,
    this.email,
    this.role = 'employee',
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      employeeId: json['employee_id'] as String? ?? '',
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      isFaceRegistered: json['is_face_registered'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'employee',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'employee_id': employeeId,
        'department': department,
        'designation': designation,
        'is_face_registered': isFaceRegistered,
        'is_active': isActive,
        'email': email,
        'role': role,
      };

  EmployeeModel copyWith({
    String? id,
    String? companyId,
    String? name,
    String? employeeId,
    String? department,
    String? designation,
    bool? isFaceRegistered,
    bool? isActive,
    String? email,
    String? role,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      isFaceRegistered: isFaceRegistered ?? this.isFaceRegistered,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
