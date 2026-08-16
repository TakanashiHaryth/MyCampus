# MyCampus project instructions

## UI and design system

- Read `theme.md` completely before creating or changing any page, widget, or
  visual state.
- Treat `theme.md` as the product-facing design source of truth and
  `lib/app_theme.dart` as its compiled Flutter implementation. Keep both in
  sync when a design token or rule changes.
- Build pages inside `lib/authenticated_shell.dart` and reuse presentation
  primitives from `lib/shared_widgets.dart`, including `PageHeader`,
  `SectionSurface`, `AppEmptyState`, `AppErrorState`, `AppLoadingState`,
  `UserAvatar`, and `StatusBadge`.
- Use `AppColors`, `AppGradients`, `AppSpacing`, `AppRadius`, and `AppMotion`.
  Do not introduce hardcoded colors, spacing, radii, page widths, backgrounds,
  or animation timings in feature screens.
- Use the signature gradient only for a single high-value brand/hero region,
  currently the desktop authentication panel. Use the gold accent sparingly
  for badges or highlights, as specified in `theme.md`.
- Use Sora for display text and Inter for body text through `AppTheme`; both
  fonts are bundled under `assets/fonts` for offline consistency.
- Preserve accessible labels, keyboard navigation, visible focus states,
  readable contrast, and touch targets of at least 48 logical pixels.
- Preserve the responsive rules: mobile below 720 uses a drawer, tablet starts
  with a collapsed sidebar, and desktop at 1100 or wider starts expanded.
- Verify changed screens at 360x800, 412x915, 768x1024, 1366x768, and
  1920x1080, then run `flutter analyze` plus `flutter test` before handoff.

## Firebase and data architecture

- Firebase UID is the only account identity. Do not restore SQLite auth or use
  email, username, or Student ID as a primary key.
- Keep Firebase SDK calls behind interfaces in `lib/core/`; feature widgets must
  not query Firestore directly.
- Friendships are many-to-many documents with canonical lower/higher UID IDs.
  Never add a single `friendUid` field to the user document.
- Keep private user fields under `users/{uid}` and searchable fields under
  `publicProfiles/{uid}`. Do not expose email or device tokens publicly.
- Store future FCM tokens under `users/{uid}/devices/{deviceId}` and send to
  other users only from trusted Cloud Functions/Admin SDK.
- Do not deploy Cloud Functions or enable Blaze billing without explicit user
  approval.
