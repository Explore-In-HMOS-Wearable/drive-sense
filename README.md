> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Drive Sense
A HarmonyOS ArkTS wearable app that monitors and evaluates driving behavior in real time. It uses accelerometer and gyroscope sensors to detect harsh braking, sharp turns, and stop-and-go events, providing instant feedback with animations and storing driving summaries locally.

# Preview
<div>
    <img src="screenshots/project.gif" width="25%"> 
</div>

# Use Cases
- Start/stop driving session with one click
- Analyze real-time accelerometer and gyroscope data
- Detect harsh braking, sharp turns, and stop-go behavior
- Provide instant animations for risky events
- Store summaries locally in RDB
- Swipe-to-delete history items

# Technology

## Stack
- **Languages:** ArkTS (TypeScript)
- **UI:** ArkUI (`@kit.ArkUI`) with declarative Stage model
- **Tools/IDE:** DevEco Studio **5.1.0.260**
- **SDK:** HarmonyOS SDK **5.1.0.54**
- **Libraries:** SensorServiceKit, BackgroundTasksKit, AbilityKit, RDB
- **Navigation:** `NavPathStack` with slide transitions

## Required Permissions
- `ohos.permission.ACCELEROMETER`
- `ohos.permission.GYROSCOPE`
- `ohos.permission.RUN_BACKGROUND`

# Directory Structure
```
src/main/ets/
├── animation/
│   └── LottieAnimation.ets
├── entryability/
│   └── EntryAbility.ets
├── entrybackupability/
│   └── EntryBackupAbility.ets
├── model/
│   ├── DriveSummary.ets
│   └── TableDefinition.ets
├── pages/
│   ├── Index.ets
│   ├── DetailPage.ets
│   ├── HistoryPage.ets
│   └── SplashPage.ets
├── service/
│   ├── HistoryTable.ets
│   └── Rdb.ets
├── util/
│   ├── ConstantUI.ets
│   ├── CommonConstantsDb.ets
│   └── Logger.ets
└── viewmodel/
    └── DriveSummaryViewModel.ets
```

# Constraints and Restrictions

## Supported Device
- Huawei Watch 5 (HarmonyOS 5.1.0+)

## App Limits
- Works only on real devices with motion sensors
- No backend, summaries stored locally
- Optimized for wearable performance and battery

# License
**Drive Sense** is distributed under the terms of the MIT License.  
See the [LICENSE](./LICENSE) file for details.
