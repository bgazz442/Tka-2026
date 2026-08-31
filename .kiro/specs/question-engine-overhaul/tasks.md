# Implementation Plan: Question Engine Overhaul

## Overview

Fix 12 critical bugs in the Futureee Flutter TKA tryout app by correcting data models, rendering logic, submit flow, result/review screens, storage, random simulation, and adding a question manifest asset and Diagnostics screen. All work is in Dart/Flutter with Provider + Hive. Existing classes are extended or corrected, not replaced.

---

## Tasks

- [ ] 1. Harden the Question model and serialization
  - [ ] 1.1 Audit and fix `Question.fromJson` type parsing to handle both `'singleChoice'` and `'QuestionType.singleChoice'` forms
    - In `lib/models/question.dart`, update `fromJson` to use `QuestionType.values.firstWhere((t) => t.name == typeStr || t.toString() == typeStr, orElse: () => parseQuestionType(typeStr))`
    - Ensure all 21 fields listed in the design field inventory are covered in `toJson` and `fromJson`
    - _Requirements: 1.1, 1.7_
  - [ ]* 1.2 Write property test for Question serialization round-trip (Property 4)
    - **Property 4: Round-trip consistency — `Question.fromJson(q.toJson())` must be field-by-field equal to the original for all 21 fields**
    - **Validates: Requirements 1.7**
    - Add to `test/question_test.dart`
  - [ ] 1.3 Verify `Question.validate()` returns correct errors for empty `questionText`, empty `options`, and empty `correctAnswers`
    - Confirm implementation matches the design spec contract in `lib/models/question.dart`
    - Ensure `questionType.isTextInput` check (for `numericInput`/`shortText`) suppresses the "no options" error
    - _Requirements: 1.2, 1.3, 1.4_
  - [ ]* 1.4 Write property tests for Question.validate() (Properties 1, 2, 3)
    - **Property 1: Any whitespace-only `questionText` → `validate()` returns `'Question text is empty'`**
    - **Property 2: Any non-text-input `QuestionType` with empty `options` → `validate()` returns `'Question has no options'`**
    - **Property 3: Any `Question` with empty `correctAnswers` → `validate()` returns `'No correct answer specified'`**
    - **Validates: Requirements 1.2, 1.3, 1.4**
    - Add to `test/question_test.dart`

- [ ] 2. Fix QuestionType enum and parseQuestionType
  - [ ] 2.1 Confirm `QuestionType` enum has all 10 values and add `complexChoice` mapping to `parseQuestionType` in `lib/models/question_type.dart`
    - Verify enum contains: `singleChoice`, `multipleChoice`, `trueOrFalse`, `suitableOrNot`, `matching`, `numericInput`, `shortText`, `imageBased`, `tableBased`, `complexChoice`
    - Add all canonical tokens, `.toString()` forms, and Indonesian labels to `parseQuestionType` without throwing
    - _Requirements: 2.1, 2.6_
  - [ ] 2.2 Add `numericInput`/`shortText` branch to `QuestionCardWidget._buildAnswerSection` in `lib/widgets/question_card_widget.dart`
    - Add `case QuestionType.numericInput: case QuestionType.shortText: return _buildTextInputAnswer();`
    - Implement `_buildTextInputAnswer()` rendering a `TextField` with appropriate keyboard type
    - _Requirements: 2.5_
  - [ ]* 2.3 Write unit tests for `Question.isCorrect()` across types
    - Test `singleChoice`, `multipleChoice`, and `trueOrFalse` cases in `test/question_test.dart`
    - _Requirements: 14.4_

- [ ] 3. Fix QuestionCardWidget rendering per QuestionType
  - [ ] 3.1 Verify/fix binary-choice row rendering for `trueOrFalse` and `suitableOrNot` in `lib/widgets/question_card_widget.dart`
    - Ensure `_TrueFalseRow` renders "Benar/Salah" for `trueOrFalse` and "Sesuai/Tidak Sesuai" for `suitableOrNot`
    - _Requirements: 2.2_
  - [ ] 3.2 Verify/fix checkbox-style multi-select rendering for `multipleChoice` and `complexChoice`
    - Ensure `_MultiSelectOption` allows selecting more than one option simultaneously for these types
    - _Requirements: 2.3_
  - [ ] 3.3 Verify radio-style single-select rendering for `singleChoice`, `imageBased`, and `tableBased`
    - Ensure `AnswerOptionWidget` enforces single selection for these types
    - _Requirements: 2.4_

- [ ] 4. Fix stimulus rendering in QuestionCardWidget
  - [ ] 4.1 Add `stimulusImageUrl` rendering to `_buildStimulus()` in `lib/widgets/question_card_widget.dart`
    - Render `Image.network(question.stimulusImageUrl!)` above the stimulus text when `stimulusImageUrl` is non-null and non-empty
    - Use the same `_imageLoadingBuilder` and `_imageErrorBuilder` helpers as question images
    - Hide stimulus block entirely when both `stimulus` and `stimulusImageUrl` are null/empty
    - _Requirements: 3.3, 3.4, 3.5_
  - [ ]* 4.2 Write widget tests for stimulus rendering
    - Test: stimulus block shown when `stimulus` is non-null; hidden when null; `stimulusImageUrl` image rendered when non-null
    - Add to `test/widgets/question_card_test.dart`
    - _Requirements: 3.3, 3.5_

- [ ] 5. Fix image loading with error placeholder
  - [ ] 5.1 Verify/fix `Image.network` loading and error states for `question.imageUrl` in `lib/widgets/question_card_widget.dart`
    - Confirm `loadingBuilder` shows `CircularProgressIndicator` while fetching
    - Confirm `errorBuilder` shows a styled container with `'Ilustrasi soal tidak dapat dimuat.'`
    - _Requirements: 4.1, 4.2_
  - [ ]* 5.2 Write widget test for image error placeholder
    - Test that the error placeholder text `'Ilustrasi soal tidak dapat dimuat.'` renders when network fails
    - Add to `test/widgets/question_card_test.dart`
    - _Requirements: 4.2_

- [ ] 6. Checkpoint — Ensure all model and widget tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Fix ExamPackage question count and data structure
  - [ ] 7.1 Fix `ExamPackage.questionCount` getter to return `questions.length` in `lib/models/exam_package.dart`
    - Verify getter is `int get questionCount => questions.length;`
    - _Requirements: 5.1_
  - [ ] 7.2 Add `ExamPackage` property test for question count (Property 5)
    - In `test/question_test.dart` or new `test/exam_package_test.dart`
    - **Property 5: For any list of Questions passed to `ExamPackage`, `package.questionCount == package.questions.length` always holds**
    - **Validates: Requirements 5.1**
  - [ ] 7.3 Verify `PackageDetailScreen` displays `package.questionCount` as "Jumlah Soal"
    - In `lib/screens/package_detail_screen.dart`, confirm the count widget reads `package.questionCount`
    - _Requirements: 5.2_
  - [ ] 7.4 Verify `ExamScreen` displays `exam.totalQuestions` in progress text
    - In `lib/screens/exam_screen.dart`, confirm `exam.totalQuestions` (which equals `package.questions.length`) is used
    - _Requirements: 5.3_

- [ ] 8. Fix submit flow with double-submit guard and navigation
  - [ ] 8.1 Verify/fix `ExamService.submitExam()` guard block in `lib/services/exam_service.dart`
    - Ensure `if (_isSubmitting || _submitGuard) return _result;` is the first check
    - Ensure `_isSubmitting = true` and `_submitGuard = true` are set atomically before scoring
    - _Requirements: 6.1, 6.2_
  - [ ] 8.2 Fix post-frame navigation in `_ExamContentState` to use `_hasNavigated` flag in `lib/screens/exam_screen.dart`
    - Add `bool _hasNavigated = false;` to state
    - Wrap `Navigator.pushReplacement` with `if (exam.result != null && !_hasNavigated) { _hasNavigated = true; ... }`
    - _Requirements: 6.5_
  - [ ] 8.3 Verify error recovery resets `_isSubmitting = false` and `_submitGuard = false` in catch block
    - In `lib/services/exam_service.dart`, ensure catch block resets both flags and calls `notifyListeners()`
    - _Requirements: 6.6_
  - [ ] 8.4 Verify timer auto-submit calls `submitExam(forcedByTimeout: true)` when `_remainingSeconds <= 0`
    - In `lib/services/exam_service.dart` timer callback, confirm this path exists
    - _Requirements: 6.7_

- [ ] 9. Implement StorageService history methods
  - [ ] 9.1 Verify/fix `StorageService.appendHistory()` inserts at index 0 in `lib/services/storage_service.dart`
    - Confirm: deserialize existing list, `items.insert(0, result)`, re-serialize and persist to `futureee_history_box`
    - _Requirements: 9.1_
  - [ ] 9.2 Verify `StorageService.getHistory()` error tolerance (skips malformed entries) in `lib/services/storage_service.dart`
    - Confirm try/catch per entry in the deserialization loop
    - _Requirements: 9.5_
  - [ ] 9.3 Verify `StorageService.getBestScoreForPackage()` and `getOverallStats()` return correct values
    - `getBestScoreForPackage`: returns max score or null when no entries
    - `getOverallStats`: returns `totalTryouts`, `totalQuestions`, `avgScore`, `bestScore`, `lowestScore`
    - _Requirements: 9.3, 9.4_
  - [ ]* 9.4 Write property tests for StorageService (Properties 7, 8, 9)
    - **Property 7: After `appendHistory(result)`, new `getHistory()[0]` equals the appended result and length increases by 1**
    - **Property 8: `getBestScoreForPackage()` returns a value ≥ every individual score for that packageId**
    - **Property 9: `getOverallStats()` satisfies `lowestScore ≤ avgScore ≤ bestScore`, `totalTryouts == history.length`, `totalQuestions == Σ result.totalQuestions`**
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.4**
    - Add to `test/storage_service_test.dart`

- [ ] 10. Fix RandomSimulationService
  - [ ] 10.1 Verify/fix `RandomSimulationService.createRandomSimulation()` signature and `StateError` throw in `lib/services/random_simulation_service.dart`
    - Accept `questionPool`, `questionCount` (default 30), optional `seed`
    - Throw `StateError('Cannot create simulation with $questionCount questions from pool of ${questionPool.length}')` when `questionCount > questionPool.length`
    - Use `Random(seed ?? DateTime.now().millisecondsSinceEpoch)` for shuffle
    - _Requirements: 10.1, 10.2, 10.3_
  - [ ] 10.2 Verify `validateNoDuplicates()` and `calculateDurationSeconds()` implementations
    - `validateNoDuplicates`: return `true` if all `id` values are unique
    - `calculateDurationSeconds`: `≤20 → 3600`, `21–25 → 4500`, `26–30 → 5400`
    - _Requirements: 10.4, 10.7_
  - [ ] 10.3 Verify simulation session metadata includes `isSimulation: true` and `seed` in `StorageService.saveActiveExam()` call path
    - In `lib/services/exam_service.dart` or where active exam is persisted, confirm the metadata map has `'isSimulation'` and `'seed'` keys
    - _Requirements: 10.5_
  - [ ] 10.4 Verify `ExamScreen` resumes simulation by re-running `createRandomSimulation()` with stored seed
    - In `lib/screens/exam_screen.dart` (or exam service init), confirm resume path reads `seed` and `questionCount` from stored metadata and reconstructs question list
    - _Requirements: 10.6_
  - [ ]* 10.5 Write unit/property tests for RandomSimulationService (Properties 10, 11, 12)
    - **Property 10: Same seed → identical question `id` sequences (determinism)**
    - **Property 11: `validateNoDuplicates(createRandomSimulation(...))` always returns `true`**
    - **Property 12: `calculateDurationSeconds` bracket invariants for n in [1,20], [21,25], [26,30]**
    - **Validates: Requirements 10.1, 10.2, 10.4, 10.7**
    - Add to `test/random_simulation_service_test.dart`

- [ ] 11. Fix PackageScreen and HomeScreen to load all 19 packages
  - [ ] 11.1 Fix `PackageScreen._getPackages()` to use a `switch` on `subject.id` returning `EnglishPackages.list`, `IndonesianPackages.list`, or `MathematicsPackages.list` in `lib/screens/package_screen.dart`
    - Ensure all three subject imports are present
    - _Requirements: 11.1, 11.2, 11.3_
  - [ ] 11.2 Fix `HomeScreen._findPackageById()` to search all three package lists in `lib/screens/home_screen.dart`
    - Implement: iterate `[...EnglishPackages.list, ...IndonesianPackages.list, ...MathematicsPackages.list]` and return matching `ExamPackage` or `null`
    - _Requirements: 11.4, 11.5_

- [ ] 12. Checkpoint — Ensure all service, model, and screen logic tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Implement ResultScreen
  - [ ] 13.1 Create/fix `lib/screens/result_screen.dart` with all required UI components
    - Score circle showing `result.score` (0–100)
    - Separate counters for `result.correct`, `result.wrong`, `result.empty`
    - Duration text using `ScoringService.formatDurationText(result.durationSeconds)`
    - `AppBar` with `automaticallyImplyLeading: false` and title `'Hasil Tryout'`
    - _Requirements: 7.1, 7.2, 7.3, 7.7_
  - [ ] 13.2 Add trend badge to `ResultScreen` (shows when ≥ 2 history entries for package)
    - Fetch `StorageService.getHistoryByPackage(result.packageId)` — `history[0]` is current, `history[1]` is previous
    - Show `diff = result.score - history[1].score` as green/red/neutral badge
    - _Requirements: 7.4_
  - [ ] 13.3 Add navigation buttons to `ResultScreen`
    - "Review Jawaban & Pembahasan" button → `Navigator.push` to `ReviewScreen(result: result)`
    - "Kembali ke Dashboard" button → `Navigator.pop(context)`
    - _Requirements: 7.5, 7.6_

- [ ] 14. Implement ReviewScreen
  - [ ] 14.1 Create/fix `lib/screens/review_screen.dart` as a `StatefulWidget` with per-question navigation
    - Display each `QuestionBreakdown` from `result.breakdown` in order
    - Status bar: green + `'BENAR'` for `'correct'`, red + `'SALAH'` for `'wrong'`, grey + `'TIDAK DIJAWAB'` for `'empty'`
    - Pass `isReviewMode: true` to `QuestionCardWidget`
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
  - [ ] 14.2 Add empty state and navigation buttons to `ReviewScreen`
    - Empty state: if `result.breakdown.isEmpty`, show `'Data review tidak tersedia.'` without crashing
    - "Sebelumnya" (disabled on first question) and "Berikutnya" buttons
    - On last question: "Berikutnya" shows `'Selesai Review'` and calls `Navigator.pop(context)`
    - _Requirements: 8.6, 8.7_

- [ ] 15. Add ScoringService unit tests
  - [ ] 15.1 Write unit tests for `ScoringService.calculate()` in `test/scoring_service_test.dart`
    - Test cases: all-correct → score 100, all-wrong → score 0 (clamped), all-empty → score 0, mixed answers → correct `rawScore`
    - _Requirements: 14.2_

- [ ] 16. Populate data layer — English packages (8 packages)
  - [ ] 16.1 Populate `lib/data/english/english_packages.dart` with all 8 `ExamPackage` entries and their question lists
    - Each package must reference a correctly populated `_packageNQuestions` list matching the defantri.com source question count
    - Use local `const String _pkgNStimulusX` variables for shared passages within each package
    - Assign matching `stimulus` string to every `Question` in each reading-passage group
    - All `Question` fields (`id`, `questionText`, `options`, `correctAnswers`, `questionType`, `displayNumber`, `subjectId`, `packageId`, `packageName`, `scoreCorrect`, `scoreWrong`, `scoreEmpty`, `scoringRule`) must be non-empty/non-null
    - _Requirements: 1.1, 5.4, 11.1_

- [ ] 17. Populate data layer — Indonesian packages (6 packages)
  - [ ] 17.1 Populate `lib/data/indonesian/indonesian_packages.dart` with all 6 `ExamPackage` entries
    - Same conventions as English packages: stimulus const variables, complete Question fields
    - _Requirements: 1.1, 5.5, 11.2_

- [ ] 18. Populate data layer — Mathematics packages (5 packages)
  - [ ] 18.1 Populate `lib/data/mathematics/mathematics_packages.dart` with all 5 `ExamPackage` entries
    - Same conventions as other subjects
    - _Requirements: 1.1, 5.6, 11.3_

- [ ] 19. Checkpoint — Run `flutter analyze` and confirm zero issues after data population
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 20. Create question_manifest.json and generation script
  - [ ] 20.1 Create `tool/generate_manifest.dart` script that reads all three package lists and writes `assets/question_manifest.json`
    - Import `EnglishPackages`, `IndonesianPackages`, `MathematicsPackages`
    - Write JSON array with keys: `id`, `subjectId`, `title`, `sourceUrl`, `questionCount`, `typeCounts`
    - `typeCounts` is a map of `QuestionType.name → count` (empty `{}` when `questionCount == 0`)
    - Output file at `assets/question_manifest.json`
    - _Requirements: 12.1, 12.2, 12.3, 12.4_
  - [ ] 20.2 Declare `assets/question_manifest.json` in `pubspec.yaml` under `flutter.assets`
    - Add `- assets/question_manifest.json` to the assets list
    - _Requirements: 12.1, 12.5_
  - [ ] 20.3 Run `dart run tool/generate_manifest.dart` to generate the initial manifest file
    - Create `assets/` directory if it doesn't exist
    - Verify output JSON matches the schema defined in design section 10.2
    - _Requirements: 12.2_

- [ ] 21. Implement DiagnosticsScreen
  - [ ] 21.1 Create `lib/screens/diagnostics_screen.dart` as a `StatefulWidget`
    - `initState` loads `assets/question_manifest.json` via `rootBundle.loadString` and parses JSON array
    - Summary header: total package count, total question count, per-subject breakdown
    - List of empty packages (`questionCount == 0`) labeled "Paket kosong"
    - _Requirements: 13.1, 13.2, 13.3, 13.6_
  - [ ] 21.2 Add per-question validation display and all-valid state to `DiagnosticsScreen`
    - For each package in manifest, find matching `ExamPackage` from all three lists and call `Question.validate()` on each question
    - Group and display validation errors by error type
    - Show `'Semua data soal valid.'` when no issues found
    - _Requirements: 13.4, 13.5_
  - [ ] 21.3 Add "Diagnostik Data" list tile to `SettingsScreen` in `lib/screens/settings_screen.dart`
    - `ListTile` with `Icons.bug_report_rounded`, title `'Diagnostik Data'`, subtitle `'Periksa kualitas data soal'`
    - `onTap` navigates to `DiagnosticsScreen`
    - _Requirements: 13.1_

- [ ] 22. Final checkpoint — `flutter analyze` and `flutter test`
  - Ensure all tests pass, run `flutter analyze` and confirm `No issues found!`, ask the user if questions arise.
  - _Requirements: 14.1, 14.5_

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- All code is Dart/Flutter; state management uses Provider (`ChangeNotifier`) + Hive for persistence
- The data-population tasks (16–18) are the most labor-intensive; each package's question list must match the actual source URL question count from defantri.com
- The `tool/generate_manifest.dart` script must be re-run after any change to `lib/data/` files
- `question_manifest.json` is only used by `DiagnosticsScreen` and offline tooling — never at exam runtime
- Property tests use a `forAll` helper (seeded `dart:math Random`) since Dart lacks a first-class QuickCheck library
- The `_hasNavigated` flag fix in task 8.2 is critical — without it, multiple `pushReplacement` calls cause a black screen or duplicate routes

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "7.1"] },
    { "id": 1, "tasks": ["1.3", "2.2", "2.3", "7.2", "7.3", "7.4"] },
    { "id": 2, "tasks": ["1.2", "1.4", "3.1", "3.2", "3.3", "8.1", "8.3", "8.4", "9.1", "9.2", "9.3", "10.1", "10.2"] },
    { "id": 3, "tasks": ["4.1", "5.1", "8.2", "10.3", "10.4", "11.1", "11.2"] },
    { "id": 4, "tasks": ["4.2", "5.2", "9.4", "10.5", "13.1", "14.1", "15.1"] },
    { "id": 5, "tasks": ["13.2", "13.3", "14.2"] },
    { "id": 6, "tasks": ["16.1", "17.1", "18.1"] },
    { "id": 7, "tasks": ["20.1", "20.2"] },
    { "id": 8, "tasks": ["20.3"] },
    { "id": 9, "tasks": ["21.1", "21.2"] },
    { "id": 10, "tasks": ["21.3"] }
  ]
}
```
