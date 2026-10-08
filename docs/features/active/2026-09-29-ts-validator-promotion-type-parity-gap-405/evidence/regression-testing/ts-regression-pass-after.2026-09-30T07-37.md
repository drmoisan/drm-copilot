# P3-T3 Phase 2 regression files re-run after the fix (pass-after)

Timestamp: 2026-09-30T07-37
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestrator-state-promotion-type-parity.test.ts test/lib/validate/orchestrator-state-routing.promotion-type.test.ts
EXIT_CODE: 0
Output Summary:
- `Test Suites: 2 passed, 2 total`; `Tests:       19 passed, 19 total` (fifteen corpus tests plus four routing-contract tests).
- The four corpus cases that failed in P2-T2 (`bug-large-bug-tool-declared-and-recorded`, `bug-large-feature-tool-only`, `bug-small-bug-tool-declared-and-recorded`, `bug-preparation-bug-tool-declared-and-recorded`) now pass: the corpus file reports 15 passed, 0 failed, where P2-T2 reported 4 failed, 11 passed. The Jest runner wrapper in this repository does not print per-test names, so the per-case statement is derived from the 15/15 count.
- P3-T1 module line count: `wc -l extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` printed 51 (below 500).
- P3-T2 diff observation: `git diff origin/main -- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` shows exactly one added import line (`import { resolvePromotionEntryTools } from "./orchestrator-state-promotion-tools";`) and the replaced declaration (`const requiredMcpTools = resolvePromotionEntryTools(` wrapped over four lines by Prettier style: the `routeList(rawRoute, "required_mcp_tools")` argument and `state`). No other line changed.
- P3-T2 porcelain observation: `git status --porcelain` printed ` M extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` and `?? extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`.
- Environment note: each command was run as a separate plain command (no `cd` chain, no `git -C`) per the worktree isolation guard.
