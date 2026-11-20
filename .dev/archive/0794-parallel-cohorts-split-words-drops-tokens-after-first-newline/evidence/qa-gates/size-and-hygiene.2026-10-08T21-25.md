# Size and hygiene (P4-T15) (AC-10, AC-13)

Timestamp: 2026-10-09T07-22
Command: wc -l (library, mirror, bats) ; cmp (library, mirror) ; grep -c -F "shellcheck disable" .claude/lib/bash/parallel-cohorts.sh ; sh -c 'grep -c -E "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|BATS_FILE_TMPDIR" tests/shell/parallel_cohorts.bats || true'
EXIT_CODE: 0
Output Summary: line counts 340, 340, 350 (all <= 500); cmp exit 0 with empty output; suppression count 2 equals N_sup; temporary-file token count 0.

wc -l: 340 / 340 / 350
cmp: (empty, exit 0)
shellcheck disable count: 2 (N_sup = 2)
temporary-file token count: 0
