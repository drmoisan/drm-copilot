# Feature Audit: Harness Survey, Gold-Standard Contracts and Parity Matrix (#1025)

---

**Audit Date:** 2026-11-16
**Feature Folder:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`
**Base Branch:** `epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/harness-survey-gold-standard-contracts-parity-matrix-1025`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/shared-agent-harness-layer-integration` (commit `bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee`)
- **Head branch/commit:** `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (commit `4d23522173644d386848a8651d5267274a6407c9`)
- **Merge base:** `bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-16 05:18:54 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` (final gate), reviewer commands listed per row
- **Feature folder used:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 13 states `- Work Mode: full-feature`, so the AC sources are `spec.md` and `user-story.md`.
- **Scope note:** the audit scope is the full diff `bba58bac..4d23522` (286 files). Two criteria depend on CI at the pull request head, which does not exist yet; they are evaluated as pending-CI, not as failures. The five owner-run runbooks were deferred by the recorded owner-stop decision (`evidence/other/owner-stop-decision.2026-11-16T03-51.md`), and their dependent matrix entries stay `provisional` by design (spec `## Owner Stop`).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` — primary source (`## Acceptance Criteria`, 26 items)
- `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/user-story.md` — secondary source (`## Acceptance Criteria`, 17 items)

### From spec.md

1. Phase 0 gate.
2. Survey completeness.
3. Identity evidence.
4. Per-skill records.
5. Classification and approval artifact.
6. Owner decision recorded.
7. Schema.
8. Matrix.
9. Contracts.
10. Bundle copies.
11. Completeness unit tests: failure cases.
12. Completeness unit tests: pass case.
13. Contract unit tests.
14. Inventory unit tests.
15. Required CI check.
16. Coverage.
17. Schema validation fallback.
18. Test isolation.
19. E5 result.
20. Runbooks.
21. Runbook results.
22. Owner stop recorded.
23. No new Python.
24. File size.
25. Excluded paths untouched.
26. Tier classification.

(Full criterion text is in `spec.md` `## Acceptance Criteria`; the labels above are the bold lead of each item.)

### From user-story.md

27. Survey index has exactly one row per skill name and a zero-difference comparison is recorded.
28. Every recorded difference has a class and port direction and appears exactly once in the approval artifact.
29. The approval artifact records the decision, approver, time, every disputed decision and Q1 to Q8.
30. Every `dropped` entry has a non-empty `reason` and a `decision_ref`, enforced by the two test files.
31. The completeness gate fails on the named inputs and passes on the committed matrix, shown by the named tests and the `poshqc / PowerShell QC` check on the pull request head.
32. E5 result recorded and the five runbooks exist with five sections and a result template.
33. Each runbook has a result or a recorded deferral, with dependent entries left `provisional`.
34. Execution stopped once, recorded with `human_decision_required` and one requirement per pending item, preserved in evidence.
35. No new `.py`, no file over 800 lines, no excluded path changed, each recorded.
36. Matrix and schema exist at their paths, Draft 2020-12 with the `$id`, and the agreement test passes.
37. Every entry carries the required fields with enum values; `shared` and `generated` carry `target_paths` (`generated` also `generated_from`).
38. Every hook registration, permission and subagent frontmatter field has an entry with a `parity_group`.
39. Every shared `codex:skill` contract satisfies `### Contract Format`.
40. Each contract has a byte-identical bundle copy, no pack-manifest entry is added, and the bundle-parity test passes.
41. Each per-skill record uses the record shape with stable Diff IDs referenced by the approval artifact.
42. Every experiment-dependent `copilot:*` entry is `approved` after its result or `provisional` with a well-formed `decision_ref`.
43. Each harness module has at least 85% line coverage, recorded per file.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Phase 0 gate | PASS | `evidence/baseline/phase0-gate.2026-11-16T00-54.md`, `phase0-parallel-run.2026-11-16T00-32.md` | `ls evidence/baseline/phase0-*` | Plan B re-check in `phase0b-*.2026-11-16T03-56.md`. |
| 2 | Survey completeness | PASS | `survey/skill-survey.md`; `evidence/baseline/survey-completeness.2026-11-16T01-21.md` | read of both files | Owner-stop R4 repeated the compare after the sync. |
| 3 | Identity evidence | PASS | `evidence/baseline/skill-identity.2026-11-16T01-20.md` | read | One row per multi-tree name with hashes and class. |
| 4 | Per-skill records | PASS | `survey/batch-a-discovery.md` to `batch-f-authoring-and-review-wrappers.md`, `survey/single-ecosystem.md` | `grep -c "Objective (draft)" survey/*.md` (16, 9, 5, 11, 7, 17 = 65) | Record shape present; Diff IDs `D-<skill>-<nn>`. |
| 5 | Classification and approval artifact | PASS | `survey/difference-approval.md`; `evidence/other/diff-id-reconciliation.2026-11-16T04-16.md` | `grep -n "^## " survey/difference-approval.md` | All five headings present; 278 bulk rows, 19 disputed cases. Rationale texts are templated (code review CR-3, Info). |
| 6 | Owner decision recorded | PASS | `difference-approval.md` lines 3-5, `Owner-Decision: A` for 19 cases, Q1 to Q8 answered | `grep -n "Approval-Status\|Approved-\|Owner-Decision"` | `Approved-By` records the autonomous orchestrator decision (CR-4, Info). |
| 7 | Schema | PASS | `config/harness-parity-matrix.schema.json`; RepoGate Its 1 and 2 passed | read of `final-pester-b.2026-11-16T05-10.md` (RepoGate 7 passed) | Agreement scope per D-R6. |
| 8 | Matrix | PASS | `config/harness-parity-matrix.json` (655 entries); RepoGate `committed matrix has no violation against the live inventory` passed | `pwsh` group-by of the matrix | No untracked file under the listing roots (`git ls-files --others`). |
| 9 | Contracts | PASS | 65 contracts; RepoGate `every shared codex skill has a conforming contract` passed | `ls .agents/skills/*/references/standard.md` (65) | Rules 1 to 7 hold. Content findings CR-1 and CR-2 (truncated items, placeholder objectives) are blocking in the code review; they concern sentence content that the rules do not test. |
| 10 | Bundle copies | PASS | `final-contract-checks-b.2026-11-16T05-11.md` (92 passed) | `cmp` of all 65 pairs (no difference) | |
| 11 | Completeness unit tests: failure cases | PASS | `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` | `grep -oE "It '[^']+'"` | Each named input has an `It`; 76 passed. |
| 12 | Completeness unit tests: pass case | PASS | `It 'reports no violation for a valid matrix covering every disposition...'`; RepoGate passed | same | |
| 13 | Contract unit tests | PASS | `tests/scripts/harness/HarnessSkillContract.Tests.ps1` (25 passed) | same | |
| 14 | Inventory unit tests | PASS | `tests/scripts/harness/HarnessInventory.Tests.ps1` (41 passed) | read of test file | In-memory listings only. |
| 15 | Required CI check | UNVERIFIED | No pull request exists; local gate passed (27468 passed, 0 failed) | `artifacts/pr_context.summary.txt` ("no PR exists yet") | Pending-CI by design; checked off by the orchestrator at S9. Not a failure. |
| 16 | Coverage | PASS | 100.00% (220/220), 99.25% (133/134), 100.00% (66/66) | reviewer parse of `artifacts/pester/powershell-coverage.xml` | Matches `final-pester-b.2026-11-16T05-10.md`. |
| 17 | Schema validation fallback | PASS | RepoGate line 104 `-Skip:($PSVersionTable.PSVersion -lt [version]'7.4')` | read of test file | No gate depends on `Test-Json`. |
| 18 | Test isolation | PASS | `pester-baseline*.md`, `phase-gate.P*.md`, `final-pester-b.2026-11-16T05-10.md`, `final-leak-scan-b.2026-11-16T05-10.md` (0 failures) | read | Parallel runs only. |
| 19 | E5 result | PASS | `evidence/other/e5-claude-hooks-subagent-permissions-documentation.2026-11-16T01-23.md` | read | |
| 20 | Runbooks | PASS | five files under `runbooks/`, each with five H2 sections and an `EXIT_CODE` template field | `grep -c '^## '` (5 each) | |
| 21 | Runbook results | PASS | `difference-approval.md` `## Owner Overrides` deferral rows E1 to E6; 314 provisional entries reference the runbooks | `pwsh` group-by of `decision_ref` | Deferral per the recorded owner-stop decision. |
| 22 | Owner stop recorded | PASS | `evidence/other/owner-stop.2026-11-16T03-50.md` (1 halt, 5 exception) | read | |
| 23 | No new Python | PASS | `no-new-python-b.2026-11-16T05-12.md` (AddedPy 0) | `git diff --name-only bba58bac..HEAD` (no `.py`) | |
| 24 | File size | PASS | `file-size.2026-11-16T03-41.md`; file-size It passed in the final gate | `@(Get-Content).Count` (largest 515) | |
| 25 | Excluded paths untouched | PASS | `excluded-paths-b.2026-11-16T05-12.md` (SpecExcludedTouched 0) | `grep` of the PR diff names against the excluded list | Matches are contract files only. |
| 26 | Tier classification | PASS | `quality-tiers.yml` entry; `final-contract-checks-b.2026-11-16T05-11.md`; `tier-classification-fail-before.2026-11-16T02-14.md` | `git diff bba58bac..HEAD -- quality-tiers.yml` | |
| 27 | Survey one row per name | PASS | as row 2 | as row 2 | |
| 28 | Every difference classified and placed once | PASS | as row 5 | as row 5 | |
| 29 | Approval artifact records the decision | PASS | as row 6 | as row 6 | |
| 30 | Dropped entries have reason and decision_ref | PASS | 43 `copilot:skill` dropped entries; RepoGate and unit tests passed | `pwsh` group-by | |
| 31 | Completeness gate fails and passes as named, with the CI check | UNVERIFIED | unit and repository tests passed locally | as row 15 | Pending-CI by design; checked off at S9. Not a failure. |
| 32 | E5 result and runbooks | PASS | as rows 19 and 20 | as rows 19 and 20 | |
| 33 | Runbook results or deferral | PASS | as row 21 | as row 21 | |
| 34 | Single owner stop recorded | PASS | as row 22 | as row 22 | |
| 35 | No new `.py`, size and excluded paths | PASS | as rows 23 to 25 | as rows 23 to 25 | |
| 36 | Matrix and schema paths and agreement | PASS | as row 7 | as row 7 | |
| 37 | Required fields and conditional fields | PASS | RepoGate violation-free | as row 8 | |
| 38 | parity_group on hook, permission and subagent field entries | PASS | RepoGate `every hook-registration permission and subagent-frontmatter-field entry has a parity_group` passed | read | |
| 39 | Contracts satisfy `### Contract Format` | PASS | as row 9 | as row 9 | See CR-1 and CR-2 for content. |
| 40 | Bundle copies, no manifest entry, parity test | PASS | as row 10; no `pack-manifests/core.json` in the diff | `grep` of the PR diff names | |
| 41 | Record shape and stable Diff IDs | PASS | `diff-id-reconciliation.2026-11-16T04-16.md` | read | |
| 42 | Experiment-dependent copilot entries | PASS | 50 `copilot:agent` provisional with the E3 runbook ref; 43 `copilot:skill` dropped and approved (D-R4) | `pwsh` group-by | |
| 43 | Harness module coverage at least 85% | PASS | as row 16 | as row 16 | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 41 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (both pending-CI by design: spec `Required CI check`, user-story `The completeness gate fails on`)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Code review CR-1: 25 truncated or dangling Observable Behavior items in 21 contracts and their bundle copies.
2. Code review CR-2: placeholder `## Objective` in 7 contracts and their bundle copies.
3. The two CI-dependent criteria await CI on the pull request head (expected; not a remediation item).

**Recommended follow-up verification steps:**

1. After the light fix, re-run the repository gate (`HarnessParityMatrix.RepoGate.Tests.ps1` within the parallel gate) and the Python bundle-parity contract set, and confirm that `grep -n ";\.$\|,\.$\|listed above"` and `grep -l "Produce the outcome that the"` over the contracts return nothing.
2. At S9, confirm `poshqc / PowerShell QC` passes on the pull request head and check off the two CI-dependent criteria.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### Acceptance Criteria Status

- Source: `spec.md`, `user-story.md`
- Total AC items: 43
- Checked off (delivered): 41
- Remaining (unchecked): 2
- Items remaining: spec `**Required CI check.** The poshqc / PowerShell QC check passes on the pull request head, including the tests under tests/scripts/harness/ (CI-dependent; checked off at S9).`; user-story `The completeness gate fails on an inventoried feature without an entry, a missing disposition, a dropped entry without a reason, and an unknown enum value, and passes on the committed matrix, as shown by the named tests in tests/scripts/harness/HarnessParityMatrix.Tests.ps1 and the poshqc / PowerShell QC check on the pull request head.`

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 26 | 25 | 1 | Checkbox-backed; the unchecked item is CI-dependent |
| `user-story.md` | 17 | 16 | 1 | Checkbox-backed; the unchecked item is CI-dependent |

No source-file checkbox change was made in this review: every criterion evaluated PASS was already checked, and the two UNVERIFIED criteria stay unchecked for the orchestrator's S9 check-off. The spec `## Definition of Done` items are not acceptance criteria and were not changed.
