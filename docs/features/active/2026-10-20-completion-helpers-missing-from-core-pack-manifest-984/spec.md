# 2026-10-20-completion-helpers-missing-from-core-pack-manifest (Spec)

- **Issue:** #984
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-20T12-40
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug

## Context

After a push-down, `.claude/hooks/enforce-completion-consistency.ps1` blocks every `Write` and `Edit` tool call in the target repository, including edits to files unrelated to the orchestrator checkpoint. The hook dot-sources `enforce-completion-helpers.ps1`, but the Claude core pack manifest does not list that file, so it is never pushed down. The load fails, and the hook fails closed before it checks whether the target path is one it governs.

Environment:
- OS/version: Windows 11 (downstream repository TaskMaster)
- Python version: not applicable (PowerShell 7 hook)
- Command/flags used: Claude Code `Edit` tool on `TaskMaster/TaskMaster.csproj`
- Data source or fixture: TaskMaster after harness upgrade commit `5791ee47a` ("(chore): upgrade claude harness for 1.1.19")

Impact / Severity: Blocker. No file can be changed with the `Write` or `Edit` tool in any repository that received the Claude core pack at 1.1.19, 1.1.20, or 1.1.21 (the fail-closed guard first shipped in v1.1.19, verified by `git tag --contains`). Executor, engineer, and reviewer workflows are blocked. The only workaround is a user-approved bypass through a non-hooked route.

## Problem Statement

Two defects combine to produce the blocker:

1. Packaging defect. The Claude core pack manifest omits files that manifested hooks, agents, and settings depend on. The manifest-completeness guard recorded the omissions as grandfathered exceptions and asserted they stay absent, so CI preserved the gap.
2. Scope defect. `enforce-completion-consistency.ps1` governs only the canonical checkpoint path, but a failed load of an evaluation-only dependency denies every call before the path is examined. A dependency needed only to evaluate a governed path should not deny out-of-scope calls.

## Repro & Evidence

Steps to Reproduce:
1. Push down the core Claude customization pack (1.1.19) into a target repository that does not already contain `.claude/hooks/enforce-completion-helpers.ps1`.
2. In that repository, call `Edit` on any file (for example a `.csproj`).
3. Observe `COMPLETION_CONSISTENCY_BLOCKED: the dependency 'enforce-completion-helpers.ps1' failed to load`.

Expected:
- Every file a pushed-down hook depends on is pushed down with it.
- A hook that governs only `artifacts/orchestration/orchestrator-state.json` does not deny edits to unrelated paths.

Actual:
```
PreToolUse:Edit hook error: COMPLETION_CONSISTENCY_BLOCKED: the dependency 'enforce-completion-helpers.ps1' failed to load (The term '<repo>\.claude\hooks\enforce-completion-helpers.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.); the gate fails closed.
```

## Root Cause Analysis

Root cause (verified):

1. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/enforce-completion-consistency.ps1` but not `.claude/hooks/enforce-completion-helpers.ps1`. The Codex `core.json` already lists `.codex/hooks/enforce-completion-helpers.ps1`.
2. `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and its TypeScript twin `claude-pack-manifest-completeness.test.ts` carry `.claude/hooks/enforce-completion-helpers.ps1` as a documented pre-existing exception (with `.claude/agents/pr-author.md` and `.claude/hooks/validate-pr-author-output.ps1`) and assert that the exceptions stay absent from every manifest. The guard therefore preserved the gap.
3. `enforce-completion-consistency.ps1` dot-sources the helper and records a failure with `Add-HookDependencyFailure`. The entry point calls `Get-HookDependencyFailureDecision` and returns a deny before the checkpoint path filter (`Test-IsCheckpointPath`) runs. The hook is registered on the Write/Edit PreToolUse matcher, so one missing dependency blocks every file edit.

Contributing findings from research (`research/2026-10-20T12-15-completion-helpers-manifest-research.md`):

- The `$PSScriptRoot` dependency closure of every manifested PowerShell file on the Claude surface has one gap: the completion helper. The Codex surface has none.
- A second dependency class exists outside `$PSScriptRoot`: hook scripts named in the command text of manifested files. Core `.claude/settings.json` registers `validate-pr-author-output.ps1` and the language-pack hooks `check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`, and `enforce-powershell-batch-budget.ps1`, none of which core carries. A missing registered script produces a non-blocking hook error on every matching tool call.
- `.claude/agents/pr-author.md` and `validate-pr-author-output.ps1` belong to the same family: core `orchestrator.md`, core `settings.json`, core `enforce-pr-author-skill.ps1`, and core `enforce-pr-author-command-allowlist.ps1` all reference the pr-author path. The #279 audit recorded the exclusion as an optional follow-up, not a design decision.
- The repository pattern for a dependency needed only for a governed path is the named Handler exemption (H1, issue #565, `enforce-feature-folder-order.ps1`). Moving the dependency decision behind the path filter would violate structural check S6 in `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.

## Scope & Non-Goals

- In scope:
  - Claude `core.json` manifest additions (FR-1).
  - Codex `core.json` addition of `.codex/scripts/post-codex-worktree-session.ps1` (FR-2).
  - Emptying the grandfathered exception sets in the Python and TypeScript completeness tests (FR-3).
  - A Python dependency-closure test with self-tests (FR-4).
  - H1 named-handler conversion of the helper load in `enforce-completion-consistency.ps1` (Claude repository copy and bundle copy) plus the Handler exemption entry (FR-5).
  - Review and conversion of other path-scoped Write/Edit hooks whose evaluation-only guarded dependencies deny out-of-scope calls (FR-6).
  - Recorded rationale for leaving the Codex `enforce-completion-consistency.ps1` unchanged (FR-7).
  - `CHANGELOG.md` `### Fixed` entry (FR-8).
- Out of scope / non-goals: see "Out of Scope" below.
- Explicitly excluded systems, integrations, or datasets: downstream repositories (TaskMaster) are not modified; remediation there is a re-run of push-down.

## Functional Requirements

### FR-1 Claude core manifest additions

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` gains these paths:

- `.claude/hooks/enforce-completion-helpers.ps1`
- `.claude/agents/pr-author.md`
- `.claude/hooks/validate-pr-author-output.ps1`
- `.claude/hooks/check-python-test-purity.ps1`
- `.claude/hooks/enforce-python-batch-budget.ps1`
- `.claude/hooks/check-powershell-test-purity.ps1`
- `.claude/hooks/enforce-powershell-batch-budget.ps1`

The language-pack manifests remain unchanged; a path listed in both core and a language manifest is harmless to the published-set union. A fresh push-down of the core pack into a clean target places each added file.

### FR-2 Codex core manifest addition

`.codex/scripts/post-codex-worktree-session.ps1` is added to the Codex core manifest unless the planner finds evidence that its exclusion is intentional. The Codex manifest edit must match the generator serialization (`json.dumps(indent=2)` plus trailing newline) so that `scripts/dev_tools/generate_codex_agent_variants.py --check` passes. If the planner finds evidence of intentional exclusion, the plan records that evidence and omits the entry.

### FR-3 Completeness test exceptions emptied

In `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`:

- The grandfathered exception set is emptied. An empty set remains in place with a comment naming issue #984, following the Codex precedent `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS = frozenset()`.
- Module docstrings are updated.
- In the Python test, `test_documented_exceptions_remain_absent_from_every_manifest` is replaced by an assertion that the exception set is empty. The TypeScript twin has no "remain absent" test; it asserts the empty set equivalently where the exception set is consumed.

### FR-4 Dependency-closure test

A new Python test module (indicative name `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`) implements research approach B1:

1. For each surface (Claude and Codex bundle roots) it loads every `pack-manifests/*.json`.
2. For each manifest P it computes the effective set `E(P) = paths(core) ∪ paths(P)`; for Codex it also includes the destinations of `VIRTUAL_RESOURCE_PAIRS`, imported from `scripts.dev_tools.push_down_codex_and_agents_customizations`. Core pack name and published-path computation are imported from `scripts.dev_tools.push_down_claude_pack_selection` and `scripts.dev_tools.push_down_codex_pack_selection`, not restated.
3. For each `.ps1`/`.psm1` path in `paths(P)` it reads the bundle file (virtual Codex destinations are read from the resource path of the pair).
4. It lexes the text, removing `<# ... #>` block comments and `#` line comments outside quoted literals and here-strings.
5. It extracts dependency targets for `$PSScriptRoot` forms F1 to F7: F1 positional, F2 named, F3 backtick continuation, F4 nested `Join-Path`, F5 `Split-Path ... -Parent`, F6 variable assigned then imported, F7 data file. Each target is resolved relative to the source file's directory using POSIX normalization (`posixpath.normpath`), a result escaping the bundle root is rejected, and the resolved path must be in `E(P)`.
6. F8 (dynamic `Get-CodexRoutingModuleCandidate` in `.codex/scripts/codex-routing-cli-common.ps1`) is handled as one named entry whose expected candidates (`.codex/lib/codex-routing/CodexDeployment.psm1`, `.codex/lib/codex-routing/CodexTopology.psm1`) must be in the Codex core effective set.
7. Exhaustiveness guard: every remaining `$PSScriptRoot` occurrence must be matched by a dependency pattern or a named non-dependency pattern (repository-root `Split-Path` computations; `$ScriptRoot = $PSScriptRoot` parameter defaults). An unrecognized occurrence fails the test.
8. Command-text closure: each `.claude/hooks/<name>.ps1` named in `.claude/settings.json` hook commands and in the frontmatter `hooks:` of each manifested `.claude/agents/*.md` must be in `E(P)` for the manifest that lists that file; the same applies to `.codex/hooks/<name>.ps1` in `.codex/config.toml`.
9. In-memory self-tests (no files): one case per form F1 to F7 resolving to the expected target; a commented-out reference is ignored; an unrecognized `$PSScriptRoot` form fails the exhaustiveness guard; and a synthetic manifest missing a target reports that target as missing (AC2 proof). A non-empty floor on the number of scanned sources prevents the real-bundle test from passing vacuously.

The test sets are computed from the tree and assert set membership, not fixed counts.

### FR-5 Named-handler conversion in `enforce-completion-consistency.ps1`

In `.claude/hooks/enforce-completion-consistency.ps1` and its bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`:

1. The helper load becomes the H1 named-handler pattern: initialize `$script:CompletionHelpersImportFailure = $null`; a single-statement try dot-sources the helper; the catch sets the variable to `'enforce-completion-helpers.ps1'` instead of calling `Add-HookDependencyFailure`.
2. In `Invoke-CompletionConsistencyDecision`, directly after the `Test-IsCheckpointPath` allow, a check on `$script:CompletionHelpersImportFailure` returns a deny whose reason starts with `COMPLETION_CONSISTENCY_BLOCKED:` and names `enforce-completion-helpers.ps1`.
3. Behavior matrix:

| Condition | Result |
|---|---|
| Helper fails to load; path is not `artifacts/orchestration/orchestrator-state.json` | Allow, exit 0 |
| Helper fails to load; path is the checkpoint (Write or Edit, relative or absolute) | Deny with `COMPLETION_CONSISTENCY_BLOCKED:` naming the helper; helper functions and `Resolve-EditedCheckpointContent` are not called |
| `HookPayload.psm1` fails to load | Deny every call (unchanged; the path cannot be read) |
| `hook-dependency-guard.ps1` fails to load | stderr reason and exit 2 (unchanged) |
| Envelope anomaly | Deny (unchanged) |
| Missing `file_path` | Allow (unchanged) |
| Helper loaded | All existing behavior unchanged |

4. `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` gains a matching Handler exemption entry in `Get-HookImportFailureExemption`: next free handler id, issue `#984`, surface `claude`, HandlerFile, ConsumerFile, and DenyPathFile all `.claude/hooks/enforce-completion-consistency.ps1`, Variable `CompletionHelpersImportFailure`, DenyPathCondition `$script:CompletionHelpersImportFailure`, DenyCode `COMPLETION_CONSISTENCY_BLOCKED:`. The function currently hard-codes `Leaf = @('feature-folder-resolution.ps1')` for every Handler row; the row structure is extended with a per-entry leaf (or the new row is emitted separately) so the new entry carries `enforce-completion-helpers.ps1`. The justification text starts with the handler id and cites #984 and H1 (#565).
5. Structural checks S1, S2, S6 and guard checks G1 to G3 remain satisfied without changes to `hook-dependency-guard.ps1`, which stays byte-identical at its four locations.

### FR-6 Review of other path-scoped Write/Edit hooks

The research table identifies path-scoped Write/Edit hooks with an evaluation-only guarded dependency that currently denies out-of-scope calls:

- `enforce-discovery-artifact-gate.ps1` (dependency `DiscoveryValidation.psm1`)
- `enforce-python-batch-budget.ps1` (dependency `enforce-batch-budget-route.ps1`)
- `enforce-powershell-batch-budget.ps1` (dependency `enforce-batch-budget-route.ps1`)

Requirement: for each of these hooks in the Claude repository copy and bundle copy, and for any Codex counterpart with the same defect, an out-of-scope path is allowed when only an evaluation-only dependency failed, and an in-scope path still fails closed. The conversion uses the same H1 named-handler pattern and adds a Handler exemption entry per hook (including the leaf column from FR-5.4). The planner verifies for each hook that the dependency is evaluation-only (reached only after the path-scope check) and that no other scope-defining dependency is bypassed; a Codex counterpart is converted only if the planner confirms the same defect and the dependency set permits a complete handler. Hooks whose guarded dependencies are scope dependencies (for example `HookPayload.psm1`) remain fail-closed for all calls.

### FR-7 Codex `enforce-completion-consistency.ps1` unchanged

`.codex/hooks/enforce-completion-consistency.ps1` (and its bundle copy) is not changed. Rationale to be recorded in the plan and implementation notes: its helper `enforce-completion-helpers.ps1` is already in the Codex core manifest, and its path mapping depends on other guarded dot-sources (`codex-pretooluse-file-mapping.ps1` and `enforce-checkpoint-monotonic.ps1`, the latter supplying `$script:GovernedCheckpointPath`) that are scope dependencies, so a handler would cover only one of the dependencies; the file is also near the 500-line limit.

### FR-8 Release notes

`extensions/drm-copilot/CHANGELOG.md` `## [Unreleased]` gains a `### Fixed` subsection (none exists today) with an entry, naming issue #984, stating:

- Repositories that received the Claude push-down at 1.1.19, 1.1.20, or 1.1.21 must re-run the Claude push-down. The completion-consistency guard first shipped in v1.1.19 (verified by `git tag --contains`).
- The core Claude pack now carries `.claude/hooks/enforce-completion-helpers.ps1` and the other added files.
- `enforce-completion-consistency.ps1` no longer denies non-checkpoint edits when the helper is absent.

## Non-Functional Requirements

- NFR-1 Mirror parity: each changed repository file under `.claude/` equals its bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and any changed Codex file equals its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass. `hook-dependency-guard.ps1` is unchanged.
- NFR-2 File size: no production, test, or reusable script file exceeds 500 lines. `enforce-completion-consistency.ps1` is near the limit, so the handler uses a single-line try and a single-line deny; the executor records the line count before and after. New proofs go in new test files; `hook-import-failure-exemptions.FailClosed.Tests.ps1` (461 lines) is not extended past the limit.
- NFR-3 No temporary files in tests. Missing-dependency simulation uses `Mock Import-Module { }` and `Mock Join-Path { throw ... } -ParameterFilter { $ChildPath -eq '<leaf>' }` with in-memory envelopes; Python self-tests use in-memory text.
- NFR-4 Linux case-sensitive hook suite: the CI job running `tests/scripts/claude-hooks` on a case-sensitive file system passes. Tests use forward-slash paths through `Join-Path`, no drive letters, and exact-case fixture paths; the Python resolver uses `posixpath`.
- NFR-5 Determinism and isolation: tests are order-independent. Re-dot-sourcing a hook inside an `It` resets `$script:CompletionHelpersImportFailure` (and equivalents) in `finally` and restores the clean hook in `AfterAll`; seeded shuffled Pester runs pass.
- NFR-6 Coverage: line coverage 85% and branch coverage 75% defaults apply (the root `CLAUDE.md` states none); PowerShell has no branch gate. Changed lines in each converted hook are covered, read from `artifacts/pester/powershell-coverage.xml`. No production file is excluded from coverage.
- NFR-7 Fail-closed integrity: an in-scope path with a failed evaluation-only dependency, and any call with a failed scope dependency, still denies.
- NFR-8 Tone and artifacts: no absolute paths are encoded in committed artifacts; evidence is written under `<FEATURE>/evidence/<kind>/`.

## Proposed Fix

### Design summary (what changes where)

- Manifests: Claude `core.json` (FR-1); Codex `core.json` (FR-2).
- Hooks: H1 handler conversion in `enforce-completion-consistency.ps1` and the FR-6 hooks, each with its bundle copy.
- Test infrastructure: Handler exemption rows (with leaf column) in `HookImportFailureExemptions.Helpers.ps1`.
- Tests: emptied exception sets (FR-3); new closure test (FR-4); new Pester proofs (Test Plan).
- Docs: `CHANGELOG.md` (FR-8).

### Boundaries and invariants to preserve

- `hook-dependency-guard.ps1` and structural checks S1 to S6 are not modified or weakened; the handler pattern is the sanctioned exemption mechanism.
- Dependencies that determine scope (payload parsing, path mapping, command scanning) stay fail-closed for all calls.
- Codex hooks keep their current behavior except where FR-6 confirms the same defect.

### Dependencies or blocked work

- None external. Research item 3 (tree-wide search for tests pinning `core.json` contents or counts) is performed by the planner before editing the manifest.

### Files/modules to change

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (FR-2)
- `.claude/hooks/enforce-completion-consistency.ps1` and bundle copy
- `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1` and bundle copies; Codex counterparts only if confirmed (FR-6)
- `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (new)
- New Pester files under `tests/scripts/claude-hooks/` for the handler proofs
- `extensions/drm-copilot/CHANGELOG.md`

### Functions/classes/CLI commands impacted

- `Invoke-CompletionConsistencyDecision` and the dot-source block of `enforce-completion-consistency.ps1`; equivalent decision functions in the FR-6 hooks.
- `Get-HookImportFailureExemption` (leaf column).
- `scripts/dev_tools/generate_codex_agent_variants.py --check` (run, not changed).

### Data flow and validation changes

- Hook flow: parse envelope (HookPayload) -> path scope check -> handler check (in-scope only) -> existing evaluation. A helper load failure is recorded in the handler variable rather than the shared dependency-failure list.

### Error handling and logging updates

- Checkpoint-path deny reason: `COMPLETION_CONSISTENCY_BLOCKED:` naming `enforce-completion-helpers.ps1` and stating the gate fails closed. FR-6 hooks keep their existing deny codes for the in-scope path.

### Rollback/feature-flag considerations

- No feature flag. Rollback is reverting the change; downstream repositories need a push-down re-run either way.

### Technical specifications (interfaces/contracts)

- Inputs/outputs and formats: unchanged hook JSON decision contract (exit 0 with decision JSON; exit 2 with stderr when the guard itself fails to load).
- Required configuration keys and defaults: none.
- Backward-compatibility expectations: no public interface changes; published pack contents grow by the FR-1 and FR-2 files.
- Performance constraints: negligible; the closure test reads bundle files once per manifest and must complete within normal unit-test time.

## Assumptions, Constraints, Dependencies

- Assumptions: the bundle trees and manifests on disk are the authoritative publish inputs; the pack-combination semantics are `core ∪ selected packs` (plus the Codex virtual set).
- Constraints: 500-line file limit; no temp files in tests; Codex manifest must satisfy the generator `--check`.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: more files are published by the Claude core push-down; hook behavior changes only when the helper is absent.
- Data or migration considerations: downstream repositories that received 1.1.19 through 1.1.21 re-run the Claude push-down.
- Logging/telemetry updates: none.
- Compatibility notes: the Claude core manifest is hand-maintained; no generator is affected. The Codex manifest edit must match generator serialization.

## Test Plan

Fail-before evidence for AC2 and AC3 is recorded before the fix: run the new closure test and the new Pester file against the unfixed manifest and hook, and store both failing runs under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.

Python (pytest):
- New closure test module (FR-4): real-bundle closure for Claude and Codex, command-text closure, exhaustiveness guard, and in-memory self-tests (F1 to F7, comment ignore, unrecognized form fails, synthetic manifest missing a target fails). Run in forward and reversed order.
- Updated `test_push_down_claude_pack_manifest_completeness.py` with an exception-set-is-empty assertion.
- A push-down unit test, through the in-memory filesystem or the Python pack-selection twin, asserting that the helper and the other FR-1 files are in the published set for the core-only selection.
- Re-run `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`.

TypeScript (Jest):
- Updated `claude-pack-manifest-completeness.test.ts` with the empty exception set.
- Optional published-set assertion in `claude-pack-selection.test.ts` or `claude-customizations.test.ts`. No production TypeScript changes.

Pester (new file, for example `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1`, plus per-hook files for FR-6):
- Control: non-checkpoint path with the helper loaded is allowed.
- Helper load failed: non-checkpoint path (for example a `.csproj`) is allowed.
- Helper load failed: relative and absolute checkpoint paths, for Write and Edit, deny with `COMPLETION_CONSISTENCY_BLOCKED:` naming `enforce-completion-helpers.ps1`.
- Helper functions are not invoked on the deny path (proven by mocks).
- `HookPayload.psm1` load failure still denies every call.
- Process-level run through the `&` route showing exit 0 and an allow for a `.csproj` path with the helper dot-source failing.
- FR-6 hooks: out-of-scope path allowed and in-scope path denied when the evaluation-only dependency fails.
- Edge cases: envelope anomaly denies; missing `file_path` allows; path separator normalization (`\` to `/`).

Suites to re-run: `hook-dependency-guard-completeness.Tests.ps1`, `hook-import-failure-exemptions.Guard.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1` (edges listed for a Handler entry leave B1; remaining edges keep denying), `hook-import-failure-exemptions.FailClosed.Tests.ps1`, all `enforce-completion-consistency*.Tests.ps1` under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, and the Codex generator `--check`.

Toolchain order per repository policy: format, lint, type-check, architecture-boundary tests, unit tests, contract/schema checks, integration tests; restart on any failure or auto-fix. Shuffled-order Pester runs use at least three seeds.

Manual validation: none required.

## Acceptance Criteria

Traceability to `issue.md`: AC1 to AC4 below correspond to the issue's four acceptance criteria in order; AC5 to AC9 are the scope additions.

- [x] AC1: Claude `core.json` includes `.claude/hooks/enforce-completion-helpers.ps1`, and a fresh push-down into a clean target puts the file in place (proved by completeness tests with empty exceptions, the closure test, and a published-set assertion for the core-only selection). The Codex `core.json` still carries `.codex/hooks/enforce-completion-helpers.ps1`. [issue.md AC1]
- [x] AC2: A manifest dependency-closure test fails if any manifested hook depends on a sibling or lib file that is missing from the manifest, proven by an in-memory self-test in which a synthetic manifest missing a target is reported as failing; the exhaustiveness guard fails on an unrecognized `$PSScriptRoot` form. [issue.md AC2; FR-4]
- [x] AC3: With the helper deliberately removed, an `Edit` of a path other than the checkpoint is allowed, and an `Edit` of `artifacts/orchestration/orchestrator-state.json` is still denied with `COMPLETION_CONSISTENCY_BLOCKED:` naming the helper; a `HookPayload.psm1` load failure still denies every call. Proven by the new Pester file in repository and bundle roots. [issue.md AC3; FR-5]
- [x] AC4: `extensions/drm-copilot/CHANGELOG.md` `## [Unreleased]` has a `### Fixed` entry stating that repositories that received the Claude push-down at 1.1.19, 1.1.20, or 1.1.21 must re-run the Claude push-down, and that the hook no longer denies non-checkpoint edits when the helper is absent. [issue.md AC4; FR-8]
- [x] AC5: Claude `core.json` also includes `.claude/agents/pr-author.md`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/check-powershell-test-purity.ps1`, and `.claude/hooks/enforce-powershell-batch-budget.ps1`, and the command-text closure check passes for `.claude/settings.json` and agent frontmatter. [FR-1, FR-4.8]
- [x] AC6: The grandfathered exception sets in the Python completeness test and its TypeScript twin are empty, and the "remain absent" assertion is replaced by an "exception set is empty" assertion. [FR-3]
- [x] AC7: `.codex/scripts/post-codex-worktree-session.ps1` is in the Codex core manifest (or the plan records evidence that its exclusion is intentional), and `generate_codex_agent_variants.py --check` passes. [FR-2]
- [x] AC8: For `enforce-discovery-artifact-gate.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, and any confirmed Codex counterpart, an out-of-scope path is allowed when only the evaluation-only dependency failed and an in-scope path still fails closed; repository and bundle copies are equal; each hook has a Handler exemption entry; the guard, structural, and exemption suites pass. [FR-6]
- [x] AC9: The Codex `enforce-completion-consistency.ps1` is unchanged and the rationale is recorded in the plan; mirror parity, the 500-line limit, and the full toolchain pass hold for all changed files. [FR-7, NFR-1, NFR-2]

## Risks & Mitigations

- Reviewers may read the handler conversion as weakening fail-closed behavior. Mitigation: cite H1 (#565) as precedent, add exemption entries whose justification starts with the handler id, and prove fail-closed behavior on the in-scope path in new Pester tests.
- New deny branches may be uncovered. Mitigation: call the decision functions in-process and read per-file coverage from `artifacts/pester/powershell-coverage.xml`.
- Mirror drift between repository and bundle copies. Mitigation: edit both in the same task and run the resource-contract and guard suites over both roots.
- File-size limit on `enforce-completion-consistency.ps1`. Mitigation: single-line try and deny; record line counts; put new tests in new files.
- Test isolation after re-dot-sourcing. Mitigation: reset handler variables in `finally`, restore the clean hook in `AfterAll`, run shuffled suites.
- CI-only behavior (Linux case sensitivity, four Python versions). Mitigation: forward-slash paths, exact case, `posixpath`.
- The Python lexer could prove brittle for PowerShell syntax. Mitigation: the exhaustiveness guard fails loudly on unrecognized forms; the Pester AST resolver (`HookDependencyGraph.Helpers.ps1`) remains a documented fallback.
- Adding manifest entries may break tests that pin `core.json` contents or counts. Mitigation: tree-wide search before editing and update of any pinned literal.
- Rollback: revert the change set; downstream repositories re-run push-down.

## Rollout & Follow-up

- Release/rollout steps: the next harness release carries the `### Fixed` changelog entry; downstream repositories that received 1.1.19 to 1.1.21 re-run the Claude push-down.
- Post-fix monitoring or clean-up tasks: none planned. Housekeeping: delete the duplicate `research/issue-984-research.md` if present, because it does not follow the `<timestamp>-<short-name>-research.md` convention.
- Links: issue #984 (https://github.com/drmoisan/drm-copilot/issues/984); research `research/2026-10-20T12-15-completion-helpers-manifest-research.md`; prior audit `docs/features/completed/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/`.

## Out of Scope

- Changes to `hook-dependency-guard.ps1` (including a `-Name` filter parameter) and to the structural checks S1 to S6.
- Moving the path filter ahead of the dependency decision in the guard (rejected: violates S6).
- Changes to the Codex `enforce-completion-consistency.ps1` (FR-7).
- Hooks whose guarded dependencies are scope dependencies, or that are global, agent-scoped, or command-scoped (for example `validate-bash.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, the Bash command-pattern gates, the SubagentStop `validate-*.ps1` hooks).
- Hooks already handled (`enforce-feature-folder-order.ps1`, H1) or exempted by design (`enforce-mermaid-validation.ps1`).
- A Pester-based closure test (research approach B2) and a TypeScript closure test (B3).
- Changes to language-pack manifests, and to the Codex virtual resource set.
- Production TypeScript or production Python changes.
- Remediation of downstream repositories directly.
- Follow-up issues: all related items are handled in this item.
