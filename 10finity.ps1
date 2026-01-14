# 10finity.ps1
# Make Windows 10 as safe and usable as possible
#
# NEVER RUN CODE YOU DON'T INSPECT YOURSELF
#
# Usage:
# 1. Run PowerShell as Administrator.
# 2. Set-ExecutionPolicy RemoteSigned (if needed).
# 3. Run the script: .\10finity.ps1
#
# Toggle features below by setting to $true or $false. Comment out lines to disable entirely if preferred.

# Toggle Variables - Set to $true to enable the action, $false to skip.
$RemovePreinstalledApps = $true      # Remove bloatware apps like Candy Crush, Xbox, etc.
$DisableTelemetry = $true            # Disable Microsoft telemetry and data collection.
$RemoveOneDrive = $true              # Uninstall OneDrive and prevent reinstall.
$DisableCortana = $true              # Disable Cortana search features.
$OptimizePerformance = $true         # Tweak for better performance (e.g., disable animations).
$DisableUnnecessaryServices = $true  # Stop and disable non-essential services.
$RemoveCopilot = $true               # Remove Copilot if present (may not apply to all Win10 builds).
$DisableWindowsUpdate = $false       # Disable Windows Update (risky, use only if you know what you're doing for post-EOL).
$RemoveEdge = $true                  # Remove Microsoft Edge (note: may affect some features).
$EnhancePrivacy = $true              # Additional privacy tweaks (e.g., disable location, advertising ID).
$DisableAggressiveServices = $true   # Aggressively disable Windows System Services, except for core functionality.

# Function: Remove Preinstalled Bloatware Apps
function Remove-PreinstalledApps {
    Write-Host "Removing preinstalled bloatware apps..."
    $appsToRemove = @(
        "Microsoft.3DBuilder",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MixedReality.Portal",
        "Microsoft.Office.OneNote",
        "Microsoft.OneConnect",
        "Microsoft.People",
        "Microsoft.Print3D",
        "Microsoft.SkypeApp",
        "Microsoft.Wallet",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCamera",
        "Microsoft.windowscommunicationsapps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo"
    )
    
    foreach ($app in $appsToRemove) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Write-Host "Preinstalled apps removed."
}

# Function: Disable Telemetry
function Disable-Telemetry {
    Write-Host "Disabling telemetry..."
    # Disable telemetry services
    Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue
    Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
    
    # Registry tweaks
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    Write-Host "Telemetry disabled."
}

# Function: Remove OneDrive
function Remove-OneDrive {
    Write-Host "Removing OneDrive..."
    taskkill /f /im OneDrive.exe
    %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
    reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
    reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
    Write-Host "OneDrive removed."
}

# Function: Disable Cortana
function Disable-Cortana {
    Write-Host "Disabling Cortana..."
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
    Write-Host "Cortana disabled."
}

# Function: Optimize Performance
function Optimize-Performance {
    Write-Host "Optimizing performance..."
    # Disable visual effects
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
    # Set power plan to high performance
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Host "Performance optimized."
}

# Function: Disable Unnecessary Services
function Disable-UnnecessaryServices {
    Write-Host "Disabling unnecessary services..."
    $servicesToDisable = @(
        "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "WMPNetworkSvc", "TabletInputService",
        "RetailDemo", "Fax", "WbioSrvc", "icssvc", "MapsBroker"
    )
    
    foreach ($service in $servicesToDisable) {
        Stop-Service -Name $service -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Write-Host "Unnecessary services disabled."
}

# Function: Remove Copilot (if applicable, mostly Win11 but for previews in Win10)
function Remove-Copilot {
    Write-Host "Removing Copilot..."
    Get-AppxPackage -Name "Microsoft.Windows.Copilot" | Remove-AppxPackage -ErrorAction SilentlyContinue
    reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f
    Write-Host "Copilot removed."
}

# Function: Disable Windows Update (Caution: This prevents security updates!)
function Disable-WindowsUpdate {
    Write-Host "Disabling Windows Update..."
    Stop-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
    Write-Host "Windows Update disabled."
}

# Function: Remove Microsoft Edge
function Remove-Edge {
    Write-Host "Removing Microsoft Edge..."
    Get-AppxPackage -Name "Microsoft.MicrosoftEdge" | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Additional cleanup if needed
    $edgePath = "$env:ProgramFiles(x86)\Microsoft\Edge\Application"
    if (Test-Path $edgePath) {
        Start-Process "$edgePath\msedge.exe" -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall"
    }
    Write-Host "Microsoft Edge removed."
}

# Function: Enhance Privacy
function Enhance-Privacy {
    Write-Host "Enhancing privacy..."
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v LocationEnabled /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f
    Write-Host "Privacy enhanced."
}

function Disable-NonEssentialServicesAggressive {
    <#
    .SYNOPSIS
        Aggressively disables many non-essential Windows services for maximum performance
        and minimal background activity (ideal for gaming / stripped-down Win10 installs)
        
    .WARNING
        This is significantly more aggressive than moderate versions.
        May break: printing, bluetooth, mobile hotspot, some location features,
        Delivery Optimization, push notifications, etc.
        
        Recommended for clean installs, gaming PCs, privacy-focused minimal setups.
        NOT recommended for work machines or if you use many peripherals.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [switch]$WhatIf
    )

    Write-Host "`nAggressive Non-Essential Services Disable (Power-user / Gaming Mode)" -ForegroundColor Cyan
    Write-Host "This will disable many background services — use with caution!" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C now if you're unsure.`n" -ForegroundColor DarkYellow

    $services = @(
        # Gaming / Xbox ecosystem
        "XblAuthManager",
        "XblGameSave",
        "XboxNetApiSvc",
        "XboxGipSvc",

        # Telemetry & Diagnostics
        "DiagTrack",
        "dmwappushservice",
        "lfsvc",
        "MapsBroker",

        # Print & Scan (disable if you never use them)
        #"Spooler",                 # ← Only uncomment if you NEVER print
        "PrintNotify",
        "PrintWorkflowUserSvc_*",

        # Networking & Sharing (mostly legacy or P2P)
        "AJRouter",
        "ALG",
        "DoSvc",
        "iphlpsvc",
        "PeerDistSvc",
        "SharedAccess",
        "WMPNetworkSvc",

        # Other bloat / niche features
        "TabletInputService",
        "RetailDemo",
        "Fax",
        "WbioSrvc",
        "icssvc",
        "PhoneSvc",
        "WalletService",
        "CaptureService_*",
        "AppReadiness",
        "WpnService",
        "WpnUserService_*",
        "PcaSvc",
        "TrkWks",
        "Wecsvc",
        "SCardSvr",
        "SCPolicySvc"
    )

    Write-Host "Processing services...`n" -ForegroundColor Cyan

    $countDisabled = 0
    $countSkipped  = 0

    foreach ($serviceName in $services) {
        if ($serviceName -like "*_*") {
            # Handle wildcard services
            Get-Service -Name $serviceName -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $name = $_.Name
                    if ($_.StartType -eq 'Disabled') {
                        Write-Host "   $name → Already disabled" -ForegroundColor DarkGray
                        $countSkipped++
                    }
                    elseif ($PSCmdlet.ShouldProcess($name, "Stop and Disable")) {
                        Stop-Service -Name $name -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                        Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
                        Write-Host "   $name → Disabled" -ForegroundColor Green
                        $countDisabled++
                    }
                }
        }
        else {
            $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($svc) {
                if ($svc.StartType -eq 'Disabled') {
                    Write-Host "   $($svc.Name) → Already disabled" -ForegroundColor DarkGray
                    $countSkipped++
                }
                elseif ($PSCmdlet.ShouldProcess($svc.Name, "Stop and Disable")) {
                    Stop-Service -Name $svc.Name -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                    Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Host "   $($svc.Name) → Disabled" -ForegroundColor Green
                    $countDisabled++
                }
            }
            else {
                Write-Host "   $serviceName → Not found on this system" -ForegroundColor DarkGray
                $countSkipped++
            }
        }
    }

    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "Successfully disabled : $countDisabled services" -ForegroundColor Green
    Write-Host "Already disabled / not found : $countSkipped" -ForegroundColor DarkGray
    Write-Host "`nRecommendation: Reboot your system for full effect." -ForegroundColor DarkCyan
    Write-Host "If something breaks → services.msc → find the service → set to Manual/Automatic`n"
}

# Main Execution
Write-Host "Starting Windows 10 Debloat and Optimization..."

if ($RemovePreinstalledApps) { Remove-PreinstalledApps }
if ($DisableTelemetry) { Disable-Telemetry }
if ($RemoveOneDrive) { Remove-OneDrive }
if ($DisableCortana) { Disable-Cortana }
if ($OptimizePerformance) { Optimize-Performance }
if ($DisableUnnecessaryServices) { Disable-UnnecessaryServices }
if ($RemoveCopilot) { Remove-Copilot }
if ($DisableWindowsUpdate) { Disable-WindowsUpdate }
if ($RemoveEdge) { Remove-Edge }
if ($EnhancePrivacy) { Enhance-Privacy }
if ($DisableAggressiveServices) { Disable-NonEssentialServicesAggressive }

Write-Host "Debloat and optimization complete. Restart your computer for changes to take effect."
