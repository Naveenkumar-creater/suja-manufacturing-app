import 'package:suja/features/data/datasource/remote/shift_status_datasource.dart';
import 'package:suja/features/data/model/shift_status_model.dart';
import 'package:suja/features/domain/repository/shift_status_repo.dart';

class ShiftStatusRepositoryImpl implements ShiftStatusRepository {
  final ShiftStatusDatasource shiftStatusDatasource;
  
ShiftStatusRepositoryImpl(
    this.shiftStatusDatasource,
  );


  @override
  Future<ShiftStatusModel> getShiftStatus(int deptid,int processid, String token) async{
 ShiftStatusModel modelresult =
        await shiftStatusDatasource.getShiftStatus(deptid,processid, token);
    return modelresult;
  }
}