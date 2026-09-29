# Shell QC Discovery Tests After the Library Change (P5-T3)

Timestamp: 2026-09-28T22-13
Command: sh SCRATCH/run-bats.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 0
Output Summary: TAP plan `1..32`; no `not ok` line. The four tests that failed in P1-T16 now pass (pass-after for AC5):

```text
ok 10 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 13 discover_shell_scripts output is sorted and de-duplicated
ok 20 check invokes shfmt once over the full list and shellcheck once per file
ok 26 test --coverage builds the kcov argv and merges the runs
```

Preceding edits (P5-T1, P5-T2) to `scripts/bash/shell_qc_lib.sh`, verified by `git grep -c -F`:
- `.claude/skills; do` count 1 (root loop now `for root in tools scripts .claude/lib/bash .claude/skills; do`; comment lines 76-77 updated).
- `/.claude/skills"` count 1 (include pattern gains `$repo_root/.claude/skills`; comment lines 333-334 updated; counted with `MSYS_NO_PATHCONV=1`).
- Library line count unchanged at 379.
