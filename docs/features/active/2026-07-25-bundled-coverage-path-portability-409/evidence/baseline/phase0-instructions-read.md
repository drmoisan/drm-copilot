# Phase 0 — Policy Instructions Read (issue #409)

Timestamp: 2026-07-25T10-40

Policy Order: The required reading order defined by `.claude/skills/policy-compliance-order/SKILL.md` and `CLAUDE.md` ("Policy Compliance Reading Order"), scoped to the languages in this change (PowerShell production + test surface, Python parity test surface).

Files read, in order:

1. `CLAUDE.md` — repository standing instructions: tone policy, policy-compliance reading order, four-layer runtime architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design priorities, module rigor tiers, mandatory seven-stage toolchain loop with restart-on-change, 500-line file cap, error handling, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: five core properties, uniform coverage thresholds (line >= 85%, branch >= 75%), coverage-exclusion prohibition, Arrange–Act–Assert, prohibition on temporary files in tests, test file location under `tests/` mirroring source.
4. `.claude/rules/powershell.md` — PowerShell toolchain (`run_poshqc_format` → `run_poshqc_analyze` → no type-check stage → `run_poshqc_test`, via the MCP server functions), change budget (2 production files direct mode; per-batch cap 3 production + 3 test), design seams (injectable ScriptBlock seam), Pester 5.x testing standards, deterministic test requirements, prohibited behaviors.
5. `.claude/rules/python.md` — Python toolchain (`poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`), typing and Pytest rules, prohibition on runtime temp files in unit tests.
6. `.claude/rules/python-suppressions.md` — pre-authorized `# noqa` / `# type: ignore` patterns and the escalation path; no suppression is used by this change.

Notes on how these constrain this change:

- The production surface is capped at the two mirrored `PoshQC.Testing.psm1` copies (PowerShell direct-mode budget: 2 production files), plus one new test file.
- The 500-line cap applies to `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (443 lines pre-change) and to the new test file; verified by task [P2-T2].
- No temporary files may be created by tests; the new Pester tests are seam-injected with `New-Item` mocked, so they perform no filesystem writes.
- The PowerShell toolchain must be driven through the PoshQC MCP tools, not VS Code task wrappers.
- No policy file under `.claude/rules/` or `.github/instructions/` is modified by this change.

Also read as execution inputs (not policy files): `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
