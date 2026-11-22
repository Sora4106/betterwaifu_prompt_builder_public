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
    '服裝與穿脫狀態': 'Clothing & wear state',
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
    '中文翻譯與記憶欄位': 'Selected tags & memory',
    'English prompt · 可直接貼上': 'English prompt · ready to paste',
    '匯出標籤 TXT': 'Export tags TXT',
    '匯出目前選擇 JSON': 'Export current selection JSON',
    '匯入目前選擇 JSON': 'Import current selection JSON',
    '記憶與備份': 'Memory & backup',
    '正在準備標籤與本機記憶…': 'Preparing tags and local memory…',
    '介面語言': 'Interface language',
    '網站使用聲明': 'Website usage notice',
    '語言': 'Language',
    '選擇語言': 'Choose language',
    '使用瀏覽器語言作為預設': 'Browser language is used as the default',
    '繁體中文（顯示中英文標籤）': 'Traditional Chinese (show Chinese + English tags)',
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
    '華麗人偶風': 'Ornate doll fashion',
    '金色闇・萬聖節': 'Golden Darkness · Halloween',
    '25時・奏': 'Nightcord at 25:00 · Kanade',
    '大圖書館・土岐野乃美': 'Daitoshokan · Nomi Tokino',
    '大圖書館・鈴木佳奈': 'Daitoshokan · Kana Suzuki',
    '大圖書館・嬉野紗弓實': 'Daitoshokan · Sayumi Ureshino',
    '大圖書館・藤宮朔夜': 'Daitoshokan · Sakuya Fujimiya',
    '附件套裝・A 時尚／角色': 'Attached outfits · A Fashion / characters',
    '附件套裝・B 主題／幻想': 'Attached outfits · B Themes / fantasy',
    '附件套裝・C 居家／睡衣': 'Attached outfits · C Home / sleepwear',
    '武器呈現方式': 'Weapon presentation',
    '雙色漸層髮': 'Two-color gradient hair',
    '色 1': 'Color 1',
    '色 2': 'Color 2',
    '上衣袖子顏色': 'Sleeve color 1',
    '上衣袖子次色': 'Sleeve color 2',
    '帽子顏色': 'Hat color 1',
    '帽子邊線色': 'Hat color 2',
    '眼鏡顏色': 'Eyewear color 1',
    '眼鏡邊線色': 'Eyewear color 2',
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
    // Catalogue groups and dynamically generated option categories.
    '互動・物件動作': 'Interaction · object actions',
    '光影效果': 'Lighting effects',
    '自訂特徵': 'Custom traits',
    '角色標籤': 'Character tags',
    '角色扮演': 'Roleplay',
    '固定外觀・臉部結構': 'Fixed appearance · facial structure',
    '原作角色服裝': 'Canonical character outfit',
    '特殊服裝': 'Special clothing',
    '服裝・主要風格': 'Clothing · primary style',
    '服裝・子風格': 'Clothing · secondary style',
    '服裝・氣質': 'Clothing · mood',
    '服裝・場合': 'Clothing · occasion',
    '配件位置': 'Accessory position',
    '翅膀類型': 'Wing type',
    '翅膀顏色': 'Wing color',
    '獸化特徵': 'Anthropomorphic traits',
    '獸耳顏色': 'Animal-ear color',
    '獸尾顏色': 'Animal-tail color',
    '獸手顏色': 'Animal-hand color',
    '獸足顏色': 'Animal-foot color',
    '動態輔助・官方效果': 'Motion aids · official effects',
    '雙人互動・撫摸／安撫': 'Two-person interaction · petting / soothing',
    '頭部動態・眼睛／視線': 'Head motion · eyes / gaze',
    '頭部動態・嘴巴／口型': 'Head motion · mouth',
    '頭部動態・挑逗': 'Head motion · teasing',
    '頭部動態・符號表情': 'Head motion · symbol expressions',
    '頭部動態・情緒／其他': 'Head motion · emotion / other',
    '場景效果／渲染': 'Scene effects / rendering',
    '畫面裝飾圖': 'Image decorations',
    '畫面風格／媒材': 'Visual style / medium',
    '畫面氛圍': 'Visual atmosphere',
    '裝備類型・武器／法具': 'Equipment type · weapons / magic tools',
    '裝備類型・防具／護具': 'Equipment type · armor / protective gear',
    '物件・家具／室內': 'Objects · furniture / interior',
    '物件・飲食／餐具': 'Objects · food / tableware',
    '物件・學習／藝術／音樂': 'Objects · study / art / music',
    '物件・科技／媒體': 'Objects · technology / media',
    '物件・運動／戶外': 'Objects · sport / outdoors',
    '物件・工具／科學／遊戲': 'Objects · tools / science / games',
    '物件・奇幻道具': 'Objects · fantasy props',
    '物件・交通／旅行': 'Objects · transport / travel',
    '物件・日常／裝飾': 'Objects · daily life / decoration',
    '物件・衣物／貼身衣物': 'Objects · clothing / underwear',
    '物件・透明／玻璃建材': 'Objects · transparent / glass structures',
    '物件・動物／寵物': 'Objects · animals / pets',
    '艾爾之光・職業套裝': 'Elsword · class outfit',
    '艾爾之光・職業識別': 'Elsword · class identity',
    '艾爾之光・原作服裝設定': 'Elsword · canonical outfit settings',
    '艾爾之光・職業頭部特徵': 'Elsword · class head traits',
    '艾爾之光・上身細節': 'Elsword · upper-body details',
    '艾爾之光・下身與腿部': 'Elsword · lower body and legs',
    '艾爾之光・頭部飾品': 'Elsword · head accessories',
    '艾爾之光・配色與飾邊': 'Elsword · colors and trim',
    '艾爾之光・鞋襪細節': 'Elsword · footwear details',
    '艾爾之光・飾品與裝置': 'Elsword · accessories and devices',
    '武器／法具': 'Weapons / magic tools',
    '防具／護具': 'Armor / protective gear',
    '下身／褲子': 'Bottom / pants',
    '下身／短褲': 'Bottom / shorts',
    '髮飾': 'Hair accessories',
    '連身裝顏色': 'One-piece color',
    '全套／散落狀態': 'Full outfit / scattered state',
    '外套穿脫／暴露': 'Outerwear wear / exposure',
    '上衣穿脫／暴露': 'Top wear / exposure',
    '連身裝穿脫／暴露': 'One-piece wear / exposure',
    '特殊服裝穿脫／暴露': 'Special clothing wear / exposure',
    '長褲穿脫／暴露': 'Pants wear / exposure',
    '短褲穿脫／暴露': 'Shorts wear / exposure',
    '裙子穿脫／暴露': 'Skirt wear / exposure',
    '內衣穿脫／暴露': 'Underwear wear / exposure',
    '胸罩穿脫／暴露': 'Bra wear / exposure',
    '內褲穿脫／暴露': 'Panties wear / exposure',
    '襪子／連褲襪穿脫': 'Socks / tights wear state',
    '鞋子穿脫': 'Footwear wear state',
    '配件穿脫': 'Accessory wear state',
    '穿脫／暴露狀態': 'Wear / exposure state',
    '剪裁': 'Cut',
    '上身剪裁': 'Upper-body cut',
    '下身剪裁': 'Lower-body cut',
    '版型': 'Fit',
    '長度': 'Length',
    '官方精準': 'Official tags',
    '描述補充': 'Descriptive details',
    '衣種': 'Garment type',
    '裝飾': 'Decoration',
    '整體描述': 'Overall description',
    '穿脫': 'Wear state',
    '裝飾／細節': 'Decoration / details',
    '圖案': 'Pattern',
    '裝飾色': 'Decoration color',
    '袖子色彩 1': 'Sleeve color 1',
    '袖子色彩 2': 'Sleeve color 2',
    '連身裝色彩 1': 'One-piece color 1',
    '連身裝色彩 2': 'One-piece color 2',
    '上衣色彩 1': 'Top color 1',
    '上衣色彩 2': 'Top color 2',
    '下身色彩 1': 'Bottom color 1',
    '下身色彩 2': 'Bottom color 2',
    '長褲色彩 1': 'Pants color 1',
    '長褲色彩 2': 'Pants color 2',
    '短褲色彩 1': 'Shorts color 1',
    '短褲色彩 2': 'Shorts color 2',
    '裙子色彩 1': 'Skirt color 1',
    '裙子色彩 2': 'Skirt color 2',
    '內衣色彩 1': 'Underwear color 1',
    '內衣色彩 2': 'Underwear color 2',
    '胸罩色彩 1': 'Bra color 1',
    '胸罩色彩 2': 'Bra color 2',
    '內褲色彩 1': 'Panties color 1',
    '內褲色彩 2': 'Panties color 2',
    '襪子色彩 1': 'Socks color 1',
    '襪子色彩 2': 'Socks color 2',
    '鞋子色彩 1': 'Footwear color 1',
    '鞋子色彩 2': 'Footwear color 2',
    '外套色彩 1': 'Outerwear color 1',
    '外套色彩 2': 'Outerwear color 2',
    '配件色彩 1': 'Accessory color 1',
    '配件色彩 2': 'Accessory color 2',
    '帽子色彩 1': 'Hat color 1',
    '帽子色彩 2': 'Hat color 2',
    '眼鏡色彩 1': 'Eyewear color 1',
    '眼鏡色彩 2': 'Eyewear color 2',
    // Remaining option labels, field labels, and UI actions.
    '初次開啟時會依瀏覽器的偏好語言預設；之後可隨時從右上角切換。':
        'The initial default follows your browser language. You can switch it at any time from the top-right menu.',
    '繁體中文 / Traditional Chinese': 'Traditional Chinese',
    '加入': 'Add',
    '加入並選取': 'Add and select',
    '人物共用防呆（自動加入）': 'Shared character safeguards (automatic)',
    '可自行調整的負面標籤': 'Adjustable negative tags',
    '清除分析結果': 'Clear analysis results',
    '反推預覽（尚未套用）': 'Reverse-match preview (not applied)',
    '反向分析結果（可點選移除）': 'Reverse-analysis results (tap to remove)',
    '刪除此人物？': 'Delete this person?',
    '確認刪除': 'Delete',
    '匯入': 'Import',
    '已儲存的原創角色': 'Saved original characters',
    '刪除目前原創角色預設': 'Delete current original-character preset',
    '儲存為原創角色特徵組合': 'Save as an original-character trait preset',
    '自訂角色': 'Custom character',
    '其他': 'Other',
    '不輸出此項': 'No output',
    '色 1（主色）': 'Color 1 (primary)',
    '色 2（次色）': 'Color 2 (secondary)',
    '色 1（整套主色）': 'Color 1 (full-outfit primary)',
    '色 2（整套次色）': 'Color 2 (full-outfit secondary)',
    '整套主色': 'Full-outfit primary color',
    '整套次色／邊線色': 'Full-outfit secondary / trim color',
    '清除物件顏色': 'Clear object color',
    '獸人特徵色': 'Anthropomorphic trait colors',
    '點選要設定的細分類': 'Choose a subcategory to configure',
    '點選展開選項': 'Tap to expand options',
    '全系統標籤搜尋': 'Search all system tags',
    '標籤資料庫': 'Tag database',
    '組合設定': 'Package settings',
    '每位人物分別設定': 'Configure each person separately',
    '隨機場景與畫面': 'Randomize scene and framing',
    '下一步：角色資料': 'Next: characters',
    '下一步：服裝': 'Next: clothing',
    '下一步：自行輸入': 'Next: manual input',
    '清除本大項標籤': 'Clear tags in this section',
    '本大項英文輸出（保留括號位置）': 'English output for this section (preserve parentheses)',
    '本大項目前沒有已選標籤。': 'No tags are selected in this section.',
    '本大項目前沒有英文輸出。': 'This section currently has no English output.',
    '快速鏡頭配置': 'Quick camera presets',
    '場景／地點': 'Scene / location',
    '鏡頭構圖／取景範圍': 'Camera composition / framing',
    '觀看方向／鏡頭角度': 'View direction / camera angle',
    '透視效果': 'Perspective effect',
    '畫面焦點': 'Image focus',
    '影片運鏡（自然語句）': 'Camera movement (natural language)',
    '起始姿勢': 'Starting pose',
    '手臂／手部': 'Arms / hands',
    '軀幹／腰臀': 'Torso / waist and hips',
    '腿部／腳部': 'Legs / feet',
    '主要動態': 'Primary motion',
    '結束姿勢': 'Ending pose',
    '一般音訊／環境音': 'General audio / ambience',
    '補充動態敘述（可選）': 'Additional motion direction (optional)',
    '往前移動': 'Move forward',
    '往後移動': 'Move backward',
    '重設此場景': 'Reset this scene',
    '刪除此場景': 'Delete this scene',
    '這個分鏡的主要人物': 'Main person in this scene',
    '複製動畫動態語句': 'Copy video motion text',
    '動畫動態語句': 'Video motion text',
    '選擇動漫': 'Choose anime',
    '保留角色特徵': 'Keep character traits',
    '只保留角色名稱': 'Keep character name only',
    '開啟角色名稱清單 Character Select SAA':
        'Open the Character Select SAA character list',
    '角色名稱清單（Character Select SAA）': 'Character list (Character Select SAA)',
    '查無此動漫角色，可自行新增角色資料。':
        'No character was found for this anime. You can add character data manually.',
    '新增自訂動漫與角色': 'Add custom anime and character',
    '保留名稱／取消特徵': 'Keep name / remove traits',
    '保留名稱／恢復特徵': 'Keep name / restore traits',
    '原創作品／世界觀中文（可選）': 'Original work / setting in Chinese (optional)',
    'Original work English（可選）': 'Original work in English (optional)',
    '原創角色名稱（僅供清單辨識）': 'Original character name (list identification only)',
    '原創角色固定特徵（中英文皆可）': 'Original character fixed traits (Chinese or English)',
    '未加入標籤': 'Uncatalogued tags',
    '額外正向標籤': 'Extra positive tags',
    '共用自然敘述動作': 'Shared natural-language action',
    '角色特徵補充': 'Additional character traits',
    '服裝／配件補充': 'Additional clothing / accessories',
    '原作服裝版本／變體（選填）': 'Canonical outfit version / variant (optional)',
    '個人姿勢／動作補充': 'Additional personal pose / action',
    'Amanatsu 品質前綴（可修改）': 'Amanatsu quality prefix (editable)',
    '中文欄位': 'Chinese field',
    '匯出完整狀態 JSON': 'Export full state JSON',
    '匯入完整狀態 JSON': 'Import full state JSON',
    '載入': 'Load',
    '切換介面語言': 'Change interface language',
    '移到左側': 'Move to the left',
    '移到右側': 'Move to the right',
    '將導覽按鈕移到左側': 'Move navigation buttons to the left',
    '將導覽按鈕移到右側': 'Move navigation buttons to the right',
    '前往中英文提示詞輸出': 'Go to prompt output',
    '複製正向英文標籤': 'Copy positive English tags',
    '正向英文標籤': 'Positive English tags',
    '複製負面英文標籤': 'Copy negative English tags',
    '負面英文標籤': 'Negative English tags',
    'Amanatsu / BetterWaifu 使用提示': 'Amanatsu / BetterWaifu usage tips',
    // Help text and empty states shown beside option controls.
    '「官方」是 Danbooru Hair Styles 群組中的精確標籤，通常較容易被 Amanatsu 辨識；「描述」是髮廊名稱或自然語句，效果依模型而異，建議再搭配官方髮型、髮長與髮色。':
        'Official entries are exact tags from the Danbooru Hair Styles group and are usually easier for Amanatsu to recognize. Descriptions are salon names or natural-language phrases; results vary by model, so pair them with an official hairstyle, hair length, and hair color.',
    '1. 選擇服裝部位與款式': '1. Choose clothing sections and items',
    '2. 裝備類型': '2. Equipment type',
    '4. 整體風格、氣質與場合': '4. Overall style, mood, and occasion',
    '5. 部位穿脫／暴露狀態': '5. Per-section wear / exposure state',
    '下一步': 'Next',
    '繼續': 'Continue',
    '已選防具配色': 'Selected armor colors',
    '中文或英文，逗號／換行分隔': 'Chinese or English, separated by commas or line breaks',
    '中文或英文皆可；建議描述節奏、視線、物件互動或不在選項中的細節。':
        'Chinese or English; describe timing, gaze, object interaction, or details not covered by the options.',
    '公開版僅提供一般場景、角色動作與鏡頭分鏡選項。':
        'The public edition provides general scenes, character actions, and camera storyboard options only.',
    '以場景順序建立短片提示。每個分鏡會輸出英文自然語句，可貼到 BetterWaifu 的影片／動畫提示欄；不會加入下方的靜態生圖提示詞。':
        'Build a short-video prompt in scene order. Each storyboard scene outputs natural English ready for BetterWaifu’s video or animation prompt field and does not affect the still-image prompt below.',
    'Jikan / MyAnimeList 公開資料': 'Public Jikan / MyAnimeList data',
    '人物數量與性別請在「角色資料」區直接增加、減少人物卡片並分別設定。':
        'Add or remove character cards and set each person’s gender directly in Characters.',
    '分析完成後輸入欄會清空，結果會轉為可點選的系統標籤或額外標籤。':
        'After analysis, the input is cleared and results become selectable system or extra tags.',
    '輸入欄已清空；點選標籤或 X 可排除單一項目，再套用保留的標籤。':
        'The input has been cleared. Tap a tag or X to exclude an item, then apply the remaining tags.',
    '所有分析項目已排除。': 'All analysis items have been excluded.',
    '只會併入此人物的特徵括號區塊。': 'Added only to this person’s trait block.',
    '只會併入此人物的服裝括號區塊，不會跑到姿勢或場景。':
        'Added only to this person’s clothing block, never to pose or scene.',
    '只會併入此人物的姿勢括號區塊。': 'Added only to this person’s pose block.',
    '可勾選單一部位並設定自己的權重；已啟用整套權重時，勾選的部位會覆寫整套數值。':
        'Select individual sections and set their own weights. When full-outfit weighting is enabled, selected sections override the full-outfit value.',
    '可輸入或拖曳設定 0.50–1.50；未勾選時髮長、髮型與髮色會維持在角色基本特徵權重區塊。':
        'Enter or drag to set 0.50–1.50. When disabled, hair length, style, and color remain in the basic character-traits weight block.',
    '開啟時所有服裝部位都套用同一權重；關閉後只加強下方勾選的部位。':
        'When enabled, every clothing section uses the same weight. When disabled, only the sections selected below are strengthened.',
    '可指定套用部位；其他部位保留原本配色':
        'Choose which sections to recolor; other sections keep their original colors',
    '目前只保留角色名稱與出處；固定外觀特徵已取消。':
        'Only the character name and source are kept; fixed appearance traits are disabled.',
    '角色名稱與出處已加入；下方會自動勾選固定外觀特徵，可在特徵中另行調整。':
        'The character name and source were added. Fixed appearance traits are selected automatically below and can be adjusted in Traits.',
    '目前資料只存在這個瀏覽器的 localStorage；清除網站資料會移除記憶。':
        'Data is stored only in this browser’s localStorage. Clearing site data removes it.',
    '完整狀態 JSON 會分區保存已勾選標籤與各人物／服裝／姿勢的額外正向詞；匯入時會覆蓋並回填到原欄位。':
        'Full-state JSON stores selected tags and extra positive text for each character, outfit, and pose section. Importing overwrites current data and restores the original fields.',
    '匯入會覆蓋目前所有已勾選標籤、人物設定、各區額外正向詞、套裝與負面標籤。':
        'Importing overwrites all selected tags, character settings, section-specific extra text, packages, and negative tags.',
    '先勾選要套用的服裝部位，再設定色 1 主色與可選的色 2 次色。未勾選部位會維持原本配色。':
        'Select the clothing sections to recolor, then set primary Color 1 and optional secondary Color 2. Unselected sections keep their original colors.',
    '先套用服裝，再選擇是否附帶專屬武器。':
        'Apply the outfit first, then choose whether to include its exclusive weapon.',
    '先選擇服裝、配件或裝備後即可設定。': 'Choose clothing, accessories, or equipment first.',
    '先選擇姿勢、動作或填入姿勢自然敘述後即可儲存。':
        'Choose a pose or action, or enter a natural pose description, before saving.',
    '先選擇翅膀類型，顏色選項就會直接顯示在翅膀設定內。':
        'Choose a wing type to show its color options in the wing settings.',
    '先選擇獸耳、獸尾、獸手或獸足，對應的顏色選項就會直接顯示在特徵內。':
        'Choose animal ears, tail, hands, or feet to show the matching color options in Traits.',
    '選擇第一種髮色後，再選第二種髮色即可建立漸層。':
        'Choose a first hair color, then a second one to create a gradient.',
    '再點其他顏色會只替換色 2；若要更換色 1，請先點色 1 取消後再選擇。':
        'Choosing another color replaces only Color 2. To replace Color 1, clear it first and then choose a new color.',
    '色 1 為主色；色 2 為次色漸層。選取第三色時會取代色 2。':
        'Color 1 is primary and Color 2 is the secondary gradient color. Choosing a third color replaces Color 2.',
    '依序點選顏色：第一色為主色、第二色為次色。兩色都選好後，再點新色只替換色 2；可用上方 X 分別清除。輸出敘述維持主色與邊線／細節色的原本規則。':
        'Choose colors in order: the first is primary and the second is secondary. After both are set, another choice replaces only Color 2. Use the X buttons above to clear either color.',
    '套用後，各部位原有顏色會被這組配色取代；仍可在下方各部位的色 1／色 2 使用 X 取消或另選顏色。':
        'Applying this palette replaces each section’s current colors. You can still clear or replace Color 1 and Color 2 in each section below.',
    '尚未勾選套用部位。': 'No target sections are selected.',
    '配色：色 1／色 2': 'Palette: Color 1 / Color 2',
    '全套服裝散落：保留穿著部位': 'Full outfit scattered: keep selected sections worn',
    '目前未選擇可轉為散落的服裝；套件仍會輸出全裸與衣物散落提示。選好服裝後可回到此處逐部位設定。':
        'No clothing is available to scatter yet. The package still outputs full nudity and scattered clothing. Choose clothing, then return here to configure each section.',
    '預設所有已選服裝都會散落在周邊。勾選部位即可讓它維持穿著；未勾選的部位會輸出為掉在地上。':
        'By default, all selected clothing is scattered nearby. Select sections to keep them worn; unselected sections are placed on the ground.',
    '完整服裝配置・套用後可自由調整；原始組合不會變更':
        'Complete outfit configuration · freely adjustable after applying; the saved package is unchanged',
    '預設收合；套用後仍可調整各服裝部位與色彩':
        'Collapsed by default; clothing sections and colors remain adjustable after applying',
    '尚未儲存自訂姿勢組合。': 'No custom pose packages have been saved.',
    '尚未儲存原創角色。可直接在目前角色資料填寫固定特徵後儲存。':
        'No original character has been saved. Enter fixed traits in the current character card and save it.',
    '尚無儲存組合。按輸出結果右上角的書籤按鈕即可保存。':
        'No packages have been saved. Use the bookmark button at the top-right of Output to save one.',
    '自訂內容會只儲存在此瀏覽器，不會上傳。':
        'Custom content is stored only in this browser and is never uploaded.',
    '自訂標籤、角色資料、已儲存組合與版本記錄不會被刪除。':
        'Custom tags, character data, saved packages, and version history are not deleted.',
    '此人物只輸出人數/性別 tag，不加入動漫名稱、角色名稱或特徵。':
        'This person outputs only count and gender tags, without anime, character name, or traits.',
    '此人物設定為不需細節，不加入此類標籤。':
        'This person is set to no details, so tags in this category are not added.',
    '此人物設定為不需細節，不加入服裝標籤。':
        'This person is set to no details, so clothing tags are not added.',
    '此人物設定為不需細節，保留個人姿勢／動作補充可用。':
        'This person is set to no details; additional personal pose and action text remains available.',
    '此人物不使用角色外觀與服裝細節；仍可設定個人姿勢、動作與自然敘述。':
        'This person does not use appearance or clothing details, but personal poses, actions, and natural-language descriptions remain available.',
    '此分類沒有符合的標籤，可以切換細分類、清除搜尋或新增自訂標籤。':
        'No tags match this category. Switch subcategories, clear the search, or add a custom tag.',
    '此區可上下滑動，建議使用搜尋快速縮小範圍。':
        'This section scrolls vertically. Use search to narrow the list quickly.',
    '此名稱不會加入英文或中文提示詞；可直接在此步驟保存固定特徵。':
        'This name is not included in either prompt. Fixed traits can be saved directly in this step.',
    '此頁內容會獨立儲存，不會變更圖片提示詞；完成後複製最下方英文動態語句。':
        'This page is stored separately and does not change the image prompt. Copy the English motion text at the bottom when finished.',
    '所有自行輸入集中於此。每個欄位的內容仍會依用途輸出到角色特徵、服裝、個人姿勢或多人共用動作的正確括號區塊；貼上會取代目前欄位內容，X 可立即清空。':
        'All manual input is collected here. Each field is still placed in the correct character-traits, clothing, personal-pose, or shared-action block. Pasting replaces the current field; X clears it immediately.',
    '輸出在人物與共用動作後方；英文原樣保留，中文會依系統對照轉換。':
        'Output after characters and shared actions. English is preserved; Chinese is converted using the built-in mappings.',
    '輸出在所有人物後方，適合多人共用互動或未收錄的自然敘述。':
        'Output after all characters; suitable for shared interactions or uncatalogued natural-language actions.',
    '角色基本特徵與整套服裝會各自使用括號權重；表情、姿勢、動作與場景維持一般權重。':
        'Basic character traits and full outfits use separate parenthesized weights; expressions, poses, actions, and scenes keep normal weight.',
    '貼上既有提示詞': 'Paste an existing prompt',
    '貼上後按「分析並建立標籤」，可再逐一排除不需要的項目':
        'After pasting, choose Analyze and create tags, then exclude unwanted items individually',
    '輸入關鍵字後會搜尋整個系統的公開標籤。':
        'Enter a keyword to search all public tags in the system.',
    '沒有符合條件的標籤。可以用右上角「新增標籤」建立自己的中文/英文內容。':
        'No tags match. Use Add tag at the top-right to create your own Chinese / English entry.',
    '搜尋中文或英文標籤…': 'Search Chinese or English tags…',
    '搜尋此區所有中英文標籤…': 'Search all Chinese and English tags in this section…',
    '負面提示內容已隱藏；仍可在下方調整，並使用左側 N 按鈕複製英文內容。':
        'Negative prompt content is hidden. You can still edit it below and use the N button on the left to copy the English text.',
    '負面提示內容已隱藏；仍可選擇標籤並使用左側 N 按鈕複製。':
        'Negative prompt content is hidden. You can still choose tags and use the N button on the left to copy it.',
    '取消勾選只會從此套裝的輸出移除該部位；職業設定、其他部位與武器不會受影響。':
        'Turning off a section removes only that section from this preset. Class context, other sections, and weapons remain unchanged.',
    '選取後可用下方上衣／下衣的色彩、剪裁、材質與裝飾調整原作服裝；兩部分會各自以括號輸出。':
        'After selecting, adjust canonical top and bottom colors, cuts, materials, and decorations below. Each part is output in its own parentheses.',
    '這些描述作用於整套穿搭，不會取代上方已選的服裝種類與細節。':
        'These descriptions apply to the whole outfit and do not replace the selected clothing items or details above.',
    '請先在上方目前部位選擇一件服裝，再設定其顏色、細節與穿脫狀態。':
        'Choose a clothing item in the current section above before setting its colors, details, and wear state.',
    '選取後會恢復已儲存的原創角色固定特徵；名稱只供清單辨識，不會輸出為提示詞。':
        'Selecting restores the saved original character’s fixed traits. The name identifies the list item and is not output as a prompt.',
    '填寫角色名稱，並在此輸入至少一項固定特徵，或選擇既有特徵後即可儲存。':
        'Enter a character name and at least one fixed trait here, or choose existing traits, before saving.',
    '填寫角色名稱與至少一項特徵後，即可直接在此步驟儲存；不必先到固定角色外觀勾選標籤。':
        'Enter a character name and at least one trait to save directly in this step; you do not need to select tags in Character Traits first.',
    '會跟在「原作設定服裝」後方，作為模型可理解的補充描述。':
        'Appended after the canonical outfit as an additional model-readable description.',
    '例如：brown hair, green eyes, long hair':
        'e.g. brown hair, green eyes, long hair',
    '例如：game 1 outfit, alternate outfit':
        'e.g. game 1 outfit, alternate outfit',
    '例如：silver facial markings, delicate freckles':
        'e.g. silver facial markings, delicate freckles',
    '例如：silver moon-shaped choker necklace':
        'e.g. silver moon-shaped choker necklace',
    '例如：swinging a sword in a wide arc while stepping forward':
        'e.g. swinging a sword in a wide arc while stepping forward',
    '例如：walking together while playfully holding hands':
        'e.g. walking together while playfully holding hands',
    '完整姿勢套件資料庫': 'Complete pose package database',
    '姿勢大分類': 'Pose categories',
    '① 頭部／表情': '① Head / expression',
    '② 手部／上半身': '② Hands / upper body',
    '③ 腰臀／腿腳': '③ Hips / legs and feet',
    '④ 基本姿勢': '④ Basic poses',
    '⑤ 單人・場所姿勢': '⑤ Solo / location poses',
    '⑥ 動態／獸人姿勢': '⑥ Dynamic / anthropomorphic poses',
    '⑦ 物件・道具互動': '⑦ Object / prop interaction',
    '⑧ 人物互動': '⑧ Character interaction',
    '頭部姿勢': 'Head poses',
    '手臂姿勢': 'Arm poses',
    '手部姿勢': 'Hand poses',
    '手部・接觸位置': 'Hands · contact positions',
    '手指・指向方向': 'Fingers · pointing directions',
    '手指・手勢形狀': 'Fingers · gesture shapes',
    '手指・嘴臉互動': 'Fingers · mouth / face interaction',
    '手指・細節動作': 'Fingers · detailed actions',
    '軀幹姿勢': 'Torso poses',
    '軀幹・腰臀動態': 'Torso · waist / hip motion',
    '軀幹・角度控制': 'Torso · angle control',
    '臀部・髖部細節': 'Hips · hip details',
    '臀部・角度控制': 'Hips · angle control',
    '臀部・正背面構圖': 'Hips · front / back framing',
    '腿部姿勢': 'Leg poses',
    '腿部・角度控制': 'Legs · angle control',
    '大腿・膝蓋動態': 'Thigh / knee motion',
    '小腿・腳踝動態': 'Lower-leg / ankle motion',
    '腳掌・腳趾動態': 'Feet / toe motion',
    '站立與蹲姿': 'Standing & crouching',
    '坐姿與跪姿': 'Seated & kneeling poses',
    '躺臥姿勢': 'Lying poses',
    '全身姿勢': 'Full-body poses',
    '單人・站姿': 'Solo · standing',
    '單人・靠牆姿勢': 'Solo · leaning against a wall',
    '單人・椅子坐姿': 'Solo · chair sitting',
    '單人・桌邊姿勢': 'Solo · table-side poses',
    '單人・地板坐姿': 'Solo · floor sitting',
    '單人・床上坐姿': 'Solo · sitting on a bed',
    '單人・仰躺姿勢': 'Solo · lying on the back',
    '單人・側躺姿勢': 'Solo · lying on the side',
    '單人・俯臥姿勢': 'Solo · lying face down',
    '單人・跪蹲姿勢': 'Solo · kneeling / crouching',
    '姿勢擴充・站姿與視線': 'Pose expansion · standing & gaze',
    '姿勢擴充・偶像互動': 'Pose expansion · idol interaction',
    '姿勢擴充・成熟站姿': 'Pose expansion · mature standing',
    '姿勢擴充・椅子坐姿': 'Pose expansion · chair sitting',
    '姿勢擴充・床上坐姿': 'Pose expansion · sitting on a bed',
    '姿勢擴充・床上躺姿': 'Pose expansion · lying on a bed',
    '動態姿勢': 'Dynamic poses',
    '身體動作': 'Body movement',
    '姿勢擴充・動態輔助': 'Pose expansion · motion aids',
    '貓系・單人動作': 'Cat-themed · solo actions',
    '獸人動作': 'Anthropomorphic actions',
    '物件・武器／奇幻': 'Objects · weapons / fantasy',
    '親吻動作': 'Kissing actions',
    '多人互動': 'Multi-person interaction',
    '貓系・人物互動': 'Cat-themed · character interaction',
    '動作線': 'Motion lines',
    '高速感': 'Speed',
    '震動感': 'Vibration',
    '節奏感': 'Rhythm',
    '高強度': 'High intensity',
    '單手互動': 'One-hand interaction',
    '雙手互動': 'Two-hand interaction',
    '遮嘴互動': 'Mouth-covering interaction',
    '遮臉互動': 'Face-covering interaction',
    '貓咪互動': 'Cat interaction',
    '狗狗互動': 'Dog interaction',
    '小型寵物': 'Small pets',
    '陪伴構圖': 'Companion composition',
    '玩耍與探索': 'Play & exploration',
    '休息與撒嬌': 'Rest & affection',
    '警覺與防備': 'Alert & guarded',
    '撒嬌與玩耍': 'Affection & play',
    '伸展與放鬆': 'Stretching & relaxation',
    '森林情境': 'Forest scenes',
    '聲音與耳尾動態': 'Sound & ear / tail motion',
    '警覺與偵察': 'Alert & scouting',
    '奔跑與追逐': 'Running & chasing',
    '抱持與依偎': 'Holding & cuddling',
    '撒嬌互動': 'Affectionate interaction',
    '摸頭／安撫': 'Head pat / soothing',
    '摸肚子／安撫': 'Belly rub / soothing',
    '臉部／安撫': 'Face touch / soothing',
    '站姿／日常／可愛／優雅': 'Standing / everyday / cute / elegant',
    '站姿／微性感但SFW': 'Standing / slightly sensual but SFW',
    '地板坐姿／跪姿': 'Floor sitting / kneeling',
    '地板躺姿': 'Floor lying poses',
    '椅子／沙發': 'Chairs / sofas',
    '桌子／書桌／吧台': 'Tables / desks / bars',
    '床上／臥室': 'Bed / bedroom',
    '牆壁／窗戶／門框': 'Walls / windows / doorframes',
    '樓梯／戶外／動態／伸展': 'Stairs / outdoors / motion / stretching',
    '站姿延伸': 'Extended standing poses',
    '走路／動態站姿': 'Walking / dynamic standing poses',
    '坐姿延伸（地面／低台）': 'Extended sitting poses (floor / low platform)',
    '躺姿 / 半躺姿延伸': 'Extended lying / reclining poses',
    '椅子 / 沙發 / 躺椅': 'Chairs / sofas / lounge chairs',
    '桌上 / 邊緣 / 窗台 / 櫃台': 'Tables / edges / windowsills / counters',
    '床上 / 居家 / 慵懶': 'Bed / home / relaxed',
    '牆邊 / 窗邊 / 樓梯 / 戶外': 'Walls / windows / stairs / outdoors',
    '可愛 / 活潑 / 小動作': 'Cute / lively / small gestures',
    '優雅 / 帥氣 / 時裝感': 'Elegant / cool / fashion',
    '抱枕 / 玩偶 / 布偶 / 寢具類': 'Pillows / toys / plushies / bedding',
    '貓咪 / 狗狗 / 小動物抱持': 'Holding cats / dogs / small animals',
    '鳥類 / 企鵝 / 小型生物互動': 'Bird / penguin / small-creature interaction',
    '書本 / 花束 / 雜貨 / 小物抱持': 'Holding books / bouquets / sundries / small items',
    '姿勢隨機（每部位最多一個動作）': 'Randomize pose (up to one action per body section)',
    '隨機目前細分類（自動避開衝突）':
        'Randomize current subcategory (avoid conflicts automatically)',
    '隨機此大項（自動避開衝突）': 'Randomize this section (avoid conflicts automatically)',
    '隨機核心穿搭（每部位最多一件）': 'Randomize core outfit (up to one item per section)',
    '枕頭互動姿勢': 'Pillow interaction poses',
    '動態強化套件': 'Motion enhancement packages',
    '寵物互動姿勢套件': 'Pet interaction pose packages',
    '貓咪單人姿勢套件': 'Cat-themed solo pose packages',
    '狼耳少女姿勢套件': 'Wolf-girl pose packages',
    '多人共同動作': 'Shared multi-person actions',
    '清除多人共同動作': 'Clear shared multi-person actions',
    '移除套裝': 'Remove outfit preset',
    '畫面': 'Visuals',
    '額外特徵顏色': 'Extra-trait color',
    '獸人與特殊角色特徵': 'Anthropomorphic and special character traits',
    '獸耳、獸尾、獸手與獸足': 'Animal ears, tails, hands, and feet',
    '人物': 'Person',
    '作品': 'Title',
    '長褲': 'Pants',
    '整套服裝': 'Full outfit',
    '裝備': 'Equipment',
    '整體服裝設定': 'Overall outfit settings',
    '額外服裝標籤': 'Extra clothing tags',
    '服裝部位': 'Clothing section',
    '未選': 'Not set',
    '例如改變髮色或長短會改變角色原本的形象設定。要套用嗎？':
        'For example, changing hair color or length changes the character’s original appearance. Apply the change?',
    '儲存目前姿勢後，可直接一鍵套用或移除':
        'Save the current pose to apply or remove it later with one click',
    '獸耳、獸尾、獸手與獸足是角色生理特徵，不會自動加入身分類。獸人角色可勾選 anthro；若要全身毛茸茸，可同時加上 furry。選好部位後，顏色會顯示在該特徵下方並合併輸出；服裝造型用的耳飾、尾飾與翅飾請到服裝分類設定。':
        'Animal ears, tails, hands, and feet are physical traits and do not automatically add a species tag. Select anthro for anthropomorphic characters and furry for full-body fur. Colors appear below the selected trait and are merged into its output; use Clothing for decorative ears, tails, and wings.',
    '以 A／B 清楚描述雙方動作；貓系互動也保留在此。':
        'Use A / B to describe each side’s actions clearly; cat-themed interactions are also available here.',
    '這裡設定角色一起進行的互動與親吻。雙人套件會明確寫出 A／B 的行為關係，並輸出在所有角色資訊之後，不使用角色權重。':
        'Configure interactions and kisses performed together. Two-person packages explicitly describe A / B roles and are output after all character details without character weighting.',
    '頭部、表情、上半身、手、臀、腿與腳各自最多一項，隨機時會避開互相衝突的選項。':
        'Randomization selects at most one item each for head, expression, upper body, hands, hips, legs, and feet while avoiding conflicts.',
    '保留貓系與狼系的主題套件；需要時再展開':
        'Cat- and wolf-themed packages remain available; expand them when needed',
    '附件整理的 1,000 組單人姿勢，依場景、姿態與物件互動分類；展開分類後可預覽與套用。':
        'A collection of 1,000 solo poses categorized by scene, posture, and object interaction. Expand a category to preview and apply.',
    '動作線、速度線、動態模糊與震動可單獨套用，也可和一般姿勢一起使用。':
        'Motion lines, speed lines, motion blur, and vibration can be applied alone or combined with regular poses.',
    '單手、雙手、抱枕遮嘴／遮臉與不同枕頭樣式的安全個人姿勢。':
        'Safe solo poses using one or both hands, pillows covering the mouth or face, and multiple pillow styles.',
    '抱著、趴在腹部／腿上、肩上與腳邊等寵物互動；可直接套用後再調整。':
        'Pet interactions including holding, resting on the abdomen or lap, sitting on a shoulder, and staying near the feet; apply and adjust freely.',
    '15 組貓系玩耍、休息、撒嬌與警覺姿態；不會自動加入獸耳、獸尾或 furry。':
        '15 cat-themed playing, resting, affectionate, and alert poses. They do not automatically add animal ears, tails, or furry.',
    '文件整理的 7 組休息、撒嬌與森林用個人姿勢；不會自動加入獸化特徵。':
        '7 solo resting, affectionate, and forest poses from the source document. They do not automatically add anthropomorphic traits.',
    '服裝依頭部到腳部排列；先選衣種，再控制該部位可用的剪裁、版型、長度、材質、裝飾、圖案與顏色。色彩依點選順序使用色 1／色 2；主體衣種與同一色彩欄位維持替換。官方標籤會優先輸出，描述詞則保留作進階補充。':
        'Clothing is ordered from head to toe. Choose an item, then configure its cut, fit, length, material, decoration, pattern, and colors. Colors follow Color 1 / Color 2 selection order; base items and values in the same color slot replace one another. Official tags are prioritized, while descriptive phrases remain available for advanced detail.',
    '依頭到腳切換部位；切換只隱藏其他部位，已選標籤仍會保留。套用整套／轉職服裝後，胸罩、內褲與襪子仍可作為內搭直接加選。':
        'Switch sections from head to toe. Switching only hides other sections and keeps selected tags. After applying a full outfit or class outfit, bras, panties, and socks can still be added as inner layers.',
    '武器、法具、盾牌與防具集中在此；一般衣服維持在上方服裝部位。武器的持握、揮動等互動仍可在「姿勢與互動」中另外設定。':
        'Weapons, magic tools, shields, and armor are configured here; regular clothing remains in the clothing sections above. Set holding, swinging, and other weapon interactions separately in Pose & interaction.',
    '色 1／色 2 直接依序選取，分別輸出主色與次色；所有色調均可直接選，不再依既選色系隱藏。風格、剪裁、版型、長度、材質、細節與圖案可多選。':
        'Choose Color 1 and Color 2 in order for primary and secondary output. Every shade remains available regardless of previous selections. Style, cut, fit, length, material, detail, and pattern allow multiple selections.',
    '依服飾部位分類，全部皆可直接選擇，不必先挑服裝；全套散落、單側露出、滑出與透視可見也集中在對應分類。':
        'Wear states are grouped by clothing section and can be selected without first choosing an item. Full-outfit scattering, one-side exposure, slipping, and see-through visibility are grouped in their matching categories.',
    '獸人角色可選 anthro；需要全身毛茸茸時可再加 furry。扶他會只套用到目前人物，兩者都可同時使用。':
        'Choose anthro for anthropomorphic characters and add furry for full-body fur. Futanari applies only to the current person; both can be used together.',
    '套用後仍可在下方分別修改構圖、方向、透視、焦點與運鏡。':
        'After applying, you can still edit framing, direction, perspective, focus, and camera movement below.',
    '這些詞語目前不在系統標籤庫中，會保留在本機，之後可整理後加入內建標籤。':
        'These terms are not currently in the system catalogue. They remain stored locally and can be curated into built-in tags later.',
    '自動髮長防衝突：角色為長髮時會在負面輸出加入 cropped hair；改選短髮後則加入 long hair。這些自動詞不會改寫上方可編輯欄位。':
        'Automatic hair-length conflict prevention adds cropped hair to the negative output for long-haired characters and long hair after switching to short hair. These automatic terms do not modify the editable field above.',
    '這裡只放固定外觀：髮色、髮型、眼睛類型、臉部結構、身材、獸化部位、翅膀與額外特徵。獸人角色可自行加入 anthro；需要全身毛茸茸時可再加 furry，兩者不會因耳尾而自動加入。表情、視線、嘴型與頭頸動作放在下一個「姿勢」大項。':
        'Use this section only for fixed appearance: hair color and style, eye type, facial structure, body shape, anthropomorphic parts, wings, and extra traits. Add anthro or furry manually when needed; ears and tails do not add them automatically. Expressions, gaze, mouth shape, and head or neck actions belong in the next Pose section.',
    '依序選頭部、上半身、下半身、全身姿勢，再選物件或人物互動。每位人物會保留自己的動作與互動。':
        'Choose head, upper-body, lower-body, and full-body poses in order, then select object or character interactions. Each person keeps their own actions and interactions.',
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
        labelText:
            labelText == null ? null : UiLanguageController.uiText(labelText!),
        helperText: helperText == null
            ? null
            : UiLanguageController.uiText(helperText!),
        hintText:
            hintText == null ? null : UiLanguageController.uiText(hintText!),
        prefixText: prefixText == null
            ? null
            : UiLanguageController.uiText(prefixText!),
        suffixText: suffixText == null
            ? null
            : UiLanguageController.uiText(suffixText!),
        counterText: counterText == null
            ? null
            : UiLanguageController.uiText(counterText!),
      );
}
