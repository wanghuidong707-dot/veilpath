# Johnny CryptSn0w → iOS 26.6 可行性核查（2026-10-26）

## 目标和验收标准
- 目标设备：iPhone 16 Pro Max（A18 Pro），iOS 26.6（须以真机 `设置 > 通用 > 关于本机` 的具体 build 号为准）。
- 用户要的是 **读取、写入及实际修改有权限保护的 /var 文件**，不是仅能安装或只能修改本 App 沙盒文件的 IPA。
- 任何声称“成功修改”的结论，都必须有目标文件修改前后的独立回读、校验，并遵循只在授权测试设备及可安全恢复的测试对象上操作的原则。不得把沙盒内读写成功说成受保护目录可写。

## 核对的原始来源（2026-10-26）
1. Johnny 的历史项目 CryptSn0w：<https://github.com/0xjohnnydev/cryptsn0w>
   - 项目自述 TSS/Cryptex 漏洞已修补，原安装流程不可供新设备继续使用。
   - TSS 请求、设备个性化和关键安装细节已被作者删减。
   - 项目包含 macOS 桌面安装程序和多种 Cryptex 运行时组件；没有现成、可独立获取越狱权限的 iPhone IPA。
   - `personalize_generic_cryptex1.py` / `install_cryptex_bootstrap.py` 含主动退出和 REDACTED 占位。
2. bad_query：<https://github.com/forcequitOS/bad_query>
   - 作者标注支持 iOS 26.0–26.6.1 / 27 Beta 4 的部分沙盒逃逸与容器路径访问；不是普适内核任意读写。
3. Erosion：<https://github.com/jailbreakdotparty/Erosion>
   - 作者标注 iOS 26.0–26.6.2 部分功能可用，并明确 bad_query 不可用于写入某些受保护文件。
4. CVE-2026-64788 PoC：<https://github.com/ByteV0rtex/CVE-2026-64788>
   - 针对 iOS 26.6 的 IOGPUFamily UAF；公开 PoC 在 A14/iPhone 12 上测试。其 README 明确表示因 iOS 26 的内核隔离机制，当前路径**单独不能**提供内核任意读写；未见 iPhone 16 Pro Max 的成功验证。
5. CVE-2026-65343 PoC：<https://github.com/ByteV0rtex/CVE-2026-65343>
   - 内核地址信息泄露；作者承认真机直接调用受沙盒限制，需要其他权限入口。信息泄露 ≠ 内核写入。
6. CVE-2026-65330 PoC：<https://github.com/ByteV0rtex/CVE-2026-65330>
   - 演示入口可触达，但完成更高权限利用仍需要预先拥有内核写入原语；其 PoC 不实现真正的任意内核写入。
7. Apple 官方参考：<https://support.apple.com/en-us/148282>
   - 说明上述若干漏洞已在 iOS 26.6.1 修复；因此 iOS 26.6 可能仍在受影响区间，但**有漏洞不等于存在可复现的完整利用链**。

## 当前判断
**阻碍不是 IPA 打包，是没有公开且已验证适用于 A18 Pro / iOS 26.6 的完整权限入口**。
目前只确认了局部研究 PoC；尚不能推出 Johnny 的 Cryptex 环境、root broker 或对受保护 /var 的写入能力。

## 开发闸门：满足之前不要生成或分发“支持 /var 写入”的 IPA
- [ ] 取得来源可信、代码完整、经复核适用于 A18 Pro + iOS 26.6 实际 build 的权限入口。
- [ ] 在授权的测试设备上完成可复现、可恢复的权限验证，记录失败情况与风险。
- [ ] 明确 Johnny 哪些组件可在新的权限模型下正常运行，不能直接依赖旧 Cryptex 安装和 TSS 票据。
- [ ] 再移植真正需要的组件，云端编译测试 IPA，执行构建与安装完整性检查。
- [ ] 真机对安全测试对象执行创建、回读、修改、再次回读、删除和复核。未通过则如实标记未实现。

这份记录只保存调查和验收条件，不声称有新的越狱或已生成有效 IPA；与原 Veilpath 构建流程隔离。