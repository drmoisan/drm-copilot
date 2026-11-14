# Acceptance Criteria Check-Off ([P8-T13])

Timestamp: 2026-11-06T00-19
Command: check-off of `spec.md` and `user-story.md` `## Acceptance Criteria` items against the evidence mapped in the plan's `## Acceptance Criteria Traceability`, one item at a time (`- [ ]` changed to `- [x]`, text unchanged)
EXIT_CODE: 0
Output Summary:
- spec.md: 31 items; 27 checked; 4 unchecked (SAC-4 and SAC-28 await the [P8-T14] self-review; SAC-27 and SAC-31 pending CI).
- user-story.md: 23 items; 20 checked; 3 unchecked (USE-4 awaits the [P8-T14] self-review; US2-6 and US3-6 pending CI).
- Pending-CI items depend on `test_execution_environment_fact_is_unchanged_across_copies`, which fails locally only because this checkout's path contains `worktrees` (WORKTREE_PATH_ENVIRONMENT); they are checked by the orchestrator after CI on the branch is green.

| ID | Source | Status | Evidence (under `<FEATURE>/evidence/`) |
|---|---|---|---|
| SAC-1 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md; other/docs-probe.2026-11-06T00-18.md |
| SAC-2 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`rejects invalid input with DOCS_INPUT_INVALID`, `does not call runDocsCommand when the resolver rejects the input`) |
| SAC-3 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-4 | spec.md | unchecked, awaiting [P8-T14] | qa-gates/self-review.(written at [P8-T14]).md (SAC-4 row); qa-gates/scope.2026-11-06T00-10.md; other/docs-probe.2026-11-06T00-18.md |
| SAC-5 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (five new files at or above 85/75) |
| SAC-6 | spec.md | checked | regression-testing/enumeration-tests.2026-11-06T00-01.md |
| SAC-7 | spec.md | checked | regression-testing/enumeration-tests.2026-11-06T00-01.md |
| SAC-8 | spec.md | checked | regression-testing/enumeration-tests.2026-11-06T00-01.md (`spreads the same definition objects into both definition surfaces`) |
| SAC-9 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`lists the six docs tools with their annotations`) |
| SAC-10 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-11 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-12 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-13 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-14 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-15 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-16 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-17 | spec.md | checked | baseline/upstream-grammars.2026-11-05T23-35.md; qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-18 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-19 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-20 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-21 | spec.md | checked | baseline/upstream-contract.2026-11-05T23-35.md; qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-22 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`returns structuredContent.docs and isError per exit code`) |
| SAC-23 | spec.md | checked | qa-gates/scope.2026-11-06T00-10.md (`src/discovery-runtime.ts` absent); qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-24 | spec.md | checked | qa-gates/typecheck.2026-11-06T00-08.md; qa-gates/jest-coverage.2026-11-06T00-09.md |
| SAC-25 | spec.md | checked | regression-testing/enumeration-tests.2026-11-06T00-01.md; baseline/enumeration-dispositions.2026-11-05T23-35.md. Jest rows pass; the Python row 9 test passed in the contract set; the Pester rows 10 to 12 are unchanged suites whose inputs (`.claude/settings.json`, the architecture document, the discovery routing modules) are unchanged, and they run in CI |
| SAC-26 | spec.md | checked | qa-gates/scope.2026-11-06T00-10.md; `test_push_down_codex_and_agents_resource_contracts.py` passed in qa-gates/contract-tests-final.2026-11-06T00-09.md |
| SAC-27 | spec.md | unchecked, pending CI | qa-gates/contract-tests-final.2026-11-06T00-09.md: `test_brief_copies_are_byte_identical` passed; `test_execution_environment_fact_is_unchanged_across_copies` fails locally only by WORKTREE_PATH_ENVIRONMENT |
| SAC-28 | spec.md | unchecked, awaiting [P8-T14] | [P7-T1] and [P7-T2] token checks; qa-gates/self-review.(written at [P8-T14]).md |
| SAC-29 | spec.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md; qa-gates/coverage-delta.2026-11-06T00-09.md (EVIDENCE_LOCATION_OVERRIDE_REJECTED: `evidence/coverage/` replaced with `evidence/qa-gates/`) |
| SAC-30 | spec.md | checked | regression-testing/jest-shuffle.2026-11-06T00-09.md; qa-gates/test-isolation-scan.2026-11-06T00-10.md |
| SAC-31 | spec.md | unchecked, pending CI | qa-gates/file-sizes.2026-11-06T00-10.md passes; the seven-stage single pass includes stage 6 ([P8-T7]), which is pending CI for the WORKTREE_PATH_ENVIRONMENT test |
| USE-1 | user-story.md | checked | as SAC-1 |
| USE-2 | user-story.md | checked | as SAC-2 |
| USE-3 | user-story.md | checked | as SAC-3 |
| USE-4 | user-story.md | unchecked, awaiting [P8-T14] | as SAC-4 |
| USE-5 | user-story.md | checked | as SAC-5 |
| US1-1 | user-story.md | checked | as SAC-22 |
| US1-2 | user-story.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`returns a code-prefixed failure without docs for each host failure code`) |
| US1-3 | user-story.md | checked | as SAC-12 |
| US1-4 | user-story.md | checked | as SAC-13 |
| US1-5 | user-story.md | checked | as SAC-9 and SAC-10 |
| US1-6 | user-story.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`rejects invalid input with DOCS_INPUT_INVALID`) |
| US2-1 | user-story.md | checked | as SAC-11 and SAC-23; other/docs-probe.2026-11-06T00-18.md |
| US2-2 | user-story.md | checked | as SAC-11 |
| US2-3 | user-story.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`passes the envelope through unchanged`) |
| US2-4 | user-story.md | checked | as SAC-16 |
| US2-5 | user-story.md | checked | qa-gates/jest-coverage.2026-11-06T00-09.md (`fails with DOCS_ENTRY_SCRIPT_MISSING naming push_down_claude_customizations without launching`) |
| US2-6 | user-story.md | unchecked, pending CI | as SAC-27 |
| US3-1 | user-story.md | checked | as SAC-25 |
| US3-2 | user-story.md | checked | as SAC-6 |
| US3-3 | user-story.md | checked | as SAC-21 |
| US3-4 | user-story.md | checked | as SAC-29 |
| US3-5 | user-story.md | checked | as SAC-30 |
| US3-6 | user-story.md | unchecked, pending CI | as SAC-31 |
| UPC-1 | plan inventory (no checkbox) | delivered | qa-gates/jest-coverage.2026-11-06T00-09.md (`pins the generate_docs_reference result key set of the 1024 contract`); other/docs-probe.2026-11-06T00-18.md (`result-keys=match`) |
| CON-1 | plan inventory (no checkbox) | delivered | qa-gates/con1-token-scan.2026-11-06T00-11.md |
