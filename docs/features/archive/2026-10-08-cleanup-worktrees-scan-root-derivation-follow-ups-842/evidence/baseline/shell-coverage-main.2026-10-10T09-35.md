# P0-T11 Baseline kcov line coverage from the most recent green main run

Timestamp: 2026-10-10T09-35
Command: gh run list --workflow ci.yml --branch main --event push --limit 10 --json databaseId,headSha,createdAt; gh run view RUN_ID --json jobs --jq (Shell Coverage conclusion); gh run view 38054308295 --log --job 114219517896 | grep -F "coverage (lines)"; gh run view 38054308295 --log --job 114219517896 | grep -c "not ok"; gh run download 38054308295 -n shell-coverage -D SCRATCH/ci-baseline; grep -n -F 'filename=".claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh"' SCRATCH/ci-baseline/cov.xml
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- The newest listed run, 38056076905 (headSha 179c586676d0f942043e349f7666852c551f25fb), was in progress; its Shell Coverage job conclusion was empty. It was skipped per the plan (first run printing success).
- BASELINE_RUN_ID = 38054308295, headSha 5431ccdd471c184917493c4211afcd715bb4b95c, Shell Coverage job conclusion: success. BASELINE_JOB_ID = 114219517896.
- Log line: `Bash coverage (lines): 94.2%`. BASELINE_AGGREGATE = 94.2.
- `grep -c "not ok"` on the job log printed 0 (grep exit 1, the pass condition).
- cov.xml enumerate-lib element at cov.xml line 984: `line-rate="0.953"`. BASELINE_ENUM_RATE = 0.953 (above the 0.850 threshold).
- Informational: scan helper line-rate 0.873 (cov.xml line 10); detached library line-rate 1.000 (cov.xml line 2061).
- Note: the first download attempt targeted a SCRATCH directory that already held files from an earlier session; the extraction failed with "The file exists" and the stale cov.xml in it reported 0.924. The values above come from a re-download of the same artifact into a new, empty SCRATCH directory (exit 0).
