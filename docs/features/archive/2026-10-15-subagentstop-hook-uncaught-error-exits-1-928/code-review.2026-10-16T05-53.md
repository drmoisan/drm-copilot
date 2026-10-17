# Code Review — Issue #928 (SubagentStop validator uncaught error exits 1), re-audit after remediation cycle 1

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base)
**Head reviewed:** `b222a6baf6dbe42f86a352938a3e8518ca1fedc0`
**Scope:** full branch diff against `origin/main`, not only the remediation cycle.
**Files reviewed:** eight validators under `.claude/hooks/` (discovery-artifact-gate, executor, orchestrator, planner, pr-author, prd-feature, required-artifact, task-researcher), `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md`, the new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, three edited test files, all bundle mirrors, and the feature documents.

## Total Blocking Findings: 1

CR-B1 is the coverage verdict carried from the policy audit (PA-B1) and is classified `awaiting_ci`. No code defect was found that blocks the change. Remediation cycle 1 introduced no new defect.

## Executive Summary

The production change is unchanged since the prior review: a two-line tail edit in each of eight validators that wraps the validation call in `try { ... }` and calls `Exit-SubagentStopBlock` in the `catch` with the validator's S1 prefix, `validator error:`, the first line of the exception message, `the gate fails closed.`, and the report-and-halt line. Remediation cycle 1 changed only the test suite, the helper's comment-help wrapping, and one paragraph of the architecture document; no validator changed (`validators-unchanged-cycle1.2026-10-16T05-42.md`, confirmed by the unchanged mirror hashes). The four targeted prior findings (CR-N1 to CR-N4) are resolved; CR-N5 is accepted as a design choice; CR-N6 is resolved. Five new non-blocking findings are recorded, all of Info severity.

## Prior Findings Verification

| Prior finding | Status | Verification by this review |
|---|---|---|
| CR-N1 (statement-terminating error class not exercised) | Resolved | `subagentstop-uncaught-error.Tests.ps1:31-34` define `$script:StatementTerminatingRows` for `validate-discovery-artifact-gate.ps1` and `validate-pr-author-output.ps1`. U1-ST (`:117-134`) mocks `Read-SubagentStopEnvelope` with `[ExceptionDispatchInfo]::Capture([InvalidOperationException]::new(...)).Throw()`, a .NET method call, which raises a statement-terminating error rather than the script-terminating `throw` used by U1. The rows assert no escaped exception, exit 2, the ordinal prefix, the injected text, exactly one reader call, and the LASTEXITCODE restore. Both rows pass (`poshqc-test.2026-10-16T05-39.md`). The U2 table (`$script:ValidatorRows`) is unchanged, so U2's set comparison is unaffected. |
| CR-N2 (`$global:LASTEXITCODE` not restored) | Resolved | `:68` saves the value before invocation; `:82` reads the hook exit code; `:91` restores the saved value inside `finally`. Order is correct: the exit code is captured before the restore. Fail-before evidence (`lastexitcode-fail-before.2026-10-16T05-10.md`) shows the restore assertion failing with value 2 before the change. |
| CR-N3 (architecture doc PreToolUse exit-code statement) | Resolved | `docs/engineering/claude-code-architecture.md:237` now states that `validate-bash.ps1` writes a PreToolUse deny decision (`hookSpecificOutput.permissionDecision` = `deny`) to stdout and exits 0, that exit 1 is not used because PreToolUse fails open on it, and that a `hook-dependency-guard.ps1` load failure writes stderr and exits 2. Each statement matches `.claude/hooks/validate-bash.ps1:12-22` (help text), `:437` (guard-load exit 2), and `:443-448` (deny JSON, exit 0). The document has no mirror. |
| CR-N4 (citation line width) | Resolved | Helper lines 12-14 (and the byte-identical mirror) are 80, 97, and 56 characters; test lines 9-11 are 68, 100, and 112 characters. The whitespace-normalized text equals the pre-cycle text (`limited-diff.2026-10-16T05-41.md`), so AC4 and AC9 still hold. See CR2-N2 for a residual cosmetic note. |
| CR-N5 (literal halt sentence in four validators) | Accepted; not a finding | The literal at `validate-discovery-artifact-gate.ps1:253`, `validate-pr-author-output.ps1:129`, `validate-prd-feature-output.ps1:118`, and `validate-task-researcher-output.ps1:290` matches each file's existing convention (none of the four defines `$script:SubagentStopReportAndHaltLine`) and avoids widening the overlap with #929 in the task-researcher file. Recorded as accepted per the orchestrator's decision. |
| CR-N6 (branch behind origin/main) | Resolved | `HEAD..origin/main` is 0 commits at `b222a6ba`. |

## Production Code Review

### Tail wrapper correctness (re-confirmed at `b222a6ba`)

- Catch lines: discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290`. Each prefix equals the `-ReasonPrefix` of the `Get-HookDependencyFailureDecision` call above it.
- `Exit-SubagentStopBlock` takes a mandatory, non-empty `Message`; each composed message always contains the non-empty prefix, so binding cannot fail inside the `catch`.
- No `exit` is inside a `try` body; deliberate validator exits are unaffected.
- `validate-required-artifact-output.ps1`: the argument check stays outside the `try`, as `spec.md:88` requires.
- `validate-feature-review-coverage.ps1` and its mirror are unchanged against the merge base (`git diff --quiet` exit 0, this review).

### Documentation edits

- `claude-code-architecture.md:237` (cycle 1) and `:239` (original delivery) now describe the PreToolUse and SubagentStop exit-code contracts consistently with the hooks.
- `epic-orchestrate/SKILL.md:279-281`, `epic-orchestrator.md:133-135`, and `enforce-epic-wave-barrier.ps1:34-35` (comment-help only) state that the transport and exit-code defect was resolved by epic #904 and issue #928. `translate-claude-to-codex/SKILL.md:285` records exit 2.

### Merge of origin/main (`b222a6ba`)

The merge postdates the last recorded QC pass. The 451 merged paths (433 under `docs/features`, 15 under `tests/scripts/codex-hooks` and `tests/scripts/dev_tools`, 3 TypeScript tests) do not intersect the branch file list or `.claude/hooks`, `.claude/lib`, `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`, `config/poshqc*`, or `.github/workflows`. The hooks that dot-source the envelope helper are still exactly the nine U1 rows, so U2 remains satisfied. The PR-head CI run reruns all suites on the merged head.

## Test Design Review

- `subagentstop-uncaught-error.Tests.ps1` (159 lines) builds both row tables in `BeforeDiscovery`, dot-sources the helper so the mock target exists, registers the #737 baseline seam mocks, and calls the interception probe inside an `It`.
- `Invoke-ValidatorUnderTest` now restores all swapped state: stdin, stderr, the two hook-guard script variables, and `$global:LASTEXITCODE`.
- U1-ST sets `$global:LASTEXITCODE = 0` before the call (`:122`) and asserts it is 0 afterwards (`:133`). This verifies the helper restore, since the hook itself leaves 2.
- The outcome of U1-ST does not depend on the ambient `$ErrorActionPreference` of the Pester run: with the validator's own `try` on the call stack, a statement-terminating error reaches the validator's `catch` under either `Continue` or `Stop`.
- REG-4 and E-RA-10 expect two `Exit-SubagentStopBlock` calls and keep their placement assertions.

## Findings Table

Blocking findings: 1 (CR-B1, awaiting_ci). Non-blocking findings: 5 (all Info).

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking (awaiting_ci) | `artifacts/pester/powershell-coverage.xml` (local) | six changed hooks absent | CR-B1: PowerShell coverage for six changed production files (`validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, `subagentstop-envelope.ps1`) is not in the local report; the repo-wide figure (52.00%) is from a partial-scope run. | Confirm per-file line coverage >= 85% and not below baseline, and repo-wide >= 85%, from the `poshqc / PowerShell QC` artifact on the PR head at S9; then check off AC14 with AC15. | Coverage verification is mandatory for every language with changed files; the evidence is CI-dependent and no defect is indicated (ci-main baseline for the six files is 98.06%-100.00%). | Recomputed by this review from `artifacts/pester/powershell-coverage.xml`: 4 matched files 99.36% (469/472); `evidence/qa-gates/poshqc-coverage.2026-10-16T05-40.md`. |
| Non-blocking (Info) | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | lines 117-134 (U1-ST) | CR2-N1: the U1-ST rows were run only against the fixed validators. The cycle-1 fail-before (`lastexitcode-fail-before.2026-10-16T05-10.md`) failed at the LASTEXITCODE-restore assertion, not at the exit-code or escaped-exception assertions, so the rows' ability to detect a removed `catch` is inferred rather than observed. By inspection, removing the validator `catch` would let the error reach the harness `catch` (`:79-81`), and the "no escaped exception" assertion would fail. | Optional: record a one-off run of U1-ST against the pre-fix validator tails (for example at `6b3a1dabc`) in `evidence/regression-testing/`. | Evidence completeness only; the rows assert the right properties. | Evidence file above; harness structure at `:72-92`. |
| Non-blocking (Info) | `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | lines 9-11 | CR2-N2: the cycle-1 rewrap changed only the citation lines, leaving a 68-character line followed by a 112-character line in a paragraph otherwise wrapped near 100 columns. | Optional: reflow lines 8-14 of the `.DESCRIPTION` block to a uniform width. | Cosmetic consistency of comment-based help; no functional effect. | `awk '{print length}'` by this review. |
| Non-blocking (Info) | `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md` | lines 6-7 | CR2-N3: `Last Updated: 2026-10-15T16-40` and `Version: 0.2` were not updated when cycle 1 edited lines 63, 197, 279, and 289. | Update the header fields when the spec is next edited (for example at the S9 AC14/AC15 check-off). | Document traceability. | `git diff b0849668 HEAD -- spec.md` (four hunks, no header hunk). |
| Non-blocking (Info) | `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/issue.md` | line 5 | CR2-N4: `Status: Promoted -> docs/features/active/subagentstop-hook-uncaught-error-exits-1/` names a folder that does not exist; the feature folder is `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/`. | Optional: correct the status path. The value was written by the promotion tooling, so a tooling follow-up may be the better fix. | Navigational accuracy. | `issue.md:5`; folder listing. |
| Non-blocking (Info, outside item scope) | `.claude/hooks/validate-bash.ps1` | lines 441-443 | CR2-N5: `Read-ClaudeHookRawPayload` and `Invoke-ValidateBashDecision` are called at script top level without a `try`/`catch`, and `Invoke-ValidateBashDecision` (`:407`) contains no handler. An unhandled error there would end `pwsh -File` with exit 1, which PreToolUse treats as non-blocking, the PreToolUse analogue of #928. Identified by inspection; no failing input was constructed. | Do not change in this item (PreToolUse is outside the #928 SubagentStop scope and `spec.md:279` excludes the rest of that area). The orchestrator decides whether to file a follow-up covering PreToolUse hooks. | Same fail-open class as this issue, on a different hook event. | `grep -n "try\|catch"` on `validate-bash.ps1` by this review (handlers only at `:40-47`). |

## Positive Observations

- The cycle-1 changes are confined to the test suite, comment-help wrapping, and one documentation paragraph; no validator was touched, which keeps the #929 overlap unchanged.
- The U1-ST mock uses a .NET method exception, which is the error class the spec identified, rather than another `throw`.
- Fail-before evidence for the LASTEXITCODE restore shows the specific assertion and value.
- Mirror parity holds for all 13 mirrored files at `b222a6ba` (`cmp` by this review).
