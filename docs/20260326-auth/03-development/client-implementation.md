# 客户端实现

## 本轮目标

- 形成 login/register 页面客户端落地方案。
- 规划共享认证组件、路由流转、表单校验和第三方登录入口策略。
- 输出进入编码阶段时可直接执行的页面开发顺序。

## 页面与交互改动

| 需求编号 | 页面/组件 | 改动内容 | 数据来源（真实接口/mock/静态） | 当前状态 | 备注 |
| --- | --- | --- | --- | --- | --- |
| CR-001, CR-002, CR-003 | LoginPage / LoginFormCard | 搭建账号输入、密码输入、登录提交和去注册跳转 | mock -> /api/auth/login | 方案已定义 | account 输入框同时承接用户名/手机号 |
| CR-004, CR-005, CR-006, CR-007 | RegisterPage / RegisterFormCard | 搭建手机号、用户名、昵称、密码输入和注册提交 | mock -> /api/auth/register | 方案已定义 | 用户名可用性校验可后接接口 |
| CR-008 | ThirdPartyLoginButton | 增加微信登录入口与状态控制 | 静态 -> /api/auth/wechat | 方案已定义 | 是否显示由配置控制 |
| CRR-001 ~ CRR-005 | AuthBrandHeader / AuthInputField / PasswordField / AuthPrimaryButton / AuthSwitchFooter | 抽取共享认证组件 | 静态 + 接口 | 方案已定义 | 登录和注册共用一套基础组件 |

## 推荐页面结构

| 页面 | 子组件 | 说明 |
| --- | --- | --- |
| LoginPage | AuthBrandHeader, LoginFormCard, ThirdPartyLoginButton, AuthSwitchFooter | 登录页入口更强调回到主应用 |
| RegisterPage | AuthBrandHeader, RegisterFormCard, AgreementNotice?, AuthSwitchFooter | 注册页重点是字段完整性和校验提示 |

## 状态管理建议

| 领域 | 推荐状态 | 说明 |
| --- | --- | --- |
| 登录表单 | account, password, fieldErrors, submitting, formError | 提交中禁用按钮 |
| 注册表单 | phone, username, nickname, password, fieldErrors, submitting | 用户名和手机号可选做异步可用性检查 |
| 认证路由 | authStatus, redirectTarget | 已登录用户避免重复进入认证页 |
| 微信登录 | wechatEnabled, authorizing, authError | 通过配置和能力检测控制 |

## 测试与验证

| 类型 | 场景 | 结果 | 备注 |
| --- | --- | --- | --- |
| 手动验证 | 登录页空字段提交 | 待执行 | 对应 AC-003 |
| 手动验证 | 登录页用户名登录、手机号登录 | 待执行 | 对应 AC-001, AC-002 |
| 手动验证 | 注册页字段错误与冲突提示 | 待执行 | 对应 AC-004 ~ AC-006 |
| 手动验证 | 登录注册页互跳 | 待执行 | 对应 AC-007, AC-008 |
| 手动验证 | 微信入口开关 | 待执行 | 对应 AC-009, AC-010 |
| 组件测试 | PasswordField 显隐切换与按钮禁用态 | 待执行 | 保证基础交互稳定 |

## 未完成项与后续依赖

| 项目 | 说明 | 后续动作 |
| --- | --- | --- |
| 认证页面视觉稿 | 当前仅基于需求推导，无正式设计稿 | 编码前补设计确认或接受默认模板 |
| 协议与忘记密码入口 | 是否进入首发未定 | 先以可选占位处理 |
| 全局登录态管理 | 当前主应用尚未建立完整路由守卫 | 进入编码时先补 app shell 和 auth gate |
| 真实实现未开始 | 当前只完成开发文档 | 后续按实现计划落地 |

