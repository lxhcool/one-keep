# 开发实施计划

## 目标

- 优先落地账号密码认证主链路。
- 在不阻塞首发的前提下，为微信登录保留扩展位。

## 阶段拆分

| 阶段 | 目标 | 主要产出 |
| --- | --- | --- |
| P1 | 冻结字段规则和错误码 | 注册/登录字段规范与错误映射 |
| P2 | 服务端 register/login 可用 | /api/auth/register, /api/auth/login |
| P3 | 客户端 login/register 可用 | LoginPage, RegisterPage, 共享认证组件 |
| P4 | 路由与登录态闭环 | 已登录重定向、成功后跳转 |
| P5 | 可选微信登录 | /api/auth/wechat 与入口开关 |

## 需求映射

| 需求 | 服务端动作 | 客户端动作 |
| --- | --- | --- |
| FR-001 / CR-002 | 实现登录接口 | 登录提交与错误展示 |
| FR-003 / CR-005 | 实现注册接口 | 注册提交与字段校验 |
| FR-004 / CR-007 | 实现唯一性检查 | 展示冲突错误 |
| FR-007 / CR-008 | 预留微信授权接口 | 接入可配置微信入口 |

## 交付顺序建议

1. register
2. login
3. auth route guard
4. wechat login optional