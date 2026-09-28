# blast-radius-mandate-reads-scripts-vscode-620 (Plan)

- **Issue:** #620
- **Feature folder:** `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/`
- **Work Mode:** minor-audit
- **AC source:** `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md`, `## Acceptance Criteria` section only (7 items, AC1–AC7 below)
- **Status:** Draft

**Plan-path note:** The canonical target path `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/plan.md` cannot be written by this agent. `.claude/hooks/enforce-feature-folder-order.ps1` denies any `Write`/`Edit` to a feature-folder `plan.md` unless `spec.md` and `user-story.md` also exist in the same folder, and it applies unconditionally regardless of the `- Work Mode: minor-audit` marker in `issue.md`. `.claude/skills/atomic-plan-contract/SKILL.md` ("Mode-Specific Mandatory Plan Gates") explicitly forbids treating a missing `spec.md`/`user-story.md` as a blocker for minor-audit plans, and further states that minor-audit execution/validation must fail closed if those files exist *unexpectedly* — so creating stub `spec.md`/`user-story.md` files to satisfy the hook would itself violate the minor-audit contract. This timestamped filename is the repo's existing accepted pattern for this exact conflict: every completed minor-audit-mode feature folder inspected (`repo-housekeeping-audit`, `planner-hook-em-dash-mismatch-357`, `2026-08-19-parallel-merge-gate-allow-branch-492`) carries only a timestamped `plan.<timestamp>.md`, never a bare `plan.md`. This file was already present in the feature folder (with generic unfilled placeholder content) before this planning pass began; it is reused in place here rather than creating an additional sibling file, per the Plan-Path Continuity Contract's reuse rule.

## Scope

Two data-only edits, each adding the string `"scripts/vscode/**"` as a new entry in the `mandate_reads` array:

1. `config/blast-radius.json` (repo root)
2. `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (bundled copy)

No production code file changes. No `spec.md` or `user-story.md` is created or required for this minor-audit plan. The toolchain loop for this plan is JSON-validity checks plus the two named test suites; no formatter, linter, or type-checker applies to a JSON data file beyond confirming continued validity and preserved formatting conventions.

## Issue Acceptance Criteria (verbatim IDs used below)

- **AC1** — `"scripts/vscode/**"` is added to `mandate_reads` in `config/blast-radius.json`.
- **AC2** — `"scripts/vscode/**"` is added to `mandate_reads` in the bundled copy.
- **AC3** — `version`, `over_breadth_fraction`, and `mandate_reads` remain byte-identical between the two copies.
- **AC4** — `tests/scripts/dev_tools/test_blast_radius_config_parity.py` passes.
- **AC5** — `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` passes.
- **AC6** — `push_down_claude_customizations` is run after the config change.
- **AC7** — No change is made to the planner's obligation (in `.claude/rules/parallel-orchestration.md`) to declare a genuine write under `scripts/vscode/` explicitly.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/python.md`, `.claude/rules/powershell.md`, and `.claude/rules/parallel-orchestration.md`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/other/phase0-instructions-read.<TIMESTAMP>.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: the artifact file exists and lists all seven file paths above in the order read.

- [x] [P0-T2] Confirm `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` contains the exact heading `## Acceptance Criteria`. Command: `grep -n "^## Acceptance Criteria$" docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md`. Acceptance: exactly one match is reported at line 61; zero matches is a fail-closed blocker for this minor-audit plan.

- [x] [P0-T3] Confirm no `spec.md` or `user-story.md` exists in the feature folder (minor-audit fail-closed check). Command: `git status --porcelain docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/spec.md docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/user-story.md` combined with a directory listing of the feature folder. Acceptance: neither file is present in the listing.

- [x] [P0-T4] Capture baseline JSON validity for `config/blast-radius.json`. Command: `poetry run python -c "import json; json.load(open('config/blast-radius.json', encoding='utf-8')); print('valid')"`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/baseline/p0-t4-json-validity-root.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and the command prints `valid`.

- [x] [P0-T5] Capture baseline JSON validity for the bundled copy. Command: `poetry run python -c "import json; json.load(open('extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json', encoding='utf-8')); print('valid')"`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/baseline/p0-t5-json-validity-bundled.<TIMESTAMP>.md` with the same required fields. Acceptance: `EXIT_CODE: 0` and the command prints `valid`.

- [x] [P0-T6] Capture baseline confirmation that `"scripts/vscode/**"` is currently absent from `config/blast-radius.json`. Command: `grep -o "scripts/vscode/\*\*" config/blast-radius.json | wc -l`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/baseline/p0-t6-pre-fix-absence-root.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: `EXIT_CODE: 0` and the printed count is `0`, confirming the defect state described in issue.md.

- [x] [P0-T7] Capture baseline confirmation that `"scripts/vscode/**"` is currently absent from the bundled copy. Command: `grep -o "scripts/vscode/\*\*" extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json | wc -l`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/baseline/p0-t7-pre-fix-absence-bundled.<TIMESTAMP>.md` with the same required fields. Acceptance: `EXIT_CODE: 0` and the printed count is `0`.

- [x] [P0-T8] Capture baseline pass state of the Python parity test. Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -v`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/baseline/p0-t8-pytest-parity-baseline.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (record the pass/fail summary line printed by pytest, e.g. the `N passed` count). Acceptance: `EXIT_CODE: 0`.

- [x] [P0-T9] Capture baseline pass state of the Pester parity suite via the repo's MCP-based Pester invocation (`.claude/rules/powershell.md` mandates the MCP tool over a raw `pwsh -File` call). Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the repository root and `scan_folders: ["tests/scripts/claude-lib/blast-radius"]`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/baseline/p0-t9-pester-keypartition-baseline.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (the returned `exitCode` field), `Output Summary:`. Acceptance: `EXIT_CODE: 0`.

---

### Phase 1 — Constrained Implementation (the two data edits)

- [x] [P1-T1] Edit `config/blast-radius.json`: in the `mandate_reads` array, add a trailing comma to the current final entry `    ".agents/skills/**"` (making it `    ".agents/skills/**",`) and insert a new line `    "scripts/vscode/**"` immediately after it, before the array's closing `],`. Do not modify any other key (`version`, `shared_surfaces`, `shared_surface_globs`, `modules`, `over_breadth_fraction`). Acceptance: the file contains the literal `"scripts/vscode/**"` as the new final element of `mandate_reads`. Check off **AC1** in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` (change `- [ ]` to `- [x]` for the AC1 line only) once this task's acceptance is verified.

- [x] [P1-T2] Edit `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`: in the `mandate_reads` array, add a trailing comma to the current final entry `    ".agents/skills/**"` and insert a new line `    "scripts/vscode/**"` immediately after it, before the array's closing `],`, at the same relative position as P1-T1. Do not modify any other key. Acceptance: the file contains the literal `"scripts/vscode/**"` as the new final element of `mandate_reads`. Check off **AC2** in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` once this task's acceptance is verified.

- [x] [P1-T3] Verify `config/blast-radius.json` remains valid JSON after P1-T1. Command: `poetry run python -c "import json; json.load(open('config/blast-radius.json', encoding='utf-8')); print('valid')"`. Acceptance: `EXIT_CODE: 0` and the command prints `valid`.

- [x] [P1-T4] Verify the bundled copy remains valid JSON after P1-T2. Command: `poetry run python -c "import json; json.load(open('extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json', encoding='utf-8')); print('valid')"`. Acceptance: `EXIT_CODE: 0` and the command prints `valid`.

- [x] [P1-T5] Verify the three Class-1 keys (`version`, `over_breadth_fraction`, `mandate_reads`) are byte-identical between the two copies after the edits, and that `"scripts/vscode/**"` is present in the compared `mandate_reads` list. Command: `poetry run python -c "import json; a=json.load(open('config/blast-radius.json', encoding='utf-8')); b=json.load(open('extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json', encoding='utf-8')); print(a['version']==b['version'], a['over_breadth_fraction']==b['over_breadth_fraction'], a['mandate_reads']==b['mandate_reads']); print('scripts/vscode/**' in a['mandate_reads'])"`. Acceptance: `EXIT_CODE: 0`, first printed line is `True True True`, second printed line is `True`. Check off **AC3** in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` once this task's acceptance is verified.

- [x] [P1-T6] Confirm the diff of `config/blast-radius.json` against `HEAD` touches only the `mandate_reads` array. Command: `git diff HEAD -- config/blast-radius.json`. Acceptance: `EXIT_CODE: 0`, the output contains exactly one `@@` hunk header, and an added line (prefixed `+`) whose trimmed text is exactly `"scripts/vscode/**"`.

- [x] [P1-T7] Confirm the diff of the bundled copy against `HEAD` touches only the `mandate_reads` array. Command: `git diff HEAD -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`. Acceptance: `EXIT_CODE: 0`, the output contains exactly one `@@` hunk header, and an added line (prefixed `+`) whose trimmed text is exactly `"scripts/vscode/**"`.

- [x] [P1-T8] Confirm `.claude/rules/parallel-orchestration.md` is unmodified by this plan (the planner's obligation to declare a genuine write under `scripts/vscode/` explicitly, stated in that file's "Read-by-mandate classification" section, must not be weakened). Command: `git diff HEAD -- .claude/rules/parallel-orchestration.md`. Acceptance: `EXIT_CODE: 0` and the command produces empty output. Check off **AC7** in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` once this task's acceptance is verified.

---

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run the final Python parity test. Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -v`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t1-pytest-parity-final.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (record the pass/fail summary line, and confirm the verbose output for the node `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` reports a pass). Acceptance: `EXIT_CODE: 0`. If this step fails or any file changes as a result, restart Phase 2 from P2-T1. Check off **AC4** in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` once this task's acceptance is verified.

- [x] [P2-T2] Run the final Pester parity suite via the repo's MCP-based Pester invocation. Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the repository root and `scan_folders: ["tests/scripts/claude-lib/blast-radius"]`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t2-pester-keypartition-final.<TIMESTAMP>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (the returned `exitCode` field), `Output Summary:` (record whether the `Committed blast-radius truth table cross-copy key partition` Describe block's `declares equal values for the runtime-describing keys in both copies` It reports a pass). Acceptance: `EXIT_CODE: 0`. If this step fails or any file changes as a result, restart Phase 2 from P2-T1. Check off **AC5** in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/issue.md` once this task's acceptance is verified.

- [x] [P2-T3] Compare the Phase 0 baseline results (P0-T8, P0-T9) against the Phase 2 final results (P2-T1, P2-T2) and confirm zero regression: both baseline and final runs report `EXIT_CODE: 0` with no newly failing test. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t3-regression-delta.<TIMESTAMP>.md` recording the baseline and final `EXIT_CODE` values for both suites side by side. Acceptance: the artifact records `EXIT_CODE: 0` for all four referenced runs and states explicitly that no regression was introduced.

- [x] [P2-T4] **DEFERRED — executed but did not achieve acceptance intent.** Orchestrator ran `mcp__drm-copilot__push_down_claude_customizations` against `C:\Users\DanMoisan\repos\TaskMaster` after explicit user confirmation. The tool call returned success (exit 0), but verification (`grep -c "scripts/vscode" TaskMaster/config/blast-radius.json`) showed the pushed content did not carry the fix: the tool serves the payload bundled into the current session's MCP server (published npm package / installed VS Code extension), not this repo's live uncommitted source, so an unreleased fix cannot propagate through it. Full findings recorded in `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p2-t4-push-down-execution.2026-09-01T15-43.md`. **AC6 is left unchecked in issue.md and marked DEFERRED** with the same rationale and a linked follow-up feature, rather than checked off, since the acceptance condition's intent was not met.

---

## Evidence Location

All evidence artifacts for this plan are written under `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/{other,baseline,qa-gates}/`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/baselines/`, `artifacts/qa/`, or similar non-canonical path is used.
