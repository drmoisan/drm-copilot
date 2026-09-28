# P0-T7 Anchor and Idempotence Survey (CR-ANCHOR)

Timestamp: 2026-09-27T10-00
Command: Route C (scratchpad cr-anchor.ps1 = CR-ANCHOR with <ROWS> = the seven EP-table rows, single quotes doubled in the S2 and S3 anchors, ending `exit $code`; run by `pwsh -NoProfile -File` via `sh` from the worktree root)
EXIT_CODE: 0
Output Summary:
ANCHOR: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=112
ANCHOR: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=395
ANCHOR: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=392
ANCHOR: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=461
ANCHOR: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=332
ANCHOR: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=487
ANCHOR: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | anchor=1 | mock=0 | import=0 | lines=223
EXIT_CODE_COMPUTED: 0

## Classification

| Suite | Classification |
|---|---|
| S1 enforce-pr-author-skill.TargetResolution.Tests.ps1 | MOCK-ABSENT |
| S2 enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | MOCK-ABSENT |
| S3 enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | MOCK-ABSENT |
| S4 enforce-orchestration-preimplementation-gate.Tests.ps1 | MOCK-ABSENT |
| S5 enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | MOCK-ABSENT |
| S6 enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | MOCK-ABSENT |
| S7 enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | MOCK-ABSENT |

ABSENT-COUNT: 7

Every anchor count is 1 and every line count is at most 498. No sibling (#707, #708, #710, #713) added the mock or the import to any of the seven suites on origin/main 849aae60.
