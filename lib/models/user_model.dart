class UserModel {
  UserModel({required this.phone,required this.firstname,required this.lastname});
  final String firstname;
    final String lastname;
  final String phone;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phone: json['phone'],
      firstname: json['firstname'],
      lastname: json['lastname'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['phone'] = phone;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    return data;
  }
}
