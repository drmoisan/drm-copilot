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
      - ExistingDenial: research section 6.2 and spec AC-2 (as amended by decisions D15,
        D16, and D17; rows ED-43 to ED-50 are the D16 pipeline-consumer and sort rows, and
        rows ED-51 to ED-96 are the D17 unmodelled-construct and executing-option rows).
        Each row is classified as implementation today and must stay classified, with the
        generic final deny text unchanged.
      - FalsePositive: research section 6.3 and spec AC-1. Each row is classified today
        and must be unclassified after the stage-2 confirmation.
      - NonGoal: the D2 declared non-goals and the two D15 rows (spec AC-3). Each row is
        unclassified today and must stay unclassified; classification is never widened.
      - BookkeepingLeg and D5D14: the decision-level bookkeeping-leg rows (research section
        6.4; spec AC-6, AC-8, AC-13) and the decision D5 rows as amended by D14 (spec AC-7),
        run by enforce-orchestration-preimplementation-gate.BookkeepingLeg.Tests.ps1 and
        tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-bookkeeping-leg.Tests.ps1.

    Every row carries a stable identifier (Id), the command text (Command), and Expected: the
    Test-ImplementationCommand result in the first three tables, the decision in the last two.
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
    @{ Id = 'ED-43'; Command = 'pwsh -NoProfile -Command "Get-ChildItem tests/scripts/run.ps1 | ForEach-Object { & $_.FullName }"'; Expected = $true }
    @{ Id = 'ED-44'; Command = 'pwsh -NoProfile -Command "Get-ChildItem tests/scripts/ -Filter *.Tests.ps1 | ForEach-Object { & $_ }"'; Expected = $true }
    @{ Id = 'ED-45'; Command = 'pwsh -NoProfile -Command "Get-ChildItem tests/scripts/run.ps1 | % { & $_ }"'; Expected = $true }
    @{ Id = 'ED-46'; Command = 'pwsh -NoProfile -Command "Get-Command pytest | ForEach-Object { & $_ }"'; Expected = $true }
    @{ Id = 'ED-47'; Command = 'pwsh -NoProfile -Command "Get-Command pytest | ForEach-Object { & $_.Source -q }"'; Expected = $true }
    @{ Id = 'ED-48'; Command = 'pwsh -NoProfile -Command "Get-Command Invoke-Pester | ForEach-Object { & $_ }"'; Expected = $true }
    @{ Id = 'ED-49'; Command = 'echo pytest | xargs env'; Expected = $true }
    @{ Id = 'ED-50'; Command = 'sort --compress-program pytest big.txt'; Expected = $true }
    @{ Id = 'ED-51'; Command = '(echo pytest) | xargs env'; Expected = $true }
    @{ Id = 'ED-52'; Command = '{ echo pytest; } | xargs env'; Expected = $true }
    @{ Id = 'ED-53'; Command = 'echo pytest | (cat) | xargs env'; Expected = $true }
    @{ Id = 'ED-54'; Command = 'cat <(echo pytest) | xargs env'; Expected = $true }
    @{ Id = 'ED-55'; Command = 'cat < <(echo pytest) | xargs env'; Expected = $true }
    @{ Id = 'ED-56'; Command = 'xargs env < <(echo pytest)'; Expected = $true }
    @{ Id = 'ED-57'; Command = 'xargs env 0< <(echo pytest)'; Expected = $true }
    @{ Id = 'ED-58'; Command = 'xargs -n1 env < <(echo pytest)'; Expected = $true }
    @{ Id = 'ED-59'; Command = 'xargs env < <(printf pytest)'; Expected = $true }
    @{ Id = 'ED-60'; Command = 'xargs env < <(grep -o pytest x)'; Expected = $true }
    @{ Id = 'ED-61'; Command = 'env < <(echo pytest) xargs env'; Expected = $true }
    @{ Id = 'ED-62'; Command = 'while read c; do $c; done < <(echo pytest)'; Expected = $true }
    @{ Id = 'ED-63'; Command = 'echo pytest > >(xargs env)'; Expected = $true }
    @{ Id = 'ED-64'; Command = 'echo pytest 1> >(xargs env)'; Expected = $true }
    @{ Id = 'ED-65'; Command = 'echo pytest >> >(xargs env)'; Expected = $true }
    @{ Id = 'ED-66'; Command = 'grep -o pytest x > >(xargs env)'; Expected = $true }
    @{ Id = 'ED-67'; Command = 'xargs env <<< $(grep -o pytest x)'; Expected = $true }
    @{ Id = 'ED-68'; Command = "grep pytest x <<'EOF'`nhello`nEOF"; Expected = $true }
    @{ Id = 'ED-69'; Command = 'env $(grep -o pytest x)'; Expected = $true }
    @{ Id = 'ED-70'; Command = 'env `grep -o pytest x`'; Expected = $true }
    @{ Id = 'ED-71'; Command = 'eval grep pytest x'; Expected = $true }
    @{ Id = 'ED-72'; Command = 'pwsh -c "function Select-String { & $args[0] }; Select-String pytest"'; Expected = $true }
    @{ Id = 'ED-73'; Command = 'pwsh -c "@(''pytest'') | Select-String pytest"'; Expected = $true }
    @{ Id = 'ED-74'; Command = 'pwsh -c "Get-Command pytest > out.txt"'; Expected = $true }
    @{ Id = 'ED-75'; Command = 'grep pytest x > out.txt'; Expected = $true }
    @{ Id = 'ED-76'; Command = 'grep pytest x & xargs env'; Expected = $true }
    @{ Id = 'ED-77'; Command = 'sh -c ''grep pytest x; "$0"'' pytest'; Expected = $true }
    @{ Id = 'ED-78'; Command = 'f() { grep pytest x; }'; Expected = $true }
    @{ Id = 'ED-79'; Command = 'a=(x) && grep pytest x'; Expected = $true }
    @{ Id = 'ED-80'; Command = 'grep pytest x # note'; Expected = $true }
    @{ Id = 'ED-81'; Command = 'grep pytest x; if true; then echo y; fi'; Expected = $true }
    @{ Id = 'ED-82'; Command = 'pwsh -c "(Get-Command pytest).ToString()"'; Expected = $true }
    @{ Id = 'ED-83'; Command = 'make test | grep pytest'; Expected = $true }
    @{ Id = 'ED-84'; Command = 'PATH=./bin grep pytest x'; Expected = $true }
    @{ Id = 'ED-85'; Command = 'alias grep=xargs; grep pytest x'; Expected = $true }
    @{ Id = 'ED-86'; Command = 'echo pytest | $''xargs\0/grep'' env'; Expected = $true }
    @{ Id = 'ED-87'; Command = 'sh -c ''echo x''$''\n'''' pytest'''; Expected = $true }
    @{ Id = 'ED-88'; Command = 'sh -c ''echo pytest''$''\x7c''''xargs env'''; Expected = $true }
    @{ Id = 'ED-89'; Command = 'echo pytest; env $_'; Expected = $true }
    @{ Id = 'ED-90'; Command = 'echo pytest; pwsh -c $_'; Expected = $true }
    @{ Id = 'ED-91'; Command = 'printf -v c pytest; env $c'; Expected = $true }
    @{ Id = 'ED-92'; Command = 'sh -c ''echo x\\' + "`n" + 'pytest'''; Expected = $true }
    @{ Id = 'ED-93'; Command = 'echo pytest | env -S''xargs -I{} env {}'' grep'; Expected = $true }
    @{ Id = 'ED-94'; Command = 'bash -c ''echo pytest; env $_'''; Expected = $true }
    @{ Id = 'ED-95'; Command = 'git grep -iOpytest pytest'; Expected = $true }
    @{ Id = 'ED-96'; Command = 'rg --hostname-bin pytest x'; Expected = $true }
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

# Bookkeeping-leg rows (research section 6.4; spec AC-6, AC-8, AC-13). Driven through the
# decision with the default configuration. Root $true: the checkpoint read is mocked to a
# synthetic worktree; Root $false: a NOT-ready checkpoint text is injected, so there is no
# root. IndexExitCode and IndexOutput are the mocked staged-index read. Expected is the
# decision; every deny carries the generic deny text with no suffix.
$script:ClassificationBookkeepingLegCase = @(
    @{ Id = 'BL-01'; Command = 'git add .claude/agent-memory/r/notes.md'; Expected = 'allow'; Root = $false; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-02'; Command = 'git add -- .claude/agent-memory/r/notes.md'; Expected = 'allow'; Root = $false; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-03'; Command = 'git commit -m m -- .claude/agent-memory/r/a.md'; Expected = 'allow'; Root = $false; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-04'; Command = 'git commit -F msg.txt -- .claude/agent-memory/r/a.md'; Expected = 'allow'; Root = $false; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-05'; Command = 'git commit -m m'; Expected = 'allow'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0" }
    @{ Id = 'BL-06'; Command = 'git commit -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-07'; Command = 'git commit -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0src/app.ps1`0" }
    @{ Id = 'BL-08'; Command = 'git commit -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 128; IndexOutput = '' }
    @{ Id = 'BL-09'; Command = 'git commit -m m'; Expected = 'deny'; Root = $false; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0" }
    @{ Id = 'BL-10'; Command = 'git commit -am m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0" }
    @{ Id = 'BL-11'; Command = 'git commit -a -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0" }
    @{ Id = 'BL-12'; Command = 'git commit --amend -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0" }
    @{ Id = 'BL-13'; Command = 'git add .'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-14'; Command = 'git add -A'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-15'; Command = 'git add -u'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-16'; Command = 'git add :/'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-17'; Command = 'git add .claude/agent-memory/r/*.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-18'; Command = 'git add .claude/agent-memory/'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-19'; Command = 'git add .claude/agent-memory/../src/x.ps1'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-20'; Command = 'git add .claude\agent-memory\x.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-21'; Command = 'git add .claude/agent-memory/r/a.md src/x.ps1'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-22'; Command = 'git commit -i -m m -- .claude/agent-memory/r/a.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-23'; Command = 'git commit -o -m m -- .claude/agent-memory/r/a.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-24'; Command = 'git commit --pathspec-from-file=list.txt -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0" }
    @{ Id = 'BL-25'; Command = 'git commit --message=m -- .claude/agent-memory/r/a.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-26'; Command = 'git add .claude/agent-memory/r/a.md && pytest'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-27'; Command = 'git add .claude/agent-memory/r/a.md && git push'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-28'; Command = 'git commit -m "$x" -- .claude/agent-memory/r/a.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'BL-29'; Command = 'git add ".claude/agent-memory/r/a.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
)

# Decision D5 rows as amended by D14 (spec AC-7). The two allow rows mix a declared-root path
# with an issue #539 tree path; the deny rows carry no declared-root path or a rejected -C
# selector, and keep the generic deny text with no suffix.
$script:ClassificationD5D14Case = @(
    @{ Id = 'DW-01'; Command = 'git add -- .claude/agent-memory/r/a.md docs/features/active/x/plan.md'; Expected = 'allow'; Root = $false; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'DW-02'; Command = 'git commit -m m'; Expected = 'allow'; Root = $true; IndexExitCode = 0; IndexOutput = ".claude/agent-memory/r/a.md`0docs/features/active/x/plan.md`0" }
    @{ Id = 'DW-03'; Command = 'git commit -m m'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = "docs/features/active/x/plan.md`0docs/features/epics/e/epic.md`0" }
    @{ Id = 'DW-04'; Command = 'git commit -F msg.txt -- docs/features/active/x/plan.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'DW-05'; Command = 'git commit --file msg.txt -- docs/features/active/x/plan.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
    @{ Id = 'DW-06'; Command = 'git -C //server/share/wt add -- .claude/agent-memory/r/a.md'; Expected = 'deny'; Root = $true; IndexExitCode = 0; IndexOutput = '' }
)
