import 'package:convenience_sales_forecast_app/vm/image_handler.dart';
import 'package:get_storage/get_storage.dart';

class UserHandler extends ImageHandler {
  final box = GetStorage();
  @override
  void onInit() async {
    super.onInit();
    box.write('id', 'dnjsd98@gmail.com');
  }
}
