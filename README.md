# LogicMonitor.Scripts

## PowerShellCore

PowerShell Core scripts

- CreateCredentialsFile.ps1

    Creates a LogicMonitorCreds.json file with encrypted API key.
    
    Can be invoked with

    ```
    pwsh -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/panoramicsystems/LogicMonitor.Scripts/blob/main/LogicMonitor.Scripts/CreateCredentialsFile.ps1'))"
    ```

- AddOpsNote.ps1

    Adds OpsNotes - uses the LogicMonitorCreds.json file