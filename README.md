# AlcreoVault 💰
**Your Personal Financial Operating System**
نظامك المالي الشخصي | Votre Système Financier Personnel

---

## ✅ ما تحتاجه فقط
- حساب **GitHub** مجاني
- حساب **Supabase** مجاني
- متصفح ويب — لا يوجد تثبيت

---

## 🚀 طريقة النشر (15 دقيقة فقط)

---

### الخطوة 1 — إعداد Supabase

1. اذهب إلى **https://supabase.com** وسجّل دخول بـ GitHub
2. اضغط **New Project**:
   - **Name**: `alcreovault`
   - **Database Password**: اختر كلمة سر قوية واحفظها
   - **Region**: اختر الأقرب لك
3. انتظر دقيقتين حتى ينتهي الإعداد

4. اذهب إلى **SQL Editor** من القائمة اليسار
5. اضغط **New query**
6. افتح ملف `supabase_schema.sql` وانسخ كل محتواه
7. الصقه في المحرر واضغط **Run** ← يجب أن تظهر رسالة "Success"

8. اذهب إلى **Project Settings → API**:
   - انسخ **Project URL** (شيء مثل: `https://abcxyz.supabase.co`)
   - انسخ **anon public** key (السلسلة الطويلة تبدأ بـ `eyJ...`)

9. اذهب إلى **Authentication → Email** وتأكد أن:
   - **Enable Email Signup** = ✅ مفعّل
   - **Confirm email** = يمكن إيقافه للاختبار السريع

---

### الخطوة 2 — إضافة مفاتيح Supabase

افتح ملف **`index.html`** وابحث عن هذا السطر (حوالي السطر 370):

```javascript
const SUPABASE_URL      = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

استبدله بمفاتيحك:

```javascript
const SUPABASE_URL      = 'https://abcxyz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

احفظ الملف.

---

### الخطوة 3 — رفع على GitHub

1. اذهب إلى **https://github.com** وسجّل دخول
2. اضغط **+** ← **New repository**:
   - **Repository name**: `alcreovault`
   - اختر **Public**
   - لا تضع ✅ على أي خيار آخر
   - اضغط **Create repository**

3. في صفحة المستودع الجديد، اضغط **uploading an existing file**
4. ارفع الملفات الثلاثة:
   - `index.html`
   - `manifest.json`
   - `sw.js`
5. اضغط **Commit changes**

---

### الخطوة 4 — تفعيل GitHub Pages

1. في المستودع اضغط **Settings** (من فوق)
2. من القائمة اليسار اختر **Pages**
3. تحت **Branch** اختر **main** ← **/ (root)**
4. اضغط **Save**
5. انتظر دقيقة واحدة
6. ستظهر رسالة: **"Your site is published at https://اسمك.github.io/alcreovault"**

---

### ✅ انتهى!

افتح الرابط من أي جهاز:
```
https://USERNAME.github.io/alcreovault
```

- 📱 **الهاتف**: افتح الرابط في Chrome/Safari ← اضغط "إضافة إلى الشاشة الرئيسية"
- 💻 **الكمبيوتر**: افتح الرابط مباشرة في المتصفح
- 🔄 **نفس الحساب**: سجّل دخول بنفس الإيميل من أي جهاز وستجد نفس البيانات

---

## 📱 تثبيت التطبيق على الهاتف (PWA)

**Android (Chrome):**
1. افتح الرابط في Chrome
2. اضغط القائمة (⋮) ← **Add to Home screen**
3. اضغط **Add** ← يظهر أيقونة على الشاشة الرئيسية

**iPhone (Safari):**
1. افتح الرابط في Safari
2. اضغط زر المشاركة (□↑)
3. اختر **Add to Home Screen**
4. اضغط **Add**

---

## 🔒 الأمان وعزل البيانات

كل مستخدم له بياناته الخاصة فقط:
- يسجّل بإيميل + كلمة سر
- Supabase **Row Level Security** يمنع أي مستخدم من رؤية بيانات مستخدم آخر
- الجلسة محفوظة في المتصفح — لا تحتاج لتسجيل دخول في كل مرة

---

## 🌐 الميزات

| الميزة | الوصف |
|--------|-------|
| تسجيل حسابات | كل مستخدم له حساب منفصل |
| مزامنة | نفس البيانات من أي جهاز |
| ثلاث لغات | عربي / فرنسي / إنجليزي + RTL |
| وضع داكن/فاتح | محفوظ تلقائياً |
| Dashboard | رصيد، دخل، مصاريف بالشهر |
| المعاملات | إضافة، تعديل، حذف |
| التقارير | رسوم بيانية، تحليل فئات |
| التذكيرات | تكرار يومي/أسبوعي/شهري |
| الإعدادات | فئات، حساب، لغة، مظهر |
| PWA | يعمل كتطبيق على الهاتف |
| Offline | يعمل بدون إنترنت (للقراءة) |

---

## 🗂️ هيكل الملفات

```
alcreovault/
├── index.html          ← التطبيق كاملاً (ملف واحد)
├── manifest.json       ← إعدادات PWA
├── sw.js               ← Service Worker (offline)
├── supabase_schema.sql ← قاعدة البيانات
└── README.md
```

---

## 🆙 تحديث التطبيق

عند تعديل `index.html`:
1. ارفعه على GitHub (نفس الخطوة 3)
2. GitHub Pages يتحدث تلقائياً خلال دقيقة

---

*AlcreoVault © 2025 — Touati Billal | Algeria*
*alcreotico@gmail.com | WhatsApp: +213 660 065 059*
