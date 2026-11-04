import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kGreen = Color(0xFF07552E);
const Color kDeepGreen = Color(0xFF003D22);
const Color kGold = Color(0xFFE6AD27);
const Color kCream = Color(0xFFFFF7E8);
const Color kPaper = Color(0xFFFFFCF5);
const Color kInk = Color(0xFF25231D);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WapariApp());
}

class WapariApp extends StatefulWidget {
  const WapariApp({super.key});
  @override
  State<WapariApp> createState() => _WapariAppState();
}

class _WapariAppState extends State<WapariApp> {
  String? _language;
  bool _ready = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _language = prefs.getString('wapari_language');
      _ready = true;
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wapari_language', code);
    if (!mounted) return;
    setState(() => _language = code);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        home: const _BootWait(),
      );
    }
    return MaterialApp(
      key: ValueKey(_language ?? 'choose-language'),
      title: 'Wapari - واپاری',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: _showSplash
          ? SplashScreen(onDone: () => setState(() => _showSplash = false))
          : _language == null
              ? LanguageScreen(onSelected: _setLanguage)
              : HomeShell(language: _language!, onLanguageChanged: _setLanguage),
    );
  }
}

ThemeData _theme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kGreen, primary: kGreen, secondary: kGold),
      scaffoldBackgroundColor: kCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: kDeepGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black38,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD8C9A9))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD8C9A9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: kGreen, width: 1.8)),
      ),
    );

class _BootWait extends StatelessWidget {
  const _BootWait();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kGreen)),
      );
}

class Txt {
  static const Map<String, Map<String, String>> _data = {
    'app': {'ur': 'واپاری', 'en': 'Wapari', 'hi': 'व्यापारी', 'zh': '商贸账本'},
    'tagline': {'ur': 'اجناس کا مکمل حساب', 'en': 'Complete commodity accounts', 'hi': 'अनाज का पूरा हिसाब', 'zh': '完整的商品账本'},
    'accounts': {'ur': 'تمام اکاؤنٹس', 'en': 'All Accounts', 'hi': 'सभी खाते', 'zh': '全部账户'},
    'new_account': {'ur': 'نیا کھاتہ بنائیں', 'en': 'Create New Account', 'hi': 'नया खाता बनाएँ', 'zh': '新建账户'},
    'reports': {'ur': 'رپورٹس', 'en': 'Reports', 'hi': 'रिपोर्ट', 'zh': '报表'},
    'settings': {'ur': 'سیٹنگز', 'en': 'Settings', 'hi': 'सेटिंग्स', 'zh': '设置'},
    'home': {'ur': 'ہوم', 'en': 'Home', 'hi': 'होम', 'zh': '首页'},
    'name': {'ur': 'نام', 'en': 'Customer name', 'hi': 'नाम', 'zh': '客户姓名'},
    'father': {'ur': 'ولدیت', 'en': 'Father name', 'hi': 'पिता का नाम', 'zh': '父亲姓名'},
    'address': {'ur': 'مکمل پتہ (اختیاری)', 'en': 'Full address (optional)', 'hi': 'पूरा पता (वैकल्पिक)', 'zh': '地址（选填）'},
    'phone': {'ur': 'موبائل نمبر (اختیاری)', 'en': 'Mobile number (optional)', 'hi': 'मोबाइल नंबर (वैकल्पिक)', 'zh': '手机号（选填）'},
    'commodity': {'ur': 'اجناس', 'en': 'Commodity', 'hi': 'अनाज / वस्तु', 'zh': '商品'},
    'choose_commodity': {'ur': 'اجناس منتخب کریں', 'en': 'Choose commodity', 'hi': 'वस्तु चुनें', 'zh': '选择商品'},
    'bag_weight': {'ur': 'فی بوری وزن (کلو)', 'en': 'Weight per bag (kg)', 'hi': 'प्रति बोरी वजन (किलो)', 'zh': '每袋重量（公斤）'},
    'bag_count': {'ur': 'کل بوریوں کی تعداد', 'en': 'Total number of bags', 'hi': 'कुल बोरियों की संख्या', 'zh': '袋数'},
    'extra': {'ur': 'اضافی وزن (کلو)', 'en': 'Additional weight (kg)', 'hi': 'अतिरिक्त वजन (किलो)', 'zh': '额外重量（公斤）'},
    'rate': {'ur': 'ریٹ (قیمت)', 'en': 'Rate', 'hi': 'रेट', 'zh': '单价'},
    'per_kg': {'ur': 'فی کلو', 'en': 'Per kg', 'hi': 'प्रति किलो', 'zh': '每公斤'},
    'per_maund': {'ur': 'فی من', 'en': 'Per maund', 'hi': 'प्रति मन', 'zh': '每曼'},
    'rate_amount': {'ur': 'ریٹ کی رقم (روپے)', 'en': 'Rate amount (PKR)', 'hi': 'रेट राशि (रुपये)', 'zh': '单价金额（卢比）'},
    'total_bag_weight': {'ur': 'بوریوں کا کل وزن', 'en': 'Total bag weight', 'hi': 'बोरियों का कुल वजन', 'zh': '袋装总重量'},
    'total_weight': {'ur': 'کل وزن', 'en': 'Total weight', 'hi': 'कुल वजन', 'zh': '总重量'},
    'maund_breakdown': {'ur': 'وزن من میں (1 من = 40 کلو)', 'en': 'Weight in maund (1 maund = 40 kg)', 'hi': 'मन में वजन (1 मन = 40 किलो)', 'zh': '曼单位重量（1曼=40公斤）'},
    'maund': {'ur': 'من', 'en': 'maund', 'hi': 'मन', 'zh': '曼'},
    'remaining': {'ur': 'باقی وزن', 'en': 'Remaining', 'hi': 'शेष वजन', 'zh': '剩余'},
    'kg': {'ur': 'کلو', 'en': 'kg', 'hi': 'किलो', 'zh': '公斤'},
    'kg_rate': {'ur': 'فی کلو قیمت', 'en': 'Price per kg', 'hi': 'प्रति किलो कीमत', 'zh': '每公斤价格'},
    'maund_rate': {'ur': 'فی من قیمت (حساب شدہ)', 'en': 'Per maund price (calculated)', 'hi': 'प्रति मन कीमत (गणना)', 'zh': '每曼价格（计算）'},
    'total_price': {'ur': 'کل قیمت', 'en': 'Total amount', 'hi': 'कुल कीमत', 'zh': '总金额'},
    'save_account': {'ur': 'کھاتہ محفوظ کریں', 'en': 'Save Account', 'hi': 'खाता सेव करें', 'zh': '保存账户'},
    'saved': {'ur': 'کھاتہ محفوظ ہو گیا', 'en': 'Account saved', 'hi': 'खाता सेव हो गया', 'zh': '账户已保存'},
    'sms': {'ur': 'SMS بھیجیں', 'en': 'Send SMS', 'hi': 'SMS भेजें', 'zh': '发送短信'},
    'whatsapp': {'ur': 'WhatsApp پر بھیجیں', 'en': 'Send on WhatsApp', 'hi': 'WhatsApp पर भेजें', 'zh': '发送 WhatsApp'},
    'send_optional': {'ur': 'پیغام بھیجنا اختیاری ہے', 'en': 'Message sending is optional', 'hi': 'मैसेज भेजना वैकल्पिक है', 'zh': '可选发送消息'},
    'search': {'ur': 'نام یا اجناس تلاش کریں...', 'en': 'Search name or commodity...', 'hi': 'नाम या वस्तु खोजें...', 'zh': '搜索姓名或商品...'},
    'no_accounts': {'ur': 'ابھی کوئی کھاتہ محفوظ نہیں', 'en': 'No accounts saved yet', 'hi': 'अभी कोई खाता सेव नहीं है', 'zh': '暂无已保存账户'},
    'details': {'ur': 'کھاتے کی تفصیل', 'en': 'Account details', 'hi': 'खाते का विवरण', 'zh': '账户详情'},
    'language': {'ur': 'زبان منتخب کریں', 'en': 'Choose language', 'hi': 'भाषा चुनें', 'zh': '选择语言'},
    'choose_language': {'ur': 'اپنی پسند کی زبان منتخب کریں', 'en': 'Select your preferred language', 'hi': 'अपनी पसंद की भाषा चुनें', 'zh': '请选择您的语言'},
    'backup': {'ur': 'بیک اپ کاپی کریں', 'en': 'Copy backup', 'hi': 'बैकअप कॉपी करें', 'zh': '复制备份'},
    'backup_done': {'ur': 'بیک اپ کلپ بورڈ میں کاپی ہو گیا', 'en': 'Backup copied to clipboard', 'hi': 'बैकअप कॉपी हो गया', 'zh': '备份已复制'},
    'select_phone': {'ur': 'پیغام بھیجنے کے لیے موبائل نمبر درج کریں', 'en': 'Add a mobile number to send a message', 'hi': 'मैसेज भेजने के लिए मोबाइल नंबर डालें', 'zh': '请填写手机号以发送消息'},
    'required': {'ur': 'یہ خانہ ضروری ہے', 'en': 'This field is required', 'hi': 'यह फ़ील्ड ज़रूरी है', 'zh': '此项为必填项'},
    'cancel': {'ur': 'واپس', 'en': 'Back', 'hi': 'वापस', 'zh': '返回'},
    'edit': {'ur': 'ترمیم', 'en': 'Edit', 'hi': 'संपादित करें', 'zh': '编辑'},
    'delete': {'ur': 'حذف کریں', 'en': 'Delete', 'hi': 'हटाएँ', 'zh': '删除'},
    'delete_confirm': {'ur': 'کیا آپ یہ کھاتہ حذف کرنا چاہتے ہیں؟', 'en': 'Delete this account?', 'hi': 'क्या यह खाता हटाना है?', 'zh': '确定删除此账户吗？'},
    'confirm': {'ur': 'ہاں، حذف کریں', 'en': 'Delete', 'hi': 'हाँ, हटाएँ', 'zh': '删除'},
    'total_accounts': {'ur': 'کل کھاتے', 'en': 'Total accounts', 'hi': 'कुल खाते', 'zh': '账户总数'},
    'total_goods': {'ur': 'کل وزن', 'en': 'Total weight', 'hi': 'कुल वजन', 'zh': '总重量'},
    'total_sales': {'ur': 'کل رقم', 'en': 'Total amount', 'hi': 'कुल राशि', 'zh': '总金额'},
    'commodity_report': {'ur': 'اجناس وار خلاصہ', 'en': 'Commodity summary', 'hi': 'वस्तु के अनुसार सारांश', 'zh': '商品汇总'},
    'saved_on_device': {'ur': 'ڈیٹا اسی ڈیوائس میں محفوظ ہے', 'en': 'Data is stored on this device', 'hi': 'डेटा इसी डिवाइस में सेव है', 'zh': '数据保存在此设备上'},
    'no_phone': {'ur': 'موبائل نمبر موجود نہیں، پیغام نہیں بھیجا جا سکتا', 'en': 'No phone number; message cannot be opened', 'hi': 'मोबाइल नंबर नहीं है', 'zh': '没有手机号，无法发送'},
    'rate_help': {'ur': 'ریٹ کے مطابق فی کلو اور فی من قیمت خود بخود نکلے گی۔', 'en': 'Equivalent per-kg and per-maund rates are calculated automatically.', 'hi': 'प्रति किलो और प्रति मन दर अपने-आप निकलेगी।', 'zh': '系统会自动换算每公斤和每曼单价。'},
  };

  static String get(String key, String lang) => _data[key]?[lang] ?? _data[key]?['ur'] ?? key;
  static bool isRtl(String lang) => lang == 'ur';
}

class TradeAccount {
  final String id;
  final String name;
  final String fatherName;
  final String address;
  final String phone;
  final String commodity;
  final double bagWeightKg;
  final int bagCount;
  final double extraKg;
  final String rateMode;
  final double rateValue;
  final DateTime createdAt;

  const TradeAccount({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.address,
    required this.phone,
    required this.commodity,
    required this.bagWeightKg,
    required this.bagCount,
    required this.extraKg,
    required this.rateMode,
    required this.rateValue,
    required this.createdAt,
  });

  double get totalBagWeight => bagWeightKg * bagCount;
  double get totalWeight => totalBagWeight + extraKg;
  int get maunds => totalWeight ~/ 40;
  double get remainingKg => totalWeight - maunds * 40;
  double get kgRate => rateMode == 'kg' ? rateValue : rateValue / 40;
  double get maundRate => rateMode == 'maund' ? rateValue : rateValue * 40;
  double get totalPrice => totalWeight * kgRate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fatherName': fatherName,
        'address': address,
        'phone': phone,
        'commodity': commodity,
        'bagWeightKg': bagWeightKg,
        'bagCount': bagCount,
        'extraKg': extraKg,
        'rateMode': rateMode,
        'rateValue': rateValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TradeAccount.fromJson(Map<String, dynamic> json) => TradeAccount(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        fatherName: json['fatherName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        commodity: json['commodity'] as String? ?? 'Wheat',
        bagWeightKg: (json['bagWeightKg'] as num?)?.toDouble() ?? 0,
        bagCount: (json['bagCount'] as num?)?.toInt() ?? 0,
        extraKg: (json['extraKg'] as num?)?.toDouble() ?? 0,
        rateMode: json['rateMode'] as String? ?? 'kg',
        rateValue: (json['rateValue'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class LocalStore {
  static const String _accountsKey = 'wapari_accounts_v1';
  static Future<List<TradeAccount>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => TradeAccount.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAccount(TradeAccount account) async {
    final accounts = await loadAccounts();
    final index = accounts.indexWhere((e) => e.id == account.id);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.insert(0, account);
    }
    await _write(accounts);
  }

  static Future<void> deleteAccount(String id) async {
    final accounts = await loadAccounts();
    accounts.removeWhere((e) => e.id == id);
    await _write(accounts);
  }

  static Future<String> exportJson() async {
    final accounts = await loadAccounts();
    return const JsonEncoder.withIndent('  ').convert(accounts.map((e) => e.toJson()).toList());
  }

  static Future<void> _write(List<TradeAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts.map((e) => e.toJson()).toList()));
  }
}

String money(double value) {
  final fixed = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    buffer.write(whole[i]);
    final left = whole.length - i - 1;
    if (left > 0 && left % 3 == 0) buffer.write(',');
  }
  return parts.length == 1 ? buffer.toString() : '${buffer.toString()}.${parts[1]}';
}

String commodityLabel(String key, String language) {
  final item = commodities.firstWhere((e) => e.key == key, orElse: () => commodities.first);
  switch (language) {
    case 'en': return item.en;
    case 'hi': return item.hi;
    case 'zh': return item.zh;
    default: return item.ur;
  }
}

class Commodity {
  final String key;
  final String ur;
  final String en;
  final String hi;
  final String zh;
  final String emoji;
  const Commodity(this.key, this.ur, this.en, this.hi, this.zh, this.emoji);
}

const List<Commodity> commodities = [
  Commodity('Wheat', 'گندم', 'Wheat', 'गेहूँ', '小麦', '🌾'),
  Commodity('Rice', 'چاول', 'Rice', 'चावल', '大米', '🍚'),
  Commodity('Maize', 'مکئی', 'Maize', 'मक्का', '玉米', '🌽'),
  Commodity('Barley', 'جو', 'Barley', 'जौ', '大麦', '🌾'),
  Commodity('Millet', 'باجرہ', 'Millet', 'बाजरा', '小米', '🌾'),
  Commodity('Sorghum', 'جوار', 'Sorghum', 'ज्वार', '高粱', '🌾'),
  Commodity('Gram', 'چنا', 'Chickpea', 'चना', '鹰嘴豆', '🫘'),
  Commodity('Mung', 'مونگ', 'Mung bean', 'मूँग', '绿豆', '🫘'),
  Commodity('Lentil', 'مسور', 'Lentil', 'मसूर', '扁豆', '🫘'),
  Commodity('Sesame', 'تل', 'Sesame', 'तिल', '芝麻', '🌱'),
  Commodity('Mustard', 'سرسوں', 'Mustard', 'सरसों', '芥菜籽', '🌼'),
  Commodity('Cotton', 'کپاس', 'Cotton', 'कपास', '棉花', '☁️'),
  Commodity('Sugarcane', 'گنا', 'Sugarcane', 'गन्ना', '甘蔗', '🎋'),
  Commodity('Peanut', 'مونگ پھلی', 'Peanut', 'मूँगफली', '花生', '🥜'),
  Commodity('Soybean', 'سویا بین', 'Soybean', 'सोयाबीन', '大豆', '🫘'),
  Commodity('Sunflower', 'سورج مکھی', 'Sunflower', 'सूरजमुखी', '向日葵', '🌻'),
  Commodity('Canola', 'کینولا', 'Canola', 'कैनोला', '油菜籽', '🌼'),
  Commodity('Oats', 'جئی', 'Oats', 'जई', '燕麦', '🌾'),
  Commodity('Black Gram', 'ماش', 'Black gram', 'उड़द', '黑豆', '🫘'),
  Commodity('Kidney Beans', 'لوبیا', 'Kidney beans', 'राजमा', '芸豆', '🫘'),
  Commodity('Peas', 'مٹر', 'Peas', 'मटर', '豌豆', '🫛'),
  Commodity('Cottonseed', 'بنولہ', 'Cottonseed', 'बिनौला', '棉籽', '☁️'),
  Commodity('Linseed', 'السی', 'Linseed', 'अलसी', '亚麻籽', '🌱'),
  Commodity('Coriander', 'دھنیا', 'Coriander', 'धनिया', '香菜籽', '🌿'),
  Commodity('Cumin', 'زیرہ', 'Cumin', 'जीरा', '孜然', '🌱'),
  Commodity('Red Chili', 'سرخ مرچ', 'Red chili', 'लाल मिर्च', '辣椒', '🌶️'),
  Commodity('Potato', 'آلو', 'Potato', 'आलू', '土豆', '🥔'),
  Commodity('Onion', 'پیاز', 'Onion', 'प्याज', '洋葱', '🧅'),
  Commodity('Sugar', 'چینی', 'Sugar', 'चीनी', '糖', '🧂'),
  Commodity('Fodder', 'چارہ', 'Fodder', 'चारा', '饲料', '🌿'),
  Commodity('Other', 'دیگر', 'Other', 'अन्य', '其他', '•••'),
];

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100))..forward();
  late final Animation<Offset> _left = Tween<Offset>(begin: const Offset(-1.6, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, .65, curve: Curves.elasticOut)));
  late final Animation<Offset> _right = Tween<Offset>(begin: const Offset(1.6, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(.12, .78, curve: Curves.elasticOut)));
  late final AnimationController _sackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250))..repeat(reverse: true);
  late final Animation<double> _sacks = Tween<double>(begin: -.035, end: .035).animate(CurvedAnimation(parent: _sackController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() { _controller.dispose(); _sackController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AnimatedBuilder(
          animation: Listenable.merge([_controller, _sackController]),
          builder: (context, _) => Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB8D5E3), Color(0xFFFFD98B), Color(0xFFB17C28), kDeepGreen]),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 24),
                  Column(children: [
                    SizedBox(height: 150, child: Stack(alignment: Alignment.center, children: [
                      Container(width: 142, height: 142, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .72), border: Border.all(color: kGold, width: 4), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 9))])),
                      SlideTransition(position: _left, child: const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 48), child: Icon(Icons.front_hand_rounded, size: 67, color: Color(0xFF9A5B18))))),
                      SlideTransition(position: _right, child: const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 48), child: Icon(Icons.front_hand_rounded, size: 67, color: Color(0xFFB77B2D))))),
                      const Positioned(top: 5, right: 0, child: Icon(Icons.grass_rounded, size: 58, color: Color(0xFFBE7B12))),
                    ])),
                    const SizedBox(height: 5),
                    const Text('واپاری', style: TextStyle(fontSize: 58, height: 1.0, color: kDeepGreen, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.white70, blurRadius: 10, offset: Offset(1, 2))])),
                    const Text('WAPARI', style: TextStyle(fontSize: 25, letterSpacing: 5, color: kDeepGreen, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9), decoration: BoxDecoration(color: kDeepGreen, borderRadius: BorderRadius.circular(28), border: Border.all(color: kGold, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 9, offset: Offset(0, 5))]), child: const Text('اجناس کا مکمل حساب', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Transform.translate(
                      offset: Offset(0, _sacks.value * 45),
                      child: Image.asset('assets/grain_sacks.png', height: 150, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class LanguageScreen extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const LanguageScreen({super.key, required this.onSelected});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kDeepGreen, Color(0xFF0B7540), kCream])),
          child: SafeArea(child: Center(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [
            const Icon(Icons.language_rounded, color: kGold, size: 58),
            const SizedBox(height: 12),
            const Text('واپاری | Wapari', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('اپنی پسند کی زبان منتخب کریں', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 24),
            _LanguageTile(label: 'اردو', sub: 'Urdu', flag: '🇵🇰', onTap: () => onSelected('ur')),
            _LanguageTile(label: 'हिन्दी', sub: 'Hindi', flag: '🇮🇳', onTap: () => onSelected('hi')),
            _LanguageTile(label: 'English', sub: 'English', flag: '🌐', onTap: () => onSelected('en')),
            _LanguageTile(label: '中文', sub: 'Chinese', flag: '🇨🇳', onTap: () => onSelected('zh')),
          ]))))),
        ),
      );
}

class _LanguageTile extends StatelessWidget {
  final String label, sub, flag;
  final VoidCallback onTap;
  const _LanguageTile({required this.label, required this.sub, required this.flag, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 7,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              color: kPaper,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kGold, width: 1.3),
            ),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: kDeepGreen),
                  ),
                ),
                Text(sub, style: const TextStyle(color: Colors.black54)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 17, color: kGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  const HomeShell({super.key, required this.language, required this.onLanguageChanged});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  int _accountsRevision = 0;
  String get lang => widget.language;
  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(language: lang, onNew: _newAccount, onAccounts: () => setState(() => _tab = 1)),
      AccountsScreen(key: ValueKey(_accountsRevision), language: lang),
      ReportsScreen(language: lang),
      SettingsScreen(language: lang, onLanguageChanged: widget.onLanguageChanged),
    ];
    return Directionality(
      textDirection: Txt.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(index: _tab, children: pages),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: kPaper, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -3))]),
          child: NavigationBar(
            height: 68,
            selectedIndex: _tab,
            backgroundColor: kPaper,
            indicatorColor: const Color(0xFFDDEBCB),
            onDestinationSelected: (i) => setState(() { _tab = i; if (i == 1) _accountsRevision++; }),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_rounded), label: Txt.get('home', lang)),
              NavigationDestination(icon: const Icon(Icons.inventory_2_rounded), label: Txt.get('accounts', lang)),
              NavigationDestination(icon: const Icon(Icons.bar_chart_rounded), label: Txt.get('reports', lang)),
              NavigationDestination(icon: const Icon(Icons.settings_rounded), label: Txt.get('settings', lang)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _newAccount() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AccountFormScreen(language: lang)));
    if (mounted) setState(() => _accountsRevision++);
  }
}

class DashboardScreen extends StatelessWidget {
  final String language;
  final VoidCallback onNew, onAccounts;
  const DashboardScreen({super.key, required this.language, required this.onNew, required this.onAccounts});
  @override
  Widget build(BuildContext context) => Directionality(textDirection: Txt.isRtl(language) ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
        appBar: AppBar(title: Text('${Txt.get('app', language)} (Wapari)'), leading: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.menu_rounded)), actions: const [Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Icon(Icons.notifications_none_rounded))]),
        body: ListView(padding: const EdgeInsets.all(15), children: [
          _HeroFarm(language: language),
          const SizedBox(height: 16),
          _BigAction(icon: Icons.groups_rounded, title: Txt.get('accounts', language), subtitle: 'Accounts', color: kGreen, onTap: onAccounts),
          const SizedBox(height: 13),
          _BigAction(icon: Icons.note_add_rounded, title: Txt.get('new_account', language), subtitle: 'New Account', color: const Color(0xFFC28718), onTap: onNew),
          const SizedBox(height: 16),
          FutureBuilder<List<TradeAccount>>(future: LocalStore.loadAccounts(), builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            final weight = items.fold<double>(0, (sum, e) => sum + e.totalWeight);
            final value = items.fold<double>(0, (sum, e) => sum + e.totalPrice);
            return Row(children: [Expanded(child: _MiniStat(icon: Icons.people_alt_rounded, label: Txt.get('total_accounts', language), value: '${items.length}')), const SizedBox(width: 9), Expanded(child: _MiniStat(icon: Icons.scale_rounded, label: Txt.get('total_goods', language), value: '${money(weight)} kg')), const SizedBox(width: 9), Expanded(child: _MiniStat(icon: Icons.payments_rounded, label: Txt.get('total_sales', language), value: 'Rs ${money(value)}'))]);
          }),
          const SizedBox(height: 15),
          _SectionTitle(text: Txt.get('tagline', language)),
          const SizedBox(height: 8),
          const Text('🌾  گندم  •  چاول  •  مکئی  •  جو  •  باجرہ  •  دالیں', textAlign: TextAlign.center, style: TextStyle(color: kGreen, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      ));
}

class _HeroFarm extends StatelessWidget {
  final String language;
  const _HeroFarm({required this.language});
  @override
  Widget build(BuildContext context) => Container(
        height: 152,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kGold, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 9, offset: Offset(0, 5))],
          image: const DecorationImage(image: AssetImage('assets/hero_farm.png'), fit: BoxFit.cover),
        ),
        child: Stack(children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [kDeepGreen.withValues(alpha: .10), kDeepGreen.withValues(alpha: .32)])))),
          Positioned(left: 14, top: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9), decoration: BoxDecoration(color: kDeepGreen.withValues(alpha: .93), borderRadius: BorderRadius.circular(17), border: Border.all(color: kGold)), child: Text(Txt.get('tagline', language), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)))),
        ]),
      );
}

class _BigAction extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _BigAction({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(elevation: 8, borderRadius: BorderRadius.circular(22), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(height: 108, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, Color.lerp(color, Colors.black, .35)!]), border: Border.all(color: kGold, width: 2), boxShadow: const [BoxShadow(color: Colors.white24, blurRadius: 4, offset: Offset(-2, -2))]), child: Row(children: [Icon(icon, size: 48, color: Colors.white), const SizedBox(width: 17), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 21)), Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))])), const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70)]))));
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _MiniStat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7), decoration: BoxDecoration(color: const Color(0xFFFFEFC8), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD6B36D)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))]), child: Column(children: [Icon(icon, color: kGreen, size: 25), const SizedBox(height: 4), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, color: kDeepGreen)), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black87))]));
}

class AccountsScreen extends StatefulWidget {
  final String language;
  const AccountsScreen({super.key, required this.language});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late Future<List<TradeAccount>> _future;
  final TextEditingController _search = TextEditingController();
  @override
  void initState() { super.initState(); _future = LocalStore.loadAccounts(); }
  void _reload() => setState(() => _future = LocalStore.loadAccounts());
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    return Directionality(textDirection: Txt.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
      appBar: AppBar(title: Text(Txt.get('accounts', lang)), actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded))]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(13), child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: Txt.get('search', lang)))),
        Expanded(child: FutureBuilder<List<TradeAccount>>(future: _future, builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final query = _search.text.trim().toLowerCase();
          final accounts = (snapshot.data ?? []).where((e) => '${e.name} ${e.fatherName} ${e.address} ${commodityLabel(e.commodity, lang)}'.toLowerCase().contains(query)).toList();
          if (accounts.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.folder_open_rounded, size: 58, color: Colors.black26), const SizedBox(height: 10), Text(Txt.get('no_accounts', lang), style: const TextStyle(color: Colors.black54, fontSize: 16))]));
          return RefreshIndicator(onRefresh: () async => _reload(), child: ListView.builder(padding: const EdgeInsets.fromLTRB(12, 0, 12, 16), itemCount: accounts.length, itemBuilder: (context, index) {
            final a = accounts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountDetailScreen(
                          account: a,
                          language: lang,
                          alreadySaved: true,
                        ),
                      ),
                    );
                    _reload();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: kPaper,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD8C49A)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFE9A8), Color(0xFFBD821A)],
                            ),
                            border: Border.all(color: kGreen),
                          ),
                          child: const Icon(Icons.person_rounded, color: kDeepGreen, size: 31),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kInk)),
                              if (a.fatherName.isNotEmpty)
                                Text(
                                  '${lang == 'ur' ? 'ولد: ' : 'Father: '}${a.fatherName}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kGreen),
                                ),
                              if (a.address.isNotEmpty)
                                Text(a.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                              const SizedBox(height: 5),
                              Text(
                                '${commodityLabel(a.commodity, lang)}  •  ${money(a.totalWeight)} kg  •  Rs ${money(a.totalPrice)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C5B0A)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 28, color: kGreen),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }));
        }))
      ]),
    ));
  }
}

class AccountFormScreen extends StatefulWidget {
  final String language;
  const AccountFormScreen({super.key, required this.language});
  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _father = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _bagWeight = TextEditingController(text: '50');
  final _bagCount = TextEditingController(text: '10');
  final _extra = TextEditingController(text: '0');
  final _rate = TextEditingController(text: '220');
  String _commodity = 'Wheat';
  String _rateMode = 'kg';

  String get lang => widget.language;
  double _num(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  double get _bagTotal => _num(_bagWeight) * _num(_bagCount);
  double get _total => _bagTotal + _num(_extra);
  double get _price => _total * (_rateMode == 'kg' ? _num(_rate) : _num(_rate) / 40);

  @override
  void initState() {
    super.initState();
    for (final c in [_bagWeight, _bagCount, _extra, _rate]) c.addListener(_update);
  }
  void _update() { if (mounted) setState(() {}); }
  @override
  void dispose() { for (final c in [_name, _father, _address, _phone, _bagWeight, _bagCount, _extra, _rate]) { c.dispose(); } super.dispose(); }

  Future<void> _chooseCommodity() async {
    final chosen = await showModalBottomSheet<String>(context: context, isScrollControlled: true, backgroundColor: kCream, builder: (_) => CommodityPicker(language: lang, selected: _commodity));
    if (chosen != null) setState(() => _commodity = chosen);
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? Txt.get('required', lang) : null;
  Widget _field(String label, TextEditingController c, {bool required = false, TextInputType? keyboard, String? hint}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, keyboardType: keyboard, validator: required ? _required : null, decoration: InputDecoration(labelText: label, hintText: hint)));

  @override
  Widget build(BuildContext context) => Directionality(textDirection: Txt.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
    appBar: AppBar(title: Text(Txt.get('new_account', lang))),
    body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(14), children: [
      _formSection(Txt.get('details', lang), [
        _field(Txt.get('name', lang), _name, required: true),
        _field(Txt.get('father', lang), _father),
        _field(Txt.get('address', lang), _address),
        _field(Txt.get('phone', lang), _phone, keyboard: TextInputType.phone),
         InkWell(
           onTap: _chooseCommodity,
           borderRadius: BorderRadius.circular(14),
           child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(14),
               border: Border.all(color: const Color(0xFFD8C9A9)),
             ),
             child: Row(
               children: [
                 const Text('🌾', style: TextStyle(fontSize: 25)),
                 const SizedBox(width: 10),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(Txt.get('commodity', lang), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                       Text(commodityLabel(_commodity, lang), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: kDeepGreen)),
                     ],
                   ),
                 ),
                 const Icon(Icons.keyboard_arrow_down_rounded, color: kGreen, size: 28),
               ],
             ),
           ),
         ),
      ]),
      _formSection(Txt.get('bag_weight', lang), [
        _field(Txt.get('bag_weight', lang), _bagWeight, required: true, keyboard: const TextInputType.numberWithOptions(decimal: true)),
        _field(Txt.get('bag_count', lang), _bagCount, required: true, keyboard: TextInputType.number),
        _field(Txt.get('extra', lang), _extra, keyboard: const TextInputType.numberWithOptions(decimal: true)),
      ]),
      _formSection(Txt.get('rate', lang), [
        SegmentedButton<String>(segments: [ButtonSegment(value: 'kg', label: Text(Txt.get('per_kg', lang)), icon: const Icon(Icons.scale_rounded)), ButtonSegment(value: 'maund', label: Text(Txt.get('per_maund', lang)), icon: const Icon(Icons.inventory_2_rounded))], selected: {_rateMode}, onSelectionChanged: (s) => setState(() => _rateMode = s.first)),
        const SizedBox(height: 12),
        _field(Txt.get('rate_amount', lang), _rate, required: true, keyboard: const TextInputType.numberWithOptions(decimal: true)),
        Text(Txt.get('rate_help', lang), style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ]),
      _CalculationCard(language: lang, bagWeight: _num(_bagWeight), bagCount: _num(_bagCount), bagTotal: _bagTotal, extra: _num(_extra), total: _total, kgRate: _rateMode == 'kg' ? _num(_rate) : _num(_rate) / 40, maundRate: _rateMode == 'maund' ? _num(_rate) : _num(_rate) * 40, price: _price),
      const SizedBox(height: 15),
      _GoldButton(icon: Icons.calculate_rounded, title: lang == 'ur' ? 'کھاتے کی تفصیل تیار کریں' : 'Generate account details', onTap: () {
        if (!_formKey.currentState!.validate()) return;
        if (_num(_bagWeight) <= 0 || _num(_bagCount) <= 0 || _num(_bagCount) % 1 != 0 || _num(_rate) <= 0 || _num(_extra) < 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ur' ? 'وزن، بوریوں اور ریٹ کی درست رقم درج کریں۔' : 'Enter valid positive weights, bag count and rate.')));
          return;
        }
        final account = TradeAccount(id: DateTime.now().microsecondsSinceEpoch.toString(), name: _name.text.trim(), fatherName: _father.text.trim(), address: _address.text.trim(), phone: _phone.text.trim(), commodity: _commodity, bagWeightKg: _num(_bagWeight), bagCount: _num(_bagCount).round(), extraKg: _num(_extra), rateMode: _rateMode, rateValue: _num(_rate), createdAt: DateTime.now());
        Navigator.push(context, MaterialPageRoute(builder: (_) => AccountDetailScreen(account: account, language: lang, alreadySaved: false)));
      }),
      const SizedBox(height: 30),
    ])),
  ));

  Widget _formSection(String title, List<Widget> children) => Container(margin: const EdgeInsets.only(bottom: 13), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: kPaper, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD8C49A)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [kGreen, kDeepGreen]), borderRadius: BorderRadius.circular(12)), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))), const SizedBox(height: 12), ...children]));
}

class CommodityPicker extends StatefulWidget {
  final String language;
  final String selected;
  const CommodityPicker({super.key, required this.language, required this.selected});
  @override
  State<CommodityPicker> createState() => _CommodityPickerState();
}

class _CommodityPickerState extends State<CommodityPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = commodities.where((e) => '${e.ur} ${e.en} ${e.hi} ${e.zh}'.toLowerCase().contains(query.toLowerCase())).toList();
                return InkWell(
                  onTap: () => Navigator.pop(context, c.key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFE3F0D4) : kPaper,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected ? kGreen : const Color(0xFFD8C49A),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 5),
                        Text(
                          commodityLabel(c.key, widget.language),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: kDeepGreen),
                        ),
                        if (selected) const Icon(Icons.check_circle, color: kGreen, size: 18),
                      ],
                    ),
                  ),
                );
  }
}

class _CalculationCard extends StatelessWidget {
  final String language;
  final double bagWeight, bagCount, bagTotal, extra, total, kgRate, maundRate, price;
  const _CalculationCard({required this.language, required this.bagWeight, required this.bagCount, required this.bagTotal, required this.extra, required this.total, required this.kgRate, required this.maundRate, required this.price});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFF7DF), borderRadius: BorderRadius.circular(18), border: Border.all(color: kGold, width: 1.6), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 4))]), child: Column(children: [const _SectionTitle(text: 'حساب کا خلاصہ'), const SizedBox(height: 8), _InfoRow(label: Txt.get('bag_count', language), value: money(bagCount)), _InfoRow(label: Txt.get('bag_weight', language), value: '${money(bagWeight)} kg'), _InfoRow(label: Txt.get('total_bag_weight', language), value: '${money(bagTotal)} kg'), _InfoRow(label: Txt.get('extra', language), value: '${money(extra)} kg'), _InfoRow(label: Txt.get('total_weight', language), value: '${money(total)} kg', highlight: true), _InfoRow(label: Txt.get('maund_breakdown', language), value: '${(total ~/ 40)} ${Txt.get('maund', language)}  ${money(total - (total ~/ 40) * 40)} kg'), const Divider(), _InfoRow(label: Txt.get('kg_rate', language), value: 'Rs ${money(kgRate)}'), _InfoRow(label: Txt.get('maund_rate', language), value: 'Rs ${money(maundRate)}'), _InfoRow(label: Txt.get('total_price', language), value: 'Rs ${money(price)}', highlight: true, gold: true)]));
}

class AccountDetailScreen extends StatefulWidget {
  final TradeAccount account;
  final String language;
  final bool alreadySaved;
  const AccountDetailScreen({super.key, required this.account, required this.language, required this.alreadySaved});
  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  bool _sms = false;
  bool _whatsapp = false;
  bool _saving = false;
  bool _saved = false;
  String get lang => widget.language;
  TradeAccount get a => widget.account;

  String _message() {
    final lines = [
      'واپاری - کھاتے کی تفصیل',
      'نام: ${a.name}',
      if (a.fatherName.isNotEmpty) 'ولدیت: ${a.fatherName}',
      if (a.address.isNotEmpty) 'پتہ: ${a.address}',
      if (a.phone.isNotEmpty) 'موبائل: ${a.phone}',
      'اجناس: ${commodityLabel(a.commodity, 'ur')}',
      'کل بوریاں: ${a.bagCount}',
      'فی بوری وزن: ${money(a.bagWeightKg)} کلو',
      'بوریوں کا کل وزن: ${money(a.totalBagWeight)} کلو',
      'اضافی وزن: ${money(a.extraKg)} کلو',
      'کل وزن: ${money(a.totalWeight)} کلو',
      'من: ${a.maunds} من ${money(a.remainingKg)} کلو',
      'فی کلو ریٹ: Rs ${money(a.kgRate)}',
      'فی من ریٹ: Rs ${money(a.maundRate)}',
      'کل قیمت: Rs ${money(a.totalPrice)}',
    ];
    return lines.join('\n');
  }

  Future<void> _saveAndSend() async {
    if (a.phone.trim().isEmpty && (_sms || _whatsapp)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Txt.get('select_phone', lang))));
      return;
    }
    setState(() => _saving = true);
    try {
      await LocalStore.saveAccount(a);
      setState(() { _saved = true; _saving = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Txt.get('saved', lang))));
      if (_sms || _whatsapp) {
        final msg = _message();
        final phone = a.phone.replaceAll(RegExp(r'[^0-9+]'), '');
        if (_sms) {
          final smsUri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': msg});
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        }
        if (_whatsapp) {
          if (_sms) await Future.delayed(const Duration(milliseconds: 650));
          var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.startsWith('0')) {
            digits = '92${digits.substring(1)}';
          } else if (digits.length == 10 && digits.startsWith('3')) {
            digits = '92$digits';
          }
          final url = Uri.https('wa.me', '/$digits', {'text': msg});
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(textDirection: Txt.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
    appBar: AppBar(title: Text(Txt.get('details', lang)), actions: [if (widget.alreadySaved) IconButton(onPressed: () async { await Clipboard.setData(ClipboardData(text: _message())); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }, icon: const Icon(Icons.copy_rounded))]),
    body: ListView(padding: const EdgeInsets.all(13), children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kPaper, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFD6C193)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 4))]), child: Row(children: [Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFFE8A7), Color(0xFFB47A17)]), border: Border.all(color: kGreen, width: 2)), child: const Icon(Icons.person_rounded, color: kDeepGreen, size: 36)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21)), if (a.fatherName.isNotEmpty) Text('${lang == 'ur' ? 'ولد: ' : 'Father: '}${a.fatherName}', style: const TextStyle(color: kGreen, fontWeight: FontWeight.w800)), if (a.phone.isNotEmpty) Text('☎  ${a.phone}', style: const TextStyle(fontWeight: FontWeight.w700)), if (a.address.isNotEmpty) Text('📍  ${a.address}', style: const TextStyle(fontSize: 12, color: Colors.black54))])), const Text('🌾', style: TextStyle(fontSize: 30))])),
      const SizedBox(height: 12),
      _detailSection(lang == 'ur' ? 'وزن کی تفصیل' : 'Weight details', [
        _InfoRow(label: Txt.get('commodity', lang), value: commodityLabel(a.commodity, lang)),
        _InfoRow(label: Txt.get('bag_count', lang), value: '${a.bagCount}'),
        _InfoRow(label: Txt.get('bag_weight', lang), value: '${money(a.bagWeightKg)} kg'),
        _InfoRow(label: Txt.get('total_bag_weight', lang), value: '${money(a.totalBagWeight)} kg'),
        _InfoRow(label: Txt.get('extra', lang), value: '${money(a.extraKg)} kg'),
        _InfoRow(label: Txt.get('total_weight', lang), value: '${money(a.totalWeight)} kg', highlight: true),
      ]),
      const SizedBox(height: 11),
      _detailSection(Txt.get('maund_breakdown', lang), [
        _InfoRow(label: lang == 'ur' ? 'کل من' : 'Complete maunds', value: '${a.maunds} ${Txt.get('maund', lang)}'),
        _InfoRow(label: Txt.get('remaining', lang), value: '${money(a.remainingKg)} kg'),
      ]),
      const SizedBox(height: 11),
      _detailSection(Txt.get('rate', lang), [
        _InfoRow(label: Txt.get('kg_rate', lang), value: 'Rs ${money(a.kgRate)}'),
        _InfoRow(label: Txt.get('maund_rate', lang), value: 'Rs ${money(a.maundRate)}'),
      ]),
      const SizedBox(height: 11),
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFE59B), Color(0xFFC58A16)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF96610C), width: 2), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]), child: Row(children: [const Icon(Icons.payments_rounded, color: kDeepGreen, size: 34), const SizedBox(width: 10), Expanded(child: Text(Txt.get('total_price', lang), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))), Text('Rs ${money(a.totalPrice)}', style: const TextStyle(color: kDeepGreen, fontWeight: FontWeight.w900, fontSize: 22))])),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: kPaper, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFD8C49A))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(Txt.get('send_optional', lang), style: const TextStyle(fontWeight: FontWeight.w800, color: kDeepGreen)), const SizedBox(height: 7), CheckboxListTile(contentPadding: EdgeInsets.zero, dense: true, value: _sms, onChanged: a.phone.isEmpty ? null : (v) => setState(() => _sms = v ?? false), title: Text(Txt.get('sms', lang)), secondary: const Icon(Icons.sms_rounded, color: Color(0xFF1477C9))), CheckboxListTile(contentPadding: EdgeInsets.zero, dense: true, value: _whatsapp, onChanged: a.phone.isEmpty ? null : (v) => setState(() => _whatsapp = v ?? false), title: Text(Txt.get('whatsapp', lang)), secondary: const Icon(Icons.chat_rounded, color: Color(0xFF179B55))), if (a.phone.isEmpty) Text(Txt.get('no_phone', lang), style: const TextStyle(color: Colors.redAccent, fontSize: 12))])),
      const SizedBox(height: 13),
      _GoldButton(icon: _saved || widget.alreadySaved ? Icons.check_circle_rounded : Icons.save_rounded, title: _saving ? '...' : (_saved || widget.alreadySaved ? (lang == 'ur' ? 'کھاتہ محفوظ ہے' : 'Account saved') : Txt.get('save_account', lang)), onTap: _saving ? null : _saveAndSend),
       if (widget.alreadySaved)
         Padding(
           padding: const EdgeInsets.only(top: 8),
           child: OutlinedButton.icon(
             onPressed: () async {
               final yes = await showDialog<bool>(
                 context: context,
                 builder: (_) => AlertDialog(
                   title: Text(Txt.get('delete', lang)),
                   content: Text(Txt.get('delete_confirm', lang)),
                   actions: [
                     TextButton(
                       onPressed: () => Navigator.pop(context, false),
                       child: Text(Txt.get('cancel', lang)),
                     ),
                     FilledButton(
                       onPressed: () => Navigator.pop(context, true),
                       child: Text(Txt.get('confirm', lang)),
                     ),
                   ],
                 ),
               );
               if (yes == true) {
                 await LocalStore.deleteAccount(a.id);
                 if (!mounted) return;
                 Navigator.pop(context);
               }
             },
             icon: const Icon(Icons.delete_outline),
             label: Text(Txt.get('delete', lang)),
             style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
           ),
         ),
      const SizedBox(height: 30),
    ]),
  ));

  Widget _detailSection(String title, List<Widget> rows) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kPaper, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFD8C49A)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))]), child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [kGreen, kDeepGreen]), borderRadius: BorderRadius.circular(10)), child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(height: 7), ...rows]));
}

class ReportsScreen extends StatelessWidget {
  final String language;
  const ReportsScreen({super.key, required this.language});
  @override
  Widget build(BuildContext context) => Directionality(textDirection: Txt.isRtl(language) ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(appBar: AppBar(title: Text(Txt.get('reports', language))), body: FutureBuilder<List<TradeAccount>>(future: LocalStore.loadAccounts(), builder: (context, snap) {
    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
    final list = snap.data!;
    final weight = list.fold<double>(0, (s, e) => s + e.totalWeight);
    final total = list.fold<double>(0, (s, e) => s + e.totalPrice);
    final byCommodity = <String, double>{};
    for (final a in list) { byCommodity[a.commodity] = (byCommodity[a.commodity] ?? 0) + a.totalWeight; }
    return ListView(padding: const EdgeInsets.all(14), children: [
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.25, crossAxisSpacing: 10, mainAxisSpacing: 10, children: [
        _ReportTile(icon: Icons.groups_rounded, label: Txt.get('total_accounts', language), value: '${list.length}'),
        _ReportTile(icon: Icons.scale_rounded, label: Txt.get('total_goods', language), value: '${money(weight)} kg'),
        _ReportTile(icon: Icons.payments_rounded, label: Txt.get('total_sales', language), value: 'Rs ${money(total)}'),
        _ReportTile(icon: Icons.account_balance_wallet_rounded, label: language == 'ur' ? 'کل من' : 'Total maunds', value: '${money(weight / 40)}'),
      ]),
      const SizedBox(height: 15), _SectionTitle(text: Txt.get('commodity_report', language)), const SizedBox(height: 8),
      ...byCommodity.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kPaper, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD8C49A))), child: Column(children: [Row(children: [Expanded(child: Text(commodityLabel(e.key, language), style: const TextStyle(fontWeight: FontWeight.w800))), Text('${money(e.value)} kg', style: const TextStyle(fontWeight: FontWeight.w900, color: kGreen))]), const SizedBox(height: 7), ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: weight <= 0 ? 0 : e.value / weight, minHeight: 9, backgroundColor: const Color(0xFFE7DEC9), color: kGreen))])))),
      if (list.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(25), child: Text(Txt.get('no_accounts', language)))),
    ]);
  }))); 
}

class _ReportTile extends StatelessWidget {
  final IconData icon; final String label, value;
  const _ReportTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF2D0), Color(0xFFECCB81)]), borderRadius: BorderRadius.circular(17), border: Border.all(color: kGold), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: kGreen, size: 32), Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), Text(value, style: const TextStyle(fontSize: 18, color: kDeepGreen, fontWeight: FontWeight.w900))]));
}

class SettingsScreen extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  const SettingsScreen({super.key, required this.language, required this.onLanguageChanged});
  @override
  Widget build(BuildContext context) => Directionality(textDirection: Txt.isRtl(language) ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(appBar: AppBar(title: Text(Txt.get('settings', language))), body: ListView(padding: const EdgeInsets.all(14), children: [
    _settingTile(context, Icons.language_rounded, Txt.get('language', language), language.toUpperCase(), () => showModalBottomSheet(context: context, backgroundColor: kCream, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: Column(mainAxisSize: MainAxisSize.min, children: [for (final x in [('ur', 'اردو'), ('hi', 'हिन्दी'), ('en', 'English'), ('zh', '中文')]) ListTile(leading: const Icon(Icons.translate_rounded, color: kGreen), title: Text(x.$2), trailing: language == x.$1 ? const Icon(Icons.check_circle, color: kGreen) : null, onTap: () { Navigator.pop(context); onLanguageChanged(x.$1); })]))))),
    _settingTile(context, Icons.cloud_download_rounded, Txt.get('backup', language), 'JSON', () async { final raw = await LocalStore.exportJson(); await Clipboard.setData(ClipboardData(text: raw)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Txt.get('backup_done', language)))); }),
    _settingTile(context, Icons.phone_android_rounded, Txt.get('saved_on_device', language), 'Offline', () {}),
    _settingTile(context, Icons.info_outline_rounded, language == 'ur' ? 'ایپ کے بارے میں' : 'About Wapari', 'Version 1.0.0', () => showAboutDialog(context: context, applicationName: 'Wapari', applicationVersion: '1.0.0', applicationLegalese: 'Offline-first commodity account book.')),
  ])));

  Widget _settingTile(BuildContext context, IconData icon, String title, String trailing, VoidCallback onTap) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Material(elevation: 3, borderRadius: BorderRadius.circular(15), child: ListTile(onTap: onTap, tileColor: kPaper, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFFD8C49A))), leading: Icon(icon, color: kGreen, size: 28), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(trailing, style: const TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(width: 5), const Icon(Icons.chevron_right_rounded)]))));
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(gradient: const LinearGradient(colors: [kGreen, kDeepGreen]), borderRadius: BorderRadius.circular(11), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)));
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool highlight, gold;
  const _InfoRow({required this.label, required this.value, this.highlight = false, this.gold = false});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), decoration: BoxDecoration(color: gold ? const Color(0xFFFFE7A2) : highlight ? const Color(0xFFE5F0D4) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontWeight: highlight ? FontWeight.w900 : FontWeight.w600, fontSize: 13))), Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: highlight ? kDeepGreen : kInk, fontSize: highlight ? 15 : 13))]));
}

class _GoldButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _GoldButton({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(elevation: 7, borderRadius: BorderRadius.circular(16), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0A783D), kDeepGreen]), borderRadius: BorderRadius.circular(16), border: Border.all(color: kGold, width: 2), boxShadow: const [BoxShadow(color: Colors.white24, blurRadius: 4, offset: Offset(-2, -2))]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 25), const SizedBox(width: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))]))));
}
