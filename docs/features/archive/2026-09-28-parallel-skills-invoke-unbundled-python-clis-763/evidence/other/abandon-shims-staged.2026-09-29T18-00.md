# Abandon Shims Staged as Executable LF Files (P2-T4)

Timestamp: 2026-09-29T18-00
Command: git add -- tests/fixtures/parallel_abandon_path tests/fixtures/parallel_abandon_path_git_only ; git add --chmod=+x -- tests/fixtures/parallel_abandon_path tests/fixtures/parallel_abandon_path_git_only ; git ls-files -s -- tests/fixtures/parallel_abandon_path tests/fixtures/parallel_abandon_path_git_only ; git ls-files --eol -- tests/fixtures/parallel_abandon_path tests/fixtures/parallel_abandon_path_git_only ; git status --porcelain -- tests/fixtures
EXIT_CODE: 0
Output Summary:
CMD-GIT-LS-MODE (three lines, each `100755`):
100755 6dbeba13d2c2265448e6070310ffefe0d6a3db3a 0	tests/fixtures/parallel_abandon_path/gh
100755 697f893012df760f22cd8e19d5f4c31f823402b3 0	tests/fixtures/parallel_abandon_path/git
100755 697f893012df760f22cd8e19d5f4c31f823402b3 0	tests/fixtures/parallel_abandon_path_git_only/git
CMD-GIT-LS-EOL (three lines, each `i/lf` and `w/lf`):
i/lf    w/lf    attr/text=auto eol=lf 	tests/fixtures/parallel_abandon_path/gh
i/lf    w/lf    attr/text=auto eol=lf 	tests/fixtures/parallel_abandon_path/git
i/lf    w/lf    attr/text=auto eol=lf 	tests/fixtures/parallel_abandon_path_git_only/git
Porcelain under tests/fixtures:
A  tests/fixtures/parallel_abandon_path/gh
A  tests/fixtures/parallel_abandon_path/git
A  tests/fixtures/parallel_abandon_path_git_only/git

Guard-compliant spelling: the plan's CMD-GIT-CHMOD (`git update-index --chmod=+x -- <three file
paths>`) and the three-file CMD-GIT-LS-MODE and CMD-GIT-LS-EOL name `git` more than once, which the
worktree isolation guard refuses. `git add --chmod=+x` over the two shim directories sets the same
executable bit in the index on the same three files, and the two listings use the two directories
as pathspecs, which select exactly the three shims (see
evidence/other/execution-substitutions.2026-09-29T17-39.md).
