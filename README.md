<div align="center">
  <h1>Nimbus</h1>
  <p><strong>A lightweight, modern download manager for desktop.</strong></p>
  <p>
    <img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue" alt="Platform">
    <img src="https://img.shields.io/badge/Frontend-Flutter-02569B" alt="Flutter">
    <img src="https://img.shields.io/badge/Backend-Rust%20%7C%20Axum-orange" alt="Rust">
  </p>
</div>

---

## ✨ Features

- **Multi-category downloads** — Organize files into Music, Video, Documents, Programs & more
- **Concurrent downloading** — Download multiple files simultaneously with configurable limits
- **Simulated progress** — Watch realistic download speed and progress animations
- **Download history** — Track completed and failed downloads with full history
- **File organization** — Set custom download directories per category
- **Dark & Light themes** — Switch between themes or follow your system preference
- **Backend ready** — Designed to work with a Rust/Axum + aria2 backend

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (channel stable, ^3.11.5)
- [Rust toolchain](https://rustup.rs/) (optional, for backend)

### Install & Run

```bash
# Clone the repository
git clone https://github.com/NareshBaruaIsHere/Nimbus.git
cd Nimbus

# Run the Flutter desktop app
cd apps/desktop
flutter run
```

### Build for Distribution

```bash
cd apps/desktop

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

The release binary will be in `build/<platform>/x64/runner/Release/`.

### Running the Backend (Optional)

```bash
cd core/api
cargo run
```

The API server starts on `http://127.0.0.1:4578`. The frontend will connect automatically.

## 🏗️ Project Structure

```
Nimbus/
├── apps/
│   └── desktop/          # Flutter desktop application
│       ├── lib/
│       │   ├── app/      # App shell, navigation, theme
│       │   ├── models/   # Data models (DownloadTask, Settings)
│       │   ├── pages/    # UI pages (Downloads, History, Settings, About)
│       │   ├── services/ # Business logic & persistence
│       │   └── widgets/  # Reusable widgets
│       └── test/         # Tests
├── core/
│   └── api/              # Rust API server (Axum + aria2)
└── shared/               # Shared code (future)
```

<!-- ## 📸 Screenshots -->

<!-- Add screenshots here once available -->

<!-- | Downloads | History | Settings | About |
|-----------|---------|----------|-------|
| Active & queued downloads | Completed & failed history | Categories, performance & theme | App info & credits | -->

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter (Dart) |
| Backend | Rust + Axum |
| Download Engine | aria2c |
| State Management | ChangeNotifier + InheritedWidget |
| Persistence | Local JSON files |

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 👨‍💻 Developer

**IFELSEGHOST** — [@NareshBaruaIsHere](https://github.com/NareshBaruaIsHere)

---

<div align="center">
  <sub>Built with Flutter & Rust.</sub>
</div>
