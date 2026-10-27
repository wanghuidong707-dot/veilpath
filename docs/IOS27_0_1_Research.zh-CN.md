# iOS 27.0.1：沙盒访问与 IPA 适配研究记录

更新日期：2026-10-28。目标固件：iOS 27.0.1，构建号 `24A446`。

## 当前结论

**尚无证据表明 Veilpath 的 `bad_query` 实现在 iOS 27.0.1 正式版上能获得完整 `/var` 权限。**
仓库可以被编译成 IPA ≠ 漏洞可被成功触发 ≠ 目标文件可被读取或写入。
保留 Veilpath 已有的安全备份、哈希校验及恢复措施，不以版本号或 `fileExists` 结果声称权限已获得。

## 公开项目与证据分级

| 项目 / 作者 | 27.0.1 证据 | 文件能力 | 使用条件与限制 |
|---|---|---|---|
| [0xjohnnydev/airlift](https://github.com/0xjohnnydev/airlift) | 原始 PoC 主要验证 27.0（24A435、24A437） | 在特定 `/var` 路径创建随机验证文件，回读确认 | 原 PoC 使用配对电脑；不能推断能覆盖已有受保护文件 |
| [YiHoooong/AirliftSilence](https://github.com/YiHoooong/AirliftSilence) | 作者报告 27.0.1（24A446）实机读取、替换、恢复、重启后保留 | **特定音频文件** 的读取与替换 | Windows + USB 已配对；作者报告，非本项目独立复现 |
| [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) | 作者列明 27.0–27.0.1 支持 | 访问指定资源、修改部分主题/缓存 | 手机端 LocalDevVPN + 配对记录；不代表任意 `/var` 访问 |
| [YiHoooong/AirliftSilence-iOS](https://github.com/YiHoooong/AirliftSilence-iOS) | 有公开 IPA 和手机端研究代码，列明支持 27.0.1 | 有针对性地检查并替换少数文件 | LocalDevVPN + 配对；并非通用文件管理器 |
| [forcequitOS/bad_query](https://github.com/forcequitOS/bad_query) | 上游仅列明 iOS 26.0–26.6.1、27.0 测试版至 beta 4 | 部分容器沙盒访问 | **不应将测试版兼容性套用到 27.0.1 正式版** |
| [jailbreakdotparty/Erosion](https://github.com/jailbreakdotparty/Erosion) | 上游列明 iOS 27 beta 1–4，不含正式 27.0.1 | 部分自定义及容器访问 | 不应视作 27.0.1 的有效验证 |
| [IvanIVGrozny/iOS27.0.1-SPTM-Research](https://github.com/IvanIVGrozny/iOS27.0.1-SPTM-Research) | 固件比较与 SPTM 修复分析 | **无可运行的利用链** | 不是 IPA/越狱/沙盒逃逸 PoC |
| [LinkPass888/AirBeep](https://github.com/LinkPass888/AirBeep) | 更新日志专门提到 27.0.1 的 AirTraffic 读取探针修复 | 特定系统资源的受控操作 | 需要配对、网络配置，不是通用目录浏览器 |

这些均来自项目维护者的公开说明。未在用户自己的设备上运行并复核，不标记为「我方实测成功」。

## 我们要把“读写”拆成 5 个证据层级

1. **路径可见**：`stat` 或 `fileExists` 成功；这不是目录读取。
2. **可列目录**：`contentsOfDirectory` 返回条目；仍不代表能打开子文件。
3. **真实读取**：目标文件句柄能打开，并返回预期的非空数据；不只是显示文件名。
4. **真实写入**：仅在明确获授权的测试目标上创建或修改验证数据，记录前后哈希。
5. **持久验证**：重新打开目标、重启后再次确认，且有可恢复备份。

**安全边界**：无明确许可或未验证的目标不尝试写入；试验初期只检测目标目录能否列出，唯一自动写入测试放在 App 自身沙盒 `Documents` 中。

## 第一阶段（本分支）

- 保留 `main` 的现有 Veilpath 和 `bad_query` 实现，不覆盖原工程。
- 为 IPA 增加清晰的「27.0.1 权限检查」入口。首先只进行**直接系统权限探测**（不会触发未知的漏洞利用），对目标目录逐项报告“列举成功”或具体错误；另测试自身沙盒文件能否写入、回读并清理。
- 该基线探测无法证明任何沙盒逃逸成功，只用来区分“空目录、拒绝访问、真正列举成功”。
- 基线通过后再审查公开 AirLift 的协议接口、许可证、配对条件和崩溃风险；任何跨沙盒读写扩展都须单独验证和审核。
- GitHub Actions 的构建仅能证明 IPA 打包正确；实际版本兼容性必须在**用户授权的真实 27.0.1 设备**上测试。

## 已知硬件约束

用户电脑为 Windows，手机 USB 尾插损坏。优先比较无需有线连接的 LocalDevVPN + 本机配对方法，但这只是公开项目的必要条件之一，不保证设备会提供配对入口或稳定执行。

## 待确认的验收标准

- 正常启动、不闪退、不出现误导性的「完整 `/var` 已解锁」。
- 在诊断界面能看到系统构建版本、各目录可否实际列举、错误提示。
- App 自身 `Documents` 临时文件写入—回读—删除成功。
- **正式版 27.0.1 的受保护文件读写结论必须等待真机证据**。
