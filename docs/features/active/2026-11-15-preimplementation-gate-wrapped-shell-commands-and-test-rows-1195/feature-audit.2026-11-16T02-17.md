# Feature Audit: Preimplementation gate classifies wrapped shell and PowerShell payloads, and adds the DEV-R3 rows (#1195), review at head ebacd29f1

---

**Audit Date:** 2026-11-16
**Feature Folder:** `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195`
**Base Branch:** `main`
**Head Branch:** `bug/gate-wrapped-shell-test-commands`
**Work Mode:** `full-bug`
**Audit Type:** First review, concurrent with CI on the head

---

## Scope and Baseline

- **Base branch:** `main` (commit `b58f045bc58d237129963543e445c7c8d2987772`, equal to `origin/main` after `git fetch` at review time)
- **Head branch/commit:** `bug/gate-wrapped-shell-test-commands` (commit `ebacd29f19918dcced5caedefe91ecf7316a85a8`, PR #1196)
- **Merge base:** `b58f045bc58d237129963543e445c7c8d2987772`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-16 02:06:53 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff b58f045bc..ebacd29f1`
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: the final-gate coverage report `artifacts/pester/powershell-coverage.xml` (parsed by the reviewer); a reviewer scoped parallel Pester run of the classify, Codex classify, and classify parity suites (283 passed, 0 failed); reviewer real-process probes (28 additional commands at the head and a base-equivalent, the N2/N5/N6/N7 mutant rerun, and a seven-mutant probe of the new function); blob hashes of every mirror set; CI dispatch run `43788266034` on `c1729bf54` (29 jobs success)
- **Feature folder used:** `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (58 files). The head commit `ebacd29f1` differs from `c1729bf54` only in feature-folder files (`git diff --quiet c1729bf54 ebacd29f1 -- . ':!docs'` exits 0).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195/spec.md` — only source (`## Acceptance Criteria`)

### Acceptance criteria

1. AC-1: `Get-OrchestrationGateWrappedPatternIndex` exists with `-CommandText` and `-Pattern`; every wrapped function row passes on both surfaces.
2. AC-2: every Positive wrapped gate row returns true on both surfaces.
3. AC-3: fail-before evidence for every wrapped gate row.
4. AC-4: every Negative wrapped gate row (mentions, D18 exclusions, non-goals) returns false on both surfaces.
5. AC-5: every Control wrapped gate row returns true on both surfaces.
6. AC-6: each gate changes only the `$supplementalIndex` line; no logical line growth; Codex 500-line row passes.
7. AC-7: stage-2 sibling, pattern literals, and shared modules unchanged on both runtimes and bundles.
8. AC-8: no existing row changes disposition.
9. AC-9: classify four-copy identity; parity suite; gate bundle identity; push-down, manifest, closure suites; Codex generator check.
10. AC-10: no new hooks file, gate dot-source, manifest, or `$script:SharedModuleNames` entry.
11. AC-11: row I2 on both surfaces; dependency-guard completeness passes.
12. AC-12: four DEV-R3 function rows with `Indexes = @()` pass on both surfaces.
13. AC-13: two DEV-R3 Negative gate rows pass on both surfaces.
14. AC-14: reverted-mutant probe evidence for N2, N5, N6, N7 with a clean control.
15. AC-15: cycle-3 guards byte-unchanged.
16. AC-16: brief text in six identical copies; parity token `#1195`.
17. AC-17: classify `.DESCRIPTION` and Cases header text.
18. AC-18: classify line coverage at least 85% with no zero-hit changed line.
19. AC-19: file-size bounds.
20. AC-20: full PowerShell toolchain in one pass and CI on the PR head succeeds.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 new function and function rows | PASS | Function and parameters present in the classify diff; all 31 wrapped function rows pass on both surfaces | reviewer scoped `run-test-suite.sh pester` (283 passed, 0 failed) | — |
| 2 | AC-2 Positive wrapped gate rows | PASS | 16 Positive rows pass on both surfaces | same | — |
| 3 | AC-3 fail-before | PASS | `evidence/regression-testing/fail-before.2026-11-15T23-50.md`: command, clock-read stamp, per-row results; Positive false, Negative and Control at expected values | evidence inspection; stamp precedes test commit `ad162c344` (00:09Z) | — |
| 4 | AC-4 Negative wrapped gate rows | PASS | 14 Negative rows, including the five D18 exclusions and four non-goals, pass on both surfaces | reviewer scoped run | — |
| 5 | AC-5 Control wrapped gate rows | PASS | 4 Control rows pass on both surfaces | reviewer scoped run | — |
| 6 | AC-6 one-line gate change | PASS | `git diff --numstat` 1/1 per gate; logical lines 493 and 485 at merge base and head | `git diff b58f045bc..HEAD`; `awk 'END{print NR}'` | Codex 500-line row passed in `evidence/other/contract-tests.2026-11-16T00-33.md` |
| 7 | AC-7 unchanged stage 2 and shared modules | PASS | `git diff --stat` over the commands sibling and `hook-command-*` paths is empty on all surfaces; pattern literals untouched | `git diff --stat b58f045bc..HEAD -- <paths>` | — |
| 8 | AC-8 no disposition change | PASS | No existing Cases row edited; full final gate 27466 passed, 0 failed | `git diff` of the Cases file (additions only); `evidence/qa-gates/final-qc-pester.2026-11-16T01-31.md` | — |
| 9 | AC-9 mirrors and contract suites | PASS | classify blob `e9f0ed763` x4; gate bundles equal sources; contract suites exit 0 | `git hash-object` per copy; `evidence/other/contract-tests.2026-11-16T00-33.md`; CI run `43788266034` | — |
| 10 | AC-10 no new files or entries | PASS | No added file outside `docs/`; the only added dot-source lines are in test `BeforeAll` blocks | `git diff --name-only --diff-filter=A`; grep of added lines | — |
| 11 | AC-11 I2 and guard completeness | PASS | I2 passes in the reviewer run on both surfaces; guard completeness in contract evidence | reviewer scoped run; contract evidence | — |
| 12 | AC-12 DEV-R3 function rows | PASS | Four rows present and passing on both surfaces | reviewer scoped run | — |
| 13 | AC-13 DEV-R3 gate rows | PASS | Two Negative rows present and passing on both surfaces | reviewer scoped run | — |
| 14 | AC-14 mutant probe | PASS | Evidence records command, stamp, per-row results; reviewer in-memory rerun at the head: control 0, N2 2, N5 1, N6 3, N7 1 failed rows | reviewer probe (scratch, in memory) | Identical to the evidence |
| 15 | AC-15 guards byte-unchanged | PASS | Classify diff hunks are the help block and an append after the last existing function | `git diff b58f045bc..HEAD` of the classify sibling | — |
| 16 | AC-16 brief | PASS | Six copies share blob `93ca58a0c`; text names `#1195`, the function, stage-2 confirmation, and D18 exclusions; parity token row passes | `git hash-object`; reviewer scoped run (parity suite) | — |
| 17 | AC-17 help and Cases header | PASS | `.DESCRIPTION` names the form and D18 exclusions; Cases header defines both tables; parity row passes | diff inspection; reviewer scoped run | — |
| 18 | AC-18 coverage | PASS | classify 96/96 per measured copy, no zero-hit line, in the final gate report; reviewer scoped run also 96/96 | JaCoCo per-file counters | — |
| 19 | AC-19 file sizes | PASS | Largest changed covered file 493 lines; classify 223 | `awk 'END{print NR}'` per changed file | — |
| 20 | AC-20 toolchain and CI on PR head | UNVERIFIED | Local toolchain one pass (`final-qc-static`, `final-qc-pester`); CI on `ebacd29f1` pending at review time; run `43788266034` on the identical non-documentation tree succeeded | `gh pr checks 1196` | CI-dependent; pending-CI, checked off by the orchestrator at S9; not a blocking finding |

---

## Deviations

| ID | Source | Description | Disposition | Blocking |
|----|--------|-------------|-------------|----------|
| AD-1 | PR #1196 body | An extra planner revision after the confirming preflight returned two substantive defects, instead of a `validator_failed` halt. | Judged an acceptable process decision under OD-1: the class is honorable, no gate was bypassed, and the execution preflight found no defect before `[P0-T1]`. | No |

---

## Summary

**Overall Feature Readiness:** READY (pending CI on the PR head for AC-20)

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria (AC-20, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-20 awaits CI on the PR head. This is a pending-CI criterion owned by the orchestrator at S9, not a blocking finding.

**Recommended follow-up verification steps:**

1. At S9, confirm that CI on `ebacd29f1` (or the final head) succeeds, including `PowerShell hook suites (Linux)`, then check off AC-20.
2. Optional: handle `env` value options after another transparent prefix (code-review Low finding).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC-1 to AC-19 were already checked off; the reviewer's PASS evaluations confirm them, so no source-file checkbox change was made. AC-20 stays unchecked (CI-dependent, owned by the orchestrator at S9). The unchecked boxes elsewhere in `spec.md` (severity options, `## Test Strategy` planning items, the repro attachment box) are not acceptance criteria.

### AC Status Summary

- Source: `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: AC-20 (full PowerShell toolchain and CI on the PR head)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 20 | 19 | 1 | AC-20 pending CI on the PR head |
