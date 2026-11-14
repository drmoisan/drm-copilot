# Acceptance-Criteria Re-Check (Remediation Cycle 1, P4-T5)

Timestamp: 2026-11-14T03-24
Command: edit of spec.md (`- [ ]` to `- [x]` only, three criteria); awk extraction of the spec.md `## Acceptance Criteria` section counting `- [ ]` and `- [x]`; read of user-story.md `## Acceptance Criteria`
EXIT_CODE: 0
Output Summary:
- spec.md `## Acceptance Criteria`: 37 checked, 0 unchecked after this task.
- Criteria checked off in this task (text unchanged; only the checkbox changed):
  1. A1, "The existing cleanup-leg suites (...Cleanup.Tests.ps1, ...cleanup.Tests.ps1) pass unchanged." Evidence: evidence/other/task-check.P2-T1.2026-11-14T02-02.md (empty merge-base diff of both cleanup suites) and evidence/qa-gates/final-qc-pester.2026-11-14T03-21.md (Cleanup 41 tests and cleanup 36 tests, 0 failures).
  2. A1 criterion 4 (revised): "A path under a documentation root or an artifact directory outside `docs/` is not in the docs path set ...". Evidence: evidence/other/task-check.P3-T2.2026-11-14T02-35.md (add-operand and staged-path deny rows under the discriminating profile in both gate suites; narrow-profile and moved reject rows in hook-docs-estate-context.Tests.ps1) and evidence/qa-gates/final-qc-pester.2026-11-14T03-21.md (0 failures, rows included).
  3. A2 (added): "A diff path under a documentation root or an artifact directory outside `docs/` denies with `DOCS_DELEGATION_PATH_NOT_ALLOWED`." Evidence: evidence/other/task-check.P3-T2.2026-11-14T02-35.md (two model-routing rows asserting the outside path in the reason) and evidence/qa-gates/final-qc-pester.2026-11-14T03-21.md.
- Every other spec.md criterion still holds: the final Pester gate (22683 passed, 0 failed), the final pytest gate (16676 passed, 0 failed), the Codex generator check (exit 0), and the coverage comparison (evidence/qa-gates/coverage-comparison.2026-11-14T03-23.md, PASS) re-verify the suites each criterion names; cycle-1 changes touched only the A1 docs-path rule, the profile read seam, the RECEIPT_ABSENT message, and the `=`-form commit option, each covered by rows that pass.
- user-story.md: 8 criteria, all checked; each still holds. Criterion 1 ("docs path set changes are allowed") now uses the CR3 docs path set and its allow and deny rows pass; criterion 5 (docs-complete gate) holds with the F2 message change, whose reason code is unchanged; criterion 8 (full loop, parity, no Python) holds per the final gates, the four-copy and pair hash checks, and the unchanged enforcement-hooks-no-python-invocation suite in the final Pester run.
