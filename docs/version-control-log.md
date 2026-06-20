# HABITUS Version Control Evidence Log

## 2026-06-10

### Branch
`feature/progress-report-mvp`

### Commit message
`feature(mvp): capture progress report MVP implementation`

### Files changed
- `Components/GoalProgressRow.swift`
- `Components/MetricRing.swift`
- `Components/WeekStripView.swift`
- `DayKey.swift`
- `HABITUS.xcodeproj/project.pbxproj`
- `Services/DailyInputsAPI.swift`
- `Services/FirebaseBootstrapper.swift`
- `ViewModels/DayDashboardStore.swift`
- `ViewModels/GoalsStore.swift`
- `Views/Components/SessionRowView.swift`
- `Views/Dashboard/DashboardView.swift`
- `Views/Goals/GoalsView.swift`
- `Views/Logging/LogActivityView.swift`
- `Views/MainTabView.swift`
- `Views/SettingsView.swift`
- `backend/functions/src/engines/smartPlanningEngine.ts`
- `backend/functions/src/index.ts`
- `docs/version-control-log.md`

### Feature / requirement supported
Documents the MVP implementation work aligned with the proposal and progress report:
SwiftUI dashboard, Firebase data flow, daily recovery inputs, activity logging, goals,
Smart Planning, calendar-aware scheduling, progress visualisation, and backend metric updates.

### Testing evidence
- Firebase Functions TypeScript build passed with `npm run build`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator.

### Dissertation relevance
Creates a clear version-control checkpoint for the progress-report MVP. This branch and
commit can be cited as evidence that the application had moved from concept to an integrated
SwiftUI/Firebase MVP with user inputs influencing metrics, planning outputs, and goal progress.

## 2026-06-10

### Branch
`feature/onboarding-profile`

### Commit message
`feature(onboarding): add Office Athlete profile setup`

### Files changed
- `App/RootView.swift`
- `ViewModels/SessionViewModel.swift`
- `Views/Onboarding/SignUpView.swift`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal requirement that users can securely sign in, select an Office Athlete
level, provide work context, set a primary wellbeing goal, and supply baseline data used for
personalised planning.

### Testing evidence
- Firebase Functions TypeScript build passed with `npm run build`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator.
- Simulator flow to verify manually: sign out or launch with no authenticated user, create a
new account, complete the personalisation and baseline fields, then confirm the app opens to
the main dashboard. For an existing account without `onboardingCompleted: true`, sign in and
confirm the profile setup screen appears before the dashboard.

### Dissertation relevance
Creates visible evidence for the onboarding and personalisation success criteria in the
proposal. The stored `users/{uid}` profile document can be shown in Firebase as proof that
HABITUS captures Office Athlete level, work location, primary goal, and baseline wellbeing
data before generating the user experience.

## 2026-06-14

### Branch
`feature/privacy-data-controls`

### Commit message
`feature(privacy): add account data controls`

### Files changed
- `HABITUS-Info.plist`
- `Views/SettingsView.swift`
- `backend/functions/src/index.ts`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal requirements for GDPR/data privacy best practice and user control over
wellness data. Adds visible privacy messaging, sign-out access, destructive account/data
deletion, and a clear calendar permission reason.

### Testing evidence
- Firebase Functions TypeScript build passed with `npm run build`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: sign in, open Settings, review the Privacy & Account
  section, confirm Sign Out returns to authentication, then use a disposable account to test
  Delete Account and Data and verify the Firebase `users/{uid}` document plus `days`,
  `sessions`, and `goals` subcollections are removed.

### Dissertation relevance
Creates direct evidence for the dissertation's ethical and GDPR discussion. The app now gives
users clear visibility of stored wellness data categories and a demonstrable deletion path for
profile, goals, daily metrics, logged sessions, and the Firebase Auth account.

## 2026-06-14

### Branch
`feature/session-delete-flow`

### Commit message
`feature(sessions): add logged activity deletion`

### Files changed
- `ViewModels/TodaySessionsStore.swift`
- `Views/Components/SessionRowView.swift`
- `Views/Dashboard/DashboardView.swift`
- `backend/functions/src/index.ts`
- `backend/functions/src/services/goalService.ts`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal sprint deliverable for edit/delete functionality on logged sessions and
strengthens user control over self-reported wellness data. Adds authenticated deletion,
daily strain recomputation, and visible dashboard deletion controls.

### Testing evidence
- Firebase Functions TypeScript build passed with `npm run build`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: log two activities, confirm the dashboard strain and
  session count update, delete one activity from the Day log, then confirm the deleted row
  disappears and the day's strain/session count recalculate. For sessions logged after this
  change, matching goal progress is reversed where the session stored activity metadata.

### Dissertation relevance
Creates evidence that HABITUS supports correction of user-entered activity data rather than
leaving incorrect health records immutable. This improves MVP credibility, data quality, and
the proposal's data-handling/user-control story.

## 2026-06-14

### Branch
`test/algorithm-validation`

### Commit message
`test(algorithms): add validation cases for strain recovery and planning`

### Files changed
- `backend/functions/package.json`
- `backend/functions/test/algorithm-validation.test.cjs`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal and progress report claims that HABITUS uses tested algorithmic models
for strain, recovery, and Smart Planning. Adds deterministic validation cases for the
Session-RPE strain model, sleep-adjustment bounds, recovery traffic-light outputs, and
goal/readiness-aware Smart Planning decisions.

### Testing evidence
- `npm test` passed with 6/6 backend algorithm tests.
- Firebase Functions TypeScript build passed as part of `npm test`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.

### Dissertation relevance
Creates direct, reproducible testing evidence for the core technical contribution of HABITUS.
The tests can be cited in the final evaluation to show that the app's key metrics and planning
outputs are not only UI claims but verified behaviours with known input/output cases.

## 2026-06-14

### Branch
`fix/planner-explainability`

### Commit message
`fix(planner): make smart plan rationale explainable`

### Files changed
- `Views/Dashboard/DashboardView.swift`
- `backend/functions/src/engines/smartPlanningEngine.ts`
- `backend/functions/test/algorithm-validation.test.cjs`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal and progress report requirements that Smart Planning should be
meaningful, personalised, and explainable. Planner summaries and item reasons now explicitly
reference strain, recovery/readiness, intensity control, and unmet weekly goals.

### Testing evidence
- `npm test` passed with 6/6 backend algorithm tests, including Smart Planning rationale
  assertions.
- Firebase Functions TypeScript build passed as part of `npm test`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: log sleep/goals/activity data, open the dashboard, and
  confirm the Today's plan section includes a "Why this plan?" explanation plus item reasons
  that connect the recommendation to strain, recovery, and goals.

### Dissertation relevance
Reduces the risk that Smart Planning appears hardcoded or arbitrary. This creates visible
and tested evidence that HABITUS can justify recommendations in terms of the dissertation's
core metrics and behavioural-planning requirements.

## 2026-06-14

### Branch
`feature/weekly-progress-visualisation`

### Commit message
`feature(progress): add weekly strain and recovery visualisation`

### Files changed
- `ViewModels/DayDashboardStore.swift`
- `Views/Dashboard/DashboardView.swift`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal requirements for visual feedback, habit tracking, and dashboard-based
progress summaries. Adds a seven-day dashboard snapshot for strain, recovery, and logged
session consistency using existing Firestore day documents.

### Testing evidence
- `npm test` passed with 6/6 backend algorithm tests.
- Firebase Functions TypeScript build passed as part of `npm test`.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: log activities and sleep check-ins across one or more
  days, open the dashboard, and confirm the Weekly snapshot card displays daily strain bars,
  recovery dots, session counts, and aggregate averages.

### Dissertation relevance
Creates visible evidence for the proposal's visual reinforcement and progress-tracking aims.
The weekly snapshot makes screenshots more convincing by showing that HABITUS is not only
reacting to today's input but also summarising recent behaviour patterns.

## 2026-06-14

### Branch
`feature/habit-streaks`

### Commit message
`feature(habits): add check-in and activity streaks`

### Files changed
- `ViewModels/DayDashboardStore.swift`
- `Views/Dashboard/DashboardView.swift`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal and progress report requirements for behavioural nudges, habit
reinforcement, and visual feedback loops. Adds dashboard streaks for consecutive sleep
check-ins and activity logging using existing Firestore day documents.

### Testing evidence
- `npm test` passed with 6/6 backend algorithm tests.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: complete sleep check-ins and log activities across
  consecutive days, open the dashboard, and confirm the Habit streaks card reflects
  consecutive check-in and activity days. Delete an activity and confirm the activity streak
  updates when that day no longer contains logged sessions.

### Dissertation relevance
Creates visible evidence that HABITUS reinforces repeat behaviour rather than only displaying
single-day metrics. The streak card gives the final report and demo a clear feedback-loop
artifact tied to sleep check-ins and activity logging.
