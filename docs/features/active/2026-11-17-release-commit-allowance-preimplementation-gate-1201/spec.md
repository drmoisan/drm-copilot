# 2026-11-17-release-commit-allowance-preimplementation-gate (Spec)

- **Issue:** #1201
- **Parent (optional):** none (epic #1018 may require later adaptation; see `## Risks & Mitigations`)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-17T19-40
- **Status:** Approved for planning
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Research:** `research/research.2026-11-17T19-10.md` in this folder (citation map, `## Behavior Semantics`). The spec names mirror locations by explicit path list and asserts no family counts.
- **Orchestrator decisions encoded:** AD-1 through AD-6 (recorded in the item checkpoint)

## Context

The preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, its sibling files, and the `.codex/hooks` twin) denies every agent `git add` / `git commit` unless `artifacts/orchestration/orchestrator-state.json` holds a ready checkpoint. A routine release version bump has no orchestration checkpoint, so an agent running a release skill cannot commit the bumped version files. A destination repository cannot add its own exemption: the hooks are push-down managed (a local edit is overwritten on refresh), and a separate local hook cannot override another hook's deny. The exemption must ship from this repository, with each destination declaring its own allowance in a file that push-down never writes. Priority: high (Blocker).

Environment:
- OS/version: Windows 11 and Linux, Claude Code and Codex runtimes
- Python version: not applicable
- Command/flags used: an agent release skill running `git add package.json CHANGELOG.md` then `git commit -m "..."` on a `release/v*` branch with no orchestration checkpoint
- Data source or fixture: any destination repository receiving the push-down hooks

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. In a destination repository with the pushed-down hooks, check out a release branch with no orchestration checkpoint.
2. Bump the version files and have an agent run `git add` on them.
3. Observe PREIMPLEMENTATION_GATE_BLOCKED.

Actual: every agent `git add` / `git commit` without a ready checkpoint is denied, including a release version bump.

Log snippet: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`

Expected (authoritative source: `issue.md`, `## Expected Behavior` items 1-5 and the acceptance sentence in `## Suspected Cause / Notes`): a repository that commits a valid `.claude/release-commit-allowance.json` lets an agent on a matching branch run `git add <allowed paths>` and `git commit -m "<message>"` with only those paths staged and no checkpoint; every forbidden variation is denied with one specific code; without the file the gate's decisions and deny text are unchanged; a push-down refresh never creates, overwrites, or deletes the file.

## Scope & Non-Goals

- In scope:
  - A repository-owned allowance file `.claude/release-commit-allowance.json` (schema version 1), its parser, and its read seam.
  - A new allow-side command leg in the Claude and Codex preimplementation gates, placed after the readiness check fails and after every existing leg.
  - The new hook files `hook-release-allowance-context.ps1` and `enforce-orchestration-preimplementation-gate-release.ps1`, byte-identical in each of these sibling roots: `.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`.
  - Registration of the new files in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
  - Exclusion of the allowance file from Claude push-down publication in both publishers.
  - Pester, Jest, and parity tests; documentation and changelog.
- Out of scope / non-goals:
  - The pr-author hooks (PR creation stays exclusive to pr-author).
  - `git push` handling and every other gate or hook.
  - Any default allowance in the payload; this repository commits no allowance file.
  - A Write/Edit path allowance for the allowance file itself (writing it stays gated by `Test-ImplementationPath`).
  - The Write/Edit path leg and the delegation leg of the gate.
  - Hook registration changes in `.claude/hooks/pretooluse-dispatch.json` or `.codex/hooks/pretooluse-dispatch.json`.
- Explicitly excluded systems: `.github/instructions/*` (canonical policy, not edited); the Claude PowerShell tool and the Codex `shell_command` tool (they never reach this gate; no registration change).

## Root Cause Analysis

The gate has allow legs for cleanup contexts (#1026), orchestration bookkeeping staging (#539/#1160), the docs estate (#1169), and parallel records (#1182, Claude only), but none for a repository-declared release commit. Because the hooks are push-down managed and hook denies cannot be overridden by another hook, a destination has no supported way to permit a checkpoint-free release commit. The fix must ship in the managed hook payload and be activated by a destination-owned file that push-down never writes.

## Proposed Fix

### Design summary (what changes where)

- New pure file `hook-release-allowance-context.ps1` (no I/O): config parser, branch matcher, segment classifier, and command decision.
- New sibling `enforce-orchestration-preimplementation-gate-release.ps1`: guarded dot-source of the context file, the I/O seams, and the leg entry `Get-OrchestrationReleaseAllowanceResult`.
- Both gates gain exactly one guarded dot-source line, one leg line immediately before the final deny, and `+ $release.DenySuffix` as the last term of the final deny expression.
- `.claude/release-commit-allowance.json` is added to `EXCLUDED_RELATIVE_PATHS` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` and in `scripts/dev_tools/push_down_claude_customizations.py`.

Spec decision (extends AD-4): the Python publisher `scripts/dev_tools/push_down_claude_customizations.py` also publishes the `.claude` root with its own `EXCLUDED_RELATIVE_PATHS` tuple, and the repository precedent (`config/blast-radius.local.json`) lists destination-owned files in both publishers. The entry is therefore added to both. This edits one existing tuple; it adds no new Python module and no new Python test. Its presence is verified by the Pester parity test as a text read.

### Boundaries and invariants to preserve

- Without the allowance file at R, every gate decision, deny text, and seam call count is unchanged; every existing gate suite passes unmodified.
- The leg is allow-side only. It never denies on its own, never suppresses another hook's deny, never changes trigger classification (`Test-ImplementationCommand`, `Test-ExemptOrchestrationStagingCommand`), and never runs before `Test-OrchestrationReady` fails or before the existing legs.
- The leg never throws. An unexpected error yields `Allowed = $false`, an empty suffix, and a `Write-Debug` line carrying the token `PREIMPL_RELEASE_LEG_ERROR`.
- Hooks never invoke Python.
- Script-scope variables in both new files use the unique prefix `$script:ReleaseAllowance` (the dispatcher's in-process isolation dot-sources many hooks into one process).

### Dependencies or blocked work

- Reuses, without modification: `Get-OrchestrationGateBookkeepingWorktreeRoot` (bookkeeping sibling), `Get-OrchestrationGateStagedIndex` and `ConvertTo-OrchestrationCleanupComparablePath` (cleanup sibling), `ConvertFrom-DocsOnlyNameList` (`hook-docs-only-diff.ps1`), `Get-EpicScopeWorktreeHeadBranch` (Claude `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`; Codex `enforce-orchestration-preimplementation-gate-epic-resolution.ps1`), and `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-OrchestrationCommandTextUnresolvable`, `Test-CommandLineTokenLiteral` (helpers sibling).
- The #1188 target resolver (`Get-OrchestrationGateCommandTargetOperand`, `Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint`) is unchanged; its `TARGET_WORKTREE_NOT_DERIVABLE` deny for an unexpandable `-C` stands.
- Destinations receive the leg only after an extension rebuild, release, and push-down refresh. Isolated subagents run the default branch's hooks, so before merge the leg is proven by Pester only.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

New (byte-identical in each sibling root listed under Scope):
- `hook-release-allowance-context.ps1`
- `enforce-orchestration-preimplementation-gate-release.ps1`

Edited:
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (adds `.claude/hooks/hook-release-allowance-context.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1`).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (adds `.codex/hooks/hook-release-allowance-context.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1`).
- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (`EXCLUDED_RELATIVE_PATHS`).
- `scripts/dev_tools/push_down_claude_customizations.py` (`EXCLUDED_RELATIVE_PATHS`).
- Documentation listed under `#### Documentation`.

New tests:
- `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1` (pure unit table, both surface copies).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1` (seams and leg entry, both surface copies).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Cases.ps1` (shared decision-table rows).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1` (Claude gate decisions).
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1` (Codex gate decisions; loads the shared cases file by a path relative to its own `$PSScriptRoot`).
- `tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1` (parity and absence contracts).
- `extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts` (Jest refresh contract).

#### Functions/classes/CLI commands impacted

`hook-release-allowance-context.ps1` (pure):
- `ConvertFrom-ReleaseAllowanceConfig -Text` returns `[pscustomobject]@{ Valid; Allowances; Detail }`.
- `Test-ReleaseAllowanceBranchMatch -Branch -Pattern` returns `[bool]`.
- `Test-ReleaseAllowanceCommandRelevant -Command` returns `[bool]` (AD-3 relevance test).
- `Get-ReleaseAllowanceSegmentShape -Token [-WorktreeRoot]` returns `[pscustomobject]@{ Kind; Paths; Code; Detail }` where `Kind` is `add`, `commit`, or `other`.
- `Get-ReleaseAllowanceCommandDecision -Command -WorktreeRoot -Branch -Allowances -StagedReader` returns `[pscustomobject]@{ Allowed; Code; Detail }`. `-StagedReader` is a scriptblock invoked at most once and only when a commit segment exists.

`enforce-orchestration-preimplementation-gate-release.ps1`:
- `Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot` (config seam).
- `Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot -RelativePath` (directory probe seam).
- `Get-OrchestrationReleaseAllowanceResult -Command -CheckpointPath [-ConfigReader] [-ContainerProbe] [-BranchReader] [-StagedIndexReader]` returns `[pscustomobject]@{ Allowed; DenySuffix }`. Each reader parameter defaults to a scriptblock that calls the named seam function (`Get-OrchestrationGateReleaseAllowanceConfigText`, `Test-OrchestrationGateReleaseAllowancePathIsContainer`, `Get-EpicScopeWorktreeHeadBranch`, `Get-OrchestrationGateStagedIndex`) by name, so Pester `Mock` of those functions takes effect.

Gate edits (both runtimes):
- Header: `try { . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-release.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-release.ps1' -ErrorRecord $_ }`, placed after the parallel-records dot-source line (Claude) or after the docs dot-source line (Codex). The release sibling dot-sources `hook-release-allowance-context.ps1` in the same guarded single-statement form.
- In `Invoke-OrchestrationPreimplementationGateDecision`, immediately before the final deny: `if (($release = Get-OrchestrationReleaseAllowanceResult -Command $command -CheckpointPath $checkpointPath).Allowed) { return Get-OrchestrationPreimplementationGateAllowDecision } # Release-commit allowance leg (issue #1201).`
- Final deny expression gains `+ $release.DenySuffix` as its last term.

#### Data flow and validation changes

Evaluation order inside `Get-OrchestrationReleaseAllowanceResult`. The first failure decides; exactly one code is reported.

1. `-Command` blank, or its trimmed text begins with `*** Begin Patch`: decline (`Allowed $false`, empty suffix), no I/O.
2. `Test-ReleaseAllowanceCommandRelevant` is false: decline, empty suffix, no I/O. A line is relevant when at least one segment produced by `Split-OrchestrationCommandLine` (whether or not `Balanced`) and tokenized by `ConvertTo-OrchestrationCommandToken` has first token `git` and, after skipping global options (tokens beginning with `-`, plus the separate value token after `-C`, `-c`, `--git-dir`, `--work-tree`, `--namespace`, `--config-env`), a first non-option token of `add` or `commit` (AD-3).
3. R = `Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $CheckpointPath -CheckpointSuffix ([string]@($script:CheckpointPaths)[0])`. `$null` (including the empty `$checkpointPath` of `-CheckpointRaw` test injection): decline, empty suffix, no further I/O.
4. Config read through the config seam beneath R. `$null` (absent): decline, empty suffix, no further I/O (no branch read, no staged-index read, no container probe). Seam throws: `RELEASE_ALLOWANCE_CONFIG_INVALID: the file could not be read`.
5. Parse with `ConvertFrom-ReleaseAllowanceConfig`; then probe each `allowed_paths` entry with the container seam. Any failure: `RELEASE_ALLOWANCE_CONFIG_INVALID: <detail>` (rules under `#### Required configuration keys and defaults`).
6. Whole-line shape (AD-2): `Test-OrchestrationCommandTextUnresolvable` true, `Split-OrchestrationCommandLine` returns `Balanced $false`, an empty segment, any segment of kind `other`, or more than one `git commit` segment: `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED`.
7. Branch: `Get-EpicScopeWorktreeHeadBranch -WorktreeRoot R`. `$null` (detached or unreadable HEAD) or no allowance with a matching pattern: `RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED`. Candidate allowances are those with at least one matching pattern, in file order.
8. Per segment, in line order, allowance-independent checks:
   - Global options: any token between `git` and the subcommand other than `-C <value>` yields `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` (covers `-c`, `--git-dir`, `--work-tree`, `--namespace`, `--config-env`, `--bare`, `-p`, `--no-pager`, `--exec-path`, and every other global option, in separate or attached form). Each `-C` value must be absolute and equal R after `ConvertTo-OrchestrationCleanupComparablePath` normalization (ordinal, case-insensitive); a relative value or a different root yields `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` (AD-5).
   - `git add`: before the first `--`, any token beginning with `-` yields `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` (covers `-A`, `--all`, `-u`, `--update`, `-f`, `--force`, `-p`, `--patch`, `-i`, `--interactive`, `--pathspec-from-file`, `-N`, `--intent-to-add`, `-e`, `--edit`, `--chmod`, and all others). `--` is accepted at most once and only before the operands; every later token, including a second `--` or a token beginning with `-`, is a literal operand. Zero operands yields `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED`.
   - `git commit`: accepted options are `-m <v>`, `--message <v>`, `--message=<v>`, `-F <v>`, `--file <v>`, `--file=<v>`, `-s`, `--signoff`, each repeatable. A missing value after `-m`, `--message`, `-F`, or `--file` yields `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED`. Any other token beginning with `-` other than `--` yields `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` (covers attached `-mvalue`, attached `-Fvalue`, `--trailer`, `-a`, `--all`, `--amend`, `-n`, `--no-verify`, `-c`, `-C`, `--reuse-message`, `--reedit-message`, `--fixup`, `--squash`, `--allow-empty`, `--allow-empty-message`, `-o`, `--only`, `-i`, `--include`, `--author`, `--date`, `-e`, `--edit`, `--pathspec-from-file`, `-p`, `--patch`, `-S`, `--gpg-sign`, `--no-gpg-sign`, `--cleanup`, `-v`, `--dry-run`). `--` or any operand yields `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED`.
9. Staged index (only when the line has a commit segment; read once): `Get-OrchestrationGateStagedIndex -WorktreeRoot R`. A `$null` result, a non-zero `ExitCode`, or non-empty `Output` that does not end with a NUL: `RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE`. The evaluated set (AD-1) is the ordered union of the staged names (`ConvertFrom-DocsOnlyNameList`) and the operands of every `git add` segment that precedes the commit segment in the line. An empty evaluated set: `RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY`.
10. Per candidate allowance, in file order: every `git add` operand in the line must ordinal-equal an entry of that allowance's `allowed_paths`, else `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED` (this covers `.`, globs, directories, absolute paths, and unlisted files); then, when a commit segment exists, every member of the evaluated set must ordinal-equal an entry of that allowance's `allowed_paths`, else `RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED`. The first candidate that passes both checks allows the line (`Allowed $true`, empty suffix). When no candidate passes, the code and detail of the first candidate's failure are reported. All segments are thereby qualified under one single allowance.

Detail templates (the `<detail>` part of the suffix):
- `RELEASE_ALLOWANCE_CONFIG_INVALID`: `the file could not be read`, or the first failing parser rule naming the offending key or entry (for example `allowed_paths entry 'docs/' has a trailing slash`, `allowed_paths entry 'docs' is a directory`).
- `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED`: `the command text is not resolvable`, `the command line is not balanced`, `segment '<trimmed segment>' is not a modelled git add or git commit`, or `the command line has more than one git commit segment`.
- `RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED`: `HEAD is detached or unreadable`, or `branch '<branch>' matches no allowance`.
- `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED`: `option '<token>' is not allowed for git <subcommand>`, `git global option '<token>' is not allowed`, or `-C '<value>' is not the target worktree root`.
- `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED`: `git add has no path operand`, `operand '<path>' is not an allowed path`, or `git commit pathspec '<token>' is not allowed`.
- `RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED`: `staged path '<path>' is not an allowed path` (first offending member in evaluated-set order).
- `RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY`: `nothing is staged for the commit`.
- `RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE`: `the staged index could not be read`.

Suffix form (appended last to the existing final deny text, with the leading space): ` Release allowance not applied: <CODE>: <detail>`. No suffix is produced in steps 1-4 (decline paths), so a repository without the file, or a line with no `git add`/`git commit` segment, sees today's text.

Interaction with the #1188 resolver: an unexpandable `-C` (shell variable or substitution) is denied by `Read-OrchestrationGateCheckpoint` with `TARGET_WORKTREE_NOT_DERIVABLE` before the leg runs; that deny text is unchanged and carries no release suffix.

#### Error handling and logging updates

- The config seam returns `$null` only when no item exists at `<R>/.claude/release-commit-allowance.json` (`Test-Path -LiteralPath`); an item that exists but is not a file, or a `Get-Content -LiteralPath -Raw -ErrorAction Stop` failure, throws, and the leg reports `RELEASE_ALLOWANCE_CONFIG_INVALID: the file could not be read`.
- The container seam returns `Test-Path -LiteralPath (Join-Path R <entry>) -PathType Container`; a throw from it is reported as `RELEASE_ALLOWANCE_CONFIG_INVALID: allowed_paths entry '<entry>' could not be checked`.
- The leg's outer `try/catch` returns `Allowed $false`, empty suffix, and `Write-Debug` with `PREIMPL_RELEASE_LEG_ERROR`.

#### Rollback/feature-flag considerations

The leg is inert without the allowance file; a destination opts out by deleting the file. Code rollback is a revert of the new files, the gate lines, the manifest entries, and the exclusion entries.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: the gate's `command` string (Bash on Claude; Bash on Codex, where `apply_patch` text is declined), the resolved checkpoint path, the allowance file text, the HEAD branch, and the NUL-delimited staged list.
- Output: the leg result object `{ Allowed; DenySuffix }`, consumed only by the gate's final deny expression.

#### Required configuration keys and defaults

File: `.claude/release-commit-allowance.json` beneath R. No default exists; absence disables the leg.

```json
{ "schema_version": 1, "allowances": [ { "id": "release-version-bump", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "CHANGELOG.md"] } ] }
```

Validation rules (first failing rule wins; parse with `ConvertFrom-Json -NoEnumerate`; key comparisons ordinal and case-sensitive):
- The text parses as JSON and the root is an object.
- Root keys are exactly `schema_version` and `allowances` (no missing, no unknown key).
- `schema_version` is an integer (`[int]` or `[long]`) equal to 1; the string `"1"`, `1.0`, and `2` are invalid.
- `allowances` is a non-empty array whose every element is an object with exactly the keys `id`, `branch_patterns`, `allowed_paths`.
- `id` is a non-empty, non-whitespace string, unique across allowances (ordinal).
- `branch_patterns` is a non-empty array of non-empty strings, each matching `^[A-Za-z0-9._/*?-]+$` (no `[` class syntax, no backtick, no whitespace).
- `allowed_paths` is a non-empty array of strings, each matching `^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*$`, with no `.` or `..` segment, no glob character, no leading or trailing `/`, no drive letter, no duplicate within the allowance (ordinal), and not a directory beneath R (container seam).

Branch matching: `[System.Management.Automation.WildcardPattern]::new(<pattern>, [System.Management.Automation.WildcardOptions]::None).IsMatch(<branch>)` against the full branch name (case-sensitive, whole-name match).

#### Backward-compatibility expectations

- No change to deny text, decisions, or seam call counts when the file is absent at R.
- Existing suffix order (cleanup, bookkeeping, docs, parallel on Claude; cleanup, bookkeeping, docs on Codex) is preserved; the release suffix is last.
- Commit messages containing `$`, a backtick, or a backslash are unresolvable (`Test-OrchestrationCommandTextUnresolvable`) and are denied with `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED`; use single quotes or `-F <file>`.

#### Performance constraints

- No git process and no worktree listing when the file is absent.
- When the file is present: at most one HEAD file read (no process), at most one staged-index call (bounded by the existing wrapper timeout), and one container probe per `allowed_paths` entry.

### Documentation

- `## Hook Execution Context`: one bullet "Release-commit allowance leg (#1201)" after the parallel-records bullet, stating the file path, schema, branch matching, accepted `git add`/`git commit` shapes, the evaluated-set rule, the codes, the suffix form, the quoting guidance, and that push-down never writes the file. `## Contract Tests That Pin Mirrored Files`: entries naming `hook-release-allowance-context.Parity.Tests.ps1` and `claude-customizations-release-allowance.test.ts`. Both edits in each byte-identical execution-environment copy: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
- `## Pre-Implementation Gate` in `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`: one paragraph "Release-commit allowance (issue #1201)" in the style of the existing #1160 paragraph.
- New section `## Release-Commit Allowance Scope` in `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`: the file is destination-owned, never bundled, never published by push-down, never shipped with a default; the leg is command-only and allow-side only; the codes.
- `extensions/drm-copilot/CHANGELOG.md`, `## [Unreleased]` / `### Added`: an entry stating destinations receive the leg through the next push-down refresh after the extension release and opt in by committing `.claude/release-commit-allowance.json`.

## Assumptions, Constraints, Dependencies

- Assumptions: the Codex gate's `$checkpointPath` variable and final deny expression have the same shape as the Claude gate's (verified by reading `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`); `scripts/dev_tools/generate_codex_agent_variants.py` `--check` preserves hand-added hook paths in the Codex core manifest (the plan runs the check to confirm).
- Constraints: the Codex gate stays at or under 500 lines in the repository and the bundle; both new files stay under 500 lines; `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` stays under 800 lines; no new Python module; tests run in parallel form only; evidence is append-only under `evidence/<kind>/`; no absolute paths in artifacts or fixtures.
- External dependencies: none new.

## Data / API / Config Impact

- User-facing: a new destination-owned config file and new deny-suffix codes; existing text unchanged when the file is absent.
- Data or migration: none.
- Logging: one new `Write-Debug` token `PREIMPL_RELEASE_LEG_ERROR`.
- Compatibility: config `schema_version` 1; any other version is invalid.

## Test Strategy

- Unit (pure): `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1`, `Describe ... -ForEach @(@{ Surface = 'Claude' }, @{ Surface = 'Codex' })`, table rows for every parser rule, branch matching, relevance, and segment shapes.
- Seam and entry: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1`, both surfaces; mocks `Test-Path` and `Get-Content` for the config seam and container seam defaults; exercises every decline path and the catch path.
- Decision tables: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1` through `Invoke-OrchestrationPreimplementationGateDecision`, rows from the shared cases file loaded in `BeforeDiscovery`, mocking `Read-OrchestrationGateCheckpoint` (synthetic forward-slash root `/synthetic-worktrees/release` plus the checkpoint suffix), `Get-OrchestrationGateReleaseAllowanceConfigText`, `Test-OrchestrationGateReleaseAllowancePathIsContainer`, `Get-EpicScopeWorktreeHeadBranch`, `Get-OrchestrationGateStagedIndex` (`[pscustomobject]@{ ExitCode; Output }`). Deny text asserted with `Should -BeExactly`. Follows the `EpicStateIsolation.Baseline.Helpers.ps1` / `Register-EpicStateBaselineMock` harness pattern.
- Parity and absence: `tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1`.
- Jest: `extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts` with `buildInMemoryFileSystem` and `fixedClock`.
- Constraints for all new tests: no live git, no temporary files, no environment or global state, no reads of gitignored `artifacts/` state, forward-slash synthetic roots, exact-case file names.
- Regression: every existing gate suite under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, the pack-manifest completeness tests, the push-down resource-contract tests, `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py`, and the existing `claude-customizations.test.ts`, all unmodified.
- Coverage: both new PowerShell files reach >= 85% line coverage from the parallel Pester run; TypeScript coverage thresholds in `extensions/drm-copilot/jest.config.cjs` stay met (no new production TS file).
- Toolchain: format, lint, type-check, architecture, unit, contract stages through the repository test-execution launcher in parallel form; integration in CI.

## Acceptance Criteria

Configuration and parser:

- [x] AC-1: `ConvertFrom-ReleaseAllowanceConfig` returns `Valid $true` with one allowance for the example document in `#### Required configuration keys and defaults`, and `Valid $false` with a detail naming the offending key or entry for each of these rows: invalid JSON, non-object root, missing `schema_version`, missing `allowances`, unknown root key, `schema_version` 2, `schema_version` `"1"`, empty `allowances`, non-object allowance, unknown allowance key, missing `id`, empty `id`, non-string `id`, duplicate `id`, empty `branch_patterns`, empty-string pattern, pattern containing `[`, empty `allowed_paths`, path with `*`, path with `?`, path with trailing `/`, path with leading `/`, path with a `..` segment, path with a `.` segment, path `.`, drive-letter path, path with a backslash, duplicate path. Verified by `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1` for both surface copies.
- [x] AC-2: `Test-ReleaseAllowanceBranchMatch` matches `release/v*` against `release/v1.2.3`, rejects `Release/v1.2.3` (case-sensitive), rejects `hotfix/release/v1` (whole-name match, no substring match), and matches `release/v1` against `release/v?` while rejecting `release/v10` against the same pattern. Verified by `hook-release-allowance-context.Tests.ps1`.
- [x] AC-3: The config seam `Get-OrchestrationGateReleaseAllowanceConfigText` returns `$null` when no item exists at `<R>/.claude/release-commit-allowance.json`, returns the raw text when it is a file, and throws when the item is not a file or the read fails; the container seam returns the `Test-Path -PathType Container` result. Verified by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-release.Tests.ps1` with mocked `Test-Path` and `Get-Content`, both surfaces.

Absent file and decline paths:

- [x] AC-4: With the config seam returning `$null`, a checkpoint-free `git add package.json` and `git commit -m 'x'` produce exactly today's generic `PREIMPLEMENTATION_GATE_BLOCKED` text, and `Get-EpicScopeWorktreeHeadBranch`, `Get-OrchestrationGateStagedIndex`, and `Test-OrchestrationGateReleaseAllowancePathIsContainer` are invoked zero times (`Should -Invoke ... -Times 0 -Exactly`). Verified by the Claude and Codex decision suites.
- [x] AC-5: A blank command, Codex `apply_patch` text beginning `*** Begin Patch`, a Write/Edit path call, and an empty `$checkpointPath` (injected `-CheckpointRaw`) all decline with an empty suffix and zero calls to the config seam. Verified by `enforce-orchestration-preimplementation-gate-release.Tests.ps1` and the decision suites.
- [x] AC-6 (AD-3): With a valid allowance file present, a classified command line containing no `git add` or `git commit` segment (for example `pytest`) produces the generic deny text with no release suffix and zero config-seam calls. Verified by the decision suites.
- [x] AC-7: Every existing test file under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` passes without modification (no diff to any pre-existing test file in the branch). Verified by the parallel Pester run JUnit evidence and `git diff --name-status main` showing only added test files under those folders.

Allowed paths:

- [x] AC-8: On branch `release/v1.2.3` with a valid file allowing `package.json` and `CHANGELOG.md`, the gate allows `git add package.json CHANGELOG.md`, `git add -- package.json`, and `git -C <R> add package.json` where `<R>` equals the synthetic root. Verified by the decision suites (Claude and Codex).
- [x] AC-9: With the staged index mocked to `package.json` and `CHANGELOG.md` (NUL-terminated, exit 0), the gate allows `git commit -m 'release'`, `git commit --message 'release'`, `git commit --message=release`, `git commit -F msg.txt`, `git commit --file=msg.txt`, `git commit -s -m 'a' -m 'b'`, and `git commit --signoff -m 'release'`. Verified by the decision suites.
- [x] AC-10 (AD-1): With an empty staged index, the gate allows `git add package.json CHANGELOG.md && git commit -m 'release'`, because the evaluated set is the union of the staged names and the preceding `git add` operands. Verified by the decision suites.
- [x] AC-11: With two allowances where only the second matches the branch, or both match and only the second lists the paths, the line is allowed under the second; a line whose `git add` operand is listed only in the first allowance and whose staged path is listed only in the second is denied (single-allowance rule) with the first candidate's code, `RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED`. Verified by the decision suites.

Denials (each row asserts the exact full deny text, `Should -BeExactly`, generic text followed by the release suffix last):

- [x] AC-12: `RELEASE_ALLOWANCE_CONFIG_INVALID` for a config seam throw (`the file could not be read`), for an invalid document, and for an `allowed_paths` entry that the container seam reports as a directory; the release suffix follows every other suffix present. Verified by the decision suites.
- [x] AC-13 (AD-2): `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED` for `git add package.json && pytest`, `git add package.json; echo done`, an unbalanced quote, `git commit -m "release $VERSION"`, a message containing a backslash, and a line with two `git commit` segments. Verified by the decision suites.
- [x] AC-14: `RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED` when `Get-EpicScopeWorktreeHeadBranch` returns `$null` (detached HEAD) and when it returns `feature/x`; in both rows `Get-OrchestrationGateStagedIndex` is invoked zero times. Verified by the decision suites.
- [x] AC-15: `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED` for each of: `git -c user.name=x commit -m 'a'`, `git --git-dir=.git add package.json`, `git --work-tree=. add package.json`, `git -C sub add package.json` (relative, AD-5), `git -C <other absolute root> add package.json` (AD-5), `git add -A`, `git add --all`, `git add -u`, `git add --update`, `git add -f package.json`, `git add --force package.json`, `git add -p`, `git add -i`, `git add --pathspec-from-file=list`, `git commit -a -m 'x'`, `git commit --all -m 'x'`, `git commit --amend`, `git commit -n -m 'x'`, `git commit --no-verify -m 'x'`, `git commit -c HEAD`, `git commit -C HEAD`, `git commit --reuse-message=HEAD`, `git commit --fixup=HEAD`, `git commit --squash=HEAD`, `git commit --allow-empty -m 'x'`, `git commit --only -m 'x'`, `git commit --include -m 'x'`, `git commit --trailer 'a: b' -m 'x'`, `git commit -mvalue`, and `git commit -m` (missing value). Verified by the decision suites.
- [x] AC-16: `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED` for each of: `git add`, `git add .`, `git add *.json`, `git add src`, `git add other.txt`, `git add -- package.json -- CHANGELOG.md` (second `--` is an operand), `git commit -m 'x' -- package.json`, and `git commit -m 'x' package.json`. Verified by the decision suites.
- [x] AC-17: `RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED` for `git commit -m 'x'` with staged `package.json` and `src/index.ts`; `RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY` with an empty staged list (exit 0, empty output) and no preceding add; `RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE` for a `$null` result, `ExitCode -1`, and output not ending in NUL. Verified by the decision suites.
- [x] AC-18: `git -C "$WT" add package.json` with a valid allowance file produces the existing `TARGET_WORKTREE_NOT_DERIVABLE` deny text unchanged and with no release suffix. Verified by the decision suites.
- [x] AC-19: When several failures are present in one line, the reported code is the first in the order of `#### Data flow and validation changes` (rows: a non-git segment plus a forbidden option yields `COMMAND_NOT_MODELLED`; an unmatched branch plus a forbidden option yields `BRANCH_NOT_MATCHED`; a forbidden option plus an unlisted operand yields `OPTION_NOT_ALLOWED`), and exactly one `Release allowance not applied:` occurrence appears. Verified by the decision suites.
- [x] AC-20: `Get-OrchestrationReleaseAllowanceResult` returns `Allowed $false` with an empty suffix and emits `PREIMPL_RELEASE_LEG_ERROR` through `Write-Debug` when a seam throws an unexpected error outside the config read. Verified by `enforce-orchestration-preimplementation-gate-release.Tests.ps1`.

Wiring, parity, and manifests:

- [x] AC-21: Each gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and their bundle copies) contains exactly one guarded dot-source line for `enforce-orchestration-preimplementation-gate-release.ps1`, exactly one call to `Get-OrchestrationReleaseAllowanceResult` placed after the last existing leg, and `$release.DenySuffix` as the last term of the final deny; each bundle gate copy is byte-identical to its source. Verified by `hook-release-allowance-context.Parity.Tests.ps1` and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.
- [x] AC-22: `hook-release-allowance-context.ps1` and `enforce-orchestration-preimplementation-gate-release.ps1` each have identical SHA256 hashes across the sibling roots listed under `## Scope & Non-Goals` (`.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`), each is under 500 lines, and the Codex gate is at or under 500 lines in the repository and the bundle. Verified by `hook-release-allowance-context.Parity.Tests.ps1` and the existing Codex line-limit tests.
- [x] AC-23: Both core pack manifests list both new files under their surface prefix, and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_codex_and_agents_resource_contracts.py` pass unmodified; `scripts/dev_tools/generate_codex_agent_variants.py --check` reports no drift. Verified by the pytest run evidence.

Push-down:

- [x] AC-24 (AD-4): No `pack-manifests/*.json` under `extensions/drm-copilot/resources/` lists `.claude/release-commit-allowance.json`, and the file is absent from the repository root `.claude/` and from both bundle roots. Verified by `hook-release-allowance-context.Parity.Tests.ps1`.
- [x] AC-25 (AD-4): `EXCLUDED_RELATIVE_PATHS` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` and in `scripts/dev_tools/push_down_claude_customizations.py` both contain `.claude/release-commit-allowance.json`. Verified by `claude-customizations-release-allowance.test.ts` (TS constant) and `hook-release-allowance-context.Parity.Tests.ps1` (text read of the Python tuple).
- [x] AC-26 (AD-4): With a source tree that contains an allowance file and a destination that holds different allowance text, `pushDownCustomizations` with no pack selection and with `packs: new Set(["core"])` leaves the destination file byte-identical and omits the path from `summary.files`. Verified by `extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts`.

Documentation:

- [x] AC-27 (AD-6): Each execution-environment copy listed under `### Documentation` contains the "Release-commit allowance leg (#1201)" bullet in `## Hook Execution Context` naming `.claude/release-commit-allowance.json`, `RELEASE_ALLOWANCE_CONFIG_INVALID`, `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED`, and the single-quote or `-F` guidance, and names both new contract tests in `## Contract Tests That Pin Mirrored Files`; the listed copies are byte-identical. Verified by token assertions in `hook-release-allowance-context.Parity.Tests.ps1` and the existing push-down resource-contract tests.
- [x] AC-28 (AD-6): `## Pre-Implementation Gate` in `.agents/skills/orchestrate/SKILL.md` and its bundle copy contains the "Release-commit allowance (issue #1201)" paragraph; `.claude/rules/orchestrator-state.md` and its bundle copy contain `## Release-Commit Allowance Scope`; each source equals its bundle copy. Verified by `hook-release-allowance-context.Parity.Tests.ps1` and the push-down resource-contract tests.
- [x] AC-29 (AD-6): `extensions/drm-copilot/CHANGELOG.md` `## [Unreleased]` / `### Added` contains an entry naming `.claude/release-commit-allowance.json`, stating that destinations receive the leg through the next push-down refresh after the extension release and opt in by committing the file. Verified by review of the file diff recorded in the QA evidence.

Quality gates:

- [x] AC-30: Both new PowerShell files reach >= 85% line coverage in the parallel Pester run, and the Jest coverage thresholds in `extensions/drm-copilot/jest.config.cjs` pass. Verified by the JUnit and coverage files recorded under `evidence/qa-gates/`.
- [ ] AC-31: The full toolchain loop passes in a single pass in parallel form (format, lint including PSScriptAnalyzer and ESLint, type-check, architecture, unit, contract), and CI on the PR head is green. Verified by the QA gate evidence and `ci_gate.conclusion` `success` (CI-dependent; checked off at S9).
- [x] AC-32: No hook added or edited by this change invokes Python, and no new Python module or Python test file is added. Verified by `hook-release-allowance-context.Parity.Tests.ps1` (asserts neither new file contains `python` or `poetry`) and the branch file list in the QA evidence.

## Risks & Mitigations

- Existing suites change behavior: mitigated by the decline order (no I/O before the config seam reports a file) and AC-4, AC-5, AC-7.
- Suffix order assertions: the release suffix is appended last (AC-12, AC-21).
- Directory entries in `allowed_paths` that a lexical check cannot detect: closed by the container seam (AC-12).
- Relative `-C` retargeting git while the resolver targets the session root: closed by AD-5 (AC-15).
- Two-step add-then-commit chain denied because the hook runs before `git add`: closed by AD-1 (AC-10).
- This repository committing its own allowance file would change resource-contract expectations: AC-24 asserts absence.
- Epic #1018 is changing the hook architecture (dispatcher, generators, push-down consolidation). The leg is localized to the new hook files, a dot-source line, a leg line, and a suffix term in each gate, the manifest entries, and the exclusion entries, so it can be adapted when merged into the epic integration branch.
- Isolated subagents run the default branch's hook copies; the leg takes effect for agents only after merge, and for destinations only after the extension release and a push-down refresh.

## Rollout & Follow-up

- Release/rollout: merge to `main`, publish an extension release, and integrate into the epic #1018 integration branch (adaptation may be required there).
- Destinations: opt in by committing `.claude/release-commit-allowance.json` after the next push-down refresh.
- Links: issue #1201; research `research/research.2026-11-17T19-10.md`; related legs #1026, #1160, #1169, #1182; resolver #1188.
