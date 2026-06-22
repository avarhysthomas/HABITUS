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

## 2026-06-20

### Branch
`feature/office-athlete-personalisation`

### Commit message
`feature(planner): personalise smart plans by athlete level`

### Files changed
- `backend/functions/src/index.ts`
- `backend/functions/src/engines/plannerTypes.ts`
- `backend/functions/src/engines/smartPlanningEngine.ts`
- `backend/functions/test/algorithm-validation.test.cjs`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal and progress report requirement that Office Athlete onboarding data
personalises recommendations rather than only being stored as profile metadata. Smart
Planning now reads the user's Office Athlete level from Firestore and adjusts recommended
session duration and intensity while adding visible rationale text.

### Testing evidence
- `npm run lint` passed for Firebase Functions.
- `npm test` passed with 8/8 backend algorithm tests, including Office Athlete
  personalisation cases for new exercisers and performance-focused users.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: create or update accounts with different Office Athlete
  levels, complete sleep/check-in and goal setup, open the dashboard, and confirm the Today's
  plan rationale references Office Athlete personalisation while suggested intensity/duration
  changes for beginner versus performance-focused profiles.

### Dissertation relevance
Creates evidence that HABITUS closes the personalisation loop from onboarding to intervention.
The final report can now show that Office Athlete level affects Smart Planning behaviour,
which strengthens the project's claim that recommendations are tailored to user context.

## 2026-06-20

### Branch
`fix/calendar-planning-feedback`

### Commit message
`fix(planner): clarify calendar scheduling feedback`

### Files changed
- `ViewModels/DayDashboardStore.swift`
- `Views/Dashboard/DashboardView.swift`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal requirement for Smart Planning to adapt around calendar availability
and the progress report claim that HABITUS includes Apple Calendar-aware scheduling. The
dashboard now explains whether suggestions were fitted into free calendar time, only partly
scheduled, blocked by missing permission, or shown unscheduled because no suitable slots were
available.

### Testing evidence
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: open Dashboard with calendar access allowed and confirm
  Today's plan shows a calendar scheduling status above scheduled cards. Then deny calendar
  access in simulator privacy settings and confirm the same section explains that suggestions
  are shown without scheduled times.

### Dissertation relevance
Creates clearer demo evidence for calendar-aware Smart Planning. A marker can now see why a
plan is scheduled or unscheduled instead of interpreting an empty scheduled list as a broken
integration.

## 2026-06-21

### Branch
`feature/session-edit-flow`

### Commit message
`feature(sessions): add logged activity editing`

### Files changed
- `ViewModels/TodaySessionsStore.swift`
- `Views/Components/SessionRowView.swift`
- `Views/Dashboard/DashboardView.swift`
- `backend/functions/src/index.ts`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal requirement for edit/delete flows on logged wellbeing data and
strengthens the MVP's data correction story. Users can now edit a logged activity's type,
duration, intensity, and run distance from the dashboard day log.

### Testing evidence
- `npm run lint` passed for Firebase Functions.
- `npm test` passed with 8/8 backend algorithm tests.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: log an activity, open Dashboard, tap the edit button in
  the Day log, change duration or RPE, save, and confirm the row plus strain score update.
  For a run, change distance or type and confirm weekly goal progress remains consistent.

### Dissertation relevance
Creates evidence that HABITUS supports correction of self-reported health/activity data
instead of forcing users to delete and recreate records. This improves data quality,
usability, and the final MVP defence around user control.

## 2026-06-21

### Branch
`test/ios-logic-validation`

### Commit message
`test(ios): add logic validation for dates goals and scheduling`

### Files changed
- `HABITUSTests/HABITUSTests.swift`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal and progress report requirement for testing and validation beyond the
Firebase Functions algorithms. Adds Swift unit tests for date key formatting, goal progress
edge cases, and Smart Planning slot scheduling behaviour.

### Testing evidence
- iOS unit tests passed on iPhone 16 simulator with 6/6 tests passing in the
  `HABITUSTests` target.
- iOS simulator compile-only build passed for scheme `HABITUS` on iPhone 16 simulator with
  no warnings or errors.
- Simulator flow to verify manually: no user-facing flow is required; this change creates
  automated test evidence for local Swift logic used by the dashboard, goals, and calendar
  planning features.

### Dissertation relevance
Strengthens the technical quality evidence by replacing the generated iOS test placeholder
with focused validation cases. This helps defend HABITUS as a tested MVP across both backend
algorithms and key Swift scheduling/date logic.

## 2026-06-22

### Branch
`fix/firestore-security-rules`

### Commit message
`fix(firebase): add user-scoped firestore rules`

### Files changed
- `backend/firestore.rules`
- `backend/firebase.json`
- `docs/version-control-log.md`

### Feature / requirement supported
Supports the proposal and progress report requirements for privacy, secure handling of
wellness data, and GDPR-aligned user data boundaries. Firestore rules are now checked into
the repository and restrict direct client access to the authenticated user's own
`users/{uid}` document and nested data.

### Testing evidence
- `firebase emulators:exec --only firestore "echo firestore-rules-loaded"` passed and
  confirmed the Firestore emulator could load the rules from `backend/firebase.json`.
- Manual review: rules deny all documents outside `users/{uid}` and allow authenticated
  users to read/write only their own user document tree.

### Dissertation relevance
Creates explicit version-controlled security evidence for HABITUS. This strengthens the
privacy discussion by showing that user wellness data is scoped by Firebase Authentication
rather than relying only on app UI behaviour.
