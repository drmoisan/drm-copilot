# P4-T1 loader prerequisite verification

Timestamp: 2026-10-19T02-12 UTC, retained-proof reconciliation command start.
Command: `poetry run python SCRATCH/issue-980-p4t1-loader-final-binding.py`
EXIT_CODE: 0
Output Summary: Frozen reviewed source hashes, four successful ordered gate receipts and raw baseline/final coverage agree. All 202 previously covered loader lines map to covered final lines; the two added executable lines (28 and 414) are covered. The only executed-branch destination adjustment is the existing loop exit to the approved new helper call; every other executed and all missing destinations map exactly, preserving 112/118 coverage. No behavior was rerun by this verifier.

Raw binding record: [p4t1-executor-loader-final-bindings.2026-10-19T02-12.json](p4t1-executor-loader-final-bindings.2026-10-19T02-12.json). The loader has 204/204 covered lines; the new helper has 22/22 lines and 14/14 branches. Every measured class/callable range is 100% line-covered. The two existing test modules preserve accepted working-byte and Git identities. Final source/test hashes match the retained documentation-repair confirmation.

The actual final loop is Black, Ruff, scoped Pyright and 62 passing tests in 169.44 seconds. The test command reverses the two baseline module positions and runs the new inventory module first. This establishes the reported module-order check; it is not described as exact reverse individual-node execution. Baseline 44 and candidate 18 cases are retained. The original invalid collection invocation and resolved documentation finding remain historical evidence.

The approved loader prerequisite is verified on this bounded evidence. P4-T1 remains pending the analyzer candidate, first-publication and consistent recapture composition, full task architecture/contracts/integration gates, final complete source/index bindings and authorized checkoff. No plan/AC or checkpoint/Git changes were made.

The initial checker rejected direct old-to-new branch mapping at the inserted call. Its exact script and diagnostic are retained in the checker-correction evidence. Removing only the approved import and straight-line helper call yields the exact original accepted AST; both the inserted call and following `_git` statement are covered. The corrected comparison accounts only for that proven edge change and does not conceal any implementation or test failure.

Evidence normalization confirmation:

Timestamp: 2026-10-19T02-13 UTC, preservation-binding command start.
Command: `poetry run python SCRATCH/issue-980-p4t1-loader-bind-normalization.py`
EXIT_CODE: 0
Output Summary: All 20 original evidence files match their retained checksums; three SQLite databases are preserved only under external `SCRATCH`, and four Markdown renderings change only documented path/destination references. Raw JSON, source/test bytes, diagnostic results and successful gate counts remain unchanged. No test was rerun.

The normalization manifest is [p4t1-loader-evidence-normalization.2026-10-19T02-09.json](p4t1-loader-evidence-normalization.2026-10-19T02-09.json). Published coverage keys are repository-relative; operational SQLite paths stay outside tracked evidence. Original receipt bytes and the initial checker failure remain retained and explicitly referenced in the raw binding record.
