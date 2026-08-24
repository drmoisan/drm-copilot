# Issue update mirror — issue #485

Timestamp: 2026-08-20T09-53

Task: [P9-T6]

Command: not applicable — no GitHub command was executed
EXIT_CODE: 0

PostedAs: unknown

## POSTING NOT PERFORMED

No GitHub update was posted. The executing agent is prohibited from running any `gh` command; the
orchestrator owns staging, committing, pull-request authoring, and any issue posting. This mirror
records the text that WOULD be posted, so the orchestrator can post it verbatim if it chooses.

The same content was written into the local feature record
`docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/issue.md`
under the headings `## Delivered Outcome (2026-08-20)` and
`## Deferred defect — duplicate-key precedence divergence remains UNFIXED`.

Issue URL: https://github.com/drmoisan/drm-copilot/issues/485

## Text intended for posting

Fix delivered on branch `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485`.

An evidence artifact can now declare the exit code its gate is expected to produce, via one optional,
flat, integer-valued key `ExpectedExitCode` defaulting to `0`. A gate whose observed code equals its
declared expectation normalizes to `pass` and still displays the observed code, with a new conditional
row line `  - Expected EXIT_CODE: <int>` emitted between the `EXIT_CODE` and `Normalized result` lines
only when the expectation is non-zero. Both runtimes changed in one change set: the Python parser and
renderer and the TypeScript parser and renderer. The required-field constant is byte-identical in both,
the result vocabulary stays exactly `pass | fail | unparseable`, a present but non-integer expectation
yields `unparseable`, and a duplicated expectation key resolves first-wins in both runtimes. The
optional key is documented in all six copies of `evidence-and-timestamp-conventions/SKILL.md`.

Verification, single clean final toolchain pass in both languages:

- Python: 3995 tests passed, 0 failed; overall line coverage 92.45%, branch 84.93%.
- TypeScript: 2580 tests passed across 185 suites, 0 failed; overall line coverage 96.62%, branch
  89.98%.
- New/changed-code coverage: 100% across the four changed production files.
- Additive guarantee proved over the real corpus: 1293 artifacts discovered by `CANONICAL_GLOBS`, with
  0 rendered-row differences between the pre-change reference and the post-change output in BOTH
  runtimes.
- 23 of 25 acceptance criteria checked off.

Deferred and still unfixed: the duplicate-key precedence divergence between the two parsers (Python
last-wins, TypeScript first-wins). 165 artifacts carry two or more `EXIT_CODE:` lines and are reported
differently by the two runtimes. Execution additionally measured that the divergence is not confined to
`EXIT_CODE`: six artifacts with a single `EXIT_CODE:` line but a duplicated `Command:` or `Timestamp:`
line are also reported differently, one of them rendering in TypeScript and being dropped as
unparseable in Python. Acceptance criteria AC10 and AC17 are therefore left unchecked. This defect will
be promoted separately via the potential-to-issue path, with its scope stated as
duplicate-REQUIRED-KEY precedence.

Output Summary: Issue-update mirror recorded with `PostedAs: unknown` because posting is outside this
agent's authority — no `gh` command was run. The same delivered-outcome and deferred-defect text was
written into the local `issue.md`. The orchestrator may post the text above verbatim.
