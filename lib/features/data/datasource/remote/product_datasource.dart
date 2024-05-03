// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:suja/constant/request_model.dart';
import 'package:suja/features/data/model/product_model.dart';

import '../../core/api_constant.dart';
import '../../core/product_client.dart';

abstract class ProductDatasource {
  Future<ProductModel> getProductList(int id, String token);
}

class ProductDatasourceImpl implements ProductDatasource {
  ProductClient productClient;
  ProductDatasourceImpl(
    this.productClient,
  );
  @override
  Future<ProductModel> getProductList(int id, String token) async {
    final response = await productClient.getProductList(id, token);

    final result = ProductModel.fromJson(response);

    return result;

    //  ApiRequestDataModel requestBody=  ApiRequestDataModel(apiFor: "list_of_product",clientAuthToken: token,processId: id);

    //  final response= await ApiConstant.makeApiRequest(requestBody: requestBody, url: '', headers: {});
    // final result= ProductModel.fromJson(response);
    // return result;
  }
}
