# Hook Surface Inventory — Issue #259: Harden Claude PreToolUse Hook Schema

**Date:** 2026-06-27
**Feature:** `2026-06-27-harden-claude-pretooluse-hook-schema-259`
**Research path:** `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/research/hook-surface-inventory.2026-06-27.md`

---

## Background: Root-Cause Invariant (Verified)

No hook file currently emits `hookSpecificOutput`. A grep of `.claude/hooks/**` for the strings `hookSpecificOutput`, `permissionDecision`, and `PreToolUse` finds only comment-text occurrences of `PreToolUse` (function/synopsis docs) and zero occurrences of `hookSpecificOutput` or `permissionDecision`.

This confirms the invariant stated in the task:

- At **PreToolUse**, Claude honors a deny only when the hook writes to stdout the exact shape:
  ```json
  {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "<reason>"
    }
  }
  ```
- The legacy `{"decision":"block","reason":"..."}` shape and `exit 1` are **ignored** (fail-open) at PreToolUse.
- At **SubagentStop** / **PostToolUse** / **UserPromptSubmit**, the `{"decision":"block"}` shape and `exit 1` **are** honored and must be preserved.

**Every PreToolUse hook in this repository currently emits the legacy `{"decision":"block"}` shape and/or calls `exit 1` on deny paths.** The schema change required by #259 applies to all PreToolUse hooks.

---

## 1. PreToolUse Hook Registration Map

Source: `.claude/settings.json` lines 71–146.

### Bash matcher (lines 73–91)

| Hook file | Line in settings.json |
|---|---|
| `.claude/hooks/validate-bash.ps1` | 78 |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 82 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 86 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 90 |

### Write|Edit matcher (lines 93–132)

| Hook file | Line in settings.json |
|---|---|
| `.claude/hooks/check-python-test-purity.ps1` | 99 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 103 |
| `.claude/hooks/check-powershell-test-purity.ps1` | 107 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 111 |
| `.claude/hooks/enforce-evidence-locations.ps1` | 115 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 119 |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 123 |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 127 |
| `.claude/hooks/enforce-completion-consistency.ps1` | 131 |

### Agent matcher (lines 134–145)

| Hook file | Line in settings.json |
|---|---|
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 140 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 144 |

`enforce-orchestration-preimplementation-gate.ps1` is registered under all three matchers (Bash, Write|Edit, Agent).

---

## 2. Per-PreToolUse-Hook Decision-Emission Table

### 2.1 `validate-bash.ps1` (Bash)

**Current line count:** 69 lines.

| Aspect | Detail |
|---|---|
| Pure decision function | None. Deny logic is inline: no extracted pure function. |
| Allow emission | None explicit; `exit 0` (no JSON written). |
| Block emission | `Write-Error "Blocked..."` + `exit 1` (line 64–65). No JSON to stdout. |
| `exit 1` sites | Lines 65 (pattern match). |
| `ConvertTo-Json` | Not used. |
| `[ordered]` | Not used. |
| Pure decision function callable by test | Does not exist; the block path is fully inline. |
| Filesystem/seam adapters | None (pure string matching). |

**Summary:** This hook blocks entirely via `exit 1` with no JSON emission. This is the highest-priority fix: it presently emits nothing to stdout on deny, so Claude ignores the deny completely.

---

### 2.2 `enforce-promotion-mcp-only.ps1` (Bash)

**Current line count:** 216 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Get-PromotionBypassReason` (lines 64–114): returns a reason string or `$null`. `Get-PromotionMcpOnlyBlockDecision` (lines 135–159): builds the block object. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 181, 199. |
| Block shape | `[ordered]@{ decision = 'block'; reason = $Reason }` — lines 155–158 (inside `Get-PromotionMcpOnlyBlockDecision`). |
| `exit 1` sites | Line 211 (error-handling path only — malformed JSON). |
| `ConvertTo-Json` | Line 214: `$decision | ConvertTo-Json -Compress`. No `-Depth` specified (default 2). |
| `[ordered]` | Yes — both allow and block objects use `[ordered]@{}`. |
| Pure function for test | `Get-PromotionMcpOnlyBlockDecision` is pure and callable without disk access. |
| Filesystem/seam adapters | None (pure string/regex matching). |

**Required change:** Replace `[ordered]@{ decision = 'block'; reason = $Reason }` with the `hookSpecificOutput` schema at the block site (line 155–158). The entrypoint emission at line 214 must wrap in the outer `hookSpecificOutput` envelope. The allow path must continue emitting allow in a form the harness accepts (allow requires no special wrapper — confirm with harness docs; the plain allow form or absence of deny is sufficient). `exit 1` at line 211 (error path) must remain as-is (non-deny hard failure).

---

### 2.3 `enforce-pr-author-skill.ps1` (Bash)

**Current line count:** 333 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Get-PrAuthorBypassReason` (lines 172–248): returns a reason string or `$null`. `Invoke-PrAuthorSkillDecision` (lines 250–293): builds allow/block object. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 267, 279, 292. |
| Block shape | `[ordered]@{ decision = 'block'; reason = $reason }` — lines 286–289. |
| `exit 1` sites | Line 328 (error path — malformed JSON). |
| `ConvertTo-Json` | Line 331: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes — both paths use `[ordered]@{}`. |
| Pure function for test | `Get-PrAuthorBypassReason` is a pure reason-builder. The block object construction is in `Invoke-PrAuthorSkillDecision` lines 285–289. |
| Filesystem/seam adapters | `Get-PrContextArtifactExistence` (line 51–63) wraps `Test-Path` — injectable. `Get-PrAuthorAuthorizationContent` (lines 65–85) wraps `Get-Content` — injectable. `Get-CurrentDateTimeUtc` (lines 87–99) wraps `[DateTime]::UtcNow` — injectable (clock seam). |

**Required change:** Replace the block literal `[ordered]@{ decision = 'block'; reason = $reason }` (lines 286–289) with the `hookSpecificOutput` schema. Update the entrypoint emission at line 331. Keep `exit 1` at line 328.

---

### 2.4 `enforce-orchestration-preimplementation-gate.ps1` (Bash + Write|Edit + Agent)

**Current line count:** 198 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Invoke-OrchestrationPreimplementationGateDecision` (lines 133–184): builds allow/block. Helper predicates: `Test-ImplementationPath` (lines 39–51), `Test-ImplementationCommand` (lines 53–77), `Test-ImplementationDelegation` (lines 79–90), `Test-OrchestrationReady` (lines 92–119). |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 141, 165, 179. |
| Block shape | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 180–183. |
| `exit 1` sites | Line 194 (error path — malformed JSON). |
| `ConvertTo-Json` | Line 197: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes — all objects use `[ordered]@{}`. |
| Pure function for test | `Invoke-OrchestrationPreimplementationGateDecision` is callable without disk access when `CheckpointRaw` is supplied. Block object is inline at lines 180–183 within this function. |
| Filesystem/seam adapters | `Get-CheckpointContent` (lines 122–131) wraps `Get-Content` — injectable by passing `CheckpointRaw` directly to the decision function. |

**Required change:** Replace block literal (lines 180–183) with `hookSpecificOutput` schema. Update entrypoint emission at line 197. Keep `exit 1` at line 194.

---

### 2.5 `check-python-test-purity.ps1` (Write|Edit)

**Current line count:** 146 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Get-PythonTestPurityBlockDecision` (lines 32–44): builds block object. `Invoke-PythonTestPurityDecision` (lines 58–135): orchestrates. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 67, 81, 92, 129. |
| Block shape | `[ordered]@{ decision = 'block'; reason = $Reason }` — lines 40–43 inside `Get-PythonTestPurityBlockDecision`. |
| `exit 1` sites | None. Exit is always 0. |
| `ConvertTo-Json` | Lines 143–144 (conditional: only on block): `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes — both paths use `[ordered]@{}`. |
| Pure function for test | `Get-PythonTestPurityBlockDecision` is pure and callable without disk access. |
| Filesystem/seam adapters | None (pure content scanning). |

**Required change:** Replace block object at lines 40–43 with `hookSpecificOutput` schema. The entrypoint at lines 143–144 only emits on block; keep that conditional logic but update the JSON shape. Allow paths emit no JSON to stdout (current behavior: no allow emission); confirm this is correct for PreToolUse (allow requires no special output, only deny requires the specific schema).

---

### 2.6 `enforce-python-batch-budget.ps1` (Write|Edit)

**Current line count:** 235 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Get-PythonBatchBudgetBlockDecision` (lines 79–98): builds block object. `Invoke-PythonBatchBudgetDecision` (lines 100–142): classifies and decides. `Invoke-PythonBatchBudgetHook` (lines 144–209): full orchestration with I/O. |
| Allow shape | `[ordered]@{ decision = 'allow'; state = ...; shouldWriteState = ... }` — lines 116, 125, 141. |
| Block shape | `[ordered]@{ decision = 'block'; reason = $Reason }` + optional `state` — lines 89–97 inside `Get-PythonBatchBudgetBlockDecision`. |
| `exit 1` sites | None. Exit is always 0. |
| `ConvertTo-Json` | Lines 231–232 (conditional: only on block, after `state` key removal). No `-Depth`. |
| `[ordered]` | Yes — both paths use `[ordered]@{}`. |
| Pure function for test | `Get-PythonBatchBudgetBlockDecision` is pure (no I/O). |
| Filesystem/seam adapters | `TestPathExists`, `EnsureDirectory`, `ReadState`, `WriteState` scriptblock parameters (lines 153–160): all injectable seams for state file I/O. |

**Required change:** Replace block object at lines 89–97 with `hookSpecificOutput` schema. The `state` key must be stripped before emission (already done at line 231). Update entrypoint at lines 231–232.

---

### 2.7 `check-powershell-test-purity.ps1` (Write|Edit)

**Current line count:** 111 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | None extracted. The block object is built inline at lines 103–107 as a plain (non-ordered) hashtable `@{ decision = 'block'; reason = $reason }`. |
| Allow shape | None emitted — the hook calls `exit 0` (lines 37, 44, 49, 54, 65, 98). |
| Block shape | `@{ decision = 'block'; reason = $reason }` — lines 103–106 (plain `@{}`, not `[ordered]`). |
| `exit 1` sites | None. Exit is always 0. |
| `ConvertTo-Json` | Line 107: `| ConvertTo-Json -Compress`. No `-Depth`. No `-ErrorAction Stop`. |
| `[ordered]` | No — uses plain `@{}`. |
| Pure function for test | Does not exist as a pure extractable function. Block object is inline. Extraction is required for a contract test. |
| Filesystem/seam adapters | None (pure content scanning). |

**Required change:** Extract a pure `Get-PowerShellTestPurityBlockDecision` function (mirroring the Python purity hook design), replace the inline block object with `hookSpecificOutput` schema, and change `@{}` to `[ordered]@{}` for consistency. This hook also does not follow the dot-sourcing guard pattern; if that is not changed, a contract test must use AST import or a different loading mechanism.

---

### 2.8 `enforce-powershell-batch-budget.ps1` (Write|Edit)

**Current line count:** 238 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Get-PowerShellBatchBudgetBlockDecision` (lines 82–101): builds block object. `Invoke-PowerShellBatchBudgetDecision` (lines 103–145): classifies and decides. `Invoke-PowerShellBatchBudgetHook` (lines 147–212): full orchestration. |
| Allow shape | `[ordered]@{ decision = 'allow'; state = ...; shouldWriteState = ... }` — lines 119, 128, 144. |
| Block shape | `[ordered]@{ decision = 'block'; reason = $Reason }` + optional `state` — lines 92–100. |
| `exit 1` sites | None. Exit is always 0. |
| `ConvertTo-Json` | Lines 234–235 (conditional: only on block, after `state` removal). No `-Depth`. |
| `[ordered]` | Yes — both paths use `[ordered]@{}`. |
| Pure function for test | `Get-PowerShellBatchBudgetBlockDecision` is pure. |
| Filesystem/seam adapters | `TestPathExists`, `EnsureDirectory`, `ReadState`, `WriteState` scriptblock parameters (lines 155–162): all injectable. |

**Required change:** Replace block object at lines 92–100 with `hookSpecificOutput` schema. Update entrypoint at lines 234–235.

---

### 2.9 `enforce-evidence-locations.ps1` (Write|Edit)

**Current line count:** 176 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Get-EvidenceLocationBlockDecision` (lines 83–101): pure, builds block object. `Invoke-EvidenceLocationDecision` (lines 103–138): orchestrates. `Invoke-EvidenceLocationEntryPoint` (lines 140–169): wraps dispatch, returns exit code. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 119, 137. |
| Block shape | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 97–100 inside `Get-EvidenceLocationBlockDecision`. |
| `exit 1` sites | `return 1` at line 164 (inside `Invoke-EvidenceLocationEntryPoint`, error path). `exit (Invoke-EvidenceLocationEntryPoint)` at line 176 propagates. |
| `ConvertTo-Json` | Line 167: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes. |
| Pure function for test | `Get-EvidenceLocationBlockDecision` is pure. |
| Filesystem/seam adapters | None (pure path-prefix matching). |

**Required change:** Replace block object at lines 97–100 with `hookSpecificOutput` schema. Update entrypoint at line 167. Keep `return 1` / `exit 1` at lines 164/176 for the error path. The design pattern with `Invoke-EvidenceLocationEntryPoint` returning an int is unique to this hook; must be preserved.

---

### 2.10 `enforce-feature-folder-order.ps1` (Write|Edit)

**Current line count:** 148 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Invoke-FeatureFolderOrderDecision` (lines 86–131): builds allow/block. No extracted pure block-builder. Block object is inline at lines 127–130. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 99, 118, 123. |
| Block shape | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 127–130. |
| `exit 1` sites | Line 143 (error path). |
| `ConvertTo-Json` | Line 146: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes. |
| Pure function for test | None for block specifically; `Invoke-FeatureFolderOrderDecision` is callable with `CheckpointRaw` but uses filesystem via `Get-FeatureFolderFileExistence` (line 26–41, injectable mock target). |
| Filesystem/seam adapters | `Get-FeatureFolderFileExistence` (lines 26–41) wraps `Test-Path` — injectable. |

**Required change:** Replace inline block object (lines 127–130) with `hookSpecificOutput` schema. Update entrypoint at line 146. Keep `exit 1` at line 143.

---

### 2.11 `enforce-checkpoint-monotonic.ps1` (Write|Edit)

**Current line count:** 303 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Invoke-CheckpointMonotonicDecision` (lines 195–286): builds allow/block. No extracted pure block-builder. Block objects are inline at lines 264–267 and lines 278–282. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 207, 219, 224, 228, 241, 259, 285. |
| Block shape (order violation) | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 264–267. |
| Block shape (missing prerequisite) | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 278–282. |
| `exit 1` sites | Line 298 (error path). |
| `ConvertTo-Json` | Line 301: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes. |
| Pure function for test | `Invoke-CheckpointMonotonicDecision` can be called with `ToolInputRaw` directly. Both block objects are inline. |
| Filesystem/seam adapters | `ConvertFrom-CheckpointJson` (lines 59–71) wraps `ConvertFrom-Json` — injectable via mock. No filesystem I/O (content is from `$toolInput.content`, supplied in the tool-input JSON). |

**Required change:** Replace both inline block objects (lines 264–267 and 278–282) with `hookSpecificOutput` schema. Update entrypoint at line 301. Keep `exit 1` at line 298.

---

### 2.12 `enforce-completion-consistency.ps1` (Write|Edit)

**Current line count:** 410 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Invoke-CompletionConsistencyDecision` (lines 312–393): builds allow/block. Block object is inline at lines 389–392. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 334, 350, 365, 376, 386. |
| Block shape | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 389–392. |
| `exit 1` sites | Line 405 (error path). |
| `ConvertTo-Json` | Line 408: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes. |
| Pure function for test | `Invoke-CompletionConsistencyDecision` is callable; it takes injectable `FolderExistsCheck`, `CheckpointReader`, and `RoutingMatrixReader` scriptblock parameters. |
| Filesystem/seam adapters | `FolderExistsCheck` (scriptblock, lines 324–325), `CheckpointReader` (scriptblock, lines 327–328), `RoutingMatrixReader` (scriptblock, optional). `Get-CheckpointFileContent` (lines 61–82) wraps real I/O. |
| Note | Dot-sources `enforce-completion-helpers.ps1` at line 44. Block object on line 389–392 references helpers' `Test-RouteRequiresPrGate`. |

**Required change:** Replace block object (lines 389–392) with `hookSpecificOutput` schema. Update entrypoint at line 408. Keep `exit 1` at line 405.

---

### 2.13 `enforce-prd-feature-before-planner.ps1` (Agent)

**Current line count:** 216 lines.

| Aspect | Detail |
|---|---|
| Pure decision functions | `Invoke-PrdFeatureBeforePlannerDecision` (lines 148–199): builds allow/block. Block objects are inline at lines 182–185 and lines 194–198. |
| Allow shape | `[ordered]@{ decision = 'allow' }` — lines 159, 172, 190. |
| Block shape (no folder) | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 182–185. |
| Block shape (missing files) | `[ordered]@{ decision = 'block'; reason = '...' }` — lines 194–198. |
| `exit 1` sites | Line 210 (error path). |
| `ConvertTo-Json` | Line 213: `$decision | ConvertTo-Json -Compress`. No `-Depth`. |
| `[ordered]` | Yes. |
| Pure function for test | `Invoke-PrdFeatureBeforePlannerDecision` is callable. |
| Filesystem/seam adapters | `Get-PrdFeatureFileExistence` (lines 35–48) wraps `Test-Path` — injectable. `Get-PrdFeatureCheckpointFolder` (lines 50–78) reads the checkpoint file — injectable. |

**Required change:** Replace both inline block objects (lines 182–185 and 194–198) with `hookSpecificOutput` schema. Update entrypoint at line 213. Keep `exit 1` at line 210.

---

## 3. validate-bash.ps1 Specifics

File: `.claude/hooks/validate-bash.ps1` (69 lines).

**Current blocking mechanism:** The hook iterates `$blockedPatterns` (lines 25–32) using `String.Contains()` (lines 62–65). On match it calls `Write-Error` (line 64) and `exit 1` (line 65). No JSON is written to stdout.

**Does a pure pattern detector exist?** No. The loop (lines 61–66) is the entire detection and blocking logic, inlined in the script body. There is no `Test-BashPattern` function, no `Get-BashDenyReason` function, and no `Invoke-BashDecision` orchestrator function.

**Does a deny-decision builder exist?** No. There is no function that constructs a deny object; the script only calls `Write-Error` + `exit 1`.

**What must be implemented:**

1. Extract a pure `Test-BashCommandBlocked` function (or `Get-BashBlockReason`) that returns the matched pattern or `$null`.
2. Extract a pure `Get-BashDenyDecision` function that returns a `[ordered]@{}` carrying the `hookSpecificOutput` shape.
3. Add an `Invoke-ValidateBashDecision` orchestrator that reads `CLAUDE_TOOL_INPUT`, calls the detector, and returns allow or deny.
4. Replace the entrypoint with the standard emit + `exit 0` pattern (no more `exit 1` on deny).
5. Add the dot-sourcing guard (`if ($MyInvocation.InvocationName -eq '.') { return }`).

**Allow shape note:** The current hook emits nothing to stdout on allow. This is valid for PreToolUse (absence of deny is treated as allow). The new design should also emit nothing (or an allow JSON) on allow paths.

**Filesystem/seam adapters:** None required — pattern matching is pure string comparison.

**Impact on line count:** Current 69 lines. Adding the three functions + guard + new entrypoint will add approximately 35–50 lines, bringing the file to ~104–119 lines. This is well under the 500-line cap.

---

## 4. SubagentStop Validators — Current State Documentation

SubagentStop validators use `exit 1` to block; this is correct and must not change.

### 4.1 `validate-executor-output.ps1` (297 lines)

Relevant functions for the porting inventory:

- **Multi-language PASS/FAIL status detection:**
  - `Test-OutputHasLanguageStatus` (lines 118–139): takes `$AgentOutput` and `$Language`; constructs a label pattern from a `$labelMap` keyed by language (`TypeScript`, `Python`, `PowerShell`, `CSharp`); uses regex `(?im)^.*$labelPattern.*\b(PASS|FAIL)\b.*$`.
  - `Get-TouchedLanguagesFromPlan` (lines 93–116): scans plan lines for file extension patterns (`.ts/.tsx` → TypeScript, `.py` → Python, `.ps1/.psm1/.psd1` → PowerShell, `.cs` → CSharp); returns a string array.
  - Command-evidence regex (lines 265–266): `(?i)(Commands Run|Command[s]?:|poetry run |npx |pwsh |git |mcp__drm-copilot__)` and `(?i)\b(PASS|FAIL)\b`.

- **Coverage parsing:** Not present in this validator (coverage validation lives in `validate-feature-review-coverage.ps1`).

- **Preflight signal handling:**
  - `Test-IsPreflightPlan` (lines 81–89): detects `DIRECTIVE: PREFLIGHT VALIDATION ONLY`.
  - `Test-HasPreflightSignal` (lines 141–153): detects `PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`.
  - `Test-HasCanonicalBlockedText` (lines 155–176): validates the blocked-preflight form.

- **Subprocess seam:** None. Plan file reads go through `Get-PlanFileContent` (lines 35–56), which wraps `Test-Path` + `Get-Content` — the injectable filesystem boundary.

- **human_interaction check:** Not present. Human interaction checking is in `validate-orchestrator-output.ps1`.

### 4.2 `validate-feature-review-coverage.ps1` (459 lines)

Relevant functions:

- **Per-language coverage parsing:**
  - `Get-LcovRepoCoverage` (lines 140–159): reads LCOV file; sums `LF:` (lines found) and `LH:` (lines hit) across all source file records; returns percentage.
  - `Get-LcovBranchCoverage` (lines 161–184): reads LCOV file; sums `BRF:` (branches found) and `BRH:` (branches hit); returns percentage.
  - `Get-JacocoRepoCoverage` (lines 221–241): parses JaCoCo XML; sums `counter[@type="LINE"]` missed/covered.
  - `Get-JacocoBranchCoverage` (lines 186–206): parses JaCoCo XML; sums `counter[@type="BRANCH"]` missed/covered.
  - `Get-LanguageRepoCoverage` (lines 243–256): dispatch by language to LCOV (TypeScript, Python) or JaCoCo (PowerShell, CSharp).
  - `Get-LanguageBranchCoverage` (lines 208–219): dispatch by language to branch-coverage readers.

- **Floor enforcement:** `Test-LanguageCoverageRow` (lines 258–331): line floor is 85% (line 313: `$RepoWidePct -lt 85.0`); branch floor is 75% (line 323: `$BranchFloor = 75.0`).

- **Artifact paths:** TypeScript LCOV: `coverage/lcov.info`. Python LCOV: `artifacts/python/lcov.info`. PowerShell JaCoCo: `artifacts/pester/powershell-coverage.xml`. CSharp JaCoCo: `artifacts/csharp/coverage.xml`.

- **Subprocess seam:** None. All reads go through `Get-ArtifactFileContent` (lines 41–63) — injectable filesystem boundary.

- **human_interaction check:** Not present.

### 4.3 `validate-orchestrator-output.ps1` (301 lines)

Relevant functions:

- **human_interaction shape gate:** `Test-HumanInteractionShape` (lines 60–142): validates the `human_interaction` block per the invariants in `.claude/rules/orchestrator-state.md`. Injectable `FileExistsCheck` scriptblock (line 93). Checks: `requirements` array present; each requirement has a `response` in `{scope_change, exception, halt}`; `halt` blocks; `exception` requires non-empty `runbook_path` and that file exists.

- **remediation_loop shape check:** Not present in-PowerShell. Delegated to the Python `validate_orchestration_artifacts` CLI via `Invoke-RoutingContractValidation` (lines 144–194), which has an injectable `Invoker` scriptblock seam (lines 168–179) for the subprocess call.

- **Subprocess seam:** `Invoke-RoutingContractValidation` takes an `Invoker` scriptblock (lines 169–179 default, injectable). Tests inject a mock to avoid spawning Python.

- **remediation_loop coverage parsing:** Not present here; Python validator handles it.

### 4.4 `validate-task-researcher-output.ps1` (225 lines)

Relevant functions:

- **Research-root handling:** `Test-IsUnderResearchRoot` (lines 60–83): accepts paths under `docs/features/<...>/research/` (requires `/research/` segment) or `docs/research/`.

- **Automation Feasibility section gate:** `Test-AutomationFeasibilitySection` (lines 101–162): detects applicability via regex `autonomous-execution|human-interaction` against filename or agent output; when applicable, reads the file through an injectable `ReadFileContent` scriptblock (line 133) and checks for `## Automation Feasibility` heading via regex `(?m)^\s{0,3}#{2,}\s+Automation\s+Feasibility\s*$`.

- **Both functions already exist** and are used in `Invoke-TaskResearcherOutputValidation`.

---

## 5. enforce-checkpoint-monotonic.ps1 — Detailed Documentation

File: `.claude/hooks/enforce-checkpoint-monotonic.ps1` (303 lines).

**Current decision/exit usage:** Emits `[ordered]@{ decision = 'block' }` via `ConvertTo-Json -Compress` to stdout (line 301). Calls `exit 1` at line 298 only on error/exception path.

**Test-StepHasPrefix:** Exists at lines 137–149. Tests that a step entry equals a prefix or starts with `<prefix>_`, `<prefix>.`, or `<prefix>-`.

**Get-MissingPrerequisiteForAdvancedStep:** Exists at lines 151–182. Returns a `pscustomobject` naming the offending step and which prerequisite (`S3_promotion`, `S4_atomic_planning`) is missing when any step with canonical index >= 5 is present without both prerequisite steps in `CompletedSteps`.

**Canonical step-name ordering** (`$script:CanonicalStepPrefixes`, lines 44–57):

| Index | Prefix |
|---|---|
| 0 | `S0_startup_checks` |
| 1 | `S1_change_budget_estimation` |
| 2 | `S2_research` |
| 3 | `S3_promotion` |
| 4 | `S4_atomic_planning` |
| 5 | `S5_atomic_execution` |
| 6 | `S6_pre_review_commit` |
| 7 | `S7_feature_review` |
| 8 | `S8_create_pr` |
| 9 | `S9_remediation_loop` |
| 10 | `S10_post_pr` |
| 11 | `S12_complete` |

Note: The list jumps from `S10_post_pr` (index 10) to `S12_complete` (index 11). There is no `S11_*` in the canonical list.

---

## 6. Already-Present "New" Gate Hooks — Status

All five files are confirmed present in `.claude/hooks/`:

### `enforce-orchestration-preimplementation-gate.ps1`
- **Exists:** Yes (198 lines).
- **Current decision schema:** `[ordered]@{ decision = 'block'; reason = '...' }` (legacy form).
- **Registration status:** Registered under Bash (line 90), Write|Edit (line 119), and Agent (line 144) in `settings.json`.

### `enforce-powershell-batch-budget.ps1`
- **Exists:** Yes (238 lines).
- **Current decision schema:** `[ordered]@{ decision = 'block'; reason = ... }` (legacy form, inside `Get-PowerShellBatchBudgetBlockDecision`).
- **Registration status:** Registered under Write|Edit (line 111) in `settings.json`.

### `check-powershell-test-purity.ps1`
- **Exists:** Yes (111 lines).
- **Current decision schema:** Plain `@{ decision = 'block'; reason = $reason }` (non-ordered, legacy form).
- **Registration status:** Registered under Write|Edit (line 107) in `settings.json`.

### `enforce-completion-consistency.ps1`
- **Exists:** Yes (410 lines).
- **Current decision schema:** `[ordered]@{ decision = 'block'; reason = '...' }` (legacy form).
- **Registration status:** Registered under Write|Edit (line 131) in `settings.json`. Functional: dot-sources `enforce-completion-helpers.ps1`, has full decision logic.

### `enforce-completion-helpers.ps1`
- **Exists:** Yes (163 lines).
- **Exposes:**
  - `Test-IsValidIssueNum` (lines 27–55): returns `$true` for digits-only strings, rejects sentinels (`n/a`, `none`, `tbd`).
  - `Test-IsValidFeatureFolder` (lines 57–103): returns `$true` for paths under `docs/features/active/` with non-empty trailing segment that exists (via injectable `FolderExistsCheck`).
  - `Test-RouteRequiresPrGate` (lines 106–163): looks up `route_id`/`path_selected` in the routing matrix loaded from `config/orchestration-routing.json` (via injectable `RoutingMatrixReader` scriptblock). Returns `$true` when `requires_pr_gate == true` for that route.
  - Routing-matrix source: `config/orchestration-routing.json` (confirmed to exist).
- `enforce-completion-consistency.ps1` is registered in `settings.json` and functional.

---

## 7. Bundled Mirror and Contract-Test Mechanism

### Mirror root
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` — confirmed to contain all 21 hook files, matching the runtime set exactly (same file names, same count).

### Byte-identical parity
The Python contract test at `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (line 100–125) enforces byte-identical parity:
- It enumerates all `.claude/**` files at repo root (excluding `settings.local.json` and `.claude/agent-memory/**`).
- For each file, it asserts the same file exists in the bundled root and that the content is identical (line 122–125: `read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path)`).
- **This test will fail for any hook file that is updated at the runtime root but not in the mirror.**

**Verified discrepancy (pre-existing, not introduced by this research):** The bundled mirror of `validate-bash.ps1` at line 39 uses `ConvertFrom-Json` without `-ErrorAction Stop`, while the runtime version has `-ErrorAction Stop`. This is an existing parity divergence that will be caught by the contract test and must be resolved in the same batch as any runtime change.

### settings.json mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` — confirmed to exist. It is within the `.claude/**` parity scope, so any change to the runtime `settings.json` must be replicated to the bundled copy or the parity test fails.

### Other mirror locations
- `.codex/`, `.agents/`, `.github/` — no hook `.ps1` files found under these paths. Hooks are mirrored only in the one bundled extension resource path above.

---

## 8. Test Layout and Contract-Test Target

### Pester discovery roots
The authoritative `pester.runsettings.psd1` at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` declares:
```
Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')
```

The path `tests/hooks/` is **not** in the discovery root list. A test file placed at `tests/hooks/PreToolUseSchema.Contract.Tests.ps1` will **not** be discovered by the PoshQC runner.

### Correct path for new test
All 20 existing hook tests live under `tests/scripts/claude-hooks/` (e.g., `tests/scripts/claude-hooks/validate-bash.Tests.ps1`). That directory falls under the `tests/scripts` discovery root.

**Recommendation:** Create the new contract test at:
```
tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
```
Do not use `tests/hooks/PreToolUseSchema.Contract.Tests.ps1` — it will not be discovered by the Pester runner.

---

## 9. File-Size Headroom

Current line counts and headroom under the 500-line cap for all PreToolUse hook files requiring edits. Each edit adds the `hookSpecificOutput` wrapper shape plus, for hooks that need it, a pure decision-function extraction.

| File | Current lines | Estimated addition | Projected total | Headroom remaining |
|---|---|---|---|---|
| `validate-bash.ps1` | 69 | ~45 (new functions + guard + entrypoint redesign) | ~114 | 386 |
| `enforce-promotion-mcp-only.ps1` | 216 | ~15 (schema substitution only) | ~231 | 269 |
| `enforce-pr-author-skill.ps1` | 333 | ~10 (schema substitution only) | ~343 | 157 |
| `enforce-orchestration-preimplementation-gate.ps1` | 198 | ~10 (schema substitution only) | ~208 | 292 |
| `check-python-test-purity.ps1` | 146 | ~10 (schema substitution only) | ~156 | 344 |
| `enforce-python-batch-budget.ps1` | 235 | ~10 (schema substitution only) | ~245 | 255 |
| `check-powershell-test-purity.ps1` | 111 | ~35 (extract function, guard, ordered conversion) | ~146 | 354 |
| `enforce-powershell-batch-budget.ps1` | 238 | ~10 (schema substitution only) | ~248 | 252 |
| `enforce-evidence-locations.ps1` | 176 | ~10 (schema substitution only) | ~186 | 314 |
| `enforce-feature-folder-order.ps1` | 148 | ~10 (schema substitution only) | ~158 | 342 |
| `enforce-checkpoint-monotonic.ps1` | 303 | ~15 (two block sites) | ~318 | 182 |
| `enforce-completion-consistency.ps1` | 410 | ~10 (schema substitution only) | ~420 | 80 |
| `enforce-prd-feature-before-planner.ps1` | 216 | ~15 (two block sites) | ~231 | 269 |

No file is projected to exceed 500 lines. `enforce-completion-consistency.ps1` has the tightest headroom at ~80 lines remaining after the change.

---

## 10. Recommended Execution Phasing

The batch cap is 3 production files + 3 test files per batch. Runtime hook + bundled mirror = 2 production files. That leaves 1 additional production file slot (usable for the helpers file or a new file) and 3 test file slots per batch.

The following phasing keeps each runtime-hook edit paired with its mirror copy and stays within cap. Each batch is stated as (runtime, mirror, test file).

### Batch 1 — validate-bash.ps1 (highest-priority: currently emits nothing on deny)
- Production (1): `.claude/hooks/validate-bash.ps1`
- Production (2): `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/validate-bash.Tests.ps1` (update existing)
- Test (2–3): not used

### Batch 2 — enforce-promotion-mcp-only.ps1 + enforce-pr-author-skill.ps1
- Production (1): `.claude/hooks/enforce-promotion-mcp-only.ps1`
- Production (2): mirror of `enforce-promotion-mcp-only.ps1`
- Production (3): not used (save slot; each file needs its own batch for test pairing)
- Test (1): `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1`
- Test (2–3): not used

  _enforce-pr-author-skill.ps1 goes in Batch 3 because its test file is the third production slot._

### Batch 3 — enforce-pr-author-skill.ps1
- Production (1): `.claude/hooks/enforce-pr-author-skill.ps1`
- Production (2): mirror of `enforce-pr-author-skill.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Test (2–3): not used

### Batch 4 — enforce-orchestration-preimplementation-gate.ps1
- Production (1): `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- Production (2): mirror of `enforce-orchestration-preimplementation-gate.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`
- Test (2–3): not used

### Batch 5 — check-python-test-purity.ps1 + enforce-python-batch-budget.ps1 (same test file slots)
- Production (1): `.claude/hooks/check-python-test-purity.ps1`
- Production (2): mirror of `check-python-test-purity.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1`
- Test (2–3): not used

### Batch 6 — enforce-python-batch-budget.ps1
- Production (1): `.claude/hooks/enforce-python-batch-budget.ps1`
- Production (2): mirror of `enforce-python-batch-budget.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`
- Test (2–3): not used

### Batch 7 — check-powershell-test-purity.ps1 (needs function extraction — more work)
- Production (1): `.claude/hooks/check-powershell-test-purity.ps1`
- Production (2): mirror of `check-powershell-test-purity.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1`
- Test (2–3): not used

### Batch 8 — enforce-powershell-batch-budget.ps1
- Production (1): `.claude/hooks/enforce-powershell-batch-budget.ps1`
- Production (2): mirror of `enforce-powershell-batch-budget.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`
- Test (2–3): not used

### Batch 9 — enforce-evidence-locations.ps1 + enforce-feature-folder-order.ps1
Two hooks with simple substitutions can share a batch if the test files are within cap.
- Production (1): `.claude/hooks/enforce-evidence-locations.ps1`
- Production (2): mirror of `enforce-evidence-locations.ps1`
- Production (3): not used (must leave room; enforce-feature-folder-order.ps1 is Batch 10)
- Test (1): `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`
- Test (2–3): not used

### Batch 10 — enforce-feature-folder-order.ps1
- Production (1): `.claude/hooks/enforce-feature-folder-order.ps1`
- Production (2): mirror of `enforce-feature-folder-order.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1`
- Test (2–3): not used

### Batch 11 — enforce-checkpoint-monotonic.ps1 (two block sites)
- Production (1): `.claude/hooks/enforce-checkpoint-monotonic.ps1`
- Production (2): mirror of `enforce-checkpoint-monotonic.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1`
- Test (2–3): not used

### Batch 12 — enforce-completion-consistency.ps1 + enforce-completion-helpers.ps1
`enforce-completion-consistency.ps1` dot-sources `enforce-completion-helpers.ps1`. Both mirrors must also be updated in the same batch, consuming all 3 production slots.
- Production (1): `.claude/hooks/enforce-completion-consistency.ps1`
- Production (2): mirror of `enforce-completion-consistency.ps1`
- Production (3): `.claude/hooks/enforce-completion-helpers.ps1` (mirror update in Batch 13, or add as Production 3 if no test changes are needed for helpers alone)

  _Recommendation: treat the helpers mirror as a no-op production write (content-identical except for the hookSpecificOutput if helpers itself is edited). If helpers requires no changes, include the runtime + mirror in the same batch and use production slot 3 for its mirror._
- Test (1): `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`
- Test (2–3): not used (helpers test: none exists; no new test file needed if helpers is unchanged)

### Batch 13 — enforce-prd-feature-before-planner.ps1
- Production (1): `.claude/hooks/enforce-prd-feature-before-planner.ps1`
- Production (2): mirror of `enforce-prd-feature-before-planner.ps1`
- Production (3): not used
- Test (1): `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
- Test (2–3): not used

### Batch 14 — New PreToolUseSchema.Contract.Tests.ps1
A new contract test that can dot-source each hook (using the `$MyInvocation.InvocationName -eq '.'` guard) and call each pure decision function with a constructed deny payload, asserting the emitted JSON matches the `hookSpecificOutput` schema. This test file is new production (or test-only) with no runtime hook changes.
- Production (1–3): not used (or use slot 1 for a new helper module if needed)
- Test (1): `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (new file)
- Test (2–3): not used

**Total batches: 14.** If the team wants to collapse some, Batches 2+3 (promotion-mcp-only and pr-author-skill) can be split differently: use production slots 1+2 for one hook's runtime+mirror and production slot 3 for the other hook's runtime, then use Batch 3 for that hook's mirror only. This is valid since a mirror-only file edit still counts as a production file.

---

## Automation Feasibility

**Automation verdict: Feasible with no human-interaction requirements.**

All 13 runtime hook files are PowerShell scripts with deterministic structure: each has a pure `Invoke-*Decision` function callable without disk/network access (after trivial seam injection), and all emit JSON to stdout. The schema change is mechanical — replacing `decision = 'block'` object literals with a `hookSpecificOutput` wrapper — and is the same transformation applied independently to each file.

Automated contract-test validation is also feasible: the existing dot-sourcing guard pattern (`if ($MyInvocation.InvocationName -eq '.') { return }`) is present in 12 of 13 hooks (absent only in `check-powershell-test-purity.ps1`), enabling Pester tests to dot-source hooks and invoke pure decision functions without spawning a subprocess.

The only hook requiring structural refactoring beyond a schema substitution is `validate-bash.ps1`, which currently has no pure functions or dot-sourcing guard. Adding a guard and extracting a pure decision function is straightforward and adds at most ~45 lines.

The 14-batch phasing above is executable by an `atomic-executor` subagent in sequential batches. No human interaction is required at any step. The Python parity contract test (`test_push_down_claude_resource_contracts.py`) will fail if any mirror is not updated in the same batch as its runtime counterpart; the phasing above ensures each runtime file and its mirror are always in the same batch.

**Risks:**
- `enforce-completion-consistency.ps1` has tight headroom (~80 lines). If the `hookSpecificOutput` schema addition causes the file to exceed 500 lines, the function must be split or the block-reason string extracted to a constant.
- The pre-existing parity divergence in `validate-bash.ps1` (mirror missing `-ErrorAction Stop`) means the parity test already fails for that file; fixing both in Batch 1 resolves it.
- `check-powershell-test-purity.ps1` uses a non-ordered hashtable and has no dot-sourcing guard; both must be corrected in the same edit to avoid technical debt accumulation.
