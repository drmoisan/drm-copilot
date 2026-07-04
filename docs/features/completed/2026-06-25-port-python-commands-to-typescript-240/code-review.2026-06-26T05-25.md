# Code Review: F8 ts-new-active-feature-folder (Issue #240)

**Review Date:** 2026-06-26
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Feature Folder Selection Rule:** Suffix `-240` matches the issue number in the branch scope; it holds the F8 plan and evidence.
**Base Branch:** `main` (merge-base `c432b69a294ef17ace8b64964b6b0cafb22bd450`)
**Head Branch:** `drm-copilot-wt-2026-06-25-22-10`
**Review Type:** Initial review

---

## Executive Summary

F8 ports the Python `new_active_feature_folder` cluster (six source modules + facade) into in-process TypeScript under `extensions/drm-copilot/src/lib/new-active-feature-folder/**` and rewires `RepoAutomationService.newActiveFeatureFolder()` from the Python-spawn path to a single delegation to the extracted helper `new-active-feature-folder-service-call.ts`. The port preserves the Python control flow, error messages, emitted lines, and regexes, with hermetic Jest tests using a `Map`-backed filesystem fake and injected `gh`/launcher/clock seams.

**What changed:** 8 new/modified production TypeScript files and 11 new/updated test files. `repo-automation-service.ts` was reduced/held at 499 lines by extracting the in-process call body to the helper module. No Python source was removed (removal is F11), and `command-runtime.ts`, `executeScript`, and the `"python"` runtime branch are untouched.

**Top 3 risks:**
1. `io.ts` is 542 lines, over the 500-line hard limit — the plan-mandated `io-launcher.ts` split was not done (Blocking).
2. Byte-identical-parity claims (regexes, messages, section ordering) are validated only by the ported Jest tests; no cross-run diff against live Python output is part of this branch (mitigated by the comprehensive parity test mapping in `f8-port-parity.md`).
3. The Jest-vs-Vitest divergence (D1) remains a standing policy-reconciliation gap at the package level.

**PR readiness recommendation:** **Needs Revision** — implementation quality is high and the toolchain is green, but the `io.ts` file-size violation must be fixed before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` | whole file (542 lines) | File exceeds the 500-line hard limit in `.claude/rules/general-code-change.md`. The plan Split Strategy (line 55) and P2-T1 acceptance required extracting the launcher seam into `io-launcher.ts` if `io.ts` breached 500 lines; the split was not performed. | Extract `INSIDERS_SIGNAL_NAMES`, `isInsidersSession`, `resolveCodeCli`, `defaultCodeLauncher` (and supporting launcher helpers) into `io-launcher.ts`, re-export from `io.ts`, and re-run the toolchain so both files are < 500 lines. | Hard policy limit; AC-F8-10 and AC-F8-3 (P2-T1 "file < 500 lines") are not met. | `wc -l` → `542 .../io.ts`; plan line 55, task P2-T1. |
| Major | `extensions/drm-copilot/test/**` | package-wide | Tests use Jest, not the Vitest mandated by `.claude/rules/typescript.md` step 4. | No per-feature action; reconcile policy text vs package toolchain at the epic/policy level. | Pre-existing, package-wide; accepted decision D1 in `spec.md`. | `spec.md` D1; `jest.config.cjs`; `run-jest.cjs`. |
| Info | `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts` | `getEstTimestamp` docstring | Documented intentional divergence: Python's naive-datetime `ValueError` path has no TS analogue (a `Date` is always an instant). | None; keep documented. | Behavior parity is intentionally relaxed only where the source distinction cannot exist in TS. | `models.ts` docstring; `f8-port-parity.md`. |
| Info | `extensions/drm-copilot/src/lib/new-active-feature-folder/index.ts` | whole file | Re-export-only facade reports 10.34% function coverage (100% line). | None; documented per `.claude/rules/general-unit-test.md` re-export clarification. | Re-export-only files legitimately report low executable coverage. | coverage table; plan P3-T3. |

No additional Blocker or Major code-correctness findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- Clean separation: pure logic (`models.ts`, `markdown.ts`) is isolated from I/O (`io.ts`, `RealFolderFileSystem`) and from service wiring (`new-active-feature-folder-service-call.ts`), satisfying the general-code-change separation-of-concerns priority.
- The port avoids widening the shared F1 `FileSystem` interface by defining a port-local `FolderFileSystem` seam in `models.ts`, mirroring the F6/F7 decision. This keeps the shared interface stable (AC-F8-6).
- The service method was rewired to a single helper delegation (`return newActiveFeatureFolderServiceCall({...})` at `repo-automation-service.ts:350`), and the now-unused `buildNewActiveFeatureFolderOptions` import was removed, holding the service file at 499 lines.
- Escape-safe replacements: `setSection` and `updateSectionBody` use function-form replacement callbacks so backslash-rich bodies (e.g. `C:\Outlook\Objects`) are inserted literally — the two locked-in regression scenarios are covered by tests.

#### Type safety and maintainability

- No `any` types: a targeted grep for `: any` / `as any` / `<any>` found only documentation-comment text, not actual annotations. Typecheck passes with 0 errors under the strict-type-checked ESLint stack.
- The clock seam (`nowProvider`) is the single allowed wall-clock access; no executable `Date.now()` call exists in the cluster.
- The principal maintainability gap is the `io.ts` size (542 lines). The launcher seam is a natural, plan-anticipated extraction boundary; splitting it restores compliance without behavior change.

#### Error handling and logging

- `createActiveFolder` throws `Error` with byte-identical messages for invalid type, invalid feature name, missing template, target-exists, and invalid work mode; the service-call helper preserves the prior non-zero-exit failure surface.
- `defaultIssueFetcher` is guarded: a missing `gh`, non-zero exit, blank stdout, or JSON parse error returns `null` and the flow proceeds with `TBD`/`name` defaults — no silent swallow of unexpected state.
- Emitted lines forward to the output channel via the injected `log` sink; the launcher is a no-op returning `false` in the service path, emitting the manual-open warning lines as designed.

---

## Test Quality Audit

The ported tests mirror the Python scenario suites (`test_new_active_feature_folder*.py`, the markdown-escape and models-coverage edge cases, and the template-resources test). All 999 tests across 85 suites pass in 2.507s on the reviewer's independent run with coverage enabled.

### Reviewed test and QA artifacts

- `test/lib/new-active-feature-folder/{models,markdown,io,docs,flow,new-active-feature-folder-service-call}.test.ts` — module-level parity coverage; hermetic fakes; AAA.
- `test/lib/new-active-feature-folder/fakes.ts`, `test/new-active-feature-folder-fs-harness.ts` — `Map`-backed `FolderFileSystem` fake and harness; no real filesystem.
- `test/extension.new-active-feature-folder-inprocess.test.ts` and the updated `extension.new-active-feature-folder.test.ts` — assert the in-process path (no Python spawn) and the inverted missing-python case.
- `evidence/qa-gates/f8-final-test-coverage.md`, `evidence/qa-gates/f8-coverage-delta.md` — coverage and no-regression evidence (independently re-verified).
- `evidence/regression-testing/f8-port-parity.md` — maps each parity property to a passing test.

### Quality assessment prompts

- **Determinism:** Injected clock, env/which, runner, and filesystem seams; deterministic `America/New_York` formatting via `Intl.DateTimeFormat`.
- **Isolation:** One behavior per test; module-scoped suites.
- **Speed:** 999 tests in 2.507s.
- **Diagnostics:** Assertions check byte-identical strings and ordered call sequences (e.g. `mkdir`→`unlink`→`replace` for `move`).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials/tokens in the diff; `gh` invoked via injected runner only. |
| No unsafe subprocess or command construction | ✅ PASS | `gh issue view <n> --json ...` runs through the injected F1 `CommandRunner` with a fixed arg vector; launcher uses `--reuse-window` with posix paths; no shell-string interpolation. |
| Input validation at boundaries | ✅ PASS | `validateFeatureName`/`buildFolderSlug` enforce `NAME_PATTERN`; type and work-mode validated with byte-identical error messages. |
| Error handling remains explicit | ✅ PASS | Explicit `Error` throws; guarded `null` returns for optional `gh`; no broad catch-and-ignore. |
| Configuration / path handling is safe | ✅ PASS | Path joins normalized to posix via `toPosixPath`/`node:path`; filesystem access via the injected seam; `templateRoot` forwarded from `this.templateRoot`. |

---

## Research Log

No external research was required. All evidence came from the branch diff, the F8 plan and evidence artifacts, repository policy rules, and the reviewer's independent toolchain runs.

---

## Verdict

The F8 port is well-structured, strongly typed, hermetically tested, and toolchain-clean (format, lint, typecheck, 999/999 tests, coverage above policy). It is not ready for normal PR flow solely because `io.ts` (542 lines) violates the 500-line hard limit — a Blocking finding the plan itself anticipated and required to be avoided via an `io-launcher.ts` split. After that single extraction and a re-run of the toolchain, the change should be merge-ready. This verdict is consistent with the Findings Table and the Needs-Revision recommendation above.
