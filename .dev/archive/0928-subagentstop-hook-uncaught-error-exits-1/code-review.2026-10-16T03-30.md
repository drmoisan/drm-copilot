# Code Review — Issue #928 (SubagentStop validator uncaught error exits 1)

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main`; merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
**Head reviewed:** `20c7a8088093a13f1937a4e75f7ed7f581f76a8b`
**Files reviewed:** eight validators under `.claude/hooks/` (discovery-artifact-gate, executor, orchestrator, planner, pr-author, prd-feature, required-artifact, task-researcher), `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md`, the new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, three edited test files, and all bundle mirrors.

## Total Blocking Findings: 1

CR-B1 is the coverage verdict carried from the policy audit (PA-B1) and is classified `awaiting_ci`. No code defect was found that blocks the change.

## Executive Summary

The production change is a two-line tail edit in each of eight validators: the validation call is wrapped in `try { ... }` and the `catch` calls `Exit-SubagentStopBlock` with the validator's S1 prefix, `validator error:`, the first line of the exception message, `the gate fails closed.`, and the report-and-halt line. The wrapper sits after the three S1 tail statements (and, for the required-artifact validator, after the argument check), and the `if (-not $result.Ok)` and `exit 0` lines remain outside it. This matches the precedent at `validate-feature-review-coverage.ps1:202-203` and the spec design table. The regression suite is well isolated and has fail-before evidence. Six non-blocking findings are listed below; two are test-strength items, one is a stale statement in the same architecture document, and three are maintainability or process items.

## Production Code Review

### Tail wrapper correctness

- All eight catches call `Exit-SubagentStopBlock`, which writes stderr and exits 2 (`subagentstop-envelope.ps1:171-191`). Its `Message` parameter is `[Parameter(Mandatory)][ValidateNotNullOrEmpty()]`; the composed message always contains the non-empty prefix, so binding cannot fail inside the catch.
- `([string]$_.Exception.Message -split "`r?`n")[0]` yields an empty string for a null or empty message, which still produces a non-empty reason. A multi-line message is truncated to its first line as the spec requires.
- `exit` inside the `try` body is not caught by the catch in PowerShell, and no `exit` is placed in the `try` body, so deliberate validator exits are unaffected.
- Prefixes match the S1 `-ReasonPrefix` of each file (verified against the `Get-HookDependencyFailureDecision` line immediately above each `try`).
- The four validators that use a literal halt line (discovery, pr-author, prd-feature, task-researcher) do not define `$script:SubagentStopReportAndHaltLine`; the literal equals the value defined in executor (`:41`), orchestrator (`:66`), planner (`:43`), and required-artifact (`:42`).
- `validate-required-artifact-output.ps1:192-197`: the argument check stays outside the `try`, as the spec requires. Its `Read-SubagentStopEnvelope` call is outside any handler, but the helper contract states that the function never throws and never exits (`subagentstop-envelope.ps1:63`), so no realistic exit-1 path remains there.
- For `validate-pr-author-output.ps1` and `validate-discovery-artifact-gate.ps1`, `$ErrorActionPreference` is the default. A statement-terminating error raised within the `try` call stack is routed to the enclosing `catch` under documented PowerShell semantics; the test suite does not exercise that error class (CR-N1).

### Documentation edits

- `docs/engineering/claude-code-architecture.md:239` now states that SubagentStop validators block with exit 2 and a stderr reason, including on an unhandled error, and that exit 1 does not block. The statement that every validator reads the envelope from stdin is consistent with the nine validators in the family.
- `epic-orchestrate/SKILL.md:279-281`, `epic-orchestrator.md:133-135`, and `enforce-epic-wave-barrier.ps1:34-35` replace the "likely to depend on the transport defect" sentence with a statement that the defect was resolved by epic #904 and issue #928. The wave-barrier change is inside the comment-help block only.
- `translate-claude-to-codex/SKILL.md:285` changes the SubagentStop row to exit 2.
- The 897 citations name the archive path and the interim active path.

## Test Design Review

- `subagentstop-uncaught-error.Tests.ps1` builds the row table in `BeforeDiscovery`, dot-sources the helper so the mock target exists, registers the #737 baseline seam mocks, and calls the interception probe from inside an `It`.
- `Invoke-ValidatorUnderTest` swaps stdin and stderr for in-memory objects and restores them and the two hook-guard script variables in `finally`. It captures any escaped exception so the "no propagated exception" assertion is meaningful.
- U1 asserts no thrown exception, exit 2, an ordinal prefix match, the injected error text, and exactly one reader call. Fail-before evidence shows the eight AC1 rows failing on the escaped `RuntimeException` and the feature-review row passing.
- U2 parses every `.claude/hooks/*.ps1` and compares the set of hooks whose AST contains a single-statement `try` around the exact helper dot-source text with the table. This keeps the table complete if a new validator adopts the helper.
- REG-4 and E-RA-10 were updated to expect two `Exit-SubagentStopBlock` calls. REG-4 still asserts that both calls are outside any function and that the S1 `$dependencyDecision` assignment precedes the first call; E-RA-10 still asserts that neither call sits inside the argument-check block. The assertions were adjusted, not weakened in intent.

## Findings Table

Blocking findings: 1 (CR-B1, awaiting_ci). Non-blocking findings: 6.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking (awaiting_ci) | `artifacts/pester/powershell-coverage.xml` (local) | six changed hooks absent | CR-B1: PowerShell coverage for six changed production files (`validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, `subagentstop-envelope.ps1`) is not in the local report; repo-wide figure is from a partial-scope run. | Confirm per-file line coverage >= 85% and not below baseline, and repo-wide >= 85%, from the `poshqc / PowerShell QC` artifact on the PR head at S9; then check off AC14 with AC15. | Coverage verification is mandatory for every language with changed files; the evidence is CI-dependent and no defect is indicated. | `evidence/qa-gates/poshqc-coverage.2026-10-16T03-15.md`; recomputation by this review (52.00% repo, partial scope; 4 matched files 99.36%). |
| Non-blocking (Medium) | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | lines 393-408 (U1) | CR-N1: U1 injects only a script-terminating `throw`. The spec identifies statement-terminating errors under the default `$ErrorActionPreference` in `validate-discovery-artifact-gate.ps1` and `validate-pr-author-output.ps1` as inferred, not observed (`spec.md:63`), and lists the thrown mock as the mitigation (`spec.md:289`). A `throw` does not exercise that error class. | Add U1 variant rows for the discovery and pr-author validators whose mock raises a statement-terminating error (for example a .NET method exception such as `[int]::Parse('not-a-number')`), asserting exit 2, the prefix, and the error text. | Converts the inferred behavior into verified behavior for the two validators where it matters. | `spec.md:63`, `spec.md:289`; U1 mock body at line 395. |
| Non-blocking (Low) | `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1` | line 369 | CR-N2: `Invoke-ValidatorUnderTest` sets `$global:LASTEXITCODE = 0` and leaves the hook's exit code in `$global:LASTEXITCODE` after return; the prior value is not saved or restored, unlike the other swapped state. | Save `$global:LASTEXITCODE` before the call and restore it in `finally` after reading the exit code. | Keeps the helper's state restoration complete and avoids leaking exit code 2 into later tests in the same run. | Test file lines 359-385. |
| Non-blocking (Low) | `docs/engineering/claude-code-architecture.md` | line 237 | CR-N3: the PreToolUse paragraph states that `validate-bash.ps1` "exits with code 1" to reject a command. `validate-bash.ps1:19-22` states that the deny path emits a `permissionDecision: deny` JSON object and that exit 1 is intentionally not used because PreToolUse fail-opens on it. `spec.md:279` placed this line out of scope. | Correct the sentence to describe the JSON `permissionDecision: deny` output (and exit 2 for a dependency load failure, `validate-bash.ps1:437`). | Same document and same exit-code accuracy theme as AC10; the current text describes a non-blocking exit code as a block. | `validate-bash.ps1:19-22`, `:437-448`. |
| Non-blocking (Low) | `.claude/hooks/subagentstop-envelope.ps1` and mirror; `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | line 12; line 9 | CR-N4: the citation edits extend the comment-help lines to 182 and 178 characters inside paragraphs otherwise wrapped near 100 columns. | Re-wrap the two citation sentences to the paragraph width; keep the `.claude` file and its bundle mirror byte-identical. | Readability and consistency of comment-based help; no functional effect. | `awk 'length > 140'` by this review. |
| Non-blocking (Info) | `validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1` | lines 253, 129, 118, 290 | CR-N5: the report-and-halt sentence is a string literal in four files and a script variable in four others; the unchanged `validate-feature-review-coverage.ps1:203` uses different halt wording. A future wording change must be made in up to nine places. | Optional: define `$script:SubagentStopReportAndHaltLine` in the four literal-using validators and reference it in the catch. Leave `validate-feature-review-coverage.ps1` unchanged in this item (AC3). Coordinate with #929, which edits another hunk of `validate-task-researcher-output.ps1`. | Reduces drift risk; the spec chose literals, so this is a maintainability note rather than a defect. | `spec.md:82-91`; grep of `SubagentStopReportAndHaltLine *=`. |
| Non-blocking (Info) | branch | merge base `adb9aa5f` | CR-N6: `origin/main` advanced to `97559c3e` (PR #943). No changed path overlaps this branch. | Update the branch from `main` before opening the PR. | Repository practice; keeps the PR diff and CI current. | `git diff --name-only adb9aa5f origin/main`. |

## Positive Observations

- The fix follows an in-repo precedent exactly and keeps the S1 structural shape intact; the S1 completeness suite (598 tests) passes.
- Fail-before and fail-after evidence is specific: per-row PASS/FAIL lines and the escaped exception type.
- The U2 completeness row guards against a future validator adopting the helper without a matching row.
- Mirror parity was verified by byte comparison and the bundle-parity pytest suite.
- Excluded paths (`.codex/`, Codex bundle, `settings.json`, agent frontmatter, `core.json`) are untouched.
