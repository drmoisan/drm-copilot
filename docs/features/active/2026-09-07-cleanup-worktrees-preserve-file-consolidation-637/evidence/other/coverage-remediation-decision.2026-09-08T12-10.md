# Decision — per-module coverage remediation for `cleanup_worktrees_preserve_lib.sh`

Timestamp: 2026-09-08T12-10
Task: coverage remediation preceding Phase 10, directed by the orchestrator after CI round C
Command: (decision record; the local measurements it rests on are recorded in the sections below)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: eleven behavioral failure-path tests added in a third suite file
`tests/shell/test_cleanup_worktrees_preserve_failures.bats` (264 lines) plus two fixture groups.
Twenty-one of the forty-one uncovered lines in `scripts/bash/cleanup_worktrees_preserve_lib.sh` are
now executed. Nineteen of the remaining twenty are literal-data lines inside two single statements
and are not independently reachable by any test; the twentieth is an unreachable defensive branch.
Projected post-remediation line rate for that file: 192 of 212 measured lines, 0.906.

**Timestamp convention.** Every artifact written in this session carries the session timestamp
`2026-09-08T12-10`. Artifacts written in the preceding session carry stamps up to `2026-09-08T11-55`
which run ahead of the wall clock by roughly forty minutes; the session stamp used here preserves
the recorded ordering.

## The finding

CI round C (run 34219866134) reported an overall bash line rate of 92.3%, which satisfies the 85%
floor. The per-file breakdown of the uploaded `artifacts/pester/kcov/cov.xml` did not:

| Module | Line rate at round C |
| --- | --- |
| `scripts/bash/cleanup_worktrees_preserve_lib.sh` | 0.807 — below the 85% per-module obligation |
| `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` | 0.870 |
| `scripts/bash/cleanup-worktrees.sh` | 1.000 |

The preserve library carries 212 measured lines with 41 uncovered:

    111 112 113 115 116 117 118 119 120 121 122 123
    164 203 219 278 279 280 281 347 348
    394 396 398 399 401 403 406 407 408 409
    445 471 472 473 474 475 476 477 483 484

## Two clusters are measurement artifacts, established by direct observation rather than assertion

Lines 111–123 are the interior lines of one statement, the single-quoted `jq` filter assigned at
`scripts/bash/cleanup_worktrees_preserve_lib.sh` line 111 and closed at line 124. Lines 471–477 are
the element lines of one statement, the `local -a patterns=(` array opened at line 470 and closed at
line 477.

kcov's bash backend attributes a hit to the line the shell reports for the simple command, so the
interior lines of a multi-line literal are instrumented but can never be reported. The behavior was
confirmed rather than assumed, by running a purpose-built probe under `PS4='+LINE:${LINENO} '` with
`set -x`:

    +LINE:7 local 'filter=
    line4
    line5
    line6'
    +LINE:8 pats=('a' 'b' 'c')

The string assignment spanning lines 4–7 was reported at line **7**, its last line; the array
assignment spanning lines 8–12 was reported at line **8**, its first line. That asymmetry predicts
exactly the observed kcov data: for the filter, 111–123 uncovered with 124 covered; for the array,
470 covered with 471–477 uncovered. The prediction was then verified against the production file
itself by tracing the library under the same mechanism, which reported line 124 and line 470 and
neither 111–123 nor 471–477.

**Verdict on the 111–123 cluster: genuinely unreachable, and the same holds for 471–477.** No test
can execute them, because they are not statements. The code was not contorted to chase them.

Line 445 is a third unreachable line of a different kind: it is the `return "$rc"` of the guard that
follows `preserve_commit_plan`, and `preserve_commit_plan` returns 0 on every path (its two `return`
statements are at lines 381 and 413). The guard is defensive and is left in place; covering it would
require changing production code to introduce a failure mode that does not exist.

## What was added

**Third suite file — `tests/shell/test_cleanup_worktrees_preserve_failures.bats`, 264 lines.**
`tests/shell/test_cleanup_worktrees_preserve.bats` stands at 471 of the 500-line cap, so the eleven
new tests do not fit there. `tests/shell/test_cleanup_worktrees_preserve_eol.bats` carries the
line-ending and index group and only two of the eleven tests belong to that subject. The new file
extends the existing naming pair and is discovered by the same `bats tests/shell` invocation, because
`find_bats_test_dirs` at `scripts/bash/shell_qc_lib.sh` lines 104–115 returns the directory and
`run_bats` at line 248 runs bats against the directory rather than against an enumerated file list.
No gate command therefore has to name it. `discover_shell_scripts` at line 85 walks only `tools`,
`scripts`, and `.claude/lib/bash`, so the new file is outside the format and lint stages, exactly as
the two existing suite files are.

**Two fixture groups, following the fixture invariants in force for this plan.**

- `tests/fixtures/cleanup_worktrees/preserve/upstream-tokens/` — `manifest.json`, `jq.out`,
  `check-ignore.null.rc` containing `1`, and
  `wt/agent-memory/atomic-executor/upstream-flagged-lesson.md`. The record carries a complete
  `host_token_scan` with `pattern_set_id` set to `cleanup-wt-host-tokens-v1` and `result` set to
  `tokens_present`; `memory_index_line` is JSON null. The source file's own bytes carry no host
  token, which is what makes the test able to fail: a pass that ignored the upstream value and
  relied only on the local scan would stage the record and exit 0.
- `tests/fixtures/cleanup_worktrees/preserve/commit-failures/` — a shared clean source file at
  `wt/agent-memory/atomic-executor/commit-lesson.md`, an index-line fixture
  `index-line-with-token.txt` carrying one fabricated host token, and two stub scenario directories
  `stage-fails/` (`add.null.rc` = 1) and `index-stage-fails/` (`add._dev_null.rc` = 1), each also
  carrying `check-ignore.null.rc` = 1.

No coverage exclusion was added for any path. No existing test was deleted, weakened, or narrowed.
No temporary file is created: the writing-phase tests target the null device and paths beneath it,
and `/dev/null` is a character device.

## Which test reaches which line

| Test | Lines newly executed |
| --- | --- |
| `a dot dot segment in source_path or target_path skips the record and reports` | 164 |
| `a record carrying fewer than fourteen columns is skipped and reports its count` | 203 |
| `a memory_index_line that is neither a string nor null is skipped and reported` | 219 |
| `an upstream tokens_present result blocks the pass without a local scan` | 278, 279, 280, 281 |
| `a rejected manifest is re-emitted by the driver and stops the pass` | 347, 348 |
| `a destination directory that cannot be created is reported as FAILED` | 394, 406, 407, 408, 409 |
| `a failed verbatim byte copy is reported as FAILED` | 396 |
| `a failed index append is reported as FAILED` | 398, 399 |
| `a failed staging call is reported as FAILED` | 401 |
| `a failed index staging call is reported as FAILED` | 403 |
| `a host token carried by the index line refuses the record` | 483, 484 |

Each test asserts the emitted `ACTION|` result record, the stderr diagnostic naming the specific
failure, and the exit code or the accumulated `PRESERVE_EXIT` value. The five writing-phase tests
additionally assert the absence of the operand-anchored staging argv where the branch under test
precedes the staging call, and the two staging tests assert the argv that was logged, so each test
distinguishes its own branch from its neighbours rather than merely executing a line.

## Local verification

`bats` is not on this host's PATH and the WSL route is refused in this worktree, so the CI round is
the discharge of record. Two local pre-verifications were run.

1. A direct probe driving each function exactly as the corresponding test does. Every one of the
   eleven scenarios produced the expected result record, diagnostic, and status.
2. The three suite files executed under a minimal local emulation of `setup`, `@test`, and `run`:

       tests/shell/test_cleanup_worktrees_preserve.bats           1..26  failures=0
       tests/shell/test_cleanup_worktrees_preserve_eol.bats       1..6   failures=0
       tests/shell/test_cleanup_worktrees_preserve_failures.bats  1..11  failures=0

The line-hit trace of the production library under the probe reported every one of the twenty-one
target lines and neither 111–123, 445, nor 471–477:

    ... 163 164 ... 202 203 204 ... 218 219 220 ... 277 278 279 280 281 ...
    ... 344 347 348 350 ... 393 394 395 396 397 398 399 400 401 402 403 405 406 407 408 409 413 ...
    ... 439 440 441 468 469 470 478 479 480 481 482 483 484 486

## Projected effect and where the canonical number comes from

Uncovered falls from 41 to 20, so the projected line rate for
`scripts/bash/cleanup_worktrees_preserve_lib.sh` is 192 / 212 = **0.906**, above the 0.85
obligation with a margin of five and a half points. The ceiling with the nineteen literal lines and
the one dead line excluded is 192 / 212, so the file is at its achievable maximum.

This projection is local and is not the gate. `[P10-T6]` and `[P10-T7]` read the value from the
`cov.xml` the final CI round uploads, and CI is canonical when local and CI disagree.
