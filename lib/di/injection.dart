import 'package:get_it/get_it.dart';
import 'package:hygge_app/di/injection.config.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
