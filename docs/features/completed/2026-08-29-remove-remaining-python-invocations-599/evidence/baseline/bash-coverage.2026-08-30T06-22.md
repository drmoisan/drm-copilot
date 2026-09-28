# Baseline — Bash Test and Coverage (`shell-qc.sh test --coverage`)

Timestamp: 2026-08-30T06-22
Task: [P0-T3]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh test --coverage'`

EXIT_CODE: 0

Output Summary:

- **Coverage headline, verbatim as printed:** `Bash coverage (lines): 91.4%`
  This is the form `scripts/bash/shell_qc_lib.sh:290-291` produces via `print_coverage_summary`,
  which derives the percentage from the `line-rate` attribute of the merged Cobertura `cov.xml`
  and renders it to exactly one decimal place. `91.4` is a real measured value read from this run,
  not a placeholder.
- **bats case count:** 251, read from the TAP plan line `1..251` emitted as line 1 of the captured
  output.
- **bats pass count:** 251.
- **bats fail count:** 0. The captured stream contains zero occurrences of the string `not ok`,
  searched anywhere in the stream rather than only at line start.

Total captured output: 796 lines.

The measured values match the reference values the plan records for the pre-Phase-1 tree
(`Bash coverage (lines): 91.4%` over 251 bats cases).

## How the Pass and Fail Counts Were Established

The fail count rests on two independent observations rather than on the exit code alone:

1. `grep -c 'not ok'` over the whole captured stream returns 0.
2. `run_test_coverage` (`scripts/bash/shell_qc_lib.sh:337-355`) runs each bats directory under
   kcov, captures the wrapped exit code with `|| rc=$?`, keeps the running maximum in `exit_code`,
   breaks at the first failure, and returns that value. An exit code of 0 therefore certifies that
   the kcov-wrapped bats run itself exited 0, which bats does only when no case failed.

Fifteen lines in the stream match `failed` or `failure`. All fifteen were inspected and none is a
test failure: they are test-case *names* covering error-handling behavior (for example
`ok 159 cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure`) or
captured stdout from tests exercising retry paths.

## Observation on the Captured Output Form — Line Clobbering Under kcov

The plan's "bats output form (observed this pass)" section states that a captured run emits one
`ok <n> <case name>` line per passing case. That holds for a plain `bats` run. It does **not** hold
for this coverage run, and the difference is recorded here because a later task that counts `ok`
lines in a coverage capture would draw the wrong conclusion.

Under `--coverage`, kcov writes its own progress output to the same file descriptor as the bats TAP
stream. Concurrent writes overwrite one another mid-line, so some TAP lines are truncated and
overwritten rather than merely interleaved. Line 5 of the capture reads:

```
ok 4 every repository baBRANCH|feature-merged|MERGED_CLEAN
```

The case name is cut off after `every repository ba` and unrelated stub output continues on the
same line.

Consequence, measured: only 118 of the 251 indices appear as a line-start `ok <n>` match, and the
same 118 is obtained when searching for `ok <n>` anywhere in the stream including mid-line. The
missing indices are the contiguous block 5 through 137. This is lost output from the clobbering,
not missing test results: the plan line declares 251 cases, index 251 is present
(`ok 251 discover_shell_scripts output is sorted and de-duplicated`), no `not ok` appears, and the
run exited 0.

**Implication for later tasks.** An `ok`-line count is not a reliable case count in a `--coverage`
capture. The reliable signals are the `1..N` plan line, the absence of `not ok`, and the exit code.
The targeted `bats` invocations in Phases 1 through 3 do not run under kcov and are not affected;
their `1..N` and `ok` assertions remain sound as the plan writes them.

## Bearing on Later Tasks

This value is the reference point for the P6-T14 no-regression delta, not an equality assertion.
This feature adds bats cases and two measured production files under `.claude/lib/bash/`, so both
the percentage and the case count are expected to move. The no-regression comparison at P6-T14 is
against the 91.4% recorded here, and the absolute gate at P6-T4 is the >= 85.0 line-coverage floor
that `.claude/rules/quality-tiers.md` sets uniformly across T1 through T4. kcov measures line
coverage only; no bash branch-coverage gate applies.
