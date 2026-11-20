<!-- markdownlint-disable-file -->

# Task Research Notes: codex-pretooluse-hook-transport (Issue #415)

## Research Executed

### File Analysis

- `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/issue.md`
  - Measured failure table (exit 2 for all admitted tool names on the seven handlers), root-cause notes, and the four-case test contract (issue.md:37-49, 65-79).
- `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md`
  - Repro contract: "For an allowed operation the handler exits 0 with no stdout" (spec.md:35); same measured table (spec.md:40-50).
- `.codex/config.toml`
  - Three `PreToolUse` matcher groups: `^Bash$` (lines 119-150), `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` (lines 152-183), `^(apply_patch|Edit|Write)$` (lines 185-234). The seven failing handlers are registered under the third group (lines 188-234). Git status shows this file is locally modified (uncommitted) in the current worktree.
- `.codex/hooks/check-python-test-purity.ps1` (223 lines)
  - Payload validator asserts `tool_name -eq 'apply_patch'` (156-157); passthrough branch when `tool_input` has `file_path` (167-169); apply-patch marker parsing (176-201); throws on empty `command` (172-173) and on marker-free commands (180-181). Docstring documents `'content' for Write, 'new_string' for Edit` (8-11).
- `.codex/hooks/enforce-python-batch-budget.ps1` (285 lines)
  - Same `apply_patch`-only assertion (228-229); additionally requires non-empty `session_id` (231-234); throws on empty command (246-247) and marker-free command (254-255); entrypoint writes state under `.codex/state/python-batch-budget.<session>.json` (184-207, 264-280).
- `.codex/hooks/check-powershell-test-purity.ps1`
  - Mirrors the Python purity hook: `apply_patch`-only assertion (156-157), `cannot map` throw (173), unrecognized-command throw (181).
- `.codex/hooks/enforce-powershell-batch-budget.ps1`
  - Mirrors the Python budget hook: `apply_patch`-only assertion (230-231), missing-session throw (233-234), `cannot map` throw (248-249), unrecognized-command throw (256-257).
- `.codex/hooks/enforce-evidence-locations.ps1` (219 lines)
  - `apply_patch`-only assertion (160-161); path extraction from patch markers (178-184); throws on empty command (175-176) and zero extracted paths (183-184). Docstring (32-35) claims allowed paths emit an explicit `allow` envelope, but the entrypoint (191-210, 218) returns 0 with no stdout on allow — the docstring is stale relative to the actual and required behavior.
- `.codex/hooks/enforce-checkpoint-monotonic.ps1` (421 lines)
  - `apply_patch`-only assertion in `ConvertFrom-CodexCheckpointHookPayload` (318-319); `ConvertTo-CodexApplyPatchCheckpointInput` throws on empty command (333-334), marker-free command (341-342), missing on-disk update source (364-365), and unappliable hunks (391-392). Fail-closed deny for checkpoint deletion/empty content (233-238) and invalid JSON (241-249). Docstring states Edit calls are allowed because partial patches cannot be validated (37-39).
- `.codex/hooks/enforce-completion-consistency.ps1` (426 lines)
  - Dot-sources `enforce-checkpoint-monotonic.ps1` at line 45 to reuse its payload validator and apply-patch adapter; this is why its stderr diagnostics name `enforce-checkpoint-monotonic` (issue.md:48). The messages are shared functions, not copied-and-unrenamed text. Dot-sources `enforce-completion-helpers.ps1` (49-50). Carries a working Edit-path (`old_string`/`new_string`) read-then-validate implementation, `Resolve-EditedCheckpointContent` (263-315), used at 362-371.
- `.codex/hooks/enforce-completion-helpers.ps1` (164 lines)
  - Shared-helper precedent: entrypoint-free, dot-sourced validation helpers (docstring 14-16).
- `.codex/hooks/enforce-epic-planning-only.ps1` (working handler, second matcher group)
  - Accepts all admitted names; branches on `tool_name` (`apply_patch` 187, `Bash` 218, `mcp__*` 226-243); reads `tool_input.command` for Bash/apply_patch and `tool_input.workspace_root` for MCP tools (232-236); returns `$null` (allow, exit 0, no stdout) for non-matching cases (285-288); exit 2 only from the catch block (289-292).
- `.codex/hooks/enforce-epic-wave-barrier.ps1` and `.codex/hooks/enforce-epic-child-worktree-binding.ps1` (working handlers)
  - Classify `Edit`/`Write` by tool name only, never dereferencing their `tool_input` fields (wave-barrier 140-142; worktree-binding 69-71); read `tool_input.command` for `Bash`/`shell_command` (worktree-binding 119-123).
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (243 lines)
  - The existing contract suite for these ten PreToolUse hooks; detailed inventory below.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
  - Asserts root/bundle byte-identity for `.codex/config.toml` and listed hook files (10-34, 162-170) and a 500-line cap on every `.codex/hooks/*.ps1`, `.codex/scripts/*.ps1`, `.codex/agents/*.toml`, and `config.toml` (172-183).
- `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`
  - Asserts the bundled mirrors of `enforce-completion-consistency.ps1` and `enforce-completion-helpers.ps1` are byte-identical to the canonical hooks (61-70).
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py`
  - Publishes root `.codex`/`.agents` trees plus the shared routing config into a *destination workspace* (docstring 1-7; `ROOT_FOLDERS` 66; `push_down_customizations` 203-258). It is a consumer-repo publisher, not a root-to-bundle sync inside this repo.
- `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
  - TypeScript port of the same publisher (1-12, 260-296).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
  - Parity gate: every root `.codex`/`.agents` file must exist in the bundle with identical text (206-219); routing config must not be duplicated inside the bundle (199-203); both configs must retain the full MCP transport (222-226).
- `scripts/dev-tools/Invoke-FullRelease.ps1`
  - Release gate requires both root and bundled `config.toml` to exist (243-261); existence only, not equality.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`
  - Compared line-by-line against root: lines 1-121 and 152-253 are identical. The only divergence is the ordering of three handlers inside the `^Bash$` group: root order is `enforce-epic-merge-gate`, `enforce-epic-worktree-removal-gate`, `enforce-orchestration-preimplementation-gate` (root config 134-150); bundle order is `enforce-orchestration-preimplementation-gate`, `enforce-epic-merge-gate`, `enforce-epic-worktree-removal-gate` (bundle config 134-150). Registration sets and matchers are identical.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`
  - Bundle-only file. It is a converted Claude-transport hook ("Reads tool input JSON from the CLAUDE_TOOL_INPUT environment variable", lines 8-11) and is not registered in either `config.toml`.
- `docs/features/potential/promoted/2026-07-09-codex-pr-author-hook-not-wired.md`
  - The bundle-only `enforce-pr-author-skill.ps1` is a pre-existing, separately tracked divergence: Issue #335 (lines 1-14, 55-58).
- `extensions/drm-copilot/src/mcp-tool-definitions.ts`
  - PoshQC MCP tool schemas: `run_poshqc_format` (248-267), `run_poshqc_analyze` (269-288), `run_poshqc_test` (290-309), `run_poshqc_analyze_autofix` (311-321); all take required `workspace_root` and optional `scan_folders` (string array).

### Code Search Results

- `tool_input|shell_command|apply_patch` in `scripts/dev_tools/codex_native_converter/`
  - No matches. The codex-native converter converts customization assets (agents, skills, hook *registrations*); it contains no PreToolUse payload or `tool_input` shape definitions.
- `PreToolUse` in `scripts/dev_tools/codex_native_converter/` and `tool_input` in `extensions/drm-copilot/src/lib/codex-native-converter/`
  - No matches in either tree.
- `tests/fixtures/codex_native_converter/**`
  - Fixtures are Claude/Copilot customization trees (`.claude/`, `.github/`), not hook payload fixtures. No `tool_input` evidence here.
- `shell_command` repo-wide
  - Payload-consuming matches only in `.codex/hooks/enforce-epic-wave-barrier.ps1:149`, `.codex/hooks/enforce-epic-child-worktree-binding.ps1:119-123`, and `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1:445-452` (fixture: `tool_name = 'shell_command'; tool_input = @{ command = ... }`).

### External Research

- None required or performed. All findings are grounded in repository evidence. Live Codex CLI payload documentation was not fetched; where repository evidence is insufficient this is stated explicitly below.

### Project Conventions

- Standards referenced: `.claude/rules/powershell.md` (toolchain, change budget, seams, Pester rules), `.claude/rules/general-unit-test.md` (no temp files in tests, test location), `.claude/rules/general-code-change.md` (500-line file limit), `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (this artifact's naming).
- Instructions followed: `research-issue` skill contract (`.claude/skills/research-issue/SKILL.md`), Task Researcher template (`.github/agents/task-researcher.agent.md`).

## Key Discoveries

### Hard Scope Constraints (recorded verbatim from the delegation)

1. Do NOT create, modify, or delete any file under `.claude/` — including any bundled `.claude` copy. Modifying `.claude` hook configuration as a workaround is prohibited.
2. Do NOT disable, remove, bypass, or weaken any Codex hook registration in `.codex/config.toml` or its bundled copy.
3. Each handler's existing allow/deny POLICY must be preserved exactly. Only the Codex input/output transport, tool-name admission, `tool_input` mapping, and error handling may change.
4. Scope is `.codex/hooks/**`, `.codex/config.toml`, the bundled Codex customization copy, and the corresponding tests under `tests/`.

### Verification of the Orchestrator's Diagnosis

Verified by code reading (this agent has no process-execution tool; runtime exit codes are corroborated by the measured table in issue.md:37-49):

- The seven handlers' payload validators assert `tool_name -eq 'apply_patch'`: `check-python-test-purity.ps1:156-157`, `check-powershell-test-purity.ps1:156-157`, `enforce-python-batch-budget.ps1:228-229`, `enforce-powershell-batch-budget.ps1:230-231`, `enforce-evidence-locations.ps1:160-161`, `enforce-checkpoint-monotonic.ps1:318-319`. `enforce-completion-consistency.ps1` has no validator of its own; it dot-sources the checkpoint-monotonic hook (line 45) and calls `ConvertFrom-CodexCheckpointHookPayload` (line 412), which is why its stderr names the neighbor hook. This refines the orchestrator's "copied validator" description: the messages are shared, not copied.
- The `apply_patch` unmapped-input throws exist at the sites listed under "Unmapped-Input Semantics" below.
- All seven entrypoints read stdin via `[Console]::In.ReadToEnd()` and none reads `$env:CLAUDE_*`; both facts are already asserted by an existing test (`legacy-codex-hook-contracts.Tests.ps1:109-115`).
- The bundle divergences are confirmed and characterized under "Bundled-Copy Parity" below.

### Research Question 1 — Codex Native `tool_input` Shapes (repository evidence)

Payload envelope (fixture used by the contract suite): `session_id`, `transcript_path`, `cwd`, `hook_event_name`, `model`, `permission_mode`, `turn_id`, `tool_name`, `tool_use_id`, `tool_input` — `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30-41`.

| Tool name | `tool_input` shape | Evidence |
|---|---|---|
| `Bash` | `{ command: string }` | `legacy-codex-hook-contracts.Tests.ps1:120,155`; consumed at `enforce-epic-planning-only.ps1:218-220` |
| `shell_command` | `{ command: string }` | `enforce-epic-child-worktree-binding.ps1:119-123`; fixture `epic-child-launch-hardening.Tests.ps1:445-452` |
| `apply_patch` | `{ command: string }` where `command` is patch text delimited by `*** Begin Patch` / `*** End Patch` with per-file markers `*** Add File:`, `*** Update File:`, `*** Delete File:`, `*** Move to:` | fixture `legacy-codex-hook-contracts.Tests.ps1:44-48,118`; parsers `enforce-evidence-locations.ps1:178-181`, `enforce-checkpoint-monotonic.ps1:337-340`, `enforce-epic-planning-only.ps1:64-67` |
| `Edit` | `{ file_path: string, old_string: string, new_string: string }` | docstrings `check-python-test-purity.ps1:8-11`, `enforce-checkpoint-monotonic.ps1:37-39`; consuming implementation `enforce-completion-consistency.ps1:288-299` (reads `old_string`/`new_string`) |
| `Write` | `{ file_path: string, content: string }` | same docstrings; content consumed at `enforce-checkpoint-monotonic.ps1:233-249` |
| `mcp__*` | the MCP tool's own argument object (e.g., `workspace_root`) | `enforce-epic-planning-only.ps1:230-236` |

**Evidence sufficiency statement.** The repository contains no captured live Codex PreToolUse payloads for `Edit` or `Write`. The codex-native converter (`scripts/dev_tools/codex_native_converter/`, `extensions/drm-copilot/src/lib/codex-native-converter/`) and its fixtures (`tests/fixtures/codex_native_converter/`) contain zero `tool_input` payload definitions (verified by search; no matches). The `Edit`/`Write` shapes above derive from handler docstrings, the working Edit-path implementation in `enforce-completion-consistency.ps1`, and in-repo test fixtures; the currently-passing handlers in the second matcher group never dereference `Edit`/`Write` `tool_input` fields (`enforce-epic-wave-barrier.ps1:140-142`, `enforce-epic-child-worktree-binding.ps1:69-71`), so they do not confirm field names. The repair must therefore tolerate absent fields: when a well-formed payload's `tool_input` carries no `file_path`, the handler must allow, not throw.

**Deny-envelope shape (repo-native contract).** exit 0 plus one compact JSON object on stdout: `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` — asserted by `legacy-codex-hook-contracts.Tests.ps1:166-172` and emitted by every working handler (e.g., `enforce-epic-planning-only.ps1:49-56`). Whether the live Codex CLI parses this envelope cannot be verified from repository evidence alone; however, the handlers that already emit it exit 0 and are explicitly "not implicated" in the runtime failures (issue.md:51), and the `invalid pre-tool-use JSON output` symptom is attributed to the nonzero exits (issue.md:16). The repair keeps this envelope unchanged (constraint 3).

### Research Question 3 — Unmapped-Input Semantics

Required contract (spec.md:35; issue.md:77): exit 2 is reserved for malformed or missing required Codex stdin. Concretely:

- **Exit 2 (unchanged):** empty stdin; invalid JSON; missing/null `tool_input`; and, for the two batch-budget hooks only, missing `session_id` (it is a required envelope field their state keying depends on: `enforce-python-batch-budget.ps1:231-234`, `enforce-powershell-batch-budget.ps1:233-234`).
- **Allow (exit 0, no stdout) — currently exit 2, must change:** any well-formed payload that names no file the hook governs. This includes: an admitted tool name whose `tool_input` has no `file_path` and no `command`; an `apply_patch` `command` containing no file markers; and (defensively) a well-formed payload whose `tool_name` is outside `{apply_patch, Edit, Write}` — the matcher already prevents these, and a well-formed payload is by definition not a transport failure.

Every site that currently conflates the two (throws, which the entrypoint `catch` converts to exit 2):

| File | Tool-name assertion | Empty `command` | Marker-free `command` | Other |
|---|---|---|---|---|
| `check-python-test-purity.ps1` | 156-157 | 172-173 | 180-181 | — |
| `check-powershell-test-purity.ps1` | 156-157 | 173 | 181 | — |
| `enforce-python-batch-budget.ps1` | 228-229 | 246-247 | 254-255 | — |
| `enforce-powershell-batch-budget.ps1` | 230-231 | 248-249 | 256-257 | — |
| `enforce-evidence-locations.ps1` | 160-161 | 175-176 | 183-184 | — |
| `enforce-checkpoint-monotonic.ps1` | 318-319 | 333-334 | 341-342 | 364-365 (missing update source on disk), 391-392 (unappliable hunk) |
| `enforce-completion-consistency.ps1` | inherits all checkpoint-monotonic sites via dot-source (line 45) | | | |

Latent defect worth fixing in the same transport change: `ConvertTo-CodexApplyPatchCheckpointInput` reconstructs post-patch content for *every* file in an Update patch by reading the source file from disk (`enforce-checkpoint-monotonic.ps1:364-367`), so an `apply_patch` Update touching any file with a missing source or non-applying hunk exits 2 even when the hook governs none of the patched files. Content reconstruction should run only for the governed checkpoint path; reconstruction failure for ungoverned paths is an allow. The fail-closed deny for the governed checkpoint (empty content → deny, 233-238; invalid JSON → deny, 241-249) is POLICY and must be preserved exactly.

### Research Question 4 — Existing Test Inventory and Gaps

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` currently covers, for the ten PreToolUse hooks plus `validate-feature-review-coverage.ps1`:

1. Parse-check + 500-line cap for root and bundled copies (83-99).
2. Root↔bundle hash parity for the listed hook files (101-107).
3. Static transport assertions: `[Console]::In.ReadToEnd()` present, `$env:CLAUDE_` absent (109-115).
4. Valid safe payload → exit 0, empty stdout, empty stderr — **for `apply_patch` (and `Bash`) payloads only** (117-134). Poisoned `CLAUDE_TOOL_INPUT`/`CLAUDE_SESSION_ID` are baked into *every* process invocation (65-66), so the poisoned-env case is covered wherever a process-level case exists.
5. Malformed stdin → exit 2, empty stdout, nonempty stderr — all hooks (136-144).
6. Forbidden payload → exit 0 + deny envelope — for `apply_patch`/`Bash` payloads: both purity hooks, evidence-locations, checkpoint-monotonic, completion-consistency, validate-bash, promotion-mcp-only (146-173). Checkpoint fail-closed deny cases (175-191).
7. Batch-budget and preimplementation deny — unit-level only, via dot-sourced pure functions with injected state (193-211).
8. Apply-patch mapping units: in-memory Update reconstruction and Move-to destination extraction (213-229).

Per-handler gap matrix against the four required deterministic process-level cases:

| Case | apply_patch | Edit | Write |
|---|---|---|---|
| Valid safe payload → 0 / empty / empty | present (117-134) | **missing (all 7)** | **missing (all 7)** |
| Forbidden payload → 0 / deny envelope | present for 5 of 7; batch budgets unit-level only | **missing (all 7)** | **missing (all 7)** |
| Malformed stdin → 2 / empty stdout / stderr | present (136-144) | n/a (tool-name-independent) | n/a |
| Poisoned `CLAUDE_*` env → stdin-only behavior | present (65-66 + 117-134) | **missing** (blocked today: Edit exits 2) | **missing** |

Additional missing cases: well-formed `apply_patch` with unmapped `tool_input` → allow (today exit 2); `enforce-completion-consistency` stderr naming itself on malformed stdin; and the integration case from issue.md:78 (run every registered handler against every tool name its matcher admits, asserting exit 0 on a benign payload — the registration list can be read from `.codex/config.toml` the way `codex-epic-runtime-contracts.Tests.ps1:37-83` already reads it).

**No-temp-file stdin pattern (mandatory to reuse).** Tests feed stdin without temporary files via `System.Diagnostics.ProcessStartInfo` with `RedirectStandardInput = $true`, writing the payload with `$process.StandardInput.Write($PayloadRaw)` then `Close()` (`legacy-codex-hook-contracts.Tests.ps1:50-80`). Repository policy prohibits temp files in tests (`.claude/rules/general-unit-test.md`, "Creation and use of temporary files in tests is strictly prohibited").

**Side-effect caution for budget hooks.** The batch-budget entrypoints write state files under `.codex/state/` inside the repo (`enforce-python-batch-budget.ps1:184-207`); the existing safe-payload process test avoids this by targeting `README.md` (non-`.py`/non-`.ps1`). New Edit/Write safe cases must do the same, and forbidden budget cases should remain unit-level with injected seams (155-161) rather than process-level. A stray untracked `.codex/state/powershell-batch-budget.<session>.json` in this worktree confirms the entrypoint writes into the repo; it must not be committed.

### Research Question 5 — Bundled-Copy Parity Mechanism

- **Direction and authority.** Root `.codex/` is authoritative. The MCP tool `push_down_codex_and_agents_customizations` publishes the `.codex`/`.agents` trees plus the shared routing config into a *consumer destination workspace* (`scripts/dev_tools/push_down_codex_and_agents_customizations.py:1-7, 60-71, 203-258`; TS port `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts:260-296`). Nothing automatically syncs root → bundle inside this repository; the bundle at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` is updated by manually mirroring files, and drift is caught by test gates:
  1. `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:206-219` — every root `.codex`/`.agents` file must exist in the bundle with identical text (direction: root ⊆ bundle).
  2. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:101-107` — SHA hash parity for the eleven listed hook files.
  3. `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:162-170` — SHA hash parity for runtime paths including `.codex/config.toml`.
  4. `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1:61-70` — byte parity for the completion hook and its helper.
  5. Release gate `scripts/dev-tools/Invoke-FullRelease.ps1:243-261` — both configs must exist (existence only).
- **What the fix must do:** every changed or added file under root `.codex/hooks/` (including any new shared helper) must be mirrored byte-for-byte into the bundle, and any new hook or helper file should be added to the parity lists in the Pester suites and to `pack-manifests/core.json` if it must publish to consumers (precedent: `codex-epic-runtime-contracts.Tests.ps1:134-160` asserts hook files are listed in the core pack manifest).
- **Divergence 1 — `config.toml` ordering.** The only textual difference is the ordering of three handlers inside the `^Bash$` matcher group (root 134-150 vs bundle 134-150; all other lines identical). Root `.codex/config.toml` is *locally modified and uncommitted* (git status `M .codex/config.toml` at session start), so the committed root file may already match the bundle; `codex-epic-runtime-contracts.Tests.ps1:162-170` fails while the trees differ. The registration sets and matchers are identical in both files, and ordering within one matcher group is not policy-bearing (each handler runs independently; any deny blocks the tool call), so restoring byte-identity in either order satisfies constraint 2. Recommendation: run `git diff .codex/config.toml`; if the reorder is an incidental uncommitted local change, revert it; if it is intentional, mirror the same bytes into the bundle. Either way the two files must end byte-identical.
- **Divergence 2 — bundle-only `enforce-pr-author-skill.ps1`.** Pre-existing and separately tracked as Issue #335 (`docs/features/potential/promoted/2026-07-09-codex-pr-author-hook-not-wired.md:14,55-58`). The file is not registered in either `config.toml`, and it still uses the legacy Claude transport (`CLAUDE_TOOL_INPUT`, file lines 8-11). Recommendation for byte-identical trees: delete the orphaned bundle file in this fix and record in #415/#335 evidence that #335's future fix must reintroduce the hook on *both* sides with stdin transport plus a `[[hooks.PreToolUse]]` registration. Deleting an unregistered file removes no registration and weakens no active enforcement, so it does not violate constraint 2. Alternative (if the planner prefers zero interaction with #335's subject matter): leave the file and document the divergence as tracked; note that no existing automated gate flags it, so byte-identity would remain unachieved.

### Research Question 6 — Toolchain Commands (PowerShell quality loop)

Per `.claude/rules/powershell.md`, in order, restarting from step 1 if any step fails or changes files:

1. Format: `mcp__drm-copilot__run_poshqc_format` — required `workspace_root` (repo root), optional `scan_folders` (`extensions/drm-copilot/src/mcp-tool-definitions.ts:248-267`).
2. Analyze: `mcp__drm-copilot__run_poshqc_analyze` — same parameters (269-288). Optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix` (311-321).
3. Type checking: not applicable to PowerShell (skip).
4. Test: `mcp__drm-copilot__run_poshqc_test` — same parameters; when `scan_folders` is omitted the scan set comes from `config/poshqc-scan.json` (290-309).

Because the parity gates include pytest, the executor must also run the Python suite for the parity contract (`poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` at minimum; full `poetry run pytest --cov --cov-branch` per `.claude/rules/python.md` if any Python file is touched — none is expected to be).

### Technical Requirements

- Exit-code contract per handler: 0 + empty stdout = allow; 0 + single-line deny envelope on stdout = deny; 2 + stderr = malformed/missing required stdin only.
- Behavior must depend only on stdin (already true; regression-tested via poisoned `CLAUDE_*` env vars).
- Every `.codex/hooks/*.ps1` file (existing and new) ≤ 500 lines, enforced twice (`legacy-codex-hook-contracts.Tests.ps1:96`; `codex-epic-runtime-contracts.Tests.ps1:172-183`). `enforce-checkpoint-monotonic.ps1` (421) and `enforce-completion-consistency.ps1` (426) are close to the cap; inlining admission/mapping logic per-file would risk exceeding it.
- PowerShell change budget (`.claude/rules/powershell.md`): per-batch cap of 3 production + 3 test files. Seven hooks + one shared helper + bundle mirrors exceed one batch; the work must be split into batches (see Implementation Guidance).
- All parity gates listed under Research Question 5 must pass after the change.

**Mandatory unachievable objective callout**: none. All objectives are achievable with repository-local changes. One evidentiary limitation stands: the exact live Codex CLI `Edit`/`Write` payload field names cannot be confirmed from repository evidence (no captured payloads exist); the recommended tolerant mapping (allow when `file_path` is absent) makes the repair safe under either outcome.

## Recommended Approach

Introduce one new shared, entrypoint-free transport module at `.codex/hooks/codex-pretooluse-file-mapping.ps1` (name indicative), dot-sourced by all seven handlers, and repair each handler's entrypoint to use it. The module provides:

1. `ConvertFrom-CodexPreToolUsePayload -PayloadRaw <string> -HookName <string>` — parses stdin, throws (→ exit 2) only for empty input, invalid JSON, or missing `tool_input`; every thrown message begins with the supplied `-HookName`, eliminating the cross-naming defect in `enforce-completion-consistency` (which today borrows `enforce-checkpoint-monotonic`'s validator via dot-source, `enforce-completion-consistency.ps1:45,412`). The `tool_name == 'apply_patch'` assertion is removed; admitted names are `apply_patch`, `Edit`, `Write`; any other well-formed name maps to zero file edits (allow).
2. `ConvertTo-CodexFileEditInput -Payload <object> [-ResolveUpdateContent]` — returns an array of `{ file_path, content?, old_string?, new_string? }` records: `Edit`/`Write` pass `tool_input` through when `file_path` is present (the shapes in Research Question 1); `apply_patch` parses the existing `*** (Add|Update|Delete) File:` / `*** Move to:` markers (logic lifted from `enforce-checkpoint-monotonic.ps1:324-400` and siblings). Unmapped input (no `file_path`, no `command`, or marker-free `command`) returns an empty array — the caller allows with exit 0 and no stdout. The expensive on-disk Update reconstruction (needed only by the two checkpoint hooks) runs only when requested and only for the governed checkpoint path; reconstruction failure for ungoverned paths yields no record (allow), while the checkpoint hooks' fail-closed denials for the governed file are preserved exactly.

Each of the seven handlers keeps its policy functions untouched (constraint 3) and replaces only its `ConvertFrom-Codex*Payload` / `ConvertTo-Codex*Input` / `Get-Codex*Path` plumbing with calls into the shared module. `enforce-completion-consistency.ps1` stops dot-sourcing `enforce-checkpoint-monotonic.ps1` for transport (it may still share the checkpoint-specific reconstruction through the module). Batch-budget hooks keep their `session_id` requirement as exit 2. Stale docstrings (`enforce-evidence-locations.ps1:32-35` claiming an allow envelope is written) are corrected to the actual allow-silently contract. Every changed/added hook file is mirrored byte-for-byte into the bundle, the new module is added to the Pester parity lists and `pack-manifests/core.json`, `config.toml` byte-identity is restored (either ordering), and the bundle-only `enforce-pr-author-skill.ps1` is deleted with a cross-reference note for Issue #335.

Why this approach: the shared-helper precedent already exists (`enforce-completion-helpers.ps1`, dot-sourced with the `$MyInvocation.InvocationName -eq '.'` guard used by every hook); the two checkpoint hooks are at 421/426 lines and cannot absorb per-file admission logic under the 500-line gates; the mapping logic is currently duplicated with drift across five files (two distinct marker-regex variants: content-reconstructing at `check-python-test-purity.ps1:176-201` vs path-only at `enforce-evidence-locations.ps1:178-184`), and a seven-way inline fix would widen that drift.

**Rejected alternatives** (brief):
- *Per-handler inline fix (no shared module):* duplicates the admission and mapping change seven times, pushes the two 420+-line checkpoint hooks toward the 500-line cap, and leaves the existing two-variant marker-parsing drift in place. Rejected for maintainability and the file-size gates.
- *Extending `enforce-completion-helpers.ps1` as the shared home:* that file is documented as completion-consistency-specific validation helpers (docstring lines 3-16) and is byte-parity-tracked by a Claude-side test (`enforce-completion-consistency-codex.Tests.ps1:70`); mixing generic transport into it muddies its contract. A new sibling module keeps concerns separate. Rejected.
- *Narrowing the matcher to `^apply_patch$` so validators match:* weakens hook coverage for `Edit`/`Write` operations and touches registrations. Prohibited by constraints 2 and 3. Rejected.
- *Copying `enforce-pr-author-skill.ps1` to root to achieve byte-identity:* imports a known-broken legacy-transport hook into the authoritative tree and pre-empts Issue #335's design. Rejected in favor of deleting the unregistered orphan from the bundle.

## Automation Feasibility

All repair steps are automatable with no human interaction:

- File edits (seven hooks + new module + docstring corrections) and byte-for-byte bundle mirroring: `Edit`/`Write`/copy operations.
- `config.toml` divergence resolution: deterministic — `git diff .codex/config.toml` decides whether the uncommitted local reorder is reverted or mirrored; both orderings are policy-equivalent (identical registration sets and matchers), so no human judgment is required.
- Bundle orphan deletion plus an evidence note referencing Issue #335: file operation plus artifact write.
- Verification: PoshQC MCP loop (format → analyze → test), targeted `poetry run pytest` for the parity contract, and the extended process-level Pester cases using the temp-file-free stdin pattern already in the suite.

Residual risks (not blockers): (1) live Codex CLI payload field names for `Edit`/`Write` are unconfirmable from repo evidence — mitigated by tolerant mapping (unmapped → allow) and by keeping the deny envelope unchanged; (2) if the fix is ever executed from inside a Codex session, the currently-broken hooks would fire on the fix's own edits — not applicable in the Claude runtime performing this work; (3) `.codex/state/*` untracked session files must be excluded from the commit.

## Implementation Guidance

- **Objectives**: All seven handlers accept every tool name their matcher admits; well-formed-but-unmapped input allows (exit 0, no stdout); exit 2 reserved for malformed/missing stdin; each handler's stderr names itself; allow/deny policy byte-preserved; root and bundle `.codex` trees byte-identical; all existing and new gates green.
- **Key Tasks**:
  1. Add `.codex/hooks/codex-pretooluse-file-mapping.ps1` (shared payload parse + admission + mapping; entrypoint-free; ≤ 500 lines).
  2. Rewire the seven handlers' entrypoints to it; remove the `apply_patch`-only assertions and the unmapped-input throws listed in Research Question 3; keep batch-budget `session_id` exit-2; keep checkpoint fail-closed denials; fix stale docstrings.
  3. Restore `config.toml` byte-identity (decide via `git diff`); mirror all changed/added hook files into the bundle; delete bundle-only `enforce-pr-author-skill.ps1` with an #335 cross-reference; add the new module to `legacy-codex-hook-contracts.Tests.ps1` parity/static lists and `pack-manifests/core.json`.
  4. Add process-level Pester cases per handler for `Edit` and `Write` (safe → 0/empty/empty; forbidden → 0/deny envelope; poisoned `CLAUDE_*` inherited from the harness) plus the `apply_patch` unmapped-allow case and a config-driven integration case (every registered handler × every admitted tool name × benign payload → exit 0). Place new cases in a new file under `tests/scripts/codex-hooks/` to respect the 500-line limit; reuse the `ProcessStartInfo` stdin pattern; use non-`.py`/non-`.ps1` target paths for budget-hook safe cases to avoid state writes.
  5. Run the PowerShell loop (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`, restarting on any failure/change) and the pytest parity contract.
- **Dependencies**: none new. PowerShell 7+, Pester 5, existing PoshQC MCP tools, existing pytest suite. Change-budget note: the touched-file count (7 hooks + 1 module + bundle mirrors + tests) exceeds the per-batch PowerShell cap of 3 production + 3 test files; the planner must split execution into batches (e.g., module + two hooks per batch, bundle mirror in the same batch as its root file) or record an approved cap override.
- **Success Criteria**: issue.md's measured table reproduces as all-zero exits with empty stdout for benign payloads on all three admitted tool names × seven handlers; forbidden payloads yield exit 0 + deny envelope with each handler's own name in diagnostics; malformed stdin yields exit 2/stderr; `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `enforce-completion-consistency-codex.Tests.ps1`, and `test_push_down_codex_and_agents_resource_contracts.py` all pass; root and bundle `.codex` trees are byte-identical.
