# 组件清单

| 组件 | 项目内是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 覆盖页面 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AuthBrandHeader | 否 | 无 | 需开发 | 新开发 | 当前仓库无认证头部品牌组件 | login, register | 标题、副标题、Logo 可配置 |
| AuthInputField | 否 | 无 | 需开发 | 新开发 | 当前仓库无统一输入组件 | login, register | 需支持手机号、用户名、昵称、错误态 |
| PasswordField | 否 | 无 | 需开发 | 新开发 | 无密码显隐交互封装 | login, register | 可继承自 AuthInputField |
| AuthPrimaryButton | 否 | 无 | 需开发 | 新开发 | 无 loading/disabled 主按钮 | login, register | 认证主操作共用 |
| AuthSwitchFooter | 否 | 无 | 需开发 | 新开发 | 无登录注册切换页尾组件 | login, register | 形成认证闭环 |
| LoginFormCard | 否 | 无 | 需开发 | 新开发 | 无登录业务容器 | login | 聚合账号、密码、提交错误 |
| RegisterFormCard | 否 | 无 | 需开发 | 新开发 | 无注册业务容器 | register | 聚合手机号、用户名、昵称、密码 |
| ThirdPartyLoginButton | 否 | 无 | 需开发 | 新开发 | 无第三方授权按钮组件 | login | 主要为微信登录预留 |
| AgreementNotice | 否 | 无 | 需开发 | 新开发 | 无协议提示或勾选组件 | register | 是否必选待确认 |

## 汇总结论

- 当前仓库没有任何可直接复用的认证 UI 或表单业务组件，auth 任务组件全部为需开发。
- 登录与注册应优先共享一套认证基础组件，避免后续页面风格和校验行为分叉。
- 若微信登录进入首发范围，建议将第三方登录按钮和授权状态处理抽象为可扩展 provider 模式，而不是只写死微信。

