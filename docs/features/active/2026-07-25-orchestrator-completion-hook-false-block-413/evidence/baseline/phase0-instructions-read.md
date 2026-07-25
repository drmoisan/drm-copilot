# Phase 0 — Policy Instructions Read (issue #413)

Timestamp: 2026-07-25T17-01

Policy Order: The five policy files below were read in the exact order mandated by [P0-T1] of
`docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md`,
which matches the reading order in `.claude/skills/policy-compliance-order/SKILL.md`
(standing instructions first, then cross-language code-change policy, then cross-language
unit-test policy, then the language-specific rule for the files in scope, then the tier/coverage rule).

Files read (in order):

1. `CLAUDE.md` — standing instructions: tone policy, policy compliance reading order, language rule routing, four-layer runtime architecture, orchestration checkpoint path `artifacts/orchestration/orchestrator-state.json`.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design priorities, mandatory seven-stage toolchain loop with restart-on-failure, 500-line file cap, fail-fast error handling, I/O boundary rules.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: five core test properties, line >= 85% / branch >= 75% coverage, no-regression-on-changed-lines, prohibition on temporary files in tests, `tests/` mirror-layout requirement.
4. `.claude/rules/powershell.md` — PowerShell toolchain (PoshQC format -> PSScriptAnalyzer analyze -> Pester test; type checking not applicable), PowerShell 7+ compatibility, design seam guidance (wrapper seam, then injectable ScriptBlock seam), mocking rules, 500-line cohesion limit, prohibition on weakening assertions to make tests pass.
5. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers, uniform gate matrix (format 100%, 0 lint errors, line >= 85%, branch >= 75%, no regression on changed lines) and tier-dependent gates.

Language scope for this change: PowerShell only for production/test code
(`.claude/hooks/validate-orchestrator-output.ps1`, its bundled copy, and
`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`). The bundle-parity
gate `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is a Python
test executed as a content gate over PowerShell files; no Python production code is
modified, so PowerShell is the only language requiring coverage-bearing evidence.

Constraints acknowledged from the reading:

- Type checking is not applicable to PowerShell; the loop is format -> analyze -> test.
- Restart the loop from formatting if any stage fails or changes files.
- The test file must remain at or under the 500-line cap.
- No temporary files may be created or used by tests.
- Existing blocking assertions must not be weakened to make tests pass.

EXIT_CODE: 0
Output Summary: All five policy files read in the mandated order. No policy file was modified.
