---
inclusion: auto
---

# 逆向/渗透/安全任务自动路由规则

当遇到以下任何一类任务时，必须先进入逆向技能路由包：

## 触发关键词（任意命中即触发）

- APK、Android 逆向、反编译、smali、jadx、apktool、Frida、Hook
- 二进制分析、IDA、radare2、r2、反汇编、逆向工程、RE
- 前端签名、加密参数、JS 逆向、jshookmcp、CDP、SourceMap
- 抓包、HTTP 捕获、请求重放、anything-analyzer
- CTF、Pwn、Web 渗透、漏洞利用、提权
- MCP 逆向工具、idalib-mcp
- 重打包、签名、证书校验、root 检测、反调试
- so 分析、native hook、JNI
- 渗透测试、红队、安全评估、蓝队、应急响应
- 写报告、写文档、出报告、writeup、技术文档、渗透报告、逆向报告
- 浏览器自动化、打开网页、填表、爬取、截图、自动化登录、Playwright、agent-browser、headless
- 游戏逆向、反作弊、Cheat Engine、Unity、IL2CPP、Unreal Engine、x64dbg、游戏安全、game hacking、anti-cheat、EAC、BattlEye

## 路由入口（按顺序读取）

1. `F:\Cybersecurity skills router\skills\SKILL.md`
2. `F:\Cybersecurity skills router\skills\routing.md`
3. `F:\Cybersecurity skills router\skills\tool-index.md`

## 执行原则

- 不要猜工具路径，先读 tool-index.md
- 缺少工具时先调用 `bootstrap-reverse.ps1` 自动补齐，不要直接报错
- 如果自动补齐失败，立即输出结构化引导（含手动安装步骤和验证命令），引导用户配置，不要沉默或反复重试
- 同一工具失败 2 次后，明确告知用户"自动安装无法完成"，给出完整手动步骤，不再重试
- MCP 服务端口不一致时，询问用户实际端口，帮用户更新配置
- 任务完成后必须执行"自动进化回写"流程（写入 field-journal/）
- 每次进入本包时先检查 `field-journal/_index.md` 是否有同类项目经验可复用

## 完整行为链

```
1. 识别任务属于安全/逆向类 → 触发本路由规则
2. 读取 SKILL.md → routing.md → 确定进入哪个子 skill
3. 如果路由未命中 → 提议新增 skill（按 CONTRIBUTING.md 流程）
4. 检查 field-journal/_index.md → 是否有同类经验可复用
5. 读取 tool-index.md → 确认本机工具状态
6. 如果缺工具 → 调用 bootstrap-reverse.ps1 自动补齐
7. 如果自动补齐失败 → 输出结构化引导（含手动步骤），等用户确认后继续
8. 进入对应 skill 的工作流 → 执行任务
9. 任务完成 → 调用 docs-generator skill，在用户项目目录生成技术文档/报告
10. 自动回写 field-journal/
11. 更新 _index.md → 检查是否需要更新路由/索引/manifest → 执行更新
12. 输出最终结果
```

## Bootstrap 命令

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "F:\Cybersecurity skills router\skills\scripts\bootstrap-reverse.ps1" -Capability @('工具名') -StartServices
```

## 刷新工具索引

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "F:\Cybersecurity skills router\skills\scripts\refresh-tool-index.ps1"
```


## 新增 Skill

当发现路由矩阵无法覆盖当前任务类型时，按 `CONTRIBUTING.md` 流程新增 skill：

```
F:\Cybersecurity skills router\skills\CONTRIBUTING.md
```

新增后必须同步更新：路由矩阵、bootstrap-manifest、ToolDiscovery、refresh-tool-index、本 steering 文件的关键词列表。
