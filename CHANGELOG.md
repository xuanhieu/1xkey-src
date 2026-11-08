# Changelog · 1xKey

Mọi thay đổi đáng chú ý của 1xKey. Định dạng theo [Keep a Changelog 1.1.0](https://keepachangelog.com/vi/1.1.0/), số phiên bản theo [SemVer 2.0.0](https://semver.org/lang/vi/). Mỗi mục có bản tiếng Anh ngay bên dưới.

All notable changes to 1xKey, following Keep a Changelog 1.1.0 and SemVer 2.0.0. Each entry is in Vietnamese with English below it.

Trang web / Web: https://1xag.com/key/changelog · Dữ liệu máy đọc / Machine-readable: [changelog.json](changelog.json)

## [1.1.0] - 2026-11-03

### Thêm / Added

- Mục "Thông báo" đọc tin từ 1xAg (https://1xag.com/notices.json): số tin chưa đọc hiện ngay trong menu thanh trạng thái, danh sách có ngày, nội dung và nút mở liên kết. Mỗi ngày kiểm tra tối đa một lần, không gửi dữ liệu nào về bạn, mất mạng thì im lặng; tin đã đọc lưu trên máy.
  <br>EN: "Notices" reads news from 1xAg (https://1xag.com/notices.json): the unread count shows in the menu bar popover, the list has dates, text and a link button. Checked at most once a day, sends nothing about you, silent when offline; read state stays on your Mac.

### Thay đổi / Changed

- Thương hiệu 1xAg: icon riêng (ô đen, ký hiệu bàn phím bạc, chấm cobalt), trang chủ 1xag.com/key, chữ ký "/by_xuanhieu.org", màu nhấn cobalt, About có dòng tác giả 1xHieu.
  <br>EN: 1xAg brand: own icon (black tile, silver keyboard glyph, cobalt dot), homepage 1xag.com/key, "/by_xuanhieu.org" signature, cobalt accent, author line 1xHieu in About.

## [1.0.1] - 2026-11-01

### Thay đổi / Changed

- App còn 5,1 MB. Danh sách app loại trừ, icon Dock và bấm-để-bật luôn tắt.
  <br>EN: App is now 5.1 MB. Excluded apps, Dock icon and click-to-toggle are always off.

### Bỏ / Removed

- Bỏ mọi phím tắt toàn cục (kể cả ⌘⇧V). Bật/tắt tiếng Việt từ menu.
  <br>EN: All global hotkeys removed (including ⌘⇧V). Toggle Vietnamese from the menu.
- Không còn build, nhúng hay tự cài bộ gõ IMKit 1xKeyIM.
  <br>EN: The 1xKeyIM IMKit input method is no longer built, embedded or auto-installed.

## [1.0.0] - 2026-11-01

### Thêm / Added

- Bản đầu tiên: bộ gõ tiếng Việt trên menu bar, Telex hoặc VNI, bảng mã Unicode.
  <br>EN: First release: Vietnamese input on the menu bar, Telex or VNI, Unicode.

### Bỏ / Removed

- Bỏ dịch, đồng bộ iCloud, Sparkle và các tính năng phụ của XKey.
  <br>EN: Translation, iCloud sync, Sparkle and XKey side features removed.

### Sửa lỗi / Fixed

- Không hiện cảnh báo quyền khi macOS đang cập nhật quyền; cảnh báo tự đóng khi đã cấp.
  <br>EN: No permission alert while macOS settles permissions; the alert closes itself once granted.

### Bảo mật / Security

- Log gỡ lỗi không ghi ký tự, mã phím hay đoạn chữ đã gõ.
  <br>EN: Debug logs never record typed characters, key codes or quoted text.

## Lịch sử trước đó / Earlier history

1xKey là bản rút gọn của XKey (MIT). Lịch sử trước khi tách nhánh nằm trong `git log` trước commit 954fb4f.

1xKey is a trimmed fork of XKey (MIT). History before the fork lives in `git log` before commit 954fb4f.
