import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mood_diary/pages/home/setting/setting_logic.dart';

import '../../utils/data/pref.dart';
import '../../utils/notice_util.dart';
import 'remove_password_state.dart';

class RemovePasswordLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RemovePasswordState state = RemovePasswordState();
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  late Animation<double> animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

  late final settingLogic = Bind.find<SettingLogic>();

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  double interpolate(double x) {
    var step = 10.0;
    if (x <= 0.25) {
      // 第一段: (0, step) - 单调递增
      return 4 * step * x;
    } else if (x <= 0.75) {
      // 第二段: (step, -step) - 单调递减
      return step - 4 * step * (x - 0.25);
    } else {
      // 第三段: (-step, 0) - 单调递增
      return -step + 4 * step * (x - 0.75);
    }
  }

  void deletePassword() {
    if (state.password.isNotEmpty) {
      state.password = state.password.substring(0, state.password.length - 1);
      update();
      HapticFeedback.selectionClick();
    }
  }

  Future<void> updatePassword(String value) async {
    if (state.password.length < 4) {
      state.password += value;
      update();
      HapticFeedback.selectionClick();
    }
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (state.password.length == 4) {
        //密码正确
        if (state.password == state.realPassword) {
          await removePassword();
        } else {
          animationController.forward();
          await HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 200), () {
            animationController.reverse();
            state.password = '';
            update();
          });
        }
      }
    });
  }

  Future<void> removePassword() async {
    //lock标记为false说明关闭密码
    await PrefUtil.setValue<bool>('lock', false);
    //移除密码字段
    await PrefUtil.removeValue('password');
    settingLogic.state.lock = false;
    settingLogic.update(['Lock']);
    NoticeUtil.showToast('关闭成功');
    Get.backLegacy();
  }
}
