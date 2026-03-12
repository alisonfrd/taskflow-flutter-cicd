import 'package:taskflow_app/bootstrap.dart';
import 'package:taskflow_app/core/config/app_config.dart';

Future<void> main() async {
  await bootstrap(const AppConfig(flavor: 'prod', appName: 'TaskFlow'));
}
