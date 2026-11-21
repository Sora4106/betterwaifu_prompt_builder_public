import 'package:flutter/material.dart' as material;

/// The public builder uses the browser language only as a first-run default.
/// A visitor's explicit choice is saved by the host app and always wins later.
enum AppUiLanguage { traditionalChinese, english }

class UiLanguageController {
  UiLanguageController._();

  static AppUiLanguage _language = AppUiLanguage.traditionalChinese;
  static final Map<String, String> _tagEnglishByChinese = <String, String>{};

  static AppUiLanguage get language => _language;
  static bool get isEnglish => _language == AppUiLanguage.english;

  static void setLanguage(AppUiLanguage value) {
    _language = value;
  }

  static AppUiLanguage fromStorageValue(String? value) =>
      value == 'en' ? AppUiLanguage.english : AppUiLanguage.traditionalChinese;

  static String storageValue(AppUiLanguage value) =>
      value == AppUiLanguage.english ? 'en' : 'zh-TW';

  static AppUiLanguage fromBrowserLanguage(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return normalized.startsWith('zh')
        ? AppUiLanguage.traditionalChinese
        : AppUiLanguage.english;
  }

  /// Register the bilingual catalogue once it has been built. This lets the
  /// shared [Text] widget render every existing tag consistently without
  /// duplicating display decisions across picker, summary, and search UIs.
  static void registerTagLabel(String chinese, String english) {
    final zh = chinese.trim();
    final en = english.trim();
    if (zh.isEmpty || en.isEmpty || zh == en) return;
    _tagEnglishByChinese.putIfAbsent(zh, () => en);
  }

  static void registerTagLabels(Iterable<MapEntry<String, String>> labels) {
    for (final label in labels) {
      registerTagLabel(label.key, label.value);
    }
  }

  static String choose(String chinese, String english) =>
      isEnglish ? english : chinese;

  /// Localise application chrome. In English mode this also recognises an
  /// already-bilingual tag label and keeps only its English half.
  static String uiText(String source) {
    if (source.isEmpty || !isEnglish) return source;
    final exact = _uiEnglish[source];
    if (exact != null) return exact;

    final tag = _tagEnglishByChinese[source.trim()];
    if (tag != null) return tag;

    final bilingual = _englishHalfOfBilingualLabel(source);
    if (bilingual != null) return bilingual;

    var result = source;
    for (final entry in _partialUiEnglishEntries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  /// Labels representing a database tag intentionally display both languages
  /// in the Chinese experience, but never add Chinese to the English one.
  static String tagLabel(String chinese, String english) {
    final zh = chinese.trim();
    final en = english.trim();
    if (isEnglish || zh.isEmpty) return en.isEmpty ? zh : en;
    if (en.isEmpty || zh == en) return zh;
    return '$zh · $en';
  }

  static String displayText(String source) {
    if (source.isEmpty) return source;
    if (isEnglish) return uiText(source);

    final trimmed = source.trim();
    // Application chrome should stay compact in Chinese mode. Tag captions,
    // on the other hand, intentionally retain their English prompt word.
    if (_uiEnglish.containsKey(trimmed)) return source;
    final tag = _tagEnglishByChinese[trimmed];
    if (tag == null || source != trimmed) return source;
    return '$source · $tag';
  }

  static String? _englishHalfOfBilingualLabel(String source) {
    final match = RegExp(r'^\s*.+?\s*[·｜]\s*([^·｜]+?)\s*$').firstMatch(source);
    if (match == null) return null;
    final candidate = match.group(1)?.trim() ?? '';
    return candidate.isNotEmpty && !_containsCjk(candidate) ? candidate : null;
  }

  static bool _containsCjk(String value) =>
      RegExp(r'[\u3400-\u9fff]').hasMatch(value);

  static const Map<String, String> _uiEnglish = <String, String>{
    '繁體中文': 'Traditional Chinese',
    '英文': 'English',
    '製作類型': 'Creation mode',
    '圖片提示詞': 'Image prompt',
    '影片動態分鏡': 'Video storyboard',
    '以場景順序、角色部位動作、鏡頭與音訊組合影片用自然語句。':
        'Build natural-language video directions from scene order, character actions, camera work, and audio.',
    '建立可貼到 Amanatsu 1.1 的圖片提示詞與負面提示詞。':
        'Build image and negative prompts ready to paste into Amanatsu 1.1.',
    '場景與畫面': 'Scene & framing',
    '角色資料': 'Characters',
    '固定角色外觀': 'Character traits',
    '服裝與穿脫': 'Clothing',
    '姿勢與互動': 'Pose & interaction',
    '自行輸入': 'Manual input',
    '品質與負面': 'Quality & negative',
    '場景': 'Scene',
    '角色': 'Character',
    '特徵': 'Traits',
    '服裝': 'Clothing',
    '姿勢': 'Pose',
    '輸入': 'Input',
    '品質': 'Quality',
    '版本歷程': 'Version history',
    '匯出完整狀態': 'Export full state',
    '匯入完整狀態': 'Import full state',
    '輸出結果': 'Output',
    '複製': 'Copy',
    '取消': 'Cancel',
    '確認': 'Confirm',
    '關閉': 'Close',
    '儲存': 'Save',
    '套用': 'Apply',
    '預覽': 'Preview',
    '新增': 'Add',
    '刪除': 'Delete',
    '清除': 'Clear',
    '全部': 'All',
    '中文翻譯與記憶欄位': 'Chinese translation & memory',
    'English prompt · 可直接貼上': 'English prompt · ready to paste',
    '匯出標籤 TXT': 'Export tags TXT',
    '匯出目前選擇 JSON': 'Export current selection JSON',
    '匯入目前選擇 JSON': 'Import current selection JSON',
    '記憶與備份': 'Memory & backup',
    '正在準備標籤與本機記憶…': 'Preparing tags and local memory…',
    '介面語言': 'Interface language',
    '語言': 'Language',
    '選擇語言': 'Choose language',
    '使用瀏覽器語言作為預設': 'Browser language is used as the default',
    '繁體中文（顯示中英文標籤）':
        'Traditional Chinese (show Chinese + English tags)',
    'English（全畫面英文）': 'English (English-only interface)',
    '已選標籤': 'Selected tags',
    '本大項已選中文標籤': 'Selected tags in this section',
    '本大項英文輸出': 'English output for this section',
    '搜尋此區所有標籤': 'Search tags in this section',
    '搜尋所有中文、英文標籤或分類…': 'Search all tags or categories…',
    '查詢動漫名稱': 'Search anime',
    '查詢角色名稱': 'Search character',
    '性別/類型': 'Gender / type',
    '人物數量（必填）': 'Character count (required)',
    '女性': 'Female',
    '男性': 'Male',
    '其他/異種': 'Other / species',
    '中文名稱': 'Chinese name',
    '動漫中文名稱': 'Anime name (Chinese)',
    '角色中文名稱': 'Character name (Chinese)',
    '角色特徵中文': 'Character traits (Chinese)',
    '留白會由英文名稱產生': 'Leave blank to generate from the English name',
    '粉紅頭髮, 呆毛, 綠眼睛': 'pink hair, ahoge, green eyes',
    '中文與英文特徵依逗號順序配對；資料只會儲存在本機。':
        'Chinese and English traits are paired by comma order and stored only on this device.',
    '組合名稱': 'Package name',
    '組合中文名稱': 'Package name',
    '姿勢組合名稱': 'Pose package name',
    '英文標籤': 'English tag',
    '中文翻譯': 'Chinese translation',
    '例如 blurry 或 bad composition': 'e.g. blurry or bad composition',
    '例如 模糊 或 構圖不佳': 'e.g. blurry or poor composition',
    '例如: blue jacket': 'e.g. blue jacket',
    '例如白色蕾絲洋裝': 'e.g. white lace dress',
    '例如坐椅子抬腿微笑': 'e.g. sitting on a chair with a raised leg and a smile',
    '額外正向標籤（中文或英文）': 'Extra positive tags (Chinese or English)',
    'custom prompt, 或用逗號分隔': 'custom prompt, or separate with commas',
    '搜尋可加入的標籤': 'Search tags to add',
    '分類與輸出順序': 'Category & output order',
    '清除所有標籤': 'Clear all tags',
    '清除搜尋文字': 'Clear search',
    '貼上並取代目前內容': 'Paste and replace current text',
    '清空此欄位': 'Clear this field',
    '只清除此細分類': 'Clear this subcategory only',
    '新增負面標籤': 'Add negative tag',
    '新增自訂標籤': 'Add custom tag',
    '儲存組合': 'Save package',
    '加入組合標籤': 'Add to packages',
    '編輯組合標籤': 'Edit package',
    '全部分類': 'All categories',
    '已選標籤：': 'Selected tags: ',
    '自然敘述：': 'Natural description: ',
    '已套用・可個別調整': 'Applied · individually editable',
    '點選展開預覽與套用': 'Tap to preview and apply',
    '原創': 'Original',
    '動漫角色': 'Anime character',
    '不需細節': 'No details needed',
    '需要細節': 'Include details',
    '選擇角色': 'Choose character',
    '尚未選擇': 'Not selected',
    '自動查詢': 'Auto search',
    '查無動漫資料，可新增自己的動漫與角色。':
        'No anime found. You can add your own anime and characters.',
    '減少人物': 'Remove character',
    '增加人物（最多 10 人）': 'Add character (up to 10)',
    '至少需要保留一位人物': 'At least one character is required',
    '人物資料數量：': 'Character cards: ',
    '未設定角色': 'No character set',
    '共用提示詞': 'Shared prompt',
    '點選標籤加入提示詞；排序會依照角色 → 特徵 → 服裝 → 表情 → 姿勢／動作／物件。':
        'Tap a tag to add it. Output is ordered as character → traits → clothing → expression → pose / action / object.',
    '先決定畫面中有幾位角色；之後可以逐一指定女性、男性或其他/異種。':
        'First choose the number of characters, then set each one as female, male, or other/species.',
    '模型、Sampler、Steps、CFG 與 Clip skip 請直接在 AI 生成網站設定；本工具只輸出可貼上的提示標籤。':
        'Set model, sampler, steps, CFG, and clip skip on the AI generation site. This tool outputs paste-ready tags only.',
    '人物數量會依下方角色資料卡自動計算。每個人物都要選擇「動漫角色」、「原創角色」，或明確選擇「不需細節」。動漫角色預設只帶入作品與角色名稱；需要時再按「保留角色特徵」。':
        'Character count is calculated from the cards below. For each character, choose anime character, original character, or no details. Anime characters add source and name by default; enable character traits only when needed.',
    '目前選擇 JSON 會保存各人物的已勾選標籤、服裝／姿勢欄位、權重與額外正向詞；匯入後會依原本欄位完整回填。':
        'The current-selection JSON saves each character’s selected tags, clothing and pose fields, weights, and extra positive text for complete restore on import.',
    '模型參數請在 AI 生成網站設定；這裡只提供可貼上的提示標籤。':
        'Set model parameters on the AI generation website; this tool only provides paste-ready prompt tags.',
    '複製本大項英文': 'Copy this section in English',
    '複製英文正向標籤': 'Copy English positive tags',
    '複製負面標籤': 'Copy negative tags',
    '室內場景': 'Indoor scene',
    '戶外場景': 'Outdoor scene',
    '戶外時段': 'Outdoor time',
    '鏡頭・取景範圍': 'Camera · framing',
    '鏡頭・臉部（眼睛／嘴巴／表情）': 'Camera · face (eyes / mouth / expression)',
    '鏡頭・身體聚焦（頭到腳）': 'Camera · body focus (head to toe)',
    '鏡頭・裁切構圖': 'Camera · crop composition',
    '鏡頭・床位視角': 'Camera · bed viewpoint',
    '獸人／特殊角色特徵（含顏色）': 'Anthro / special character traits (with colors)',
    '翅膀（含顏色）': 'Wings (with colors)',
    '武器／法具': 'Weapons / magic tools',
    '防具／護具': 'Armor / protective gear',
    'Cosplay／角色扮演': 'Cosplay / roleplay',
    '連身裙／洋裝': 'One-piece / dress',
    '特殊服裝／制服': 'Special clothing / uniform',
    '帽子／頭戴': 'Hats / headwear',
    '眼鏡／眼罩': 'Glasses / eye coverings',
    '其他頭部配件': 'Other head accessories',
    '獸耳／尾飾／翅飾': 'Animal ears / tails / wing accessories',
    '腿部飾品': 'Leg accessories',
    '腳踝／足部飾品': 'Ankle / foot accessories',
    '上衣': 'Top',
    '下身': 'Bottom',
    '褲子': 'Pants',
    '短褲': 'Shorts',
    '裙子': 'Skirt',
    '連身裝': 'One-piece',
    '內衣': 'Underwear',
    '胸罩': 'Bra',
    '內褲': 'Panties',
    '襪子': 'Socks',
    '鞋子': 'Shoes',
    '外套': 'Outerwear',
    '配件': 'Accessories',
    '色彩': 'color',
    '顏色': 'color',
    '邊線色': 'accent color',
    '主色': 'primary color',
    '次色': 'secondary color',
    '風格': 'style',
    '細節': 'details',
    '材質': 'material',
    '穿脫狀態': 'wear / removal state',
    '髮長': 'Hair length',
    '髮色': 'Hair color',
    '髮型': 'Hairstyle',
    '眼睛': 'Eyes',
    '臉部特徵': 'Facial traits',
    '身體特徵': 'Body traits',
    '額外特徵': 'Extra traits',
    '表情': 'Expression',
    '物件': 'Objects',
    '動作': 'Action',
    '互動': 'Interaction',
    '品質前綴': 'Quality prefix',
    '回到最上方': 'Back to top',
    '使用提示': 'Usage help',
    '正': 'Positive',
    '負': 'Negative',
    '中文組合預覽': 'Chinese package preview',
    '英文組合預覽': 'English package preview',
    '可選標籤': 'Selectable tags',
    '中文動作內容': 'Chinese action content',
    '英文提示詞（實際輸出）': 'English prompt (actual output)',
    '套件標籤': 'Package tags',
    '漸層色彩': 'Gradient colors',
    '未設定漸層色彩': 'No gradient colors set',
    '職業設定與頭部特徵': 'Class context & head traits',
    '套裝部位（可單獨移除）': 'Outfit parts (removable individually)',
    '專屬武器／裝備': 'Exclusive weapon / equipment',
    '不含武器': 'No weapon',
    '恢復全部部位': 'Restore all parts',
    '原作服裝細節調整': 'Canonical outfit adjustments',
    '女子服裝靈感套裝': 'Women’s outfit inspiration',
    '配色版本': 'Color variants',
    '藍色系列': 'Blue series',
    '日常／正式': 'Everyday / formal',
    '優雅／正式': 'Elegant / formal',
    '甜美／浪漫': 'Sweet / romantic',
    '街頭／運動': 'Street / sport',
    '奇幻／特色': 'Fantasy / signature',
    '艾爾之光・轉職服裝': 'Elsword · class outfits',
    '拉拉・萬聖節': 'Lala · Halloween',
    '武器呈現方式': 'Weapon presentation',
    '雙色漸層髮': 'Two-color gradient hair',
    '色 1': 'Color 1',
    '色 2': 'Color 2',
    '全髮線性漸層': 'Full linear gradient',
    '髮尾漸層': 'Gradient tips',
    '髮根漸層': 'Root gradient',
    '內層挑染': 'Inner-layer highlight',
    '左右分色': 'Split color',
    '底層雙色': 'Two-tone underlayer',
    '知道了': 'Got it',
    '新增負面標籤（中英文）': 'Add negative tag (Chinese + English)',
    '標籤可能互相衝突': 'Potential tag conflict',
    '保留原標籤': 'Keep current tag',
    '移除原標籤並更換': 'Remove current tag and replace',
    '這會覆寫角色原始特徵': 'This replaces the character’s original traits',
    '保留原特徵': 'Keep original traits',
    '套用並替換': 'Apply and replace',
    '套用已對應標籤': 'Apply matched tags',
    '未對應詞加入對應額外欄位': 'Add unmatched words to the matching extra field',
    '清除所有標籤？': 'Clear all tags?',
    '確定清除': 'Clear now',
    '清除目前分類？': 'Clear current category?',
    '匯入完整狀態備份': 'Import full-state backup',
    '覆蓋並匯入': 'Overwrite and import',
    '新增動漫／角色資料': 'Add anime / character data',
    '儲存角色': 'Save character',
    '自動查詢結果': 'Auto-search results',
    '清除查詢結果': 'Clear search results',
    '查詢角色': 'Search characters',
    '匯入此作品角色與可辨識特徵': 'Import this title’s characters and recognizable traits',
    '刪除原創角色預設？': 'Delete original-character preset?',
    '儲存姿勢組合': 'Save pose package',
    '已選姿勢標籤': 'Selected pose tags',
    '姿勢自然敘述': 'Natural pose description',
    '新版服裝輸出預覽：': 'New clothing-output preview:',
    '已套用・可修改': 'Applied · editable',
    '套用到此人物': 'Apply to this person',
    '移除套用': 'Remove application',
    '編輯': 'Edit',
    '我的姿勢組合': 'My pose packages',
    '儲存目前姿勢組合': 'Save current pose package',
    '請先選擇至少一件服裝或配件，再使用整套配色表。':
        'Choose at least one clothing item or accessory before using the full-outfit palette.',
    '整套配色表': 'Full-outfit palette',
    '選擇套用部位': 'Choose sections to apply',
    '全選': 'Select all',
    '套用至目前服裝': 'Apply to current clothing',
    '清空配色表': 'Clear palette',
    '先選擇物件，再指定該人物目前物件的顏色。':
        'Choose an object first, then set the color for this character’s current object.',
    '物件顏色': 'Object color',
    '加強髮長／髮型／髮色': 'Strengthen hair length / style / color',
    '髮型權重': 'Hair weight',
    '整套服裝權重': 'Full-outfit weight',
    '個別服裝部位加強': 'Individual clothing-part strength',
    '髮型套件': 'Hair style packages',
    '套用後只是勾選既有髮色、髮長與髮型，可再自由修改。':
        'Applying a package only checks existing hair color, length, and style tags; you can still edit them freely.',
    '這個分類目前沒有可用的公開標籤': 'This category currently has no available public tags',
    '人物設定為不需細節，不加入此類標籤。':
        'This person is set to no details, so tags in this category are not added.',
    '雙人互動套件': 'Two-person interaction packages',
    '姿勢隨機': 'Randomize pose',
    '姿勢套件（主題）': 'Pose packages (themes)',
    '全部改為散落': 'Set all to scattered',
    '下一步：姿勢與互動': 'Next: pose & interaction',
    '下一步：場景': 'Next: scene',
    '完成角色：下一步特徵': 'Finish characters: next, traits',
    '複製全部': 'Copy all',
    '下載清單': 'Download list',
    '清除清單': 'Clear list',
    '啟用權重': 'Enable weight',
    '人物權重': 'Character weight',
    '全域補充': 'Global additions',
    '標籤反推': 'Reverse tag matching',
    '分析並建立標籤': 'Analyze and create tags',
    '下一步：品質與負面': 'Next: quality & negative',
    '新增標籤': 'Add tag',
    '提示詞': 'Prompt',
    '清除分鏡': 'Clear storyboard',
    '動畫動態語句（英文）': 'Video motion text (English)',
    '新增下一個場景': 'Add next scene',
    '部位動作': 'Body-part actions',
    '動作流程與聲音': 'Action flow & sound',
    '此套件沒有其他標籤。': 'This package has no other tags.',
    '此套件以完整自然敘述保留動作關係。':
        'This package keeps its action relationship as a complete natural-language prompt.',
    '原始米白款': 'Original preset',
  };

  static final List<MapEntry<String, String>> _partialUiEnglishEntries =
      _uiEnglish.entries.toList()
        ..sort((left, right) => right.key.length.compareTo(left.key.length));
}

/// A drop-in [Text] replacement. It keeps existing `const Text(...)` calls
/// valid while every ordinary text label reacts to the selected UI language.
class Text extends material.StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final material.TextStyle? style;
  final material.StrutStyle? strutStyle;
  final material.TextAlign? textAlign;
  final material.TextDirection? textDirection;
  final material.Locale? locale;
  final bool? softWrap;
  final material.TextOverflow? overflow;
  final material.TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final material.TextWidthBasis? textWidthBasis;
  final material.TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  material.Widget build(material.BuildContext context) => material.Text(
        UiLanguageController.displayText(data),
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel == null
            ? null
            : UiLanguageController.uiText(semanticsLabel!),
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
}

extension LocalizedInputDecoration on material.InputDecoration {
  material.InputDecoration localized() => copyWith(
        labelText: labelText == null ? null : UiLanguageController.uiText(labelText!),
        helperText:
            helperText == null ? null : UiLanguageController.uiText(helperText!),
        hintText: hintText == null ? null : UiLanguageController.uiText(hintText!),
        prefixText:
            prefixText == null ? null : UiLanguageController.uiText(prefixText!),
        suffixText:
            suffixText == null ? null : UiLanguageController.uiText(suffixText!),
        counterText:
            counterText == null ? null : UiLanguageController.uiText(counterText!),
      );
}
