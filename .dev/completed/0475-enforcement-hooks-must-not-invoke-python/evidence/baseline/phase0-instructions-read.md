# Phase 0 Policy Reads — Issue #475

Timestamp: 2026-08-15T19-11

Policy Order: The order mandated by `CLAUDE.md` section "Policy Compliance Reading Order": (1) repository tone and communication policy, (2) baseline code change rules, (3) baseline unit test rules, (4) language-specific policies for the languages in scope (PowerShell first, then Python), followed by confirmation of the auto-loaded path-scoped rule files under `.claude/rules/`.

## Files Read (in order)

1. `.github/copilot-instructions.md` — repository tone and communication policy.
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (500-line file cap; mandatory format -> lint -> type-check -> test loop with restart-on-change; temporary files in tests prohibited).
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (independence, isolation, determinism; no external dependencies; temporary-file creation expressly prohibited with no approved exceptions).
4. `.github/instructions/powershell-code-change.instructions.md` — PowerShell code change policy (PoshQC MCP functions are the approved agent toolchain contract; PowerShell 7+ compatibility; avoid `Invoke-Expression`; under 500 lines).
5. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell unit test policy (Pester 5.x; repo config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; `*.Tests.ps1` naming; `Describe`/`Context`/`It`, one behavior per `It`).
6. `.github/instructions/python-code-change.instructions.md` — Python code change policy (Black, Ruff, Pyright; suppression authorization rules).
7. `.github/instructions/python-unit-test.instructions.md` — Python unit test policy (Pytest as the only approved runner).

## Auto-Loaded Rules Confirmed

8. `.claude/rules/powershell.md` — PowerShell toolchain (format -> analyze -> test via MCP), change budget (per-batch cap of 3 production files and 3 test files), design seams (wrapper-function seam `Invoke-<Tool>Exe -<Tool>Args`, then injectable delegate/ScriptBlock seam, then adapter seams), deterministic test requirements (no dependence on mutable machine PATH or profile state; no live executables), coverage floors (>= 85% line, >= 75% branch).
9. `.claude/rules/python.md` — Python toolchain (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`), coverage floors (>= 85% line, >= 75% branch).

## Standing Rules Already Loaded as Standing Instructions

`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md` are loaded as standing instructions for this session and were applied as context to the reads above.

## Constraints Extracted as Binding on This Plan

- 500-line cap on every production file, test file, and reusable script (`general-code-change.instructions.md` section 4.1).
- No temporary files in tests; no approved exceptions exist (`general-unit-test.instructions.md` section 4).
- Tests must not depend on mutable machine PATH or profile state, or on live executables (`.claude/rules/powershell.md`, "Deterministic Test Requirements"). This is the policy basis for the plan's SD-3 structural Python-absence criterion and for the prohibition on `$PSVersionTable` mutation.
- Per-batch cap of 3 production files and 3 test files in all modes (`.claude/rules/powershell.md`, "Change Budget").
- PoshQC MCP server functions are the approved PowerShell toolchain; VS Code task wrappers are not a substitute.
- Coverage floors are uniform at >= 85% line and >= 75% branch across tiers T1-T4.
- `Invoke-Expression` is prohibited in PowerShell production code, which is consistent with the guard's detection class 4.
