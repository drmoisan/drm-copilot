# Phase 0 — Baseline Line Counts of Every File This Diff Will Write

Timestamp: 2026-08-28T12-47

Task: [P0-T14]

Command: `pwsh -NoProfile -Command "Get-Content docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/scope-files.txt | ForEach-Object { [pscustomobject]@{ Path = $_; Lines = (Get-Content -LiteralPath $_).Count } }"` (working directory: repository root)

EXIT_CODE: 0

The recorded exit code is the exit code of the `pwsh` command itself, captured directly and not
from a pipeline tail.

## Input list

`docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/scope-files.txt`
holds the twenty repo-relative paths drawn from items 1 through 24 of the plan's "Scope of the
diff" enumeration that exist at baseline. Items 6
(`scripts/dev_tools/pr_context/collector_documents.py`), 17
(`extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts`), 23
(`extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts`), and 24
(`tests/scripts/dev_tools/test_pr_context_freshness.py`) are the four paths marked new; they do
not yet exist and are omitted, which is why the list holds twenty entries rather than
twenty-four.

## Output Summary

| Path | Lines |
| --- | --- |
| `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` | 92 |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 454 |
| `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` | 362 |
| `scripts/dev_tools/pr_context/collector.py` | **623** |
| `scripts/dev_tools/pr_context/summary_helpers.py` | 386 |
| `extensions/drm-copilot/jest.config.cjs` | 245 |
| `.claude/skills/pr-context-artifacts/SKILL.md` | 30 |
| `.github/skills/pr-context-artifacts/SKILL.md` | 29 |
| `.agents/skills/pr-context-artifacts/SKILL.md` | 29 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md` | 30 |
| `extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md` | 29 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md` | 29 |
| `extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts` | 144 |
| `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` | 130 |
| `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` | 445 |
| `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts` | 171 |
| `extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts` | 281 |
| `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` | 447 |
| `extensions/drm-copilot/test/extension.integration.test.ts` | 437 |
| `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` | 487 |

Twenty paths, each with an integer line count. All twenty resolved; none was missing.

## Explicit statement about the 500-line limit at baseline

**`scripts/dev_tools/pr_context/collector.py` exceeds the 500-line limit at baseline, at 623
lines.** That is a pre-existing overage of 123 lines, and it is what `[P4-T1]` repairs by
extracting the two document-assembly blocks into the new module
`scripts/dev_tools/pr_context/collector_documents.py`.

No other path in the list exceeds 500 lines at baseline. The three closest are
`extensions/drm-copilot/test/repo-automation-dispatch.test.ts` at 487,
`extensions/drm-copilot/src/lib/pr-context/collector-output.ts` at 454, and
`extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` at 445, so headroom is
limited on all three and each is watched during the phases that edit it. The Markdown files in
the list are exempt from the limit under the file-size exception in
`.claude/rules/general-code-change.md`; their counts are recorded as information only.
