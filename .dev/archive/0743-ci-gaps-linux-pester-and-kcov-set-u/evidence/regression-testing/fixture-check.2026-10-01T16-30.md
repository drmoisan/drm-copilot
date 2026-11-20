# Fixture Check (P1-T3 to P1-T6)

Timestamp: 2026-10-01T16-30

Created with the Write tool (P1-T3 to P1-T5), content exactly as R2, R3, R4. `tests/fixtures/shell_qc/kcov_trace/` contains only `nounset_lib.sh`. Each file's first line is `#!/usr/bin/env bash`.

| Path | Command | EXIT_CODE | Output |
| --- | --- | --- | --- |
| tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh | `tr -d -c '\r' < <path> \| wc -c` | 0 | `0` |
| tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh | `git check-attr text eol -- <path>` | 0 | `text: auto`, `eol: lf` |
| tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh | `sh -n <path>` | 0 | no output |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source | `tr -d -c '\r' < <path> \| wc -c` | 0 | `0` |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source | `git check-attr text eol -- <path>` | 0 | `text: auto`, `eol: lf` |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source | `sh -n <path>` | 0 | no output |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset | `tr -d -c '\r' < <path> \| wc -c` | 0 | `0` |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset | `git check-attr text eol -- <path>` | 0 | `text: auto`, `eol: lf` |
| tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset | `sh -n <path>` | 0 | no output |

Command: (per row above)
EXIT_CODE: 0
Output Summary: no carriage returns; all three paths carry `text: auto` and `eol: lf`; all three pass `sh -n`. `.gitattributes` was not edited.
