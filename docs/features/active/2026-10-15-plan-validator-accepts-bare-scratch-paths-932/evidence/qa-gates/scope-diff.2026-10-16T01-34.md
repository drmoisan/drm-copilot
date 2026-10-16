# Scope Diff Against the Merge Base — Issue #932

Timestamp: 2026-10-16T01-34
Task: [P6-T15]
Command: git diff --name-only <MERGE_BASE> HEAD; git diff --name-status --diff-filter=D <MERGE_BASE> HEAD; git status --porcelain
EXIT_CODE: 0

MERGE_BASE: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 (no rebase; equal to the [P0-T2] value). HEAD: 086d24e75b73120aa40b80bccc9193e3671f3b38.

Output Summary: 83 changed paths. Every path is either in the plan's WRITES list (42 paths) or under `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/` (41 paths). The deletion listing is empty. No forbidden path appears.

REMEDIATION-LOG: none (Glob `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/evidence/other/out-of-scope-remediation.*.md` returned no files).

WRITES-list paths in the diff (42):
- `scripts/dev_tools/plan_gate_scratch.py`, `scripts/dev_tools/plan_gate_discrimination.py`
- `tests/scripts/dev_tools/test_plan_gate_scratch.py`, `test_plan_gate_scratch_docs.py`, `test_plan_gate_parity.py`, `test_scratch_location_contracts.py`, `test_plan_gate_observability_boundaries.py`
- `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`, `plan-gate-discrimination.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`, `plan-gate-parity.test.ts`, `validate-orchestration-service-call-plan-gates.test.ts`, `plan-gate-observability-boundaries.test.ts`
- `extensions/drm-copilot/jest.config.cjs`
- `.claude/rules/plan-acceptance-gates.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
- `.claude/skills/atomic-plan-contract/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
- the 12 `.codex/agents/atomic-{planner,executor}{,-c1,-c2,-c3,-c3-elevated,-c4}.toml` files and their 12 copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`

Feature-folder paths (41): `issue.md`, `spec.md`, `plan.2026-10-15T15-45.md`, the two research files, and the committed evidence artifacts under `evidence/baseline/`, `evidence/regression-testing/`, `evidence/other/`, and `evidence/qa-gates/`. These include commits made before Phase 0 on this branch (issue, research, spec, plan).

Plan-file check: the only paths matching `plan.*.md` or `remediation-plan.*.md` are `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/plan.2026-10-15T15-45.md`, inside the feature folder.

Absent as required: `scripts/dev_tools/validate_orchestration_artifacts.py`, `scripts/dev_tools/plan_gate_observability.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts`, `.agents/skills/atomic-plan-contract/SKILL.md`, every path under `.github/`, and every pack manifest under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/`.

Deletion listing (`--diff-filter=D`): empty.

Porcelain: the modified plan file and new `evidence/qa-gates/` artifacts only, plus the untracked `SCRATCH/` directory at the worktree root, which belongs to the orchestrator, predates this run, and is never staged by this item.
