# Final Shell Format Check (issue #953, P6-T7, post-split restart pass)

Timestamp: 2026-10-16T09-58
Command: shfmt -d .devcontainer/post-create.sh .github/codex/codex-web-setup.sh > SCRATCH/issue-953-final-shfmt.txt (read-only diff mode; script SCRATCH/issue-953-p6-t7.sh, run with sh), then substitution of the four P5-T1/P5-T2 new line texts by their base-commit texts and cmp against SCRATCH/issue-953-baseline-shfmt.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: shfmt exit 1 equals the P0-T24 shfmt exit code 1, from formatting differences that already existed in both files at baseline. The final output is 814 lines, the same as the baseline. None of the four new line texts occurs in the final output, so the substitution changes nothing; cmp reports the final output byte-identical to issue-953-baseline-shfmt.txt both before and after substitution. No new formatting difference.
KCOV_POPULATION: NOT-INCLUDED (.claude/rules/shell.md:67-70)

BASELINE_SHFMT_EXIT: 1
FINAL_SHFMT_EXIT: 1
NEW_LINE_TEXT_OCCURRENCES: 0
OUTPUT_EQUAL_TO_BASELINE: YES
