import 'dart:io';

final _blockedEnglish = RegExp(
  r'\b(?:nsfw|explicit|erotic|sexual|sex|sexy|nude|naked|topless|bottomless|lingerie|bra|bralette|panties|thong|underwear|cleavage|underboob|breast(?:s|job)?|nipple(?:s)?|areola(?:e)?|vagina|vaginal|vulva|pussy|penis|cock|testicle(?:s)?|clitoris|anal|anus|oral|fellatio|blowjob|handjob|footjob|legjob|paizuri|masturbat(?:ion|e)|fingering|penetrat(?:ion|e)|cum(?:shot|drip)?|semen|ejaculat(?:ion|e)|orgasm|creampie|squirt(?:ing)?|futanari|dildo|vibrator|strap-on|butt plug|bondage|bdsm|fetish|gag|crotch|groin|cunnilingus|tribadism|scissoring|deepthroat|humping)\b',
  caseSensitive: false,
);

const _blockedChinese = <String>{
  '18+',
  '性愛',
  '性行為',
  '性姿勢',
  '自慰',
  '裸體',
  '裸露',
  '上空',
  '下空',
  '乳溝',
  '乳頭',
  '乳暈',
  '胸罩',
  '內褲',
  '情趣',
  '陰道',
  '陰莖',
  '陰部',
  '肛交',
  '口交',
  '手交',
  '足交',
  '腿交',
  '插入',
  '射精',
  '精液',
  '高潮',
  '扶他',
  '性玩具',
  '按摩器',
  '假陽具',
  '肛塞',
  '束縛',
  'BDSM',
};

const _publicDataFiles = <String>[
  'lib/public_catalog_data.dart',
  'lib/public_clothing_taxonomy.dart',
  'lib/public_outfit_reference_data.dart',
  'lib/attached_outfit_reference_data.dart',
  'lib/curated_pose_extension_data.dart',
  'lib/elsword_female_job_prompt_data.dart',
  'lib/elsword_job_outfit_data.dart',
  'lib/expression_catalog_data.dart',
  'lib/finger_gesture_data.dart',
  'lib/hair_style_package_data.dart',
  'lib/object_catalog_data.dart',
  'lib/prompt_package_data.dart',
  'lib/public_expanded_tag_data.dart',
  'lib/single_person_pose_data.dart',
];

String _normalise(String value) => value
    .toLowerCase()
    .replaceAll('手交握', '手握')
    .replaceAll('手交叉', '手叉')
    .replaceAll('手交疊', '手疊')
    .replaceAll('腿交叉', '腿叉')
    .replaceAll('腿交錯', '腿錯');

void main() {
  final problems = <String>[];
  for (final path in _publicDataFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      problems.add('Missing public data file: $path.');
      continue;
    }
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (line.isEmpty || line.startsWith('//')) continue;
      final normalized = _normalise(line);
      if (_blockedEnglish.hasMatch(normalized) ||
          _blockedChinese.any(normalized.contains)) {
        problems.add('$path:${index + 1} contains a blocked public term.');
      }
    }
  }

  final main = File('lib/main.dart').readAsStringSync();
  for (final required in <String>[
    '_isPublicSafePromptText',
    '_isPublicSafeTag',
    '.where(_isPublicSafeTag)',
    '.where(_isPublicSafePromptText)',
  ]) {
    if (!main.contains(required)) {
      problems.add('Public safety gate is missing: $required.');
    }
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print(
      'Public all-ages catalogue OK: ${_publicDataFiles.length} data files checked.');
}
