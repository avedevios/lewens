# Lewens App Localization

## Supported Languages

The application supports the following languages:
- **German (de)** - default language
- **English (en)**
- **Polish (pl)**

## Localization File Structure

```
lewens/
├── de.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── en.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
└── pl.lproj/
    ├── Localizable.strings
    └── InfoPlist.strings
```

## How to Add New Translations

1. Add a new key to `LocalizationKeys` in the `Utils/LocalizationHelper.swift` file
2. Add translations for all supported languages in the corresponding `Localizable.strings` files
3. Use the key in code: `LocalizationKeys.yourKey.localized`

## Language Switching

Users can switch languages in the "Profile" section after authentication.

## Default Language Configuration

The default language (German) is configured in `Info.plist`:
- `CFBundleDevelopmentRegion` = `de`
- `CFBundleLocalizations` contains all supported languages

## Testing Localization

To test different languages:
1. Change the language in app settings (Profile → Language)
2. Or change the system language in iOS settings
3. Restart the app to apply changes