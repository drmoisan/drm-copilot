# Remediation Inputs — F8 ts-new-active-feature-folder (Issue #240)

**Issue:** #240
**Feature:** F8 (ts-new-active-feature-folder)
**Work Mode:** full-feature
**Entry timestamp:** 2026-06-26T05-25
**Feature folder (`<FEATURE>`):** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base branch:** `main` (merge-base `c432b69a294ef17ace8b64964b6b0cafb22bd450`)
**Head:** `drm-copilot-wt-2026-06-25-22-10` @ HEAD

## Source Audit Artifacts (this cycle)

- Policy audit: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/policy-audit.2026-06-26T05-25.md`
- Code review: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/code-review.2026-06-26T05-25.md`
- Feature audit: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/feature-audit.2026-06-26T05-25.md`

## Finding Summary

The F8 port is functionally complete and passes format, lint, typecheck, and the full Jest suite (999/999; `src/lib/**` 97.73% line / 88.29% branch; every new executable cluster file line >= 97%, branch >= 83%). Exactly one Blocking remediation-required finding blocks PR readiness: a production file exceeds the 500-line hard limit. No functional/correctness defects were found.

## Enumerated Fix List

### R1 (Blocking, remediation-required) — File-size limit on `io.ts`

- **File:** `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts`
- **Problem:** The file is **542 lines** (`wc -l`). `.claude/rules/general-code-change.md` sets a hard 500-line limit on production code files, with no applicable exception. The F8 plan Split Strategy (line 55) and the P2-T1 task acceptance ("file < 500 lines") explicitly anticipated this and required extracting the VS Code launcher seam into a sibling module if `io.ts` exceeded 500 lines; that contingent split was not performed.
- **Expected behavior after fix:** `io.ts` and the extracted module are each < 500 lines; every public export of `io.ts` continues to be importable from `io.ts` (re-exported) and from `index.ts`; no observable behavior, regex, message string, or `--json` field list changes; all 999 tests continue to pass with thresholds met.
- **Suggested approach (planner may choose another that satisfies the limit):** Extract the VS Code launcher seam — `INSIDERS_SIGNAL_NAMES` (or the equivalent signal-name list), `isInsidersSession`, `resolveCodeCli`, `defaultCodeLauncher`, and any launcher-only private helpers — into a new module `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts`, then re-export those symbols from `io.ts` so existing imports (including `index.ts`) remain valid. This is exactly the split named in the plan Split Strategy and mirrors the contingent-split pattern used elsewhere in the cluster.
- **Verification commands (run from `extensions/drm-copilot/`):**
  - `wc -l src/lib/new-active-feature-folder/io.ts src/lib/new-active-feature-folder/io-launcher.ts` (each must report < 500)
  - `npx prettier --check "src/lib/new-active-feature-folder/**/*.ts" "test/lib/new-active-feature-folder/**/*.ts"`
  - `npm run lint`
  - `npm run typecheck`
  - `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (999 tests pass; `src/lib/**` line >= 85%, branch >= 75%; launcher-seam coverage maintained)
- **Acceptance-criterion impact:** Re-satisfies AC-F8-10 (currently FAIL / to be reverted to unchecked) and the file-size portion of AC-F8-3 (currently PARTIAL).

## Do-Not-Do List

- Do NOT modify `.claude/rules/**` or `.github/instructions/**` (no policy weakening). The 500-line limit stands.
- Do NOT change any public export name, signature, regex, message string, or the `gh --json` field list in the cluster; the split must be behavior-preserving.
- Do NOT modify `command-runtime.ts`, the `"python"` runtime branch, `executeScript`, `repo-automation-service-workflows.ts` (`buildNewActiveFeatureFolderOptions` body), or `repo-automation-args.ts` (F11 scope).
- Do NOT modify any Python `scripts/dev_tools/**`, `resources/scripts/dev_tools/**/*.py`, or `resources/templates/*.py` file (removal is F11).
- Do NOT modify the shared F1 interfaces `src/lib/file-system.ts`, `subprocess-runner.ts`, or `prompt-mode-contract.ts`.
- Do NOT lower coverage thresholds, add production-path coverage excludes, or weaken any test.
- Do NOT introduce real subprocess calls, real PATH/env reads, or real-filesystem temp files in tests (tests stay hermetic).
- Do NOT split a file in a way that creates another file over 500 lines or introduces a circular import.

## Out-of-Scope (record only, no action this cycle)

- Epic ACs AC-E1/AC-E3/AC-E4 are realized incrementally and complete at F11; not part of this remediation.
- AC-E5 CI green run: capture after the split when CI runs against the branch head (no workflow files changed; `modified-workflow-needs-green-run` does not fire).
- `user-story.md` absence is an epic-folder documentation note (the epic uses `initiative.md`); no code action.
- The `getEstTimestamp` naive-datetime divergence is an accepted, documented divergence; no action.
- The Jest-vs-Vitest divergence (D1) is an accepted, epic-level policy-reconciliation item; no per-feature action.
