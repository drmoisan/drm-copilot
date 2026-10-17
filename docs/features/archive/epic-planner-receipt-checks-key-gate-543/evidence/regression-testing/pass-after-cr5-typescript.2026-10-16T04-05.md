# Pass-After CR-5 TypeScript (P3-T9)

Timestamp: 2026-10-16T04-05
Command: npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-planner-state-feature-indices.test.ts test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts --reporters=default --verbose > SCRATCH/rc1/ts-pass-after.txt 2>&1; grep -e 'Tests:' -e 'original feature index' -e 'feature index unchanged' -e 'positional pairing' -e 'no feature error' SCRATCH/rc1/ts-pass-after.txt
EXIT_CODE: 0
Output Summary:
- Tests:       14 passed, 14 total
- √ uses the original feature index after a non-object entry
- √ uses the original feature index after a plan-less entry
- √ keeps the feature index unchanged without skipped entries
- √ keeps the positional pairing when no entry carries the plan
- √ reports no feature error for a empty features value
- √ reports no feature error for a non-list features value
- √ uses the original feature index after a string entry
- √ uses the original feature index after a null entry
- √ uses the original feature index after a number entry
- √ uses the original feature index after a list entry
- √ uses the original feature index for receipt prefixes under a Codex flag
- √ uses the original feature index for dependency-wave prefixes
- √ uses the original feature index for launch-binding prefixes under a Codex flag
- √ keeps the feature index unchanged without non-object entries
- Paired fail-before runs: evidence/regression-testing/fail-before-cr5-typescript.2026-10-16T03-54.md (7 failed, 1 passed) and evidence/regression-testing/fail-before-cr5-git-typescript.2026-10-16T03-56.md (2 failed, 4 passed).
