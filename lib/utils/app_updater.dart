import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

/// Current app version — must match the latest GitHub tag (v1.0.4).
/// Bump this every time a new APK is published.
const kAppVersion = '1.0.4';

const _kRepo = 'gracesellemanaging-lab/K-Vibes';
const _kFallbackApk =
    'https://github.com/gracesellemanaging-lab/K-Vibes/raw/main/K-vibes.apk';

class AppUpdateInfo {
  final String version; // e.g. v1.0.3
  final String apkUrl;
  final String notes;
  const AppUpdateInfo(
      {required this.version, required this.apkUrl, required this.notes});
}

/// Returns update info if GitHub has a NEWER tag than [kAppVersion],
/// otherwise null (up to date or no internet — this is an offline app).
///
/// NOTE: we use the public *tags* endpoint, not /releases/latest, because
/// this repo publishes via tags + raw APK link and has no Release objects.
/// Tags come back newest-first, so the first vX.Y.Z match wins.
Future<AppUpdateInfo?> checkForAppUpdate() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    final req = await client
        .getUrl(Uri.parse('https://api.github.com/repos/$_kRepo/tags'))
        .timeout(const Duration(seconds: 10));
    req.headers.set('Accept', 'application/vnd.github+json');
    req.headers.set('User-Agent', 'K-VIBES-app');
    final res = await req.close().timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final body =
        await res.transform(utf8.decoder).join().timeout(const Duration(seconds: 10));
    final list = jsonDecode(body) as List<dynamic>;
    String latest = '';
    for (final t in list) {
      final name =
          (((t as Map<String, dynamic>)['name'] as String?) ?? '').trim();
      if (RegExp(r'^v?\d+\.\d+\.\d+$').hasMatch(name)) {
        latest = name;
        break;
      }
    }
    if (latest.isEmpty || !_isNewer(latest, kAppVersion)) return null;
    return AppUpdateInfo(version: latest, apkUrl: _kFallbackApk, notes: '');
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

bool _isNewer(String latest, String current) {
  List<int> parse(String v) => v
      .replaceFirst(RegExp(r'^v', caseSensitive: false), '')
      .split('.')
      .map((p) => int.tryParse(RegExp(r'\d+').firstMatch(p)?.group(0) ?? '0') ?? 0)
      .toList();
  final l = parse(latest), c = parse(current);
  for (int i = 0; i < 3; i++) {
    final lv = i < l.length ? l[i] : 0;
    final cv = i < c.length ? c[i] : 0;
    if (lv != cv) return lv > cv;
  }
  return false;
}

/// Shows the "Update available" dialog. Safe to call even offline (no-op).
Future<void> showUpdateDialog(BuildContext context, AppUpdateInfo info) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              gradient: AppColors.gradientPink,
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.system_update_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Update available',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: kPinkLight, borderRadius: BorderRadius.circular(20)),
          child: Text('${info.version} • bag-ong version',
              style: const TextStyle(
                  color: kPink, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        if (info.notes.isNotEmpty) ...[
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Text(info.notes,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ),
          ),
        ],
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later', style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton.icon(
          onPressed: () async {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            await downloadUpdate(context, info.apkUrl);
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Download'),
          style: FilledButton.styleFrom(backgroundColor: kPink),
        ),
      ],
    ),
  );
}

/// Opens the APK link in the browser. Falls back to copying the link.
Future<void> downloadUpdate(BuildContext context, String apkUrl) async {
  final uri = Uri.tryParse(apkUrl);
  if (uri != null) {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
  }
  // Fallback: copy link so the user can paste it in Chrome.
  try {
    await Clipboard.setData(ClipboardData(text: apkUrl));
  } catch (_) {}
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Link gi-copy — i-paste sa Chrome para ma-download')));
  }
}

/// Manual "Check for updates" — shows a Snackbar when already latest/offline.
Future<void> checkForUpdateManually(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Gina-check kung naay update…'),
      duration: Duration(seconds: 2)));
  AppUpdateInfo? info;
  try {
    info = await checkForAppUpdate().timeout(const Duration(seconds: 15));
  } catch (_) {
    info = null;
  }
  if (!context.mounted) return;
  if (info == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Naka latest ka na (v$kAppVersion) — o walay internet connection')));
  } else {
    await showUpdateDialog(context, info);
  }
}
