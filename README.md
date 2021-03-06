# LogicMonitor.Scripts

## PowerShellCore

PowerShell Core scripts

### CreateCredentialsFile.ps1

Creates a LogicMonitorCreds.json file with encrypted API key.

Can be invoked with

```
pwsh -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/panoramicsystems/LogicMonitor.Scripts/main/PowerShellCore/CreateCredentialsFile.ps1'))"
```

### AddOpsNote.ps1

Adds OpsNotes - uses the LogicMonitorCreds.json file

Download the file using wget or similar: 
```
wget https://raw.githubusercontent.com/panoramicsystems/LogicMonitor.Scripts/main/PowerShellCore/AddOpsNote.ps1
```

Usage:

Create a system wide OpsNote
```
pwsh -Command ./AddOpsNote.ps1 "Creating an OpsNote"
```

Create an OpsNote for one or more DeviceGroups/WebSiteGroups
```
pwsh -Command ./AddOpsNote.ps1 "Creating an OpsNote" -deviceGroupIds x,y,z -websiteGroupIds x,y,z
```
