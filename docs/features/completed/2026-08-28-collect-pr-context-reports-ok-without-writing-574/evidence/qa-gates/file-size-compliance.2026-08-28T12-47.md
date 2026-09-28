# Phase 7 — File-Size Compliance for Every File This Change Writes

Timestamp: 2026-08-28T12-47

Task: [P7-T2]

Both commands read
`docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt`,
the 57-path union derived by `[P7-T1]`. Working directory: repository root.

---

## Run 1 — non-Markdown files, subject to the 500-line limit

Command: `pwsh -NoProfile -Command "Get-Content docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt | Where-Object { $_ -notlike '*.md' } | ForEach-Object { [pscustomobject]@{ Path = $_; Lines = (Get-Content -LiteralPath $_).Count } } | Sort-Object Lines -Descending"`

EXIT_CODE: 0

The recorded exit code is the exit code of the `pwsh` command itself, captured directly and not
from a pipeline tail.

### Output Summary

Sorted descending by line count:

| Lines | Path |
| --- | --- |
| **491** | `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` |
| 487 | `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` |
| 485 | `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` |
| 474 | `scripts/dev_tools/pr_context/collector.py` |
| 463 | `extensions/drm-copilot/test/extension.integration.test.ts` |
| 460 | `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` |
| 416 | `scripts/dev_tools/pr_context/summary_helpers.py` |
| 387 | `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` |
| 345 | `scripts/dev_tools/pr_context/collector_documents.py` |
| 302 | `tests/scripts/dev_tools/test_pr_context_freshness.py` |
| 294 | `extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts` |
| 276 | `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` |
| 260 | `extensions/drm-copilot/jest.config.cjs` |
| 171 | `extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts` |
| 153 | `extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts` |
| 141 | `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` |
| 126 | `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` |
| 57 | `docs/features/.../evidence/other/changed-files.txt` |
| 20 | `docs/features/.../evidence/other/scope-files.txt` |

Nineteen non-Markdown paths, each with an integer line count.

**The largest recorded line count is 491, which is at most 500. The gate passes.**

The three closest to the limit are `repo-automation-dispatch.test.ts` at 491, nine lines of
headroom; `extension.collect-pr-context.test.ts` at 487, thirteen lines; and `collector-output.ts`
at 485, fifteen lines. `scripts/dev_tools/pr_context/collector.py` is at 474, down from 623 at
baseline where it exceeded the limit; that pre-existing overage is what `[P4-T1]` repaired.

---

## Run 2 — Markdown files, recorded as information only

Command: `pwsh -NoProfile -Command "Get-Content docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt | Where-Object { $_ -like '*.md' } | ForEach-Object { [pscustomobject]@{ Path = $_; Lines = (Get-Content -LiteralPath $_).Count } } | Sort-Object Lines -Descending"`

EXIT_CODE: 0

### Output Summary

Thirty-eight Markdown paths. The largest are:

| Lines | Path |
| --- | --- |
| 471 | `docs/features/.../research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md` |
| 412 | `docs/features/.../spec.md` |
| 403 | `docs/features/.../plan.2026-08-28T09-31.md` |
| 169 | `docs/features/.../evidence/other/changed-files.2026-08-28T12-47.md` |
| 99 | `docs/features/.../evidence/baseline/py-pytest-coverage.2026-08-28T12-47.md` |
| 96 | `docs/features/.../evidence/baseline/git-baseline.2026-08-28T12-47.md` |
| 92 | `docs/features/.../evidence/baseline/python-batch-budget.2026-08-28T12-47.md` |
| 82 | `docs/features/.../evidence/other/collector-size.2026-08-28T12-47.md` |
| 75 | `docs/features/.../evidence/qa-gates/ts-coverage-thresholds.2026-08-28T12-47.md` |
| 75 | `docs/features/.../evidence/qa-gates/push-down-parity.2026-08-28T12-47.md` |

The six skill copies are 51 or 52 lines each: the `.claude` pair at 52 and the `.github` and
`.agents` pairs at 51, the one-line difference being the pre-existing trailing blank line in the
`.claude` copy. Each bundled copy matches its self-hosted counterpart exactly.

Two entries report 0 lines: this artifact and
`evidence/qa-gates/scope-invariants.2026-08-28T12-47.md`. Both were created empty as placeholders
before the two measurement commands ran, so that the porcelain span of `[P7-T1]` would enumerate
them and the union would be complete. Both are written with their content immediately after these
measurements.

**These Markdown counts are recorded as information only and are not subject to the 500-line
limit.** `.claude/rules/general-code-change.md` exempts Markdown documentation files from the
limit under its File Size Limit exceptions. The exemption matters here for a concrete reason: the
evidence artifacts of this feature carry verbatim coverage-table transcripts and verbatim command
output, and one of them exceeds 100 lines for that reason alone. A Markdown evidence file must not
fail this gate for a reason unrelated to the fix.
