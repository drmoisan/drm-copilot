<#
.SYNOPSIS
    Shared decision-table rows of the release-commit allowance leg (issue #1201).

.DESCRIPTION
    Dot-sourced in BeforeDiscovery (rows) and BeforeAll (constants) by
    tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1
    and tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1.
    Each row is a hashtable read by the suites:
      Id, Command, Expected ('allow' or 'deny'), Suffix (the text after the generic deny text);
      optional Config (allowance file text; default $script:ReleaseAllowanceValidConfig),
      ConfigAbsent, ConfigThrows, Directory (the allowed_paths entry the container seam reports
      as a directory), ContainerThrows, Branch (default release/v1.2.3; $null is a detached HEAD),
      StagedExitCode and StagedOutput (default exit 0 with package.json and CHANGELOG.md),
      StagedNull, BookkeepingConfig, Mode ('command', 'write', or 'raw'), ReasonLike (a pattern the
      deny text must match instead of an exact comparison), OneSuffix, and Invoke (seam name to
      exact call count).
    No row creates a file, starts a process, or reads a real worktree.
#>

$script:ReleaseAllowanceGenericDenyText = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
$script:ReleaseAllowanceSyntheticRoot = '/synthetic-worktrees/release'
$script:ReleaseAllowanceUnexpandableCommand = 'git -C "$WT" add package.json'
$script:ReleaseAllowanceValidConfig = '{"schema_version": 1, "allowances": [{"id": "release-version-bump", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "CHANGELOG.md"]}]}'
$script:ReleaseAllowanceDisabledBookkeepingConfig = '{"schema_version": 1, "bookkeeping_roots": []}'

$releaseSuffix = ' Release allowance not applied: '
$optionCode = $releaseSuffix + 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED: '
$pathCode = $releaseSuffix + 'RELEASE_ALLOWANCE_PATH_NOT_ALLOWED: '
$modelCode = $releaseSuffix + 'RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED: '
$configCode = $releaseSuffix + 'RELEASE_ALLOWANCE_CONFIG_INVALID: '
$branchCode = $releaseSuffix + 'RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED: '
$twoAllowanceConfig = { param([string] $FirstPattern, [string] $FirstPaths, [string] $SecondPaths)
    '{"schema_version": 1, "allowances": [{"id": "first", "branch_patterns": ["' + $FirstPattern + '"], "allowed_paths": [' + $FirstPaths + ']}, {"id": "second", "branch_patterns": ["release/v*"], "allowed_paths": [' + $SecondPaths + ']}]}'
}

$script:ReleaseAllowanceDecisionCase = @(
    # AC-4: no allowance file at R keeps today's text and starts no git read.
    @{ Id = 'AC4-add-absent'; Command = 'git add package.json'; Expected = 'deny'; Suffix = ''; ConfigAbsent = $true; Invoke = @{ 'Get-EpicScopeWorktreeHeadBranch' = 0; 'Get-OrchestrationGateStagedIndex' = 0; 'Test-OrchestrationGateReleaseAllowancePathIsContainer' = 0 } }
    @{ Id = 'AC4-commit-absent'; Command = 'git commit -m ''x'''; Expected = 'deny'; Suffix = ''; ConfigAbsent = $true; Invoke = @{ 'Get-EpicScopeWorktreeHeadBranch' = 0; 'Get-OrchestrationGateStagedIndex' = 0; 'Test-OrchestrationGateReleaseAllowancePathIsContainer' = 0 } }
    # AC-5 and AC-6: the leg never reads the file for a Write path, an injected checkpoint, or a line without git add or git commit.
    @{ Id = 'AC5-write-path'; Command = 'src/app.ps1'; Mode = 'write'; Expected = 'deny'; Suffix = ''; Invoke = @{ 'Get-OrchestrationGateReleaseAllowanceConfigText' = 0 } }
    @{ Id = 'AC5-injected-checkpoint'; Command = 'git add package.json'; Mode = 'raw'; Expected = 'deny'; Suffix = ''; Invoke = @{ 'Get-OrchestrationGateReleaseAllowanceConfigText' = 0 } }
    @{ Id = 'AC6-no-git-segment'; Command = 'pytest'; Expected = 'deny'; Suffix = ''; Invoke = @{ 'Get-OrchestrationGateReleaseAllowanceConfigText' = 0 } }
    # AC-8: allowed git add forms.
    @{ Id = 'AC8-add-two-paths'; Command = 'git add package.json CHANGELOG.md'; Expected = 'allow'; Invoke = @{ 'Get-OrchestrationGateStagedIndex' = 0; 'Get-EpicScopeWorktreeHeadBranch' = 1; 'Test-OrchestrationGateReleaseAllowancePathIsContainer' = 2 } }
    @{ Id = 'AC8-add-separator'; Command = 'git add -- package.json'; Expected = 'allow' }
    @{ Id = 'AC8-add-target-root'; Command = 'git -C /synthetic-worktrees/release add package.json'; Expected = 'allow' }
    @{ Id = 'AC8-add-target-root-case'; Command = 'git -C /SYNTHETIC-WORKTREES/RELEASE add package.json'; Expected = 'allow' }
    @{ Id = 'AC8-add-target-root-trailing-slash'; Command = 'git -C /synthetic-worktrees/release/ add package.json'; Expected = 'allow' }
    @{ Id = 'AC8-add-trailing-separator'; Command = 'git add package.json;'; Expected = 'allow' }
    # AC-9: allowed git commit forms.
    @{ Id = 'AC9-commit-m'; Command = 'git commit -m ''release'''; Expected = 'allow'; Invoke = @{ 'Get-OrchestrationGateStagedIndex' = 1 } }
    @{ Id = 'AC9-commit-message'; Command = 'git commit --message ''release'''; Expected = 'allow' }
    @{ Id = 'AC9-commit-message-equals'; Command = 'git commit --message=release'; Expected = 'allow' }
    @{ Id = 'AC9-commit-F'; Command = 'git commit -F msg.txt'; Expected = 'allow' }
    @{ Id = 'AC9-commit-file-equals'; Command = 'git commit --file=msg.txt'; Expected = 'allow' }
    @{ Id = 'AC9-commit-file'; Command = 'git commit --file msg.txt'; Expected = 'allow' }
    @{ Id = 'AC9-commit-s-two-messages'; Command = 'git commit -s -m ''a'' -m ''b'''; Expected = 'allow' }
    @{ Id = 'AC9-commit-signoff'; Command = 'git commit --signoff -m ''release'''; Expected = 'allow' }
    # AC-10: the evaluated set is the union of the staged names and the preceding git add operands.
    @{ Id = 'AC10-add-then-commit'; Command = 'git add package.json CHANGELOG.md && git commit -m ''release'''; Expected = 'allow'; StagedOutput = ''; Invoke = @{ 'Get-OrchestrationGateStagedIndex' = 1 } }
    # AC-11: one single allowance qualifies the whole line.
    @{ Id = 'AC11-second-matches-branch'; Command = 'git add package.json'; Expected = 'allow'; Config = (& $twoAllowanceConfig 'hotfix/*' '"package.json"' '"package.json", "CHANGELOG.md"') }
    @{ Id = 'AC11-second-lists-paths'; Command = 'git add package.json CHANGELOG.md'; Expected = 'allow'; Config = (& $twoAllowanceConfig 'release/v*' '"README.md"' '"package.json", "CHANGELOG.md"') }
    @{ Id = 'AC11-split-across-allowances'; Command = 'git add package.json && git commit -m ''release'''; Expected = 'deny'; StagedOutput = "CHANGELOG.md`0"; Config = (& $twoAllowanceConfig 'release/v*' '"package.json"' '"CHANGELOG.md"'); Suffix = $releaseSuffix + 'RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED: staged path ''CHANGELOG.md'' is not an allowed path' }
    # AC-12: configuration failures.
    @{ Id = 'AC12-config-read-failure'; Command = 'git add package.json'; Expected = 'deny'; ConfigThrows = $true; Suffix = $configCode + 'the file could not be read' }
    @{ Id = 'AC12-invalid-document'; Command = 'git add package.json'; Expected = 'deny'; Config = '{"schema_version": 2, "allowances": []}'; Suffix = $configCode + 'schema_version is not the integer 1'; Invoke = @{ 'Get-EpicScopeWorktreeHeadBranch' = 0; 'Get-OrchestrationGateStagedIndex' = 0 } }
    @{ Id = 'AC12-directory-entry'; Command = 'git add package.json'; Expected = 'deny'; Directory = 'CHANGELOG.md'; Suffix = $configCode + 'allowed_paths entry ''CHANGELOG.md'' is a directory' }
    @{ Id = 'AC12-container-probe-failure'; Command = 'git add package.json'; Expected = 'deny'; ContainerThrows = $true; Suffix = $configCode + 'allowed_paths entry ''package.json'' could not be checked' }
    @{ Id = 'AC12-suffix-after-bookkeeping'; Command = 'git add package.json'; Expected = 'deny'; Config = '{"schema_version": 2, "allowances": []}'; BookkeepingConfig = '{"schema_version": 1, "bookkeeping_roots": [], "extra": 1}'; Suffix = " Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: unknown top-level key 'extra'." + $configCode + 'schema_version is not the integer 1' }
    # AC-13: whole-line shape.
    @{ Id = 'AC13-non-git-segment'; Command = 'git add package.json && pytest'; Expected = 'deny'; Suffix = $modelCode + 'segment ''pytest'' is not a modelled git add or git commit'; Invoke = @{ 'Get-EpicScopeWorktreeHeadBranch' = 0; 'Get-OrchestrationGateStagedIndex' = 0 } }
    @{ Id = 'AC13-echo-segment'; Command = 'git add package.json; echo done'; Expected = 'deny'; Suffix = $modelCode + 'segment ''echo done'' is not a modelled git add or git commit' }
    @{ Id = 'AC13-unbalanced-quote'; Command = 'git add ''package.json'; Expected = 'deny'; Suffix = $modelCode + 'the command line is not balanced' }
    @{ Id = 'AC13-variable-in-message'; Command = 'git commit -m "release $VERSION"'; Expected = 'deny'; Suffix = $modelCode + 'the command text is not resolvable' }
    @{ Id = 'AC13-backslash-in-message'; Command = 'git commit -m ''a\b'''; Expected = 'deny'; Suffix = $modelCode + 'the command text is not resolvable' }
    @{ Id = 'AC13-two-commits'; Command = 'git commit -m ''a'' && git commit -m ''b'''; Expected = 'deny'; Suffix = $modelCode + 'the command line has more than one git commit segment' }
    @{ Id = 'AC13-empty-segment'; Command = 'git add package.json && ""'; Expected = 'deny'; Suffix = $modelCode + 'segment ''""'' is not a modelled git add or git commit' }
    @{ Id = 'AC13-git-status-segment'; Command = 'git add package.json && git status'; Expected = 'deny'; Suffix = $modelCode + 'segment ''git status'' is not a modelled git add or git commit' }
    # AC-14: branch.
    @{ Id = 'AC14-detached-head'; Command = 'git commit -m ''x'''; Expected = 'deny'; Branch = $null; Suffix = $branchCode + 'HEAD is detached or unreadable'; Invoke = @{ 'Get-OrchestrationGateStagedIndex' = 0 } }
    @{ Id = 'AC14-unmatched-branch'; Command = 'git commit -m ''x'''; Expected = 'deny'; Branch = 'feature/x'; Suffix = $branchCode + 'branch ''feature/x'' matches no allowance'; Invoke = @{ 'Get-OrchestrationGateStagedIndex' = 0 } }
    # AC-15: options.
    @{ Id = 'AC15-global-c'; Command = 'git -c user.name=x commit -m ''a'''; Expected = 'deny'; Suffix = $optionCode + 'git global option ''-c'' is not allowed' }
    @{ Id = 'AC15-git-dir-attached'; Command = 'git --git-dir=.git add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--git-dir=.git'' is not allowed' }
    @{ Id = 'AC15-work-tree-attached'; Command = 'git --work-tree=. add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--work-tree=.'' is not allowed' }
    @{ Id = 'AC15-relative-C'; Command = 'git -C sub add package.json'; Expected = 'deny'; Suffix = $optionCode + '-C ''sub'' is not the target worktree root' }
    @{ Id = 'AC15-other-root-C'; Command = 'git -C /synthetic-worktrees/other add package.json'; Expected = 'deny'; Suffix = $optionCode + '-C ''/synthetic-worktrees/other'' is not the target worktree root' }
    @{ Id = 'AC15-add-A'; Command = 'git add -A'; Expected = 'deny'; Suffix = $optionCode + 'option ''-A'' is not allowed for git add' }
    @{ Id = 'AC15-add-all'; Command = 'git add --all'; Expected = 'deny'; Suffix = $optionCode + 'option ''--all'' is not allowed for git add' }
    @{ Id = 'AC15-add-u'; Command = 'git add -u'; Expected = 'deny'; Suffix = $optionCode + 'option ''-u'' is not allowed for git add' }
    @{ Id = 'AC15-add-update'; Command = 'git add --update'; Expected = 'deny'; Suffix = $optionCode + 'option ''--update'' is not allowed for git add' }
    @{ Id = 'AC15-add-f'; Command = 'git add -f package.json'; Expected = 'deny'; Suffix = $optionCode + 'option ''-f'' is not allowed for git add' }
    @{ Id = 'AC15-add-force'; Command = 'git add --force package.json'; Expected = 'deny'; Suffix = $optionCode + 'option ''--force'' is not allowed for git add' }
    @{ Id = 'AC15-add-p'; Command = 'git add -p'; Expected = 'deny'; Suffix = $optionCode + 'option ''-p'' is not allowed for git add' }
    @{ Id = 'AC15-add-i'; Command = 'git add -i'; Expected = 'deny'; Suffix = $optionCode + 'option ''-i'' is not allowed for git add' }
    @{ Id = 'AC15-add-pathspec-from-file'; Command = 'git add --pathspec-from-file=list'; Expected = 'deny'; Suffix = $optionCode + 'option ''--pathspec-from-file=list'' is not allowed for git add' }
    @{ Id = 'AC15-commit-a'; Command = 'git commit -a -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''-a'' is not allowed for git commit'; Invoke = @{ 'Get-OrchestrationGateStagedIndex' = 0 } }
    @{ Id = 'AC15-commit-all'; Command = 'git commit --all -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''--all'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-amend'; Command = 'git commit --amend'; Expected = 'deny'; Suffix = $optionCode + 'option ''--amend'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-n'; Command = 'git commit -n -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''-n'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-no-verify'; Command = 'git commit --no-verify -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''--no-verify'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-reedit-option'; Command = 'git commit -c HEAD'; Expected = 'deny'; Suffix = $optionCode + 'option ''-c'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-reuse-option'; Command = 'git commit -C HEAD'; Expected = 'deny'; Suffix = $optionCode + 'option ''-C'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-reuse-message'; Command = 'git commit --reuse-message=HEAD'; Expected = 'deny'; Suffix = $optionCode + 'option ''--reuse-message=HEAD'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-fixup'; Command = 'git commit --fixup=HEAD'; Expected = 'deny'; Suffix = $optionCode + 'option ''--fixup=HEAD'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-squash'; Command = 'git commit --squash=HEAD'; Expected = 'deny'; Suffix = $optionCode + 'option ''--squash=HEAD'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-allow-empty'; Command = 'git commit --allow-empty -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''--allow-empty'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-only'; Command = 'git commit --only -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''--only'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-include'; Command = 'git commit --include -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''--include'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-trailer'; Command = 'git commit --trailer ''a: b'' -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'option ''--trailer'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-attached-m'; Command = 'git commit -mvalue'; Expected = 'deny'; Suffix = $optionCode + 'option ''-mvalue'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-m-missing-value'; Command = 'git commit -m'; Expected = 'deny'; Suffix = $optionCode + 'option ''-m'' is not allowed for git commit' }
    @{ Id = 'AC15-git-dir-separate'; Command = 'git --git-dir .git add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--git-dir'' is not allowed' }
    @{ Id = 'AC15-work-tree-separate'; Command = 'git --work-tree . add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--work-tree'' is not allowed' }
    @{ Id = 'AC15-namespace-separate'; Command = 'git --namespace n add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--namespace'' is not allowed' }
    @{ Id = 'AC15-config-env-separate'; Command = 'git --config-env a=B commit -m ''x'''; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--config-env'' is not allowed' }
    @{ Id = 'AC15-namespace-attached'; Command = 'git --namespace=n add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--namespace=n'' is not allowed' }
    @{ Id = 'AC15-C-attached'; Command = 'git -C/synthetic-worktrees/release add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''-C/synthetic-worktrees/release'' is not allowed' }
    @{ Id = 'AC15-bare'; Command = 'git --bare add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--bare'' is not allowed' }
    @{ Id = 'AC15-p-global'; Command = 'git -p add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''-p'' is not allowed' }
    @{ Id = 'AC15-no-pager'; Command = 'git --no-pager add package.json'; Expected = 'deny'; Suffix = $optionCode + 'git global option ''--no-pager'' is not allowed' }
    @{ Id = 'AC15-commit-message-missing-value'; Command = 'git commit --message'; Expected = 'deny'; Suffix = $optionCode + 'option ''--message'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-F-missing-value'; Command = 'git commit -F'; Expected = 'deny'; Suffix = $optionCode + 'option ''-F'' is not allowed for git commit' }
    @{ Id = 'AC15-commit-file-missing-value'; Command = 'git commit --file'; Expected = 'deny'; Suffix = $optionCode + 'option ''--file'' is not allowed for git commit' }
    # AC-16: paths.
    @{ Id = 'AC16-add-no-operand'; Command = 'git add'; Expected = 'deny'; Suffix = $pathCode + 'git add has no path operand' }
    @{ Id = 'AC16-add-dot'; Command = 'git add .'; Expected = 'deny'; Suffix = $pathCode + 'operand ''.'' is not an allowed path' }
    @{ Id = 'AC16-add-glob'; Command = 'git add *.json'; Expected = 'deny'; Suffix = $pathCode + 'operand ''*.json'' is not an allowed path' }
    @{ Id = 'AC16-add-directory'; Command = 'git add src'; Expected = 'deny'; Suffix = $pathCode + 'operand ''src'' is not an allowed path' }
    @{ Id = 'AC16-add-unlisted'; Command = 'git add other.txt'; Expected = 'deny'; Suffix = $pathCode + 'operand ''other.txt'' is not an allowed path' }
    @{ Id = 'AC16-add-second-separator'; Command = 'git add -- package.json -- CHANGELOG.md'; Expected = 'deny'; Suffix = $pathCode + 'operand ''--'' is not an allowed path' }
    @{ Id = 'AC16-commit-separator-path'; Command = 'git commit -m ''x'' -- package.json'; Expected = 'deny'; Suffix = $pathCode + 'git commit pathspec ''--'' is not allowed' }
    @{ Id = 'AC16-commit-path'; Command = 'git commit -m ''x'' package.json'; Expected = 'deny'; Suffix = $pathCode + 'git commit pathspec ''package.json'' is not allowed' }
    @{ Id = 'AC16-add-separator-only'; Command = 'git add --'; Expected = 'deny'; Suffix = $pathCode + 'git add has no path operand' }
    @{ Id = 'AC16-add-separator-then-dash'; Command = 'git add -- -A'; Expected = 'deny'; Suffix = $pathCode + 'operand ''-A'' is not an allowed path' }
    @{ Id = 'AC16-add-case-differs'; Command = 'git add Package.json'; Expected = 'deny'; Suffix = $pathCode + 'operand ''Package.json'' is not an allowed path' }
    @{ Id = 'AC16-commit-trailing-separator'; Command = 'git commit -m ''x'' --'; Expected = 'deny'; Suffix = $pathCode + 'git commit pathspec ''--'' is not allowed' }
    # AC-17: staged index.
    @{ Id = 'AC17-staged-unlisted'; Command = 'git commit -m ''x'''; Expected = 'deny'; StagedOutput = "package.json`0src/index.ts`0"; Suffix = $releaseSuffix + 'RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED: staged path ''src/index.ts'' is not an allowed path' }
    @{ Id = 'AC17-staged-empty'; Command = 'git commit -m ''x'''; Expected = 'deny'; StagedOutput = ''; Suffix = $releaseSuffix + 'RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY: nothing is staged for the commit' }
    @{ Id = 'AC17-staged-null'; Command = 'git commit -m ''x'''; Expected = 'deny'; StagedNull = $true; Suffix = $releaseSuffix + 'RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE: the staged index could not be read' }
    @{ Id = 'AC17-staged-exit-failure'; Command = 'git commit -m ''x'''; Expected = 'deny'; StagedExitCode = -1; Suffix = $releaseSuffix + 'RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE: the staged index could not be read' }
    @{ Id = 'AC17-staged-no-terminator'; Command = 'git commit -m ''x'''; Expected = 'deny'; StagedOutput = 'package.json'; Suffix = $releaseSuffix + 'RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE: the staged index could not be read' }
    # AC-18: the #1188 resolver deny for an unexpandable -C stands, with no release suffix.
    @{ Id = 'AC18-unexpandable-C'; Command = $script:ReleaseAllowanceUnexpandableCommand; Expected = 'deny'; ReasonLike = 'TARGET_WORKTREE_NOT_DERIVABLE'; Invoke = @{ 'Get-OrchestrationGateReleaseAllowanceConfigText' = 0 } }
    # AC-19: the first failure in evaluation order is the one reported.
    @{ Id = 'AC19-non-git-before-option'; Command = 'git add -A && pytest'; Expected = 'deny'; OneSuffix = $true; Suffix = $modelCode + 'segment ''pytest'' is not a modelled git add or git commit' }
    @{ Id = 'AC19-branch-before-option'; Command = 'git add -A'; Expected = 'deny'; OneSuffix = $true; Branch = 'feature/x'; Suffix = $branchCode + 'branch ''feature/x'' matches no allowance' }
    @{ Id = 'AC19-option-before-operand'; Command = 'git add -f other.txt'; Expected = 'deny'; OneSuffix = $true; Suffix = $optionCode + 'option ''-f'' is not allowed for git add' }
)
