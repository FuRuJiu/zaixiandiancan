# 鸿蒙在线点餐系统 (HarmonyOS Online Ordering System)

这是一个基于鸿蒙（HarmonyOS）系统的在线点餐应用，采用ArkTS语言开发，实现了完整的点餐、下单、订单管理等功能。

## 🚀 快速开始

### 环境要求
- DevEco Studio 4.0+
- HarmonyOS SDK 4.0+
- Node.js 16+

### 证书配置
项目已配置为使用DevEco Studio自动生成的调试证书，无需手动配置。

如果遇到证书相关错误：
1. 重新启动DevEco Studio
2. 选择菜单：Build → Generate Key and CSR
3. 按照向导创建新的调试证书

## 项目概述

本项目是一个完整的鸿蒙在线点餐系统，包含以下核心功能：
- 菜品分类展示
- 购物车管理
- 地址填写与管理
- 订单确认与提交
- 本地数据持久化

## 技术架构

### 开发技术栈
- **开发语言**: ArkTS
- **UI框架**: ArkUI (声明式UI)
- **状态管理**: @State / @Link / @Observed
- **数据库**: RelationalStore (鸿蒙原生关系型数据库)
- **并发处理**: TaskPool (鸿蒙任务池)
- **本地存储**: Preferences (偏好设置)

### 项目结构
```
entry/src/main/ets/
├── models/           # 数据模型
│   ├── MenuItem.ets  # 菜品和购物车项模型
│   └── Order.ets     # 订单和地址模型
├── database/         # 数据库层
│   └── DatabaseManager.ets  # 数据库管理类
├── managers/         # 业务逻辑层
│   └── AppStateManager.ets  # 应用状态管理
└── pages/            # 页面层
    ├── Index.ets           # 主页（菜品展示）
    ├── CartPage.ets        # 购物车页面
    ├── AddressPage.ets     # 地址填写页面
    └── OrderConfirmPage.ets # 订单确认页面
```

## 数据库设计

### 菜品表 (menu)
| 字段名 | 类型 | 说明 |
|--------|------|------|
| item_id | INTEGER | 菜品ID（主键） |
| name | TEXT | 菜品名称 |
| price | REAL | 菜品价格 |
| category | TEXT | 菜品分类 |
| stock | INTEGER | 菜品库存 |

### 订单表 (orders)
| 字段名 | 类型 | 说明 |
|--------|------|------|
| order_id | TEXT | 订单号（主键） |
| items | TEXT | 订单菜品（JSON格式） |
| total | REAL | 订单总价 |
| address | TEXT | 配送地址 |
| create_time | TEXT | 下单时间 |
| status | TEXT | 订单状态 |

### 地址表 (addresses)
| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | INTEGER | 地址ID（主键，自增） |
| name | TEXT | 收货人姓名 |
| phone | TEXT | 联系电话 |
| address | TEXT | 详细地址 |
| is_default | INTEGER | 是否为默认地址 |

## 核心功能

### 1. 菜品展示 (Index.ets)
- 使用 `Tabs` + `TabContent` 组件实现分类切换
- 支持全部菜品和分分类别展示
- 实时显示购物车数量
- 菜品添加购物车功能

### 2. 购物车管理 (CartPage.ets)
- 显示购物车中所有商品
- 支持数量增减和删除操作
- 实时计算总价
- 支持清空购物车
- 购物车数据持久化存储

### 3. 地址管理 (AddressPage.ets)
- 支持选择已保存地址
- 新地址填写表单（姓名、电话、详细地址）
- 表单验证（必填项校验、手机号格式验证）
- 地址本地存储

### 4. 订单处理 (OrderConfirmPage.ets)
- 订单信息确认
- 使用 `TaskPool` 处理订单提交
- 库存扣减和订单创建原子操作
- 唯一订单号生成（时间戳+随机数）
- 订单提交结果反馈

## 技术特点

### 状态管理
- 使用 `@Observed` 装饰器实现响应式状态
- `@State` 管理组件内部状态
- 全局状态通过单例模式管理

### 并发处理
- 使用 `TaskPool` 替代传统多线程
- 异步任务处理确保UI流畅性

### 数据持久化
- 购物车数据通过 `Preferences` 存储
- 业务数据通过 `RelationalStore` 存储
- 支持应用重启后数据恢复

### UI设计
- 声明式UI开发
- 组件化设计
- 响应式布局
- 鸿蒙设计规范

## 开发环境要求

- DevEco Studio 4.0+
- HarmonyOS SDK 4.0+
- Node.js 16+

## 运行方式

1. 使用 DevEco Studio 打开项目
2. 配置开发证书（见证书配置部分）
3. 选择目标设备（真机或模拟器）
4. 点击运行按钮

## 🔧 故障排除

### 证书相关错误
- **错误**: "No signing config found" 或 "Certificate not found"
- **解决**: 重新启动DevEco Studio，选择 Build → Generate Key and CSR 生成调试证书

### API使用错误
- **错误**: "Property 'tintColor' does not exist" 或 "TabContent builder error"
- **解决**: 代码已修复，重新拉取最新代码

### 数据库错误
- **错误**: "Database initialization failed"
- **解决**: 检查设备存储权限，确保应用有读写权限

### 构建错误
- **错误**: 各种编译错误
- **解决**: 确保所有依赖正确安装，SDK版本匹配

## 功能演示

1. **启动应用**: 显示菜品分类列表
2. **添加菜品**: 点击菜品卡片的"添加"按钮
3. **查看购物车**: 点击右上角购物车图标
4. **修改数量**: 在购物车页面调整商品数量
5. **填写地址**: 点击"去结算"进入地址填写页面
6. **确认订单**: 确认订单信息后提交
7. **完成下单**: 系统生成订单号并扣减库存

## 注意事项

- 应用首次运行会自动初始化示例数据
- 订单提交时会检查库存是否充足
- 地址信息支持本地保存和快速选择
- 购物车数据在应用重启后会自动恢复

## 扩展建议

1. 添加用户登录注册功能
2. 集成支付SDK
3. 添加订单历史查询
4. 实现实时配送状态跟踪
5. 添加菜品评价系统
6. 支持多种支付方式