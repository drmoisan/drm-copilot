# Remediation Inputs: Development-Docs Root Resolver and Feature-Folder Name Parser (#1035)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate

- Feature folder: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`
- Branch: `feature/dev-docs-root-resolver-phase1-1035` (reviewed head `e3a7b7de2dd82b9968ecb2f698055006515c4853`; PR base `epic/shared-agent-harness-layer-integration`, merge base `7ebf1347dd8fb86613d40e66461fa5ad64a07cfb`)
- Review artifacts: `policy-audit.2026-11-17T11-41.md`, `code-review.2026-11-17T11-41.md`, `feature-audit.2026-11-17T11-41.md` in this folder.

Path rationale: F1 spans nine production files in two languages; `.codex/scripts/epic-child-launch-runtime.ps1` (20.69%) and `scripts/dev_tools/copy_research_to_issue.py` (50.00%) are likely to need small testability seams in production code beyond a named line, so the light path does not apply.

## Findings

### F1 - Modified production files below the modified-file coverage thresholds

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Tests, and where needed small testability seams, can be added on the branch with the existing toolchain; no external system, policy decision or owner input is involved.
Finding-Scope: contained

Each file below is modified on the branch and is below 85% line coverage or, for Python, 75% branch coverage in the single gate run. None regressed from the Phase 0 baseline. Source: `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml` (reviewer parse, matching `evidence/qa-gates/python-tests.2026-11-17T10-18.md` and `powershell-tests.2026-11-17T11-20.md`).

| File | Current | Target |
|---|---|---|
| `scripts/dev_tools/copy_research_to_issue.py` | line 50.00% (41 of 82), branch 46.15% | line 85%, branch 75% |
| `scripts/dev_tools/plan_progress_report.py` | line 82.35% (84 of 102) | line 85% |
| `scripts/dev_tools/atomic_executor/cli.py` | branch 73.08% (38 of 52) | branch 75% |
| `.codex/hooks/authorize-root-epic-invocation.ps1` | line 55.66% (59 of 106) | line 85% |
| `.codex/hooks/enforce-completion-helpers.ps1` | line 83.58% (56 of 67) | line 85% |
| `.codex/scripts/epic-child-launch-contract.ps1` | line 82.20% (194 of 236) | line 85% |
| `.codex/scripts/epic-child-launch-runtime.ps1` | line 20.69% (48 of 232) | line 85% |
| `scripts/dev-tools/link-feature-docs.ps1` | line 82.61% (38 of 46) | line 85% |
| `scripts/dev-tools/new-potential-entry.ps1` | line 82.42% (75 of 91) | line 85% |

Required outcome: each file at or above its target in one full gate run per language; no other file drops below its baseline; any production seam keeps byte parity with its bundle copies (`extensions/drm-copilot/resources/...`) and the template copy of `new-potential-entry.ps1`.

### F2 - Python coverage report older than the newest Python commit

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The pytest coverage gate can be re-run in the item worktree by the executor with the existing launcher; the refusal seen in the review session came from that session's checkpoint context, not from an external system.
Finding-Scope: contained

- Python: `artifacts/python/lcov.info` (10:18:35Z) predates commit `32d8b4260` (10:19:58Z).
- The reviewer regenerated root `coverage/lcov.info` (11:49:30Z) and `artifacts/pester/powershell-coverage.xml` (12:03:28Z) at the head (`evidence/qa-gates/reviewer-coverage-rerun.2026-11-17T12-05.md`); the pytest launch was refused by `PREIMPLEMENTATION_GATE_BLOCKED` in the review session.

The Python figures describe the head's code (content equivalence proven in the policy audit `## CI Cross-check`), so no figure changes; the report must be regenerated after F1 so the coverage Stop hook and the re-review can read it.

Required outcome: after the F1 work, one root `node run-jest.cjs --coverage` run (writes `coverage/lcov.info`), one extension Jest coverage run, one `pytest -n auto` coverage run writing `artifacts/python/lcov.info`, and one `Invoke-PoshQCParallelTest` run, each after the last commit touching its language, with evidence recorded under `evidence/qa-gates/`.

## Non-Blocking Items (no action required for the verdict)

- Warning: six covered files at or above 700 logical lines (`EpicCrossDependency.psm1` 780 in three copies, `Invoke-ParallelAdmission.Tests.ps1` 756, `Invoke-ParallelAdmission.ps1` 711 in two copies).
- Minor CR-2: BOM handling of the routing file differs between PowerShell and Python/TypeScript.
- Minor CR-3: `-DateKind` in `Resolve-DevelopmentDocsRoot` requires PowerShell 7.5.
- Pending CI (not findings): spec and user-story criteria for the full suites and the seven-stage toolchain, and DoD "Behavior matches acceptance criteria in all documented environments".
