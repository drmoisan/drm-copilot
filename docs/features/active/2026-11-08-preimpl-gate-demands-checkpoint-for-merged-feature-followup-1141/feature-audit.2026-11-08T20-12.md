# Feature Audit: Preimplementation gate demands a checkpoint for a merged-feature follow-up (#1141)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141`
**Base Branch:** `main`
**Head Branch:** `bug/preimpl-gate-merged-feature-followup`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` at `5c81af727d0c4c85b893d6542356c47123454117`, confirmed by `git fetch origin main`)
- **Head branch/commit:** `bug/preimpl-gate-merged-feature-followup` (commit `d5961781e56f83046f76b7ab4d131ef8cb498d44`)
- **Merge base:** `5c81af727d0c4c85b893d6542356c47123454117` (equal to the `origin/main` tip; the merge commit `d5961781e` brought #1138 content, which is outside the reviewed range)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-08 20:11:29 UTC at head `d5961781e`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`; `git diff 5c81af727...HEAD` (43 paths)
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/fail-before.2026-11-08T19-39.md`, `evidence/qa-gates/` (final gates stamped `2026-11-08T19-53` to `2026-11-08T20-07`), `evidence/other/`
  - Additional evidence: reviewer runs at the reviewed head (full `Invoke-PoshQCParallelTest`: ExitCode 0, 20484 tests, 0 failures, repo-wide 95.67% lines; `pytest -n auto` over seven contract modules, 105 passed; `generate_codex_agent_variants --check`, exit 0; `validate_evidence_locations.py --root .`, exit 0), `sha256sum` parity of all mirror copies, direct parsing of `artifacts/pester/powershell-coverage.xml`, and an in-process adversarial probe of `Get-EpicMergedFeatureFollowUpAllowance`
- **Feature folder used:** `docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`; `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base of `origin/main` and HEAD. The executor's final gates ran before the merge of `origin/main`; the merge changed no file of this branch's diff other than the combined pin comment, and the reviewer re-ran the Pester gate and the contract modules at the merged head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141/spec.md` - only source (checkbox-backed, 20 items under `## Acceptance Criteria`)

### Acceptance criteria

1. AC1: Fail-before evidence for the `-F` pathspec row and the pathless `-m` row, recorded under `evidence/regression-testing/` with the four fields.
2. AC2: After the fix, Write/Edit, `git add`, `git commit -- <paths>`, and pathless `git commit` (five options) under a qualifying feature's active or completed root, or the status document, are allowed on Claude and Codex (rows on each).
3. AC3: Qualification conjuncts (terminal status, plain basename after prefix stripping, 40/64 lowercase hex SHA, JSON integer `pr_number` above 0) with pass and fail unit rows.
4. AC4: Missing `merge_commit_sha` denied with unchanged text on both surfaces.
5. AC5: Missing `pr_number` denied with unchanged text on both surfaces.
6. AC6: Non-terminal `merge_status` denied with unchanged text.
7. AC7: A hand-authored per-item checkpoint with `lifecycle_ready: true` does not admit `scripts/x.ps1`; the allowance reads no per-item checkpoint.
8. AC8: Listed shapes denied with unchanged text (outside roots, sibling prefix, `..`, backslash, `-a`/`--all`, `--amend`, `-A`, other flags, empty index, mixed index).
9. AC9: Allowance applies only when the readiness failure is exactly `merge-in-progress`.
10. AC10: Non-regression of admitted calls (#1136 and #539 rows pass unchanged).
11. AC11: Existing deny texts byte-unchanged; single-feature deny outside epic scope unchanged; asserted by rows.
12. AC12: Allowance implemented in `hook-epic-fan-in.ps1` by generalizing the shape and staged-index predicates and adding `Get-EpicMergedFeatureFollowUpAllowance`; no duplicated fan-in logic; #1136 unit rows unchanged.
13. AC13: Unit rows for each new or changed function; new code at least 90% line coverage; no touched file's coverage drops.
14. AC14: Four `hook-epic-fan-in.ps1` copies byte-identical; epic-scope siblings match bundles; manifest entries if a hook file is added.
15. AC15: `epic-orchestrate/SKILL.md` (four copies) documents the allowance, provenance recording, code corrections via a new child, and the never-hand-author rule.
16. AC16: `orchestrate/SKILL.md` (four copies) carries the pointer paragraph; no `.github` copy created.
17. AC17: Execution-environment brief `Post-fan-in allowance (#1136)` bullet extended in all six byte-identical copies.
18. AC18: `PINNED_FROZEN_SURFACE_HASHES` carries the new skill digest with a dated comment.
19. AC19: Push-down contract tests and the Codex generator `--check` pass.
20. AC20: One `Invoke-PoshQCParallelTest` and one `pytest -n auto` run as evidence; no serial run; no new Python file.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1 | Fail-before evidence | PASS | `evidence/regression-testing/fail-before.2026-11-08T19-39.md`: EXIT_CODE 1 (expected 1); both named rows denied with `'merge-in-progress'` on both surfaces; all four required fields present | read the artifact | 18 failures, all allow rows of the two new files |
| AC2 | Allows on both surfaces | PASS | Claude `fail-before`/`allows` rows (Write, Edit, absolute Write, `git add`, `git add --`, `git -C ... commit --message`, `--file --trailer`, status doc, pathless mixed-root index); Codex rows (file_path Write, apply_patch, `git add`, `--file` pathspec, status doc, pathless) | reviewer `Invoke-PoshQCParallelTest`; in-process probe | Pathless `-F`/`--trailer` forms share the same option table |
| AC3 | Qualification conjuncts | PASS | `Context 'Get-EpicMergedFeatureRoots'` in `hook-epic-fan-in.Tests.ps1`, run for both surface copies: bare and prefixed folders, JSON-parsed 64-char SHA, `[long]` PR; 18 refusal rows incl. uppercase hex, lengths 39/41/63, string/0/-1/null/7.5/`$true`/absent `pr_number` | reviewer Pester run | Code: `hook-epic-fan-in.ps1` lines 380-416 |
| AC4 | Missing SHA denied | PASS | child-d rows in the Claude (`-BeExactly` deny text) and Codex (contains `'merge-in-progress'`) suites | reviewer Pester run | Codex rows assert a substring; the deny text comes from unchanged code |
| AC5 | Missing PR number denied | PASS | child-e rows on both surfaces | reviewer Pester run | Same note as AC4 |
| AC6 | Non-terminal status denied | PASS | child-b (`pr_open`) rows on both surfaces | reviewer Pester run | |
| AC7 | Hand-authored checkpoint ignored | PASS | Claude row with `lifecycle_ready: true` denies `scripts/x.ps1` with the exact epic text; AST row `reads no per-item checkpoint and touches no file`; code inspection: new functions read only `$Scope` | reviewer Pester run; `grep -n orchestrator-state.json .claude/hooks/hook-epic-fan-in.ps1` (no match) | |
| AC8 | Listed deny shapes | PASS | Claude `Context 'denies with unchanged text'` (13 rows, `-BeExactly`) and `Context 'denies'` (`..`, backslash, glob); unit refusal rows; reviewer probe added redirection, `$(...)`, `:(top)`, `git -c`, `git mv`, `git rm`, traversal | reviewer Pester run; in-process probe | |
| AC9 | Exact failure only | PASS | `epic_manifest_path` rows on both surfaces; `-ceq 'merge-in-progress'` guard at Claude line 389 and Codex line 449 | reviewer Pester run; code inspection | |
| AC10 | Admitted calls stay admitted | PASS | No existing test file modified (`git diff --numstat` shows additions only); `already admitted` rows; full Pester run at head with zero failures includes the #1136 EpicFanIn and #539 CommandExemption suites | `git diff --numstat 5c81af727...HEAD -- tests/`; reviewer Pester run | Disjunct is allow-only |
| AC11 | Deny texts byte-unchanged | PASS | Claude rows use `-BeExactly` against the production outcome function and the literal single-feature text; outside-epic-scope rows on both surfaces; no change to any deny-text producer in the diff | `git diff 5c81af727...HEAD -- .claude/hooks .codex/hooks` | |
| AC12 | Generalization in the same file | PASS | Optional `-PathPredicate`/`-OperandPredicate` in `Get-EpicFanInShapeDetail`, `Test-EpicFanInCommitShape`, `Test-EpicFanInStagedIndex`, `Get-EpicFanInAllowance`; `Get-EpicMergedFeatureFollowUpAllowance` calls `Get-EpicFanInAllowance`; existing #1136 unit rows unchanged and passing | code inspection; reviewer Pester run | |
| AC13 | Unit rows and coverage | PASS | Coverage XML at head: `hook-epic-fan-in.ps1` 136/136 (100%) on both surfaces, baseline 91/91; epic-scope 97.66% Claude (baseline 97.60%) and 97.96% Codex (baseline 97.92%); changed lines covered 54/54 and 3/3 | parse `artifacts/pester/powershell-coverage.xml` | Missed lines in the epic-scope files (131-133 Claude, 119-121 Codex) are outside the diff |
| AC14 | Copies identical | PASS | Four `hook-epic-fan-in.ps1` copies SHA-256 `86bd8bbe...`; Claude epic-scope and bundle `17aaa740...`; Codex epic-scope and bundle `a9a63b5e...`; no hook file added | `sha256sum` | |
| AC15 | epic-orchestrate docs | PASS | Paragraph `**Merged-feature follow-up allowance (issue #1141).**` in `.claude` and bundle (`e227db65...`), and `.agents` and bundle (`143e1895...`); the `## Worktree Cleanup` / merge-mirror text records `pr_number` and `merge_commit_sha`; code corrections via a new child; never hand-author | `sha256sum`; `git diff` of the four files | |
| AC16 | orchestrate pointer | PASS | Pointer paragraph in `.claude` and bundle (`e174bde5...`), `.agents` and bundle (`75d97868...`); standalone form `git commit -m <msg> -- <paths>` or a new run; `.github/skills/orchestrate` and `.github/skills/epic-orchestrate` absent | `sha256sum`; `ls` | |
| AC17 | Brief six copies | PASS | All six copies SHA-256 `57e4c81c...`; bullet extended with `Merged-feature follow-up allowance (#1141)` | `sha256sum` over `git ls-files '*execution-environment/SKILL.md'` | |
| AC18 | Pinned digest | PASS | `e227db655edef428ef688da4c482868db0c3a7cb6de662a7bafa19f9924b0d53` equals `git show HEAD:.claude/skills/epic-orchestrate/SKILL.md \| sha256sum`; `# RE-BASELINED by issue #1141.` block names the merged result of #1129, #1130, #1136, #1138, and #1141 | `sha256sum` | The merge updated the digest to the combined content |
| AC19 | Contract tests and generator | PASS | Reviewer `pytest -n auto` over `test_execution_environment_brief_contracts.py`, `test_parallel_orchestrator_surface_contracts.py`, the four push-down resource and manifest modules, and `test_push_down_pack_manifest_dependency_closure.py`: 105 passed; generator `--check` exit 0; Pester wording, guard-completeness, and concurrent-review contract suites pass in the reviewer Pester run | reviewer commands | |
| AC20 | Parallel-only gates, no new Python | PASS | Executor: one `Invoke-PoshQCParallelTest` (20452 passed, 0 failed) and one `pytest -n auto` (16560 passed, 0 failed); `git diff --name-status 5c81af727...HEAD` lists no added `.py` | read the gate artifacts; `git diff --name-status` | Reviewer runs were also parallel |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 20 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. At S9, confirm the PowerShell QC and Python quality jobs on the PR head (pending-CI; not a finding).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

All 20 criteria were already checked in `spec.md` by the executor and were re-evaluated as PASS at the reviewed head. No source-file change was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-11-08-preimpl-gate-demands-checkpoint-for-merged-feature-followup-1141/spec.md`
- Total AC items: 20
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 20 | 20 | 0 | Checkbox-backed |
