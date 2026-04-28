<div align="center">

# 🏘️ Iitti Community App

**A cross-platform community engagement app built with Flutter & Firebase**

Enabling residents of Iitti to share updates, request help, offer services, and stay connected — in real time.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Material 3](https://img.shields.io/badge/Material_3-757575?style=for-the-badge&logo=material-design&logoColor=white)

</div>

---

## ✨ Features

| Feature | Description |
|---|---|
| 📱 **Cross-Platform** | Runs on Android, iOS, and Web from a single Flutter codebase |
| 🔐 **Secure Authentication** | Firebase Auth with email/password login and role-based admin access |
| ⚡ **Real-Time Updates** | Firestore Streams for instant UI refresh on posts, notices, events, and services |
| 🛡️ **Admin Moderation** | User-submitted services enter a pending state — admin approves or rejects before going public |
| 🚫 **Content Safety** | Profanity filter applied to all user-generated text |
| 🏗️ **Clean Architecture** | Clear separation of UI, authentication, database, and filtering layers |

---

## 🗂️ Project Structure

```
lib/
├── auth/            # Login, register, admin check
├── screens/         # UI screens (Home, Help, Services, Admin, etc.)
├── widgets/         # Reusable UI components
├── models/          # Data models
├── services/        # Firestore interactions
└── main.dart        # App entry point
```

---

## 🔥 Firebase Services

### Firebase Authentication
- Email/password login
- User registration
- Admin role detection

### Cloud Firestore
Stores and streams in real time:
- Posts
- Help requests & offers
- Notices & events
- Services (pending and approved)

---

## 🛠️ Tech Stack

**Frontend**
- Flutter (Material 3)
- Dart

**Backend**
- Firebase Authentication
- Cloud Firestore (NoSQL real-time database)

**Content Safety**
- `profanity_filter`

**Tooling**
- `flutter_test`
- `flutter_lints`

---

## 🚀 Installation & Setup

**1. Clone the repository**
```bash
git clone https://github.com/x135861/Data-Pipeline.git
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the app**
```bash
flutter run
```

**4. Run tests**
```bash
flutter test
```

---

## 🔒 Security Considerations

### Firebase Provides
- Authentication
- Data encryption
- Secure communication

### ⚠️ Potential Vulnerabilities (if launched publicly)
- Admin role currently stored client-side
- Firestore security rules must be hardened
- No rate limiting in place
- Client-side validation can be bypassed

### ✅ Recommended Improvements
- Use **Firebase Custom Claims** for admin roles
- Add **strict Firestore security rules**
- Add **server-side validation** via Cloud Functions

---

## 📄 License

This project is for educational and community development purposes.

---

## 👩‍💻 Author

**Susan Pandey**
Flutter Developer · Firebase Integration · Community App Builder
