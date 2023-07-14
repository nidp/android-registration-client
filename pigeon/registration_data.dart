import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class RegistrationDataApi {
  @async
  bool startRegistration(List<String> languages);

  @async
  bool checkMVEL(String expression);

  @async
  String getPreviewTemplate(bool isPreview);
}