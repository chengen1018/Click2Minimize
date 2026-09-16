<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-TW.md">繁體中文</a>
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/hero-banner-dark.svg" />
    <img src="assets/hero-banner.svg" alt="Click2Minimize" width="100%" />
  </picture>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-1A1A1A?style=for-the-badge&logo=apple&logoColor=CCFF00" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-5-1A1A1A?style=for-the-badge&logo=swift&logoColor=CCFF00" alt="Swift 5" />
  <img src="https://img.shields.io/badge/Xcode-16-1A1A1A?style=for-the-badge&logo=xcode&logoColor=CCFF00" alt="Xcode 16" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/LICENSE-POLYFORM_NC-1A1A1A?style=for-the-badge&labelColor=1A1A1A&color=CCFF00" alt="PolyForm Noncommercial" /></a>
</p>

<p align="center">
  <em><strong>點一下 App 的 Dock 圖示，就能將它的視窗縮到最小。</strong>macOS 預設沒有這項操作行為，Click2Minimize 透過約 570 行 Swift 程式碼補上了這個功能。它是一款選單列輔助工具，沒有主視窗，也不收集遙測資料；透過事件監聽（event tap），搭配「輔助使用」API 與 AppleScript 和 Dock 互動。可免費供個人使用，不得用於商業用途（詳見 <a href="LICENSE">LICENSE</a>）。</em>
</p>

---

### `/// 專案來源與致謝`

本儲存庫是以 Hatim El Hassak 開發的 [Click2Minimize](https://github.com/hatimhtm/Click2Minimize) 為基礎的衍生作品。原始專案及其原始碼仍受 [PolyForm Noncommercial 1.0.0 授權條款](LICENSE) 規範。

本儲存庫的修改由 **Chengen** 維護，目前著重於：

- 切換 Dock 圖示對應視窗的狀態時，優先處理可見視窗；
- 還原 App 所有已縮到最小的視窗，包括切換前手動縮到最小的視窗；
- 更安全地處理 Finder，只對標準 Finder 視窗進行操作；
- 用於驗證判斷邏輯的本機測試。

本專案供個人、教育、研究及其他授權允許的非商業用途使用，並非從零獨立實作的 Click2Minimize。

### `/// 功能說明`

在 macOS 上，點擊目前使用中 App 的 Dock 圖示，通常不會有任何變化，只會再次啟用已經在使用中的 App。Click2Minimize 讓這個操作改為將 App 的視窗縮到最小，再點一次即可還原，就像 Windows 工作列的操作方式。

- 點擊**目前使用中** App 的 Dock 圖示 → 將視窗縮到最小。
- 當目前使用中 App 所有符合操作條件的視窗都已縮到最小時，再點擊圖示 → 還原所有符合條件的視窗。
- 點擊**非使用中** App 的圖示 → 保留 macOS 預設行為（啟用 App，將視窗帶到最前方）。
- 點擊 **Launchpad／垃圾桶／下載項目** → 保留預設行為（這些項目沒有可縮到最小的視窗）。
- App 處於**全螢幕**模式 → 不攔截操作，也不將視窗縮到最小。

---

### `/// 運作原理`

```text
NSWorkspace 通知（啟動 App／啟用 App／切換桌面空間）
  → 等待最後一次事件後 300 毫秒（防抖動）
  → 透過 AppleScript 查詢 Dock
  → 更新 Dock 圖示範圍與 App 名稱的快取

CGEvent 事件監聽（滑鼠左鍵按下）
  → 比對滑鼠位置與 Dock 圖示範圍
  → 透過 AXUIElement 將 App 各個可見視窗的
    kAXMinimized 設為 true
```

- **事件監聽**使用 `cghidEventTap`／`tailAppendEventTap`，只擷取滑鼠左鍵按下事件。
- **Dock 圖示範圍**會儲存在快取中，並採用 300 毫秒的尾端防抖動機制更新；短時間內連續觸發的 `didLaunch / didActivate / activeSpaceDidChange` 事件會合併為一次 AppleScript 呼叫。
- **將視窗縮到最小**使用 `AXUIElementSetAttributeValue(kAXMinimizedAttribute)`，透過正式的輔助使用 API 操作，而非模擬按鍵。
- **全螢幕偵測**會讀取最前方 App 視窗的 `AXFullScreen` 屬性（於 1.5 重寫；舊版誤查了 Click2Minimize 自己的視窗）。

---

### `/// 特色`

| | |
|---|---|
| **沒有主視窗** | 採用 `LSUIElement` 類型的輔助 App 模式，只顯示在選單列 |
| **不收集遙測資料** | 目前的啟動流程不會發出網路請求 |
| **沒有背景常駐服務** | 只有一個程序，透過輔助使用權限註冊 `CGEvent` 事件監聽 |
| **現代 Swift 日誌** | 使用 `os.Logger`，搭配子系統識別與隱私修飾設定；Release 版本不再大量呼叫 `print()` |
| **自行選擇登入時啟動** | SwiftUI 開關透過 `SMAppService.mainApp` 註冊或取消註冊；1.5 之前為無條件啟用 |
| **Dock 掃描備援** | 若 `AXUIElement` 無法讀取 Dock 清單，會改用 AppleScript，從 `System Events` 取得 App 名稱 |
| **通用執行檔** | `build_dmg.sh` 指定建置 arm64 與 x86_64 架構，並產生以 ad-hoc 方式簽署的 DMG |
| **原始碼公開** | 採用 PolyForm Noncommercial 1.0.0 授權，可閱讀、學習與個人使用，不得用於商業產品 |

---

### `/// 2.1 — 相較於 2.0 的變更`

- **修正**：`isActiveAppFullscreen()` 原本檢查的是 Click2Minimize 自己的 `NSWindow`，因此總是回傳 false。現已改為透過輔助使用 API 讀取最前方 App 的 `AXFullScreen` 屬性。
- **修正**：Dock 項目排除清單原本使用 `"Launchpad||Trash||Downloads".contains(name)` 進行子字串比對，會誤判「TrashCan」或任何名稱包含「Trash」的 App。現已改為正確的 `Set` 成員判斷。
- **修正**：Dock 更新的防抖動機制原本在每次事件觸發時執行，再於 0.5 秒內抑制後續事件，未真正合併密集事件。現已使用 `DispatchWorkItem` 改寫為 300 毫秒的尾端防抖動。
- **改善**：所有 `print()` 呼叫已改為搭配隱私修飾設定的 `os.Logger`，Release 建置不再寫入標準輸出。
- **改善**：登入時啟動改為由使用者在設定中自行開啟。先前已自動註冊的安裝版本會保留註冊狀態，直到使用者關閉此選項。
- **改善**：重新設計設定面板，加入登入時啟動選項、調整間距，並固定註腳位置。
- **改善**：以 `openApplication(at:configuration:completionHandler:)` 取代已棄用的 `NSWorkspace.launchApplication(_:)`。
- **版本更新**：將對外顯示版本號調整為 2.1，使 App 內版本與 GitHub 發行標籤一致（先前 plist 仍為 1.4，但最新發行版本已標記為 v2.0）。

---

### `/// 安裝`

本儲存庫目前未發布自己的 Release 或可下載的 DMG。請依照[從原始碼建置](#build-from-source)的步驟在本機建置，或開啟 Xcode 專案並選擇 **Product → Build**。

建置完成後，啟動 `Click2Minimize.app`，並前往「系統設定 → 隱私權與安全性 → 輔助使用」授予**輔助使用**權限。如果你使用 Catalyst／Electron App，且希望備援機制順利運作，請在 macOS 提示時一併授予**自動化**權限。

本機建置的發行版本採用 ad-hoc 簽署，因此首次啟動時可能需要按右鍵 → **打開**，才能通過 Gatekeeper 檢查。

---

<a id="build-from-source"></a>

### `/// 從原始碼建置`

```bash
git clone https://github.com/chengen1018/Click2Minimize.git
cd Click2Minimize

# 在 Xcode 中開啟專案
open Click2Minimize.xcodeproj

# 將 Release 版本建置至 ./build
xcodebuild -project Click2Minimize.xcodeproj -scheme Click2Minimize \
  -configuration Release -derivedDataPath build

# 或在 ./dist 中產生完整的 DMG
./build_dmg.sh
```

需要 Xcode 15 以上版本，目標系統為 macOS 13.0 以上版本。

---

### `/// 授權`

本專案採用 [PolyForm Noncommercial 1.0.0](LICENSE) 授權。以下為簡要說明：

- **允許**：閱讀、學習、個人使用、興趣用途、非營利／教育／研究用途、建立分支以改進專案，以及在相同授權條款下散布你的分支版本。
- **不允許**：納入付費產品、販售相關支援服務、嵌入商業軟體，或用於任何商業用途。

在重新散布或發布修改內容前，請閱讀 [LICENSE](LICENSE) 與 [NOTICE.md](NOTICE.md)。

---
