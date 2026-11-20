# Pre-change file-size census

Timestamp: 2026-08-20T09-53

Task: [P0-T4]

Command: pwsh -NoProfile -Command "foreach ($p in @(<the seven paths below>)) { (Get-Content $p).Count }"
EXIT_CODE: 0

## Line counts (pre-change)

| File | Lines | 500-line limit |
| --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 171 | within |
| `scripts/dev_tools/pr_context/collector.py` | 619 | OVER (pre-existing) |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 248 | within |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 449 | within (51 lines of headroom) |
| `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` | 219 | within |
| `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` | 383 | within |
| `tests/scripts/dev_tools/test_collect_pr_context_part4.py` | 1026 | OVER (pre-existing) |

Seven counts recorded.

## Pre-existing-overage statement

`scripts/dev_tools/pr_context/collector.py` (619 lines) and
`tests/scripts/dev_tools/test_collect_pr_context_part4.py` (1026 lines) are ALREADY over the
500-line limit of `.claude/rules/general-code-change.md` BEFORE this change. That overage is
pre-existing and is NOT created by this change. Extraction or splitting of either file is out of
scope per `spec.md` ("Rendering decision — in scope, with an explicit boundary"). This change caps
`collector.py` growth at 5 added lines (AC20, gated at [P5-T6]) and adds ZERO changed lines to
`test_collect_pr_context_part4.py` (AC20, AC25, gated at [P5-T6] and [P8-T11]); the new Python
collector-level cases go into the new sibling module
`tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`.

A third file, `tests/scripts/dev_tools/test_collect_pr_context.py` (654 lines, recorded at plan
constraint SC5), is likewise already over the limit and likewise receives zero changed lines.

Output Summary: Seven line counts recorded. Two of the seven files are already over the 500-line
limit before this change (`collector.py` at 619, `test_collect_pr_context_part4.py` at 1026); the
overage is pre-existing and not created here. The four files this change will modify or create in
the parser and renderer layer have headroom: `verification_evidence.py` 171, `verification-evidence.ts`
248, `collector-output.ts` 449, `collector-output.test.ts` 383, `verification-evidence.test.ts` 219.
