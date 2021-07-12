import 'mynumber_command_error.dart';

class MynumberException implements Exception {
  final MynumberCommandError error;

  const MynumberException(this.error);
}