# Feature Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), R4 re-audit

---

**Audit Date:** 2026-11-15
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Base Branch:** `main`
**Head Branch:** `bug/gate-sibling-worktree-pytest-target`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycles 1 (R1) and 2 (F2)

---

## Scope and Baseline

- **Base branch:** `main` (commit `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb`, equal to `origin/main` at review time)
- **Head branch/commit:** `bug/gate-sibling-worktree-pytest-target` (commit `5f8b15daf20b977cfdba2fa14319e36f6536df67`, PR #1191)
- **Merge base:** `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-15 20:39:14 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 1df569f65..5f8b15daf`
  - Feature evidence: `evidence/baseline/`, `evidence/remediation-baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: the reviewer's full Pester gate at the head (`artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`); the reviewer's targeted pytest run (88 passed); reviewer real-process probes over 46 command forms on both surfaces; a seven-mutant probe of the classify rows; `gh pr checks 1191`
- **Feature folder used:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (100 files). CI on the PR was running concurrently (review mode concurrent).

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
| 2 | AC-2 npm and npx selectors | PASS | N1, N2, N4 and the N3 allow-ready and deny-not-ready pair pass; probe: `npx --prefix /synthetic-worktrees/w-item jest` classified with `Paths` the item root | reviewer gate; classification probe | N3 was an unclassified control before cycle 1 |
| 3 | AC-3 launcher forms | PASS | L1, L2 pass on both surfaces | reviewer gate | The session checkout denied the same form for the reviewer, as expected before merge |
| 4 | AC-4 pwsh forms | PASS | W1, W2 pass on both surfaces | reviewer gate | — |
| 5 | AC-5 bare absolute test path | PASS | A1 passes on both surfaces | reviewer gate | — |
| 6 | AC-6 non-literal operands | PASS | V1-V5 (unquoted V3) and the quoted V3 row pass with zero reads and zero listing calls; probe: `npm --prefix $(pwd) run lint` classified, `Unresolved` true, Claude decision deny | reviewer gate; classification and decision probes | R2 concerns a variant with a leading assignment substitution that AC-6 does not name |
| 7 | AC-7 ambiguity | PASS | M1, M2 pass | reviewer gate | — |
| 8 | AC-8 session-root keep | PASS | R1-R3 pass | reviewer gate | — |
| 9 | AC-9 listing failure | PASS | F1, F2 pass | reviewer gate | — |
| 10 | AC-10 unresolvable records | PASS | U1-U5 pass | reviewer gate | — |
| 11 | AC-11 G rows and coverage | PASS | G rows pass on both surfaces; operands 100% (154/154) per copy; epic-scope 97.79% and 98.09%, no changed executable line at zero hits | reviewer gate; JaCoCo LINE counters | — |
| 12 | AC-12 mirrors and manifests | PASS | operands blob `802f0449` in four copies; epic-scope bundle copies equal; manifest completeness, dependency-closure, and resource contract suites pass | `git rev-parse HEAD:<path>`; reviewer pytest run (88 passed) | — |
| 13 | AC-13 fail-closed dot-source | PASS | I1 passes on both surfaces; `hook-dependency-guard-completeness.Tests.ps1` passes in the reviewer gate | reviewer gate | — |
| 14 | AC-14 gate wiring and classify sibling | PASS | gate diffs against the merge base are the dot-source, the call, and the extended condition (plus the Codex block removal); Codex gate 485 lines; classify blob `b3c7c45c` in four copies; positive rows classify and negative rows stay unclassified on both surfaces | `git diff -U0 <merge base> HEAD`; reviewer gate | R2 is a missing positive form, not a failing row |
| 15 | AC-15 brief text | PASS | brief blob `b0ca4b7d` in six copies; `test_brief_copies_are_byte_identical` and the operands and classify wording rows pass | reviewer pytest and Pester runs | — |

---

## Summary

**Overall Feature Readiness:** NOT READY

**Criteria summary:**
- **PASS:** 15 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. R2 (related defect, blocking): `FOO=$(pwd) npm --prefix $(pwd) run lint`, `env FOO=$(pwd) npm --prefix $(pwd) run lint`, and the npx equivalents are unclassified and admitted, because Form 1 of the classify sibling checks only the first record of a joined-word run.
2. E1 (evidence, blocking): `evidence/qa-gates/self-review.2026-11-15T20-38.md` is stamped later than the commit that added it and carries no correction line.

**Recommended follow-up verification steps:**

1. After the light cycle, re-run the classify function and gate rows on both surfaces with the new positive rows for the leading-assignment forms, and confirm the four classify copies remain byte-identical.
2. Confirm the appended correction line in `self-review.2026-11-15T20-38.md` leaves every existing line unchanged.
3. Confirm CI on the remediated head is green, including the six PowerShell shards and the Linux hook-suite job.

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
| `spec.md` | 15 | 15 | 0 | Checkbox-backed; R2 and E1 are blocking findings outside the AC text |
