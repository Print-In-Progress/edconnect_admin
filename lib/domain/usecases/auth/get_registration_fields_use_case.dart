import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';

class GetRegistrationFieldsUseCase {
  final UserRepository _userRepository;

  GetRegistrationFieldsUseCase(this._userRepository);

  Future<List<BaseRegistrationField>> execute() {
    return _userRepository.getRegistrationFields();
  }
}
