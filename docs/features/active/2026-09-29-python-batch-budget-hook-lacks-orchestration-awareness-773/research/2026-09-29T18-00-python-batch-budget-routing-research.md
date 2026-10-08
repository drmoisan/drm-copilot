# Research: Python batch-budget hooks as a large-path routing signal (Issue #773)

- Issue: #773
- Branch: `bug/python-batch-budget-hook-lacks-orchestration-awareness-773`
- Feature folder: `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773`
- Researched: 2026-09-29
- Primary reference (reused, not re-derived): `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/` (research `research/2026-09-29T13-35-batch-budget-routing-research.md`, `spec.md` AC-1..AC-23, `plan.2026-09-29T13-19.md`, `code-review.2026-09-29T15-33.md`), merged in PR #772 (merge commit `91805f15`).
- Owner direction (from #769, restated in `issue.md:37`): the hook signals that a change touching more than 3 production files belongs on the large-path orchestrator. The large path has no file cap. Batching instructions are removed. Threshold confirmed for Python: 1-3 production files small, more than 3 large; no threshold number changes.

All file:line citations were verified by reading or searching files in this worktree on 2026-09-29. The large-path detection signal, route set, precedence rule, terminal markers, execution-context analysis, and failure-mode analysis are adopted unchanged from #769 research Sections 2.1-2.4 and #769 `spec.md` "Large-path detection signal"; they are not repeated here.

---

## 1. Current State and Python-Specific Differences

### 1.1 Structural equivalence with the pre-#769 PowerShell hooks

A `git diff` against the pre-#769 blob was not run (this research session has no shell tool). Equivalence is established instead by comparing the current Python hooks with (a) the pre-#769 PowerShell hook inventory recorded in #769 research Section 1.1-1.2 and #769 plan line 31-32, and (b) the unchanged regions of the post-#769 PowerShell hooks.

| Element | Pre-#769 PowerShell (from #769 research/plan) | Current Python |
|---|---|---|
| Claude hook size | 457 lines | 454 lines (`.claude/hooks/enforce-python-batch-budget.ps1`) |
| Claude deny message | `:296` | `:293` |
| Claude persisted cap overlay | `:214-215` | `:211-212` |
| Claude env override block | `:426-433` | `:423-430` |
| Claude session-id resolution, containment, rehydrate filter, deny-only entry point, dot-source guard | present | present, same shape (`:53-171`, `:217-222`, `:387-454`) |
| Codex hook size | 256 lines | 254 lines (`.codex/hooks/enforce-python-batch-budget.ps1`) |
| Codex deny message | `:139` | `:137` |
| Codex persisted cap overlay | `:77-78` | `:75-76` |
| Codex top-level wiring (inline try/catch, rename both sides, `-RequireSessionId`) | `:219-256` | `:217-254` |

The function bodies of the Python hooks match the unchanged helper functions of the post-#769 PowerShell hooks line-for-line apart from the language noun (compare `Test-PythonBatchBudgetPathInRoot` `.claude/hooks/enforce-python-batch-budget.ps1:53-90` with `Test-PowerShellBatchBudgetPathInRoot` `.claude/hooks/enforce-powershell-batch-budget.ps1:65-102`; `Get-PythonBatchBudgetSessionId` `:108-171` with `Get-PowerShellBatchBudgetSessionId` `:120-183`). The Python hooks are the pre-#769 PowerShell design with the language-specific values below.

### 1.2 Python-specific differences (complete list)

| # | Difference | Claude hook | Codex hook |
|---|---|---|---|
| D1 | Extension filter `\.py$` (PowerShell: `\.(ps1\|psm1\|psd1)$`) | `:270`, `:345` | `:122`, `:184` |
| D2 | Test classification `(^\|/)tests/.*\.py$` or `(^\|/)test_[^/]+\.py$`. No `*_test.py` rule exists, and `conftest.py` outside `tests/` classifies as production. | `:281` | `:126` |
| D3 | Env overrides `CLAUDE_PYTHON_BUDGET_PROD` / `CLAUDE_PYTHON_BUDGET_TEST` | `:423-430`, docstring `:35-37` | none (Codex reads no `$env:CLAUDE_*`) |
| D4 | State file `python-batch-budget.<session>.json` under `.claude/state` / `.codex/state` | `:363` | `:193` |
| D5 | Function-name noun `Python` (`Get-PythonBatchBudgetState`, `ConvertTo-PythonBatchBudgetState`, `Get-PythonBatchBudgetBlockDecision`, `Invoke-PythonBatchBudgetDecision`, `Invoke-PythonBatchBudgetHook`, `Invoke-PythonBatchBudgetEntryPoint`) | throughout | throughout (no entry-point function) |
| D6 | `-StateFile` is `Mandatory` on the decision function (post-#769 PowerShell made it optional, default `''`) | `:261-262` | `:117-118` |
| D7 | `-TestCap` is `Mandatory` on `Get-/ConvertTo-PythonBatchBudgetState` | `:180-181`, `:202-203` | `:48-49`, `:70-71` |
| D8 | Codex hook has no testable entry-point function; wiring is inline at top level. Post-#769 Codex PowerShell added `Invoke-PowerShellBatchBudgetCodexEntryPoint` (`.codex/hooks/enforce-powershell-batch-budget.ps1:384-448`). | n/a | `:221-254` |
| D9 | Envelope anomaly reason text begins `Python batch-budget hook received ...` | `:333-336` | `:175` |

D2 is preserved unchanged by this item (it is an invariant in #769 spec "Boundaries and invariants"). Whether `*_test.py` should also classify as test is out of scope; the router and policy text do not define it.

### 1.3 Registration surfaces

| Surface | Python hook entry |
|---|---|
| `.claude/settings.json:136` and bundle copy | `pwsh -NoProfile -File .claude/hooks/enforce-python-batch-budget.ps1` (unchanged) |
| `.codex/config.toml:196-197` and bundle copy | unchanged |
| Claude pack manifest | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json:9` (Python pack, not core) |
| Codex pack manifest | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json:58` (core pack) |
| Coverage | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:30` (Claude), `:136` (Codex); same lines in `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` |
| `scripts/powershell/Publish-DrmCopilotExtension.ps1` | no batch-budget or route-helper reference (search for `batch\|route` returned no match); no change |

The #769 route helper `.claude/hooks/enforce-powershell-batch-budget-route.ps1` is registered only in the PowerShell pack (`pack-manifests/powershell.json:9`) and at `pester.runsettings.psd1:32` (both copies).

---

## 2. Reuse Decision

### 2.1 Candidates

| Candidate | Description | Assessment |
|---|---|---|
| **A. One language-neutral shared route helper per runtime** | Rename `.claude/hooks/enforce-powershell-batch-budget-route.ps1` to `.claude/hooks/enforce-batch-budget-route.ps1` with neutral function names; add a byte-identical `.codex/hooks/enforce-batch-budget-route.ps1`; both PowerShell hooks and both Python hooks dot-source their runtime's copy; the inline copy in the Codex PowerShell hook is removed; a parity test asserts the Claude and Codex copies are byte-identical. | **Selected.** |
| B. Python hooks carry their own copies | Inline or sibling copies in each Python hook. | Rejected: four copies of the same pure logic with no parity check, the defect class the #769 review recorded as Minor (a). |
| C. Python hooks dot-source the existing PowerShell-named helper as-is | Claude Python hook dot-sources `enforce-powershell-batch-budget-route.ps1`; Codex Python hook dot-sources the Codex PowerShell hook or a PowerShell-named extract. | Rejected: the Claude helper ships only in the PowerShell pack, so a Python-pack-only consumer would lack it (the #769 review Minor (b) exposure, made reachable by pack selection); `PowerShell`-named functions in a Python hook misstate intent; dot-sourcing a hook entry script from another hook couples unrelated state functions. |

### 2.2 Why A

- Reusability: one implementation per runtime, and the two runtime copies are held identical by a test. This closes #769 review Minor (a) (`code-review.2026-09-29T15-33.md:40`).
- Packaging exposure (#769 review Minor (b), `code-review.2026-09-29T15-33.md:41`): placing the Claude helper in the Claude **core** pack (`pack-manifests/core.json`, label "Core (always included)", `:3`) means every consumer that receives either batch-budget hook also receives the helper. The Codex helper goes in the Codex core pack, where both Codex batch-budget hooks already are (`core.json:56`, `:58`). This removes the pack-selection cause of a missing sibling. A runtime `Test-Path` guard is not recommended: the reviewer recommended "Accept" (`:41`), the same exposure exists for the `HookPayload.psm1` import (`.claude/hooks/enforce-python-batch-budget.ps1:51`), and the guard branch cannot be exercised without deleting a file, which the test policy forbids.
- The helper contains no runtime-specific text (it reads no file and no environment variable, `.claude/hooks/enforce-powershell-batch-budget-route.ps1:5-10`), so the Claude and Codex copies can be byte-identical. The Codex bundle cannot carry `.claude/**` (#769 spec "Functions/classes/CLI commands impacted"), so two copies are required; the parity test makes them one contract.
- Hooks remain PowerShell only. No Python leg is introduced.

### 2.3 Proposed shared helper contract

File (both runtimes): `enforce-batch-budget-route.ps1`, no entry point, dot-sourced.

| New name | Replaces | Behavior |
|---|---|---|
| `ConvertFrom-BatchBudgetCheckpoint -CheckpointText` | `ConvertFrom-PowerShellBatchBudgetCheckpoint` | unchanged (`...-route.ps1:16-51`) |
| `Get-BatchBudgetSelectedRoute -CheckpointText` | `Get-PowerShellBatchBudgetSelectedRoute` | unchanged (`:53-90`) |
| `Test-BatchBudgetLargePathRoute -CheckpointText` | `Test-PowerShellBatchBudgetLargePathRoute` | unchanged (`:92-137`) |

The #769 review Nit on triple parsing (`code-review.2026-09-29T15-33.md:42`) is not addressed here; changing the helper signatures would widen the change without a behavior benefit.

### 2.4 Registration changes

| Surface | Change |
|---|---|
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json:9` | remove `.claude/hooks/enforce-powershell-batch-budget-route.ps1` |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add `.claude/hooks/enforce-batch-budget-route.ps1` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | add `.codex/hooks/enforce-batch-budget-route.ps1` (required by `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:165-167`, which enumerates every bundled `.codex/hooks` file) |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:32` and the bundle copy | replace the route-helper path with `.claude/hooks/enforce-batch-budget-route.ps1`; add `.codex/hooks/enforce-batch-budget-route.ps1` beside `:136-137` |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` | add `'enforce-batch-budget-route.ps1'` to `$script:SharedModuleNames` (in-place edit; the file stays at 497 lines). This subjects the Codex helper to the existing parse, 500-line, root/bundle byte-identity, no-`$env:CLAUDE_`, and core-manifest checks (`:96-142`). |
| Bundle files | add both helper copies to their bundles; delete `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget-route.ps1`. The repo-to-bundle parity test is one-directional (`test_push_down_claude_resource_contracts.py:118-143`), but a stale bundle file absent from every manifest fails `test_push_down_claude_pack_manifest_completeness.py:139-159`. |
| `.claude/settings.json`, `.codex/config.toml`, `Publish-DrmCopilotExtension.ps1` | no change |

---

## 3. Direct-Mode and Large-Path Semantics (mirrors #769)

- Both Python hooks read `<Root>/artifacts/orchestration/orchestrator-state.json` through a `[scriptblock] $ReadCheckpoint` seam, before any state operation. `<Root>` is the existing root (`Split-Path (Split-Path $PSScriptRoot -Parent) -Parent` in the Claude hook, `:312`; `$repositoryRoot` in the Codex wiring, `:226`).
- Large path (non-terminal `large`, `remediation`, `preparation`): allow every Python path, no counting, no state directory creation, no state read or write.
- Direct mode: count distinct production Python paths only; deny the 4th. Test paths (D2) are allowed and not recorded.
- Remove the Claude env override (`:423-430`) and both persisted cap overlays (Claude `:211-212`, Codex `:75-76`). Keep `ProdCap` (default 3) for testability only. Keep `-TestCap` as an optional, ignored parameter with the same `PSReviewUnusedParameter` suppression #769 used (`.claude/hooks/enforce-powershell-batch-budget.ps1:186`, `:203`), because existing callers pass it (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:228`; `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1:116`, `:124`, `:133`, `:143`). Make `-StateFile` optional (D6).
- Legacy state files carrying `prodCap`, `testCap`, `testFiles` load without error; only `prodFiles` is carried over (containment filter retained in the Claude hook).
- Fresh state is `[ordered]@{ prodCap; prodFiles }`. `prodCap` stays in state because `codex-batch-budget-hooks.Tests.ps1:120` asserts `$decision.state.prodCap | Should -Be 3` for both rows.
- Add `Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw -RepositoryRoot -HookSeams` to the Codex Python hook (D8), mirroring `.codex/hooks/enforce-powershell-batch-budget.ps1:384-448`, so the entry point is testable in-process with seams.
- Unchanged: fail-closed envelope deny (Claude) and malformed-JSON deny (Codex); allow on missing `file_path` or non-`.py` path before the checkpoint is read; out-of-root discard (Claude); session-id resolution; `-RequireSessionId` (Codex, bound by `codex-pretooluse-transport.Tests.ps1:127-134`); both rename sides evaluated; deny-only output with `state` stripped; `Get-PythonBatchBudgetBlockDecision` name, parameters, and shape (bound by `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:77-81`).

### 3.1 Deny messages

Claude:

```
PYTHON_LARGE_PATH_REQUIRED: this change touches more than 3 production Python files (already counted: <a>, <b>, <c>; requested: <d>). A change of this size belongs on the orchestrated large path, which has no production-file cap. Route the change through /orchestrate. Checkpoint route observed: <route or 'none'>.
```

Codex: identical except `Route the change through .codex/prompts/orchestrate-work.md.` (file verified present).

Neither message contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, `python-batch-budget.`, or the state directory.

### 3.2 Estimated line counts after the change

| File | Now | Estimate | Basis |
|---|---|---|---|
| `.claude/hooks/enforce-python-batch-budget.ps1` | 454 | about 480-486 | the same edit took the PowerShell hook from 457 to 486 with the helpers already external |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 254 | about 340 | post-#769 Codex PowerShell hook (461) minus its inline helpers (`:53-174`) |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 461 | about 340 | inline helpers removed, one dot-source line added |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 486 | 486 | dot-source path and two call names change in place |
| `enforce-batch-budget-route.ps1` (each runtime) | new | about 137 | copy of the #769 helper with neutral names and docstring |

All stay under 500. The executor must measure actual counts.

---

## 4. Tests Binding Current Behavior

| File (lines now) | Binding | Required change |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` (485) | `:53-62` test path recorded; `:83` `*production file cap is 1*`; `:88-97` test-cap deny with `*test file cap is 1*`; `:136` loaded `testFiles` asserted; `:228-236` deny via decision (passes unchanged); `:474-483` sets `CLAUDE_PYTHON_BUDGET_*` (passes unchanged; malformed JSON denies before any cap logic); `:37-38` clears those variables | Invert `:53-62` (test path allowed, not recorded); delete `:88-97`; change `:83` to `PYTHON_LARGE_PATH_REQUIRED:*`; drop the `testFiles` assertion at `:136`. Add no new cases here (15 lines of headroom). For determinism, set `$PSDefaultParameterValues['Invoke-PythonBatchBudgetHook:ReadCheckpoint']` to an empty-text reader in `BeforeAll` (one line) instead of editing each call; calls with `-Root '/repo'` already miss the checkpoint, and no entry-point case reaches the checkpoint read (each fails the envelope or extension check first). |
| `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` (371) | Shared `-ForEach` Python row `ExtraSeams = @{}` (`:80`); Python-only cap Context `:276-370` asserts `testCap`, persisted `prodCap 5`/`testCap 4` overlay, `production file cap is 1` + `state.json`, `test file cap is 0`, test slot consumed, persisted cap honored | **Required:** set the Python row's `ExtraSeams` to the empty `ReadCheckpoint` seam the PowerShell row uses (`:90`). Without it, `:204`, `:221`, `:235` pass `-Root $script:RepoRoot`, the hook reads the live checkpoint (`artifacts/orchestration/orchestrator-state.json:8` is `route_id: large` in this worktree), takes the large path, and `:207-209` (state directory ensured and file recorded) fails. Delete the Python-only cap Context (`:276-370`, about 95 lines) and move its surviving intent into the new Codex Python routing suite, as #769 did for the PowerShell Context. Update the header comment `:4-13` ("per-batch"). |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (497) | `:227-231` Python decision with `-ProdCap 1 -TestCap 1` and `-StateFile` denies `src/second.py` | No change: still a direct-mode deny if `-TestCap` is retained as an optional ignored parameter. Only `:30` changes (Section 2.4). Leaves 3 lines of headroom; add nothing else. |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (171) | `:77-81` `Get-PythonBatchBudgetBlockDecision -Reason` deny shape | No change. Dot-sourcing the hook now also dot-sources the helper. |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (353) | `:125` `Test-PowerShellBatchBudgetLargePathRoute`; `:136` `Get-PowerShellBatchBudgetSelectedRoute` | Rename the two calls to the neutral names. |
| `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (382) | `:136`, `:147` same two functions | Rename the two calls. |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (492), `codex-pretooluse-integration.Tests.ps1` (210) | session_id required (`transport :127-134`); no Python state left for benign payloads (`integration :192-202`) | No change; re-run. |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:172-183` | every `.codex/hooks/*.ps1` within 500 lines | No change; the new Codex helper is covered by it. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_orchestrator_direct_command_contracts.py:10,16` (binds `.github/agents/python-orchestrator.agent.md` to its bundle copy), `test_generate_codex_agent_variants.py` | bundle parity, manifest completeness, generated-variant drift | No edit; re-run. The TypeScript twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` is also re-run. |

No `.py` file needs editing.

---

## 5. Python Policy Text Surfaces

Canonical `.github/copilot-instructions.md` and `.github/instructions/*.md` carry no per-batch or production-file-count text (search `(?i)batch|production files|budget` over each returned only `typescript-code-change.instructions.md:202`, an unrelated event-debounce sentence). They are not modified. `.claude/rules/python.md` and `.agents/skills/python/SKILL.md` have no change-budget section (both read in full); no change. `atomic-plan-contract`, `atomic-executor`, `atomic-planner`, and the `python-atomic-*` agents carry no cap text (searches returned no match); `python-qa-gate` uses "batch" only for a plan work unit (`.claude/skills/python-qa-gate/SKILL.md:15`, `:77`).

### 5.1 Per-batch, batching, budget-override, and scope-expansion text (remove; replace with the routing rule)

| File | Lines | Content |
|---|---|---|
| `.claude/skills/python-change-budget-router/SKILL.md` | `:3`, `:8`, `:17`, `:26-33`, `:35-49`, `:79` | description, per-batch intro, executor batch check, "Per-Batch Change Budget (Hard Gate)" with `budget: prod=<N>, test=<M>`, "Scope Expansion Protocol", override documentation line |
| `.agents/skills/python-change-budget-router/SKILL.md` | same lines | same text (differs from `.claude` only at `:62`) |
| `.claude/skills/invoke-python-engineer/SKILL.md` | `:3`, `:26` | "3-production + 3-test per-batch budget"; `budget:` override input |
| `.agents/skills/invoke-python-engineer/SKILL.md` | `:3`, `:26` | "three-production plus three-test per-batch budget"; `budget:` override input |
| `.claude/agents/python-typed-engineer.md` | `:4`, `:40`, `:61` | description; Routing and scope step; stop condition "in-flight batch would exceed the 3-production-file cap" |
| `.codex/agents/python-typed-engineer.toml` | `:32`, `:68`, `:89` | same three; then regenerate `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` with `scripts/dev_tools/generate_codex_agent_variants.py` (Python family is `python-typed-engineer` only, `:45`) |
| `.github/agents/python-typed-engineer.agent.md` | `:62-74`, `:76-80` | scope-control approval text tied to 3 files; "Change budget (hard gate)" per batch 3/3 with `budget:` override |
| `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1` | docstrings `:1-43` / `:2-30`; messages `:293` / `:137` | Section 3 |

### 5.2 Test-file routing clause (remove; routing is decided by production files only)

| File | Lines |
|---|---|
| `.github/agents/python-orchestrator.agent.md` | `:100`, `:120`, `:129`, `:246` (">3 test Python files" routes large; small path "1-3 test Python files") |
| `.github/prompts/orchestrate-python-work.prompt.md` | `:23`, `:26` |
| `.codex/agents/python-orchestrator.toml` | `:31` ("`>3` test files") |

Rationale: the hooks will not count test files; the #769 PowerShell equivalents route on production files only (`.github/agents/powershell-orchestrator.agent.md:102`, `:248`; `.github/prompts/orchestrate-powershell-work.prompt.md:26`); and the Codex resolver routes only on `production_file_count > max_production_files` (`scripts/dev_tools/resolve_codex_topology.py:239`), reporting `max_test_files` without using it. This is a routing-dimension correction, not a threshold-number change. It is recommended in scope; if the spec author prefers to hold `issue.md:37` ("no threshold text changes") literally, it becomes a follow-up entry.

### 5.3 Excluded, with reason

- `.github/agents/python-execution-only-typed.agent.md:34-37` (and bundle copy): a separate execution-only agent with a 30/30 per-batch cap and `budget:` override. No routing surface delegates to it (search for `python-execution-only-typed` outside `docs/` found only `virtual/` debug artifacts), and its Codex conversion `.codex/agents/python-execution-only-typed.toml` carries no budget text. Same treatment as `Powershell DI Unit Test Engineer.agent.md` in #769. Flag for the owner.
- Language-generic orchestrator surfaces: `.claude/agents/orchestrator.md:75`, `.github/agents/orchestrator.agent.md:17,167,283`, `.github/prompts/orchestrate-work.prompt.md:25,37`, `.codex/agents/orchestrator*.toml:37-38` ("apply its batch cap"), `.claude/skills/translate-copilot-to-claude/SKILL.md:62`. `.github/agents/orchestrator.agent.md:283` and `orchestrate-work.prompt.md:37` carry the same ">3 test files" clause; recommend a follow-up entry. After #769 and #773, only the C# router still has a batch cap, so the Codex orchestrator's "apply its batch cap" phrasing will be partly stale; covered by the existing `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md`.
- `.claude/agents/python-typed-engineer.md:42` and `.codex/agents/python-typed-engineer*.toml:70` "Implement in batches", `.github/agents/python-typed-engineer.agent.md:12-14,143-150` "small batches": plan work units, not the cap (same exclusion as #769).
- Observation outside scope: `.agents/skills/invoke-powershell-engineer/SKILL.md:26` still offers the `budget: prod=<N>, test=<M>` input after #769 (its AC-16 covered only the `.claude` copy). Record as a follow-up rather than widening #773.

### 5.4 Bundle mirrors

- `.claude/**` -> `extensions/drm-copilot/resources/claude-customizations/.claude/**`
- `.codex/**`, `.agents/**` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/**`
- `.github/**` -> `extensions/drm-copilot/resources/customizations/.github/**` (all five in-scope `.github` files have bundle copies, verified by glob)

---

## 6. Replacement Text for the Router (Question 5)

The router's "Per-Batch Change Budget (Hard Gate)" (`:26-33`) and "Scope Expansion Protocol" (`:35-49`) both assume a cap that applies during execution, and both resolve an over-threshold change by user approval or override rather than by routing. Under the owner direction the only sanctioned way past 3 production files is the large path. Recommendation: align the Python router with the post-#769 PowerShell router structure (`.claude/skills/powershell-change-budget-router/SKILL.md:1-49`).

- **Description (`:3`):** "Budget-first routing contract for Python work: estimate production-file scope, choose small vs large path, and route direct-mode work of more than 3 production files to the orchestrated large path."
- **Intro (`:8`):** drop "and for enforcing per-batch change budgets during execution"; name `/orchestrate` (the `orchestrator` agent) on the Claude copy.
- **When to Use (`:17`):** delete the executor batch-check bullet.
- **Canonical Routing Rules (`:24`):** "More than 3 production files -> **large path** (`/orchestrate`, the `orchestrator` agent). The large path has no production-file cap. Test files are not counted toward the routing threshold."
- **Delete** "Per-Batch Change Budget (Hard Gate)" and "Scope Expansion Protocol".
- **Direct-Mode Rejection Rule (`:51-56`):** extend to cover discovery during implementation: "If `python-typed-engineer` is invoked directly and the estimated scope, or the scope discovered during implementation, is more than 3 production files: stop before editing the 4th production file, report the production files already changed and those still required, and return an explicit routing instruction to invoke `/orchestrate`. Do not request a budget override; routing is the only path past the threshold."
- **Minimal-seam list (`:45-49`):** delete from the router (the PowerShell router has none). The same list in `.github/agents/python-typed-engineer.agent.md:62-65` can remain as a description of what a direct-mode slice may include, provided it no longer implies that exceeding 3 files is an approval question.
- **Documentation Expectations (`:79`):** delete "any requested budget override and its approval state".
- `.agents` copy: same edits, naming `.codex/prompts/orchestrate-work.md` as the routing target in place of `/orchestrate`, and keeping its own `:62` MCP wording.
- `.github/agents/python-typed-engineer.agent.md`: replace `:66` with "If the change requires more than 3 production files, stop and instruct the caller to use `python-orchestrator` (or `.github/prompts/orchestrate-python-work.prompt.md`)"; keep the scope-expansion STOP block (`:70-74`) for files outside the approved scope (the PowerShell agent keeps the same block, `.github/agents/powershell-typed-engineer.agent.md:122-126`); replace section 2 (`:76-80`) with "Direct mode budget: 1-3 production Python files (+ corresponding tests). Test files are not counted toward the routing threshold, and the orchestrated large path has no production-file cap." The `:138` sentence "decide upfront to split now (counting new files against the budget) or seek an override" should drop "or seek an override".
- `invoke-python-engineer` (`.claude`, `.agents`): description "... the 1-3 production-file direct-mode budget with routing to the orchestrated large path above it ..." (the #769 PowerShell wording, `.claude/skills/invoke-powershell-engineer/SKILL.md:3`); delete the `budget:` input at `:26`; `:18` names `/orchestrate` (Claude) or the Codex entry (`.agents`).
- `python-typed-engineer` (`.claude` agent and `.codex` base): description as for the invoke skill; `:40`/`:68` "apply `python-change-budget-router` to estimate scope and select direct mode (1-3 production files) vs large-path escalation through `/orchestrate`. The large path has no production-file cap."; stop condition `:61`/`:89` "the scope estimate exceeds 3 production files in direct mode".

---

## 7. Coupling and Scope Boundary (Question 6)

- **Codex topology resolver:** Python budget is `max_production_files: 3`, `max_test_files: 3` (`scripts/dev_tools/resolve_codex_topology.py:70-75`; TypeScript `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts:63-64`). It routes on production count only (`:239`). It is already consistent with "1-3 small, more than 3 large". Out of scope; no change. The PowerShell value is covered by `docs/features/potential/2026-09-29-codex-routing-resolver-powershell-budget-two.md`.
- **`atomic-plan-contract`, `atomic-executor`, `atomic-planner`, `python-atomic-*`:** no cap text; no change.
- **`local_execution_overrides` validators:** no change (same reasoning as #769 research Section 5).
- **C#:** out of scope; existing entry `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md`.

---

## 8. Recommended Implementation Approach and Ordering

Current checkpoint: `route_id: large`, `path_selected: large`, `issue-num: 773`, `next_step: S3b_research` (`artifacts/orchestration/orchestrator-state.json:7-8,14,27`). `lifecycle_ready` is not yet present; the preimplementation gate requires it before any `.ps1` write (#769 research Section 5.1).

This run writes no `.py` file, so the live Python hook is not exercised by its own execution. The live PowerShell hook is the post-#769 hook; it reads the large route and allows every `.ps1` write. The live Claude PowerShell hook dot-sources its route helper on every `.ps1` write, so the helper rename must keep a loadable helper at every step:

1. Create `.claude/hooks/enforce-batch-budget-route.ps1` (neutral names). The old helper still exists.
2. Edit `.claude/hooks/enforce-powershell-batch-budget.ps1`: add a dot-source of the new helper next to the existing one (both sets of names load).
3. Change its two call sites (`:395-396`) to the neutral names.
4. Remove the old dot-source line (`:63`).
5. Delete `.claude/hooks/enforce-powershell-batch-budget-route.ps1` and its bundle copy (a `git rm` or equivalent; the plan must name the command because the file tools cannot delete).
6. Edit the Claude Python hook (dot-source the helper, seam, decision, message, removals, docstring).
7. Create `.codex/hooks/enforce-batch-budget-route.ps1` byte-identical to step 1; edit the Codex PowerShell hook to dot-source it and remove its inline helpers (`:53-174`); edit the Codex Python hook (dot-source, seam, decision, message, entry-point function, docstring).
8. Mirror every changed hook and helper into its bundle; update pack manifests and both runsettings.
9. Tests (Section 9), then text surfaces (Section 5), then `generate_codex_agent_variants.py`, then mirrors of every changed text file.

Regression-first ordering for `[expect-fail]` tasks: the new routing suites can be added before step 6/7 and must fail on the missing seam or message. Tests that rename the PowerShell helper calls must land with step 3 (they fail between steps 1 and 3 only if run then).

Rejected alternatives: carrying separate Python copies (Section 2.1-B); dot-sourcing the PowerShell-named helper (2.1-C); keying on `agent_type`, resetting counts at phase boundaries, or raising the cap for orchestrated runs (all rejected in #769 research Section 7).

---

## 9. Proposed File List

Production PowerShell (hooks, helpers, and bundle copies):

1. `.claude/hooks/enforce-python-batch-budget.ps1` (modify)
2. `.codex/hooks/enforce-python-batch-budget.ps1` (modify)
3. `.claude/hooks/enforce-batch-budget-route.ps1` (new; replaces `.claude/hooks/enforce-powershell-batch-budget-route.ps1`, which is deleted)
4. `.codex/hooks/enforce-batch-budget-route.ps1` (new)
5. `.claude/hooks/enforce-powershell-batch-budget.ps1` (modify: dot-source path and two call names)
6. `.codex/hooks/enforce-powershell-batch-budget.ps1` (modify: inline helpers removed, dot-source added)
7. Bundle copies of 1-6 under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, plus deletion of the bundled `enforce-powershell-batch-budget-route.ps1`.

Configuration / manifests: Claude `pack-manifests/powershell.json`, Claude `pack-manifests/core.json`, Codex `pack-manifests/core.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.

Policy text: every file in Sections 5.1 and 5.2, the five regenerated Codex variants, and the bundle mirror of each.

Tests:

- New: `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` (the existing suite has 15 lines of headroom).
- New: `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`.
- New: `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` (byte identity of the two helper copies; the route predicate table run once against each copy). An alternative location is `tests/scripts/claude-hooks/`; the Codex tree is proposed because the existing root/bundle identity checks for Codex hooks live there.
- Modified: `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`, `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`:30` only), `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (`:125`, `:136`), `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (`:136`, `:147`).
- Re-run unchanged: `PreToolUseSchema.Contract.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, and the Pytest parity/completeness suites in Section 4.

---

## 10. Proposed Acceptance Criteria (mirrors #769 AC-1..AC-23)

1. In direct mode (no checkpoint, or selected route `small`), the Claude Python hook allows the first three distinct production Python paths and denies the 4th; the reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `/orchestrate`.
2. In direct mode, the Codex Python hook denies the 4th distinct production Python path; the reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
3. Neither Python deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, or the state-file path; asserted by unit tests for both hooks.
4. With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither Python hook denies any Python path for count at any number of distinct production files, and neither writes state or creates the state directory for those paths.
5. Route precedence matches #769 AC-5 in both Python hooks.
6. Missing, malformed, non-object, blank-route, unknown-route, `next_step: "complete"`, and `S12_complete` checkpoints each yield direct-mode enforcement in both Python hooks, and no checkpoint condition causes a non-zero exit.
7. Test Python paths (`tests/**/*.py`, `test_*.py`) are never denied for count and are not recorded, in either mode, in both hooks.
8. `CLAUDE_PYTHON_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file with `prodCap`, `testCap`, `testFiles` loads without error in both hooks; no Python hook source references `CLAUDE_PYTHON_BUDGET`.
9. Existing behaviors hold in both Python hooks: fail-closed envelope/malformed-JSON deny, out-of-root discard (Claude), repeated-path allow without a state write, deny-only output with `state` stripped, session_id required (Codex), and the `Get-PythonBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
10. The Codex Python hook reads no `$env:CLAUDE_` variable, and its entry point is a testable function (`Invoke-PythonBatchBudgetCodexEntryPoint`) exercised in-process through seams.
11. The checkpoint is supplied to both Python hooks through an injectable seam, and no new or modified test creates a temporary file.
12. The route helpers exist once per runtime as `.claude/hooks/enforce-batch-budget-route.ps1` and `.codex/hooks/enforce-batch-budget-route.ps1`; both PowerShell and both Python hooks dot-source their runtime's copy; the Codex PowerShell hook contains no inline route helper; a test asserts the two copies are byte-identical.
13. `.claude/hooks/enforce-powershell-batch-budget-route.ps1` and its bundle copy no longer exist; the Claude helper is listed in the Claude core pack manifest and not in the PowerShell pack; the Codex helper is listed in the Codex core pack manifest and in `SharedModuleNames`; both runsettings copies list both helpers.
14. The #769 PowerShell routing suites pass with the renamed helper functions, and PowerShell hook behavior is unchanged.
15. New suites `enforce-python-batch-budget-routing.Tests.ps1`, `codex-python-batch-budget-routing.Tests.ps1`, and the helper parity suite pass; the updated `enforce-python-batch-budget.Tests.ps1` and `codex-batch-budget-hooks.Tests.ps1` pass, and the Python row of the shared Codex Context injects an empty checkpoint.
16. A case-insensitive search for `per-batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, `in-flight batch`, and `budget: prod=` returns no match in Python-scoped files (path contains `python`, including skill directories) under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, `.github/prompts/`, or their bundle mirrors, excluding `.github/agents/python-execution-only-typed.agent.md` and its mirror.
17. Python routing text on every runtime states `1-3` production files for the small/direct path and more than 3 for the large path, states that the large path has no production-file cap, and contains no test-file routing clause (Section 5.2 files).
18. Claude-surface Python routing instructions (`python-change-budget-router`, `invoke-python-engineer`, `python-typed-engineer`) name `/orchestrate`.
19. Neither `invoke-python-engineer` copy offers the `budget: prod=<N>, test=<M>` input, and neither router copy contains a "Per-Batch Change Budget" or "Scope Expansion Protocol" section.
20. Every generated variant of `.codex/agents/python-typed-engineer.toml` is regenerated with `generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
21. Bundle parity and manifest completeness pass (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness suites and the TypeScript twin, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and core-manifest checks in `legacy-codex-hook-contracts.Tests.ps1`); every changed `.github` file is identical to its bundle copy.
22. `.github/copilot-instructions.md` and `.github/instructions/*` are unchanged relative to `main`.
23. No production or test file created or modified exceeds 500 lines.
24. PoshQC format -> analyze -> test passes with zero analyzer findings, line coverage >= 85% for each changed hook and both helper copies, and no coverage regression on changed lines.
25. Hook docstrings describe the routing model and the stale-checkpoint limitation with the #673 mitigation, and contain no per-batch or state-file-deletion guidance.
26. Follow-up entries are recorded for the generic orchestrator test-file routing clause (Section 5.3), `python-execution-only-typed` (owner decision), and the residual `.agents/skills/invoke-powershell-engineer/SKILL.md:26` override input.

Criteria 16 and 17 are stated as searches and content requirements, not counts (see Numeric Derivation Evidence).

---

## 11. Testing Implications

Pester v5 through PoshQC; in-memory seams only (`ReadCheckpoint`, `TestPathExists`, `EnsureDirectory`, `ReadState`, `WriteState`, `HookSeams`), no temporary files, no dependence on the live checkpoint. Reuse the #769 routing-suite structure (`tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1:16-352`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1:19-381`) with Python paths (`src/a.py`, `scripts/b.py`, test paths `tests/unit/test_a.py` and a root-level `test_a.py` to cover both D2 rules). The route predicate table need not be repeated in the Python suites; the parity suite covers it for both helper copies. The Python suites cover the integration cases: large routes allow six production paths with zero writes and zero ensures; `path_selected`-only large; terminal large denies the 4th; throwing reader denies; unreadable envelope still denies under a large route; checkpoint path is `<root>/artifacts/orchestration/orchestrator-state.json`; non-`.py` paths do not read the checkpoint; legacy keys ignored; env variables ignored (Claude, with the prior value restored in `AfterEach` to address the #769 Nit at `code-review.2026-09-29T15-33.md:44`); Codex entry point allow/deny/exit-2 cases.

Coverage evidence: the MCP PoshQC test runner reads the installed extension's runsettings, so new files (both helpers) will be absent from the canonical coverage artifact until the extension is rebuilt, as recorded for #769 (`code-review.2026-09-29T15-33.md:45`). The plan should obtain per-file coverage for the helpers from a direct Pester run and record it under the feature `evidence/qa-gates/` folder.

Validate end-to-end in the session worktree, not an isolated subagent (isolated worktrees load `origin/main` hooks; #769 research Section 2.3).

---

## Numeric Derivation Evidence

No numeric count is proposed for any acceptance criterion. The independent searches disagreed for both families below; the union sets are the working sets in Section 5, and the related criteria (16, 17) are stated as searches.

### Family A - Python per-batch / batching / budget-override text surfaces

- **Complete Family:** tracked, non-bundle, non-test, non-`docs/` files scoped to Python routing (typed engineer, its invoke skill, the router, the two Python batch-budget hooks, generated Codex variants) that state a per-batch or batch cap, offer a budget override, or resolve an over-threshold change by approval.
- **Exhaustive Search Scope:** `.claude/`, `.agents/`, `.codex/`, `.github/` (excluding `extensions/**`, `docs/**`, `tests/**`, `virtual/**`, `artifacts/**`).
- **Inclusion Rules:** path contains `python` (file name or directory name); matching text refers to the typed-engineer/hook production-and-test cap or its override.
- **Exclusion Rules:** `.github/agents/python-execution-only-typed.agent.md` (separate 30/30 agent, Section 5.3); `python-qa-gate` "Zero-Regression Hard Gate" (unrelated); "Implement in batches" plan-unit text.
- **Primary Search Strategy or Query Expression:** `(?i)per-batch|smaller batches|split the work|new batch|batch cap|per batch|three-test|three-production|split .{0,20}batch|budget: prod|budget override|scope expansion` with ripgrep glob `*python*` (matches the file basename only).
- **Primary Member Set:** `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, `-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`, `.github/agents/python-typed-engineer.agent.md`
- **Primary Count:** 10
- **Cross-check Search Strategy or Query Expression:** `(?i)in-flight batch|production-file cap|budget override|requested budget|override of the form|3/3|test file cap|hard gate|beyond \*{0,2}3|exceeds 3|>\s*3 test|test Python files|within the 3-file cap` with path-inclusive glob `{**/*python*,**/*python*/**}`.
- **Cross-check Member Set:** `.claude/skills/python-change-budget-router/SKILL.md`, `.agents/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, `.agents/skills/invoke-python-engineer/SKILL.md`, `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, `-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`, `.github/agents/python-typed-engineer.agent.md`
- **Cross-check Count:** 12
- **Member-set Comparison:** disagree. The primary misses all four skill files because the basename glob excludes `SKILL.md` under `python-*` directories. The cross-check misses both hooks (their text uses `per-batch cap` and an interpolated `$kind file cap`, not the literal `test file cap`). The union has 14 members and is the working set for Section 5.1. A numeric assertion is withheld.

### Family B - Python test-file routing clause

- **Complete Family:** tracked, non-bundle, non-test, non-`docs/` Python-scoped routing text that routes on a test-file count.
- **Exhaustive Search Scope:** same as Family A.
- **Inclusion Rules:** Python-scoped orchestrator or orchestration prompt text stating a test-file threshold for path selection.
- **Exclusion Rules:** language-generic orchestrator files (Section 5.3); resolver code that reports `max_test_files` without routing on it.
- **Primary Search Strategy or Query Expression:** the Family A cross-check expression (its `>\s*3 test|test Python files` alternatives) over the path-inclusive glob.
- **Primary Member Set:** `.github/agents/python-orchestrator.agent.md`, `.github/prompts/orchestrate-python-work.prompt.md`
- **Primary Count:** 2
- **Cross-check Search Strategy or Query Expression:** `(?i)test|budget|>3|1-3` over `.codex/agents/python-orchestrator.toml`, plus `(?i)batch|budget|override|expan|3 production|three production|production files|prod=` over `.codex/agents/python-*.toml`.
- **Cross-check Member Set:** `.codex/agents/python-orchestrator.toml` (`:31`, "`>3` test files")
- **Cross-check Count:** 1
- **Member-set Comparison:** disagree. The primary misses the Codex file because a backtick sits between `>3` and `test`. The union has 3 members and is the working set for Section 5.2. A numeric assertion is withheld.

---

## Automation Feasibility

Fully automatable. Every change is a file edit, one file deletion per runtime pair (the old Claude helper and its bundle copy, which requires a named shell command such as `git rm` in the plan because the file-edit tools cannot delete), deterministic regeneration with `scripts/dev_tools/generate_codex_agent_variants.py`, and byte-copy mirroring into the extension bundle. Verification uses PoshQC (format, analyze, test), direct Pester runs for per-file coverage of the new helpers, and the existing Pytest parity and completeness suites. New behavior is unit-testable through injected seams with in-memory checkpoint text; no live orchestration run, network access, or manual step is required. Ordering constraints: set `lifecycle_ready` before the first `.ps1` write, and follow the helper-rename sequence in Section 8 so the live Claude PowerShell hook can load a route helper at every step.
