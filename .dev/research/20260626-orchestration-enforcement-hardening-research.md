# Orchestration Enforcement Hardening — Research Findings

**Date:** 2026-06-26
**Scope:** One-off research (no active feature folder). Precedes promotion to a new feature.
**Context:** A prior diagnostic confirmed an orchestration run selected `path_selected: "small"` yet
deviated from that route's procedure, fabricated `execution_mode: "direct_powershell_engineer_remediation"`
(not a key in `config/orchestration-routing.json`), used sentinel values (`issue-num: "n/a"`,
`feature-folder: "n/a"`), skipped promotion and feature-review, wrote no atomic plan, and still advanced
to `next_step: "complete"`. No enforcement surface stopped it. Issues #207, #230, and #232 are CLOSED
and merged. This document diagnoses all remaining open gaps and designs their remediation.

---

## 1. Current State: Key Abstractions

| File | Role |
|---|---|
| `config/orchestration-routing.json` | Routing matrix: three routes (`small`, `large`, `remediation`), each listing `required_agents`, `required_skills`, `required_mcp_tools`. |
| `scripts/dev_tools/_orchestrator_state_routing.py` | `validate_routing_contract()` — strong validator: checks route-id membership, required-agent/skill/MCP receipts, empty override lists, MCP-surface lifecycle ops. |
| `scripts/dev_tools/validate_orchestrator_state.py` | `validate_orchestrator_state_text()` — calls `validate_routing_contract()` only when `require_complete=True`. |
| `.claude/hooks/validate-orchestrator-output.ps1` | SubagentStop hook for the `orchestrator` agent. Checks: non-empty output, checkpoint exists, valid JSON, four required fields (`objective`, `completed_steps`, `next_step`, `last_updated`), non-empty `objective`, `human_interaction` shape. Does NOT invoke the routing validator. |
| `.claude/hooks/enforce-completion-consistency.ps1` | PreToolUse Write/Edit hook. Blocks completion-asserting checkpoint writes missing `issue-num`, `feature-folder`, or `ci_gate`. Allows Edit tool unconditionally. Allows any non-empty string for `issue-num` and `feature-folder`. Issue #232 special-case adds `pr_gate` requirement. |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | PreToolUse Write/Edit hook. Validates `completed_steps` canonical order. Allows Edit tool unconditionally. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | PreToolUse Write/Bash/Agent hook. Requires `issue-num`, `feature-folder`, `route_id`/`path_selected`, `lifecycle_ready` in checkpoint before implementation. Issue #232 special-case hardcodes expected feature folder. |
| `.claude/agents/orchestrator.md` | SubagentStop wired to `validate-orchestrator-output.ps1`. |

---

## 2. Per-Gap Analysis

### Gap 1 — Routing Validator Is Opt-In; SubagentStop Completion Gate Does Not Invoke It

**Current code evidence:**

- `validate-orchestrator-output.ps1` lines 193–220: checks only `objective`, `completed_steps`, `next_step`,
  `last_updated`, and `human_interaction`. No call to `_orchestrator_state_routing.py::validate_routing_contract`.
- `validate_orchestrator_state.py` lines 480–503: `validate_routing_contract(state_map)` is called only
  inside `if require_complete:` (line 480). The MCP tool `validate_orchestration_artifacts` must pass
  `require_complete=True` to reach it; in the gap scenario the orchestrator never invoked that tool.
- `_orchestrator_state_routing.py` lines 158–216: `validate_routing_contract()` checks route-id membership
  in the routing matrix, agent/skill/MCP receipts, and non-empty override lists. It returns a list of error
  strings; it does not call `sys.exit` or write to disk.

**Coverage by prior merged work (#207, #230, #232):** None. The SubagentStop hook was not modified by
any of those issues to add routing validation. The routing validator itself was strengthened by #230.

**Root cause:** `validate-orchestrator-output.ps1` is pure PowerShell and cannot import Python modules
directly. The Python validator is only available through the MCP tool or a subprocess call.

**Proposed remediation:**

Add a new PowerShell function `Invoke-RoutingContractValidation` to `validate-orchestrator-output.ps1`
that subprocess-calls `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts --file
artifacts/orchestration/orchestrator-state.json --require-complete` and interprets exit code / stdout
errors. Insert this call inside `Invoke-OrchestratorOutputValidation` after the `human_interaction` check
and before the final `return @{ Ok = $true }`.

The subprocess seam must be injectable (scriptblock parameter defaulting to the real call) so Pester
tests can mock it without running Python. The hook should block with a named message
`ROUTING_CONTRACT_BLOCKED: <error list>` when the validator returns non-zero or prints errors.

Because the MCP entrypoint `validate_orchestration_artifacts` does not expose a stable CLI contract
separate from the MCP wrapper, the call target should be the internal Python module's CLI:
`scripts/dev_tools/validate_orchestration_artifacts.py --file ... --require-complete`. Verify that
script has a `__main__` entry; if not, add one (a thin function already exists at
`validate_orchestrator_state_text`).

**Affected tests:** `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` — add contexts
for routing validator subprocess call: subprocess returns errors, subprocess returns clean, subprocess
seam is mockable.

**Module rigor tier:** The hook is tooling/scaffolding (T4) but touches the completion gate, making it
functionally T2. Apply >= 85% line coverage, >= 75% branch coverage per uniform policy.

---

### Gap 2 — Sentinel Values Accepted as Present

**Current code evidence:**

- `enforce-completion-consistency.ps1` lines 157–169: uses `if (-not $issueNum)` and
  `if (-not $featureFolder)`. In PowerShell, a non-empty string such as `"n/a"` is truthy, so the
  checks pass. No pattern match or format check is performed.
- `enforce-completion-consistency.ps1` lines 164–169: `feature-folder` check is `if (-not $featureFolder)`.
  A value like `"n/a"` passes. No path-prefix check (`docs/features/active/`) and no disk-existence
  check are performed.
- `enforce-orchestration-preimplementation-gate.ps1` lines 100–103: `Get-StringProperty` returns a
  trimmed string; the caller checks `-not $issueNum` (line 112). Same issue: `"n/a"` is truthy.
  Line 120: `$featureFolder.StartsWith('docs/features/active/')` IS enforced for the preimplementation
  gate, but the check is only reached when `$featureFolder` is non-empty. The sentinel `"n/a"` does not
  start with `docs/features/active/`, so the preimplementation gate DOES reject `"n/a"` for
  `feature-folder`. However the completion-consistency hook does not.

**Partially addressed:** The preimplementation gate rejects `feature-folder: "n/a"` via the
`StartsWith('docs/features/active/')` check (line 120). The completion-consistency hook does not.

**Coverage by prior merged work:** Partial. #232 did not add sentinel rejection to the completion hook.
`issue-num` format is not validated anywhere.

**Proposed remediation (completion-consistency hook):**

Add a helper function `Test-IsValidIssueNum` to `enforce-completion-consistency.ps1` that rejects a
value when it matches the sentinel set `{n/a, none, tbd, empty, whitespace}` or does not match the
pattern `^\d+$` (integer digits only). Routes that are genuinely issue-less (currently none in the
routing matrix) should document a reserved literal (e.g., `"0"` or a new route-specific convention);
for now, reject all non-integer values.

Add a helper function `Test-IsValidFeatureFolder` that:
1. Rejects values in the sentinel set `{n/a, none, tbd, empty, whitespace}`.
2. Requires the value to start with `docs/features/active/` and contain at least one additional path
   segment (i.e., the folder name).
3. Optionally verifies disk existence (via an injectable `FolderExistsCheck` scriptblock defaulting to
   `Test-Path -PathType Container`).

Replace the existing `if (-not $issueNum)` and `if (-not $featureFolder)` branches in
`Get-MissingCompletionEvidence` with calls to these helpers. The rejection message should name the
sentinel value explicitly: `issue-num value 'n/a' is not a valid issue number (must be digits-only)`.

**Affected tests:** `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` — add cases:
- `issue-num = "n/a"` blocked.
- `issue-num = "none"` blocked.
- `issue-num = "  "` blocked.
- `issue-num = "123"` allowed.
- `feature-folder = "n/a"` blocked.
- `feature-folder = "docs/features/active/my-feature-233"` allowed.
- `feature-folder = "docs/features/active/my-feature-233"` with disk-existence check injected as false → blocked.

**Sentinel set to reject (both fields unless noted):** `n/a`, `none`, `tbd`, empty string, whitespace-only.
`issue-num` additionally rejects any string containing non-digit characters.

---

### Gap 3 — Edit-Tool Bypass on the Checkpoint

**Current code evidence:**

- `enforce-completion-consistency.ps1` lines 249–254:
  ```
  $content = $toolInput.content
  if (-not $content) {
      return [ordered]@{ decision = 'allow' }
  }
  ```
  The Edit tool sends `old_string`/`new_string`, not `content`. `$content` is null/empty → unconditional allow.
- `enforce-checkpoint-monotonic.ps1` lines 229–231: same pattern; `$content` absent → allow.
- Comment in both hooks (e.g., line 250 of consistency hook): "Edit tool calls supply only
  old_string/new_string … so they are allowed."

**Coverage by prior merged work:** None. This bypass was explicitly designed in as a simplification
and was not addressed by #207, #230, or #232.

**Feasibility assessment:**

Fully validating an Edit call requires reading the on-disk file, applying the `old_string`→`new_string`
patch in memory, and then running all checkpoint checks against the result. This is feasible but raises
risk:

- The on-disk file may differ from what the agent believes (concurrent edits, race conditions in hook
  execution).
- The patch may fail to apply if `old_string` is not unique (though Claude Code rejects such edits before
  invoking the hook).
- The hook must handle the case where the checkpoint file does not exist yet (Edit on a new file fails
  at the tool level before the hook fires).

**Recommended approach (read-then-validate):**

Extend `enforce-completion-consistency.ps1` with an injectable `CheckpointReader` scriptblock
(default: `Get-CheckpointFileContent`) and, when `$content` is absent but `$toolInput.old_string`
is present and the path is the checkpoint path:
1. Read the current on-disk checkpoint via the seam.
2. Apply the `old_string`→`new_string` replacement in memory (PowerShell `-replace` or `[string]::Replace`).
3. Run the same JSON-parse and completion-check logic on the resulting string.
4. Block if completion is asserted without evidence; allow otherwise.
5. If the on-disk file does not exist or the patch cannot be applied, allow (defer to downstream tools).

This is automatable with the existing PowerShell toolchain. Risk is bounded by the injectable seam
(tests can inject both the file content and the patch result). The bypass is eliminated for the
dominant use case where the orchestrator edits an existing checkpoint.

**Alternative rejected:** Requiring Write instead of Edit for completion-asserting updates would require
a settings.json change and would break agents that use Edit for partial checkpoint mutations not related
to completion. That approach is higher risk and lower benefit.

**Affected tests:** `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` — add contexts:
- Edit call with `old_string`/`new_string` that applies a completion assertion → blocked.
- Edit call with `old_string`/`new_string` that does not result in a completion assertion → allowed.
- Edit call where on-disk file does not exist → allowed.
- Edit call where patch does not match (old_string not found) → allowed (defer).

---

### Gap 4 — Hardcoded Issue '232' Special-Casing

**Current code evidence:**

- `enforce-completion-consistency.ps1` lines 191–213: `if ($issueNum -eq '232')` gates `pr_gate`
  requirement and SHA-matching.
- `enforce-completion-consistency.ps1` lines 274–276: `if ((Get-CheckpointStringValue ...) -eq '232')`:
  issue-context message enrichment.
- `enforce-orchestration-preimplementation-gate.ps1` line 9: `$script:Issue232FeatureFolder` hardcodes
  the issue 232 feature folder path.
- `enforce-orchestration-preimplementation-gate.ps1` lines 116–118: `if ($issueNum -eq '232' -and
  $featureFolder -ne $script:Issue232FeatureFolder)` gates a special path check.
- `enforce-orchestration-preimplementation-gate.ps1` lines 186–190: issue-232-specific block message.
- `validate_orchestrator_state.py` lines 98–100, 229–235: `ISSUE_232 = "232"`, `ISSUE_232_BRANCH`
  constant used in `_validate_completion_pr_gate` to enforce the branch name.

**Coverage by prior merged work:** The hardcoding was introduced by #232. Neither #207 nor #230
added or removed it. It is new debt from #232 that was expected to generalize.

**Root cause:** The `pr_gate` and `pr_gate.head_branch` requirements were introduced specifically for
issue #232's PR workflow and were not driven from the route definition.

**Proposed remediation:**

Generalize the `pr_gate` and `ci_gate`/`pr_gate` SHA-matching requirements to be driven by the
routing matrix rather than a literal issue number. Specifically:

1. Add a boolean field `requires_pr_gate: true` to the routing-matrix entries that need it. Currently
   `large` route requires a PR. `small` and `remediation` routes do not. This makes the requirement
   readable from `config/orchestration-routing.json` rather than hardcoded.
2. In `enforce-completion-consistency.ps1`, replace `$issueNum -eq '232'` with a lookup:
   - Load the routing matrix (injectable seam, default reads `config/orchestration-routing.json`).
   - Read `route_id` from the checkpoint (with `path_selected` fallback).
   - If the route's `requires_pr_gate == true`, apply `pr_gate` checks.
3. In `enforce-orchestration-preimplementation-gate.ps1`, remove `$script:Issue232FeatureFolder` and
   the hardcoded-path check. The `StartsWith('docs/features/active/')` check already covers the
   general case. The hardcoded #232-specific message should be generalized to name the checkpoint fields
   that are missing rather than the issue number.
4. In `validate_orchestrator_state.py`, replace `ISSUE_232` and `ISSUE_232_BRANCH` constants with a
   lookup: read `requires_pr_gate` from the routing matrix for the checkpoint's route, and enforce
   `pr_gate` only when the matrix says so. Remove the branch-name check for `ISSUE_232_BRANCH`; it was
   specific to one feature branch and has no general equivalent.

**Backward compatibility:** Existing checkpoints without `route_id` or `path_selected` will not match
any route in the new lookup, so the `requires_pr_gate` check will default to `false` (safe). Checkpoints
with `issue-num: "232"` that were valid under the old rule must still validate; since they should have
a `pr_gate` field already, the route-driven check will pass if the route is `large` (which has
`requires_pr_gate: true` after the matrix update).

**Affected files:** `config/orchestration-routing.json` (add `requires_pr_gate`),
`extensions/drm-copilot/resources/config/orchestration-routing.json` (mirror, must remain
byte-identical per `test_orchestration_routing_config_parity.py`),
`enforce-completion-consistency.ps1`, `enforce-orchestration-preimplementation-gate.ps1`,
`scripts/dev_tools/validate_orchestrator_state.py`.

**Affected tests:**
- `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`: update #232 contexts to use
  route-driven lookup; add context for non-#232 route with `requires_pr_gate: true`.
- `tests/scripts/dev_tools/test_validate_orchestrator_state.py`: remove #232-specific branch-name
  assertion; add route-driven `pr_gate` tests.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`: will catch divergence between
  canonical and bundled configs automatically after the routing matrix is updated.

---

### Gap 5 — No Route-Membership or Phase-Completeness Check

**Current code evidence:**

- `validate_orchestrator_state.py` `validate_orchestrator_state_text` (lines 396–505): validates
  structural keys and receipt shapes but never checks that `path_selected` / `route_id` is a key in the
  routing matrix at the non-complete validation level. The routing-matrix check is deferred to
  `validate_routing_contract()` which is only invoked under `require_complete=True`.
- `_orchestrator_state_routing.py` line 174: `if not isinstance(raw_route, dict): return ["Checkpoint
  selected route has no routing-matrix entry: {route_id}."]` — this check exists but only runs
  under `require_complete=True`.
- `enforce-completion-consistency.ps1`: checks evidence fields but does not verify route-id membership.
- `enforce-checkpoint-monotonic.ps1`: checks step order but does not verify route-id membership.
- `validate-orchestrator-output.ps1` (SubagentStop hook): does not verify route-id membership.
- No hook or non-complete validator verifies that `completed_steps` covers the selected route's
  mandatory phases (e.g., `S3_promotion` and `S4_atomic_planning` for `small` route).

**Coverage by prior merged work:** None at the non-complete level. #230 added the route-membership
check to `validate_routing_contract()` (complete path only).

**Proposed remediation:**

Add a new Python function `validate_route_membership` in `_orchestrator_state_routing.py` that:
1. Reads `route_id` or `path_selected` from the state dict.
2. Checks it is a non-empty string.
3. Checks it is a key in `matrix["routes"]`.
4. Returns a list of error strings (one error per violation).

Call `validate_route_membership` from `validate_orchestrator_state_text` **unconditionally** (before
the `if require_complete:` block) so an unrecognized route is rejected on any write, not only at
completion.

For phase-completeness checking: define a separate function
`validate_phase_completeness(state, route_map)` in `_orchestrator_state_routing.py` that reads
`completed_steps` and verifies mandatory canonical steps for the route. For `small` route, the
mandatory phases are `S3_promotion` and `S4_atomic_planning` (already enforced by
`enforce-checkpoint-monotonic.ps1` prerequisite check, but only for `completed_steps` ordering, not
for route-specific mandatory presence). Call this function from `validate_orchestrator_state_text`
under `require_complete=True` only (phase completeness is a completion gate, not a structural check).

**Backward compatibility:** The `validate_route_membership` function returns errors only when
`route_id`/`path_selected` is absent or not in the routing matrix. Existing checkpoints that have no
`route_id`/`path_selected` key will produce a new error from the unconditional path. To avoid
breaking old-format checkpoints, add an optional parameter `strict_route_membership: bool = False`
to `validate_orchestrator_state_text` and pass `True` only from the completion gate. This preserves
backward compatibility while allowing the new hook in Gap 1 to opt into strict checking.

**Affected files:** `scripts/dev_tools/_orchestrator_state_routing.py`,
`scripts/dev_tools/validate_orchestrator_state.py`.

**Affected tests:** `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` —
add tests for unknown route rejection. New test file or additions to existing
`test_validate_orchestrator_state.py` for `validate_route_membership` unit tests.

---

### Gap 6 — Checkpoint Transition Audit Trail

**Current code evidence:**

- `artifacts/orchestration/orchestrator-state.json` is a single mutable JSON file. Each Write or Edit
  replaces its content with no history.
- `enforce-checkpoint-monotonic.ps1` reads the to-be-written content and compares `completed_steps`
  against the canonical order, but does not log or persist the prior state.
- No append-only log exists. `rollback_history` within the checkpoint records rollback events as
  checkpoint-internal data (not external log), but it is optional and sparse.

**Coverage by prior merged work:** None.

**Assessment and priority:**

An append-only transition log would answer: what state was the checkpoint in before a given write?
This is useful for forensic diagnosis of future incidents. However:

- The existing `enforce-checkpoint-monotonic.ps1` hook already prevents out-of-order overwrites,
  which is the primary guard.
- The SubagentStop hook (Gap 1 after remediation) will enforce routing contract at termination.
- A transition log would be a new file at `artifacts/orchestration/orchestrator-state.log.jsonl`
  (newline-delimited JSON, one entry per write) written by a new PreToolUse hook or by extending
  `enforce-checkpoint-monotonic.ps1`.
- Risk: the log grows unboundedly; requires a rotation or max-entries policy.
- Benefit: post-hoc debugging only; does not prevent the incident from occurring.

**Priority: Low.** The other five gaps are preventive; this gap is diagnostic. Implement after Gaps 1–5
are closed.

**Proposed minimal design (if implemented):** Extend `enforce-checkpoint-monotonic.ps1` or add a
new `log-checkpoint-transition.ps1` PreToolUse hook that, before allowing a Write to the checkpoint
path, appends `{"timestamp": "<ISO>", "prior_next_step": "<x>", "new_next_step": "<y>",
"completed_steps_count": N}` to `artifacts/orchestration/orchestrator-state.log.jsonl`. Cap the log
at 100 entries (rotate oldest on cap). The monotonic hook would consume the log only for forensic
context when blocking; it does not need the log for its current ordering checks.

---

## 3. Additional Investigation: Routing-Matrix Agent-Name Mismatch

**Evidence from `.claude/agents/` directory listing:**

Agents present (`.md` files in `.claude/agents/`):
- `atomic-executor.md`, `atomic-planner.md`, `csharp-typed-engineer.md`, `epic-review.md`,
  `feature-review.md`, `orchestrator.md`, `powershell-typed-engineer.md`, `pr-author.md`,
  `prd-feature.md`, `python-typed-engineer.md`, `staged-review.md`, `status-updater.md`,
  `task-researcher.md`, `typescript-engineer.md`.

Agents NOT present:
- `feature-reviewer.md` — does not exist.
- `commit-steward.md` — does not exist.

**Evidence from `config/orchestration-routing.json`:**

```
"large": {
  "required_agents": [
    "task-researcher",
    "prd-feature",
    "atomic-planner",
    "atomic-executor",
    "feature-reviewer",   ← does not exist in .claude/agents/
    "commit-steward"      ← does not exist in .claude/agents/
  ]
}
```

Small and remediation routes use `"feature-review"` (which exists). The large route uses both
`"feature-reviewer"` and `"commit-steward"` (neither exists).

**Coverage by prior merged work (#230):** Issue #230's evidence artifact
(`issue-230.2026-06-24T17-55.md`) shows all 9 acceptance criteria were verified, including
"Routing matrix uses only real names across all three routes." However, the current
`config/orchestration-routing.json` still shows `feature-reviewer` and `commit-steward` in the
large route. This indicates #230's fix was to the `small` and `remediation` routes' naming only, or
the acceptance criteria text did not define "real names" to exclude non-existent large-route agents.

**Conclusion:** The large route contains two agent names (`feature-reviewer`, `commit-steward`) with
no corresponding `.claude/agents/*.md` file. This means:

1. `validate_routing_contract()` will check for receipts from `feature-reviewer` and `commit-steward`
   when the large route is used, but those agents cannot be delegated to by the orchestrator (no
   `Agent(feature-reviewer)` in settings.json permissions or orchestrator.md tools).
2. The routing matrix validator will reject any large-route checkpoint completion because it requires
   receipts for agents that cannot run.

**Proposed reconciliation:**

Option A (recommended): Replace `feature-reviewer` with `feature-review` in the large route's
`required_agents` (matching the existing agent). Remove `commit-steward` from `required_agents`
since no such agent exists and no `pr-author` replacement is documented; add `pr-author` if PR
authoring is a required large-route handoff, or simply remove the non-existent entry.

Option B: Create `.claude/agents/feature-reviewer.md` and `.claude/agents/commit-steward.md`. This
is higher effort and would require defining the agent personas, tools, and hooks from scratch.

Option A is recommended. The `feature-review` agent exists and performs the review function. The
`commit-steward` function (if it means PR creation) is covered by `pr-author`. Update both
`config/orchestration-routing.json` and its byte-identical mirror
`extensions/drm-copilot/resources/config/orchestration-routing.json`.

This change is not addressed by any merged prior work (the issue-230 fix left the large route
unchanged). This is a blocking defect for any large-route orchestration run.

---

## 4. Consolidated File Change List

### Python (Black/Ruff/Pyright/Pytest toolchain)

| File | Change Type | Gap |
|---|---|---|
| `scripts/dev_tools/_orchestrator_state_routing.py` | Add `validate_route_membership()` function; add `validate_phase_completeness()` function | Gap 5 |
| `scripts/dev_tools/validate_orchestrator_state.py` | Call `validate_route_membership` unconditionally (with `strict` param); call `validate_phase_completeness` under `require_complete` | Gap 5 |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | Add `__main__` CLI entry if absent (needed for subprocess call from Gap 1) | Gap 1 |
| `config/orchestration-routing.json` | Add `requires_pr_gate: true` to `large` route; rename `feature-reviewer` → `feature-review`, remove `commit-steward` (or replace with `pr-author`) | Gaps 4, Agent-mismatch |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | Same changes (byte-identical mirror) | Gaps 4, Agent-mismatch |

**Python test files:**

| File | Change Type | Gap |
|---|---|---|
| `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` | Add unknown-route rejection tests; remove #232-specific branch-name tests | Gaps 5, 4 |
| `tests/scripts/dev_tools/test_validate_orchestrator_state.py` | Add `validate_route_membership` unit tests | Gap 5 |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` | Add CLI `--require-complete` subprocess tests if `__main__` is added | Gap 1 |
| `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` | No change needed (byte-identical guard catches mirror drift automatically) | — |

### PowerShell (PoshQC format/analyze/Pester toolchain)

| File | Change Type | Gap |
|---|---|---|
| `.claude/hooks/validate-orchestrator-output.ps1` | Add `Invoke-RoutingContractValidation` with injectable subprocess seam; call after `human_interaction` check | Gap 1 |
| `.claude/hooks/enforce-completion-consistency.ps1` | Add `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder` helpers; replace sentinel-passing checks; add Edit-tool read-then-validate logic; replace #232 hardcoding with routing-matrix lookup | Gaps 2, 3, 4 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Remove `$script:Issue232FeatureFolder` and hardcoded #232 checks; generalize block messages | Gap 4 |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | No structural change needed; Gap 3 (Edit bypass) is handled in completion-consistency hook; Gap 6 (audit log) deferred | — |

**PowerShell test files:**

| File | Change Type | Gap |
|---|---|---|
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | Add routing-validator subprocess mock contexts | Gap 1 |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | Add sentinel rejection, feature-folder validation, Edit-bypass fix, routing-matrix lookup tests | Gaps 2, 3, 4 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | Update hardcoded-path tests to use generalized assertions | Gap 4 |

---

## 5. Testable Acceptance Criteria (Checkbox Form)

### Gap 1 — Routing Validator Wired into SubagentStop

- [ ] `validate-orchestrator-output.ps1` calls the routing contract validator via an injectable subprocess seam when the checkpoint is present and structurally valid.
- [ ] When the routing validator returns errors, `Invoke-OrchestratorOutputValidation` returns `{ Ok = $false; Message = "ROUTING_CONTRACT_BLOCKED: ..." }`.
- [ ] When the routing validator returns no errors, the hook continues to the existing allow result.
- [ ] A Pester test asserts block behavior when the subprocess seam returns routing errors.
- [ ] A Pester test asserts allow behavior when the subprocess seam returns no errors.
- [ ] The subprocess seam is mockable without running Python (injected scriptblock, default produces real call).
- [ ] Existing Pester tests in `validate-orchestrator-output.Tests.ps1` continue to pass.

### Gap 2 — Sentinel Values Rejected

- [ ] `enforce-completion-consistency.ps1` rejects `issue-num` values in the set `{n/a, none, tbd, empty, whitespace-only, any non-digit string}` with a named error citing the invalid value.
- [ ] `enforce-completion-consistency.ps1` rejects `feature-folder` values in the set `{n/a, none, tbd, empty, whitespace-only}` with a named error.
- [ ] `enforce-completion-consistency.ps1` rejects `feature-folder` values that do not start with `docs/features/active/` (plus a non-empty path suffix).
- [ ] An injectable `FolderExistsCheck` seam allows disk-existence check to be mocked in tests.
- [ ] Pester tests cover each sentinel value for both fields.
- [ ] Pester test covers allowed integer `issue-num` with valid `feature-folder` path.

### Gap 3 — Edit-Tool Bypass Eliminated for Completion-Asserting Patches

- [ ] When an Edit call targets the checkpoint path and `old_string`/`new_string` are present, `enforce-completion-consistency.ps1` reads the on-disk checkpoint via the injectable `CheckpointReader` seam, applies the patch in memory, and runs completion checks on the result.
- [ ] A Pester test (with injected on-disk content) demonstrates block when the patched result asserts completion without evidence.
- [ ] A Pester test demonstrates allow when the patched result does not assert completion.
- [ ] When the on-disk file does not exist or the patch does not apply (old_string not found), the hook allows (defer).
- [ ] Existing Pester tests for Edit-tool bypass remain; the bypass now applies only to non-checkpoint paths.

### Gap 4 — Issue-Specific Hardcoding Removed; Route-Driven Requirements

- [ ] `config/orchestration-routing.json` has a `requires_pr_gate` boolean field on applicable routes (true for `large`, absent or false for `small` and `remediation`).
- [ ] `extensions/drm-copilot/resources/config/orchestration-routing.json` is byte-identical to the canonical config (enforced by `test_orchestration_routing_config_parity.py`).
- [ ] `enforce-completion-consistency.ps1` reads `requires_pr_gate` from the routing matrix for the checkpoint's route and applies `pr_gate` checks only when `true`.
- [ ] The literal string `"232"` does not appear in any condition in `enforce-completion-consistency.ps1` after the change.
- [ ] The literal string `"232"` does not appear in any condition in `enforce-orchestration-preimplementation-gate.ps1` after the change.
- [ ] `ISSUE_232` and `ISSUE_232_BRANCH` constants are removed from `validate_orchestrator_state.py`.
- [ ] A Pester test asserts `pr_gate` is required for the `large` route.
- [ ] A Pester test asserts `pr_gate` is not required for the `small` route.
- [ ] Python tests assert `pr_gate` requirement is route-driven (not issue-number-driven).

### Gap 5 — Route Membership and Phase Completeness Checked

- [ ] `validate_orchestrator_state_text` (with `strict_route_membership=True`) rejects a checkpoint whose `path_selected`/`route_id` is not a key in the routing matrix.
- [ ] `validate_routing_contract` (called under `require_complete=True`) rejects a checkpoint whose `path_selected`/`route_id` is not in the routing matrix (already exists; confirm coverage).
- [ ] A fabricated `execution_mode: "direct_powershell_engineer_remediation"` value is rejected as an unrecognized route by `validate_route_membership`.
- [ ] `validate_phase_completeness` returns errors when `completed_steps` does not include mandatory phases for the selected route at completion.
- [ ] Python tests cover unknown-route rejection, phase-completeness pass, and phase-completeness fail cases.

### Gap 6 — Audit Trail (Low Priority, Deferred)

- [ ] (Deferred) An append-only `artifacts/orchestration/orchestrator-state.log.jsonl` is written on each checkpoint Write.
- [ ] (Deferred) The log is capped at 100 entries with oldest-entry rotation.
- [ ] (Deferred) The monotonic hook can read the log for forensic context on block.

### Agent-Name Mismatch Fix

- [ ] `config/orchestration-routing.json` large route `required_agents` contains only agent names that have corresponding `.claude/agents/*.md` files.
- [ ] `feature-reviewer` is removed or replaced with `feature-review` in the large route.
- [ ] `commit-steward` is removed or replaced with a documented existing agent (e.g., `pr-author`) in the large route.
- [ ] `test_orchestration_routing_config_parity.py` passes after both JSON files are updated.
- [ ] `test_validate_orchestrator_state_routing_contract.py` large-route positive test passes with updated agent list.

---

## 6. Automation Feasibility

All steps in this remediation are automatable with the available toolchain:

| Step | Toolchain | Automation Feasible? | Notes |
|---|---|---|---|
| Modify `config/orchestration-routing.json` | File edit (Write/Edit) | Yes | Pure JSON change; no build step required. |
| Sync bundled mirror | File copy or Write | Yes | Identical content; `test_orchestration_routing_config_parity.py` will validate. |
| Add Python functions to `_orchestrator_state_routing.py` | Python/Pyright/Ruff/Black | Yes | Standard typed Python with existing patterns. |
| Update `validate_orchestrator_state.py` | Python | Yes | Add unconditional call and optional strict param. |
| Add CLI to `validate_orchestration_artifacts.py` | Python | Yes | Thin `__main__` block if absent. |
| Extend `validate-orchestrator-output.ps1` | PowerShell/PoshQC | Yes | Subprocess seam follows existing injectable scriptblock pattern. |
| Extend `enforce-completion-consistency.ps1` | PowerShell/PoshQC | Yes | Helper functions follow existing `Get-CheckpointStringValue` pattern. |
| Extend `enforce-orchestration-preimplementation-gate.ps1` | PowerShell/PoshQC | Yes | Remove hardcoded constants; generalize messages. |
| Write Pester tests | Pester v5 / `mcp__drm-copilot__run_poshqc_test` | Yes | Mock seams are injectable per established pattern. |
| Write Python tests | Pytest / `poetry run pytest` | Yes | Match existing test structure in `test_validate_orchestrator_state*.py`. |

No third-party UI interaction, browser automation, or human-in-the-loop approval is required for any
step. The full seven-stage toolchain loop (format, lint, type-check, arch-boundary, unit tests,
schema, integration) is executable via existing MCP and CLI commands.

---

## 7. Risk and Backward Compatibility

### Existing Checkpoints Without New Fields

| New Requirement | Impact on Old Checkpoints | Mitigation |
|---|---|---|
| `requires_pr_gate` in routing matrix | Read during completion checks; if absent from matrix, treated as `false` | Default to `false`; no impact on existing checkpoints. |
| `validate_route_membership` (Gap 5, strict mode) | Old checkpoints missing `route_id`/`path_selected` would fail if strict mode is default | Use `strict_route_membership=False` as default; enable only at completion gate. |
| `Test-IsValidIssueNum` sentinel rejection | Old checkpoints with integer `issue-num` are unaffected; sentinel `"n/a"` never was valid | Only blocks what was always wrong. |
| `Test-IsValidFeatureFolder` prefix check | Old checkpoints with valid `feature-folder` paths unaffected | Only blocks sentinel values. |
| Edit-bypass removal (Gap 3) | Old Edit calls on non-completion checkpoints → on-disk checkpoint passes completion check → allowed | Risk bounded by injectable seam; allow on missing file or patch failure. |
| Agent-name fix in routing matrix | Old large-route checkpoints had `required_agents` mismatch anyway | Fix resolves an existing rejection; does not introduce new rejection for passing checkpoints. |

### Regression Scope

- Python changes affect `test_validate_orchestrator_state_routing_contract.py`,
  `test_validate_orchestrator_state.py`, `test_validate_orchestration_artifacts.py`. All existing tests
  must continue to pass.
- PowerShell changes affect three hook test files. All existing Pester tests must continue to pass before
  new tests are added.
- `test_orchestration_routing_config_parity.py` will catch any divergence between the two routing JSON
  files automatically; it requires no change.

### File Size Limit Compliance

- `enforce-completion-consistency.ps1` is currently 301 lines. Adding Gap 2, 3, and 4 changes will
  increase it. If it approaches 500 lines, extract helper functions to a shared script module
  (e.g., `enforce-completion-helpers.ps1`) and dot-source it, following the existing
  `ConvertFrom-CheckpointJson` seam pattern.
- `validate_orchestrator_state.py` is currently 506 lines. The `require_complete` block additions for
  Gap 5 are small (one function call). The removal of `ISSUE_232`/`ISSUE_232_BRANCH` and related
  `_validate_completion_pr_gate` hardcoding may offset additions.

### Module Rigor Tiers

Per `quality-tiers.yml` (file not found at repository root at time of research; classification derived
from code evidence):

- `scripts/dev_tools/`: used by orchestration guardrails and CI gates → T2 (Core). Apply >= 85% line,
  >= 75% branch coverage, property tests for pure functions, trend-only mutation.
- `.claude/hooks/`: tooling/scaffolding supporting the development loop → T4 elevated to T2 for
  completion gates. Apply >= 85% line, >= 75% branch coverage per uniform policy.

---

## 8. Rejected Alternatives

**Gap 1 alternative — Python subprocess at SubagentStop instead of in-process call:** The PowerShell
hook cannot import Python in-process. A subprocess call is the only available mechanism. A simpler
alternative of writing the routing check directly in PowerShell (duplicating the Python logic) was
rejected because it creates a second implementation that can diverge from the authoritative Python
validator.

**Gap 3 alternative — Require Write for completion-asserting updates:** Rejected. Requiring Write
instead of Edit would force agents to reconstruct the full checkpoint content on every partial update,
increasing the risk of data loss and requiring broader settings.json changes.

**Gap 4 alternative — Per-issue runbook files driving pr_gate requirement:** Rejected as over-engineering.
The routing matrix already encodes per-route requirements; adding `requires_pr_gate` to the matrix is
the minimal, data-driven approach.

**Gap 5 alternative — Reject unknown route at all validation levels unconditionally:** Partially
adopted. `validate_route_membership` is called unconditionally but with an optional strict parameter
to maintain backward compatibility for existing checkpoints without `route_id`.
