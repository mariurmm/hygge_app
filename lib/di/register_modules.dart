import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  Logger get logger => Logger(
    level: kReleaseMode ? Level.warning : Level.trace,
    printer: kReleaseMode ? SimplePrinter() : PrettyPrinter(),
    output: ConsoleOutput(),
  );
}
