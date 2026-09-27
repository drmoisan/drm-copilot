#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Issue #697 (AC-4.7, AC-4.8, AC-4.9): the PowerShell wrappers
    .codex/scripts/Resolve-CodexTopology.ps1 and Resolve-CodexDeployment.ps1 must
    reproduce the Python CLIs over the committed parity corpus. Each record is
    checked through pwsh -File (process level), through the wrapper functions in
    process (coverage-bearing), and, for a subset, through the wrappers' own entry
    blocks in process. Parity normalization: CRLF to LF, trailing whitespace
    stripped, byte-equal stdout, equal parsed objects, equal exit codes; error
    cases require empty stdout and, for exit 1, the Python message substring.
#>

BeforeDiscovery {
    $corpusRoot = Join-Path $PSScriptRoot '../../fixtures/codex_routing'
    $script:TopologyCases = @(Get-Content -Raw -LiteralPath (Join-Path $corpusRoot 'topology.json') | ConvertFrom-Json -AsHashtable)
    $script:DeploymentCases = @(Get-Content -Raw -LiteralPath (Join-Path $corpusRoot 'deployment.json') | ConvertFrom-Json -AsHashtable)
    $entryTopologyIds = @('topo-standalone-small', 'topo-invalid-choice', 'topo-empty-language')
    $entryDeploymentIds = @('dep-commit-steward', 'dep-invalid-choice', 'dep-unsupported-agent')
    $script:TopologyEntryCases = @($script:TopologyCases | Where-Object { $_.id -in $entryTopologyIds })
    $script:DeploymentEntryCases = @($script:DeploymentCases | Where-Object { $_.id -in $entryDeploymentIds })
}

Describe 'Codex routing PowerShell wrappers match the Python CLI corpus (issue #697)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:TopologyWrapper = Join-Path $script:RepoRoot '.codex/scripts/Resolve-CodexTopology.ps1'
        $script:DeploymentWrapper = Join-Path $script:RepoRoot '.codex/scripts/Resolve-CodexDeployment.ps1'
        $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
        $corpusRoot = Join-Path $script:RepoRoot 'tests/fixtures/codex_routing'
        $script:TopologyById = @{}
        foreach ($record in @(Get-Content -Raw -LiteralPath (Join-Path $corpusRoot 'topology.json') | ConvertFrom-Json -AsHashtable)) {
            $script:TopologyById[$record.id] = $record
        }

        . $script:TopologyWrapper
        . $script:DeploymentWrapper

        function ConvertTo-ParityText {
            <#
                Applies the parity normalization: CRLF to LF, trailing whitespace stripped.
            #>
            param([AllowNull()][AllowEmptyString()][string] $Text)

            if ($null -eq $Text) {
                return ''
            }
            return $Text.Replace("`r`n", "`n").TrimEnd()
        }

        function Test-ParsedJsonEqual {
            <#
                Compares two values produced by ConvertFrom-Json -AsHashtable key by key.
            #>
            param([AllowNull()] $Expected, [AllowNull()] $Actual)

            if ($null -eq $Expected -or $null -eq $Actual) {
                return ($null -eq $Expected -and $null -eq $Actual)
            }
            if ($Expected -is [System.Collections.IDictionary]) {
                if ($Actual -isnot [System.Collections.IDictionary] -or $Expected.Count -ne $Actual.Count) {
                    return $false
                }
                foreach ($key in $Expected.Keys) {
                    if (-not $Actual.Contains($key) -or -not (Test-ParsedJsonEqual $Expected[$key] $Actual[$key])) {
                        return $false
                    }
                }
                return $true
            }
            if ($Expected -is [string] -or $Actual -is [string]) {
                return ($Expected -is [string] -and $Actual -is [string] -and $Expected -ceq $Actual)
            }
            if ($Expected -is [System.Collections.IEnumerable]) {
                $left = @($Expected)
                $right = @($Actual)
                if ($left.Count -ne $right.Count) {
                    return $false
                }
                for ($index = 0; $index -lt $left.Count; $index++) {
                    if (-not (Test-ParsedJsonEqual $left[$index] $right[$index])) {
                        return $false
                    }
                }
                return $true
            }
            return ($Expected.GetType() -eq $Actual.GetType() -and $Expected -eq $Actual)
        }

        function Assert-CorpusOutcome {
            <#
                Asserts one wrapper outcome against its corpus record.
            #>
            param(
                [Parameter(Mandatory)][hashtable] $Record,
                [Parameter(Mandatory)][int] $ExitCode,
                [AllowNull()][AllowEmptyString()][string] $Stdout,
                [AllowNull()][AllowEmptyString()][string] $Stderr
            )

            $normalized = ConvertTo-ParityText $Stdout
            $ExitCode | Should -Be $Record.expected_exit -Because "stderr was '$Stderr'"
            if ($Record.expected_exit -eq 0) {
                $normalized | Should -BeExactly $Record.expected_stdout
                $expectedObject = $Record.expected_stdout | ConvertFrom-Json -AsHashtable
                $actualObject = $normalized | ConvertFrom-Json -AsHashtable
                Test-ParsedJsonEqual $expectedObject $actualObject | Should -BeTrue
                return
            }
            $normalized | Should -BeNullOrEmpty
            if ($Record.expected_exit -eq 1) {
                ([string]$Stderr).Contains([string]$Record.expected_stderr_contains) |
                    Should -BeTrue -Because "stderr '$Stderr' must contain the Python message"
            } else {
                $Stderr | Should -Match 'error:'
            }
        }

        function Invoke-WrapperProcess {
            <#
                Runs a wrapper through pwsh -NoProfile -File, passing each corpus
                token through ProcessStartInfo.ArgumentList.
            #>
            param([Parameter(Mandatory)][string] $WrapperPath, [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Argv)

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = $script:PwshPath
            $startInfo.ArgumentList.Add('-NoProfile')
            $startInfo.ArgumentList.Add('-File')
            $startInfo.ArgumentList.Add($WrapperPath)
            foreach ($token in $Argv) {
                $startInfo.ArgumentList.Add($token)
            }
            $startInfo.WorkingDirectory = $script:RepoRoot
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.UseShellExecute = $false

            $process = [System.Diagnostics.Process]::Start($startInfo)
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $stdout; Stderr = $stderr }
        }

        function Invoke-WrapperEntryInProcess {
            <#
                Runs a wrapper's own entry block in the Pester session, capturing the
                console streams with StringWriter instances restored in finally.
            #>
            param([Parameter(Mandatory)][string] $WrapperPath, [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Argv)

            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                & $WrapperPath @Argv
                $exitCode = $LASTEXITCODE
            } finally {
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
            return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $outWriter.ToString(); Stderr = $errorWriter.ToString() }
        }
    }

    It 'matches the Python CLI for topology case <id> through pwsh -File' -ForEach $script:TopologyCases {
        $result = Invoke-WrapperProcess -WrapperPath $script:TopologyWrapper -Argv ([string[]]$argv)

        Assert-CorpusOutcome -Record $_ -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }

    It 'matches the Python CLI for deployment case <id> through pwsh -File' -ForEach $script:DeploymentCases {
        $result = Invoke-WrapperProcess -WrapperPath $script:DeploymentWrapper -Argv ([string[]]$argv)

        Assert-CorpusOutcome -Record $_ -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }

    It 'matches the corpus in process for topology case <id>' -ForEach $script:TopologyCases {
        $result = Invoke-CodexTopologyCli -Arguments ([string[]]$argv)

        Assert-CorpusOutcome -Record $_ -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }

    It 'matches the corpus in process for deployment case <id>' -ForEach $script:DeploymentCases {
        $result = Invoke-CodexDeploymentCli -Arguments ([string[]]$argv)

        Assert-CorpusOutcome -Record $_ -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }

    It 'runs the Resolve-CodexTopology entry block in process for case <id>' -ForEach $script:TopologyEntryCases {
        $result = Invoke-WrapperEntryInProcess -WrapperPath $script:TopologyWrapper -Argv ([string[]]$argv)

        Assert-CorpusOutcome -Record $_ -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }

    It 'runs the Resolve-CodexDeployment entry block in process for case <id>' -ForEach $script:DeploymentEntryCases {
        $result = Invoke-WrapperEntryInProcess -WrapperPath $script:DeploymentWrapper -Argv ([string[]]$argv)

        Assert-CorpusOutcome -Record $_ -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }

    It 'resolves modules through the .claude/lib fallback inside drm-copilot' {
        Test-Path -LiteralPath (Join-Path $script:RepoRoot '.codex/lib') | Should -BeFalse
        $record = $script:TopologyById['topo-standalone-small']

        $result = Invoke-CodexTopologyCli -Arguments ([string[]]$record.argv)

        $result.ExitCode | Should -Be 0 -Because "stderr was '$($result.Stderr)'"
        Assert-CorpusOutcome -Record $record -ExitCode $result.ExitCode -Stdout $result.Stdout -Stderr $result.Stderr
    }
}
