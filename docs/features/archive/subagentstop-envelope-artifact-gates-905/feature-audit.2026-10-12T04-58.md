# Feature Audit: subagentstop-envelope-artifact-gates (Issue #905)

- Timestamp: 2026-10-12T04-58
- Reviewer: feature-review agent
- Related artifacts: `policy-audit.2026-10-12T04-58.md`, `code-review.2026-10-12T04-58.md` (same folder)

## Scope and Baseline

- Issue: #905 (child E3 of epic #904; parent issue #897). Upstream dependency E1 (#897) merged into the integration branch as PR 906; helper `.claude/hooks/subagentstop-envelope.ps1` defines `Get-SubagentStopEnvelopeAnomalyReason`, `Read-SubagentStopEnvelope` (with `[AllowNull()]` `-InputText`, reading `[Console]::In.ReadToEnd()` only when unbound) and `Exit-SubagentStopBlock` (`exit 2`).
- Branch: `bug/subagentstop-envelope-artifact-gates-exec-905`, reviewed at local `exec905-r3`, HEAD `642050f82`.
- Baseline: `origin/epic/subagentstop-envelope-integration` (tip `3fd6958d9`, merge-base `ebf4504ae`). The three commits on the integration branch after the merge-base change only `docs/features/epics/subagentstop-envelope/epic-status.md`.
- Diff: `git diff origin/epic/subagentstop-envelope-integration...HEAD`, 95 files: 4 hooks, 4 mirrors, 7 suites (1 new), and 80 feature-folder documents (plan, spec checkbox flips, 78 evidence files).
- Work mode: `full-bug` from `issue.md` (`- Work Mode: full-bug`). AC source: `spec.md` only; `user-story.md` intentionally absent.
- Plan: `plan.2026-10-11T07-59.md`, 161 of 161 tasks checked.
- Assumptions: (1) the PR body for AC-30 does not exist yet, as stated by the caller; (2) the coverage XML copy preserved from the executor worktree is the artifact the executor measured, based on its matching SHA256.

## Acceptance Criteria Inventory

| AC | Short description | Source state before review |
|---|---|---|
| AC-01 | Upstream-merge check passes and is recorded | checked |
| AC-02 | R1 implemented | checked |
| AC-03 | R1 Pester coverage, both sides | checked |
| AC-04 | R2 implemented | checked |
| AC-05 | R2 Pester coverage, both sides, plus entry-point case | checked |
| AC-06 | No policy file edited | checked |
| AC-07 | Task-researcher corpus run | checked |
| AC-08 | Prd-feature corpus run (R2 and R3) | checked |
| AC-09 | Discovery corpus run | checked |
| AC-10 | Pr-author corpus run | checked |
| AC-11 | Zero-FP gate ordering per validator | checked |
| AC-12 | Discovery exits 2 on failing artifact | checked |
| AC-13 | Discovery exits 0 on allow cases | checked |
| AC-14 | Pr-author exit 2 / exit 0 | checked |
| AC-15 | Prd-feature exit 2 / exit 0 | checked |
| AC-16 | Task-researcher exit 2 / exit 0 | checked |
| AC-17 | `output`-only and `CLAUDE_HOOK_INPUT`-only input does not satisfy any gate | checked |
| AC-18 | Envelope anomalies and empty-message outcomes per hook | checked |
| AC-19 | Task-researcher #786 guard and helper-load failure | checked |
| AC-20 | No `CLAUDE_HOOK_INPUT` or `.output` in hooks and mirrors | checked |
| AC-21 | No `exit 1` or `Write-Error` in hooks and mirrors | checked |
| AC-22 | Exit-code assertions inverted | checked |
| AC-23 | Test hygiene (env var only to prove ignored; no temp files) | checked |
| AC-24 | Pinned message strings preserved | checked |
| AC-25 | Line coverage >= 85% per changed file | checked |
| AC-26 | No file over 500 lines | checked |
| AC-27 | Mirrors byte-identical; parity pytest passes | checked |
| AC-28 | No Python; registration guard suites pass | checked |
| AC-29 | Full toolchain single pass; agent registrations unchanged | checked |
| AC-30 | Out-of-scope files untouched; PR body non-closing | unchecked |
| AC-31 | R3 implemented | checked |
| AC-32 | R3 Pester coverage, both suites; mirror parity | checked |
| AC-33 | R4 implemented and tested; mirror parity | checked |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (reviewer verification) |
|---|---|---|
| AC-01 | PASS | Plan section 1 `UCR-*` record (`UCR-E1-MERGED: YES`, `UCR-CONTRACT-MATCH: YES`); helper functions confirmed by reviewer grep of `.claude/hooks/subagentstop-envelope.ps1` (lines 20, 54, 171; `ReadToEnd` at 86; `exit 2` at 190); `evidence/other/upstream-merge-check.2026-10-11T14-42.md`. |
| AC-02 | PASS | `validate-task-researcher-output.ps1` regex equals the R1 normative regex; `[regex]::IsMatch` (case-sensitive) on the file name after `\` normalization. |
| AC-03 | PASS | `validate-task-researcher-output.Coverage.Tests.ps1:221-272`: 13 accepted cases (all four stamp forms, `.research.md` variants, `research.`/`research-addendum.` with timestamp and date, backslash path) and 22 rejected cases covering every R1 category including `foo.md` and `bad-name.md`; suite 52/52 passed. |
| AC-04 | PASS | `validate-prd-feature-output.ps1` `Test-SpecNumericCriterion`: R2 pattern identical to spec with the `U` alternation expanded, `IgnoreCase`, per-checkbox-line evaluation, policy-marker exclusion after `\` to `/` normalization. |
| AC-05 | PASS | `validate-prd-feature-output.Tests.ps1:150-185`: 10 triggering cases (digit and word cardinal under each determiner) and 15 non-triggering cases (threshold, comparator, exit code, issue/PR number, `file:line`, AC/task identifier, version, date/timestamp, section reference, zero, unit, three policy-citation cases, non-noun word); entry case `validate-prd-feature-output.Coverage.Tests.ps1:174`; suites passed. |
| AC-06 | PASS | Reviewer diff scan: no path under `.claude/rules/`, `.github/instructions/`, or `.github/copilot-instructions.md`. |
| AC-07 | PASS | `evidence/qa-gates/corpus-task-researcher.2026-10-11T15-02.md`: commit `2ef8d361e`, enumeration command, 235 paths; Before 137 blocks / 110 FP; After 27 blocks, each classified TRUE-REJECTION (26 R1 categories, 1 heading deviation), 0 FP; scope recheck failed 0. |
| AC-08 | PASS | `evidence/qa-gates/corpus-prd-feature.2026-10-11T15-03.md`: 236 specs; Before 1744 triggered lines (1600 non-derived), 56 evidence failures (8 CHECKER-DEFECT, all scope); After 280 triggered lines (DERIVED by definition), 56 failures all ARTIFACT-DEFECT, 0 FP; 8 scope rechecks PASS. |
| AC-09 | PASS | `evidence/qa-gates/corpus-discovery.2026-10-11T15-04.md`: 17 source files plus the `profile_cli.py` synthetic message; Before 12 `EXCEPTION:` blocks (12 FP); After 0 blocks, 0 FP, no `EXCEPTION:` reason. |
| AC-10 | PASS | `evidence/qa-gates/corpus-pr-author.2026-10-11T15-05.md`: 124 PR numbers, 620 decisions, 124 `Refs #<n>` control blocks; FP 0 before and after. |
| AC-11 | PASS | Reviewer `git show` check: for each validator the conversion commit already contains `AFTER-FALSE-POSITIVES: 0` and the hook still ends in `Write-Error; exit 1`; the switch commit changes only that tail line to `Exit-SubagentStopBlock`. Pairs: pr-author `53cf0fb1f` before `5b168a452`; prd-feature `14aaf7c52` before `9fb0f6da6`; discovery `e2284acf4` before `aab401160`; task-researcher `fe96ab715` before `489b66cdf`. Scope rechecks recorded for prd-feature and task-researcher. Plan section 1 `AC11:` lines agree. |
| AC-12 | PASS | `validate-discovery-artifact-gate.Tests.ps1:214` (exit 2, `DISCOVERY_ARTIFACT_GATE_BLOCKED:` on stderr); passed. |
| AC-13 | PASS | `validate-discovery-artifact-gate.Tests.ps1:226`, `:239`, `:250`, `:261`; passed. |
| AC-14 | PASS | `validate-pr-author-output.Coverage.Tests.ps1:52` (exit 2, `PR_AUTHOR_OUTPUT_NO_PR`), `:63` (exit 0); `validate-pr-author-output.Tests.ps1:104` (subprocess exit 2); passed. |
| AC-15 | PASS | `validate-prd-feature-output.Coverage.Tests.ps1:58` (exit 2), `:69` (exit 0), `:164` (subprocess); passed. |
| AC-16 | PASS | `validate-task-researcher-output.Coverage.Tests.ps1:58` (exit 2), `:69` and `:202` (exit 0), `:192` (subprocess); passed. |
| AC-17 | PASS | `output`-only plus `CLAUDE_HOOK_INPUT` negative cases: discovery `Tests.ps1:273`, pr-author `Coverage.Tests.ps1:74`, prd-feature `Coverage.Tests.ps1:82`, task-researcher `Coverage.Tests.ps1:82`; each blocks with exit 2; passed. |
| AC-18 | PASS | Empty stdin, malformed stdin, absent `last_assistant_message` cases in each hook's entry suite (discovery `:291/:301/:311`; pr-author `:101/:111/:121`; prd-feature `:111/:121/:131`; task-researcher `:111/:121/:131`), each asserting prefix and `payload anomaly`; empty-string outcomes: discovery allows (`:250`), pr-author `PR_AUTHOR_OUTPUT_EMPTY` (`:90`), prd-feature (`:100`), task-researcher (`:100`); passed. |
| AC-19 | PASS | Guard bootstrap, guarded helper edge, dependency tail and leading dependency-decision statement present; `validate-task-researcher-output.Coverage.Tests.ps1:164` (exit 2, `validate-task-researcher-output:` prefix) and `:181` (no S1/S2/S3/S6 finding); registration suites 786/786 passed. |
| AC-20 | PASS | Reviewer grep `CLAUDE_HOOK_INPUT|\.output\b` over 4 hooks and 4 mirrors: no match. |
| AC-21 | PASS | Reviewer grep `\bexit 1\b|Write-Error` over 4 hooks and 4 mirrors: no match. |
| AC-22 | PASS | Reviewer grep of the AC-22 pattern over the seven E3 suites: no match; block cases assert exit 2; prd-feature Coverage suite asserts exit 2 and stderr. The unchanged `ValidatorDispatch.Tests.ps1:49` match asserts an in-process result object, not a process exit code (`deviations.md` [P11-T10]). |
| AC-23 | PASS | `CLAUDE_HOOK_INPUT` is set only inside the four negative cases and restored in `finally`; reviewer grep for temp-file APIs over the changed suites: no match. |
| AC-24 | PASS | Reviewer pytest run including `test_claude_planning_integrity_contracts.py`: 22 passed. |
| AC-25 | PASS | Reviewer parse of the hash-verified coverage XML: discovery 100.00%, pr-author 100.00%, prd-feature 100.00%, task-researcher 98.06%; `evidence/qa-gates/final-coverage-per-file.2026-10-12T00-10.md`. |
| AC-26 | PASS | Reviewer `wc -l`: maximum 418 (`validate-task-researcher-output.Tests.ps1`); `evidence/qa-gates/final-file-sizes.2026-10-12T00-11.md`. |
| AC-27 | PASS | Reviewer `sha256sum`: 4 of 4 pairs equal; resource-contract pytest passed. |
| AC-28 | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 32/32; no `.py` in the hooks diff; `hook-dependency-failure.Claude` 143/143, `.SpecialCases` 13/13, `hook-dependency-guard-completeness` 598/598 (reviewer run). |
| AC-29 | PASS | Reviewer format check (11 files unchanged) and PSScriptAnalyzer (0 findings); executor loop pass 2 clean (`final-loop-status.2026-10-12T00-15.md`); `.claude/agents/` absent from the diff; `enforce-pr-author-command-allowlist` 38/38 and `claude-settings` 9/9 (reviewer run). |
| AC-30 | PARTIAL (file-scope PASS; PR-body UNVERIFIED pending PR) | File scope: reviewer scan of the three-dot diff for `settings.json`, `subagentstop-envelope.ps1`, manifests, E2 validators, `agents/prd-feature.md`, feature-review files, `.codex/`, and `tests/scripts/claude-runtime/` returned no match. PR body: the child PR does not exist, so `gh pr view <number> --json body` cannot run; `evidence/other/pr-handoff.2026-10-12T00-16.md` records the required body terms. Left unchecked. |
| AC-31 | PASS | Both sites use the R3 pattern; function diffs show one changed line each; `r3-verification.2026-10-11T23-22.md` `R3-ONLY-CHANGE: YES` for both hooks. |
| AC-32 | PASS | R3 cases in `validate-prd-feature-output.Tests.ps1:198-212` and `validate-task-researcher-output.Coverage.Tests.ps1:296-319`; passed; mirrors equal. |
| AC-33 | PASS | Line 190 matches the R4 text; function diff one line; mirror equal; `validate-discovery-artifact-gate.Tests.ps1:345` passed. |

### Mandatory evaluations (summary of code review sections)

- **R3 (exhaustive-scope wording accepts `whole` and `worktree`):** correct (exact normative pattern, superset of the old pattern, unchanged message); narrowly scoped (one line per site, mirrors equal); does not weaken a check that previously caught a real defect (no prior test or fixture rejected a whole/entire-worktree scope; the 12 corpus scope rejections classified ARTIFACT-DEFECT before R3 still reject after R3; the hooks never blocked at runtime before this branch). Residual breadth for whole-worktree scopes that enumerate a narrower covered set is recorded as NB-2.
- **R4 (discovery gate skips empty tokens):** correct (non-empty tokens follow the original call; empty tokens could never yield a reference); narrowly scoped (one condition on one line, mirror equal); does not weaken a check (no prior test expected the exception; the exception terminated validation rather than detecting a defect; 12 corpus `EXCEPTION:` blocks before, 0 after).
- **Per-validator corpus false-positive gate:** pr-author PASS (0 FP at `53cf0fb1f`, switch `5b168a452`); prd-feature PASS (0 FP at `14aaf7c52`, switch `9fb0f6da6`); discovery PASS (0 FP at `e2284acf4`, switch `aab401160`); task-researcher PASS (0 FP at `fe96ab715`, switch `489b66cdf`). In each case the hook at the conversion commit still used `exit 1`, and the switch commit changed only the final block line.

## Summary

- 32 of 33 acceptance criteria PASS on reviewer verification. Every previously checked AC was confirmed; none failed verification.
- AC-30 is PARTIAL: the file-scope half passes; the PR-body half is pending the child PR and remains unchecked.
- Blocking findings: 0. Non-blocking findings: 11 (see `code-review.2026-10-12T04-58.md`).
- Remediation inputs: not produced, because no Blocking finding or failed AC exists.
- Recommended next step: open the child PR against `epic/subagentstop-envelope-integration` with `Refs #905` and `Refs #897` and no closing keyword, then verify AC-30 with `gh pr view <number> --json body` and check it off.

## Acceptance Criteria Check-off

- Newly checked off by this review: none. AC-01 to AC-29 and AC-31 to AC-33 were already checked and were confirmed. AC-30 is left unchecked because its PR-body half cannot be verified until the PR exists.

### Acceptance Criteria Status
- Source: `docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md`
- Total AC items: 33
- Checked off (delivered): 32
- Remaining (unchecked): 1
- Items remaining: AC-30 (out-of-scope files untouched and child pull request non-closing; PR-body half pending PR creation)
