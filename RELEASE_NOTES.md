# MyCampus v2.1.0 — Release Notes

<div align="center">

<!-- Anime Header -->

<img src="https://media.tenor.com/EEbyku4nU8gAAAAi/rimuru-spin.gif" width="170" alt="Anime Character"/>
<img src="https://media1.tenor.com/m/ajHV0O5APUMAAAAC/rimuru-rimuru-tempest.gif" width="170" alt="Anime Character"/>
<img src="https://media1.tenor.com/m/T6cnb8csQAMAAAAC/%E3%81%A1%E3%82%87%E3%81%93%E3%81%88%E3%81%84-chocoeiru.gif" width="170" alt="Anime Character"/>

<br>

<img src="https://readme-typing-svg.herokuapp.com?font=Orbitron&size=32&duration=3500&pause=900&color=00BFFF&center=true&vCenter=true&width=750&lines=MyCampus+v2.1.0;Profile+Experience+Improved;Friendship+System+Refined;Cleaner.+Better.+More+Responsive." alt="MyCampus v2.1.0"/>

<br>

# 🎓 MyCampus v2.1.0

### 👤 Profile Redesign · 🤝 Friendship Fixes · 🎨 New Identity

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
</p>

<p>
  <img src="https://img.shields.io/badge/Release-v2.1.0-00BFFF?style=flat-square" alt="Release"/>
  <img src="https://img.shields.io/badge/Status-Stable-22C55E?style=flat-square" alt="Status"/>
  <img src="https://img.shields.io/badge/License-Apache_2.0-7E22CE?style=flat-square" alt="License"/>
</p>

**Release Date:** 24 August 2026

</div>

---

## 🌌 About This Release

MyCampus `v2.1.0` focuses on improving the profile experience, friendship reliability, responsive layouts, and overall project quality.

```text
╭──────────────────────────────────────────╮
│            MYCAMPUS v2.1.0               │
├──────────────────────────────────────────┤
│  👤 Profile Redesign                    │
│  🤝 Friendship Improvements             │
│  🎨 New MyCampus Icon                   │
│  🧪 Responsive UI Tests                 │
│  📜 Apache License 2.0                  │
╰──────────────────────────────────────────╯
```

> This update improves the existing MyCampus foundation without introducing major architectural changes.

---

## ✨ Main Changes

<table>
<tr>
<td width="50%" valign="top">

### 👤 Profile Experience

The Profile page has been redesigned with a cleaner and more professional layout.

* Separate **View** and **Edit** modes
* Personal information section
* Academic information section
* Account information section
* Better spacing and visual hierarchy

</td>
<td width="50%" valign="top">

### 📱 Responsive Layout

Profile layouts have been improved across supported screen sizes.

* Android phones
* Tablets
* Windows
* Web
* Responsive profile tests added

</td>
</tr>

<tr>
<td width="50%" valign="top">

### 🤝 Friendship System

Friend request handling is now more reliable.

* Fixed `Unable to send` errors
* Duplicate request handling
* Pending request handling
* Accepted friendship handling
* Rejected friendship handling
* Blocked relationship handling

</td>
<td width="50%" valign="top">

### 🔥 Firebase Improvements

Firebase and Firestore errors now provide clearer and more user-friendly messages.

This improves debugging while also preventing confusing raw backend errors from being shown directly to users.

</td>
</tr>
</table>

---

## 🎨 New MyCampus Identity

A new MyCampus launcher icon has been added across:

| Platform | Status  |
| -------- | ------- |
| Android  | ✅ Added |
| Windows  | ✅ Added |
| Web      | ✅ Added |

The new icon provides a more consistent visual identity across supported platforms.

---

## 🧹 Repository Improvements

This release also includes several project maintenance changes:

* Added **Apache License 2.0**
* Removed generated Graphify files
* Removed unnecessary build files
* Removed debug-generated files from version control
* Added responsive Profile tests

---

## ⚠️ Current Limitation

Profile photo upload is not available in `v2.1.0`.

```text
Profile Photo
     │
     ▼
Firebase Storage
     │
     └── ⏳ Not Configured Yet
```

Firebase Storage must be configured before profile images can be uploaded and synchronized between devices.

---

## 🚀 Upgrade

Pull the latest changes:

```bash
git pull
flutter pub get
flutter analyze
flutter test
flutter run
```

No major Firebase data migration is required for this release.

---

## 📌 Release Summary

| Area           | Improvement           |
| -------------- | --------------------- |
| Profile        | Major UI redesign     |
| Friendship     | Reliability fixes     |
| Firebase       | Better error handling |
| Responsive UI  | Improved              |
| App Icon       | Added                 |
| Testing        | Expanded              |
| License        | Apache 2.0            |
| Profile Photos | Not yet available     |

---

<div align="center">

## 🎓 MyCampus v2.1.0

> **Connect better. Organize smarter. Build your campus experience.**

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,20,24&height=120&section=footer" width="100%" alt="Footer"/>

**Learn · Connect · Organize · Improve**

</div>
