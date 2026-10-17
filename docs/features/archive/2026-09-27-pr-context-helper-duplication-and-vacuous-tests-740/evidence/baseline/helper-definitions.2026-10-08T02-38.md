# Baseline Helper Definitions (P0-T17)

Timestamp: 2026-10-08T02-38
Command: git grep -n -E "function (sortedSet|relativeToPosix|escapeRegExp|splitLines)\(" -- extensions/drm-copilot/src/lib/pr-context
EXIT_CODE: 0
Output Summary: PASS. Exactly 12 output lines, matching the plan list as amended by DEV-1 (verification-evidence.ts:268 and :282 instead of :266 and :280). This proves the P2-T10 condition (exactly 4 lines) can fail.

```
extensions/drm-copilot/src/lib/pr-context/collector-core.ts:384:function sortedSet(values: Iterable<string>): string[] {
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:299:export function relativeToPosix(root: string, path: string): string {
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:314:function escapeRegExp(value: string): string {
extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts:123:function sortedSet(values: string[]): string[] {
extensions/drm-copilot/src/lib/pr-context/models.ts:221:export function splitLines(value: string): string[] {
extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts:431:function relativeToPosix(root: string, path: string): string {
extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts:440:function escapeRegExp(value: string): string {
extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:394:function splitLines(value: string): string[] {
extensions/drm-copilot/src/lib/pr-context/render.ts:377:function sortedSet(values: Iterable<string>): string[] {
extensions/drm-copilot/src/lib/pr-context/render.ts:387:function splitLines(value: string): string[] {
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:268:function relativeToPosix(root: string, absolute: string): string {
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:282:function splitLines(value: string): string[] {
```
