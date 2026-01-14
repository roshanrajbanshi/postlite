# ==============================
# PostLite - Windows Post Exploitation v4
# Lightweight | Signal-Focused
# ==============================

function Print($level, $msg) {
    Write-Host "[$level] $msg"
}

Clear-Host

Write-Host "========================================"
Write-Host " PostLite - Windows Post Exploitation v4 "
Write-Host " Lightweight - Signal Focused            "
Write-Host "========================================"
Write-Host ""

# -------------------------
# v1 — Context
# -------------------------
$os = Get-CimInstance Win32_OperatingSystem
$user = $env:USERNAME
$hostn = $env:COMPUTERNAME
$build = $os.BuildNumber

Print "INFO" "Mode: Local Post-Exploitation"
Print "INFO" "User: $user"
Print "INFO" "Host: $hostn"
Print "INFO" "OS: $($os.Caption)"
Print "INFO" "Windows Build: $build"

$admin = ([Security.Principal.WindowsPrincipal]
          [Security.Principal.WindowsIdentity]::GetCurrent()
         ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($admin) {
    Print "HIGH" "User is in Administrators group"
} else {
    Print "INFO" "User is NOT in Administrators group"
}

# -------------------------
# v2 — UAC Verification
# -------------------------
$uac = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

$EnableLUA = $uac.EnableLUA
$Consent = $uac.ConsentPromptBehaviorAdmin
$SecureDesktop = $uac.PromptOnSecureDesktop

Print "INFO" "UAC EnableLUA: $EnableLUA"
Print "INFO" "ConsentPromptBehaviorAdmin: $Consent"
Print "INFO" "PromptOnSecureDesktop: $SecureDesktop"

if ($EnableLUA -eq 0) {
    Print "CRITICAL" "UAC disabled — full admin token"
} elseif ($Consent -eq 2) {
    Print "INFO" "UAC level: Always Notify"
} elseif ($Consent -eq 5) {
    Print "HIGH" "UAC level: Default (bypass-friendly)"
}

# -------------------------
# v3 — Abuse Surface Signals
# -------------------------
Write-Host ""
Print "INFO" "v3: Abuse Surface Signals"

$whoami = whoami /priv
if ($whoami -match "SeImpersonatePrivilege\s+Enabled") {
    Print "CRITICAL" "SeImpersonatePrivilege enabled"
} else {
    Print "INFO" "No impersonation token detected"
}

$spooler = Get-Service Spooler -ErrorAction SilentlyContinue
if ($spooler -and $spooler.Status -eq "Running") {
    Print "HIGH" "Print Spooler running (named pipe surface)"
}

# -------------------------
# v4 — UAC Exploitability Intelligence
# -------------------------
Write-Host ""
Print "INFO" "v4: UAC Exploitability Signals"

$autoElevated = @(
    "fodhelper.exe",
    "computerdefaults.exe",
    "sdclt.exe",
    "eventvwr.exe"
)

$uacSurface = $false
foreach ($bin in $autoElevated) {
    $path = "$env:SystemRoot\System32\$bin"
    if (Test-Path $path) {
        Print "HIGH" "$bin present (auto-elevated binary)"
        $uacSurface = $true
    }
}

if ([int]$build -lt 19041) {
    Print "HIGH" "Older Windows build — UAC bypass techniques likely"
} else {
    Print "INFO" "Modern Windows build — reduced UAC surface"
}

# -------------------------
# SUMMARY
# -------------------------
Write-Host ""
Write-Host "------------"
Write-Host " SUMMARY "
Write-Host "------------"

if ($EnableLUA -eq 0 -and $admin) {
    Print "CRITICAL" "Full administrative context"
}
elseif ($uacSurface -and $Consent -eq 5) {
    Print "HIGH" "UAC bypass MAY be viable — manual technique required"
}
else {
    Print "INFO" "No immediate exploitation paths detected"
}
