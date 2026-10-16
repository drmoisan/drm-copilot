# Epic Permission Before (P6-T19, expect-fail)

Timestamp: 2026-10-16T11-30
Command: poetry run pytest tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed in 0.10s

Summary line (verbatim): 1 failed in 0.10s (contains `1 failed`, does not contain `passed`)

Second command: git grep -c -F -e "lib/ci-gate/" -- .claude/agents/epic-orchestrator.md
Second command exit code: 1, no output. The persona file names no `.claude/lib/ci-gate/` path, so it holds no parser grant (its tools are `.claude/agents/epic-orchestrator.md:5-18`).

AssertionError (verbatim):
the epic-orchestrate procedure prescribes a pwsh invocation no epic-orchestrator Bash grant covers: ('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1', 'pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson'). Declared Bash grants are ('git *', 'gh *').
Failing line: tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py:58 (the `uncovered` assertion; the floor assertion at the preceding statement passed because two invocations were parsed).

RowAttribution:
- `test_every_prescribed_pwsh_invocation_has_an_epic_persona_bash_grant` fails before the change on the `uncovered` assertion, not on the floor assertion. Two invocations are uncovered:
  1. `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` (`.claude/skills/epic-orchestrate/SKILL.md:127`)
  2. `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson` (added by P6-T16)
  Reason: the persona grants only `Bash(git *)` and `Bash(gh *)`.
