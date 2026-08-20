# Pass-after — parity pair closed, plus the AC8 shape-by-shape agreement result

Timestamp: 2026-08-20T09-53

Command: poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py
EXIT_CODE: 0

Command: (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/verification-evidence.test.ts
EXIT_CODE: 0

Command: poetry run python <scratchpad>/shape_crossruntime.py
EXIT_CODE: 0

Task: [P4-T12]

## Both regressions now pass

| Runtime | Command | Result |
| --- | --- | --- |
| Python | `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py` | 54 passed, 0 failed, exit 0 |
| TypeScript | `npm run test:unit -- test/lib/pr-context/verification-evidence.test.ts` | 28 passed, 0 failed, exit 0 |

The two Phase 1 fail-before runs
(`evidence/regression-testing/py-parser-fail-before.2026-08-20T09-53.md` and
`evidence/regression-testing/ts-parser-fail-before.2026-08-20T09-53.md`, both EXIT_CODE 1) are
closed. The parity pair opened in Phase 2 and completed in Phase 4 lands in one change set (SC2).

## AC8 — shape-by-shape cross-runtime agreement

Method: the Jest suite passes, so every value declared in the TypeScript shape table equals that
runtime's actual record. The comparison therefore reads the eleven declared TypeScript entries
directly out of
`extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` and compares each against
the Python parser's ACTUAL record for the same markdown, in this worktree.

Resolved paths printed by the comparison, proving it exercised this worktree:

```
RESOLVED_PY_PARSER C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad8da196d6247bdf4\scripts\dev_tools\pr_context\verification_evidence.py
RESOLVED_TS_TABLE  C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad8da196d6247bdf4\extensions\drm-copilot\test\lib\pr-context\verification-evidence.test.ts
TS_TABLE_ENTRIES=11
```

Result per shape, as `(normalized_result, exit_code, expectation)`:

```
shape-01 AGREE: py=(pass,0,0)              ts=(pass,0,0)
shape-02 AGREE: py=(fail,1,0)              ts=(fail,1,0)
shape-03 AGREE: py=(unparseable,None,0)    ts=(unparseable,None,0)
shape-04 AGREE: py=(unparseable,None,0)    ts=(unparseable,None,0)
shape-05 AGREE: py=(unparseable,None,0)    ts=(unparseable,None,0)
shape-06 EXCLUDED (two EXIT_CODE lines):   py=(pass,0,0)  ts=(fail,1,0)
shape-07 AGREE: py=(pass,0,0)              ts=(pass,0,0)
shape-08 AGREE: py=(fail,2,0)              ts=(fail,2,0)
shape-09 AGREE: py=(pass,1,1)              ts=(pass,1,1)
shape-10 AGREE: py=(fail,2,1)              ts=(fail,2,1)
shape-11 AGREE: py=(unparseable,None,0)    ts=(unparseable,None,0)
COMPARED=10 DIFFERENCES=0 EXCLUDED=shape-06
```

Ten in-scope shapes agree across runtimes with ZERO differences.

## shape-06 exclusion statement

shape-06 is EXCLUDED from the cross-runtime agreement assertion because it is the
duplicated-`EXIT_CODE` case: `spec.md`'s own shape table defines row 6 as pinning each runtime's
EXISTING duplicate-`EXIT_CODE` precedence. Python assigns unconditionally in the parse loop
(`scripts/dev_tools/pr_context/verification_evidence.py:127-128`), so LAST occurrence wins and it
reports `(pass, 0)`. TypeScript guards with `!parsed.has(key)`
(`extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:135-140`), so FIRST occurrence
wins and it reports `(fail, 1)`. That divergence is PRE-EXISTING, is deferred by plan constraint SC3
and by the spec's Option P2 decision, and is not introduced by this change: no task in this plan
alters the `EXIT_CODE` assignment in either parse loop. The new optional expectation key is
first-wins in BOTH runtimes, which shapes 09 through 11 and the duplicate-key tests in each suite
confirm.

Output Summary: Both parser regressions pass with exit code 0 — 54 Python tests and 28 TypeScript
tests, 0 failures. The AC8 shape-by-shape comparison reports 10 shapes compared, 0 differences, and
shape-06 excluded as the duplicated-`EXIT_CODE` case whose per-runtime precedence divergence is
deferred by SC3 and pre-exists this change. The resolved Python parser path and TypeScript table
path are both inside this worktree, so the comparison exercised the post-change code.
