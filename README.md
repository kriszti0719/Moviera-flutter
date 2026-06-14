# Moviera

Moviera is a minimalist, distraction-free mobile movie-tracking application built with Flutter and Dart. The application serves as a personal digital notepad designed explicitly to counter digital choice overload and decision fatigue by allowing users to look up films and maintain a streamlined, offline-accessible watchlist.

## Project Overview

I engineered this application as an academic mobile development project, strictly adhering to production-grade design principles and standard software engineering practices. The platform eliminates the heavy social tracking, endless reviews, and data bloat found in commercial alternatives, prioritizing rapid under-30-second user interactions.

### Key Features Implemented:
* **Secure Gateway Access:** Integrated Firebase Authentication to lock and preserve user-specific profiles across device sessions.
* **Real-Time Catalog Discovery:** Consumes the external remote TMDB REST API (v3) asynchronously to fetch movie metadata and promotional artwork.
* **Relational Local Persistence:** Deploys an embedded SQLite database engine (`sqflite`) with strict prepared statement placeholders to ensure reliable offline visibility and defend against SQL injection.
* **Tactile Progress Modifier:** Features a custom, full-width Material status row banner on the movie details page, tracking viewing states (`Watched` vs. `Unwatched`) with dynamic color shifts and ripple responses.

## Architecture & Technologies

The system strictly follows the structural **Model-View-ViewModel (MVVM)** architectural pattern combined with the **Provider** framework for reactive state-propagation and clean dependency injection.

* **Frontend:** Flutter SDK (Material 3 Specifications)
* **Language:** Dart (Sound Null-Safety)
* **Database:** SQLite via `sqflite` (Local persistence)
* **Cloud Services:** Firebase Auth & Firebase Core (Session handling)
* **Network Client:** Asynchronous `http` handlers

## Testing Suite

I established a reliable, **Local-First Testing Strategy** to guarantee structural and business logic stability without inflating deployment infrastructure overhead:

* **Unit Tests:** Validates bidirectional data mapping hooks inside `MovieModel` and monitors isolated async state transitions within the ViewModels.
* **Widget Tests:** Mounts components inside an ephemeral virtual tree viewport sandbox to verify visual alignment and form layout constraints under simulated hermetic network isolation (`HttpOverrides`).

To run the full automated verification suite locally, execute the following command in your terminal:
```bash
flutter test