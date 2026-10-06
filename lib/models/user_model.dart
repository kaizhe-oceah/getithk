class UserModel {
  int? id;
  String? name;
  String? image;
  String? email;
  String? dob;
  String? countryCode;
  String? phoneNo;

  String get phone => '${countryCode ?? ''}${phoneNo ?? ''}';

  UserModel({
    this.id,
    this.name,
    this.image,
    this.email,
    this.dob,
    this.countryCode,
    this.phoneNo,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    email = json['email'];
    dob = json['dob'];
    countryCode = json['country_code'];
    phoneNo = json['phone_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['email'] = email;
    data['dob'] = dob;
    data['country_code'] = countryCode;
    data['phone_no'] = phoneNo;

    return data;
  }
}
