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
