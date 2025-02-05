import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mood_diary/common/values/border.dart';
import 'package:mood_diary/components/loading/loading.dart';

import '../../main.dart';
import 'category_manager_logic.dart';

class CategoryManagerPage extends StatelessWidget {
  const CategoryManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Bind.find<CategoryManagerLogic>();
    final state = Bind.find<CategoryManagerLogic>().state;
    final colorScheme = Theme.of(context).colorScheme;

    Widget inputDialog(Function() operate) {
      return AlertDialog(
        title: TextField(
          maxLines: 1,
          controller: logic.textEditingController,
          decoration: InputDecoration(
            fillColor: colorScheme.secondaryContainer,
            border: const UnderlineInputBorder(
              borderRadius: AppBorderRadius.smallBorderRadius,
              borderSide: BorderSide.none,
            ),
            filled: true,
            labelText: '分类',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.backLegacy();
              },
              child: Text(l10n.cancel)),
          TextButton(onPressed: operate, child: Text(l10n.ok))
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
      ),
      body: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !state.isFetching.value
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(state.categoryList[index].categoryName),
                      subtitle: Text(
                        state.categoryList[index].id,
                        style: const TextStyle(fontSize: 8),
                      ),
                      onTap: null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              logic.editInput(
                                  state.categoryList[index].categoryName);
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return inputDialog(() {
                                      logic.editCategory(
                                          state.categoryList[index].id);
                                    });
                                  });
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              logic
                                  .deleteCategory(state.categoryList[index].id);
                            },
                            icon: const Icon(Icons.delete_forever),
                            color: colorScheme.error,
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: state.categoryList.length,
                )
              : const Center(
                  child: Processing(),
                ),
        );
      }),
      floatingActionButton: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !state.isFetching.value
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    logic.clearInput();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return inputDialog(() {
                            logic.addCategory();
                          });
                        });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('添加分类'),
                )
              : const SizedBox.shrink(),
        );
      }),
    );
  }
}
