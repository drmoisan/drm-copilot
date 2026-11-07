# hooks-read-main-checkout-not-item-worktree (Spec)

- **Issue:** #1105
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07
- **Status:** Approved for planning
- **Version:** 1.0
- **Work Mode:** full-bug
- **Research:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/research/research.2026-11-07T13-55.md`

## Context
Several SubagentStop hooks and the review coverage hook resolve an item's artifacts against the main checkout instead of the item's worktree. As a result they reject correct returns, skip their deeper checks, or read stale data.

Environment:
- OS/version: Windows 11 Pro, PowerShell 7
- Python version: 3.13 (Poetry environment)
- Command/flags used: orchestrator runs that delegate to subagents working in item worktrees under `.claude/worktrees/`
- Data source or fixture: issues #1031, #1034, #1096, and #1097, observed on 2026-11-07

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Correct work is rejected, which costs review and preflight rounds. Checks that should run are skipped without notice. A stale coverage file can block every review, or could pass a review on another branch's figures.

## Repro & Evidence
Steps to Reproduce:
1. Start an orchestrated item in its own worktree, with a feature folder that exists only on the item branch.
2. Let a researcher, `prd-feature`, planner, executor, preflight, or feature-review subagent return a repo-relative artifact path.
3. Observe the stop hook resolve that path from the main checkout.
4. For a review, let the review coverage hook run while the main checkout holds an old `artifacts/pester/powershell-coverage.xml`.

Expected:
Each hook resolves artifact paths and coverage files against the item worktree that produced them, then runs its full checks against the item's own content.

Actual:
- The researcher, `prd-feature`, planner, and executor artifact hooks probe repo-relative paths from the hook process directory (the main checkout), where the item's feature folder does not exist. Their deeper checks did not run, including the planner hook's Pre-Mortem check (#1096).
- The executor stop hook rejected a preflight return because it looked for the preflight fix record in the main checkout. The record was committed on the item branch at `697ddeab8` (#1034).
- A feature-review stop hook rejected a PASS review because the artifacts existed only in the worktree (#1031).
- The review coverage hook read `artifacts/pester/powershell-coverage.xml` in the main checkout, a 2026-11-05 file from another branch at 12.33%, and rejected every #1097 review. The item's measured coverage was 93.96% to 94.01%.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: the reports are in the orchestrator returns for #1096 and #1097 and the review returns for #1031 and #1034.

## Scope & Non-Goals
- In scope:
  - `.claude/hooks/validate-task-researcher-output.ps1` (`research-path`)
  - `.claude/hooks/validate-prd-feature-output.ps1` (`spec-path`, `research-path`)
  - `.claude/hooks/validate-required-artifact-output.ps1` (all registrations; the `-RequiredArtifact` spec strings are unchanged)
  - `.claude/hooks/validate-planner-output.ps1` (`plan-path`)
  - `.claude/hooks/validate-executor-output.ps1` (`plan-path`, `preflight-fix-record`)
  - `.claude/hooks/validate-feature-review-coverage.ps1` and its siblings `validate-feature-review-coverage-metrics.ps1` and `validate-feature-review-coverage-rules.ps1` (review artifact paths, PR context summary, root `CLAUDE.md`, coverage reports)
  - New shared helper `.claude/hooks/subagentstop-target-worktree.ps1` and new freshness sibling `.claude/hooks/validate-feature-review-coverage-freshness.ps1`
  - Bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, the `core.json` pack manifest entries, and every copy of the execution-environment brief (`execution-environment/SKILL.md`, section `## Hook Execution Context`)
- Out of scope / non-goals:
  - The Codex twin `.codex/hooks/validate-feature-review-coverage.ps1` and its bundle copy, including its newest-policy-audit selection.
  - Detection of uncommitted source edits newer than a coverage report.
  - Any change to `Resolve-HookTargetWorktree` (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`), `Resolve-WorktreeItemTarget`, or `.claude/hooks/subagentstop-envelope.ps1`.
  - Freshness checks for a session whose work is in the main checkout.
- Explicitly excluded systems, integrations, or datasets: Python hook implementations (enforcement hooks are PowerShell only); checkpoint files (`artifacts/orchestration/orchestrator-state.json` is neither read nor written by these hooks).

## Root Cause Analysis
Each affected hook calls `Test-Path` / `Get-Content` on the advertised value, so a relative value resolves against the hook process directory. For a coordinator delegation that directory is the main checkout; for an isolated subagent it is a worktree built from `origin/main`. Neither is the item worktree. The researcher, required-artifact, executor fix-record, and review shape rules additionally reject absolute paths, so an agent cannot work around the defect by reporting an absolute path. The coverage hook reads fixed process-relative report paths with no freshness check, and an absent report or PR context summary silently disables the coverage stage. The repository already provides `Resolve-HookTargetWorktree`, which identifies the item worktree from an absolute file path or from the delegation prompt's `branch:` label and canonical-issue line; these hooks do not use it.

## Proposed Fix

### Design summary (what changes where):
1. Add `.claude/hooks/subagentstop-target-worktree.ps1`, dot-sourced by every affected hook under the guarded single-statement pattern. It imports `HookTargetWorktree.psm1` and adds no resolver of its own. It exposes:
   - `Resolve-SubagentStopTargetWorktree -Envelope -AdvertisedPath -SessionRoot [-ReadTranscriptHead] [-WorktreeListInvoker]`: when any advertised path is absolute, call `Resolve-HookTargetWorktree -FilePath` (source `FilePath`); otherwise read the delegation prompt from `agent_transcript_path` and call `Resolve-HookTargetWorktree -DelegationPrompt` (source `DelegationPrompt`); with neither, the resolver returns the session root (source `SessionRoot`). `SessionRoot` is `(Get-Location).Path`.
   - `Resolve-SubagentStopArtifactPath -Path -WorktreeRoot -SessionRoot`: when the resolved root equals the session root (ordinal-ignore-case after normalization) or is `$null`, return the advertised value unchanged; otherwise convert an absolute value inside the resolved root to repository-relative form with `Get-HookTargetWorktreeRelativePath`, and join the relative value beneath the resolved root.
   - `Get-TranscriptPathFromEnvelope`, `Read-TranscriptHead`, and `Get-TranscriptFirstUserText`, moved from `validate-executor-output.ps1` with unchanged names and parameters.
2. Artifact hooks (researcher, prd-feature, required-artifact, planner, executor plan-path and `preflight-fix-record`, feature-review artifacts) resolve the target root once, normalize absolute values to repository-relative form, run the unchanged shape rules, and probe only the root-joined path.
3. The coverage hook passes the resolved root to the PR context summary, root `CLAUDE.md`, and coverage report readers, and calls the freshness sibling when the resolved root is an item worktree other than the session root.

### Boundaries and invariants to preserve:
- Session-root case (resolver source `SessionRoot`, or a resolved root equal to the session root): byte-for-byte current behavior, including probe paths, block messages, and no freshness check.
- Artifact hooks never fall back to the main checkout when the resolved item root lacks the file.
- An absolute advertised path that lies inside no registered worktree is still rejected by the unchanged shape rules.
- Output token spellings and parse rules, block message stems pinned by skills and contract tests, repairable/non-repairable classification, and `stop_hook_active` handling are unchanged.

### Dependencies or blocked work:
- Depends on the existing `Resolve-HookTargetWorktree` contract and on the model-routing PreToolUse gate, which already denies gated delegations whose prompt does not resolve to a worktree.
- In-flight items are affected only after merge, because live runs load `main`'s hook copies.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/hooks/subagentstop-target-worktree.ps1`, `.claude/hooks/validate-feature-review-coverage-freshness.ps1`.
- Edited: `validate-task-researcher-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1` (all under `.claude/hooks/`).
- Mirrors: byte-identical bundle copies of every new and edited hook; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` entries for both new files; every copy of `execution-environment/SKILL.md` under `.claude/skills/`, `.agents/skills/`, `.github/skills/`, and their bundle locations.
- New test files: `tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1`, `<hook>.TargetWorktree.Tests.ps1` per edited artifact hook, `validate-feature-review-coverage.TargetWorktree.Tests.ps1`, `validate-feature-review-coverage-freshness.Tests.ps1`.

#### Functions/classes/CLI commands impacted:
- `Test-ResearchFile`, `Get-ResearchFileContent`, `Test-IsUnderResearchRoot` (researcher); `Invoke-PrdFeatureOutputValidation` (inline `Test-Path` moves behind a named seam); `Test-ArtifactFile` (required-artifact); `Get-PlanFileContent` (planner, executor); `Get-PreflightRunBlockDecision`, `Test-PreflightFixRecord` (executor); `Get-ReviewArtifactInfo`, `Get-ArtifactFileContent`, `Get-FeatureReviewClaudeMdText`, `Get-LanguageRepoCoverage`, `Get-LanguageBranchCoverage`, `Invoke-FeatureReviewCoverageValidation` (coverage). Reader functions take an optional root that defaults to today's process-relative paths.
- `Test-LanguageCoverageRow` and `Get-CoverageNarrowingLine` are not edited (Codex parity tests pin them).

#### Data flow and validation changes:
| Case | Artifact hooks | Coverage hook |
|---|---|---|
| File only in item worktree | Found; every deeper check runs on item content | Report read from item root |
| File only in main checkout | Existing repairable "no file exists" block, with probed absolute location and resolver `Source` appended | Absent-report block (below) |
| File in both | Only the item copy is read | Only the item copy is read |
| Source `SessionRoot` / root equals session root | Unchanged | Unchanged, no freshness check |
| Identity present, `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` | Fall back to session root; append reason code to any block message | Repairable block naming the reason code; session root is not read |

Coverage freshness (resolved root is an item worktree other than the session root):
- Absent PR context summary or absent report for a changed language: repairable block naming the language, the expected repository-relative path, and the item root.
- Stale report: repairable block when the report's `LastWriteTimeUtc` is earlier than the committer time of the newest item `HEAD` commit touching that language's files (`git -C <root> log -1 --format=%ct HEAD -- <pathspecs>`; PowerShell `*.ps1 *.psm1 *.psd1`, Python `*.py`, TypeScript `*.ts *.tsx`, C# `*.cs`). The message states language, expected path, report time, and reference commit time.
- `git` failure (non-zero exit, empty output, non-integer output): fail closed with its own block message.
- Fresh report: existing floor checks run unchanged.

#### Error handling and logging updates:
- New block messages name the probed root, resolver `Source`, and any reason code. No exceptions escape the helper; resolution failures map to the table above.
- The new helper is a guarded dependency of every hook that loads it; its load failure follows the existing dependency-guard path.

#### Rollback/feature-flag considerations (if applicable):
- No flag. Rollback is a revert of the hook, mirror, manifest, and brief edits together.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: SubagentStop envelope from `Read-SubagentStopEnvelope` (`last_assistant_message`, `agent_transcript_path`). Output: unchanged hook decision JSON.
- Repository-relative advertised values remain valid; absolute values are additionally accepted when inside the resolved worktree.

#### Required configuration keys and defaults:
- None. `-RequiredArtifact` spec strings in agent frontmatter and `.claude/settings.json` registrations are unchanged.

#### Backward-compatibility expectations:
- Existing suites that supply no transcript and no absolute path keep their exact `ParameterFilter` values and pass unchanged.

#### Performance constraints (latency/throughput/memory):
- At most one worktree listing per hook invocation (resolver contract), one 50-line transcript head read, and one `git log` per changed language in the coverage hook.

## Assumptions, Constraints, Dependencies
- Assumptions: every delegation that reaches SubagentStop for these agents passed the model-routing gate and therefore carries resolvable identity; Pester JaCoCo XML and LCOV carry no usable generation timestamp, so file mtime is the freshness signal.
- Constraints: enforcement hooks use PowerShell only and invoke no Python; tests create no files, and every file, git, transcript, mtime, and worktree-list read goes through a mockable function or a declared `[scriptblock]` parameter; Linux CI fixtures use `/`-rooted forward-slash paths; no edited file exceeds 800 logical lines.
- External dependencies: `git` on PATH for the coverage freshness probe.

## Data / API / Config Impact
- User-facing or API changes: absolute artifact paths inside the item worktree are accepted; the coverage hook now blocks on absent or stale reports in item worktrees.
- Data or migration considerations: none.
- Logging/telemetry updates: block messages carry resolver source, probed root, and reason codes.
- Compatibility notes: a review on an item worktree that never produced its coverage report will be asked to produce it.

## Test Strategy
- Regression tests: one `*.TargetWorktree.Tests.ps1` per edited hook plus a helper suite and a freshness suite, all seam-driven. Fail-before runs of the new suites against the unmodified hooks are recorded under `<FEATURE>/evidence/regression-testing/`.
- Edge cases: absolute path outside every worktree; transcript missing or unreadable; prompt without identity; ambiguous identity; `git` failure modes.
- Coverage: new files at least 85% line coverage; no drop on changed lines; read from the single gate run's `artifacts/pester/powershell-coverage.xml` in the item worktree.
- Toolchain: `Invoke-Formatter`, PSScriptAnalyzer, Pester through `Invoke-PoshQCParallelTest`, `pytest -n auto` for contract tests.
- Manual validation: none required; the execution-environment brief states branch hook behavior is proven by Pester suites.

## Acceptance Criteria
- [ ] `subagentstop-target-worktree.Tests.ps1` verifies `Resolve-SubagentStopTargetWorktree` returns source `FilePath` for an absolute advertised path, `DelegationPrompt` for a relative path with a transcript prompt carrying `branch:` and canonical-issue identity, and `SessionRoot` when neither is available, using injected `ReadTranscriptHead` and `WorktreeListInvoker` seams.
- [ ] `subagentstop-target-worktree.Tests.ps1` verifies `Resolve-SubagentStopArtifactPath` returns the value unchanged for the session root or a `$null` root, joins a relative value beneath an item root, converts an absolute value inside the item root to repository-relative form, and leaves an absolute value outside every worktree for the unchanged shape rules to reject.
- [ ] `validate-task-researcher-output.TargetWorktree.Tests.ps1` verifies, for `research-path`: item-only is found and the automation-feasibility, numeric-evidence, and Pre-Mortem checks run; main-only blocks with the probed item location and resolver source and does not read the main checkout; both reads only the item copy; not-derivable and ambiguous fall back to the session root with the reason code in the block message.
- [ ] `validate-prd-feature-output.TargetWorktree.Tests.ps1` verifies the same item-only, main-only, both, and not-derivable/ambiguous cases for `spec-path` and `research-path`, including that the numeric-criterion check runs in the item-only case.
- [ ] `validate-required-artifact-output.TargetWorktree.Tests.ps1` verifies the same cases for the `prd-feature` `spec-path` registration, and that an absolute path inside the item worktree passes the unchanged `^docs/features/active/.+/spec\.md$` rule after conversion.
- [ ] `validate-planner-output.TargetWorktree.Tests.ps1` verifies the same cases for `plan-path`, including that the plan-structure, Pre-Mortem, and planner-internal-review checks run in the item-only case.
- [ ] `validate-executor-output.TargetWorktree.Tests.ps1` verifies the same cases for `plan-path` and for `preflight-fix-record`, including that a fix record present only on the item branch allows the preflight return (#1034).
- [ ] `validate-feature-review-coverage.TargetWorktree.Tests.ps1` verifies the same cases for `policy-audit-path`, `code-review-path`, `feature-audit-path`, and `remediation-inputs-path` (#1031), and that the PR context summary and root `CLAUDE.md` are read only beneath the resolved item root.
- [ ] `validate-feature-review-coverage-freshness.Tests.ps1` verifies, for an item root other than the session root: an absent report for a changed language is a repairable block naming language, expected path, and item root; an absent PR context summary is a repairable block; a report older than the newest language-touching commit is a repairable block stating both times; a report at or after that time passes to the unchanged floor checks; a `git` failure (non-zero exit, empty output, non-integer output) fails closed.
- [ ] `validate-feature-review-coverage.TargetWorktree.Tests.ps1` verifies that a `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` resolution blocks (repairable) with the reason code and reads no coverage report from the session root, and that a stale main-checkout report is never read when the item root is resolved.
- [ ] Session-root behavior is unchanged: every pre-existing suite for the edited hooks (`validate-task-researcher-output*`, `validate-prd-feature-output*`, `validate-required-artifact-output*`, `validate-planner-output*`, `validate-executor-output*`, `validate-feature-review-coverage*`) passes without edits to its `ParameterFilter` values, and `validate-feature-review-coverage-freshness.Tests.ps1` verifies no freshness probe runs when the resolver source is `SessionRoot` or the resolved root equals the session root.
- [ ] `hook-dependency-guard-completeness.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` pass with the new helper and freshness sibling loaded under the guarded pattern and invoking no Python.
- [ ] `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `test_push_down_issue_824_follow_ups.py` pass, confirming byte-identical bundle mirrors and `core.json` entries for both new files.
- [ ] Every copy of `execution-environment/SKILL.md` states in `## Hook Execution Context` that the SubagentStop artifact and coverage hooks resolve the item worktree through `Resolve-HookTargetWorktree`, and the copies are byte-identical, verified by `test_push_down_claude_resource_contracts.py` and the mirror contract tests listed in the brief's `## Contract Tests That Pin Mirrored Files`.
- [ ] Restored test baseline: `Invoke-PoshQCParallelTest` and `pytest -n auto` show no new failures versus the Phase 0 baseline recorded under `<FEATURE>/evidence/baseline/`, changed lines show no coverage drop, and `subagentstop-target-worktree.ps1` and `validate-feature-review-coverage-freshness.ps1` each reach at least 85% line coverage in the gate run's `artifacts/pester/powershell-coverage.xml`.
- [ ] CI-dependent: the CI Required Gate is green on the PR head SHA.

## Risks & Mitigations
- Technical or operational risks: newly accepted absolute paths could be flagged in review; module or function state could leak between suites after moving the transcript readers and adding `Import-Module`; a test that reaches real `git` or the real worktree list would read the CI runner's state; in-flight reviews may newly block on an absent coverage report.
- Mitigations and rollbacks: absolute values are converted to repository-relative form before the unchanged shape rules; `Import-Module -Force`, no script-scope state, per-`It` mocks, and the parallel gate run; injected invokers in every test; the block message names the expected report path so the reviewer can produce it. Rollback is a single revert of hooks, mirrors, manifest, and brief.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; hooks take effect for subsequent runs.
- Post-fix monitoring or clean-up tasks: confirm on the next coordinator-delegated item that stop hooks run their deeper checks; the Codex twin's newest-policy-audit selection is a related defect left out of scope.
- Links: issue #1105; related #1031, #1034, #1096, #1097; research file listed in the header.
