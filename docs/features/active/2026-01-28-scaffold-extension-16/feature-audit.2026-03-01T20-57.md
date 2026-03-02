# Feature Audit — scaffold-extension (Issue #16)

## Scope and Baseline

- **Base branch:** `main`
- **PR context summary:** `artifacts/pr_context.summary.txt`
- **PR context appendix:** `artifacts/pr_context.appendix.txt`
- **Feature folder:** `docs/features/active/2026-01-28-scaffold-extension-16`
- **Work mode marker:** Fallback to `full` behavior (no exact `- Work Mode: ...` marker line in `issue.md`; YAML `work_mode: full` present but marker contract requires fail-closed behavior).

## Acceptance Criteria Inventory (authoritative)

Primary source: PR context summary acceptance-criteria block for `2026-01-28-scaffold-extension-16` (matches `issue.md`/`user-story.md`).

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| Manifest + entrypoint present and functional | PASS | `extensions/scaffold-extension/package.json`, `src/extension.ts`; tests pass | `npm --prefix extensions/scaffold-extension run test` | Command IDs present and registered. |
| Hello Python flow produces `artifacts/hello_python.txt` | PARTIAL | Orchestration path validated by tests; bundled script writes artifact marker | `npm --prefix extensions/scaffold-extension run test` | Test asserts spawn args/cwd, not real file creation in runtime environment. |
| Hello PowerShell flow produces `artifacts/hello_pwsh.txt` | PARTIAL | Same as above | `npm --prefix extensions/scaffold-extension run test` | Real artifact creation not asserted by non-mocked integration. |
| Runtime probe order deterministic (`python`; `pwsh` then `powershell`) | PASS | `detectRuntime` logic and unit test for pwsh preference | `npm --prefix extensions/scaffold-extension run test` | Missing explicit fallback-to-`powershell` assertion still acceptable for order preference but should be improved. |
| Commands use workspace context only | PASS | `spawn(..., { cwd: workspaceRoot, shell: false })`; tests assert `cwd` | `npm --prefix extensions/scaffold-extension run test` | Meets intent. |
| No workspace-root script copy | PASS | Unit/integration tests assert bundled resource path usage, not workspace root | `npm --prefix extensions/scaffold-extension run test` | Invariant covered. |
| Runtime validation explicit + actionable errors | PARTIAL | Python missing-runtime case covered; PowerShell missing-runtime not explicitly tested | `npm --prefix extensions/scaffold-extension run test` | Add explicit missing-PowerShell test. |
| OutputChannel lifecycle logging | PASS | `Scaffold Utils` channel; logs include probe/script/start/success/failure | `npm --prefix extensions/scaffold-extension run test` | Logging assertions present. |
| Unit test coverage for registration/runtime/script execution | PASS | `test/extension.test.ts` has focused unit cases | `npm --prefix extensions/scaffold-extension run test` | Good breadth, one gap noted above. |
| Integration tests for Windows + POSIX end-to-end | PARTIAL | `extension.integration.test.ts` exists but is mock-driven | `npm --prefix extensions/scaffold-extension run test` | Does not provide true OS-matrix E2E confidence. |
| Error cases tested (no workspace, missing Python, missing PowerShell, non-zero exit) | PARTIAL | no workspace + missing Python + non-zero exit covered | `npm --prefix extensions/scaffold-extension run test` | Missing explicit missing-PowerShell test. |
| Platform notes for Windows/macOS/Linux | PARTIAL | README lists runtime names but lacks explicit per-OS expectations | Inspect `extensions/scaffold-extension/README.md` | Needs explicit platform note section. |
| README documents pattern, runtimes, first-run workflow | PARTIAL | Pattern and runtimes documented | Inspect README | First-run workflow steps are minimal/incomplete. |
| README includes production-foundation positioning | PARTIAL | Intro implies intent | Inspect README | Add explicit dedicated section to satisfy AC verbatim. |
| Feature implemented in baseline diff to `main` | FAIL | PR range shows docs-only for this feature; implementation untracked | `git diff --name-status origin/main...HEAD`; `git status --short` | Merge readiness blocker. |

## Summary

**Overall feature readiness:** **NEEDS REVISION**

Top gaps preventing PASS:
1. Implementation files are not committed into the `main...HEAD` PR range (blocker).
2. Missing explicit missing-PowerShell runtime test case.
3. Integration evidence is not true cross-platform E2E.
4. README lacks full platform notes + explicit production-foundation section.

Recommended follow-up verification:
- Re-run extension toolchain after committing implementation:
  - `npx prettier --check ...`
  - `npm --prefix extensions/scaffold-extension run lint`
  - `npm --prefix extensions/scaffold-extension run typecheck`
  - `npm --prefix extensions/scaffold-extension run test`
- Add CI matrix evidence for Windows/macOS/Linux runtime behavior where feasible.
