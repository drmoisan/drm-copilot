# Task check [P6-T3]

Timestamp: 2026-11-14T04-51
Command: sh SCRATCH/issue-1159-brief.sh (cp from .claude/skills/execution-environment/SKILL.md to the five other copies; sha256sum; pytest -n auto over the brief and resource contract tests); sh SCRATCH/issue-1159-taskcheck.sh over the Pester suites that read the brief
EXIT_CODE: 0
Output Summary: six copies share SHA-256 fe80a048fa22bf872a9b25b5f42c6fe46ef0b8db446db88828a4477bf3d529ec; pytest 123 passed, 0 failed (includes test_brief_batch_budget_section_states_cap_codes_and_exemptions); Pester 315 passed, 0 failed (NestingDepthContract, planning-contract-wording, test-cadence-wording, parallel-gate-wording).

## Changes (all six copies)
- '## Hook Execution Context': new 'PreToolUse dispatcher (#1159)' bullet (one registration per runtime, registry, isolation with its per-process default, HOOK_DISPATCH_BLOCKED:, new hooks go into the registry).
- '## Batch Budget': the matcher statement now points at the Write|Edit group of .claude/hooks/pretooluse-dispatch.json and the Codex ^(apply_patch|Edit|Write)$ group; every required token of the section is unchanged.

## Selection and rule
Contract tests that read the changed brief paths.
