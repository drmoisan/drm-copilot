# Remediation Inputs: ci-green-gate-all-checks-and-codex-parity (Issue #899), cycle 2

- Timestamp: 2026-10-12T17-20
- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`, HEAD `75437a6227d0a9c535edcfc11429a2c1a7dcd4c9`
- Base: `origin/main` @ `9338ed463c63a039cadbe4f0548af7151f43f687`
- Opened by: scope-change rule. A new finding surfaced during cycle 1 execution (`remediation-plan.2026-10-12T16-45.md` P1-T1, full `tests/` coverage run). Cycle 1 did not extend its plan; this cycle processes the new finding and re-closes R-1.
- Source evidence: `evidence/qa-gates/python-coverage-run.2026-10-12T16-45.md` and `evidence/qa-gates/python-coverage.2026-10-12T16-45.md` (Disposition: FAIL) in this feature folder.

## Remediation-Required Findings

### R-2 - Parallel-orchestrate procedure prescribes a CI gate parser invocation the parallel-orchestrator persona cannot run

- Severity: Blocking
- Remediability: autonomous
- Failing node: `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant` (passes on `origin/main`; introduced by this branch's Merge-on-Green step 1-2 edit to `.claude/skills/parallel-orchestrate/SKILL.md`).
- Observed assertion: uncovered invocations `('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>', 'no checks reported')`. The declared parallel-orchestrator Bash grants (`.claude/agents/parallel-orchestrator.md` frontmatter `tools:`) contain no grant covering the parser invocation.
- Analysis:
  1. The parser invocation is a genuine prescribed command: the parent must run it to re-read every check before recording `merge_status: ci_green`. Without a grant the step is unexecutable by the persona, so the correct fix is a narrowly scoped grant `Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1*)` in `.claude/agents/parallel-orchestrator.md` and its bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`, kept byte-identical. Placement: immediately after the existing `Invoke-ParallelDriftDetection.ps1` grant line, to stay clear of the lines concurrent issue #890 edits (it replaces the `poetry run python -c *` grant line and adds a `mutate-parallel-run.sh` grant line after `remove-parallel-item.sh`).
  2. `no checks reported` is an error string, not a command. It is parsed as a command only because it is a backticked span whose first token is lowercase. Render it as a double-quoted string (`"no checks reported"`) in the parallel-orchestrate Merge-on-Green step (source and bundle mirror), unless a contract test pins the backticked form; if one does, record why and choose the alternative that keeps every contract test passing.
- Required checks: every test that pins parallel-orchestrator persona tools, skill hashes, or surface fragments (for example `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_orchestrator_permission_contracts.py`, `test_ci_gate_all_checks_contracts.py`, `test_completion_gate_documentation_contracts.py`, push-down resource and bundle-parity contracts) must pass after the edit; any pinned hash or fragment the edit shifts is re-derived in the same change.
- Scope limit: no change to the parser, any hook, any policy file, `.claude/settings.json`, or the #890-owned passages of `.claude/skills/parallel-orchestrate/SKILL.md`.

### R-1 (carried from cycle 1) - Python repo-wide coverage evidence

- Severity: Blocking until re-closed
- Cycle 1 recorded `artifacts/python/lcov.info`, line 93.80% (threshold 85), branch 88.10% (threshold 75), but Disposition FAIL solely because of the R-2 failing node.
- Required outcome: after R-2 is fixed, re-run the full `tests/` coverage run, record a new R-1 artifact with a PASS disposition (zero failed nodes, or only the known state-only node #510), and the baseline comparison.

## Not Remediation-Required

- AC-9: PENDING-CI.
- Code-review CR-1 to CR-4: non-blocking.
