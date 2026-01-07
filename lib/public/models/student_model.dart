class Student {
  final String id; // uid
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String parentPhone;
  final String grade; // e.g., "Grade 1"
  final String className; // e.g., "A"
  final String fees;
  final String urlAvatar;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.parentPhone,
    required this.grade,
    required this.className,
    required this.fees,
    required this.urlAvatar,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['uid'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      grade: json['grade'] ?? '',
      className: json['class_name'] ?? '',
      fees: json['fees'] ?? '',
      urlAvatar: json['urlAvatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'parent_phone': parentPhone,
      'grade': grade,
      'class_name': className,
      'fees': fees,
      'urlAvatar': urlAvatar,
    };
  }
}
