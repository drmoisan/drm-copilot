# Final QC: Shell Format (P8-T16 / P6-T7, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t7.sh" — `shfmt -d .devcontainer/post-create.sh .github/codex/codex-web-setup.sh > SCRATCH/issue-953-final-shfmt.txt`, the substitution of the four P5-T1/P5-T2 line texts by their base-commit texts, and `cmp` against `SCRATCH/issue-953-baseline-shfmt.txt`.
EXIT_CODE: 1

Output Summary:
- shfmt exit code 1, equal to the P0-T24 baseline shfmt exit code (1; pre-existing formatting differences).
- Output: 814 lines; occurrences of the new line texts in the output: 0.
- Substituted output vs baseline: identical (cmp 0); raw output vs baseline: identical (cmp 0). No new formatting difference.
- KCOV_POPULATION: NOT-INCLUDED (.claude/rules/shell.md:67-70)
- Result: PASS (exit code equals baseline; output equal).
