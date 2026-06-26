# Feature Audit: F11 ts-command-runtime-cleanup (Epic #240, final feature)

**Audit Date:** 2026-06-26
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base Branch:** `main`
**Head Branch:** `feat/ts-port-command-runtime-cleanup-240`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review (epic-completion at F11)

---

## Scope and Baseline

- **Base branch:** `main` (commit `bbfbab947edd60a51353044db6b8ebba5f220286`)
- **Head branch/commit:** `feat/ts-port-command-runtime-cleanup-240` (commit `8def2ad6ed5207060d5313bc97ea4c6260ceae80`)
- **Merge base:** `bbfbab947edd60a51353044db6b8ebba5f220286` (committed 2026-06-26T08:52:20-04:00)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/**`
  - Additional evidence: reviewer-reproduced `git diff bbfbab94..8def2ad`, two full test-suite runs, coverage artifacts
- **Feature folder used:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
- **Requirements source:** `spec.md` (epic ACs AC-E1..AC-E5; `## User Story` inline) and `plans/F11-command-runtime-cleanup.plan.md` (F11 plan AC checklist AC-F11-1..AC-F11-13).
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`. For `full-feature`, AC sources are `spec.md` and `user-story.md`.
- **Scope note:** `user-story.md` does not exist in the feature folder; the epic carries its user story inline in `spec.md` ("## User Story") and tracks acceptance criteria in `spec.md` plus per-feature plan checklists. AC evaluation therefore used `spec.md` (epic ACs) and the F11 plan checklist as the authoritative source set. The PR-context summary misclassified the changed TypeScript as "Core logic changes: 74 files" and listed deletions; the reviewer used `git diff --name-status` as authoritative (113 files: 1 new TS module + test, several TS edits, bundled Python and bundled-parity test deletions).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary (epic ACs)
- `plans/F11-command-runtime-cleanup.plan.md` — F11 feature ACs (per-feature checklist)
- `user-story.md` — expected by `full-feature` but absent (documented above)

### From spec.md (Epic ACs)

1. AC-E1: Every Python command script invoked by the extension or MCP server has a TypeScript equivalent with behavior parity (CLI output, exit codes, file artifacts, JSON shapes). (Delivered by F2-F10.)
2. AC-E2: TypeScript test coverage for ported modules meets policy (line >= 85%, branch >= 75%).
3. AC-E3: `RepoAutomationService` methods invoke in-process TypeScript instead of spawning Python; the `"python"` runtime branch and bundled Python resources are removed (delivered by F11).
4. AC-E4: No remaining runtime dependency on a `python` interpreter for extension or MCP command execution.
5. AC-E5: All CI gates pass on each feature PR.

### From plans/F11-command-runtime-cleanup.plan.md (F11 ACs)

AC-F11-1..AC-F11-13 as listed in the plan (helloPython in-process; command-runtime narrowing; ScriptExecutionOptions narrowing; dead builder removal; no bundled Python; MCP prepack; surgical Python test removal; README; TS suite green; Python suite green; AC-E3; AC-E4; epic completion).

---

## Acceptance Criteria Evaluation

### Epic ACs (spec.md)

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-E1 | TS equivalents with parity for all extension/MCP Python commands | PASS | Delivered by F2-F10 (cited in spec); F11 removes the now-dead bridge. helloPython parity confirmed in-process. | `rg --files extensions/drm-copilot/resources -g '*.py'` (zero) | Parity for the 12 commands established in prior features; F11 does not regress them (1389 TS tests pass). |
| AC-E2 | TS coverage line >= 85%, branch >= 75% | PASS | `src` 96.62% line / 88.29% branch; `hello-message.ts` 100%/100%. | `node run-jest.cjs --coverage --collectCoverageFrom="src/**/*.ts"` | Reviewer reran; `coverage/lcov.info` present. |
| AC-E3 | Service invokes in-process TS; `"python"` branch + bundled Python removed | PASS | `RuntimeKind="powershell"`; no Python branch in `detectRuntime()`; zero `.py` under `resources/`; four dead builders removed. | `rg -n 'runtimeKind: *"python"\|detectRuntime\("python"\)' extensions/drm-copilot/src extensions/drm-copilot/test` (zero) | Reviewer independently reproduced zero matches. |
| AC-E4 | No `python` interpreter runtime dependency | PASS | Last Python spawn (helloPython) ported in-process; `.vscodeignore` and MCP prepack exclude Python; MCP prepack run produced zero `.py`. | `rg --files packages/mcp-server/resources -g '*.py'` (zero, per evidence) | No-python audit reproduced by reviewer. |
| AC-E5 | All CI gates pass on each feature PR | PARTIAL | Local toolchain green for both languages (format/lint/typecheck/test all EXIT 0; 1389 TS + 1123 Python pass). CI status at HEAD is "(not available)" in PR context; no PR exists yet for this branch. | `npm run format/lint/typecheck`; `poetry run pytest` | Local equivalents of CI gates all pass; the actual CI run on a PR head has not yet executed. Not a defect; an as-yet-unobserved external gate. |

### F11 plan ACs (plans/F11-command-runtime-cleanup.plan.md)

| # | Criterion (abbreviated) | Status | Evidence |
|---|--------------------------|--------|----------|
| AC-F11-1 | helloPython in-process via `hello-message.ts`, command ID + `hello_python:ok\n` preserved | PASS | `src/lib/hello-message.ts`; `extension.ts` registers `helloPython` calling `writeHelloMessage`; content byte-identical; 100% coverage. |
| AC-F11-2 | `command-runtime.ts` no Python branch; `RuntimeKind="powershell"`; PowerShell behavior unchanged | PASS | `RuntimeKind = "powershell"` (line 12); detectRuntime PowerShell-only; reviewer grep zero Python. |
| AC-F11-3 | `ScriptExecutionOptions.runtimeKind="powershell"`; no `runtimeKind:"python"` in src | PASS | support.ts line 10 `readonly runtimeKind: "powershell"`; typecheck EXIT 0; grep zero. |
| AC-F11-4 | Four dead builders + orphaned imports removed; file <= 500 | PASS | `repo-automation-service-workflows.ts` 133 lines; no `runtimeKind:"python"`. |
| AC-F11-5 | No bundled Python; `.vscodeignore` excludes; PowerShell + DATA payloads retained | PASS | zero `.py` under `resources/`; `.vscodeignore` has `**/*.py` + `resources/scripts/**`; `resources/powershell/`, `resources/claude-customizations/`, 11 `.ps1` templates present. |
| AC-F11-6 | MCP prepack copies no Python; payloads preserved | PASS | `packages/mcp-server/prepack.cjs` filter; `evidence/qa-gates/mcp-prepack-no-python.md` EXIT 0. |
| AC-F11-7 | Only bundled-parity Python tests removed/edited; source + DATA + PowerShell tests retained | PASS (with Minor note) | 4 parity files + bundled-wrapper tree removed; 3 files surgically edited; `scripts/dev_tools` source (91) + `tests/scripts/dev_tools` (111) retained; zero bundled refs in `tests/`. Two of the three edited files were not pre-enumerated in P5 (see code review Minor finding). |
| AC-F11-8 | README de-claims Python runtime; helloPython listed; PowerShell bullets retained | PASS | `README.md` updated; reviewer confirms helloPython command remains; `pwsh`/`powershell` requirement retained. |
| AC-F11-9 | TS suite green; `hello-message.ts` >= 85%/75%; no `src` regression | PASS | 1389 pass; 100%/100% new code; 96.62%/88.29% repo-wide (reviewer rerun). |
| AC-F11-10 | Python suite green; line >= 85%/branch >= 75%; CI 3.10-3.13 not broken | PASS | 1123 pass/19 skip; 85.72% line / 85.97% branch (reviewer rerun). |
| AC-F11-11 (AC-E3) | Service in-process; Python branch + bundled removed | PASS | See AC-E3. |
| AC-F11-12 (AC-E4) | No `python` runtime dependency | PASS | See AC-E4. |
| AC-F11-13 | Epic completion recorded; AC-E3/AC-E4 marked satisfied | PASS | `spec.md` AC-E3/AC-E4 `[x]`; `evidence/qa-gates/f11-acceptance.md`; `evidence/issue-updates/issue-240.2026-06-26T09-27.md`. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary (epic ACs):**
- **PASS:** 4 (AC-E1, AC-E2, AC-E3, AC-E4)
- **PARTIAL:** 1 (AC-E5 — local gates pass; CI run on a PR head not yet observed)
- **UNVERIFIED:** 0
- **FAIL:** 0

**Criteria summary (F11 plan ACs):** 13 PASS, 0 PARTIAL, 0 FAIL (AC-F11-7 PASS with a Minor traceability note).

**Top gaps preventing PASS:**

1. AC-E5 is PARTIAL only because no PR/CI run exists for this branch yet; all local CI-equivalent gates pass for both languages. This is an as-yet-unobserved external gate, not a code defect — it does not trigger remediation per the SKILL (toolchain checks pass locally).

**Recommended follow-up verification steps:**

1. Open the PR for `feat/ts-port-command-runtime-cleanup-240` and confirm the CI workflows (including Python "Code Quality & Tests" 3.10-3.13) report green on the PR head to close AC-E5.
2. In a separate, non-blocking follow-up, split the two pre-existing >500-line files (`src/workflow-command-arguments.ts` 663; `test/extension.workflow-commands.test.ts` 774); both are outside the F11 diff.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Epic ACs in `spec.md` are checkbox-backed. AC-E1, AC-E2, AC-E3, AC-E4 evaluate PASS and are already `[x]` in `spec.md` (checked off by the executor at F11). The reviewer confirms these check-offs are evidence-backed and leaves them checked.
- AC-E5 evaluates PARTIAL and remains `[ ]` in `spec.md` (correct; CI on a PR head not yet observed). No reviewer change.
- The F11 plan ACs (AC-F11-1..AC-F11-13) are all `[x]` in the plan; the reviewer confirms each is evidence-backed and leaves them checked.

No source-file checkbox state change was required by the reviewer: all PASS epic ACs were already checked, and the only unchecked epic AC (AC-E5) correctly remains unchecked pending CI observation.

### AC Status Summary

- Source: `spec.md` (epic ACs) and `plans/F11-command-runtime-cleanup.plan.md` (F11 ACs)
- Total AC items: 5 epic + 13 F11 = 18
- Checked off (delivered): 4 epic (AC-E1..E4) + 13 F11 = 17
- Remaining (unchecked): 1 epic (AC-E5)
- Items remaining: AC-E5 (All CI gates pass on each feature PR) — PARTIAL pending CI run on a PR head.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 5 | 4 | 1 | Checkbox-backed; AC-E5 PARTIAL pending CI observation. |
| `plans/F11-command-runtime-cleanup.plan.md` | 13 | 13 | 0 | Checkbox-backed; all PASS. |
| `user-story.md` | 0 | 0 | 0 | Absent; epic user story carried inline in `spec.md`. |
