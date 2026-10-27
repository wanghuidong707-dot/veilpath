# iOS 27.0.1 读写验证 IPA：下一步实施计划

状态：**实施计划，不是已完成的漏洞集成或成功验证**  
日期：2026-10-28（北京时间）  
现有仓库：[Veilpath](https://github.com/wanghuidong707-dot/veilpath) · [源码项目索引](ios27.0.1-source-index.md)

## 当前工程实际情况

- `Veilpath/Core/BadQueryClient.swift` 负责当前的沙盒访问路径；既有 `bad_query` 兼容性声明不能推导出 iOS 27.0.1 正式版兼容。
- `Veilpath/Diagnostics/SelfTestRunner.swift` 已有 JSON 诊断报告：`Documents/veilpath-self-test.json`。保持其结构化测试方法。
- `.github/workflows/build-ipa.yml` 存在，包含模拟器/arm64 构建、IPA 打包和上传步骤；**尚未核实最新 Actions 运行通过或产物在真机可用**。
- 用户以 Windows 为主，无 Mac，USB 不可用。优先研究**手机本机配对 + LocalDevVPN**，不把必须有初始 USB 配对的 Windows 工具当第一方案。

## 第一步：先验证现有公开实现是否能在目标手机完成配对

优先阅读和评估：
- [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS)：支持表列出 27.0.1；`rust-core/src/pairing.rs`、`grappa.rs`、`lib.rs` 与 SwiftUI 配对界面。
- [YiHoooong/AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS)：27.0.1 手机端方案、读取后哈希比对方案、IPA 发行。
- [0xjohnnydev/airlift](https://github.com/0xjohnnydev/airlift)：基础研究和媒体同步路径文件操作原语，**不是通用目录浏览器**。
- [YiHoooong/AirliftSilence](https://github.com/YiHoooong/AirliftSilence)：Windows 实机证据（27.0.1，指定文件读取/替换/还原），但要求原始可信配对，无法据此保证用户 USB 损坏设备能直接工作。

在测试设备上首先确认：
1. 设备型号、iOS **27.0.1（24A446）**、开发者模式开启、Apple Books 已安装并打开过。
2. LocalDevVPN 是否运行、应用本地网络授权是否开启。
3. 「设置 → 隐私与安全 → 开发者模式」能否显示并完成本机 App 配对，或是否存在事先生成的合法配对文件。
4. **能否完成真实 AirTraffic 服务握手**。仅界面打开/IPA 可安装不等于成功。

不建议直接以改变通信录、短信或录音通知文件作为首个测试。

## 第二步：独立开发“27.0.1 通信诊断”界面和适配层

现有 Veilpath UI/BadQuery 保留，另建 AirLift 适配模块。最初只展示：
- 设备系统版本和 Build、VPN 状态、配对状态、协议握手状态，以及真实报错；
- 明确区分「未测试 / 验证成功 / 拒绝 / 失败」；没有证据绝不显示「全盘可读写」；
- 可导出完整 JSON 诊断报告，记录测试环境而非私人文件数据。

**通过门槛：** 在真实 iOS 27.0.1 上证明本机配对与通信就绪，后续才合并写入能力。

## 第三步：安全、可清理的真实文件测试

仅在自有测试设备和明确许可测试路径上操作随机测试文件：
1. 创建临时文件；
2. 回读并对比 SHA-256；
3. 验证清理；
4. 分开记录目录枚举、读取已有文件、新建文件、覆盖原文件、重新读取、重启后持久性。

禁止在未经确认时写入重要系统设置或个人数据。任何替换操作先备份，支持回滚和错误诊断。

## 第四步：云端编译和真机验收

- 使用本仓库现有 GitHub Actions 的 macOS 环境构建 **unsigned IPA**，检查是实在的 arm64 可执行文件，而非只有 ZIP 壳；
- 用户再用自己的证书签名安装（无需本地 Mac，但并非免签名）；
- 收集真实设备上生成的 JSON 报告，以此决定是继续扩展还是放弃不兼容的版本路径。

## 源码许可与现实限制

- 先核对各依赖的 LICENSE、转授权和组件边界；源代码公开并不等于都可自由复制分发。
- AirLift 已公开的证据侧重特定文件“移动/替换”；**不能推导任意遍历或写入整个 /var**。
- 首版成功标准是：**本机配对成功 + 具体测试文件有回读验证**，不是“一键解锁 /var”。
- **截至本文件提交时**：尚未引入第三方漏洞代码、尚未生成新的 IPA、尚未进行目标设备实测。

## 监控

现有「iOS 27.0.1 源码与读写监控」每小时检查 GitHub 实质性变化；用户无需重复设置。新增真实测试证据后，更新 [研究索引](ios27.0.1-source-index.md)。
