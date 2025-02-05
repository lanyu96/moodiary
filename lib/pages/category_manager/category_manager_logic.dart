import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mood_diary/common/models/isar/category.dart';
import 'package:mood_diary/pages/home/diary/diary_logic.dart';

import '../../utils/data/isar.dart';
import '../../utils/notice_util.dart';
import 'category_manager_state.dart';

class CategoryManagerLogic extends GetxController {
  final CategoryManagerState state = CategoryManagerState();

  late TextEditingController textEditingController = TextEditingController();

  late DiaryLogic diaryLogic = Bind.find<DiaryLogic>();

  @override
  void onReady() async {
    await getCategory();
    super.onReady();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  Future<void> getCategory() async {
    state.isFetching.value = true;
    state.categoryList.value = await IsarUtil.getAllCategoryAsync();
    state.isFetching.value = false;
  }

  Future<void> addCategory() async {
    if (textEditingController.text.isNotEmpty) {
      if (await IsarUtil.insertACategory(
          Category()..categoryName = textEditingController.text)) {
        Get.backLegacy();
        await getCategory();
        await diaryLogic.updateCategory();
      } else {
        Get.backLegacy();
        await getCategory();
        await diaryLogic.updateCategory();
        NoticeUtil.showToast('分类已存在，已自动添加后缀');
      }
    }
  }

  Future<void> editCategory(String categoryId) async {
    if (textEditingController.text.isNotEmpty) {
      await IsarUtil.updateACategory(Category()
        ..id = categoryId
        ..categoryName = textEditingController.text);
      Get.backLegacy();
      await getCategory();
      await diaryLogic.updateCategory();
    }
  }

  Future<void> deleteCategory(String id) async {
    if (await IsarUtil.deleteACategory(id)) {
      NoticeUtil.showToast('删除成功');
      await getCategory();
      await diaryLogic.updateCategory();
    } else {
      NoticeUtil.showToast('删除失败，当前分类下还有日记');
    }
  }

  void clearInput() {
    textEditingController.clear();
  }

  void editInput(String value) {
    textEditingController.text = value;
  }
}
