# Feature Audit: F10 — ts-codex-native-converter (Issue #240)

**Audit Date:** 2026-06-26
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base Branch:** `main`
**Head Branch:** `feat/ts-port-codex-native-converter-240` @ `b45dbae1e9bd66ae2b91e0a2877a477d3322722e`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge base `d06d39e2c8c8cb1753a4442773b6313d6d8885af`)
- **Head branch/commit:** `feat/ts-port-codex-native-converter-240` @ `b45dbae1e9bd66ae2b91e0a2877a477d3322722e`
- **Merge base:** `d06d39e2c8c8cb1753a4442773b6313d6d8885af`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (head SHA matches HEAD; treated as fresh)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff --name-status d06d39e2..HEAD`
  - Feature evidence: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/**`
  - Additional evidence: independent toolchain re-runs (Prettier check, ESLint, tsc, Jest coverage), `wc -l` measurements, `validate_evidence_locations.py`
- **Feature folder used:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
- **Requirements source:** `spec.md` (epic AC + inline user story) and `plans/F10-codex-native-converter.plan.md` (F10 AC checklist). `issue.md` `Work Mode: full-feature`.
- **Work mode resolution note:** `issue.md` line `- Work Mode: full-feature`. full-feature requires `spec.md` AND `user-story.md`.
- **Scope note:** No standalone `user-story.md` exists in the feature folder. The user story is present inline in `spec.md` ("## User Story"). The PR-context summary misclassifies the TS changes as tooling ("Core logic changes: 0 files"); per the explicit caller instruction and known summary defect, `git diff --name-status` and direct `git diff` were treated as authoritative for scope. The branch diff contains only F10-related changes, so full-diff scope and F10 scope coincide.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — epic acceptance criteria (AC-E1..AC-E5) plus the inline user story; primary
- `plans/F10-codex-native-converter.plan.md` (## F10 Acceptance Criteria) — feature-level AC-F10-1..AC-F10-10; primary feature source
- `user-story.md` — absent; inline user story in spec.md used as substitute

### User story (from spec.md)

> As a user of the drm-copilot extension and the published MCP server, I want every command to run without a Python interpreter on PATH, so that the tools work on machines that do not have Python installed.

### Epic acceptance criteria (from spec.md)

1. AC-E1: Every Python command script invoked by the extension or MCP server has a TypeScript equivalent with behavior parity.
2. AC-E2: TypeScript test coverage for ported modules meets policy (line >= 85%, branch >= 75%).
3. AC-E3: `RepoAutomationService` methods invoke in-process TypeScript instead of spawning Python; the `"python"` runtime branch and bundled Python resources are removed (delivered by F11).
4. AC-E4: No remaining runtime dependency on a `python` interpreter for extension or MCP command execution.
5. AC-E5: All CI gates pass on each feature PR.

### F10 acceptance criteria (from plan)

1. AC-F10-1: All 16 in-scope `codex_native_converter/*.py` modules ported with behavior parity.
2. AC-F10-2: Files near the 500-line limit split as planned; no file in `src/lib/codex-native-converter/**` or `test/lib/codex-native-converter/**` exceeds 500 lines.
3. AC-F10-3: `runCodexNativeConverter()` invokes the in-process TS port; no Python spawn path reachable from that method; `repo-automation-service.ts` <= 500 lines.
4. AC-F10-4: Return contract preserved (tool, exact summary string, single normalized artifact path; review/apply write behavior).
5. AC-F10-5: Typer CLI replaced by TS argument parser preserving validation error strings and apply-mode non-zero-exit-equivalent; no `typer` dependency introduced.
6. AC-F10-6: All ported Jest tests hermetic and under `test/lib/codex-native-converter/`, covering all 16 Python test files; T1 classifier has property-based / exhaustive invariant coverage.
7. AC-F10-7: New `src/lib/codex-native-converter/**` files meet coverage (line >= 85%, branch >= 75%) with no regression on changed lines.
8. AC-F10-8: Format, lint, type-check, and test all pass in a single clean toolchain pass.
9. AC-F10-9: F1 `file-system.ts` / `subprocess-runner.ts` reused (not re-ported); `command-runtime.ts`, the `"python"` branch, and all `scripts/dev_tools/**` / `resources/**/*.py` unmodified.
10. AC-F10-10: Reworked `mcp-tools.codex-native-converter.test.ts`, `codex-native-converter-handlers.test.ts`, `mcp-tool-inputs.codex-native-converter.test.ts` preserve dispatch/input-schema assertions and assert the in-process path with zero assertions of a `codex_native_converter.py` spawn.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| US | User story: commands run without Python on PATH | PARTIAL | Converter no longer spawns Python; other commands still use `runtimeKind: "python"` until F11. | `grep runtimeKind src/repo-automation-service-workflows.ts` | Epic-level outcome realized incrementally; fully met at F11. |
| E1 | TS equivalent with behavior parity for invoked scripts | PARTIAL | F10 delivers the converter port with parity tests; epic-wide parity completes across F1–F11. | `git diff --name-status` | Incremental epic AC; F10 contributes the converter. |
| E2 | Coverage policy for ported modules | PASS | `src/lib/codex-native-converter` 98.87% lines / 89.06% branch; all new files above thresholds. | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/codex-native-converter/**/*.ts"` | See policy-audit Section 5. |
| E3 | Service invokes in-process TS; Python branch removed (by F11) | PARTIAL | `runCodexNativeConverter` delegates in-process; `"python"` branch removal explicitly deferred to F11 by spec. | `repo-automation-service.ts:227-244` | Branch removal is out of F10 scope by design. |
| E4 | No remaining `python` runtime dependency | PARTIAL | True for the converter command; other commands still spawn Python until F11. | `grep runtimeKind` | Incremental; fully met at F11. |
| E5 | All CI gates pass | PASS (local) | Format, lint, typecheck, 1387 tests all pass locally in a single pass. | `npx prettier --check`; `npm run lint`; `npm run typecheck`; `node run-jest.cjs --coverage` | CI run on the PR not yet present; local toolchain green. |
| F10-1 | All 16 modules ported with parity | PASS | 23 TS modules covering the 16 Python sources (with splits); parity tests port all 16 Python test files. | `git diff --name-status`; `evidence/qa-gates/f10-acceptance.md` | Largest new file 372 lines. |
| F10-2 | Planned splits; no file > 500 lines | PASS | All 23 new production + 17 new test files <= 372 lines (independently measured). | `wc -l src/lib/codex-native-converter/*.ts test/lib/codex-native-converter/*.ts` | classifier/classifier-claude, rewrites/rewrites-rules, engine/engine-pipeline, pipeline/pipeline-render, reporting/reporting-render all present. |
| F10-3 | In-process invocation; no Python spawn from method; service <= 500 | PASS | `runCodexNativeConverter` calls `runCodexNativeConverterServiceCall`; converter Python builder deleted; `repo-automation-service.ts` = 494 lines. | `wc -l src/repo-automation-service.ts`; read lines 227-244 | Independently confirmed 494 lines. |
| F10-4 | Return contract preserved | PASS | Helper returns `tool: "run_codex_native_converter"`, verbatim summary, single artifact = report parent; review/apply write semantics in engine. | Read `codex-native-converter-service-call.ts`; `engine.test.ts`; `codex-native-converter-service-call.test.ts` | Summary string matches verbatim. |
| F10-5 | Typer replaced by TS arg parser; error strings + apply exit preserved; no typer dep | PASS | `cli.ts` reproduces `review`/`apply`, verbatim error strings, apply non-zero on blocking; no new runtime dependency. | `cli.test.ts`; grep new code for deps | No `typer`/new dep introduced. |
| F10-6 | Hermetic tests, correct location, cover 16 Python test files; T1 invariant coverage | PASS | 17 test files + in-memory FS helper under `test/lib/codex-native-converter/`; classifier exhaustive `it.each` + determinism invariant. | `node run-jest.cjs`; `evidence/other/property-test-tooling-note.md` | No temp files / real FS. |
| F10-7 | New-file coverage >= 85% line / 75% branch, no changed-line regression | PASS | Lowest line 93.44% (`pipeline-traces.ts`), lowest branch 79.54% (`pipeline-render.ts`); `src/lib` aggregate not regressed. | `node run-jest.cjs --coverage`; `evidence/qa-gates/f10-coverage-delta.md` | All above thresholds. |
| F10-8 | Single clean toolchain pass | PASS | Prettier check clean; ESLint exit 0; tsc exit 0; 1387 tests pass; no auto-fix needed. | `npx prettier --check`; `npm run lint`; `npm run typecheck`; `node run-jest.cjs` | Re-run this audit. |
| F10-9 | F1 reuse; protected files unmodified | PASS | `file-system.ts` reused (imported, not re-ported); diff shows no changes to `command-runtime.ts`, `scripts/dev_tools/**`, or `resources/**/*.py`. | `git diff --name-status d06d39e2..HEAD` | Only converter Python builder removed (in workflows file), not the `"python"` runtime branch. |
| F10-10 | Reworked MCP/handler/input tests preserve assertions; zero Python-spawn assertions | PASS | These three files are not in the branch diff (unchanged); spawn-search artifacts confirm no `codex_native_converter.py` spawn assertion existed; the modified `repo-automation-service.codex-native-converter.test.ts` asserts the in-process contract. | `git diff --name-status`; `evidence/other/codex-converter-spawn-test-search.md`, `codex-converter-extension-test-search.md` | The three named files were not modified because no spawn assertion needed rewriting; negative-evidence recorded. |

---

## Summary

**Overall Feature Readiness:** PASS (with non-blocking follow-up)

**Criteria summary:**
- **PASS:** 12 criteria (E2, E5-local, F10-1 through F10-10)
- **PARTIAL:** 4 criteria (US, E1, E3, E4 — all epic-level and incremental by design; F10's contribution is complete)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:**

1. The PARTIAL epic-level criteria (US, E1, E3, E4) are incremental and explicitly completed at F11 per `spec.md`; they are not F10 deficiencies. F10 fully delivers its assigned scope.
2. Non-blocking debt: `test/extension.workflow-commands.test.ts` (774 lines, modified) exceeds the 500-line limit; pre-existing, not introduced by F10.
3. Source-completeness: no standalone `user-story.md`; inline user story in `spec.md` used.

**Recommended follow-up verification steps:**

1. After PR open, confirm CI gates run green on the PR head (E5 full verification).
2. Track a follow-up to split `test/extension.workflow-commands.test.ts` below 500 lines.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 10 F10 plan AC items (AC-F10-1..AC-F10-10) evaluate PASS and were already checked off `[x]` in `plans/F10-codex-native-converter.plan.md` by the executor; verification confirms they are correctly checked. No change needed.
- The epic AC items (AC-E1..AC-E5) in `spec.md` remain `[ ]` and are left unchecked: they are incremental epic criteria fully realized at F11, and four evaluate PARTIAL at F10. Per the rules, PARTIAL items are not checked off.
- No new criteria were added; no criterion text was modified.

### AC Status Summary

- Source: `plans/F10-codex-native-converter.plan.md` (F10 AC) and `spec.md` (epic AC)
- Total AC items: 10 F10-level + 5 epic-level = 15
- Checked off (delivered): 10 (all F10-level AC; already `[x]` and verified)
- Remaining (unchecked): 5 epic-level (E1, E3, E4 PARTIAL; E2 and E5 PASS but tracked at epic completion/F11; left as authored)
- Items remaining: AC-E1, AC-E2, AC-E3, AC-E4, AC-E5 (epic-level; realized incrementally through F11)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `plans/F10-codex-native-converter.plan.md` | 10 | 10 | 0 | Checkbox-backed; all F10 AC verified PASS and already checked. |
| `spec.md` | 5 | 0 | 5 | Checkbox-backed; epic AC, incremental to F11; 3 PARTIAL at F10. Left as authored. |

No source-file checkbox change was made by this audit: the F10 plan items were already checked by the executor and verified correct; the epic items are not eligible for check-off at F10 (incremental / PARTIAL).
