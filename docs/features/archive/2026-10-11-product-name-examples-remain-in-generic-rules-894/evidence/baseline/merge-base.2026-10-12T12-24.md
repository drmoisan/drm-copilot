Timestamp: 2026-10-12T12-24
Command: git fetch origin main; git branch --show-current; git rev-parse HEAD; git merge-base origin/main HEAD; git diff --name-only 5dd9d1f33d1c0ccb01a6c34f6fefd959e020aa74 -- <rules, mirror rules, GUARD>; git status --porcelain --untracked-files=all -- <rules, mirror rules, GUARD>
EXIT_CODE: 0
Output Summary:
- Branch: bug/product-name-examples-remain-in-generic-rules-894 (equals BRANCH)
- HEAD: 8e14d5cf51e6e458ba6582cf5256882cda95d064
- MERGE_BASE: 5dd9d1f33d1c0ccb01a6c34f6fefd959e020aa74 (equals origin/main tip)
- Anchored diff: no output. Porcelain status: no output. Baseline measures the committed state.
Note: origin/main was merged into the branch after the plan was written; see the line-number corrections recorded in token-counts and line-counts artifacts.
