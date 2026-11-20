# Research: MCP Promotion Tooling Defects (Issue #401)

- Timestamp: 2026-07-22T10-20
- Issue: #401
- Feature: docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401
- Scope: research only; no production source or test changes made.
- All findings below were verified by reading the cited files in this worktree.

---

## Defect A — `workspace_root` default resolution under worktree isolation

### 1. Root cause (exact locations)

Three cooperating code paths, all verified:

1. **`extensions/drm-copilot/src/workflow-command-arguments.ts`, `normalizeWorkspaceRoot`, lines 275-284.** The function signature is `normalizeWorkspaceRoot(value: unknown, fallbackWorkspaceRoot: string = process.cwd())`. When `workspace_root` is omitted (`value === undefined`) the function returns the fallback, and the fallback default parameter is `process.cwd()` of the long-running MCP server process. This is the single shared default for every tool.

2. **`extensions/drm-copilot/src/mcp-tool-inputs.ts` (and siblings).** Every per-tool resolver (`resolvePotentialToIssueToolInput` lines 316-336, `resolveNewPotentialBugEntryToolInput` lines 261-276, `resolveNewPotentialEntryToolInput` 278-293, `resolveNewActiveFeatureFolderToolInput` 338-359, `resolveCollectCommitContextToolInput` 126-137, `resolveCollectPrContextToolInput` 139-151, `resolveRunCodexNativeConverterToolInput` 153-246, `resolveLinkParentChildToolInput` 295-314, `resolvePolicyAuditTemplateAssetToolInput` 389-416, `resolveRunPoshQCSuiteToolInput` 418-446, `resolveValidateOrchestrationArtifactsToolInput` 459-498, `resolveResolveExecuteHardLockPromptToolInput` 361-373, `resolveResolveAtomicPlanPromptToolInput` 375-387) accepts an optional `fallbackWorkspaceRoot?: string` second parameter — **and every MCP handler calls the resolver without it** (`extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts` lines 16, 24, 32, 40; the same pattern in the other `mcp-handlers/*` files), so the `process.cwd()` default in `normalizeWorkspaceRoot` always applies for MCP calls. The same pattern repeats in `mcp-tool-inputs-push-down.ts` (lines 80, 99), `mcp-tool-inputs-discovery.ts` (lines 84, 110, 137, 182, 222-224), and `mcp-tool-inputs-subagent-tree.ts` (line 37).

3. **`extensions/drm-copilot/src/mcp-tools.ts`, `inferWorkspaceRoot`, lines 73-86** (line 79 `return process.cwd();`, line 85 `normalizeWorkspaceRoot(workspaceRoot, process.cwd())`). This helper is used only to echo `workspace_root` in the *failure* result envelope (`toFailureToolResult`, lines 110-123); the per-tool defaulting happens in item 1/2 above. Both paths share the same wrong default.

**Secondary root cause — `potential_path` resolution.** `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` line 309 calls `filesystem.resolvePath(options.potentialPath)`, and `RealPotentialFileSystem.resolvePath` (`extensions/drm-copilot/src/lib/potential-to-issue/promotion-filesystem.ts`, lines 57-64) is `nodePath.resolve(expanded)`, which resolves a relative path against **`process.cwd()` of the server process — never against the supplied `workspace_root`**. The `workspace` option in `promotePotential` (promotion.ts line 299, 328, 425-430) is used only for (a) the relative footer path and (b) the promoted-folder destination — not for locating the input file.

### Explanation of both empirical observations

- **Relative `potential_path` failed ("Potential file not found") while absolute succeeded, even with explicit `workspace_root`:** the relative path was resolved by `nodePath.resolve` against the server's `process.cwd()` (the main checkout), where the file does not exist; `promotePotential` then throws the not-found `PromotionError` (promotion.ts lines 311-315). `workspace_root` never participates in input-path resolution. Note the tool schema description promises otherwise: `mcp-repo-automation-tool-definitions.ts` line 205 documents `potential_path` as "Absolute or workspace-relative path" — the implementation violates its own contract.
- **Every promotion tool needed an explicit `workspace_root` to avoid writing into the main checkout:** the MCP server is launched from `.mcp.json` (`npx -y @danmoisan/drm-copilot-mcp`) with cwd = the directory in which the Claude Code session started (the main checkout). Omitting `workspace_root` therefore silently targets the main checkout: for example `promotePotential` computes `promotedDir = posixJoin(workspacePath, "docs/features/potential/promoted")` (promotion.ts lines 425-431) and moves the file there with no error.

### 2. Complete list of affected MCP tools

All 28 tools in `REPO_AUTOMATION_TOOLS` (`extensions/drm-copilot/src/repo-automation-tool-names.ts`) accept `workspace_root` as an **optional** schema property (`workspaceRootProperty`, `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts` lines 1-4, whose description literally states "Defaults to process.cwd() when omitted"), and all of them route through `normalizeWorkspaceRoot` with no fallback supplied:

collect_commit_context, collect_pr_context, run_codex_native_converter, push_down_copilot_customizations, push_down_codex_and_agents_customizations, push_down_claude_customizations, new_potential_bug_entry, new_potential_entry, link_parent_child, potential_to_issue, new_active_feature_folder, run_poshqc_format, run_poshqc_analyze, run_poshqc_test, run_poshqc_analyze_autofix, run_poshqc_suite, resolve_policy_audit_template_asset, resolve_execute_hard_lock_prompt, resolve_atomic_plan_prompt, validate_orchestration_artifacts, render_subagent_tree, validate_discovery_artifacts, run_discovery_init, run_discovery_repo_inventory, run_discovery_dotnet_analyzer, run_discovery_vsto_analyzer, run_discovery_scenario_generation, run_discovery_report.

Workspace-**writing** tools (highest severity — silent misdirected writes): new_potential_bug_entry, new_potential_entry, potential_to_issue, new_active_feature_folder, all three push_down_* tools, run_codex_native_converter (apply mode), collect_commit_context / collect_pr_context (artifact writers), run_poshqc_* (artifact writers), resolve_policy_audit_template_asset (asset copy), resolve_execute_hard_lock_prompt / resolve_atomic_plan_prompt (prompt outputs), run_discovery_* (artifact writers). Read-oriented tools (validate_orchestration_artifacts, validate_discovery_artifacts, render_subagent_tree) return wrong-checkout answers rather than misdirected writes.

Path inputs that resolve against `process.cwd()`:
- `workspace_root` itself (when omitted) — all 28 tools.
- `potential_to_issue.potential_path` — via `RealPotentialFileSystem.resolvePath` (always, even when `workspace_root` is supplied).
- By contrast, `run_codex_native_converter.source_root/destination_root/artifact_root` and `resolve_policy_audit_template_asset.target_path` are correctly resolved against `workspaceRoot` via `normalizeWorkspaceDestinationPath` (workflow-command-arguments.ts lines 290-300) — this existing helper is the model for the `potential_path` fix.

### 3. Decisive design question: can the server auto-detect the caller's worktree?

**No reliable per-call signal exists.** Verified facts:

- The server is one long-running stdio process per session (`extensions/drm-copilot/src/mcp-server.ts`, `main()` lines 123-127), spawned via `.mcp.json` with env and cwd fixed at launch. Multiple concurrently running worktree-isolated agents share this single process, so **no process-level state (env var, cwd) can identify the caller of an individual request.**
- The `CallToolRequest` handler (mcp-server.ts lines 91-113) reads only `request.params.name` and `request.params.arguments`. The MCP protocol's per-call `_meta` field is available in principle, but Claude Code does not populate a caller-working-directory field in it, and the server has no code to read one. Building on an undocumented `_meta` field would be speculative.
- The MCP `roots` capability is session-scoped (client advertises workspace roots), not per-call; even if implemented, it cannot attribute a specific call to a specific worktree when several worktree agents share the session.
- Git worktree discovery (`git worktree list` from the server cwd) enumerates candidate worktrees but provides no signal for *which* worktree issued the call. Any heuristic (most recent worktree, single-worktree shortcut) is nondeterministic under concurrent agents and would convert silent misdirection into intermittent misdirection.

**Conclusion: auto-detection is not possible; the fix must fail closed.**

### 4. Recommended fix strategy (Defect A)

**Make `workspace_root` effectively required for MCP calls, and resolve `potential_path` against it.** Concretely:

1. In `mcp-repo-automation-tool-definitions.ts` (and `mcp-discovery-tool-definitions.ts`), add `"workspace_root"` to every tool's `required` array, and rewrite `workspaceRootProperty.description` (mcp-push-down-schema-properties.ts) to state that the absolute root of the target checkout/worktree is required (removing the "Defaults to process.cwd()" text).
2. In `workflow-command-arguments.ts`, change `normalizeWorkspaceRoot` so that when `value === undefined` **and no explicit `fallbackWorkspaceRoot` argument was supplied**, it throws a clear error (e.g. `"workspace_root is required. The MCP server cannot infer the calling agent's checkout; pass the absolute worktree root explicitly."`) instead of silently returning `process.cwd()`. Keep the two-argument signature: the VS Code extension command surface (`extension.ts`) resolves its own `getWorkspaceRoot()` from the VS Code workspace folder and passes it explicitly, so that trusted host context is unaffected; MCP handlers simply continue to pass nothing, which now fails closed.
3. In `resolvePotentialToIssueToolInput` (mcp-tool-inputs.ts lines 316-336), resolve `potential_path` with the existing `normalizeWorkspaceDestinationPath(potentialPath, workspaceRoot, "potential_path")` helper before it reaches `promotePotential`, making the schema's "Absolute or workspace-relative" description true. Doing this in the resolver layer deliberately avoids touching the parity-bound `promotion.ts` / `promotion-filesystem.ts` (see parity notes).

**Rationale:** fail-closed is the only option that makes silent misdirection impossible (the issue's stated expected behavior); it is a schema-level change visible to callers via the advertised `inputSchema`, and the error message is actionable.

**Backward-compatibility impact:**
- MCP callers that previously omitted `workspace_root` now receive a structured `ok: false` error result instead of a silent wrong-checkout write. This is the intended behavior change. Any repository skills/agent docs that instruct calling these tools without `workspace_root` need a doc sweep.
- Existing tests asserting the fallback (e.g. `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` — "uses fallback when workspace_root is missing" line 254, "falls back to the provided workspace root when workspace_root is omitted" line 50, and the analogous cases across the input-resolver test files) must be inverted to assert the thrown error for the no-fallback case, while keeping the explicit-fallback cases (extension command surface) green.
- The VS Code command surface is unaffected: it never relies on the resolver default (verified: `extension.ts` passes `workspaceRoot: getWorkspaceRoot()` directly into service calls).

**Workspace-root parity constraints:** `workflow-command-arguments.ts`, `mcp-tool-inputs*.ts`, and the tool-definition files are TypeScript-native (no Python parity docstring). The Python CLI `scripts/dev_tools/potential_to_issue.py` defaults its workspace to the script's repo root (`Path(__file__).resolve().parents[2]`, line 327) — a correct default in its CLI context — so **no Python lockstep change is required for Defect A** as long as the fix stays out of `promotion.ts`/`promotion-filesystem.ts`. If the implementer instead changed `RealPotentialFileSystem.resolvePath` semantics, that would break the documented mirror of Python `Path(...).expanduser().resolve()` (promotion-filesystem.ts lines 50-64) and force a lockstep Python change; the resolver-layer fix avoids this.

---

## Defect B — `potential_to_issue` section-heading mapping produces placeholder issue bodies

### 1. Root cause (exact locations)

- **`extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`, `buildIssueBody`, lines 201-262.** The decision order is: (1) `selectedMode === "minor-audit"` → `buildMinorAuditBody` (lines 208-234), (2) `promotionType === "bug"` → `buildBugBody` (lines 237-243), (3) default → `buildBody` (lines 246-261). Because the minor-audit branch precedes the bug branch, **a bug potential promoted with `work_mode=minor-audit` is routed to `buildMinorAuditBody`**, whose `getSection` reads (`Problem / Why`, `Proposed Behavior`, `Acceptance Criteria (early draft)`, `Constraints & Risks`, `Test Conditions to Consider`) match **none** of the bug template's headings, so every section falls back to `PLACEHOLDER` (`content.ts` line 24, `"(not provided in potential file)"`). Only the Evidence Checklist gets its default three-line block (promotion.ts lines 219-223).
- **`extensions/drm-copilot/src/lib/potential-to-issue/content.ts`**: `PLACEHOLDER` (line 24), `BUG_SECTION_HEADINGS` (lines 39-47), `buildBody` (lines 180-198), `buildBugBody` (lines 212-224), `buildMinorAuditBody` (lines 283-303), `getSection` (lines 148-162).
- **Identical logic in the Python parity source**: `scripts/dev_tools/potential_to_issue.py` lines 437-485 — same `if selected_mode == "minor-audit": ... elif promotion_type == "bug": ... else: ...` order. The defect exists in both implementations by construction of the byte-parity port.

Work-mode gating (`extensions/drm-copilot/src/lib/prompt-mode-contract.ts`, `normalizeRequestedWorkMode`, lines 57-91): `minor-audit` is valid for **every** promotion type (line 69-71); `full` normalizes to `full-bug` for bug and `full-feature` otherwise (lines 76-78); `full-bug` with a non-bug type and `full-feature` with bug both **throw** before any body is built (lines 81-88).

### Actual template headings (verified)

- **Bug potential template** (`extensions/drm-copilot/resources/feature-templates/bug/potential_bug.md`): `Summary`, `Environment`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, `Logs / Screenshots`, `Impact / Severity`, `Suspected Cause / Notes`, `Proposed Fix / Validation Ideas`, `Next Step`. The first seven exactly match `BUG_SECTION_HEADINGS`.
- **Generic potential template** (`extensions/drm-copilot/resources/feature-templates/potential/template.md`, used for feature, refactor, AND epic potentials — it is the only non-bug potential template; the `feature/`, `refactor/`, `epic/` template folders contain active-folder docs (spec/plan/epic), not potential templates): `Problem / Why`, `Proposed Behavior`, `Acceptance Criteria (early draft)`, `Constraints & Risks`, `Test Conditions to Consider`, `Next Step`.

### 2. Full decision matrix (promotion_type x work_mode)

| promotion_type | work_mode (requested) | normalized mode | builder chosen | headings read from potential | present in that type's template? | verdict |
|---|---|---|---|---|---|---|
| feature | minor-audit | minor-audit | buildMinorAuditBody | Problem / Why; Proposed Behavior; Acceptance Criteria (early draft); Constraints & Risks; Test Conditions to Consider; Evidence Checklist (defaults) | yes (all five; checklist defaulted) | CORRECT |
| refactor | minor-audit | minor-audit | buildMinorAuditBody | same | yes | CORRECT |
| epic | minor-audit | minor-audit | buildMinorAuditBody | same | yes | CORRECT |
| **bug** | **minor-audit** | **minor-audit** | **buildMinorAuditBody** | same | **NO — bug template has none of these headings** | **BROKEN (issue #399 case: all placeholders)** |
| bug | full-bug | full-bug | buildBugBody | BUG_SECTION_HEADINGS (7) | yes (all seven) | CORRECT (verified empirically: issue #401 body populated) |
| bug | full | full-bug | buildBugBody | BUG_SECTION_HEADINGS | yes | CORRECT |
| feature / refactor / epic | full-feature | full-feature | buildBody | Problem / Why; Proposed Behavior; Acceptance Criteria (early draft); Constraints & Risks; Test Conditions to Consider | yes | CORRECT |
| feature / refactor / epic | full | full-feature | buildBody | same | yes | CORRECT |
| bug | full-feature | — | — (throws "full-feature may not be used with bug work") | — | — | rejected before body build (not broken) |
| feature / refactor / epic | full-bug | — | — (throws "full-bug may only be used with bug work") | — | — | rejected before body build (not broken) |

**Broken cells: exactly one class — (bug, minor-audit).** Feature, refactor, and epic do NOT share the defect: they all originate from the generic potential template, whose headings match both `buildBody` and the minor-audit `getSection` reads. The empirical evidence is consistent: #401 (bug, full-bug) rendered correctly via `buildBugBody`; #399 (bug, minor-audit) rendered feature-oriented minor-audit headings with placeholders.

### 3. Recommended fix strategy (Defect B)

**Reorder `buildIssueBody` so the promotion-type check precedes the work-mode check for bug promotions: `promotionType === "bug"` → `buildBugBody` regardless of work mode; then `minor-audit` → `buildMinorAuditBody` for non-bug types; else `buildBody`.** The `- Work Mode:` first line of `buildBugBody` already carries the selected mode (content.ts line 217), so a minor-audit bug issue still records `- Work Mode: minor-audit` while containing the full authored bug content under the real bug headings.

Rationale:
- It is lossless — all seven authored bug sections survive, versus any cross-template heading map, which necessarily discards `Environment`, `Actual Behavior`, and `Logs / Screenshots` content.
- It is deterministic and minimal (a branch reorder plus tests), reads the headings that actually exist in the bug template per promotion type, and needs no new builder in `content.ts`.
- Downstream compatibility risk is low: the minor-audit consumer in `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` (lines 260-318) either moves the potential file verbatim to `issue.md` or synthesizes its own minor-audit body — it does not parse the GitHub issue body headings, and it already extracts bug headings (`bug_summary` ... `bug_validation`) for bug flows.
- No type-aware minor-audit *variant builder* is needed in `content.ts`, and no data-driven heading map is required for correctness. If the planner nevertheless wants minor-audit envelope headings preserved for bug issues, the fallback design is a data-driven per-(type, mode) section-source table in `content.ts` — documented below as the rejected alternative.

**Parity constraint (must change in lockstep):** `promotion.ts` and `content.ts` document byte-for-byte parity of "every PromotionError message, emitted line, constant, and decision branch" with the Python source. The decision-branch reorder is exactly the class of change the parity contract pins. Therefore the fix MUST update, in the same change set:
- `scripts/dev_tools/potential_to_issue.py` (branch order at lines 437-485), and
- its tests: `tests/scripts/dev_tools/test_potential_to_issue.py` (which asserts minor-audit routing) plus any affected cases in `tests/scripts/dev_tools/test_potential_to_issue_content.py` and `tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py`,
- and the routing-table docblocks in `promotion.ts` (lines 187-199) and the module parity headers if wording changes.

Note: the parity header in `promotion.ts` (line 6) cites `resources/scripts/dev_tools/potential_to_issue.py`, but no Python exists under `extensions/drm-copilot/resources/` (verified by glob); the actual source is repo-root `scripts/dev_tools/potential_to_issue.py`. The fix should correct this stale path reference in the docstring.

`content.ts` itself needs **no builder changes** for the recommended strategy (`buildBugBody`, `buildMinorAuditBody`, `buildBody`, `BUG_SECTION_HEADINGS`, `PLACEHOLDER` are all reused as-is), so `potential_to_issue_content.py` stays untouched.

### Rejected alternatives (brief)

- **Defect A — per-call worktree auto-detection** (env var, `_meta` context, MCP roots, `git worktree list` heuristics): rejected; no reliable per-call caller-identity signal reaches the shared long-running server process (analysis above). Any heuristic converts deterministic misdirection into intermittent misdirection.
- **Defect A — warn-but-proceed with `process.cwd()`**: rejected; a warning inside a successful tool result does not prevent the misdirected write, and agents demonstrably missed it (this session's evidence).
- **Defect A — fixing path resolution inside `RealPotentialFileSystem.resolvePath`**: rejected; breaks the documented Python mirror and forces unnecessary lockstep churn; the resolver-layer `normalizeWorkspaceDestinationPath` fix achieves the same result.
- **Defect B — data-driven per-(type, mode) heading map keeping the minor-audit envelope for bugs** (e.g. Problem / Why ← Summary, Implementation Intent ← Proposed Fix / Validation Ideas, Verification Steps ← Steps to Reproduce, Dependencies / Risks ← Impact / Severity): rejected as primary strategy; the mapping is lossy (drops Environment, Actual Behavior, Logs / Screenshots), adds a new builder/map surface to `content.ts` and its Python twin, and provides no consumer-verified benefit.

---

## Existing test coverage (framework and files)

**Framework correction:** the extension's unit tests run under **Jest** (ts-jest), not Vitest. Evidence: `extensions/drm-copilot/package.json` — `"test": "node run-jest.cjs"`, devDependencies `jest`, `ts-jest`, `@jest/globals`; every test file imports from `@jest/globals` (e.g. `test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` line 1). The repo-root `package.json` likewise wires `run-jest.cjs`. The repo rule file `.claude/rules/typescript.md` names Vitest, but the extension as built uses Jest; the plan should extend the existing Jest suites, not introduce Vitest.

Relevant test files under `extensions/drm-copilot/test/`:

| Area | File | Notes |
|---|---|---|
| buildIssueBody routing | `test/lib/potential-to-issue/promotion.test.ts` | Has `describe` blocks for feature promotion, bug promotion, minor-audit routing (feature-shaped content only), work-mode normalization. **No (bug, minor-audit) case exists — the broken cell is untested.** |
| content builders | `test/lib/potential-to-issue/content.test.ts` | Covers `buildBugBody` heading order, `buildMinorAuditBody` section set, `getSection`, `PLACEHOLDER`. |
| missing-label recovery | `test/lib/potential-to-issue/promotion.missing-label.test.ts` | Unaffected. |
| service call | `test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | Injects `FakePotentialFileSystem` (Map-backed; its `resolvePath` is identity-like), so the `process.cwd()` path-resolution defect is invisible here by design — a new resolver-layer test is needed instead. |
| shared fakes | `test/lib/potential-to-issue/promotion-test-support.ts` | `FakePotentialFileSystem`, `FakeGhClient`, `WORKSPACE`. |
| input resolvers | `test/mcp-tool-inputs.test.ts` | Contains the fallback-behavior tests that must be inverted (lines 50, 248-256, 342, plus per-tool omission cases). Also `test/mcp-tool-inputs-discovery.test.ts`, `test/mcp-tool-inputs-epic-validation.test.ts`, `test/mcp-tool-inputs.codex-native-converter.test.ts`. |
| tool definitions | `test/mcp-repo-automation-tool-definitions.test.ts` | Schema assertions; must be extended for the new `required: ["workspace_root", ...]` entries. |
| dispatch | `test/mcp-tools.*.test.ts`, `test/mcp-server.test.ts` | Failure-envelope `workspace_root` echo. |
| VS Code command surface | `test/extension.potential-to-issue.test.ts`, `test/extension.new-potential-bug-entry-inprocess.test.ts` | Verify the explicit-workspace path stays green. |
| Python lockstep | `tests/scripts/dev_tools/test_potential_to_issue.py`, `test_potential_to_issue_content.py`, `test_potential_to_issue_missing_label_regression.py` | Pytest; must be updated with the branch reorder. |

Test style: `@jest/globals` imports, Arrange–Act–Assert, injected fakes (no real fs/subprocess), tests in `test/` mirroring `src/`.

---

## Parity / contract constraints a fix must preserve or update

1. **Python byte-parity (Defect B):** `promotion.ts`/`content.ts` pin messages, constants, and decision branches to `scripts/dev_tools/potential_to_issue.py` / `potential_to_issue_content.py`. The Defect B branch reorder requires a lockstep Python + pytest change. The stale `resources/scripts/dev_tools/...` path in the promotion.ts header should be corrected to the real location.
2. **No Python parity for Defect A** if implemented at the resolver/schema layer (`mcp-tool-inputs.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-push-down-schema-properties.ts`, `workflow-command-arguments.ts` are TS-native). Avoid touching `promotion-filesystem.ts` (documented mirror of Python `Path.expanduser().resolve()`).
3. **MCP input schemas:** all tool `inputSchema.required` arrays gain `workspace_root`; `workspaceRootProperty.description` must stop advertising the `process.cwd()` default; `potential_path` description already promises workspace-relative support — the fix makes the implementation match rather than changing the schema.
4. **Tool descriptions / return contract:** `RepoAutomationMcpToolResult` failure envelope (`ok:false`, `workspace_root`, `summary`) is preserved; the new required-field error surfaces through the existing `toFailureToolResult` path. The `potentialToIssueServiceCall` summary string (`Promoted '<path>' ...`) uses the caller-supplied `potentialPath`; if the resolver starts normalizing the path, the summary text changes for relative inputs — the plan should pin the intended summary form in a test.
5. **500-line file limit:** `mcp-tool-inputs.ts` is at 499 lines; adding `potential_path` normalization there may push it over 500 and require a small extraction (precedent: `mcp-tool-inputs-push-down.ts`).

---

## Automation Feasibility

This is a pure-code change confined to TypeScript sources/tests under `extensions/drm-copilot/` and the Python lockstep files `scripts/dev_tools/potential_to_issue.py` + `tests/scripts/dev_tools/`. There is no third-party UI, no credential issuance, no external service configuration, and no environment mutation beyond the repository. **No human-interaction or manual step is required**; all verification (format, lint, typecheck, unit tests, and the promotion-body regression assertions) is executable by the standard toolchain commands below. The only optional manual step is cosmetic and out of code scope: editing the already-created GitHub issue #399 body, which is not required by any acceptance criterion.

---

## Toolchain commands

Run from `extensions/drm-copilot/` (scripts verified in `extensions/drm-copilot/package.json`):

1. Format: `npm run format` (Prettier over `src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`)
2. Lint: `npm run lint` (ESLint over `src test`)
3. Typecheck: `npm run typecheck` (`tsc -p ./ --noEmit`)
4. Test: `npm run test` (Jest via `node run-jest.cjs`); coverage: `npm run test:coverage`

Repo root (`package.json`, for the root-level surfaces if touched): `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit` / `npm run test:unit:coverage` (also Jest). Python lockstep tests run under pytest per the repository Python toolchain (`tests/scripts/dev_tools/test_potential_to_issue*.py`).

---

## Summary of recommended plan inputs

- Defect A: fail-closed `workspace_root` (schema `required` + `normalizeWorkspaceRoot` throw when no explicit fallback), plus resolver-layer `potential_path` normalization against `workspaceRoot`. TS-only; invert fallback tests; doc sweep for callers.
- Defect B: reorder `buildIssueBody` so `promotionType === "bug"` routes to `buildBugBody` before the minor-audit branch; lockstep change in `scripts/dev_tools/potential_to_issue.py` and its pytest suite; add the missing (bug, minor-audit) regression tests on both sides; fix the stale parity path reference.
