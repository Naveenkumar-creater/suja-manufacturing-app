// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:suja/features/data/datasource/remote/process_datasource.dart';
import 'package:suja/features/domain/repository/process_repository.dart';
import '../../domain/entity/process_entity.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  final ProcessDatasource processDatasource;
  ProcessRepositoryImpl(
    this.processDatasource,
  );
  @override
  Future<ProcessEntity> getProcessList(
    String token,
  ) async {
    final result = await processDatasource.getProcessList(token);
    return result;
  }
}
