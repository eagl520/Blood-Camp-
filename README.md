# Blood Camp 🩸

A modern blood donation management mobile application built with Flutter, Dart, and Firebase.

## 📱 About the Project

Blood Camp helps users find nearby blood donation camps, book donation slots, and track their eligibility — all in one simple application.

The app provides a clean dashboard where donors can browse camps, book slots, monitor their 56-day cooldown countdown, and stay updated with health tips. Camp staff can manage the donor roster and screening workflow, while organizers can create camps, assign staff, and view real-time analytics.

## ✨ Features

🩸 **Donor Role**
- 🔐 Secure User Authentication with Firebase
- 🏥 Browse Nearby Blood Donation Camps
- 🔍 Filter Camps by City & Blood Group
- 📅 Smart Booking with Date Range Restriction
- ⏳ Live 56-Day Cooldown Countdown Timer
- 🚫 Auto-Block If Not Eligible to Donate
- 📖 Complete Booking History
- 💡 Health & Recovery Tips
- 🏷️ Dynamic Camp Status Badge

👨‍⚕️ **Camp Staff Role**
- 📋 Real-time Today's Donor Roster
- 🩺 Complete Medical Screening Workflow
- 💉 Record Bag Numbers & Blood Units
- 🔄 Stage Workflow (Booked → Collected → Refreshment)
- 🚶 Walk-in Donor Registration
- 📊 End-of-Shift Summary Report

🎯 **Organizer Role**
- 🏗️ Create, Edit & Delete Blood Camps
- 📆 Multi-Day Camp Support
- 🩸 Select Blood Groups Needed
- 👥 Assign Staff to Camps
- 📈 Monthly Analytics
- 🗑️ Staff Auto-Release on Camp Delete

## 🛠️ Technologies Used

- Flutter
- Dart
- ImgBB API
- Firebase Authentication
- Cloud Firestore
- Material 3
- Git & GitHub

## ⚙️ How It Works

1. User creates an account or logs in via email/password.
2. Firebase Authentication securely manages the user account.
3. Role is auto-assigned at signup (organizer / staff / donor).
4. The user browses nearby blood donation camps from the dashboard.
5. Camps, bookings, and user data are stored in Cloud Firestore.
6. Each user's data is protected using Firebase Security Rules.
7. Donors can book slots, track cooldown, and manage their history.

## 🔒 Firebase Security

Blood Camp uses Firebase Authentication and Firestore Security Rules to ensure:

- Users can only access their own bookings and profile
- Camp data is readable by all authenticated users
- Only organizers can create / edit / delete camps
- Only assigned staff can update screening data

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Firebase project
- VS Code

### 📂 Project Structure
```
lib/
│
├─ main.dart
├─ firebase_options.dart
│
├── Auth/
│   ├── Splash_screen.dart
│   ├── login_screen.dart
│   ├── signup.dart
│   └── Help&Support_Screen.dart
│
├── screens/
│   │
│   ├── donor/
│   │   ├── donor_home_screen.dart
│   │   ├── camp_home.dart
│   │   ├── camp_detail_screen.dart
│   │   ├── booking_screen.dart
│   │   ├── History_screen.dart
│   │   ├── Health_tips.dart
│   │   ├── Edit_Profile_Screen.dart
│   │   └── profile.screen.dart
│   │
│   ├── organizer/
│   │   ├── organizer_home_screen.dart
│   │   ├── create_camp.dart
│   │   ├── add_new_staff.dart
│   │   ├── reports_screen.dart
│   │   └── profile_screen.dart
│   │
│   └── staff/
│       ├── staff_home_screen.dart
│       ├── screening.dart
│       ├── WalkIn_Booking_Screen.dart
│       ├── End_of_Shift.dart
│       └── profile_screen.dart
│
android/
ios/
web/
linux/
windows/
macos/
pubspec.yaml
README.md
```
### 🔥 Firestore Collections
- Collection Purpose
- users	All users (donors, staff, organizers) with role field
- organizer	Email whitelist for organizers (role detection at signup)
- staff	Email whitelist for staff (role detection at signup)
- camps	Blood donation camps
- bookings	Donor bookings + status tracking

### 🎓 Academic / Portfolio Project
 Blood Camp was developed as a Flutter mobile application project demonstrating:

- Flutter UI development
- Dart programming
- Firebase integration
- Authentication
- Cloud database management
- CRUD operations
- Application security
- GitHub version control

### 👨‍💻 Developer

Ibrahim
