# Feature Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), re-audit at head 861fecb75

---

**Audit Date:** 2026-11-15
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Base Branch:** `main`
**Head Branch:** `bug/gate-sibling-worktree-pytest-target`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit with owner directive OD-2 applied (R3 recorded as accepted deviation DEV-R3)

---

## Scope and Baseline

- **Base branch:** `main` (commit `38f87bc2c4bab54be8121ee546f9eb0dc92272ee`, equal to `origin/main` after `git fetch` at review time)
- **Head branch/commit:** `bug/gate-sibling-worktree-pytest-target` (commit `861fecb753d0befcf2907e094196d9e2a404c4d1`, PR #1191)
- **Merge base:** `38f87bc2c4bab54be8121ee546f9eb0dc92272ee`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-15 22:04:45 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 38f87bc2c..861fecb75`
  - Feature evidence: `evidence/baseline/`, `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: the previous reviewer's full Pester gate on the identical non-documentation tree (`artifacts/pester/powershell-coverage.xml`; 27323 run, 0 failed); CI run `43764064186` on `06f085b30` (29 jobs success; merged PowerShell report and Python coverage shards downloaded and combined by the reviewer); CI run `43766284142` on `861fecb75` (success); a rerun of the reverted-mutant probe at the head
- **Feature folder used:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (111 files). The only commit after `06f085b30` adds review records in the feature folder; `git diff --quiet 06f085b30 861fecb75 -- . ':!docs'` exits 0.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md` — only source (`## Acceptance Criteria`)

### Acceptance criteria

1. AC-1: poetry `-C`/`--directory`/`--directory=`/`-P` forms resolve to the item worktree (P1-P3).
2. AC-2: `npm --prefix`, `npm -C`, `npx --prefix` resolve to the item worktree (N1-N2 allow, N4 deny, N3 pair).
3. AC-3: both absolute launcher forms resolve to the item worktree (L1, L2).
4. AC-4: `pwsh -File <item>/...` and `pwsh -WorkingDirectory <item>` resolve to the item worktree (W1, W2).
5. AC-5: `pytest <item>/tests/x.py` resolves to the item worktree (A1).
6. AC-6: five shell-variable or substitution forms deny `TARGET_WORKTREE_NOT_DERIVABLE` with no checkpoint read and no listing call (V1-V5), plus the quoted V3 form.
7. AC-7: two registered worktrees, or one plus an outside path, deny `TARGET_WORKTREE_AMBIGUOUS` (M1, M2).
8. AC-8: relative operands and a lone outside absolute path keep the session root (R1-R3).
9. AC-9: listing failure or empty listing deny `TARGET_WORKTREE_NOT_DERIVABLE` (F1, F2).
10. AC-10: malformed records, a selector with no value, `env -S`, and an unmodelled poetry option deny as unresolvable (U1-U4).
11. AC-11: G rows on both surfaces; B1-B15 unchanged; sibling at least 85% lines; no regression on changed epic-scope lines.
12. AC-12: operands four-copy identity, epic-scope bundle identity, manifest and `$script:SharedModuleNames` entries, five push-down contract suites.
13. AC-13: a failed dot-source of the operands sibling denies naming the file (I1); dependency-guard completeness passes.
14. AC-14: each gate differs from `main` only by the classify wiring (plus the Codex block move); 500-line row, AC-18 inventory, F1 rows pass; classify four-copy identity, manifests, `$script:SharedModuleNames`; positive rows classify and negative rows stay unclassified.
15. AC-15: the brief's `## Hook Execution Context` states the resolution, byte-identical in six copies.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 poetry selectors | PASS | P1-P3 rows pass on both surfaces | full Pester gate (identical tree); CI shards success | Code unchanged since the previous review |
| 2 | AC-2 npm and npx selectors | PASS | N1, N2, N4 and the N3 pair pass | same | — |
| 3 | AC-3 launcher forms | PASS | L1, L2 pass on both surfaces | same | — |
| 4 | AC-4 pwsh forms | PASS | W1, W2 pass on both surfaces | same | — |
| 5 | AC-5 bare absolute test path | PASS | A1 passes on both surfaces | same | — |
| 6 | AC-6 non-literal operands | PASS | V1-V5, the quoted V3 row, and the leading-assignment V3 row pass with zero reads and zero listing calls | same | — |
| 7 | AC-7 ambiguity | PASS | M1, M2 pass | same | — |
| 8 | AC-8 session-root keep | PASS | R1-R3 pass | same | — |
| 9 | AC-9 listing failure | PASS | F1, F2 pass | same | — |
| 10 | AC-10 unresolvable records | PASS | U1-U5 pass | same | — |
| 11 | AC-11 G rows and coverage | PASS | operands 154/154 per copy; Claude epic-scope 133/136 (97.79%), Codex epic-scope 154/157 (98.09%); no changed executable line at zero hits | JaCoCo LINE counters, reviewer gate and CI merged report of run `43764064186` | — |
| 12 | AC-12 mirrors and manifests | PASS | operands blob `802f0449f` in four copies; manifest and push-down suites pass in CI `Code Quality & Tests` | `git rev-parse HEAD:<path>` per copy; run `43764064186` | — |
| 13 | AC-13 fail-closed dot-source | PASS | I1 passes on both surfaces; dependency-guard completeness passes | full Pester gate | — |
| 14 | AC-14 gate wiring and classify sibling | PASS | classify blob `f15f48929` in four copies; positive rows classify and every existing negative row stays unclassified on both surfaces | `git rev-parse HEAD:<path>`; full Pester gate | Absent extra Negative rows are DEV-R3 (accepted, non-blocking); the AC text is satisfied by the existing rows |
| 15 | AC-15 brief text | PASS | brief copies unchanged since the previous review; CI pytest success | `git diff 06f085b30 861fecb75` lists no brief path | — |

---

## Deviations

| ID | Source | Description | Disposition | Blocking |
|----|--------|-------------|-------------|----------|
| DEV-R3 | Finding R3 in `remediation-inputs.2026-11-15T21-47.md` | Six regression test rows are absent for the cycle 3 classify guards N2, N5, N6, and N7 (four function rows with `Indexes = @()` and two Negative gate rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`). Reverted mutants of those guards fail no row. | Accepted by owner directive OD-2 (class `accept_nonblocking_deviation`). The rows are tracked in a coordinator-filed follow-up issue together with the `sh -c` / `pwsh -Command` stage-1 classification gap. Reviewer re-verification at the head: the head leaves `` echo `npm --version` lint `` and `echo $(echo npm --version) lint` unclassified and returns no supplement index for `FOO=$(echo npx jest) ls` and `FOO=$(echo npm x lint) npm --version`; a regression of the guards would newly classify and deny a mention form, which fails closed. | No (excluded from the blocking count) |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 15 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None. DEV-R3 is an owner-accepted non-blocking deviation.

**Recommended follow-up verification steps:**

1. In the follow-up issue, add the six DEV-R3 rows and confirm that N2, N5, N6, and N7 each fail at least one row while the unmutated control fails none.
2. In the same issue, address stage-1 classification of `sh -c` and `pwsh -Command` payloads.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC-1 to AC-15 were already checked off; the reviewer's PASS evaluations confirm them, so no source-file checkbox change was made. The unchecked boxes elsewhere in `spec.md` (severity options, `## Test Strategy` planning items, the repro attachment box) are not acceptance criteria.

### AC Status Summary

- Source: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 15 | 0 | Checkbox-backed; DEV-R3 is an accepted deviation outside the AC text |
