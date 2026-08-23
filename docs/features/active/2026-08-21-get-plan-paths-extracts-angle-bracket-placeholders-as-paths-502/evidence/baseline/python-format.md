# Baseline — Python Formatting — [P0-T2]

Timestamp: 2026-08-23T00-08

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T2]
State captured: PRE-CHANGE baseline

Command: `poetry run black --check .`

EXIT_CODE: 0

## Final summary line, verbatim

```text
438 files would be left unchanged.
```

The line ends with the literal `would be left unchanged.` as the acceptance requires.

## Would-reformat line check

```text
$ poetry run black --check . 2>&1 | grep -c '^would reformat '
0
```

Zero output lines begin with the literal `would reformat `. On a clean run Black emits no
per-file line and no reformatted count at all, only the two-line summary, which is why the
acceptance names the clean-run literal rather than a count.

## Read-only confirmation

The `--check` flag makes this invocation read-only: Black reports what it would change and
writes nothing. No before-and-after snapshot pair is therefore required here. The write-mode
form of the same command runs at [P8-T1], where the observation is the absence of a
`reformatted ` output line.

## Output Summary

Baseline Python formatting is clean: exit code 0, 438 files would be left unchanged, zero
would-reformat lines.
