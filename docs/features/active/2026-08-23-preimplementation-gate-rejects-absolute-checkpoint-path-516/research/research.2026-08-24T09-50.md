# Research: preimplementation gate rejects absolute checkpoint path (Issue #516)

- Date: 2026-08-24
- Researcher: task-researcher
- Worktree: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-24T09-02` (branch `drm-copilot-wt-2026-08-24T09-02`)
- Issue copy: `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/issue.md`
- Subject file: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (340 lines at research time)

## 1. Current State Analysis (Q1)

### 1.1 Decision flow of the hook

All line references are to `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` unless stated otherwise.

- Lines 9: imports the shared payload reader `.claude/lib/hook-payload/HookPayload.psm1` via `$PSScriptRoot`.
- Line 11: `$script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'` — the readiness checkpoint the gate reads (relative to the process working directory; see `Get-CheckpointContent`, lines 194–203, which calls `Test-Path -LiteralPath` / `Get-Content` on the relative literal).
- Lines 18–26: `$script:CheckpointPaths` — seven repo-relative checkpoint literals added by issue #535. The comment at lines 13–17 states the contract: "a list of repo-relative literals behind a single membership check: no directory prefix, no glob, and no absolute-path entry."
- Lines 57–63: `Test-FeatureDocumentationOrEvidencePath` — exemption 1: `$NormalizedPath.StartsWith('docs/features/active/')`. `[string]::StartsWith(string)` is case-sensitive.
- Lines 65–77: `Test-ImplementationPath` — exemption order: feature-doc/evidence prefix first (lines 70–72), then checkpoint-literal membership `-contains` (lines 73–75; PowerShell `-contains` is case-insensitive), then the implementation-extension classifier `-match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'` (line 76; `-match` is case-insensitive).
- Lines 79–103: `Test-ImplementationCommand` — command-regex classifier for the Bash matcher; not path-based, not affected by this defect.
- Lines 105–138: `Test-PreparationModeDelegation` — issue #535 preparation-mode exemption (agent exactly `orchestrator` plus both markers at lines 31–34 in the field-scoped `prompt`).
- Lines 140–162: `Test-ImplementationDelegation` — preparation probe first (fail-through on error, lines 149–158), then the whole-payload agent-name regex (lines 160–161).
- Lines 164–192: `Test-OrchestrationReady` — requires non-empty `issue-num`, `feature-folder` starting with `docs/features/active/`, `route_id` (with `path_selected` fallback, lines 175–177), and truthy `lifecycle_ready`.
- Lines 235–287: `Invoke-OrchestrationPreimplementationGateDecision`. The defect site is lines 258–260:

  ```powershell
  if ($filePath) {
      $normalized = ([string]$filePath) -replace '\\', '/'
      $requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
  ```

  Only separators are normalized; the workspace root is never stripped, so an absolute spelling of an exempt path fails both exemptions, matches the `\.json$` extension pattern, and requires a ready checkpoint that cannot exist yet. Block reason text is the single generalized message at line 286.
- Lines 246–252: envelope anomalies fail closed as deny (shared reader anomaly text).
- Lines 289–325: `Invoke-OrchestrationPreimplementationGateEntryPoint` — payload-acquisition seam (`-ReadPayload`), always returns exit code 0.
- Lines 328–330: dot-source guard for tests; lines 335–340: script tail that emits the decision and exits.

### 1.2 Hook invocation context

- `.claude/settings.json` registers the hook with a **relative** command, `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, on the `Bash`, `Write|Edit`, and `Agent` matchers (settings.json lines 111–112, 156–157, and the Agent block; the registration is pinned by the test at `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:437-459`, expected command literal at line 443). A relative `-File` argument can only resolve if the hook process starts in the project root, so the runtime already guarantees cwd == workspace root.
- The hook already depends on that guarantee: `Get-CheckpointContent` (lines 199–202) reads the checkpoint via the cwd-relative literal. The issue #501 research records this as deliberate: "checkpoint-file reads the hooks perform ... remain cwd-relative by design" (`docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/research/2026-08-21T17-45-pretooluse-hook-payload-envelope-501-research.md:247-249`).
- The documented PreToolUse envelope carries a root-level `cwd` key, and hook processes receive `CLAUDE_PROJECT_DIR` (same research file, lines 15–16 and 82–84). Neither is consumed by any hook in this repository today.

### 1.3 Existing test assertions the fix must not break

File: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (461 lines). Every payload it builds uses **repo-relative** `file_path` values, which is exactly the blind spot the issue predicts (issue.md, "Suspected Cause" bullet 1).

Context "implementation writes before orchestration readiness" (lines 56–170):
1. Blocks an implementation write with generalized message; no `#232`; mentions "route metadata" and "lifecycle readiness" (57–68).
2. Deny schema survives serialize-then-parse (70–80).
3. Allows `docs/features/active/.../spec.md` (82–88) and evidence writes (90–96) with no checkpoint.
4. Allows implementation write when checkpoint is ready regardless of issue number (98–110, 162–169).
5. Blocks `pytest`, `git add`/`git commit`, formatter/test command payloads before readiness (112–149).
6. Blocks implementation delegation before readiness (151–160).

Context "tool input parsing and checkpoint resolution" (lines 172–244):
7. Empty payload → deny; unparseable JSON → deny with "not parseable JSON"; flat root shape → deny with "no tool_input key" (173–190).
8. Nested Bash envelope with no `file_path` → allow (192–199).
9. Documentation `.md` write allowed with no checkpoint (201–204).
10. Malformed checkpoint JSON → deny (206–211); `path_selected` fallback → allow (213–223); empty `feature-folder` → deny (225–235).
11. Null-payload unit assertions for `Test-OrchestrationReady` / `Test-ImplementationDelegation` (237–243).

Context "issue #535 checkpoint write exemptions" (lines 246–309):
12. Every one of the seven relative literals allowed against an explicitly not-ready checkpoint (259–274). The comment at 260–263 explains why the not-ready checkpoint must be supplied explicitly.
13. Backslash spellings of all seven literals allowed (276–288).
14. **Deny** `artifacts/orchestration/some-other-file.json` (290–298) — literal set, not directory prefix.
15. **Deny** `scripts/parallel-planner-state.json` (300–308) — full-path equality, not basename.

Context "issue #535 preparation-mode delegation exemption" (lines 311–399): verbatim parallel-plan and epic-plan kickoff prompts allowed; wrong agent, missing marker, marker without trailing period, and marker planted in a non-prompt field all denied.

Context "Entrypoint" (402–430): exit code always 0, decision JSON emitted, for empty transports / documentation write / unparseable JSON.

Context "Claude runtime registration" (432–460): both settings files register the exact relative command on all three matchers.

Additional structural guards that scan this hook's source:
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` derives the hook set from `.claude/settings.json` and asserts (i) `Import-Module` of `HookPayload.psm1` plus a `Read-ClaudeHookRawPayload` call, and (ii) that the literals `$env:CLAUDE_TOOL_INPUT` / `$env:CLAUDE_HOOK_INPUT` appear nowhere in the hook file, including comments (lines 14–26, 60–63). Consequence: the fix must not introduce those environment literals even in prose.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`: hooks must not invoke Python.

### 1.4 Issue #535 composition (merged PR #536)

Working-tree state and the #535 feature folder confirm the recent change this fix must compose with. `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/qa-gates/scope-and-size.2026-08-23T22-16.md:19-24` records the exact production/test surface #535 touched:

| File | Lines then |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 339 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 339 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 336 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 336 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 461 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 |

#535 added `$script:CheckpointPaths` (lines 18–26), the preparation markers (31–34), `Test-PreparationModeDelegation` (105–138), the try/catch probe inside `Test-ImplementationDelegation` (149–158), and the two `issue #535` test contexts. It was executed in two batches (claude pair, then codex pair) with a batch-budget reset between them (`evidence/other/batch-budget-reset.2026-08-23T21-54.md`), and verified mirror parity by pair hashes (`evidence/other/claude-pair-hash...md`, `codex-pair-hash...md`) plus the push-down parity gate (`evidence/qa-gates/pushdown-parity.2026-08-23T22-18.md`).

### 1.5 Blast radius: the four hook copies and the mirror contract

- The Claude hook is mirrored **byte-identically** at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; the push-down publisher copies the whole `.claude` tree byte-for-byte (`tests/scripts/dev_tools/test_push_down_claude_customizations.py:97-166`) and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` carries the root-to-bundle byte-identical mirror assertion (docstring lines 6–7, 107). Any edit to the `.claude` hook must be replicated byte-for-byte in the bundled copy.
- The Codex variant `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is **not** byte-identical (it dot-sources `codex-pretooluse-file-mapping.ps1` at line 11 instead of importing `HookPayload.psm1`) but carries the same defect: identical `Test-ImplementationPath` (lines 68–79), identical separator-only normalization at lines 272–273, and it additionally routes apply-patch hunk paths (lines 92–103) and mapped Edit/Write paths (lines 321–327) through the same classifier. Its bundled mirror is `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; its tests are in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- The issue also names `enforce-evidence-locations.ps1` and `enforce-feature-folder-order.ps1` as sharing the pattern. Verified: they do **not** share the defect, because both already match after any separator, and both make deny decisions where widening is safe. `enforce-evidence-locations.ps1:61-83` normalizes separators then matches each forbidden prefix with `"(^|/)$escapedPrefix"` — the comment at 76–77 says explicitly "to handle both relative and absolute path forms". `enforce-feature-folder-order.ps1:87` anchors with `(^|/)docs/features/(active|archive)/[^/]+/plan\.md$`. This `(^|/)` idiom is the repository's existing absolute-path accommodation — but it is only safe for a **deny** classifier or a scope trigger; see section 3.1 for why it must not be copied into an **allow** exemption.

## 2. Workspace-Root Resolution (Q2)

### 2.1 Survey of existing hook conventions

- **No hook reads `$env:CLAUDE_PROJECT_DIR` or runs `git rev-parse`.** A grep of `.claude/hooks/` for `CLAUDE_PROJECT_DIR` / `show-toplevel` returns zero hits; `$PSScriptRoot` appears only for module/library imports.
- **`(Get-Location).Path` with an optional-parameter seam is the established root convention**: `enforce-powershell-batch-budget.ps1:158` (`[string] $Root = (Get-Location).Path` on `Invoke-PowerShellBatchBudgetHook`), `enforce-python-batch-budget.ps1:155` (same), `persist-session-id.ps1:150` (`Join-Path -Path (Get-Location).Path`).
- The hook under change already assumes cwd == workspace root for its checkpoint read (section 1.2), and the settings registration proves the runtime guarantee (relative `-File` path).

### 2.2 Candidate assessment

| Mechanism | Worktree correctness | Determinism under Pester | Testability seam | Notes |
| --- | --- | --- | --- | --- |
| `(Get-Location).Path` default on an optional parameter | Correct: Claude Code launches hook processes in the project root (the worktree root, not the main checkout), proven by the relative `-File` registration and the working cwd-relative checkpoint read | Default never exercised for root-dependent assertions; tests always inject the root; existing relative-path tests are unaffected because relative inputs bypass stripping | Parameter injection — the exact seam shape of `enforce-powershell-batch-budget.ps1:158` | **Recommended.** Zero new assumptions; matches `.claude/rules/powershell.md` "Adapter seams for non-executable boundaries: ... narrow injectable parameters" |
| `$PSScriptRoot` two levels up | Correct for the executing copy (the hook file lives inside the worktree); the bundled mirror is never executed in place, and in a push-down destination the copy lives at `<dest>/.claude/hooks/`, so it also resolves correctly there | Deterministic, but when tests dot-source the hook, the resolved root is the real repo root — tests could not substitute a synthetic root without a second seam anyway | Weaker: `$PSScriptRoot` is fixed at dot-source time; still needs a parameter to inject | Viable fallback, but adds a second root-resolution mechanism alongside the existing cwd guarantee for no benefit |
| `$env:CLAUDE_PROJECT_DIR` | Documented for hook processes (#501 research lines 15–16) but unverified in this runtime and unset in Pester/Test Explorer | Mutable ambient environment — exactly what `.claude/rules/powershell.md` "Deterministic Test Requirements" forbids relying on | Would need env manipulation in tests | Rejected |
| `git rev-parse --show-toplevel` | Correct in a worktree | Live executable; forbidden in unit tests without a wrapper seam; slowest option (extra process per hook invocation, and this hook runs on three matchers) | Wrapper-function seam required | Rejected |
| Envelope root-level `cwd` key | Documented (#501 research lines 82–84) but no hook consumes envelope root keys except `enforce-epic-invocation-origin` (`agent_type`); would change the payload contract surface of this hook | Injectable via payload text | Rejected for scope: equals the process cwd in practice, so it buys nothing over `Get-Location` while enlarging the parsed surface |

### 2.3 Recommendation

Add an optional parameter to `Invoke-OrchestrationPreimplementationGateDecision`:

```powershell
[string] $WorkspaceRoot = (Get-Location).Path
```

and pass it to a new **pure** helper function (no filesystem, no subprocess, no environment read) defined in the hook file, e.g. `ConvertTo-WorkspaceRelativePath -FilePath <string> -WorkspaceRoot <string>`, whose output feeds the existing, unchanged `Test-ImplementationPath`. Tests inject a synthetic root (for example `C:/synthetic/root`) through the parameter; the default is exercised by the existing relative-path tests (relative inputs never consult the root).

Helper placement: **inside the hook file**, duplicated into the Codex variant, following the #535 precedent (the checkpoint list is likewise duplicated across the variant pair). The issue's suggestion of `.claude/lib/hook-payload/HookPayload.psm1` as the home was evaluated and rejected for this fix: the Codex variant does not import that module (`.codex/hooks/...gate.ps1:11` dot-sources its own transport), the module's own contract says "no filesystem access" and it is separately mirrored with its own test surface, so the module home would grow the change from 4 files to 6 plus module tests. Centralizing later (so `enforce-evidence-locations.ps1` and `enforce-feature-folder-order.ps1` could adopt it) is a legitimate follow-up, not part of #516.

## 3. Candidate Approaches for the Comparison Itself

### 3.1 Rejected alternatives (brief)

- **Segment-anchored suffix match (`(^|/)artifacts/orchestration/<literal>$`)** — the idiom `enforce-evidence-locations.ps1:76-83` uses. Rejected: it widens the exemption. `C:/any/other/repo/artifacts/orchestration/orchestrator-state.json` — outside the workspace — would become exempt, and the existing negative test "checkpoint-named file outside artifacts/orchestration/" (Tests.ps1:300-308) demonstrates the suite's intent that only the exact workspace-resolved path is exempt. The idiom is safe only where a match produces a deny.
- **Adding absolute literals to `$script:CheckpointPaths`** — impossible: the workspace root differs per machine and per worktree, and the list's own contract comment (hook lines 13–17) forbids absolute entries.
- **Filesystem canonicalization (`Resolve-Path`/`[IO.Path]::GetFullPath`)** — rejected: `Resolve-Path` requires the target to exist (the checkpoint does not yet exist at the moment that matters), `GetFullPath` consults the process cwd ambiently (hidden dependency, harder to pin in tests), and both drag filesystem/platform semantics into what must be a deterministic pure-string decision.

### 3.2 Selected approach

Pure-string, root-stripping normalization: reduce the incoming `file_path` to a repo-relative form when — and only when — it can be confidently shown to sit under the supplied workspace root; otherwise pass the separator-normalized input through unchanged so the existing classifier fails closed. The two exemptions (`docs/features/active/` prefix and checkpoint literals) and the extension regex are not modified at all; only the string handed to `Test-ImplementationPath` changes.

## 4. Normalization Algorithm (Q3)

### 4.1 Algorithm

Inputs: raw `file_path` string `P`, workspace root string `R` (from the seam). All steps are ordinal string operations.

1. Separators: `P' = P -replace '\\','/'`; same for `R`.
2. Collapse duplicate separators in `P'` and `R'` **except** a leading `//` (UNC server prefix): replace `(?<!^)/{2,}` with `/`.
3. Remove identity dot segments from `P'`: leading `./` (repeatedly), interior `/./`, trailing `/.`.
4. Fail-closed guard: if `P'` still contains a `..` segment (`^\.\./`, `/\.\./`, or `/\.\.$`), **skip stripping entirely** and return `P'` as-is. Textual `..` resolution is not attempted.
5. Root preparation: trim all trailing `/` from `R'`.
6. Segment-aligned prefix test: if `R'` is non-empty and `P'.StartsWith(R' + '/', [System.StringComparison]::OrdinalIgnoreCase)`, the candidate tail is `P'.Substring(R'.Length + 1)`. If the tail is non-empty, return the tail; if empty, return `P'` (degenerate: the path *is* the root — carries no extension, so the classifier allows it anyway).
7. Otherwise return `P'` unchanged (covers: relative paths, absolute paths outside the root, UNC paths under a non-UNC root, drive-relative forms).

Appending `'/'` to the root before the prefix test is what makes the match segment-aligned: root `C:/repo` tests the prefix `C:/repo/`, which `C:/repository/...` does not carry.

Case policy: the **root-prefix** comparison is `OrdinalIgnoreCase`, because Windows paths are case-insensitive, drive-letter case varies across tools, and Pester for this repo runs only on Windows (`.github/workflows/_poshqc.yml:10`, `runs-on: windows-latest`). The **tail** comparisons are deliberately left with their existing, mixed semantics — `-contains` case-insensitive (hook line 73), `StartsWith` case-sensitive (line 62), `-match` case-insensitive (line 76) — so the stripped tail behaves byte-for-byte like today's relative input. Changing tail case semantics would alter the existing contract and is out of scope.

### 4.2 Decision table

Root for all rows: `C:/wt/repo` (i.e. seam value `C:\wt\repo`). "ALLOW" means the path is exempt (or non-implementation); "DENY" means classified as an implementation write, therefore blocked whenever the checkpoint is not ready.

| # | Incoming `file_path` | Handling | Decision |
| --- | --- | --- | --- |
| 1 | `artifacts/orchestration/orchestrator-state.json` | relative; steps 6–7 no-op; existing literal match | ALLOW (existing) |
| 2 | `artifacts\orchestration\orchestrator-state.json` | separator normalization only | ALLOW (existing) |
| 3 | `C:\wt\repo\artifacts\orchestration\orchestrator-state.json` | strip root → literal | **ALLOW (the fix)** |
| 4 | `C:/wt/repo/artifacts/orchestration/orchestrator-state.json` | strip root → literal | **ALLOW (the fix)** |
| 5 | `c:\wt\repo\artifacts\orchestration\orchestrator-state.json` (drive-letter case) | OrdinalIgnoreCase prefix → literal | ALLOW |
| 6 | `C:/WT/REPO/artifacts/orchestration/orchestrator-state.json` (root-segment case) | OrdinalIgnoreCase prefix → literal | ALLOW (Windows fs is case-insensitive; same file) |
| 7 | Root supplied with trailing separator `C:/wt/repo/` | step 5 trims; same as row 3 | ALLOW |
| 8 | `C:/wt/repository/artifacts/orchestration/orchestrator-state.json` | prefix `C:/wt/repo/` not present → no strip → absolute string reaches classifier | **DENY** (segment alignment) |
| 9 | `C:/wt/repo//artifacts//orchestration/orchestrator-state.json` | duplicate separators collapse → literal | ALLOW (filesystem treats `//` as `/`; same file) |
| 10 | `C:/wt/repo/./artifacts/orchestration/orchestrator-state.json` | `.` segments removed → literal | ALLOW (identity segments; same file) |
| 11 | `C:/wt/repo/x/../artifacts/orchestration/orchestrator-state.json` | `..` present → no strip (step 4) | **DENY** (fail closed; `..` is not resolved textually) |
| 12 | `//server/share/artifacts/orchestration/orchestrator-state.json` (UNC, non-UNC root) | leading `//` preserved; prefix fails → no strip | **DENY** (fail closed) |
| 13 | UNC path under a UNC root (`//server/share/repo` + same-root path) | same segment-aligned logic applies naturally | ALLOW (only when the seam root itself is that UNC root) |
| 14 | `C:/other/artifacts/orchestration/orchestrator-state.json` (absolute, outside root) | prefix fails → no strip | **DENY** (fail closed; identical to current behaviour) |
| 15 | `./artifacts/orchestration/orchestrator-state.json` | leading `./` removed → literal | ALLOW (behaviour change from today's DENY; the resolution is confident — `./` is identity) |
| 16 | `C:/wt/repo/docs/features/active/2026-08-23-...-516/evidence/x.json` | strip root → `StartsWith('docs/features/active/')` | **ALLOW (fixes exemption 2)** |
| 17 | `C:/wt/repo/scripts/dev_tools/x.py` | strip root → extension match | **DENY** (critical negative: absolute implementation writes stay gated) |
| 18 | `C:/wt/repo/artifacts/orchestration/some-other-file.json` | strip root → not in literal set | **DENY** (preserves Tests.ps1:290-298 semantics in absolute form) |
| 19 | `C:/wt/repo/scripts/parallel-planner-state.json` | strip root → not a literal | **DENY** (preserves Tests.ps1:300-308 semantics in absolute form) |
| 20 | `C:artifacts/orchestration/orchestrator-state.json` (drive-relative, no slash) | matches no root prefix → no strip; contains `:` so it equals no literal | **DENY** (fail closed) |
| 21 | `C:\wt\repo/artifacts\orchestration/orchestrator-state.json` (mixed separators) | step 1 unifies → literal | ALLOW |
| 22 | `C:/wt/repo/ARTIFACTS/orchestration/orchestrator-state.json` (tail case variant) | strip → `-contains` is case-insensitive | ALLOW (identical to today's relative-tail semantics; not a widening) |
| 23 | `C:/wt/repo/DOCS/features/active/x/file.json` (tail case variant) | strip → `StartsWith` is case-sensitive → falls to extension match | **DENY** (identical to today's relative-tail semantics) |
| 24 | `C:/wt/repo` exactly (degenerate) | empty tail → pass-through; no extension | ALLOW (no extension → not an implementation path, same as today) |

The non-widening invariant holds: every row that ALLOWs either (a) already allowed today for the equivalent relative spelling, or (b) is a confidently-resolved absolute/`.`-normalized spelling of the *same file* as an already-exempt relative literal. Every form the algorithm cannot confidently resolve (rows 8, 11, 12, 14, 20) passes through unchanged and is denied by the unchanged classifier.

## 5. The `docs/features/active/` Exemption and Step Sharing (Q4)

Yes, it needs the same treatment. The reachable defect surface is narrower than the checkpoint one — `.md` files never match the extension regex at line 76, so only non-`.md` artifacts inside a feature folder are affected (a `.json`/`.yml` evidence artifact, a `.ps1` fixture under `evidence/`) — but the issue text confirms the misclassification (issue.md, "Actual Behavior", final paragraph), and the feature workflow does write such files (e.g., JSON evidence).

**One shared normalization step, not two.** The normalization already happens once, upstream of both exemptions, at hook lines 259–260; the fix replaces that one line pair with the one call to `ConvertTo-WorkspaceRelativePath` and leaves `Test-ImplementationPath` — which internally consults both exemptions — untouched. Two separate normalizations would create two divergence points and would also miss the extension regex itself (an absolute path currently matches the extension pattern only because the pattern is `$`-anchored on the filename; the stripped form matches identically, so a single upstream step keeps all three checks consistent).

The `Test-OrchestrationReady` `feature-folder` check at line 188 is a checkpoint-**content** check, not a tool-path check; it is out of scope and needs no change.

## 6. Test Strategy (Q5)

### 6.1 Placement and the 500-line cap

The existing test file is at 461 lines; the fix's case matrix (~20 `It` blocks) does not fit under the 500-line cap of `.claude/rules/general-code-change.md`. The repository already uses facet-named sibling files for exactly this (`enforce-pr-author-skill.epic-base-branch.Tests.ps1`, `enforce-completion-consistency.Payload.Tests.ps1`, `validate-orchestrator-output.model-routing.Tests.ps1`). Recommendation: new file `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1`, dot-sourcing the hook exactly as the existing file does (line 6–7 pattern). Keep every existing relative-path test unchanged — the issue's validation note (issue.md, "Proposed Fix") is explicit: "Keep the existing relative cases and add absolute twins; replacing them would relocate the blind spot rather than close it."

The Codex twin tests go to `tests/scripts/codex-hooks/` — `legacy-codex-hook-contracts.Tests.ps1` is at 494 lines, so a sibling facet file is required there too.

### 6.2 How each case is driven without the filesystem

Every case is a pure in-memory call. No temporary files, no `Test-Path`, no mocks of executables:

- **End-to-end decision cases**: build the nested envelope with the existing helper pattern (`ConvertTo-ImplementationWriteToolInput`, Tests.ps1:9-19), call `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $notReady -WorkspaceRoot 'C:\synthetic\root'`. Supplying `-CheckpointRaw` means `Get-CheckpointContent` (the only filesystem read on this path) never executes — the same isolation trick the #535 tests already use and document (Tests.ps1:260-263). Supplying `-WorkspaceRoot` removes any cwd dependency, satisfying Terminal/Test Explorer parity.
- **Unit cases on the pure helper**: call `ConvertTo-WorkspaceRelativePath -FilePath ... -WorkspaceRoot ...` directly and assert the returned string. This pins the algorithm (rows 5–13, 20–24 of the table) cheaply, one behaviour per `It`, without building envelopes.
- **Default-root line**: the existing relative-path tests call the decision function without `-WorkspaceRoot`, so the `(Get-Location).Path` default line executes under coverage; no assertion depends on what it returns, because relative inputs never consult the root.

### 6.3 Concrete case list

Positive (ALLOW against an explicitly not-ready checkpoint):
1. Absolute Windows-backslash twin of **each** of the seven checkpoint literals under the synthetic root (row 3; loop over the literal list, mirroring Tests.ps1:259-274).
2. Absolute forward-slash twin of each literal (row 4).
3. Lower-case drive letter (row 5); upper-cased root segments (row 6); root supplied with trailing separator (row 7); duplicated separators (row 9); `/./` segment (row 10); mixed separators (row 21).
4. Absolute path to a feature evidence artifact with a gated extension, e.g. `C:\synthetic\root\docs\features\active\2026-08-23-...-516\evidence\qa-gates\summary.json` (row 16), plus the absolute twin of the existing `spec.md` case.
5. `./artifacts/orchestration/orchestrator-state.json` relative-dot form (row 15).

Negative (DENY against the same not-ready checkpoint) — the half the issue calls equally required:
6. Absolute production-source write `C:\synthetic\root\scripts\dev_tools\x.py` (row 17) and `...\scripts\powershell\Foo.ps1`.
7. Absolute `artifacts/orchestration/some-other-file.json` under the root (row 18).
8. Absolute `scripts/parallel-planner-state.json` under the root (row 19).
9. Absolute checkpoint-shaped path under a **different** root `C:\other\repo\artifacts\orchestration\orchestrator-state.json` (row 14).
10. Root-prefix near-miss `C:\synthetic\rootX\artifacts\...` with root `C:\synthetic\root` (row 8, segment alignment).
11. `..`-bearing path `C:\synthetic\root\x\..\artifacts\orchestration\orchestrator-state.json` (row 11).
12. UNC path `\\server\share\artifacts\orchestration\orchestrator-state.json` (row 12).
13. Drive-relative `C:artifacts\orchestration\orchestrator-state.json` (row 20).
14. Case-variant `DOCS/...` absolute form (row 23) — pins that tail case semantics did not change.

Helper-unit cases: rows 5, 9, 10, 13, 20, 22, 24 asserted on the returned string, including the degenerate path-equals-root case (row 24) and the UNC-root positive (row 13), which is awkward to express end-to-end.

Regression: run the untouched existing suite; all 461 lines of assertions must pass unchanged.

## 7. Coverage (Q6)

- `_poshqc.yml` runs Pester on `windows-latest` (line 10); `.claude/rules/quality-tiers.md` requires >= 85 % line coverage; Pester measures line/command coverage only (no branch gate for PowerShell).
- The new helper is a pure function; every line is reachable from direct unit calls, including the early-return guards (`..` guard, empty-root guard, empty-tail guard). Nothing in it is host-bound.
- The `(Get-Location).Path` default-value expression is covered by any existing test that omits `-WorkspaceRoot` (all current tests do).
- The only historically uncoverable lines in this file are the script tail (lines 335–340) and the dot-source guard (328–330), which run only as a process; the fix does not add to that region, so the file's coverage ratio improves or holds. No new hard-to-cover path is introduced.

## 8. Requirements Mapping / Proposed Change Shape

Production change (per variant pair):
1. Add pure function `ConvertTo-WorkspaceRelativePath` (~30 lines with mandated comments) implementing section 4.1.
2. Add `[string] $WorkspaceRoot = (Get-Location).Path` to `Invoke-OrchestrationPreimplementationGateDecision` (Claude hook lines 235–244 parameter block; Codex equivalent) — and, in the Codex variant only, thread the same root into the apply-patch path loop (Codex hook lines 92–103) and mapped-file loop (lines 321–327), which classify paths through the same function.
3. Replace the two-line normalization at Claude hook lines 259–260 (Codex lines 272–273) with the helper call.
4. No change to `Test-ImplementationPath`, `Test-FeatureDocumentationOrEvidencePath`, the checkpoint literal list, readiness logic, message text, or the entry point.

File set (mirrors the #535 template, section 1.4): the four hook copies plus two new facet test files. Byte parity between each hook and its bundled mirror is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (and the codex pack manifest test names the codex hook at `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:98`). Four production files exceeds the PowerShell per-batch cap of 3 (`.claude/rules/powershell.md`, "Change Budget"), so execution must batch as #535 did: claude pair + claude tests, then codex pair + codex tests, with the batch-budget state reset between batches.

Line-budget check: Claude hook 340 → ~395 after the change; Codex hook 336 → ~395 (it gains the helper plus two loop threadings); both under 500. Existing test files unchanged; new facet files sized freely under 500.

Constraint reminders for the executor:
- Do not write the strings `$env:CLAUDE_TOOL_INPUT` or `$env:CLAUDE_HOOK_INPUT` anywhere in the hook, including comments (`PreToolUsePayload.Contract.Tests.ps1:60-63` scans text).
- Do not invoke Python from the hook (`enforcement-hooks-no-python-invocation.Tests.ps1`).
- Toolchain: `run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`, restart on any change, per `.claude/rules/powershell.md`.

## 9. Rejected Alternatives (summary)

- Segment-anchored suffix matching (`(^|/)` idiom): widens the exemption to same-shaped paths outside the workspace (section 3.1).
- Absolute literals in the checkpoint list: machine-dependent, contradicts the list's own contract (hook lines 13–17).
- Filesystem canonicalization (`Resolve-Path` / `GetFullPath`): existence requirement, ambient cwd, nondeterminism in tests.
- `$env:CLAUDE_PROJECT_DIR`, `git rev-parse`, envelope `cwd` as the root source: section 2.2 table.
- Helper in `HookPayload.psm1`: grows the change to six-plus files and does not reach the Codex variant, which does not import the module (section 2.3).

## Automation Feasibility

Fully automatable; no step requires human interaction. The fix is a pure-string normalization in four tracked PowerShell files plus new Pester test files; every acceptance signal is machine-checkable (Pester suites, PoshQC format/analyze, the push-down byte-parity tests, and the source-scanning contract tests). The end-to-end reproduction in the issue (a `Write` of the absolute checkpoint path being denied, then allowed after the fix) is expressible as a Pester case with an injected synthetic root and an injected not-ready checkpoint, so no live orchestration run and no manual observation is needed. No credentials, no external services, no CI-only verification path is involved: the affected surface is exercised entirely by the local windows-latest-equivalent Pester run. The only judgment calls — helper placement, case policy on the root prefix, and batching order — are settled in sections 2.3, 4.1, and 8 of this document.
