Set-StrictMode -Version Latest

# Enforcement-hook Python-invocation guard (issue #475).
#
# BASH-MIGRATION ORACLE INTENT. This suite is the intended behavioral oracle for the
# eventual bash migration of the `.claude/**` hook surface: its detection classes,
# carve-outs, and allowlist semantics are the contract any future migration must
# reproduce, and the fixtures are the executable statement of that contract.
# WHAT IT PROVES. Structurally, that no hook or hook library invokes a Python
# interpreter on any path. Nothing here mutates `$env:PATH`, probes for a live
# `python`, or defines a shadow `function python` (SD-3). The detection classes,
# carve-outs, and allowlist policy are documented in the sibling helper's header.
#
# COMPOSED `Start-Process` TOKEN. `check-powershell-test-purity.ps1:119` forbids that
# literal token anywhere under `tests/`. This suite starts no subprocess; it needs the
# token only as INPUT DATA to the parser, so it is composed from two fragments.

BeforeAll {
    # Resolve the repo root by walking up from this file's own location, never from
    # the CWD, so the scan behaves identically in terminal and Test Explorer.
    $testsRoot = $PSScriptRoot
    while ($null -ne $testsRoot -and (Split-Path -Path $testsRoot -Leaf) -ne 'tests') {
        $testsRoot = Split-Path -Path $testsRoot -Parent
    }
    if ($null -eq $testsRoot) {
        throw "Unable to resolve the 'tests' root by walking up from '$PSScriptRoot'."
    }
    $script:RepoRoot = Split-Path -Path $testsRoot -Parent

    # Detection logic and allowlist live in a sibling helper so fixtures and scan
    # exercise one single code path.
    . (Join-Path -Path $PSScriptRoot -ChildPath 'EnforcementHooksNoPythonInvocation.Helpers.ps1')

    # Exactly two scan roots, anchored at the resolved repository root. A repo-wide
    # recursive glob is deliberately NOT used: the bundled mirror under
    # `extensions/drm-copilot/resources/claude-customizations/.claude/**` is a
    # byte-identical second copy of these files and must stay out of scope, because
    # allowlist keys are repo-root-relative paths.
    $script:ScanRoot = @(
        (Join-Path -Path $script:RepoRoot -ChildPath '.claude/hooks'),
        (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib')
    )

    <#
    .SYNOPSIS
        Enumerates every `*.ps1` and `*.psm1` beneath the two scan roots, excluding
        `.claude/lib/bash/**` (shell, not PowerShell). Each result carries the
        absolute path and the repo-root-relative label used by the allowlist.
    #>
    function Get-GuardedPowerShellFile {
        [CmdletBinding()]
        [OutputType([object[]])]
        param()

        $results = [System.Collections.Generic.List[object]]::new()
        foreach ($root in $script:ScanRoot) {
            if (-not (Test-Path -Path $root)) {
                continue
            }
            $files = Get-ChildItem -Path $root -Recurse -File |
                Where-Object { $_.Extension -in @('.ps1', '.psm1') }
            foreach ($file in $files) {
                $relative = $file.FullName.Substring($script:RepoRoot.Length).TrimStart('\', '/')
                $relative = $relative -replace '\\', '/'
                # `.claude/lib/bash/**` holds shell scripts, not PowerShell.
                if ($relative -like '.claude/lib/bash/*') {
                    continue
                }
                $results.Add([pscustomobject]@{
                        FullName = $file.FullName
                        Relative = $relative
                    })
            }
        }
        return , $results.ToArray()
    }

    <#
    .SYNOPSIS
        Runs the detection helper over every guarded file and returns all findings.
    #>
    function Get-RepositoryPythonInvocationFinding {
        [CmdletBinding()]
        [OutputType([object[]])]
        param()

        $all = [System.Collections.Generic.List[object]]::new()
        foreach ($file in (Get-GuardedPowerShellFile)) {
            $content = Get-Content -Path $file.FullName -Raw
            $findings = Get-PythonInvocationFinding -ScriptText $content -SourceLabel $file.Relative
            foreach ($finding in $findings) {
                $all.Add($finding)
            }
        }
        return , $all.ToArray()
    }
}

Describe 'enforcement hooks must not invoke Python' {

    Context 'allowlist policy' {
        It 'ships an empty allowlist' {
            # Arrange / Act
            $allowlist = Get-PythonInvocationAllowlist

            # Assert: issue #475 removes every site, so none needs an exemption. An
            # entry may only be added by an owner decision, never to pass a failure.
            @($allowlist).Count | Should -Be 0
        }
    }

    Context 'detection class 1 - constant interpreter command' {
        It 'detects a bare python invocation' {
            # Arrange
            $fixture = @'
function Invoke-Thing {
    python -m scripts.dev_tools.validate_discovery_artifacts
}
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'bare-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'ConstantCommand'
            $findings[0].Function | Should -Be 'Invoke-Thing'
        }

        It 'detects an ampersand-invoked python invocation' {
            # Arrange
            $fixture = @'
& python -m scripts.dev_tools.validate_orchestration_artifacts
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'ampersand-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'ConstantCommand'
        }

        It 'detects a dot-invoked python invocation' {
            # Arrange: `.` with a constant name still runs the interpreter.
            $fixture = @'
. python -c 'import scripts.dev_tools.validate_orchestration_artifacts'
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'dot-constant-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'ConstantCommand'
        }

        It 'detects a quoted python constant invocation' {
            # Arrange
            $fixture = @'
& 'python' -m scripts.dev_tools.validate_discovery_artifacts
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'quoted-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'ConstantCommand'
        }

        It 'detects python3, py, and poetry as interpreter commands' {
            # Arrange: the remaining three names in the interpreter set.
            $fixture = @'
python3 -m foo
py -3 -m foo
poetry run pytest
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'aliases-fixture'

            # Assert
            @($findings).Count | Should -Be 3
            ($findings | ForEach-Object { $_.Kind } | Select-Object -Unique) | Should -Be 'ConstantCommand'
        }

        It 'detects an interpreter name written in mixed case' {
            # Arrange: command-name matching is case-insensitive.
            $fixture = @'
PyThOn -m foo
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'mixed-case-fixture'

            # Assert
            @($findings).Count | Should -Be 1
        }
    }

    Context 'detection class 2 - subprocess start targeting an interpreter' {
        It 'detects a subprocess start whose FilePath is an interpreter' {
            # Arrange: token composed, not literal, per the purity rule; nothing runs.
            $startProcess = 'Start' + '-Process'
            $fixture = "$startProcess -FilePath 'python' -ArgumentList '-m', 'scripts.dev_tools.x'"

            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'startprocess-filepath-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'StartProcess'
        }

        It 'detects a subprocess start whose first positional argument is an interpreter' {
            # Arrange
            $startProcess = 'Start' + '-Process'
            $fixture = "$startProcess 'poetry' -ArgumentList 'run', 'pytest'"

            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'startprocess-positional-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'StartProcess'
        }

        It 'reports no finding for a subprocess start targeting an unrelated executable' {
            # Arrange
            $startProcess = 'Start' + '-Process'
            $fixture = "$startProcess -FilePath 'pwsh' -ArgumentList '-NoProfile'"

            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'startprocess-unrelated-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }
    }

    Context 'detection class 3 - dynamic invocation fail-closed' {
        It 'detects an ampersand-invoked variable that is not a scriptblock parameter' {
            # Arrange: nothing statically proves the target, so the guard fails closed.
            # The file also declares a real [scriptblock] seam, pinning that the
            # carve-out matches by NAME: a defect collapsing names to '' carved out
            # both calls, and this fixture fails under it.
            $fixture = @'
function Invoke-Thing {
    param(
        [string] $ToolPath,
        [scriptblock] $Invoker = { 'x' }
    )
    & $Invoker
    & $ToolPath -m foo
}
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'dynamic-fixture'

            # Assert: only the non-seam variable is reported.
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'DynamicInvocation'
            $findings[0].Detail | Should -Match 'ToolPath'
        }

        It 'detects an ampersand-invoked expression in the command position' {
            # Arrange
            $fixture = @'
& (Get-InterpreterPath) -m foo
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'expression-fixture'

            # Assert: the inner `Get-InterpreterPath` is a constant non-interpreter
            # command, so exactly one dynamic finding is expected.
            @($findings | Where-Object { $_.Kind -eq 'DynamicInvocation' }).Count | Should -Be 1
        }
    }

    Context 'detection class 4 - arbitrary text execution' {
        It 'detects an Invoke-Expression call' {
            # Arrange
            $fixture = @'
Invoke-Expression $someCommandText
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'iex-long-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'InvokeExpression'
        }

        It 'detects the built-in alias of Invoke-Expression' {
            # Arrange: long-form-only detection would be trivially bypassable.
            $fixture = @'
iex $someCommandText
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'iex-alias-fixture'

            # Assert
            @($findings).Count | Should -Be 1
            $findings[0].Kind | Should -Be 'InvokeExpression'
        }
    }

    Context 'non-detection - constructs that must never be reported' {
        It 'reports no finding for interpreter names inside string literals' {
            # Arrange
            $fixture = @'
$message = 'run python -m scripts.dev_tools.validate_discovery_artifacts to reproduce'
$other = "poetry run pytest"
Write-Output $message
Write-Output $other
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'string-literal-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }

        It 'reports no finding for interpreter names inside comments' {
            # Arrange
            $fixture = @'
# Invokes `python -m scripts.dev_tools.validate_discovery_artifacts` with the
# supplied arguments. Historically this ran poetry run pytest as well.
Write-Output 'done'
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'comment-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }

        It 'reports no finding for function names beginning with Invoke-Python' {
            # Arrange: a function whose NAME contains "Python" invokes no interpreter.
            $fixture = @'
function Invoke-PythonBatchBudgetHook {
    param([string] $ToolInputRaw)
    return $ToolInputRaw
}
Invoke-PythonBatchBudgetHook -ToolInputRaw 'x'
Invoke-PythonTestPurityDecision -ToolInputRaw 'y'
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'invoke-python-name-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }

        It 'reports no finding for a scriptblock-parameter seam invocation' {
            # Arrange: carve-out (a), the approved injectable seam.
            $fixture = @'
function Invoke-Gate {
    param(
        [scriptblock] $Invoker = { param($Path) $Path },
        [scriptblock] $ProfileReader = { $null }
    )
    $declaration = & $ProfileReader
    $result = & $Invoker 'artifacts/orchestration/orchestrator-state.json'
    return @($declaration, $result)
}
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'scriptblock-seam-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }

        It 'reports no finding when a seam variable differs from its parameter by letter case' {
            # Arrange: variable names are case-insensitive, so this is the same seam.
            # Regression guard - an earlier helper revision returned the
            # parameter-name set in a case-sensitive form, making this a false positive.
            $fixture = @'
function Invoke-Gate {
    param([scriptblock] $Invoker = { 'x' })
    return & $invoker
}
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'seam-case-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }

        It 'reports no finding for dot-sourcing a sibling helper path variable' {
            # Arrange: carve-out (b) - the sibling-script helper-load pattern.
            $fixture = @'
$script:CompletionHelpersPath = Join-Path $PSScriptRoot 'enforce-completion-helpers.ps1'
. $script:CompletionHelpersPath
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'dot-source-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }

        It 'reports no finding for dot-sourcing an inline sibling helper path' {
            # Arrange: carve-out (b) inline form, without the intermediate variable.
            $fixture = @'
. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.epic-base-branch.ps1')
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'inline-dot-source-fixture'

            # Assert
            @($findings).Count | Should -Be 0
        }
    }

    Context 'carve-out boundaries - the inline sibling-load exemption stays tight' {
        It 'still reports a dot-sourced expression that is not a Join-Path call' {
            # Arrange: an arbitrary dot-sourced expression is not the sibling pattern.
            $fixture = @'
. (Get-InterpreterPath)
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'dot-arbitrary-fixture'

            # Assert
            @($findings | Where-Object { $_.Kind -eq 'DynamicInvocation' }).Count | Should -Be 1
        }

        It 'still reports a Join-Path load that does not resolve a ps1 sibling' {
            # Arrange: no literal `.ps1` argument, so the target is unknown.
            $fixture = @'
. (Join-Path $PSScriptRoot $someName)
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'dot-nonliteral-fixture'

            # Assert
            @($findings | Where-Object { $_.Kind -eq 'DynamicInvocation' }).Count | Should -Be 1
        }

        It 'still reports an ampersand-invoked inline sibling-load expression' {
            # Arrange: the exemption is dot-source only; `&` runs the resolved path.
            $fixture = @'
& (Join-Path $PSScriptRoot 'helper.ps1')
'@
            # Act
            $findings = Get-PythonInvocationFinding -ScriptText $fixture -SourceLabel 'amp-inline-fixture'

            # Assert
            @($findings | Where-Object { $_.Kind -eq 'DynamicInvocation' }).Count | Should -Be 1
        }
    }

    Context 'repository scan' -Tag 'RepositoryScan' {
        It 'enumerates only the two guarded roots and never the bundled mirror' {
            # Arrange / Act
            $files = Get-GuardedPowerShellFile

            # Assert: non-empty, rooted, bash excluded, mirror excluded.
            @($files).Count | Should -BeGreaterThan 0

            $outsideRoots = @($files | Where-Object {
                    $_.Relative -notlike '.claude/hooks/*' -and $_.Relative -notlike '.claude/lib/*'
                })
            $outsideRoots.Count | Should -Be 0 -Because (
                'enumerated paths outside the two scan roots: ' + (($outsideRoots | ForEach-Object { $_.Relative }) -join ', '))

            $bashPaths = @($files | Where-Object { $_.Relative -like '.claude/lib/bash/*' })
            $bashPaths.Count | Should -Be 0 -Because 'the bash library is shell, not PowerShell'

            $mirrorPaths = @($files | Where-Object { $_.Relative -like 'extensions/*' })
            $mirrorPaths.Count | Should -Be 0 -Because (
                'the bundled mirror is a byte-identical second copy and is deliberately out of scan scope')
        }

        It 'reports no Python invocation beyond the allowlist across the guarded tree' {
            # Assertion A. Arrange
            $findings = Get-RepositoryPythonInvocationFinding
            $allowlist = Get-PythonInvocationAllowlist

            # Act
            $residual = Select-UnallowedPythonInvocationFinding -Finding @($findings) -Allowlist @($allowlist)

            # Assert
            @($residual).Count | Should -Be 0 -Because (
                "residual Python invocation sites:`n" + (($residual | ForEach-Object { $_.Message }) -join "`n"))
        }

        It 'carries no stale allowlist entry' {
            # Assertion B. Vacuously green while the allowlist is empty; retained so
            # any future entry that goes stale fails the suite. Arrange:
            $findings = Get-RepositoryPythonInvocationFinding
            $allowlist = Get-PythonInvocationAllowlist

            # Act
            $stale = Get-UnusedPythonInvocationAllowlistEntry -Finding @($findings) -Allowlist @($allowlist)

            # Assert
            @($stale).Count | Should -Be 0 -Because (
                'stale allowlist entries: ' + (($stale | ForEach-Object { "$($_['Path'])::$($_['Function'])" }) -join ', '))
        }
    }
}
