<#
.SYNOPSIS
    Generates config/file-size-baseline.json from the tracked tree at a git ref (issue #990).

.DESCRIPTION
    Lists the tracked files at -Ref with 'git ls-tree -r --name-only <Ref>', keeps the files the
    shared policy module covers, reads each covered blob at the ref, counts its logical lines as
    the number of lines git returns for the blob (the on-disk equivalent of the logical line rule
    in Get-FileSizeLogicalLineCount), keeps the files above the 800-line hard limit, and writes the
    canonical baseline JSON (ordinal key order, two-space indent, LF, trailing newline). Running it
    twice at the same ref yields byte-identical output.

    Use the merge base of origin/main and HEAD as -Ref, never origin/main itself, so the baseline
    describes the tree the branch started from.

    Git access goes through Invoke-GitExe and the injectable -GitInvoker seam, and the output goes
    through the injectable -Writer seam without newline translation, so the tests run without
    processes or files. The entry point runs only when the script is executed; when it is
    dot-sourced (tests), the guard at the end of the file skips it.

.PARAMETER Ref
    The git ref whose tracked tree is measured.

.PARAMETER OutputPath
    The file to write. Defaults to config/file-size-baseline.json under the current location.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Ref,

    [string] $OutputPath = 'config/file-size-baseline.json'
)
Set-StrictMode -Version Latest
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/lib/file-size-policy/FileSizePolicy.psm1') -Force -ErrorAction Stop
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'FileSizeBaseline.psm1') -Force -ErrorAction Stop

function Invoke-GitExe {
    <#
    .SYNOPSIS
        Runs git with the supplied arguments and returns its exit code and output lines.
    .DESCRIPTION
        The only process boundary of the generator. Standard error is discarded; the caller
        treats a non-zero exit code as a failure.
    .PARAMETER GitArgs
        The git arguments.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $GitArgs
    )

    $lines = @(& git @GitArgs 2>$null)
    $exitCode = [int]$LASTEXITCODE
    return [pscustomobject]@{ ExitCode = $exitCode; Lines = @($lines | ForEach-Object { [string]$_ }) }
}

function Invoke-FileSizeBaselineGit {
    <#
    .SYNOPSIS
        Runs one git command through the seam and throws on a non-zero exit code.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock] $GitInvoker,

        [Parameter(Mandatory = $true)]
        [string[]] $GitArgs
    )

    $result = & $GitInvoker $GitArgs
    if ($result.ExitCode -ne 0) {
        throw "git $($GitArgs -join ' ') failed with exit code $($result.ExitCode)."
    }
    return , @($result.Lines)
}

function Write-FileSizeBaselineText {
    <#
    .SYNOPSIS
        Writes the baseline text to a path as UTF-8 without a byte-order mark or newline translation.
    .PARAMETER Path
        The output path; a relative path resolves against the current location.
    .PARAMETER Text
        The JSON text, already LF-terminated.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Text
    )

    $fullPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path (Get-Location).ProviderPath $Path }
    if ($PSCmdlet.ShouldProcess($fullPath, 'Write file-size baseline')) {
        Set-Content -LiteralPath $fullPath -Value $Text -NoNewline -Encoding utf8NoBOM
    }
}

function New-FileSizeBaseline {
    <#
    .SYNOPSIS
        Measures the covered tracked files at a ref and writes the baseline JSON.
    .PARAMETER Ref
        The git ref whose tracked tree is measured.
    .PARAMETER OutputPath
        The file to write.
    .PARAMETER GitInvoker
        Seam that runs git: receives the argument array and returns ExitCode and Lines.
    .PARAMETER Writer
        Seam that writes the JSON text to a path without newline translation.
    .OUTPUTS
        A PSCustomObject with Ref, OutputPath, Files (path to recorded size), and Json.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Ref,

        [string] $OutputPath = 'config/file-size-baseline.json',

        [scriptblock] $GitInvoker = { param([string[]] $GitArgs) Invoke-GitExe -GitArgs $GitArgs },

        [scriptblock] $Writer = { param([string] $Path, [string] $Text) Write-FileSizeBaselineText -Path $Path -Text $Text }
    )

    $hardLimit = (Get-FileSizePolicyLimit).HardLimit
    $tracked = Invoke-FileSizeBaselineGit -GitInvoker $GitInvoker -GitArgs @('ls-tree', '-r', '--name-only', $Ref)

    $files = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    foreach ($path in $tracked) {
        if (-not (Test-FileSizeCoveredPath -RelativePath $path)) { continue }
        $blobLines = Invoke-FileSizeBaselineGit -GitInvoker $GitInvoker -GitArgs @('cat-file', 'blob', "$($Ref):$path")
        # Count the native element array. Joining the elements with LF is not used because a final
        # empty element makes the joined text end in LF, which Get-FileSizeLogicalLineCount
        # subtracts as a terminator, leaving the count one short of the on-disk line count.
        $count = @($blobLines).Count
        if ($count -gt $hardLimit) {
            $files[$path] = $count
        }
    }

    $json = ConvertTo-FileSizeBaselineJson -Files $files
    if ($PSCmdlet.ShouldProcess($OutputPath, 'Write file-size baseline')) {
        & $Writer $OutputPath $json
    }
    return [pscustomobject]@{ Ref = $Ref; OutputPath = $OutputPath; Files = $files; Json = $json }
}

if ($MyInvocation.InvocationName -ne '.') {
    $result = New-FileSizeBaseline -Ref $Ref -OutputPath $OutputPath
    Write-Information "Wrote $($result.OutputPath) with $($result.Files.Count) entries at $($result.Ref)." -InformationAction Continue
    exit 0
}
