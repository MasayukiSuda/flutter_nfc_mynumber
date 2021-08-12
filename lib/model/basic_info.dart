class BasicInfo {
  final String name;
  final String address;
  final String birthDay;
  final Gender gender;
  BasicInfo(this.name, this.address, this.birthDay, this.gender);
}

enum Gender{
  MEN,
  WOMEN,
  OTHER
}