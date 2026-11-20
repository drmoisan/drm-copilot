# Task Check P4-T4

Timestamp: 2026-11-18T10-32
Command: npx prettier --check / eslint / tsc x2 (extensions/drm-copilot); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down
EXIT_CODE: 0
Output Summary: `PDT/push-down-harness.real-bundle.test.ts` uses `ReadThroughPushDownFileSystem` over the extension directory (real reads, writes refused) and a fresh in-memory `/dest`, data-driven over Claude, Codex and Copilot. It passes with `installs every shared-layer file`, `writes nothing under another ecosystem's layer`, `publishes core plus selected packs`, `second apply is a no-op`, `keeps a local edit and reports conflict`, `first run without a manifest adopts and reports unmanaged-conflict` (with the `overwriteUnmanaged` case), `classifies a CRLF copy as unchanged`, `merges the Codex routing document`, `honors .push-down-exclusions for all three` and `publishes ecosystem-layer exceptions only in a Codex run`. The selection passed 46 suites and 667 tests. Its first draft run (09-13) found the merged-JSON idempotence defect, fixed per `evidence/other/execution-decision.merged-json-idempotence.2026-11-18T09-15.md`. One launch hit a queue timeout (exit 75) and was re-run.

- Changed files: `extensions/drm-copilot/test/lib/push-down/push-down-harness.real-bundle.test.ts`
- Selection rule: the new test plus the push-down suites it exercises.
