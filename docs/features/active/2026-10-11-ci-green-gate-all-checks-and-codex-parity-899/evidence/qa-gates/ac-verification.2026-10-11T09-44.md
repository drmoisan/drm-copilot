# Acceptance Criteria Verification (P2-T16)

Timestamp: 2026-10-12T16-33
Task: P2-T16
Source: `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/issue.md`, section `## Acceptance Criteria` (minor-audit)

Evidence paths below are relative to `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/`.

| AC | Verifying test or command | Evidence artifact | Result |
|---|---|---|---|
| AC-1 | `test_ci_gate_all_checks_contracts.py::test_s9_queries_every_check_without_required_flag` (2 copies); P2-T12 `git grep -F -e "--required"` exit 1 | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md` (198 passed); `evidence/qa-gates/final-required-flag-search.2026-10-11T09-44.md`; fail-before `evidence/regression-testing/pytest-all-checks-before-edit.2026-10-11T09-44.md` | PASS |
| AC-2 | `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (in P2-T7; P1-T5 subset `8 passed`) | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md` | PASS |
| AC-3 | `test_ci_gate_all_checks_contracts.py::test_s9_states_no_checks_error_is_never_green` (2 copies) | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md`; fail-before `evidence/regression-testing/pytest-all-checks-before-edit.2026-10-11T09-44.md` | PASS |
| AC-4 | `test_ci_gate_all_checks_contracts.py::test_merge_on_green_always_rereads_every_check` (2 copies) | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md`; `evidence/other/mirror-sync.2026-10-11T09-44.md` (P1-T10) | PASS |
| AC-5 | `test_ci_gate_all_checks_contracts.py::test_codex_ci_green_gate_invokes_parser_with_epic_child_guard` and `::test_codex_ci_green_gate_fails_closed_without_parser` (2 copies each); `test_completion_gate_documentation_contracts.py` | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md` | PASS |
| AC-6 | `test_ci_gate_all_checks_contracts.py::test_surface_restates_no_required_only_population` (22 cases) | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md`; `evidence/regression-testing/pytest-all-checks-after-edit.2026-10-11T09-44.md` (34 passed) | PASS |
| AC-7 | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exit 0 | `evidence/qa-gates/final-codex-variants-check.2026-10-11T09-44.md`; `evidence/other/codex-variants-regenerate.2026-10-11T09-44.md` | PASS |
| AC-8 | MCP `run_poshqc_test` over `tests/scripts/claude-lib/ci-gate` (ok=true) plus `git grep` of both new `It` titles; supplementary read of the runner's JUnit file (both new cases `status="Passed"`, failures="0") | `evidence/qa-gates/final-pester-ci-gate.2026-10-11T09-44.md`; `evidence/qa-gates/final-powershell-coverage-status.2026-10-11T09-44.md` | PASS |
| AC-9 | PR `CI` run artifact `poshqc-test-results`, `artifacts/pester/powershell-coverage.xml`, zero missed lines for `Invoke-CiGateParser.ps1` | `evidence/qa-gates/final-powershell-coverage-status.2026-10-11T09-44.md` | PENDING-CI (owner: orchestrator at S9) |
| AC-10 | P2-T10 mirror hashes `PAIRS_EQUAL=7/7`; `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror` (in P2-T7) | `evidence/qa-gates/final-mirror-hashes.2026-10-11T09-44.md`; `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md`; `evidence/other/mirror-sync.2026-10-11T09-44.md` | PASS |
| AC-11 | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (in P2-T7); P2-T13 scope boundary shows epic surfaces and `parallel-orchestrator.md` unchanged | `evidence/qa-gates/final-python-contract-suites.2026-10-11T09-44.md`; `evidence/qa-gates/final-scope-boundary.2026-10-11T09-44.md` | PASS |

Output Summary: AC-1 through AC-8, AC-10, and AC-11 PASS on their cited artifacts. AC-9 PENDING-CI, checked off by the orchestrator at S9.
