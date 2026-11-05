# واپاری (Wapari) — مکمل سورس کوڈ

واپاری اجناس اور غلہ کے تاجروں کے لیے آف لائن اکاؤنٹ بک ایپ ہے۔ بنیادی ایپ Flutter اور Dart میں ہے۔ اکاؤنٹس موبائل کے مقامی اسٹوریج میں محفوظ ہوتے ہیں۔ SMS اور WhatsApp کے لیے ایپ صرف تیار شدہ پیغام کھولتی ہے؛ صارف خود آخری Send بٹن دبا کر پیغام بھیجتا ہے۔

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

## ویب پری ویو (صرف الگ UI حوالہ)

`web_preview/` میں ایک الگ HTML/CSS/JavaScript پری ویو موجود ہے۔ یہ GitHub Actions کے Android build کا حصہ نہیں ہے اور اس workflow میں ویب build نہیں چلتا۔

## Android Package ID

ایپ کا Android application ID / package name: `com.awasigogera.wapari`۔

## Android APK بنانا

Flutter SDK انسٹال ہونے کے بعد پروجیکٹ فولڈر میں:

```bash
flutter create --project-name wapari --platforms=android --org com.awasigogera /tmp/wapari_scaffold
cp -R /tmp/wapari_scaffold/android ./android
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

## GitHub Actions سے APK ZIP حاصل کرنا

`.github/workflows/build.yml` صرف Android کا release APK بناتا ہے، پھر اسی APK کو `wapari-apk.zip` میں پیک کرکے GitHub Actions کے **Artifacts** میں `wapari-apk` کے نام سے محفوظ کرتا ہے۔

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Download ZIP: `dist/wapari-apk.zip` (Actions artifact میں)

اس workflow میں **AAB build نہیں ہوتا** اور **Flutter Web build نہیں ہوتا**۔ Artifact ZIP کے اندر صرف APK فائل ہوتی ہے۔

## ڈیٹا اور بیک اپ

Flutter ایپ `shared_preferences` کے ذریعے ہر ڈیوائس کے مقامی اسٹوریج میں JSON کھاتے محفوظ کرتی ہے۔ سیٹنگز میں JSON بیک اپ کلپ بورڈ پر کاپی کیا جا سکتا ہے۔ یہ ورژن کلاؤڈ سنک نہیں کرتا؛ ایپ حذف کرنے یا ڈیوائس تبدیل کرنے سے پہلے بیک اپ محفوظ کر لیں۔

## اہم حساب

`کل وزن = (فی بوری وزن × بوریوں کی تعداد) + اضافی کلو`

`کل من = کل وزن ÷ 40` (پورے من)

`باقی کلو = کل وزن − (پورے من × 40)`

`فی کلو ریٹ = فی من ریٹ ÷ 40` (جب ریٹ فی من دیا ہو)

`کل قیمت = کل وزن × فی کلو ریٹ`

## Build verification

اصل Flutter build اور tests GitHub Actions پر چلتے ہیں۔ کامیابی کی تصدیق صرف اسی وقت ہوگی جب Actions run کامیابی سے مکمل ہو اور `wapari-apk` artifact دستیاب ہو۔
