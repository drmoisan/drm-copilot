# r3 Final Coverage Delta (P5-T4)

Timestamp: 2026-10-16T22-25
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; CRP (steps 1-7) over SCRATCH/issue-953-r3-baseline-coverage.xml and SCRATCH/issue-953-r3-final-coverage.xml; key-set and per-file total comparison; CLD: git diff -U0 7558c7e42ec8c8955cb5f9997cca41afc6e3b797 -- scripts/powershell/PoshQC/PoshQC.Shard.psm1 parsed with ^@@ -\S+ \+(\d+)(?:,(\d+))? @@; L(MOD_KEY, nr) for each CLD line in the final report' (SCRATCH/issue-953-r3-p5-t4.sh)
EXIT_CODE: 0
Output Summary:
- Baseline: LINE_COVERED=17123 LINE_TOTAL=18594 LINE_PERCENT=92.09 SOURCEFILE_COUNT=208
- Final: LINE_COVERED=17136 LINE_TOTAL=18607 LINE_PERCENT=92.09 SOURCEFILE_COUNT=208
- Final CRP threshold (step 7, 85% line): PASS
- MOD_KEY baseline: covered=82 missed=0; MOD_KEY final: covered=95 missed=0 (100%; 100 * 95 >= 85 * 95: PASS)
- KEY_SETS_EQUAL=True; OTHER_KEYS_TOTAL_CHANGED=0 (every key other than MOD_KEY has an unchanged covered+missed total)
- CLD(scripts/powershell/PoshQC/PoshQC.Shard.psm1)=9,10,42,43,44,45,46,221,222,252,262-296
- L(MOD_KEY, nr) executable changed lines: 42 ci=3, 43 ci=1, 44 ci=3, 252 ci=2, 281 ci=1, 284 ci=1, 285 ci=1, 286 ci=1, 287 ci=2, 288 ci=1, 289 ci=1, 290 ci=1, 292 ci=1, 295 ci=1 (all mi=0); every other CLD line is ABSENT (help text, comments, braces, blank lines, and the param block).
- CHANGED_LINES=45 EXECUTABLE_CHANGED=14 UNCOVERED_CHANGED=0; uncovered numbers: none
- The bundled copies under extensions/drm-copilot/resources/powershell/PoshQC/ are outside the coverage roots of config/poshqc-coverage.json and are not measured; test files are not in the coverage population; Pester measures no branch coverage, so no branch gate applies.
- Result: PASS.
