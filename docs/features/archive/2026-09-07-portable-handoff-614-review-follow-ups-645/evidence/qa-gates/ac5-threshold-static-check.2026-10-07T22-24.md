# AC-5 Threshold Static Check (P6-T2)

Timestamp: 2026-10-07T22-24
Task: [P6-T2]
Command: read `extensions/drm-copilot/jest.config.cjs` (Python line scan for each key and the two following value lines); regex `(^|\s|")(global|coveragePathIgnorePatterns)"?\s*:` over the file; `git diff -U0 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- extensions/drm-copilot/jest.config.cjs`; `git diff --name-status 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- extensions/drm-copilot/src` and `git status --porcelain --untracked-files=all -- extensions/drm-copilot/src`
EXIT_CODE: 0
Output Summary: 14 of 14 keys found, each `lines: 85,` and `branches: 75,`. The global/coveragePathIgnorePatterns regex returned 0 matches. The jest.config diff is one insertion hunk `@@ -396,0 +397,57 @@` with no removed lines, so no existing entry changed. No new production `.ts` file under `extensions/drm-copilot/src/` (name-status lists only `M` entries; porcelain is empty), so no additional entry is required.

| Key | Line | Values |
|---|---|---|
| `./src/lib/validate/orchestration-handoff-authority-service.ts` | 398 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-checkout-context.ts` | 402 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-contract-support.ts` | 406 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-contract.ts` | 410 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-materializer-production.ts` | 414 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-materializer-request.ts` | 418 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-materializer-support.ts` | 422 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-materializer.ts` | 426 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-path-boundary.ts` | 430 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-provider-adapters.ts` | 434 | lines: 85, branches: 75 |
| `./src/lib/validate/orchestration-handoff-validation.ts` | 438 | lines: 85, branches: 75 |
| `./src/lib/validate/semantic-mcp-identity.ts` | 442 | lines: 85, branches: 75 |
| `./src/mcp-handlers/orchestration-handoff-handlers.ts` | 446 | lines: 85, branches: 75 |
| `./src/mcp-repo-automation-tool-definitions-handoff.ts` | 450 | lines: 85, branches: 75 |

Comment line at 397: `// Issue #645: the portable prepared-orchestration handoff production modules added by #614.`

## global / coveragePathIgnorePatterns search

SearchScope: `extensions/drm-copilot/jest.config.cjs`
SearchPatterns: `(^|\s|")(global|coveragePathIgnorePatterns)"?\s*:`
SearchResult: none

## New production files under src (Glob against the P0-T3 list)

`git diff --name-status` vs 08ee030d: 8 `M` entries (all pre-existing files); `git status --porcelain --untracked-files=all -- extensions/drm-copilot/src`: empty. New production files: none.

Result: PASS
