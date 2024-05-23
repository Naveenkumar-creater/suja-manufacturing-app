import 'package:suja/features/domain/entity/activity_entity.dart';
import 'package:suja/features/domain/repository/activity_repo.dart';

class ActivityUsecase{
  final ActivityRepository activityRepository;
  ActivityUsecase(this.activityRepository);

  Future<ActivityEntity>execute(int id,int deptid, String token)async{
    return activityRepository.getActivity(id,deptid, token);
  }

}