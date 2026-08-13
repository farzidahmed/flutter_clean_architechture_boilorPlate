# Flutter Clean Architecture Boilerplate — Riverpod + Dio

Reusable boilerplate — যেকোনো নতুন প্রজেক্টে `lib/core/` আর pattern-টা
কপি করে নতুন feature বসিয়ে দিলেই কাজ চলবে। এই ভার্সনে auth (login)
ও profile feature-এর model দুটোই real backend response অনুযায়ী বসানো।

## Layer flow

```
Presentation (Riverpod Notifier / Widget)
      ↓ calls
Domain (UseCase → Repository interface → Entity)
      ↓ implemented by
Data (Repository impl → DataSource → Model.toEntity() → ApiService → Dio)
```

## এই boilerplate-এ কী কী আছে

- **core/network/api_service.dart** — common reusable `get/post/put/delete`।
  এটা response-এর raw JSON body হুবহু parser-কে পাঠায় (কোনো auto
  "data"-unwrap করে না), কারণ backend-এর প্রতিটা endpoint-এর shape
  ভিন্ন হতে পারে (যেমন: login-এ token top-level-এ, profile-এ সব data-এর
  ভেতরে) — সেটা handle করার দায়িত্ব প্রতিটা Model-এর নিজের।

- **features/auth** — POST-এর উদাহরণ (login)।
  - `login_response_model.dart` — backend-এর exact JSON shape
    (status/message/code/expires_in/token/data) মেনে বানানো raw model,
    সাথে `toEntity()` method যেটা top-level token + nested data মিলিয়ে
    একটা flat `UserEntity` বানায়।
  - Presentation-এ `AsyncNotifier` — action-trigger pattern, `build()`
    কিছু করে না, `login()` call হলে state বদলায়।

- **features/profile** — GET-এর উদাহরণ।
  - `profile_response_model.dart` — তিন স্তরের nested model
    (ProfileResponseModel → ProfileDataModel → ProfileUserModel),
    ঠিক backend response-এর গঠন অনুযায়ী। `toEntity()` দিয়ে
    domain-এর `ProfileEntity` (stats + nested `ProfileUserEntity`) বানায়।
  - Presentation-এ `AsyncNotifier.build()` নিজে থেকেই fetch করে —
    page open হওয়া মাত্র data লোড শুরু হয়। `refresh()` pull-to-refresh-এর জন্য।

## Model vs Entity — কেন দুটো আলাদা ক্লাস?

- **Model** (data layer) — backend JSON-এর exact প্রতিরূপ, key নাম
  ভুল/snake_case হ্যান্ডেল করার জায়গা।
- **Entity** (domain layer) — app-এর ভেতরে ব্যবহারযোগ্য clean object,
  API shape সম্পর্কে কিছুই জানে না।
- প্রতিটা Model-এ একটা `toEntity()` method থাকে যেটা Repository layer
  থেকে call হয় — এই এক জায়গাতেই conversion ঘটে।

## নতুন feature যোগ করতে যা করবেন

1. আপনার backend response থেকে quicktype/JSON-to-dart দিয়ে raw model
   বানান (এই boilerplate-এর `login_response_model.dart` বা
   `profile_response_model.dart`-এর মতো)
2. `domain/entities/` — সেই raw model থেকে একটা clean Entity বানান
3. Model-এ একটা `toEntity()` method যোগ করুন
4. `domain/repositories/` — abstract interface
5. `data/datasources/` — `apiService.get/post(...)` কল করে raw Model রিটার্ন করুন
6. `data/repositories/` — Exception → Failure map + Model → Entity convert
7. `domain/usecases/` — Repository call করা single action
8. `presentation/providers/` — DI wiring + AsyncNotifier
9. `presentation/pages/` — UI, `.when()` দিয়ে state handle

`api_service.dart`, `dio_client.dart`, `failures.dart`, `usecase.dart` —
এই core ফাইলগুলো প্রায় কখনোই বদলাতে হবে না।

## Run করতে

```bash
flutter pub get
flutter run
```

`lib/core/constants/api_endpoints.dart`-এ `baseUrl` আপনার backend
অনুযায়ী বদলে নিন।
