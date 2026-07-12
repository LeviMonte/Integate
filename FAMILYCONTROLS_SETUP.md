# FamilyControls Setup — Xcode Steps

These are one-time Xcode configuration steps to wire up real app blocking.
Do these in order, then build and run.

---

## Step 1 — Main App: Add Capabilities

Select the **Integate** target (blue icon at the top of the file list) →
**Signing & Capabilities** tab → click **+ Capability** (top left).

Add these three:

| Capability | Notes |
|---|---|
| **Family Controls** | The core entitlement for real blocking |
| **App Groups** | Shared UserDefaults between main app and extensions |
| **Push Notifications** | Already added if you set up local notifications |

For **App Groups**, click the `+` button and add:
```
group.com.levimonte.integate
```
(swap `levimonte.integate` if your bundle ID is different, but keep the `group.` prefix)

---

## Step 2 — Create the ShieldConfigurationExtension target

In Xcode: **File → New → Target** → scroll down to find:

> **Shield Configuration Extension**

Name it: `ShieldConfigurationExtension`  
Language: Swift  
Project: Integate

When Xcode creates it:
1. Delete the auto-generated `.swift` file it creates (it will be empty boilerplate).
2. Drag `ShieldConfigurationExtension/ShieldConfigurationExtension.swift` from the sidebar into this target's group folder.
3. Make sure the file's **Target Membership** checkbox (right panel, Inspector) is set to **ShieldConfigurationExtension** only (not the main app).

Add the **App Groups** capability to this target too, with the same group ID:
```
group.com.levimonte.integate
```

In **Build Phases → Link Binary With Libraries**, add:
- `ManagedSettingsUI.framework`
- `ManagedSettings.framework`

---

## Step 3 — Create the ShieldActionExtension target

Same process: **File → New → Target** →

> **Shield Action Extension**

Name it: `ShieldActionExtension`  
Language: Swift

1. Delete the auto-generated file.
2. Drag `ShieldActionExtension/ShieldActionExtension.swift` into this target's group.
3. Add **App Groups** capability with the same group ID.
4. In **Build Phases → Link Binary With Libraries**, add `ManagedSettings.framework`.

---

## Step 4 — Check Info.plist for each extension

Xcode usually auto-generates a correct Info.plist for each extension.
The key it needs is:
```
NSExtension → NSExtensionPrincipalClass → $(PRODUCT_MODULE_NAME).ShieldConfigurationExtension
```
(Xcode fills this in automatically when you use the template.)

---

## Step 5 — Build and test on a real device

The Family Controls permission dialog and actual app-blocking **do not work in the Simulator**. You must run on a real iPhone.

First run flow:
1. Launch the app.
2. Go to **Settings → Manage Blocked Apps**.
3. Tap **Grant Permission** — iOS shows a Screen Time permission sheet.
4. Approve it.
5. Tap **Choose Apps to Block** — the system `FamilyActivityPicker` appears.
6. Select an app (e.g. Instagram).
7. Tap Done.
8. Press the Home button and open Instagram.
9. The custom shield should appear immediately: "Solve to Unlock / Open Integate →"

---

## How the flow works end-to-end

```
User opens Instagram
   ↓
iOS sees it's shielded (ManagedSettingsStore.shield.applications)
   ↓
ShieldConfigurationExtension draws the custom screen
   ↓
User taps "Open Integate →"
   ↓
ShieldActionExtension writes mg_pendingUnlock=true to App Group UserDefaults
   ↓
Shield closes → user is on home screen
   ↓
User taps Integate
   ↓
hasPendingUnlockRequest == true → blue "Solve to Unlock" banner appears
   ↓
User solves a problem
   ↓
grantTime(seconds:) is called → ManagedSettingsStore.clearAllSettings()
   ↓
Shields are lifted — Instagram (and all blocked apps) open normally
   ↓
Timer counts down → applyRestrictions() re-shields everything automatically
```

---

## Troubleshooting

**Shield doesn't appear?**
- Make sure the App Group ID in `ScreenTimeManager.appGroupID` and `ShieldActionExtension.appGroupID` are identical.
- Check that both extension targets have the App Groups capability set.
- Make sure you called `requestAuthorization()` and it returned `.approved`.

**"Family Controls" capability not showing?**
- You need an Apple Developer account (any tier). Make sure you're signed into Xcode with your dev account under Xcode → Settings → Accounts.

**Build error: "ManagedSettingsUI not found"?**
- Select the ShieldConfigurationExtension target → Build Phases → Link Binary With Libraries → `+` → search ManagedSettingsUI.
