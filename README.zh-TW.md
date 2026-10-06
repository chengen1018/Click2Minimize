<p align="center"><a href="README.md">English</a> · <strong>繁體中文</strong></p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/hero-banner-zh-TW-dark.svg">
    <img src="assets/hero-banner-zh-TW.svg" alt="Click2Minimize：讓 macOS Dock 擁有類似 Windows 工作列的視窗切換操作" width="100%">
  </picture>
</p>

<p align="center"><strong>點擊目前正在使用的 App Dock 圖示，即可縮小它的視窗；再點一次即可還原。</strong><br>
Click2Minimize 為 macOS Dock 加上視窗切換功能；開啟 App 與切換 App 仍由 macOS 照原本方式處理。</p>

<p align="center">macOS 13+ · Swift 5 · Xcode 15+ 建置 · <a href="LICENSE">PolyForm Noncommercial 1.0.0</a></p>

<p align="center"><small>以 <a href="https://github.com/hatimhtm/Click2Minimize">Hatim El Hassak 的 Click2Minimize</a> 為基礎。</small></p>

## 看看前後差異

### 使用前 · macOS 預設 Dock

Chrome 已在前景時，點擊它的 Dock 圖示，視窗仍留在畫面上。

![使用前：點擊已在前景的 Chrome Dock 圖示，視窗仍保持開啟](assets/demo-before.gif)

### 使用後 · Click2Minimize

點擊同一個 Dock 圖示，即可在還原與縮小視窗之間切換。這段錄影中，第一次點擊還原 Chrome，下一次點擊則縮小視窗。

![使用後：點擊已在前景的 Chrome Dock 圖示，先還原再縮小視窗](assets/demo-after.gif)

| 點擊 App 的 Dock 圖示時 | macOS 預設行為 | 使用 Click2Minimize |
| --- | --- | --- |
| App 尚未開啟或位於背景 | 開啟或切換至 App | 維持 macOS 原本行為 |
| App 已在前景，且有可見視窗 | App 保持在前景 | **縮小符合條件的可見視窗** |
| App 已在前景，只剩已縮小的視窗 | 由 Dock 照原本方式處理 | **還原符合條件的已縮小視窗** |
| 最前方 App 有全螢幕視窗 | 由 Dock 照原本方式處理 | 維持 macOS 原本行為 |

## 運作方式

第一次點擊 Dock 圖示時，由 macOS 開啟或切換至 App。只有再次點擊**已在前景的 App** 圖示，Click2Minimize 才會接手：

**開啟或切換（macOS）→ 縮小可見視窗 → 還原已縮小視窗**

如果同一個 App 同時有可見和已縮小的視窗，程式會優先縮小可見視窗。再點一次時，會還原符合條件的已縮小視窗，包括先前手動縮小的視窗。

## 開始使用

請在本機建置此衍生版本：

```bash
git clone https://github.com/chengen1018/Click2Minimize.git
cd Click2Minimize
xcodebuild -project Click2Minimize.xcodeproj -scheme Click2Minimize \
  -configuration Release -derivedDataPath build
```

App 位於 `build/Build/Products/Release/Click2Minimize.app`。可以將它移到「應用程式」資料夾後啟動。若要建立臨時簽署的通用架構 DMG，改執行 `./build_dmg.sh`，輸出會位於 `dist/Click2Minimize.dmg`。

### 所需權限

1. 到「**系統設定 → 隱私權與安全性 → 輔助使用**」允許 Click2Minimize，授權後重新啟動 App。
2. macOS 詢問時，允許「**自動化 → System Events**」，讓程式讀取 Dock 圖示的名稱與位置。
3. 從選單列圖示開啟設定，可以開關此功能或啟用「**登入時啟動**」。預設會啟用縮小／還原功能，登入時啟動則預設關閉。

> 本機建置並以臨時憑證簽署的 App，首次啟動時可能需要在 Finder 中按右鍵選擇「打開」。

## 行為與限制

- 點擊 Launchpad、垃圾桶或下載項目時，維持 macOS 原本行為。
- 最前方 App 有全螢幕視窗時，Click2Minimize 會將點擊交由 macOS 處理。
- Finder 只切換標準 Finder 視窗。
- 若 App 沒有透過 macOS「輔助使用」公開視窗，則可能無法操作。

## 為什麼維護這個衍生版本？

此版本著重於多視窗 App、手動縮小的視窗，以及 Finder 的 Dock 切換行為：

- **依目前視窗狀態決定操作：** 只要有可見視窗，就先縮小；若沒有可見視窗，則還原所有符合條件的已縮小視窗，即使那些視窗並非由 Click2Minimize 縮小。
- **篩選 Finder 視窗：** 只操作標準 Finder 視窗。
- **依序處理多個視窗：** 逐一操作，以配合部分 App 非同步更新「輔助使用」視窗清單的情況。

變更記錄請參閱 [CHANGELOG.md](CHANGELOG.md)。

## 架構與運作流程

<p align="center"><img src="assets/architecture-zh-TW.svg" alt="架構圖：工作空間通知更新 Dock 資料；滑鼠點擊經過 Dock 項目比對與條件檢查後，使用輔助使用 API 縮小或還原視窗" width="100%"></p>

兩條流程透過快取的 Dock 資料銜接：

- **更新 Dock 資料：**`NSWorkspace` 的 App 啟動、啟用、結束與空間切換通知，經過 300 毫秒防抖動後，以 AppleScript 向 System Events 讀取 Dock 項目名稱與範圍。
- **處理點擊：**`CGEvent` 事件監聽取得滑鼠左鍵按下事件，比對快取的 Dock 項目，再檢查功能是否啟用、App 是否正在使用中，以及最前方 App 是否處於全螢幕。
- **操作視窗：**`AXUIElement` 讀取 App 視窗。只要有可見視窗，就優先縮小；若沒有可見視窗，則還原已縮小視窗。無需操作時，將原點擊交還 macOS。

目前的啟動流程不會呼叫更新檢查函式。讀取 Dock 資料需仰賴 macOS 的「輔助使用」與「自動化」權限。視窗操作判斷的本機測試位於 [`Tests/WindowToggleDecisionTests.swift`](Tests/WindowToggleDecisionTests.swift)。

## 專案來源與授權

原始專案是 [Hatim El Hassak 的 Click2Minimize](https://github.com/hatimhtm/Click2Minimize)。本儲存庫是以它為基礎的衍生作品，並非獨立從零實作。原始作品及衍生部分仍受 [PolyForm Noncommercial 1.0.0](LICENSE) 授權條款規範。重新散布或修改專案前，請閱讀 [NOTICE.md](NOTICE.md) 與 [LICENSE](LICENSE)。
