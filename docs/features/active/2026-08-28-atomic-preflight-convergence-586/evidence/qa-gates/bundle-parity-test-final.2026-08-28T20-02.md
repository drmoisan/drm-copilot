# QA Gate — Bundle-Parity Test, Final Run (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T11]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Baseline reference: `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/baseline/baseline-bundle-parity-test.2026-08-28T20-02.md` ([P0-T6])

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q

EXIT_CODE: 0

Output Summary:

The command printed the following, with the summary line transcribed verbatim:

```
..........                                                               [100%]
10 passed in 0.11s
```

The summary line records `10 passed`, the same passed count the [P0-T6] artifact recorded on the pre-change tree. Ten dots and no `F`, `E`, or `s` character appear on the progress line, so all ten collected cases passed and none was skipped or errored.

## What This Gate Detects

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every repository `.claude/**` file except `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree, and asserts that the bundled copy under `extensions/drm-copilot/resources/claude-customizations/` is byte-equal to it. A bundled mirror that diverged from its target file during Phase 1 makes that case fail. The case passed, so both mirrors are byte-equal to their target files.

This is the automated form of the same invariant [P2-T10] measured by blob hash. The two gates agree: [P2-T10] recorded `243fc8629eb4d168d385e583c805dc2c104437eb` for both copies of `atomic-plan-contract/SKILL.md` and `1e944becfd8a31128fb1b7546b3c055e76a4d5a2` for both copies of `remediation-handoff-atomic-planner/SKILL.md`.

The `REQUIRED_BUNDLED_FILES` tuple of the same test module names `.claude/skills/atomic-plan-contract/SKILL.md` explicitly, so a missing bundled copy of that file would also fail here.

## Coverage Note

This command is a payload-parity gate, not a coverage gate, and is run without coverage flags as the plan states. No Python production or test file is created or modified by this plan, so no Python line enters or leaves coverage measurement and there is no coverage number to record. Per the plan's `## Scope and Toolchain Applicability` and `## Test Plan` sections, no coverage-bearing language is in scope for this change. This is a scope fact, not a waived gate.

## Verdict

`EXIT_CODE: 0` and `10 passed`, matching the [P0-T6] pre-change result. The command was executed unconditionally; `EXIT_CODE: SKIPPED` was not used. Gate passes.
