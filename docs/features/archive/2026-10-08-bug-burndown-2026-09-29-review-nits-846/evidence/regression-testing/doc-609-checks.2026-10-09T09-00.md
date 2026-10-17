# Regression: #609 point-in-time records unchanged ([P7-T18], AC-26)

Merge-base substitution: anchored commands use 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a (recorded by [P0-T4]) in place of the plan literal e7d3779b398604af919678c16c877c8539a86cc0.

Timestamp: 2026-10-09T21-40
Command: git diff --name-only 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- 'docs/features/active/2026-08-30-*-609/evidence/other/ac-gaps.2026-09-29T18-45.md' 'docs/features/active/2026-08-30-*-609/evidence/other/ac-status-summary.2026-09-29T18-45.md' 'docs/features/active/2026-08-30-*-609/evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md' 'docs/features/active/2026-08-30-*-609/evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md'
EXIT_CODE: 0
Output Summary: nothing printed; the four superseded files are unchanged. Supplementary check: `git ls-files --` with the same four quoted pathspecs printed all four tracked paths, so each pathspec resolves to its file.

## Block 2

Command: git status --porcelain --untracked-files=all -- 'docs/features/active/2026-08-30-*-609/'
EXIT_CODE: 0
Output Summary: nothing printed. Observed deviation: the work is not yet committed, so the empty result does not come from the "already committed" case the plan anticipated. The quoted wildcard pathspec ending in `/` does not match the untracked file beneath the folder (git wildcard pathspec matching is applied to the full path, and the trailing `/` pattern matches only the directory entry itself). The same check was therefore rerun with forms that do match:

Command: git status --porcelain --untracked-files=all -- 'docs/features/active/2026-08-30-*-609/**'
EXIT_CODE: 0
Output Summary: exactly one line:

```
?? docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.2026-10-09T09-00.md
```

The literal folder pathspec (`git status --porcelain --untracked-files=all -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/`) printed the same single line; it was not denied by the command-text guard.

Acceptance (AC-26): first block prints nothing; the matching status form prints exactly one line, `?? ` followed by the new summary path. PASS (with the recorded pathspec deviation).
