# Architecture & Design Decisions

This project is built using **Clean Architecture** combined with **BLoC (Business Logic Component)** for state management. This structure ensures that the code is modular, testable, and easy to maintain.

## 📂 Project Structure

The project is organized by **features**, where each feature contains its own layers:

```
lib/
├── core/                   # Shared code (Utilities, Constants, Base Classes)
├── features/
│   ├── audio_recording/    # Feature: Audio Recording & Management
│   │   ├── data/           # Data Layer
│   │   ├── domain/         # Domain Layer
│   │   └── presentation/   # Presentation Layer
│   └── audio_filter/       # Feature: Audio Processing & Filters
├── injection_container.dart # Dependency Injection Setup (GetIt)
└── main.dart               # Entry Point
```

## 🏗 Layers

### 1. Domain Layer (Inner Layer)
This is the core of the application. It contains the business logic and is independent of any external libraries or frameworks (except basic Dart packages).

- **Entities**: Plain Dart objects representing the data (e.g., `Recording`, `FilterType`).
- **Repositories (Interfaces)**: Abstract definitions of how data should be accessed.
- **Use Cases**: Specific business rules that orchestrate the flow of data to/from entities (e.g., `StartRecording`, `ApplyFilter`).

### 2. Data Layer (Middle Layer)
This layer implements the interfaces defined in the Domain layer. It handles data retrieval from various sources (Local Database, File System, API, etc.).

- **Models**: Data Transfer Objects (DTOs) that extend Entities and handle JSON serialization/deserialization.
- **Data Sources**: Low-level classes that interact with external systems (e.g., `RecordingDataSource` wraps the `record` package).
- **Repositories (Implementations)**: Implement the domain repository interfaces, coordinating data sources and handling errors.

### 3. Presentation Layer (Outer Layer)
This layer is responsible for showing data to the user and handling user interactions.

- **BLoC**: Manages the state of the UI. It receives **Events** from the UI, executes Use Cases, and emits **States** back to the UI.
- **Pages/Widgets**: The UI components built with Flutter widgets. They observe the BLoC state and rebuild accordingly.

## 🛠 Key Design Decisions

### State Management: BLoC
We chose **flutter_bloc** because:
- It enforces a unidirectional data flow.
- It clearly separates business logic from UI code.
- It makes state changes predictable and easy to debug.

### Dependency Injection: GetIt
We use **get_it** as a Service Locator to manage dependencies. This allows us to:
- Decouple classes from their dependencies.
- Easily swap implementations (e.g., using a mock recorder for testing).
- Manage the lifecycle of singletons and factories.

### Audio Recording: `record` Package
We use the `record` package for its simplicity and cross-platform support.
- **Waveform Visualization**: Since the `record` package (v6.0.0+) removed direct metering support in `RecordConfig`, we implemented a **polling mechanism** in the UI layer. We poll `recorder.getAmplitude()` every 100ms to update the waveform in real-time.

### Audio Processing: FFmpeg
We use `ffmpeg_kit_flutter_new` for applying audio filters.
- **Why FFmpeg?**: It provides powerful and flexible audio manipulation capabilities that standard audio players cannot achieve (e.g., changing pitch, speed, and applying complex effects).

### Waveform Rendering
We use `waveform_flutter` to render the visual representation of the audio.
- **Custom Implementation**: We customized the `AnimatedWaveList` integration to ensure smooth updates by streaming normalized amplitude values from our polling logic.

## 🔄 Data Flow Example: Starting a Recording

1.  **UI**: User taps the "Record" button.
2.  **BLoC**: `RecordingControls` widget adds `StartRecordingEvent` to `RecordingBloc`.
3.  **Bloc Logic**: `RecordingBloc` calls the `StartRecording` use case.
4.  **Use Case**: `StartRecording` calls `RecordingRepository.startRecording()`.
5.  **Repository**: `RecordingRepositoryImpl` checks permissions and calls `RecordingDataSource.startRecording()`.
6.  **Data Source**: `RecordingDataSource` uses the `record` package to start the actual recording.
7.  **Result**: The success/failure result propagates back up the chain.
8.  **State Update**: `RecordingBloc` emits `RecordingInProgress` state.
9.  **UI Update**: The UI updates to show the "Stop" button and starts the waveform animation.
