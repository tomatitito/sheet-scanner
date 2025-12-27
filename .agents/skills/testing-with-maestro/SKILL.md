---
name: testing-with-maestro
description: Automates mobile and web app testing using Maestro, a declarative YAML-based UI testing framework. Captures screenshots, tests user flows, and validates functionality across iOS, Android, Flutter, and web apps. Use for app testing, screenshot generation, UI automation, and end-to-end testing workflows.
---

# Testing with Maestro

Maestro is a lightweight, open-source framework for mobile and web UI testing. It uses YAML-based test definitions (called "flows") to automate user journeys, take screenshots, and validate app functionality without complex setup or test harnesses.

## Quick Reference

Maestro is installed and available as `maestro` CLI.

Key commands:
- `maestro test <flow.yaml>` - Run a single flow
- `maestro test --include-tags <tag> .` - Run flows with specific tags
- `maestro test <dir> --output-dir <path>` - Run all flows in directory with custom screenshot location
- `maestro studio` - Open interactive testing IDE (GUI)

## Supported Platforms

Maestro works cross-platform for:
- **Mobile**: iOS (UIKit, SwiftUI), Android (Views, Jetpack Compose)
- **Hybrid**: React Native, Flutter, Flutter Web
- **Web**: Desktop browsers, WebViews, web applications
- **Accessibility**: Biometric authentication, push notifications, device gestures

## YAML Flow Structure

Flows are YAML files that define test sequences. Basic structure:

```yaml
appId: com.example.myapp  # Required for mobile apps
---                        # Separator between metadata and steps
- launchApp                # Start the app
- tapOn: "Button Label"    # Tap by visible text
- tapOn:
    text: "Username"
    type: "TextField"      # Type selector
- inputText: "john@example.com"
- takeScreenshot: LoginScreen
- assertVisible: "Welcome"
```

For web apps, use `url` instead of `appId`:

```yaml
url: https://example.com
---
- launchApp
- tapOn: "Sign in"
- assertVisible: "Dashboard"
```

## Core Commands

### Navigation
- `launchApp` - Start the application
- `back` - Press back button (mobile)
- `openLink: <url>` - Open a URL in browser (web)

### Interaction
- `tapOn: <text>` - Tap element by visible text (simplest, most reliable)
- `inputText: <text>` - Type into focused text field
- `tapOn: { id: "element_id" }` - Tap by element identifier (fallback)
- `swipe:` - Swipe gesture (up/down/left/right)
- `scroll:` - Scroll in a direction
- `longPress:` - Long-press on element
- `waitForAnimationToEnd:` - Wait for animations to complete

### Verification
- `takeScreenshot: <name>` - Save screenshot (stored in `.maestro/` by default)
- `assertVisible: <text>` - Verify text/element is visible
- `assertNotVisible: <text>` - Verify element is NOT visible
- `assertWithAI: <description>` - AI-powered assertion (check if screen matches description)

### Control Flow
- `runFlow: <path/to/flow.yaml>` - Reuse flows (parametric flows supported)
- `repeat: 5` - Repeat next command N times
- `onFlow: <flow.yaml>` - Conditional flow execution
- `sleep: 2` - Wait N seconds (use sparingly—Maestro auto-waits)

### Configuration
- `env:` - Set environment variables
- `config:` - Configure timeouts, retries, tolerance
- `tags: [smoke, regression]` - Mark flows for selective execution

## Best Practices

### 1. Use Text Over IDs When Possible
Good:
```yaml
- tapOn: "Add Sheet Music"  # Uses visible text—resilient to UI changes
```

Bad:
```yaml
- tapOn:
    id: "button_123"        # ID may change; brittle
```

Text selectors survive UI refactoring. Only use IDs when labels are dynamic or non-unique.

### 2. Avoid Hardcoded Waits
Bad:
```yaml
- sleep: 3  # Hope the server responds in 3 seconds
```

Good:
```yaml
- tapOn: "Search"
- assertVisible: "Results"  # Auto-waits up to timeout
- takeScreenshot: SearchResults
```

Maestro auto-waits for elements. Only use `sleep` for animations or special cases.

### 3. Test User Flows, Not Implementation Details
Good:
```yaml
- launchApp
- tapOn: "Title"
- inputText: "Moonlight Sonata"
- tapOn: "Add"
- assertVisible: "Sheet added"
```

Bad:
```yaml
- launchApp
- tapOn: { id: "text_field_1" }  # Implementation detail
- inputText: "Moonlight Sonata"
- tapOn: { id: "submit_btn" }
```

Test **what users do**, not internal IDs. Tests should remain stable across refactors.

### 3. Organize Flows by Feature
```
.maestro/
├── flows/
│   ├── authentication/
│   │   ├── login.yaml
│   │   ├── logout.yaml
│   │   └── signup.yaml
│   ├── sheet_music/
│   │   ├── add_sheet.yaml
│   │   ├── edit_sheet.yaml
│   │   └── search.yaml
│   └── common/
│       └── launch.yaml
```

### 4. Use Environment Variables for Dynamic Data
```yaml
env:
  USERNAME: ${ENV_USERNAME:-guest@example.com}
  PASSWORD: ${ENV_PASSWORD:-password123}
---
- launchApp
- tapOn: "Email"
- inputText: ${USERNAME}
- tapOn: "Password"
- inputText: ${PASSWORD}
- tapOn: "Sign In"
```

Run with:
```bash
ENV_USERNAME="john@example.com" maestro test flows/login.yaml
```

### 5. Reuse Flows for Common Actions
Common flow (`flows/common/launch_and_login.yaml`):
```yaml
env:
  EMAIL: ${EMAIL:-test@example.com}
  PASSWORD: ${PASSWORD:-test123}
---
- launchApp
- tapOn: "Sign In"
- inputText: ${EMAIL}
- tapOn: "Password"
- inputText: ${PASSWORD}
- tapOn: "Login"
- assertVisible: "Dashboard"
```

Flow that uses it (`flows/sheet_music/add_sheet.yaml`):
```yaml
---
- runFlow: flows/common/launch_and_login.yaml
- tapOn: "Add Sheet"
- inputText: "Nocturne in E-flat Major"
- tapOn: "Save"
- assertVisible: "Sheet added"
- takeScreenshot: SheetAdded
```

### 6. Tag Flows for Selective Runs
```yaml
tags: [smoke, ios]
appId: com.example.app
---
- launchApp
- assertVisible: "Home"
```

Run only smoke tests:
```bash
maestro test --include-tags smoke .
```

## Screenshot Generation

Maestro is perfect for automated screenshot generation for app store listings:

```yaml
env:
  LANG: de_DE  # German locale for German screenshots
---
- launchApp
- takeScreenshot: 01_HomeScreen
- tapOn: "Add"
- takeScreenshot: 02_AddSheetForm
- inputText: "Beethoven"
- takeScreenshot: 03_Autocomplete
- tapOn: "Beethoven - 5th Symphony"
- takeScreenshot: 04_SelectedSheet
```

Run for each language/locale:
```bash
LANG=en_US maestro test flows/screenshots.yaml --output-dir screenshots/en_US
LANG=de_DE maestro test flows/screenshots.yaml --output-dir screenshots/de_DE
LANG=fr_FR maestro test flows/screenshots.yaml --output-dir screenshots/fr_FR
```

Screenshots are saved as PNG files in `.maestro/` or your specified `--output-dir`.

## Testing Flutter Apps

Maestro fully supports Flutter on both iOS and Android. Flutter tests are identical to native tests—just use app-visible text.

### Example: Sheet Scanner Add Flow
```yaml
appId: com.example.sheetscanner
tags: [smoke, android, ios]
---
- launchApp
- assertVisible: "Add Sheet Music"
- tapOn: "Add Sheet Music"
- assertVisible: "Title"
- tapOn: "Title"
- inputText: "Moonlight Sonata"
- tapOn: "Composer"
- inputText: "Beethoven"
- tapOn: "Add Sheet Music"
- assertVisible: "Sheet music\"Moonlight Sonata\" added successfully"
- takeScreenshot: AddSheetSuccess
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  maestro:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.19.x
      
      - name: Build Android APK
        run: flutter build apk --debug
      
      - name: Install Maestro
        run: curl -Ls "https://get.maestro.dev" | bash
      
      - name: Run E2E tests
        run: maestro test --include-tags smoke .
      
      - name: Upload screenshots
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: maestro-screenshots
          path: .maestro/
```

### Running Locally for Debugging

1. Start your app on an emulator or connected device
2. Open Maestro Studio for interactive debugging:
   ```bash
   maestro studio
   ```
3. Or run flows directly:
   ```bash
   maestro test flows/add_sheet.yaml
   ```

## Troubleshooting

### Element Not Found
**Problem**: `tapOn: "Label"` fails because text doesn't match exactly.

**Solution**:
- Use substring matching: `tapOn: "Part of Label"`
- Check actual text with `maestro studio` element inspector
- Enable debug output: `maestro test --verbose flows/test.yaml`

### Timeout Waiting for Element
**Problem**: Test waits too long for an element that never appears.

**Solution**:
- Increase timeout (default 30s): 
  ```yaml
  config:
    timeout: 60
  ```
- Add intermediate assertions:
  ```yaml
  - tapOn: "Search"
  - assertVisible: "Loading..."
  - assertVisible: "Results"
  ```

### App Crashes During Test
**Problem**: App state is dirty between test runs.

**Solution**:
- Clear app data between flows:
  ```bash
  maestro test flows/test.yaml --clear-app-state
  ```

### Flaky Tests
**Problem**: Tests pass randomly but fail sometimes.

**Solution**:
- Avoid hardcoded sleeps—use assertions
- Wait for animations: `- waitForAnimationToEnd:`
- Use AI assertions for visual stability: `- assertWithAI: "User logged in"`

## Advanced Features

### AI-Powered Assertions
```yaml
- assertWithAI: "The sheet 'Moonlight Sonata' is displayed correctly"
```

Maestro uses AI to validate screen state, more resilient than text matching.

### Parametric Flows
```yaml
# flows/edit_sheet.yaml
params:
  - sheetTitle
  - newTitle
---
- launchApp
- tapOn: ${sheetTitle}
- tapOn: "Edit"
- inputText: ${newTitle}
- tapOn: "Save"
```

Call from another flow:
```yaml
- runFlow:
    file: flows/edit_sheet.yaml
    params:
      sheetTitle: "Original Title"
      newTitle: "Updated Title"
```

## Resources

- **Official Docs**: https://docs.maestro.dev/
- **GitHub**: https://github.com/mobile-dev-inc/maestro
- **Slack Community**: https://slack.maestro.dev
- **Maestro Studio (GUI)**: https://studio.maestro.dev/
