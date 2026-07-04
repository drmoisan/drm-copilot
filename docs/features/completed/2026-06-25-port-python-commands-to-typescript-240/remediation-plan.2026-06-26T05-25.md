# Remediation Plan — F8 ts-new-active-feature-folder (Issue #240)

**Issue:** #240
**Feature:** F8 (ts-new-active-feature-folder)
**Work Mode:** full-feature
**Entry timestamp:** 2026-06-26T05-25
**Plan path:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-plan.2026-06-26T05-25.md`
**Feature folder (`<FEATURE>`):** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Remediation inputs:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/remediation-inputs.2026-06-26T05-25.md`

## Scope Summary

Resolve the single Blocking remediation-required finding R1 from the 2026-06-26T05-25 audit cycle: `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` exceeds the 500-line production-file limit (542 lines). The fix extracts the VS Code launcher seam into a sibling module `io-launcher.ts` and re-exports it from `io.ts`, returning both files to < 500 lines with no change to observable behavior, public exports, regexes, message strings, or the `gh --json` field list. No other findings require action this cycle.

## Constraints (must hold for every task)

- No production or test file may exceed 500 lines.
- ES modules only; no `require`/`module.exports` in `src/`.
- Strong typing; no `any`; no new ESLint/TS suppressions.
- The split must be behavior-preserving: no change to any public export name, signature, regex, message string, emitted line, or the `gh --json` field list.
- Do NOT modify `command-runtime.ts`, the `"python"` runtime branch, `executeScript`, `repo-automation-service-workflows.ts`, or `repo-automation-args.ts`.
- Do NOT modify any Python `scripts/dev_tools/**`, `resources/scripts/dev_tools/**/*.py`, or `resources/templates/*.py` file.
- Do NOT modify the shared F1 interfaces (`file-system.ts`, `subprocess-runner.ts`, `prompt-mode-contract.ts`).
- Do NOT modify `.claude/rules/**` or `.github/instructions/**`.
- Do not weaken tests, lower coverage thresholds, or add production-path coverage excludes.
- Tests remain hermetic: no real subprocess, PATH/env reads, temp files, or real filesystem writes.
- Do NOT introduce a circular import between `io.ts` and `io-launcher.ts`.

## Evidence Location Invariant

All evidence artifacts MUST be written under `<FEATURE>/evidence/<kind>/`:
- Baseline: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/remediation-baseline/`
- QA gates: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/`
- Regression: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/regression-testing/`

Each command-step evidence artifact MUST include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage artifacts MUST record numeric line and branch coverage. Writing evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` is a policy violation; substitute the canonical path and record `EVIDENCE_LOCATION_OVERRIDE_REJECTED`.

---

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read repository policy files in required order per `policy-compliance-order`: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`. Write `evidence/remediation-baseline/phase0-instructions-read.2026-06-26T05-25.md` with `Timestamp:`, `Policy Order:`, and an explicit `Files Read:` list. Acceptance: artifact exists and lists every file read.

- [x] [P0-T2] Capture the baseline toolchain state from `extensions/drm-copilot/`: run `npx prettier --check "src/lib/new-active-feature-folder/**/*.ts" "test/lib/new-active-feature-folder/**/*.ts"`, `npm run lint`, `npm run typecheck`, and `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`, and record `wc -l src/lib/new-active-feature-folder/io.ts`. Write `evidence/remediation-baseline/baseline-toolchain.2026-06-26T05-25.md` with `Timestamp:`, `Command:` (each), `EXIT_CODE:` (each), and `Output Summary:` including the `io.ts` line count (expected 542) and numeric line/branch coverage for `src/lib/**` and for `io.ts`. Acceptance: artifact records all commands with exit codes and numeric values.

---

### Phase 1 — Extract the VS Code launcher seam

- [x] [P1-T1] Create `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts` and move the VS Code launcher seam from `io.ts` into it verbatim: the Insiders signal-name list (`INSIDERS_SIGNAL_NAMES` or equivalent), `isInsidersSession`, `resolveCodeCli`, `defaultCodeLauncher`, and any launcher-only private helpers and their docstrings/intent comments. Preserve every signal name, the `--reuse-window` arg vector, the posix-path mapping, the injectable env/which/runner seams, and all message strings character-for-character. Add a module docstring. Acceptance: `io-launcher.ts` < 500 lines; no behavior change; format/lint/typecheck pass.

- [x] [P1-T2] Update `io.ts` to remove the moved launcher code and re-export the launcher symbols from `io-launcher.ts` (e.g. `export { isInsidersSession, resolveCodeCli, defaultCodeLauncher, INSIDERS_SIGNAL_NAMES } from "./io-launcher";`) so that every prior import path — including `index.ts` and `flow.ts` — continues to resolve unchanged. Confirm no circular import is introduced (the launcher module must not import from `io.ts`; if shared helpers are needed, place them in `models.ts` or a small shared helper, not in `io.ts`). Acceptance: `io.ts` < 500 lines (`wc -l`); `index.ts` and `flow.ts` imports unchanged; format/lint/typecheck pass.

- [x] [P1-T3] If the existing launcher tests live in `test/lib/new-active-feature-folder/io.test.ts` and that file is at risk of staying coherent, move only the launcher-seam test cases into a new sibling `test/lib/new-active-feature-folder/io-launcher.test.ts` mirroring the production split (optional — only if it improves cohesion or is needed to keep a test file < 500 lines). Do not change any assertion. Acceptance: launcher-seam coverage is preserved; both test files < 500 lines.

---

### Phase 2 — Final QA Loop and AC re-check-off

- [x] [P2-T1] Run the full toolchain from `extensions/drm-copilot/` in order — `npx prettier --check ...`, `npm run lint`, `npm run typecheck`, `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` — restarting from format on any change/failure. Write `evidence/qa-gates/remediation-final-toolchain.2026-06-26T05-25.md` with `Timestamp:`, `Command:` (each), `EXIT_CODE:` (each), and `Output Summary:` recording: format clean; 0 lint errors; 0 type errors; 999 tests pass; `src/lib/**` line/branch coverage (no regression vs 97.73%/88.29%); `io.ts` and `io-launcher.ts` line/branch coverage; and `wc -l` for both files (< 500). Acceptance: all gates green; both files < 500 lines.

- [x] [P2-T2] Confirm scope containment: `git diff --name-only c432b69...HEAD` shows only the new `io-launcher.ts` (and any new `io-launcher.test.ts`), the edited `io.ts`, and the evidence artifacts beyond the original F8 change set; no prohibited path (Python sources, `command-runtime.ts`, `executeScript`, `repo-automation-args.ts`, F1 interfaces) is modified. Write `evidence/qa-gates/remediation-scope-verification.2026-06-26T05-25.md` with the four schema fields. Acceptance: change set matches the allowed list.

- [x] [P2-T3] Re-check-off the acceptance criteria in `plans/F8-new-active-feature-folder.plan.md`: confirm AC-F8-10 (no file > 500 lines) and the file-size portion of AC-F8-3 now hold, and ensure both are marked `[x]` only after the verification in P2-T1 passes. Acceptance: AC-F8-3 and AC-F8-10 are validly satisfied with evidence; no other AC checkbox altered.

---

## Exit Condition

Remediation is complete when:
- `io.ts` and `io-launcher.ts` are each < 500 lines (no production/test file exceeds 500 lines).
- Format, lint, typecheck pass; 999/999 tests pass; `src/lib/**` coverage shows no regression and the launcher seam retains line >= 85% / branch >= 75%.
- The change is behavior-preserving (no export/regex/message/`--json` change).
- AC-F8-3 and AC-F8-10 are re-satisfied with evidence; the blocking-finding count for the next review cycle is 0.
