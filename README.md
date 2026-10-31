# 1xKey

> Bộ gõ đơn giản, tối giản, thuận tiện cho người Việt chỉ muốn gõ tiếng Việt chuẩn.

Bộ gõ tiếng Việt cho macOS của **Phạm Xuân Hiếu**. Gõ thẳng không gạch chân, không mất dấu trong Chrome, Claude, Slack hay terminal, và không gửi dữ liệu nào ra khỏi máy.

Không có cửa sổ cài đặt. Mọi thứ nằm trong menu trên thanh menu: bật/tắt tiếng Việt, chọn Telex hoặc VNI, thoát. Bảng mã luôn là Unicode. Các tính năng phụ (macro, kiểm tra chính tả, gõ tắt, nhớ ngôn ngữ theo app, thanh công cụ nổi, debug, phím tắt phụ) đều tắt cứng.

Trang chủ: https://1x.xuanhieu.org/key

## Khác gì so với các bộ gõ khác

| Vấn đề thường gặp | 1xKey xử lý |
|---|---|
| Gạch chân khi đang gõ (bộ gõ có sẵn của Apple) | Mặc định gõ thẳng. Chế độ Input Method (1xKeyIM) cũng mặc định không gạch chân, bật lại được trong Thiết lập |
| Mất dấu trong Chrome, Electron, ô chat AI | Luật dựng sẵn cho ô địa chỉ, Google Docs, Word Online, Claude desktop, claude.ai, ChatGPT, Gemini, Slack, Discord, Zalo, Teams, Messenger, terminal. Tự thêm luật theo app hoặc tiêu đề cửa sổ |
| Bộ gõ gửi dữ liệu ra ngoài | Đã bỏ hẳn tính năng Dịch (Google, Tencent, Volcano) và đồng bộ iCloud. Mạng chỉ dùng khi bạn bấm "Tải từ điển" hoặc "Kiểm tra cập nhật" |
| Log debug lộ chữ đã gõ | Log chỉ ghi mã phím và độ dài, file quyền 0600, tự xóa khi tắt debug |
| Binary không rõ nguồn gốc | Tự build từ mã nguồn bằng một lệnh, ký ad-hoc trên máy bạn. Phiên bản Sparkle được ghim cố định |
| Quyền thừa | Chỉ cần Accessibility và Input Monitoring. Không iCloud, App Group, Apple Events hay quyền đọc thư mục |

Giữ lại phần lõi đã được kiểm chứng của XKey và OpenKey: engine Telex/VNI, tự khôi phục khi gõ từ tiếng Anh, luật chống mất dấu theo từng app, và tôn trọng Secure Input (ô mật khẩu).

## Build và cài đặt

Cần **Xcode** đầy đủ (App Store), macOS 12 trở lên.

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
./scripts/build-1xkey.sh
```

Kết quả ở `build/release.noindex/1xKey.app` kèm file zip và sha256. Kéo `1xKey.app` vào `/Applications`, mở lần đầu bằng chuột phải rồi chọn Open, sau đó cấp quyền **Accessibility** và **Input Monitoring** trong System Settings → Privacy & Security.

Dùng bàn phím **ABC** làm Input Source (không bật song song bộ gõ tiếng Việt của Apple). Bật/tắt tiếng Việt bằng menu hoặc ⌘⇧V.

Lưu ý với bản ký ad-hoc: mỗi lần build lại, macOS coi đó là app mới, cần xóa 1xKey khỏi Accessibility và Input Monitoring rồi thêm lại.

## Cập nhật

Tự kiểm tra cập nhật mặc định **tắt**. Để phát hành bản cập nhật qua Sparkle, chủ dự án tạo khóa bằng `generate_keys` của Sparkle, đặt khóa công khai vào `SUPublicEDKey` trong `XKey/Info.plist`, và đăng `appcast.xml` tại https://1x.xuanhieu.org/key/appcast.xml. Khi chưa có khóa, Sparkle không chạy.

## Giấy phép

GPL-3.0. Xem `LICENSE` và `NOTICE` (ghi công XKey của xmannv và OpenKey của Mai Vũ Tuyên).
