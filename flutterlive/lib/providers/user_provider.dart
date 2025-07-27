import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final userProvider = Provider<User>((ref) {
  return const User(
    id: 'user-1',
    name: 'Sophia Carter',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMgW1pdshNEwtMnjidyMBkPM1F-Qsv_eFRBiwPGDyzHLT3TFrWl81oUdZTTBu2GWqW_-wxYCALZBPBE0qSHiuK5Iqgi3FBXarzwncaIcIe0rW4ZTXyUr0OLsZe1iys5RMEbqq0FzixvoJwX6QvBuxc0Rt4kk_pqhbbm2bbWnW63Bo_bHJkZ_8QiMIClphmnGCgcpXTQnj_ii-Ujc8Xd3vbwM7IyHYDFld_SxIo76ZRpgw_XdKtg_YSS3MwZ_6CBuvd4Yrxgz4fmB1C',
    age: '28',
    height: '170 cm',
    weightLossGoal: 'Lose 5 kg',
  );
});