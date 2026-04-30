import 'package:hygge_app/data/models/user_model.dart';

/// Interface for managing user data.
///
/// This repository handles fetching the current authenticated user information.
abstract class UserRepository {
  /// Fetch the current authenticated user.
  ///
  /// Returns the [UserModel] if a user is authenticated, [UserModel.empty] otherwise.
  Future<UserModel> getCurrentUser();
}
