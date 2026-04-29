param(
    [Parameter(Mandatory = $true)]
    [string]$Module,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [ValidateSet('topic', 'troubleshooting', 'source-reading', 'interview', 'learning-record')]
    [string]$Type = 'topic',

    [string]$Slug,

    [switch]$AsDirectory,

    [switch]$Force,

    [switch]$SkipDuplicateCheck,

    [switch]$SkipIndex
)

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Convert-ToSlug {
    param([string]$Value)

    $slugValue = $Value.ToLowerInvariant()
    $slugValue = $slugValue -replace '\s+', '-'
    $slugValue = $slugValue -replace '[^a-z0-9\-]', ''
    $slugValue = $slugValue -replace '-+', '-'
    $slugValue = $slugValue.Trim('-')
    return $slugValue
}

function Get-TemplatePath {
    param(
        [string]$RepoRoot,
        [string]$NoteType
    )

    $templateName = switch ($NoteType) {
        'topic' { 'topic-template.md' }
        'troubleshooting' { 'troubleshooting-template.md' }
        'source-reading' { 'source-reading-template.md' }
        'interview' { 'interview-template.md' }
        'learning-record' { 'learning-record-template.md' }
    }

    return Join-Path (Join-Path $RepoRoot 'templates') $templateName
}

function Set-TemplateTitle {
    param(
        [string]$Content,
        [string]$Title
    )

    $lines = $Content -split "`r?`n"
    if ($lines.Count -gt 0 -and $lines[0] -match '^# ') {
        $lines[0] = "# $Title"
    }
    return ($lines -join "`n")
}

function Get-MarkdownTitle {
    param([string]$Path)

    $heading = Get-Content -Encoding UTF8 -LiteralPath $Path |
        Where-Object { $_ -match '^#\s+' } |
        Select-Object -First 1

    if ($heading) {
        return ($heading -replace '^#\s+', '').Trim()
    }

    return [System.IO.Path]::GetFileNameWithoutExtension($Path)
}

function Find-SimilarNotes {
    param(
        [string]$RepoRoot,
        [string]$Slug,
        [string]$Title
    )

    $docsDir = Join-Path $RepoRoot 'docs'
    $matches = @()

    Get-ChildItem -LiteralPath $docsDir -Recurse -File -Filter '*.md' |
        Where-Object { $_.Name -ne 'README.md' } |
        ForEach-Object {
            $fileSlug = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
            $fileTitle = Get-MarkdownTitle -Path $_.FullName

            if ($fileSlug -eq $Slug -or $fileTitle -eq $Title -or $fileSlug -like "*$Slug*" -or $Slug -like "*$fileSlug*") {
                $matches += $_.FullName
            }
        }

    return $matches
}

$repoRoot = Get-RepoRoot
$moduleName = $Module.ToLowerInvariant()

if ([string]::IsNullOrWhiteSpace($Slug)) {
    $Slug = Convert-ToSlug $Title
}

if ([string]::IsNullOrWhiteSpace($Slug)) {
    throw 'Slug is required when Title cannot be converted to an ASCII file name.'
}

$templatePath = Get-TemplatePath -RepoRoot $repoRoot -NoteType $Type
if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Template not found: $templatePath"
}

$moduleDir = if ($Type -eq 'learning-record') {
    Join-Path (Join-Path $repoRoot 'docs') 'learning-records'
} else {
    Join-Path (Join-Path $repoRoot 'docs') $moduleName
}

if (-not (Test-Path -LiteralPath $moduleDir)) {
    throw "Module does not exist: $moduleName. Create the module README first or choose an existing docs module."
}

$targetPath = if ($AsDirectory) {
    $noteDir = Join-Path $moduleDir $Slug
    New-Item -ItemType Directory -Force -Path $noteDir | Out-Null
    Join-Path $noteDir 'README.md'
} else {
    Join-Path $moduleDir "$Slug.md"
}

if ((Test-Path -LiteralPath $targetPath) -and -not $Force) {
    throw "Target already exists: $targetPath"
}

if (-not $SkipDuplicateCheck -and -not $Force) {
    $similarNotes = @(Find-SimilarNotes -RepoRoot $repoRoot -Slug $Slug -Title $Title)
    if ($similarNotes.Count -gt 0) {
        $message = "Similar note exists. Use -Force to create anyway or choose an existing note:`n" + ($similarNotes -join "`n")
        throw $message
    }
}

$template = Get-Content -Raw -Encoding UTF8 -LiteralPath $templatePath
$content = Set-TemplateTitle -Content $template -Title $Title
Set-Content -Encoding UTF8 -LiteralPath $targetPath -Value $content

if (-not $SkipIndex) {
    & (Join-Path $PSScriptRoot 'update-index.ps1') | Out-Null
}

Write-Output $targetPath
