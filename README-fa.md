# تصویر ۳x-UI به‌همراه Nginx برای Runsite

این پروژه تصویر رسمی ۳x-UI را با Nginx و Supervisor ترکیب می‌کند تا پنل ۳x-UI و ورودی‌های Xray در یک Web Service اجرا شوند.

> این تصویر رسمی سازندهٔ ۳x-UI نیست؛ از تصویر `ghcr.io/mhsanaei/3x-ui:v3.8.5` استفاده می‌کند.

## فایل‌های پروژه

- `Dockerfile` — تصویر ۳x-UI را با Nginx و Supervisor ترکیب می‌کند.
- `nginx.conf.template` — پنل، subscription و مسیر WebSocket را به سرویس داخلی مربوط می‌فرستد.
- `supervisord.conf` — اجرای هم‌زمان ۳x-UI و Nginx را مدیریت می‌کند.
- `start-with-nginx.sh` — پورت عمومی Runsite را از متغیر `PORT` می‌گیرد و Nginx را راه‌اندازی می‌کند.

## استقرار روی Runsite

1. در Runsite یک **Web Service** جدید بساز و Repository گیت‌هاب را به آن متصل کن.
2. Branch پروژه را روی `main` بگذار. Runsite با وجود `Dockerfile` تصویر را از همین فایل می‌سازد.
3. در بخش **Settings → Build & Deploy** پورت سرویس را روی `8080` بگذار. Nginx داخل کانتینر روی `PORT` گوش می‌دهد و مقدار پیش‌فرض این پروژه `8080` است.
4. یک دامنهٔ Runsite بساز و بعد از سالم‌شدن سرویس، از همان دامنه برای پنل و لینک‌های اتصال استفاده کن.
5. در **Settings → Scaling** مقدار حداقل Instance را `1` بگذار و **Sleep on idle** را خاموش کن. Sleep برای سرویس‌های Xray/WebSocket مناسب نیست.
6. در بخش **Persistent Disk** یک دیسک بساز و آن را دقیقاً روی مسیر زیر Mount کن:

```text
/etc/x-ui
```

دیتابیس و تنظیمات ۳x-UI در همین مسیر قرار می‌گیرند. بدون این دیسک، بعد از Restart یا Redeploy پنل به حالت اولیه برمی‌گردد و کاربران/ورودی‌ها از بین می‌روند.

7. در بخش **Health checks** مسیر زیر را به‌عنوان HTTP health check قرار بده:

```text
/health
```

8. پس از Deploy، ابتدا این آدرس را باز کن:

```text
https://YOUR-SERVICE.runsite.app/health
```

باید پاسخ `ok` بگیری. سپس ریشهٔ دامنه را برای ورود به پنل باز کن.

## تنظیم اولیهٔ پنل

بعد از ورود به ۳x-UI:

- رمز مدیر را فوراً عوض کن.
- مسیر Web Base Path پنل را از مقدار پیش‌فرض تغییر بده.
- برای ورودی VLESS یک مسیر غیرقابل‌حدس انتخاب کن.
- مسیر انتخابی WebSocket را در فایل `nginx.conf.template` نیز همان مقدار قرار بده و دوباره Deploy کن.

مسیر پیش‌فرض این پروژه:

```text
/ws-k7p9
```

## ساخت ورودی VLESS + WebSocket

برای ورودی آزمایشی در پنل:

| گزینه | مقدار |
|---|---|
| نوع اتصال | VLESS |
| پورت داخلی ورودی | `10001` |
| نوع انتقال | WebSocket (WS) |
| مسیر | `/ws-k7p9` |
| امنیت TLS داخل Xray | خاموش / None |

پورت `10001` و مسیر `/ws-k7p9` باید با `nginx.conf.template` یکسان باشند. TLS در لبهٔ Runsite و روی دامنهٔ عمومی خاتمه پیدا می‌کند؛ بنابراین در ورودی داخلی Xray، TLS را روشن نکن.

## مشخصات کلاینت

در لینک VLESS این مقادیر را استفاده کن:

- Address: دامنهٔ Runsite
- Port: `443`
- Network: `ws`
- Path: `/ws-k7p9`
- TLS: روشن
- SNI: همان دامنهٔ Runsite
- UUID: شناسه‌ای که پنل ساخته است

نمونهٔ ساختار لینک:

```text
vless://UUID@YOUR-SERVICE.runsite.app:443?encryption=none&security=tls&sni=YOUR-SERVICE.runsite.app&type=ws&host=YOUR-SERVICE.runsite.app&path=%2Fws-k7p9#Runsite-XUI
```

## محدودیت‌ها و نکات مهم

- این تنظیم برای VLESS/VMess و سایر ورودی‌های HTTP/WebSocket است.
- برای VLESS TCP+REALITY روی دامنهٔ عمومی HTTPS مناسب نیست؛ TLS توسط لبهٔ Runsite خاتمه پیدا می‌کند.
- پورت‌های Xray به‌صورت عمومی Publish نمی‌شوند؛ فقط ترافیکی که از مسیر Nginx عبور می‌کند قابل دسترسی است.
- فایل‌سیستم عادی کانتینر Runsite موقتی است. فقط `/etc/x-ui` را روی Persistent Disk نگه دار.
- Autoscaling را برای این پنل روی یک Instance نگه دار؛ چند Instance می‌تواند باعث ناسازگاری Session و تنظیمات پنل شود.
- دامنهٔ سرویس را بعد از ساخت لینک‌ها تغییر نده، چون Address و SNI لینک‌های قبلی عوض می‌شود.
- این پروژه برای آزمایش و استفاده‌ای است که با قوانین Runsite و قوانین محل استفاده سازگار باشد.
