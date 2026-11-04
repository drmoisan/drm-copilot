<#
.SYNOPSIS
    Entry script of the documentation tooling: parameters, dispatch table, argument parsing, the
    real command context, output and exit code.

.DESCRIPTION
    Invoke-DocsCommand.ps1 -Command <name> [-Json] [-Help] [-RepositoryRoot <path>] [options]
    dispatches to the command function named by the dispatch table row of <name>, importing that
    row's module only when the row is selected. Exit codes: 0 success or -Help, 1 error findings,
    2 usage error (exactly one DOCS_CLI_ARGUMENTS finding, result null), 3 internal or
    environment error (exactly one finding, one stderr line). With -Json stdout receives one
    canonical JSON envelope {command, exit_code, findings, ok, result}; otherwise the text
    report, ending with the summary line.

    The top-level body runs only when the script is not dot-sourced, so tests dot-source it to
    load its functions. The body writes the outcome of Invoke-DocsCommandCli and exits.

    The real command context reads and writes under RepositoryRoot. Its InvokeProcess member
    forwards unchanged to the thin seam Invoke-DocsProcess; argument validation and result
    shaping are the pure functions ConvertTo-DocsProcessRequest and ConvertTo-DocsProcessResult.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this script fails fast at script scope and imports its siblings with -ErrorAction Stop.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [string] $Command,
    [switch] $Json,
    [switch] $Help,
    [string] $RepositoryRoot,
    [Parameter(ValueFromRemainingArguments = $true)] [string[]] $CommandArgument
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop

function Get-DocsCommandTable {
    <#
    .SYNOPSIS
        Returns the dispatch table: one row per subcommand under its owner's anchor.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    return , [object[]]@(
        # --- 1020: init, validate-profile ---
        [pscustomobject]@{ Name = 'init'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsInitCommand'; Option = @{ RepositoryId = 'value'; Profile = 'value'; Write = 'switch'; Force = 'switch' } }
        [pscustomobject]@{ Name = 'validate-profile'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsValidateProfileCommand'; Option = @{ Profile = 'value' } }
        # --- 1021: check ---
        [pscustomobject]@{ Name = 'check'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageCheck.psm1'); Function = 'Invoke-DocsCheckCommand'; Option = @{ Profile = 'value'; Path = 'multi' } }
        # --- 1022: inventory ---
        # --- 1023: coverage, update-ledger, validate ---
        [pscustomobject]@{ Name = 'coverage'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsCoverageCommand'; Option = @{ Profile = 'value' } }
        [pscustomobject]@{ Name = 'update-ledger'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsUpdateLedgerCommand'; Option = @{ Profile = 'value'; Operation = 'value'; Element = 'value'; Limit = 'value'; Disposition = 'value'; Page = 'multi'; Rationale = 'value'; Owner = 'value'; Target = 'value'; Dimension = 'value'; State = 'value'; Claim = 'value'; ActorKind = 'value'; ActorId = 'value'; Write = 'switch' } }
        [pscustomobject]@{ Name = 'validate'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsValidateCommand'; Option = @{ Profile = 'value'; Mode = 'value'; Revision = 'value'; WriteReceipt = 'switch' } }
        # --- 1024: generate-reference ---
        [pscustomobject]@{ Name = 'generate-reference'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceWriter.psm1'); Function = 'Invoke-DocsGenerateReferenceCommand'; Option = @{ Profile = 'value'; Snapshot = 'value'; OutputDirectory = 'value'; Write = 'switch' } }
        # --- 1034: surface-delta ---
    )
}

function Test-DocsCommandTable {
    <#
    .SYNOPSIS
        Returns DOCS_CLI_TABLE_INVALID findings for a dispatch table.
    .DESCRIPTION
        Reports a duplicate Name, a reserved option name (Command, Json, Help, RepositoryRoot),
        an option kind outside value, multi and switch, and a Function outside
        ^Invoke-Docs[A-Za-z]+Command$.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Table)

    $findings = [System.Collections.Generic.List[object]]::new()
    $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Table.Count; $index++) {
        $row = $Table[$index]
        if (-not $names.Add([string] $row.Name)) { $findings.Add((New-DocsFinding -Code 'DOCS_CLI_TABLE_INVALID' -Severity 'error' -Pointer "/$index/Name" -Message "The subcommand name '$($row.Name)' is registered more than once." -NextAction "Correct dispatch table row $index.")) }
        foreach ($option in @($row.Option.Keys)) {
            if (@('Command', 'Json', 'Help', 'RepositoryRoot') -contains [string] $option) { $findings.Add((New-DocsFinding -Code 'DOCS_CLI_TABLE_INVALID' -Severity 'error' -Pointer "/$index/Option/$option" -Message "The option name '$option' is reserved by the entry script." -NextAction "Correct dispatch table row $index.")) }
            elseif (@('value', 'multi', 'switch') -cnotcontains [string] $row.Option[$option]) { $findings.Add((New-DocsFinding -Code 'DOCS_CLI_TABLE_INVALID' -Severity 'error' -Pointer "/$index/Option/$option" -Message "The option kind '$($row.Option[$option])' of '$option' is not value, multi or switch." -NextAction "Correct dispatch table row $index.")) }
        }
        if ([string] $row.Function -cnotmatch '^Invoke-Docs[A-Za-z]+Command$') { $findings.Add((New-DocsFinding -Code 'DOCS_CLI_TABLE_INVALID' -Severity 'error' -Pointer "/$index/Function" -Message "The function '$($row.Function)' does not match ^Invoke-Docs[A-Za-z]+Command$." -NextAction "Correct dispatch table row $index.")) }
    }
    return Get-DocsOrderedFinding -Finding $findings.ToArray()
}

function ConvertFrom-DocsCommandArgument {
    <#
    .SYNOPSIS
        Parses subcommand arguments against an option map; returns @{ Argument; Error }.
    .DESCRIPTION
        OptionSpec maps a PascalCase option name to value, multi or switch. Option names match
        case-insensitively and are stored under their OptionSpec spelling. Error is $null or the
        message of the first usage error: an unexpected positional argument, an unknown option,
        a missing value, or a repeated non-multi option.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [string[]] $CommandArgument,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $OptionSpec
    )

    $argument = [ordered]@{}
    $tokens = @($CommandArgument | Where-Object { $null -ne $_ })
    for ($index = 0; $index -lt $tokens.Count; $index++) {
        $token = [string] $tokens[$index]
        if (-not $token.StartsWith('-') -or $token.Length -lt 2) { return @{ Argument = $null; Error = "Unexpected argument '$token'." } }
        $name = @($OptionSpec.Keys | Where-Object { [string]::Equals([string] $_, $token.Substring(1), [System.StringComparison]::OrdinalIgnoreCase) })
        if ($name.Count -eq 0) { return @{ Argument = $null; Error = "Unknown option '$token'." } }
        $key = [string] $name[0]
        $kind = [string] $OptionSpec[$key]
        if ($kind -cne 'multi' -and $argument.Contains($key)) { return @{ Argument = $null; Error = "Option '-$key' is given more than once." } }
        if ($kind -ceq 'switch') { $argument[$key] = $true; continue }
        if ($index + 1 -ge $tokens.Count) { return @{ Argument = $null; Error = "Option '-$key' requires a value." } }
        $index++
        if ($kind -ceq 'multi') { $argument[$key] = [string[]]@(@(if ($argument.Contains($key)) { $argument[$key] }) + [string] $tokens[$index]) }
        else { $argument[$key] = [string] $tokens[$index] }
    }
    return @{ Argument = $argument; Error = $null }
}

function ConvertTo-DocsProcessRequest {
    <#
    .SYNOPSIS
        Validates InvokeProcess arguments; returns @{ FilePath; ArgumentList; StdinText; TimeoutMilliseconds }.
    .DESCRIPTION
        FilePath is a non-blank string; ArgumentList a string array ($null becomes empty; a $null
        item is invalid); StdinText a string ($null becomes empty); TimeoutSeconds a positive
        finite number, converted to whole milliseconds rounded up. Any other value throws
        DOCS_PROCESS_ARGUMENT_INVALID naming the argument.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [object] $FilePath,
        [AllowNull()] [object] $ArgumentList,
        [AllowNull()] [object] $StdinText,
        [AllowNull()] [object] $TimeoutSeconds
    )

    if ($FilePath -isnot [string] -or [string]::IsNullOrWhiteSpace($FilePath)) { throw 'DOCS_PROCESS_ARGUMENT_INVALID: FilePath must be a non-blank string.' }
    $arguments = [System.Collections.Generic.List[string]]::new()
    foreach ($item in @(if ($null -ne $ArgumentList) { $ArgumentList })) {
        if ($item -isnot [string]) { throw 'DOCS_PROCESS_ARGUMENT_INVALID: ArgumentList must hold strings only, with no $null item.' }
        $arguments.Add($item)
    }
    if ($null -ne $ArgumentList -and @($ArgumentList).Count -ne $arguments.Count) { throw 'DOCS_PROCESS_ARGUMENT_INVALID: ArgumentList must hold strings only, with no $null item.' }
    if ($null -ne $StdinText -and $StdinText -isnot [string]) { throw 'DOCS_PROCESS_ARGUMENT_INVALID: StdinText must be a string.' }
    $isNumber = $TimeoutSeconds -is [int] -or $TimeoutSeconds -is [long] -or $TimeoutSeconds -is [double] -or $TimeoutSeconds -is [decimal]
    if (-not $isNumber -or [double]::IsNaN([double] $TimeoutSeconds) -or [double]::IsInfinity([double] $TimeoutSeconds) -or [double] $TimeoutSeconds -le 0) {
        throw 'DOCS_PROCESS_ARGUMENT_INVALID: TimeoutSeconds must be a positive finite number.'
    }
    return [ordered]@{
        FilePath            = [string] $FilePath
        ArgumentList        = $arguments.ToArray()
        StdinText           = if ($null -eq $StdinText) { '' } else { [string] $StdinText }
        TimeoutMilliseconds = [long] [math]::Ceiling([double] $TimeoutSeconds * 1000)
    }
}

function ConvertTo-DocsProcessResult {
    <#
    .SYNOPSIS
        Shapes the InvokeProcess result @{ ExitCode; Stdout; Stderr; TimedOut }.
    .DESCRIPTION
        Started $false throws DOCS_PROCESS_START_FAILED naming FilePath and including StartError.
        Exited $true returns the integer exit code and TimedOut $false; Exited $false returns
        ExitCode $null and TimedOut $true. A $null stream becomes the empty string.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $FilePath,
        [Parameter(Mandatory = $true)] [bool] $Started,
        [Parameter(Mandatory = $true)] [bool] $Exited,
        [AllowNull()] [object] $ExitCode,
        [AllowNull()] [string] $Stdout,
        [AllowNull()] [string] $Stderr,
        [AllowNull()] [string] $StartError
    )

    if (-not $Started) { throw "DOCS_PROCESS_START_FAILED: the process '$FilePath' could not be started: $StartError" }
    $out = if ($null -eq $Stdout) { '' } else { $Stdout }
    $err = if ($null -eq $Stderr) { '' } else { $Stderr }
    if ($Exited) { return @{ ExitCode = [int] $ExitCode; Stdout = $out; Stderr = $err; TimedOut = $false } }
    return @{ ExitCode = $null; Stdout = $out; Stderr = $err; TimedOut = $true }
}

function Invoke-DocsProcess {
    <#
    .SYNOPSIS
        Thin process seam: starts one child without a shell and returns its shaped result.
    .DESCRIPTION
        Validation is ConvertTo-DocsProcessRequest and shaping is ConvertTo-DocsProcessResult; this
        function adds neither. The working directory is WorkingDirectory, which defaults to the
        current location (callers run with the repository root as the current location). No test
        executes this body.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds, [string] $WorkingDirectory = (Get-Location).ProviderPath)

    $request = ConvertTo-DocsProcessRequest -FilePath $FilePath -ArgumentList $ArgumentList -StdinText $StdinText -TimeoutSeconds $TimeoutSeconds
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $info = [System.Diagnostics.ProcessStartInfo]::new($request.FilePath)
    foreach ($item in $request.ArgumentList) { $info.ArgumentList.Add($item) }
    $info.UseShellExecute = $false
    $info.WorkingDirectory = $WorkingDirectory
    $info.RedirectStandardInput = $true; $info.RedirectStandardOutput = $true; $info.RedirectStandardError = $true
    $info.StandardInputEncoding = $utf8; $info.StandardOutputEncoding = $utf8; $info.StandardErrorEncoding = $utf8
    try { $process = [System.Diagnostics.Process]::Start($info) } catch { return ConvertTo-DocsProcessResult -FilePath $request.FilePath -Started $false -Exited $false -StartError $_.Exception.Message }
    $stdout = $process.StandardOutput.ReadToEndAsync(); $stderr = $process.StandardError.ReadToEndAsync()
    $process.StandardInput.Write($request.StdinText); $process.StandardInput.Close()
    $exited = $process.WaitForExit([int] [math]::Min($request.TimeoutMilliseconds, [int]::MaxValue))
    if ($exited) { $process.WaitForExit() } else { $process.Kill($true) }
    $code = if ($exited) { $process.ExitCode } else { $null }
    return ConvertTo-DocsProcessResult -FilePath $request.FilePath -Started $true -Exited $exited -ExitCode $code -Stdout $stdout.Result -Stderr $stderr.Result
}

function Write-DocsFileText {
    <#
    .SYNOPSIS
        The only filesystem write primitive: writes UTF-8 without BOM with LF line endings.
    .DESCRIPTION
        Mode 'create' refuses an existing file; 'overwrite' replaces it. The function supports
        ShouldProcess: under -WhatIf (or an inherited WhatIfPreference) it creates neither the
        directory nor the file. The tests exercise only the -WhatIf path; the guarded write body
        is not executed by a test because tests create no files.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)] [string] $FullPath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [ValidateSet('create', 'overwrite')] [string] $Mode
    )

    $fileMode = if ($Mode -ceq 'create') { [System.IO.FileMode]::CreateNew } else { [System.IO.FileMode]::Create }
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text.Replace("`r`n", "`n"))
    if ($PSCmdlet.ShouldProcess($FullPath, "Write file ($Mode)")) {
        [void][System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($FullPath))
        $stream = [System.IO.FileStream]::new($FullPath, $fileMode, [System.IO.FileAccess]::Write)
        try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
    }
}

function Get-DocsContextFullPath {
    <#
    .SYNOPSIS
        Returns Root joined with a checked repository-relative path (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Root,
        [AllowNull()] [AllowEmptyString()] [string] $RelativePath
    )

    if (-not (Test-DocsRelativePath -Path $RelativePath)) { throw "DOCS_CONTEXT_PATH_INVALID: '$RelativePath' is not a repository-relative path." }
    return Join-Path -Path $Root -ChildPath $RelativePath
}

function Read-DocsContextText {
    <#
    .SYNOPSIS
        ReadText operation: decodes the file bytes through ConvertFrom-DocsUtf8Bytes (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Root, [AllowNull()] [AllowEmptyString()] [string] $RelativePath)

    $full = Get-DocsContextFullPath -Root $Root -RelativePath $RelativePath
    if (-not [System.IO.File]::Exists($full)) { throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$RelativePath' because it does not exist.") }
    return ConvertFrom-DocsUtf8Bytes -Bytes ([System.IO.File]::ReadAllBytes($full))
}

function Read-DocsContextByte {
    <#
    .SYNOPSIS
        ReadBytes operation (private helper).
    #>
    [CmdletBinding()]
    [OutputType([byte[]], [object[]])]
    param([string] $Root, [AllowNull()] [AllowEmptyString()] [string] $RelativePath)

    return , [System.IO.File]::ReadAllBytes((Get-DocsContextFullPath -Root $Root -RelativePath $RelativePath))
}

function Test-DocsContextFile {
    <#
    .SYNOPSIS
        TestFile operation (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([string] $Root, [AllowNull()] [AllowEmptyString()] [string] $RelativePath)

    return [System.IO.File]::Exists((Get-DocsContextFullPath -Root $Root -RelativePath $RelativePath))
}

function Get-DocsContextFileList {
    <#
    .SYNOPSIS
        ListFile operation: sorted repository-relative POSIX paths under RelativeRoot (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([string] $Root, [AllowNull()] [AllowEmptyString()] [string] $RelativeRoot)

    $directory = Get-DocsContextFullPath -Root $Root -RelativePath $RelativeRoot
    [string[]] $paths = @(if ([System.IO.Directory]::Exists($directory)) { [System.IO.Directory]::EnumerateFiles($directory, '*', [System.IO.SearchOption]::AllDirectories) | ForEach-Object { [System.IO.Path]::GetRelativePath($Root, $_).Replace('\', '/') } })
    [Array]::Sort($paths, [System.StringComparer]::Ordinal)
    return , $paths
}

function Write-DocsContextText {
    <#
    .SYNOPSIS
        WriteText operation: checks the path and forwards to Write-DocsFileText (private helper).
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string] $Root, [AllowNull()] [AllowEmptyString()] [string] $RelativePath, [AllowEmptyString()] [string] $Text, [string] $Mode)

    Write-DocsFileText -FullPath (Get-DocsContextFullPath -Root $Root -RelativePath $RelativePath) -Text $Text -Mode $Mode
}

function New-DocsCommandContext {
    <#
    .SYNOPSIS
        Returns the real command context for RepositoryRoot.
    .DESCRIPTION
        Members: RepositoryRoot, ReadText, ReadBytes, TestFile, ListFile, WriteText, UtcNow,
        InvokeProcess. Relative paths are checked with Test-DocsRelativePath before any access.
        ReadText decodes through ConvertFrom-DocsUtf8Bytes and throws an item-not-found error for
        an absent file. WriteText forwards the full path, text and mode to Write-DocsFileText;
        InvokeProcess forwards its four arguments unchanged to Invoke-DocsProcess.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds an in-memory context object; the members, not this factory, perform I/O.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $RepositoryRoot)

    $root = [System.IO.Path]::GetFullPath($RepositoryRoot)
    # Each repository member is a closure over the root whose [scriptblock] Operation parameter
    # defaults to a script function. A closure resolves no script or module command by name, and
    # the script function resolves its callees (and any test mock of them) at call time.
    $readTextOperation = ${function:Read-DocsContextText}
    $readBytesOperation = ${function:Read-DocsContextByte}
    $testFileOperation = ${function:Test-DocsContextFile}
    $listFileOperation = ${function:Get-DocsContextFileList}
    $writeTextOperation = ${function:Write-DocsContextText}
    $readText = { param($RelativePath, [scriptblock] $Operation = $readTextOperation) & $Operation $root $RelativePath }.GetNewClosure()
    $readBytes = { param($RelativePath, [scriptblock] $Operation = $readBytesOperation) & $Operation $root $RelativePath }.GetNewClosure()
    $testFile = { param($RelativePath, [scriptblock] $Operation = $testFileOperation) & $Operation $root $RelativePath }.GetNewClosure()
    $listFile = { param($RelativeRoot, [scriptblock] $Operation = $listFileOperation) & $Operation $root $RelativeRoot }.GetNewClosure()
    $writeText = { param($RelativePath, $Text, $Mode, [scriptblock] $Operation = $writeTextOperation) & $Operation $root $RelativePath $Text $Mode }.GetNewClosure()
    # Bound (non-closure) member: Invoke-DocsProcess, or a test mock of it, is resolved at call time.
    $invokeProcess = { param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds) Invoke-DocsProcess -FilePath $FilePath -ArgumentList $ArgumentList -StdinText $StdinText -TimeoutSeconds $TimeoutSeconds }
    $utcNow = { [datetime]::UtcNow }

    return [pscustomobject]@{
        RepositoryRoot = $root
        ReadText       = $readText
        ReadBytes      = $readBytes
        TestFile       = $testFile
        ListFile       = $listFile
        WriteText      = $writeText
        UtcNow         = $utcNow
        InvokeProcess  = $invokeProcess
    }
}

function Get-DocsCommandUsage {
    <#
    .SYNOPSIS
        Returns the usage lines listing every dispatch table row (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Table)

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('Usage: Invoke-DocsCommand.ps1 -Command <name> [-Json] [-Help] [-RepositoryRoot <path>] [options]')
    foreach ($row in $Table) {
        [string[]] $options = @($row.Option.Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($options, [System.StringComparer]::Ordinal)
        $parts = @($options | ForEach-Object { if ($row.Option[$_] -ceq 'switch') { "[-$_]" } else { "[-$_ <$($row.Option[$_])>]" } })
        $lines.Add(("  $($row.Name) " + ($parts -join ' ')).TrimEnd())
    }
    return , $lines.ToArray()
}

function Invoke-DocsCommandCli {
    <#
    .SYNOPSIS
        Runs one subcommand and returns @{ ExitCode; Stdout; Stderr } without writing or exiting.
    .DESCRIPTION
        Context defaults to New-DocsCommandContext for RepositoryRoot (default: the current
        location). CommandFunction defaults to the function named by the selected row, after the
        row's module is imported. PowerShellVersion is the version-floor seam.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Command,
        [switch] $Json,
        [switch] $Help,
        [AllowNull()] [AllowEmptyString()] [string] $RepositoryRoot,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $CommandArgument,
        [AllowNull()] [object] $Context,
        [AllowNull()] [scriptblock] $CommandFunction,
        [version] $PowerShellVersion = $PSVersionTable.PSVersion
    )

    $table = Get-DocsCommandTable
    $row = @($table | Where-Object { [string] $_.Name -ceq $Command }) | Select-Object -First 1
    $name = if ($null -ne $row) { [string] $row.Name } else { $null }
    $result = $null
    $versionError = Get-DocsRuntimeVersionError -PowerShellVersion $PowerShellVersion
    if ($null -ne $versionError) {
        $result = New-DocsCommandResult -Command $name -ExitCode 3 -Finding @(New-DocsFinding -Code 'DOCS_RUNTIME_UNSUPPORTED' -Severity 'error' -Message $versionError -NextAction 'Run the documentation tooling with PowerShell 7.4 or later.')
    } elseif ($Help) {
        $usage = Get-DocsCommandUsage -Table $table
        $result = New-DocsCommandResult -Command $null -ExitCode 0 -Finding @() -Result ([ordered]@{ usage = $usage }) -Line $usage
    } elseif ($null -eq $row) {
        $message = if ([string]::IsNullOrEmpty($Command)) { 'The -Command parameter is required.' } else { "The command '$Command' is not a subcommand of Invoke-DocsCommand.ps1." }
        $result = New-DocsCommandResult -Command $null -ExitCode 2 -Finding @(New-DocsFinding -Code 'DOCS_CLI_ARGUMENTS' -Severity 'error' -Message $message -NextAction 'Run Invoke-DocsCommand.ps1 -Help for the list of subcommands.')
    } else {
        $parsed = ConvertFrom-DocsCommandArgument -CommandArgument $CommandArgument -OptionSpec $row.Option
        if ($null -ne $parsed.Error) {
            $result = New-DocsCommandResult -Command $name -ExitCode 2 -Finding @(New-DocsFinding -Code 'DOCS_CLI_ARGUMENTS' -Severity 'error' -Message $parsed.Error -NextAction "Run Invoke-DocsCommand.ps1 -Help for the $name options.")
        } else {
            try {
                if ($null -eq $Context) { $Context = New-DocsCommandContext -RepositoryRoot $(if ([string]::IsNullOrEmpty($RepositoryRoot)) { (Get-Location).ProviderPath } else { $RepositoryRoot }) }
                if ($null -eq $CommandFunction) {
                    Import-Module -Name $row.Module -ErrorAction Stop
                    $CommandFunction = (Get-Command -Name $row.Function -CommandType Function -ErrorAction Stop).ScriptBlock
                }
                $result = & $CommandFunction -Argument $parsed.Argument -Context $Context
            } catch {
                $result = New-DocsCommandResult -Command $name -ExitCode 3 -Finding @(New-DocsFinding -Code 'DOCS_CLI_RUNTIME' -Severity 'error' -Message "The command failed: $($_.Exception.Message)" -NextAction 'Correct the reported condition and run the command again.')
            }
        }
    }

    $stdout = if ($Json) { ConvertTo-DocsEnvelopeText -CommandResult $result } else { ConvertTo-DocsReportText -CommandResult $result }
    $stderr = ''
    if ($result.ExitCode -eq 3) { $stderr = "Invoke-DocsCommand.ps1: exit 3 ($(@($result.Findings)[0]['code']))`n" }
    return @{ ExitCode = [int] $result.ExitCode; Stdout = $stdout; Stderr = $stderr }
}

if ($MyInvocation.InvocationName -ne '.') {
    $outcome = Invoke-DocsCommandCli -Command $Command -Json:$Json -Help:$Help -RepositoryRoot $RepositoryRoot -CommandArgument $CommandArgument
    [Console]::Out.Write($outcome.Stdout)
    [Console]::Error.Write($outcome.Stderr)
    exit $outcome.ExitCode
}
