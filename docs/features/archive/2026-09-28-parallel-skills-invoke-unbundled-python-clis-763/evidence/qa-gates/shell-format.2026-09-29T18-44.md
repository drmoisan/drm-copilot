# Bash Format (P7-T1)

Timestamp: 2026-09-29T18-44
Command: git status --porcelain (before) ; sh SCRATCH/shell-format.sh ; git status --porcelain (after) ; sh SCRATCH/shell-lint.sh
EXIT_CODE: 0
Output Summary:
- A13: `SHFMT-WRITE-EXIT=0`
- The before and after porcelain outputs are byte-identical (`cmp` exit 0); both list only the
  checklist file and this phase's uncommitted evidence under FEATURE, so shfmt changed no file.
- A12: `SHFMT-DIFF-EXIT=0` (and `SHELLCHECK-EXIT=0`).
- Files covered: `.claude/lib/bash/abandon-parallel-item.sh`, `tests/fixtures/parallel_abandon_path/gh`,
  `tests/fixtures/parallel_abandon_path/git`, `tests/fixtures/parallel_abandon_path_git_only/git`.
