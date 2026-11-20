# Feature Audit: Tiered File-Size Policy 500/700/800 (#990)

**Audit Date:** 2026-10-28
**Feature Folder:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
**Base Branch:** `main`
**Head Branch:** `feature/tiered-file-size-policy-500-700-800-990`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at `a7a928d59fd52610c1a627448c8fffac106b23c5`)
- **Head branch/commit:** `feature/tiered-file-size-policy-500-700-800-990` (commit `d60b776c3112301cf56ceeb8c4caca352d392b18`)
- **Merge base:** `a7a928d59fd52610c1a627448c8fffac106b23c5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-28 22:27:26 UTC for head `d60b776c3`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, and the reviewer commands listed in the policy audit appendix
- **Feature folder used:** `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so the AC sources are `spec.md` and `user-story.md`. The `issue.md` early-draft criteria are not authoritative.
- **Scope note:** full branch diff against the merge base. No caller narrowing was applied. No PR exists yet, so CI status on the head is not available.

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
| 1 | AC1: three-tier policy text in every surface; exemptions kept | PASS | Diff of `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`, `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md` states 500/700/800; exceptions bullet unchanged; referencing surfaces point to the policy; six execution-environment brief copies share md5 `e76d9151db443e288c43cf0fa2210cad`; bundle twins byte-identical; `evidence/other/residual-500-classification.2026-10-28T21-56.md` reports 0 single-limit statements | `git diff a7a928d59..HEAD -- <policy files>`; `cmp` per bundle pair; `md5sum` over brief copies; `git grep -n -i -E '500[ -]lines?|500-line'` over policy surfaces | Remaining 500 figures are tiered text, historical comments, pinned per-file assertions, or the excluded skill-authoring limit. |
| 2 | AC2: no gate fails at 500-800; `feature-review` reports >= 700 as non-blocking Warning | PASS | `Compare-FileSizeBaselineEntry` passes any S <= 800 without an entry; hook allows <= 800; `ClaudeLibModuleConvention` and `codex-epic-runtime-contracts` general gates moved to the 800 limit; `## File Size Advisory` added to `.claude/agents/feature-review.md` and its `.agents`, `.codex`, `.github` and bundle counterparts; code-review template legend adds `Warning`; `evidence/other/code-review-warning-validation.2026-10-28T21-54.md` shows the validator accepts a Warning row | Inspection of the module and agent diffs; `evidence/other/existing-500-assertion-dispositions.2026-10-28T21-47.md` | Per-file pinned `<= 500` assertions remain on specific files by spec decision 2; they pass and do not act as a general gate. |
| 3 | AC3: CI/Pester check fails above 800 without entry and for baselined growth | PASS | `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` applies `Get-FileSizeRatchetViolation` to the discovered tree; ratchet rows `new-over-limit` and `grew` in `FileSizeBaseline.Tests.ps1`; the suite sits under `tests/scripts` in the existing PoshQC shards | Full Pester run 11812 / 0 failed (`evidence/qa-gates/pester-final-coverage.2026-10-28T22-14.md`) | Execution on CI shards is part of AC7's pending CI leg. |
| 4 | AC4: PreToolUse hook denies a Write/Edit leaving a covered file above 800, with tier and split message; baselined files may shrink or stay equal | PASS | Claude and Codex hooks plus suites: 801 deny, 800 allow, 810 to 815 deny, 810 to 805 and 810 to 810 allow; the deny reason names 500, 700, 800, the path, the count, and the split requirement; registered in `.claude/settings.json` (`Write\|Edit`) and `.codex/config.toml` (`^(apply_patch\|Edit\|Write)$`) and bundle twins; pack manifests list both hooks and the module | Inspection of hooks and registrations; full Pester run | Baseline-free pre-edit ratchet, as specified. |
| 5 | AC5: every hard-coded 500 limit updated or confirmed unaffected | PASS | `evidence/other/existing-500-assertion-dispositions.2026-10-28T21-47.md` (11 suites dispositioned), `evidence/other/it-name-reference-search.2026-10-28T21-46.md`, `evidence/other/residual-500-classification.2026-10-28T21-56.md` (389 hits, 0 single-limit) | Reviewer `git grep` spot check over `.claude`, `.agents`, `.codex`, `.github`, `AGENTS.md`, `scripts`, `extensions/drm-copilot/resources` | No residual single-limit statement found. |
| 6 | AC6: baseline generated deterministically at the merge base and reviewable | PASS | `evidence/baseline/file-size-baseline-generation.2026-10-28T21-45.md`: two runs at `a7a928d59` with equal SHA256 `8ed473b7...f4ea`; `config/file-size-baseline.json` is 7 lines with one entry (`scripts/dev_tools/agentic_sync.py`: 819); generator determinism rows; the repository gate accepts the committed baseline | Evidence inspection; `git diff` of `config/file-size-baseline.json` | Determinism and reviewability hold. The generator's line count diverges from the spec counting convention for files ending in an empty line (PA-B1 / CR-1). That is a spec-conformance defect, not a failure of this criterion's text, and the committed baseline is unaffected. |
| 7 | AC7: mirrors and bundle copies pass contract tests; seven-stage toolchain passes | UNVERIFIED | Local: 211 Python contract tests passed, generator `--check` clean, tier check 26/26, Jest 24 passed, PowerShell format/analyze/test clean (`evidence/qa-gates/`). CI on the PR head, including the Linux hook-suite job for the new hook suites, has not run because no PR exists. | `evidence/qa-gates/contract-tests.2026-10-28T21-59.md`; `evidence/qa-gates/jest-manifest-completeness.2026-10-28T21-59.md` | Pending-CI (FA-B1). Checked off by the item's orchestrator run at S9. The PA-B1 fix requires the local toolchain to be re-run. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 6 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC7, pending CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. PA-B1 / CR-1 (autonomous): `scripts/ci/New-FileSizeBaseline.ps1` undercounts by one any blob whose last line is empty, which contradicts the spec's single counting convention.
2. FA-B1 (awaiting CI): AC7 requires CI on the PR head, including the Linux hook-suite job.

**Recommended follow-up verification steps:**

1. After the PA-B1 fix, re-run `scripts/ci/New-FileSizeBaseline.ps1 -Ref a7a928d59fd52610c1a627448c8fffac106b23c5` to a scratch path and confirm the SHA256 is still `8ed473b7fda2623b51c3b5fa41a5e134398d4e49f1b93ad6649cd5f1ddc6f4ea`. Then re-run the PowerShell toolchain, with a full coverage-enabled `Invoke-PoshQCTest -ScanFolders tests/scripts`.
2. Open the PR, wait for the PoshQC shards and the Linux hook-suite job, and check off AC7 at S9.

### Blocking findings

#### FA-B1 - AC7 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the CI leg of AC7 needs CI results on the PR head, and no pull request exists for this branch yet; the local contract tests and toolchain already pass.
- File/location: `spec.md` and `user-story.md`, `## Acceptance Criteria` item AC7.
- Action: the item's own orchestrator run opens the PR, waits for CI success (including the Linux hook-suite job), checks off AC7 in both files, pushes, and re-runs the CI gate on the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

AC1-AC6 were already checked in both `spec.md` and `user-story.md` by the executor. This review evaluates each of them as PASS, so the source files need no change. AC7 is UNVERIFIED (pending CI) and remains unchecked in both files. This review made no checkbox change.

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
