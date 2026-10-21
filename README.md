# Cut the Rope · 割绳子 HTML5

🎮 **Live Demo / 在线游玩**: [https://atbfun.github.io/cutrope/](https://atbfun.github.io/cutrope/)

将 `source/cutrope/cutrope.swf` 的 50 个原始关卡、角色、场景及音效迁移为无运行时第三方依赖的 HTML5 Canvas 游戏。支持鼠标、触屏、桌面和手机；无需 Flash，无需构建。

## 运行

### 在线体验
访问 GitHub Pages 在线游玩：**[https://atbfun.github.io/cutrope/](https://atbfun.github.io/cutrope/)**

### 本地运行
直接用浏览器打开 `cutrope/web/index.html`，或在仓库根目录运行：

```sh
python3 cutrope/analysis/serve.py
```

访问 **http://127.0.0.1:8765**。服务器仅绑定本机，使用多线程静态 HTTP。

保留完整的 `cutrope` 文件夹，包括 `assets/`。`web/assets` 与 `assets/` 保持同步。在 GitHub Actions 自动化构建中，工作流会自动将 web 核心与完整 assets 打包到发布目录。

## GitHub Pages 部署

本项目已配置自动化 GitHub Actions 部署工作流（`.github/workflows/deploy-pages.yml`），推送到 `main` 分支即可自动打包并发布至 GitHub Pages。

**首次启用步骤：**
1. 进入 GitHub 仓库设置：**Settings** -> **Pages**
2. 在 **Build and deployment** 的 **Source** 下拉菜单选择 **GitHub Actions**
3. 待工作流执行完毕后，即可通过 [https://atbfun.github.io/cutrope/](https://atbfun.github.io/cutrope/) 在线游玩


## 玩法

- 按住并划过绳索，带糖果收集三颗星，最后送进 Om Nom 的嘴里。
- 气泡带糖果上升；点气泡可戳破。蓝色气垫会朝喷嘴方向吹动糖果。
- 虚线圆圈中的自动挂点会捕捉糖果一次。避开尖刺，及时切断蜘蛛所在的绳索。
- **R** 重玩；**空格 / Esc** 暂停或继续；数字 **1–9** 切断对应绳索。按钮可用 Tab 和 Enter 操作。
- 右侧还提供切绳、气泡和气垫按钮，可替代拖划操作。
- 两章各 25 关均可自由选择；最佳星数与上次关卡保存在浏览器本地。
- 第一次点击开始后解锁音乐与音效。右上角可关闭声音。

## 实现

| 文件 | 职责 |
| --- | --- |
| `web/physics.js` | 固定 60 Hz Verlet 模拟、绳约束、碰撞、关卡实体和胜败 |
| `web/renderer.js` | 原版素材、几何兜底、镜头、粒子及划动轨迹 |
| `web/media.js` | 图片校验/路径回退、按需加载的 Web Audio / HTML Audio |
| `web/app.js` | 输入、暂停、关卡、结算、存档、可访问按钮 |
| `assets/levels.js` / `levels.json` | 从原始 XML 自动转换的 50 个关卡 |
| `assets/manifest.json` | 图像、音频、时间轴、符号与原文件偏移 |
| `analysis/original_scripts/` | 关键原始 AS3 的反编译证据 |

每帧立即绘制场景；图片全部经过 `complete && naturalWidth > 0` 校验。缺失背景、角色、糖果、星星或障碍时均有 Canvas 几何回退。脚本采用传统 script 标签，兼容直接打开文件。音频仅在用户手势后按需加载；HTTP 使用 Web Audio，file 协议使用 HTML Audio。

## 验证

```sh
node --test cutrope/tests/physics.test.cjs
# 浏览器测试需要开发环境安装 Playwright 与 Chrome，不是游戏依赖：
NODE_PATH=/path/to/node_modules node cutrope/tests/browser.cjs
```

`CHROME_PATH` 可指定其他 Chrome/Chromium；不指定时先尝试 macOS Chrome，再尝试 Playwright 自带 Chromium。报告和截图保存在 `analysis/`。

已验证真实鼠标三星通关、下一关、暂停、重玩、关卡选择、390px 触控、存档恢复、32 个 MP3 解码、所有关卡加载/渲染、资源缺失时继续游玩，以及 HTTP/file 协议通关。Canvas 在 HTTP 首屏、第二关、手机及缺图场景的有色像素比例均超过 99%。

**验收范围：**所有 50 关均进行了模拟稳定性和浏览器渲染检查；完整通关操作验证以第一关为基准，没有逐关完成人工三星攻略。原版 Flash 时间轴和 Flave 引擎并非逐指令仿真：绳段分配、气泡动力、蜘蛛结束动画和宽/长地图镜头有实现差异，详见逆向报告。

## 重新提取

需要 Python 与 Pillow。项目 conda 环境 `ATBPort` 已存在，但本次检查发现未安装 Pillow；本次资产提取使用已有的 `/opt/homebrew/anaconda3/bin/python`。

```sh
python cutrope/analysis/extract_swf.py
# 另用 FFDec 26.3.0 导出合成糖果：
java -Djava.awt.headless=true -jar /path/to/ffdec.jar -selectid 823 \
  -export sprite /tmp/cutrope-sprites source/cutrope/cutrope.swf
python cutrope/analysis/import_candy_sprite.py /tmp/cutrope-sprites
```

反编译命令与原始文件 SHA-256 见 `analysis/reverse_engineering_report.md`。原文件未修改，游戏资产与原作归其原权利人所有。
