# Changed-path contract gate

Timestamp: 2026-08-04T10-23-00-04:00

Command: Read `BaselineCommit` from `evidence/baseline/git-baseline.2026-08-04T09-49.md`; combine `git diff --name-only <baseline>` with `git ls-files --others --exclude-standard`; require every path to be one of the two approved implementation/test paths or beneath the issue #434 feature folder.

EXIT_CODE: 0

Output Summary: Baseline commit `8a3807b80683883e7fc1d3db22ae99f52a7d5715`. Nineteen unique changed or untracked paths were found. All nineteen were either the two approved TypeScript paths or issue #434 feature documents/evidence; unexpected path count was zero.
