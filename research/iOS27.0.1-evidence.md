# iOS 27.0.1 沙盒边界研究记录（2026-10-28）

> 状态：公开资料核对与安全诊断原型，不是 iOS 27.0.1 上任意 `/var` 读写的成功证明。已确认 GitHub 构建成功 ≠ 已确认漏洞可用。所有结论应按设备型号、系统构建号、触发条件分别记录。

## 公开证据及可复用程度

| 研究/作者 | 公开证据 | 与 iOS 27.0.1 的关系 | 限制/下一步 |
|---|---|---|---|
| 苹果安全公告 — CVE-2026-112612 | 2026-10-26 iOS 27.2 公告：具有物理访问和设备信任配对条件的攻击者，可能读写任意文件；路径处理问题已加强校验 | 证明苹果承认存在该类安全问题，不证明任意公开 IPA 都能操作任意路径 | 限定前置条件，不能忽略配对；不能以“任意文件”公告代替单路径实测 |
| [0xjohnnydev/airlift](https://github.com/0xjohnnydev/airlift) — Johnny Franks | AirTraffic/Books 同步沙盒逃逸概念验证；iOS 27.0 RC (24A435) 部分目录创建新文件，iOS 27.0 (24A437) `/var/tmp` canary 创建、AFC 回读和清理 | 研究原理直接相关，原版没有声明 27.0.1 实测 | 原 PoC 使用配对 Mac/USB；创建新文件 ≠ 替换已有文件，更不等于取得内核权限 |
| [YiHoooong/AirliftSilence](https://github.com/YiHoooong/AirliftSilence) | 作者声明 Windows + USB 环境下 iOS 27.0.1 (24A446) 成功读取、替换、恢复指定文件，重启后保留 | **版本吻合，明确报告文件修改的完整闭环** | 实测范围仅指定文件；本仓库未独立复现；需要 USB，不能直接适配损坏接口 |
| [DahanGuy/airlift-windows](https://github.com/DahanGuy/airlift-windows) | AirLift Windows 移植，原说明报告在 iOS 27.0 RC 测试 | 不可直接声称在 27.0.1 已经通过 | 使用 USB、Apple 移动设备组件；单独看作候选实现 |
| [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) | 官方 README 列明 27.0–27.0.1 可用；LocalDevVPN + pairing + AirliftFFI 用于定向资源写入；发布 IPA | **不依赖每次 USB 连接的候选手机端架构** | 功能是特定资源修改，不是任意目录文件浏览器；设备配对仍需成功 |
| [YiHoooong/AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS) | 声明 iOS 18.0–27.2 beta 2；可在手机端运行；带 SHA-256 回读验证；已发布 IPA | **可用来研究配对、隧道和回读实现** | 只处理预设文件；作者报告 ≠ 我们的真机测试 |
| [IvanIVGrozny/iOS27.0.1-SPTM-Research](https://github.com/IvanIVGrozny/iOS27.0.1-SPTM-Research) | SPTM 固件对比和静态分析，README 明确“does not present a working exploit” | 可能帮助解释补丁变化，但不是可利用漏洞代码 | 不要作为 IPA 内可运行沙盒逃逸模块 |
| [forcequitOS/bad_query](https://github.com/forcequitOS/bad_query) | 沙盒与容器研究 PoC，当前 Veilpath 基于这条路线 | Veilpath 文档没有声称 27.0.1 真机通过 | **不能**把 27 beta 3 的测试结果推广至 27.0.1；衍生代码授权需核实 |

苹果官方来源：https://support.apple.com/en-us/149230

## 诊断定义（防止假阳性）

- **目录可列举**：真实的 `contentsOfDirectory` 返回；目录为空也不代表具有文件读取权。
- **文件可读**：确实打开一个已经存在的测试文件，并读取字节；`fileExists` 或显示路径不算。
- **创建新文件**：在测试位置写入随机 canary、重新读取并逐字节比较，再删除；只代表该具体路径可创建新文件。
- **替换已有文件**：必须额外备份、替换、哈希校验与可回滚；本阶段明确不进行真实系统文件替换。
- **受保护位置**：不能从 `/var/tmp` 的新文件创建成功推断 `/var/mobile/Library` 等其他路径可写。
- **版本证据**：至少记录设备、版本与构建号、配对方式、是否用了漏洞实现、操作路径、每一步结果和重启后情况。

## 本次独立开发范围

1. 保留 Veilpath 现有功能和源码，不合并许可证不明的第三方代码。
2. 向现有真机诊断报告添加只读目录枚举探测，以及**仅对新建随机 canary** 的写入—回读—清理测试（自身 Documents 与 `/var/tmp`）。
3. 禁止诊断自动修改已有系统文件或收集/导出其他应用敏感数据。
4. 把 `denied`、`unsupported`、`passed` 区分清楚，失败应记录操作与错误，而不是显示空目录当作成功。
5. GitHub Actions 先检查模拟器编译和未签名 IPA 结构；真机效果只能由设备回传报告确认。
6. 对 AirLift 类库的进一步集成需要先确认其开源授权和真实测试前提，避免未经验证的打包“可用 IPA”承诺。

## 当前设备限制

- 用户主要使用 Windows，且曾报告 USB 接口损坏。
- 因此优先研究 **IPA + LocalDevVPN + 手机端合法信任配对** 的技术路径，而不是依赖 USB 的原版 PoC。
- 即使有 IPA，也需要用户本人完成签名、安装与手机端的授权/配对；没有配对记录就不能宣称已能写入 `/var`。

## 后续研究的两个并行方向

**路线 A：构建与验证。** 先验证这批非破坏性诊断会不会在 iOS 27.0.1 报错，并收集每条路径的明确错误代码。根据实际证据再讨论是否接入经许可的 AirLift 组件。

**路线 B：补丁与作者跟进。** 跟踪上述研究者及 Apple 27.2 公告，寻找有完整源码、实际路径回读、准确版本号和设备证据的新研究；不得把尚未开放的漏洞链写成已完成。

以上记录基于公开 README、GitHub Release 和 Apple 安全公告，尚未在用户设备上完成验证。
