# Coverage Delta ([P4-T4])

Timestamp: 2026-11-20T07-47
Command: node SCRATCH/issue-1016-delta.cjs SCRATCH/issue-1016-baseline-lcov.info SCRATCH/issue-1016-final2-lcov.info <worktree> 5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3 (for each changed file it runs git -C <worktree> diff -U0 <baseline HEAD> -- <file>, maps unchanged post-change lines to baseline lines through the hunk headers, and compares the zero-count DA and BRDA records)
EXIT_CODE: 0
Output Summary: no changed file gains a zero-count record; each of the thirteen new files is at or above 85% lines and 75% branches (`evidence/qa-gates/ts-test-coverage.2026-11-20T07-47.md`). Pass 1 of the loop found one gained record (`src/mcp-server.ts` DA 133, the added `startStdioServer` header, never executed); a test was added and Phase 4 restarted from [P4-T1]; this comparison is from the pass-2 gate run.

Inputs: baseline records and `HEAD` 5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3 from `evidence/baseline/ts-test-coverage.2026-11-20T06-54.md` (the SCRATCH copy of its lcov carries the same records); post-change records from the [P4-T3] pass-2 run. The diff is from that `HEAD` to the working tree the run measured. Gained-record rule as stated in [P4-T4].

| File | Baseline lines | Post lines | Line delta | Baseline branches | Post branches | Branch delta | Gained zero-count records |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `src/mcp-tools.ts` | 473/488 (96.93) | 480/495 (96.97) | +0.04 | 97/104 (93.27) | 99/106 (93.40) | +0.13 | none |
| `src/mcp-tool-definitions.ts` | 473/473 (100.00) | 475/475 (100.00) | 0.00 | 0/0 (100.00) | 0/0 (100.00) | 0.00 | none |
| `src/mcp-repo-automation-tool-definitions.ts` | 436/436 (100.00) | 438/438 (100.00) | 0.00 | 0/0 (100.00) | 0/0 (100.00) | 0.00 | none |
| `src/repo-automation-service.ts` | 513/513 (100.00) | 528/528 (100.00) | 0.00 | 47/50 (94.00) | 48/51 (94.12) | +0.12 | none |
| `src/repo-automation-tool-names.ts` | 55/55 (100.00) | 56/56 (100.00) | 0.00 | 0/0 (100.00) | 0/0 (100.00) | 0.00 | none |
| `src/mcp-server.ts` | 111/136 (81.62) | 152/172 (88.37) | +6.75 | 8/12 (66.67) | 14/17 (82.35) | +15.69 | none |
| `src/lib/subprocess-runner.ts` | 140/142 (98.59) | 147/149 (98.66) | +0.07 | 19/20 (95.00) | 21/22 (95.45) | +0.45 | none |
| Seven changed files, total | 2201/2243 (98.13) | 2276/2313 (98.40) | +0.27 | 171/186 (91.94) | 182/196 (92.86) | +0.92 | none |
| Repository text-summary totals | Lines 97.51% (71883/73715); Branches 94.83% (11414/12036) | Lines 97.58% (74504/76344); Branches 94.95% (11903/12536) | +0.07 | | | +0.12 | |

Zero-context hunk headers used for the line map (baseline start,count to post start,count):

- `src/mcp-tools.ts`: -76,0 +77,1; -346,0 +348,6
- `src/mcp-tool-definitions.ts`: -9,0 +10,1; -469,0 +471,1
- `src/mcp-repo-automation-tool-definitions.ts`: -9,0 +10,1; -432,0 +434,1
- `src/repo-automation-service.ts`: -40,0 +41,5; -501,0 +507,10
- `src/repo-automation-tool-names.ts`: -25,0 +26,1
- `src/mcp-server.ts`: -10,0 +11,4; -117,0 +122,6; -123,1 +133,1; -128,0 +139,26
- `src/lib/subprocess-runner.ts`: -23,0 +24,2; -27,0 +30,1; -107,1 +110,1; -110,0 +114,4
