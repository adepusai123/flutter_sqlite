class Contact {
  static const tblContact = 'contacts';
  static const colId = 'id';
  static const colName = 'name';
  static const colMobile = 'mobile';
  Contact({this.id, this.name, this.mobile});

  Contact.fromMap(Map<String, dynamic> map) {
    // for reteriving the list we need convert to contact model
    id = map[colId];
    name = map[colName];
    mobile = map[colMobile];
  }

  int id;
  String name;
  String mobile;

  Map<String, dynamic> toMap() {
// Note: For saving into SQLite we need convert contact object into Map object
    var map = <String, dynamic>{colName: name, colMobile: mobile};
    if (id != null) map[colId] = id;
    return map;
  }
}
