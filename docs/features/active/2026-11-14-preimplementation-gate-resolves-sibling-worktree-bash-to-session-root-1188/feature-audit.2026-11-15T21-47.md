# Feature Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), re-audit after remediation cycle 3

---

**Audit Date:** 2026-11-15
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Base Branch:** `main`
**Head Branch:** `bug/gate-sibling-worktree-pytest-target`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 3 (light; R2 and E1)

---

## Scope and Baseline

- **Base branch:** `main` (commit `38f87bc2c4bab54be8121ee546f9eb0dc92272ee`, equal to `origin/main` at review time)
- **Head branch/commit:** `bug/gate-sibling-worktree-pytest-target` (commit `06f085b30b352deb006126a4053cb2f39e26a37c`, PR #1191)
- **Merge base:** `38f87bc2c4bab54be8121ee546f9eb0dc92272ee`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-15 21:30:46 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 38f87bc2c..06f085b30`
  - Feature evidence: `evidence/baseline/`, `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: the reviewer's full Pester gate at the head (`artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`; 27323 run, 0 failed); reviewer real-process probes; an eight-mutant probe of the cycle 3 classify code; `gh pr checks 1191`
- **Feature folder used:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (107 files). CI on the PR was running concurrently (review mode concurrent); every check passed except PowerShell QC shard 5, pending at audit time.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md` — only source

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
| 1 | AC-1 poetry selectors | PASS | P1-P3 rows pass on both surfaces in the reviewer gate | `run-test-suite.sh pester` (reviewer, head) | Unchanged since the initial review |
| 2 | AC-2 npm and npx selectors | PASS | N1, N2, N4 and the N3 pair pass | reviewer gate | — |
| 3 | AC-3 launcher forms | PASS | L1, L2 pass on both surfaces | reviewer gate | — |
| 4 | AC-4 pwsh forms | PASS | W1, W2 pass on both surfaces | reviewer gate | — |
| 5 | AC-5 bare absolute test path | PASS | A1 passes on both surfaces | reviewer gate | — |
| 6 | AC-6 non-literal operands | PASS | V1-V5, the quoted V3 row, and the new leading-assignment V3 row pass with zero reads and zero listing calls; probe: `FOO=$(pwd) npm --prefix $(pwd) run lint` denies `TARGET_WORKTREE_NOT_DERIVABLE` | reviewer gate; decision probe | R2 closed |
| 7 | AC-7 ambiguity | PASS | M1, M2 pass | reviewer gate | — |
| 8 | AC-8 session-root keep | PASS | R1-R3 pass | reviewer gate | — |
| 9 | AC-9 listing failure | PASS | F1, F2 pass | reviewer gate | — |
| 10 | AC-10 unresolvable records | PASS | U1-U5 pass | reviewer gate | — |
| 11 | AC-11 G rows and coverage | PASS | G rows pass on both surfaces; operands 100% (154/154) per copy; epic-scope 97.79% and 98.09%, no changed executable line at zero hits | reviewer gate; JaCoCo LINE counters | — |
| 12 | AC-12 mirrors and manifests | PASS | operands blob `802f0449` in four copies; epic-scope bundle copies equal; manifest and push-down suites pass in CI `Code Quality & Tests` at the head | `git hash-object` per copy; `gh pr checks 1191` | Python suites unchanged since the previous reviewer run (88 passed) |
| 13 | AC-13 fail-closed dot-source | PASS | I1 passes on both surfaces; `hook-dependency-guard-completeness.Tests.ps1` passes in the reviewer gate | reviewer gate | — |
| 14 | AC-14 gate wiring and classify sibling | PASS | gates unchanged since the previous review; classify blob `f15f4892` in four copies; positive rows (including the four cycle 3 rows) classify and negative rows stay unclassified on both surfaces | `git hash-object`; reviewer gate | R3 concerns absent Negative rows, not a failing row |
| 15 | AC-15 brief text | PASS | brief copies unchanged since the previous review (blob `b0ca4b7d` in six copies); CI pytest pass | `git diff 5f8b15daf 06f085b30` lists no brief path | — |

---

## Summary

**Overall Feature Readiness:** NOT READY

**Criteria summary:**
- **PASS:** 15 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. R3 (related test gap, blocking): the backtick arm of the cycle 3 unclosed-substitution filter, the member `npm` and `npx` word checks, and the member-tail match have no discriminating row; reverted mutants N2, N5, N6, and N7 fail no row.

**Recommended follow-up verification steps:**

1. After the cycle, rerun the reverted-mutant probe and confirm N2, N5, N6, and N7 each fail at least one row on both surfaces.
2. Confirm the new rows are Negative (unclassified) at the head and that the four classify copies are unchanged.
3. Confirm CI on the remediated head is green, including PowerShell QC shard 5.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC-1 to AC-15 were already checked off; the reviewer's PASS evaluations confirm them, so no source-file checkbox change was made.

### AC Status Summary

- Source: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 15 | 0 | Checkbox-backed; R3 is a blocking finding outside the AC text |
