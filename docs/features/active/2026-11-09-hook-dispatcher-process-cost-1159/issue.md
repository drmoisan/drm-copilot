# Feature: Hook process cost: one dispatcher per tool call

- Issue: #1159
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1159
- Work Mode: full-feature
- Source: mirrored from the GitHub issue body (adopted issue, filed before orchestration); the issue names `docs/features/potential/2026-11-09-hook-dispatcher-process-cost.md` as its source, which is not present in the repository tree.

## Problem / Why

Every Bash tool call starts 12-15 separate PowerShell hook processes, each using roughly a third to half of a core for about a second. With about ten agents active, hook start-up alone kept machine load high even when no tests were running.

## Proposed Behavior

- Measure per-tool-call hook cost: process count, CPU seconds, wall time.
- Consolidate the PreToolUse hooks for each tool into a single dispatcher process per call that loads the shared modules once and evaluates every check in it; alternatively move cheap pattern checks into a lightweight front filter that starts PowerShell only when a check needs it.
- Keep each hook's decision logic and deny codes unchanged, with a parity suite showing identical decisions before and after.

## Acceptance Criteria

- [ ] A repeatable measurement of per-tool-call hook cost (process count, CPU seconds, wall time) exists and is run before and after.
- [ ] PreToolUse hooks per tool run in one dispatcher process (or behind a front filter) that loads shared modules once.
- [ ] Each hook's decision logic and deny codes are unchanged, proven by a parity test suite comparing decisions before and after across the existing hook test corpus.
- [ ] The PR reports before and after cost.
- [ ] settings.json hook registration, hook documentation, and the push-down payload are updated consistently.

## Constraints & Risks

(not provided in potential file)

## Test Conditions

(not provided in potential file)
