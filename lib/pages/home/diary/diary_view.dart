import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:mood_diary/common/values/view_mode.dart';
import 'package:mood_diary/components/base/sheet.dart';
import 'package:mood_diary/components/category_choice_sheet/category_choice_sheet_view.dart';
import 'package:mood_diary/components/diary_tab_view/diary_tab_view_view.dart';
import 'package:mood_diary/components/keepalive/keepalive.dart';
import 'package:mood_diary/components/scroll/fix_scroll.dart';
import 'package:mood_diary/components/search_sheet/search_sheet_view.dart';
import 'package:mood_diary/components/sync_dash_board/sync_dash_board_view.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

import '../../../main.dart';
import '../../../utils/data/pref.dart';
import '../../../utils/webdav_util.dart';
import 'diary_logic.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  Widget _buildSyncingButton(
      {required ColorScheme colorScheme, required Function() onTap}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: RiveAnimatedIcon(
          riveIcon: RiveIcon.reload,
          color: colorScheme.onPrimaryContainer,
          width: 24,
          height: 24,
          loopAnimation: true,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(DiaryLogic());
    final state = Bind.find<DiaryLogic>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    //生成TabBar
    Widget buildTabBar() {
      List<Widget> allTabs = [];
      //默认的全部tab
      allTabs.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Tab(text: '全部'),
      ));
      //根据分类生成分类Tab
      allTabs.addAll(List.generate(state.categoryList.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Tab(text: state.categoryList[index].categoryName),
        );
      }));
      return Row(
        children: [
          IconButton(
            onPressed: () {
              showFloatingModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const CategoryChoiceSheetComponent();
                  });
            },
            icon: const Icon(Icons.menu_open_rounded),
          ),
          Expanded(
            child: TabBar(
              controller: logic.tabController,
              isScrollable: true,
              dividerHeight: .0,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              splashFactory: NoSplash.splashFactory,
              dragStartBehavior: DragStartBehavior.start,
              unselectedLabelStyle: textStyle.labelSmall,
              labelStyle: textStyle.labelMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontVariations: [const FontVariation('wght', 500)]),
              indicator: ShapeDecoration(
                shape: const StadiumBorder(),
                color: colorScheme.primaryContainer,
              ),
              indicatorWeight: .0,
              unselectedLabelColor:
                  colorScheme.onSurface.withValues(alpha: 0.8),
              labelColor: colorScheme.onPrimaryContainer,
              labelPadding: EdgeInsets.zero,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 12.0),
              tabs: allTabs,
            ),
          ),
        ],
      );
    }

    // 单个页面
    Widget buildDiaryView(int index, key, String? categoryId) {
      return KeepAliveWrapper(
        child: PrimaryScrollWrapper(
          key: key,
          child: DiaryTabViewComponent(categoryId: categoryId),
        ),
      );
    }

    Widget buildTabBarView() {
      List<Widget> allViews = [];
      // 添加全部日记页面
      allViews.add(buildDiaryView(0, state.keyMap['default'], null));
      // 添加分类日记页面
      allViews.addAll(List.generate(state.categoryList.length, (index) {
        return buildDiaryView(
            index + 1,
            state.keyMap[state.categoryList[index].id],
            state.categoryList[index].id);
      }));

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.horizontal) {
            logic.checkPageChange();
          }
          return true;
        },
        child: TabBarView(
          controller: logic.tabController,
          dragStartBehavior: DragStartBehavior.start,
          children: allViews,
        ),
      );
    }

    return GetBuilder<DiaryLogic>(
        id: 'All',
        assignId: true,
        builder: (_) {
          return NestedScrollView(
            key: state.nestedScrollKey,
            headerSliverBuilder: (context, _) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    title: GestureDetector(
                      onTap: logic.getHitokoto,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GetBuilder<DiaryLogic>(
                              id: 'Title',
                              builder: (_) {
                                return Text(
                                  state.customTitleName.isNotEmpty
                                      ? state.customTitleName
                                      : l10n.appName,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyle.titleLarge,
                                );
                              }),
                          LayoutBuilder(builder: (context, constraints) {
                            return Obx(() {
                              final textPainter = TextPainter(
                                  text: TextSpan(
                                      text: state.hitokoto.value,
                                      style: textStyle.labelSmall),
                                  textDirection: TextDirection.ltr,
                                  textScaler: TextScaler.linear(
                                      PrefUtil.getValue<double>('fontScale')!))
                                ..layout();
                              final showMarquee =
                                  textPainter.width > constraints.maxWidth;
                              return showMarquee
                                  ? SizedBox(
                                      height: textPainter.height,
                                      width: constraints.maxWidth,
                                      child: Marquee(
                                        text: state.hitokoto.value,
                                        velocity: 20,
                                        blankSpace: 20,
                                        pauseAfterRound:
                                            const Duration(seconds: 1),
                                        accelerationDuration:
                                            const Duration(seconds: 1),
                                        accelerationCurve: Curves.linear,
                                        decelerationDuration:
                                            const Duration(milliseconds: 500),
                                        decelerationCurve: Curves.easeOut,
                                        style: textStyle.labelMedium?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.9)),
                                      ),
                                    )
                                  : Text(
                                      state.hitokoto.value,
                                      style: textStyle.labelMedium?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.9)),
                                    );
                            });
                          }),
                        ],
                      ),
                    ),
                    pinned: true,
                    actions: [
                      Obx(() {
                        return WebDavUtil().syncingDiaries.isNotEmpty
                            ? _buildSyncingButton(
                                colorScheme: colorScheme,
                                onTap: () {
                                  showFloatingModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return const SyncDashBoardComponent();
                                    },
                                  );
                                })
                            : IconButton(
                                onPressed: () {
                                  showFloatingModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return const SyncDashBoardComponent();
                                    },
                                  );
                                },
                                tooltip: '数据同步',
                                icon: const Icon(Icons.cloud_sync_rounded),
                              );
                      }),
                      IconButton(
                        onPressed: () {
                          showFloatingModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return const SearchSheetComponent();
                              });
                        },
                        icon: const Icon(Icons.search_rounded),
                        tooltip: l10n.diaryPageSearchButton,
                      ),
                      PopupMenuButton(
                        offset: const Offset(0, 46),
                        tooltip: l10n.diaryPageViewModeButton,
                        itemBuilder: (context) {
                          return <PopupMenuEntry<String>>[
                            CheckedPopupMenuItem(
                              checked: state.viewModeType == ViewModeType.list,
                              onTap: () async {
                                await logic.changeViewMode(ViewModeType.list);
                              },
                              child: Text(l10n.diaryViewModeList),
                            ),
                            const PopupMenuDivider(),
                            CheckedPopupMenuItem(
                              checked: state.viewModeType == ViewModeType.grid,
                              onTap: () async {
                                await logic.changeViewMode(ViewModeType.grid);
                              },
                              child: Text(l10n.diaryViewModeGrid),
                            ),
                          ];
                        },
                      ),
                    ],
                    bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(46.0),
                        child: buildTabBar()),
                  ),
                ),
              ];
            },
            body: GetBuilder<DiaryLogic>(
                id: 'TabBarView',
                builder: (_) {
                  return buildTabBarView();
                }),
          );
        });
  }
}
