import 'dart:io';

import 'package:betterwaifu_prompt_builder_public/ui_language.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final containsCjk = RegExp(r'[\u3400-\u9fff]');

  setUp(() {
    UiLanguageController.setLanguage(AppUiLanguage.english);
  });

  test('English mode translates visible option categories', () {
    const labels = <String>[
      '女性',
      '男性',
      '其他/異種',
      '動漫角色',
      '原創',
      '不需細節',
      '互動・物件動作',
      '固定外觀・臉部結構',
      '服裝・主要風格',
      '物件・家具／室內',
      '物件・工具／科學／遊戲',
      '裝備類型・武器／法具',
      '頭部動態・眼睛／視線',
      '場景效果／渲染',
      '全套／散落狀態',
      '上衣穿脫／暴露',
      '袖子色彩 1',
      '下身色彩 2',
      '下一步：角色資料',
      '下一步：服裝',
      '下一步：自行輸入',
    ];

    for (final label in labels) {
      expect(
        UiLanguageController.uiText(label),
        isNot(matches(containsCjk)),
        reason: 'Untranslated English option label: $label',
      );
    }
  });

  test('English mode shows only the English half of tag labels', () {
    expect(
      UiLanguageController.tagLabel('長髮', 'long hair'),
      'long hair',
    );
    UiLanguageController.registerTagLabel('自訂測試標籤', 'custom test tag');
    expect(UiLanguageController.displayText('自訂測試標籤'), 'custom test tag');
  });

  testWidgets('drop-in Text widget renders translated option labels',
      (tester) async {
    await tester.pumpWidget(
      const material.MaterialApp(
        home: material.Scaffold(
          body: Text('女性'),
        ),
      ),
    );

    expect(find.text('Female'), findsOneWidget);
    expect(find.text('女性'), findsNothing);
  });

  test('critical English interface strings contain no CJK characters', () {
    const sourceStrings = <String>[
      '全系統標籤搜尋',
      '輸入關鍵字後會搜尋整個系統的公開標籤。',
      '移到左側',
      '移到右側',
      '選擇動漫',
      '角色名稱清單（Character Select SAA）',
      '場景效果／渲染',
      '畫面裝飾圖',
      '畫面風格／媒材',
      '光影效果',
      '畫面氛圍',
      '點選要設定的細分類',
      '本大項已選中文標籤',
      '本大項目前沒有已選標籤。',
      '本大項英文輸出（保留括號位置）',
      '本大項目前沒有英文輸出。',
      '負面提示內容已隱藏；仍可在下方調整，並使用左側 N 按鈕複製英文內容。',
      '負面提示內容已隱藏；仍可選擇標籤並使用左側 N 按鈕複製。',
      '中文翻譯與記憶欄位',
      '記憶與備份',
      '目前資料只存在這個瀏覽器的 localStorage；清除網站資料會移除記憶。',
      '完整狀態 JSON 會分區保存已勾選標籤與各人物／服裝／姿勢的額外正向詞；匯入時會覆蓋並回填到原欄位。',
      '尚無儲存組合。按輸出結果右上角的書籤按鈕即可保存。',
      '網站使用聲明',
      '服裝與穿脫狀態',
      '官方精準',
      '描述補充',
      '衣種',
      '剪裁',
      '版型',
      '長度',
      '材質',
      '裝飾',
      '圖案',
      '顏色',
      '整體描述',
      '穿脫',
    ];

    for (final source in sourceStrings) {
      expect(
        UiLanguageController.uiText(source),
        isNot(matches(containsCjk)),
        reason: 'Missing complete English UI translation for: $source',
      );
    }
  });

  test('fixed UI literals in main.dart have complete English translations', () {
    final source = File('lib/main.dart').readAsStringSync();
    final stateSource = source.substring(
      source.indexOf('class _PromptBuilderAppState'),
    );
    final candidates = <String>{};
    final patterns = <RegExp>[
      RegExp(
        r"(?:const\s+)?Text\(\s*'([^'\$]*[\u3400-\u9fff][^'\$]*)'",
        multiLine: true,
      ),
      RegExp(
        r"(?:labelText|hintText|helperText|tooltip):\s*'([^'\$]*[\u3400-\u9fff][^'\$]*)'",
        multiLine: true,
      ),
    ];

    for (final pattern in patterns) {
      candidates.addAll(
        pattern
            .allMatches(source)
            .map((match) => match.group(1)!)
            .where((value) => value.isNotEmpty),
      );
    }
    final namedUiLiteralPattern = RegExp(
      r"(?:title|subtitle|description|message):\s*'([^'\$]*[\u3400-\u9fff][^'\$]*)'",
      multiLine: true,
    );
    candidates.addAll(
      namedUiLiteralPattern
          .allMatches(stateSource)
          .map((match) => match.group(1)!)
          .where((value) => value.isNotEmpty),
    );

    final untranslated = candidates
        .where(
            (value) => containsCjk.hasMatch(UiLanguageController.uiText(value)))
        .toList()
      ..sort();
    expect(
      untranslated,
      isEmpty,
      reason: 'Fixed UI literals still contain CJK in English mode.',
    );
  });

  test('all generated category and subcategory labels translate completely',
      () {
    final source = File('lib/main.dart').readAsStringSync();
    String section(String startMarker, String endMarker) {
      final start = source.indexOf(startMarker);
      final end = source.indexOf(endMarker, start + startMarker.length);
      expect(start, isNonNegative,
          reason: 'Missing source marker: $startMarker');
      expect(end, greaterThan(start),
          reason: 'Missing source marker: $endMarker');
      return source.substring(start, end);
    }

    final sections = <String>[
      section(
        'String _clothingWearPickerLabel',
        'String? _clothingWearPickerSlotForTag',
      ),
      section(
        'String _clothingScopeLabel',
        'String _clothingScopedKindLabel',
      ),
      section(
        'String _clothingScopedKindLabel',
        'String _clothingAccessoryPickerGroup',
      ),
      section(
        'String _wizardGroupLabel',
        'List<TagItem> _stepVisibleTags',
      ),
    ];
    final literalPattern = RegExp(r"'([^'\$]*[\u3400-\u9fff][^'\$]*)'");
    final labels = sections
        .expand((section) =>
            literalPattern.allMatches(section).map((match) => match.group(1)!))
        .toSet();
    final untranslated = labels
        .where(
            (label) => containsCjk.hasMatch(UiLanguageController.uiText(label)))
        .toList()
      ..sort();

    expect(
      untranslated,
      isEmpty,
      reason: 'A generated category or subcategory label is still Chinese.',
    );
  });

  test('copy controls use single-letter P and N labels', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("icon: const Text('P',"));
    expect(source, contains("icon: const Text('N',"));
    expect(source, isNot(contains("icon: const Text('POS',")));
    expect(source, isNot(contains("icon: const Text('NEG',")));
  });

  test('all Pose and outfit data categories are English-only in English mode',
      () {
    final labels = <String>{};
    final promptPackages =
        File('lib/prompt_package_data.dart').readAsStringSync();
    final outfitData =
        File('lib/public_outfit_reference_data.dart').readAsStringSync();
    final attachedData =
        File('lib/attached_outfit_reference_data.dart').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();

    final categoryPattern = RegExp(r'''category:\s*["']([^"']+)["']''');
    for (final source in [promptPackages, outfitData]) {
      labels.addAll(
        categoryPattern.allMatches(source).map((match) => match.group(1)!),
      );
    }
    labels.addAll(
      RegExp(r"category\s*=\s*'([^']+)'")
          .allMatches(attachedData)
          .map((match) => match.group(1)!),
    );
    labels.addAll(
      RegExp(
        r'^(?:##\s+)?[A-Z]\.\s*(.+?)(?=\s*\d{3,4}[–-]\d{2,4}$)',
        multiLine: true,
      ).allMatches(attachedData).map((match) => match.group(1)!.trim()),
    );

    final poseSections = mainSource.substring(
      mainSource.indexOf('const _organizedPosePickerSections'),
      mainSource.indexOf('bool _isSharedActionGroup'),
    );
    labels.addAll(
      RegExp(r"'([^'\$]*[\u3400-\u9fff][^'\$]*)'")
          .allMatches(poseSections)
          .map((match) => match.group(1)!),
    );

    final untranslated = labels
        .where(
            (label) => containsCjk.hasMatch(UiLanguageController.uiText(label)))
        .toList()
      ..sort();
    expect(
      untranslated.join('\n'),
      isEmpty,
      reason: 'A Pose or outfit category still contains Chinese.',
    );
  });

  test('collapsed summaries and negative chips use language-aware labels', () {
    final source = File('lib/main.dart').readAsStringSync();
    final progressive = source.substring(
      source.indexOf('Widget _progressiveBuilder()'),
      source.indexOf('// ignore: unused_element',
          source.indexOf('Widget _progressiveBuilder()')),
    );

    expect(progressive, isNot(contains('.map((tag) => tag.zh)')));
    expect(progressive, contains('.map(_tagDisplayLabel)'));
    expect(
      source,
      contains("UiLanguageController.tagLabel(item['zh']!, item['en']!)"),
    );
    expect(
      source,
      isNot(contains("label: Text('\${item['zh']} / \${item['en']}')")),
    );
  });
}
