# واپاری (Wapari) — مکمل سورس کوڈ

واپاری اجناس اور غلہ کے تاجروں کے لیے آف لائن اکاؤنٹ بک ایپ ہے۔ بنیادی ایپ Flutter اور Dart میں ہے۔ اکاؤنٹس موبائل/براؤزر کے مقامی اسٹوریج میں محفوظ ہوتے ہیں۔ SMS اور WhatsApp کے لیے ایپ صرف تیار شدہ پیغام کھولتی ہے؛ صارف خود آخری Send بٹن دبا کر پیغام بھیجتا ہے۔

## شامل فیچرز

- پہلی مرتبہ اردو، ہندی، انگریزی یا چینی زبان کا انتخاب
- اینیمیٹڈ آغاز: ہینڈ شیک اور ہلکی حرکت والے اناج کے تھیلے
- نیا کھاتہ: نام، ولدیت، اختیاری پتہ اور موبائل، اجناس کا انتخاب
- فی بوری وزن، بوریوں کی تعداد اور اضافی کلو
- فی کلو یا فی من ریٹ؛ ایک من = 40 کلو
- خودکار کل وزن، مکمل من، باقی کلو، فی کلو/فی من مساوی ریٹ اور کل قیمت
- کھاتوں کی مقامی محفوظ فہرست؛ نام، ولدیت اور مختصر پتہ ساتھ دکھتے ہیں
- کھاتے کی مکمل تفصیل، اختیاری SMS/WhatsApp چیک باکس اور Save
- رپورٹس، اجناس وار وزن، JSON بیک اپ کاپی

## ویب پری ویو

فوری UI ٹیسٹ کے لیے `web_preview/index.html` کھولیں۔ یہ الگ HTML/CSS/JavaScript پری ویو ہے اور براؤزر کے `localStorage` میں کھاتے محفوظ کرتا ہے۔ موبائل پر اسے کھولنے سے SMS/WhatsApp ڈیپ لنکس دستیاب ڈیوائس کے مطابق کام کر سکتے ہیں۔

لوکل سرور چلانے کے لیے:

```bash
cd web_preview
python3 -m http.server 8080
```

پھر براؤزر میں `http://localhost:8080` کھولیں۔

## Flutter پروجیکٹ چلانا

Flutter SDK انسٹال ہونے کے بعد پروجیکٹ فولڈر میں:

```bash
flutter create --project-name wapari --platforms=android,web --org com.wapari.app /tmp/wapari_scaffold
cp -R /tmp/wapari_scaffold/android ./android
cp -R /tmp/wapari_scaffold/web ./web
flutter pub get
flutter run -d chrome
```

## ریلیز بنانا

```bash
flutter build web --release
flutter build apk --release
flutter build appbundle --release
```

ویب آؤٹ پٹ `build/web/`، APK `build/app/outputs/flutter-apk/app-release.apk` اور AAB `build/app/outputs/bundle/release/app-release.aab` میں ملیں گے۔

## Termux / GitHub Actions

اس سورس میں `.github/workflows/build.yml` شامل ہے۔ GitHub پر `main` برانچ میں push یا Actions کو دستی طور پر چلانے سے CI پلیٹ فارم فولڈرز بنائے گا، `flutter analyze`، ٹیسٹ، Web، APK اور AAB build چلائے گا۔

## ڈیٹا اور بیک اپ

Flutter ایپ `shared_preferences` کے ذریعے ہر ڈیوائس کے مقامی اسٹوریج میں JSON کھاتے محفوظ کرتی ہے۔ سیٹنگز میں JSON بیک اپ کلپ بورڈ پر کاپی کیا جا سکتا ہے۔ یہ ورژن کلاؤڈ سنک نہیں کرتا؛ ایپ حذف کرنے یا ڈیوائس تبدیل کرنے سے پہلے بیک اپ محفوظ کر لیں۔

## اہم حساب

`کل وزن = (فی بوری وزن × بوریوں کی تعداد) + اضافی کلو`

`کل من = کل وزن ÷ 40` (پورے من)

`باقی کلو = کل وزن − (پورے من × 40)`

`فی کلو ریٹ = فی من ریٹ ÷ 40` (جب ریٹ فی من دیا ہو)

`کل قیمت = کل وزن × فی کلو ریٹ`

## Build verification

اس سورس پیکج میں Flutter SDK موجود نہیں تھا، اس لیے اس ماحول میں اصل Flutter Web/APK/AAB build چلانا ممکن نہیں ہوا۔ JavaScript ویب پری ویو کی syntax چیک کی گئی ہے؛ اصل Flutter build اور tests کو Flutter SDK یا شامل GitHub Actions پر چلانا ضروری ہے۔
