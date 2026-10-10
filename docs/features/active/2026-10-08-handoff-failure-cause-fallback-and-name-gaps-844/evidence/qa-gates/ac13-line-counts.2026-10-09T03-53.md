# AC-13 Post-Format Line Counts (P6-T2)

Timestamp: 2026-10-09T03-53
Task: [P6-T2]
Command: Grep tool, pattern `^`, output mode count, over each path below
EXIT_CODE: 0

| File | Pre-edit (P0-T3) | Post-format | <= 500 |
| --- | --- | --- | --- |
| extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts | 122 | 155 | yes |
| extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts | 488 | 494 | yes |
| extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts | 390 | 390 | yes |
| extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts | 139 | 138 | yes |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts | 500 | 154 | yes |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-test-support.ts | absent | 179 | yes |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-binding.test.ts | absent | 179 | yes |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts | 442 | 469 | yes |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts | 186 | 193 | yes |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts | absent | 170 | yes |

Output Summary: Pass (AC-13). All 10 blast-radius files under extensions/drm-copilot/ are at or under 500 lines; the largest is orchestration-handoff-materializer.ts at 494. The authority-service test file dropped from 500 to 154 after the split.
