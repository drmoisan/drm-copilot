# Research: release-commit allowance leg for the preimplementation gate (Issue #1201)

- Issue: #1201
- Branch: bug/release-commit-allowance-gate
- Requirements source: `issue.md` in this feature folder, section `## Expected Behavior` (items 1-5)
- Timestamp note: the researcher has no shell; the file stamp is the coordinator-supplied fallback `2026-11-17T19-10`.
- Method: every finding below was read from the item worktree with Read/Grep/Glob. No test or toolchain command was run. Facts that need `git` or a live run are marked "orchestrator to confirm".

## 1. Current State: gate decision flow (command leg)

### Claude gate `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (493 lines)

`Invoke-OrchestrationPreimplementationGateDecision`, in order:

1. Dependency-failure decision (`Get-HookDependencyFailureDecision`), payload parse (`Resolve-ClaudeHookToolInput`).
2. Classification: `file_path` -> `Test-ImplementationPath`; else `command` -> `Test-ImplementationCommand`; else delegation -> `Test-ImplementationDelegation`. Not classified -> allow. `git add`/`git commit` is classified structurally (index 0, `Test-CommandLineInvocation`), unless `Test-ExemptOrchestrationStagingCommand` (#539 trees) clears it.
3. `Test-OrchestrationDelegationDeclaredCheckpointPath` (delegation only in practice).
4. Epic scope first: `Get-OrchestrationEpicScopeDecision -Command -FilePath` (epic-scope sibling). Non-epic returns `$null`.
5. Epic/parallel delegation modes return here.
6. Single-feature checkpoint read: when `-CheckpointRaw` is not bound/empty, `Read-OrchestrationGateCheckpoint -Mode 'single-feature' -Prompt -FilePath -Command`; an unresolved target returns its deny immediately (`TARGET_WORKTREE_NOT_DERIVABLE` / ambiguous). Sets `$checkpointPath = $read.Path`. When `-CheckpointRaw` is injected (tests), `$checkpointPath` stays `''`.
7. `Test-OrchestrationReady` -> allow. **This is where the readiness failure is detected.**
8. Allow-side legs, each a one-line `if (($x = <Leg>).Allowed) { return allow }` with the result captured for its suffix:
   1. `Get-OrchestrationCleanupContextResult -FilePath -Content -Command` (#1026, `-cleanup.ps1`)
   2. `Get-OrchestrationBookkeepingStagingResult -Command -CheckpointPath $checkpointPath` (#1160/#539, `-bookkeeping.ps1`)
   3. `Get-OrchestrationDocsEstateContextResult -FilePath -Command` (#1169, `-docs.ps1`)
   4. `Get-OrchestrationParallelRecordsResult -ToolInput -FilePath` (#1182, `-parallel-records.ps1`, Claude only)
9. Final deny: the fixed `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require ...` text `+ $cleanup.DenySuffix + $bookkeeping.DenySuffix + $docs.DenySuffix + $parallel.DenySuffix`.

Dot-source form (header block): every sibling is loaded as `try { . (Join-Path $PSScriptRoot '<file>') } catch { Add-HookDependencyFailure -Name '<file>' -ErrorRecord $_ }`, one statement per line. This form is pinned by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S2: every direct edge guarded in its own single-statement try).

Leg result contract (shared by all four legs): `[pscustomobject]@{ Allowed = <bool>; DenySuffix = <string> }`, never throws (outer `try/catch` returns `Allowed $false`, empty suffix, `Write-Debug` with a `PREIMPL_<LEG>_LEG_ERROR` token). Suffix grammar: `' <Leg> leg not applied: <SUB_CODE>: <detail>'` (cleanup, docs, parallel) or `' Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: <detail>.'`.

### Codex gate `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (486 lines)

Same decision order with three structural differences: (a) payload is mapped JSON from `ConvertFrom-CodexPreToolUsePayload` (Bash and `apply_patch` reach the decision with `command`, so `command` may be apply_patch text beginning `*** Begin Patch`); (b) the cleanup call passes `-AllowPatchManifest`; (c) there is no parallel-records leg. The final line is `... + $cleanup.DenySuffix + $bookkeeping.DenySuffix + $docs.DenySuffix`. The Codex epic-scope sibling additionally dot-sources `enforce-orchestration-preimplementation-gate-epic-resolution.ps1`, which defines the Codex copies of `Get-WorktreeResolutionGitFileText` and `Get-EpicScopeWorktreeHeadBranch`.

### Smallest insertion point (recommended)

- One guarded dot-source line after the parallel-records line (Claude) / after the docs line (Codex): `try { . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-release.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-release.ps1' -ErrorRecord $_ }`.
- One leg line immediately before the final deny, after the last existing leg: `if (($release = Get-OrchestrationReleaseAllowanceResult -Command $command -CheckpointPath $checkpointPath).Allowed) { return Get-OrchestrationPreimplementationGateAllowDecision } # Release-commit allowance leg (issue #1201).`
- Append `+ $release.DenySuffix` as the last term of the final deny expression.
- Net growth: +2 lines per gate (Claude 495, Codex 488). The Codex gate is pinned at <= 500 lines by `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` (`keeps <File> at or under 500 lines in the repository and the bundle`) and by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`parse-checks each root and bundled hook and keeps every file within 500 lines`); 488 passes both. No test pins the Claude gate's line count.

The leg is command-leg only by construction: it returns immediately for a blank `-Command` (Write/Edit path legs and delegations reach the final deny with `$command = ''`) and for Codex apply_patch text.

PowerShell `command` input: on Claude the gate is registered only under the `Bash`, `Write|Edit`, and `Agent` groups of `.claude/hooks/pretooluse-dispatch.json`; on Codex under `^Bash$`, `^(apply_patch|Edit|Write)$`, and the delegation group of `.codex/hooks/pretooluse-dispatch.json`. The Claude PowerShell tool and the Codex `shell_command` tool never reach this gate, so no allowance is needed for them. The leg reads the `command` field generically and therefore applies to any tool whose payload the gate receives with `command`. No registration change is in scope.

## 2. #1188 operand resolver and `-C` handling

- `Get-OrchestrationGateCommandTargetOperand -Command` (`enforce-orchestration-preimplementation-gate-operands.ps1`, byte-identical in four copies) returns `Paths`, `Unresolved`, `Detail`. It folds in `Get-OrchestrationGateCommandOperandPath` (epic-scope sibling: every `-C` value and absolute operand of `git add`/`git commit`).
- `Add-OrchestrationGateOperandFinding`: a selector value that is missing, or not literal per `Test-CommandLineTokenLiteral` (shell variable or substitution), sets `Unresolved` with `unresolvable operand (shell variable or substitution): '<token>'`; a relative literal is ignored; an absolute literal is added.
- `Resolve-OrchestrationGateTarget` (epic-scope sibling) returns `Status = 'NoTarget'` with `ReasonCode = Get-WorktreeResolutionNoTargetReasonCode` for an Unresolved operand **before any listing call or checkpoint read**; otherwise it calls `Resolve-HookTargetWorktree -CommandOperandPath` with the recording listing invoker and returns `SessionRoot` / `OtherWorktree` with an absolute `WorktreeRoot`.
- `Read-OrchestrationGateCheckpoint` turns NoTarget/Ambiguous into the deny `PREIMPLEMENTATION_GATE_BLOCKED: <ReasonCode>: the target worktree of this single-feature call could not be resolved: ...`, and otherwise returns `Path = Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot <root>`.

Consequence for the issue's "deny an unexpandable `-C`": `git -C "$WT" add package.json` is already denied at step 6 with `TARGET_WORKTREE_NOT_DERIVABLE` before any leg runs. The release leg never sees it; the table-driven test row asserts that existing deny text (with no release suffix).

Gap the leg must close itself: a relative literal `-C` (for example `git -C sub add package.json`) is ignored by the resolver, so the target resolves to the session root while git would stage `sub/package.json`. An absolute `-C` naming a subdirectory resolves to its enclosing worktree. The leg must therefore require every `-C` value, when present, to be absolute and equal (normalized, ordinal case-insensitive, like `ConvertTo-OrchestrationCleanupComparablePath`) to the resolved root R; otherwise `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED`.

Root R for the leg: derive it from `$checkpointPath` with the existing `Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath -CheckpointSuffix ([string]@($script:CheckpointPaths)[0])` (bookkeeping sibling, both surfaces). This adds no git or listing call, honors the #1188 resolution, and yields `$null` when tests inject `-CheckpointRaw` (the leg then declines with no I/O).

## 3. Segmenting and tokenizing (reusable functions)

From `enforce-orchestration-preimplementation-gate-helpers.ps1` (both surfaces, loaded by both gates):

- `Test-OrchestrationCommandTextUnresolvable -CommandText`: true for `$` or backtick outside single quotes, `<`, `>`, `#`, `{ } , ( ) @` outside quotes, any backslash, or a typographic quote. Note: `git commit -m "release $VERSION"` and any message containing a backslash are unresolvable.
- `Split-OrchestrationCommandLine -CommandText` -> `@{ Balanced; Segments }`, splitting on `;`, `&`, `|`, newline outside quotes.
- `ConvertTo-OrchestrationCommandToken -Segment` -> tokens with balanced quotes stripped.

Existing per-segment shape models (none is reusable as-is for the issue's option table):

- `Get-EpicFanInShapeDetail` / `Get-EpicFanInAllowance` (`hook-epic-fan-in.ps1`): `git [-C <abs>] add [--] <p...>`; commit with `-m`, `--message`, `-F`, `--file`, `--trailer` only, no `-s`, no `--message=` form, and no failure codes (Detail only). Not suitable because the issue requires `-s/--signoff`, forbids `--trailer`, and requires one code per failure.
- `Test-OrchestrationCleanupSegmentShape` (cleanup sibling) and `Get-OrchestrationDocsEstateSegmentShape` (docs sibling): same commit option set plus `--name=value` forms; return shape only.

Recommendation: a new pure classifier in the context file that walks tokens positively (`git`, optional `-C <abs>`, subcommand, then a closed option table) and returns `Kind`, `Paths`, `Code`, `Detail`, reusing the three helper functions above for split/tokenize/unresolvable checks.

## 4. Git seams, branch read, detached HEAD

- Bounded git wrapper: `Invoke-DocsOnlyGitExe -WorktreeRoot -GitArgs [-GitInvoker]` in `hook-docs-only-diff.ps1` (both surfaces; dot-sourced by the cleanup and docs siblings). Never throws; returns `ExitCode` and `Output`; `-1` for a non-directory root or start failure; 3000 ms timeout through `Invoke-DocsOnlyBoundedNative`.
- Staged index seam: `Get-OrchestrationGateStagedIndex -WorktreeRoot` (cleanup sibling) runs `diff --cached --name-only -z --no-renames --no-color --no-ext-diff --no-relative` through the wrapper. `ConvertFrom-DocsOnlyNameList -Text` (`hook-docs-only-diff.ps1`) parses the NUL list. The unreadable/empty/not-NUL-terminated triage pattern to copy is in `Get-OrchestrationDocsEstateStagedResult` and `Get-OrchestrationCleanupConsolidationCommandResult`.
- Branch read: `Get-EpicScopeWorktreeHeadBranch -WorktreeRoot` (Claude `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`; Codex `enforce-orchestration-preimplementation-gate-epic-resolution.ps1`). It reads the HEAD file through `Get-WorktreeResolutionGitFileText` (no process), follows a `.git` file pointer, and returns `$null` for a detached HEAD (first line not `ref: refs/heads/`) or an unreadable HEAD. The parallel-records leg already uses it (Q4). No hook uses `symbolic-ref` or `rev-parse --abbrev-ref`.
- Test mocking pattern: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1` mocks `Get-EpicScopeWorktreeHeadBranch` and `Get-WorktreeRunCheckpointText` directly (no `-ModuleName`, since the call site is in dot-sourced script scope). `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.BookkeepingLeg.Tests.ps1` mocks `Get-OrchestrationGateStagedIndex` per row with `[pscustomobject]@{ ExitCode; Output }` closures and `Read-OrchestrationGateCheckpoint` to a synthetic `/synthetic-worktrees/item/...` path. Per `.claude/rules/powershell.md`, mock the wrapper/seam, never `git`.

## 5. Config read pattern

`enforce-orchestration-preimplementation-gate-bookkeeping.ps1`:

- `Get-OrchestrationGateBookkeepingConfigText` is the only I/O: resolves `config/preimplementation-gate.json` two levels above `$PSScriptRoot`, returns `$null` when absent (`Test-Path -PathType Leaf`), else `Get-Content -Raw -ErrorAction Stop`.
- `ConvertFrom-OrchestrationGateBookkeepingConfig -Text` returns `Valid`, `Roots`, `Detail`; uses `ConvertFrom-Json -NoEnumerate`, closed key set with `-cnotcontains`, `schema_version` integer-1 check (`[int]` or `[long]`), first failing rule wins.
- `Get-OrchestrationBookkeepingStagingResult` takes `-ConfigReader` and `-StagedIndexReader` scriptblock parameters with seam defaults; a read throw becomes `Valid $false` with `the file could not be read`.

Do not use `Get-WorktreeResolutionGitFileText` for the allowance file: it returns `$null` for both absent and unreadable, and the issue requires unreadable to deny.

Recommended seam: `Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot <R>` returning `$null` when `<R>/.claude/release-commit-allowance.json` is not a leaf, else `Get-Content -Raw -ErrorAction Stop`. Read beneath R (the target worktree), not beneath `$PSScriptRoot`:

- the file is committed with the branch whose files are being committed, and R is the worktree the commit acts on;
- the relative location is identical for `.claude/hooks` and `.codex/hooks` (no surface-specific `Split-Path` arithmetic);
- it follows the docs-estate precedent (profile read beneath R).

Writing the allowance file itself is gated: `Test-ImplementationPath` classifies any `.json` path, so a checkpoint-free agent's Write/Edit of it is denied.

## 6. Existing Pester tests and harness style

Gate decision suites (Claude, `tests/scripts/claude-hooks/`): `enforce-orchestration-preimplementation-gate.Tests.ps1`, `.Cleanup.Tests.ps1`, `.BookkeepingLeg.Tests.ps1`, `.DocsEstate.Tests.ps1`, `.ParallelRecords.Tests.ps1`, `.OperandResolution.Tests.ps1`, `.OperandBypass.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.Classification.Tests.ps1`, `.CommandExemption.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.EpicScope*.Tests.ps1`, `.EpicFanIn.Tests.ps1`, `.MergedFollowUp.Tests.ps1`. Codex (`tests/scripts/codex-hooks/`): `enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`, `-bookkeeping-leg.Tests.ps1`, `-docs.Tests.ps1`, `-operand-bypass.Tests.ps1`, `-classification.Tests.ps1`, `-epic-scope*.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`.

Harness style: dot-source the gate in `BeforeAll`; `EpicStateIsolation.Baseline.Helpers.ps1` with `Register-EpicStateBaselineMock` and an interception probe `It`; `Mock Resolve-OrchestrationGateTarget` / `Read-OrchestrationGateCheckpoint` to synthetic forward-slash roots; per-row seam mocks in `BeforeEach`/`It`; table rows via `-ForEach` with data defined in a `*.Cases.ps1` loaded in `BeforeDiscovery`; deny-text assertions with `Should -BeExactly`. Unit suites for a sibling run both copies with `Describe ... -ForEach @(@{ Surface = 'Claude' }, @{ Surface = 'Codex' })` (`enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1`).

Parity tests: `enforce-orchestration-preimplementation-gate-bookkeeping.Parity.Tests.ps1` (SHA256 across four roots, `< 500` lines) and `hook-docs-estate-context.Parity.Tests.ps1` (two leaves across four roots). `enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` additionally pins tokens in the `## Hook Execution Context` section of the six execution-environment copies; copy that pattern for the docs pin.

## 7. Push-down

- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (lists e.g. `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1`, `hook-docs-estate-context.ps1`) and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (lists `.codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`, `-bookkeeping.ps1`, `-cleanup.ps1`). Add both new files to both core manifests. `scripts/dev_tools/generate_codex_agent_variants.py` `render_manifest` keeps existing `paths` and only adds agent paths, so a hand-added hook path survives `--check` (orchestrator to confirm by running the check).
- Bundle mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- Closure/completeness/content contracts that the new files must satisfy: `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (every `$PSScriptRoot` dependency of a manifested file is in core), `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`.
- Refresh semantics: `PushDownFileSystem` (`extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts`) exposes `listFiles`, `isDir`, `isFile`, `readTextFile`, `writeTextFile`, `ensureDir` and no delete; no file under `src/lib/push-down/` deletes. A refresh therefore never deletes an unmanaged destination file. It can overwrite: with no pack selection `pushDownCustomizations` (`claude-customizations.ts`) publishes the whole source `.claude` and `config` trees (`ROOT_FOLDERS`) except `EXCLUDED_RELATIVE_PATHS` (`.claude/settings.local.json`, `config/blast-radius.local.json`). So the allowance file is safe only while no source/bundle copy exists.
- Recommendation: add `.claude/release-commit-allowance.json` to `EXCLUDED_RELATIVE_PATHS` (precedent: `config/blast-radius.local.json`, a destination-owned file), so a refresh cannot create or overwrite it even if a copy ever appears in the source. `claude-customizations.ts` is 496 lines (+1). The Codex push-down roots are `.codex`, `.agents` plus virtual `config` and `.codex/lib/codex-routing`, so it never reaches `.claude/`.
- Contract test location: TypeScript, in a new `extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts` mirroring `claude-customizations.test.ts` (`buildInMemoryFileSystem`, `fixedClock` from `push-down.test-helpers`; the case "excludes settings.local.json from the published set"). Rows: (a) seed source with an allowance file and destination with different text, run `pushDownCustomizations` with no packs and with `packs: new Set(["core"])`; assert the destination text is unchanged and `summary.files` omits the path; (b) `EXCLUDED_RELATIVE_PATHS` contains the path. No new production TS file, so no new `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`. The "no pack manifest lists the file" and "repo/bundle hold no copy" assertions fit a Pester parity file (pure JSON/file reads, no Python). An equivalent Python harness exists (`test_push_down_claude_blast_radius_overlay.py`) but is not needed.

## 8. Documentation targets

- `## Hook Execution Context` of the execution-environment brief, six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the three bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, `.../codex-and-agents-customizations/.agents/skills/`, `.../customizations/.github/skills/`. Add one bullet "Release-commit allowance leg (#1201)" after the parallel records bullet, and name the new contract tests in `## Contract Tests That Pin Mirrored Files`.
- "The rule that describes the preimplementation gate": no `.claude/rules/*.md` file describes the command-leg allow legs (#1026, #1160, #1169, #1182). The documents that do are (a) the execution-environment brief above, and (b) `## Pre-Implementation Gate` of `.agents/skills/orchestrate/SKILL.md` (Codex runtime doc; it carries the #1160 bookkeeping paragraph) plus its bundle copy. `.claude/rules/orchestrator-state.md` (runtime rule, no `.github/instructions` counterpart, bundled) documents only the epic regeneration preimplementation allowance and states that `config/orchestration-regeneration.json` is never bundled. Recommendation: update (a) and (b); add a short "Release-commit allowance scope" paragraph to `.claude/rules/orchestrator-state.md` and its bundle copy only if the planner wants a Claude-side rule text (it is a runtime doc, not a canonical `.github/instructions` policy file, so it is editable). Do not edit `.github/instructions/*`.
- CHANGELOG: `extensions/drm-copilot/CHANGELOG.md` (Keep a Changelog; `## [Unreleased]` has `### Added`, `### Changed`, `### Fixed`). Add an `### Added` entry: destinations receive the leg through the next push-down refresh after the extension release, and opt in by committing `.claude/release-commit-allowance.json`. No test pins CHANGELOG content (`tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1` reads it for release mechanics only; orchestrator to confirm no content assertion breaks).
- Contract tests that read these docs: `enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` (section tokens), `tests/scripts/claude-runtime/documentation-workflow.CommitStage.Tests.ps1` (docs-estate bullet in the six copies), `test_push_down_claude_resource_contracts.py` / `test_push_down_codex_and_agents_resource_contracts.py` (source equals bundle), `test_claude_rules_frontmatter.py` (if the rule file is edited).

## 9. File-size headroom and file names

| File | Current lines | After change |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (+ bundle) | 493 | 495 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (+ bundle) | 486 | 488 (pinned <= 500) |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | 496 | 497 |
| `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts` | 335 | unchanged (new test file recommended) |
| new `hook-release-allowance-context.ps1` (four copies) | 0 | est. 250-350, keep < 500 |
| new `enforce-orchestration-preimplementation-gate-release.ps1` (four copies) | 0 | est. 120-200, keep < 500 |
| execution-environment `SKILL.md` (six), orchestrate `SKILL.md`, CHANGELOG | Markdown | exempt |

Names (byte-identical across `.claude/hooks`, `.codex/hooks`, and both bundles):

- `hook-release-allowance-context.ps1`: pure, no I/O. `ConvertFrom-ReleaseAllowanceConfig -Text` (Valid, Allowances, Detail), `Test-ReleaseAllowanceBranchMatch -Branch -Pattern`, `Get-ReleaseAllowanceSegmentShape -Token` (Kind, Selector, Paths, Code, Detail), `Get-ReleaseAllowanceCommandDecision` (applies one allowance to all segments plus the staged list, returns Allowed/Code/Detail).
- `enforce-orchestration-preimplementation-gate-release.ps1`: guarded dot-source of the context file; seam `Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot`; entry `Get-OrchestrationReleaseAllowanceResult -Command -CheckpointPath [-ConfigReader] [-BranchReader] [-StagedIndexReader]` returning `Allowed`, `DenySuffix`.
- Use unique `$script:ReleaseAllowance*` variable names: the dispatcher's `in-process` isolation dot-sources many hooks into one process.

## Candidate Approaches

1. **Selected: new sibling leg + pure context file, root from `$checkpointPath`, config beneath R, explicit option table.** Matches the #1160/#1169 sibling pattern, adds two lines per gate, keeps the leg's I/O to three mockable seams, and makes the no-file path free of git calls.
2. Rejected: reuse `Get-EpicFanInAllowance` with a path predicate (as the bookkeeping leg does). Its option table includes `--trailer` and lacks `-s/--signoff`, and it reports no per-failure codes.
3. Rejected: read the config beneath `$PSScriptRoot` (bookkeeping precedent). It reads the hook checkout, not the worktree being committed, and needs surface-specific path arithmetic for `.codex/hooks`.
4. Rejected: resolve R independently through `Get-OrchestrationCommandTarget` and the listing seam (docs-leg precedent). It adds a `git worktree list` call on every denied staging command, which changes seam call counts in existing suites.

## Behavior Semantics (proposed for the spec)

Evaluation order inside `Get-OrchestrationReleaseAllowanceResult` (first failure decides; never throws):

1. Blank command or `*** Begin Patch` text -> decline, empty suffix.
2. R = `Get-OrchestrationGateBookkeepingWorktreeRoot` of `-CheckpointPath`; `$null` -> decline, empty suffix (injected-checkpoint tests).
3. Config text beneath R: `$null` (absent) -> decline, empty suffix, no further I/O. Read throws -> `RELEASE_ALLOWANCE_CONFIG_INVALID: the file could not be read`.
4. Parse: invalid -> `RELEASE_ALLOWANCE_CONFIG_INVALID: <first failing rule>`. Rules: JSON object; keys exactly `schema_version` and `allowances`; `schema_version` integer 1; `allowances` non-empty array of objects with exactly `id`, `branch_patterns`, `allowed_paths`; `id` non-empty string, unique; `branch_patterns` non-empty array of non-empty strings (recommend restricting to `^[A-Za-z0-9._/*?-]+$`, no `[` class syntax); `allowed_paths` non-empty array of strings matching `^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*$` with no `.`/`..` segment, no glob character, no trailing `/`, no leading `/`, no drive letter, no duplicates. A directory entry without a trailing slash cannot be detected lexically; an optional container probe beneath R through the config seam module would close it, and the commit-time staged-index check denies its effect regardless.
5. From here every failure appends `' Release allowance not applied: <CODE>: <detail>'` (one code).
6. Whole-line shape: unresolvable text, unbalanced quotes, or any segment that is not `git [-C <abs>] add|commit ...` -> recommended additional code `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED` (the issue's six codes do not cover a non-git segment; spec decision). Recommend emitting no suffix when no segment is a git add/commit at all (e.g. a plain `pytest` while the file exists) to avoid noise; the issue's text only requires the suffix "when a release allowance exists".
7. Branch: `Get-EpicScopeWorktreeHeadBranch -WorktreeRoot R`; `$null` (detached/unreadable) or no allowance whose patterns match (case-sensitive `[WildcardPattern]` with option `None`, full name) -> `RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED`. Candidate allowances = those matching the branch; the command must qualify entirely under one of them.
8. Selectors: each `-C` must be absolute and equal R; `git -c`, `--git-dir`, `--work-tree`, or any other global option -> `RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED`.
9. `git add`: only `--` (at most once, before operands) and literal operands; any dash option (`-A`, `--all`, `-u`, `--update`, `-f`, `--force`, `-p`, `-i`, `--pathspec-from-file`, ...) -> `OPTION_NOT_ALLOWED`; zero operands, `.`, a glob, a directory, or an operand not in `allowed_paths` -> `RELEASE_ALLOWANCE_PATH_NOT_ALLOWED`.
10. `git commit`: allowed `-m <v>`, `--message <v>`, `--message=<v>`, `-F <v>`, `--file <v>`, `--file=<v>`, `-s`, `--signoff`; repeatable. Everything else, including attached `-mvalue`, `--trailer`, `-a`, `--amend`, `-n`, `--no-verify`, `-c`, `-C`, `--reuse-message`, `--fixup`, `--squash`, `--allow-empty`, `-o`, `--only`, `-i`, `--include` -> `OPTION_NOT_ALLOWED`; any operand or `--` pathspec -> `PATH_NOT_ALLOWED`.
11. Staged index (only when a commit segment exists): `Get-OrchestrationGateStagedIndex -WorktreeRoot R`; null/non-zero exit/not NUL-terminated -> `RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE`; empty -> `RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY`; a name outside `allowed_paths` -> `RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED`. Chain decision for the spec: the hook runs before the command, so in `git add package.json && git commit -m x` the index does not yet hold `package.json`. Recommend evaluating the union of the current staged names and the operands of `git add` segments that precede the commit segment (both already validated against `allowed_paths`); without this the documented two-step chain is denied with `STAGED_INDEX_EMPTY`.
12. All checks pass -> `Allowed $true`.

## Numeric Derivation Evidence

### N1: copies of each new hook file

- Complete Family: surface roots that carry the byte-identical preimplementation-gate siblings.
- Exhaustive Search Scope: the whole item worktree.
- Inclusion Rules: a path whose leaf is `enforce-orchestration-preimplementation-gate-bookkeeping.ps1` (the closest existing four-surface sibling).
- Exclusion Rules: feature-folder documents.
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`.
- Primary Member Set: `.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: the `$script:SiblingSurfaceRoots` array literal read in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Parity.Tests.ps1`.
- Cross-check Member Set: `.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`.
- Cross-check Count: 4.
- Member-set Comparison: identical sets after normalizing to the containing directory.

### N2: copies of the execution-environment brief

- Complete Family: every `execution-environment/SKILL.md` in the worktree.
- Exhaustive Search Scope: the whole item worktree.
- Inclusion Rules: file name `SKILL.md` under a directory named `execution-environment`.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/execution-environment/SKILL.md`.
- Primary Member Set: `.agents/skills`, `.claude/skills`, `.github/skills`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills`, `extensions/drm-copilot/resources/customizations/.github/skills` (each `/execution-environment/SKILL.md`).
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: Grep `^## Hook Execution Context` (files_with_matches) over the worktree excluding `docs/`.
- Cross-check Member Set: the same six paths.
- Cross-check Count: 6.
- Member-set Comparison: identical.

### N3: core pack manifests

- Complete Family: pack manifests named `core.json`.
- Exhaustive Search Scope: `extensions/`.
- Inclusion Rules: `pack-manifests/core.json`.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/pack-manifests/core.json` under `extensions/`.
- Primary Member Set: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep of the literal sibling names (`enforce-orchestration-preimplementation-gate-parallel-records.ps1` in `*.json` under `extensions/drm-copilot`; `enforce-orchestration-preimplementation-gate-(bookkeeping|docs|cleanup).ps1` in the Codex manifest), which located the manifest that lists each surface's siblings.
- Cross-check Member Set: the same two files.
- Cross-check Count: 2.
- Member-set Comparison: identical.

## Requirements Mapping (file changes)

- New: `hook-release-allowance-context.ps1` and `enforce-orchestration-preimplementation-gate-release.ps1` in four roots each.
- Edit: both gates and their bundle copies (one dot-source line, one leg line, one suffix term).
- Edit: both `core.json` manifests (+2 paths each).
- Edit: `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` `EXCLUDED_RELATIVE_PATHS` (+1 entry).
- Edit: six execution-environment copies; `.agents/skills/orchestrate/SKILL.md` and its bundle copy; optionally `.claude/rules/orchestrator-state.md` and its bundle copy; `extensions/drm-copilot/CHANGELOG.md`.
- Production PowerShell files touched: 12 (2 gates x 2 copies, 2 new files x 4 copies), above the direct-mode cap of 3; the orchestrated route is required (no cap there).

## Testing Implications

- `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1`: `-ForEach` Claude/Codex copies; parser rows (valid; each invalid case: bad JSON, non-object, unknown/missing key, schema_version 2 and "1", empty allowances, duplicate id, empty/non-string id, empty branch_patterns, empty allowed_paths, glob, trailing slash, `..`, absolute, drive letter, duplicate path); branch match rows; segment-shape rows per option.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1`: decision-level tables through `Invoke-OrchestrationPreimplementationGateDecision`, mocking `Read-OrchestrationGateCheckpoint` (synthetic `/synthetic-worktrees/release/...` path), `Get-OrchestrationGateReleaseAllowanceConfigText`, `Get-EpicScopeWorktreeHeadBranch`, `Get-OrchestrationGateStagedIndex`. Rows: allowed add, allowed commit (`-m`, `-F`, `-s`), add+commit chain, each forbidden add/commit option, forbidden operand, `-c` prefix, relative `-C`, `-C` to another root, branch mismatch, detached HEAD (`$null`), chained non-git segment, staged extra path, empty index, unreadable index (`ExitCode -1`), unexpandable `-C` (asserts the existing `TARGET_WORKTREE_NOT_DERIVABLE` text with no release suffix), file absent (asserts the exact generic text), invalid file (suffix position after the other suffixes), and `Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 0` / `Get-OrchestrationGateStagedIndex -Times 0` when the file is absent.
- `tests/scripts/claude-hooks/hook-release-allowance-context.Parity.Tests.ps1`: SHA256 identity of both new files across four roots; < 500 lines; tokens in `## Hook Execution Context` of the six brief copies; no `pack-manifests/*.json` under either bundle lists `.claude/release-commit-allowance.json`; the file is absent from the repository root and from both bundles.
- Jest: `extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts` (section 7).
- Existing suites stay unmodified; every gate and toolchain gate runs through the test-execution launcher in parallel form.

## Pre-Mortem

- Review checklists: reviewers check the final deny text is unchanged without the file, guarded dot-source form, docs in all six copies, and CHANGELOG; mitigation: plan a task that greps every gate test's expected deny literal and a decision-level row asserting `Should -BeExactly` the generic text when the config seam returns `$null`.
- Coverage: the new PowerShell files must reach >= 85% line coverage and are in `config/poshqc-coverage.json` derivation by folder; risk is an untested seam default (`Get-Content` branch); mitigation: unit rows that call the real seam against a mocked `Test-Path`/`Get-Content` and rows for every parser rule, recorded from the single parallel Pester gate.
- Mirror parity: four copies of two new files, two gates with bundle copies, two manifests, six brief copies, two orchestrate copies; mitigation: one parity test file plus the existing push-down resource and manifest completeness tests, and a plan task that copies bundle files in the same task that edits the source; the plan's Mirror parity bullet names the execution-environment update task.
- File size: Codex gate is pinned at <= 500 (488 after); `claude-customizations.ts` reaches 497; new files estimated < 400; mitigation: a plan step that records `@(Get-Content).Count` for each touched file before handoff and splits the context file if it passes 450.
- Test isolation: the leg must make no git or listing call when the file is absent, and must use unique `$script:` names; existing suites mock `Read-OrchestrationGateCheckpoint` to synthetic roots, so the unmocked config seam probes a non-existent path (returns `$null`); mitigation: the absent-file rows with `-Times 0` invocation assertions, no environment or global state in new tests, and a `Invoke-PoshQCLeakScan` run.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on a case-sensitive file system; mitigation: forward-slash synthetic roots, `Join-Path`, exact-case file names, no drive letters or backslash literals in fixtures, and no read of gitignored `artifacts/` state.
- Evidence: gate evidence must come from the launcher's parallel Pester run (JUnit and coverage files), the Jest run, and the push-down contract tests, append-only under `evidence/<kind>/` with clock-read stamps; PoshQC MCP results carry no counts and are not evidence; mitigation: the plan names the JUnit/coverage file paths as the evidence sources.

## Risks

- "Existing gate tests pass unmodified": safe only if the leg declines before any seam call when `-CheckpointPath` is empty or the file is absent; any new git call (branch, staged index) before the existence check would change mocked-seam invocation counts in suites such as `.BookkeepingLeg.Tests.ps1` and `.Cleanup.Tests.ps1`.
- Order of suffix concatenation: append `$release.DenySuffix` last so existing suffix-order assertions (`places the invalid-configuration suffix after the cleanup suffix`) are unaffected.
- If this repository ever commits its own `.claude/release-commit-allowance.json`, the existing suites that use the real checkpoint read at the repository root would see it, and `test_push_down_claude_resource_contracts.py` would expect a bundle copy unless the path is added to the local-only set in `tests/scripts/dev_tools/claude_payload_scope_test_support.py`. The plan should assert absence (Parity test) and record this as a known constraint.
- Isolated subagents run `main`'s hook copies, so the leg is proven by Pester only until merge and release; destinations receive it only after an extension rebuild, release, and push-down refresh.
- Epic #1018 is changing the hook architecture (dispatcher, generators, push-down consolidation); the leg is self-contained in two new files plus three gate lines to minimize the merge surface.
- Commit messages containing `$`, a backtick, or a backslash are unresolvable and denied; document the use of single quotes or `-F <file>`.
