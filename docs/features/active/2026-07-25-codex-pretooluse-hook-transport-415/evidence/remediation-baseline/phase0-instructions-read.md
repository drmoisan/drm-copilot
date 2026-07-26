# Phase 0 — Policy Instructions Read (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P0-T1]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-25T21-03.md`

Timestamp: 2026-07-26T11-41

Policy Order: the seven files below were read in the exact order listed, per `.claude/skills/policy-compliance-order/SKILL.md` and plan task [P0-T1].

## Files Read

1. `CLAUDE.md` — repository standing instructions: tone policy, policy compliance reading order, four-layer runtime architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles, module rigor tiers, mandatory seven-stage toolchain loop, 500-line file limit, error handling, naming, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: five core test properties, coverage requirements (line >= 85%, branch >= 75%), coverage exclusion policy (no production file may be excluded from measurement), scenario completeness, Arrange–Act–Assert structure, prohibition on temporary files in tests, test file location (`tests/` tree mirroring production), determinism infrastructure.
4. `.claude/rules/powershell.md` — PowerShell toolchain (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`), PowerShell 7+ compatibility, coding standards, change budget (per-batch cap: at most 3 production files and 3 test files), design seams, Pester testing standards, deterministic test requirements, mocking rules, prohibited behaviors.
5. `.claude/rules/python.md` — Python toolchain (black → ruff → pyright → pytest with `--cov --cov-branch --cov-report=term-missing`), PEP 8 naming, strong typing, design rules, pytest rules, coverage thresholds, prohibited behaviors.
6. `.claude/rules/python-suppressions.md` — suppression authorization requirement, pre-authorized `# noqa` and `# type: ignore` patterns, explicitly unauthorized suppressions and their required workarounds, enforcement checklist.
7. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers, `quality-tiers.yml` as source of truth, uniform-versus-tier-dependent gate matrix, rationale for uniform coverage thresholds.

## Additional Policy Context Loaded

The following rule files were also present in the loaded standing-instruction context and bind this execution:

- `.claude/rules/tonality.md` — required professional tone.
- `.claude/rules/orchestrator-state.md` — checkpoint invariants (not modified by this plan).
- `.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md` — not in scope for this remediation.

## Binding Constraints Acknowledged

- No file under `.claude/` may be created, modified, or deleted by this plan (Hard Constraint 1).
- No coverage threshold may be lowered, no production file removed from `CodeCoverage.Path`, no denominator shrunk (Hard Constraint 6).
- No temporary files in tests (Hard Constraint 4 / `.claude/rules/general-unit-test.md`).
- No file over 500 lines (Hard Constraint 5).
- PowerShell per-batch cap of 3 production / 3 test files, satisfied by per-phase batching (RI-6).

EXIT_CODE: 0

Output Summary: All seven policy files read in the prescribed order. No policy file was modified. Execution proceeds under the constraints listed above.
