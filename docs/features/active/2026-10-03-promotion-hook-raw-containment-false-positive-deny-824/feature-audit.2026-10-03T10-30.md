# Feature Audit: Promotion hook raw-containment false-positive deny (#824)

---

**Audit Date:** 2026-10-03
**Feature Folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Base Branch:** `origin/main`
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
- **Head branch/commit:** `bug/promotion-hook-raw-containment-false-positive-deny-824` (commit `90566dd4b1fa172cf6b559c79a2cb392211c6498`)
- **Merge base:** `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (head-bound to 90566dd4)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/**`
  - Additional evidence: reviewer re-runs (17 affected Pester suites with coverage, 359 pass; four parity pytest files, 27 pass; check-only format and analyzer; hash parity; grep checks; merge-base versus head decision probes)
- **Feature folder used:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
- **Requirements source:** `spec.md` (only source)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the sole AC source. The `issue.md` acceptance checklist is not authoritative and was not edited.
- **Scope note:** Full branch diff against `origin/main` (103 files). No PR exists yet, so CI-dependent AC-27 cannot be evaluated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` — only source

### Acceptance criteria

1. AC-1: R2 of `Resolve-CommandLineInvocation` calls `Test-CommandLineRawInvocation` (new `hook-command-raw-invocation.ps1`), not `Test-CommandLineRawContainment`, on both surfaces.
2. AC-2: No classification or deny decision uses `Test-CommandLineRawContainment`; its only caller is `Test-CommandLineMention`.
3. AC-3: An Unbalanced segment (`echo "unterminated`) is still denied by the promotion hook on both runtimes.
4. AC-4: New raw-invocation unit suites exist on both runtimes and pass, with the listed positive and negative cases.
5. AC-5: The exact reproduction command is allowed by the promotion hook on both runtimes.
6. AC-6: The wrapped "through"/"issue"/"New-Object" payload is allowed on both runtimes.
7. AC-7: `gh issue create --title x` is denied.
8. AC-8: `gh issue new --title x` is denied.
9. AC-9: `GH  Issue  Create` is denied.
10. AC-10: `pwsh -NoProfile -Command 'gh issue create --title x'` is denied.
11. AC-11: `pwsh -c "& gh issue new"` is denied.
12. AC-12: `bash -c "gh issue create"` is denied.
13. AC-13: `gh api repos/o/r/issues -X POST` is denied.
14. AC-14: Detection of real bypasses that raw containment caught before the fix is not weakened: `bash -c "gh -R o/r issue create"`, `bash -c 'x=create; gh issue $x'`, and `bash -c 'c=gh; $c issue create'` are each denied, and `gh --repo o/r issue list` is allowed.
15. AC-15: Negative control in `hook-command-invocation.Tests.ps1` (both surfaces): containment `$true` and invocation `$false` in the same `It`; reverting R2 makes it fail.
16. AC-16: The "any arrangement" test is renamed on both surfaces with assertions retained; all research 6.1 wrapper deny pins pass without assertion edits.
17. AC-17: Audit record `evidence/other/containment-path-hook-audit.md` exists with the required hooks, effects, dispositions, the abandon-gate note, and the N1 citation.
18. AC-18: The pr-author hook allows the wrapped `Select-String ... "high priority" ... "create"` command.
19. AC-19: Worktree-removal gates allow the wrapped `git worktree list` filtered on "removed" and still deny `bash -c "git worktree remove ../x"`.
20. AC-20: `validate-bash` returns no blocked pattern for `pwsh -NoProfile -f ./scripts/legit-push.ps1`.
21. AC-21: `Test-ImplementationCommand` is `$false` for the wrapped "digit address" payload, and the epic merge gate still routes `bash -c "gh pr merge --merge 688"` to its checkpoint check.
22. AC-22: Comments at `hook-command-invocation.ps1` :96-99, :172-174, :28-30 corrected on both surfaces; no "only forces a checkpoint check" match in hooks roots or extension resources.
23. AC-23: `.claude`/`.codex` copies of both helper files are content-identical.
24. AC-24: Canonical files are byte-identical to their extension mirrors and both manifests list the new module; the four parity pytest files pass.
25. AC-25: `legacy-codex-hook-contracts.Tests.ps1` lists the new module on its existing line, stays at or below 497 lines, and passes.
26. AC-26: PoshQC format leaves no changes, analyze reports zero errors, test with coverage passes with >= 85% line coverage per changed or new hooks file and no uncovered changed lines; evidence in `evidence/qa-gates/`.
27. AC-27: The repository's full toolchain passes on the PR head, including the Windows PoshQC job and the Linux hook-suite Pester job (CI-dependent).
28. AC-28: No changed or added file exceeds 500 lines.
29. AC-29: Public parameter signatures of the four resolver-family functions are unchanged; signature-pin tests pass without edits.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 R2 calls the token-aware matcher | PASS | Diff line 211 on both helpers; new module present on both roots | `git diff origin/main...HEAD -- .claude/hooks/` and grep inside `Resolve-CommandLineInvocation` | One call to `Test-CommandLineRawInvocation`, zero to containment, per surface |
| 2 | AC-2 containment only feeds `Test-CommandLineMention` | PASS | Grep returns line 94 (definition) and line 490 (`Test-CommandLineMention`) on each surface only | `grep -rn Test-CommandLineRawContainment .claude/hooks .codex/hooks` | No classification path retains loose containment |
| 3 | AC-3 Unbalanced segment still denied | PASS | P824-D11 in both promotion suites asserts deny with the gh-issue reason | `Invoke-Pester` on the 17 affected suites | Passed in reviewer run |
| 4 | AC-4 raw-invocation unit suites | PASS | R824-P1..P20 and R824-N1..N7 on both runtimes cover every listed case | `Invoke-Pester` (reviewer) | All 54 rows pass |
| 5 | AC-5 reproduction allowed | PASS | P824-A1 (both runtimes); reviewer probe through `Invoke-PromotionMcpOnlyDecision` shows deny at merge base and allow at head on both runtimes | reviewer probe script; `Invoke-Pester` | Defect reproduced at base and fixed at head |
| 6 | AC-6 wrapped through/issue/New-Object allowed | PASS | P824-A2 (both runtimes) | `Invoke-Pester` | |
| 7 | AC-7 `gh issue create --title x` denied | PASS | P824-D1 (both) asserts exact reason | `Invoke-Pester` | |
| 8 | AC-8 `gh issue new --title x` denied | PASS | P824-D2 (both) | `Invoke-Pester` | |
| 9 | AC-9 `GH  Issue  Create` denied | PASS | P824-D3 (both) | `Invoke-Pester` | |
| 10 | AC-10 pwsh -Command gh issue create denied | PASS | P824-D4 (both) | `Invoke-Pester` | |
| 11 | AC-11 `pwsh -c "& gh issue new"` denied | PASS | P824-D5 (both) | `Invoke-Pester` | |
| 12 | AC-12 `bash -c "gh issue create"` denied | PASS | P824-D6 (both) | `Invoke-Pester` | |
| 13 | AC-13 `gh api ... -X POST` denied | PASS | P824-D7 (both) | `Invoke-Pester` | |
| 14 | AC-14 bypass detection not weakened | PARTIAL | The three enumerated deny cases (P824-D8..D10) and the allow case (P824-A3) pass. Reviewer probes show five wrapped forms denied at merge base and allowed at head on both runtimes: `bash -c 'cmd="issue create"; gh $cmd'`, `pwsh -c '$a = "issue","create"; gh @a'`, `bash -c 'args=(issue create); gh "${args[@]}"'`, a wrapped backslash-newline continuation, and `bash -c 'a="worktree remove"; git $a ../x'` (epic worktree gate) | reviewer probe script at `git archive f6ef5b2f` and at head | Contradicts the criterion's general clause; code review CR-1; unchecked in `spec.md` |
| 15 | AC-15 negative control | PASS | N824-1 on both surfaces; reviewer simulated the R2 revert in-process and `Test-CommandLineInvocation` returned `True`, so the test fails on revert | reviewer probe script; `Invoke-Pester` | Discrimination verified, not assumed |
| 16 | AC-16 rename with retained assertions; 6.1 pins pass | PASS | Line 207 renamed on both surfaces; the diff hunks touch only the title line in that block; full suites pass | `git diff -U0` of both test files; `Invoke-Pester` | |
| 17 | AC-17 audit record | PASS | `evidence/other/containment-path-hook-audit.md` lists all 13 required hook rows with call sites, effect, disposition, covering test; abandon-gate note; Claim N1 citation | file inspection | |
| 18 | AC-18 pr-author allows high-priority create | PASS | A824-PR1 | `Invoke-Pester` | |
| 19 | AC-19 worktree gates allow list, deny remove | PASS | A824-WT1/WT2 in Claude epic, Claude parallel, Codex epic suites | `Invoke-Pester` | The enumerated cases pass; the split-expansion form is covered under AC-14 |
| 20 | AC-20 validate-bash legit-push | PASS | A824-VB1 (both runtimes) | `Invoke-Pester` | |
| 21 | AC-21 preimplementation false; merge gate routes | PASS | A824-PI1 (both), A824-MG1 (both) | `Invoke-Pester` | |
| 22 | AC-22 comments corrected | PASS | Diff shows all three comment blocks rewritten on both surfaces; grep for the phrase returns no match (exit 1) | `grep -rn "only forces a checkpoint check" .claude/hooks .codex/hooks extensions/drm-copilot/resources` | |
| 23 | AC-23 runtime copies identical | PASS | One distinct SHA-256 per file across `.claude` and `.codex` | `sha256sum` on each pair | |
| 24 | AC-24 mirror parity and manifests | PASS | One distinct SHA-256 per four-file group; both manifests carry the new path; 27 parity pytest cases pass | `poetry run pytest` on the four listed files | |
| 25 | AC-25 legacy contracts list | PASS | Module appended on line 30; file is 497 lines (unchanged count); suite passed in reviewer run | `wc -l`; `Invoke-Pester` | |
| 26 | AC-26 PoshQC loop with coverage | PASS | Format 0 rewritten, analyze 0 findings, 6626 tests 0 failures; raw-invocation modules 100%, helpers 99.20% and 97.60%; changed lines 18 and 211 hit; reviewer re-parsed the JaCoCo XML and re-ran check-only format and analyze | `evidence/qa-gates/poshqc-*.md`, `coverage-delta.2026-10-03T10-13.md`; reviewer parse of `artifacts/pester/powershell-coverage.xml` | |
| 27 | AC-27 full toolchain on PR head (CI) | UNVERIFIED | No PR exists for the branch (`gh pr list --head ...` returned an empty list) | `gh pr list --repo drmoisan/drm-copilot --head bug/promotion-hook-raw-containment-false-positive-deny-824 --state all` | Pending CI; owned by the orchestrator at S9 |
| 28 | AC-28 500-line limit | PASS | Maximum 497 lines across all 25 changed `.ps1` files | `wc -l` on every changed file | |
| 29 | AC-29 signatures unchanged | PASS | Signature-pin blocks untouched by the diff; suites pass | `git diff -U0`; `Invoke-Pester` | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 27 criteria
- **PARTIAL:** 1 criteria (AC-14)
- **UNVERIFIED:** 1 criteria (AC-27, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-14: five wrapped bypass forms that the merge-base hooks denied are allowed at head (code review CR-1; remediation inputs R1).
2. AC-27: CI has not run because the PR has not been opened; this is the expected pending-CI state.

**Recommended follow-up verification steps:**

1. After remediation, re-run the reviewer's merge-base versus head probe for the five forms and confirm deny on both runtimes, with the reproduction and AC-6, AC-18, and AC-19 allow cases still allowing.
2. Open the PR and run the S9 CI gate for AC-27.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

Changes made to `spec.md` by this review:
- AC-14 was unchecked (`- [x]` changed to `- [ ]`). The executor had checked it off, and this review grades it PARTIAL. The criterion text was not modified.
- No newly checked items: the 27 PASS criteria were already checked by the executor and are confirmed.
- AC-27 remains unchecked (pending CI).

### AC Status Summary

- Source: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md`
- Total AC items: 29
- Checked off (delivered): 27
- Remaining (unchecked): 2
- Items remaining: AC-14 (detection of real bypasses not weakened; PARTIAL); AC-27 (full toolchain on the PR head; pending CI)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` | 29 | 27 | 2 | Checkbox-backed; AC-14 unchecked by this review |
