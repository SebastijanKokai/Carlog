# ScanKeeper

## Overview
ScanKeeper is a Flutter app that scans and extracts data from driver's permit licenses using a custom-trained **Azure Document Intelligence** model. Users can log in with **Firebase Authentication**, manage extracted data with **CRUD** operations, and sync it to **Firestore**.

## Features
- Scan and extract data from driver's permit licenses (front & back) using Azure Document Intelligence.
- Firebase Authentication for secure user login.
- Edit extracted data manually before saving.
- Delete and manage stored data easily.
- Sync data in real-time with Firebase Firestore.
- Firestore handles **offline mode**, allowing users to access and update data without an internet connection.

## Screenshots
<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/login_screen.jpg" alt="Login Screen" width="200"/>
      <br>
      <b>Login Screen</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/home_screen.jpg" alt="Home Screen" width="200"/>
      <br>
      <b>Home Screen</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/scan_screen.jpg" alt="Scan Screen" width="200"/>
      <br>
      <b>Scan Screen</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/details_screen.jpg" alt="Details Screen" width="200"/>
      <br>
      <b>Details Screen</b>
    </td>
  </tr>
</table>

## Tech Stack
- **Flutter** (Dart)
- **Firebase** (Authentication, Firestore)
- **Azure Document Intelligence** (Custom-trained model)

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/SebastijanKokai/ScanKeeper.git
   cd ScanKeeper
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up Firebase by adding `firebase_options.dart`.
4. Configure **Azure Document Intelligence** API keys in the .env file.
5. Run the app:
   ```bash
   flutter run
   ```

## Usage
1. **Login/Register** with Firebase Authentication.
2. **Scan or Upload** a driver's permit license image.
3. **Extracted Data** is automatically populated in form fields.
4. **Edit** any incorrect or missing data manually.
5. **Save or Delete** the data in Firebase Firestore.