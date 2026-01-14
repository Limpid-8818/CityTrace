# citytrace

A Flutter app project.

## 项目结构

```
lib/
├── common/              # [公共配置]
│   ├── values/          # 常量
│   ├── routes/          # 路由定义
│   └── ...
│
├── components/          # [通用组件] (widgets)
│
├── controllers/         # [全局控制器]
│
├── core/                # [核心逻辑]
│   ├── net/             # 网络封装 (Dio Client, Interceptors)
│   └── utils/           # 工具类 (DateUtil, StorageUtil...)
│
├── models/              # [数据模型] (OpenAPI 的 schemas)
│
├── pages/               # [页面层] (按业务模块划分)
│
├── services/            # [业务服务层] (API 调用)
│
└── main.dart            # 入口

```

