# Remediation Cycle 1 — Codex Mode-Resolution Suite Run (R1, R3)

Timestamp: 2026-08-28T00-05
Cycle Timestamp: 2026-08-27T22-47
Task: [P1-T6]
Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 -Output Detailed"`
EXIT_CODE: 0

## Result line

```text
Discovery found 53 tests in 146ms.
Tests completed in 779ms
Tests Passed: 53, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Metric | Value |
| --- | --- |
| Passed | **53** |
| Failed | **0** |
| Skipped | 0 |

## `It` count movement

| Measurement | Value |
| --- | --- |
| `It` blocks at `HEAD` (`git show HEAD:<file>`) | 11 |
| `It` blocks after the Phase 1 edits | 21 |
| Rise | **+10** |

The rise of ten matches the ten cases the plan's [P1-T2] through [P1-T5] specify: one from [P1-T2],
four from [P1-T3], three from [P1-T4], and two from [P1-T5]. Each name was confirmed to be defined
exactly once by a fixed-string count over the file.

The discovered test count of 53 exceeds the `It` count of 21 because eight of the eleven pre-existing
`It` blocks are `-ForEach` tables that expand into multiple cases at discovery. All ten added cases
are plain `It` blocks and each contributes exactly one test.

## The ten added cases, each with result Passed

From the `-Output Detailed` transcript:

| # | Task | Context | `It` name | Result |
| --- | --- | --- | --- | --- |
| 1 | [P1-T2] | mode resolution parity | `returns an empty checkpoint path for a mode name that is not in the table` | **Passed** |
| 2 | [P1-T3] | target folder resolution parity | `returns nothing for a prompt carrying no feature-folder token` | **Passed** |
| 3 | [P1-T3] | target folder resolution parity | `returns the parent basename for a token ending in a Markdown file` | **Passed** |
| 4 | [P1-T3] | target folder resolution parity | `returns the basename for a bare directory token` | **Passed** |
| 5 | [P1-T3] | target folder resolution parity | `returns the basename for a token followed by sentence punctuation` | **Passed** |
| 6 | [P1-T4] | target folder resolution parity | `returns nothing for a prompt carrying no issue number` | **Passed** |
| 7 | [P1-T4] | target folder resolution parity | `returns the numeric string for a keyed issue number` | **Passed** |
| 8 | [P1-T4] | target folder resolution parity | `returns the numeric string for a bare-hash issue number` | **Passed** |
| 9 | [P1-T5] | the mode deny-reason builder | `builds an epic deny reason naming the epic checkpoint and the failed predicate` | **Passed** |
| 10 | [P1-T5] | the mode deny-reason builder | `builds a parallel deny reason naming the parallel checkpoint and the failed predicate` | **Passed** |

Verbatim transcript lines for the two new `Context` blocks:

```text
 Context target folder resolution parity
   [+] returns nothing for a prompt carrying no feature-folder token 12ms
   [+] returns the parent basename for a token ending in a Markdown file 11ms
   [+] returns the basename for a bare directory token 3ms
   [+] returns the basename for a token followed by sentence punctuation 3ms
   [+] returns nothing for a prompt carrying no issue number 5ms
   [+] returns the numeric string for a keyed issue number 2ms
   [+] returns the numeric string for a bare-hash issue number 2ms
 Context the mode deny-reason builder
   [+] builds an epic deny reason naming the epic checkpoint and the failed predicate 5ms
   [+] builds a parallel deny reason naming the parallel checkpoint and the failed predicate 2ms
```

and, inside the pre-existing `mode resolution parity` context:

```text
   [+] returns an empty checkpoint path for a mode name that is not in the table 2ms
```

## Decision D5 compliance

Every one of the ten added cases calls a pure function directly. Seven take a `[string] $Prompt`
and return a `[string]`; one takes a `[string] $Mode` and returns a `[string]`; two take two
`[string]` parameters and return a `[string]`. No case constructs an `Agent` envelope, and no case
passes a delegation payload to `Invoke-OrchestrationPreimplementationGateDecision`. Decision D5's
prohibition is therefore not engaged, which is the reasoning the cycle-1 audit gave when it rejected
the D5 attribution for these lines.

Every fixture is a literal string written inline in the case body. No temporary file, no filesystem
write, no wall-clock read, no network call, no external process, and no `Mock`.

Output Summary: Codex mode-resolution suite passes with **53 passed, 0 failed**, exit code 0. The
file's `It` count rose from 11 to 21, a rise of exactly ten. All ten added `It` names are listed
above with result Passed, each confirmed defined exactly once.
