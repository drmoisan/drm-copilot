# Remediation Inputs — MCP Promotion Tooling Defects (Issue #401)

- Timestamp: 2026-07-22T21-07
- Cycle: 1 (entry)
- Base branch: `main` (merge-base `a0b251d330525b8307467f4cf529c5cc3e947445`)
- Head branch: `bug/mcp-promotion-tooling-defects-401` (`9d2e7633bdb461e2c34b37a784e1f06f9628c73e`)
- Work mode: `full-bug` (AC source: `spec.md`)
- Blocking-finding count: **1**

## Source Audit Artifacts

- `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/policy-audit.2026-07-22T21-07.md` (Section 2.3 "Under 500 lines" FAIL; Section 8 gaps)
- `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/code-review.2026-07-22T21-07.md` (Findings Table: 1 Blocker, 2 Major, 1 Minor)
- `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/feature-audit.2026-07-22T21-07.md` (AC-14 FAIL, AC-11 PARTIAL; AC-11/AC-14 unchecked in `spec.md`)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated 2026-07-22T21-07 against merge-base `a0b251d3`)

## Enumerated Fix List

### R1 — Decompose `mcp-repo-automation-tool-definitions.ts` below the 500-line limit

- Severity: **Blocking**
- Finding: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is 504 lines (> 500 hard limit, `general-code-change.md`). It was 490 lines at merge-base `a0b251d3`; this branch's `required: ["workspace_root", ...]` insertions (+26/−12) pushed it over. The executor's AC-14 evidence (`evidence/other/mcp-tool-inputs-linecount-final.2026-07-22T20-17.md`) measured only `mcp-tool-inputs.ts` and its sibling and missed this file.
- Files: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (+ one new sibling module; update any imports/tests that reference the moved definitions).
- Expected behavior after fix:
  - `mcp-repo-automation-tool-definitions.ts` <= 500 lines; every changed/new production and test file <= 500 lines.
  - `REPO_AUTOMATION_TOOL_DEFINITIONS` continues to expose all 21 repo-automation tools with identical schemas (including `workspace_root` in every `required` array); the public import surface is preserved (re-export from the original module, following the `mcp-tool-inputs-push-down.ts` / `mcp-tool-inputs-potential-to-issue.ts` extraction precedent).
  - No behavior change: all Jest suites pass unchanged, in particular the AC-5 length-pinned `workspace_root required contract` assertions in `test/mcp-repo-automation-tool-definitions.test.ts`.
- Verification commands (from `extensions/drm-copilot/`, via pwsh if node/npm is allowlist-blocked):
  - `wc -l src/mcp-repo-automation-tool-definitions.ts src/<new-sibling>.ts` (each <= 500)
  - `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test` (single pass, all exit 0)
  - `npm run test:coverage` (line >= 85%, branch >= 75%, no regression vs 96.34%/89.21%)
- Evidence: new qa-gates artifacts under `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/qa-gates/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, including a line-count artifact that measures **every** changed production and test file, then re-check AC-14 in `spec.md`.

### R2 — Raise `potential_to_issue.py` branch coverage to >= 75% (per-module)

- Severity: Major (non-blocking; pre-existing at merge-base with zero regression — include in this cycle to close AC-11)
- Finding: `scripts/dev_tools/potential_to_issue.py` branch coverage is 68.18% (45/66 branches; 21 partial) vs the uniform 75% floor (`.claude/rules/quality-tiers.md`). Line coverage is 91.00% and unchanged vs baseline. Additionally, `evidence/qa-gates/coverage-delta-py.2026-07-22T20-17.md` line 15 computed the AC-11 branch check against the overall measured set (87.3%) instead of the changed module — an evidence-accuracy defect.
- Files: `tests/scripts/dev_tools/test_potential_to_issue.py` (new cases only; production code unchanged), corrected coverage-delta evidence artifact.
- Expected behavior after fix:
  - Per-module branch coverage for `scripts/dev_tools/potential_to_issue.py` >= 75% (>= 50 of 66 branches hit), measured from per-module counts.
  - No production-code changes for this item; new pytest cases target the currently partial branches only.
  - AC-11 re-checked in `spec.md` once per-module thresholds hold.
- Verification commands (repo root):
  - `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term` (exit 0; per-file branch figure computed from per-module counts, not the TOTAL row)
  - `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` → `poetry run ruff check ...` → `poetry run pyright ...` (single pass)
- Evidence: corrected coverage-delta artifact under `evidence/qa-gates/` stating the per-module branch percentage explicitly.
- Note: mind the 500-line rule interaction — `test_potential_to_issue.py` is already 1076 lines (see R3); place new branch-coverage cases in a new mirrored test file (e.g., `tests/scripts/dev_tools/test_potential_to_issue_branches.py`) rather than growing the existing file.

### R3 — Follow-up decomposition of pre-existing over-500-line Python files

- Severity: Major (follow-up; may be deferred to a separate issue at the orchestrator's discretion — pre-existing violations not attributable to this bug fix, per the April 2026 precedent for these same files)
- Finding: `scripts/dev_tools/potential_to_issue.py` 639 lines (634 at merge-base, +5 from the required lockstep reorder) and `tests/scripts/dev_tools/test_potential_to_issue.py` 1076 lines (1017 at merge-base, +59 from required regression cases); both exceed the 500-line limit and predate this branch.
- Expected behavior if executed: cohesive sibling-module decomposition (production: alongside the existing `potential_to_issue_content.py` split; tests: split by concern), preserving the TS/Python byte-parity contract for messages, constants, emitted lines, and decision branches (the parity contract pins semantics, not file layout — coordinate any production split with the parity header references in `promotion.ts`).
- Verification: `wc -l` <= 500 per resulting file; full Python toolchain single-pass green; pytest counts unchanged or increased.

## Do-Not-Do List

- Do not weaken, suppress, or reinterpret the 500-line rule or coverage thresholds; no `exclude` additions to coverage configuration.
- Do not change any MCP tool schema semantics, tool names, or the `workspace_root` required contract while extracting definitions (R1 is a pure module split).
- Do not modify protected files: `extensions/drm-copilot/src/lib/potential-to-issue/content.ts`, `promotion-filesystem.ts`, `src/lib/prompt-mode-contract.ts`, `scripts/dev_tools/potential_to_issue_content.py`.
- Do not revert or alter the delivered Defect A/B behavior (fail-closed `workspace_root`, bug-first `buildIssueBody` routing, `potential_path` normalization).
- Do not apply partial parity changes: any touch to `potential_to_issue.py` decision branches must land lockstep with `promotion.ts` (R2 adds tests only; R3 must preserve byte-parity semantics).
- Do not write evidence outside the canonical `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/<kind>/` tree (no `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`).
- Do not skip toolchain stages or claim completion without single-pass green runs recorded with exit codes.
- No scope creep beyond R1 (mandatory), R2 (recommended this cycle), R3 (optional/deferrable).

## Exit Condition

Cycle 1 exits when a reaudit confirms: R1 resolved (all changed production/test files <= 500 lines, full TS toolchain green, AC-14 re-checked), R2 either resolved (module branch coverage >= 75%, AC-11 re-checked) or explicitly deferred with rationale by the orchestrator, and blocking_count == 0 in the reaudit artifacts.
