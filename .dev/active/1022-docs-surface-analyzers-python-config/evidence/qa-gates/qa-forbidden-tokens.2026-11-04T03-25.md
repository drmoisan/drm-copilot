# [P6-T12] Forbidden-token scan (issue #1022)

Timestamp: 2026-11-04T03-25
Command: sh SCRATCH/issue-1022-p6t12-tokens.sh (builds the sorted union of `git diff --name-only MERGE_BASE`, `git status --porcelain --untracked-files=all` and `git ls-files --others --cached` of the feature folder, then runs a plain `grep -i -n -E -e 'r[g]f' -e 'fore[c]ast'` over every listed file that exists, covering untracked files)
EXIT_CODE: 0
Output Summary: Files scanned: 119 (the [P6-T8] union, this plan, spec.md, user-story.md and every evidence file under the feature folder, including this artifact; the scan was re-run after this artifact was written). Matches: 0 (empty result).
