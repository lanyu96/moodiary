// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.7.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import '../frb_generated.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FontReader>>
abstract class FontReader implements RustOpaqueInterface {
  static Future<String?> getFontNameFromTtf({required String ttfFilePath}) =>
      RustLib.instance.api
          .crateApiFontFontReaderGetFontNameFromTtf(ttfFilePath: ttfFilePath);

  static Future<Map<String, double>> getWghtAxisFromVfFont(
          {required String ttfFilePath}) =>
      RustLib.instance.api.crateApiFontFontReaderGetWghtAxisFromVfFont(
          ttfFilePath: ttfFilePath);
}
