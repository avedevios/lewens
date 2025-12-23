# Localization Testing Guide

## How to Test Language Switching

1. **Build and run the app**
2. **Navigate to Profile tab** (center tab)
3. **Login with Keycloak** if not already authenticated
4. **Tap on "Language/Sprache" button** in the Profile view
5. **Select different language** from the action sheet
6. **Observe immediate changes** in the UI text

## User-Specific Language Settings

- **Each user has their own language preference**
- **Language is saved per user ID**
- **When switching users, language preference is restored**
- **When logging out, app returns to system default language**

## Expected Behavior

- **Immediate UI update**: All text should change instantly without app restart
- **Tab bar labels**: Should update to selected language
- **All screens**: Should reflect the new language when navigated
- **Persistence**: Selected language should be remembered after app restart

## Languages Available

- **German (Deutsch)** - Default
- **English** 
- **Polish (Polski)**

## Test Scenarios

### Scenario 1: Basic Language Switch
1. Start app (should be in German by default)
2. Switch to English
3. Verify all text changes to English
4. Switch to Polish
5. Verify all text changes to Polish

### Scenario 2: Navigation Test
1. Switch language to English
2. Navigate between tabs (Downloads, Profile, Customers)
3. Verify all tabs show English text
4. Switch to Polish while on different tab
5. Verify current tab updates immediately

### Scenario 3: User-Specific Language Test
1. Login as User A
2. Switch language to English
3. Logout
4. Verify app returns to system default language
5. Login as User A again
6. Verify app loads English (User A's preference)
7. Logout and login as different user
8. Verify new user starts with system default language

### Scenario 4: Persistence Test
1. Login and switch language to English
2. Close app completely
3. Reopen app and login with same user
4. Verify app starts in English (user's saved preference)

## Troubleshooting

If language switching doesn't work:
1. Check that all `.lproj` folders are included in Xcode project
2. Verify `LocalizationManager` is properly initialized
3. Ensure all views use `LocalizedText` or `localizationManager.localizedString()`
4. Check console for any localization errors