# Scope and AC Check ([P2-T3], remediation cycle R1)

Timestamp: 2026-11-12T06-02
Command: git -C <worktree> diff --name-only HEAD ; git -C <worktree> status --porcelain (union, sorted, written to SCRATCH/issue-1167-p2t3-scope.txt); grep -E for the out-of-bounds paths and `\.py$`; grep of the spec.md `## Acceptance Criteria` checkboxes
EXIT_CODE: 0
Output Summary:
- Union of `git diff --name-only HEAD` and `git status --porcelain`: 55 paths (39 tracked files modified, 16 untracked feature-folder files: the review artifact set, the remediation inputs and plan, the preflight fix record, and this cycle's evidence).
- Out-of-bounds search over the union: 0 matches (grep exit 1) for `scripts/dev_tools/atomic_executor/`, `scripts/dev_tools/validate_orchestration_artifacts.py`, `scripts/dev_tools/plan_gate_`, `extensions/drm-copilot/src/lib/validate/`, `.claude/hooks/validate-planner-output.ps1`, `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, and any `.py` path. No production code file changed; no Python file added.
- Acceptance criteria in spec.md: AC1 to AC13 checked (`- [x]`), AC14 (CI-dependent) unchecked, pending CI on the PR head.

Tracked files changed in this cycle:
- Contract: .claude/skills/atomic-plan-contract/SKILL.md, .agents/skills/atomic-plan-contract/SKILL.md, .github/skills/atomic-plan-contract/SKILL.md, and their three bundle copies.
- Planner: .claude/agents/atomic-planner.md, .codex/agents/atomic-planner.toml with the -c1, -c2, -c3, -c3-elevated, and -c4 variants, .agents/skills/atomic-planner/SKILL.md, .github/agents/atomic_planning.agent.md, python-atomic-planning.agent.md, powershell-atomic-planning.agent.md, csharp-atomic-planning.agent.md, and their bundle copies and generated bundle variants.
- Policy (CR2): .claude/rules/general-code-change.md, .agents/skills/general-code-change/SKILL.md, and their bundle copies.
- Template: docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md and its bundle copy.
- Test: tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1.
- Ledger: docs/engineering/process-reductions/0011-task-check-cadence.md.
- Feature: docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/spec.md (decision D15; no AC line changed).
