# Research: Preimplementation Gate Blocks Multi-Item Planner Surfaces (Issue #535)

- Timestamp: 2026-08-23T20-24
- Issue: #535
- Feature folder: `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/`
- Subject under change: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- Method: direct reads of the hook, its Pester suite, the planner skill contracts, the checkpoint rule files, sibling hooks, and repository-wide greps for the checkpoint literal. All findings below are verified against file contents at the current worktree head.

## 1. Current State Analysis

### 1.1 Hook behavior (verified from source, 270 lines)

`Invoke-OrchestrationPreimplementationGateDecision` (line 165) classifies the tool payload in three mutually exclusive branches:

1. **`file_path` present** → `Test-ImplementationPath` (line 41). Exemptions: any path starting `docs/features/active/` (line 46), and exact equality with the single script-scoped literal `$script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'` (line 10, compared at line 49). Everything else matching `\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$` requires a ready checkpoint.
2. **`command` present** → `Test-ImplementationCommand` (line 55): git add/commit, Python toolchain, npm/npx toolchain, Pester invocations.
3. **Otherwise (Agent delegations)** → `Test-ImplementationDelegation` (line 81): serializes the entire tool input with `ConvertTo-Json -Depth 20 -Compress` and regex-matches `(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)` against the whole payload text.

Readiness (`Test-OrchestrationReady`, line 94) requires a checkpoint with non-empty `issue-num`, `feature-folder` starting `docs/features/active/`, `route_id` (or `path_selected`), and truthy `lifecycle_ready` — a single-feature tuple that no multi-item planner run possesses. This function is out of scope for change per the issue constraints.

### 1.2 Why the planner surfaces are blocked (verified)

- `parallel-planner-state.json`, `parallel-orchestrator-state.json`, `epic-planner-state.json`, and `epic-orchestrator-state.json` all end in `.json`, are not the exempt literal, and are not under `docs/features/active/`, so `Test-ImplementationPath` returns `$true` and the gate demands the single-feature checkpoint that a planner run can never satisfy.
- Both pinned preparation-mode kickoff lines (section 3 below) necessarily contain the substrings `atomic-executor`, `execute`/`executed`, and `execution`, so `Test-ImplementationDelegation` classifies every preparation-mode `Agent(orchestrator)` delegation as an implementation delegation.

### 1.3 Registration and mirror copies (verified)

The hook is registered as PreToolUse for matchers `Bash`, `Write|Edit`, and `Agent` in both `.claude/settings.json` and the bundled `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (asserted by the existing test at `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` lines 276–304).

Four copies of the hook exist:

| Copy | Path | Parity binding |
| --- | --- | --- |
| Canonical Claude | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | none found to the Claude bundle copy |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | no byte-identity test found |
| Canonical Codex | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | byte-identical to Codex bundle, enforced by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 111 (`Get-FileHash` comparison over `$script:PreToolHookNames`, which includes this hook at line 13) |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | bound to canonical Codex by the test above |

The `.codex` copy carries the identical delegation regex (its line 107) and the identical single-literal `$script:CheckpointPath`. It is a divergent file (different line numbering, Codex transport differences), not a byte copy of the `.claude` one. Scope decision for the plan: fixing only the `.claude` copy unblocks `/parallel-plan` and `/epic-plan` in this repository; leaving the `.codex` copies stale leaves the same defect in the Codex runtime and in every push-down destination. If the `.codex` copies are updated, the Codex bundle copy MUST be updated byte-identically or the hash test fails. Four production PowerShell files exceeds the direct-mode change budget of 2; per `.claude/rules/powershell.md` this routes through `powershell-orchestrator` or requires batching.

## 2. Research Question 1 — Exact checkpoint path set

Enumerated from `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, the agent definitions, and the skills. Files the owning agents must write to `artifacts/orchestration/` and whether the gate currently matches them:

| Path | Named by | Extension gate-matched? | Currently blocked? |
| --- | --- | --- | --- |
| `artifacts/orchestration/orchestrator-state.json` | `.claude/rules/orchestrator-state.md`; `orchestrate` skill | `.json` — yes | No (exempt literal, relative spelling only — see #516) |
| `artifacts/orchestration/parallel-planner-state.json` | `.claude/rules/parallel-orchestration.md`; `parallel-plan` skill line 404; `parallel-planner` agent | yes | **Yes** |
| `artifacts/orchestration/parallel-orchestrator-state.json` | same rule; `parallel-orchestrate` skill; `parallel-orchestrator` agent | yes | **Yes** |
| `artifacts/orchestration/epic-planner-state.json` | `epic-plan` skill lines 151, 178; `epic-planner` agent | yes | **Yes** |
| `artifacts/orchestration/epic-orchestrator-state.json` | `epic-orchestrate` skill; `epic-orchestrator` agent; `.claude/settings.json` line 270 | yes | **Yes** |
| `artifacts/orchestration/parallel-kickoff-<slug>.md` | `parallel-plan` skill lines 409, 427, 470, 539; planner invariant P9 | `.md` — **not** in the extension pattern | No (confirmed: `.md` does not match `\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$`) |
| `artifacts/orchestration/epic-kickoff-<epic-slug>.md` | `epic-plan` skill line 142; `epic-planner` agent line 97 | `.md` — not matched | No |

Two additional `.json` checkpoints exist under `artifacts/orchestration/` for the language state machines:

- `artifacts/orchestration/powershell-orchestrator-state.json` (`.claude/skills/powershell-orchestration-state-machine/SKILL.md` line 19)
- `artifacts/orchestration/csharp-orchestrator-state.json` (`.claude/skills/csharp-orchestration-state-machine/SKILL.md` line 19)

These are written by the language orchestrators, which can be invoked via the change-budget router outside a standard `orchestrate` run (that is, without a ready single-feature checkpoint). Recommendation: include them in the exempt set. They are orchestration bookkeeping by the same argument as the five route checkpoints, and excluding them reproduces this defect for the language-orchestrator surfaces. If the plan chooses the minimal five-literal set instead, record the exclusion explicitly so the language-surface recurrence is a known deferral rather than an oversight.

Minimum required exempt set to resolve #535: the five route checkpoints (rows 1–5). Recommended exempt set: those five plus the two language-orchestrator checkpoints — seven repo-relative literals.

The kickoff `.md` artifacts require no change; confirmed unblocked by extension.

## 3. Research Question 2 — Preparation-mode markers and the delegation discriminator

### 3.1 Exact pinned markers (verified verbatim)

`parallel-plan` SKILL.md line 105 pins the kickoff line beginning:

> `Preparation mode: true. route_id: preparation. parallel_slug: <slug>. Perform promotion, research, feature documents (spec.md, user-story.md), atomic planning, and preflight clearance only. Atomic execution, PR authoring, and CI monitoring are out of scope ... executed later by parallel-orchestrator. After the atomic-executor preflight returns PREFLIGHT: ALL CLEAR, ...`

`epic-plan` SKILL.md line 99 pins the same opening with epic context fields:

> `Preparation mode: true. route_id: preparation. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. ... executed later by epic-orchestrator. After the atomic-executor preflight returns PREFLIGHT: ALL CLEAR, ...`

Both skills state the markers `Preparation mode: true.` and `route_id: preparation.` are "reused verbatim" and that "route selection is marker-driven, so no issuer identity is required" (`parallel-plan` SKILL.md line 111). Both lines unavoidably contain `atomic-executor` and `execute*`, which is exactly what the current whole-payload regex fires on.

### 3.2 Recommended discriminator (narrowest reliable predicate)

There is direct in-repo precedent: `enforce-epic-wave-barrier.ps1` activates only when `tool_input.subagent_type -eq 'orchestrator'` **and** the `prompt` field contains the literal marker `Epic mode: true` (its lines 257–263), reading both fields through `Get-ClaudeHookToolInputString` from `HookPayload.psm1`. The same module import already exists in the gate hook.

Recommended predicate for `Test-ImplementationDelegation`: return `$false` (not an implementation delegation) if and only if **all three** hold:

1. `Get-ClaudeHookToolInputString -ToolInput $ToolInput -Name 'subagent_type'` equals exactly `'orchestrator'`;
2. the `prompt` string (field-scoped, not the serialized whole payload) contains the literal `Preparation mode: true.` (with trailing period);
3. the `prompt` string contains the literal `route_id: preparation.` (with trailing period).

In every other case the existing whole-payload regex runs unchanged, so the fail-closed default is preserved: a payload with a missing or empty `prompt`, a non-string `subagent_type`, or any extraction failure falls through to the current matcher.

### 3.3 Spoofing analysis

- **Execution delegation that merely mentions the marker text:** an execution-mode delegation targets `atomic-executor` or an engineer agent, so `subagent_type` is not `orchestrator` and condition 1 fails; the regex still denies it. The agent-identity conjunct is the load-bearing part of the predicate — the marker text alone must never exempt.
- **A delegation to `orchestrator` that carries the markers but intends execution:** defense in depth holds. (a) This same PreToolUse gate is registered on `Bash` and `Write|Edit`, so any actual implementation write, toolchain command, or `git add|commit` the child attempts is still denied unless a ready checkpoint exists — the exemption releases only the delegation itself, not the work. (b) The `preparation` route contract (`epic-plan` SKILL.md, "Child run contract") permits `atomic-executor` in preflight-only mode, and `validate-orchestrator-output.ps1` gates the child's completion against its checkpoint. (c) `enforce-model-routing-receipt.ps1` deliberately excludes `subagent_type == 'orchestrator'` from receipt gating (its lines 17–21), so the exemption introduces no new interaction there.
- **Marker in a non-prompt field:** field-scoping the check to `prompt` prevents a crafted `file_path` or other field from carrying the marker; the current whole-payload serialization approach is what made the matcher over-broad in the first place, and the fix should not repeat that shape for the exemption.

Rejected weaker predicates: (a) marker-only without the agent check — spoofable by any delegation prose; (b) removing `execute`/`implementation` from the regex — weakens the gate for genuinely implementation-flavored delegations and does not fix the `atomic-executor` substring hit; (c) exempting all `Agent(orchestrator)` delegations — exempts execution-mode orchestrator fan-outs (epic/parallel execution children), which the gate currently covers.

## 4. Research Question 3 — Existing Pester coverage and required additions

### 4.1 Current suite (verified)

`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (305 lines). Structure:

- Dot-sources the hook (the guard at hook line 258 returns early under dot-sourcing).
- Drives the pure seam `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw <envelope JSON> -CheckpointRaw <checkpoint JSON>` — no disk, no child process.
- Builder helpers: `ConvertTo-ImplementationWriteToolInput`, `ConvertTo-CommandToolInput`, `ConvertTo-DelegationToolInput` (constructs nested envelopes `{tool_name, tool_input}`), `ConvertTo-CheckpointRaw`.
- Contexts: implementation writes/commands/delegations pre-readiness (deny), documentation/evidence writes (allow), ready-checkpoint allows, payload-anomaly fail-closed cases, entrypoint exit-code seam via injected `-ReadPayload` scriptblock, and settings registration in both settings.json copies.
- Secondary coverage: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` exercises the `.codex` copy's decision function and asserts codex-bundle byte-identity; `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` covers the decision schema.

### 4.2 New test cases the fix requires

Checkpoint-path exemption (each as an `It`, or a `-ForEach` table):

1. Allow: `Write` of each exempt checkpoint literal with **no** `-CheckpointRaw` (the bootstrap case — five route checkpoints, plus the two language checkpoints if adopted).
2. Deny: `Write` of a non-checkpoint `.json` under `artifacts/orchestration/` — e.g. `artifacts/orchestration/some-other-file.json` — proving the exemption is a literal set, not a directory prefix.
3. Deny: `Write` of a checkpoint-named file **outside** `artifacts/orchestration/` (e.g. `scripts/parallel-planner-state.json`), proving full-path equality.
4. Backslash spelling of an exempt checkpoint still allowed (the existing `-replace '\\','/'` normalization must apply to the widened set).

Delegation discriminator:

5. Allow: `Agent` payload with `subagent_type: 'orchestrator'` and a prompt that is the verbatim parallel-plan kickoff line (contains `atomic-executor` and `execute`), no checkpoint.
6. Allow: same with the verbatim epic-plan kickoff line.
7. Deny: `Agent` payload with `subagent_type: 'atomic-executor'` whose prompt contains both preparation markers (spoof case — agent conjunct must control).
8. Deny: `Agent` payload with `subagent_type: 'orchestrator'` and an execution-mode prompt without the markers that matches the regex (e.g. mentions `atomic-executor`).
9. Deny: marker with a missing trailing period or only one of the two markers present (literal-match strictness), when the payload otherwise matches the implementation regex.
10. Deny: markers present in a field other than `prompt` while `prompt` is regex-matching text.

Fail-closed regression (unchanged behavior):

11. Existing anomaly cases re-run green: empty payload, unparseable JSON, flat root shape, malformed `-CheckpointRaw` — all deny.
12. Existing implementation write/command/delegation denials and ready-checkpoint allows unchanged.

Registration/parity:

13. If the `.codex` copies are updated: the existing byte-identity test in `legacy-codex-hook-contracts.Tests.ps1` covers the codex pair automatically; no new test needed, but the bundle copy must be regenerated in the same commit.

## 5. Research Question 4 — Policy constraints

- **Language:** PowerShell only. Persistent guidance (agent memory, `enforcement-hooks-must-not-use-Python`): enforcement hooks must not gain a Python leg; the fix stays inside the `.ps1` hook.
- **Toolchain:** PoshQC format → analyze → Pester test via the MCP commands (`.claude/rules/powershell.md`); restart on any failure. Pester v5, advanced functions with `CmdletBinding()`, approved verbs — the existing hook already conforms; new/changed functions must keep `[OutputType([bool])]` and mandatory-parameter attributes.
- **Coverage:** line coverage >= 85% (uniform, T1–T4); no branch gate for PowerShell. New branches (literal-set membership, three-conjunct discriminator) are all reachable through the `-ToolInputRaw`/`-CheckpointRaw` seam, so coverage is straightforward.
- **File size:** hook is 270 lines. The estimated fix is roughly +25 to +40 lines: replace the scalar `$script:CheckpointPath` with a `$script:CheckpointPaths` array (the block-message text at line 216 still names `orchestrator-state.json`; it should be generalized), membership test in `Test-ImplementationPath`, and a small `Test-PreparationModeDelegation` helper called at the top of `Test-ImplementationDelegation`. Result ~300–310 lines — comfortably under 500. **No extraction into `.claude/lib/` is required.** Note that `Get-CheckpointContent` (line 124) reads `$script:CheckpointPath` for the readiness lookup; that scalar usage must remain pointed at `orchestrator-state.json` specifically (readiness is defined only for the standard checkpoint), so keep a distinct scalar for the readiness source and a separate array for the write exemption.
- **Change budget:** direct-mode cap is 2 production PowerShell files. Canonical `.claude` hook + its Claude bundle mirror = 2. Adding both `.codex` copies makes 4, which requires routing through `powershell-orchestrator` or explicit batching. The plan must decide the mirror scope up front.
- **Test location:** `tests/scripts/claude-hooks/` mirrors the established convention for this hook; extend the existing file rather than creating a new one (it is 305 lines; additions of ~100 lines keep it under 500).

## 6. Research Question 5 — Other consumers of the checkpoint literal

Grep of `.claude/hooks/` and `.claude/lib/` for `orchestrator-state.json`; disposition of each with respect to the widened exempt set:

| File | Usage | Conflict with widened set? |
| --- | --- | --- |
| `enforce-checkpoint-monotonic.ps1` (line 9) | Activates **only** when `file_path` equals `artifacts/orchestration/orchestrator-state.json`; validates `completed_steps` ordering; allows all other paths | No. Planner checkpoints pass through it untouched. Gap, not conflict: no monotonicity check exists for the other four checkpoints, which is out of scope for #535. |
| `enforce-model-routing-receipt.ps1` (lines 9, 46) | Reads the standard checkpoint to gate Agent delegations; `orchestrator` subagent_type deliberately excluded from gating | No. Preparation-mode `Agent(orchestrator)` delegations pass. |
| `enforce-epic-merge-gate.ps1` (lines 11–17, 44–46) | Reads all three checkpoints (standard, epic, parallel) at merge time | No. Merge-time only; already multi-checkpoint aware. |
| `enforce-completion-consistency.ps1`, `enforce-pr-author-skill.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`, `enforce-prd-feature-before-planner.ps1`, `validate-orchestrator-output.ps1` | Read the standard checkpoint for their own gates; `validate-orchestrator-output.ps1` takes `-CheckpointPath`/`-ArtifactType` parameters and is registered per-agent in settings.json (epic/parallel matchers pass their own checkpoint paths) | No conflicts. None of them classifies checkpoint *writes*. |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` (line 416) | Default checkpoint path constant for the state library | No conflict; not a write gate. |
| Parallel/epic-specific hooks (`enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`) | Hard-code their own surface's checkpoint path as a read source | No conflict. |

Conclusion: the preimplementation gate is the **only** hook that denies writes to the non-standard checkpoints. Widening its exempt set disagrees with nothing.

### Interaction with issue #516 (absolute-path normalization)

#516 (promoted record `docs/features/potential/promoted/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path.md`) is the adjacent defect: the exempt comparison is exact equality against the repo-relative literal after backslash normalization only, so the `Write` tool's mandatory absolute paths fail the exemption. The #535 fix must not fold #516 in, and must not make it worse:

- Keep every new exempt entry as a **repo-relative literal** and keep the comparison a single membership check against the normalized path (`$script:CheckpointPaths -contains $normalized` or equivalent). Do not add absolute-path literals and do not add per-path normalization logic.
- When #516 later inserts workspace-root stripping upstream of classification (its record proposes `.claude/lib/hook-payload/` as the shared home), the widened set composes automatically: the stripped repo-relative form hits the same membership check. A set-membership function over the normalized path is exactly the shape #516 needs to slot into.
- The #535 reproductions all use the repo-relative spelling (issue.md, Suspected Cause note), so #516 does not mask verification of this fix. New Pester cases should use repo-relative `file_path` values, matching the existing suite; absolute-path twins are #516's test scope, not this fix's.

## 7. Candidate Approaches and Recommendation

### Approach A (recommended): explicit literal set + field-scoped preparation-marker discriminator

- Replace the single exempt literal with a script-scoped array of repo-relative checkpoint literals (five route checkpoints; recommend including the two language-orchestrator checkpoints, total seven). `Test-ImplementationPath` tests set membership after the existing backslash normalization.
- Keep a separate scalar for the readiness-read source (`Get-CheckpointContent` and the block-message text), which remains `orchestrator-state.json`.
- Add `Test-PreparationModeDelegation` implementing the three-conjunct predicate of section 3.2 (subagent_type equals `orchestrator` + both verbatim markers in the `prompt` field), checked before the existing regex in `Test-ImplementationDelegation`; on any extraction failure the regex path runs.

Advantages: fail-closed by construction (both changes are enumerated exemptions layered over unchanged deny logic); follows the proven `enforce-epic-wave-barrier.ps1` pattern; composes with the #516 normalization fix; no new files; hook stays well under 500 lines; every new branch testable through the existing seam.

### Rejected alternatives (brief)

- **Directory-prefix exemption (`artifacts/orchestration/*.json`):** wider than needed; exempts arbitrary future `.json` writes under that directory without review. The literal set is the fail-closed shape; a new checkpoint costs one line plus one test.
- **Marker-only delegation exemption (no agent conjunct):** spoofable by any execution delegation quoting the marker in prose. Rejected in section 3.3.
- **Whole-payload marker search (mirror the current regex shape):** lets a marker in any field (e.g. `file_path`) exempt the payload; the field-scoped `prompt` check is strictly narrower.
- **Teaching `Test-OrchestrationReady` a planner-run tuple:** explicitly out of scope per the delegation constraints; also unnecessary once checkpoint writes and preparation delegations are exempt, because a planner run performs no other gate-matched operations (its manifests and kickoff artifacts are `.md`; its feature documents are under `docs/features/`).

## 8. Behavior Semantics (success/failure conditions)

Post-fix decision table, with no ready checkpoint present:

| Operation | Decision |
| --- | --- |
| Write/Edit of any of the exempt checkpoint literals (relative spelling, either separator) | allow |
| Write/Edit of any other `.json`/`.py`/`.ps1`/... path outside `docs/features/active/` | deny (unchanged) |
| Write of `artifacts/orchestration/parallel-kickoff-<slug>.md` or `epic-kickoff-<slug>.md` | allow (unchanged — `.md` never matched) |
| `git add`/`git commit`, toolchain commands | deny (unchanged) |
| `Agent(orchestrator)` with both verbatim preparation markers in `prompt` | allow |
| `Agent(orchestrator)` without both markers, matching the implementation regex | deny |
| `Agent(<any other subagent>)`, markers present anywhere | deny |
| Empty/unparseable/flat payload | deny with payload-anomaly reason (unchanged) |
| Malformed `-CheckpointRaw` for a genuinely implementation operation | deny (unchanged) |

Ordering rule inside `Test-ImplementationDelegation`: preparation-mode exemption first, regex second; any failure to extract `subagent_type` or `prompt` falls through to the regex.

## 9. Requirements Mapping (acceptance criteria → design)

1. **Planner checkpoints writable pre-readiness** → `$script:CheckpointPaths` membership exemption in `Test-ImplementationPath` (section 7A). Verified by tests 1–4 of section 4.2.
2. **Preparation-mode delegations not classified as implementation** → `Test-PreparationModeDelegation` three-conjunct predicate. Verified by tests 5–10.
3. **Gate remains fail-closed** → no change to `Test-OrchestrationReady`, `Test-ImplementationCommand`, the anomaly path, or the extension regex; existing deny tests re-run unchanged (tests 11–12).
4. **Mirror integrity** → Claude bundle copy updated with the canonical hook (2-file direct-mode budget); `.codex` pair either updated together (routes to `powershell-orchestrator` for budget) or explicitly deferred with a recorded follow-up. The codex byte-identity test enforces the pair if touched.
5. **#516 non-interference** → exempt set stays repo-relative literals behind a single membership check (section 6).
6. **Block-message accuracy** → generalize the deny reason at hook line 216 if the plan chooses; the current text names only `orchestrator-state.json`, which is misleading for a planner-surface deny after this fix. Low-risk, message-only change; existing tests assert `PREIMPLEMENTATION_GATE_BLOCKED` and the phrases `route metadata`/`lifecycle readiness`, which should be preserved.

## 10. Testing Implications

- Extend `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` with the cases in section 4.2, driven entirely through `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` — no disk, no processes, deterministic, no temporary files.
- Use the verbatim kickoff lines from the two SKILL.md files as the allow-case prompts, so the tests break if the pinned contract and the discriminator ever drift apart.
- Fail-before evidence: the current suite has no test asserting an allow for a planner checkpoint write or a preparation delegation; running the new allow cases against the unfixed hook produces the failing baseline for `evidence/regression-testing/`.
- Toolchain: PoshQC format → analyze → Pester via MCP, repeated to a clean single pass; line coverage >= 85% on the hook.

## Automation Feasibility

This fix is fully automatable in-repo. The complete scope is: editing one to four PowerShell hook files, extending one existing Pester test file, and running the local PoshQC/Pester toolchain via the MCP commands. Verification is entirely local (direct invocation of the decision seam with constructed payloads, plus the existing test suites). No third-party UI, external service, credential, or manual browser step is involved. Zero human-interaction requirements. The only human decision points are scope selections already enumerated above (whether to include the two language-orchestrator checkpoints in the exempt set, and whether to update the `.codex` mirror pair in the same change or defer it), both of which can be settled at planning time.
