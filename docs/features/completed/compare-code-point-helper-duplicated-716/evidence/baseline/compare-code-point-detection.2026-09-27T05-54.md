# Duplicate detection — compareCodePoint in pr-context

Timestamp: 2026-09-27T05-54
Command: git grep -n "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context (cwd: repository root)
EXIT_CODE: 0
Output Summary:
Raw matches (8):
- extensions/drm-copilot/src/lib/pr-context/autoclose.ts:296:function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/collector-core.ts:388:function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:305:export function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts:128:export function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts:439:function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:388:function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/render.ts:381:function compareCodePoint(left: string, right: string): number {
- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:274:function compareCodePoint(left: string, right: string): number {

Per-file status (the eight files named in plan P1-T1):
| File | Status | Phase 2 task |
|---|---|---|
| collector-core.ts | matched (private copy present) | P2-T2 applies |
| autoclose.ts | matched (private copy present) | P2-T3 applies |
| feature-docs-parsers.ts | matched (exported copy present) | P2-T4 applies |
| gh-client-details.ts | matched (exported copy present) | P2-T5 applies |
| render.ts | matched (private copy present) | P2-T6 applies |
| render-pr-helpers.ts | matched (private copy present) | P2-T7 applies |
| render-feature-excerpts.ts | matched (private copy present) | P2-T8 applies |
| verification-evidence.ts | matched (private copy present) | P2-T9 applies |

No file is already satisfied; no sibling branch has consolidated any of these copies as of this run. `models.ts` has no definition at this point (P2-T1 adds it).
