---
name: agent-browser
description: |
  统一浏览器自动化入口。所有需要操控浏览器的任务都走这个 skill：打开页面、点击、填表、爬取、截图、自动化登录、渗透中的页面交互、验证码页面操作等。
  基于 Playwright，通过 agent-browser CLI 或 npx playwright 调用。
  触发关键词：浏览器自动化、打开网页、填表、爬取、截图、自动化登录、页面操作、Playwright、agent-browser、headless。
---

# 浏览器自动化 (agent-browser)

## 适用范围

当任务属于以下场景时优先使用本 skill：

- 打开网页并操作页面元素（点击、填表、提交）
- 爬取页面内容或截图
- 自动化登录流程
- 渗透测试中需要与 Web 页面交互（如提交 payload、触发 XSS）
- 验证码页面的自动化处理
- 批量表单提交
- 页面状态验证（检查某个元素是否存在、文本是否正确）
- 任何需要"像人一样操作浏览器"的场景

### 与其他工具的分工

| 场景 | 用什么 |
|------|--------|
| 打开页面、点击、填表、爬取、截图 | **本 skill (agent-browser)** |
| 抓包分析、HTTP 请求捕获、AI 辅助分析 | anything-analyzer |
| JS 断点、Hook 函数、CDP 调试、SourceMap | jshookmcp |
| 定位签名算法、补环境复现 | js-reverse |

简单判断：
- 需要"操作浏览器" → agent-browser
- 需要"分析流量" → anything-analyzer
- 需要"调试 JS 代码" → jshookmcp

## 核心工作流

```bash
# 1. 打开页面
agent-browser open <url>

# 2. 获取可交互元素（返回 @e1, @e2... 引用）
agent-browser snapshot -i

# 3. 用引用操作元素
agent-browser click @e1
agent-browser fill @e2 "text"

# 4. 完成后关闭
agent-browser close
```

## 命令参考

### 导航

```bash
agent-browser open <url>      # 打开页面
agent-browser close           # 关闭浏览器（必须执行）
```

### 页面快照

```bash
agent-browser snapshot        # 完整无障碍树
agent-browser snapshot -i     # 仅可交互元素（推荐）
```

### 交互操作（使用 snapshot 返回的 @ref）

```bash
agent-browser click @e1           # 点击
agent-browser fill @e2 "text"     # 清空并输入
agent-browser type @e2 "text"     # 追加输入（不清空）
agent-browser press Enter         # 按键
agent-browser scroll down 500     # 滚动
```

### 获取信息

```bash
agent-browser get text @e1        # 获取元素文本
agent-browser get title           # 获取页面标题
agent-browser get url             # 获取当前 URL
```

### 等待

```bash
agent-browser wait @e1                     # 等待元素出现
agent-browser wait 2000                    # 等待毫秒数
agent-browser wait --load networkidle      # 等待网络空闲
```

## 常见工作流示例

### 示例 1：表单提交

```bash
agent-browser open "https://example.com/form"
agent-browser snapshot -i
# 看到: textbox "Name" [ref=e1], textbox "Email" [ref=e2], button "Submit" [ref=e3]
agent-browser fill @e1 "张三"
agent-browser fill @e2 "test@example.com"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i   # 验证提交结果
agent-browser close
```

### 示例 2：自动化登录

```bash
agent-browser open "https://example.com/login"
agent-browser snapshot -i
agent-browser fill @e1 "username"
agent-browser fill @e2 "password"
agent-browser click @e3    # 登录按钮
agent-browser wait --load networkidle
agent-browser get url      # 确认跳转到了登录后页面
agent-browser close
```

### 示例 3：页面爬取

```bash
agent-browser open "https://example.com/products"
agent-browser snapshot      # 获取完整页面结构
agent-browser get text @e5  # 获取特定元素内容
agent-browser scroll down 1000
agent-browser snapshot      # 滚动后重新获取
agent-browser close
```

### 示例 4：渗透测试中的页面交互

```bash
agent-browser open "https://target.com/search"
agent-browser snapshot -i
agent-browser fill @e1 "<script>alert(1)</script>"   # 测试 XSS
agent-browser click @e2
agent-browser wait --load networkidle
agent-browser snapshot      # 检查是否触发
agent-browser close
```

## 注意事项

- **必须关闭浏览器**：每次操作完必须执行 `agent-browser close`，否则进程泄漏
- **操作前先 snapshot**：不要猜元素引用，每次页面变化后重新 snapshot
- **网络等待**：提交表单或导航后，用 `wait --load networkidle` 等页面稳定
- **无头模式**：默认 headless 运行，不会弹出浏览器窗口
- **敏感操作**：不要在自动化中硬编码真实密码，用环境变量或让用户手动输入

---

## 按需自举（On-Demand Bootstrap）

### 自动化能力边界

| 工具 | 可自动安装 | 安装方式 | 说明 |
|------|-----------|---------|------|
| Playwright | ✓ | npm install + npx playwright install | 自动安装库和浏览器二进制 |
| agent-browser CLI | ✓ | npm install -g agent-browser | 全局安装 CLI |
| Node.js | ✓ | winget | 前置依赖 |

### 自举触发点

当 AI 检测到需要浏览器自动化但 `agent-browser` 或 `playwright` 不可用时，自动调用：

```powershell
powershell -File "<skill-root>\browser-automation\scripts\setup.ps1"
```

### 自举失败时

如果自动安装失败，手动执行：

```powershell
# 1. 确保 Node.js 已安装
node -v

# 2. 全局安装 agent-browser
npm install -g agent-browser

# 3. 安装 Playwright 浏览器
npx playwright install chromium

# 4. 验证
agent-browser open "https://example.com"
agent-browser snapshot -i
agent-browser close
```

---

## 路由上下文

**上游入口**: `逆向skill/SKILL.md`（总控）、路由矩阵
**适用场景**: 任何需要操控浏览器的任务
**下游出口**:
- 需要分析抓到的请求 → `anything-analyzer`
- 需要 JS 调试/Hook → `jshookmcp`
- 需要还原签名算法 → `js-reverse`

**同级关联模块**: `js-reverse`（浏览器操作后可能需要进一步分析 JS）
