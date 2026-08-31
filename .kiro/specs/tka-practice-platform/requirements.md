# Requirements Document

## Introduction

Transform the existing Flutter TKA tryout app (Provider + Hive, local-only, Android/iOS/Web) from a one-time exam application into a full learning practice platform. The platform supports unlimited retries on any tryout package, a formal attempt tracking system, a fully preserved history grouped by tryout, per-package statistics with a score-development graph, safe back-navigation that saves progress, a complete question bank with source validation diagnostics, and an Excel export enriched with per-attempt metadata. The app uses fl_chart (already in pubspec.yaml) for visualisation and no changes to backend or authentication infrastructure are required.

---

## Glossary

- **AttemptId**: A globally unique string identifier for a single exam attempt, generated as `{uid}_{packageId}_{millisecondsSinceEpoch}` at the moment the attempt is created.
- **AttemptNumber**: A positive integer indicating how many times a user has attempted the same package. The first attempt is 1, the second is 2, and so on, computed from the ordered history of that package.
- **ActiveExam**: A Hive-persisted map representing an in-progress exam session keyed by `_keyActiveExam`. It includes `packageId`, `subjectId`, `currentIndex`, `startedAt`, `endAt`, `warningsCount`, `answers`, `flagged`, `questionOrder`, and `seed`.
- **ExamResult**: A completed attempt record stored in Hive history. Fields include `id` (same as AttemptId), `attemptNumber`, and all existing fields.
- **QuestionOrder**: An ordered list of question IDs (List\<String\>) stored in the ActiveExam, enabling exact resume of a shuffled or seeded simulation.
- **Seed**: An integer derived from `DateTime.now().millisecondsSinceEpoch` at the start of a random simulation, persisted in ActiveExam to allow identical question reselection on resume.
- **PackageStats**: Computed per-package aggregate: `attemptCount`, `bestScore`, `lowestScore`, `averageScore`, `lastScore`, `lastAttemptDate`.
- **QuestionImportReport**: An existing model (`question_import_report.dart`) extended with an `INCOMPLETE` status when `actualCount != expectedCount`.
- **HistoryGroup**: A UI grouping of all ExamResults sharing the same `packageId`, rendered as an expandable section in HistoryScreen.
- **ExamService**: The existing `ChangeNotifier`-based service controlling the active exam session.
- **StorageService**: The existing Hive-backed persistence service.
- **ExcelExportService**: The existing service that writes `.xlsx` results.
- **RandomSimulationService**: The existing service that creates seeded random question selections.
- **ResultScreen**: The screen displayed immediately after exam submission.
- **PackageDetailScreen**: The screen displaying package info and statistics before starting or retrying an exam.
- **HistoryScreen**: The screen listing all completed attempts.
- **ProgressScreen**: The existing screen showing score-development graphs and subject progress.
- **fl_chart**: The charting library already declared in `pubspec.yaml` used for line charts.

---

## Requirements

### Requirement 1 — Attempt Identity

**User Story:** As a student, I want every exam attempt to be uniquely identifiable and sequentially numbered per package, so that I can track my progress over multiple tries.

#### Acceptance Criteria

1. THE ExamResult model SHALL include an `attemptNumber` field of type `int` with a minimum value of 1 alongside the existing `id` (AttemptId) field.
2. WHEN ExamService submits an exam, THE ExamService SHALL compute `attemptNumber` as the count of existing ExamResults for the same `packageId` plus one before writing the new ExamResult to storage.
3. WHEN ExamResult is serialised to JSON, THE ExamResult SHALL include `attemptNumber` in the output map under the key `"attemptNumber"`.
4. WHEN ExamResult is deserialised from JSON, THE ExamResult SHALL read `attemptNumber` from the map, defaulting to 1 if the key is absent, preserving backward compatibility with existing stored data.
5. THE StorageService `appendHistory` method SHALL preserve all prior ExamResults for the same `packageId` and SHALL NOT overwrite or remove any existing entry.

---

### Requirement 2 — Result Screen "Coba Lagi" Button

**User Story:** As a student, I want a "Coba Lagi" button on the result screen so that I can immediately start a new attempt on the same package without returning to the package list.

#### Acceptance Criteria

1. THE ResultScreen SHALL display a "Coba Lagi" button rendered as a full-width `ElevatedButton` below the existing "Review Jawaban & Pembahasan" button.
2. WHEN the user taps "Coba Lagi", THE ResultScreen SHALL clear the ActiveExam for the current package from StorageService and navigate using `pushReplacement` to a new ExamScreen instance for the same `ExamPackage`.
3. WHEN navigating to a new ExamScreen via "Coba Lagi", THE ExamService SHALL initialise a new session with a fresh `startedAt`, a zeroed answer map, and a new `questionOrder` matching the package question list order (non-simulation packages use natural order).
4. IF the ResultScreen is reached from a RandomSimulation, THEN THE "Coba Lagi" button SHALL generate a new random seed so the new attempt uses a different question selection.
5. THE ResultScreen SHALL display the current `attemptNumber` of the just-completed attempt in the celebratory banner card below the package name.

---

### Requirement 3 — Package Detail Screen Statistics and Action Button

**User Story:** As a student, I want the package detail screen to show my attempt count, best score, and last score, and to offer the correct action button depending on whether an attempt is in progress, so that I understand my history at a glance.

#### Acceptance Criteria

1. THE PackageDetailScreen SHALL display `PackageStats.attemptCount`, `PackageStats.bestScore`, `PackageStats.lastScore`, and `PackageStats.averageScore` in the statistics card whenever at least one completed attempt exists for the package.
2. WHEN no attempt exists for a package and no ActiveExam is in progress for that package, THE PackageDetailScreen SHALL display a single "Mulai Tryout" button.
3. WHEN an ActiveExam is in progress for the package, THE PackageDetailScreen SHALL display a "Lanjutkan Tryout" button styled with the amber color `0xFFD97706`.
4. WHEN at least one completed attempt exists and no ActiveExam is in progress for the package, THE PackageDetailScreen SHALL display a "Coba Lagi" button styled with the primary color `0xFF4F46E5`.
5. WHEN the user taps "Coba Lagi" on PackageDetailScreen, THE PackageDetailScreen SHALL clear any residual ActiveExam for that package and navigate to a new ExamScreen instance.
6. THE PackageDetailScreen statistics card SHALL show `PackageStats.lastAttemptDate` formatted as a human-readable Indonesian locale date-time string using the existing `AppHelpers.formatDateTime` method.

---

### Requirement 4 — Grouped and Expandable History Screen

**User Story:** As a student, I want the history screen to group my attempts by tryout package with expandable sections so that I can quickly find all attempts for a specific package.

#### Acceptance Criteria

1. THE HistoryScreen SHALL group all ExamResults into HistoryGroups, where each HistoryGroup contains all ExamResults sharing the same `packageId`, sorted within the group by `completedAt` descending (newest first).
2. THE HistoryScreen SHALL render each HistoryGroup as an `ExpansionTile` whose header displays the package name, the total attempt count for that package, and the best score for that package.
3. WHEN a HistoryGroup `ExpansionTile` is expanded, THE HistoryScreen SHALL display each ExamResult as a list tile showing `attemptNumber`, `score`, `completedAt` formatted via `AppHelpers.formatDateTime`, and the count of correct/wrong/empty answers.
4. WHEN the user taps an individual ExamResult tile, THE HistoryScreen SHALL navigate to ResultScreen for that ExamResult.
5. THE HistoryScreen SHALL sort HistoryGroups by the `completedAt` of the most recent attempt in each group, descending.
6. IF the history is empty, THEN THE HistoryScreen SHALL display the existing empty-state illustration and the text "Belum Ada Riwayat Tryout".

---

### Requirement 5 — Score Progress Graph Per Package

**User Story:** As a student, I want to see a line chart of my score history for a specific package so that I can visualise my improvement over time.

#### Acceptance Criteria

1. THE PackageDetailScreen SHALL display a score progress line chart using `fl_chart LineChart` whenever at least 2 completed attempts exist for the package.
2. THE score progress chart SHALL plot `attemptNumber` on the X-axis and `score` (0–100 range) on the Y-axis, with one `FlSpot` per attempt ordered by `attemptNumber` ascending.
3. THE score progress chart SHALL use `isCurved: true`, a line color of `AppConstants.primaryColor`, and a translucent fill under the line using `BarAreaData` with alpha 0.1.
4. THE score progress chart SHALL display dot markers at each data point using `FlDotData(show: true)`.
5. WHEN only 1 completed attempt exists for the package, THE PackageDetailScreen SHALL display the statistics card without the chart widget.

---

### Requirement 6 — Per-Package Statistics Computation

**User Story:** As a student, I want accurate per-package statistics so that I know my average, best, worst, and latest scores for each package.

#### Acceptance Criteria

1. THE StorageService SHALL expose a `getPackageStats(String packageId)` method that returns a `PackageStats` map containing `attemptCount`, `bestScore`, `lowestScore`, `averageScore` (integer, rounded), `lastScore`, and `lastAttemptDate` as ISO 8601 string.
2. WHEN `getPackageStats` is called for a `packageId` with no history, THE StorageService SHALL return `null`.
3. THE `averageScore` field in PackageStats SHALL be computed as the arithmetic mean of all attempt `score` values for the package, rounded to the nearest integer.
4. THE `bestScore` field SHALL equal the maximum `score` value among all ExamResults for the package.
5. THE `lowestScore` field SHALL equal the minimum `score` value among all ExamResults for the package.
6. THE `lastScore` field SHALL equal the `score` of the ExamResult with the latest `completedAt` timestamp for the package.

---

### Requirement 7 — Random Simulation Seed Persistence

**User Story:** As a student, I want to be able to resume a random simulation with the exact same question selection so that my progress is not lost when I exit mid-session.

#### Acceptance Criteria

1. WHEN ExamService initialises a new session for a random simulation package, THE ExamService SHALL generate a seed as `DateTime.now().millisecondsSinceEpoch % 2147483647` and store it in the ActiveExam map under the key `"seed"`.
2. THE ExamService `_saveStateToStorage` method SHALL include the `"seed"` value in the persisted ActiveExam map for simulation packages.
3. WHEN ExamService resumes from an ActiveExam map containing a `"seed"` key, THE ExamService SHALL pass that seed to `RandomSimulationService.createRandomSimulation` to reconstruct the identical question list.
4. THE ExamService SHALL ensure no duplicate question IDs appear in a single simulation session by validating via `RandomSimulationService.validateNoDuplicates` during session initialisation.
5. WHEN `validateNoDuplicates` returns false during session initialisation, THE ExamService SHALL regenerate with a new seed and retry up to 3 times before throwing a `StateError`.

---

### Requirement 8 — Question Order Persistence for Resume

**User Story:** As a student, I want the exact question order of my session to be saved so that resuming an exam shows questions in the same sequence as when I started.

#### Acceptance Criteria

1. THE ExamService SHALL maintain a `_questionOrder` field of type `List<String>` containing the ordered question IDs for the current session.
2. WHEN a new session is initialised, THE ExamService SHALL populate `_questionOrder` from `package.questions.map((q) => q.id).toList()` for non-simulation packages.
3. THE ExamService `_saveStateToStorage` method SHALL persist `_questionOrder` in the ActiveExam map under the key `"questionOrder"` as a JSON list of strings.
4. WHEN ExamService restores from an ActiveExam map containing a `"questionOrder"` key, THE ExamService SHALL use the stored order to reconstruct the question list, matching each ID to the corresponding `Question` in `package.questions`.
5. IF a `"questionOrder"` key is absent from the restored ActiveExam, THEN THE ExamService SHALL fall back to the natural `package.questions` order to remain backward compatible.

---

### Requirement 9 — Safe Back Navigation with Save & Exit

**User Story:** As a student, I want pressing the back button during an exam to show a "Simpan & Keluar" dialog that saves my progress, so that I never lose answered questions or remaining time.

#### Acceptance Criteria

1. WHILE an exam is in progress, THE ExamScreen SHALL intercept all back-navigation events using `PopScope(canPop: false)`.
2. WHEN the user triggers back navigation or taps the close icon, THE ExamScreen SHALL display a modal dialog with title "Simpan & Keluar?" and body text "Semua jawaban dan sisa waktu akan disimpan. Kamu dapat melanjutkan tryout ini nanti."
3. THE dialog SHALL present two buttons: "Simpan & Keluar" (primary) and "Batal" (secondary).
4. WHEN the user taps "Simpan & Keluar", THE ExamService SHALL invoke `_saveStateToStorage` to persist the current `answers`, `flaggedQuestions`, `currentIndex`, `questionOrder`, `seed`, `startedAt`, and `endAt` before navigation.
5. WHEN the user taps "Batal", THE ExamScreen SHALL dismiss the dialog and resume the exam without any state change.
6. WHEN the user taps "Simpan & Keluar", THE ExamScreen SHALL navigate back to the previous screen using `Navigator.of(context).pop()` after `_saveStateToStorage` completes.

---

### Requirement 10 — Full Question Bank (No Placeholder Data)

**User Story:** As a student, I want every package in the app to contain the real questions from its source so that I am practising with authentic exam content.

#### Acceptance Criteria

1. THE EnglishPackages list SHALL contain exactly 8 packages, each with questions sourced from their respective declared `sourceUrl` and `sourceName`.
2. THE IndonesianPackages list SHALL contain exactly 6 packages, each with questions sourced from their respective declared `sourceUrl` and `sourceName`.
3. THE MathematicsPackages list SHALL contain exactly 5 packages, each with questions sourced from their respective declared `sourceUrl` and `sourceName`.
4. THE EntrepreneurshipPackages list SHALL contain at least 1 package with real questions sourced from a declared `sourceUrl` and `sourceName`.
5. WHEN any package question list is empty (0 questions), THE App SHALL NOT display that package in PackageScreen.
6. THE `Question.validate()` method SHALL return an empty error list for every question in every package, meaning no question has an empty `questionText`, missing `options`, or empty `correctAnswers`.

---

### Requirement 11 — Source Validation Diagnostics

**User Story:** As a developer, I want each package to declare an expected question count so that mismatches between the declared count and the actual imported count are surfaced as INCOMPLETE status.

#### Acceptance Criteria

1. THE ExamPackage model SHALL include an optional `expectedQuestionCount` field of type `int?`, defaulting to `null`.
2. WHEN `expectedQuestionCount` is set and `questions.length != expectedQuestionCount`, THE QuestionImportReport for that package SHALL set `isValid` to `false` and include the text `"INCOMPLETE"` in `statusMessage`.
3. THE QuestionImportReport SHALL expose an `isIncomplete` boolean getter that returns `true` when `actualCount != expectedCount` and `expectedCount > 0`.
4. WHERE a diagnostics or debug screen exists, THE App SHALL be capable of generating a `QuestionImportReport` per package by comparing `package.questions.length` against `package.expectedQuestionCount`.
5. THE `QuestionImportReport.statusMessage` SHALL begin with `"INCOMPLETE ⚠"` when `isIncomplete` is `true` and `importErrors` is empty.

---

### Requirement 12 — Excel Export with Attempt Number

**User Story:** As a student, I want the Excel export to include an attempt number column so that I can distinguish multiple attempts on the same package.

#### Acceptance Criteria

1. THE ExcelExportService `exportTryoutResults` method SHALL add an "No. Percobaan" column to the "Data Tryout" sheet as column L, containing the `attemptNumber` of each ExamResult.
2. THE "Data Tryout" sheet header row SHALL list columns in order: No, Tanggal, Nama, Mapel, Tryout, Jumlah Soal, Benar, Salah, Tidak Dijawab, Nilai, Durasi, No. Percobaan.
3. THE ExcelExportService SHALL group the "Perkembangan" sheet rows by `packageName`, with each package section showing rows in ascending `attemptNumber` order.
4. WHEN an ExamResult's `attemptNumber` is absent (legacy data), THE ExcelExportService SHALL write `1` as the fallback value for the "No. Percobaan" cell.
5. THE exported `.xlsx` file name format SHALL remain `TKA_Study_Hasil_{username}.xlsx`.

---

### Requirement 13 — Responsive UI Without Fixed-Height Containers

**User Story:** As a student, I want all screens to adapt to different device sizes without clipping or overflow so that the app is usable on any phone screen.

#### Acceptance Criteria

1. THE PackageDetailScreen SHALL wrap its entire body content in a `SingleChildScrollView` and SHALL NOT use any `Container` with a hardcoded fixed height on the main scroll axis.
2. THE ResultScreen SHALL wrap its entire body content in a `SingleChildScrollView` and SHALL NOT use any `Container` with a hardcoded fixed height on the main scroll axis.
3. THE HistoryScreen SHALL use `ListView` or `ListView.builder` for the grouped list and SHALL NOT use fixed-height rows outside of avatar or badge widgets.
4. THE score progress chart widget SHALL set its height via a `SizedBox` or `AspectRatio` with at most a 220px fixed height, and this widget SHALL be the only fixed-height element in the scroll view.
5. IF any screen body does not need to scroll (empty state), THEN THE screen SHALL still use a `Center` widget wrapping the content without a fixed-height outer container.

---

### Requirement 14 — Build and Analysis Quality Gates

**User Story:** As a developer, I want the codebase to pass all quality checks so that the platform transformation does not introduce regressions.

#### Acceptance Criteria

1. WHEN `flutter analyze` is executed on the project, THE Analyzer SHALL report zero errors and zero warnings.
2. WHEN `flutter test` is executed on the project, THE Test Runner SHALL report all existing and new unit tests as passing with exit code 0.
3. WHEN `flutter build apk --release` is executed, THE Android Build Tool SHALL produce an APK file without build errors.
4. WHEN `flutter build web` is executed, THE Web Build Tool SHALL produce a deployable web bundle without build errors.
5. THE App SHALL NOT use any deprecated Flutter API that generates a deprecation warning in the current Flutter 3.x stable SDK.
