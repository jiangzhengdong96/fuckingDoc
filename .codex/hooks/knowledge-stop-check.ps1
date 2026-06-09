$ErrorActionPreference = 'Stop'

function Write-HookMessage {
    param([string]$Message)

    @{
        continue = $true
        systemMessage = $Message
    } | ConvertTo-Json -Compress
}

function Invoke-And-Capture {
    param([string]$ScriptPath)

    $output = & $ScriptPath 2>&1
    $exitCode = $LASTEXITCODE

    return [PSCustomObject]@{
        ExitCode = $exitCode
        Output = ($output | Out-String).Trim()
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$changedFiles = @(git -C $repoRoot diff --name-only --diff-filter=ACMRTD HEAD 2>$null)
$gitExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

if ($gitExitCode -ne 0) {
    Write-HookMessage 'Knowledge hook skipped: unable to read git changes.'
    exit 0
}

$knowledgeFiles = $changedFiles | Where-Object {
    $_ -match '^(docs/|templates/|AGENT\.md$|CONTRIBUTING\.md$|\.agents/skills/)'
}

if (-not $knowledgeFiles -or $knowledgeFiles.Count -eq 0) {
    exit 0
}

$indexFiles = $changedFiles | Where-Object {
    $_ -match '^(docs/|templates/)'
}

$updateScript = Join-Path $repoRoot 'scripts\update-index.ps1'
$checkScript = Join-Path $repoRoot 'scripts\check-knowledge.ps1'

if ($indexFiles -and $indexFiles.Count -gt 0) {
    $updateResult = Invoke-And-Capture -ScriptPath $updateScript
    if ($updateResult.ExitCode -ne 0) {
        Write-HookMessage ("Knowledge hook: update-index failed. " + $updateResult.Output)
        exit 0
    }
}

$checkResult = Invoke-And-Capture -ScriptPath $checkScript
if ($checkResult.ExitCode -ne 0) {
    $lines = @($checkResult.Output -split "`r?`n" | Select-Object -First 8)
    $summary = ($lines -join ' | ')
    Write-HookMessage ("Knowledge hook: check-knowledge failed. " + $summary)
    exit 0
}

if ($indexFiles -and $indexFiles.Count -gt 0) {
    Write-HookMessage 'Knowledge hook: index refreshed and knowledge check passed.'
} else {
    Write-HookMessage 'Knowledge hook: knowledge check passed.'
}
