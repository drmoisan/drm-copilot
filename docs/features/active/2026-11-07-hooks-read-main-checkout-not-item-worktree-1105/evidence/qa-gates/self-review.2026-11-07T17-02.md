# Self-Review (issue 1105, remediation cycle 1)

Timestamp: 2026-11-07T17-02
Task: [P3-T5]
Command: walk of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against `git diff --name-status <merge base of origin/main and HEAD> HEAD`, with the cycle's own changes read from the diff since the commit that added `remediation-plan.2026-11-07T15-37.md`
EXIT_CODE: 0
Output Summary:
- 0 FAIL rows.
- Branch diff outside this feature folder: 13 added and 47 modified paths.
- 0 `.py` paths, 0 `.codex/` paths, 0 `.claude/lib/` paths (repository or bundle).
- One function added this cycle: `Get-SubagentStopIdentityPrompt`, a pure reducer. No resolver was added.

Cycle diff (outside this feature folder):

- 7 hooks: the helper and six consumers.
- Their 7 byte-identical bundle copies.
- 28 suites under `tests/scripts/claude-hooks/`.
- 3 suites under `tests/scripts/codex-hooks/`.

## Remediation findings

| Item | Result | Evidence |
|---|---|---|
| F1 Required change 1: first `branch:` label and canonical issue lines only | PASS | `Get-SubagentStopIdentityPrompt` in `.claude/hooks/subagentstop-target-worktree.ps1` uses `Find-WorktreeResolutionBranchSignal` and `Find-WorktreeItemIssueSignal`. Tests: `resolves to the item root from the first branch label when a later label names the base branch`; `returns the first branch label and one line per distinct issue number for a mixed prompt`. |
| F1 Required change 2: checkpoint issue reader for an issue-only prompt | PASS | `Resolve-SubagentStopTargetWorktree` gained `[scriptblock] $CheckpointIssueReader`, defaulting to `Get-WorktreeItemCheckpointIssue` behind a guarded import of `WorktreeItemResolution.psm1`. It is passed only when the reduced identity has no branch signal. `Resolve-HookTargetWorktree`, `Resolve-WorktreeItemTarget`, and `subagentstop-envelope.ps1` are unchanged. |
| F1 Required change 3: coverage hook message | PASS | `Invoke-FeatureReviewCoverageValidation` keeps the `validate-feature-review-coverage:` stem, the reason code, and `the session root is not read`. It now names the first `branch:` label or a recorded canonical issue line. Test `gives a not-derivable message that keeps the stem and reason code and never advises absolute paths`. |
| F1 Required change 4: session-root invariant | PASS | Test `returns the session root and leaves the value unchanged when the first branch label names the session branch`. Test `reports source SessionRoot when the delegation prompt carries no branch label and no canonical issue line` is unchanged. The `..` rejection applies only beneath an item root (test `leaves a value with a parent segment unchanged and unrejected for the session root`). |
| F1 Verification (a): helper cases | PASS | Issue-only prompt with an injected reader resolves to the item root; a reader that records nothing gives `TARGET_WORKTREE_NOT_DERIVABLE`; `branch:` followed by `base branch: main` resolves to the item root. `subagentstop-target-worktree.Tests.ps1`: 40 / 0 in the final gate. |
| F1 Verification (b): coverage-suite cases in a main-checkout session | PASS | `Describe 'validate-feature-review-coverage gate-admitted prompts in a main-checkout session (issue #1105)'`: both shapes return `Ok` true with `stop_hook_active` true and read the session-root artifact paths. |
| F1 Verification (c): artifact-hook case | PASS | `validate-planner-output.TargetWorktree.Tests.ps1` `reads only the item copy when a later label names the base branch`. |
| F1 Verification (d): pre-existing suites without `ParameterFilter` edits | PASS | Rewritten in [P1-T1] and [P1-T3]: only the eight two-branch prompts (as planned) and the additive baseline-mock and probe lines. No `ParameterFilter`, existing mock, or assertion was edited. All pre-existing suites passed in the final gate. |
| F1 Verification (e): bundle byte identity and guard suites | PASS | `cmp` reported no difference for all 7 copies. `hook-dependency-guard-completeness.Tests.ps1` 671 / 0; `hook-dependency-failure.Claude.Tests.ps1` 191 / 0; `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` 486 / 0. Mirror contract modules passed in the pytest gate. |
| F1 Verification (f): format, analyze, one parallel run, helper at or above 85% | PASS | `poshqc-format.2026-11-07T16-52.md` and `poshqc-analyze.2026-11-07T16-52.md`: 0 changed, 0 findings. `pester-parallel.2026-11-07T17-01.md`: ExitCode 0; helper 100.00% (92/92). |
| F2: one transcript read per invocation | PASS | `Get-ExecutorOutputBlockDecision` reads once through `ReadTranscriptHead` and passes a reader over those lines to both consumers. Tests `reads the transcript head once and still classifies the run from the delegation prompt` and `invokes a throwing transcript reader once and treats the run as having no transcript`. |
| F3: `..` segments rejected beneath an item root | PASS | `Resolve-SubagentStopArtifactLocation` returns `Rejected` and `RejectionDetail`. All nine consumer sites block before any probe, and nine tests assert `'..' segment` and zero seam calls. |
| No Python file changed | PASS | 0 `.py` paths in the merge-base diff. |
| No `.claude/lib/` or `.codex/` file changed | PASS | 0 paths under either root in the merge-base diff (repository and bundle). |
| No new resolver | PASS | The only function added this cycle is `Get-SubagentStopIdentityPrompt`, which returns text and resolves nothing. |
| Session-root invariant holds | PASS | See F1 Required change 4. Every pre-existing suite of the six hooks passed in the final gate. |

## Policy audit template

| Item | Result | Evidence |
|---|---|---|
| 1.1 Independence | PASS | A leak from `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` was found and fixed. Its bundle-copy load left a second `WorktreeItemResolution` module in the process; an `AfterAll` now removes the bundle-path modules. Debug-only check: that suite followed by a victim suite went from 26 failures to 0. The final gate passed in 8 shards. The victim-side hardening of `Register-EpicStateBaselineMock` is outside the plan's file set and is reported as a follow-up. |
| 1.1 Isolation | PASS | Each new `It` targets one behavior (one prompt shape, one rejection site, one read count). |
| 1.1 Fast execution | PASS | All new cases use in-memory seams. |
| 1.1 Determinism | PASS | Transcript, worktree list, checkpoint issue, and file reads are injected script blocks or Pester mocks; fixture roots are `/`-rooted. |
| 1.1 Readability | PASS | Descriptive names; Arrange-Act-Assert comments. |
| 1.2 Changed files meet thresholds | PASS | Every hook edited this cycle is 98.33% to 100.00% line coverage (85% threshold; no PowerShell branch gate). |
| 1.2 New code coverage | PASS | Helper 100.00%; 0 uncovered changed executable lines in the seven hooks edited this cycle (`baseline-comparison.2026-11-07T17-01.md`). |
| 1.2 Comprehensive coverage | PASS | The default `CheckpointIssueReader` is covered through a mock of `Get-WorktreeItemCheckpointIssue`. |
| 1.2 Positive, negative, edge, error flows | PASS | Issue-only resolved and not derivable; first-label item and session cases; two issue numbers ambiguous; throwing transcript reader; `..` rejected, unaffected, and session-root cases. |
| 1.2 Concurrency, state transitions | N/A | Single-invocation hooks with no shared state. |
| 1.2.1 Per-language comparison | PASS | `baseline-comparison.2026-11-07T17-01.md`: 0 new failures in either gate. |
| 1.3 Messages, AAA, intent | PASS | Assertions match message stems and seam counts; `-Because` on count assertions. |
| 1.4 External dependencies, mocks, environment | PASS | No test runs git, reads a checkpoint, or creates a file. |
| 1.5 Pre-submission review | PASS | This artifact. |
| 2.1 Objective, plans, documentation | PASS | `remediation-inputs.2026-11-07T15-37.md` and the remediation plan; one commit per task. |
| 2.2 Simplicity, reuse, extensibility, separation | PASS | Reuses the gate's readers and `Get-WorktreeItemCheckpointIssue`; seams are optional parameters with production defaults. |
| 2.3 Cohesion and file size | PASS | Largest edited hook `validate-planner-output.ps1` has 473 lines; helper 349. Largest edited suite `validate-feature-review-coverage.Coverage.Tests.ps1` has 481. `FileSizePolicy.RepoGate.Tests.ps1` 5 / 0. No file is at or above 700 lines. |
| 2.3 No circular dependencies | PASS | The helper imports three lib modules; the lib modules do not load hooks. |
| 2.4 Names, help, comments | PASS | Comment-based help on `Get-SubagentStopIdentityPrompt` and the new parameters; the comments state why. |
| 2.5 Formatting / linting | PASS | 392 files: 0 changed; 0 findings. |
| 2.5 Type checking | N/A | PowerShell only. |
| 2.5 Testing and full loop | PASS | Three Pester gate runs: two runs after a fix, each preceded by a loop restart from [P3-T1]. The final run passed with 0 failures. One pytest run: 16179 passed, 0 failed. |
| 2.6 Summary, design choices, documents, next steps | PASS | The brief's `## Hook Execution Context` #1105 bullet stays accurate (Pre-Mortem `Mirror parity`), so no brief change. The next steps (re-review and CI) are owned by the orchestrator. |
| 3A Python | N/A | No Python change. |
| 3B PowerShell formatting, linting, advanced functions, validation, state, errors, verbs | PASS | `[CmdletBinding()]` and `[OutputType()]` on the new function. No script-scope state. The single transcript read keeps the thrown-read-as-null behavior. Approved verbs only. |
| 3C Bash / 3D JSON | N/A | Not changed. |
| 4A Python tests | N/A | Contract modules passed unchanged. |
| 4B Pester usage, focus, organization, naming, runner | PASS | Gate evidence comes only from `Invoke-PoshQCParallelTest`; focused runs were debugging only. |
| 5-7 Coverage detail, execution metrics, quality checks | PASS | `pester-parallel.2026-11-07T17-01.md` (15759 tests, 515.91 s); `pytest-parallel.2026-11-07T16-50.md` (88.75 s). |
| 8 Gaps and exceptions | PASS | `validate-feature-review-coverage-freshness.ps1` has one uncovered line, the default `GitInvoker`. That file was not edited this cycle, and the line was dispositioned in the prior cycle. No test removed or skipped. |
| 9-10 Summary and verdict | PASS | Compliant on the checks above. AC-16 stays unchecked pending CI. |

## Code review template

| Item | Result | Evidence |
|---|---|---|
| Findings table | PASS | No Blocking or Major finding in the cycle diff walk. |
| PowerShell implementation | PASS | Branch-bearing prompts resolve without a checkpoint read. Issue-only prompts are placed as at the gate. |
| PowerShell API and safety | PASS | `Resolve-SubagentStopArtifactPath` is unchanged. The new `Rejected` keys are additive, so existing callers that read `RelativePath` and `ProbePath` keep working. |
| Error handling | PASS | Rejection blocks are repairable and name the token, the value, and the detail under each hook's existing stem. |
| Test quality | PASS | Each F1 verification item, F2, and F3 has named tests (see the remediation table). |
| Security: secrets, subprocess, input validation, paths | PASS | No secret. No new process; the default checkpoint reader reads one fixed checkpoint path through the lib seam. A `..` segment is rejected before any join beneath an item root. |
| Python, TypeScript, C# audits | N/A | Not in scope. |

## Feature audit template

| Item | Result | Evidence |
|---|---|---|
| Scope and baseline | PASS | Phase 0 baselines under `evidence/baseline/`; cycle policy reads under `evidence/remediation-baseline/`. |
| Acceptance criteria inventory | PASS | `spec.md` holds 16 criteria; this cycle adds none. |
| Acceptance criteria evaluation | PASS | AC-01 to AC-15 were checked in the prior cycle and remain satisfied: all their tests passed in the final gate. AC-16 is CI-dependent. |
| Acceptance criteria check-off | PASS | `spec.md` checkboxes were not changed; AC-16 stays unchecked. |
| AC status summary | PASS | 16 total, 15 checked, 1 remaining (AC-16, pending CI). |
