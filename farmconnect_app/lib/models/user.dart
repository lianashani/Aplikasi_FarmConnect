class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;

  UserModel({required this.id, required this.name, required this.email, this.role});

  factory UserModel.fromJson(Map<String, dynamic> j) {
    final src = (j['user'] is Map<String, dynamic>) ? (j['user'] as Map<String, dynamic>) : j;
    return UserModel(
      id: (src['id'] ?? src['id_petani']) is int
          ? (src['id'] ?? src['id_petani']) as int
          : int.parse((src['id'] ?? src['id_petani']).toString()),
      name: (src['name'] ?? src['nama_petani'] ?? '').toString(),
      email: (src['email'] ?? '').toString(),
      role: src['role']?.toString(),
    );
  }
}
