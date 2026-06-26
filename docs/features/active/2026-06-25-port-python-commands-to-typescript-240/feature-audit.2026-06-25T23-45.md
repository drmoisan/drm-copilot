# Feature Audit: F2 ts-validate-orchestration-artifacts (#240)

---

**Audit Date:** 2026-06-25
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base Branch:** `main`
**Head Branch:** `feat/ts-port-validate-orchestration-240`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `f6af666ea9c160828d6f10d81c3591191b5c0800`)
- **Head branch/commit:** `feat/ts-port-validate-orchestration-240` (commit `71f707983164f60bc321103512085b4b11d767fd`)
- **Merge base:** `f6af666ea9c160828d6f10d81c3591191b5c0800`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/**`
  - Additional evidence: independent toolchain rerun (format/lint/typecheck/Jest coverage) and direct diff inspection
- **Feature folder used:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
- **Requirements source:** `spec.md` (epic AC) and `plans/F2-validate-orchestration-artifacts.plan.md` (embedded F2 AC checklist). `user-story.md` is absent; its content is embedded in `spec.md` under `## User Story`.
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`. Per the work-mode contract, `full-feature` resolves AC sources to `spec.md` and `user-story.md`; `user-story.md` does not exist in this folder, so the user story embedded in `spec.md` and the per-feature plan AC checklist are used as the authoritative AC sources, consistent with the caller's AC-source instruction.
- **Scope note:** The PR context summary (`pr_context.summary.txt`) misclassified the TypeScript files as "Docs/templates/agents/tooling" with "Core logic changes: 0 files." The appendix `name-status` list and the direct `git diff` are authoritative and list all 22 `.ts` files plus 11 `.md` files. The audit used the authoritative diff. The audit scope is the full feature-vs-base diff, not any plan/phase subset.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — epic AC (AC-E1..AC-E5) and F1 AC (already delivered, prior feature)
- `plans/F2-validate-orchestration-artifacts.plan.md` — F2 AC checklist (AC-F2-1..AC-F2-15), authoritative per-feature AC for this branch

### From spec.md (Epic AC — realized incrementally across features; fully at F11)

1. AC-E1: Every Python command script invoked by the extension or MCP server has a TypeScript equivalent with behavior parity (CLI output, exit codes, file artifacts, JSON shapes).
2. AC-E2: TypeScript test coverage for ported modules meets policy (line >= 85%, branch >= 75%).
3. AC-E3: `RepoAutomationService` methods invoke in-process TypeScript instead of spawning Python; the `"python"` runtime branch and bundled Python resources are removed (delivered by F11).
4. AC-E4: No remaining runtime dependency on a `python` interpreter for extension or MCP command execution.
5. AC-E5: All CI gates pass on each feature PR.

### From plans/F2-...plan.md (F2 AC — authoritative for this branch)

1. AC-F2-1: `orchestration-artifacts.ts` ports the dispatcher and `validate_plan_text` with identical phase/task regexes, plan error strings, the supported `artifactType` set, the `requireComplete` flag, and the unsupported-type fallback message.
2. AC-F2-2: `orchestrator-state-core.ts` + `orchestrator-state-remediation.ts` port `validate_orchestrator_state.py` split across files each < 500 lines, with required keys, status/blocked-reason validation, delegation-receipt validation, completion gates, and verbatim error strings.
3. AC-F2-3: `orchestrator-state-human-interaction.ts` ports the three human_interaction invariants and verbatim message strings.
4. AC-F2-4: `orchestrator-state-routing.ts` ports the routing-contract receipts, empty-list and lifecycle checks, and verbatim message strings, with the routing matrix injected (hermetic; no direct `node:fs`).
5. AC-F2-5: `review-artifacts.ts` ports code-review and feature-audit heading validators with verbatim message strings.
6. AC-F2-6: `policy-audit-artifact.ts` ports the policy-audit headings, checklist labels, coverage-table parsing, per-language comparison checks, placeholder/template-resolver checks, and verbatim message strings.
7. AC-F2-7: `evidence-locations.ts` ports the forbidden-prefix map and `VIOLATION:` message with an injected `FileSystem`.
8. AC-F2-8: `json-validator.ts` ports the built-in schema checker, governed-file collection, and local/`file:` schema resolution with verbatim local-path message strings; remote-schema divergence is documented.
9. AC-F2-9: `RepoAutomationService.validateOrchestrationArtifacts()` calls the in-process TS dispatcher; result preserves `{ tool, workspaceRoot, summary }` on success and surfaces failures; no other method, `command-runtime.ts`, or `"python"` branch changed.
10. AC-F2-10: The MCP input contract and existing extension tests for this command still pass.
11. AC-F2-11: F1 shared lib modules are reused; none re-ported.
12. AC-F2-12: New `src/lib/validate/**` and test files covered by Jest; line >= 85% and branch >= 75%, numeric evidence recorded.
13. AC-F2-13: Format, lint, type-check, test pass from `extensions/drm-copilot/` in a single clean final-QA pass.
14. AC-F2-14: No production or test file exceeds 500 lines; tests hermetic (no real subprocess, no real filesystem temp files).
15. AC-F2-15: All Python `scripts/dev_tools/**` source files remain intact (unmodified).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| E1 | TS equivalent with behavior parity (epic) | PARTIAL | F2 ports the validate-orchestration cluster with verbatim message parity; the rest of the epic surface is delivered by other features. | `grep` parity spot-checks vs `scripts/dev_tools/*.py` | Epic AC realized incrementally; F2 contributes one cluster. |
| E2 | TS coverage line >= 85% / branch >= 75% (epic) | PASS | 95% line / 88.73% branch on `src/lib/validate/**`. | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/validate/**/*.ts"` | For the F2 modules. |
| E3 | Service invokes in-process TS; python branch removed at F11 | PARTIAL | `validateOrchestrationArtifacts` now in-process; the `"python"` branch and bundled Python remain (by design, F11). | diff of `repo-automation-service.ts` | Per-spec, removal is F11. |
| E4 | No remaining python runtime dependency | PARTIAL | This method no longer spawns Python; other methods still do. | diff inspection | Fully realized at F11. |
| E5 | All CI gates pass on each feature PR | PARTIAL | Local toolchain passes; CI status at HEAD is "not available" in PR context. One Major file-size finding is open. | `npm run lint/typecheck`; `node run-jest.cjs` | CI conclusion unverified; file-size finding must be fixed. |
| F2-1 | Dispatcher + plan validator parity | PASS | `orchestration-artifacts.ts` has `PLAN_PHASE_RE`/`PLAN_TASK_RE`, the 5-type switch + unsupported fallback, and `requireComplete` threading. | Read `src/lib/validate/orchestration-artifacts.ts`; `orchestration-artifacts.test.ts` 619-suite pass | Matches Python regexes and strings. |
| F2-2 | orchestrator-state core+remediation split, verbatim strings | PASS | core (371) + remediation (136) + completion (198) all < 500; messages match Python. | `wc -l`; `grep` parity | Plan-named split honored; extra completion module documented. |
| F2-3 | human_interaction invariants verbatim | PASS | Three invariants and exact strings ported. | Read `orchestrator-state-human-interaction.ts`; tests pass | Includes `pythonRepr` for `got: <response>` parity. |
| F2-4 | routing-contract receipts, hermetic, no node:fs | PASS | Matrix injected via `options.routingMatrix` or `loadRoutingMatrix(fs, root)`; no direct `node:fs`. | Read `orchestrator-state-routing.ts`; tests pass | Verbatim agent/skill/MCP-receipt and empty-list messages. |
| F2-5 | review-artifacts heading validators verbatim | PASS | Code-review and feature-audit heading + findings-table-header checks present. | Read `review-artifacts.ts`; tests pass | Exact headings and strings. |
| F2-6 | policy-audit validator parity | PASS | Headings, checklist labels, 7-column coverage-table parsing, comparison checks, placeholder/template-resolver logic ported. | Read `policy-audit-artifact.ts`; this audit passes the ported validator | `validate_policy_audit_artifact.py` exit 0 against this artifact. |
| F2-7 | evidence-locations forbidden-prefix map + VIOLATION message | PASS | 9-entry map and em-dash `VIOLATION:` line; injected `FileSystem`. | Read `evidence-locations.ts`; tests pass | Matches Python map and message. |
| F2-8 | json-validator built-in checker + governed files + local schema; divergence doc | PASS | Built-in checker, `iterGovernedFiles` reuse, local/`file:` schema, unsupported-scheme throw; divergence note present. | Read `json-validator.ts`; tests pass | Remote fetch intentionally excluded and documented. |
| F2-9 | service in-process dispatch; contract preserved; no other change | PASS | Body rewired; success returns `{ tool, workspaceRoot, summary }` with preserved summary; throws on errors; only this method + constructor field changed. | diff of `repo-automation-service.ts` | `command-runtime.ts` and `"python"` branch untouched. |
| F2-10 | MCP input contract + existing tests pass | PASS | Rewritten orchestration-validation tests pass; full suite green. | `node run-jest.cjs` 619/619 | Interface signature unchanged. |
| F2-11 | F1 modules reused, none re-ported | PASS | Imports `FileSystem`/`toPosixPath` from `../file-system` and `iterGovernedFiles` from `../json-config`. | `grep` imports | No re-port of F1 files. |
| F2-12 | new files covered; line >= 85% / branch >= 75%; numeric evidence | PASS | 95% line / 88.73% branch; per-file all >= 85%/>= 75%; numeric in evidence. | coverage rerun | `qa-test-coverage.md`. |
| F2-13 | format/lint/typecheck/test single clean pass | PASS | All four passed on independent rerun. | prettier --check; npm run lint; npm run typecheck; node run-jest.cjs | Single pass, no auto-fix mutations. |
| F2-14 | No file > 500 lines; hermetic tests | FAIL | All new `src/lib/validate/**` files < 500 (max 433) and all test files < 500. But the MODIFIED production file `src/repo-automation-service.ts` is 526 lines (484 baseline), exceeding 500. | `wc -l src/repo-automation-service.ts` = 526; `git show f6af666e:...` = 484 | Tests are hermetic (no subprocess/temp files). The file-size sub-criterion fails for the modified file. |
| F2-15 | Python `scripts/dev_tools/**` unmodified | PASS | No Python files in the diff. | `git diff f6af666e..HEAD --name-only -- 'scripts/dev_tools/**'` = empty | Retained for repo CI/hooks per scope. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 14 criteria (E2 plus F2-1..F2-13, F2-15)
- **PARTIAL:** 4 criteria (E1, E3, E4, E5 — epic-level, realized incrementally / CI conclusion unverified)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (F2-14, file-size sub-criterion on the modified service file)

**Top gaps preventing PASS:**

1. AC-F2-14: `src/repo-automation-service.ts` exceeds the 500-line limit (526 lines) after this change. This is the single remediation-required gap for the F2 feature.
2. AC-E5: CI conclusion at HEAD is not available in the PR context; combined with the open file-size finding, full PR readiness is not yet established.
3. Epic ACs E1/E3/E4 are partial by design (completed across the feature series, fully at F11); not blockers for F2.

**Recommended follow-up verification steps:**

1. Refactor `repo-automation-service.ts` to <= 500 lines (extract the in-process validation wiring into a helper module) and re-run the full toolchain.
2. After the refactor, confirm the rewritten orchestration-validation tests and the full Jest suite remain green, and capture a CI green run for AC-E5.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- The epic ACs in `spec.md` (AC-E1..AC-E5) are evaluated PARTIAL at F2 (realized incrementally; fully at F11). They remain unchecked in `spec.md`.
- The F2 plan AC checklist in `plans/F2-validate-orchestration-artifacts.plan.md` is the per-feature AC source. Items F2-1..F2-13 and F2-15 evaluate PASS; F2-14 evaluates FAIL. The plan file already has all F2 items marked `[x]` by the executor.
- Because AC-F2-14 is FAIL in this review, it must NOT remain checked off. This audit records that AC-F2-14 should be reverted to `[ ]` in the plan file pending remediation of the file-size finding. No PASS criterion required a new check-off (the executor pre-checked all items); the reviewer's action here is to flag the one over-checked item rather than add checkmarks.

### AC Status Summary

- Source: `plans/F2-validate-orchestration-artifacts.plan.md` (per-feature AC); `spec.md` (epic AC)
- Total AC items: 15 (F2 plan) + 5 (epic)
- Checked off (delivered and verified PASS this review): 14 of 15 F2 items
- Remaining (not verifiable as PASS this review): F2-14 (FAIL); epic E1/E3/E4/E5 (PARTIAL by design / CI unverified)
- Items remaining: AC-F2-14 (file-size on modified service file); AC-E1, AC-E3, AC-E4, AC-E5 (epic, incremental)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `plans/F2-validate-orchestration-artifacts.plan.md` | 15 | 14 | 1 | Checkbox-backed; F2-14 must be reverted to unchecked pending remediation. |
| `spec.md` (epic AC-E1..E5) | 5 | 0 | 5 | Checkbox-backed; epic ACs realized incrementally, fully at F11. |

No new source-file checkbox was set by this review. The executor had pre-checked all 15 F2 items; this review identifies AC-F2-14 as not satisfied and flags it for reversion. The plan file is not edited by this audit beyond that recommendation, to avoid masking the open finding.
