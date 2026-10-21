# Cut the Rope / SWF 移植证据与实现报告

日期：2026-10-19（Asia/Shanghai）。输入仅为用户提供的 `source/cutrope/cutrope.swf`；未执行其中的 AS3、外链、广告或联网代码。

## 1. 文件身份与分析路线

| 项目 | 直接观测 |
| --- | --- |
| SHA-256 | `fc3d9d9329562765bb1db4ec25866ebd939edecdedda872e35fb26b8caa2447a` |
| 格式 | 未压缩 `FWS`，SWF v12，AVM2 / ActionScript 3 |
| 文件大小 | 4,753,024 字节，与头部声明一致 |
| 舞台 | 800 × 450；单主时间轴帧；60 FPS |
| 主类 | `Document` |
| 原始地图坐标 | 通常 320 × 480；有两关 320 × 960、一关 640 × 480 |

依照 `atb-game-porting` 优先使用 REA，调用：

```json
{"path":"/Users/brainzhang/work/aitobox/ATBPort/source/cutrope/cutrope.swf"}
```

`mcp__rea__open_binary` 返回 `target_unavailable` / `unsupported_target`，原因 `unsupported binary format`，约束 `file_format_rejected`。该调用没有生成成功的 Evidence ID，不伪造 REA 证据。Hopper 面向本机指令，不将 AVM2 当作 x86 反编译。

后续使用原始标签解析器 `extract_swf.py` 与 **JPEXS FFDec 26.3.0**。FFDec 从其[官方发布页](https://github.com/jindrapetrik/jpexs-decompiler/releases/tag/version26.3.0)获取并仅放在 `/tmp/atb-cutrope-ffdec/`，使用本机现有 Java 11。CLI 语法依据[官方文档](https://github.com/jindrapetrik/jpexs-decompiler/wiki/Commandline-arguments)。没有修改系统配置或安装 Flash runtime。

```sh
java -Djava.awt.headless=true -jar /tmp/atb-cutrope-ffdec/tool/ffdec.jar \
  -export script /tmp/atb-cutrope-decompiled source/cutrope/cutrope.swf
java -Djava.awt.headless=true -jar /tmp/atb-cutrope-ffdec/tool/ffdec.jar \
  -selectid 759,823,187,247,899 -export sprite \
  /tmp/atb-cutrope-sprites source/cutrope/cutrope.swf
```

得到 262 个 AS3 脚本、所选 Sprite 全时间轴 PNG。重要脚本的原样副本保存在 `original_scripts/`；其余第三方 Tween 等脚本不纳入产品代码。FFDec 的 `-select all:1` 在本机版本触发了内部 NullPointerException；移除帧过滤，导出完整所选时间轴成功。最终运行时不依赖 FFDec。

## 2. 资源解码

| SWF 标签 | 数量 | 处理 |
| --- | ---: | --- |
| DefineBitsJPEG2 | 7 | JPEG 解码到 PNG |
| DefineBitsJPEG3 | 287 | 合成 JPEG 与 zlib alpha |
| DefineBitsLossless2 | 108 | 解码 ARGB / 调色板两种格式，反预乘透明度 |
| DefineSprite | 77 | 保存 SymbolClass、帧数、帧率、文件偏移 |
| DefineBinaryData | 51 | 提取 XML；其中 50 个为 L1_1…L2_25，一个为默认编辑器 XML |
| DefineSound | 32 | MP3，跳过 SoundInfo 和 2 字节 SeekSamples |

原始图片导出 402 张；另生成 9 张裁去透明留白的角色/道具变体，以及 FFDec 原生合成糖果图。不能直接将带有右侧透明留白的位图压缩到可见实体宽度，否则角色会变瘦。`manifest.json` 提供符号、图像尺寸、音效名称和原始标签数据偏移，构成可定位的本地证据。

音频使用 SymbolClass 的完整 `SoundController_` 后缀命名，避免 `Star_1`、`Pump_1`、`Rope_bleak_1` 只取最后一段时互相覆盖。全部 32 个原始 MP3 已由 Chrome AudioContext 解码验证。

## 3. 关卡及玩法证据

`LevelCreater.as` 构造器根据 `Document.menuNum` / `levelNum` 实例化 `LevelClass.L1_1` 等 ByteArray 并解析 XML。`resoveObject()` 逐实体创建 `candy`、`grab`、`target`、`star`、`bubble`、`pump`、`spike1..4` 和教程。

实体总数：50 糖果、50 目标、150 星星、166 挂点、66 气泡、34 气垫、34 组尖刺。蜘蛛由挂点的 `spider="true"` 声明；`radius > 0` 表示自动挂点。本批数据的 `wheel` / `gun` / `kickable` 全为 false，没有未实现的轮盘或枪关卡。移动挂点参数均为 -1 或 0；本批地图不需要移动挂点机制。

原代码将坐标放大 1.2 倍并平移到横向舞台中间。本移植保持 XML 坐标，按 1.2 归一化物理量。

| 规则 | AS3 证据 | Web 实现 |
| --- | --- | --- |
| Verlet 运动 | `Flave/Particle.as`：当前位置减旧位置，阻尼 0.9999 | 固定 1/60 秒推进，保留旧位置 |
| 重力 | `Flave/World.as`：grav.Y = 0.18 | 每帧 0.15 XML 单位 |
| 约束 | `Constraint.as`：只在超长时收紧，4 次迭代，质量分配 | 质量加权单向绳约束、4 次迭代 |
| 绳索 | `Rope.as`：长度额外 +30，trueRope ×1.02，stiff .23；段长25 | +25 XML 单位，保留辅助约束参数 |
| 糖果 | `LXWorld.addCandy`：mass38，rad20 | mass38；各交互按原距离阈值归一化 |
| 自动捕捉 | `AutoGrab.step`：radius+18 范围，一次捕捉 | radius+15，切断后不重复捕捉 |
| 星星 | `Star.as`：距离 candy.rad+20；timeout+3 秒消失 | 距离33.3；仅 timeout>0 时计时 |
| 气泡 | `Bubble.as`：悬浮、每帧速度阻尼、向上0.25力；点击爆破 | 净力 (0.18−0.25)/1.2；0.95 阻尼；点按释放 |
| 喂食 | `Charactor.as`：目标 y+20，距离<40 | y+16.67，距离<33.3，胜败终态互斥 |
| 气垫 | `pump.as`：长300宽80的方向走廊，力3 | 长250、半宽33.4、冲量2.5 |
| 蜘蛛 | `Spider.as`：沿绳每帧0.3，切绳掉落，末端抢糖 | 沿绳每帧0.25，切断停止，抵达判负 |
| 尖刺 | `Spikes.as`：尺寸1…4，图片A…D，旋转/路径 | 85/134/182/227原像素跨度归一化，路径往返、角速度还原 |

## 4. 现代化架构和防黑屏

传统脚本加载代替 ES modules / fetch JSON，保证直接双击可玩。`assets/levels.js` 是原始 XML 的数据转换，`levels.json` 便于审计。资源链接 `web/assets -> ../assets`，图片和音频各自具备双路径回退。DOMContentLoaded 与 readyState 双入口确保初始化不丢失。

应用状态区分 ready、playing、paused、menu、won、lost；物理只有 playing、won、lost。页面失去可见性会暂停；暂停和选择关卡均冻结物理；重试建立新实例。Canvas 在开始面板后立即绘制。所有 drawImage 统一校验，绘制主循环捕获异常后继续下一帧，并显示可恢复提示。

Web Audio 在首次交互后解锁，HTTP 按需缓存解码，file 使用 HTML Audio。背景音乐独立、音效池最多六个；没有启动时创建几十个 Audio 的连接风暴。关声会阻止尚未完成解码的旧声音再次启动。

## 5. 与原版的明确差异

- 这是基于原始资产和规则的原生 Web 重构，不是 Flash runtime 或 AS3 逐指令仿真。
- 绳长和质量参数保留，但绳段均匀分配；原版最后一段使用余数长度，初始粒子铺设方式也不同，摆动时序可能略有差异。
- 气泡的合力和阻尼按同一规则归一化，更新顺序与原引擎分开的粒子/气泡 step 略有不同。
- 角色选用原始表情帧与简单补间；不逐帧重放所有 MovieClip。蜘蛛抢糖后直接结算，不播放整段搬运糖果退出动画。
- XML 中 640 宽/960 高地图由平滑镜头跟随；宽屏留白、原 Flash 显示宽度及可出界距离不逐像素相等。
- 所有关卡自由选择；无需原版解锁流程。存档是 Web 版独立的本地记录。
- 未逐关完成三星人工攻略。稳定性/渲染测试覆盖50关，真实输入三星通关验证以第1关为基准，不能据此声称50关三星操作序列均已验证。

## 6. 自查闭环与验收

`grill-with-docs` 未在可用技能或本机技能目录中找到，未冒充调用。采用独立代码审查、行为回归和浏览器验收作为替代；这是该技能依赖未满足的显式记录。

自查后已修复：

1. Lossless2 的 indexed RGBA 调色板和行填充，避免遗漏格式3图片。
2. MP3 文件名完整映射，避免 Sound ID 同名覆盖。
3. 位图 alpha 留白造成角色挤压；用原始透明包围盒裁切，糖果用 FFDec 合成帧。
4. 尖刺尺寸映射顺序不符原始 ImgSpikesA…D；新增边缘碰撞回归测试，确认修复前失败、修复后通过。
5. file 协议 Canvas 因浏览器 origin 策略不能 getImageData；以离线真实通关+截图验收，HTTP与缺图场景保留像素采样。
6. 移动端侧栏章节副标题换行；调整紧凑布局。
7. 独立审查复现关卡脚本失败后改 src 不会再次执行。新增 `data-loader.js`，每次创建新节点，通过 Promise 等待数据，延迟450ms的回退和全部路径失败均有浏览器回归测试。
8. 独立审查复现每段小于1单位的慢速划动被忽略。阈值改为浮点极小量，空 coalesced event 列表回退到事件本身；0.5单位物理测试确认修复前失败，0.25px真实触控测试覆盖浏览器输入。
9. 独立审查复现静音/暂停后残留音效及暂停时开声绕过状态。追踪并停止 Web Audio source、清理 HTML Audio 池、令待解码事件失效，并统一 paused 状态；通过真实 source ended 事件与离线 Audio 实例验证。
10. 多浏览器上下文同时载入时出现连接重置：本地 ThreadingHTTPServer 的连接等待队列从默认5调为128，并在验收中记录正常页面的请求失败。测试完成的上下文及时关闭，触控断言等待原生事件实际送达。

最终机器证据为 `browser-verification.json` 和 `screen_initial.png` / `screen_gameplay.png` / `screen_stage2.png` / `screen_win.png` / `screen_mobile.png` / `screen_file.png`。测试命令与运行方式见上级 README。浏览器验收必须退出码0，且记录控制台错误和异常均为空。
