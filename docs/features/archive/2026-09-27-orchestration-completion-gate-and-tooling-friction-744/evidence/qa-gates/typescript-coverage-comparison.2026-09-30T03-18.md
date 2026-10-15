# QA Gate: TypeScript Coverage Comparison

Timestamp: 2026-10-02T01-51
Command: npm --prefix extensions/drm-copilot run test -- --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov
EXIT_CODE: 0
Loop iteration: 1
Output Summary:
- Totals: FinalTsLines% 97.07 vs BaselineTsLines% 97.07 (not below); FinalTsBranches% 91.35 vs BaselineTsBranches% 91.35 (not below). Raw: lines 50620/52146 vs 50618/52144; branches 7391/8090 vs 7391/8090.
- verification-evidence.ts row: % Branch 84.61 = 84.61, % Funcs 100 = 100. % Stmts and % Lines are 96.94 vs baseline 96.92, so they are NOT equal; deviation D-V8-COMMENT-LINES records why.
- Cause (verified): `extensions/drm-copilot/jest.config.cjs` sets `coverageProvider: "v8"`, which emits a `DA:` entry for every source line, including comment lines. The comment-only edit (`git diff -U0 b080a69ecb60b65d016362b21fffed0a34be9144 -- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`, hunks `@@ -111,3 +111,4 @@` and `@@ -127 +128,2 @@`) adds two net comment lines, both covered: 284/293 = 96.92 becomes 286/295 = 96.94.
- lcov `SF:src\lib\pr-context\verification-evidence.ts` record (final): `LF:295`, `LH:286`, `BRF:39`, `BRH:33`, `FNF:7`, `FNH:7`. Baseline equivalents derived from the P0-T26 row: LF 293, LH 284 (9 uncovered lines), BRH/BRF 33/39 (84.61%).
- Changed comment lines and `DA:` entries: under the v8 provider, `DA:` entries DO exist for the changed comment lines, as `DA:111,1`, `DA:112,1`, `DA:113,1`, `DA:114,1`, `DA:128,43`, and `DA:129,43`. All six are hit (count > 0), so none is uncovered. The plan's condition "no `DA:` entry corresponds to a changed comment line" assumes an instrumenting provider and cannot hold under v8; see D-V8-COMMENT-LINES.
- Uncovered-line set: baseline `131-132,271-272,282-283,288,290-291` (9 lines); final `133-134,273-274,284-285,290,292-293` (9 lines). The final set equals the baseline set shifted by +2, the two lines the comment edit added before line 131. No line became uncovered and no executable line changed.
