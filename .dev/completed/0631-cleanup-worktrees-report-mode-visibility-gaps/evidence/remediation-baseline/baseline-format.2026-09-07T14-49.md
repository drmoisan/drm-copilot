# Baseline — bash format stage (remediation cycle 1, issue #631)

Timestamp: 2026-09-07T14-49

Command: `bash scripts/bash/shell-qc.sh format` followed immediately by
`git status --porcelain -- scripts/bash tests/shell tests/fixtures`

EXIT_CODE: 0

Output Summary:

- `bash scripts/bash/shell-qc.sh format` exited 0 and printed no output. Because `run_format`
  (`scripts/bash/shell_qc_lib.sh:204-224`) returns shfmt's exit code and prints nothing whether
  or not it rewrote a file, the exit code alone cannot distinguish a clean run from a repairing
  one; the porcelain observation below is the distinguishing evidence.
- `git status --porcelain -- scripts/bash tests/shell tests/fixtures` produced **empty output**
  (zero lines) and exited 0. The porcelain result is therefore empty: the formatter rewrote no
  tracked file under `scripts/bash`, `tests/shell`, or `tests/fixtures`, so the pre-remediation
  tree was already shfmt-clean and this was a clean run rather than a repairing one.
- No formatting drift existed in the baseline tree, so no formatting change is folded into the
  remediation diff.
