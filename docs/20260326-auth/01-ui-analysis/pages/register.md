# 页面分析: register

  ## 输入信息

  | 项目 | 内容 |
  | --- | --- |
  | 来源 | 截图 / Figma 导出 / MasterGo 地址 / Pencli 地址 / 页面链接 |
  | 分析页面 |  |
    | 来源 | 用户补充需求，无设计稿 |
    | 分析页面 | 注册页 |
    | 目标设备 | 移动端手机页面 |
    | 已知约束 | 注册字段包含手机号、用户名、昵称、密码 |
    | 假设前提 | 注册完成后可直接登录或自动进入主应用；与登录页共享视觉和组件体系 |

  | 区域 | 目标 | 布局类型 | 关键元素 | 备注 |
  | --- | --- | --- | --- | --- |

  ## 功能点清单
    | 顶部品牌区 | 建立注册引导和信任感 | 纵向堆叠 | Logo、标题、副标题 | 与登录页共用品牌头 |
    | 注册表单区 | 收集注册所需字段 | 纵向表单 | 手机号、用户名、昵称、密码四个输入项 | 字段顺序按用户提供要求 |
    | 主操作区 | 提交注册 | 纵向按钮区 | 注册按钮、用户协议提示 | 协议是否必选待确认 |
    | 辅助入口区 | 提供已有账号登录路径 | 横向文案区 | “已有账号？去登录” | 与登录页互相跳转 |

  | 功能点 | 用户动作 | 页面反馈 | 优先级 | 备注 |
  | --- | --- | --- | --- | --- |

  ## 布局树
    | 手机号输入 | 输入手机号 | 校验长度与格式 | P0 | 注册主键候选之一 |
    | 用户名输入 | 输入用户名 | 校验唯一性和格式 | P0 | 需服务端支持唯一性校验 |
    | 昵称输入 | 输入昵称 | 实时展示与长度校验 | P0 | 用于页面欢迎语与用户展示 |
    | 密码输入 | 输入密码 | 支持显隐切换与强度规则 | P0 | 需明确密码规则 |
    | 注册提交 | 点击注册按钮 | 按钮 loading，成功后进入下一步 | P0 | 注册核心闭环 |
    | 去登录 | 点击底部登录入口 | 跳转登录页 | P0 | 认证闭环必要 |
    | 协议确认 | 阅读或勾选协议 | 决定是否允许提交 | P1 | 设计稿缺失，仅保留需求位 |

  ## 组件拆分

    - RegisterPage
      - SafeArea
        - ScrollView
          - BrandHeader
            - AppLogo
            - TitleText
            - SubtitleText
          - AuthFormCard
            - PhoneInput
            - UsernameInput
            - NicknameInput
            - PasswordInput
            - AgreementHint
            - SubmitButton
          - BottomSwitchAction
            - LoginPromptText
            - LoginLinkButton

  | 组件名 | 类型（页面/共享） | 所在区域 | 参数/配置 | 状态 | 备注 |
  | --- | --- | --- | --- | --- | --- |

  ## 组件匹配检查表
    | AuthBrandHeader | 共享 | 顶部品牌区 | title, subtitle, logo | 默认 | 与登录页共用 |
    | AuthInputField | 共享 | 注册表单区 | label, placeholder, keyboardType, errorText | 默认/聚焦/错误 | 手机号、用户名、昵称共用 |
    | PasswordField | 共享 | 注册表单区 | obscureText, toggleVisible | 默认/显示/错误 | 与登录页共用 |
    | AgreementNotice | 共享 | 主操作区 | links, checked | 默认/错误 | 是否交互化待确认 |
    | AuthPrimaryButton | 共享 | 主操作区 | text, loading, disabled | 默认/加载/禁用 | 与登录页共用 |
    | AuthSwitchFooter | 共享 | 辅助入口区 | promptText, actionText | 默认 | 与登录页共用 |
    | RegisterFormCard | 页面 | 注册表单区 | phone, username, nickname, password | 默认 | 聚合注册逻辑与字段校验 |

  | 候选组件 | 是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 备注 |
  | --- | --- | --- | --- | --- | --- | --- |

  ## 交互与状态表
    | AuthBrandHeader | 否 | 无 | 需开发 | 新开发 | 仓库无认证页头部组件 | 可与登录页共用 |
    | AuthInputField | 否 | 无 | 需开发 | 新开发 | 无统一输入框和错误态组件 | 需覆盖多字段校验 |
    | PasswordField | 否 | 无 | 需开发 | 新开发 | 无密码显隐组件 | 注册/登录共用 |
    | AgreementNotice | 否 | 无 | 需开发 | 新开发 | 仓库无协议说明组件 | 首发可能简化为文案 |
    | AuthPrimaryButton | 否 | 无 | 需开发 | 新开发 | 无 loading 主按钮组件 | 与登录页共用 |
    | AuthSwitchFooter | 否 | 无 | 需开发 | 新开发 | 无页尾切换组件 | 登录/注册闭环需要 |
    | RegisterFormCard | 否 | 无 | 需开发 | 新开发 | 无注册业务容器 | 封装四字段提交逻辑 |

  | 场景 | 触发条件 | 页面反馈 | 依赖组件 | 备注 |
  | --- | --- | --- | --- | --- |

  ## 待确认问题与假设表
    | 手机号格式错误 | 输入非手机号格式 | 展示字段级错误 | AuthInputField | 手机号规则需与服务端一致 |
    | 用户名已占用 | 提交或失焦校验失败 | 展示占用提示 | AuthInputField, RegisterFormCard | 依赖服务端能力 |
    | 昵称为空 | 点击提交时昵称为空 | 阻止提交并提示错误 | AuthInputField, AuthPrimaryButton | P0 |
    | 密码弱或不合规 | 输入不满足规则 | 展示规则提示 | PasswordField | 规则待明确 |
    | 注册中 | 点击注册按钮后 | 按钮进入 loading，禁止重复点击 | AuthPrimaryButton | P0 |
    | 注册成功 | 服务端返回成功 | 跳转登录页或直接进入主应用 | RegisterFormCard | 跳转策略待确认 |
    | 点击去登录 | 点击底部入口 | 跳转登录页 | AuthSwitchFooter | 必须闭环 |


  | 类型 | 内容 | 影响范围 | 处理建议 |
  | --- | --- | --- | --- |

    | 假设 | 注册页与登录页共享同一认证模板和主题 token | 组件复用、开发效率 | 默认按共享方案设计 |
    | 待确认 | 注册成功后是自动登录还是跳登录页 | 主流程、接口编排 | 在需求评审中确定 |
    | 待确认 | 用户名唯一性校验是在输入阶段还是提交阶段 | 客户端交互、服务端接口 | 可先以提交阶段为最小实现 |
    | 待确认 | 是否需要用户协议和隐私政策勾选 | 法务、页面结构 | 若必需则补充字段和状态 |
    | 待确认 | 密码复杂度最低标准 | 服务端校验、前端提示 | 统一后写入接口契约 |

