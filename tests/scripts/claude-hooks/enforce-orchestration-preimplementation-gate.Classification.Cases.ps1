<#
.SYNOPSIS
    Data-only classification corpus for the preimplementation gate (issue #1160).

.DESCRIPTION
    Dot-sourced by the Claude runner
    tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1
    and the Codex runner
    tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1,
    so both surfaces judge the same rows. The file defines data only: no Describe, no
    function, and no I/O.

    Tables:
      - ExistingDenial: research section 6.2 and spec AC-2 (as amended by decision D15).
        Each row is classified as implementation today and must stay classified, with the
        generic final deny text unchanged.
      - FalsePositive: research section 6.3 and spec AC-1. Each row is classified today
        and must be unclassified after the stage-2 confirmation.
      - NonGoal: the D2 declared non-goals and the two D15 rows (spec AC-3). Each row is
        unclassified today and must stay unclassified; classification is never widened.

    Every row carries a stable identifier (Id), the command text (Command), and the
    expected Test-ImplementationCommand result (Expected).
#>

$script:ClassificationExistingDenialCase = @(
    @{ Id = 'ED-01'; Command = 'poetry run pytest tests/scripts'; Expected = $true }
    @{ Id = 'ED-02'; Command = 'git add .'; Expected = $true }
    @{ Id = 'ED-03'; Command = 'git commit -m "test"'; Expected = $true }
    @{ Id = 'ED-04'; Command = 'poetry run black scripts --check'; Expected = $true }
    @{ Id = 'ED-05'; Command = 'npm --prefix extensions/drm-copilot run test:unit -- --coverage'; Expected = $true }
    @{ Id = 'ED-06'; Command = 'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"'; Expected = $true }
    @{ Id = 'ED-07'; Command = 'git -C ../other-worktree add .'; Expected = $true }
    @{ Id = 'ED-08'; Command = 'git --git-dir=../other/.git commit -m wip'; Expected = $true }
    @{ Id = 'ED-09'; Command = 'git --work-tree=../other add .'; Expected = $true }
    @{ Id = 'ED-10'; Command = 'git --future-unmodeled-option add .'; Expected = $true }
    @{ Id = 'ED-11'; Command = '(git add .)'; Expected = $true }
    @{ Id = 'ED-12'; Command = '$(git add .)'; Expected = $true }
    @{ Id = 'ED-13'; Command = 'echo scripts/powershell/Sample.ps1 | xargs git add'; Expected = $true }
    @{ Id = 'ED-14'; Command = "bash -c 'git add .'"; Expected = $true }
    @{ Id = 'ED-15'; Command = 'sh -c "git add ."'; Expected = $true }
    @{ Id = 'ED-16'; Command = 'env git add .'; Expected = $true }
    @{ Id = 'ED-17'; Command = "bash <<'EOF'`ngit add .`nEOF"; Expected = $true }
    @{ Id = 'ED-18'; Command = 'echo "$(git add .)"'; Expected = $true }
    @{ Id = 'ED-19'; Command = 'git add src/app.ps1'; Expected = $true }
    @{ Id = 'ED-20'; Command = 'poetry run black src/'; Expected = $true }
    @{ Id = 'ED-21'; Command = 'npx prettier --check .'; Expected = $true }
    @{ Id = 'ED-22'; Command = 'git add src/feature.ps1'; Expected = $true }
    @{ Id = 'ED-23'; Command = 'bash -c "git add src/feature.ps1"'; Expected = $true }
    @{ Id = 'ED-24'; Command = 'git add docs/features/epics/sample/epic.md && poetry run pytest'; Expected = $true }
    @{ Id = 'ED-25'; Command = 'env -u VIRTUAL_ENV poetry run pytest'; Expected = $true }
    @{ Id = 'ED-26'; Command = 'timeout 60 pytest'; Expected = $true }
    @{ Id = 'ED-27'; Command = 'FOO=1 pytest'; Expected = $true }
    @{ Id = 'ED-28'; Command = 'python -m pytest'; Expected = $true }
    @{ Id = 'ED-29'; Command = 'pytest | tee out.txt'; Expected = $true }
    @{ Id = 'ED-30'; Command = 'echo pytest | bash'; Expected = $true }
    @{ Id = 'ED-31'; Command = "bash <<'EOF'`npytest`nEOF"; Expected = $true }
    @{ Id = 'ED-32'; Command = 'pwsh -c "Invoke-Expression ''Invoke-Pester''"'; Expected = $true }
    @{ Id = 'ED-33'; Command = 'pwsh -c "[Diagnostics.Process]::Start(''tests/scripts/run.ps1'')"'; Expected = $true }
    @{ Id = 'ED-34'; Command = 'pwsh -NoProfile -File tests/scripts/run.ps1'; Expected = $true }
    @{ Id = 'ED-35'; Command = 'pwsh -c "& ./tests/scripts/x.ps1"'; Expected = $true }
    @{ Id = 'ED-36'; Command = 'xargs -n1 pytest'; Expected = $true }
    @{ Id = 'ED-37'; Command = 'find . -name x -exec pytest {} ;'; Expected = $true }
    @{ Id = 'ED-38'; Command = 'npm install prettier'; Expected = $true }
    @{ Id = 'ED-39'; Command = 'rg --pre pytest x'; Expected = $true }
    @{ Id = 'ED-40'; Command = 'git grep -O vim pytest'; Expected = $true }
    @{ Id = 'ED-41'; Command = 'command -v pytest'; Expected = $true }
    @{ Id = 'ED-42'; Command = 'echo "pytest'; Expected = $true }
)

$script:ClassificationFalsePositiveCase = @(
    @{ Id = 'FP-01'; Command = 'ps aux | grep pytest'; Expected = $false }
    @{ Id = 'FP-02'; Command = 'ps -ef | grep -i pytest'; Expected = $false }
    @{ Id = 'FP-03'; Command = 'pgrep -f pytest'; Expected = $false }
    @{ Id = 'FP-04'; Command = 'Get-Process -Name pytest'; Expected = $false }
    @{ Id = 'FP-05'; Command = 'rg -n pytest pyproject.toml'; Expected = $false }
    @{ Id = 'FP-06'; Command = 'grep -rn ruff docs/'; Expected = $false }
    @{ Id = 'FP-07'; Command = 'git log --grep pytest'; Expected = $false }
    @{ Id = 'FP-08'; Command = 'git grep black'; Expected = $false }
    @{ Id = 'FP-09'; Command = 'which pytest'; Expected = $false }
    @{ Id = 'FP-10'; Command = 'Get-Command pytest'; Expected = $false }
    @{ Id = 'FP-11'; Command = 'poetry show pytest'; Expected = $false }
    @{ Id = 'FP-12'; Command = 'pip show black'; Expected = $false }
    @{ Id = 'FP-13'; Command = 'npm ls prettier'; Expected = $false }
    @{ Id = 'FP-14'; Command = 'cat pytest.ini'; Expected = $false }
    @{ Id = 'FP-15'; Command = 'echo git add docs'; Expected = $false }
    @{ Id = 'FP-16'; Command = 'pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match ''Invoke-Pester'' }"'; Expected = $false }
    @{ Id = 'FP-17'; Command = 'pwsh -c "Select-String -Path x -Pattern Invoke-Pester"'; Expected = $false }
)

$script:ClassificationNonGoalCase = @(
    @{ Id = 'NG-01'; Command = '.venv/bin/pytest'; Expected = $false }
    @{ Id = 'NG-02'; Command = 'npx --yes jest'; Expected = $false }
    @{ Id = 'NG-03'; Command = 'node run-jest.cjs'; Expected = $false }
    @{ Id = 'NG-04'; Command = 'npm test'; Expected = $false }
    @{ Id = 'NG-05'; Command = 'Invoke-PoshQCParallelTest'; Expected = $false }
    @{ Id = 'NG-06'; Command = 'Invoke-Pester'; Expected = $false }
    @{ Id = 'NG-07'; Command = 'sh artifacts/launcher.sh'; Expected = $false }
    @{ Id = 'NG-08'; Command = 'pwsh -c "Invoke-Expression ''pytest''"'; Expected = $false }
    @{ Id = 'NG-09'; Command = 'pwsh -c "[Diagnostics.Process]::Start(''pytest'')"'; Expected = $false }
)
