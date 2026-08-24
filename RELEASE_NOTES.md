# My Campus v2.0.0 — Release Notes

<div align="center">

<img src="https://readme-typing-svg.herokuapp.com?font=Orbitron&size=30&duration=3500&pause=900&color=00BFFF&center=true&vCenter=true&width=700&lines=My+Campus+v2.0.0;Major+Flutter+Rebuild;Powered+by+Firebase" alt="My Campus v2.0.0"/>

# 🎓 My Campus v2.0.0

### 🚀 Major Rewrite · 🔥 Firebase Migration · 📱 Cross-Platform

![Release](https://img.shields.io/badge/Release-v2.0.0-7E22CE?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge\&logo=firebase\&logoColor=black)

**Release Date:** 16 August 2026
**Last Revised:** 24 August 2026
**Release Type:** Major Update
**Previous:** `v1.0.0` → **Current:** `v2.0.0`
**Build Revision:** `2.0.0+2`

</div>

---

## 🔁 Revision 2 — 24 August 2026

### Added

* New MyCampus launcher icon for Android, Windows and Web
* Apache License 2.0
* Responsive profile view/edit coverage at all required screen sizes

### Improved

* Rebuilt the Profile page with clearer identity, academic and account sections
* Improved responsive profile layouts for phone, tablet and desktop
* Added consistent readable content width through the shared design system
* Improved friend-request creation and user-friendly Firestore error handling
* Cleaned generated build, Graphify and debug artifacts from the workspace

> Profile photo controls are now presented in the UI, but photo upload remains
> unavailable until Firebase Storage is explicitly approved and configured.

---

## 🌌 What's New

My Campus `2.0.0` is a major rebuild of the original Android application.

The project has moved from **native Kotlin** to **Flutter**, allowing one codebase to support Android, Windows and Web while preparing for future Apple platform support.

```text
Kotlin + SQLite
      │
      ▼
Flutter + Firebase
      │
      ├── Android
      ├── Windows
      ├── Web
      └── Future iOS / macOS
```

---

## ✨ Highlights

* 🔄 Migrated from Kotlin to Flutter
* 🔥 Replaced SQLite authentication with Firebase Authentication
* ⚡ Added realtime Cloud Firestore architecture
* 🎨 Added light, dark and system themes
* 📱 Added responsive mobile, tablet and desktop layouts
* 🆔 Changed Android application ID to `com.mycampus.harina`
* 🔐 Firebase UID is now the primary user identity

---

## 🧩 New & Rebuilt Pages

* Sign In
* Create Account
* Password Reset
* Dashboard
* Profile View & Edit
* Friends
* Friend Requests
* Settings
* Responsive Sidebar / Drawer
* Classes foundation
* Schedule foundation
* Assignments foundation
* Notices foundation
* Notifications foundation

> Foundation pages provide navigation and UI structure while their complete realtime workflows remain under development.

---

## 🔥 Firebase Changes

* Firebase initialized through `firebase_options.dart`
* Email/password authentication
* Password reset and persistent sessions
* Realtime Firestore streams
* Private profiles under `users/{uid}`
* Searchable profiles under `publicProfiles/{uid}`
* Canonical many-to-many friendship documents
* Firestore security rules and indexes included
* Firebase Messaging dependency prepared
* Cloud Function notification delivery planned for a future release

---

## 🎨 Design & Performance

* Responsive mobile drawer
* Tablet collapsed sidebar
* Desktop expandable sidebar
* Centralized design tokens from `theme.md`
* Bundled Sora and Inter fonts
* Professional responsive Profile page
* Branded launcher icon across Android, Windows and Web
* Loading, empty and friendly error states
* Faster startup experience
* SQLite removed from the active runtime

---

## 🖥️ Platform Support

| Platform     | Status                     |
| ------------ | -------------------------- |
| Android 7.0+ | ✅ Primary Target           |
| Windows      | ✅ Development Supported    |
| Web          | 🧪 Secondary Target        |
| iOS / macOS  | ⚙️ Architecture Ready      |
| Linux        | ⚠️ Firebase Not Configured |

Android 14 has been used for current Android testing.

---

## 🔄 Migration Notes

Users from `v1.0.0` must register again using Firebase Authentication.

Existing SQLite password hashes are not migrated into Firebase credentials.

The old Kotlin data model is also incompatible with the new UID-based Firestore architecture.

```text
legacy_sqlite/
```

The legacy SQLite archive is excluded from Git and is no longer used by the Flutter runtime.

Firebase client configuration remains in the application where required, while service-account credentials, signing keys and private environment secrets remain excluded.

---

## ⚠️ Known Limits

The following features are still under active development:

* Classes
* Schedule
* Assignments
* Notices
* Notification Center
* FCM delivery
* Cloud Functions
* Profile photo upload (requires Firebase Storage configuration)

Windows debug builds may also display an upstream FlutterFire platform-thread warning.

Android remains the primary release platform for `v2.0.0`.

---

<div align="center">

### ⚡ My Campus 2.0

> **New architecture. New foundation. Same goal — better campus productivity.**

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,20,24&height=110&section=footer" width="100%" alt="Footer"/>

</div>
