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
#>

$script:ClassifyFunctionRows = @(
    # Form 1: a joined shell word split at $(, ${, or a backtick.
    @{ Name = 'npm --prefix command substitution'; Command = 'npm --prefix $(pwd) run lint'; Indexes = @(2) }
    @{ Name = 'npm --prefix braced variable'; Command = 'npm --prefix ${W} run test:unit'; Indexes = @(2) }
    @{ Name = 'npm --prefix backtick substitution'; Command = 'npm --prefix `pwd` run typecheck'; Indexes = @(2) }
    @{ Name = 'env prefix before a joined npm word'; Command = 'env -u VIRTUAL_ENV npm --prefix $(pwd) run lint'; Indexes = @(2) }
    @{ Name = 'nested substitution'; Command = 'npm --prefix $(dirname $(pwd)) run lint'; Indexes = @(2) }
    @{ Name = 'chained substitutions'; Command = 'npm --prefix $(pwd)/$(echo x) run lint'; Indexes = @(2) }
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
    # Control: true before and after.
    @{ Kind = 'Control'; Command = 'npx jest'; Expected = $true }
    @{ Kind = 'Control'; Command = 'npm run lint'; Expected = $true }
    @{ Kind = 'Control'; Command = 'npm --prefix "$(pwd)" run lint'; Expected = $true }
)
