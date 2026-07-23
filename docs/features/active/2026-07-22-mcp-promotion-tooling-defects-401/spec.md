# 2026-07-22-mcp-promotion-tooling-defects (Spec)

- **Issue:** #401
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-22T20-17
- **Status:** Ready
- **Version:** 1.0

## Context
Two defects in the drm-copilot MCP tooling (extension under `extensions/drm-copilot/`) were discovered while filing issue #399. Defect A: the shared `workspace_root` default resolution returns the long-running MCP server process's own `process.cwd()` (the main repo checkout) instead of the calling agent's isolated git worktree, silently writing promotion artifacts to the wrong repo checkout. Defect B: `potential_to_issue` renders every section of the created GitHub bug issue body as the placeholder `(not provided in potential file)` because the issue-body section-heading mapping does not match the actual bug-potential template headings.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (defects are in the TypeScript MCP server under `extensions/drm-copilot/src/`)
- Command/flags used: `mcp__drm-copilot__new_potential_bug_entry`, `mcp__drm-copilot__potential_to_issue`, `mcp__drm-copilot__new_active_feature_folder` invoked from an Agent tool run with `isolation: "worktree"`
- Data source or fixture: `docs/features/potential/promoted/2026-07-22-npm-audit-vulnerabilities-ci-gate.md` and the bug-potential template; GitHub issue https://github.com/drmoisan/drm-copilot/issues/399

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Rationale: Defect A silently corrupts the target checkout for promotion artifacts under worktree isolation (data-misdirection risk with no error). Defect B produces empty GitHub issues for bug promotions, discarding all authored content.


## Repro & Evidence
Steps to Reproduce:
Defect A:
1. Run an agent inside an isolated git worktree (`Agent` tool `isolation: "worktree"`, working dir under `.claude/worktrees/<id>/`).
2. Call a `workspace_root`-accepting drm-copilot MCP tool (for example `new_potential_bug_entry`) without passing `workspace_root`.
3. Observe that the artifact is written to the main repo checkout (`process.cwd()` of the shared MCP server process), not the calling worktree; `git status` in the worktree shows nothing new.

Defect B:
1. Create a bug potential entry from the bug template and populate its real headings (`Summary`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, etc.).
2. Promote it with `potential_to_issue`.
3. Open the created GitHub issue and observe every section body renders as `(not provided in potential file)` even though the source potential doc has complete content.

Expected:
- Defect A: the tool resolves the calling agent's actual worktree directory when `workspace_root` is omitted, or fails closed / loudly warns when the resolved default cannot be trusted, so silent misdirection to the wrong checkout is impossible.
- Defect B: the created GitHub issue body contains the real content from the potential doc, mapped from the potential doc's actual section headings for the given promotion type.

Actual:
- Defect A: `extensions/drm-copilot/src/mcp-tools.ts` resolves the omitted `workspace_root` to `process.cwd()` of the long-running MCP server process, which is the main checkout rather than the caller's worktree. Artifacts land in the wrong checkout with no error.
- Defect B: `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` `buildIssueBody` selects a body builder whose section headings do not match the actual template headings for the affected path, so `getSection` returns empty for each heading and the placeholder `(not provided in potential file)` (defined in `content.ts`) is emitted for every section.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `extensions/drm-copilot/src/mcp-tools.ts` line 79 `return process.cwd();` and line 85 `normalizeWorkspaceRoot(workspaceRoot, process.cwd())`; `promotion.ts` `buildIssueBody` minor-audit branch precedes the `promotionType === "bug"` branch. GitHub issue #399 body shows `(not provided in potential file)` in every section.

Additional evidence (research, `research/2026-07-22T10-20-mcp-promotion-tooling-defects-research.md`):
- A relative `potential_path` fails with "Potential file not found" even when `workspace_root` is passed explicitly, because `RealPotentialFileSystem.resolvePath` resolves against the server's `process.cwd()`; the tool schema documents `potential_path` as "Absolute or workspace-relative path", so the implementation violates its own contract.
- Empirical confirmation of the Defect B matrix: issue #401 (bug, `full-bug`) rendered correctly via `buildBugBody`; issue #399 (bug, `minor-audit`) rendered minor-audit headings with placeholders.


## Scope & Non-Goals
- In scope:
  - Defect A: fail-closed `workspace_root` resolution for MCP tool calls — `normalizeWorkspaceRoot` throws when `workspace_root` is omitted and no explicit fallback argument is supplied; `workspace_root` becomes a required schema property for all 28 MCP tools; schema description text no longer advertises a `process.cwd()` default.
  - Defect A (secondary): workspace-relative `potential_path` resolution against the resolved `workspace_root` for `potential_to_issue`, implemented at the tool-input resolver layer (`resolvePotentialToIssueToolInput`) using the existing `normalizeWorkspaceDestinationPath` helper.
  - Defect B: reorder `buildIssueBody` in `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` so `promotionType === "bug"` routes to `buildBugBody` before the `minor-audit` branch, in lockstep with the identical branch reorder in `scripts/dev_tools/potential_to_issue.py`.
  - Correction of the stale parity-header path reference in `promotion.ts` (cites `resources/scripts/dev_tools/potential_to_issue.py`; actual source is repo-root `scripts/dev_tools/potential_to_issue.py`) and the routing-table docblock.
  - Test updates on both sides: new Jest regression tests for the (bug, minor-audit) cell, fail-closed `workspace_root`, and workspace-relative `potential_path`; inversion of existing fallback-default tests; matching pytest updates for the Python branch reorder.
  - Documentation sweep of in-repo skills/agent docs that instruct calling these MCP tools without `workspace_root`, so instructions match the new required-input contract.
- Out of scope / non-goals:
  - Per-call worktree auto-detection (env vars, MCP `_meta`, MCP `roots` capability, `git worktree list` heuristics). Rejected by research: no reliable per-call caller-identity signal reaches the shared long-running server process.
  - Warn-but-proceed behavior for omitted `workspace_root`. Rejected: a warning does not prevent the misdirected write.
  - Changing `RealPotentialFileSystem.resolvePath` in `promotion-filesystem.ts`. Rejected: it is a documented mirror of Python `Path(...).expanduser().resolve()`; changing it forces unnecessary lockstep churn. The resolver-layer fix achieves the same observable behavior.
  - Any new body builder, heading map, or type-aware minor-audit variant in `content.ts` / `potential_to_issue_content.py`. The recommended reorder reuses existing builders as-is.
  - Changes to feature/refactor/epic promotion body mapping — the research decision matrix verifies those cells are correct.
  - Editing the already-created GitHub issue #399 body (cosmetic, outside code scope).
  - Changes to the VS Code extension command surface behavior (it must remain working unchanged).
- Explicitly excluded systems, integrations, or datasets:
  - GitHub Actions workflows, branch protection, and CI required-check configuration.
  - `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` (downstream consumer; research verifies it does not parse GitHub issue body headings).
  - `content.ts` builders and `scripts/dev_tools/potential_to_issue_content.py` (no changes required by the chosen strategy).

## Root Cause Analysis
- Defect A: `resolveWorkspaceRootForTool` (or equivalent) in `extensions/drm-copilot/src/mcp-tools.ts` defaults to the MCP server process `process.cwd()`, which does not reflect the calling agent's worktree because the MCP server is a long-running process shared across the session. Determine whether a reliable worktree signal exists (environment variable set by the harness, per-call originating context) or whether the fix is to make `workspace_root` effectively required / fail-closed when the resolved default does not match an expected signal.
- Defect B: `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` `buildIssueBody` orders the minor-audit branch (`buildMinorAuditBody`, headings `Problem / Why`, `Implementation Intent`, `Acceptance Criteria`, `Dependencies / Risks`, `Verification Steps`, `Evidence Checklist`) before the `promotionType === "bug"` branch (`buildBugBody`, headings from `BUG_SECTION_HEADINGS`). Confirm which work_mode + promotion_type combinations mis-route, and check whether `feature` / `epic` / `refactor` promotion types share the same class of heading-mapping defect against their own templates.

Research resolution of the open questions above (`research/2026-07-22T10-20-mcp-promotion-tooling-defects-research.md`):
- Defect A — no reliable worktree signal exists. The server is one long-running stdio process per session shared by concurrent worktree-isolated agents; no process-level state, per-call `_meta` field, or session-scoped MCP `roots` capability can attribute an individual call to a specific worktree. Auto-detection is not possible; the fix must fail closed. The exact defect locations are: `normalizeWorkspaceRoot` (`extensions/drm-copilot/src/workflow-command-arguments.ts` lines 275-284, default parameter `fallbackWorkspaceRoot: string = process.cwd()`); every per-tool resolver in `mcp-tool-inputs*.ts` called by the MCP handlers without a fallback argument; and `inferWorkspaceRoot` in `mcp-tools.ts` lines 73-86 (failure-envelope echo only).
- Defect A secondary root cause — `RealPotentialFileSystem.resolvePath` (`extensions/drm-copilot/src/lib/potential-to-issue/promotion-filesystem.ts` lines 57-64) is `nodePath.resolve(expanded)`, which resolves a relative `potential_path` against the server's `process.cwd()`, never against the supplied `workspace_root`. The `workspace` option in `promotePotential` is used only for the relative footer path and the promoted-folder destination, not for locating the input file.
- Defect B — exactly one broken cell in the (promotion_type x work_mode) matrix: **(bug, minor-audit)**. `minor-audit` is a valid work mode for every promotion type, and the minor-audit branch precedes the bug branch, so a bug potential promoted in minor-audit mode routes to `buildMinorAuditBody`, whose section reads match none of the bug template's headings. Feature, refactor, and epic potentials all originate from the generic potential template whose headings match both `buildBody` and the minor-audit reads, so they are unaffected. Invalid combinations (`full-feature` + bug, `full-bug` + non-bug) throw before body build. The identical branch order exists in the Python parity source `scripts/dev_tools/potential_to_issue.py` lines 437-485 by construction of the byte-parity port.


## Proposed Fix

### Design summary (what changes where):

**Defect A — fail closed on omitted `workspace_root` (TypeScript only; no Python parity impact).**
1. `extensions/drm-copilot/src/workflow-command-arguments.ts`, `normalizeWorkspaceRoot` (lines ~275-284): when `value === undefined` and no explicit `fallbackWorkspaceRoot` argument was supplied by the caller, throw a clear, actionable error (message form: `workspace_root is required. The MCP server cannot infer the calling agent's checkout; pass the absolute worktree root explicitly.`) instead of silently returning `process.cwd()`. The two-argument signature is retained: callers that pass an explicit fallback (the VS Code extension command surface, which passes `getWorkspaceRoot()`) keep their current behavior; MCP handlers continue to pass nothing and now fail closed.
2. `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` and `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts`: add `"workspace_root"` to the `inputSchema.required` array of every tool (all 28 tools in `REPO_AUTOMATION_TOOLS`), so an omitted value is rejected at the MCP boundary. This is a deliberate, documented breaking change for agent callers that previously relied on the silent default.
3. `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`, `workspaceRootProperty.description`: remove the "Defaults to process.cwd() when omitted" text; state that the absolute root of the target checkout/worktree is required.

**Defect A (secondary) — workspace-relative `potential_path` (TypeScript only).**
4. `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `resolvePotentialToIssueToolInput` (lines ~316-336): resolve `potential_path` against the resolved `workspace_root` using the existing `normalizeWorkspaceDestinationPath(potentialPath, workspaceRoot, "potential_path")` helper (`workflow-command-arguments.ts` lines 290-300) before the value reaches `promotePotential`. This makes the schema's documented "Absolute or workspace-relative path" contract true. `promotion-filesystem.ts` is deliberately not modified (documented Python mirror); the resolver-layer placement achieves the required behavior — a relative `potential_path` resolves against `workspace_root`, not `process.cwd()`.

**Defect B — branch reorder with Python lockstep.**
5. `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`, `buildIssueBody` (lines ~201-262): reorder so `promotionType === "bug"` routes to `buildBugBody` first, regardless of work mode; then `selectedMode === "minor-audit"` routes non-bug types to `buildMinorAuditBody`; else `buildBody`. The `- Work Mode:` first line emitted by `buildBugBody` already records the selected mode, so a minor-audit bug issue still records `- Work Mode: minor-audit` while carrying the full authored bug content under the real bug headings. Update the routing-table docblock (lines ~187-199) to match.
6. `scripts/dev_tools/potential_to_issue.py` (lines ~437-485): apply the identical branch reorder in lockstep, per the byte-parity contract pinning "every PromotionError message, emitted line, constant, and decision branch".
7. `promotion.ts` parity header (line ~6): correct the stale path reference `resources/scripts/dev_tools/potential_to_issue.py` to the actual source `scripts/dev_tools/potential_to_issue.py`.

### Boundaries and invariants to preserve:
- VS Code extension command surface: `extension.ts` passes `workspaceRoot: getWorkspaceRoot()` explicitly into service calls; it never relies on the resolver default and must remain fully working with no behavior change.
- `RepoAutomationMcpToolResult` failure envelope (`ok: false`, `workspace_root`, `summary`) is preserved; the new required-field error surfaces through the existing `toFailureToolResult` path.
- `promotion-filesystem.ts` (`RealPotentialFileSystem`) stays untouched — it is a documented mirror of Python `Path(...).expanduser().resolve()`.
- `content.ts` builders (`buildBugBody`, `buildMinorAuditBody`, `buildBody`, `BUG_SECTION_HEADINGS`, `PLACEHOLDER`) and `scripts/dev_tools/potential_to_issue_content.py` are reused as-is; no builder changes.
- Byte-parity between `promotion.ts`/`content.ts` and `scripts/dev_tools/potential_to_issue.py`/`potential_to_issue_content.py` for messages, constants, emitted lines, and decision branches: the Defect B reorder must land in both sources in the same change set.
- Feature/refactor/epic promotion behavior for all valid work modes is unchanged (verified-correct matrix cells).
- Work-mode validation in `prompt-mode-contract.ts` (`normalizeRequestedWorkMode`) is unchanged: `full` still normalizes to `full-bug` for bug and `full-feature` otherwise; invalid combinations still throw before body build.
- 500-line production file limit: `mcp-tool-inputs.ts` is at 499 lines; if the `potential_path` normalization pushes it over 500, extract per the existing `mcp-tool-inputs-push-down.ts` precedent.
- The `potentialToIssueServiceCall` summary string (`Promoted '<path>' ...`): the intended summary form for relative inputs after resolver normalization must be pinned by a test, since normalization changes the echoed path text.

### Dependencies or blocked work:
- None. This is a pure-code change confined to `extensions/drm-copilot/` TypeScript sources/tests and the Python lockstep files `scripts/dev_tools/potential_to_issue.py` + `tests/scripts/dev_tools/`. No third-party services, credentials, or environment mutation. No human-interaction requirement.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `extensions/drm-copilot/src/workflow-command-arguments.ts` — `normalizeWorkspaceRoot` fail-closed behavior.
- `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` — `workspace_root` added to `required` for all repo-automation tools.
- `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` — `workspace_root` added to `required` for all discovery tools.
- `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts` — `workspaceRootProperty.description` rewrite.
- `extensions/drm-copilot/src/mcp-tool-inputs.ts` — `resolvePotentialToIssueToolInput` normalizes `potential_path` against `workspace_root` (with extraction to a sibling module if the 500-line limit is exceeded).
- `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` — `buildIssueBody` branch reorder; routing-table docblock; stale parity-header path correction.
- `scripts/dev_tools/potential_to_issue.py` — lockstep branch reorder.
- Tests (Jest): `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts`, `test/mcp-tool-inputs.test.ts`, `test/mcp-tool-inputs-discovery.test.ts`, `test/mcp-tool-inputs-epic-validation.test.ts`, `test/mcp-tool-inputs.codex-native-converter.test.ts`, `test/mcp-repo-automation-tool-definitions.test.ts`, plus dispatch/extension tests as needed (`test/mcp-tools.*.test.ts`, `test/mcp-server.test.ts`, `test/extension.potential-to-issue.test.ts`, `test/extension.new-potential-bug-entry-inprocess.test.ts`).
- Tests (pytest): `tests/scripts/dev_tools/test_potential_to_issue.py`, and any affected cases in `tests/scripts/dev_tools/test_potential_to_issue_content.py` and `tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py`.
- In-repo docs (skills/agent instructions) that call the affected MCP tools without `workspace_root`.

#### Functions/classes/CLI commands impacted:
- `normalizeWorkspaceRoot(value, fallbackWorkspaceRoot?)` — throws when `value` is undefined and no explicit fallback argument is supplied; unchanged when an explicit fallback is supplied or `value` is a valid string.
- `resolvePotentialToIssueToolInput` — `potential_path` output becomes an absolute path resolved against `workspace_root` via `normalizeWorkspaceDestinationPath`.
- All per-tool input resolvers in `mcp-tool-inputs.ts`, `mcp-tool-inputs-push-down.ts`, `mcp-tool-inputs-discovery.ts`, `mcp-tool-inputs-subagent-tree.ts` — behavior change is inherited from `normalizeWorkspaceRoot` (no signature changes).
- `buildIssueBody` (TS) and its Python twin in `potential_to_issue.py` — decision-branch order change only.
- MCP tools (all 28 in `REPO_AUTOMATION_TOOLS`): `workspace_root` becomes required input.
- Python CLI `scripts/dev_tools/potential_to_issue.py`: body-routing change only; its workspace default (`Path(__file__).resolve().parents[2]`) is correct in its CLI context and is unchanged.

#### Data flow and validation changes:
- MCP call boundary: `workspace_root` is validated as required by the advertised `inputSchema`; an omitted value produces a structured failure result with an actionable message instead of a silent `process.cwd()` substitution.
- `potential_to_issue` input flow: caller-supplied `potential_path` (absolute or workspace-relative) is normalized against the resolved `workspace_root` at the resolver layer; `promotePotential` and `RealPotentialFileSystem.resolvePath` receive an already-absolute path and are unchanged.
- Issue-body routing: promotion type is evaluated before work mode for bug promotions; the (bug, minor-audit) cell now produces a bug-headed body (`Summary`, `Environment`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, `Logs / Screenshots`, `Impact / Severity`) populated from the potential doc, with `- Work Mode: minor-audit` recorded on the first line.

#### Error handling and logging updates:
- New thrown error in `normalizeWorkspaceRoot` for the omitted-with-no-fallback case; the message must name the missing field and the corrective action (pass the absolute worktree root). It surfaces to MCP callers through the existing `toFailureToolResult` failure envelope.
- `normalizeWorkspaceDestinationPath` supplies existing validation/error semantics for `potential_path` (field-named errors); no new logging framework or telemetry is introduced.
- No broad catch-all handlers; failures propagate through the established structured-result path.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the change set. The Defect A schema change is intentionally breaking for MCP agent callers; partial rollback (reverting the TS reorder without the Python reorder, or vice versa) would violate the parity contract and is not permitted.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `workspace_root` (all 28 MCP tools): string, absolute path to the target checkout/worktree root; **required** in `inputSchema.required`. Omission yields `ok: false` with the actionable required-field message.
- `potential_to_issue.potential_path`: string, absolute or workspace-relative; a relative value resolves against `workspace_root`. Schema description text is already correct and unchanged; the implementation is brought into conformance.
- `potential_to_issue` output for a bug potential in `minor-audit` mode: GitHub issue body headed by the bug sections (per `BUG_SECTION_HEADINGS`) with real authored content, first line `- Work Mode: minor-audit`.
- `RepoAutomationMcpToolResult` envelope shape is unchanged (`ok`, `workspace_root`, `summary`, per-tool payload).

#### Required configuration keys and defaults:
- None added or changed. No config schema, `.mcp.json`, or environment-variable changes.

#### Backward-compatibility expectations:
- Breaking (intended): MCP agent callers omitting `workspace_root` now receive a structured error instead of a silent wrong-checkout write. This applies uniformly across all 28 tools.
- Preserved: VS Code command surface (explicit `getWorkspaceRoot()` path); all feature/refactor/epic promotion outputs; all bug promotions in `full-bug`/`full` modes; Python CLI default workspace behavior; the failure-envelope contract; `content.ts`/`potential_to_issue_content.py` public surface.
- Parity: TS and Python `buildIssueBody` decision branches remain byte-parity equivalents after the lockstep reorder.

#### Performance constraints (latency/throughput/memory):
- None material. Changes are branch-order, validation, and one extra path normalization per `potential_to_issue` call. No new I/O, no measurable latency, throughput, or memory impact. No benchmark baseline is affected.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The MCP server remains a single long-running stdio process per session shared across concurrent worktree-isolated agents; no per-call caller-identity signal is available (verified by research).
  - Agent callers can always supply an absolute `workspace_root` (they know their own working directory).
  - The Jest suites under `extensions/drm-copilot/test/` and the pytest suites under `tests/scripts/dev_tools/` are the authoritative regression surfaces.
- Constraints (budget, performance, compatibility):
  - Byte-parity contract between `promotion.ts`/`content.ts` and their Python sources: decision-branch changes must land in both in the same change set.
  - 500-line production file limit (`mcp-tool-inputs.ts` at 499 lines; extraction required if exceeded).
  - Test framework is Jest (ts-jest) via `node run-jest.cjs`, not Vitest; extend existing Jest suites.
  - Unit tests use injected fakes (`FakePotentialFileSystem`, `FakeGhClient`); no real filesystem, subprocess, or network access; no temporary files.
  - Coverage thresholds: line >= 85%, branch >= 75%; no regression on changed lines.
- External dependencies (services, libraries, releases):
  - None. No new packages. GitHub API interaction remains behind the existing `gh` client abstraction and is faked in tests.

## Data / API / Config Impact
- User-facing or API changes:
  - All 28 drm-copilot MCP tools now require `workspace_root` (advertised via `inputSchema.required`); the property description no longer claims a `process.cwd()` default. Deliberate breaking change for agent callers.
  - `potential_to_issue` accepts workspace-relative `potential_path` values as documented (previously broken for relative inputs).
  - Bug potentials promoted in `minor-audit` mode produce bug-headed issue bodies with authored content.
- Data or migration considerations:
  - None. No stored data format changes. Existing GitHub issues created with placeholder bodies (e.g., #399) are not retroactively edited by this fix.
- Logging/telemetry updates (if any):
  - None beyond the new thrown error message surfaced through the existing failure envelope.
- Compatibility notes (CLI flags, config schemas, versioning):
  - Python CLI `potential_to_issue.py` flags and workspace default are unchanged; only its body-routing branch order changes.
  - In-repo skill/agent documentation that instructs calling these MCP tools must be swept to state that `workspace_root` is required.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: `mcp-tools.ts` workspace_root resolution; `promotion.ts` `buildIssueBody` per (promotion_type x work_mode) matrix; `content.ts` body builders and heading maps.
- [x] Integration scenario to retest: promote a bug potential and assert the created issue body contains real section content, not placeholders; assert an omitted `workspace_root` under worktree isolation does not silently target the wrong checkout.
- [x] Manual verification notes: compare the created GitHub issue body against the populated potential doc for each promotion type.

- Regression tests to add or update:
  - Jest, `test/lib/potential-to-issue/promotion.test.ts`: new (bug, minor-audit) case — a bug potential with populated bug-template headings promoted with `work_mode=minor-audit` yields a body headed by the bug sections (`Summary`, `Environment`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, `Logs / Screenshots`, `Impact / Severity`) containing the authored content, with zero occurrences of `(not provided in potential file)` for populated sections, and first line `- Work Mode: minor-audit`.
  - Jest, `test/lib/potential-to-issue/promotion.test.ts`: matrix guard cases confirming (feature|refactor|epic, minor-audit) still route to `buildMinorAuditBody` and (bug, full-bug|full) still route to `buildBugBody` (unchanged cells).
  - Jest, `test/mcp-tool-inputs.test.ts` (and sibling resolver test files): omitted `workspace_root` with no explicit fallback throws/rejects with the required-field message (inverting the existing "uses fallback when workspace_root is missing" style cases at lines ~50, ~248-256, ~342 and per-tool omission cases); explicit-fallback cases (extension command surface path) remain green.
  - Jest, `test/mcp-tool-inputs.test.ts`: `resolvePotentialToIssueToolInput` resolves a relative `potential_path` against the supplied `workspace_root` (result is `workspace_root`-joined absolute path) and leaves an absolute `potential_path` unchanged; the `potentialToIssueServiceCall` summary form for relative inputs is pinned.
  - Jest, `test/mcp-repo-automation-tool-definitions.test.ts` (and discovery-definitions coverage): every tool's `inputSchema.required` includes `workspace_root`; `workspaceRootProperty.description` no longer contains "process.cwd()".
  - Jest, `test/extension.potential-to-issue.test.ts` / `test/extension.new-potential-bug-entry-inprocess.test.ts`: VS Code command surface (explicit workspace) remains green unchanged.
  - Pytest, `tests/scripts/dev_tools/test_potential_to_issue.py`: mirrored (bug, minor-audit) regression case asserting bug-headed body; existing minor-audit routing assertions updated for the reorder; affected cases in `test_potential_to_issue_content.py` and `test_potential_to_issue_missing_label_regression.py` reviewed and updated as needed.
- Unit tests for the fixed behavior and boundaries:
  - `normalizeWorkspaceRoot`: (a) omitted value + no fallback argument → throws with actionable message; (b) omitted value + explicit fallback argument → returns fallback (unchanged); (c) valid string value → normalized as before; (d) invalid-type value → existing error behavior preserved.
  - `buildIssueBody` routing table exercised across the full valid (promotion_type x work_mode) matrix per the research decision matrix.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Empty-string and whitespace-only `workspace_root` (existing validation semantics preserved).
  - Relative `potential_path` with `..` segments and `~` expansion through `normalizeWorkspaceDestinationPath` semantics.
  - Bug potential with some empty sections in minor-audit mode: empty sections fall back to `PLACEHOLDER` individually while populated sections carry content.
  - Invalid mode/type combinations ((bug, full-feature), (non-bug, full-bug)) still throw before body build.
- Error handling and logging verification:
  - The required-`workspace_root` error surfaces to MCP callers as `ok: false` through `toFailureToolResult` with the actionable message; assert message text and envelope shape.
- Coverage impact and targets for changed lines/modules:
  - Line coverage >= 85% and branch coverage >= 75% maintained for both the TypeScript extension (`npm run test:coverage`) and the Python module; changed lines in `workflow-command-arguments.ts`, `mcp-tool-inputs.ts`, `promotion.ts`, and `potential_to_issue.py` are fully exercised by the new/updated tests.
- Toolchain commands to run (format → lint → type-check → test):
  - TypeScript, from `extensions/drm-copilot/`: `npm run format` (Prettier) → `npm run lint` (ESLint) → `npm run typecheck` (`tsc -p ./ --noEmit`) → `npm run test` (Jest via `node run-jest.cjs`) and `npm run test:coverage`. Repeat at repo root if root-level surfaces are touched.
  - Python: `black` → `ruff` → `pyright` → `pytest tests/scripts/dev_tools/` with coverage, per the repository Python toolchain.
  - Repeat the full loop from formatting until all stages pass in a single pass.
- Manual validation steps (if required):
  - None required; all acceptance criteria are verifiable by automated tests. Optional post-merge smoke check: promote a real bug potential in minor-audit mode and compare the created issue body against the potential doc.


## Acceptance Criteria
- [x] AC-1 (Defect B regression): a Jest test in `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts` proves that a bug potential with populated bug-template sections, promoted with `work_mode=minor-audit`, produces an issue body headed by the bug sections (`Summary`, `Environment`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, `Logs / Screenshots`, `Impact / Severity`) containing the authored content — not minor-audit/feature-oriented placeholder sections — and recording `- Work Mode: minor-audit` on the first body line. Test passes. (Evidence: evidence/regression-testing/expect-fail-ts-bug-minor-audit.2026-07-22T15-53.md, evidence/regression-testing/pass-after-defect-b.2026-07-22T20-17.md)
- [x] AC-2 (Defect B matrix preserved): Jest tests confirm unchanged routing for the verified-correct matrix cells: (feature|refactor|epic, minor-audit) → `buildMinorAuditBody`; (bug, full-bug) and (bug, full) → `buildBugBody`; (feature|refactor|epic, full-feature|full) → `buildBody`; invalid combinations ((bug, full-feature), (non-bug, full-bug)) still throw before body build. Tests pass. (Evidence: extensions/drm-copilot/test/lib/potential-to-issue/promotion.matrix.test.ts; evidence/regression-testing/pass-after-defect-b.2026-07-22T20-17.md)
- [x] AC-3 (Defect B Python lockstep): `scripts/dev_tools/potential_to_issue.py` receives the identical branch reorder in the same change set, and a pytest regression case in `tests/scripts/dev_tools/test_potential_to_issue.py` proves the (bug, minor-audit) promotion yields a bug-headed body. All pytest cases in `tests/scripts/dev_tools/test_potential_to_issue*.py` pass. (Evidence: evidence/regression-testing/expect-fail-py-bug-minor-audit.2026-07-22T15-53.md, evidence/regression-testing/pass-after-defect-b.2026-07-22T20-17.md)
- [x] AC-4 (Defect A fail-closed): a Jest test proves that resolving any affected tool input with `workspace_root` omitted and no explicit fallback argument throws (is rejected) with an actionable message naming `workspace_root`, rather than silently resolving to `process.cwd()`. Existing fallback-default tests are inverted accordingly. Tests pass. (Evidence: extensions/drm-copilot/test/workflow-command-arguments.test.ts, extensions/drm-copilot/test/mcp-tool-inputs.workspace-root.test.ts; evidence/regression-testing/expect-fail-ts-defect-a.2026-07-22T15-53.md, evidence/regression-testing/pass-after-defect-a.2026-07-22T20-17.md)
- [x] AC-5 (Defect A schema): every tool in `REPO_AUTOMATION_TOOLS` (all 28) lists `workspace_root` in its `inputSchema.required` array, and `workspaceRootProperty.description` no longer advertises a `process.cwd()` default; both facts are asserted by Jest tests in `test/mcp-repo-automation-tool-definitions.test.ts` (and discovery-definitions coverage). Tests pass. (Evidence: extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts; evidence/regression-testing/pass-after-defect-a.2026-07-22T20-17.md)
- [x] AC-6 (Defect A potential_path): a Jest test proves that a workspace-relative `potential_path` passed to `resolvePotentialToIssueToolInput` resolves against the supplied `workspace_root` (not `process.cwd()`), and that an absolute `potential_path` is preserved. `promotion-filesystem.ts` (`RealPotentialFileSystem`) is unmodified. Tests pass. (Evidence: extensions/drm-copilot/test/mcp-tool-inputs.workspace-root.test.ts, extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts; evidence/qa-gates/scope-integrity.2026-07-22T20-17.md confirms promotion-filesystem.ts unmodified)
- [x] AC-7 (VS Code surface intact): the extension command-surface tests (`test/extension.potential-to-issue.test.ts`, `test/extension.new-potential-bug-entry-inprocess.test.ts`) pass unchanged in behavior — the explicit `getWorkspaceRoot()` path continues to work with no new errors. (Evidence: evidence/regression-testing/vscode-surface-intact.2026-07-22T20-17.md)
- [x] AC-8 (Failure envelope): the omitted-`workspace_root` error surfaces to MCP callers as a structured `ok: false` result through the existing `toFailureToolResult` path, preserving the `RepoAutomationMcpToolResult` envelope shape; asserted by test. (Evidence: extensions/drm-copilot/test/mcp-tools.workspace-root.test.ts, extensions/drm-copilot/test/mcp-server.test.ts)
- [x] AC-9 (Parity header correction): the stale parity-header reference in `promotion.ts` (`resources/scripts/dev_tools/potential_to_issue.py`) is corrected to `scripts/dev_tools/potential_to_issue.py`, and the `buildIssueBody` routing-table docblock reflects the new branch order. (Evidence: extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts header + buildIssueBody docblock; verified by evidence/regression-testing/pass-after-defect-b.2026-07-22T20-17.md)
- [x] AC-10 (TypeScript toolchain): full TypeScript toolchain passes in a single pass from `extensions/drm-copilot/` (and repo root if touched): `npm run format` (Prettier), `npm run lint` (ESLint), `npm run typecheck` (tsc), `npm run test` (Jest), with `npm run test:coverage` showing line coverage >= 85% and branch coverage >= 75%. (Evidence: evidence/qa-gates/final-ts-format, final-ts-lint, final-ts-typecheck, final-ts-test-coverage, coverage-delta-ts (all 2026-07-22T20-17); line 96.33%, branch 89.21%)
- [x] AC-11 (Python toolchain): full Python toolchain passes in a single pass: black, ruff, pyright, pytest, with coverage thresholds (line >= 85%, branch >= 75%) preserved for the changed module. (Evidence: evidence/qa-gates/final-py-format, final-py-lint, final-py-typecheck, final-py-test-coverage, coverage-delta-py (all 2026-07-22T20-17); potential_to_issue.py 85%, no regression vs baseline)
- [x] AC-12 (No out-of-scope behavior change): no behavior changes outside the defined scope — `content.ts`, `potential_to_issue_content.py`, `promotion-filesystem.ts`, `prompt-mode-contract.ts` validation semantics, the Python CLI workspace default, and the feature/refactor/epic promotion outputs are unchanged; confirmed by the existing suites passing without semantic modification beyond the documented inversions in AC-4. (Evidence: evidence/qa-gates/scope-integrity.2026-07-22T20-17.md)
- [x] AC-13 (Docs updated): in-repo skill/agent documentation that instructs calling the affected MCP tools is updated to state that `workspace_root` is required, and no in-repo doc still claims a `process.cwd()` default for these tools. (Evidence: evidence/other/doc-sweep-workspace-root.2026-07-22T20-17.md)
- [x] AC-14 (File-size limit): no production or test file exceeds 500 lines after the change; if `mcp-tool-inputs.ts` (currently 499 lines) exceeds the limit, the `potential_path` normalization is extracted to a sibling module following the `mcp-tool-inputs-push-down.ts` precedent. (Evidence: evidence/other/mcp-tool-inputs-linecount-final.2026-07-22T20-17.md; mcp-tool-inputs.ts 477 lines, mcp-tool-inputs-potential-to-issue.ts 60 lines)

## Risks & Mitigations
- Technical or operational risks:
  - **Breaking change ripple:** requiring `workspace_root` breaks any in-repo skill, agent instruction, or automation that omitted it. Mitigation: AC-13 documentation sweep; the error message is actionable so residual callers self-correct on first failure; the failure envelope keeps the error structured rather than a protocol-level crash.
  - **Parity drift:** applying the Defect B reorder in TypeScript but not Python (or vice versa) silently violates the byte-parity contract. Mitigation: AC-3 requires both changes in one change set; mirrored regression tests on both sides fail if either diverges.
  - **Test-inversion collateral:** inverting the fallback-default tests could mask a regression in the explicit-fallback (VS Code) path. Mitigation: AC-4 explicitly keeps explicit-fallback cases green; AC-7 exercises the extension surface end-to-end.
  - **Summary-string drift:** resolver-layer `potential_path` normalization changes the echoed path in the `potentialToIssueServiceCall` summary for relative inputs. Mitigation: the intended summary form is pinned by test (AC-6 scope).
  - **500-line limit breach in `mcp-tool-inputs.ts`.** Mitigation: AC-14 extraction path is pre-identified.
- Mitigations and rollbacks:
  - Rollback is a single revert of the full change set (TS + Python together). Partial rollback is prohibited by the parity contract.

## Rollout & Follow-up
- Release/rollout steps:
  - Land as one change set on a feature branch for issue #401; merge via PR after full toolchain and review gates pass. The MCP server change takes effect when the extension package is rebuilt/republished and sessions restart the server process; no data migration, no staged rollout, no feature flag.
- Post-fix monitoring or clean-up tasks:
  - Sweep and update any remaining in-repo caller documentation found after merge that omits `workspace_root` (AC-13 covers known locations).
  - Optional cosmetic follow-up (out of scope for this fix): manually correct the placeholder body of GitHub issue #399.
  - Known pre-existing discrepancy, not addressed here: `.claude/rules/typescript.md` names Vitest while the extension uses Jest; flag for a separate docs correction if desired.
- Links: issue #401 (https://github.com/drmoisan/drm-copilot/issues/401); `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/issue.md`; `research/2026-07-22T10-20-mcp-promotion-tooling-defects-research.md`; related evidence: GitHub issues #399 (broken cell) and #401 (correct full-bug rendering).
