# 核心源代码

本次目标是原生 Web，不引入 C++/WASM 编译链。可单独运行和测试的模拟器位于 `../web/physics.js`，同时导出浏览器全局 `CutRopePhysics` 与 Node.js CommonJS 接口。

- `new World(level)`：加载原始 XML 转换的关卡。
- `world.step()`：推进一个固定的 1/60 秒。
- `world.swipe(a, b)`：切断与手势线段相交的活动绳段。
- `world.tap(point)`：触发气泡或定向气垫。
- `world.events`：包含坐标的切割、星星、气泡和胜败事件，由应用消费。
- `world.state`：`playing` → `won` / `lost`，终态不再推进。

原始 AS3 物理实现的证据副本保存在 `../analysis/original_scripts/`，现代化输入、音画、状态和存档逻辑分别位于 `../web/` 的其他模块。
