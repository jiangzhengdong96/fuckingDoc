$ErrorActionPreference = 'Stop'

function ConvertFrom-CodePoint {
    param([int[]]$CodePoints)

    return -join ($CodePoints | ForEach-Object { [char]$_ })
}

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Get-MarkdownTitle {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $heading = Get-Content -Encoding UTF8 -LiteralPath $Path |
        Where-Object { $_ -match '^#\s+' } |
        Select-Object -First 1

    if ($heading) {
        return ($heading -replace '^#\s+', '').Trim()
    }

    return [System.IO.Path]::GetFileNameWithoutExtension($Path)
}

function Get-ModuleDescription {
    param([string]$ReadmePath)

    if (-not (Test-Path -LiteralPath $ReadmePath)) {
        return ''
    }

    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $ReadmePath
    $heading = [regex]::Escape($script:ModuleDescriptionHeading)
    $match = [regex]::Match($text, "(?s)$heading\s+(.+?)(\r?\n##\s+)")
    if ($match.Success) {
        return (($match.Groups[1].Value -replace '\r?\n', ' ').Trim())
    }

    return ''
}

function Get-ModuleItems {
    param([string]$ModuleDir)

    $items = @()

    Get-ChildItem -LiteralPath $ModuleDir -File -Filter '*.md' |
        Where-Object { $_.Name -ne 'README.md' } |
        Sort-Object Name |
        ForEach-Object {
            $title = Get-MarkdownTitle -Path $_.FullName
            $items += [PSCustomObject]@{
                Title = $title
                Link = "./$($_.Name)"
            }
        }

    Get-ChildItem -LiteralPath $ModuleDir -Directory |
        Sort-Object Name |
        ForEach-Object {
            $readme = Join-Path $_.FullName 'README.md'
            if (Test-Path -LiteralPath $readme) {
                $title = Get-MarkdownTitle -Path $readme
                $items += [PSCustomObject]@{
                    Title = $title
                    Link = "./$($_.Name)/"
                }
            }
        }

    return $items
}

function Update-ModuleReadme {
    param([string]$ModuleDir)

    $readmePath = Join-Path $ModuleDir 'README.md'
    if (-not (Test-Path -LiteralPath $readmePath)) {
        return
    }

    $items = @(Get-ModuleItems -ModuleDir $ModuleDir)
    if ($items.Count -eq 0) {
        return
    }

    $navigation = ($items | ForEach-Object { "- [$($_.Title)]($($_.Link))" }) -join "`n"
    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $readmePath

    $heading = [regex]::Escape($script:NavigationHeading)
    $pattern = "(?s)($heading\s+).*?(\r?\n##\s+)"
    $updated = [regex]::Replace($content, $pattern, {
        param($match)
        return $match.Groups[1].Value + $navigation + "`n`n" + $match.Groups[2].Value
    }, 1)

    Set-Content -Encoding UTF8 -LiteralPath $readmePath -Value $updated
}

$repoRoot = Get-RepoRoot
$docsDir = Join-Path $repoRoot 'docs'
$indexPath = Join-Path $docsDir 'index.md'
$script:ModuleDescriptionHeading = '## ' + (ConvertFrom-CodePoint @(0x6A21, 0x5757, 0x8BF4, 0x660E))
$script:NavigationHeading = '## ' + (ConvertFrom-CodePoint @(0x5BFC, 0x822A))

$modules = @(Get-ChildItem -LiteralPath $docsDir -Directory | Sort-Object Name)

foreach ($module in $modules) {
    Update-ModuleReadme -ModuleDir $module.FullName
}

$rows = foreach ($module in $modules) {
    $readmePath = Join-Path $module.FullName 'README.md'
    if (-not (Test-Path -LiteralPath $readmePath)) {
        continue
    }

    $title = Get-MarkdownTitle -Path $readmePath
    $description = Get-ModuleDescription -ReadmePath $readmePath
    $noteCount = @(Get-ModuleItems -ModuleDir $module.FullName).Count
    "| [$title](./$($module.Name)/) | $description | $noteCount |"
}

$indexTitle = '# ' + (ConvertFrom-CodePoint -CodePoints @(0x5168, 0x5C40, 0x7D22, 0x5F15))
$indexDescriptionPrefix = ConvertFrom-CodePoint -CodePoints @(0x8FD9, 0x91CC, 0x6309, 0x6A21, 0x5757, 0x6C47, 0x603B, 0x6280, 0x672F, 0x76EE, 0x5F55, 0x3002, 0x65B0, 0x589E, 0x3001, 0x79FB, 0x52A8, 0x6216, 0x5220, 0x9664, 0x7B14, 0x8BB0, 0x540E, 0xFF0C, 0x8FD0, 0x884C)
$indexDescriptionSuffix = ConvertFrom-CodePoint -CodePoints @(0x81EA, 0x52A8, 0x5237, 0x65B0, 0x672C, 0x6587, 0x4EF6, 0x3002)
$moduleHeader = ConvertFrom-CodePoint -CodePoints @(0x6A21, 0x5757)
$descriptionHeader = ConvertFrom-CodePoint -CodePoints @(0x8BF4, 0x660E)
$notesHeader = ConvertFrom-CodePoint -CodePoints @(0x5DF2, 0x6574, 0x7406)
$tableHeader = '| ' + $moduleHeader + ' | ' + $descriptionHeader + ' | ' + $notesHeader + ' |'

$index = @(
    $indexTitle
    ''
    ($indexDescriptionPrefix + ' `scripts/update-index.ps1` ' + $indexDescriptionSuffix)
    ''
    $tableHeader
    '|---|---|---:|'
    ($rows -join "`n")
) -join "`n"

Set-Content -Encoding UTF8 -LiteralPath $indexPath -Value $index
Write-Output "Updated index: $indexPath"
