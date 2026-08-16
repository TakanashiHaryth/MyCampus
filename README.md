# My Campus — GitHub README

<div align="center">

<img src="https://readme-typing-svg.herokuapp.com?font=Orbitron&size=30&duration=3500&pause=900&color=00BFFF&center=true&vCenter=true&width=720&lines=My+Campus+v2.0;Student+Productivity+Reimagined;Built+with+Flutter+and+Firebase" alt="My Campus"/>

# 🎓 My Campus

### 📱 Student Productivity · 🤝 Collaboration · ⚡ Realtime Sync

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Android-7.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/Windows-Supported-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Windows"/>
</p>

<p>
  <a href="RELEASE_NOTES.md">
    <img src="https://img.shields.io/badge/Release-v2.0.0-7E22CE?style=flat-square" alt="Release"/>
  </a>
  <img src="https://img.shields.io/badge/Status-Active_Development-22C55E?style=flat-square" alt="Development Status"/>
</p>

**Current Release:** `v2.0.0` — [View Release Notes](RELEASE_NOTES.md)

</div>

---

## 🌌 About My Campus

**My Campus** is a student productivity and collaboration application designed to bring important campus activities into one place.

Version `2.0` is a major rewrite of the original native Kotlin application using **Flutter**, with **Firebase** providing authentication and realtime data synchronization.

```text
╭────────────────────────────────────────╮
│           MY CAMPUS SYSTEM             │
├────────────────────────────────────────┤
│  👤 Student Profiles                   │
│  🤝 Friend System                      │
│  📚 Classes & Assignments              │
│  📅 Realtime Schedules                 │
│  📢 Notices & Notifications            │
│  🔥 Firebase Realtime Backend          │
╰────────────────────────────────────────╯
```

---

## ✨ Main Features

| Area          | Features                                                             |
| ------------- | -------------------------------------------------------------------- |
| 🔐 Account    | Registration, sign-in, sign-out, password reset and persistent login |
| 👤 Profile    | Private account data, searchable public profile and profile editing  |
| 🤝 Friends    | Search, request, accept, reject and remove friendships               |
| 📊 Dashboard  | Realtime overview of schedules, notices and friend count             |
| 🎨 Experience | Responsive navigation, light/dark/system themes and useful UI states |
| 🛡️ Security  | Firebase UID identity and separated public/private Firestore data    |

Friendships use a scalable **many-to-many model**, allowing each user to have multiple friends without storing a single `friendUid` field inside the profile.

---

## 🚦 Feature Status

| Feature             | Status              |
| ------------------- | ------------------- |
| Authentication      | ✅ Available         |
| Profile             | ✅ Available         |
| Friends             | ✅ Available         |
| Dashboard           | ✅ Available         |
| Settings            | ✅ Available         |
| Classes             | 🚧 In Development   |
| Schedule            | 🚧 In Development   |
| Assignments         | 🚧 In Development   |
| Notices             | 🚧 In Development   |
| Notifications / FCM | 🧪 Foundation Ready |
| Cloud Functions     | ⏳ Planned           |

---

## 🖥️ Supported Platforms

| Platform     | Status                     |
| ------------ | -------------------------- |
| Android 7.0+ | ✅ Primary Target           |
| Windows      | ✅ Development Support      |
| Web          | 🧪 Secondary Target        |
| iOS / macOS  | ⚙️ Architecture Ready      |
| Linux        | ⚠️ Firebase Not Configured |

Android is currently the primary release target.

---

## 🛠️ Technology Stack

<div align="center">

<img src="https://skillicons.dev/icons?i=flutter,dart,firebase,androidstudio,git,github&theme=dark" alt="My Campus Technology Stack"/>

</div>

| Technology               | Purpose                              |
| ------------------------ | ------------------------------------ |
| Flutter                  | Cross-platform application framework |
| Dart                     | Primary programming language         |
| Firebase Auth            | User authentication                  |
| Cloud Firestore          | Realtime application data            |
| Firebase Cloud Messaging | Future push notifications            |
| Android Studio           | Android development and debugging    |
| Git / GitHub             | Version control and collaboration    |

---

## 🧩 Architecture

Firebase access is kept behind repositories and services.

UI widgets should not directly query Firestore.

```text
lib/
├── core/
│   ├── repositories/
│   ├── services/
│   └── models/
│
├── authenticated_shell.dart
├── app_theme.dart
├── shared_widgets.dart
├── login_screen.dart
└── main.dart
```

### Firestore Structure

```text
users/{uid}
publicProfiles/{uid}

friendships/{lowerUid}_{higherUid}

schedules/{scheduleId}
notices/{noticeId}

users/{uid}/devices/{deviceId}
```

The Firebase UID remains the primary identity throughout the application.

---

## 🚀 Getting Started

### Requirements

* Flutter SDK
* Android Studio or VS Code
* Firebase CLI
* FlutterFire CLI
* Android emulator or physical device

Clone the repository:

```bash
git clone https://github.com/TakanashiHaryth/MyCampus.git
cd MyCampus
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

If you fork My Campus and want to use your own Firebase backend:

```bash
flutterfire configure
```

---

## 🧪 Development Checks

Before committing or releasing changes:

```bash
flutter analyze
flutter test
```

Both commands should pass before a production release.

---

## 🔐 Firebase & Security

My Campus follows several core security principles:

* Firebase UID is the primary account identity.
* Passwords are handled exclusively by Firebase Authentication.
* Passwords are never stored in Firestore.
* Private profile data is stored under `users/{uid}`.
* Searchable profile information is stored under `publicProfiles/{uid}`.
* Friendship IDs use sorted UIDs to prevent duplicate relationships.
* FCM device tokens belong under private user data.
* Push notifications must be sent through trusted server-side code.

Never commit:

```text
❌ Service account credentials
❌ Private keystores
❌ API secrets
❌ .env files
❌ Production credentials
```

---

## 🗺️ Roadmap

* [x] Firebase Authentication
* [x] Student Profile System
* [x] Friend System
* [x] Realtime Dashboard
* [x] Theme and Settings
* [ ] Complete Class Management
* [ ] Complete Schedule Sharing
* [ ] Assignment Management
* [ ] Notice System
* [ ] Notification Center
* [ ] Firebase Cloud Messaging Delivery
* [ ] Cloud Functions
* [ ] Multi-user Integration Testing

---

## 👨‍💻 Developer

<div align="center">

### Built by [TakanashiHaryth](https://github.com/TakanashiHaryth)

> **“Life is like a GitHub repository. No progress happens until you make a commit.”**

<br>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,20,24&height=110&section=footer" width="100%" alt="Footer"/>

### 🎓 Learn · Connect · Organize · Improve

⭐ Star the repository if you find **My Campus** useful.

</div>
