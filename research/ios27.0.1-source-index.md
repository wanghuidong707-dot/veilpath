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

### 2026-10-30 补充核查：Apple 官方披露可信配对条件下任意文件读写漏洞 CVE-2026-112612（公告发布于 10 月 26 日）

- **官方确认的漏洞影响与修补：** [Apple iOS/iPadOS 27.2 安全公告](https://support.apple.com/en-us/149230) 的 **Accounts / CVE-2026-112612** 条目明确写明：攻击者若能**物理接触一台已建立可信配对的设备**，可能读取和写入任意文件；苹果称已通过更严格的路径校验修复。苹果的 CVE 记录还将 **iOS/iPadOS 26.7.2 与 27.2** 列为修复版本。此公告发表于 **2026-10-26**，是本轮补充发现的**此前未收录官方证据**，不是 10 月 30 日新发布的漏洞或新 IPA。
- **证据分级：** “存在这种条件性任意文件读写风险、修补版本”属于**厂商公开确认**；但公告**没有提供 24A446 专项实机日志、PoC、源码、IPA、漏洞具体接口或每个目标文件的测试结果**。27.0.1 属于 27.2 之前的版本分支，但不能据此声称已有 27.0.1 实机独立复现。苹果列出的研究者为 **Johnny Franks（@0xjohnny）、Daniel、KennethLi 及匿名研究者**；**不能仅凭相近名称认定它就是 0xjohnnydev/airlift 的同一漏洞**，亦不能推断该 CVE 可由普通 IPA、AirTraffic 或 LocalDevVPN 直接触发。
- **权限细项不能混淆：** 官方的“arbitrary files read and write”是漏洞影响描述；未分别公布**任意目录列举、已有文件读取、新文件创建、已有文件覆盖、远端回读字节/哈希、重启持久性**的可复核真机操作记录，不能将其当成上述六项都已在 24A446 通过验证。也没有证明完整 `/var` 在所有权限上下文中可读写。
- **设备与部署前提：** 官方仅明确**物理接触 + 已可信配对**，未指明 Mac/Windows 主机要求、是否必须在当次操作连接 USB、是否使用 VPN、或是否存在可签名/可直接安装的 IPA；因此**不能作为免 USB 首次配对或纯手机端可用方案**。iOS 26.6/26.6.1/26.6.2 各 build 的实际成功情况仍需单独验证。此处只记录官方漏洞公告，**没有复制或合并利用代码**。

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

### 2026-10-30 01:48（北京时间）补充发现：GpGp700/3105 2.0.1 仅开放 24A446 版本门槛（不等于漏洞适配）

- **新收录的仓库和来源：** [GpGp700/3105](https://github.com/GpGp700/3105) 于 **2026-10-22 03:00:43 UTC** 发布 [提交 `df4b2e2`](https://github.com/GpGp700/3105/commit/df4b2e2d1553bbaf87cc9714366b155cbe9bb7a2)，README/CHANGELOG **声称已验证** iOS 27.0.1（24A446），版本标注 2.0.1。它是从 YangJiiii/3105 源码派生的独立仓库（GitHub 元数据 `fork:false` 不代表代码独立）。**尚无作者真机日志、独立实机复现或 24A446 受保护文件回读证据**。
- **源码差异核验：** 对比 [GpGp700 的 `SupportPolicy.swift`](https://github.com/GpGp700/3105/blob/main/ThreeOneOSFive/helpers/SupportPolicy.swift) 与 [YangJiiii 上游同文件](https://github.com/YangJiiii/3105/blob/main/ThreeOneOSFive/helpers/SupportPolicy.swift)，本次可核实的 27.0.1 变化是加入 `("27.0.1", "24A446")` 并放宽版本白名单；两仓库 `exploit/bad_query.c`、`helpers/SBX.swift`、`helpers/KernelExploit.swift`、`exploit/mcm_bridge.m` 的 Git blob SHA **完全相同**。**白名单通过不等于底层沙盒逃逸在 24A446 上成功**，也不代表可以读写整个 `/var`。
- **IPA 构建证据：** [Actions #39714751656](https://github.com/GpGp700/3105/actions/runs/39714751656) 于 **2026-10-22 03:03 UTC** 成功，产出 `3105-unsigned-ipa`（约 **3.86 MB** 的 Actions ZIP 构件），不是已签名 IPA 或安装/真机成功的证明；[Releases](https://github.com/GpGp700/3105/releases) 无正式发行。README 要求**企业证书签名**，称 SideStore、AltStore、3uTools、LiveContainer 不是受支持的安装途径。构建由云端 macOS 执行，**未见免 USB 首次配对、Windows 本地部署、LocalDevVPN 或可回读写入的新增证明**。
- **权限与许可结论：** 没有新增独立证据支持任意列目录、读取已有受保护文件、新建、覆盖、回读哈希或重启持久性。仓库标注 GPL-3.0，但包含第三方来源，不能推断每个利用模块均可自由重分发。**仅加入证据索引，未复制、合并或编译第三方利用代码**。此项属于“新发现的 24A446 支持宣称与可核实构建”，**不是新的漏洞或真机能力突破**。

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

**2026-10-29 18:08（北京时间）后续 CI 构建核查：** [GoldenNugget Actions #40853678061](https://github.com/GoldenNugget-Team/GoldenNugget/actions/runs/40853678061) 于 17:57（北京时间）因提交 [`977f886`](https://github.com/GoldenNugget-Team/GoldenNugget/commit/977f886113d330d51b0bab4872436a4a267b3f57) 触发，运行结果为 **success**；Actions 可核查到 `GoldenNugget_Windows`（约 204 MB）、`GoldenNugget_macOS_Universal2`（约 480 MB）、Linux 两种架构的桌面构件，最新 macOS 构件于 18:08 创建。该提交主要统一 PyInstaller 输出名称及 Actions 构件名称，不增加 iOS 文件权限。**这是包含此前 9.7.3 源码修复的桌面 CI 构建成功证据，不是 GitHub Release 9.7.3，也不是 IPA 发布或 27.0.1 实机成功证明。** [官方 Releases](https://github.com/GoldenNugget-Team/GoldenNugget/releases) 仍以 9.7.2 为最新正式发行。Windows 构件不证明免 USB 首次配对；没有新增 VPN、IPA 签名、任意 `/var` 列目录/读取/新建/覆盖/回读/重启持久性能力。此项仅记录构建元数据，不合并第三方代码。

**2026-10-30 15:35（北京时间）后续上游合并与 CI 核验（非权限突破）：** [GoldenNugget PR #82](https://github.com/GoldenNugget-Team/GoldenNugget/pull/82) 于北京时间 **15:21** 合并（[合并提交 `7e08606`](https://github.com/GoldenNugget-Team/GoldenNugget/commit/7e08606944b33c0541ab5e26c7676b5758078c7d)）。核对差异涉及四个 Python 文件：移除已停用的 FeatureFlag / UIKit 偏好写入器，加载旧预设时跳过这些项，并在 AutoSave 中禁用旧选择；PR 作者注明仅通过 Python 语法和差异检查，**未进行设备操作**。[Actions #41019586834](https://github.com/GoldenNugget-Team/GoldenNugget/actions/runs/41019586834) 显示该合并提交的桌面构建成功，产生 Windows（204,505,452 字节）、macOS Universal2（480,082,986 字节）、Linux x64/aarch64 构件；**这些是桌面 CI 产物，不是 IPA 或实体机验证**。截至核查，[正式 Releases](https://github.com/GoldenNugget-Team/GoldenNugget/releases) 仍为 **9.7.2**；没有新 27.0.1（24A446）真机证据、AirTraffic 利用原语、受保护 `/var` 目录枚举/读取/新建/覆盖/回读/重启持久性验证，也没有免 USB 首次配对改进。桌面版支持 Windows/macOS，但目标机仍需设备连接及可信配对；本次变更不涉及 VPN 或手机 IPA 签名。仅补充可复核元数据，**未合并任何第三方利用源码**。

### 2026-10-30 15:40（北京时间）新增 AirTraffic 手机端源码/构建候选：CocoWall（**尚未验证 27.0.1**）

- **源码和构建已核实：** [zhy976073500-cyber/CocoWall](https://github.com/zhy976073500-cyber/CocoWall) 是 2026-10-27 建立的 SwiftUI + Rust idevice + 内置 PacketTunnel 壁纸工具；代码中有 [ATC 同步](https://github.com/zhy976073500-cyber/CocoWall/blob/main/rust-core/src/atc.rs)、[AFC/StreamingZip 暂存](https://github.com/zhy976073500-cyber/CocoWall/blob/main/rust-core/src/stage.rs)、[Grappa](https://github.com/zhy976073500-cyber/CocoWall/blob/main/rust-core/src/grappa.rs)、配对与壁纸写入调用路径。[Actions #41020338668](https://github.com/zhy976073500-cyber/CocoWall/actions/runs/41020338668) 于北京时间 15:28 开始、构建成功，15:32 产生 CocoWall-iOS-IPA 构件（ZIP 4,753,758 字节，内含未签名 CocoWall-unsigned.ipa）；这是**真实源码和 CI 打包证据，不是已签名可安装或实机写入成功证明**。目前无正式 Release。
- **版本与权限边界：** [README](https://github.com/zhy976073500-cyber/CocoWall/blob/main/README.md) 声称 iOS 17+、仅 iPhone，目标为导入 .tendies 壁纸到特定 PosterBoard 目录。[规格](https://github.com/zhy976073500-cyber/CocoWall/blob/main/SPEC.md) 将 27.0.1 正式版列为**未验证**，仅描述其他项目的 iOS 27 Beta/26.x 直写适配；**不能推断 24A446 支持**。代码包含特定文件/目录同步实现，但没有独立 24A446 实机证据证明任意受保护 /var 列目录、读取、新建、覆盖、远端回读或重启持久性。项目中提及部分真机故障日志，不等于成功操作记录。
- **部署与许可证：** GitHub Actions 使用 macOS runner + Xcode 构建，非 Windows 原生编译；iPhone 端方案内置 PacketTunnel（需系统 VPN 授权），并宣称 iOS 27 可机内 PIN 配对或导入配对文件，但**未独立验证 27.0.1 无 USB 首次可信配对**。IPA 未签名，安装前仍需有效签名；不需要把“内置隧道”误记为外部 LocalDevVPN 的必需依赖。仓库目前**未找到 LICENSE**，不能据公开源码直接认定允许第三方复制、修改或再分发；只记录来源，**不合并代码**。

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


### 2026-10-30 18:49（北京时间）新增：CVE-2026-112705（AVEVideoEncoder）崩溃 PoC 与 24A446 作者日志（**不是文件读写**）

- **Apple 官方已确认的漏洞（2026-10-26 公告）：** [iOS/iPadOS 27.2 安全公告](https://support.apple.com/en-us/149230) 的 AVEVideoEncoder / CVE-2026-112705 条目将其描述为越界写入，影响为「应用可能导致系统意外终止」，已通过边界检查修复；原始报告人是 Marco Schmitt、Andrey Chernykh、Josh Maine（Calif.io）。**苹果未宣布任意内核读写、沙盒逃逸、/var 文件读写或越狱能力**；不能把这条 CVE 等同于 Calif 完整越狱利用链。
- **新公开的 PoC（代码存在已核验）：** [Lak453/CVE-2026-112705-poc](https://github.com/Lak453/CVE-2026-112705-poc) 于 2026-10-30 08:02 UTC 发布 Swift/VideoToolbox 的一次性崩溃复现源码；其 README 自述 iOS **26.0（23A330）** 设备 2/2 触发重启，**没有** 24A446 真机日志。仅为崩溃验证，非任意读写或越狱。
- **明确针对 iOS 27.0.1（24A446）的新源码与作者证据：** [MchinaMd57764/AVETemporalPoC-CVE-2026-112705](https://github.com/MchinaMd57764/AVETemporalPoC-CVE-2026-112705) 于 2026-10-30 09:29 UTC 创建，源码初始提交日期为 09:26 UTC，10:06 UTC 更新说明。项目提供 Swift/Xcode 工程、VideoToolbox 测试代码，以及 [panic-evidence 目录](https://github.com/MchinaMd57764/AVETemporalPoC-CVE-2026-112705/tree/main/panic-evidence) 中约 1.69 MB 的 `.ips` 日志文件；README **作者自述** iPhone 17 Pro / iOS 27.0.1（24A446）触发 AppleAVE2 kernel panic，iOS 27.2 同参数被拒绝。**仓库源码、日志文件的存在和 SHA 可核验，但设备来源、日志真实性、崩溃可重复性及修补差异未由本监测独立实机验证。** [evan5208 同名仓库](https://github.com/evan5208/AVETemporalPoC-CVE-2026-112705) 为其 GitHub fork，提交 SHA 相同，**不是第二份独立实机证据**。
- **能力分级：** 这两份公开研究仅涉及视频编码驱动的**崩溃/拒绝服务复现**；没有证明列举受保护目录、读取文件、新建文件、覆盖已有文件、远端回读哈希、重启后文件持久性、任意内核读写或完整沙盒逃逸。27.0.1 证据为作者日志，不能当成独立核验。也不能从 27.0.1 推断 iOS 26.6/26.6.1/26.6.2 已成功复现。
- **部署与风险：** 仅提供 Xcode 源码，未发现签名 IPA、Actions IPA 构件或 Release；需 **macOS + Xcode + 开发签名**部署到真机，首次设备部署/信任通常涉及 USB（仓库未证明免 USB），未要求 LocalDevVPN、AirTraffic 或已配对主机作为触发条件。该 PoC 可能导致设备内核崩溃和重启，**不建议在主力机运行**。未发现明确的 LICENSE，不能推断允许复制或合并代码。本次**仅更新证据索引，未合并利用源码、未构建或执行 PoC**。


### 2026-10-30 19:23（北京时间）后续发现：CocoWall Grappa 候选回退与 Cinder27 研究工具

- **CocoWall 新的 AirTraffic/Grappa 源码改动（19:13 北京时间）：** [提交 `1e78878`](https://github.com/zhy976073500-cyber/CocoWall/commit/1e78878b8dfbb47838d471fe46d074a4205db20b) 于 2026-10-30 11:13:46 UTC 更新 `GrappaHelper.m/.h`、`project.yml` 并新增 `Sources/App/grappa-tokens.txt.b64` 与 `NOTICE`。当本机动态 Grappa 生成及 CI macOS 生成都失败时，构建脚本改为嵌入来自 [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) 的候选 token 表；运行时逐项执行设备会话 self-check，取第一个通过的候选；**若全部失败，源码仍回退采用第一个候选，因此采用候选不等于配对成功**。这是可核验的 **AirTraffic 会话初始化/兼容性源码改动**，不是已证明在 24A446 上首次免 USB 配对成功、文件写入成功或沙盒权限提升。此提交尚未独立核实新的成功 IPA 构建/Release/实机日志；此前成功的 unsigned IPA 构建不能自动证明本次新提交可用。新增 NOTICE 仅注明候选数据来自上游 MIT 代码，**不等于 CocoWall 整仓已有 LICENSE 或允许任意重新分发**。内置 PacketTunnel/VPN、配对与有效 IPA 签名仍是手机端部署前提；macOS CI 编译不等于需要用户自备 Mac，Windows 原生构建仍未证明。
- **新发现的 24A446 多模块验证源码（不是越狱）：** [jixui666/testasdsf（Cinder27）](https://github.com/jixui666/testasdsf) 在 2026-10-28 起有公开提交，2026-10-30 02:46 UTC 的 [提交 `de277ec`](https://github.com/jixui666/testasdsf/commit/de277ec1) 补充 LinkPresentation 触发记录；仓库 README 列出 52 个验证/工具模块，宣称 2026-10-29 在 iPhone 15 Pro（`iPhone16,1`）/ iOS 27.0.1（24A446）取得部分崩溃日志及 CoreMedia `cm.fdleak` 读取 iTunes 媒体库 7 个文件、合计 5,015,357 字节的结果。**代码、提交与 README 文字可核验，真机来源、日志和结果均为作者记录，未独立实机复现**。README 的 `sbx.toctou` 实验明确是 **`bypassed=0`**，不能把项目模块数量或崩溃 PoC 视为沙盒逃逸。特定 iTunes 目录读取不等于任意 `/var` 列目录/读取；没有已核验的新建、覆盖、写后远端回读或重启持久性。
- **Cinder27 安装/构建边界：** [CI 源码](https://github.com/jixui666/testasdsf/blob/main/.github/workflows/build-ipa.yml) 确实配置 macOS runner + Xcode 生成 `Cinder27-unsigned.ipa` 并发布滚动构件；**本次未能独立确认该工作流的最新成功状态或 Release 文件真实可下载**，更不能据此证明已签名/已在 24A446 安装运行。需要有效 IPA 签名与设备安装授权；项目未提供免 USB 首次配对的独立验证，且其漏洞验证不依赖 AirLift/LocalDevVPN。未找到根目录 LICENSE，不复制或合并其源码。部分 PoC 可导致应用或系统崩溃，不建议在主力机测试。
- **本轮其他范围：** 指定 17 个重点仓库最新源码提交没有比此前记录更新的相关权限突破（GoldenNugget 最近为 10 月 30 日旧功能清理）；新检索到的 AirLift/SPTM/CoreMedia 同名仓库多为复制/派生，不能计为独立实机证据。iOS 26.6、26.6.1、26.6.2、Calif 完整越狱及 SPTM 均未发现新的可核验任意 `/var` 读写链。继续严格区分目录枚举、文件读取、新建、覆盖、写后远端回读及重启持久性；iOS 27 beta 支持不作为 24A446 正式版证据。本次**只更新研究索引，不合并第三方利用代码**。


### 2026-10-30 20:44（北京时间）增量复核：GoldenNugget 偏好文件基线修复与 CocoWall 交付判定

- **GoldenNugget 新源码（20:01 北京时间）：** [提交 `ea90f278`](https://github.com/GoldenNugget-Team/GoldenNugget/commit/ea90f278bb7370530fce5c282d10f55020ec0301) 修改 `src/restore/inject.py`、设备管理器及测试：对**备份 Manifest.db 中没有基线记录**的目标偏好 plist，不再一律中止应用，而将所选 tweak 键值作为**新偏好文件**准备交付，并在报告中列入 `preference_baseline_creates`；针对缺失文件的重置请求会跳过，特定 FeatureFlags 重置仍报错。新增 `tools/test_missing_preference_baseline.py` 是**离线回归测试**，不等于 iOS 27.0.1（24A446）真机已成功新建并回读文件。此路径是电脑端备份恢复机制中的**受支持域/指定偏好文件**，不等于普通 IPA 可以列举或任意写入整个 `/var`。同日 20:20 的 [提交 `7aec1f10`](https://github.com/GoldenNugget-Team/GoldenNugget/commit/7aec1f10f2c4e7a234d64de1db75192020ac2ef0) 仅修复界面动画定时器，不属于权限进展。桌面程序涉及 Windows/macOS、设备信任/配对及备份恢复流程；**不是手机 IPA，不需 IPA 签名或 LocalDevVPN；不能据此证明免 USB 首次信任配对**。本轮未独立核实新提交的 CI 成功或新 Release。
- **CocoWall 新源码（19:33、19:41、20:03 北京时间）：** [`1bc9792`](https://github.com/zhy976073500-cyber/CocoWall/commit/1bc9792a1e84edfc3bd5058dc24a48f1bda9abd0) 将 `FileComplete` 已发送与目标目录计数已**实际回读确认**拆成两种状态；作者在代码注释中记录经 AFC symlink 读取目标时出现 `PermDenied`，因此可能显示“已交付但未确认”。[`79dc3be`](https://github.com/zhy976073500-cyber/CocoWall/commit/79dc3be0baa08b117989bcf83b9d6c74fe1c8574) 改为把迟到的 `SyncFailed` 只记日志、不撤销交付状态；[`4ca418c`](https://github.com/zhy976073500-cyber/CocoWall/commit/4ca418c37e473973a8a36d88c8b0ce3fb8070102) 新增 InstalledAssets、路径、资产标识和双路径交付诊断，**提交信息明确没有改变注入行为**。这些是可核验的源码变更，**不是** 24A446 真机目标文件实际写入、覆盖、远端哈希回读或重启持久性的证据；尤其不能把“FileComplete 已发送”写成“文件已落盘”。现有手机端设计仍涉及 LocalDevVPN/PacketTunnel、配对文件/本机配对、有效 IPA 签名；未证明首次免 USB 配对、Windows 原生构建或本轮新 IPA 构建成功。
- **其余范围：** 17 个指定重点仓库中，本轮未见与 27.0.1 任意受保护 `/var` 读写直接相关的新实机证据；Calif 完整越狱利用链、SPTM、26.6/26.6.1/26.6.2 无新增独立验证。仍严格区分列目录、读取、创建、覆盖、远端回读和重启持久性。以上仅补充研究索引，**未合并第三方利用代码或执行设备测试**。
