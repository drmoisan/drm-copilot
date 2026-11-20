# Phase 2 — Post-Merge Pytest Coverage (Issue #369, Remediation Cycle 1)

Timestamp: 2026-07-18T22-36

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing

EXIT_CODE: 1

Output Summary:
- Test result on the merged tree: 2064 passed, 1 failed, 0 skipped (total 2065 tests, up from 1975 pre-merge; the integration branch added ~90 tests).
- Coverage TOTAL row: Stmts=12474, Miss=1336, Branch=4530, BrPart=564, combined Cover=87%.
- Derived line coverage = (12474 - 1336) / 12474 = 89.29%.
- Derived branch coverage = (4530 - 564) / 4530 = 87.55%.
- Both exceed policy thresholds (line >= 85%, branch >= 75%).

## Single Failing Test — Pre-Existing Integration-Branch Defect (Out of Authorized Scope)

- Failing test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- Assertion failure: `Repo file missing from bundle: .claude\hooks\enforce-discovery-artifact-gate.ps1`. The test requires every non-memory repo `.claude` file to have a byte-identical counterpart under the bundled extension payload root `extensions/drm-copilot/resources/claude-customizations/`.

### Provenance analysis (conclusive)
- Pre-merge feature-branch baseline (P0-T7) had 0 failures (1975 passed). The failure appears only after merging the integration branch.
- `git ls-tree -r origin/epic/legacy-discovery-and-parity-integration -- .claude/hooks/enforce-discovery-artifact-gate.ps1` → present on integration.
- `git ls-tree -r HEAD -- .claude/hooks/enforce-discovery-artifact-gate.ps1` → absent on the feature branch (HEAD).
- `git ls-tree -r origin/epic/legacy-discovery-and-parity-integration -- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1` → absent (no bundle copy on integration).
- The contract test `test_push_down_claude_resource_contracts.py` exists on both the feature branch and the integration branch.
- Conclusion: the integration branch alone contains the repo hook and the contract test but NOT the required bundle copy, so this test fails on `origin/epic/legacy-discovery-and-parity-integration` by itself. The failure is a pre-existing integration-branch defect (a sibling discovery feature added `.claude/hooks/enforce-discovery-artifact-gate.ps1` at the repo root without pushing it down to the bundled extension resources). It is not introduced by this feature's change.

### Scope decision
- The authorized scope for this remediation cycle is the single `pyproject.toml` `[tool.poetry.scripts]` merge conflict (per `remediation-inputs.2026-07-19T02-21.md`: "No scope beyond that document is authorized"). The plan further directs "change nothing else."
- Fixing this failure requires adding a bundle copy under `extensions/drm-copilot/resources/claude-customizations/`, which is an independent outcome outside the authorized single-conflict scope and prohibited by the plan's "change nothing else" instruction.
- Per the plan's established handling of out-of-scope discoveries (P0-T3, P1-T1: "escalate as a new finding rather than resolved ad hoc"), this failure is escalated as a new finding and is NOT fixed in this cycle. Restarting the QA loop is not performed because no in-scope fix exists; a rerun would deterministically reproduce the identical pre-existing failure.
- This task's exit-0 acceptance is therefore not met within authorized scope. The failure does not affect git-level mergeability (a git-conflict concern) and does not reduce coverage below thresholds.

### Escalation (new finding, integration branch)
- Finding: `origin/epic/legacy-discovery-and-parity-integration` violates the bundled-`.claude` resource contract: `.claude/hooks/enforce-discovery-artifact-gate.ps1` exists at the repo `.claude` root with no bundle counterpart at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1`.
- Recommended remediation (separate authorized task, on the integration branch): run the repository's `.claude` push-down tooling to add the missing bundle copy, then re-run the contract test. This affects every PR targeting the epic, not only PR #384.
