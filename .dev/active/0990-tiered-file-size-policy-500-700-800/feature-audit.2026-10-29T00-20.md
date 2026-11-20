# Feature Audit: Tiered File-Size Policy 500/700/800 (#990), remediation cycle 2 re-audit

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
**Base Branch:** `main`
**Head Branch:** `feature/tiered-file-size-policy-500-700-800-990`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 2 (prior audit `feature-audit.2026-10-28T23-25.md`)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `a7a928d59fd52610c1a627448c8fffac106b23c5`)
- **Head branch/commit:** `feature/tiered-file-size-policy-500-700-800-990` (commit `b5fe10469d22b54cc6b178e38a0a3dddd30110df`)
- **Merge base:** `a7a928d59fd52610c1a627448c8fffac106b23c5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 00:11:33 UTC for head `b5fe10469`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/**`, including the cycle-2 records
  - Additional evidence: `artifacts/pester/powershell-coverage.xml`, a reviewer Pester and analyzer run, and the reviewer commands listed in the policy audit appendix
- **Feature folder used:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so the AC sources are `spec.md` and `user-story.md`. The unchecked early-draft criteria in `issue.md` are not authoritative.
- **Scope note:** full branch diff against the merge base; no caller narrowing was applied. No PR exists yet (`gh pr list --head <branch> --state all` returned no rows), so CI status on the head is not available.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/spec.md` — primary source
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/user-story.md` — secondary source (identical AC1-AC7 text)

### Acceptance criteria

1. AC1: Policy text in every authoritative and mirrored surface states a three-tier policy (500 guidance, 700 advisory Warning, 800 hard block) and keeps the existing exemption list.
2. AC2: No gate fails for a file between 500 and 800 lines; `feature-review` reports files at or above 700 lines as non-blocking Warning findings.
3. AC3: A CI/Pester check fails for any file over 800 lines that is not on the baseline list, and for any baselined file that grows.
4. AC4: A PreToolUse hook denies a Write or Edit that leaves a covered file above 800 lines, with a message naming the tiers and the split requirement; baselined files may shrink or stay equal.
5. AC5: Every existing test, hook, validator, and document that hard-codes the 500-line limit is updated or confirmed unaffected.
6. AC6: The baseline list is generated deterministically from the repository at the merge base and is reviewable.
7. AC7: All mirrors and bundle copies pass the contract tests, and the seven-stage toolchain passes.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1: three-tier policy text in every surface; exemptions kept | PASS | Policy diffs in `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`, `AGENTS.md`, and `.agents/skills/general-code-change/SKILL.md` state 500/700/800, and the exemptions are unchanged. `evidence/other/residual-500-classification.2026-10-28T21-56.md` reports 0 single-limit statements. | `git diff a7a928d59..HEAD -- <policy files>` | Cycle 2 changed no policy text. |
| 2 | AC2: no gate fails at 500-800; `feature-review` reports >= 700 as non-blocking Warning | PASS | `Compare-FileSizeBaselineEntry` passes any size at or below 800 without an entry, and the hooks allow at or below 800. `## File Size Advisory` in `.claude/agents/feature-review.md` instructs Warning rows for files at or above 700. `evidence/other/code-review-warning-validation.2026-10-28T21-54.md` shows the validator accepts a Warning row. | Inspection of module and agent text | This review applied the advisory and found no changed file at or above 700 lines. |
| 3 | AC3: CI/Pester check fails above 800 without entry and for baselined growth | PASS | `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` applies `Get-FileSizeRatchetViolation` to the tree; its traversal now reads `Get-FileSizeExcludedSegment` (CR-M1). The ratchet rows `new-over-limit` and `grew` are in `FileSizeBaseline.Tests.ps1`. | Full Pester run 11861 / 0 failed (`evidence/qa-gates/pester-full-coverage.2026-10-29T00-08.md`); reviewer gate-suite run passed | Execution on the CI shards is part of AC7's pending CI leg. |
| 4 | AC4: PreToolUse hook denies a Write/Edit leaving a covered file above 800, with tier and split message; baselined files may shrink or stay equal | PASS | Claude and Codex hooks and their suites cover 801 deny, 800 allow, 810 to 815 deny, and 810 to 805 or 810 allow; the deny reason names the tiers, path, count, and split requirement. Both hooks are registered in `.claude/settings.json` and `.codex/config.toml` and the bundle twins. | Inspection; full Pester run | Covered-path behavior unchanged in cycle 2; hook suites pass in the full run. |
| 5 | AC5: every hard-coded 500 limit updated or confirmed unaffected | PASS | `evidence/other/existing-500-assertion-dispositions.2026-10-28T21-47.md`, `evidence/other/it-name-reference-search.2026-10-28T21-46.md`, `evidence/other/residual-500-classification.2026-10-28T21-56.md` | Prior reviewer `git grep` spot check | Unchanged in cycle 2. |
| 6 | AC6: baseline generated deterministically at the merge base and reviewable | PASS | `evidence/baseline/file-size-baseline-generation.2026-10-28T21-45.md`, `generator-hash-before.2026-10-28T22-45.md`, and `generator-hash-after.2026-10-28T22-59.md` record `8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea`, byte-identical to `config/file-size-baseline.json`. The generator consumes `Test-FileSizeCoveredPath`, whose behavior cycle 2 left unchanged; `config/file-size-baseline.json` is not in the cycle-2 diff. | `git diff --stat abb51cc69 b5fe10469` | Unchanged in cycle 2. |
| 7 | AC7: mirrors and bundle copies pass contract tests; seven-stage toolchain passes | UNVERIFIED | Local evidence after cycle 2: format 5/5 unchanged (`format.2026-10-28T23-52.md`), analyze 0 findings (`analyze.2026-10-28T23-52.md`), mirror parity and bundle SHA256 equality (`mirror-parity.2026-10-28T23-52.md`, re-hashed by this review), manifest and epic-runtime contract suites 17 / 17 (`mirror-pester.2026-10-28T23-51.md`), push-down contract tests 27 passed (`push-down-contracts.2026-10-28T23-51.md`), full Pester 11861 / 0 failed. Initial-cycle contract evidence: 211 Python contract tests, generator `--check`, tier check 26/26, Jest 24. CI on the PR head has not run because no PR exists, including the PoshQC shards and the Linux hook-suite job. | Reviewer Pester run 288 / 288 and analyzer 0 findings; `sha256sum` per bundle pair | Pending CI (FA-B1). The item's orchestrator run checks it off at S9. |

---

## Summary

**Overall Feature Readiness:** READY FOR PR (AC7 pending CI)

**Criteria summary:**
- **PASS:** 6 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC7, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. FA-B1 (awaiting CI): AC7 requires CI on the PR head, including the PoshQC shards and the Linux hook-suite job.

**Recommended follow-up verification steps:**

1. Open the PR through `Agent(pr-author)` with `Author-asserted autoclose issues: #990`.
2. Wait for CI success on the PR head, then check off AC7 in both `spec.md` and `user-story.md` at S9. Push the check-off and re-run the CI gate so that `ci_gate.head_sha` equals the final head.

### Blocking findings

#### FA-B1 - AC7 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: AC7 needs CI results on the PR head; no pull request exists for this branch yet, and every local leg of AC7 has passing evidence after cycle 2.
- File/location: `spec.md` and `user-story.md`, `## Acceptance Criteria` item AC7.
- Action: the item's own orchestrator run opens the PR, waits for CI success (including the Linux hook-suite job), checks off AC7 in both files, pushes, and re-runs the CI gate on the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC1-AC6 were already checked in both `spec.md` and `user-story.md`, and this review evaluates each of them as PASS, so the source files need no change. AC7 is UNVERIFIED (pending CI) and remains unchecked in both files. This review made no checkbox change.

### AC Status Summary

- Source: `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/spec.md`, `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/user-story.md`
- Total AC items: 7 (per file)
- Checked off (delivered): 6
- Remaining (unchecked): 1
- Items remaining: AC7: All mirrors and bundle copies pass the contract tests, and the seven-stage toolchain passes.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/spec.md` | 7 | 6 | 1 | Checkbox-backed; AC7 pending CI |
| `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/user-story.md` | 7 | 6 | 1 | Checkbox-backed; AC7 pending CI |
