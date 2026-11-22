# BetterWaifu Prompt Builder — Public Edition

一個可離線使用的 Flutter Web PWA 提示詞組合工具，供 BetterWaifu／Amanatsu 類型模型整理角色、服裝、場景、一般姿勢與畫面標籤。

## 公開版範圍

- 角色、原創角色、外觀特徵與服裝搭配。
- 場景、鏡頭、一般姿勢、互動、物件與畫面效果。
- 中英文標籤、反推、匯入／匯出、複製與本機 PWA 記憶。
- 僅提供全年齡的角色、服裝、場景、姿勢與畫面提示詞。

## 開發

```powershell
cd flutter_pwa
flutter pub get
flutter run -d chrome
```

GitHub Pages 工作流程會在推送 `main` 後自動建置與部署網站。

## Google AdSense

- 發佈商：`ca-pub-2900796832149095`。
- 自動廣告與網站驗證標籤位於 `flutter_pwa/web/index.html`。
- 隱私權政策位於 `flutter_pwa/web/privacy.html`。
- 授權賣方宣告位於 `flutter_pwa/web/ads.txt`。
- AdSense 會從網域根目錄讀取 `/ads.txt`。GitHub Pages 專案網站目前部署在 `/betterwaifu_prompt_builder_public/`；若未使用自訂網域，還需要在 `sora4106.github.io` 根網站放置相同的 `ads.txt`，或改用指向本專案的自訂網域。
- 上線前請在 AdSense 的「隱私權與訊息」啟用 Google CMP 或其他 Google 認證 CMP。
