# Requirements Document

## Introduction

The **Question Engine Overhaul** addresses 12 critical bugs in the Futureee Flutter TKA tryout app. The app currently stores question data as Dart `const` in `lib/data/` and uses Provider + Hive for state and persistence. The overhaul fixes partial question display, missing answer options, stimulus sharing failures, image loading failures, wrong question counts, all-single-choice type misclassification, broken submit flow, missing result/review screens, lost results, broken random simulation, and incomplete package loading. It also adds a question manifest asset and a Diagnostics screen to expose data quality issues, while maintaining zero `dart analyze` issues and passing tests.

Subjects in scope: **Bahasa Inggris** (8 tryout packages), **Bahasa Indonesia** (6 packages), and **Matematika** (5 packages). All 19 source URLs are from defantri.com. The existing `ExamPackage`, `Question`, `QuestionType`, `ExamResult`, `ScoringService`, `ExamService`, `StorageService`, and `RandomSimulationService` classes must be extended or corrected rather than replaced.

---

## Glossary

- **App**: The Futureee Flutter application targeting Android, iOS, and Web.
- **Question**: An instance of the `Question` Dart model; the atomic unit of examination content.
- **Package**: An `ExamPackage` instance grouping a fixed, ordered set of `Question` objects for one tryout session.
- **Subject**: A top-level category (`english`, `indonesian`, `mathematics`) grouping multiple Packages.
- **Stimulus**: A shared passage, text block, or image header that is displayed once and referenced by one or more consecutive Questions within the same Package.
- **StimulusGroup**: A `StimulusGroup` model instance that owns a `stimulus` text and/or `stimulusImageUrl` and references a list of `questionIds`.
- **QuestionType**: The `QuestionType` enum value carried by each Question; one of 10 values (`singleChoice`, `multipleChoice`, `trueOrFalse`, `suitableOrNot`, `matching`, `numericInput`, `shortText`, `imageBased`, `tableBased`, `complexChoice`).
- **ExamService**: The `ChangeNotifier` service that drives a live exam session.
- **ScoringService**: The static scoring utility that produces `ExamResult` from questions + answers.
- **StorageService**: The Hive-backed persistence layer.
- **RandomSimulationService**: The service that selects 30 unique random questions for a TKA simulation session.
- **Manifest**: The `assets/question_manifest.json` file listing every Package with its question count, subject, source URL, and per-type counts.
- **Diagnostics Screen**: A developer-accessible Flutter screen that reads the Manifest and reports data-quality issues.
- **Result Screen**: `ResultScreen` — shown immediately after a successful exam submit.
- **Review Screen**: `ReviewScreen` — accessible from the Result Screen; shows each question with the user answer, correct answer, and explanation.

---

## Requirements

### Requirement 1 — Full Question Model Correctness

**User Story:** As a developer, I want every `Question` instance in `lib/data/` to carry complete, non-empty field values, so that all 12 rendering and scoring bugs rooted in missing data are eliminated.

#### Acceptance Criteria

1. THE `Question` model SHALL include the fields `id`, `questionText`, `options`, `correctAnswers`, `questionType`, `displayNumber`, `subjectId`, `packageId`, `packageName`, `scoreCorrect`, `scoreWrong`, `scoreEmpty`, and `scoringRule` as non-nullable (with defaults for scoring fields).
2. WHEN a `Question` is constructed with an empty `questionText`, THEN THE `Question.validate()` method SHALL return a list containing the error string `'Question text is empty'`.
3. WHEN a `Question` with a `questionType` that is not `numericInput` or `shortText` is constructed with an empty `options` map, THEN THE `Question.validate()` method SHALL return a list containing the error string `'Question has no options'`.
4. WHEN a `Question` is constructed with an empty `correctAnswers` list, THEN THE `Question.validate()` method SHALL return a list containing the error string `'No correct answer specified'`.
5. THE `Question` model SHALL support an optional `stimulus` field (plain text passage) and an optional `stimulusImageUrl` field (absolute HTTPS URL) so that stimulus data is carried per-question and also resolved via a shared `StimulusGroup`.
6. THE `Question` model SHALL carry an `imageUrl` field accepting an absolute HTTPS URL or `null`; WHEN the field is non-null, THE `QuestionCardWidget` SHALL attempt to render the image using `Image.network`.
7. THE `Question.toJson()` and `Question.fromJson()` methods SHALL round-trip all model fields without data loss.

---

### Requirement 2 — 10 QuestionType Values and Rendering

**User Story:** As a student, I want every question rendered with the correct answer UI for its type, so that I can interact with True/False, Multi-select, and other formats without errors.

#### Acceptance Criteria

1. THE `QuestionType` enum SHALL contain exactly 10 values: `singleChoice`, `multipleChoice`, `trueOrFalse`, `suitableOrNot`, `matching`, `numericInput`, `shortText`, `imageBased`, `tableBased`, and `complexChoice`.
2. WHEN a `Question` has `questionType == QuestionType.trueOrFalse` or `questionType == QuestionType.suitableOrNot`, THEN THE `QuestionCardWidget` SHALL render a binary-choice row (Benar/Salah or Sesuai/Tidak Sesuai) for each entry in `options`.
3. WHEN a `Question` has `questionType == QuestionType.multipleChoice` or `questionType == QuestionType.complexChoice`, THEN THE `QuestionCardWidget` SHALL render checkbox-style options and permit selecting more than one option simultaneously.
4. WHEN a `Question` has `questionType == QuestionType.singleChoice`, `imageBased`, or `tableBased`, THEN THE `QuestionCardWidget` SHALL render radio-style options permitting exactly one selection.
5. WHEN a `Question` has `questionType == QuestionType.numericInput` or `shortText`, THEN THE `QuestionCardWidget` SHALL render a text input field instead of option buttons.
6. THE `parseQuestionType` function SHALL map any of the following string tokens to the correct enum value without throwing: `'singleChoice'`, `'multipleChoice'`, `'trueOrFalse'`, `'suitableOrNot'`, `'matching'`, `'numericInput'`, `'shortText'`, `'imageBased'`, `'tableBased'`, `'complexChoice'`, their `QuestionType.xxx.toString()` forms, and human-readable Indonesian labels.

---

### Requirement 3 — Stimulus Sharing Across Questions

**User Story:** As a student, I want a reading passage to appear once above the first question that uses it and persist across all subsequent questions in that group, so that I can read the text without scrolling back.

#### Acceptance Criteria

1. THE App SHALL support a `StimulusGroup` model with fields `id`, `text` (nullable), `imageUrl` (nullable), `questionIds` (list of question IDs that share the stimulus), and `createdAt`.
2. WHEN building `ExamPackage` question lists in `lib/data/`, THE developer SHALL attach an identical non-null `stimulus` string or `stimulusImageUrl` to every `Question` that belongs to the same reading-passage group.
3. WHEN `QuestionCardWidget` renders a `Question` where `stimulus` is non-null and non-empty, THEN THE widget SHALL display the stimulus block above the question text in every render of that question.
4. WHEN consecutive `Question` objects in a Package share the same `stimulus` value, THEN THE `QuestionCardWidget` SHALL display the stimulus for each of them individually (the student sees the passage on every question in the group).
5. IF a `Question.stimulus` is `null` or empty, THEN THE `QuestionCardWidget` SHALL NOT render the stimulus block.

---

### Requirement 4 — Image Loading

**User Story:** As a student, I want question images to load from their HTTPS URLs, so that image-based questions are fully legible.

#### Acceptance Criteria

1. WHEN a `Question.imageUrl` is a non-empty absolute HTTPS URL, THEN THE `QuestionCardWidget` SHALL display a loading indicator while the image is fetching and replace it with the loaded image on success.
2. IF `Image.network` fails to load the image at `Question.imageUrl`, THEN THE `QuestionCardWidget` SHALL display an error placeholder with the text `'Ilustrasi soal tidak dapat dimuat.'` inside a styled container.
3. WHEN a `Question.stimulusImageUrl` is a non-empty absolute HTTPS URL, THEN THE `QuestionCardWidget` SHALL render the stimulus image above the stimulus text block (or alone if stimulus text is null).
4. THE App SHALL declare all image-hosting domains in `android/app/src/main/AndroidManifest.xml` as `android:usesCleartextTraffic="false"` is NOT present (default HTTPS behavior); HTTPS URLs SHALL be accessible without additional manifest configuration.
5. THE `pubspec.yaml` SHALL NOT list any `assets:` directories that contain remote image URLs as local assets; images are loaded at runtime via `Image.network`.

---

### Requirement 5 — Correct Question Count Per Package

**User Story:** As a student, I want the question counter in the exam app bar and the package detail screen to show the real count matching the source tryout, so that I am not surprised mid-exam.

#### Acceptance Criteria

1. THE `ExamPackage.questionCount` getter SHALL return `questions.length` exactly.
2. WHEN `PackageDetailScreen` renders, THE App SHALL display `package.questionCount` as the "Jumlah Soal" value.
3. WHEN `ExamScreen` renders, THE App SHALL display `exam.totalQuestions` (which equals `package.questions.length`) in the question-progress text.
4. THE `lib/data/english/english_packages.dart` SHALL contain exactly 8 `ExamPackage` entries, each referencing a `_packageNQuestions` list with a length equal to the number of questions published at the corresponding defantri.com source URL.
5. THE `lib/data/indonesian/indonesian_packages.dart` SHALL contain exactly 6 `ExamPackage` entries with correctly populated question lists.
6. THE `lib/data/mathematics/mathematics_packages.dart` SHALL contain exactly 5 `ExamPackage` entries with correctly populated question lists.

---

### Requirement 6 — Submit Flow with Guard, Save, and Navigate

**User Story:** As a student, I want submitting my exam to produce a result, save it to history, and navigate me to the Result Screen without any double-submit or missing-result bug.

#### Acceptance Criteria

1. WHEN `ExamService.submitExam()` is called and `_submitGuard` is `false`, THEN THE `ExamService` SHALL set `_isSubmitting = true` and `_submitGuard = true` before performing any further operations.
2. WHEN `ExamService.submitExam()` is called while `_submitGuard` is `true`, THEN THE `ExamService` SHALL return the existing `_result` value without restarting the scoring pipeline.
3. WHEN `ScoringService.calculate()` completes without exception, THEN THE `ExamService` SHALL call `StorageService.appendHistory(_result!)` to persist the result.
4. WHEN `StorageService.appendHistory()` completes, THEN THE `ExamService` SHALL call `StorageService.clearActiveExam()` to remove the in-progress session.
5. WHEN `ExamService._result` becomes non-null, THEN THE `_ExamContentState` post-frame callback SHALL call `Navigator.of(context).pushReplacement` with a `MaterialPageRoute` to `ResultScreen(result: exam.result!)`.
6. IF `ScoringService.calculate()` throws an exception, THEN THE `ExamService` SHALL reset `_isSubmitting = false` and `_submitGuard = false` and call `notifyListeners()` so the UI returns to an interactive state.
7. WHEN the exam timer reaches zero seconds, THEN THE `ExamService` SHALL automatically call `submitExam(forcedByTimeout: true)`, triggering the same guard + save + navigate flow.

---

### Requirement 7 — Result Screen

**User Story:** As a student, I want to see my final score, correct/wrong/empty counts, time taken, and a comparison with my previous attempt immediately after submitting, so that I can assess my performance.

#### Acceptance Criteria

1. WHEN `ResultScreen` is displayed with a valid `ExamResult`, THEN THE `ResultScreen` SHALL render a score circle showing `result.score` (0–100).
2. THE `ResultScreen` SHALL display separate counters for `result.correct`, `result.wrong`, and `result.empty`.
3. THE `ResultScreen` SHALL display the formatted duration using `ScoringService.formatDurationText(result.durationSeconds)`.
4. WHEN `StorageService.getHistoryByPackage(result.packageId)` returns 2 or more entries, THEN THE `ResultScreen` SHALL display a trend badge comparing the current score to the previous attempt's score.
5. THE `ResultScreen` SHALL provide a "Review Jawaban & Pembahasan" button that navigates to `ReviewScreen(result: result)`.
6. THE `ResultScreen` SHALL provide a "Kembali ke Dashboard" button that calls `Navigator.pop(context)`.
7. THE `ResultScreen` SHALL NOT display a back-navigation arrow in the AppBar; `automaticallyImplyLeading` SHALL be `false`.

---

### Requirement 8 — Review Screen

**User Story:** As a student, I want to browse every question after the exam with my answer highlighted, the correct answer indicated, and an explanation shown, so that I can learn from my mistakes.

#### Acceptance Criteria

1. THE `ReviewScreen` SHALL display each `QuestionBreakdown` from `result.breakdown` in order, one at a time.
2. WHEN the current `QuestionBreakdown.status` equals `'correct'`, THEN THE `ReviewScreen` SHALL display a green status bar with the label `'BENAR'`.
3. WHEN the current `QuestionBreakdown.status` equals `'wrong'`, THEN THE `ReviewScreen` SHALL display a red status bar with the label `'SALAH'`.
4. WHEN the current `QuestionBreakdown.status` equals `'empty'`, THEN THE `ReviewScreen` SHALL display a grey status bar with the label `'TIDAK DIJAWAB'`.
5. THE `ReviewScreen` SHALL pass `isReviewMode: true` to `QuestionCardWidget` so that the correct answer and explanation are rendered.
6. WHEN `result.breakdown` is empty, THEN THE `ReviewScreen` SHALL display the message `'Data review tidak tersedia.'` and not crash.
7. THE `ReviewScreen` SHALL provide "Sebelumnya" and "Berikutnya" navigation buttons; WHEN on the last question, THE "Berikutnya" button SHALL show the label `'Selesai Review'` and SHALL call `Navigator.pop(context)`.

---

### Requirement 9 — Results Saved to History

**User Story:** As a student, I want my exam result persisted to local Hive storage so that it appears in the History screen and contributes to my overall statistics.

#### Acceptance Criteria

1. WHEN `StorageService.appendHistory(result)` is called, THE `StorageService` SHALL insert the new `ExamResult` at index 0 of the history list and persist the updated list to the `futureee_history_box` Hive box.
2. THE `StorageService.getHistory()` method SHALL deserialize the stored list using `ExamResult.fromJson` and return results in reverse-chronological order (newest first).
3. THE `StorageService.getBestScoreForPackage(packageId)` method SHALL return the highest `score` value among all `ExamResult` entries with a matching `packageId`, or `null` if no entries exist.
4. THE `StorageService.getOverallStats()` method SHALL return a map containing `totalTryouts`, `totalQuestions`, `avgScore`, `bestScore`, and `lowestScore` computed from all stored history entries.
5. IF an `ExamResult.fromJson` call throws during `getHistory()`, THEN THE `StorageService` SHALL skip that entry and continue deserializing remaining entries without re-throwing.

---

### Requirement 10 — TKA Random Simulation

**User Story:** As a student, I want to start a 30-question TKA simulation drawn randomly from all available packages, with a fixed seed so I can resume the same session if I leave and return.

#### Acceptance Criteria

1. THE `RandomSimulationService.createRandomSimulation()` method SHALL accept a `questionPool` list, a `questionCount` integer defaulting to 30, and an optional `seed` integer.
2. WHEN `createRandomSimulation()` is called with a `seed`, THE `RandomSimulationService` SHALL use `Random(seed)` to shuffle the pool so the result is deterministic for that seed.
3. WHEN `questionCount` is greater than `questionPool.length`, THEN `createRandomSimulation()` SHALL throw a `StateError` with the message `'Cannot create simulation with $questionCount questions from pool of ${questionPool.length}'`.
4. THE `RandomSimulationService.validateNoDuplicates()` method SHALL return `true` when every question in the list has a unique `id`, and `false` if any `id` appears more than once.
5. WHEN a simulation session is saved to `StorageService` (active exam state), THE `ExamService` SHALL include `isSimulation: true` and the `seed` integer in the session metadata, so that resuming the session reconstructs the same question order.
6. WHEN a simulation is resumed from storage, THE App SHALL re-run `createRandomSimulation()` with the stored `seed` to reconstruct the identical question list before restoring answer state.
7. THE `RandomSimulationService.calculateDurationSeconds()` method SHALL return `3600` for `questionCount <= 20`, `4500` for `questionCount` in 21–25, and `5400` for `questionCount` in 26–30.

---

### Requirement 11 — All Packages Loaded from All Subjects

**User Story:** As a student, I want every package from every subject to be accessible from the Package Screen, so that I can practice any of the 19 available tryouts.

#### Acceptance Criteria

1. WHEN `PackageScreen._getPackages()` is called with `subject.id == 'english'`, THE `PackageScreen` SHALL return `EnglishPackages.list` containing 8 non-empty `ExamPackage` entries.
2. WHEN `PackageScreen._getPackages()` is called with `subject.id == 'indonesian'`, THE `PackageScreen` SHALL return `IndonesianPackages.list` containing 6 non-empty `ExamPackage` entries.
3. WHEN `PackageScreen._getPackages()` is called with `subject.id == 'mathematics'`, THE `PackageScreen` SHALL return `MathematicsPackages.list` containing 5 non-empty `ExamPackage` entries.
4. WHEN `HomeScreen._findPackageById()` is called with a valid `packageId`, THE method SHALL search `EnglishPackages.list`, `MathematicsPackages.list`, and `IndonesianPackages.list` and return the matching `ExamPackage`, or `null` if not found.
5. THE App SHALL import and reference all three subject package classes (`EnglishPackages`, `IndonesianPackages`, `MathematicsPackages`) in every screen that aggregates across subjects.

---

### Requirement 12 — Question Manifest Asset

**User Story:** As a developer, I want a `question_manifest.json` asset file that lists every package with metadata, so that I can diagnose data gaps without running the app.

#### Acceptance Criteria

1. THE App SHALL include a file at `assets/question_manifest.json` listed under `flutter.assets` in `pubspec.yaml`.
2. THE `question_manifest.json` SHALL be a JSON array where each element represents one `ExamPackage` and contains the keys `id`, `subjectId`, `title`, `sourceUrl`, `questionCount`, and `typeCounts` (an object mapping each `QuestionType` label to its integer count within the package).
3. WHEN an `ExamPackage` has a `questionCount` of zero, THE manifest entry for that package SHALL include `questionCount: 0` and `typeCounts: {}`.
4. THE `question_manifest.json` SHALL be regenerated whenever `lib/data/` package files change, so that it always reflects the current state of the data files.
5. THE App SHALL NOT read `question_manifest.json` at exam runtime; it is used only by the Diagnostics Screen and external tooling.

---

### Requirement 13 — Diagnostics Screen

**User Story:** As a developer, I want a Diagnostics screen accessible from Settings that reads the manifest and reports all packages with zero questions, wrong question counts, missing correct answers, or missing options, so that I can pinpoint data issues quickly.

#### Acceptance Criteria

1. THE `DiagnosticsScreen` SHALL be a Flutter `StatefulWidget` accessible from the `SettingsScreen` via a "Diagnostik Data" list tile.
2. WHEN `DiagnosticsScreen` initializes, THE screen SHALL load `assets/question_manifest.json` using `rootBundle.loadString` and parse the JSON array.
3. THE `DiagnosticsScreen` SHALL display a list of `ExamPackage` entries where `questionCount == 0`, with the label "Paket kosong" next to each entry.
4. THE `DiagnosticsScreen` SHALL display a list of packages where any `Question.validate()` returns a non-empty error list, grouped by error type.
5. WHEN all packages pass validation, THE `DiagnosticsScreen` SHALL display the message `'Semua data soal valid.'` in the body.
6. THE `DiagnosticsScreen` SHALL display the total package count, total question count across all subjects, and a per-subject breakdown.

---

### Requirement 14 — Zero Analyze Issues and Tests Pass

**User Story:** As a developer, I want the `flutter analyze` command to report zero issues and all widget/unit tests to pass after the overhaul, so that CI is green.

#### Acceptance Criteria

1. WHEN `flutter analyze` is run on the workspace, THE tool SHALL report `No issues found!`.
2. THE `test/` directory SHALL contain at least one unit test file covering `ScoringService.calculate()` with at least 3 test cases: all-correct, all-wrong, and all-empty answers.
3. THE `test/` directory SHALL contain at least one unit test covering `RandomSimulationService.createRandomSimulation()` verifying deterministic output for the same seed.
4. THE `test/` directory SHALL contain at least one unit test covering `Question.isCorrect()` for `QuestionType.singleChoice`, `QuestionType.multipleChoice`, and `QuestionType.trueOrFalse`.
5. WHEN `flutter test` is run, THE test runner SHALL exit with code 0 with no failing tests.
