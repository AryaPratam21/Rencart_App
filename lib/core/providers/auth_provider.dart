import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../appwrite_constants.dart';

class AuthController {
  final appwrite.Account _account;

  AuthController(appwrite.Client client) : _account = appwrite.Account(client);

  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      return null;
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  final client = appwrite.Client()
    ..setEndpoint('http://localhost/v1')
    ..setProject(AppwriteConstants.projectId)
    ..setSelfSigned();

  return AuthController(client);
});
