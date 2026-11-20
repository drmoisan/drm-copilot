# Acceptance criteria verification

Timestamp: 2026-11-07T22-00
Command: record mapping each acceptance criterion of spec.md and user-story.md `## Acceptance Criteria` to its evidence (no new command)
EXIT_CODE: 0
Output Summary: spec.md 25 items: 24 checked, SAC-24 unchecked (pending-CI). user-story.md 11 items: 11 checked. One recorded deviation: SAC-12 (Python floor stated as 3.11; see the SAC-12 row).

Evidence paths are relative to `<FEATURE>/evidence/`. "Pester gate" is regression-testing/pester-coverage.2026-11-07T21-55.md (the [P4-T3] parallel run, 0 failed).

## spec.md

| Item | Status | Evidence |
|---|---|---|
| SAC-1 template files, no epic-status.md | checked | test `ships epic.md and README.md and no epic-status.md`; regression-testing/epic-template-suite.2026-11-07T21-55.md |
| SAC-2 schema conformance | checked | tests `parses the frontmatter within the supported subset` to `resolves every depends_on entry to another features entry`; regression-testing/epic-template-suite.2026-11-07T21-55.md |
| SAC-3 cycle-free waves | checked | tests `has no self-edge and no cycle` to `computes waves equal to the Planned Waves list`; regression-testing/epic-template-suite.2026-11-07T21-55.md |
| SAC-4 positive controls | checked | the five `fails with EPIC_MANIFEST_*` tests (cycle, unresolved, duplicate issue_num, self-edge, flow mapping); regression-testing/epic-template-suite.2026-11-07T21-55.md |
| SAC-5 template README | checked | test `states placement, paired fields, the /epic-plan invocation and that no command copies the template`; regression-testing/epic-template-suite.2026-11-07T21-55.md |
| SAC-6 five pages | checked | test `has the five onboarding pages`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-7 subcommands | checked | tests `documents every Get-DocsCommandTable row with a heading and an example`, `documents the nine named subcommands`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-8 MCP tools | checked | test `documents every docs MCP tool defined in mcp-docs-tool-definitions.ts with a heading and an example`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-9 exit codes, envelope, MCP statements | checked | tests `documents exit codes, envelope keys and the envelope schema path`, `states the MCP tool boundaries`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-10 option spellings | checked | other/option-spelling.2026-11-07T21-18.md (15 sections, all match) |
| SAC-11 PowerShell 7.4 | checked | test `states the PowerShell 7.4 prerequisite`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-12 python pack | checked, with deviation | test `states that the optional python pack enables the native Python analyzer`; regression-testing/onboarding-suite.2026-11-07T21-55.md. Deviation: the page states Python 3.11 or later, the floor that the merged native helper enforces (`FLOOR = (3, 11)` in `.claude/lib/docs/python/run_docs_python_native.py`) per the owner decision of 2026-11-04 recorded in the 1031 spec, which raised it from 3.10. The criterion text says 3.10; stating 3.10 would document a floor the code rejects. Every other clause of the criterion is stated as written. |
| SAC-13 optional linting | checked | test `states that linting is optional and check is the required page gate`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-14 workflow names | checked | test `names the workflow roles, skills and the integration gate key`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-15 onboarding positive control | checked | test `fails naming the subcommand that an in-memory command reference omits`; regression-testing/onboarding-suite.2026-11-07T21-55.md |
| SAC-16 end-to-end baseline | checked | test `passes docs-complete at revision R1 after inventory, ledger and generation`; regression-testing/end-to-end-suite.2026-11-07T21-55.md |
| SAC-17 fail at R2 | checked | tests `fails docs-complete at revision R2 with exit code 1`, `reports DOCS_LEDGER_MISSING_DISPOSITION ...`, `reports DOCS_STALE_PAGE ...`, `returns a receipt whose validation_result is fail`; regression-testing/end-to-end-suite.2026-11-07T21-55.md |
| SAC-18 pass after fix | checked | test `passes docs-complete at revision R2 after the ledger and page are fixed`; regression-testing/end-to-end-suite.2026-11-07T21-55.md |
| SAC-19 analysis_method | checked | tests `records analysis_method scanner on every inventory snapshot element in every step`, `... on every ledger entry in every step`, `records no InvokeProcess call under -AnalysisMethod scanner`; regression-testing/end-to-end-suite.2026-11-07T21-55.md |
| SAC-20 unpinned snapshot | checked | test `fails closed with DOCS_SNAPSHOT_UNPINNED when inventory ran without a revision`; regression-testing/end-to-end-suite.2026-11-07T21-55.md |
| SAC-21 no temporary files or process | checked | qa-gates/temp-file-scan.2026-11-07T22-00.md (0 matches for all eight strings) |
| SAC-22 neutrality | checked | test `finds no consumer-identifier digest in the template pair or the onboarding pages`; qa-gates/con1-scan.2026-11-07T22-00.md |
| SAC-23 language and path scope | checked | qa-gates/scope.2026-11-07T22-00.md |
| SAC-24 CI, isolation and coverage | unchecked (pending-CI) | qa-gates/ci-pending.2026-11-07T22-00.md; coverage clause met by qa-gates/coverage-delta.2026-11-07T21-55.md; seeded-shuffle and single-process clauses waived by owner directive 2026-11-07 (regression-testing/pester-shuffle.2026-11-07T21-55.md); owner of the check-off: this item's orchestrator at S9 |
| SAC-25 file size and seven-stage loop | checked | qa-gates/file-sizes.2026-11-07T22-00.md; qa-gates/toolchain-loop.2026-11-07T22-00.md |

## user-story.md

| Item | Status | Evidence |
|---|---|---|
| USE-1 template accepted as manifest | checked | as SAC-2 |
| USE-2 cycle-free graph and mutations | checked | as SAC-3 and SAC-4 |
| USE-3 template README | checked | as SAC-5 |
| USE-4 every subcommand and tool documented | checked | as SAC-7, SAC-8 and SAC-10 |
| USE-5 PowerShell 7.4 | checked | as SAC-11 |
| USE-6 python pack and scanner fallback | checked | as SAC-12 (this criterion names no version) |
| USE-7 optional linting | checked | as SAC-13 |
| USE-8 end-to-end fail and pass | checked | as SAC-16, SAC-17 and SAC-18 |
| USE-9 analysis_method scanner | checked | as SAC-19 |
| USE-10 no temporary files or process | checked | as SAC-21 |
| USE-11 neutrality, no Python or TypeScript | checked | as SAC-22 and SAC-23 |
