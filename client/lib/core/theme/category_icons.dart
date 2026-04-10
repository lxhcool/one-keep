/// Category icon registry — maps category keys to PNG asset paths and Chinese labels.
///
/// Each entry has:
/// - key: English identifier (matches PNG filename without extension)
/// - label: Chinese display name
/// - type: 'expense' | 'income' | 'both'

const String _base = 'assets/category/';

class CategoryIconEntry {
  final String key;
  final String label;
  final String type; // 'expense', 'income', 'both'
  final String asset;

  const CategoryIconEntry({
    required this.key,
    required this.label,
    required this.type,
    required this.asset,
  });
}

const List<CategoryIconEntry> categoryIconEntries = [
  // ── 支出分类 ──
  // 餐饮
  CategoryIconEntry(key: 'breakfast', label: '早餐', type: 'expense', asset: '${_base}breakfast.png'),
  CategoryIconEntry(key: 'lunch', label: '午餐', type: 'expense', asset: '${_base}lunch.png'),
  CategoryIconEntry(key: 'dinner', label: '晚餐', type: 'expense', asset: '${_base}dinner.png'),
  CategoryIconEntry(key: 'hotpot', label: '火锅', type: 'expense', asset: '${_base}hotpot.png'),
  CategoryIconEntry(key: 'bbq', label: '烤肉', type: 'expense', asset: '${_base}bbq.png'),
  CategoryIconEntry(key: 'skewer', label: '烤串', type: 'expense', asset: '${_base}skewer.png'),
  CategoryIconEntry(key: 'dumpling', label: '饺子', type: 'expense', asset: '${_base}dumpling.png'),
  CategoryIconEntry(key: 'grocery', label: '买菜', type: 'expense', asset: '${_base}grocery.png'),
  CategoryIconEntry(key: 'fruit', label: '水果', type: 'expense', asset: '${_base}fruit.png'),
  CategoryIconEntry(key: 'snacks', label: '零食', type: 'expense', asset: '${_base}snacks.png'),
  CategoryIconEntry(key: 'ice_cream', label: '冰淇淋', type: 'expense', asset: '${_base}ice_cream.png'),
  // 饮品
  CategoryIconEntry(key: 'coffee', label: '咖啡', type: 'expense', asset: '${_base}coffee.png'),
  CategoryIconEntry(key: 'milk_tea', label: '奶茶', type: 'expense', asset: '${_base}milk_tea.png'),
  CategoryIconEntry(key: 'drinks', label: '饮品', type: 'expense', asset: '${_base}drinks.png'),
  CategoryIconEntry(key: 'cola', label: '可乐', type: 'expense', asset: '${_base}cola.png'),
  CategoryIconEntry(key: 'sprite', label: '雪碧', type: 'expense', asset: '${_base}sprite.png'),
  // 酒水
  CategoryIconEntry(key: 'beer', label: '啤酒', type: 'expense', asset: '${_base}beer.png'),
  CategoryIconEntry(key: 'wine', label: '葡萄酒', type: 'expense', asset: '${_base}wine.png'),
  CategoryIconEntry(key: 'baijiu', label: '白酒', type: 'expense', asset: '${_base}baijiu.png'),
  CategoryIconEntry(key: 'spirits', label: '洋酒', type: 'expense', asset: '${_base}spirits.png'),
  CategoryIconEntry(key: 'pineapple_beer', label: '菠萝啤', type: 'expense', asset: '${_base}pineapple_beer.png'),
  // 交通
  CategoryIconEntry(key: 'bus', label: '公交', type: 'expense', asset: '${_base}bus.png'),
  CategoryIconEntry(key: 'taxi', label: '出租车', type: 'expense', asset: '${_base}taxi.png'),
  CategoryIconEntry(key: 'train', label: '火车', type: 'expense', asset: '${_base}train.png'),
  CategoryIconEntry(key: 'flight', label: '飞机', type: 'expense', asset: '${_base}flight.png'),
  CategoryIconEntry(key: 'fuel', label: '加油', type: 'expense', asset: '${_base}fuel.png'),
  CategoryIconEntry(key: 'parking', label: '停车费', type: 'expense', asset: '${_base}parking.png'),
  CategoryIconEntry(key: 'car', label: '汽车', type: 'expense', asset: '${_base}car.png'),
  // 购物
  CategoryIconEntry(key: 'shopping', label: '购物', type: 'expense', asset: '${_base}shopping.png'),
  CategoryIconEntry(key: 'clothing', label: '衣服', type: 'expense', asset: '${_base}clothing.png'),
  CategoryIconEntry(key: 'shoes', label: '鞋子', type: 'expense', asset: '${_base}shoes.png'),
  CategoryIconEntry(key: 'socks', label: '袜子', type: 'expense', asset: '${_base}socks.png'),
  CategoryIconEntry(key: 'scarf', label: '围巾', type: 'expense', asset: '${_base}scarf.png'),
  // 数码 & 通讯
  CategoryIconEntry(key: 'phone', label: '手机', type: 'expense', asset: '${_base}phone.png'),
  CategoryIconEntry(key: 'computer', label: '电脑', type: 'expense', asset: '${_base}computer.png'),
  CategoryIconEntry(key: 'phone_bill', label: '话费', type: 'expense', asset: '${_base}phone_bill.png'),
  // 生活
  CategoryIconEntry(key: 'utilities', label: '水电', type: 'expense', asset: '${_base}utilities.png'),
  CategoryIconEntry(key: 'renovation', label: '装修', type: 'expense', asset: '${_base}renovation.png'),
  CategoryIconEntry(key: 'mortgage', label: '车房贷', type: 'expense', asset: '${_base}mortgage.png'),
  CategoryIconEntry(key: 'pet', label: '宠物', type: 'expense', asset: '${_base}pet.png'),
  CategoryIconEntry(key: 'stationery', label: '文具', type: 'expense', asset: '${_base}stationery.png'),
  // 娱乐
  CategoryIconEntry(key: 'movie', label: '电影', type: 'expense', asset: '${_base}movie.png'),
  CategoryIconEntry(key: 'gaming', label: '游戏', type: 'expense', asset: '${_base}gaming.png'),
  CategoryIconEntry(key: 'concert', label: '演唱会', type: 'expense', asset: '${_base}concert.png'),
  CategoryIconEntry(key: 'music', label: '音乐', type: 'expense', asset: '${_base}music.png'),
  CategoryIconEntry(key: 'sports', label: '运动', type: 'expense', asset: '${_base}sports.png'),
  CategoryIconEntry(key: 'travel', label: '旅游', type: 'expense', asset: '${_base}travel.png'),
  // 个人护理
  CategoryIconEntry(key: 'haircut', label: '理发', type: 'expense', asset: '${_base}haircut.png'),
  CategoryIconEntry(key: 'beauty', label: '美容', type: 'expense', asset: '${_base}beauty.png'),
  CategoryIconEntry(key: 'cosmetics', label: '化妆品', type: 'expense', asset: '${_base}cosmetics.png'),
  CategoryIconEntry(key: 'massage', label: '按摩', type: 'expense', asset: '${_base}massage.png'),
  // 医疗
  CategoryIconEntry(key: 'clinic', label: '看诊', type: 'expense', asset: '${_base}clinic.png'),
  CategoryIconEntry(key: 'medicine', label: '药品', type: 'expense', asset: '${_base}medicine.png'),
  // 社交 & 节日
  CategoryIconEntry(key: 'gift', label: '礼物', type: 'expense', asset: '${_base}gift.png'),
  CategoryIconEntry(key: 'flowers', label: '鲜花', type: 'expense', asset: '${_base}flowers.png'),
  CategoryIconEntry(key: 'festival', label: '节日', type: 'expense', asset: '${_base}festival.png'),
  // 其他支出
  CategoryIconEntry(key: 'other', label: '其他', type: 'both', asset: '${_base}other.png'),
  CategoryIconEntry(key: 'token', label: 'Token', type: 'expense', asset: '${_base}token.png'),

  // ── 收入分类 ──
  CategoryIconEntry(key: 'salary', label: '工资', type: 'income', asset: '${_base}salary.png'),
  CategoryIconEntry(key: 'investment', label: '理财', type: 'income', asset: '${_base}investment.png'),
  CategoryIconEntry(key: 'red_envelope', label: '红包', type: 'income', asset: '${_base}red_envelope.png'),
  CategoryIconEntry(key: 'transfer', label: '转账', type: 'both', asset: '${_base}transfer.png'),
];

/// Lookup map: key → entry
final Map<String, CategoryIconEntry> _byKey = {
  for (final e in categoryIconEntries) e.key: e,
};

/// Lookup map: Chinese label → entry
final Map<String, CategoryIconEntry> _byLabel = {
  for (final e in categoryIconEntries) e.label: e,
};

/// Get asset path by key (e.g. 'coffee' → 'assets/category/coffee.png')
String? categoryIconAsset(String key) => _byKey[key]?.asset;

/// Get asset path by Chinese label (e.g. '咖啡' → 'assets/category/coffee.png')
String? categoryIconAssetByLabel(String label) => _byLabel[label]?.asset;

/// Legacy Material icon name → new key mapping (for old database entries)
const Map<String, String> _legacyIconMap = {
  'restaurant': 'lunch',
  'restaurant_rounded': 'lunch',
  'directions_bus': 'bus',
  'directions_subway': 'bus',
  'directions_subway_rounded': 'bus',
  'shopping_bag': 'shopping',
  'shopping_bag_rounded': 'shopping',
  'receipt_long': 'other',
  'receipt_long_rounded': 'other',
  'sports_esports': 'gaming',
  'local_hospital': 'clinic',
  'school': 'stationery',
  'more_horiz': 'other',
  'work': 'salary',
  'account_balance_wallet': 'salary',
  'account_balance_wallet_rounded': 'salary',
  'trending_up': 'investment',
  'account_balance': 'investment',
  'account_balance_rounded': 'investment',
  'local_cafe': 'coffee',
  'local_cafe_rounded': 'coffee',
  // iconfont legacy keys
  'a-068_yongcan': 'lunch',
  'a-068_gongjiao': 'bus',
  'a-068_gouwu': 'shopping',
  'a-068_shuidian': 'utilities',
  'a-068_jiayou': 'fuel',
  'a-068_lvyou': 'travel',
  'a-068_jiuyi': 'clinic',
  'a-068_youxi': 'gaming',
  'a-068_gongzi': 'salary',
  'a-068_licai': 'investment',
  'a-068_zhuanzhang': 'transfer',
  'a-068_qita-60': 'other',
  'a-068_chuzuche': 'taxi',
  'a-068_dianying': 'movie',
  'a-068_yifu': 'clothing',
  'a-068_shuiguo': 'fruit',
  'a-068_lingshi': 'snacks',
  'a-068_yundong': 'sports',
  'a-068_liwu': 'gift',
  'a-068_yao': 'medicine',
  'a-068_huafei': 'phone_bill',
  'a-068_meifa': 'haircut',
  'a-068_chongwu': 'pet',
  'a-068_zaocan': 'breakfast',
  'a-068_maicai': 'grocery',
  'a-068_xianhua': 'flowers',
  // Chinese category name aliases (old seed names)
  '餐饮美食': 'lunch',
  '交通出行': 'bus',
  '购物消费': 'shopping',
  '生活缴费': 'utilities',
  '休闲娱乐': 'gaming',
  '医疗健康': 'clinic',
  '教育学习': 'stationery',
  '其他支出': 'other',
  '工资薪资': 'salary',
  '兼职收入': 'salary',
  '投资理财': 'investment',
  '其他收入': 'other',
  '用餐': 'lunch',
  '旅行': 'travel',
  '就医': 'clinic',
  '生活': 'utilities',
  '报销': 'transfer',
};

/// Resolve asset path from any identifier — tries key first, then label, then
/// legacy icon name, then substring match. Returns fallback 'other' if nothing matches.
String resolveCategoryIconAsset(String identifier) {
  // Exact key match
  if (_byKey.containsKey(identifier)) return _byKey[identifier]!.asset;
  // Exact label match
  if (_byLabel.containsKey(identifier)) return _byLabel[identifier]!.asset;
  // Legacy icon name match
  final legacyKey = _legacyIconMap[identifier];
  if (legacyKey != null && _byKey.containsKey(legacyKey)) return _byKey[legacyKey]!.asset;
  // Substring search in labels
  for (final e in categoryIconEntries) {
    if (identifier.contains(e.label) || e.label.contains(identifier)) {
      return e.asset;
    }
  }
  // Substring search in keys
  final lower = identifier.toLowerCase();
  for (final e in categoryIconEntries) {
    if (lower.contains(e.key) || e.key.contains(lower)) {
      return e.asset;
    }
  }
  return '${_base}other.png';
}

/// Get all entries filtered by type
List<CategoryIconEntry> categoryIconsByType(String type) {
  return categoryIconEntries.where((e) => e.type == type || e.type == 'both').toList();
}

/// Get the Chinese label for a key
String categoryIconLabel(String key) => _byKey[key]?.label ?? key;
