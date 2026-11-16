<#
    Shared case tables for the stage-1 classification supplement of issue #1188. Data only: this
    file holds hashtable and array literals and no command. It is dot-sourced at discovery by
    tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1 and by
    tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1.

    ClassifyFunctionRows drive Get-OrchestrationGateSupplementalPatternIndex alone: Command is the
    input and Indexes the expected index set (a subset of 2, the npm scripts pattern, and 3, the npx
    tools pattern, in ascending order).

    ClassifyGateRows drive Test-ImplementationCommand: Expected is the classification after the
    supplement. Kind is Positive (false before the supplement, true after), Negative (false before
    and after), or Control (true before and after).

    Issue #1195 adds two tables for the wrapped-payload form. ClassifyWrappedFunctionRows drive
    Get-OrchestrationGateWrappedPatternIndex alone (Name, Command, Indexes): Indexes is the ascending
    subset of 1 to 4 that the function returns for Command, given the gate's own stage-1 patterns.
    ClassifyWrappedGateRows drive Test-ImplementationCommand (Kind, Command, Expected), with Kind as
    for ClassifyGateRows, measured against the gate before and after the wrapped-payload change.
#>

$script:ClassifyFunctionRows = @(
    # Form 1: a joined shell word split at $(, ${, or a backtick.
    @{ Name = 'npm --prefix command substitution'; Command = 'npm --prefix $(pwd) run lint'; Indexes = @(2) }
    @{ Name = 'npm --prefix braced variable'; Command = 'npm --prefix ${W} run test:unit'; Indexes = @(2) }
    @{ Name = 'npm --prefix backtick substitution'; Command = 'npm --prefix `pwd` run typecheck'; Indexes = @(2) }
    @{ Name = 'env prefix before a joined npm word'; Command = 'env -u VIRTUAL_ENV npm --prefix $(pwd) run lint'; Indexes = @(2) }
    @{ Name = 'nested substitution'; Command = 'npm --prefix $(dirname $(pwd)) run lint'; Indexes = @(2) }
    @{ Name = 'chained substitutions'; Command = 'npm --prefix $(pwd)/$(echo x) run lint'; Indexes = @(2) }
    # Form 1 with a leading assignment: the npm or npx word is a later member of the run.
    @{ Name = 'leading assignment before npm'; Command = 'FOO=$(pwd) npm --prefix $(pwd) run lint'; Indexes = @(2) }
    @{ Name = 'env assignment before npm'; Command = 'env FOO=$(pwd) npm --prefix $(pwd) run lint'; Indexes = @(2) }
    @{ Name = 'leading assignment before npx'; Command = 'FOO=$(pwd) npx --prefix $(pwd) jest'; Indexes = @(3) }
    @{ Name = 'env assignment before npx'; Command = 'env FOO=$(pwd) npx --prefix $(pwd) jest'; Indexes = @(3) }
    # Form 2: npx options before the tool word.
    @{ Name = 'npx --prefix separate value'; Command = 'npx --prefix /synthetic-worktrees/w-item jest'; Indexes = @(3) }
    @{ Name = 'npx --prefix inline value'; Command = 'npx --prefix=/synthetic-worktrees/w-item tsc'; Indexes = @(3) }
    @{ Name = 'npx -C value'; Command = 'npx -C /synthetic-worktrees/w-item eslint'; Indexes = @(3) }
    @{ Name = 'npx --yes'; Command = 'npx --yes jest'; Indexes = @(3) }
    @{ Name = 'npx -y -q'; Command = 'npx -y -q prettier'; Indexes = @(3) }
    @{ Name = 'npx --no'; Command = 'npx --no jest'; Indexes = @(3) }
    @{ Name = 'npx --quiet'; Command = 'npx --quiet tsc'; Indexes = @(3) }
    @{ Name = 'npx --prefix substitution value'; Command = 'npx --prefix $(pwd) jest'; Indexes = @(3) }
    @{ Name = 'which before npx options still returns the index'; Command = 'which npx --yes jest'; Indexes = @(3) }
    # Near misses return no index.
    @{ Name = 'substitution run whose first record lacks npm'; Command = 'npm --version; echo $(pwd) lint'; Indexes = @() }
    @{ Name = 'npm inside the substitution only'; Command = 'echo $(npm --version) lint'; Indexes = @() }
    @{ Name = 'joined npm word with an ungoverned script'; Command = 'npm --prefix $(pwd) run build'; Indexes = @() }
    @{ Name = 'npx with an ungoverned tool before the governed word'; Command = 'npx cowsay jest'; Indexes = @() }
    @{ Name = 'npx -p is not an accepted option'; Command = 'npx -p prettier cowsay'; Indexes = @() }
    @{ Name = 'npx --package is not an accepted option'; Command = 'npx --package jest cowsay'; Indexes = @() }
    @{ Name = 'npx --prefix then an ungoverned tool'; Command = 'npx --prefix /synthetic-worktrees/w-item cowsay jest'; Indexes = @() }
    @{ Name = 'npx --yes then an ungoverned tool'; Command = 'npx --yes cowsay'; Indexes = @() }
    @{ Name = 'segments joined by && are not one word'; Command = 'npm --version && echo lint'; Indexes = @() }
    @{ Name = 'bare npx tool is left to the unchanged pattern'; Command = 'npx jest'; Indexes = @() }
    @{ Name = 'bare npm script is left to the unchanged pattern'; Command = 'npm run lint'; Indexes = @() }
    @{ Name = 'quoted substitution is one record'; Command = 'npm --prefix "$(pwd)" run lint'; Indexes = @() }
    @{ Name = 'unclosed substitution is not joined'; Command = 'npm --prefix $(pwd run lint'; Indexes = @() }
    @{ Name = 'an empty command'; Command = ''; Indexes = @() }
    # Issue #1195 (DEV-R3): each row fails when its cycle-3 guard is removed.
    @{ Name = 'npm inside a backtick substitution only (C2)'; Command = 'echo `npm --version` lint'; Indexes = @() }
    @{ Name = 'npm inside a nested substitution only (C4)'; Command = 'echo $(echo npm --version) lint'; Indexes = @() }
    @{ Name = 'npx inside an assignment substitution only (C5)'; Command = 'FOO=$(echo npx jest) ls'; Indexes = @() }
    @{ Name = 'npm script word inside an assignment substitution only (C3)'; Command = 'FOO=$(echo npm x lint) npm --version'; Indexes = @() }
)

$script:ClassifyGateRows = @(
    # Positive: false before the supplement, true after.
    @{ Kind = 'Positive'; Command = 'npm --prefix $(pwd) run lint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npm --prefix ${W} run test:unit'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npm --prefix `pwd` run typecheck'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'env -u VIRTUAL_ENV npm --prefix $(pwd) run lint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx --prefix /synthetic-worktrees/w-item jest'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx --prefix=/synthetic-worktrees/w-item tsc'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx -C /synthetic-worktrees/w-item eslint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx --yes jest'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx -y -q prettier'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx --no jest'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx --quiet tsc'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npx --prefix $(pwd) jest'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npm --prefix $(dirname $(pwd)) run lint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'npm --prefix $(pwd)/$(echo x) run lint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'FOO=$(pwd) npm --prefix $(pwd) run lint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'env FOO=$(pwd) npm --prefix $(pwd) run lint'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'FOO=$(pwd) npx --prefix $(pwd) jest'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'env FOO=$(pwd) npx --prefix $(pwd) jest'; Expected = $true }
    # Negative: false before and after.
    @{ Kind = 'Negative'; Command = 'npm --version; echo $(pwd) lint'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'echo $(npm --version) lint'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npm --prefix $(pwd) run build'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npx cowsay jest'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npx -p prettier cowsay'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npx --package jest cowsay'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npx --prefix /synthetic-worktrees/w-item cowsay jest'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npx --yes cowsay'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'which npx --yes jest'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'npm --version && echo lint'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'echo `npm --version` lint'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'echo $(echo npm --version) lint'; Expected = $false }
    # Control: true before and after.
    @{ Kind = 'Control'; Command = 'npx jest'; Expected = $true }
    @{ Kind = 'Control'; Command = 'npm run lint'; Expected = $true }
    @{ Kind = 'Control'; Command = 'npm --prefix "$(pwd)" run lint'; Expected = $true }
)

$script:ClassifyWrappedFunctionRows = @(
    # One row per branch of the wrapped-payload enumeration.
    @{ Name = 'plain sh -c payload'; Command = 'sh -c "pytest -q"'; Indexes = @(1) }
    @{ Name = 'option bundle -lc'; Command = 'bash -lc "pyright"'; Indexes = @(1) }
    @{ Name = 'pwsh -Command prefix'; Command = 'pwsh -Comm "npm run lint"'; Indexes = @(2) }
    @{ Name = 'pwsh -CommandWithArgs'; Command = 'pwsh -CommandWithArgs "pytest"'; Indexes = @(1) }
    @{ Name = 'pwsh -cwa'; Command = 'pwsh -cwa "npx jest"'; Indexes = @(3) }
    @{ Name = 'eval payload'; Command = 'eval "pytest"'; Indexes = @(1) }
    @{ Name = 'env -u NAME'; Command = 'env -u VIRTUAL_ENV bash -c "pytest"'; Indexes = @(1) }
    @{ Name = 'env --unset=NAME'; Command = 'env --unset=VIRTUAL_ENV sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'env -C DIR'; Command = 'env -C dir sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'env --unset NAME separate value'; Command = 'env --unset NAME sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'env --chdir DIR separate value'; Command = 'env --chdir dir sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'env -S split string is declined'; Command = 'env -S sh -c "pytest"'; Indexes = @() }
    @{ Name = 'pwsh -e encoded command is declined'; Command = 'pwsh -e cAB5AHQAZQBzAHQA'; Indexes = @() }
    @{ Name = 'pwsh -ec encoded command is declined'; Command = 'pwsh -ec cAB5AHQAZQBzAHQA'; Indexes = @() }
    @{ Name = 'unbalanced payload quote yields no payload'; Command = 'sh -c "pytest'; Indexes = @() }
    @{ Name = 'xargs injected words'; Command = 'echo x | xargs sh -c ''pytest'''; Indexes = @(1) }
    @{ Name = 'timeout prefix'; Command = 'timeout 600 sh -c ''npx jest'''; Indexes = @(3) }
    @{ Name = 'time -p prefix'; Command = 'time -p sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'command prefix'; Command = 'command sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'nohup prefix'; Command = 'nohup sh -c "pytest"'; Indexes = @(1) }
    @{ Name = 'nested payload at depth 4'; Command = 'sh -c "sh -c \"sh -c ''sh -c \\\"pytest\\\"''\""'; Indexes = @(1) }
    @{ Name = 'nested payload at depth 5'; Command = 'sh -c ''sh -c "sh -c \"sh -c ''\''''sh -c \\\"pytest\\\"''\''''\""'''; Indexes = @() }
    @{ Name = 'payload matched through the supplement only'; Command = 'sh -c "npm --prefix $(pwd) run lint"'; Indexes = @(2) }
    @{ Name = 'masked mention in a payload'; Command = 'sh -c "echo ''pytest''"'; Indexes = @() }
    @{ Name = 'variable payload'; Command = 'sh -c "$CMD"'; Indexes = @() }
    @{ Name = 'segment with no wrapper'; Command = 'pytest -q'; Indexes = @() }
    @{ Name = 'empty command'; Command = ''; Indexes = @() }
    # Output contract and option shapes.
    @{ Name = 'ascending distinct union of two indexes'; Command = 'sh -c "npx jest; pytest"'; Indexes = @(1, 3) }
    @{ Name = 'repeated index is returned once'; Command = 'sh -c "pytest; pytest -q"'; Indexes = @(1) }
    @{ Name = 'index 0 is never returned'; Command = 'sh -c "git add ."'; Indexes = @() }
    @{ Name = 'hit that stage 2 later drops'; Command = 'sh -c "grep pytest docs"'; Indexes = @(1) }
)

$script:ClassifyWrappedGateRows = @(
    # Positive: false before the wrapped-payload change, true after.
    @{ Kind = 'Positive'; Command = 'sh -c "pytest -q"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'bash -c ''ruff check .'''; Expected = $true }
    @{ Kind = 'Positive'; Command = 'bash -lc "pyright"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'sh -c "npm run lint"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'bash -c "npx jest"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'pwsh -Command "npm run lint"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'pwsh -NoProfile -c "pytest"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'powershell -Command "npx eslint ."'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'pwsh -CommandWithArgs "pytest"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'eval "pytest"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'env -u VIRTUAL_ENV bash -c "pytest"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'timeout 600 sh -c ''npx jest'''; Expected = $true }
    @{ Kind = 'Positive'; Command = 'echo x | xargs sh -c ''pytest'''; Expected = $true }
    @{ Kind = 'Positive'; Command = 'bash -c "bash -c ''pytest''"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'bash -c "pwsh -File tests/scripts/x.Tests.ps1"'; Expected = $true }
    @{ Kind = 'Positive'; Command = 'sh -c "npm --prefix $(pwd) run lint"'; Expected = $true }
    # Negative: false before and after (mentions, D18 exclusions, recorded non-goals).
    @{ Kind = 'Negative'; Command = 'sh -c "echo ''pytest''"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'bash -c "grep -rn ''ruff'' docs/"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'pwsh -c "Write-Output ''npm run lint''"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'echo "sh -c ''pytest''"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'sh -c "$CMD"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'CMD=pytest; sh -c "$CMD"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'pwsh -EncodedCommand cAB5AHQAZQBzAHQA'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'sh -c "$(cat cmd.txt)"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'env -S "sh -c ''pytest''"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'powershell -Command "Invoke-Pester"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'cmd /c "pytest"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'timeout 60 "pytest"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'bash -c -- "pytest"'; Expected = $false }
    @{ Kind = 'Negative'; Command = 'sh -c "grep pytest docs"'; Expected = $false }
    # Control: true before and after.
    @{ Kind = 'Control'; Command = 'sh -c "poetry run pytest"'; Expected = $true }
    @{ Kind = 'Control'; Command = 'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"'; Expected = $true }
    @{ Kind = 'Control'; Command = 'bash -c ''git add .'''; Expected = $true }
    @{ Kind = 'Control'; Command = 'sh -c "cd x && npm run lint"'; Expected = $true }
)
