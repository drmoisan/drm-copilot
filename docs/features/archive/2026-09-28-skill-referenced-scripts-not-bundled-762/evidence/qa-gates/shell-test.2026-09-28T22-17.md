# Shell Test (P7-T3)

Timestamp: 2026-09-28T22-17
Command: sh SCRATCH/run-shell-qc.sh test
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: TAP plan `1..478` (the 477 baseline tests plus the one test added by P1-T14). Exactly two `not ok` lines, both members of KL-SHELL-2. These are local-WSL baseline failures with the same names and TAP numbers (282, 304) as the 2026-09-28T19-10 baseline. No other test failed. Local numeric bash coverage cannot be obtained while a KL-SHELL-2 member fails, because the wrapper prints `Bash coverage (lines):` only on a fully passing run. Bash coverage values for this language come from CI (P10-T5, P10-T6).

```text
not ok 282 dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)
not ok 304 dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)
```
