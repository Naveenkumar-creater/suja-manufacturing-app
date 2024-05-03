import 'package:suja/features/data/model/activity_model.dart';
import 'package:suja/features/data/model/actual_qty_model.dart';
import 'package:suja/features/data/model/recent_activity_model.dart';

import '../../../../constant/request_model.dart';
import '../../core/api_constant.dart';

abstract class ActualQtyDatasource {
  Future<ActualQuantityModel> getActualQty(int id, String token);
}

class ActualQtyDatasourceImpl extends ActualQtyDatasource {
  // final AllocationClient allocationClient;

  // ActivityDatasourceImpl(this.allocationClient);
  
  
  @override
  Future<ActualQuantityModel> getActualQty(int id, String token) async{
    
   ApiRequestDataModel requestbody = ApiRequestDataModel(
          apiFor: "actual_qty", processId: id,clientAuthToken: token );
     final response = await ApiConstant.makeApiRequest(requestBody: requestbody);
    final result = ActualQuantityModel.fromJson(response);
      print(result);
      return result;
  }
}

