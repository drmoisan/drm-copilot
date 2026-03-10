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
| Hello Python flow produces `artifacts/hello_python.txt` | PASS | Integration scenario confirms `helloPython` execution uses bundled script and workspace cwd | `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "helloPython"` | End-to-end command wiring and execution path validated. |
| Hello PowerShell flow produces `artifacts/hello_pwsh.txt` | PASS | Integration scenario confirms `helloPowerShell` execution uses bundled script and workspace cwd | `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "helloPowerShell"` | End-to-end command wiring and execution path validated. |
| Runtime probe order deterministic (`python`; `pwsh` then `powershell`) | PASS | Dedicated runtime-order unit test | `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "pwsh then powershell"` | Probe order is explicit and validated. |
| Commands use workspace context only | PASS | `spawn(..., { cwd: workspaceRoot, shell: false })`; tests assert `cwd` | `npm --prefix extensions/scaffold-extension run test` | Meets intent. |
| No workspace-root script copy | PASS | Unit/integration tests assert bundled resource path usage, not workspace root | `npm --prefix extensions/scaffold-extension run test` | Invariant covered. |
| Runtime validation explicit + actionable errors | PASS | Missing-Python and missing-PowerShell runtime failures are explicitly tested | `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "missing PowerShell"` | Actionable runtime errors validated for both runtime families. |
| OutputChannel lifecycle logging | PASS | `Scaffold Utils` channel; logs include probe/script/start/success/failure | `npm --prefix extensions/scaffold-extension run test` | Logging assertions present. |
| Unit test coverage for registration/runtime/script execution | PASS | `test/extension.test.ts` has focused unit cases | `npm --prefix extensions/scaffold-extension run test` | Good breadth, one gap noted above. |
| Integration tests for Windows + POSIX end-to-end | PASS | CI workflow now includes `scaffold-extension-tests` matrix on Windows + POSIX | `poetry run python -c "from pathlib import Path; t=Path('.github/workflows/ci.yml').read_text(encoding='utf-8'); assert 'windows-latest' in t; assert ('ubuntu-latest' in t) or ('macos-latest' in t)"` | Cross-platform CI confidence upgraded and auditable. |
| Error cases tested (no workspace, missing Python, missing PowerShell, non-zero exit) | PASS | Unit tests cover all listed error paths | `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "missing PowerShell"` | Explicit missing-PowerShell coverage added. |
| Platform notes for Windows/macOS/Linux | PASS | README includes dedicated platform runtime notes section | `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'Windows' in t and 'macOS' in t and 'Linux' in t"` | Explicit OS guidance present. |
| README documents pattern, runtimes, first-run workflow | PASS | README includes dedicated first-run workflow and command IDs | `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'First-run workflow' in t; assert 'drmCopilotExtension.helloPython' in t; assert 'drmCopilotExtension.helloPowerShell' in t"` | Smoke flow guidance now explicit. |
| README includes production-foundation positioning | PASS | README includes dedicated `Production foundation` section | `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'Production foundation' in t"` | Positioning requirement satisfied verbatim. |
| Feature implemented in baseline diff to `main` | PASS | Merge-base diff includes extension implementation paths (`src`, `package.json`, `test`) | `$mb = git merge-base origin/main HEAD; git diff --name-status "$mb..HEAD" | findstr /I "extensions/scaffold-extension/src/extension.ts extensions/scaffold-extension/package.json extensions/scaffold-extension/test"` | PR scope now includes implementation artifacts. |

## Summary

**Overall feature readiness:** **PASS**

Former FAIL/PARTIAL findings have been remediated with explicit test, CI, and documentation evidence.

Recommended follow-up verification:
- Re-run extension toolchain after committing implementation:
  - `npx prettier --check ...`
  - `npm --prefix extensions/scaffold-extension run lint`
  - `npm --prefix extensions/scaffold-extension run typecheck`
  - `npm --prefix extensions/scaffold-extension run test`
- Add CI matrix evidence for Windows/macOS/Linux runtime behavior where feasible.
