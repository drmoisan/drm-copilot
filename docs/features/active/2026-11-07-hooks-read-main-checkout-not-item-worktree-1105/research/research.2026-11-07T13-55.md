# Research: SubagentStop hooks resolve item artifacts against the main checkout (Issue #1105)

- Issue: #1105
- Branch: `bug/hooks-read-main-checkout-1105`
- Work mode: full-bug
- Requirements source: `docs/features/potential/promoted/2026-11-07-hooks-read-main-checkout-not-item-worktree.md`, `issue.md`, and `spec.md` in this feature folder.
- Timestamp source: the UTC time in the file name was read from `timeapi.io` (`Etc/UTC`), because the researcher has no shell clock.

All findings below were read from the item worktree. No line numbers or commit identifiers are cited.

## 1. Current State per Affected Hook

### Registration and process root

- `task-researcher`, `atomic-executor`, `atomic-planner`, `prd-feature`, and `feature-review` stop hooks are registered in agent frontmatter (`.claude/agents/<agent>.md`, `hooks: SubagentStop`), and `atomic-planner`, `prd-feature`, and `feature-review` are also registered in `.claude/settings.json` `SubagentStop`. Every command is `pwsh -NoProfile -File .claude/hooks/<script>.ps1`, a path relative to the hook process working directory.
- For a non-isolated subagent delegated by a session rooted in the main checkout, the hook process directory is the main checkout. For an isolated subagent, the hook runs inside the subagent's own worktree, built from `origin/main` (recorded in the session memory note on hook execution context; consistent with the execution-environment brief `## Hook Execution Context`). Neither process root is the item worktree in the coordinator-delegation case that #1105 describes.
- Every affected hook reads its envelope through `Read-SubagentStopEnvelope` (`.claude/hooks/subagentstop-envelope.ps1`). The helper exposes `IsValid`, `Anomaly`, `Envelope` (the full parsed payload object), `AssistantText`, `StopHookActive`, `AgentType`, and `HookEventName`. Other payload fields are reachable through `Envelope`.

### Per-hook table

| Hook | Dot-sourced / imported helpers | Advertised token(s) | Resolution of the path | Absolute path | Checks skipped or wrong when the path does not resolve |
|---|---|---|---|---|---|
| `.claude/hooks/validate-task-researcher-output.ps1` | `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1`, `premortem-section.ps1` | `research-path` (`Get-ResearchPathFromOutput`) | `Test-ResearchFile` and `Get-ResearchFileContent` call `Test-Path -LiteralPath` / `Get-Content` on the raw value, so a relative value resolves against the process directory | Rejected: `Test-IsUnderResearchRoot` requires the value to start with `docs/features/` or `docs/research/` | Blocks with "no file exists at that location"; `Test-AutomationFeasibilitySection`, `Test-NumericDerivationEvidence`, and `Test-PreMortemSection` never run. Because absolute paths are rejected and relative paths are probed in the main checkout, a researcher writing into an item worktree cannot pass. |
| `.claude/hooks/validate-prd-feature-output.ps1` | `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1` | `spec-path`, `research-path` (`Get-ArtifactPathFromOutput`, line-anchored label) | Inline `Test-Path -LiteralPath` and `Get-Content -LiteralPath` in `Invoke-PrdFeatureOutputValidation`; relative to the process directory | Accepted (no shape check) | Blocks "spec-path is required and must exist"; `Test-SpecNumericCriterion` and `Test-NumericDerivationEvidence` skipped. |
| `.claude/hooks/validate-required-artifact-output.ps1` (registered for `prd-feature` with `spec-path|^docs/features/active/.+/spec\.md$|...`; also `epic-review`, `status-updater`, `staged-review`) | `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1` | per `-RequiredArtifact` spec (`Get-ArtifactPathFromOutput`) | `Test-ArtifactFile` (`Test-Path -LiteralPath`), relative to the process directory | Rejected for `prd-feature` by the spec regex anchored at `^docs/` | Blocks "no file exists at that location". With both prd-feature hooks registered, a relative path fails existence here and an absolute path fails the regex here, so an item-worktree spec cannot pass both hooks. |
| `.claude/hooks/validate-planner-output.ps1` | `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1`, `premortem-section.ps1` | `plan-path` (`Get-PlanPathFromOutput`) | `Get-PlanFileContent` (`Test-Path` / `Get-Content`), relative to the process directory | Accepted (no shape check) | Relative path: blocks "no file exists"; `Get-PlanStructureValidationReport`, `Test-PreMortemSection`, `Get-PlannerInternalReviewValidation` skipped. An absolute path runs every check, which is the route #1096 relied on. |
| `.claude/hooks/validate-executor-output.ps1` | `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1` | `plan-path`; `preflight-fix-record` (regex inside `Get-PreflightRunBlockDecision`) | `Get-PlanFileContent` and `Test-PreflightFixRecord` (`Test-Path`), relative to the process directory | `plan-path` accepted; `preflight-fix-record` rejected (normalized value must start with `docs/features/`) | Plan not found: blocks before `Test-IsPreflightRun` and all completion checks. Fix record not found: repairable block "requires a `preflight-fix-record: <path>` line naming an existing record under docs/features/" (#1034). |
| `.claude/hooks/validate-feature-review-coverage.ps1` (the review coverage hook) | `hook-dependency-guard.ps1`, `feature-review-coverage-thresholds.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1`, `subagentstop-envelope.ps1` | `policy-audit-path`, `code-review-path`, `feature-audit-path`, optional `remediation-inputs-path` (`Get-ReviewArtifactPathFromOutput`) | `Get-ArtifactFileContent` (`validate-feature-review-coverage-metrics.ps1`), relative to the process directory | Rejected: `Get-ReviewArtifactInfo` requires `^docs/features/active/...` | Missing artifacts block (#1031) and the coverage stage never runs. |

### The review coverage hook in detail

`Invoke-FeatureReviewCoverageValidation` in `.claude/hooks/validate-feature-review-coverage.ps1`, after the artifact checks:

- Reads `artifacts/pr_context.summary.txt` through `Get-ArtifactFileContent` and derives languages with `Get-ChangedLanguageSet` (`validate-feature-review-coverage-rules.ps1`; `.ts/.tsx`, `.py`, `.ps1/.psm1`, `.cs`). An absent summary yields an empty set and the hook allows with no coverage check, so a missing summary in the process directory silently skips the whole coverage stage.
- Reads the root `CLAUDE.md` through `Get-FeatureReviewClaudeMdText` (path `CLAUDE.md`, process-relative) for `Get-FeatureReviewCoverageThreshold`.
- Per language, `Get-LanguageRepoCoverage` and `Get-LanguageBranchCoverage` (`validate-feature-review-coverage-metrics.ps1`) read fixed process-relative paths: TypeScript `coverage/lcov.info` (LCOV, `Get-LcovRepoCoverage` / `Get-LcovBranchCoverage`), Python `artifacts/python/lcov.info` (LCOV), PowerShell `artifacts/pester/powershell-coverage.xml` (JaCoCo XML, `Get-JacocoRepoCoverage` / `Get-JacocoBranchCoverage`), C# `artifacts/csharp/coverage.xml` (JaCoCo).
- There is no freshness check of any kind: no mtime, no head comparison, no metadata read. An absent report returns `$null`, and `Test-LanguageCoverageRow` then skips both floor checks. A present report from any branch is used as-is; this is how the main checkout's stale 12.33% PowerShell report blocked every #1097 review.
- Pytest and Jest outputs are read only through the LCOV paths above; no JUnit or JSON report is read.

### Codex twin and bundle mirrors

- `.codex/hooks/` has no SubagentStop twin for the researcher, prd-feature, planner, executor, or required-artifact hooks. The only twin is `.codex/hooks/validate-feature-review-coverage.ps1`, registered in `.codex/config.toml` as `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/validate-feature-review-coverage.ps1"`. Its `Get-RepoRoot` returns the checkout that holds the script (`$PSScriptRoot` two levels up), it selects the newest `policy-audit.*.md` under `docs/features/active/**` by `LastWriteTime` (`Get-LatestPolicyAudit`), and it reads the same four coverage paths joined to that root, with no freshness check and the line floor only.
- Byte-identical bundle mirrors exist for every affected Claude file under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and the Codex twin under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. All affected Claude hooks and `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` are listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.

## 2. Identity Sources in the SubagentStop Payload

Observed top-level keys (`docs/features/archive/subagentstop-envelope-core-897/evidence/other/subagentstop-live-differential.2026-10-11T12-01.md`): `session_id`, `transcript_path`, `cwd`, `prompt_id`, `permission_mode`, `agent_id`, `agent_type`, `effort`, `hook_event_name`, `stop_hook_active`, `agent_transcript_path`, `last_assistant_message`, `background_tasks`, `session_crons`.

| Source | Identifies the item worktree? | Existing parser |
|---|---|---|
| `cwd` | No. It is the delegating session's directory for a coordinator delegation; `validate-orchestrator-output-resolution.ps1` states "The payload cwd is never used as a target selector". | none (by design) |
| `transcript_path` | No; it is the parent session transcript. | none |
| `agent_transcript_path` | Indirectly: its first `user` entry is the delegation prompt. | `Get-TranscriptPathFromEnvelope`, `Read-TranscriptHead` (50-line file seam), `Get-TranscriptFirstUserText`, all in `.claude/hooks/validate-executor-output.ps1`, used by `Test-IsPreflightRun` (issue #964) |
| Delegation prompt `branch:` label and `Canonical issue number for this feature is <N>.` line | Yes. All five agents are in `Get-ModelRoutingGatedAgent` (`.claude/hooks/enforce-model-routing-receipt.ps1`), whose PreToolUse gate denies a gated delegation whose prompt does not resolve to a worktree (`Get-ModelRoutingTargetCheckpointResolution`, `TARGET_WORKTREE_NOT_DERIVABLE` / `TARGET_WORKTREE_AMBIGUOUS`). Any delegation that reaches SubagentStop therefore carried resolvable identity. | `Resolve-HookTargetWorktree` `DelegationPrompt` source (same regexes as the gates) |
| Absolute paths in `last_assistant_message` | Yes, when the agent reports one. | `Resolve-HookTargetWorktree` `FilePath` source (nearest enclosing registered worktree) |

Existing resolvers and probes reviewed:

- `Resolve-HookTargetWorktree` (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`; Codex twin `.codex/hooks/hook-target-worktree.ps1`): precedence `FilePath` > `CommandOperand` > `DelegationIdentity` > `SessionRoot`; one `WorktreeListInvoker` call at most; relative paths map to the session root without listing; returns `WorktreeRoot`, `Source`, `Ambiguous`, `ReasonCode`, `Detail`, `Candidates`. Helpers `Get-HookTargetWorktreeRelativePath`, `ConvertTo-HookTargetWorktreeNormalizedPath`, `Get-HookTargetWorktreeKey`. Used by both batch-budget hooks (with a `WorktreeListInvoker` seam), the preimplementation gate (`enforce-orchestration-preimplementation-gate-epic-scope.ps1`, seam `Invoke-OrchestrationGateWorktreeList`), and the PR authoring gate (`Resolve-PrAuthorWorktreeTarget` path in `enforce-pr-author-skill-helpers.ps1`, `-CommandBranch`).
- `Resolve-WorktreeItemTarget` (`WorktreeItemResolution.psm1`): the model-routing and prd-before-planner gates' resolver. It is a second resolver; the recommendation does not add calls to it.
- Issue-adoption probe `Get-OrchestratorOutputFeatureFolderDecision` (`.claude/hooks/validate-orchestrator-output-feature-folder.ps1`): reads the run worktree with `git -C <WorktreeRoot> cat-file -t HEAD:<feature-folder>` through `Invoke-FeatureFolderGitExe` with a `GitInvoker` scriptblock parameter; never throws; fails closed. Its worktree root comes from `Resolve-OrchestratorOutputCheckpointPath`, which for `orchestrator-state` resolves the session worktree.
- `Resolve-OrchestratorOutputRunbookPath` (`validate-orchestrator-output-resolution.ps1`): the precedent for placing a repository-relative path beneath a resolved root (rooted values pass through, `./` stripped, joined with forward slashes).

### Recommended resolution approach (one approach)

Add one shared, dot-sourced SubagentStop helper (proposed name `.claude/hooks/subagentstop-target-worktree.ps1`) that the five hooks load under the guarded pattern. It imports `HookTargetWorktree.psm1` (already in `core.json`) and adds no resolver of its own:

1. `Resolve-SubagentStopTargetWorktree -Envelope -AdvertisedPath -SessionRoot [-ReadTranscriptHead] [-WorktreeListInvoker]`:
   - If any advertised path is absolute, call `Resolve-HookTargetWorktree -FilePath`.
   - Otherwise read the delegation prompt from `agent_transcript_path` (moving `Get-TranscriptPathFromEnvelope`, `Read-TranscriptHead`, and `Get-TranscriptFirstUserText` from `validate-executor-output.ps1` into the helper, so the executor keeps using them) and call `Resolve-HookTargetWorktree -DelegationPrompt`.
   - With neither, the resolver returns `SessionRoot` without listing worktrees.
   - `SessionRoot` is `(Get-Location).Path`, matching the other hooks.
2. `Resolve-SubagentStopArtifactPath -Path -WorktreeRoot -SessionRoot`: when the resolved root equals the session root (ordinal-ignore-case after normalization) or is `$null`, return the advertised value unchanged; otherwise join the repository-relative value beneath the resolved root (the `Resolve-OrchestratorOutputRunbookPath` rule). An absolute advertised path inside the resolved root is converted to its relative form with `Get-HookTargetWorktreeRelativePath` before the shape checks (`Test-IsUnderResearchRoot`, `Test-IsValidResearchFileName`, `Get-ReviewArtifactInfo`, the required-artifact regex, the `docs/features/` fix-record rule), so the existing repository-relative contracts keep governing shape.

Rules:

| Case | Rule |
|---|---|
| Path exists only in the item worktree | The resolved item root is probed; the file is found and every deeper check runs on the item's content. |
| Path exists only in the main checkout | The item root is probed; the file is not found; the existing repairable "no file exists" block is returned, with the probed absolute location and the resolver `Source` appended. The main checkout is never consulted as a fallback. |
| Path exists in both | Only the item worktree copy is read. |
| No derivable worktree (no transcript, unreadable transcript, prompt without identity, resolver `Source` = `SessionRoot`) | Unchanged current behavior: the value is probed relative to the session root, so a session whose work is in the main checkout behaves as today and existing relative-path tests keep their exact `ParameterFilter` values. |
| Resolver returns `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` | Fall back to the session root (unchanged behavior), and append the reason code and `Detail` to any block message. See Open Questions for the fail-closed alternative. |

Rejected alternatives: (a) teaching each hook to accept absolute paths only: the researcher, required-artifact, executor fix-record, and review rules would all need separate absolute-path handling, and a relative return would still be probed in the main checkout; (b) a new hook-specific resolver over `cwd` or `Resolve-WorktreeItemTarget`: `cwd` does not identify the item, and a second resolver duplicates `Resolve-HookTargetWorktree`; (c) falling back to the main checkout when the item root lacks the file: this reintroduces the stale-read defect.

## 3. Coverage Freshness

- Root: the coverage hook resolves the item root once (Section 2) and passes it to the readers. `Get-ArtifactFileContent`, `Get-FeatureReviewClaudeMdText`, the PR context summary read, and the four language report paths take an optional root; with no root (session-root case) they keep today's process-relative paths, which keeps `validate-feature-review-coverage.Coverage.Tests.ps1` `language dispatchers` and the E4 artifact-map tests unchanged.
- Absence: when a changed language's report is absent beneath the item root, block with a message naming the language, the expected repository-relative report path, and the item root, instead of today's silent skip. Same rule for an absent `artifacts/pr_context.summary.txt` beneath an item root (today it disables the coverage stage).
- Staleness reference: the committer time of the newest commit on the item `HEAD` that touches files of that language, `git -C <item root> log -1 --format=%ct HEAD -- <language pathspecs>` (for PowerShell `*.ps1`, `*.psm1`, `*.psd1`; Python `*.py`; TypeScript `*.ts`, `*.tsx`; C# `*.cs`). Comparing against the bare `HEAD` commit time is rejected: executors and reviewers commit evidence and docs after the coverage run, so a bare-`HEAD` comparison would mark nearly every valid report stale. A report whose `LastWriteTimeUtc` is earlier than the reference blocks with a message stating both times. A `git` failure (exit non-zero, no output, non-integer) fails closed with its own message. Uncommitted source edits are not detected by this rule; see Open Questions.
- Coverage-file metadata: Pester JaCoCo XML (`powershell-coverage.xml`) and LCOV carry no reliable generation timestamp or commit identifier usable here, so file mtime is the only available signal.
- Never read another worktree's file: the reader takes only the resolved item root; there is no candidate list and no fallback.
- Test seams (no temporary files allowed): follow `Get-PrContextSummaryLastWriteUtc` in `.claude/hooks/enforce-pr-author-skill.ps1` (a mockable function returning `LastWriteTimeUtc` or `$null`), `Invoke-FeatureFolderGitExe` with a `GitInvoker` scriptblock parameter (`validate-orchestrator-output-feature-folder.ps1`), the `WorktreeListInvoker` parameter of `Resolve-HookTargetWorktree`, and the `ReadTranscriptHead` parameter of `Test-IsPreflightRun`. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` flags an ampersand-invoked variable that is not a scriptblock parameter, so each invoker must be a declared `[scriptblock]` parameter; `validate-feature-review-coverage.ps1` already documents this constraint on its do-while block.

## 4. Existing Pester Suites and Tests Asserting Current Resolution

All under `tests/scripts/claude-hooks/` unless named.

| Suite | Current-resolution assertions | Disposition under the recommendation |
|---|---|---|
| `validate-task-researcher-output.Tests.ps1`, `.Coverage.Tests.ps1`, `.PreMortem.Tests.ps1` | `.Coverage.Tests.ps1` mocks `Test-Path` / `Get-Content` with `ParameterFilter { $LiteralPath -eq 'docs/research/...' }` (relative literal); absolute-path rejection by `Test-IsUnderResearchRoot` is asserted in the main suite | Unchanged when no transcript is supplied (session-root case). New cases: item-only, main-only, both, absolute-inside-worktree acceptance. |
| `validate-prd-feature-output.Tests.ps1`, `.Coverage.Tests.ps1` | `Mock Test-Path` / `Get-Content` with `$LiteralPath -eq 'synthetic/spec.md'`, `'numeric.md'` | Unchanged in the session-root case; inline `Test-Path` calls should move behind a named seam so new tests do not mock `Test-Path` globally. |
| `validate-required-artifact-output.Tests.ps1`, `.Envelope.Tests.ps1`, `.Reentry.Tests.ps1` | `Mock Test-ArtifactFile { $true }` | Unchanged; new resolution cases added. |
| `validate-planner-output.Tests.ps1`, `.PreMortem.Tests.ps1`, `.Reentry.Tests.ps1`, `.Coverage.Tests.ps1` | `Mock Get-PlanFileContent` without path filters | Unchanged; `validate-planner-output.Tests.ps1` is read by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` for fixture tokens, which must remain. |
| `validate-executor-output.Tests.ps1`, `.Preflight.Tests.ps1`, `.Envelope.Tests.ps1`, `.Reentry.Tests.ps1`, `.LightRemediation.Tests.ps1` | `.Preflight.Tests.ps1` asserts `Test-PreflightFixRecord` is invoked with `$Path -eq 'docs/features/active/foo/evidence/other/preflight-fixes.2026-10-16T23-07.md'` and exercises `ReadTranscriptHead` | Unchanged if the moved transcript functions keep their names and parameters and the mocked prompts carry no `branch:` label (verified: no `branch:` or canonical-issue text in the executor suites). |
| `validate-feature-review-coverage.Tests.ps1`, `.Coverage.Tests.ps1`, `.Issue824.Tests.ps1`, `.ThresholdsGuard.Tests.ps1`, helper `validate-feature-review-coverage.E4.Helpers.ps1` | `language dispatchers` asserts exact relative report paths; E4 maps keyed by `'artifacts/pr_context.summary.txt'` and review paths; `Mock Test-Path` / `Get-Content` around `Get-ArtifactFileContent` | Unchanged with an optional root parameter defaulting to process-relative. New freshness and absence cases go in a new file. |
| `subagentstop-uncaught-error.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` | Dependency-guard rows per hook, uncaught-error tail text | The new helper becomes a guarded dependency of five hooks; rows for its load failure must be added or confirmed. |
| `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, `feature-review-coverage-floor-parity.Tests.ps1`, `feature-review-coverage-narrowing-parity.Tests.ps1` | Claude/Codex parity on `Test-LanguageCoverageRow` and narrowing | Unchanged if `Test-LanguageCoverageRow` and `Get-CoverageNarrowingLine` are not edited. |
| `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` | Resolver contract | Unchanged; the resolver is not edited. |

## 5. Compatibility With In-Flight Items

- Isolated subagents and any live run load `main`'s hook copies, so in-flight items (Epic #1019, #1096, #1097) are affected only after merge.
- Constraints to preserve:
  - Output token spellings and parse rules: `research-path`, `spec-path`, `plan-path`, `preflight-fix-record`, `policy-audit-path`, `code-review-path`, `feature-audit-path`, `remediation-inputs-path`, `PREFLIGHT:` signals, `PLANNER-INTERNAL-REVIEW` record.
  - Repository-relative values remain valid everywhere; absolute values are additionally accepted only when inside a registered worktree.
  - The `-RequiredArtifact` spec strings in agent frontmatter (`prd-feature`, `epic-review`, `status-updater`, `staged-review`) are unchanged.
  - Block message stems that skills and agents quote (`atomic-plan-contract` names the fix-record block; `test_claude_planning_integrity_contracts.py` pins the numeric-evidence and "requires an existing research-path" wording).
  - Repairable/non-repairable classification and `stop_hook_active` handling per hook.
  - No checkpoint field is read or written by these hooks; `artifacts/orchestration/orchestrator-state.json` shape is unaffected.
- Behavior that does change after merge and may block an in-flight review: an absent or stale coverage report beneath an item root now blocks instead of being skipped. A review on a run that never produced `artifacts/pester/powershell-coverage.xml` in its worktree will be asked to produce it.

## 6. Mirror, Bundle, Contract Pins, and File Size

Pins (execution-environment brief `## Contract Tests That Pin Mirrored Files`) that each edit triggers:

- `test_push_down_claude_resource_contracts.py` (byte equality; also lists `validate-planner-output.ps1` in `PLANNER_REVIEW_RESOURCE_PATHS`), `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (the new helper must be in `core.json` because every affected hook is in core), `test_push_down_issue_824_follow_ups.py` (lists `validate-feature-review-coverage.ps1` and its bundle copy; `EXPECTED_LISTED_COPY_COUNT`), `test_claude_planning_integrity_contracts.py` (token pins in the researcher, prd, and planner hooks).
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S1-S6: every new dot-source or `Import-Module` edge in its own guarded single-statement try with `-ErrorAction Stop`, pre-loaded, decision-function-first), `enforcement-hooks-no-python-invocation.Tests.ps1`, `claude-settings.Tests.ps1`.
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` if the Codex twin is edited.
- Execution-environment brief: `## Hook Execution Context` currently states that gates other than the batch-budget, preimplementation, and PR-authoring gates "still use the root that holds the hook script". The SubagentStop resolution added here is a new fact, so the brief must be updated in all six byte-identical copies (`.claude/skills/`, `.agents/skills/`, `.github/skills/`, and their bundle copies).

File sizes (logical lines, read in the item worktree; none of these files is in `config/file-size-baseline.json`):

| File | Lines | Headroom to 800 |
|---|---|---|
| `.claude/hooks/validate-planner-output.ps1` | 454 | 346 |
| `.claude/hooks/validate-executor-output.ps1` | 450 (shrinks when the transcript readers move) | 350 |
| `.claude/hooks/validate-task-researcher-output.ps1` | 310 | 490 |
| `.claude/hooks/validate-feature-review-coverage-rules.ps1` | 229 | 571 |
| `.claude/hooks/validate-feature-review-coverage.ps1` | 205 | 595 |
| `.claude/hooks/validate-required-artifact-output.ps1` | 201 | 599 |
| `.claude/hooks/subagentstop-envelope.ps1` | 192 (not to be edited) | 608 |
| `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | 180 | 620 |
| `.claude/hooks/validate-prd-feature-output.ps1` | 120 | 680 |
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | 391 (not to be edited) | 409 |
| `.codex/hooks/validate-feature-review-coverage.ps1` | 363 | 437 |

Test files near the 500 guidance tier (approximate physical counts): `validate-feature-review-coverage.Coverage.Tests.ps1` about 475, `validate-feature-review-coverage.Tests.ps1` about 447, `validate-task-researcher-output.Tests.ps1` about 410, `validate-planner-output.Tests.ps1` about 402, `validate-executor-output.Preflight.Tests.ps1` about 386. New cases belong in new files (for example `*.TargetWorktree.Tests.ps1` per hook, following `enforce-powershell-batch-budget.TargetWorktree.Tests.ps1`, and a `subagentstop-target-worktree.Tests.ps1` for the helper). Freshness logic belongs in a new sibling (for example `validate-feature-review-coverage-freshness.ps1`) rather than in the metrics file.

## 7. Constraints

- Enforcement hooks invoke no Python (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`); the helper and freshness probe are PowerShell and call only `git` through wrapper seams.
- The route is `large`, so the PowerShell batch budget does not bind; the six brief copies are Markdown.
- Tests create no files: every filesystem, transcript, clock-free mtime, `git`, and worktree-list read goes through a mockable function or scriptblock parameter. Linux hook-suite job: fixture roots use forward-slash `/`-rooted paths, never drive letters.

## Automation Feasibility

No human interaction is required. Every change is a repository edit verifiable by Pester, the pytest contract tests, and the existing CI jobs. The live end-to-end check (a coordinator-delegated item whose stop hooks run on this branch's scripts) needs a non-isolated delegation from a session after merge or from the item worktree; it is not required for acceptance because the brief states branch hook behavior is proven by Pester suites.

## Pre-Mortem

- Review checklists: a reviewer may flag that absolute paths are newly accepted by the researcher, required-artifact, executor fix-record, and review rules. Mitigation: the plan states that absolute values are converted to the repository-relative form inside the resolved worktree before the unchanged shape rules run, and that a path inside no registered worktree is still rejected.
- Coverage: the new helper and freshness sibling are new PowerShell production files that must reach 85% line coverage, and the moved transcript functions must stay covered. Mitigation: dedicated suites drive every rule branch (item-only, main-only, both, not derivable, ambiguous, absent report, stale report, git failure) through seams; read figures from `artifacts/pester/powershell-coverage.xml` of the single gate run.
- Mirror parity: every edited `.claude/hooks/` file and the new helper need byte-identical bundle copies, the helper needs a `core.json` entry, and the execution-environment brief needs all six copies updated. Mitigation: one task per mirror set and the contract tests listed in Section 6 run in the QA phase.
- File size: `validate-planner-output.ps1` (454) and `validate-executor-output.ps1` (450) are the largest edited files; the coverage test files approach 500. Mitigation: hook edits limited to a guarded load plus calls into the shared helper; new tests in new files.
- Test isolation: moving `Read-TranscriptHead` / `Get-TranscriptFirstUserText` and adding `Import-Module` of `HookTargetWorktree.psm1` into five hooks can leak module or function state between suites in one shard. Mitigation: import with `-Force`, no script-scope state in the helper, mocks scoped per `It`, and the parallel `Invoke-PoshQCParallelTest` gate.
- CI-only behavior: the Linux hook-suite job is case-sensitive and has no drive letters; a test that calls the default `WorktreeListInvoker` or `git` would read the runner's real worktrees. Mitigation: `/`-rooted forward-slash fixtures, injected invokers in every test, and no test reading gitignored `artifacts/`.
- Evidence: fail-before evidence for "path only in item worktree" and "stale coverage in main checkout" must exist without creating files. Mitigation: record fail-before runs of the new seam-driven tests against the unmodified hooks under `<FEATURE>/evidence/regression-testing/`, with `Timestamp`, `Command`, `EXIT_CODE`, and `ExpectedExitCode` where non-zero.

## Recommended Approach

1. Add `.claude/hooks/subagentstop-target-worktree.ps1` (guarded load, imports `HookTargetWorktree.psm1`) with `Resolve-SubagentStopTargetWorktree` and `Resolve-SubagentStopArtifactPath`, and move the transcript readers from `validate-executor-output.ps1` into it.
2. In each of `validate-task-researcher-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1` (plan path and `preflight-fix-record`), and `validate-feature-review-coverage.ps1`, resolve the target root once from the envelope, normalize absolute advertised paths to repository-relative form inside that root, run the unchanged shape rules, and probe the root-joined path through the existing file seams.
3. In the coverage hook, pass the resolved root to the PR context summary, `CLAUDE.md`, and report readers; add a freshness sibling that blocks on an absent report or a report older than the newest commit touching that language, through `LastWriteTimeUtc` and `git -C <root> log` seams; never read outside the resolved root.
4. Keep the session-root case byte-for-byte equivalent so existing suites stay green; add `*.TargetWorktree.Tests.ps1` suites.
5. Update bundle mirrors, `core.json`, and the six execution-environment brief copies; leave the Codex twin unchanged (it resolves through `git rev-parse --show-toplevel` of its session and has no researcher, planner, or executor twins), and record that decision.

## Open Questions

- On `TARGET_WORKTREE_AMBIGUOUS` or `TARGET_WORKTREE_NOT_DERIVABLE`, should the hooks fall back to the session root (recommended for compatibility) or block? Blocking is stricter but can trap a delegation whose prompt mentions a second `branch:` label in prose.
- Should an absent coverage report beneath an item root be repairable (the reviewer runs the coverage gate in the item worktree) or non-repairable (report and stop)? The recommendation treats it as repairable.
- Should the freshness rule also treat uncommitted source edits of the language (newer `LastWriteTimeUtc` than the report) as stale? This needs a `git status` seam and adds scope.
- Should the freshness rule apply when the resolved root is the session root? The issue asks for unchanged behavior for main-checkout sessions in path resolution; applying freshness there would change review outcomes in those sessions.
- Should the Codex twin `.codex/hooks/validate-feature-review-coverage.ps1` receive the freshness rule and stop selecting the newest policy audit across all active feature folders by `LastWriteTime`? That selection can read another item's audit; it is a related defect outside the stated scope.
