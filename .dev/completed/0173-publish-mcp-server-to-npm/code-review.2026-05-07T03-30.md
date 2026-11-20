# Code Review: publish-mcp-server-to-npm (#173)

---

**Review Date:** 2026-05-07  
**Reviewer:** feature_code_review_agent  
**Feature Folder:** `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173`  
**Feature Folder Selection Rule:** Matched issue number 173 in branch name and scoping docs.  
**Base Branch:** `chore/publish-to-marketplace` (commit `a852089b`)  
**Head Branch:** `feature/publish-mcp-server-to-npm-173` (commit `335c72b6`)  
**Review Type:** Initial review

---

## Executive Summary

This feature adds a standalone npm distribution package for the drm-copilot MCP server. The change introduces `packages/mcp-server/` (7 new files), `.github/workflows/publish-mcp-npm.yml`, a root-level `LICENSE` file, and feature documentation. One commit in range: `335c72b` (`feat(mcp-server): publish MCP server as npm package`). No TypeScript source files were added or modified.

The implementation is technically sound: `package.json` has correct npm metadata, the esbuild configuration properly injects the shebang and shims vscode, the `prepack` script copies resources at pack time, and the publish workflow gates publication on extension tests. The license file resolves the pre-existing docs-validation CI failure.

One major finding requires remediation before the PR is ready: `packages/mcp-server/README.md` omits the `cwd` field from the MCP client configuration snippet. This is explicitly required by the spec and user-story and is functionally necessary for correct consumer setup.

**What changed:**  
Seven new files in `packages/mcp-server/`, one new GitHub Actions workflow, one new root-level LICENSE, and five feature documentation files. Minor agent/skill customizations in `.github/agents/` and `.github/skills/`. 1315 lines added, 13 deleted.

**Top 3 risks:**
1. README.md is missing `cwd` in the MCP config snippet — consumers who follow the documented config will not set `cwd`, causing workspace-relative tool calls to resolve against the wrong directory.
2. `actionlint` was not run against `publish-mcp-npm.yml` in the review environment; GitHub Actions-specific linting issues cannot be ruled out.
3. Version synchronization between `packages/mcp-server/package.json` and `extensions/drm-copilot/package.json` is manual; no automation guards against drift at tag time.

**PR readiness recommendation:** **Needs Revision** — one major finding (README missing `cwd`) must be corrected before this feature is complete against its acceptance criteria and spec.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `packages/mcp-server/README.md` | MCP Client Configuration section | MCP config snippet omits required `cwd` field. The spec (`spec.md` API/CLI Surface) and user-story (Scenario: First-Time Setup) both specify `"cwd": "/absolute/path/to/workspace"` as a required field. Without it, consumers will not configure `cwd` and workspace-relative tool calls will resolve to the wrong directory. | Add `"cwd": "/absolute/path/to/your/workspace"` to the config snippet, with a note that this value must be set to the consumer's target workspace root. | The MCP server resolves `workspace_root` from `process.cwd()` when not supplied by the tool caller. The MCP client configuration must set `cwd` to the consumer's workspace so tool calls operate on the correct files. Omitting it from the README creates a functional misconfiguration risk for every consumer. | `spec.md` lines 78–87 (API/CLI Surface); `user-story.md` lines 34–41 (Scenario: First-Time Setup); `packages/mcp-server/README.md` lines 18–26. |
| Minor | `packages/mcp-server/esbuild-mcp-server.cjs` | `esbuild.build()` call | `format` option not explicitly set. The esbuild config sets `platform: "node"` and `outfile: "out/mcp-server.js"`. The default format for `platform: "node"` in esbuild is CJS, which matches `"type": "commonjs"` in package.json. Not specifying `format: "cjs"` explicitly creates a subtle dependency on esbuild's default behavior. | Add `format: "cjs"` to the esbuild build call for explicit, self-documenting output format declaration. | Relying on an implicit default creates future maintenance risk if the esbuild default ever changes or if someone reads the build script without reference to esbuild docs. The fix is a one-line addition with no behavioral change. | `packages/mcp-server/esbuild-mcp-server.cjs` lines 27–38; esbuild documentation (default format for platform:node is "cjs"). |
| Info | `.github/workflows/publish-mcp-npm.yml` | `drm-copilot-extension-tests` job | Extension tests job is duplicated inline in the publish workflow rather than referencing `ci.yml`. This is structurally necessary because `ci.yml` does not expose a `workflow_call` trigger; GitHub Actions cannot reference jobs across workflow files without that trigger. | No immediate change required. Consider adding `workflow_call` to `ci.yml` in a future maintenance cycle to eliminate this duplication. | This was acknowledged in `plan.2026-05-06T21-36.md` (Open Questions section). The duplication creates a maintenance liability: changes to the extension test steps in `ci.yml` must also be applied to `publish-mcp-npm.yml` manually. | `plan.2026-05-06T21-36.md`, Open Questions; `.github/workflows/ci.yml` lines 295–320; `.github/workflows/publish-mcp-npm.yml` lines 11–29. |
| Info | `.github/workflows/publish-mcp-npm.yml` | All | `actionlint` validation not performed. The GitHub Actions policy requires workflow files to pass `actionlint`. YAML structural validity was confirmed via `yaml.safe_load` but actionlint-specific checks (step name syntax, expression syntax, runner label validity) were not run. | Run `scripts/dev-tools/run-actionlint.ps1` before merging. The CI `actionlint` job in `ci.yml` should also catch this if it covers new workflow files. | Policy compliance gap. Low risk given the workflow is straightforward, but the requirement exists. | `.github/instructions/github-actions.instructions.md`; `scripts/dev-tools/run-actionlint.ps1`. |
| Info | `packages/mcp-server/package.json` | `scripts.prepack` | The `prepack` lifecycle script performs a `cpSync` with no error handling observable at the npm level. If `../../extensions/drm-copilot/resources` does not exist, the script will throw and abort the pack/publish. This is acceptable behavior (fail-fast), but there is no explicit error message to guide the user. | Acceptable as-is. Optionally, wrap in a `try/catch` that prints a diagnostic message before re-throwing. | Not a blocker. The CI workflow runs `npm run prepack` explicitly and would surface the error at that step. | `packages/mcp-server/package.json` line 18. |

---

## Implementation Audit

### TypeScript implementation audit

No new TypeScript source files were introduced. The TypeScript toolchain was run against `extensions/drm-copilot/` as a regression guard. All four toolchain steps (Prettier, ESLint, TSC, Jest) pass without errors or warnings.

`packages/mcp-server/tsconfig.json` extends `../../extensions/drm-copilot/tsconfig.json` and includes `../../extensions/drm-copilot/src`. This is a read-only IDE navigation configuration with no compilation artifacts produced by it directly. It is correct and minimal.

### CJS build script implementation audit (`esbuild-mcp-server.cjs`)

#### What changed well

- The vscode shim plugin is retained verbatim from the extension's build script. The rationale for its presence is documented in the JSDoc header ("unreachable from the MCP execution path but present in the module graph").
- `allowOverwrite: true` prevents unnecessary clean steps between builds.
- `.catch(() => process.exit(1))` ensures esbuild failures propagate as a non-zero process exit, which correctly aborts CI steps.
- The `tsconfig` field is explicitly set to `../../extensions/drm-copilot/tsconfig.json`, ensuring consistent resolution of the extension's TypeScript configuration.

#### Type safety and maintainability

Not applicable — this is a CommonJS build script, not a TypeScript source file.

#### Error handling

Explicit `.catch(() => process.exit(1))` terminates the process with a non-zero code on build failure. This is the correct pattern for esbuild invocations in CI. One minor improvement would be a logged error message before exit, but the error is surfaced by esbuild's own stderr output.

### GitHub Actions workflow audit (`.github/workflows/publish-mcp-npm.yml`)

#### What changed well

- Trigger is scoped narrowly to `mcp-server-v*` tag pushes, preventing accidental publication on branch pushes.
- `publish` job correctly declares `needs: drm-copilot-extension-tests`, enforcing the quality gate.
- `registry-url: https://registry.npmjs.org` with `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` is the correct pattern for actions/setup-node-managed npm authentication.
- The `prepack` step is run explicitly as a separate step before `build`, which makes the resource copy visible and debuggable in CI logs.
- Matrix runs on `[ubuntu-latest, windows-latest]` provide cross-platform test coverage for the extension tests.

#### API and safety notes

- `NODE_AUTH_TOKEN` is used as the env variable name (not `NPM_TOKEN` directly), which is correct for the actions/setup-node npm authentication pattern.
- No hardcoded credentials. The NPM_TOKEN is referenced only via `${{ secrets.NPM_TOKEN }}`.

---

## Test Quality Audit

This feature does not introduce new automated tests. The test quality audit covers regression evidence only.

### Reviewed test and QA artifacts

- `artifacts/evidence/post-change/jest-qc.md` — 348 tests pass, exit code 0. Confirms no regression in the existing extension test suite.
- `artifacts/evidence/post-change/prettier-qc.md` — No files reformatted. Exit code 0.
- `artifacts/evidence/post-change/eslint-qc.md` — No lint errors or warnings. Exit code 0.
- `artifacts/evidence/post-change/typecheck-qc.md` — No type errors. Exit code 0.
- `artifacts/evidence/post-change/npm-pack-listing.md` — Tarball produced. `out/mcp-server.js` and `resources/` entries present. Exit code 0.
- `artifacts/evidence/post-change/npm-publish-dry-run.md` — Dry run pass. Package `@danmoisan/drm-copilot-mcp@0.0.1` confirmed. Exit code 0.
- `artifacts/evidence/post-change/coverage-comparison.md` — Coverage unchanged at 95.5% lines (0% delta). Threshold satisfied.

### Quality assessment prompts

- **Determinism:** Existing tests use mocks and stubs; no external I/O. Coverage is identical across baseline and post-change runs.
- **Isolation:** No new tests to assess.
- **Speed:** 348 tests complete within normal CI bounds. No new slow tests added.
- **Diagnostics:** Not applicable — no new tests added.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | `NPM_TOKEN` referenced only as `${{ secrets.NPM_TOKEN }}` in workflow env. No hardcoded credentials in any file. |
| No unsafe subprocess or command construction | ✅ PASS | No shell construction of dynamic commands. `esbuild-mcp-server.cjs` uses the esbuild Node.js API directly; no child process or shell string concatenation. `prepack` uses Node.js `fs.cpSync` directly. |
| Input validation at boundaries | ✅ N/A | No user-facing input handling introduced. |
| Error handling remains explicit | ✅ PASS | Build script `.catch(() => process.exit(1))`. `prepack` script will throw on `cpSync` failure. GitHub Actions steps propagate non-zero exit codes by default. |
