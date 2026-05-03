import 'package:hygge_app/data/models/program_model.dart';

/// Interface for managing program data.
///
/// Programs are lesson types/categories: meditation, yoga, stretching, breathing, fitness, etc.
/// This repository handles fetching and watching programs from the data source.
abstract class ProgramsRepository {
  /// Fetch all active programs.
  ///
  /// [limit] - optional limit on the number of results.
  /// Returns a list of [ProgramModel] representing programs.
  Future<List<ProgramModel>> fetchPrograms({int? limit});

  /// Watch all active programs as a stream.
  ///
  /// [limit] - optional limit on the number of results.
  /// Returns a stream of program lists.
  Stream<List<ProgramModel>> watchPrograms({int? limit});

  /// Fetch a specific program by its ID.
  ///
  /// [programId] - the unique identifier of the program.
  /// Returns the [ProgramModel] if found, null otherwise.
  Future<ProgramModel?> fetchProgramById(String programId);
}
