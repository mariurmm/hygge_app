import 'package:hygge_app/data/models/localized_value.dart';
import 'package:hygge_app/data/models/program_model.dart';

abstract class ProgramsRepository {
  Future<List<ProgramModel>> fetchPrograms({
    int? limit,
    String locale = LocalizedValue.defaultLocale,
  });

  Stream<List<ProgramModel>> watchPrograms({
    int? limit,
    String locale = LocalizedValue.defaultLocale,
  });

  Future<ProgramModel?> fetchProgramById(
    String programId, {
    String locale = LocalizedValue.defaultLocale,
  });

  Future<List<ProgramModel>> fetchProgramsByMasterId(
    String masterId, {
    String locale = LocalizedValue.defaultLocale,
  });
}
