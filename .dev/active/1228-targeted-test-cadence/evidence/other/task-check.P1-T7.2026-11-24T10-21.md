# Task Check - [P1-T7] - Issue #1228, remediation cycle 1

Timestamp: 2026-11-24T10-21
Plan: remediation-plan.2026-11-24T07-15.md
Kind: task check (not a gate; no coverage measured; not coverage evidence)
Command: `sed -i` changing `- [ ]` to `- [x]` on the AC-08 line of `.dev/active/1228-targeted-test-cadence/spec.md` and on items 2 and 3 of `## Acceptance Criteria` in `.dev/active/1228-targeted-test-cadence/user-story.md`; `git -C <item worktree> diff HEAD -- spec.md user-story.md`; `grep -c '^- \[ \]'` of both files; `junit.ps1` row counts from the JUnit report of the [P1-T6] Pester run
EXIT_CODE: 0
Output Summary:
- Changed files: `spec.md` (AC-08) and `user-story.md` (`## Acceptance Criteria` items 2 and 3). Only `- [ ]` changed to `- [x]`; criterion text is unchanged. `git diff HEAD` of both files is now empty: the review had unchecked these three items, and the check-off returns them to the committed text. Remaining unchecked boxes: `spec.md` 4 (the `## Definition of Done` items, outside `## Acceptance Criteria`), `user-story.md` 0. No other checkbox changed.
- AC-08 (`spec.md`): evidence `evidence/qa-gates/remediation-gate.2026-11-24T10-19.md` ([P1-T6]) and `evidence/other/task-check.P1-T3.2026-11-24T08-41.md`; rows in the [P1-T6] run: `TCW-REVIEW-*` 10 passed (including `TCW-REVIEW-AGENT-*` 4 and `TCW-REVIEW-TEMPLATE-*` 2), `PGW-REVIEW-*` 4 passed, `LEC-*` 65 passed, `TCW-COVERAGE-SOURCE-DISCRIMINATES` passed.
- `user-story.md` item 2 (no full-suite run outside the `Phase 0 baseline` and the final QA loop): evidence `evidence/qa-gates/remediation-gate.2026-11-24T10-19.md` ([P1-T6]: `TCW-CADENCE-SWEEP-SURFACES` passed with no match) and the repository-wide search `evidence/other/cadence-search.2026-11-24T04-48.md` (SearchScope, SearchPatterns, SearchResult). The F1 and F2 contradictions that left it PARTIAL are removed: `TCW-QAGATE-*` 14 passed and the coverage-source rows above passed.
- `user-story.md` item 3 (selection-based runs on the remediation plan shape, regenerate path, typed engineers, feature-review coverage step, QA-gate skills, brief, and test-execution policy): evidence `evidence/qa-gates/remediation-gate.2026-11-24T10-19.md` ([P1-T6]); `TCW-QAGATE-*` 14, `TCW-REVIEW-*` 10, `PGW-REVIEW-*` 4, `LEC-*` 65, all passed; the remaining named rows (`TCW-HANDOFF-*`, `TCW-ENGINEER-*`, `TCW-SCOPED-*`, `TCW-BRIEF-*`, `RSC-REGENERATE`) passed in the same `test-cadence-wording.Tests.ps1` run and in the main plan's final gate `evidence/qa-gates/pester.2026-11-24T06-30.md`.
- Selection: Markdown requirement files only; no test reads the checkbox state, so no test selection applies.
- Result: PASS.
