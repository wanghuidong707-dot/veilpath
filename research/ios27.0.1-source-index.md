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
| B（2026-10-28 新发现） | [DYY-Studio/AirFetch](https://github.com/DYY-Studio/AirFetch) | **作者自述 iPadOS 27.0.1（24A446）真机读取**：iPad Pro 11 英寸（2022）+ macOS 15.7.5/Xcode 26.3/USB，称从 LocalSend 的 App Data Container 提取约 30.8 MiB 文件，两次独立提取 SHA-256 相同、移动后原文件放回；**未独立实测，未证明任意受保护 `/var` 文件读写** | 2026-10-28 10:29 北京时间首次提交的 Python/macOS 主机端源码，MIT；无手机 IPA | 代码实现根据 bundle ID 查容器路径、AirLift 将**已知普通文件**移至 AFC Media、下载并尝试移回；**不列任意目录、不覆盖目标内容、不创建新文件**。本地哈希不等于恢复后远端内容独立回读；无重启持久性记录。需要 Mac、USB、已建立信任配对；不需 LocalDevVPN/手机 IPA 签名，不能解决 USB 损坏场景。原文件短暂离位，断线可能导致恢复失败。 |
| B（新发现） | [bestcrwaaaa/Airlift-debug](https://github.com/bestcrwaaaa/Airlift-debug) | **代码与构建可核验，27.0.1 真机读写尚未核验**：README 宣称覆盖 iOS 18.0–27.2 beta 2（含 27.0.1 正式版），没有附该分支的独立真机回读日志 | 2026-10-28 新增源码；[Actions 成功](https://github.com/bestcrwaaaa/Airlift-debug/actions/runs/40594296113)，产出 `AirLiftDebug-unsigned-ipa` 构件 ZIP（约 3.55 MB），**未签名、非 Release** | 在上游 AirliftSilence-iOS 上新增按指定路径读取内容、写入、导入/导出和调试界面；**目录枚举仅限 AFC Media**，其他 `/var` 路径只能按已知文件名尝试。读操作会先移动原文件再写回，失败可能遗留文件；源码存在≠写入成功≠回读持久。需 LocalDevVPN、可信配对、Apple Books 初始化和 IPA 签名；本机配对属于项目声明，未独立验证免 USB。 |
| A | [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) | README **明确列出支持 27.0–27.0.1** | SwiftUI、Rust `rust-core`、`AirliftFFI`、IPA Release | **最有价值的手机端架构参考**：LocalDevVPN、本机/导入配对、AirTraffic 接口；已有应用功能以指定缓存与素材为主，不能据此断言任意文件可读写。 |
| A | [YiHoooong/AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS) | README 声称支持 iOS 18.0–27.2 beta 2，覆盖 27.0.1；未在此独立实测 | SwiftUI + Rust、[IPA Release](https://github.com/YiHoooong/AirliftSilence-iOS/releases) | **手机端读写验证逻辑参考**：新增只回传文件大小和 SHA-256 的读取/回写校验；需 LocalDevVPN、配对以及 Books 初始化；用途原为录音提示音修改，不应直接照搬。 |
| B | [LinkPass888/AirBeep](https://github.com/LinkPass888/AirBeep) | 作者支持范围包括 27.0.1；[v2.3.0](https://github.com/LinkPass888/AirBeep/releases/tag/v2.3.0)调整读取探针；[v2.5.2（2026-10-19）](https://github.com/LinkPass888/AirBeep/releases/tag/v2.5.2)新增手动回读状态检查 | iOS 工程、GitHub Actions unsigned IPA | **重要反证：** 作者承认部分 iOS 27.x 上写入接口返回成功，但文件未实际变化；回读不可用时必须标记「未验证」，不能把接口成功当作真实写入。需签名、LocalDevVPN/配对；不复用其录音告知音修改功能。 |
| B | [ios-bundles/CarrierSIM](https://github.com/ios-bundles/CarrierSIM) | README 列出 iOS 27.0.1（24A446）；[Issue #44](https://github.com/ios-bundles/CarrierSIM/issues/44) 为 Mac + USB 的 24A446 实机故障记录（AirTraffic 阶段、恢复失败）；[Issue #56](https://github.com/ios-bundles/CarrierSIM/issues/56) 为 27.2 beta 3+ 失败日志和作者分析；**均非本监测独立复现** | Python 源码、Mac/Windows/Linux 主机端发布包；无手机 IPA | 特定运营商配置路径的主机端操作研究，**不是任意 `/var` 读写**。首次可信配对需 USB；后续可试 Wi-Fi 但不能代替初次信任。Issue #44 记录 iCloud 备份期间 `Books.plist` 被重写导致恢复受阻，提示存在持久状态与回滚风险；不建议将其敏感配置修改用途移植到诊断 IPA。 |
| B | [SheldonJoO/AirCard-iOS-CN](https://github.com/SheldonJoO/AirCard-iOS-CN) | 以 AirCard 派生，声称针对 iOS 27+；仍受上游补丁限制，需单独核实 | 中文界面源码、IPA/Actions | 中文界面、构建与配对交互的参考；不能把派生仓库算成新漏洞。 |
| B | [Lumid-Off/AirCard-Windows](https://github.com/Lumid-Off/AirCard-Windows) | README 声称 iOS 18.0–27.0.1；非独立普遍性证明 | Windows Rust 客户端 | USB 初次配对、随后可 Wi-Fi；**用户 USB 损坏**时不能视为现成免线方案。 |
| B | [dhava-gautama/AirCard-Windows](https://github.com/dhava-gautama/AirCard-Windows) | README 声称 27.0.1；公开实测主要在 26.6、18.7.1，27.0 有第三方报告 | Windows Rust 派生 | 参考 AirTraffic 握手、探针和错误处理；不构成 27.0.1 已实测的直接证据。 |
| C | [DahanGuy/airlift-windows](https://github.com/DahanGuy/airlift-windows) | 作者只明确测试过 iOS 27.0 RC；27.0.1 未证实 | Windows Python 脚本 | Windows 移植参考；需要电脑/可信设备连接。 |
| C | [AldazActivator/airlift-rw](https://github.com/AldazActivator/airlift-rw) | README 主要说明 27.0 RC，27.0.1 未证实 | macOS / 配对主机读写研究 | AirLift 主机端扩展读/替换原语参考；需单独审查其适用版本和读写保护。 |

**新增 iPadOS 27.0.1 应用容器读取来源（2026-10-28）：** [DYY-Studio/AirFetch](https://github.com/DYY-Studio/AirFetch) 于北京时间 10:29 发布[初始源码](https://github.com/DYY-Studio/AirFetch/commit/8c7dea3ec13b35cb469e45810f8656abb97236a7)，10:37 添加 [MIT 许可证](https://github.com/DYY-Studio/AirFetch/commit/312290ed89b6c27be3e1d7aef68131d89b13f80f)。[README](https://github.com/DYY-Studio/AirFetch/blob/main/README.md) 声称在 iPad Pro 11 英寸 2022 / iPadOS 27.0.1（24A446）+ macOS 15.7.5 / Xcode 26.3 / USB 已配对设备上，将 LocalSend App Data Container 内的约 30.8 MiB IPA 文件经 AirLift 移至 Media、通过 AFC 下载、再移回，**两次独立提取的 SHA-256 一致**。审阅 `src/airfetch/core.py` 与 CLI 可核实存在容器查找、文件搬运、下载大小及本地 SHA-256 计算、移回逻辑；但**未在实体机独立复现**，`Restored: yes` 是工具执行移动恢复后打印，不等于远端字节级回读或重启持久性核验。它**只处理已知 App 容器内的普通文件**，不提供任意 `/var` 目录枚举、系统受保护文件覆盖写入、新建文件或手机 IPA。需要 Mac + USB 首次可信配对，无本机免 USB 配对、Windows、VPN 或签名方案；读取通过「移出—移回」完成，断线有文件暂离原路径风险。仅收录证据，**未合并源码或修改构建**。

**新增手机端源码与构建证据（北京时间 2026-10-28 06:33 前后）：** [bestcrwaaaa/Airlift-debug](https://github.com/bestcrwaaaa/Airlift-debug) 在 10 月 28 日北京时间 05:52 后创建并发布了带通用**已知文件路径**调试界面的源码（继承 [YiHoooong/AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS) 的 AirTraffic 利用原语）。[提交 ed610776](https://github.com/bestcrwaaaa/Airlift-debug/commit/ed610776ef2fe88aaeb705b5a0c7c5c49d6421b4) 后，[Actions #40594296113](https://github.com/bestcrwaaaa/Airlift-debug/actions/runs/40594296113) 于 2026-10-27 22:33 UTC 产出名为 `AirLiftDebug-unsigned-ipa` 的构件（ZIP 约 3,545,098 字节），属于**可核验的编译产物而非已签名/已安装/已运行 IPA 的证据**。`rust-core/src/exploit.rs`、`lib.rs`、`ios-app/DebugEngine.swift` 存在读取原始字节、写入字节及 AFC 目录枚举接口；[技术说明](https://github.com/bestcrwaaaa/Airlift-debug/blob/main/docs/debug-console.md) 明确 AFC 枚举只在 `/var/mobile/Media` 下，其他路径需要事先知道完整文件名。README 仅为**作者功能/兼容性宣称**，未见该分支在 24A446 上独立的「读取现有文件 → 覆盖写入 → 再读字节/哈希 → 重启复测」记录。尤其注意其读取流程会搬离原文件后再尝试写回，若回写失败会造成原位置缺失，**不建议直接对受保护/重要文件测试**。依赖 LocalDevVPN、可信配对（声称可本机配对但尚未独立验证免 USB）、Apple Books 初始化和第三方 IPA 签名；云端 macOS 编译已成功，用户无需自备 Mac，但这不等于安装后可用。该仓库 LICENSE 为 MIT，保留原作者归属；**仅索引证据，未复制或合并第三方利用代码**。

**新增来源核查（2026-10-28；原始证据发表于 2026-10-19 或更早）：** `jiutinglifeng/ios-calltone-silence` 的 [README](https://github.com/jiutinglifeng/ios-calltone-silence/blob/main/README.md) 记录 Mac/USB 在 24A446 上的指定文件「读出 → 覆盖 → 回读哈希 → 重启后复测」，[Issue #2](https://github.com/jiutinglifeng/ios-calltone-silence/issues/2) 则由第三方用户报告 Windows 11、iPhone17,3 上两条指定文件的 `previousSize` 与 SHA-256 回读一致。两者均属于**作者/用户提供的可追溯测试叙述，不是本监测独立执行的设备测试**。Windows 测试未提供重启后持久性复测；没有证明列目录、任意读取或任意覆盖其他受保护文件。需要 USB，不能解决用户 USB 不可用的问题。此条仅作为来源索引，不集成代码或复用录音告知音修改用途。

**新增证据分级补充（2026-10-28 核查，证据均早于本次核查）：** [AirBeep v2.5.2](https://github.com/LinkPass888/AirBeep/releases/tag/v2.5.2) 于 10 月 19 日明确记录：部分 iOS 27.x 上写入通道成功返回，但实际文件未变化；读取通道也可能不可用。它支持将「调用成功」「实际改变」「可回读验证」分开记录，不是新突破。[CarrierSIM README](https://github.com/ios-bundles/CarrierSIM) 和 [Issue #44](https://github.com/ios-bundles/CarrierSIM/issues/44) 进一步显示 24A446 主机端 AirTraffic 操作依赖 USB/可信配对，且 Books/iCloud 备份竞态可造成回滚受阻；[Issue #56](https://github.com/ios-bundles/CarrierSIM/issues/56) 支持 27.2 beta 3 后路径搬运受阻的修补判断。上述均为作者或用户记录，不构成独立实机核验，也不证明任意受保护路径可写。

**修补状态补充（2026-10-27，作者回复）：** [AirliftSilence-iOS Issue #7](https://github.com/YiHoooong/AirliftSilence-iOS/issues/7#issuecomment-6431542894) 中，用户报告升级至 **iOS 27.2 RC** 后原有读回/替换流程失败；作者 YiHoooong 明确回复「27.2rc 已经修复了」。这是**作者确认的 RC 修补状态及单个用户故障报告**，与 README 已列的「27.2 beta 3+ 已修复」一致；不是对 iOS 27.0.1 新增任意 `/var` 读写能力的独立验证。

### 2026-10-28 20:04（北京时间）新增：CoreMedia CVE-2026-112706 只读 PoC（非 AirLift）

- **官方漏洞证据：** [Apple iOS/iPadOS 27.2 安全公告](https://support.apple.com/en-us/149230) 的 CoreMedia / CVE-2026-112706 条目确认：普通应用可能访问敏感用户数据，修复方式为额外权限限制；[26.7.2 公告](https://support.apple.com/en-us/149227) 亦列出修复。**Apple 未公开确认下述研究者所述的具体 fd 利用机制、可读路径或设备日志。**
- **新源码（2026-10-28 12:04:34 UTC 提交）：** [MchinaMd57764/CVE-2026-112706-CoreMedia-fd-leak](https://github.com/MchinaMd57764/CVE-2026-112706-CoreMedia-fd-leak)，包含 Xcode Swift PoC、[iOS 27.0.1（24A446）作者日志](https://github.com/MchinaMd57764/CVE-2026-112706-CoreMedia-fd-leak/blob/main/evidence/wave4_ios2701_result.txt)、[受限路径测试](https://github.com/MchinaMd57764/CVE-2026-112706-CoreMedia-fd-leak/blob/main/evidence/wave5_domain_map.txt)。源码可确认通过 CoreMedia/XPC 请求并读取返回的文件描述符；**真机成功仅为仓库作者提交的日志，未独立复现**，作者自称独立向 Apple 报告并被判为重复发现，不能当作 Apple 对其个人测试的背书。
- **明确的能力边界：** 作者日志称 iOS 27.0.1 上普通应用直接 `open()` 返回 EPERM，但 CoreMedia 通道读出了 `/private/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb`（835,584 字节）和 WAL（1,862,272 字节），并列出了该 **iTunes 子目录** 13 个条目；对 DCIM、TCC、其他应用容器、整个 `/var` 等路径的访问未成功。**仅指定文件读取与指定目录枚举**；未证明通用列目录、任意文件读取、新建、覆盖或重启后持久性。作者报告写入请求返回 -12878（拒绝），**不能用来修改受保护文件**。
- **版本、安装与许可证：** 作者报告在 iOS 26.5、27.0、27.0.1 真机成功，未给出 iOS 26.6/26.6.1/26.6.2 各版本的独立日志；Apple 修补信息涵盖 iOS/iPadOS 26.7.2 与 27.2。仓库为 **Xcode 工程与 PoC 源码，未见已签名或普通用户可直接安装的 IPA**；构建/安装需 Mac、Xcode 和开发签名，首次部署通常需要 USB/设备信任（不能推断支持免 USB 首次安装）；运行时利用的是手机内 CoreMedia 服务，README 未要求 LocalDevVPN、AirLift 或主机端持续连接。仓库未见明确 LICENSE，**不得假设可以复制或合并源码**。
- **研究结论：** 这是新的 **24A446 受限只读 PoC/作者日志**，与 AirTraffic 文件搬运不同；对只读研究有价值，**不满足用户的任意 `/var` 读写或免 USB 即装即用 IPA 目标**。仅新增证据索引，未合并漏洞代码或修改构建。

### 2026-10-28 21:45（北京时间）补充：周边 PR 与失败验证（不改变 24A446 结论）

- **AirTraffic 在 iOS 27.2 的写入假阳性（第三方用户记录，尚未合并）：** [jiutinglifeng/ios-calltone-silence Issue #4](https://github.com/jiutinglifeng/ios-calltone-silence/issues/4) 于 2026-10-28 20:52 北京时间由外部用户 `pomark20` 提交，称 iPhone19,7 / iOS 27.2（24B119）+ Apple Silicon Mac / USB 环境下，`write` 返回 `ok:true`，但同一路径回读失败。其 [PR #3](https://github.com/jiutinglifeng/ios-calltone-silence/pull/3)（20:41 创建、**仍未合并**）提供 226 行评估文档与 README 修订，分析 AirTraffic 越界目标被忽略、AFC 目录边界及若干失败通道。**证据等级：第三方用户自述日志和提议文档；不是原仓库作者实机认证，更不是本监测独立复现。** 此前已有 27.2 beta 3 / RC 修补信息，因此属于新失败复现和工具返回值语义提醒，**不是修补状态新改变**。不能从 API 返回成功推断创建/覆盖成功，必须远端回读字节/哈希，必要时重启复测；也不能反推 27.0.1 的新能力。该项目仍是电脑端工具，需已建立可信配对/USB，不提供免 USB 手机 IPA。
- **Liter8 扩展到其他版本的实验性代码（不属于监测目标系统）：** [Xplo8E/Liter8 PR #30](https://github.com/Xplo8E/Liter8/pull/30) 于 2026-10-28 20:39 北京时间由贡献者 `gru2007` 提交，**仍未合并**；43 个文件约 5,290 行新增，拟支持 iPad 8 Wi-Fi（A12 / `iPad11,6`）在 iPadOS **26.7.1（23H30）/26.7.2（23H128）** 上的有线实验性启动。贡献者在 [26.7.1 测试记录](https://github.com/gru2007/Liter8-iPad8/blob/ipad8-lite/docs/runs/IPAD8_J171AAP_23H30.md) 自述恢复、SSHRD、进入 UI 与 SSH 成功；[26.7.2 记录](https://github.com/gru2007/Liter8-iPad8/blob/ipad8-lite/docs/runs/IPAD8_J171AAP_23H128.md) 自述恢复/SSHRD 成功，但正常启动仍卡 Recovery，所提 iBEC 修补**尚未真机启动验证**。这些是贡献者记录，未独立复现；PR 尚无合并或 IPA 发布。**A12 此构建使用 PPL，记录明确无 SPTM/TXM**；不能称为 27.0.1 SPTM 利用链，也不支持 iOS 26.6/26.6.1/26.6.2 或 27.0.1 的新证据。依赖 Mac/USB/有线启动，涉及抹除恢复，不适合 USB 不可用的手机，亦非普通签名 IPA。

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

### 2026-10-29 08:33：状态栏归档的 24A446 真机回读与行为纠错（特定文件，非通用 /var 读写）

- **原始新增提交：** [Prognosticate-X/ios27-carrier-lockscreen-research — 66627e94](https://github.com/Prognosticate-X/ios27-carrier-lockscreen-research/commit/66627e94be0439f49ade825a6276d4098c779433)，2026-10-29 00:33:53 UTC；08:35 左右合并 [PR #6](https://github.com/Prognosticate-X/ios27-carrier-lockscreen-research/pull/6)。包含状态栏覆写工具、逆向文档、实机对照报告及安全预检更新。
- **作者真机记录（未独立复现）：** [iPhone 14 Pro / iOS 27.0.1（24A446）验证报告](https://github.com/Prognosticate-X/ios27-carrier-lockscreen-research/blob/main/docs/EN/03_hardware_and_verification/2026-10-29_displayvalue-omission-hardware-verification.md) 称通过 **macOS + USB + 已信任配对的 AirLift 主机工具** 投递 `/var/mobile/Library/SpringBoard/StatusBarOverrides.archive`，再取回文件，961 字节逐字节一致；报告附 UI 对照截图，但设备日志与过程尚无第三方独立核验。
- **本轮新增的具体结论：** 省略 `displayValue` 时，顶部状态栏显示 **0 格灰色信号条**，不是实时基带格数；控制中心绿色蜂窝按钮仍显示实时信号。作者据此恢复工具默认 `displayValue=4`。这是**既有特定文件投递/回读路径的细化实测**，并未新增任意目录列举、任意已有文件读取、通用新建、任意文件覆盖或重启后内容持久性的独立证据。
- **适用边界与风险：** 原方案是 Mac 主机端 AirLift，不是手机端 IPA；首次 USB 可信配对仍是前提，不需要 LocalDevVPN 或手机 IPA 签名；未提供 Windows 同等流程或免 USB 首次配对证据。作者另记录 [iOS 27 最小备份系统恢复导致设备进入设置助理且目标文件未写入](https://github.com/Prognosticate-X/ios27-carrier-lockscreen-research/blob/main/docs/EN/04_research_handoffs/2026-10-28_name-only-live-override.md)，**不可在主力机复现该备份写入实验**。与 27 beta 兼容性声明无关。
- **证据等级：** 提交和文档可核验；文件投递、961 字节回读与 UI 效果为作者自述；**没有独立设备复现，不代表整个 `/var` 可写**。本索引仅引用研究成果，未合并其源码。

### 2026-10-29 17:45（北京时间）：GoldenNugget 备份缓存修复与版本号调整（非沙盒突破）

- **已核实的上游源码变化：** [GoldenNugget 提交 `5e70f09`](https://github.com/GoldenNugget-Team/GoldenNugget/commit/5e70f09f9a3220a69a65b4c1ff87a1f5a8fdc639)（2026-10-29 09:38:54 UTC）修复「启用加密备份时，增量缓存主副本的加密 `Manifest.db` 被错误当成损坏 SQLite」问题，补充 DeviceLink 无响应超时（默认 900 秒）、进度心跳及 iOS 27 文件树路径分类，并加入离线回归测试。该修复回应 [Issue #81](https://github.com/GoldenNugget-Team/GoldenNugget/issues/81)：**第三方用户**报告 iPhone 16 Pro Max、**iOS 27.0（24A437）**、Mac + USB 的 9.7.2 在「Device data 46%」卡住，产生约 25.5 万个占位文件、没有完成有效载荷写入。**Issue 为用户反馈，补丁为可核查源码，尚无修复后真机成功的独立证据。**
- **版本和构建：** [提交 `861aabe`](https://github.com/GoldenNugget-Team/GoldenNugget/commit/861aabe164e6f9ed4209b400168126562286ae73)（2026-10-29 09:45:40 UTC）仅将源码版本号从 9.7.2 调为 **9.7.3**；截至本次检查，[官方 Releases](https://github.com/GoldenNugget-Team/GoldenNugget/releases) 页面可核实的最新正式发行仍为 **9.7.2**，不能把版本号提交当成已发布可下载的 9.7.3 二进制或 IPA。
- **目标能力与设备条件：** 这是电脑端备份/恢复可靠性修复，**不是** AirTraffic 沙盒逃逸原语、受保护 `/var` 任意读写、免 USB 首次配对或手机端 IPA。相关问题环境为 Mac + USB + 设备信任；项目存在 Windows 桌面构建，但**此次补丁未有 Windows/27.0.1（24A446）真机独立复现**。无新增 LocalDevVPN 要求，亦无 IPA 签名需求（桌面应用）。目录列举、文件读取、新建、覆盖、写后回读及重启持久性均**没有新增验证**。
- **判定：** 可追踪的源代码维护进展，适合关注后续 Release/真机回归；不改变 iOS 26.6/26.6.1/26.6.2 与 iOS 27.0.1 受保护文件权限结论。

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
- 新增 `DYY-Studio/AirFetch`：关注 24A446 独立实机复现、恢复后远端哈希/重启持久性、是否新增免 USB 方案；目前只有 Mac + USB 的 App 容器已知文件读取记录；
- 新增 `bestcrwaaaa/Airlift-debug`：关注新 Releases、Actions IPA 构件、真实 24A446 设备日志、配对可用性、读写后回读与文件恢复风险；
- `0xjohnnydev/airlift`、`Mak5er/AirCard-iOS`、`YiHoooong/AirliftSilence-iOS`、`LinkPass888/AirBeep`、`Lumid-Off/AirCard-Windows`、`dhava-gautama/AirCard-Windows`、`DahanGuy/airlift-windows`；
- `forcequitOS/bad_query`、`jailbreakdotparty/Erosion`、`0xjohnnydev/FilzaSlop`、`IvanIVGrozny/iOS27.0.1-SPTM-Research`，及新发现的明确标注 27.0.1 正式版的仓库；
- **报告触发条件：** 有源码/IPA 上新、27.0.1 明确新增支持、可靠真实设备读写证据、版本被修复、免 USB 配对实测、许可证变化；
- 每次通知说明「作者声称／独立验证」「可见目录／可读／新建可写／覆盖可写／写后验证」「是否需要电脑/USB」「原始仓库与具体发布记录」；无实质变化不通知。

---
*维护说明：这是一份来源清单和工程可行性审查，不是自动同步的漏洞源码集合，也不是实机兼容性认证。*
