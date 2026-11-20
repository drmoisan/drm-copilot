Timestamp: 2026-08-26T01-11

Command: grep -L "^Command:" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md
EXIT_CODE: 0

Command: grep -L "^EXIT_CODE:" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md
EXIT_CODE: 0

Command: grep -L "^Output Summary:" docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/*/*.md
EXIT_CODE: 0

Output Summary: The actual output of all three commands DIVERGES from the counts
anticipated in this task's Acceptance text. Reported here verbatim and in full,
per the task's own "Do not guess; report exactly what the three commands print"
instruction.

`grep -L "^Command:"` listed 27 files (26 from the 29 pre-existing T00-00 artifacts,
plus this remediation cycle's own new `remediation-baseline/phase0-instructions-read.2026-08-26T01-11.md`,
which legitimately carries no Command field because it is not a command-step
artifact): every file under `evidence/baseline/` (10 files), `evidence/other/ac-reconciliation.2026-08-26T00-00.md`
and `evidence/other/f3-glob-justification.2026-08-26T00-00.md`, 10 files under
`evidence/qa-gates/` (`coverage-delta`, `final-black`, `final-codex-agent-variants`,
`final-pyright`, `final-pytest-coverage`, `final-ruff`, `frozen-epic-digest-repin`,
`not-applicable-gates`, `push-down-mirror-parity`, `scope-containment`), and all 4
files under `evidence/regression-testing/`.

`grep -L "^EXIT_CODE:"` listed 5 files: `evidence/other/ac-reconciliation.2026-08-26T00-00.md`,
`evidence/other/f3-glob-justification.2026-08-26T00-00.md`,
`evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`,
`evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md`, and this cycle's own
`remediation-baseline/phase0-instructions-read.2026-08-26T01-11.md`.

`grep -L "^Output Summary:"` listed 2 files: `evidence/other/ac-reconciliation.2026-08-26T00-00.md`
and `evidence/other/f3-glob-justification.2026-08-26T00-00.md`.

Root cause of the divergence: the anchored, flat-line patterns
(`^Command:`, `^EXIT_CODE:`, `^Output Summary:`) do not match two conforming
formatting styles present in this feature's 29 committed evidence artifacts —
the markdown section-heading style (`## Command:` followed by a fenced code
block, used by all 10 `evidence/baseline/` artifacts and most `evidence/qa-gates/`
and `evidence/regression-testing/` artifacts) and the dash-prefixed list-item
style (`- Command: ...`, `- EXIT_CODE: 0`, used by
`evidence/other/f3-glob-justification.2026-08-26T00-00.md`, which does in fact
carry all four schema fields under that style and is not a genuine gap).

Net finding: among the 29 pre-existing artifacts, only `evidence/other/ac-reconciliation.2026-08-26T00-00.md`,
`evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`, and
`evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md` are genuinely missing
a `Command:`/`EXIT_CODE:` value in any styling (heading, dash-list, or flat line);
`evidence/other/f3-glob-justification.2026-08-26T00-00.md` only appeared in the
raw grep output because of its dash-list styling, not because it lacks the field.
This corrects the literal grep-count expectation stated in this task's Acceptance
text (which anticipated exactly 3 files for the first two commands and exactly 1
for the third); the true, format-normalized set of genuinely deficient artifacts
is the same three files R3 targets in Phase 3 of this plan.
