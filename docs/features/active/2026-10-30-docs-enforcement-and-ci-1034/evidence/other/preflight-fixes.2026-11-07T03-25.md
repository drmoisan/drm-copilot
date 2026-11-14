# Preflight Fixes - Issue 1034 Remediation Design Cycle 2 (confirming preflight)

Timestamp: 2026-11-07T03-25
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T02-24.md

## Fixes

- P1-T3 | validator-blind defect, correction keeps the assertion | The acceptance named six commands that disagree at head, but the command set holds eight that do. `gh pr merge --merge 2>&1 epic/x-integration` and `gh pr merge 1{2..2}` are in `### F1 remaining forms` and also disagree: a scratch run with real bash and a stand-in `gh` passed `epic/x-integration` and `12`, while the hook looked up the bare form and `1`. The acceptance now names all eight, so it cannot be read as requiring only six. What the task proves is unchanged.
- P2-T1 | validator-blind defect, correction keeps the assertion | Added that no helper function invokes a variable with `&`, because `enforcement-hooks-no-python-invocation.Tests.ps1`, which P2-T4 runs, reports that form as a dynamic invocation. A scratch prototype with a word-reader script block failed that suite; a prototype with the five functions and no such call passed it. No acceptance condition changes.
- P2-T7 | stale anchor | "the hook tree" now names `.claude/hooks` and `.claude/lib`, because `HOOK` imports modules under `.claude/lib` and the copy cannot load without them. A scratch copy of those two trees and `HOOK_SUITE` reported 111 passed. What the task asserts is unchanged.
