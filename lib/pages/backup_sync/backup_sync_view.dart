import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mood_diary/components/base/button.dart';
import 'package:mood_diary/components/local_send/local_send_view.dart';
import 'package:mood_diary/components/tile/setting_tile.dart';
import 'package:mood_diary/components/web_dav/web_dav_view.dart';
import 'package:refreshed/refreshed.dart';

import '../../main.dart';
import 'backup_sync_logic.dart';

class BackupSyncPage extends StatelessWidget {
  const BackupSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BackupSyncLogic logic = Get.put(BackupSyncLogic());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingDataSyncAndBackup),
        leading: const PageBackButton(),
      ),
      body: ListView(
        children: [
          AdaptiveListTile(
            title: Text(l10n.settingExport),
            onTap: () async {
              var res = await showOkCancelAlertDialog(
                context: context,
                title: l10n.settingExportDialogTitle,
                message: l10n.settingExportDialogContent,
                style: AdaptiveStyle.material,
              );
              if (res == OkCancelResult.ok) {
                await logic.exportFile();
              }
            },
            trailing: const Icon(Icons.chevron_right_rounded),
            leading: const Icon(Icons.file_upload_outlined),
          ),
          AdaptiveListTile(
            title: Text(l10n.settingImport),
            subtitle: l10n.settingImportDes,
            onTap: () async {
              var res = await showOkCancelAlertDialog(
                context: context,
                title: l10n.settingImportDialogTitle,
                message: l10n.settingImportDialogContent,
                okLabel: l10n.settingImportSelectFile,
                style: AdaptiveStyle.material,
              );
              if (res == OkCancelResult.ok) {
                await logic.import();
              }
            },
            trailing: const Icon(Icons.chevron_right_rounded),
            leading: const Icon(Icons.file_download_outlined),
          ),
          const LocalSendComponent(),
          const WebDavComponent()
        ],
      ),
    );
  }
}
