# Unit tests for the machine test-suite lock branch of the MCP PoshQC templates run-poshqc-test.ps1 and
# run-poshqc-suite.ps1, and of the byte-identical local copy scripts/dev-tools/run-poshqc-suite.ps1
# (issue #1158, spec D7, D21, D32). Every probe, load, lock, clock, and sleep call goes through a template
# seam with in-memory values; the seams and the mocked command resolve the variable $scenario of the running It
# block (set through Set-Variable), which the template's scope chain reaches, so no lock file, holder record, or workspace file is touched and no real wait occurs.

BeforeDiscovery {
    $script:Templates = @(
        @{ Script = 'extensions/drm-copilot/resources/templates/run-poshqc-test.ps1'; Command = 'Invoke-PoshQCTest' }
        @{ Script = 'extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1'; Command = 'Invoke-PoshQCSuite' }
        @{ Script = 'scripts/dev-tools/run-poshqc-suite.ps1'; Command = 'Invoke-PoshQCSuite' }
    )
}

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root module.
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }
    Import-Module -Name $resolvedModulePath -Force

    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path

    # Builds the template arguments over one scenario table; every seam records into the table.
    $script:NewScenario = {
        param([string] $Present, [AllowNull()][object] $ConfigText, [bool] $Busy)
        $configValue = $ConfigText
        $scenario = @{
            Imported = [System.Collections.Generic.List[string]]::new()
            Events   = [System.Collections.Generic.List[string]]::new()
            Sleeps   = [System.Collections.Generic.List[int]]::new()
            Errors   = [System.Collections.Generic.List[string]]::new()
            Calls    = [System.Collections.Generic.List[hashtable]]::new()
            Now      = [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
            Repo     = $script:RepoRoot
        }
        $stream = [pscustomobject]@{ Scenario = $scenario }
        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Scenario.Events.Add('dispose') }
        $presentFolders = switch ($Present) { 'codex' { @('.codex/hooks') } 'both' { @('.claude/hooks', '.codex/hooks') } default { @() } }
        $arguments = @{
            WorkspaceRoot      = '/repo'
            TestPath           = { param([string] $Path) $normalized = $Path.Replace('\', '/'); @($presentFolders | Where-Object { $normalized.EndsWith("/$_/test-execution-lock.ps1") }).Count -gt 0 }.GetNewClosure()
            ImportHelper       = {
                param([string] $Path)
                $normalized = $Path.Replace('\', '/')
                $scenario.Imported.Add($normalized)
                $relative = $normalized.Substring($normalized.IndexOf('/.') + 1)
                # Not a closure: the template dot-invokes this seam, so the helper functions must land in its scope.
                . (Join-Path $scenario.Repo $relative)
            }
            ReadConfigText     = { param([string] $Path) [void] $Path; $configValue }.GetNewClosure()
            GetLockDirectory   = { '/locks' }
            Clock              = { $scenario.Now }.GetNewClosure()
            Sleep              = { param([int] $Milliseconds) $scenario.Sleeps.Add($Milliseconds); $scenario.Now = $scenario.Now.AddMilliseconds($Milliseconds) }.GetNewClosure()
            WriteStandardError = { param([string] $Line) $scenario.Errors.Add($Line) }.GetNewClosure()
            LockSeams          = @{
                OpenLockStream     = if ($Busy) { { param([string] $Path) [void] $Path; throw [System.IO.IOException]::new('busy') } } else { { param([string] $Path) [void] $Path; $scenario.Events.Add('open'); $stream }.GetNewClosure() }
                ReadHolderText     = { param([string] $Path) [void] $Path; $null }
                WriteHolderText    = { param([string] $Path, [string] $Content) [void] $Path; [void] $Content; $scenario.Events.Add('write') }.GetNewClosure()
                RemoveHolderFile   = { param([string] $Path) [void] $Path; $scenario.Events.Add('remove') }.GetNewClosure()
                GetProcessStartUtc = { param([int] $Id) [void] $Id; [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc) }
            }
        }
        return @{ Scenario = $scenario; Arguments = $arguments }
    }

    $script:SlowConfig = '{"version":1,"localLanes":{"exclude":["integration"]},"lanes":{"integration":{"pesterTags":["Slow"],"fileNameSuffixes":[".slow.tests.ps1"]}},"machineLock":{"waitMilliseconds":4000,"pollMilliseconds":1000}}'
}

Describe 'MCP template lock branch (<Script>)' -ForEach $script:Templates {
    BeforeEach {
        Mock -CommandName Import-Module -MockWith { }
        Mock -CommandName $Command -MockWith {
            $scenario.Events.Add('command')
            $scenario.Calls.Add(@{
                    HasTag    = $PesterBoundParameters.ContainsKey('ExcludeTag')
                    HasSuffix = $PesterBoundParameters.ContainsKey('ExcludeTestFileSuffix')
                    Tags      = @($PesterBoundParameters['ExcludeTag'])
                    Suffixes  = @($PesterBoundParameters['ExcludeTestFileSuffix'])
                })
        }
        $script:TemplatePath = Join-Path $script:RepoRoot $Script
    }

    It 'loads the .codex/hooks helpers when only the .codex/hooks copy is present and runs inside the lock' {
        # Arrange
        $built = & $script:NewScenario 'codex' $null $false
        Set-Variable -Name scenario -Value $built.Scenario
        $arguments = $built.Arguments

        # Act
        & $script:TemplatePath @arguments

        # Assert
        $built.Scenario.Imported.Count | Should -Be 3
        @($built.Scenario.Imported | Where-Object { $_ -like '*/.codex/hooks/*' }).Count | Should -Be 3
        @($built.Scenario.Imported | Where-Object { $_ -like '*/.claude/hooks/*' }).Count | Should -Be 0
        ($built.Scenario.Events -join ',') | Should -BeExactly 'open,write,command,remove,dispose'
        ($built.Scenario.Calls[0].Tags -join ',') | Should -BeExactly 'Integration,Golden'
        ($built.Scenario.Calls[0].Suffixes -join ',') | Should -BeExactly '.integration.test.ts,.integration.test.js,_integration.py,.integration.tests.ps1,.golden.test.ts,.golden.test.js,_golden.py,.golden.tests.ps1'
    }

    It 'loads only the .claude/hooks helpers when both copies are present' {
        # Arrange
        $built = & $script:NewScenario 'both' $null $false
        Set-Variable -Name scenario -Value $built.Scenario
        $arguments = $built.Arguments

        # Act
        & $script:TemplatePath @arguments

        # Assert
        $built.Scenario.Imported.Count | Should -Be 3
        @($built.Scenario.Imported | Where-Object { $_ -like '*/.claude/hooks/*' }).Count | Should -Be 3
    }

    It 'releases the lock and removes the holder record after a throwing command' {
        # Arrange
        $built = & $script:NewScenario 'both' $null $false
        Set-Variable -Name scenario -Value $built.Scenario
        $arguments = $built.Arguments
        Mock -CommandName $Command -MockWith { $scenario.Events.Add('command'); throw 'suite failed' }

        # Act / Assert
        { & $script:TemplatePath @arguments } | Should -Throw '*suite failed*'
        ($built.Scenario.Events -join ',') | Should -BeExactly 'open,write,command,remove,dispose'
    }

    It 'passes configured lanes and honors the configured wait on a busy lock' {
        # Arrange
        $free = & $script:NewScenario 'both' $script:SlowConfig $false
        Set-Variable -Name scenario -Value $free.Scenario
        $freeArguments = $free.Arguments

        # Act
        & $script:TemplatePath @freeArguments

        # Assert
        ($free.Scenario.Calls[0].Tags -join ',') | Should -BeExactly 'Slow'
        ($free.Scenario.Calls[0].Suffixes -join ',') | Should -BeExactly '.slow.tests.ps1'

        # Arrange
        $busy = & $script:NewScenario 'both' $script:SlowConfig $true
        Set-Variable -Name scenario -Value $busy.Scenario
        $busyArguments = $busy.Arguments

        # Act
        & $script:TemplatePath @busyArguments

        # Assert
        $LASTEXITCODE | Should -Be 75
        ($busy.Scenario.Sleeps -join ',') | Should -BeExactly '1000,1000,1000,1000'
        $busy.Scenario.Calls.Count | Should -Be 0
    }

    It 'exits 75 with a queue-timeout line and does not run the command when the lock stays busy' {
        # Arrange
        $built = & $script:NewScenario 'both' $null $true
        Set-Variable -Name scenario -Value $built.Scenario
        $arguments = $built.Arguments

        # Act
        & $script:TemplatePath @arguments

        # Assert
        $LASTEXITCODE | Should -Be 75
        $built.Scenario.Calls.Count | Should -Be 0
        $built.Scenario.Errors.Count | Should -Be 1
        $built.Scenario.Errors[0] | Should -BeLike 'TEST_EXECUTION_QUEUE_TIMEOUT:*waited 90000 ms*'
    }

    It 'runs the command with neither lane parameter when the helper is absent' {
        # Arrange
        $built = & $script:NewScenario 'none' $null $false
        Set-Variable -Name scenario -Value $built.Scenario
        $arguments = $built.Arguments

        # Act
        & $script:TemplatePath @arguments

        # Assert
        $built.Scenario.Imported.Count | Should -Be 0
        $built.Scenario.Calls.Count | Should -Be 1
        $built.Scenario.Calls[0].HasTag | Should -BeFalse
        $built.Scenario.Calls[0].HasSuffix | Should -BeFalse
        ($built.Scenario.Events -join ',') | Should -BeExactly 'command'
    }
}
