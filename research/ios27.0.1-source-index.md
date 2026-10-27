# iOS 27.0.1：公开源码与沙盒访问项目追踪

> 核查日期：2026-10-28（北京时间） · 系统：iOS 27.0.1 / Build 24A446
>
> 目标：筛选能用于**受控文件访问诊断 IPA** 的开源研究与实现；区分作者声明、实机记录、原始漏洞研究和可安装应用。
> **本清单是已检索到的相关公开项目，不代表穷尽 GitHub。所有兼容性声明都应在对应设备上独立验证。**
> **本文件仅整合索引、证据和开发设计；未将第三方漏洞利用源码合并到 Veilpath，未构建新 IPA，未测试实体设备。**

## 结论与优先级

**最高优先级：** AirLift / AirTraffic 系列。有项目对 **27.0.1** 明确报告文件读取、替换、恢复与重启后持久性；手机端项目已有 IPA 和 LocalDevVPN/配对方案。它是**特定文件操作能力**，不是任意浏览/修改全部 `/var` 的已证明权限。

**Veilpath 当前限制：** 本仓库使用 `bad_query`，上游仅宣称 iOS 26.0–26.6.1 / 27.0 beta 4，而非 27.0.1 正式版。因此不能把 Veilpath 原有文件浏览界面直接标注为支持 27.0.1。若要面向 27.0.1，需独立的 AirLift 能力适配和真机核验。

## 一、与 iOS 27.0.1 最直接相关的仓库

| 优先级 | 作者 / 仓库 | 27.0.1 证据等级 | 有源码 / IPA | 对目标的实际价值和限制 |
|---|---|---|---|---|
| A | [0xjohnnydev/airlift](https://github.com/0xjohnnydev/airlift) | **基础漏洞**：原始 PoC 实测 27.0 RC、正式版 27.0；**不是** 27.0.1 直接证明 | PoC 源码；不是 iPhone IPA | AirTraffic/ATAirlock 跨媒体目录边界；证明部分路径创建随机测试文件并回读；原 PoC 无通用目录枚举和原文件任意覆盖能力。 |
| A | [YiHoooong/AirliftSilence](https://github.com/YiHoooong/AirliftSilence) | **作者明确实机验证**：27.0.1（24A446）读取、替换、恢复，重启后仍保持 | Windows 源码及 EXE | 证据最明确，但初始可信配对要求 USB；仅验证特定文件，不能推广到整个 `/var`。其功能涉及录音提醒，研究时不应复用该隐私敏感用途。 |
| B | [jiutinglifeng/ios-calltone-silence](https://github.com/jiutinglifeng/ios-calltone-silence) | **作者自述真机记录**：Mac + iOS 27.0.1（24A446）特定音频文件读取、替换、哈希回读及重启复测；[Issue #2](https://github.com/jiutinglifeng/ios-calltone-silence/issues/2) 为**第三方用户自述** Windows 11 + iPhone17,3 / 24A446 指定文件替换、SHA-256 回读一致；**均非独立核验** | Python 主机端源码，MIT；无 IPA Release | **需电脑与 USB 信任连接**；不需手机 IPA 签名或 LocalDevVPN，亦不等于无需建立设备信任。只能支持特定用户数据文件操作的结论；不是通用 `/var` 枚举、覆盖或免 USB 证据。原项目功能涉及通话录音告知音，不作为 Veilpath 的功能移植目标。 |
| A | [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) | README **明确列出支持 27.0–27.0.1** | SwiftUI、Rust `rust-core`、`AirliftFFI`、IPA Release | **最有价值的手机端架构参考**：LocalDevVPN、本机/导入配对、AirTraffic 接口；已有应用功能以指定缓存与素材为主，不能据此断言任意文件可读写。 |
| A | [YiHoooong/AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS) | README 声称支持 iOS 18.0–27.2 beta 2，覆盖 27.0.1；未在此独立实测 | SwiftUI + Rust、[IPA Release](https://github.com/YiHoooong/AirliftSilence-iOS/releases) | **手机端读写验证逻辑参考**：新增只回传文件大小和 SHA-256 的读取/回写校验；需 LocalDevVPN、配对以及 Books 初始化；用途原为录音提示音修改，不应直接照搬。 |
| B | [LinkPass888/AirBeep](https://github.com/LinkPass888/AirBeep) | 作者支持范围包括 27.0.1；[v2.3.0](https://github.com/LinkPass888/AirBeep/releases/tag/v2.3.0)调整读取探针；[v2.5.2（2026-10-19）](https://github.com/LinkPass888/AirBeep/releases/tag/v2.5.2)新增手动回读状态检查 | iOS 工程、GitHub Actions unsigned IPA | **重要反证：** 作者承认部分 iOS 27.x 上写入接口返回成功，但文件未实际变化；回读不可用时必须标记「未验证」，不能把接口成功当作真实写入。需签名、LocalDevVPN/配对；不复用其录音告知音修改功能。 |
| B | [ios-bundles/CarrierSIM](https://github.com/ios-bundles/CarrierSIM) | README 列出 iOS 27.0.1（24A446）；[Issue #44](https://github.com/ios-bundles/CarrierSIM/issues/44) 为 Mac + USB 的 24A446 实机故障记录（AirTraffic 阶段、恢复失败）；[Issue #56](https://github.com/ios-bundles/CarrierSIM/issues/56) 为 27.2 beta 3+ 失败日志和作者分析；**均非本监测独立复现** | Python 源码、Mac/Windows/Linux 主机端发布包；无手机 IPA | 特定运营商配置路径的主机端操作研究，**不是任意 `/var` 读写**。首次可信配对需 USB；后续可试 Wi-Fi 但不能代替初次信任。Issue #44 记录 iCloud 备份期间 `Books.plist` 被重写导致恢复受阻，提示存在持久状态与回滚风险；不建议将其敏感配置修改用途移植到诊断 IPA。 |
| B | [SheldonJoO/AirCard-iOS-CN](https://github.com/SheldonJoO/AirCard-iOS-CN) | 以 AirCard 派生，声称针对 iOS 27+；仍受上游补丁限制，需单独核实 | 中文界面源码、IPA/Actions | 中文界面、构建与配对交互的参考；不能把派生仓库算成新漏洞。 |
| B | [Lumid-Off/AirCard-Windows](https://github.com/Lumid-Off/AirCard-Windows) | README 声称 iOS 18.0–27.0.1；非独立普遍性证明 | Windows Rust 客户端 | USB 初次配对、随后可 Wi-Fi；**用户 USB 损坏**时不能视为现成免线方案。 |
| B | [dhava-gautama/AirCard-Windows](https://github.com/dhava-gautama/AirCard-Windows) | README 声称 27.0.1；公开实测主要在 26.6、18.7.1，27.0 有第三方报告 | Windows Rust 派生 | 参考 AirTraffic 握手、探针和错误处理；不构成 27.0.1 已实测的直接证据。 |
| C | [DahanGuy/airlift-windows](https://github.com/DahanGuy/airlift-windows) | 作者只明确测试过 iOS 27.0 RC；27.0.1 未证实 | Windows Python 脚本 | Windows 移植参考；需要电脑/可信设备连接。 |
| C | [AldazActivator/airlift-rw](https://github.com/AldazActivator/airlift-rw) | README 主要说明 27.0 RC，27.0.1 未证实 | macOS / 配对主机读写研究 | AirLift 主机端扩展读/替换原语参考；需单独审查其适用版本和读写保护。 |

**新增来源核查（2026-10-28；原始证据发表于 2026-10-19 或更早）：** `jiutinglifeng/ios-calltone-silence` 的 [README](https://github.com/jiutinglifeng/ios-calltone-silence/blob/main/README.md) 记录 Mac/USB 在 24A446 上的指定文件「读出 → 覆盖 → 回读哈希 → 重启后复测」，[Issue #2](https://github.com/jiutinglifeng/ios-calltone-silence/issues/2) 则由第三方用户报告 Windows 11、iPhone17,3 上两条指定文件的 `previousSize` 与 SHA-256 回读一致。两者均属于**作者/用户提供的可追溯测试叙述，不是本监测独立执行的设备测试**。Windows 测试未提供重启后持久性复测；没有证明列目录、任意读取或任意覆盖其他受保护文件。需要 USB，不能解决用户 USB 不可用的问题。此条仅作为来源索引，不集成代码或复用录音告知音修改用途。

**新增证据分级补充（2026-10-28 核查，证据均早于本次核查）：** [AirBeep v2.5.2](https://github.com/LinkPass888/AirBeep/releases/tag/v2.5.2) 于 10 月 19 日明确记录：部分 iOS 27.x 上写入通道成功返回，但实际文件未变化；读取通道也可能不可用。它支持将「调用成功」「实际改变」「可回读验证」分开记录，不是新突破。[CarrierSIM README](https://github.com/ios-bundles/CarrierSIM) 和 [Issue #44](https://github.com/ios-bundles/CarrierSIM/issues/44) 进一步显示 24A446 主机端 AirTraffic 操作依赖 USB/可信配对，且 Books/iCloud 备份竞态可造成回滚受阻；[Issue #56](https://github.com/ios-bundles/CarrierSIM/issues/56) 支持 27.2 beta 3 后路径搬运受阻的修补判断。上述均为作者或用户记录，不构成独立实机核验，也不证明任意受保护路径可写。

**修补状态补充（2026-10-27，作者回复）：** [AirliftSilence-iOS Issue #7](https://github.com/YiHoooong/AirliftSilence-iOS/issues/7#issuecomment-6431542894) 中，用户报告升级至 **iOS 27.2 RC** 后原有读回/替换流程失败；作者 YiHoooong 明确回复「27.2rc 已经修复了」。这是**作者确认的 RC 修补状态及单个用户故障报告**，与 README 已列的「27.2 beta 3+ 已修复」一致；不是对 iOS 27.0.1 新增任意 `/var` 读写能力的独立验证。

## 二、相关但不能直接算作 27.0.1 文件访问漏洞的项目

| 仓库 | 已知范围/定位 | 为什么暂不选作 27.0.1 IPA 的漏洞核心 |
|---|---|---|
| [forcequitOS/bad_query](https://github.com/forcequitOS/bad_query) | 官方声明 iOS 26.0–26.6.1 / iOS 27.0 beta 4 | **不包括 27.0.1 正式版**；也不是整盘 `/var` 任意读写。上游没有明确许可证，严禁擅自认定可以重新分发衍生代码。 |
| [jailbreakdotparty/Erosion](https://github.com/jailbreakdotparty/Erosion) | iOS 26.0–26.6.2、27.0 beta 1–4 | 官方兼容表**没有 27.0.1 正式版**。 |
| [0xjohnnydev/FilzaSlop](https://github.com/0xjohnnydev/FilzaSlop) | iOS 18、26 和 27 beta 1–4 | 不能将 beta 兼容性等同 27.0.1 正式版。 |
| [frs0n/GestaltEdit](https://github.com/frs0n/GestaltEdit)、[rooootdev/mond](https://github.com/rooootdev/mond) | 27.0 早期 beta 特定功能 | 并非 27.0.1 可用的沙盒读写证据。 |
| [TT0FF999/WorkSlop](https://github.com/TT0FF999/WorkSlop) | 组合 `bad_query`、AirLift 和备份还原；子功能版本范围各异 | 有 AirLift 模块可学习，但没有对整个工具在 27.0.1 任意路径读写的证明。 |
| [GoldenNugget-Team/GoldenNugget](https://github.com/GoldenNugget-Team/GoldenNugget) | 使用 AirLift 修改特定素材/系统配置 | 可作集成案例，和一套通用 `/var` 管理器不是同一件事。 |
| [IvanIVGrozny/iOS27.0.1-SPTM-Research](https://github.com/IvanIVGrozny/iOS27.0.1-SPTM-Research) | SPTM 固件差异与竞态修补研究 | README 明确声明**没有工作利用程序**；脚本是静态分析工具，不是可集成 IPA 的现成漏洞。 |
| [Xplo8E/Liter8](https://github.com/Xplo8E/Liter8) | iPhone 11 特定机型 + Mac/USB + 有线启动研究，27.0.1 实验性 | 不符合现有设备和免线 IPA 需求。 |
| [FrizzleM/SideInstaller](https://github.com/FrizzleM/SideInstaller) | iOS 侧载/配对工具 | 可以辅助安装或配对，但它本身不提供 `/var` 沙盒逃逸。 |

## 三、可以借鉴、但不能直接等同为成功漏洞利用的组件

1. **手机端通信/配对：** 优先研究 [AirCard-iOS 的 `rust-core/src/pairing.rs`](https://github.com/Mak5er/AirCard-iOS/blob/main/rust-core/src/pairing.rs)、`grappa.rs` 与现有本机配对流程，评估无需 USB 是否能够实际完成可信配对。
2. **受限文件操作抽象：** 阅读 [`rust-core/src/exploit.rs`](https://github.com/Mak5er/AirCard-iOS/blob/main/rust-core/src/exploit.rs) 与 `lib.rs` 的接口；单独记录源路径、目标路径、写入后回读、错误与回滚状态，**不把文件移动原语宣称为任意目录枚举能力**。
3. **读取验证：** [AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS) 的「大小 + SHA-256」回传方案，只能证明其所操作文件的内容一致性，不能替代任意文件直接读权限验证。
4. **打包路径：** 本仓库已有 [`build-ipa.yml`](https://github.com/wanghuidong707-dot/veilpath/blob/main/.github/workflows/build-ipa.yml)，可构建未签名 IPA。**构建成功≠实体机漏洞成功**；建议先加独立适配模块和诊断界面，再安排真机测试。
5. **参考许可证：** 分别核对各仓库 `LICENSE`，保留作者归属；`bad_query` 未声明许可证，不能仅凭代码可读就随意移植/分发。

## 四、针对 Veilpath 的下一轮决策

**拟采用的架构：** `现有 SwiftUI 浏览器/诊断 UI` + `独立 AirLift 适配层` + `本机配对/LocalDevVPN 状态` + `只读优先的安全测试报告`。

**首次验证目标（低风险且可清理）：**
- 真正连接到系统服务、完成可信配对，不把「程序启动」当作成功；
- 对明确允许、可清理的测试路径验证**新文件创建 → 再读取 → 字节/哈希一致 → 清理**；
- 单独测试「列目录」「读取已有文件」「替换已有文件」，用 **支持／拒绝／未测试** 三态显示，不能拿一种能力冒充另一种；
- 每项记录 iPhone 机型、系统 build、配对模式、目标路径、具体返回错误和哈希证据；
- 不默认触碰个人敏感资料或关键系统配置，写操作需明确确认、备份和回滚；先在自有测试机上验证。

**当前明确无法宣称的事项：** 27.0.1 上可随意修改全部 `/var`、免签名直接安装、无需配对、或已有可用的通用文件管理器 IPA。

## 五、仓库监测重点

监测 **Commit / Releases / Issues / README兼容表 / 可下载 IPA**，重点看：
- `0xjohnnydev/airlift`、`Mak5er/AirCard-iOS`、`YiHoooong/AirliftSilence-iOS`、`LinkPass888/AirBeep`、`Lumid-Off/AirCard-Windows`、`dhava-gautama/AirCard-Windows`、`DahanGuy/airlift-windows`；
- `forcequitOS/bad_query`、`jailbreakdotparty/Erosion`、`0xjohnnydev/FilzaSlop`、`IvanIVGrozny/iOS27.0.1-SPTM-Research`，及新发现的明确标注 27.0.1 正式版的仓库；
- **报告触发条件：** 有源码/IPA 上新、27.0.1 明确新增支持、可靠真实设备读写证据、版本被修复、免 USB 配对实测、许可证变化；
- 每次通知说明「作者声称／独立验证」「可见目录／可读／新建可写／覆盖可写／写后验证」「是否需要电脑/USB」「原始仓库与具体发布记录」；无实质变化不通知。

---
*维护说明：这是一份来源清单和工程可行性审查，不是自动同步的漏洞源码集合，也不是实机兼容性认证。*
