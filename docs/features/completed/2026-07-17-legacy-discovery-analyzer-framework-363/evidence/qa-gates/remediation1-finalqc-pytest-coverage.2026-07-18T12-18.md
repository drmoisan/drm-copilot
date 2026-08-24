# Remediation Cycle 1 — Final QC: Pytest Coverage (BLOCKED — pre-existing integration-branch failure)

Timestamp: 2026-07-18T12-18

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing

EXIT_CODE: 1

Output Summary:
- Result: 1 failed, 1768 passed (runtime 8.98s).
- Failing test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- Failure assertion: "Repo file missing from bundle: .claude\agents\legacy-parity-analyst.md". The repo file `.claude/agents/legacy-parity-analyst.md` exists but is absent from the bundled payload at `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`.
- Coverage TOTAL row (from this run): Stmts=11614, Miss=1322, Branch=4290, BrPart=550, combined Cover=86%.
  - Derived line coverage = (11614 - 1322) / 11614 = 88.62%.
  - Derived branch coverage = (4290 - 550) / 4290 = 87.18%.
  - Coverage thresholds are met; the blocker is the failing test, not coverage.

## Provenance / Root Cause (verified via git object inspection)

- The agent file `.claude/agents/legacy-parity-analyst.md` was introduced by integration-branch commit `5335075c feat(agents): add four domain-neutral agent personas for legacy-discovery (#365)`. It was NOT present on the feature branch pre-merge (`cfc17114`).
- On the integration branch head `e5f501082a13db2331c1b77132e9e47d182468b4`: the repo file `.claude/agents/legacy-parity-analyst.md` is present, the test `test_push_down_claude_resource_contracts.py` is present, and the bundled counterpart `extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md` is ABSENT.
- Conclusion: this test already fails on the integration branch head. It is a pre-existing integration-branch defect (bundle payload not updated when the #365 agent persona was added), independent of this cycle's merge resolution, which touched only `pyproject.toml`.

## Decision

- Remediation would require adding the missing agent persona file(s) to the bundled `claude-customizations` payload — a code change outside this remediation plan's scope (scope: resolve the pyproject.toml conflict and re-run QC).
- Per the caller's explicit stop-and-report directive for a QC failure requiring code changes, execution is halted here. Tasks P2-T4 through P2-T7 remain unchecked. No branch push was performed.
