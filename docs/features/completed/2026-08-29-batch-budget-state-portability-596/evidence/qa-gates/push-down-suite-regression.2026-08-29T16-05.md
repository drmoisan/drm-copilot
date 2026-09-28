# [P5-T5] Push-down suite regression after the call-site change

Timestamp: 2026-08-29T21-54

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down`

Absolute-path prefix actually used: the plan's `cd extensions/drm-copilot` was executed as
`cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot`.
No other part of the command text was altered. The prohibited flags `--passWithNoTests`,
`--onlyChanged`, and `--lastCommit` were not used.

EXIT_CODE: 0

Output Summary: All 17 push-down suites pass, 234 tests, failed count 0. The pre-existing suites
remain green after the [P5-T3] call-site change in `claude-customizations.ts`.

## Result lines, quoted verbatim

```
Test Suites: 17 passed, 17 total
Tests:       234 passed, 234 total
Snapshots:   0 total
Time:        1.358 s, estimated 3 s
Ran all test suites matching test/lib/push-down.
```

Failed count: 0 suites failed and 0 tests failed.

## Suites included in the run

Enumerated with `cd extensions/drm-copilot && npx jest test/lib/push-down --listTests` (exit code 0),
normalized to repository-relative form. The three suites the acceptance condition names are present
and are inside the passing set:

```
test/lib/push-down/blast-radius-derive.test.ts
test/lib/push-down/blast-radius-derive-core.test.ts
test/lib/push-down/claude-config-carriage.test.ts
test/lib/push-down/claude-customizations.test.ts
test/lib/push-down/claude-filesystem-adapter.test.ts
test/lib/push-down/claude-gitignore-delivery.test.ts
test/lib/push-down/claude-gitignore-merge.test.ts
test/lib/push-down/claude-pack-manifest-completeness.test.ts
test/lib/push-down/claude-pack-name-translation.test.ts
test/lib/push-down/claude-pack-selection.test.ts
test/lib/push-down/codex-agents-customizations.test.ts
test/lib/push-down/codex-pack-selection.test.ts
test/lib/push-down/copilot-customizations.test.ts
test/lib/push-down/copilot-customizations-engine.test.ts
test/lib/push-down/filesystem-adapter.test.ts
test/lib/push-down/push-down-service-call.test.ts
test/lib/push-down/reference-rewrites.test.ts
```

- `claude-config-carriage.test.ts` — present, green.
- `claude-customizations.test.ts` — present, green.
- `claude-pack-manifest-completeness.test.ts` — present, green.
