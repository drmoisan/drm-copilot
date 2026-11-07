# Policy Compliance Audit: epic-main-sync-plain-merge (Issue #1117)

**Audit Date:** 2026-11-07
**Work Mode:** minor-audit
**Scope:** full branch diff against the merge base of origin/main and HEAD (head c1fc64275599b77ca9f93e232a56d66e27018647)
**Code Under Test:** `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, the two bundled copies under `extensions/drm-copilot/resources/`, `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, ledger entry `docs/engineering/process-reductions/0007-epic-main-sync-plain-merge.md`, the ledger README row, and feature-folder documents and evidence.

## Executive Summary

The branch replaces the dedicated sync child item in the epic integration branch lifecycle with a plain merge of `origin/main` performed by `epic-orchestrator`, in four skill copies, with the contract test and the pinned digest updated and a ledger entry added. All applicable policies are satisfied. Python is the only changed coverage language (two test files); the repo-wide Python figures equal the Phase 0 baseline. No blocking finding was identified. Overall verdict: PASS.

## Rejected Scope Narrowing

None. The caller prompt stated an owner ruling about the change content (no added sync rules, gates, routes, or conflict handling). That ruling concerns what the change must contain and does not narrow the audit scope, the toolchain checks, or the coverage checks. The full branch diff was audited.

## Evidence Location Compliance

- Evidence files in the diff live under `docs/features/active/2026-11-07-epic-main-sync-plain-merge-1117/evidence/baseline/`, `evidence/qa-gates/`, and `evidence/other/`. All are canonical locations.
- No file in the diff is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none; the caller supplied no non-canonical path.
- Disposition: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

- Independence, isolation, determinism: PASS. The new tests read tracked skill text and operate on in-memory strings; no clock, randomness, network, or temporary file is used.
- Fast execution: PASS. The contract module and surface-contract module ran in 0.24 s (56 passed) in this review.
- Readability: PASS. Test names state the scenario; the new assertion helper names the retired phrase in its failure message.
- Test location: PASS. Tests remain under `tests/scripts/dev_tools/`.

### 1.2 Coverage

Coverage artifacts: the Python artifact `artifacts/python/lcov.info` is present. No PowerShell, TypeScript, or C# file changed in the branch diff. The PowerShell artifact `artifacts/pester/powershell-coverage.xml` is present and was read for the unchanged-baseline cross-check.

Thresholds: the root `CLAUDE.md` states no coverage thresholds, so the defaults govern (85 percent line, 75 percent branch).

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 test files | 16218 tests | PASS 16218 pass, 0 fail | 96.99% lines, 94.17% branches | 96.99% lines, 94.17% branches | N/A - no production file changed |
| PowerShell | 0 files | 15984 tests | PASS 15984 pass, 0 fail | 94.10% lines | 94.10% lines | N/A - zero changed PowerShell files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.99% lines and 94.17% branches. Post-change: 96.99% lines and 94.17% branches. Change: 0.00 points on both. Disposition: PASS. Evidence: totals recomputed in this review from `artifacts/python/lcov.info` (LH 32456 of LF 33464, BRH 11828 of BRF 12560) and the final gate record `evidence/qa-gates/pytest.2026-11-07T21-12.md`. Both exceed the 85 percent and 75 percent thresholds. The two changed Python files are tests, outside the production denominator, so the changed-line regression rule has no production line to evaluate.
- PowerShell: Baseline: 94.10% lines. Post-change: 94.10% lines. Change: 0.00 points. Disposition: PASS. Evidence: LINE counter in `artifacts/pester/powershell-coverage.xml` (covered 24578, missed 1540) and `evidence/qa-gates/pester.2026-11-07T21-14.md`. No PowerShell file changed, and no branch figure exists for Pester, so only the line threshold applies.

### 1.3 Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester.2026-11-07T20-47.md` (94.10 percent lines)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (94.10 percent lines)
- Per-language comparison summary: Python and PowerShell repo-wide figures equal the Phase 0 baseline; no regression.

## 2. General Code Change Policy Compliance

- Simplicity and scope: PASS. The skill diff replaces only the text the issue names; steps 1, 2, 4, 5, and 6 are unchanged. The Codex copy uses the equivalent wording the issue instructs ("re-fetches the integration tip" for "re-runs step 2"; no "in step 6" because the Codex section has no numbered steps).
- Error handling: PASS. The new assertion helper fails with the label and the retired phrase.
- File size: PASS. The largest changed covered file, the contract test, has 362 logical lines; no covered file reaches the 700-line advisory tier.
- Dependencies, I/O boundaries: PASS. No dependency added; the tests read repository files through the existing helper.
- Suppressions: PASS. No `noqa`, `type: ignore`, or analyzer suppression added.

## 3. Language-Specific Code Change Policy Compliance

- Python (test files only): PASS. Docstrings in Google style on the new helper and tests; type annotations present; black, ruff, and pyright records under `evidence/qa-gates/` show zero findings.
- Markdown skill text: PASS. Tone is factual.

## 4. Language-Specific Unit Test Policy Compliance

- Python: PASS. Arrange-Act-Assert structure with comments; parametrized over all four surfaces; a negative test re-inserts the retired wording and asserts the failure. No temporary files.
- Test discrimination: verified by the executor's negative test and by this review's execution of the module (56 passed together with the surface-contract module). The pinned fragments and retired phrases match the issue's lists exactly (six retired, five kept, two added).

## 5. Test Coverage Detail

Per-language figures are in section 1.2. File-size baseline: no entry in `config/file-size-baseline.json` was added or increased. The `contains_phrase` helper now compares case-insensitively so that fragments match at a sentence start; this change is exercised by the existing parametrized fragment tests.

## 6. Test Execution Metrics

| Gate | Result | Evidence |
|---|---|---|
| pytest -n auto | 16218 passed, 0 failed, 6 skipped | `evidence/qa-gates/pytest.2026-11-07T21-12.md` |
| Invoke-PoshQCParallelTest | 15984 passed, 0 failed | `evidence/qa-gates/pester.2026-11-07T21-14.md` |
| black, ruff, pyright | zero findings | `evidence/qa-gates/black.2026-11-07T20-59.md`, `ruff.2026-11-07T20-59.md`, `pyright.2026-11-07T20-59.md` |
| Review re-run of contract and surface-contract modules | 56 passed | executed in this review |

## 7. Code Quality Checks

- Bundle parity: the canonical and bundled Claude skill copies share one blob id (ce93fafae4bc9c17f42eec7d66c980ca79f9d931); the canonical and bundled Codex copies share one blob id (26dacb27de4e186ba1db4a7fb376f7502f1b92a1).
- Pinned digest: the SHA-256 of `.claude/skills/epic-orchestrate/SKILL.md` is 65f34506ae2d0505f47f79bfbfcbbd9d7c7f78dccc0e9213bc6c9b8222101b76, equal to the re-baselined `PINNED_FROZEN_SURFACE_HASHES` entry; the agent digest is unchanged.
- Ledger: entry 0007 carries the prior text and revert blocks for both Claude and Codex text, revert steps, and revert signals; the README row is added. The `Merge commit: pending (PR #1117)` line is a known pending item that the orchestrator replaces after PR creation; it is not a finding.
- Tier classification: `quality-tiers.yml` handling is not applicable to this change set; no project was added.

## 8. Gaps and Exceptions

- The issue's Known Facts record that whether the preimplementation gate admits `git add` and `git commit` for a conflict-resolving sync in the integration checkout has not been observed. The ledger lists it as a revert signal. The owner ruling excludes adding handling for it; it is recorded, not a finding.
- AC 4 is verified from executor gate records and from the artifacts present at HEAD; CI on the PR head is not required by any criterion.

## 9. Summary of Changes

Four skill copies carry the replacement step 3 text; the contract test drops six retired pins, adds two pins and a retired-phrase guard with two tests; one pinned digest is re-baselined; one ledger entry and index row are added; feature-folder documents and evidence are added.

## 10. Compliance Verdict

PASS. No blocking policy finding.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`: existing fragment tests across four surfaces, plus `test_child_item_wording_absent_from_lifecycle_section` (four parametrized cases) and `test_contract_fails_when_child_item_wording_returns`.
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`: pinned-digest check, unchanged, passing against the new digest.

## Appendix B: Toolchain Commands Reference

- `poetry run pytest -n auto --cov --cov-branch` (executor final gate)
- `Invoke-PoshQCParallelTest` (executor final gate)
- `black`, `ruff`, `pyright` (executor gates)
- Review spot check: `python -m pytest` on the contract and surface-contract modules
