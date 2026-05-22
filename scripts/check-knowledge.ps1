$ErrorActionPreference = 'Stop'

function ConvertFrom-CodePoint {
    param([int[]]$CodePoints)

    return -join ($CodePoints | ForEach-Object { [char]$_ })
}

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Add-Issue {
    param(
        [System.Collections.ArrayList]$Issues,
        [string]$Message
    )

    [void]$Issues.Add($Message)
}

$repoRoot = Get-RepoRoot
$docsDir = Join-Path $repoRoot 'docs'
$issues = New-Object System.Collections.ArrayList

$moduleDescriptionTitle = ConvertFrom-CodePoint -CodePoints @(0x6A21, 0x5757, 0x8BF4, 0x660E)
$navigationTitle = ConvertFrom-CodePoint -CodePoints @(0x5BFC, 0x822A)
$learningFocusTitle = ConvertFrom-CodePoint -CodePoints @(0x5B66, 0x4E60, 0x91CD, 0x70B9)
$todoTitle = ConvertFrom-CodePoint -CodePoints @(0x5F85, 0x6574, 0x7406)

$requiredHeadingTitles = @(
    $moduleDescriptionTitle,
    $navigationTitle,
    $learningFocusTitle,
    $todoTitle
)

Get-ChildItem -LiteralPath $docsDir -Directory | ForEach-Object {
    $readmePath = Join-Path $_.FullName 'README.md'
    if (-not (Test-Path -LiteralPath $readmePath)) {
        Add-Issue -Issues $issues -Message "Missing module README: $($_.FullName)"
        return
    }

    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $readmePath
    foreach ($headingTitle in $requiredHeadingTitles) {
        $pattern = '(?m)^#{1,6}\s+' + [regex]::Escape($headingTitle) + '\s*$'
        if ($content -notmatch $pattern) {
            Add-Issue -Issues $issues -Message "Missing required section in $readmePath : $headingTitle"
        }
    }
}

Get-ChildItem -LiteralPath $docsDir -Recurse -File -Filter '*.md' | ForEach-Object {
    $currentFile = $_.FullName
    $name = $_.Name
    if ($name -ne 'README.md' -and $name -notmatch '^[\p{L}\p{Nd}]+([-.][\p{L}\p{Nd}]+)*\.md$') {
        Add-Issue -Issues $issues -Message "Markdown file name should use readable letters/numbers with hyphen or dot separators: $currentFile"
    }

    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $currentFile
    if ($content -notmatch '(?m)^#{1,6}\s+') {
        Add-Issue -Issues $issues -Message "Markdown file has no Markdown heading: $currentFile"
    }

    $dir = $_.DirectoryName
    [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)') | ForEach-Object {
        $target = $_.Groups[1].Value
        if ($target -match '^(https?://|mailto:|#)') {
            return
        }

        $path = ($target -split '#')[0]
        if ([string]::IsNullOrWhiteSpace($path)) {
            return
        }

        $resolved = Join-Path $dir $path
        if (-not (Test-Path -LiteralPath $resolved)) {
            Add-Issue -Issues $issues -Message "Broken local markdown link: $($_.Value) in $currentFile"
        }
    }
}

if ($issues.Count -gt 0) {
    $issues | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output 'Knowledge base check passed.'
