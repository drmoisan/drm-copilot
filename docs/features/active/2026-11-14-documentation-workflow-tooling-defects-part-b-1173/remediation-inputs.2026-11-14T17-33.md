# Remediation Inputs: #1173 feature review pass 1

- Timestamp: 2026-11-14T17-33
- Branch: `feature/documentation-workflow-tooling-defects-1173` at `ec00c5389f10be134de8390cf839365fea5c5687` (PR #1185)
- Base: `origin/main`, merge base `d7ef763637319b2aa2f886ecdab7a11be0044491`

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate

## Source audit artifacts

- `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/policy-audit.2026-11-14T17-33.md` (one failing requirement: No circular dependencies)
- `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/code-review.2026-11-14T17-33.md` (one Blocker row, same finding)
- `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/feature-audit.2026-11-14T17-33.md` (no failing criterion; three criteria pending CI)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `ec00c5389f10`)

## Remediation-required findings

### R1 - Circular import between the TypeScript MCP input modules

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the cycle is in two extension source files on this branch and can be removed by a module refactor and a rerun of the TypeScript toolchain and Jest coverage gate, with no external service, owner decision, or policy change involved.
- Finding-Scope: design
- File/location: `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` line 13 imports `checkDocsLedgerInput` from `./mcp-tool-inputs-docs-ledger-batch`; `extensions/drm-copilot/src/mcp-tool-inputs-docs-ledger-batch.ts` lines 13-22 import `DOCS_DIMENSION_STATES`, `DOCS_LEDGER_COMMON_FIELDS`, `DOCS_DIMENSIONS`, `DOCS_DISPOSITIONS`, `DOCS_LEDGER_OPERATIONS`, `DocsInputError`, `matchesDocsGrammar` and the `DocsGrammar` type from `./mcp-tool-inputs-docs`.
- Rule: `.github/instructions/general-code-change.instructions.md` (Avoid circular dependencies; if they appear, refactor shared logic into a lower-level module). The executor self-review (`evidence/qa-gates/self-review.2026-11-14T17-15.md`) recorded "No circular dependencies" as PASS.
- Fix:
  1. Move the symbols both modules need (the ledger operation, disposition, dimension and state enumerations, `DOCS_LEDGER_COMMON_FIELDS`, `DocsInputError`, `matchesDocsGrammar`, `DocsGrammar`, and any helper they depend on) into one lower-level module that imports neither MCP input module, or remove the back-edge in another way that leaves no cycle.
  2. Keep every existing export of `mcp-tool-inputs-docs.ts` available to its current importers (for example by re-exporting), so no caller outside the two files changes.
  3. Keep the `update_docs_ledger` behavior unchanged: the `operations` and `operation` exclusivity, per-item validation, serialization, `-Operations -` emission and standard-input forwarding.
  4. If a new source module is added, list it in `extensions/drm-copilot/jest.docs-coverage.json` and cover it at or above 85% line and 75% branch; keep `mcp-tool-inputs-docs.ts` changes to imports and re-exports, consistent with the spec limit of table rows and requiredness for that file.
  5. Rerun prettier check, eslint, `npm run typecheck`, and one Jest coverage run (normal parallel workers) for the extension; record the results under `<FEATURE>/evidence/qa-gates/` with clock-read timestamps.
- Verification: neither module imports the other directly or through another module; the TypeScript static stages pass; Jest passes with the changed and new modules at or above the thresholds and no regression against `evidence/qa-gates/final-qc-jest.2026-11-14T17-11.md`.

## Non-blocking items (no remediation cycle)

- Warning: `.claude/lib/docs/DocsLedgerCommands.psm1` and its bundle copy are 758 logical lines (advisory tier).
- Minor: the spec limited `DocsLedgerCommands.psm1` to dispatch and exports; the branch also extracted `Get-DocsLedgerCommandOutcome` and added the `PageReference` load option. Record the accepted deviation; no code change required.
- Info: default inventory exclusions match `build` and `dist` at any depth (spec B8 behavior).
- Info: the executor and planner decision files for OD-1 record class `scheduling`, while the item checkpoint records `merge_timing`; use the checkpoint class when copying decisions into `owner_directive_records`.
- Pending CI: spec criteria "The full seven-stage toolchain loop passes..." and "CI is green on the final pull request head." and the last user-story criterion are pending CI on the final head; they are owned by the orchestrator at S9 and are not remediation findings.

## Do not do

- Do not change the PowerShell CLI, the operations document shape, or any acceptance criterion.
- Do not lower coverage thresholds or remove entries from `jest.docs-coverage.json`.
- Do not edit or delete existing evidence files; add new evidence only under `<FEATURE>/evidence/<kind>/`.
- Do not add Python.
