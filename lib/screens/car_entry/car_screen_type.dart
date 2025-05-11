import 'package:carlog/models/car_details_model.dart';

sealed class CarScreenType {
  const CarScreenType();
}

class Add extends CarScreenType {
  Add();
}

class Edit extends CarScreenType {
  Edit(this.car);
  final CarDetails car;
}
