# GDFrame Ext

**GDFrame 的可选能力扩展**——环境音、语音、批量预加载、手柄震动与输入改键等模块，按需安装到 **`res://gdframe/ext/<id>/`**。

仓库：[GitHub](https://github.com/ftyu3d/gdframe-ext) 或 [Gitee](https://gitee.com/ftyu3d/gdframe-ext)。须先启用 **GDFrame** 插件（[GitHub](https://github.com/ftyu3d/gdframe) 或 [Gitee](https://gitee.com/ftyu3d/gdframe)）。

## 扩展

| 扩展 | 说明 | 文档 |
|------|------|------|
| **bgs** | 循环环境音（`BGS` 总线） | [bgs/editor/README.md](bgs/editor/README.md) |
| **voice** | 单轨角色语音（`Voice` 总线） | [voice/editor/README.md](voice/editor/README.md) |
| **load** | UI / FSM / 自定义步骤批量预加载与进度 | [load/editor/README.md](load/editor/README.md) |
| **rumble** | 手柄震动开关与振动 | [rumble/editor/README.md](rumble/editor/README.md) |
| **input_remap** | 玩法 action 改键（`GDFrameInputRemap`） | [input_remap/editor/README.md](input_remap/editor/README.md) |

各扩展 README 结构：**API → 行为说明**（及 Profile / 信号 / 示例，视模块而定）。

## 安装

1. 在 Godot 项目中启用 **GDFrame** 插件。
2. 打开编辑器 Dock → **扩展管理**，安装所需扩展。
3. 点击 **生成扩展 API**，使 facade / profile / 信号与工程同步。

也可从 [GitHub Releases](https://github.com/ftyu3d/gdframe-ext/releases) 或 [Gitee Releases](https://gitee.com/ftyu3d/gdframe-ext/releases) 下载各扩展 ZIP；或将本仓库中对应扩展目录（如 `bgs/`）复制到 `res://gdframe/ext/`。

## 许可证

[MIT](LICENSE) © Feng Yang
