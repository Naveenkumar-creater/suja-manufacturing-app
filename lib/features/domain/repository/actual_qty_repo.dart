import 'package:prominous/features/domain/entity/actual_qty_entity.dart';

abstract class ActualQtyRepository{
  Future<ActualQtyEntity> getActualQty(int id,String token);

}