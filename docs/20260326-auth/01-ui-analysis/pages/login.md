# 页面分析: login

  ## 输入信息

  | 项目 | 内容 |
  | --- | --- |
  | 来源 | 用户补充需求，无设计稿 |
  | 分析页面 | 登录页 |
  | 目标设备 | 移动端手机页面 |
  | 已知约束 | 登录账号支持用户名或手机号；必须输入密码；可考虑微信登录 |
  | 假设前提 | 登录页作为未登录态入口页，与注册页互相跳转；延续 OneKeep 简洁卡片式移动端风格 |

  ## 页面结构说明

  | 区域 | 目标 | 布局类型 | 关键元素 | 备注 |
  | --- | --- | --- | --- | --- |
  | 顶部品牌区 | 建立应用识别与欢迎感 | 纵向堆叠 | Logo、标题、副标题 | 可弱化插画，重点是品牌与信任感 |
  | 表单区 | 完成账号密码输入 | 纵向表单 | 账号输入框、密码输入框、显示/隐藏密码按钮 | 账号输入框需支持手机号或用户名语义提示 |
  | 主操作区 | 提交登录请求 | 纵向按钮区 | 登录主按钮、忘记密码入口 | 忘记密码若未实现，可先记录占位 |
  | 第三方登录区 | 提供快捷登录入口 | 分区块 | 微信登录按钮、分割线文案 | 若首发不做，可置灰或隐藏 |
  | 底部跳转区 | 引导未注册用户去注册 | 横向文案区 | “没有账号？去注册” | 与注册页形成闭环 |

  ## 功能点清单

  | 功能点 | 用户动作 | 页面反馈 | 优先级 | 备注 |
  | --- | --- | --- | --- | --- |
  | 账号输入 | 输入用户名或手机号 | 实时显示输入内容并校验格式 | P0 | 手机号与用户名共用一个输入框 |
  | 密码输入 | 输入密码 | 支持密文展示与显示切换 | P0 | 需有最小长度规则 |
  | 登录提交 | 点击登录按钮 | 进入加载态，请求成功后进入主应用 | P0 | 首要闭环 |
  | 表单校验 | 输入缺失或非法 | 禁用按钮或展示错误提示 | P0 | 防止无效提交 |
  | 微信登录 | 点击微信登录 | 拉起微信授权或提示暂未开放 | P1 | 作为可选能力 |
  | 去注册 | 点击底部注册入口 | 跳转注册页 | P0 | 认证闭环必要 |
  | 忘记密码 | 点击忘记密码 | 进入找回密码流程或占位提示 | P2 | 当前需求未展开 |

  ## 布局树

  - LoginPage
    - SafeArea
      - ScrollView
        - BrandHeader
          - AppLogo
          - TitleText
          - SubtitleText
        - AuthFormCard
          - AccountInput
          - PasswordInput
          - ForgotPasswordLink
          - SubmitButton
        - ThirdPartySection
          - DividerWithText
          - WechatLoginButton
        - BottomSwitchAction
          - RegisterPromptText
          - RegisterLinkButton

  ## 组件拆分

  | 组件名 | 类型（页面/共享） | 所在区域 | 参数/配置 | 状态 | 备注 |
  | --- | --- | --- | --- | --- | --- |
  | AuthBrandHeader | 共享 | 顶部品牌区 | title, subtitle, logo | 默认 | 登录/注册共用 |
  | AuthInputField | 共享 | 表单区 | label, placeholder, keyboardType, errorText | 默认/聚焦/错误 | 可派生账号、手机号、昵称、密码输入 |
  | PasswordField | 共享 | 表单区 | obscureText, toggleVisible | 默认/显示/错误 | 继承 AuthInputField |
  | AuthPrimaryButton | 共享 | 主操作区 | text, loading, disabled | 默认/加载/禁用 | 登录/注册主按钮共用 |
  | ThirdPartyLoginButton | 共享 | 第三方登录区 | provider=wechat | 默认/禁用/加载 | 微信登录专用变体 |
  | AuthSwitchFooter | 共享 | 底部跳转区 | promptText, actionText | 默认 | 登录/注册切换使用 |
  | LoginFormCard | 页面 | 表单区 | accountValue, passwordValue | 默认 | 封装登录提交逻辑 |

  ## 组件匹配检查表

  | 候选组件 | 是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 备注 |
  | --- | --- | --- | --- | --- | --- | --- |
  | AuthBrandHeader | 否 | 无 | 需开发 | 新开发 | 当前仓库无认证头部组件 | 登录/注册可共用 |
  | AuthInputField | 否 | 无 | 需开发 | 新开发 | 当前仓库无表单输入组件体系 | 需支持错误态与语义键盘 |
  | PasswordField | 否 | 无 | 需开发 | 新开发 | 无密码显隐交互封装 | 可基于 AuthInputField 扩展 |
  | AuthPrimaryButton | 否 | 无 | 需开发 | 新开发 | 当前仓库无认证按钮组件 | 需支持 loading |
  | ThirdPartyLoginButton | 否 | 无 | 需开发 | 新开发 | 无第三方授权按钮组件 | 首发是否启用待确认 |
  | AuthSwitchFooter | 否 | 无 | 需开发 | 新开发 | 无认证页底部切换区 | 登录/注册闭环需要 |
  | LoginFormCard | 否 | 无 | 需开发 | 新开发 | 当前仓库没有登录业务容器 | 聚合校验、提交、错误展示 |

  ## 交互与状态表

  | 场景 | 触发条件 | 页面反馈 | 依赖组件 | 备注 |
  | --- | --- | --- | --- | --- |
  | 页面初始展示 | 用户进入登录页 | 默认聚焦第一个可编辑输入项或保持静态默认态 | AuthBrandHeader, LoginFormCard | 可按端能力决定是否自动聚焦 |
  | 账号格式错误 | 用户输入非法手机号或空用户名 | 展示字段级错误提示 | AuthInputField | 用户名规则待产品确认 |
  | 密码为空提交 | 点击登录时密码为空 | 阻止提交并展示错误 | PasswordField, AuthPrimaryButton | P0 |
  | 登录中 | 提交登录请求后 | 按钮进入 loading，禁止重复点击 | AuthPrimaryButton | 可同时禁用第三方按钮 |
  | 登录失败 | 服务端返回认证失败 | 展示表单级错误或 toast | LoginFormCard | 错误文案需统一 |
  | 登录成功 | 服务端返回成功 | 跳转主应用首页 | LoginFormCard | 需确定是否拉取用户初始化数据 |
  | 点击微信登录 | 点击微信按钮 | 进入微信授权或提示能力未开放 | ThirdPartyLoginButton | 可选能力 |
  | 点击去注册 | 点击底部入口 | 跳转注册页 | AuthSwitchFooter | 必须闭环 |

  ## 待确认问题与假设表

  | 类型 | 内容 | 影响范围 | 处理建议 |
  | --- | --- | --- | --- |
  | 假设 | 登录页与注册页采用统一认证视觉模板 | 组件抽象、主题设计 | 开发前由设计确认 |
  | 待确认 | 账号输入框对用户名格式是否有限制 | 服务端校验、客户端提示 | 在需求评审中补齐规则 |
  | 待确认 | 是否提供忘记密码流程 | 路由设计、服务端接口 | 若本轮不做，先隐藏入口 |
  | 待确认 | 微信登录是否首发启用 | 依赖接入、测试范围 | 作为 P1 开关能力处理 |

