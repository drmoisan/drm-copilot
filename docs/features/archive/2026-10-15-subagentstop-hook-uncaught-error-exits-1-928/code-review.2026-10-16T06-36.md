# Code Review — Issue #928 (SubagentStop validator uncaught error exits 1), re-audit after remediation cycle 2

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `5bc97774b8322e57abb94dfac3cd0a000a136c5b` (merge base; 0 commits behind)
**Head reviewed:** `2f6b960051a92c85a3fcc7ea8c85dd89fea79014`
**Scope:** full branch diff against `origin/main` (115 files), not only remediation cycle 2.
**Files reviewed:** eight validators under `.claude/hooks/` (discovery-artifact-gate, executor, orchestrator, planner, pr-author, prd-feature, required-artifact, task-researcher), `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md`, the new suite `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, three edited test files, all bundle mirrors, and the feature documents (including the cycle-2 edits to `spec.md` and `issue.md`).

## Total Blocking Findings: 1

CR-B1 is the coverage verdict carried from the policy audit (PA-B1) and is classified `awaiting_ci`. No code defect blocks the change. Remediation cycle 2 introduced no defect.

## Executive Summary

The production change is unchanged since the two prior reviews: a two-line tail edit in each of eight validators that wraps the validation call in `try { ... }` and calls `Exit-SubagentStopBlock` in the `catch` with the validator's S1 prefix, `validator error:`, the first line of the exception message, `the gate fails closed.`, and the report-and-halt line. Remediation cycle 2 (`2f6b9600`) changed three lines of Markdown: `spec.md` lines 6 and 8 and `issue.md` line 5. `git diff --name-status b222a6baf HEAD` lists only files under the feature folder (13 added review, plan, and evidence files; 2 modified documents). CR2-N3 and CR2-N4 are resolved. CR-N5, CR2-N1, CR2-N2, and CR2-N5 are recorded as accepted orchestrator decisions. Two new non-blocking findings of Info severity are recorded.

## Prior Findings Verification

| Prior finding | Status | Verification by this review |
|---|---|---|
| CR2-N3 (`spec.md` `Last Updated` / `Version` stale) | Resolved | `git diff b222a6baf HEAD -- spec.md`: one hunk replacing line 6 (`2026-10-15T16-40` to `2026-10-16T06-23`) and line 8 (`0.2` to `0.3`); line 7 `Status: Draft` unchanged. No AC checkbox changed (14 checked, 2 unchecked, `grep` by this review). |
| CR2-N4 (`issue.md` status path names a missing folder) | Resolved | `git diff b222a6baf HEAD -- issue.md`: one line replaced; `issue.md:5` now names `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/`, which exists. The section headings the promotion tooling maps are unchanged. |
| CR-N5 (literal halt sentence in four validators) | Accepted (orchestrator decision) | Per-file convention; overlap with #929 avoided. Literals confirmed at `validate-discovery-artifact-gate.ps1:253`, `validate-pr-author-output.ps1:129`, `validate-prd-feature-output.ps1:118`, `validate-task-researcher-output.ps1:290`. |
| CR2-N1 (U1-ST rows not run against pre-fix validators) | Accepted (orchestrator decision) | The statement-terminating rows are characterization rows: the two default-preference validators already blocked this error class before the fix, so no fail-before result is obtainable. |
| CR2-N2 (uneven rewrap, `subagentstop-envelope.Tests.ps1:9-11`) | Accepted (orchestrator decision) | Widths 68, 100, 112 are within the line limit; a reflow would re-churn the verified AC4/AC9 hunk. |
| CR2-N5 (`validate-bash.ps1:441-443` exit 1 fail-open) | Accepted as unrelated (orchestrator decision) | Different hook, event (PreToolUse), and exit-code contract; the file is not in the branch diff. |

## Production Code Review

### Tail wrapper correctness (re-confirmed at `2f6b9600`)

- Catch lines (`grep -n 'catch { Exit-SubagentStopBlock' .claude/hooks/*.ps1` by this review): discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290`, plus the pre-existing `validate-feature-review-coverage.ps1:203`. Each prefix equals the validator's S1 `-ReasonPrefix`.
- `Exit-SubagentStopBlock` takes a mandatory, non-empty `Message`; each composed message always contains the non-empty prefix.
- No `exit` is inside a `try` body.
- `validate-feature-review-coverage.ps1` and its mirror are unchanged against the merge base (`git diff --quiet` exit 0, this review).
- The hooks that dot-source `subagentstop-envelope.ps1` are still exactly the nine U1 rows (`grep -l` by this review), so U2 remains satisfied.

### Mirror parity

All 12 changed `.claude` files are byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/...`, and `.agents/skills/translate-claude-to-codex/SKILL.md` is byte-identical to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md` (`cmp` by this review, exit 0 for each).

### Documentation edits

- `claude-code-architecture.md:237` and `:239` describe the PreToolUse and SubagentStop exit-code contracts consistently with the hooks (unchanged since the prior review).
- Cycle-2 edits to `spec.md` and `issue.md` are metadata only and match the cycle-2 plan's E1-E3 text exactly.

## Test Design Review

No test file changed since the prior review. `subagentstop-uncaught-error.Tests.ps1` (159 lines) builds both row tables in `BeforeDiscovery`, registers the #737 baseline seam mocks, restores all swapped state including `$global:LASTEXITCODE`, and asserts exit 2, the ordinal prefix, the injected text, one reader call, and no escaped exception.

## Findings Table

Blocking findings: 1 (CR-B1, awaiting_ci). Non-blocking findings: 2 (Info).

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking (awaiting_ci) | `artifacts/pester/powershell-coverage.xml` (local) | six changed hooks absent | CR-B1: PowerShell coverage for six changed production files (`validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, `subagentstop-envelope.ps1`) is not in the local report; the repo-wide figure (52.00%) is from a partial-scope run. | Confirm per-file line coverage >= 85% and not below baseline, and repo-wide >= 85%, from the `poshqc / PowerShell QC` artifact on the PR head at S9; then check off AC14 with AC15. | Coverage verification is mandatory for every language with changed files; the evidence is CI-dependent and no defect is indicated (ci-main baseline for the six files is 98.06%-100.00%). | Recomputed by this review: discovery 64/64, orchestrator 110/111, planner 200/201, wave-barrier 95/96 (99.36%, 469/472); six files ABSENT. |
| Non-blocking (Info) | `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/remediation-plan.2026-10-16T06-40.md` | filename and line 6 | CR3-N1: the plan's stamp `2026-10-16T06-40` is later than the commit that added it (`cd709e54b`, 2026-10-16 06:06 UTC) and later than the evidence it governed (`2026-10-16T06-23` to `06-25`). Under the "lexicographically greatest" selection convention, this review set (`06-36`, true UTC write time) sorts before the plan. | No change required for this item. Stamp future plans with the `date -u` write time. | Timestamp convention consistency; artifact ordering by name. | `git log -1 --format=%cI cd709e54b` (`02:06:23-04:00`); `date -u` at this review's write time `2026-10-16T06-36`. |
| Non-blocking (Info) | `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/issue.md` | line 11 | CR3-N2: `- Last Updated: 2026-10-15` was left unchanged when line 5 was edited on 2026-10-16. The cycle-2 plan kept it unchanged by direction, so this is a residual inconsistency rather than an execution error. | Update the field in the S9 check-off commit if `issue.md` is touched again. | Document traceability, same class as the resolved CR2-N3. | `sed -n 11p issue.md`; `git diff b222a6baf HEAD -- issue.md`. |

## Positive Observations

- The cycle-2 change is confined to three Markdown lines, with numstat, hunk-header, and no-code-change evidence recorded before commit.
- The branch is pushed, clean, and 0 commits behind `origin/main`.
- Mirror parity and excluded-path invariants still hold at the new head.
