# Policy Audit: parallel-add-and-plan-resume-prepared-items-without-replanning (#1047)

- Timestamp: 2026-11-03T14-31
- Branch: feature/parallel-add-and-plan-resume-prepared-items-1047
- Base: origin/main @ 3ba4795ab2ce22f3d060e4709df8c489e4994971 (merge base)
- Head: fd66abe40e0d900ef1c5653be828d7c5af2de23c
- Work mode: full-feature (AC sources: spec.md, user-story.md)
- Review status: PAUSED. The owner paused this review before completion. Sections marked INCOMPLETE list the checks still to do.

## Scope

Full branch diff against the merge base: 89 files (+8283/-60). Languages with changed files:

- PowerShell: 4 production files (3 added under `.claude/lib/parallel-admission/`, 1 modified hook helper) plus byte-equal bundle copies; 5 added and 1 modified Pester suites.
- Python: 1 modified test-support module, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (constants only). No production Python, no added `.py` file.
- TypeScript: 0 changed files. C#: 0 changed files. Bash: 0 changed files.
- JSON: `.claude/settings.json`, `pack-manifests/core.json`, five fixtures under `tests/fixtures/parallel_admission/`.
- Markdown: skills, rule, agents, feature documents, evidence.

## Rejected Scope Narrowing

No scope narrowing was present in the caller prompt. The audit scope is the full merge-base diff.

## Coverage Evidence Checklist

TypeScript baseline coverage artifact: not applicable; zero TypeScript files changed on the branch.
TypeScript post-change coverage artifact: not applicable; zero TypeScript files changed on the branch.
PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-03T12-53.md` (cohort-barrier helpers 100.00%, 77/77).
PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (full `tests/scripts` run; JUnit 13912 tests, 0 failures, 0 errors, 10 disabled).
Python baseline coverage artifact: INCOMPLETE: review paused by the owner, resume here. `artifacts/python/lcov.info` is absent in the item worktree.
Python post-change coverage artifact: INCOMPLETE: review paused by the owner, resume here. Regenerate at head with `poetry run pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json`.

## Per-Language Coverage Comparison

| Language | Repo-wide line | Repo-wide branch | New/changed files | Verdict |
| --- | --- | --- | --- | --- |
| PowerShell | 93.74% (21839/23298) | no branch gate (Pester) | see below | PASS |
| Python | INCOMPLETE | INCOMPLETE | test-support constants only | INCOMPLETE: review paused by the owner, resume here |
| TypeScript | not applicable (0 changed files) | not applicable | none | not applicable |
| C# | not applicable (0 changed files) | not applicable | none | not applicable |

PowerShell comparison: New/changed-code coverage: 96.15% minimum across the changed production files. Per-file line coverage read from `artifacts/pester/powershell-coverage.xml`:

| File | Status | Covered/Total | Line % | Threshold | Result |
| --- | --- | --- | --- | --- | --- |
| `.claude/lib/parallel-admission/ParallelAdmission.psm1` | added | 141/141 | 100.00 | 85 | PASS |
| `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` | added | 179/179 | 100.00 | 85 | PASS |
| `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | added | 250/260 | 96.15 | 85 | PASS |
| `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` | modified | 97/97 | 100.00 | no regression from 100.00 | PASS |

Uncovered lines in `Invoke-ParallelAdmission.ps1`: 67, 68, 80 (git and file seam bodies), 122 (double JSON number), 185 (unsupported-type throw), 422 (planner item not found), 692, 696-698 (guarded entry body).

Artifact provenance: the coverage XML (14:16 UTC) and JUnit (14:20 UTC) postdate the last code change; the item worktree had no uncommitted changes at review start, and the JUnit total (13912) matches a full `tests/scripts` run, not a narrowed run.

Python comparison: New/changed-code coverage: INCOMPLETE: review paused by the owner, resume here.

## Toolchain Verification

| Stage | PowerShell | Python | Source |
| --- | --- | --- | --- |
| Formatting | PASS per executor evidence | PASS per executor evidence | `evidence/qa-gates/poshqc-format.2026-11-03T13-52.md`, `black-final.2026-11-03T13-53.md` |
| Linting | PASS per executor evidence | PASS per executor evidence | `poshqc-analyze.2026-11-03T13-52.md`, `ruff-final.2026-11-03T13-53.md` |
| Type checking | not applicable | PASS per executor evidence | `pyright-final.2026-11-03T13-53.md` |
| Unit tests | PASS (JUnit 13912/0 verified by reviewer) | PASS per executor evidence | `artifacts/pester/pester-junit.xml`, `pytest-contracts.2026-11-03T13-38.md` |

INCOMPLETE: review paused by the owner, resume here. Reviewer re-runs still to do: PSScriptAnalyzer and Invoke-Formatter check on the four PowerShell production files and six suites; Ruff, Black `--check`, and Pyright on the Python test-support module; targeted Pester run of `tests/scripts/claude-lib/parallel-admission` and the cohort-barrier suites.

## File Size Policy

Logical line counts measured by the reviewer (split on line terminators, trailing terminator not counted): largest covered file is `Invoke-ParallelAdmission.ps1` at 699 lines; both modules 508; helpers 344; largest suite 537. No covered file is at or above 700 lines, none exceeds 800, and `config/file-size-baseline.json` is not changed. Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists on the base and the branch adds `.claude/lib/parallel-admission` as T3, consistent with the sibling `.claude/lib/parallel-drift` entry. Verdict: PASS (by manifest diff; `check_quality_tiers` not re-run by the reviewer).

## Coverage Exclusion Policy

INCOMPLETE: review paused by the owner, resume here. Confirm that `config/poshqc-coverage.json` and `pyproject.toml` coverage settings are unchanged on the branch and that no production path is excluded.

## Evidence Location Compliance

The merge-base name list contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`; all evidence is under the feature folder `evidence/<kind>/`. Verdict: PASS by name list.

INCOMPLETE: review paused by the owner, resume here. Run `validate_evidence_locations.py --root .` in the item worktree and record its exit code.

## Approved Exceptions

None recorded at pause time.

## Compliance Verdict

INCOMPLETE: review paused by the owner, resume here. PowerShell coverage, file size, tier classification, and evidence location (name list) are PASS. The Python coverage verdict, reviewer toolchain re-runs, coverage-exclusion check, and evidence-location script run remain.

## Appendix A: Test Inventory

| Suite | Tests (executor evidence) |
| --- | --- |
| `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1` | 56 |
| `tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1` | 51 |
| `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | 57 |
| `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` | 11 |
| `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1` | 5 |
| `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` | 62 |
| Full `tests/scripts` Pester run | 13912 (0 failures, reviewer-verified from JUnit) |
| Python contract set under `tests/scripts/dev_tools/` | 410 (executor evidence) |

## Appendix B: Toolchain Commands Reference

- PowerShell: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest -Root <repo> -ScanFolders @('tests/scripts')`.
- Python: `poetry run black --check <file>`, `poetry run ruff check <file>`, `poetry run pyright <file>`, `poetry run pytest --cov --cov-branch -q -p no:cacheprovider`.
- Evidence locations: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`.
