# Remediation Inputs — Issue 1164 (related non-blocking rows, cycle 2)

Timestamp: 2026-11-13T14-14
Remediation-Mode: proportionate
Source: orchestrator, under owner directive OD-7 ("Fix related findings inside this item before merge; file issues only for completely unrelated findings").
Opening review: `code-review.2026-11-13T14-04.md` (verdict PASS, head `90d84af1305f120cf0c7d044c09c0390b99cfde9`). The review recorded no blocking finding; the two rows below are the related Info rows of its findings table, which the review's remediation inputs (`remediation-inputs.2026-11-13T14-04.md`) name as addressable inside this item under OD-7. Neither is a blocking finding.

Mode rationale: proportionate. Both fixes change files already in the branch diff (`BlastRadiusAccess.psm1` and its bundle mirror; `parallel-state-shared.ts`; the `## Enforcement` section of `.claude/rules/parallel-orchestration.md` and its bundle mirror) plus their tests and the shared corpus. No spec acceptance criterion, public interface, or file inventory beyond the branch diff, its tests, and its mirrors changes.

## Findings

### R5 — Irregular write forms are not recognized (Info)

- File: `.claude/lib/blast-radius/BlastRadiusAccess.psm1` (`$script:WriteTitleWordSet` builder, `Test-WriteTitleWord`), plus its bundle mirror under `extensions/drm-copilot/resources/claude-customizations/`.
- Finding: the set holds only regular inflections, so `written`, `wrote`, `rewrote`, `rewritten`, and `overwritten` (and `overwrote`) do not mark a write. A title such as "Run the generator; output written to `docs/a.json`." still yields a read-only path.
- Required change: add the irregular past and past-participle forms of the listed write verbs that have them (`Write`, `Rewrite`, `Overwrite`, and any other listed verb with an irregular form) to the set, fail-safe direction only (more paths classified as written, never fewer), with one `-ForEach` row per added form in `tests/scripts/claude-lib/blast-radius/BlastRadiusAccess.Tests.ps1`. Copy the module to its bundle mirror byte-identically. Identify every existing test that asserts the set or a classification and state its disposition.

### R6 — `pythonRepr` does not escape control and non-printable characters as CPython `repr` does (Info)

- File: `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` (`pythonRepr`, string branch).
- Finding: CPython `repr` escapes `\n`, `\r`, `\t`, other non-printable characters (`\xNN`, `\uNNNN`, `\UNNNNNNNN`, per `str.isprintable`), and the backslash; `pythonRepr` does not, so for a value containing such a character the Python and TypeScript validators emit different error strings, contrary to US-AC6 (byte-identical strings). The `## Enforcement` paragraph of `.claude/rules/parallel-orchestration.md` lists three known divergence classes and does not name this one.
- Required change: make `pythonRepr` produce CPython's `repr` escaping for every code point (the escape forms above, with CPython's printable test), keeping the quote selection of R1, and hold the file within its size tier. Add shared-corpus stems under `tests/fixtures/parallel_state_scheduling/`, consumed by both the Python and the TypeScript parity tests, covering at least a newline, a tab, an ASCII control character, a backslash, and a non-ASCII non-printable code point, so that a one-sided edit fails. Update the `## Enforcement` paragraph of the rule file and its bundle mirror so the documented divergence classes match the implementation. Identify every existing test that asserts `pythonRepr` output and state its disposition.

## Out of scope (accepted, no change)

- The `0 min / 0 min` message for a hand-written tolerated entry without estimates, and the current-directory-relative config resolution of `test-precedence`: carried from the prior reviews and accepted as requiring no change.
- The extension-scoped Jest gate: the cycle 2 plan runs the root Jest configuration as well, so `coverage/lcov.info` exists at the worktree root for the review coverage hook.
