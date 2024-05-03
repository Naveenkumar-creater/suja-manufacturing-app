// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:suja/features/data/model/emp_production_model.dart';

import '../../../../constant/request_model.dart';
import '../../core/emp_production_entry_client.dart';

abstract class EmpProductionEntryDatasource {
  Future<EmpProductionModel> getempproduction(int empid, String token
      // int goodQuantities, int rejectedQuantities, int reworkQuantities
      );
}

class EmpProductionEntryDatasourceImpl implements EmpProductionEntryDatasource {
  final EmpProductionEntryClient empProductionEntryClient;
  EmpProductionEntryDatasourceImpl(
    this.empProductionEntryClient,
  );

  @override
  Future<EmpProductionModel> getempproduction(int empid, String token
      //int goodQuantities, int rejectedQuantities, int reworkQuantities
      ) async {
    final response =
        await empProductionEntryClient.getempproduction(empid, token);

    final result = EmpProductionModel.fromJson(response);

    return result;
    // ApiRequestDataModel requestBody = ApiRequestDataModel(
    //     apiFor: "emp_production_entry",
    //     clientAuthToken: token,
    //     emppersonid: empid
    //     //   goodQuantities: goodQuantities,
    //     //   rejectedQuantities: rejectedQuantities,
    //     //   reworkQuantities: reworkQuantities,
    //     );
    // final response = await ApiConstant.makeApiRequest(requestBody: requestBody);
    // final result = EmpProductionModel.fromJson(response);
    // return result;
  }
}
