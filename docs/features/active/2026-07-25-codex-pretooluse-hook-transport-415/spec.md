# 2026-07-25-codex-pretooluse-hook-transport (Spec)

- **Issue:** #415
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-25
- **Status:** Ready for Planning
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole authoritative acceptance-criteria source; no `user-story.md` exists for this feature)

## Context
Eight Codex `PreToolUse` handlers are registered under the `^(apply_patch|Edit|Write)$` matcher in `.codex/config.toml` (`.codex/config.toml:186-234`). Seven of them exit 2 on every invocation, because each handler's payload validator hard-requires `tool_name == 'apply_patch'` and rejects the `Edit` and `Write` tool names the matcher admits. The eighth, `enforce-orchestration-preimplementation-gate`, admits only `Bash` and `apply_patch` (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:242-244`) and therefore exits 2 for `Edit` and `Write` with the same class of defect (measured: `Edit` exit=2, `Write` exit=2, `apply_patch` exit=0). The result is repeated nonzero `PreToolUse` hook exits and `invalid pre-tool-use JSON output` in Codex sessions.

The eight affected handlers are: `check-python-test-purity`, `enforce-python-batch-budget`, `check-powershell-test-purity`, `enforce-powershell-batch-budget`, `enforce-evidence-locations`, `enforce-checkpoint-monotonic`, `enforce-completion-consistency`, and `enforce-orchestration-preimplementation-gate` (the last fails only for `Edit`/`Write`; its existing `Bash` and `apply_patch` handling must be preserved exactly).

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell 7 hook handlers)
- Command/flags used: `pwsh -NoProfile -File .codex/hooks/<handler>.ps1` with a `PreToolUse` payload on stdin
- Data source or fixture: `.codex/config.toml` hook registrations

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every Codex file edit fires seven failing hooks, so the enforcement surface those hooks implement (test purity, batch budget, evidence locations, checkpoint monotonicity, completion consistency) is not actually applied to `Edit` or `Write` operations.


## Repro & Evidence
Steps to Reproduce:
1. Pipe a well-formed Codex `PreToolUse` payload with `tool_name = "Edit"` and a benign `tool_input` into `.codex/hooks/enforce-evidence-locations.ps1`.
2. Observe the exit code and stderr.
3. Repeat for `tool_name = "Write"` and for the other six handlers registered under the `^(apply_patch|Edit|Write)$` matcher.

Expected:
For an allowed operation the handler exits 0 with no stdout. A handler registered under a matcher that admits `Edit` and `Write` must accept those tool names and evaluate its policy against the corresponding `tool_input`, not reject the payload.

Actual:
Every handler in the `^(apply_patch|Edit|Write)$` group exits 2 for all three admitted tool names. Measured directly (process-level execution of every registered handler):

```
check-python-test-purity         Edit         exit=2  stderr=[check-python-test-purity requires a PreToolUse apply_patch payload.]
check-python-test-purity         Write        exit=2  stderr=[check-python-test-purity requires a PreToolUse apply_patch payload.]
check-python-test-purity         apply_patch  exit=2  stderr=[check-python-test-purity cannot map tool_input to a file edit.]
enforce-python-batch-budget      Edit         exit=2  stderr=[enforce-python-batch-budget requires a PreToolUse apply_patch payload.]
check-powershell-test-purity     Edit         exit=2  stderr=[check-powershell-test-purity requires a PreToolUse apply_patch payload.]
enforce-powershell-batch-budget  Edit         exit=2  stderr=[enforce-powershell-batch-budget requires a PreToolUse apply_patch payload.]
enforce-evidence-locations       Edit         exit=2  stderr=[enforce-evidence-locations requires a PreToolUse apply_patch payload.]
enforce-checkpoint-monotonic     Edit         exit=2  stderr=[enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.]
enforce-completion-consistency   Edit         exit=2  stderr=[enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.]
```

The defect has two halves:
1. `Edit` / `Write` payloads exit 2 because each payload validator asserts `tool_name -eq 'apply_patch'`.
2. `apply_patch` payloads whose `tool_input` carries neither `file_path` nor apply-patch file markers exit 2 instead of allowing. Well-formed input that names no file or command the hook governs is an allow, not a transport failure; conflating the two is the second half of the defect.

The handlers registered under `^Bash$` and under `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` exit 0 with empty stdout for every admitted tool name and are not implicated. They must not be behaviorally changed; they require regression coverage only.

Logs / Screenshots:
- [x] Attached minimal logs or snippet
- Snippet: see the measured table under **Actual**.


## Scope & Non-Goals
- In scope:
  - Repair the seven handlers listed in Context so every one honors the native Codex stdin/stdout contract (see Technical specifications) for every tool name the `^(apply_patch|Edit|Write)$` matcher admits.
  - Introduce one new shared, entrypoint-free transport module under `.codex/hooks/` (indicative name: `codex-pretooluse-file-mapping.ps1`) providing payload parsing, tool-name admission, and `tool_input`-to-file-edit mapping, dot-sourced by all seven handlers. Rationale: `enforce-checkpoint-monotonic.ps1` (420 lines gate-measured) and `enforce-completion-consistency.ps1` (425 lines gate-measured) cannot absorb inline mapping logic under the 500-line cap, and the mapping logic is currently duplicated with drift across five files.
  - Parameterize the shared validator error messages with a `-HookName` argument so each handler's stderr names itself (fixes `enforce-completion-consistency` reporting `enforce-checkpoint-monotonic` in its diagnostics).
  - Correct stale docstrings (`enforce-evidence-locations.ps1` claims an allow envelope is emitted; the actual and required behavior is allow-silently).
  - Restore byte-identity between root `.codex/` and the bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`: resolve the `config.toml` handler-ordering divergence (decide via `git diff .codex/config.toml`; either ordering is policy-equivalent), mirror every changed or added hook file, delete the bundle-only unregistered `enforce-pr-author-skill.ps1` with a cross-reference note for issue #335, and retain all existing parity assertions.
  - Add the new shared module to the Pester parity/static lists (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`) and to `pack-manifests/core.json`.
  - Process-level Pester regression coverage per the Test Strategy, including regression-only coverage for the non-implicated `^Bash$` and `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` handler groups.
- Out of scope / non-goals:
  - Any change to any file under `.claude/`, including any bundled `.claude` copy (hard constraint 1).
  - Any change to hook registrations, matchers, or the set of registered handlers in `.codex/config.toml` or its bundled copy, other than restoring byte-identity of the existing registrations (hard constraint 2).
  - Any change to any handler's allow/deny policy (hard constraint 3). Checkpoint fail-closed denies remain denies.
  - Behavioral changes to the handlers in the `^Bash$` and `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` groups.
  - Reintroducing or re-wiring `enforce-pr-author-skill.ps1`; that is issue #335. This fix only deletes the unregistered legacy-transport orphan from the bundle to achieve byte-identity and records the cross-reference.
  - Release/version bump and publishing to consumers.
- Explicitly excluded systems, integrations, or datasets:
  - Live Codex CLI payload capture. The exact live `Edit`/`Write` `tool_input` field names cannot be confirmed from repository evidence; the fix uses the repo-native shapes (docstrings, working Edit-path implementation, test fixtures) with tolerant mapping (unmapped input allows), which is safe under either outcome.

### Hard Constraints (non-negotiable)

1. No file under `.claude/` — including any bundled `.claude` copy — may be created, modified, or deleted. Modifying `.claude` hook configuration as a workaround is prohibited.
2. No Codex hook registration may be disabled, removed, bypassed, or weakened in `.codex/config.toml` or its bundled copy.
3. Each handler's existing allow/deny POLICY is preserved exactly. Only Codex input/output transport, tool-name admission, `tool_input` mapping, and error handling change. Checkpoint fail-closed denies remain denies.
4. Root `.codex/` and the bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` must end byte-identical, with parity assertions retained. Root is authoritative.
5. Repository policy prohibits temporary files in tests. Process-level stdin must be fed via `System.Diagnostics.ProcessStartInfo` with `RedirectStandardInput`, per the existing pattern in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:50-80`.
6. No production file may exceed 500 lines. `enforce-checkpoint-monotonic.ps1` and `enforce-completion-consistency.ps1` are already at 420/425 lines as measured by both 500-line gates (`(Get-Content -LiteralPath $path).Count`; `legacy-codex-hook-contracts.Tests.ps1:96`, `codex-epic-runtime-contracts.Tests.ps1:180`), so shared mapping logic must be extracted rather than duplicated inline.

## Root Cause Analysis
- `.codex/config.toml` widened the third `PreToolUse` matcher to `^(apply_patch|Edit|Write)$` without widening the handlers' payload validators, which still assert `tool_name -eq 'apply_patch'` (`check-python-test-purity.ps1:156-157`, `check-powershell-test-purity.ps1:156-157`, `enforce-python-batch-budget.ps1:228-229`, `enforce-powershell-batch-budget.ps1:230-231`, `enforce-evidence-locations.ps1:160-161`, `enforce-checkpoint-monotonic.ps1:318-319`). The eighth registered handler in the group has the same class of defect at `enforce-orchestration-preimplementation-gate.ps1:242-244`: its validator admits only `Bash` and `apply_patch`, so the `Edit`/`Write` tool names the matcher admits exit 2.
- The `apply_patch` path additionally throws (converted to exit 2 by each entrypoint's catch block) when `tool_input` carries neither `file_path` nor a `command` string containing `*** Add File:` / `*** Update File:` / `*** Delete File:` / `*** Move to:` markers. Exit 2 is thereby conflated with the allow case: a well-formed payload that names nothing the hook governs must allow, not fail.
- `enforce-completion-consistency.ps1` has no validator of its own; it dot-sources `enforce-checkpoint-monotonic.ps1` (line 45) and reuses `ConvertFrom-CodexCheckpointHookPayload`, which is why its stderr names the neighbor hook. This sharing is by design, not a copy-paste defect; the fix must not rename the hook, but the shared error messages must become `-HookName`-parameterized so each handler's diagnostics name itself.
- Latent defect in the same transport path: `ConvertTo-CodexApplyPatchCheckpointInput` (`enforce-checkpoint-monotonic.ps1:364-392`) reconstructs post-patch content for every file in an Update patch by reading each source file from disk, so an `apply_patch` Update touching any file with a missing source or non-applying hunk exits 2 even when the hook governs none of the patched files. Reconstruction must run only for the governed checkpoint path; reconstruction failure for ungoverned paths is an allow. The fail-closed deny for the governed checkpoint file (empty content, invalid JSON) is policy and is preserved exactly.
- Bundled-copy divergences (confirmed): `config.toml` differs from root only in the ordering of three handlers inside the `^Bash$` group (registration sets and matchers identical; root `.codex/config.toml` is locally modified and uncommitted); the bundle carries an unregistered legacy-transport `enforce-pr-author-skill.ps1` the root does not (pre-existing, separately tracked as issue #335).
- Files implicated: `.codex/hooks/check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1`, `enforce-orchestration-preimplementation-gate.ps1`; `.codex/config.toml`; the bundled copies of all of the above.


## Proposed Fix

### Design summary (what changes where):

Introduce one new shared, entrypoint-free transport module at `.codex/hooks/codex-pretooluse-file-mapping.ps1` (name indicative), dot-sourced by all seven handlers, following the existing shared-helper precedent (`enforce-completion-helpers.ps1` with the `$MyInvocation.InvocationName -eq '.'` guard). The module provides:

1. `ConvertFrom-CodexPreToolUsePayload -PayloadRaw <string> -HookName <string>` — parses stdin; throws (converted to exit 2 by the caller's entrypoint) only for empty input, invalid JSON, or missing/null `tool_input`. Every thrown message begins with the supplied `-HookName`, so each handler's stderr names itself. The `tool_name -eq 'apply_patch'` assertion is removed; admitted names are `apply_patch`, `Edit`, and `Write`; any other well-formed tool name maps to zero file edits (allow).
2. `ConvertTo-CodexFileEditInput -Payload <object> [-ResolveUpdateContent]` — returns an array of `{ file_path, content?, old_string?, new_string? }` records. `Edit`/`Write` pass `tool_input` through when `file_path` is present; `apply_patch` parses the existing `*** (Add|Update|Delete) File:` / `*** Move to:` markers (logic lifted from the current per-handler implementations). Unmapped input (no `file_path` and no `command`, or a marker-free `command`) returns an empty array; the caller allows with exit 0 and no stdout. On-disk Update-content reconstruction (needed only by the two checkpoint hooks) runs only when requested and only for the governed checkpoint path; reconstruction failure for ungoverned paths yields no record (allow), while the checkpoint hooks' fail-closed denials for the governed file are preserved exactly.

Each of the seven handlers keeps its policy functions untouched (hard constraint 3) and replaces only its `ConvertFrom-Codex*Payload` / `ConvertTo-Codex*Input` / `Get-Codex*Path` plumbing with calls into the shared module. `enforce-completion-consistency.ps1` stops dot-sourcing `enforce-checkpoint-monotonic.ps1` for transport (it may still share checkpoint-specific reconstruction through the module). The batch-budget hooks keep their non-empty `session_id` requirement as an exit-2 condition (a required envelope field their state keying depends on). The stale `enforce-evidence-locations.ps1` docstring (claiming an allow envelope is written) is corrected to the allow-silently contract.

### Boundaries and invariants to preserve:

- The six hard constraints listed under **Hard Constraints (non-negotiable)** above.
- The native deny envelope emitted by deny paths is unchanged in shape and content semantics.
- Every existing parity gate stays green: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (hash parity, static transport assertions, 500-line cap), `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` (hash parity including `config.toml`, 500-line cap, core-pack-manifest listing), `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` (completion hook and helper byte parity), `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (root ⊆ bundle identical text; routing-config non-duplication; MCP transport retention).
- Handlers in the `^Bash$` and `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` groups are behaviorally unchanged.
- Untracked `.codex/state/*` session files must not be committed.

### Dependencies or blocked work:

- None new. PowerShell 7+, Pester 5, existing PoshQC MCP tools, existing pytest suite.
- Issue #335 (bundle-only `enforce-pr-author-skill.ps1` not wired) is cross-referenced, not solved: this fix deletes the unregistered bundle orphan and records that #335's future fix must reintroduce the hook on both sides with stdin transport plus a `[[hooks.PreToolUse]]` registration. Deleting an unregistered file removes no registration and weakens no active enforcement (consistent with hard constraint 2).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production surface (root files authoritative; each mirrored byte-for-byte into `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`):
1. `.codex/hooks/codex-pretooluse-file-mapping.ps1` — new shared module (≤ 500 lines, entrypoint-free).
2. `.codex/hooks/check-python-test-purity.ps1`
3. `.codex/hooks/check-powershell-test-purity.ps1`
4. `.codex/hooks/enforce-python-batch-budget.ps1`
5. `.codex/hooks/enforce-powershell-batch-budget.ps1`
6. `.codex/hooks/enforce-evidence-locations.ps1`
7. `.codex/hooks/enforce-checkpoint-monotonic.ps1`
8. `.codex/hooks/enforce-completion-consistency.ps1`
9. `.codex/config.toml` — byte-identity restoration only (no registration change).
10. Bundle-only deletion: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`.
11. `pack-manifests/core.json` — list the new shared module.

Test surface:
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — add the new module to parity/static lists.
- New file under `tests/scripts/codex-hooks/` for the added process-level cases (respects the 500-line limit on the existing suite).

Change-budget note: the touched-file count exceeds the PowerShell per-batch cap of 3 production + 3 test files (`.claude/rules/powershell.md`); the planner must split execution into batches (each bundle mirror in the same batch as its root file) or record an approved cap override.

#### Functions/classes/CLI commands impacted:

- New: `ConvertFrom-CodexPreToolUsePayload`, `ConvertTo-CodexFileEditInput` (shared module).
- Replaced/removed per handler: the `apply_patch`-only payload validators and per-handler mapping helpers (`ConvertFrom-Codex*Payload`, `ConvertTo-Codex*Input`, `Get-CodexEvidenceLocationPath` and siblings) in the seven handlers.
- Unchanged: every policy function (purity checks, budget accounting, evidence-location rules, checkpoint monotonicity/consistency validation) and every deny decision.

#### Data flow and validation changes:

- Before: stdin → per-handler validator (asserts `tool_name -eq 'apply_patch'`; throws on unmapped `tool_input`) → policy → allow/deny. `Edit`/`Write` and unmapped `apply_patch` never reach policy; they exit 2.
- After: stdin → shared parse (exit 2 only for empty stdin, invalid JSON, missing/null `tool_input`; plus missing `session_id` for the two batch-budget hooks) → shared admission and mapping (`apply_patch`/`Edit`/`Write` → file-edit records; unmapped or unadmitted well-formed input → empty record set → allow) → unchanged policy → allow (exit 0, no stdout) or deny (exit 0, native envelope).

#### Error handling and logging updates:

- Exit 2 is reserved for malformed or missing required Codex stdin, with an actionable message on stderr and nothing on stdout.
- All shared-module error messages are `-HookName`-prefixed so each handler's stderr names itself.
- No new logging channels; hooks communicate only via exit code, stdout envelope, and stderr.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the changed hook files, their bundle mirrors, the config byte-identity restoration, the manifest entry, and the test additions.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Native Codex `PreToolUse` contract — normative for every registered handler, for every tool name its matcher admits:

1. Read exactly one JSON payload from stdin via `[Console]::In.ReadToEnd()`.
2. Never read `CLAUDE_TOOL_INPUT`, `CLAUDE_SESSION_ID`, or any other `CLAUDE_*` environment variable. Behavior must depend only on stdin.
3. Allowed operation: exit 0 with no stdout.
4. Denied operation: exit 0 and emit ONLY the native envelope
   `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}`
5. Malformed or missing required Codex stdin: write an actionable error to stderr, write nothing to stdout, exit 2.
6. Well-formed input that names no file or command the hook governs is an ALLOW (exit 0, no stdout) — it is NOT an exit-2 condition.
7. Never emit legacy Claude shapes such as `{"decision":"allow"}` or `{"decision":"block"}`.

`tool_input` shapes consumed (repo-native evidence; tolerant mapping applies):

| Tool name | `tool_input` shape |
|---|---|
| `apply_patch` | `{ command: string }` — patch text with `*** Begin Patch`/`*** End Patch` and per-file `*** Add File:` / `*** Update File:` / `*** Delete File:` / `*** Move to:` markers |
| `Edit` | `{ file_path: string, old_string: string, new_string: string }` |
| `Write` | `{ file_path: string, content: string }` |

When a well-formed payload's `tool_input` carries no `file_path` and no mappable `command`, the handler allows.

#### Required configuration keys and defaults:

- None added or changed. `.codex/config.toml` registrations, matchers, and handler set are unchanged; the file changes only to restore root/bundle byte-identity.

#### Backward-compatibility expectations:

- `apply_patch` payloads that previously reached policy continue to produce identical allow/deny outcomes.
- `Edit`/`Write` payloads move from erroneous exit 2 to policy evaluation; new denies on those tool names are the hooks' existing policies finally being applied, not a policy change.
- Malformed-stdin behavior (exit 2, stderr, no stdout) is unchanged except that stderr now names the correct handler.

#### Performance constraints (latency/throughput/memory):

- Hooks run once per tool call as short-lived `pwsh` processes; the shared module adds one dot-source per invocation. No measurable constraint applies. On-disk Update reconstruction is narrowed (governed checkpoint path only), which can only reduce I/O.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The repo-native payload envelope and `tool_input` shapes documented in the research artifact are correct for the live Codex CLI. No captured live `Edit`/`Write` payloads exist in the repository; the tolerant mapping (unmapped → allow) makes the repair safe if live field names differ.
  - The `invalid pre-tool-use JSON output` symptom is attributed to the nonzero exits; the deny envelope shape already emitted by the non-implicated working handlers is kept unchanged.
- Constraints (budget, performance, compatibility):
  - The six hard constraints under **Hard Constraints (non-negotiable)**.
  - PowerShell change budget: per-batch cap of 3 production + 3 test files; work must be batched or a cap override recorded.
  - 500-line cap enforced twice on `.codex` files (`legacy-codex-hook-contracts.Tests.ps1`; `codex-epic-runtime-contracts.Tests.ps1:172-183`).
  - Temporary files in tests are strictly prohibited (`.claude/rules/general-unit-test.md`).
- External dependencies (services, libraries, releases):
  - None for the fix. Consumer delivery via `push_down_codex_and_agents_customizations` / release publishing is out of scope.

## Data / API / Config Impact
- User-facing or API changes: none to any public parameter surface. Codex-session-visible behavior change: `Edit`/`Write` tool calls stop failing all seven hooks; hook enforcement is actually applied to those operations.
- Data or migration considerations: none. Batch-budget state files under `.codex/state/` keep their existing keying (`session_id`); untracked session state must not be committed.
- Logging/telemetry updates (if any): stderr diagnostics become self-naming per handler; no other changes.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flags or schemas change. `pack-manifests/core.json` gains the new shared module entry. No version bump in this fix.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: per-handler process-level Pester tests covering a valid safe payload (exit 0, empty stdout and stderr), a representative forbidden payload (exit 0, native deny envelope), malformed stdin (exit 2, empty stdout, nonempty stderr), and poisoned `CLAUDE_*` environment variables (behavior unchanged).
- [x] Integration scenario to retest: run the full registered `PreToolUse` set against every tool name its matcher admits and assert no handler exits nonzero on a benign payload.
- [x] Manual verification notes: preserve each handler's existing allow/deny policy; change only tool-name admission, `tool_input` mapping, and error handling. Do not weaken or unregister any hook.

- Regression tests to add or update:
  - **Fail-before evidence:** capture the current measured failure table (exit 2 for `Edit`/`Write`/unmapped-`apply_patch` across the seven handlers) by running the new process-level cases against the pre-fix hooks; store output under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/regression-testing/`.
  - New process-level Pester cases (new file under `tests/scripts/codex-hooks/`), reusing the `ProcessStartInfo` + `RedirectStandardInput` stdin pattern from `legacy-codex-hook-contracts.Tests.ps1:50-80` (no temp files) and the harness's baked-in poisoned `CLAUDE_TOOL_INPUT`/`CLAUDE_SESSION_ID` environment:
    1. Per seven-handler group: valid safe payload for `Edit`, `Write`, and `apply_patch` → exit 0, empty stdout, empty stderr.
    2. Per handler with a deny policy: representative forbidden payload per admitted tool name → exit 0 and exactly the native deny envelope on stdout; assert no legacy `decision` key.
    3. Well-formed `apply_patch` with unmapped `tool_input` (no `file_path`, no markers) → exit 0, empty stdout (the second-half-of-defect regression case).
    4. Malformed stdin → exit 2, empty stdout, nonempty stderr, for every registered handler; assert `enforce-completion-consistency`'s stderr names itself.
    5. Config-driven integration case: parse the `[[hooks.PreToolUse]]` registrations from `.codex/config.toml` (pattern precedent: `codex-epic-runtime-contracts.Tests.ps1:37-83`) and run every registered handler against every tool name its matcher admits with a benign payload → exit 0 for all. This also provides the regression-only coverage for the two non-implicated handler groups.
  - Batch-budget cautions: safe-payload process cases must target non-`.py`/non-`.ps1` paths (e.g., `README.md`) so the budget entrypoints write no state under `.codex/state/`; forbidden budget cases remain unit-level via dot-sourced pure functions with injected state, per the existing suite.
  - Parity: existing suites `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `enforce-completion-consistency-codex.Tests.ps1`, and `test_push_down_codex_and_agents_resource_contracts.py` must pass with the new module added to the relevant lists.
- Unit tests (pytest) for the fixed behavior and boundaries: no new pytest tests; the pytest surface is the existing parity contract (`poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` at minimum). Behavior tests are Pester (the changed code is PowerShell).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): empty stdin; invalid JSON; missing/null `tool_input`; missing `session_id` for the two batch-budget hooks (remains exit 2); well-formed payload with unadmitted tool name (allow); `apply_patch` Update touching only ungoverned files with a missing on-disk source (allow, latent-defect regression); checkpoint fail-closed cases (empty content / invalid JSON for the governed file → deny, unchanged).
- Error handling and logging verification: assert stderr is nonempty and `-HookName`-prefixed on every exit-2 case; assert stdout is empty on every exit-2 and allow case.
- Coverage impact and targets for changed lines/modules: line coverage >= 85% and branch coverage >= 75% per `.claude/rules/general-unit-test.md` (branch coverage where the toolchain measures it; PowerShell branch coverage is not separately measurable in this toolchain — documented limitation). The new shared module and rewired entrypoint paths must be covered by the new cases.
- Toolchain commands to run (format → lint → type-check → test): `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → (no type-check stage for PowerShell) → `mcp__drm-copilot__run_poshqc_test`, restarting from format if any stage fails or changes files; plus the pytest parity contract.
- Manual validation steps (if required): none beyond the evidence comparisons below.

### Evidence plan (canonical locations per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`)

All evidence resolves under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/<kind>/`:

- `evidence/regression-testing/` — fail-before process-level output reproducing the measured table; pass-after output showing all-zero exits with empty stdout for benign payloads across all admitted tool names × seven handlers; the config-driven integration run output.
- `evidence/qa-gates/` — PoshQC loop results (format → analyze → test) and the pytest parity run output.
- `evidence/regression-testing/` (cross-reference note) — the #335 note recording that the bundle-only `enforce-pr-author-skill.ps1` was deleted for byte-identity and must be reintroduced on both sides with stdin transport plus registration by #335's fix.


## Acceptance Criteria
- [x] Every handler registered in `.codex/config.toml` exits 0 with empty stdout and empty stderr for a valid safe payload for EVERY tool name its matcher admits, verified by the config-driven process-level Pester integration case (registrations parsed from `.codex/config.toml`; output captured under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/regression-testing/`).
- [x] For each handler with a deny policy, a representative forbidden payload yields exit 0 and exactly the native envelope `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` on stdout, with no legacy `decision` key present, asserted by process-level Pester cases (batch-budget forbidden cases at unit level via injected state, per the existing suite pattern).
- [x] A well-formed `apply_patch` payload whose `tool_input` carries neither `file_path` nor apply-patch file markers yields exit 0 with empty stdout (allow) for every handler in the `^(apply_patch|Edit|Write)$` group, asserted by a process-level Pester case.
- [x] Malformed stdin yields exit 2, empty stdout, and nonempty stderr as follows: empty input and invalid JSON for EVERY registered handler; missing/null `tool_input` for every handler in the `^(apply_patch|Edit|Write)$` group (seven non-implicated registered handlers measurably exit 0 on missing/null `tool_input` today and must not be behaviorally changed). `enforce-completion-consistency.ps1`'s stderr names `enforce-completion-consistency` (not `enforce-checkpoint-monotonic`). Asserted by process-level Pester cases.
- [x] Poisoned `CLAUDE_TOOL_INPUT` / `CLAUDE_SESSION_ID` (and other `CLAUDE_*`) environment variables do not alter any handler's behavior; results depend only on stdin. Verified by the poisoned-environment process harness plus the static assertion that no hook reads `$env:CLAUDE_` (`legacy-codex-hook-contracts.Tests.ps1`).
- [x] Every hook registration present in `.codex/config.toml` before the change is still present after it, with matchers unchanged, verified by `git diff` of the registration blocks and the passing config-driven integration case.
- [x] Each handler's allow/deny policy outcome for previously reachable `apply_patch` payloads is unchanged (checkpoint fail-closed denies remain denies), verified by the existing deny-path and fail-closed Pester cases in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` continuing to pass without policy-assertion changes.
- [x] Root `.codex/` and the bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` are byte-identical, asserted by passing runs of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; the bundle-only `enforce-pr-author-skill.ps1` is deleted with an issue #335 cross-reference note recorded in the evidence tree.
- [x] The new shared transport module exists under `.codex/hooks/`, is entrypoint-free, is ≤ 500 lines (as are all changed hook files), is mirrored byte-for-byte into the bundle, and is listed in the Pester parity/static lists and `pack-manifests/core.json`, verified by the passing parity and manifest assertions in the Pester suites.
- [x] No file under `.claude/` (including any bundled `.claude` copy) is created, modified, or deleted, verified by `git diff --stat` showing no `.claude/` paths in the change set.
- [x] The PowerShell quality loop passes in order: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`, all stages clean in a single pass, with results captured under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/`.
- [x] Line coverage >= 85% and branch coverage >= 75% (branch coverage where the toolchain measures it), evidenced by the `run_poshqc_test` coverage output and the pytest parity run, captured under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/`.

## Risks & Mitigations
- Technical or operational risks:
  - Live Codex CLI `Edit`/`Write` `tool_input` field names differ from the repo-native shapes (no captured live payloads exist). Mitigation: tolerant mapping — a well-formed payload without `file_path` allows rather than errors — so a shape mismatch degrades to allow (the pre-fix state was a hard failure), and the deny envelope is unchanged.
  - Accidental policy change while rewiring transport (hard constraint 3 violation). Mitigation: policy functions are untouched; the existing deny-path and fail-closed Pester cases must pass without assertion changes (acceptance criterion 7).
  - Root/bundle drift reintroduced by partial mirroring. Mitigation: four independent parity gates (three Pester, one pytest) fail on any byte difference (acceptance criterion 8); each bundle mirror is changed in the same batch as its root file.
  - The two checkpoint hooks exceed the 500-line cap during rework. Mitigation: mapping logic lives in the shared module; the cap is enforced by two existing test gates.
  - Batch-budget hooks writing state into the repo during tests. Mitigation: safe-payload cases target non-`.py`/non-`.ps1` paths; forbidden budget cases stay unit-level with injected state; untracked `.codex/state/*` files are excluded from the commit.
- Mitigations and rollbacks: the change is confined to `.codex/hooks/**`, `.codex/config.toml` byte-identity, the bundled mirrors, `pack-manifests/core.json`, and tests; rollback is a revert of those files.

## Rollout & Follow-up
- Release/rollout steps: none in this fix. Delivery to consumers occurs through the separate release/publish process (out of scope).
- Post-fix monitoring or clean-up tasks:
  - Record in #415 and #335 evidence that #335's fix must reintroduce `enforce-pr-author-skill.ps1` on both root and bundle with stdin transport plus a `[[hooks.PreToolUse]]` registration.
  - Confirm no untracked `.codex/state/*` session files entered the commit.
- Links: issue #415 (https://github.com/drmoisan/drm-copilot/issues/415), branch `bug/codex-pretooluse-hook-transport-415`, research artifact `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/research/2026-07-25T18-30-codex-pretooluse-hook-transport-research.md`, related issue #335 (`docs/features/potential/promoted/2026-07-09-codex-pr-author-hook-not-wired.md`).
