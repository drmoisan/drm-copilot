# Feature Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Base Branch:** `main`
**Head Branch:** `bug/gate-sibling-worktree-pytest-target`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `11c6ecde2e3080722c90bc63289bc160bf9596ea`, equal to `origin/main` at review time)
- **Head branch/commit:** `bug/gate-sibling-worktree-pytest-target` (commit `aca57bf07214fb4436a7459beb1b587eedd6af35`, PR #1191)
- **Merge base:** `11c6ecde2e3080722c90bc63289bc160bf9596ea`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 23:19:55 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 11c6ecde2..aca57bf07`
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: the reviewer's Pester gate re-run at the head (`evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`, `artifacts/pester/powershell-coverage.xml`); reviewer real-process probes of the extraction and classification functions over 70 command forms; `gh pr checks 1191`
- **Feature folder used:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (52 files). CI on the PR was running concurrently (review mode concurrent).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md` — only source

### Acceptance criteria

1. AC-1: poetry `-C`/`--directory`/`--directory=`/`-P` forms resolve to the item worktree; item checkpoint read once, session checkpoint never (P1-P3).
2. AC-2: `npm --prefix`, `npm -C`, `npx --prefix` resolve to the item worktree (N1-N3 allow, N4 deny).
3. AC-3: both absolute launcher forms resolve to the item worktree (L1, L2).
4. AC-4: `pwsh -File <item>/...` and `pwsh -WorkingDirectory <item>` resolve to the item worktree (W1, W2).
5. AC-5: `pytest <item>/tests/x.py` resolves to the item worktree (A1).
6. AC-6: five shell-variable or substitution forms, including `npm --prefix $(pwd) run lint`, deny `TARGET_WORKTREE_NOT_DERIVABLE` with no checkpoint read and no listing call (V1-V5).
7. AC-7: two registered worktrees, or a registered worktree plus an outside path, deny `TARGET_WORKTREE_AMBIGUOUS` (M1, M2).
8. AC-8: relative operands and a lone outside absolute path keep the session root (R1-R3).
9. AC-9: listing failure or empty listing deny `TARGET_WORKTREE_NOT_DERIVABLE` with no checkpoint read (F1, F2).
10. AC-10: unbalanced or undecodable records, a selector with no value, `env -S`, and an unmodelled poetry option deny as unresolvable (U1-U4).
11. AC-11: G rows for the function alone on both surfaces; B1-B15 unchanged; sibling at least 85% line coverage; no regression on changed epic-scope lines.
12. AC-12: four-copy byte identity, epic-scope bundle identity, manifest and `$script:SharedModuleNames` entries, five push-down contract suites pass.
13. AC-13: a failed dot-source of the sibling denies naming the file (I1); dependency-guard completeness passes.
14. AC-14: neither gate file differs from `main`; 500-line legacy row, AC-18 inventory, and F1 rows pass.
15. AC-15: the brief's `## Hook Execution Context` states the new resolution, byte-identical in six copies.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 poetry selectors | PASS | P1-P3 rows for four selector forms on both surfaces; reviewer probe: `poetry -C <item> run pytest <item>/tests/x.py`, `--directory=`, attached `-C<path>`, and `-q -C` all give `Paths` with the item root | reviewer Pester gate at the head; extraction probe | Fail-before shows all 12 rows failing per surface |
| 2 | AC-2 npm and npx selectors | PASS | N1, N2 allow against a ready item checkpoint; N4 denies not-ready; N3 (`npx --prefix <item> jest`) is admitted, but because the command is unclassified, with zero reads | reviewer Pester gate; classification probe | The enumerated rows pass; the npx form never reaches resolution, which is part of finding R1 |
| 3 | AC-3 launcher forms | PASS | L1, L2 on both surfaces for both launcher forms | reviewer Pester gate | The prescribed sibling-worktree test form |
| 4 | AC-4 pwsh selectors | PASS | W1, W2 on both surfaces; probe: `pwsh -NoProfile -File <item>/tests/scripts/X.Tests.ps1` gives the file path; `pwsh -f $W/...` and `pwsh -WorkingDirectory $W` are Unresolved | reviewer Pester gate; probe | |
| 5 | AC-5 bare runner operand | PASS | A1 ready and not ready on both surfaces | reviewer Pester gate | |
| 6 | AC-6 shell-variable and substitution forms | FAIL | V1, V2, V4, V5 deny as specified with zero reads and zero listing calls; the AC's V3 command `npm --prefix $(pwd) run lint` is admitted by both gates (unclassified); the delivered V3 row uses the quoted form and a control row pins the unquoted form as allowed | classification probe: scan segments `npm --prefix `, `pwd`, ` run lint`; `classified=False`; stage 2 `confirmed=True` | Finding R1; left unchecked by the executor and by this review |
| 7 | AC-7 ambiguity | PASS | M1, M2 deny `TARGET_WORKTREE_AMBIGUOUS` on both surfaces | reviewer Pester gate | Separate-token outside option values also produce ambiguity (Info in the code review) |
| 8 | AC-8 session-root controls | PASS | R1-R3 keep the session root; item never read | reviewer Pester gate | |
| 9 | AC-9 listing failure | PASS | F1 (throws), F2 (empty) deny with zero reads | reviewer Pester gate | |
| 10 | AC-10 malformed and unmodelled | PASS | U1 (unbalanced), U2 (selector with no value, npm form), U3 (`env -S`), U4 (`poetry --frobnicate`), plus U5 and DecodeFailure and DepthLimit G rows | reviewer Pester gate; probe | U2 uses the npm form; a trailing `poetry -C` carries no governed word (Info in the code review) |
| 11 | AC-11 unit rows and coverage | PASS | 90 G rows per surface including redirection and `git commit -F`; existing target-worktree suites pass unchanged; siblings 100% (154/154); every changed executable epic-scope line covered | reviewer parse of `artifacts/pester/powershell-coverage.xml` after the head run | |
| 12 | AC-12 mirrors and manifests | PASS | One SHA-256 for all four sibling copies; `cmp` identical epic-scope bundle copies; both `core.json` entries; `$script:SharedModuleNames` entry; push-down suites in the executor's pytest gate and CI `quality-checks7` 3.11 and 3.12 pass at the head | `sha256sum`, `cmp`, `gh pr checks 1191` | |
| 13 | AC-13 fail-closed dot-source | PASS | I1 on both surfaces; guarded single-statement dot-source in each epic-scope file | reviewer Pester gate; diff inspection | |
| 14 | AC-14 gate files unchanged | PASS | `git diff --exit-code 11c6ecde2 HEAD` on both gate files exits 0; legacy 500-line row, AC-18, F1 rows in the reviewer gate | `git diff --exit-code` | Note: remediating R1 may require revising this AC (see remediation inputs) |
| 15 | AC-15 brief | PASS | All six brief copies share one SHA-256 prefix `b3d92b110c59`; the `## Hook Execution Context` item states the selectors, script operands, absolute operands, the not-derivable denials, the session-root rule, and the absolute launcher form | `sha256sum`; diff inspection | The `npx --prefix`/`-C` clause is accurate only for gated commands (R1) |

---

## Summary

**Overall Feature Readiness:** NOT READY

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (AC-6)

**Top gaps preventing PASS:**

1. R1: AC-6 command `npm --prefix $(pwd) run lint` is admitted by both gates because stage 1 never matches it; the related form `npx --prefix <item> jest` is likewise ungated.

**Recommended follow-up verification steps:**

1. After the remediation cycle, re-run the V3 gate row with the unquoted AC-6 command on both surfaces and confirm `TARGET_WORKTREE_NOT_DERIVABLE` with zero reads and zero listing calls.
2. Confirm N3 as an allow-ready and deny-not-ready pair for `npx --prefix <item> jest`.
3. Confirm CI on the remediated head is green, including the Linux hook-suite job.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC-1 to AC-5 and AC-7 to AC-15 were already checked off by the executor; the reviewer's PASS evaluations confirm them, so no source-file checkbox change was made. AC-6 stays unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/spec.md`
- Total AC items: 15
- Checked off (delivered): 14
- Remaining (unchecked): 1
- Items remaining: AC-6: Each of `git -C $W add x`, `poetry -C ${W} run pytest`, `npm --prefix $(pwd) run lint`, `sh $W/run-test-suite.sh pytest`, and `pytest $W/tests` denies with `TARGET_WORKTREE_NOT_DERIVABLE` and an unresolvable-operand detail even when the session-root checkpoint is ready, reads no checkpoint, and does not call `Get-OrchestrationGateWorktreeList` (rows V1-V5, on both surfaces).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 15 | 14 | 1 | Checkbox-backed; AC-6 FAIL (R1) |
