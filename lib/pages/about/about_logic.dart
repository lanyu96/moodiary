import 'package:get/get.dart';
import 'package:mood_diary/router/app_routes.dart';
import 'package:mood_diary/utils/package_util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/data/pref.dart';
import 'about_state.dart';

class AboutLogic extends GetxController {
  final AboutState state = AboutState();

  @override
  void onReady() async {
    await getInfo();
    super.onReady();
  }

  Future<void> getInfo() async {
    var packageInfo = await PackageUtil.getPackageInfo();
    state.appName = packageInfo.appName;
    state.appVersion = packageInfo.version;
    update();
  }

  //跳转到反馈页
  Future<void> toReportPage() async {
    var uri = Uri(
        scheme: 'https',
        host: 'support.qq.com',
        path: 'products/650147',
        queryParameters: {
          'nickname': PrefUtil.getValue<String>('uuid'),
          'avatar':
              'https://txc.qq.com/static/desktop/img/products/def-product-logo.png',
          'openid': PrefUtil.getValue<String>('uuid')
        });
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  //跳转至源代码
  Future<void> toSource() async {
    var uri = Uri(
      scheme: 'https',
      host: 'github.com',
      path: 'ZhuJHua/moodiary',
    );
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  void toPrivacy() {
    Get.toNamed(AppRoutes.privacyPage);
  }

  void toAgreement() {
    Get.toNamed(AppRoutes.agreementPage);
  }
}
