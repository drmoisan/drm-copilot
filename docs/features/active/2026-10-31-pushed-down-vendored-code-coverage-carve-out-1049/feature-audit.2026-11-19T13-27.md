# Feature Audit: Pushed-Down Vendored Code Coverage Carve-Out (#1049)

**Audit Date:** 2026-11-19
**Feature Folder:** `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/pushed-down-vendored-code-coverage-carve-out-1049`
**Work Mode:** `full-feature`
**Audit Type:** Opening review

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (resolved at `021a52e74999d17c6ae67ed7a32c14958448ceab`, equal to the merge base)
- **Head branch/commit:** `feature/pushed-down-vendored-code-coverage-carve-out-1049` (commit `a9fcaf343c8966df05f10a517b0cae9b3d0bb358`)
- **Merge base:** `021a52e74999d17c6ae67ed7a32c14958448ceab`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-19 13:16:23 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/*`, `evidence/other/phase0-gate*.md`, `evidence/other/task-check.*.md`, `evidence/qa-gates/*` (final QC, coverage delta, rules generation, brief update, bundle copy, AC status, self-review)
  - Additional evidence: reviewer reads of `artifacts/pester/powershell-coverage.xml` (repo 47306/48882 lines; `PoshQC.VendoredCoverage.psm1` 109/110) and `extensions/drm-copilot/coverage/lcov.info` (68431/70241 lines, 10598/11199 branches); reviewer `sha256sum` of the six brief copies (all `5f471c53...0f3b`) and of the PoshQC source/bundle pairs (equal); `validate_evidence_locations.py --root .` exit 0
- **Feature folder used:** `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so the AC sources are `spec.md` (`## Acceptance Criteria`) and `user-story.md` (`## Acceptance Criteria`). The `issue.md` "Acceptance Criteria (early draft)" checklist is not an AC source in this mode.
- **Scope note:** The review covers the full branch diff from the merge base. The last three commits change only feature-folder files, so the final QC runs (Pester 13:04Z, Jest 13:07Z, pytest 12:52Z) measured the code state of the head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/spec.md` — primary source (15 items)
- `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/user-story.md` — secondary source (10 items)

### From spec.md

1. Rule source carries the **Vendored push-down files** paragraph (exact path, matching canonical hash, tooling-derived), and every generated output and bundle copy matches (`-Surface rules -Check` exits 0).
2. Rule text and generated copies omit `not used in this repository` and consuming-product names; the two guarding pytest modules pass unmodified.
3. Jest end-to-end apply test asserts manifest `sha256` equals the hash of written bytes for `create`, `update`, `adopt`, `converged`.
4. Jest and Pester read the same committed corpus and both produce the expected digests, without temporary files.
5. Pester tests of `Get-PoshQCVendoredCoverageStatus` show `exempt`, `modified`, `missing`, `unlisted`, including case-renamed and reparse-point cases.
6. With the opt-in, an invalid manifest fails the run naming `.push-down-manifest.json`; an absent manifest exempts nothing and logs one warning.
7. `Resolve-PoshQCCoveragePopulation` subtracts `exempt` paths only for `config` with the opt-in; `settings` and fallback unchanged; no exclusion path written.
8. Destination-added `.claude/hooks/*.ps1` is `unlisted` and retained.
9. `vendored-coverage-exemptions.json` written beside the coverage output file, sorted, no timestamps or absolute paths.
10. Enforcement sentence and the feature-review `## Coverage Verification` step carry both Blocking clauses and recognize the manifest-derived exemption.
11. Rule paragraph and PoshQC README (and bundle copy) state the ownership policy.
12. Pester repo-gate test: no opt-in key in `config/poshqc-coverage.json`; no root `.push-down-manifest.json`.
13. Every execution-environment brief copy carries the updated sentence and the copies are identical.
14. `test_poshqc_bundled_parity.py` and the two push-down resource contract modules pass; PoshQC files byte-equal to bundle copies.
15. Coverage: no regression on changed lines; >= 85% line per changed PowerShell production file; >= 85%/75% per changed TypeScript production file.

### From user-story.md

16. Maintainer can read the exception conditions in the pushed-down rule.
17. Manifest records path and canonical hash for every written file, matching the written bytes.
18. A modified or unlisted file is not exempt and stays in the denominator.
19. A destination-added hook stays in the denominator.
20. One boolean key enables the exemption; no hand-written path.
21. Invalid manifest fails the run naming the file; missing manifest exempts nothing.
22. Reviewer can verify from the sorted report without timestamps or absolute paths.
23. Rule and feature-review step treat hand-written exclusions and hand-edited hashes as Blocking and recognize the manifest-derived exemption.
24. Rule and README state the ownership policy.
25. This repository does not opt in, enforced by a repo-gate test.

---

## Acceptance Criteria Evaluation

Pester evidence: `evidence/qa-gates/final-pester.2026-11-19T13-05.md` (29313 tests, 0 failed). Jest evidence: `evidence/qa-gates/final-jest.2026-11-19T13-07.md` (6142 and 6159 passed). pytest evidence: `evidence/qa-gates/final-pytest.2026-11-19T12-52.md` (17122 passed).

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Vendored paragraph in rule source; generated copies match | PASS | `scripts/harness-generation/sources/rules/general-unit-test.md` diff; `rules-generation.2026-11-19T11-36.md` (rules/agents/skills `-Check` exit 0); `final-contracts.2026-11-19T13-07.md` (`-Surface all -Check` exit 0); RepoGate `every general-unit-test copy carries the vendored push-down paragraph` | `Invoke-HarnessGeneration.ps1 -Surface all -Check` | Reviewer read the paragraph text in the source and the Copilot output |
| 2 | Forbidden phrase and product names absent; guard tests unmodified | PASS | Neither guard module is in the branch diff; pytest 17122 passed including both; RepoGate `no general-unit-test copy says not used in this repository` | `run-test-suite.sh pytest` | |
| 3 | Apply hash-of-written-bytes invariant (four actions) | PASS | `push-down-apply-hash-invariant.test.ts`: action map asserts `create`, `update`, `adopt`, `converged`; per-entry hash recomputed with `node:crypto` | `run-test-suite.sh jest-extension --coverage` | |
| 4 | Shared corpus, Jest and Pester digests | PASS | `tests/fixtures/push-down-manifest-hash/corpus.json`; `push-down-hash-parity.test.ts` reads it; Pester `produces the corpus digest for <Name>` and the no-CR/no-non-ASCII check; `corpus-digests.2026-11-19T09-19.md` | Jest and Pester runs | No temporary file in either test |
| 5 | Status classification incl. case rename and reparse point | PASS | `PoshQC.VendoredCoverage.Tests.ps1` cases for each status, `reports a case-renamed file unlisted`, `reports modified for a reparse point` | `run-test-suite.sh pester` | Leaf-only reparse check noted as a Minor code-review finding |
| 6 | Invalid manifest fails the run; absent manifest one warning | PASS | Ten `throws naming .push-down-manifest.json for <Case>` cases (malformed JSON, unknown major, absolute, drive-letter, UNC, backslash UNC, `..`, and others); `stops before Pester when the resolver throws for an invalid manifest`; `logs one warning and exempts nothing when the manifest is absent` | same | |
| 7 | Subtraction only for `config` with opt-in; no exclusion path written | PASS | `PoshQC.CoverageConfig.Tests.ps1` new cases (with/without opt-in, `settings`, `fallback`); writer test asserts no write to `config/poshqc-coverage.json` | same | |
| 8 | Destination-added hook `unlisted` and retained | PASS | `reports a destination-added .claude/hooks file unlisted`; `keeps a destination-added .claude/hooks file in the population` | same | |
| 9 | Report beside the coverage output file, sorted, no timestamps/absolute paths | PASS | `renders sorted report JSON without timestamps or absolute paths`; `writes the report beside the coverage output file for <Case>` (default and shard paths); AD-3 fallback case | same | |
| 10 | Enforcement sentence and feature-review step | PASS | Rule source Enforcement sentence; `scripts/harness-generation/sources/agents/feature-review.md` step 2 sub-bullet in both coverage sections; generated `.claude/agents/feature-review.md` and `.codex/agents/feature-review.toml`; RepoGate cases for both | same | |
| 11 | Ownership policy in rule and README | PASS | Rule paragraph bullets 3-4; `scripts/powershell/PoshQC/README.md` "Ownership policy" bullet; bundle README SHA-256 equal; RepoGate `README states the ownership policy` | same | |
| 12 | Repo gate: no opt-in, no root manifest | PASS | `PoshQC.VendoredCoverage.RepoGate.Tests.ps1` first two cases; reviewer: `.push-down-manifest.json` absent at the worktree root; `config/poshqc-coverage.json` not in the branch diff | same | |
| 13 | Brief copies updated and identical | PASS | Reviewer `sha256sum` of the six copies: all `5f471c53ec5ed1bc651072e99c9f6887941ec36cdf3efc57ca4c822e28630f3b`; `brief-update.2026-11-19T11-36.md` | `sha256sum` | |
| 14 | Parity and contract tests; bundle byte-equality | PASS | pytest 17122 passed including the three named modules; reviewer `sha256sum` of the PoshQC source/bundle pairs equal | `run-test-suite.sh pytest`; `sha256sum` | |
| 15 | Coverage thresholds and no regression | PASS | `coverage-delta-powershell.2026-11-19T13-06.md`; reviewer read of `powershell-coverage.xml`: `PoshQC.VendoredCoverage.psm1` 109/110 (99.09%), `PoshQC.Coverage.psm1` 112/118 (94.92%), `PoshQC.Testing.psm1` 215/228 (94.30%), `PoshQC.psm1` 54/61 (88.52%); changed lines 100% covered in modified files; no TypeScript production file changed | XML counter read | |
| 16 | Rule states the exception conditions | PASS | Same evidence as 1 | same | |
| 17 | Manifest path and hash match written bytes | PASS | Same evidence as 3 and 4 | same | Writer owned by child 4 |
| 18 | Modified and unlisted not exempt | PASS | Same evidence as 5 and 7 (`keeps modified and unlisted files in the population`) | same | |
| 19 | Destination-added hook stays in denominator | PASS | Same evidence as 8 | same | |
| 20 | One boolean key, no hand-written path | PASS | `Get-PoshQCVendoredCoverageOptIn` cases (absent, true, false, non-boolean throws); same evidence as 7 | same | |
| 21 | Invalid manifest fails; missing manifest exempts nothing | PASS | Same evidence as 6 | same | |
| 22 | Verifiable sorted report | PASS | Same evidence as 9 | same | |
| 23 | Rule and review step Blocking clauses | PASS | Same evidence as 10 | same | |
| 24 | Ownership policy stated | PASS | Same evidence as 11 | same | |
| 25 | This repository does not opt in | PASS | Same evidence as 12 | same | |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Every acceptance criterion is met at the head with test and artifact evidence that the reviewer read or recomputed. The policy-file edits are within `spec.md` `## Owner Authorization`.

**Top gaps preventing PASS:**

None.

**Pending-CI (not blocking):** CI on the PR head (`poshqc / PowerShell QC` shards on windows-latest, the Linux hook suites, the extension Jest jobs, and the Python quality job), confirmed by the S9 CI gate after the PR is opened.

**Recommended follow-up verification steps:**

1. After the PR is opened, confirm `CI Required Gate` and the PowerShell QC shards pass at the final head.
2. Optional hardening noted in the code review (parent-directory reparse points; case-variant manifest keys) can be considered by child 10 (#1051), which consumes the status vocabulary.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 25 criteria were already checked (`- [x]`) in the source files at the reviewed head (executor check-off at [P4-T8], committed in `a9fcaf343`), and all evaluate PASS, so this review made no checkbox change. The unchecked `## Definition of Done` items and the `CLI/API examples` item under `## Seeded Test Conditions` in `spec.md` are not acceptance criteria.

### AC Status Summary

- Source: `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/spec.md`, `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/user-story.md`
- Total AC items: 25
- Checked off (delivered): 25
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/spec.md` | 15 | 15 | 0 | Checkbox-backed (`## Acceptance Criteria`) |
| `docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/user-story.md` | 10 | 10 | 0 | Checkbox-backed |
