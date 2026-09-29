# Shell QC Discovery Tests Before Library Change (P1-T16) [expect-fail]

Timestamp: 2026-09-28T22-02
Command: sh SCRATCH/run-bats.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: TAP plan `1..32`; exactly four `not ok` lines, naming the four expected tests. This is the fail-before evidence for AC5.

```text
not ok 10 discover_shell_scripts finds a .sh file under the .claude/skills root
#   `[[ "$output" == *".claude/skills/demo-skill/scripts/skill_entry.sh"* ]]' failed
not ok 13 discover_shell_scripts output is sorted and de-duplicated
#   `[ "${#lines[@]}" -eq 7 ]' failed
not ok 20 check invokes shfmt once over the full list and shellcheck once per file
#   `[ "$shellcheck_calls" -eq 7 ]' failed
not ok 26 test --coverage builds the kcov argv and merges the runs
#   `[[ "$output" == *"--include-pattern="*"/.claude/skills"* ]]' failed
```

Execution notes:
- A direct `> file` redirect of the WSL invocation captured only bats' stderr warnings; stdout was captured through a pipe (`2>&1 | cat > SCRATCH/p1t16.txt`), and the exit code was read from `PIPESTATUS[0]`.
- The P1-T15 count required `MSYS_NO_PATHCONV=1` in the environment, because Git for Windows' MSYS layer rewrote the leading-slash literal argument; with conversion disabled, `git grep -c -F -e '"/.claude/skills"'` printed `tests/shell/test_shell_qc_commands.bats:1`.
