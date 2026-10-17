# AC-3 Decision: Inline-Code Grant (Issue #890)

Timestamp: 2026-10-12T20-29
Task: P1-T29
Command: `git grep -n -F --untracked "python -c" -- .claude extensions/drm-copilot/resources/claude-customizations/.claude`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: empty output — no `python -c` text remains in `.claude/` or its bundled mirror (2 matching lines at baseline P0-T11: `.claude/agents/parallel-orchestrator.md:16` and its mirror).

Decision: removed

The grant `"Bash(poetry run python -c *)"` was removed from `.claude/agents/parallel-orchestrator.md` and its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`, and the persona prose paragraph that justified it was rewritten (no `poetry run python` grant is held; inline-code grant removed under #890; module-form grant removed under #791; add, close, and requeue run through `.claude/lib/bash/mutate-parallel-run.sh` since #890). The grant `"Bash(bash .claude/lib/bash/mutate-parallel-run.sh*)"` was added to the persona `tools` list and to `.claude/settings.json` `permissions.allow` (operator approval recorded in `evidence/other/operator-approval-settings-allow-890.md`).

## Dependency evidence

1. Research section 5 (`research/2026-10-11T12-35-parallel-skills-python-engine-calls-research.md`, "Dependence on `Bash(poetry run python -c *)` after the port"): the only `python -c` text in `.claude/` was the grant line itself; the persona's preloaded skills contain no `python -c` prescription; no test pins the grant; after the port no forked skill needs a Python interpreter.
2. Baseline P0-T11 (`evidence/baseline/python-c-grant-baseline-890.md`): exactly 2 matching lines, both the grant line (repository and mirror).
3. No skill forked into or preloaded by `parallel-orchestrator` invokes `python -c` or `poetry run python`:

   Command: `git grep -n -E "python3? +-c|poetry run python" -- .claude/skills/parallel-run .claude/skills/parallel-add .claude/skills/parallel-close .claude/skills/parallel-remove .claude/skills/parallel-orchestrate .claude/skills/policy-compliance-order .claude/skills/feature-promotion-lifecycle .claude/skills/atomic-plan-contract .claude/skills/acceptance-criteria-tracking .claude/skills/evidence-and-timestamp-conventions`
   EXIT_CODE: 1 (empty output)

4. Every new command line added to `parallel-orchestrate` (`bash .claude/lib/bash/mutate-parallel-run.sh requeue-entry ...`, `bash .claude/lib/bash/mutate-parallel-run.sh recolor ...`, and the inline `bash .claude/lib/bash/mutate-parallel-run.sh` and `bash .claude/lib/bash/remove-parallel-item.sh` references) is covered by a persona `Bash(...)` grant; `test_every_prescribed_command_invocation_has_a_persona_bash_grant` in `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py` is run in P2-T6.

Out of scope (follow-up note only, no issue filed): `has_unresolved_drift` and `request_requeue_via_recolor` in `parallel-orchestrate/SKILL.md` remain Python-only seams; they are not invoked through the removed grant.
