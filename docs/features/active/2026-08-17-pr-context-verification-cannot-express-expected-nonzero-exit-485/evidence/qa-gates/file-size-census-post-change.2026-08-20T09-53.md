# Gate — post-change file-size census (AC19)

Timestamp: 2026-08-20T09-53

Task: [P7-T11]

Command: pwsh -NoProfile -Command "foreach ($f in @(<the seven paths below>)) { (Get-Content $f).Count }"
EXIT_CODE: 0

## Line counts after the change

| File | Lines | Baseline ([P0-T4]) | 500-line limit |
| --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 215 | 171 | within (285 lines of headroom) |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 303 | 248 | within (197) |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 454 | 449 | within (46) |
| `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` | 408 | new file | within (92) |
| `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` | 117 | new file | within (383) |
| `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` | 456 | 219 | within (44) |
| `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` | 445 | 383 | within (55) |

Every listed file is at or under 500 lines. AC19 is satisfied for both changed parser files, for the
changed TypeScript renderer, and for every new or modified test file.

## Restatement of the pre-existing overage

`scripts/dev_tools/pr_context/collector.py` is not in the table above because it was ALREADY over the
500-line limit before this change, at 619 lines, as recorded at [P0-T4]. That overage is pre-existing
and is not created here; extraction or splitting of the file is out of scope per `spec.md`. This change
adds exactly 4 lines to it, inside the AC20 cap of 5, measured at [P5-T6] and re-confirmed at
[P8-T11]. The other two pre-existing over-limit files,
`tests/scripts/dev_tools/test_collect_pr_context_part4.py` (1026 lines) and
`tests/scripts/dev_tools/test_collect_pr_context.py` (654 lines), received ZERO changed lines; the new
Python collector-level cases went into the new 117-line sibling module instead.

Output Summary: All seven listed files are within the 500-line limit — 215, 303, 454, 408, 117, 456,
and 445 lines. The tightest margin is 44 lines (`verification-evidence.test.ts`). The pre-existing
619-line overage of `collector.py` is unchanged in kind and grew by exactly 4 lines, inside the AC20
cap of 5.
