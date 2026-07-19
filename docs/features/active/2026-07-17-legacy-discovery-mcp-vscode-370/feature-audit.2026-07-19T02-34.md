# Feature Audit: legacy-discovery-mcp-vscode (#370)

---

**Audit Date:** 2026-07-19
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370`
**Base Branch:** `epic/legacy-discovery-and-parity-integration`
**Head Branch:** `feature/legacy-discovery-mcp-vscode-370`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `epic/legacy-discovery-and-parity-integration` (merge-base commit `a6dd7d4591ef80f4d351cea4b0488ce08568286e`)
- **Head branch/commit:** `feature/legacy-discovery-mcp-vscode-370` (commit `9525dd0a529ff833f13c0c0bec8076794492d16e`)
- **Merge base:** `a6dd7d4591ef80f4d351cea4b0488ce08568286e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-07-19T02-29 against the merge-base)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/{baseline,qa-gates,other}/`
  - Additional evidence: independent reviewer toolchain re-run (Prettier check, ESLint, TSC, Jest coverage at head; see `policy-audit.2026-07-19T02-34.md` Section 7)
- **Feature folder used:** `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370`
- **Requirements source:** `spec.md` and `user-story.md` (both authoritative for `full-feature`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`; per the acceptance-criteria tracking rules the AC sources are `spec.md` and `user-story.md`.
- **Scope note:** The audit scope is the full branch diff against the merge-base (45 files, +4,422/−303). PR context artifacts were missing at review start and were regenerated with `python -m scripts.dev_tools.pr_context.collector --base a6dd7d45... --head HEAD`. Test/coverage verification used the documented non-dotted mirror because Jest cannot glob test files under the dotted `.claude/worktrees` checkout (environment quirk, recorded in `evidence/baseline/baseline-test-coverage.2026-07-19T00-40.md`; independently reproduced by this reviewer).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/spec.md` — primary source (`## Acceptance Criteria`, 11 checkbox items)
- `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md` — co-authoritative source (`## Acceptance Criteria`, 11 checkbox items, textually identical to spec.md)

### Acceptance criteria

The 11 criteria are identical in both source files; they are inventoried once and evaluated once, with both files tracked in the check-off section.

1. Seven discovery MCP tools are exposed — `validate_discovery_artifacts`, `run_discovery_init`, `run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer`, `run_discovery_scenario_generation`, `run_discovery_report` — and each satisfies all five touch-points: a `REPO_AUTOMATION_TOOLS` union entry in `repo-automation-tool-names.ts`; a tool definition with JSON-Schema-shaped `inputSchema` and `additionalProperties: false` in `mcp-repo-automation-tool-definitions.ts` plus an aligned base entry in `mcp-tool-definitions.ts`; a dispatch-switch case in `mcp-tools.ts`; a handler in `mcp-handlers/` paired with a `resolve<X>ToolInput` input resolver; and a service method on both the `RepoAutomationService` interface and `DefaultRepoAutomationService`.
2. Each service call invokes the workspace discovery CLI via a Python subprocess with the interpreter `-c` `module:function` argv shape — `[pythonExe, "-c", "import sys; from <module> import <function>; sys.exit(<function>())", ...cliArgs]` targeting the landed console-script entries — with `cwd = workspace_root`, reusing the existing `runCommandWithOutput` / `CommandExecutionError` semantics; no Python is bundled into the VSIX and no `.vscodeignore` or packaging change is made.
3. `RuntimeKind` in `runtime-detection.ts` is extended with a `"python"` kind and `detectRuntime` gains a Python interpreter probe, covered by tests for found and not-found cases.
4. The tool-name-to-CLI mapping (dotted module path, entry-function name, and CLI-arg composition per wrapped invocation, including the per-kind validate entries and the per-`report_type` report entries) is centralized in a single table module; no `dev.discovery.*` command logic is re-authored in TypeScript.
5. `run_discovery_report` exposes a required `report_type` enum exactly `["coverage", "parity", "completion"]` with report_type-aware required inputs validated by the resolver before any spawn (`input_path` for `coverage`/`parity`; `coverage_input` and `parity_input` for `completion`), and `validate_discovery_artifacts` exposes a required `artifact_type` enum exactly `["profile", "feature-contract", "coverage-ledger", "runtime-scenario", "parity-matrix", "unspecified-behavior", "product-decision", "evidence-reference", "all"]`; both enums are duplicated in the input resolvers and rejected values fail before any spawn.
6. Each of the seven tools is registered as a VS Code command: a `contributes.commands` entry in `extensions/drm-copilot/package.json` and a registration function in a dedicated discovery registration module called from `extension.ts` `activate`, with disposables pushed to `context.subscriptions`, supporting both direct-argument and interactive invocation.
7. The exposure layer is domain-neutral: no TaskMaster/TMW/Outlook/email/task-management-specific identifier appears in any tool name, command id, schema field, description, or implementation; domain specificity is supplied only via runtime arguments (e.g. the domain-profile path).
8. The landed-contract reconciliation is preserved in the implementation: the landed module/function names and flags are confined to the mapping table and enum constants module, and the helper's header doc comment records that the mapping targets the merged `dev.discovery.*` console-script entries and justifies the `-c` invocation mechanism (dotnet/vsto/init entries are not `python -m`-runnable; no Poetry-on-PATH dependency).
9. TypeScript Jest tests are mirrored under `extensions/drm-copilot/test/`, covering: definitions contract (union order, cross-file alignment, `additionalProperties: false`, enums), input resolvers, dispatch/handler routing per tool, service-call argv/cwd/error mapping with a faked spawn boundary, runtime detection, `mcp-server.test.ts` list/dispatch round-trips, and VS Code command harness tests.
10. Every new production file has a per-file `coverageThreshold` entry of `{ lines: 85, branches: 75 }` in `jest.config.cjs`, and `npm run test:coverage` passes with line coverage >= 85% and branch coverage >= 75% on all new files.
11. The full extension toolchain passes in `extensions/drm-copilot/`: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test`, `npm run test:coverage` (Jest 30 + ts-jest, v8 coverage).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Seven tools, five lockstep touch-points | PASS | Union: `repo-automation-tool-names.ts` lines 23–29 (seven appended entries). Definitions: `mcp-discovery-tool-definitions.ts` (seven `ToolDefinition`s, `additionalProperties: false` ×7 + fragment reuse) spread into both `mcp-repo-automation-tool-definitions.ts` (line 489) and `mcp-tool-definitions.ts` (line 436). Dispatch: seven `case` arms in `mcp-tools.ts` (exhaustive switch, no `default`). Handlers: `mcp-handlers/discovery-handlers.ts` (seven, each calling its resolver). Service: seven methods on the interface (`repo-automation-service-contract.ts` lines 154–174) and on `DefaultRepoAutomationService` (`repo-automation-service.ts` lines 384–426). | `git diff a6dd7d45..HEAD -- extensions/drm-copilot/src/`; `grep -n "run_discovery\|validate_discovery" src/repo-automation-tool-names.ts` | Cross-file alignment is structural (shared spread) and contract-tested (`test/mcp-repo-automation-tool-definitions.test.ts`). |
| 2 | Python `-c` subprocess, `cwd = workspace_root`, no bundling change | PASS | `executeDiscoveryServiceCall` builds `[...argsPrefix, "-c", "import sys; from <module> import <function>; sys.exit(<function>())", ...cliArgs]` and spawns via `runCommandWithOutput(output, executable, args, request.workspaceRoot)` (`repo-automation-execute-discovery.ts` lines 239–252); failures propagate as `CommandExecutionError`. No `.vscodeignore`, esbuild, or packaging file appears in the branch diff. | `git diff --name-only a6dd7d45..HEAD -- extensions/drm-copilot/.vscodeignore extensions/drm-copilot/esbuild-*.cjs` (empty) | Argv shape asserted per tool in `test/repo-automation-execute-discovery.test.ts` (21 tests). |
| 3 | `RuntimeKind` widened + Python probe with found/not-found tests | PASS | `export type RuntimeKind = "powershell" \| "python"`; `detectPythonRuntime` resolves workspace `.venv` → `py` → `python` and throws an explicit not-found error (`runtime-detection.ts` diff). Seven tests in `test/runtime-detection.test.ts` cover `.venv` hit, PATH fallbacks incl. PATHEXT, and the not-found message. | Reviewer jest run (mirror): 165/165 suites pass | Existing PowerShell probe behavior unchanged. |
| 4 | Central mapping table; no CLI logic re-authored | PASS | All module paths, entry functions (incl. the nine per-kind validate entries and three per-report_type entries), and arg composition are confined to `repo-automation-execute-discovery.ts` (lines 90–151 + per-tool builders). The wrapper transforms only argument and result shape; no discovery domain logic exists in TypeScript. | File inspection; `grep -rn "scripts.dev_tools" extensions/drm-copilot/src/` (matches only in the mapping module) | Upstream renames are single-line changes per the design intent. |
| 5 | Exact enums, resolver-enforced conditional inputs, reject-before-spawn | PASS | `DISCOVERY_REPORT_TYPES = ["coverage","parity","completion"]` and `DISCOVERY_ARTIFACT_TYPES` with the exact nine values (`mcp-tool-inputs-discovery.ts` lines 25–41); schemas consume the same constants (`mcp-discovery-tool-definitions.ts` lines 29, 182), so duplication cannot drift. `resolveRunDiscoveryReportToolInput` requires `input_path` vs `coverage_input`+`parity_input` by `report_type` before any service/spawn work. | `test/mcp-tool-inputs-discovery.test.ts` (23 tests incl. out-of-enum and per-report_type missing-field rejections); `test/mcp-server.discovery.test.ts` invalid-enum round-trip | Rejection paths verified to occur with zero service calls (mock assertions). |
| 6 | Seven VS Code commands, dedicated module, disposables, dual invocation | PASS | Seven `contributes.commands` entries in `package.json` (diff lines 168–198); `registerDiscoveryCommands` in `discovery-command-registration.ts` returns seven disposables; `extension.ts` `activate` calls it and pushes `...discoveryDisposables` to `context.subscriptions`; each command supports direct-args (resolver path) and interactive prompts. | `test/extension.discovery-commands.test.ts` (16 tests, both paths incl. cancel) | Analyzer commands run interactively with workspace defaults (optional fields), a documented intentional choice. |
| 7 | Domain neutrality | PASS | Case-insensitive grep for `taskmaster\|tmw\|outlook\|email\|task-management` over all new/modified exposure-layer files: zero matches (executor evidence `evidence/qa-gates/domain-neutrality.2026-07-19T02-10.md`; independently re-run by reviewer over the six new modules + runtime-detection, exit 1 = no matches). "dotnet"/"vsto" name analyzed technology stacks per the epic's naming, not a consumer domain. | `grep -rniE "taskmaster\|tmw\|outlook\|email\|task-management" <new modules>` | Domain specificity arrives only via runtime arguments (profile paths). |
| 8 | Reconciliation preserved; header doc comment | PASS | The header comment of `repo-automation-execute-discovery.ts` (lines 10–35) records the merged waves 0/1/2 target, the `pyproject.toml [tool.poetry.scripts]` verification, and the `-c` justification (no `__main__` guard on dotnet/vsto/init; no Poetry-on-PATH dependency). Landed names/flags appear only in the mapping table and the enum constants module. | File inspection; `evidence/other/plan-reconciliation.2026-07-19T00-15.md` | Matches the spec's Substrate correction section. |
| 9 | Jest tests mirrored under `test/` with the enumerated coverage areas | PASS | New/extended files: `runtime-detection.test.ts`, `repo-automation-execute-discovery.test.ts`, `repo-automation-service.discovery.test.ts`, `mcp-tool-inputs-discovery.test.ts`, `mcp-tools.discovery.test.ts`, `extension.discovery-commands.test.ts`, `mcp-server.discovery.test.ts`, extended `mcp-repo-automation-tool-definitions.test.ts` and `mcp-server.test.ts` (listTools union), plus widened mock-service builders in three sibling suites. All enumerated areas covered (definitions contract, resolvers, dispatch/handlers, service argv/cwd/error with faked spawn, runtime detection, MCP round-trips, VS Code harness). | Reviewer jest run: 165 suites / 2006 tests pass | The MCP round-trip suite lives in the sibling `mcp-server.discovery.test.ts` (extracted to respect the 500-line cap; rationale in `evidence/qa-gates/file-size-audit.2026-07-19T02-10.md`). |
| 10 | Per-file `coverageThreshold` `{lines:85, branches:75}`; coverage passes on all new files | PASS | `jest.config.cjs` has entries for the five executable new files plus modified `runtime-detection.ts`/`mcp-tools.ts`/`repo-automation-service.ts` etc.; the type-only `repo-automation-service-contract.ts` is omitted from the gate under the interface-only policy clarification with an inline justification comment (it remains measured in `collectCoverageFrom`). Reviewer-verified per-file coverage at head: lowest gated new file `discovery-command-registration.ts` at 90.66%/78.18%; all gated files >= 85/75. | `node run-jest.cjs --coverage ...` exit 0 (thresholds enforced); reviewer lcov parse of `coverage/lcov.info` | Threshold enforcement is active: a per-file miss fails the run (exit non-zero), and the run exits 0. |
| 11 | Full toolchain passes | PASS | Independent reviewer re-run at head `9525dd0a`: Prettier `--check` clean; `npm run lint` exit 0; `npm run typecheck` exit 0; jest coverage run 165/2006 pass exit 0 (non-dotted mirror, byte-identical config). Executor final-QC artifacts record the same results (`evidence/qa-gates/final-qc-*.2026-07-19T02-20.md`, single-pass loop). | See `policy-audit.2026-07-19T02-34.md` Section 7 for exact commands | Test/coverage stage executed in the documented non-dotted mirror due to the jest dotted-path glob limitation (environment quirk, not a code defect). |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 11 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional (post-merge hardening): replace the `?? ""` fallbacks in `runDiscoveryReport` with explicit missing-field errors (Minor finding in `code-review.2026-07-19T02-34.md`).
2. At PR time, confirm CI (non-dotted checkout) runs the jest suite directly, closing the loop on the worktree-only discovery limitation.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All 11 criteria were already checked off (`- [x]`) in both `spec.md` and `user-story.md` by the executor during plan execution, with per-task verification evidence in the feature folder.
- This audit independently confirms every checked item as PASS; **no source-file checkbox change was needed or made** (all items were already `[x]`, and reviewers do not re-modify verified check-offs).

### AC Status Summary

- Source: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md`
- Total AC items: 11 per source file (22 checkbox instances across the two files; identical text)
- Checked off (delivered): 11 per source file
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 11 | 11 | 0 | Checkbox-backed; all pre-checked by executor, confirmed by this audit |
| `user-story.md` | 11 | 11 | 0 | Checkbox-backed; identical text to spec.md; all pre-checked, confirmed |
