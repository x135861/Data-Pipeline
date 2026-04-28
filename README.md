Iitti Community App
A cross‑platform community engagement application built with Flutter and Firebase, designed for residents of Iitti to share updates, request help, offer services, and stay connected in real time.

🚀 Features
✔ Cross‑Platform
Runs on Android, iOS, and Web using a single Flutter codebase.

✔ Secure Authentication
Firebase Authentication

Email/password login

Role‑based admin access

✔ Real‑Time Updates
Firestore Streams

Instant UI refresh

Live posts, notices, events, and services

✔ Admin Moderation
Services submitted by users go to Pending

Admin approves or rejects before public visibility

✔ Content Safety
Profanity filter on all user‑generated text

Prevents offensive or harmful content

✔ Clean Architecture
Separation of UI, authentication, database, and filtering

Easy to maintain and extend

🏗 Tech Stack
Frontend
Flutter (Material 3)

Dart

Backend
Firebase Authentication

Cloud Firestore (NoSQL real‑time database)

Content Safety
profanity_filter

Tooling
flutter_test

flutter_lints

📂 Project Structure
Code
lib/
 ├── auth/            # Login, register, admin check
 ├── screens/         # UI screens (Home, Help, Services, Admin, etc.)
 ├── widgets/         # Reusable UI components
 ├── models/          # Data models
 ├── services/        # Firestore interactions
 └── main.dart        # App entry point
🔥 Firebase Services Used
1. Firebase Core
Initializes Firebase in the app.

2. Firebase Authentication
Handles:

Login

Registration

Admin role detection

3. Cloud Firestore
Stores:

Posts

Help requests

Help offers

Notices

Events

Services (pending + approved)

Provides real‑time updates via Streams.

🛡 Security Considerations
✔ Firebase provides:
Authentication

Data encryption

Secure communication

⚠ Potential vulnerabilities (if launching publicly):
Admin role stored client‑side

Firestore rules must be hardened

No rate limiting

Client‑side validation can be bypassed

🔐 Recommended improvements:
Use Firebase Custom Claims for admin

Add strict Firestore security rules

Add server‑side validation with Cloud Functions

📦 Installation & Setup
1. Clone the repository
Code
git clone https://github.com/x135861/Data-Pipeline.git
2. Install dependencies
Code
flutter pub get
3. Run the app
Code
flutter run
🧪 Testing
Run Flutter tests:

Code
flutter test
📜 License
This project is for educational and community development purposes.

🙋‍♀️ Author
Susan Pandey  
Flutter Developer • Firebase Integration • Community App Builder
