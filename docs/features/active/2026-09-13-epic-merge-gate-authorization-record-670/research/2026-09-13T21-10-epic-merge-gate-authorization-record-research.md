# Research — epic-merge-gate-authorization-record (Issue #670, epic F3, ref 3.6)

- **Timestamp:** 2026-09-13T21-10
- **Feature:** `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/`
- **Epic:** `worktree-scoped-state-resolution`, F3, wave 0, complexity C3
- **Work mode:** full-bug
- **Tree verified against:** worktree `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a03eff8b5079d342b`, branch `epic/worktree-scoped-state-resolution-integration`, HEAD `499e288a`

## Session Tool Limitation (affects how some evidence was gathered)

The `Bash` tool was disabled for this session (`Error: No such tool available: Bash. Bash is disabled
for this session, in subagents as well as here.`) and no PowerShell execution tool was available.
Every claim below is therefore verified by `Read` / `Grep` / `Glob` against file contents, not by
running `git hash-object`, `wc`, `Get-FileHash`, or `diff`. Where byte-level identity could not be
computed, the section says so explicitly and states what *was* compared.

---

## R1 — Anatomy of `.claude/hooks/enforce-epic-merge-gate.ps1`

### R1.1 Size

`Read` renders the file as numbered lines 1 through 487, with line 487 being
`exit ([int]$entryPointResult[-1])`. The epic manifest (`epic.md:212`) and `issue.md:75` both state
**486**. The one-line difference is a measurement-tool difference, not a disagreement about content:
`wc -l` counts newline characters and reports 486 when the final line carries no trailing newline,
while `(Get-Content).Count` — the measurement the repository's only automated line-cap test uses
(`tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:180`) — reports 487.

The same pattern holds for the Codex mirror: `Read` shows lines 1..187 with line 186 = `}` and line
187 empty; the epic states 186.

**Planning figure: treat the Claude hook as 487 lines under `(Get-Content).Count`, i.e. 13 lines of
headroom, not 14.** A fourth allow path plus its helper cannot be added in place. Note separately
(R3.3) that no automated test enforces the cap on `.claude/hooks/**` at all, so the cap is a policy
obligation here, not a gated one.

### R1.2 The three allow paths, documented at lines 8-19

Verbatim, `.claude/hooks/enforce-epic-merge-gate.ps1:8-21`:

```
    the envelope's tool_input.command and, when matched, allows the merge only when one of three
    checkpoint-only conditions holds:

      1. Child-feature path: artifacts/orchestration/orchestrator-state.json exists,
         epic_mode == true, and step9_status == "passed" (the per-feature orchestrator has
         already run S9 step 6's CI-green gate before attempting its own merge-on-green).
      2. Epic-integration path: artifacts/orchestration/epic-orchestrator-state.json exists,
         epic_merge_pr.ci_gate.conclusion == "success", and, when the command names an
         explicit PR number, that number matches epic_merge_pr.pr_number.
      3. Parallel path: artifacts/orchestration/parallel-orchestrator-state.json exists,
         route_id == "parallel", and the command's explicit PR number matches an items[]
         entry whose merge_status == "ci_green". A parallel run always names an explicit PR
         number (each item merges from its own isolated worktree), so a bare command with no
         PR number cannot satisfy this branch.
```

Lines 23-27 state the exclusion the defect report cites:

```
    Otherwise the command is denied with reason EPIC_MERGE_GATE_BLOCKED. A missing or
    unreadable checkpoint in any branch fails closed (denies); standalone (non-epic,
    non-parallel) orchestration never sets epic_mode, populates epic_merge_pr, or writes a
    parallel checkpoint with route_id == "parallel", so it is structurally prevented from
    invoking gh pr merge --merge at all.
```

The header comment block is the normative statement of the gate's contract and **must be updated by
this change**; leaving it at "one of three" after adding a fourth path would leave the file's own
documentation false.

### R1.3 Function inventory

All line numbers verified in this tree.

| Line | Function | Signature (params) | Responsibility |
| --- | --- | --- | --- |
| 52 | `Get-ChildOrchestratorCheckpointContent` | none | Read seam: raw text of `artifacts/orchestration/orchestrator-state.json`, or `$null`. |
| 70 | `Get-EpicOrchestratorCheckpointContent` | none | Read seam: raw text of `artifacts/orchestration/epic-orchestrator-state.json`, or `$null`. |
| 88 | `Get-ParallelOrchestratorCheckpointContent` | none | Read seam: raw text of `artifacts/orchestration/parallel-orchestrator-state.json`, or `$null`. |
| 106 | `ConvertFrom-EpicMergeGateJson` | `[AllowNull()][string] $Raw` | Parse to object; `$null` on empty/whitespace or on `ConvertFrom-Json` throw. |
| 131 | `Get-EpicMergeGateCommandPrNumber` | `[Parameter(Mandatory)][string] $CommandText` | Extract the explicit PR number from the `gh pr merge` segment, or `$null`. |
| 177 | `Test-ChildCheckpointAllowsEpicMerge` | `[AllowNull()] $Checkpoint` | Branch 1 predicate. Confirmed at the line the issue cites. |
| 206 | `Test-EpicCheckpointAllowsMerge` | `[AllowNull()] $Checkpoint`, `[AllowNull()][Nullable[int]] $CommandPrNumber` | Branch 2 predicate. Confirmed at the line the issue cites. |
| 264 | `Test-ParallelCheckpointAllowsMerge` | `[AllowNull()] $Checkpoint`, `[AllowNull()][Nullable[int]] $CommandPrNumber` | Branch 3 predicate. Confirmed at the line the issue cites. |
| 327 | `Get-EpicMergeGateAllowDecision` | none | Allow envelope factory. |
| 340 | `Get-EpicMergeGateBlockDecision` | `[Parameter(Mandatory)][string] $Reason` | Deny envelope factory. |
| 357 | `Invoke-EpicMergeGateDecision` | `[AllowNull()][AllowEmptyString()][string] $ToolInputRaw` | The pure decision seam every test drives. |
| 436 | `Invoke-EpicMergeGateEntryPoint` | `[AllowNull()][AllowEmptyString()][string] $ToolInputRaw`, `[scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload }` | Payload acquisition + emit + return exit code 0. |

Script-scoped constants (module-level, lines 48-50) — `$script:ParallelCheckpointPath` is confirmed
at **line 50** exactly as the issue states:

```powershell
$script:ChildCheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
$script:EpicCheckpointPath = 'artifacts/orchestration/epic-orchestrator-state.json'
$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'
```

Imports, lines 42-46:

```powershell
Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')
```

Dot-source guard, lines 474-477: `if ($MyInvocation.InvocationName -eq '.') { return }` — this is
what lets a Pester `BeforeAll` dot-source the file without running the entry point.

### R1.4 Trigger matching (`gh pr merge --merge`) and PR-number extraction

The gate does **not** regex-match the phrase against the whole command text. Despite the header
comment's legacy wording "Regex-matches gh pr merge with a --merge flag" (line 7), the actual scope
filter is structural, at lines 401-414:

```powershell
$isMergeInvocation = Test-CommandLineInvocation -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge')
$hasMergeFlag = Test-CommandLineFlag -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
if (-not $hasMergeFlag) {
    foreach ($segment in @(Read-CommandLineSegment -CommandText $commandText)) {
        if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
            $segment.ScanText.IndexOf('--merge', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $hasMergeFlag = $true
            break
        }
    }
}
if (-not $isMergeInvocation -or -not $hasMergeFlag) {
    return Get-EpicMergeGateAllowDecision
}
```

The raw-scan fallback exists because a wrapper's quoted argument (`bash -c "gh pr merge --merge 688"`)
collapses into one token, so the flag is otherwise unreadable; the fallback reads only segments the
scanner already scans raw (comment, lines 397-400).

**PR-number extraction — `Get-EpicMergeGateCommandPrNumber`, body verbatim (lines 163-174).** This is
the block whose bytes the plan must prove unchanged:

```powershell
    foreach ($operand in @(Get-CommandLineOperand -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        if ($operand -match '^\d+$') {
            return [int]$operand
        }
    }

    $flagValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
    if ($null -ne $flagValue -and $flagValue -match '^\d+$') {
        return [int]$flagValue
    }

    return $null
```

The only regular expression in the matcher is `'^\d+$'`, appearing twice (lines 164 and 170). It is
an end-to-end anchored all-digit token test, not a digit-run scan. The whole-line digit scan that
this replaced is described in the function's own `.DESCRIPTION` (lines 143-150) and is the subject of
the false-allow regression test quoted in R5.3.

**Byte-unchanged proof method available without a shell:** assert that lines 163-174 of the Claude
hook and lines 55-66 of the Codex hook match the two literals above character for character, and that
`Get-EpicMergeGateCommandPrNumber` appears in exactly the same call position at line 416
(`$commandPrNumber = Get-EpicMergeGateCommandPrNumber -CommandText $commandText`). A stronger
mechanical proof is a `git diff` restricted to those line ranges at review time.

### R1.5 Injectable seams (no temp files required in tests)

Three filesystem read seams (lines 52, 70, 88), each implemented as
`Test-Path -LiteralPath <script-scoped path> -PathType Leaf` followed by `Get-Content -Raw`. Tests
mock the seam function itself (`Mock -CommandName Get-ParallelOrchestratorCheckpointContent`) and, for
the seam's own coverage, mock `Test-Path` / `Get-Content` with a `-ParameterFilter` on the script
variable (`enforce-epic-merge-gate.Tests.ps1:232-243`).

One payload seam: `Invoke-EpicMergeGateEntryPoint -ReadPayload <scriptblock>` (line 461).

**A fourth allow path must follow this pattern exactly**: if the authorization record lives in a new
file, it needs a fourth read-seam function; if it lives inside an existing checkpoint, it needs no new
seam at all. The second option is materially cheaper to test and is the recommendation in R7.

### R1.6 Deny reason codes and the decision envelope

Allow envelope (lines 332-337):

```powershell
[ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
```

Deny envelope (lines 348-353): same shape plus `permissionDecisionReason = $Reason`.

The hook emits exactly **two** distinct deny-reason strings, both prefixed `EPIC_MERGE_GATE_BLOCKED`:

- line 382 — the envelope-anomaly deny: `'EPIC_MERGE_GATE_BLOCKED: payload anomaly - ' + (Get-ClaudeHookPayloadAnomalyReason -Anomaly $payload.Anomaly) + '. The gate fails closed on an envelope it cannot read.'`
- line 433 — the no-checkpoint-satisfied deny (the full string is quoted in R8).

Line 23 is a documentation mention of the token, not an emission site.

### R1.7 Checkpoint path resolution — **session-relative, and this is the epic's own defect class**

All three Claude-side paths are bare repo-relative strings (lines 48-50) passed to
`Test-Path -LiteralPath` with no root anchoring. PowerShell resolves them against the hook process's
**current working directory**, which for a Claude PreToolUse hook is the session root. The Codex
mirror does the opposite: it anchors to the repository root computed from `$PSScriptRoot`
(`.codex/hooks/enforce-epic-merge-gate.ps1:173-175`):

```powershell
$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$childPath = Join-Path $repositoryRoot 'artifacts/orchestration/orchestrator-state.json'
```

This asymmetry is recorded but is **out of F3's scope**: the epic's "Must Not Regress" list requires
epic and standalone topologies to behave exactly as now when cwd and target coincide, and changing
the Claude hook's path anchoring is not part of RULING 1. It is worth surfacing to the user as a
candidate follow-up, because it means the Claude gate reads whatever checkpoint sits under the
session root regardless of which worktree the merge targets.

---

## R2 — `.codex/hooks/enforce-epic-merge-gate.ps1`

### R2.1 Structure

187 numbered lines (186 by `wc -l`). A genuinely different implementation, not a byte copy.

| Line | Function | Responsibility |
| --- | --- | --- |
| 14 | `ConvertFrom-CodexMergeJson` | Parse with a `-Name` label and an `-Optional` switch. **Throws** on empty/malformed when not optional; returns `$null` when optional. |
| 34 | `Get-CodexMergeCommandPrNumber` | PR-number resolver. Body is functionally identical to the Claude extractor (same two calls, same `'^\d+$'` anchor) but the parameter is named `-Command`, not `-CommandText`. |
| 69 | `Test-CodexChildMergeReady` | Branch 1. |
| 87 | `Test-CodexEpicMergeReady` | Branch 2. |
| 114 | `Invoke-CodexEpicMergeDecision` | Decision router; **takes the checkpoint texts as parameters**, not through read seams. |
| 171-186 | entry-point `try/catch` | Reads stdin, resolves the repo root, reads both checkpoint files, calls the router, `exit 0` / `exit 2`. |

### R2.2 Allow paths — the Codex hook has only **two**, and **no parallel path**

`Invoke-CodexEpicMergeDecision` (lines 148-156) consults only the child checkpoint and the epic
checkpoint. There is no `parallel-orchestrator-state.json` read, no `route_id == "parallel"` test, and
no `items[]` scan anywhere in the file. Two further intentional differences:

- Branch 1 accepts a wider `step9_status` set: `@('passed', 'verified')` (line 83) versus the Claude
  hook's `-eq 'passed'` (line 203).
- Branch 1 additionally requires `epic_mode` to be a real `[bool]` (`$Checkpoint.epic_mode -is [bool]`,
  line 80); the Claude hook coerces with `[bool]$Checkpoint.epic_mode` (line 197).
- A non-`Bash` `tool_name` returns `$null` early (lines 124-126); the Claude hook has no `tool_name`
  test, because `.claude/settings.json` already scopes it with the `"matcher": "Bash"` (line 91).
- Allow is expressed as `$null` (emit nothing); deny is the one decision object.

### R2.3 Seams

- Checkpoint content: **parameter seam** (`-ChildCheckpointRaw`, `-EpicCheckpointRaw`), not a mockable
  read function. Tests pass literal JSON strings directly.
- Payload: the entry point reads `[Console]::In.ReadToEnd()` (line 172); tests redirect
  `[System.Console]::In` to a `StringReader` in-process
  (`tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1:39-67`).

### R2.4 Deny reason codes

Three sites, all carrying the same `EPIC_MERGE_GATE_BLOCKED` token:

- line 22 — `throw "EPIC_MERGE_GATE_BLOCKED: $Name is empty."`
- line 30 — `throw "EPIC_MERGE_GATE_BLOCKED: $Name is malformed JSON: $_"`
- line 162 — `permissionDecisionReason = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'`

The two `throw` sites reach the entry point's `catch` and produce `exit 2` with the message on stderr
(lines 183-185) — a hard-fail channel the Claude hook does not have (it never returns non-zero,
documented at lines 441-445).

### R2.5 What "Codex parity" must mean for this change

Parity here is **behavioural on the standalone decision, not textual on the whole file**. Concretely:

**Must match:**
1. The new standalone allow path must exist on both runtimes with the same activation condition
   (record present, names *this* PR, well-formed), so a coordinating session on either runtime can
   land the same PR.
2. The new deny reason codes (R8) must be spelled identically on both sides, because the epic's NFR
   is "a distinct, greppable reason code" — a token that differs by runtime is not greppable across a
   mixed transcript. The precedent for one-token-two-runtimes is `EPIC_MERGE_GATE_BLOCKED` itself.
3. The PR-number matcher must be byte-unchanged on both sides (Claude lines 163-174, Codex lines
   55-66).
4. `--squash` must remain out of scope on both sides (R10).

**Intentionally differs, and must not be "fixed" as a side effect:**
1. **The Codex hook has no parallel path and must not acquire one.** Adding branch 3 to Codex is a
   separate behavioural change with no ruling behind it and is outside this feature.
2. Seam shape: Claude uses mockable read functions; Codex uses parameters plus a repo-root-anchored
   entry point. The new record must be plumbed through each runtime's existing seam idiom, not
   unified.
3. Allow representation (`$null` vs. an explicit allow object) and the `exit 2` failure channel.
4. The `step9_status` accepted set and the `epic_mode` type test.
5. Path anchoring (session-relative vs `$PSScriptRoot`-derived repo root) — see R1.7.

---

## R3 — Helpers extraction

### R3.1 Precedent: how existing helpers files are structured and loaded

Two precedents exist on the Claude side.

**(a) `enforce-orchestration-preimplementation-gate-helpers.ps1` and `-modes.ps1`.** Loaded by the
parent hook by **dot-source with `$PSScriptRoot`**, not `Import-Module`
(`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`):

```
line  9: Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
line 14: . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-helpers.ps1')
line 20: . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-modes.ps1')
line 23: . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')
line 24: . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')
```

The helpers file itself is a bare script (no `[CmdletBinding()] param()`), opening with a comment
block that states the split rationale and declares it "dot-sourced by the sibling gate hook,
following the headroom-split precedent set by enforce-pr-author-skill.ps1"
(`enforce-orchestration-preimplementation-gate-helpers.ps1:16-17`). It declares script-scoped
constants at file level (lines 22-37) and pure functions below.

**(b) `enforce-pr-author-skill-helpers.ps1`.** Dot-sourced at
`enforce-pr-author-skill.ps1:148`, guarded by a comment explaining that dot-sourcing the hook in tests
loads the helpers too. This file *does* carry `[CmdletBinding()] param()` (lines 26-27) and
**re-dot-sources the shared parsers itself** (lines 31-32) "so this file keeps working when a test
dot-sources it directly". It reads the parent's script-scoped variables and calls the parent's read
seams (documented at lines 18-21).

**How tests load them.** Both: dot-source the parent hook *and* dot-source the helpers file
explicitly, with a comment that the redundancy is deliberate. Example,
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1:38-42`:

```
# change to the hook's dot-source line cannot silently leave these cases
# asserting against functions and constants that came from somewhere else.
# The file is pure, so redefining it is idempotent.
$script:ModesUnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1").Path
. $script:ModesUnderTest
```

**Recommended idiom for F3:** pattern (b) — `[CmdletBinding()] param()` plus a self-contained
dot-source of any shared parser it needs — because the authorization predicate will be a pure
function over an already-parsed checkpoint object and will therefore be directly unit-testable in
isolation, which pattern (b)'s self-sufficiency supports.

### R3.2 Hook registration by filename

**Yes, hooks are registered by filename, and the registration is per-entry-point only.**

- Claude: `.claude/settings.json` `hooks.PreToolUse[0].hooks[4].command` =
  `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` (line 111), under
  `"matcher": "Bash"` (line 91).
- Codex: `.codex/config.toml:142-143` registers the same hook with `command` and `command_windows`.

**Neither `enforce-orchestration-preimplementation-gate-helpers.ps1` nor `-modes.ps1` nor
`enforce-pr-author-skill-helpers.ps1` appears in `.claude/settings.json`, and neither preimplementation
helper appears in `.codex/config.toml`** (grep of `.codex/config.toml` for `preimplementation` returns
only the parent hook at lines 136-137 and 220-221).

**Conclusion: a new helpers file needs no hook registration. Confirmed, not assumed.**

There is, however, a Claude settings contract test —
`tests/scripts/claude-runtime/claude-settings.Tests.ps1` — which should be read before editing
`settings.json`. F3 does not need to edit `settings.json` at all.

### R3.3 Pack-manifest registration — **required, and there is a test that will catch its absence**

Hooks are enumerated **individually**, not by directory glob. Confirmed in
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`:

```
line 29: ".claude/hooks/enforce-epic-merge-gate.ps1",
line 35: ".claude/hooks/enforce-orchestration-preimplementation-gate.ps1",
line 36: ".claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1",
line 37: ".claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1",
line 46: ".claude/hooks/enforce-pr-author-skill-helpers.ps1",
```

Helpers files are precedent-registered. There are six manifests
(`core|csharp-legacy|csharp-modern|powershell|python|typescript.json`).

**The manifest test exists:**
`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`. It walks the **bundled**
`.claude/hooks/` directory (`enumerate_bundled_claude_relative_paths`, lines 86-91, no extension
filter) and asserts every entry appears in the union of all manifests' `paths` arrays
(`test_bundled_claude_files_are_listed_in_some_pack_manifest`, line 139), excluding exactly three
documented pre-existing exceptions (lines 52-58). A new bundled helper not added to a manifest fails
this test. A matching TypeScript twin is named at line 5:
`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.

Codex side, the same obligation exists with a **hardcoded** list rather than a directory walk:
`tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:134-160`
(`It 'includes every epic runtime surface in the core pack manifest'`) — a new Codex helper must be
added both to `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
and to that test's inline list, or it is silently unregistered. The Codex core manifest already lists
the two preimplementation helpers (lines 41-42), so the precedent is established.

The epic manifest's claim that `.claude/lib/` modules are asserted exactly once in `core.json` (via
`ModelRouting.Manifest.Tests.ps1`) is about **lib modules**, not hooks; for hooks the enforcing test is
the Python completeness test named above. Both obligations are real and distinct.

### R3.4 Recommended extraction boundary and line budget

**Do not move the existing three branch predicates.** They are directly unit-tested by name
(`enforce-epic-merge-gate.Tests.ps1` contexts at lines 245, 315, 336), and moving them would churn
three test files for no behavioural reason while making the "matcher is byte-unchanged" proof harder
to read in the diff.

**Recommended boundary — a new file `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` holding
only the new concern:**

| Content | Est. lines |
| --- | --- |
| Header comment block (rationale, split precedent, non-forgeability disclosure) | 30-40 |
| `[CmdletBinding()] param()` + shared-parser dot-sources | 5 |
| Reason-code constants (4 tokens, one assignment each, per the `enforce-parallel-abandon-gate.ps1:38-45` "declared ONCE EACH" precedent) | 12-16 |
| `Get-StandaloneMergeAuthorizationRecord` — locate the record for a given PR number in a parsed checkpoint; returns the record or `$null` | 35-45 |
| `Test-StandaloneMergeAuthorizationRecord` — field-shape and PR-binding validation; returns `$null` for valid, else a reason code | 60-90 |
| `Test-StandaloneCheckpointAllowsMerge` — the branch-4 predicate, composing the two above | 30-40 |
| **Total** | **~175-235** |

Parent-hook delta: one dot-source line, one branch-4 call block in `Invoke-EpicMergeGateDecision`
(~5 lines), and the header-comment rewrite from "three" to "four" (~8 net lines). **Parent lands at
roughly 500-505 lines under `(Get-Content).Count` if the header grows as written — which exceeds the
cap.** Therefore the extraction must also move something out, or the header edit must be net-neutral.

**Two viable ways to stay under the cap:**

- **(i) Preferred.** Move `Get-EpicMergeGateAllowDecision` (lines 327-338, 12 lines) and
  `Get-EpicMergeGateBlockDecision` (lines 340-355, 16 lines) into the new helpers file alongside the
  authorization logic. They are pure envelope factories with no script-scoped dependencies, they are
  exercised indirectly by every existing test (no test calls them by name — verified by grep of
  `tests/scripts/claude-hooks/enforce-epic-merge-gate*.Tests.ps1`), and removing them frees 28 lines.
  Parent then lands at roughly **472-477** lines: 23-28 lines of headroom, enough for the header
  rewrite. This is the smallest-blast-radius option.
- **(ii) Fallback.** Keep the header rewrite terse (replace the three-item list with a four-item list
  of the same total length by compressing the existing prose) and add only the dot-source plus the
  branch call. Parent lands at ~493-495. This works but leaves 5-7 lines of headroom, which is the
  position `enforce-orchestration-preimplementation-gate.ps1` is already in and which the epic calls
  out as unsustainable.

Codex side: the Codex hook at 187 lines has ~313 lines of headroom and needs **no extraction**. Adding
the standalone branch in place is correct there, and doing so avoids a second Codex manifest entry,
a second `$script:RuntimePaths` entry, a second coverage-config entry, and a second bundled file.
**Asymmetric treatment (extract on Claude, in-place on Codex) is the right call and should be stated
explicitly in the spec** so a reviewer does not read it as a parity gap.

---

## R4 — Bundled payload mirroring

### R4.1 Is the Claude bundled copy identical today?

`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
renders as 487 numbered lines, the same count as the repo-side file. Lines 1-60 and 400-487 were read
from both and are character-identical, including the `.NOTES` block, the three `$script:` path
assignments, the scope filter, the full deny string at line 433, and the entry-point tail.

**A byte-level hash comparison was not performed** because the `Bash` tool is disabled in this session
and no execution tool was available (`git hash-object`, `Get-FileHash`, and `diff` were all
unavailable). The claim verified here is: *identical line count and character-identical across the
148 lines sampled*. The epic manifest's stronger claim (`epic.md:176-179`, "`diff` reports no
difference") was made with tooling I did not have; I neither confirmed nor contradicted it.

**This gap does not matter for planning**, because the mirror-parity test in R4.2 asserts full-content
equality in CI and will fail loudly if the two ever diverge.

### R4.2 The mirror-parity test — **it exists, and a new helpers file is automatically covered**

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` (line 118):

```python
repo_runtime_files = [
    f
    for f in list_scoped_files(REPO_ROOT)
    if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
]

for relative_path in repo_runtime_files:
    assert (
        relative_path in bundled_files
    ), f"Repo file missing from bundle: {relative_path}"
    assert read_text(BUNDLED_ROOT, relative_path) == read_text(
        REPO_ROOT,
        relative_path,
    ), f"Bundle content differs from repo for: {relative_path}"
```

`list_scoped_files` (line 51) walks `SCOPED_ROOTS == (Path(".claude"),)` recursively, so **every**
`.claude/**` file is enumerated. Consequences for F3:

- A repo-side-only edit to `enforce-epic-merge-gate.ps1` **is** caught: the content assertion fails.
- A **new** `.claude/hooks/*.ps1` file **is automatically covered** — it enters `repo_runtime_files` by
  virtue of existing, and the presence assertion fires if the bundle copy is missing. **No new entry
  in any test is required for the mirror test.** (The *manifest* test in R3.3 is the one that also
  needs `core.json` updated.)
- One caveat: the comparison is `read_text` (Python text mode, universal newlines), not `read_bytes`.
  A pure CRLF-vs-LF difference between the two copies would pass. A separate byte-level test exists
  but covers only three named planner-review files
  (`test_planner_review_resources_exist_and_are_byte_identical`, line 146,
  `PLANNER_REVIEW_RESOURCE_PATHS` at lines 37-41) — the merge gate is not among them.

### R4.3 Every tree carrying a copy of this hook

`Glob('**/enforce-epic-merge-gate*.ps1')` returns eight paths; four are production copies and four are
test files.

| # | Path | Kind | Parity mechanism |
| --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-merge-gate.ps1` | Claude canonical | source of truth for #2 |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | Claude bundled | text-equality test, R4.2 |
| 3 | `.codex/hooks/enforce-epic-merge-gate.ps1` | Codex canonical | source of truth for #4 |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | Codex bundled | SHA-256 test, below |

**The Codex bundle parity test is a hardcoded allow-list, not a directory walk.**
`tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:162-170`:

```powershell
It 'keeps root and tracked bundle runtime copies byte-identical' {
    foreach ($relativePath in $script:RuntimePaths) {
        $rootPath = Join-Path $script:RepoRoot $relativePath
        $bundlePath = Join-Path $script:BundleRoot $relativePath
        Test-Path -LiteralPath $bundlePath -PathType Leaf | Should -BeTrue
        (Get-FileHash -LiteralPath $bundlePath -Algorithm SHA256).Hash |
            Should -Be (Get-FileHash -LiteralPath $rootPath -Algorithm SHA256).Hash
    }
}
```

`$script:RuntimePaths` is defined at lines 10-34 and contains
`'.codex/hooks/enforce-epic-merge-gate.ps1'` at line 29. Note the two preimplementation helpers are
**not** in that list — Codex helpers are in the manifest but not in the byte-identity list. If F3 adds
a Codex helpers file (not recommended, per R3.4), it must be added to `$script:RuntimePaths` and to
the manifest list at lines 136-157 or it gets no parity assertion at all.

There is a second Codex static-check surface,
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, whose `$script:SharedModuleNames`
(line 30) enumerates non-entry-point modules subject to "parse, 500-line cap, root/bundle" checks
(lines 25-31, 106, 137). A new Codex shared module belongs there too.

### R4.4 Full change-surface checklist for F3

1. `.claude/hooks/enforce-epic-merge-gate.ps1` — branch 4 + header rewrite + dot-source.
2. `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` — new.
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` — mirrors of both (1) and (2).
4. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — add (2)'s path.
5. `.codex/hooks/enforce-epic-merge-gate.ps1` — branch in place.
6. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` — mirror of (5).
7. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — add (2) to `CodeCoverage.Path` (R9).
8. `.claude/rules/orchestrator-state.md` — new key-gated scope + invariants section (R6).
9. Its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` — required by the R4.2 test.
10. The writer surface(s) that produce the record — see R7.5.
11. Tests (R5.4).

---

## R5 — Existing tests and the established idiom

### R5.1 The four suites

| File | Lines | Loads under test by |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 455 | dot-source the hook in `BeforeAll` (lines 9-12) |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | — | dot-source the hook (lines 24-26) + a local `ConvertTo-MergeGateEnvelope` helper (lines 28-38) |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` | — | dot-source (lines 34-37) + in-process console redirection harness (lines 39-67) |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | — | dot-source (lines 33-35) + `ConvertTo-CodexMergeTriggerScopingPayload` (lines 37-49) |

**Note the Claude primary suite is at 455 lines against the 500 cap.** The full standalone matrix will
not fit there; F3 must add a new sibling suite, which is the established convention (the repo has at
least ten `*.Payload.Tests.ps1` / `*.TriggerScoping.Tests.ps1` splits created for exactly this reason —
e.g. `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:7`,
`enforce-pr-author-skill.Payload.Tests.ps1:8`).

### R5.2 The idiom

**Claude:** every decision case drives the pure seam `Invoke-EpicMergeGateDecision -ToolInputRaw
<literal JSON>` and mocks **all three** checkpoint read seams, with checkpoint JSON supplied as a
string literal from the mock body. Canonical form
(`enforce-epic-merge-gate.Tests.ps1:136-145`):

```powershell
Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
    '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}'
}
$json = '{"tool_input":{"command":"gh pr merge --merge 501"}}'
$decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
```

The TriggerScoping suite states the determinism rule explicitly (lines 14-20): "Every decision-level
case mocks all three checkpoint read seams, so no case reads live orchestration state from disk.
Without that, a case would pass or fail depending on whether an orchestration run happened to be in
flight." **F3's new tests must mock the new seam (if any) in every existing case too, or existing
cases become order-dependent.** If the record lives inside an already-mocked checkpoint, this problem
does not arise — a further argument for that placement.

Branch-predicate cases call the predicate directly with a `ConvertFrom-Json`-parsed literal
(lines 245-289), no mocking at all.

Assertion form is always `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'|'deny'`
plus, on deny, `permissionDecisionReason | Should -Match '<TOKEN>'`.

**Zero temp files.** Nothing in any of the four suites writes to disk. The two seam-coverage cases
(lines 232-243, 291-313) mock `Test-Path` and `Get-Content` with `-ParameterFilter` on the script
variable rather than creating a fixture file.

**Codex:** checkpoint text arrives as a parameter; allow is asserted as `$null`. See
`enforce-epic-merge-gate-trigger-scoping.Tests.ps1:11-14` for the idiom statement.

### R5.3 The false-allow test referenced by hook comments at lines 141-147

The hook comment (`.claude/hooks/enforce-epic-merge-gate.ps1:143-150`) says:

```
        The deleted unanchored branch scanned the WHOLE command text for the first run of
        digits once "gh pr merge" appeared anywhere in it, and that failed in both
        directions. Fail-closed: a leading "cd <path>" whose path carries a timestamp
        component supplied a digit run that was not a pull request number, so an authorized
        merge was blocked. False-allow: with authorized item 501 and unauthorized item 777,
        "cd /repo/worktrees/501 && gh pr merge --merge 777" extracted 501, matched the
        authorized item, and permitted the merge of PR 777. Taking the number from the
        matched segment's own operand or flag value closes both directions.
```

The test is `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1:87-131`,
context `'the false-allow direction of the whole-line PR-number defect'`. Verbatim, lines 87-118:

```powershell
    Context 'the false-allow direction of the whole-line PR-number defect' {
        # This context pins the UNAUTHORIZED-MERGE direction of the defect, which the
        # cd-prefixed case above does not exercise. That case uses a cd path component
        # matching no authorized item, so it only exercises the fail-closed direction.
        # Here the cd path component IS an authorized item number and the merge operand
        # is a DIFFERENT, unauthorized pull request. Before the fix the whole-line scan
        # returned the authorized 501, the parallel branch matched item 501 at ci_green,
        # and the gate permitted merging PR 777. Executed pre-change observation:
        # the extractor returned 501 and the decision was allow.
        BeforeAll {
            $script:FalseAllowCommand = 'cd /repo/worktrees/501 && gh pr merge --merge 777'
        }

        It 'takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path' {
            Get-EpicMergeGateCommandPrNumber -CommandText $script:FalseAllowCommand | Should -Be 777
        }

        It 'denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line' {
            # Item table: 501 is authorized (merge_status ci_green); 777 is NOT
            # authorized (merge_status pr_open). Only the parallel checkpoint is
            # populated, so the decision turns on which number the gate extracted.
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"item_id":"item-501","pr_number":501,"merge_status":"ci_green"},{"item_id":"item-777","pr_number":777,"merge_status":"pr_open"}]}'
            }

            $envelope = ConvertTo-MergeGateEnvelope -Command 'cd /repo/worktrees/501 && gh pr merge --merge 777'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'still allows merging the authorized PR 501 when 501 is the merge operand' {
```

**How it works, and why F3's tests must copy it.** The construction has four properties that make it
a genuine discriminator rather than a tautology:

1. **A two-entry item table where one entry is authorized and the other is not.** If both entries were
   authorized the test could not distinguish which number was extracted.
2. **The unauthorized number appears in the operand; the authorized number appears elsewhere on the
   line** (inside the `cd` path). The defect and the fix disagree about which one is read.
3. **All three checkpoint seams are mocked, and only the one under test is populated**, so the decision
   turns on exactly one variable.
4. **A paired positive case** (lines 120-131) proves the fix does not simply deny everything.

**The exact analogue F3 needs:** an authorization record naming PR *A*, a command merging PR *B*,
where a naive implementation (record present ⇒ allow) would allow, and the correct implementation
denies. The paired positive is the same record with the command merging PR *A*. Without property (1)
— two distinct PR numbers, only one authorized — a "record names a different PR" test proves nothing.

### R5.4 Which existing cases become regression guards

All currently-passing cases stay. The ones load-bearing for F3, by name:

**Must-not-widen guards (prove the `pr_number` matcher is intact):**

| Test | File:line |
| --- | --- |
| `'takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path'` | TriggerScoping:100 |
| `'denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line'` | TriggerScoping:104 |
| `'still allows merging the authorized PR 501 when 501 is the merge operand'` | TriggerScoping:120 |
| `'returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag'` | TriggerScoping:42 |
| `'returns 410 for the equals-joined spelling gh pr merge --merge=410'` | TriggerScoping:57 |
| `'returns 410 for the number-before-flag form gh pr merge 410 --merge'` | Tests:219 |
| `'returns 410 for the flag-before-number form gh pr merge --merge 410'` | Tests:223 |
| `'returns $null for a bare gh pr merge --merge with no PR number'` | Tests:227 |
| `'denies gh pr merge <N> --merge when N does not match epic_merge_pr.pr_number'` | Tests:86 |
| `'denies when the command PR number matches no item'` | Tests:161 |
| Codex: `'resolves 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag'` | codex trigger-scoping:57 |

**Fail-closed guards (prove branch 4 does not open a hole when no record is present):**

| Test | File:line |
| --- | --- |
| `'denies EPIC_MERGE_GATE_BLOCKED when both checkpoints are absent'` | Tests:114 |
| `'denies when both checkpoints are unreadable (malformed JSON)'` | Tests:124 |
| `'denies when the parallel checkpoint is absent and child and epic are also absent'` | Tests:185 |
| `'denies when the parallel checkpoint is malformed JSON'` | Tests:195 |
| `'denies a bare gh pr merge --merge (no PR number) even when a parallel checkpoint is present'` | Tests:205 |
| `'denies an empty payload as an envelope anomaly (fail closed)'` | Tests:15 |
| `'denies unparseable JSON instead of throwing (exit 1 is non-blocking)'` | Tests:33 |
| `'denies the nested envelope end-to-end when no checkpoint satisfies the gate'` | Tests:435 |

**Scope-filter guards (prove branch 4 does not widen what is in scope):**

| Test | File:line |
| --- | --- |
| `'allows gh pr merge without --merge (e.g., --squash)'` | Tests:27 |
| `'allows a non gh-pr-merge Bash command'` | Tests:21 |
| `'allows a printf whose double-quoted text mentions the gated merge phrase'` | TriggerScoping:63 |
| `'keeps gh --repo drmoisan/drm-copilot pr merge --merge 688 in scope'` | TriggerScoping:75 |
| `'R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument'` | TriggerScoping:139 |

**Existing allow guards (prove branches 1-3 still authorize what they authorized):** Tests:41, 64, 74,
136.

Note the case at Tests:205 (`bare --merge with a parallel checkpoint present` ⇒ deny) is the sharpest
constraint on branch 4's design: **whatever the new branch does, a bare `gh pr merge --merge` with no
explicit PR number must still deny**, because an authorization record that names a specific PR cannot
be matched against a command that names none. This must be an explicit F3 test, not an inherited one.

---

## R6 — Checkpoint schema addition

### R6.1 The additive, KEY-GATED convention

`.claude/rules/orchestrator-state.md` establishes the convention four times over, once per existing
optional block. The canonical phrasing (line 49, the `human_interaction` block):

> These invariants apply only when the checkpoint contains a top-level `human_interaction` block. A
> checkpoint with no `human_interaction` key (the existing checkpoint shape) is unaffected: it
> validates exactly as before and produces no new errors. The invariants are additive.

Repeated verbatim in structure at line 37 (`remediation_loop`), line 61 (`complexity_assessments`),
and line 79 (`model_routing_receipts`). Line 95 restates it as a design property: "The
complexity-assessment and model-routing-receipt invariants above are key-gated: they run only when
their key is present, so a checkpoint that omits both arrays passes at every stage."

Two further rules the new section must observe:

- **Foreign Schema Warning (lines 29-33).** Enforcement is "validator logic plus this prose, never an
  imported JSON Schema." No schema file may be authored for the new block.
- **Enforcement bullets (lines 127-132).** Each optional block gets one bullet naming its delegated
  sibling module. The new block needs one.

### R6.2 `optional_key_validators` and the `_orchestrator_state_*.py` sibling pattern

`scripts/dev_tools/validate_orchestrator_state.py:432-448`:

```python
    optional_key_validators = (
        (REMEDIATION_LOOP_KEY, _validate_remediation_loop),
        (HUMAN_INTERACTION_KEY, _validate_human_interaction),
        (COMPLEXITY_ASSESSMENTS_KEY, _validate_complexity_assessments),
        (MODEL_ROUTING_RECEIPTS_KEY, _validate_model_routing_receipts),
        (
            CODEX_MODEL_ROUTING_RECEIPTS_KEY,
            validate_codex_model_routing_receipts,
        ),
        (
            codex_topology.CODEX_TOPOLOGY_RECEIPTS_KEY,
            codex_topology.validate_codex_topology_receipts,
        ),
    )
    for optional_key, optional_validator in optional_key_validators:
        if optional_key in state_map:
            errors.extend(optional_validator(state_map.get(optional_key)))
```

Each entry is `(KEY_CONSTANT, validator_callable)`, both imported from a `_orchestrator_state_<block>.py`
sibling (imports at lines 8-47). Ten such siblings exist:
`_orchestrator_state_codex_model_routing.py`, `_codex_topology.py`, `_complexity.py`,
`_human_interaction.py`, `_model_routing.py`, `_model_routing_gate.py`, `_pr_creation_readiness.py`,
`_preparation_terminal.py`, `_routing.py`, `_step_status.py`.

**The exact pattern a new block follows:** create
`scripts/dev_tools/_orchestrator_state_standalone_merge.py` exporting a
`STANDALONE_MERGE_AUTHORIZATIONS_KEY` string constant and a
`validate_standalone_merge_authorizations(value: object) -> list[str]` function that takes **only the
block's value** (not the whole `state_map`), returns one error string per violated invariant, and
mutates nothing; import both in `validate_orchestrator_state.py` and append one tuple to
`optional_key_validators`. Error strings follow the existing "literal, checkpoint-context prefixed"
style (rule line 128).

**Parallel and epic checkpoints have their own validators**, and both are also key-gated:

- `validate_parallel_orchestrator_state.py:181-206` — a run of `if "<key>" in state: errors.extend(...)`.
  **Important constraint:** line 327 calls `scan_prohibited_keys(state_map, CONTEXT)`, which rejects
  `depends_on`, `integration_branch`, and `epic_merge_pr` **at any nesting level**
  (`_parallel_state_common.py:100-102`). A new block for the parallel checkpoint must avoid those three
  key names anywhere inside it. It is a three-name denylist, not `additionalProperties: false`, so an
  unrelated new top-level key is permitted.
- `validate_epic_orchestrator_state.py:468, 474` — the same `if KEY in state_map` form; no
  prohibited-key scan.

### R6.3 The TypeScript parity port

`extensions/drm-copilot/src/lib/validate/orchestrator-state-*` contains **nine** files:
`-codex-model-routing.ts`, `-codex-topology.ts`, `-completion.ts`, `-core.ts`,
`-human-interaction.ts`, `-model-routing-existence.ts`, `-preparation-terminal.ts`,
`-remediation.ts`, `-routing.ts`.

`orchestrator-state-core.ts` imports remediation (line 17), human-interaction (line 13),
codex-model-routing (line 2), codex-topology (line 3), preparation-terminal (line 18), and
model-routing-existence (line 19). Its header comment (lines 36-43) states it ports "the core of
`scripts/dev_tools/validate_orchestrator_state.py`".

**The port is not universal, and there is a precedent for a Python-only optional block.**
`complexity_assessments` has a Python validator (`_orchestrator_state_complexity.py`) and **no**
TypeScript counterpart: a repo-wide grep for `complexity_assessments` under `extensions/` returns nine
matches, all in `.claude` bundle prose (skills, rules, `.psm1`, agents) and **zero** in
`extensions/drm-copilot/src/`. Per-receipt model-routing correctness is likewise Python-only; the TS
surface does the existence check only, stated at `.claude/rules/orchestrator-state.md:107`:

> The MCP TypeScript surface performs the existence check only (delegated-agent set ⊆ routing-receipt-agent set); the Python validator remains authoritative for per-receipt correctness.

**Conclusion: a TypeScript port is not required for the new block.** If one is nevertheless added,
error strings must be byte-identical — the rule states this for the launch-binding port (line 123:
"reproduces it with byte-identical error strings") and the TS modules assert it in their own headers
(`plan-gate-rules.ts:21`, `parallel-state-shared.ts:14`, `epic-orchestrator-state-resolution.ts:13`).
**Recommendation: Python-only, following the `complexity_assessments` precedent, and say so explicitly
in the spec** so a reviewer does not read the absence as an oversight.

### R6.4 Does the merge gate need the Python validator? **No. The split is clean.**

- **Hook = PowerShell read + verify.** The hook already reads and parses checkpoint JSON itself
  (`ConvertFrom-EpicMergeGateJson`, line 106) and makes every allow/deny decision from the parsed
  object with no external process. Branch 4 does the same. The hook **must not** call the Python
  validator: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans
  `.claude/hooks/**` and `.claude/lib/**` (scan roots at lines 39-42) for four detection classes —
  constant interpreter command (`python|python3|py|poetry`), `Start-Process` targeting one,
  fail-closed dynamic invocation, and `Invoke-Expression`/`iex` — and its allowlist is asserted
  **empty** (`It 'ships an empty allowlist'`, line 102). Any Python leg fails that suite.
- **Validator = optional structural check.** The Python validator's role is to catch a malformed
  record at `SubagentStop` / MCP-validation time, so a checkpoint carrying a garbage record is
  rejected before a merge is ever attempted. It is defence in depth, not the gate.
- **Consequence for the design:** the hook's own record validation must be complete and fail-closed on
  its own, because in the production path the validator may never have run on that checkpoint. The
  hook cannot assume a validated record.

---

## R7 — Non-forgeability

### R7.1 What currently limits an agent from writing `artifacts/orchestration/*.json`

**Effectively nothing, and the repository says so in writing.**

1. **`.claude/settings.json` permissions.** The `allow` list contains `"Edit(artifacts/**)"` (line 13)
   and `"Edit(docs/**)"` (line 12). The `deny` list (lines 68-73) contains exactly four entries:
   `Read(./.env)`, `Read(./.env.*)`, `Read(./secrets/**)`, `Edit(./secrets/**)`. **There is no deny
   rule of any kind for `artifacts/**` or `artifacts/orchestration/**`.**

2. **`"defaultPermissionMode": "bypassPermissions"` (line 292).** This makes the allow list
   decorative: the permission system is not consulted for a decision in this repository's default
   configuration. The measured-semantics memory note records the same conclusion for the adjacent
   `.claude/` protection ("In this repo it is moot in practice because `defaultPermissionMode` is
   `bypassPermissions`"). I verified line 292 in this tree; I did **not** re-run the empirical probe.

3. **Measured matcher semantics (recorded, verified against this tree where possible).** A memory note
   from 19 days ago records four empirically measured facts about Claude Code 2.1.246 permission
   matchers. The two that bear on F3, with their observable footprint in this tree:
   - `Write(<path>)` matches no tool; `Edit(<path>)` is the family rule covering Edit, Write, and
     NotebookEdit. **Consistent with this tree:** `settings.json` uses `Edit(...)` in all six
     path-bearing rules and uses `Write(...)` in none.
   - `memory:` in agent frontmatter grants unscoped `Write` + `Edit` to that agent regardless of its
     `tools:` list, and all agents in `.claude/agents/` declare a `memory:` scope. **I did not
     re-verify the frontmatter of all 24 agents in this session**; treat this as a recorded prior
     observation, not a fresh measurement. Its direction is not in doubt given (2) above.

4. **Per-write hooks.** `.claude/settings.json` registers eleven `Write|Edit` PreToolUse hooks
   (lines 128-174). The only one that inspects the orchestrator checkpoint is
   `enforce-checkpoint-monotonic.ps1`, which activates only when `file_path` is exactly
   `artifacts/orchestration/orchestrator-state.json` (header, lines 7-9), validates only
   `completed_steps` ordering, is suppressed by a non-empty `rollback_history` (line 32), and
   **allows every `Edit` call unconditionally** because a partial patch cannot be validated
   (lines 35-38). It does not fire on the epic or parallel checkpoints at all.

**Statement for the spec:** the agent whose `gh pr merge --merge` the gate evaluates can write the
record the gate reads, on the same filesystem, in the same session, with no permission obstacle. Any
design must be honest about that.

### R7.2 Existing precedents for an auditable, hard-to-forge record

**(a) The SHA-256 body receipt.** `artifacts/pr_body_<N>.receipt.json`, consumed by
`enforce-pr-author-skill.ps1` via `enforce-pr-author-skill-helpers.ps1`
`Test-PrAuthorReceiptVerification` (line 34). Six ordered checks, first failure blocks:
`PR_BODY_PATH_NONCANONICAL` → `PR_AUTHOR_RECEIPT_MISSING` → `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` →
`PR_AUTHOR_RECEIPT_HASH_MISMATCH` → `PR_AUTHOR_RECEIPT_STALE` → `EPIC_BASE_BRANCH_MISMATCH`
(helpers lines 41-50). Field set: `number` (int), `sha256` (lowercase hex), `created_at` (UTC
ISO-8601), plus `pr_body_path` and `context_summary_path` written by the agent
(`.claude/agents/pr-author.md:55-60`). The staleness check (helpers lines 119-133) compares
`created_at` against the *filesystem* last-write time of `artifacts/pr_context.summary.txt` — a value
the record's author does not write. Four injectable seams; SHA-256 computed inline
(`[System.Security.Cryptography.SHA256]::Create()`, helpers line 107).

**The repository's own honest disclosure**, `.claude/agents/pr-author.md:79-88`:

> The SHA-256 receipt is a **policy-level integrity check, not a cryptographic or security control.** It
> binds the PR body bytes to the receipt so that the hook can confirm the body passed via `--body-file`
> is the body the pr-author skill produced. Any actor with `Write(/artifacts/**)` access can replace
> both `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json` together with a matching
> SHA-256, because all agents share the same filesystem and the runtime exposes no native agent-identity
> signal at Bash PreToolUse time. The mechanism prevents accidental bypass (such as the PR #228 pattern
> where the orchestrator wrote the body file and called `gh pr create` directly) and requires a
> deliberate, documented act to circumvent. It is not tamper-proof and is not a security boundary.

The same paragraph appears in the hook's `.NOTES` (`enforce-pr-author-skill.ps1:35-41`).

**(b) The injectable `$Invoker` subprocess seam.** `Invoke-OrchestratorStatePreflight` in
`.claude/lib/orchestrator-state/OrchestratorState.psm1:401-486`, called from the PreToolUse hook at
`enforce-pr-author-skill-helpers.ps1:240`. Its docstring (lines 405-415) is emphatic that **the seam
starts no subprocess**: "an injectable scriptblock seam whose default runs the portable in-process
validation and starts no subprocess. As of issue #475 there is no capability detection and no
alternative branch". The re-validation runs **inside the PreToolUse hook** so it "cannot be bypassed
by invoking gh pr create/edit directly" (helpers lines 237-238). The seam's contract is a hashtable
`@{ HasErrors = <bool>; ErrorText = <string> }` (line 485). Callers surface failure as
`ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summary>` (helpers line 247).

`.claude/hooks/validate-orchestrator-output.ps1` carries the same two seam names (`$Invoker` line 251,
`$RoutingInvoker` line 323). The `[scriptblock]` parameter form is the **one carve-out** the
no-Python guard recognizes as safe dynamic invocation
(`enforcement-hooks-no-python-invocation.Tests.ps1:350-368`, `'reports no finding for a
scriptblock-parameter seam invocation'`).

**(c) Live `gh` lookups from a hook — there are none, and the merge gate's own comment explains why.**
A grep of `.claude/hooks/` for `gh pr view`, `& gh `, `Start-Process`, and `Invoke-Expression` returns
four hits, none of which is a live `gh` call: two are documentation strings, one is a forbidden-pattern
literal in the test-purity hook, and one is the merge gate's own design note. The design note,
`.claude/hooks/enforce-epic-merge-gate.ps1:29-32`, verbatim:

```
    Design decision: this gate trusts the on-disk checkpoint rather than shelling out live
    to gh pr view for a real-time head-SHA check, matching the same non-adversarial,
    policy-level-not-cryptographic posture already accepted for
    enforce-pr-author-skill.ps1's own receipt mechanism. It is not a cryptographic control.
```

A `gh` wrapper-seam convention exists (`Invoke-GhExe`) but **only in `scripts/dev-tools/`**
(`Invoke-ReleaseVerification.ps1:56`, `Invoke-MarketplacePublish.ps1:93`, `Invoke-FullRelease.ps1:96`,
`Invoke-FullReleaseFlow.ps1:85`) — never in a hook. `check-powershell-test-purity.ps1:101,104` forbids
`Mock gh` in any Pester test and directs the author to the `Invoke-GhExe` wrapper, so a live `gh` call
in a hook would be testable, but it would be the first one.

**(d) A non-workspace authority store — exists, but only on Codex.**
`.codex/hooks/codex-authority-store.ps1:5-8`:

```
    Epic-entry receipts and routed-subagent attestations must not be writable by
    workspace-scoped agents. These helpers derive a repository- and session-bound
    directory under CODEX_HOME and exact receipt/attestation paths within it.
```

It keys the store by `SHA-256(canonical repository root path)`
(`Get-CodexAuthorityRepositoryKey`, lines 39-47). This works on Codex because `.codex/config.toml`
declares a real permissions profile (`[permissions.orchestrator-workspace]` / `extends = ":workspace"`,
asserted at `codex-epic-runtime-contracts.Tests.ps1:80-81`) and the epic child launcher sets an
isolated `CODEX_HOME` with explicit denied paths (`.codex/scripts/resume-epic-child.ps1:126-134`).
**There is no Claude-side equivalent**, and `bypassPermissions` means one cannot be constructed from
`settings.json`.

**(e) A same-command confirmation marker.** `.claude/hooks/enforce-parallel-abandon-gate.ps1:11-14`
requires the confirmation marker to appear "in the SAME command" as the destructive token. The two
token literals are declared once each (lines 41-42) and a producer/consumer seam test
(`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`, named at hook line 30) parses both
sides at run time so a rename on one side fails. The reason-code literal is likewise declared once
(line 45) "so the reason code is greppable in transcripts".

**(f) Authorization as a property of the object, not the caller.**
`.claude/hooks/enforce-epic-worktree-removal-gate.ps1:34-36`:

```
    The authorization is a property of the path rather than of the caller, and the safety
    property this gate protects - do not destroy unmerged work - is likewise a property of
    the path's recorded merge state.
```

Lines 38-46 then record an "Accepted residual" in full — stale-checkpoint risk, why a collision is
implausible, and the explicit framing "This is a documented accepted trade, not an unexamined gap."
**This is the disclosure template F3 should copy.**

### R7.3 What the runtime actually hands the hook that the agent does not author

Two signals are already reachable in this hook with no new plumbing:

1. **`session_id`.** `Resolve-ClaudeHookToolInput` returns `Envelope` alongside `Value`
   (`HookPayload.psm1:478-483`) specifically so a hook can read envelope-root fields; the docstring
   (lines 447-450) names `enforce-epic-invocation-origin.ps1`'s `agent_type` need as the reason.
   `Get-ClaudeHookEnvelopeValue -Envelope $payload.Envelope -Name 'session_id'` is a one-line read.
   Corroborating evidence that `session_id` is on the envelope: `persist-session-id.ps1:57-59` extracts
   it from the SessionStart payload, and `enforce-epic-merge-gate.Tests.ps1:406` already feeds a
   `{"session_id":"s1","tool_name":"Bash"}` envelope in a test.
   The same hook publishes it to disk at `.claude/state/current-session-id`
   (`persist-session-id.ps1:161`), so the hook has an independent second copy to compare against.

2. **`agent_type`.** `.claude/hooks/enforce-epic-invocation-origin.ps1:18-20`:
   "The PreToolUse envelope carries a top-level 'agent_type' field only when the tool call is made
   from inside a subagent context. A main-thread call carries no 'agent_type'."

**Conflict to record, not resolve.** That statement and `pr-author.md:85`'s "the runtime exposes no
native agent-identity signal at Bash PreToolUse time" are in tension. Two readings are consistent with
the evidence: (i) `agent_type` is present on Agent-matcher envelopes but not Bash-matcher envelopes, or
(ii) the pr-author disclosure predates the `agent_type` discovery and is now stale.
**I could not resolve this** — it requires observing a live Bash PreToolUse envelope raised from inside
a subagent, which is not possible from a read-only research session. Search scope: I grepped all 30
files in the repository containing `agent_type`; every production consumer is an Agent-matcher hook
(Claude `enforce-epic-invocation-origin.ps1`; Codex `enforce-epic-root-invocation.ps1`,
`enforce-codex-model-routing.ps1`, `enforce-epic-child-worktree-binding.ps1`,
`validate-codex-subagent-routing.ps1`, `record-subagent-routing-attestation.ps1`), and no test
asserts `agent_type` on a Bash envelope. **A design that depends on `agent_type` at Bash PreToolUse
time must first verify it empirically.** A design that depends only on `session_id` does not carry
that risk.

### R7.4 Feasible verification designs (reported, not decided)

Each axis is assessed on three fixed criteria: PowerShell feasibility in this hook; consistency with
the "not a cryptographic control" posture; and testability cost under the no-temp-file rule.

| # | Design | PowerShell feasibility | Posture consistency | Testability cost | What it actually stops |
| --- | --- | --- | --- | --- | --- |
| (i) | **Required self-consistent fields.** Record must carry `pr_number`, `pr_url`, `branch_name`, `issue_num`, `authorized_by`, `authorized_at`, `basis`, and the hook cross-validates `pr_url` ends in `/pull/<pr_number>`, `authorized_at` parses as UTC ISO-8601, `basis` is a non-empty string of >= N characters. | Trivial. Pure string/int logic on an already-parsed object; no new seam. | Fully consistent — this is exactly the receipt precedent (b)'s check 3 (`number` vs path `<N>`) generalised. | Zero. String literals in mocks. | Accidental bypass, copy-paste of another PR's record, an empty placeholder. Not deliberate forgery. |
| (ii) | **Cross-check a field the agent does not author.** Compare the record's `session_id` against the live envelope's `session_id` (and/or `.claude/state/current-session-id`). | Trivial for the envelope leg (`$payload.Envelope`, already in scope). One extra read seam for the disk leg. | Consistent. Analogous to the receipt's `created_at` vs context-file mtime check, which compares against filesystem metadata the author does not set. | Near zero for the envelope leg — the test envelope already carries `session_id`. One more seam to mock for the disk leg. | A **stale or reused** record from a previous session, and a record copied between runs. This is the highest-value-per-unit-cost check, because the observed failure mode (a run stalls, an agent is tempted to hand-write a record) is exactly the one a session binding makes visible. Does not stop same-session forgery. |
| (iii) | **Live `gh pr view` corroboration in the hook.** Verify the PR is open, CLEAN, and all checks passed at decision time. | Feasible behind a `[scriptblock] $Invoker` seam (the one carve-out the no-Python guard permits). But it would be the **first** `gh` call from any hook, adds network latency to every in-scope Bash call, and fails closed on a network blip — turning a transient outage into a merge stall, which is the very failure class this feature exists to remove. | **Directly contradicts** the gate's own design note at lines 29-32, which names `gh pr view` and rejects it by name. Adopting it reverses a documented decision without a ruling. | Moderate. `Mock gh` is forbidden (`check-powershell-test-purity.ps1:101,104`); an `Invoke-GhExe`-style wrapper plus seam injection is required. No temp files needed. | A record naming a PR that is not actually green. But the checkpoint already claims that, and the gate already trusts the checkpoint for branches 1-3. |
| (iv) | **SHA-256 receipt over the record**, following the pr_body precedent — a sidecar `artifacts/standalone_merge_<N>.receipt.json` whose `sha256` covers the record bytes. | Trivial; `SHA256::Create()` precedent at helpers line 107. Needs one new read seam. | Consistent with the precedent, **but the precedent's own disclosure says it does not raise the bar**: "Any actor with Write access to artifacts/ can replace both the body file and the receipt together." A record and its own receipt written by the same agent in the same session is strictly weaker than the pr_body case, because there is no third artifact (the context file's mtime) to anchor staleness against. | One new seam to mock in every case. | Almost nothing beyond (i). Adds a file, a seam, a manifest entry, and a coverage entry for no measurable gain. **Recommend against.** |
| (v) | **Record lives outside the gated agent's write permissions.** | **Not feasible on Claude today.** `defaultPermissionMode: bypassPermissions` (settings.json:292) means no path is outside any agent's write reach, and the measured semantics say `.claude/` cannot be granted either. The Codex authority store (precedent (d)) works only because Codex has a real permissions profile and an isolated `CODEX_HOME`. | Would be the strongest design if the substrate supported it. | High — would need a new store module, a path resolver, and its own test surface. | Deliberate forgery, if the substrate existed. **Record as blocked on a substrate change, not rejected on merit.** A separate issue proposing a Claude-side permissions posture change is the honest path. |

**Two designs that must be explicitly excluded in the spec** (both are restatements of a closed
anti-pattern, and a reviewer will otherwise propose them):

- A boolean `standalone_merges_allowed: true` — the issue already forbids it
  ("A blanket 'standalone merges allowed' flag is not an authorization record and must be rejected by
  the design", `issue.md:84-85`). The design must **actively reject** it, meaning a record object with
  no `pr_number` must produce a distinct deny code, not merely fail to match.
- A record whose `pr_number` is a wildcard, a list, `"*"`, `0`, or `null`. Each must deny.

### R7.5 What makes the record "auditable" — proposed field set

The issue's own words are "explicit, auditable authorization record naming that SPECIFIC PR". The four
audit questions are **who**, **which PR**, **when**, **on what basis**. Proposed shape (block name
avoids all three prohibited key tokens from R6.2):

```json
"standalone_merge_authorizations": [
  {
    "pr_number": 691,
    "pr_url": "https://github.com/drmoisan/drm-copilot/pull/691",
    "issue_num": 670,
    "branch_name": "fix/epic-merge-gate-authorization-record-670",
    "authorized_by": "parallel-orchestrator",
    "authorized_at": "2026-09-13T21:04:00Z",
    "session_id": "0f3c...",
    "basis": "Standalone fix for #670 unblocks run bugs-2026-09-11; PR is CLEAN with all required checks passed.",
    "run_slug": "bugs-2026-09-11"
  }
]
```

| Field | Type | Audit question | Hook obligation |
| --- | --- | --- | --- |
| `pr_number` | integer, > 0 | which PR | **The binding.** Must equal the command's extracted PR number. Absent, non-integer, <= 0, wildcard, or list ⇒ deny. |
| `pr_url` | non-empty string | which PR (corroboration) | Must end with `/pull/<pr_number>`. Catches a copy-paste that updated one field and not the other — the direct analogue of receipt check 3. |
| `issue_num` | integer, > 0 | why it exists | Presence and type only. |
| `branch_name` | non-empty string | which change | Presence and non-emptiness only. Do not compare against the live branch: that would reintroduce cwd dependence, which is the epic's own defect class. |
| `authorized_by` | non-empty string | **who** | Presence and non-emptiness. The runtime cannot attest it (R7.3), so the hook must **not** claim it verifies identity; it records a declaration. State this in the disclosure. |
| `authorized_at` | UTC ISO-8601 string | **when** | Must parse via `[DateTime]::TryParse(..., InvariantCulture, AdjustToUniversal -bor AssumeUniversal, [ref])` — the exact call the receipt uses (helpers lines 121-125). Unparseable ⇒ deny. |
| `session_id` | non-empty string | **when / which run** | Design (ii). Must equal the live envelope's `session_id`. This is the only field a forging agent cannot simply invent without also being in the authorizing session. |
| `basis` | non-empty string | **on what basis** | Non-empty after trim, and >= a stated minimum length so a single character does not satisfy "auditable". The receipt has no analogue; the nearest precedent is the `rationale` non-emptiness invariant for `complexity_assessments` (`.claude/rules/orchestrator-state.md:73`). |
| `run_slug` | non-empty string, optional | traceability | Presence not required. |

An **array** rather than a single object, because one run may legitimately land more than one
standalone fix; the hook selects by `pr_number` and denies when the command's number matches no entry.
This mirrors the `items[]` selection shape the parallel branch already uses (lines 303-322) without
touching that branch's matcher.

**Where the block lives.** Recommend the **parallel checkpoint** and the **epic checkpoint** and the
**per-feature checkpoint** — i.e. the hook checks branch 4 against whichever of the three already-read
checkpoints carries the key, using the existing three read seams and adding none. This is the
single most valuable design decision available:

- No new read seam ⇒ no new mock in any existing test ⇒ no risk of turning an existing case
  order-dependent (R5.2).
- No new file ⇒ no pack-manifest entry, no coverage-config entry, no bundle mirror for a data file.
- The key-gated convention (R6.1) means all three validators stay byte-identical for a checkpoint that
  omits the key.
- The `bugs-2026-09-11` failure occurred under a parallel run, whose checkpoint the gate already reads.

### R7.6 Recommendation

**Design (i) + (ii): required self-consistent fields, plus a `session_id` cross-check against the live
PreToolUse envelope, with the record carried as a key-gated top-level array inside the existing
checkpoints.** Reject (iv) outright (cost with no gain, and the precedent's own disclosure says so).
Reject (iii) as contradicting a documented decision that has not been re-litigated. Record (v) as
blocked on a substrate the Claude runtime does not currently provide, and propose it as a separate
issue rather than silently dropping it.

**Mandatory accompanying disclosure**, to be written into the hook's `.NOTES`, the helpers file
header, and the new `orchestrator-state.md` section, following the templates at
`pr-author.md:79-88` and `enforce-epic-worktree-removal-gate.ps1:38-46`:

> The authorization record is a policy-level, auditable declaration, not a cryptographic or security
> control. It names a specific pull request, a specific session, an authorizer, a time, and a stated
> basis, so that a standalone merge leaves a reviewable trail and cannot be reached by accident or by
> a record written for a different pull request. It is not tamper-proof: any actor able to write
> `artifacts/orchestration/*.json` in the authorizing session can write a record, because all agents
> share one filesystem and the runtime exposes no attested agent identity at Bash PreToolUse time.
> The mechanism converts an untraceable bypass into a deliberate, attributable, auditable act.

Note the last sentence is the honest claim. The `pr_number` matcher is untouched; branch 4 is a
**disjunct added after** branches 1-3 and reads a different key, so it cannot widen what branches 1-3
authorize — the same structural argument the worktree-removal gate makes for its own second branch
(`enforce-epic-worktree-removal-gate.ps1:30-33`).

---

## R8 — Reason codes

### R8.1 Existing inventory

| Runtime | Site | Token | Full text |
| --- | --- | --- | --- |
| Claude | `enforce-epic-merge-gate.ps1:382` | `EPIC_MERGE_GATE_BLOCKED` | `'EPIC_MERGE_GATE_BLOCKED: payload anomaly - ' + <anomaly reason> + '. The gate fails closed on an envelope it cannot read.'` |
| Claude | `enforce-epic-merge-gate.ps1:433` | `EPIC_MERGE_GATE_BLOCKED` | `EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.` |
| Codex | `enforce-epic-merge-gate.ps1:22` | `EPIC_MERGE_GATE_BLOCKED` (throw ⇒ exit 2) | `EPIC_MERGE_GATE_BLOCKED: $Name is empty.` |
| Codex | `enforce-epic-merge-gate.ps1:30` | `EPIC_MERGE_GATE_BLOCKED` (throw ⇒ exit 2) | `EPIC_MERGE_GATE_BLOCKED: $Name is malformed JSON: $_` |
| Codex | `enforce-epic-merge-gate.ps1:162` | `EPIC_MERGE_GATE_BLOCKED` | `EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.` |

Only **one** distinct token exists across both runtimes today. The epic NFR
(`epic.md:13`) requires "a distinct, greppable reason code" per denial, so the new denials must not
reuse it.

### R8.2 Proposed new codes

Declared once each as script-scoped constants in the helpers file, per the
`enforce-parallel-abandon-gate.ps1:38-45` precedent.

| Code | Fires when | Notes |
| --- | --- | --- |
| `STANDALONE_MERGE_AUTHORIZATION_ABSENT` | The command is in scope, branches 1-3 all denied, and no checkpoint carries the `standalone_merge_authorizations` key at all. | **Replaces** the current line-433 text for this case only, or is appended to it. Must clearly tell the operator the authorized path exists and how to take it — the operator-facing purpose the current text lacks. |
| `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH` | The key is present with >= 1 well-formed entry, but no entry's `pr_number` equals the command's extracted number. | The R5.3 analogue case. **Distinct from ABSENT on purpose:** "you have records but not for this PR" is a different operator situation from "you have none". |
| `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` | The key is present but the value is not an array, or the matched entry fails a field-shape check (`authorized_at` unparseable, `pr_url` not ending `/pull/<pr_number>`, `basis` empty/too short, `authorized_by` empty, `session_id` mismatched). | Should name the failing field in the message, following the receipt-verification message style (`enforce-pr-author-skill-helpers.ps1:98`). Consider a `STANDALONE_MERGE_AUTHORIZATION_SESSION_MISMATCH` sub-code if the session cross-check proves to be the common operator error in practice. |
| `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC` | The key is present and an entry exists, but it names no specific PR — `pr_number` absent, `null`, `0`, negative, non-integer, a list, or a wildcard string; or the block is a bare boolean/blanket flag rather than an array of records. | **This is the code that makes the "blanket flag is not an authorization record" ruling executable.** Without it, a blanket flag would merely fall through to ABSENT and the rejection would be invisible in the transcript. |

A fifth denial is **not** a new code: a bare `gh pr merge --merge` with no explicit PR number can never
match a PR-specific record, so it must continue to deny with the existing
`EPIC_MERGE_GATE_BLOCKED` line-433 text (or `..._PR_MISMATCH`). Pick one and pin it with a named test;
do not leave it implicit.

Both runtimes must spell all four identically (R2.5). A producer/consumer token-seam test in the style
of `test_parallel_abandon_token_seam.py` is worth considering if the codes end up duplicated across
the Claude helpers file and the Codex hook.

---

## R9 — PowerShell quality toolchain

### R9.1 Coverage configuration — an explicit per-file allow-list

**`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`** is the file. `CodeCoverage` block at
lines 17-286:

```
line 17: CodeCoverage = @{
line 18:     Enabled               = $true
line 21:     OutputFormat          = 'CoverageGutters'
line 22:     OutputPath            = 'artifacts/pester/powershell-coverage.xml'
line 23:     Path                  = @(
...
line 44:         '.claude/hooks/enforce-epic-merge-gate.ps1'
...
line 239:        '.claude/hooks/enforce-pr-author-skill-helpers.ps1'
...
line 280:        '.codex/hooks/enforce-epic-merge-gate.ps1'
line 283:     )
line 285:     CoveragePercentTarget = 0
```

**A new helpers file is NOT picked up automatically.** The file's own comments say so repeatedly, e.g.
lines 246-249:

```
            # file, because the parent stood one line under the 500-line cap. CodeCoverage.Path
```

and lines 241-245:

```
            # missed-npm-publish defence). CodeCoverage.Path is an explicit per-file
            # allow-list, so the new production file is registered here; without it the file
            # would sit outside the coverage denominator, which the Coverage Exclusion Policy
            # forbids.
```

**F3 must add `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` to `CodeCoverage.Path`.**
Omitting it is a Coverage Exclusion Policy violation (`.claude/rules/general-unit-test.md`, "No
production file may be excluded from coverage measurement") that a feature-review agent is instructed
to treat as Blocking. `CoveragePercentTarget = 0` (line 285) means Pester will not fail the run on the
percentage; the 85%/75% thresholds are enforced by review, so the plan needs an explicit
coverage-comparison evidence task.

### R9.2 Test discovery

`config/poshqc-scan.json` (the whole file):

```json
{
  "version": 1,
  "test": {
    "scanFolders": ["scripts", "tests/powershell", "tests/scripts"]
  }
}
```

Matching `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` at
`pester.runsettings.psd1:3`. **A new test file anywhere under `tests/scripts/` is discovered
automatically; no config entry is needed for the test.** Only the production file needs a coverage
entry.

### R9.3 Other PowerShell gates F3 must satisfy

- **Test purity** (`check-powershell-test-purity.ps1`, PreToolUse on Write|Edit): no
  `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `$env:TMP`, `Invoke-WebRequest`,
  `Invoke-RestMethod`, `System.Net.*`, `Start-Process`, `Start-Sleep`, `Mock git`, `Mock gh`,
  `Mock actionlint` (lines 100-116).
- **No-Python guard** (R6.4): applies to `.claude/hooks/**` and `.claude/lib/**`; allowlist asserted
  empty.
- **Line cap**: enforced by test only for `.codex/**`
  (`codex-epic-runtime-contracts.Tests.ps1:172-183`,
  `legacy-codex-hook-contracts.Tests.ps1:106`). **Negative result for `.claude/hooks/**`:** a grep of
  `tests/` for `BeLessOrEqual 500`, `<= 500`, and `500-line` (case-insensitive) returned 40 matches,
  all of which are either prose comments explaining a file split or the two `.codex`-scoped
  assertions above; a targeted grep of `tests/scripts/claude-runtime/` for `500` returned no matches.
  **No automated test enforces the 500-line cap on `.claude/hooks/**` in this tree.** The cap is
  therefore a policy obligation for F3, verified by review, not a gate.

---

## R10 — `--squash`

### R10.1 What the hooks actually do — **`--squash` is out of scope and is ALLOWED, not denied**

This corrects the framing in the delegation prompt. Neither hook denies `--squash`; neither hook
mentions the string at all.

- **Claude.** The scope filter (lines 401-414) requires **both** a structural `gh pr merge` invocation
  **and** the `--merge` flag. A command carrying `--squash` and not `--merge` fails
  `$hasMergeFlag` and returns `Get-EpicMergeGateAllowDecision` at line 413. Pinned by test
  `enforce-epic-merge-gate.Tests.ps1:27-31`:

  ```powershell
  It 'allows gh pr merge without --merge (e.g., --squash)' {
      $json = '{"tool_input":{"command":"gh pr merge 10 --squash"}}'
      $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
      $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
  }
  ```

- **Codex.** Identical structure at `.codex/hooks/enforce-epic-merge-gate.ps1:133-146`; out of scope
  returns `$null` (allow).

- `Get-CommandLineFlagValue` correctly returns null for `gh pr merge --merge --squash` because the
  token after `--merge` is dash-leading (`hook-command-invocation.Tests.ps1:152-155`, both runtimes).

### R10.2 Is `--squash` denied anywhere else in the repository?

**No.** Search scope and patterns, so the negative is auditable:

| Search | Scope | Result |
| --- | --- | --- |
| `--squash` (content, all files) | repository root, all file types | 22 matches: 4 in feature/epic docs, 10 in archived JUnit/evidence artifacts and research docs, 6 in tests (the two allow-tests and the two flag-value tests plus `enforce-pr-author-skill.Tests.ps1:179` `It 'allows gh pr merge'`). **Zero in any production `.ps1`, `.sh`, `.py`, or `.ts` enforcement path.** |
| `squash` (case-insensitive) | `.claude/**` | **No matches found.** |
| `squash` (case-insensitive) | `.github/**` | **No matches found.** |
| `pr merge` / `merge` | `.claude/hooks/validate-bash.ps1` | **No matches found.** |

The only repository-level statement that `--squash` is disallowed is prose in the epic itself
(`epic.md:148`: "This is disallowed repo-wide") and the corroborating research note
`docs/features/active/2026-09-06-.../research/...:924` ("merge issued with `--squash` or `--rebase` is
outside this gate entirely and is allowed today").

### R10.3 Consequence for F3

Three statements, in decreasing order of confidence:

1. **The authorization record must not create a `--squash` bypass, and by construction it cannot.**
   Branch 4 is evaluated *after* the scope filter, inside the block that only in-scope commands reach.
   A `--squash` command never reaches any branch. The regression guard is the existing test at
   `enforce-epic-merge-gate.Tests.ps1:27`, which must stay green and must **not** be edited.
2. **F3 must add a paired case**: a valid authorization record present **plus** `gh pr merge <N>
   --squash` ⇒ still allow (out of scope), so that the record demonstrably does not change scope. This
   is a new test, because no existing case combines a populated checkpoint with `--squash`.
3. **The prompt's premise — "`--squash` must remain denied in every configuration" — is not the
   current behaviour and cannot be asserted as an acceptance criterion without changing the gate's
   scope**, which is out of RULING 1's remit and would be a new behavioural change with its own
   blast radius. **Recommend surfacing this to the user as a separate finding.** If the user wants
   `--squash` denied, that is a distinct feature: it would widen the gate's trigger surface, and every
   currently-allowed `--squash` call in every topology would begin to deny.

---

## Numeric Derivation Evidence

Required before any numeric or enumerative claim is proposed for an approved `spec.md` acceptance
criterion. Three numeric claims below are load-bearing for the spec.

### Claim N1 — Exactly four production trees carry a copy of `enforce-epic-merge-gate.ps1`

- **Complete Family:** every file in the repository whose basename matches `enforce-epic-merge-gate*.ps1`, partitioned into production copies and test files.
- **Exhaustive Search Scope:** the entire worktree, all directories, all `.ps1` files, no path filter. Both the canonical and bundled trees for both runtimes are inside this scope, as are `tests/`.
- **Inclusion Rules:** a file is a production copy when its path is under `.claude/hooks/`, `.codex/hooks/`, or either `extensions/drm-copilot/resources/*-customizations/` payload tree.
- **Exclusion Rules:** files under `tests/` are test files, not production copies. Files whose basename carries a `.Tests.` or `-decision-surface`/`-trigger-scoping` component are test files.
- **Primary Search Strategy or Query Expression:** `Glob('**/enforce-epic-merge-gate*.ps1')` — a basename-prefix glob over the whole tree, which matches every naming variant including any hypothetical `-helpers` sibling.
- **Primary Member Set (8 results, partitioned):**
  - Production (4): `.claude/hooks/enforce-epic-merge-gate.ps1`; `.codex/hooks/enforce-epic-merge-gate.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
  - Test (4): `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`
- **Primary Count:** 4 production, 4 test.
- **Cross-check Search Strategy or Query Expression:** a different strategy — a **path-anchored glob over only the extension resources tree**, `Glob('extensions/drm-copilot/resources/**/enforce-epic-merge-gate.ps1')`, combined with **direct `Read` of the two canonical paths** (a file-open, not a search). This exercises a different mechanism (path anchoring plus direct file access) than the basename glob.
- **Cross-check Member Set:** resources glob returns exactly 2 — `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`. Direct `Read` succeeded on `.claude/hooks/enforce-epic-merge-gate.ps1` (487 lines returned) and `.codex/hooks/enforce-epic-merge-gate.ps1` (187 lines returned), confirming both exist as real files. Union = 4.
- **Cross-check Count:** 4.
- **Member-set Comparison:** normalized to forward-slash repo-relative paths, the primary production set and the cross-check union are **identical, element for element**, with no member in one and not the other. Claim N1 stands.

### Claim N2 — The Claude hook emits exactly two distinct deny-reason strings today

- **Complete Family:** every expression in `.claude/hooks/enforce-epic-merge-gate.ps1` that produces a `permissionDecisionReason` value reaching the emitted decision. This is the complete family because `Get-EpicMergeGateBlockDecision` (line 340) is the sole constructor of a deny envelope in the file — there is no second deny path, no `throw`, and no direct literal construction of `permissionDecision = 'deny'` elsewhere.
- **Exhaustive Search Scope:** all 487 lines of the file, read end to end, including comment blocks (so a documentation-only mention is identified and excluded rather than silently counted).
- **Inclusion Rules:** an expression counts when it is an argument to `Get-EpicMergeGateBlockDecision -Reason`.
- **Exclusion Rules:** occurrences of the token inside `<# ... #>` comment blocks are documentation, not emissions.
- **Primary Search Strategy or Query Expression:** **full sequential file read** (`Read` of lines 1-487) and manual identification of every `Get-EpicMergeGateBlockDecision` call site. This strategy cannot miss a call site that uses a variable or a concatenation rather than a literal token.
- **Primary Member Set:** line 381-384 (`return Get-EpicMergeGateBlockDecision -Reason ('EPIC_MERGE_GATE_BLOCKED: payload anomaly - ' + ... )`) and line 433 (`return Get-EpicMergeGateBlockDecision -Reason 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either ...'`).
- **Primary Count:** 2.
- **Cross-check Search Strategy or Query Expression:** a different strategy — **token grep** `Grep(pattern='EPIC_MERGE_GATE_BLOCKED', path=<the hook>, output_mode='content', -n=true)`. This is a text search, not a structural read, and it also surfaces non-emitting occurrences so the exclusion rule can be applied visibly.
- **Cross-check Member Set:** three hits — line 23 (inside the `<# .DESCRIPTION #>` block: "Otherwise the command is denied with reason EPIC_MERGE_GATE_BLOCKED"), line 382, line 433. Applying the exclusion rule removes line 23.
- **Cross-check Count:** 3 raw, **2 after the documented exclusion**.
- **Member-set Comparison:** the primary set `{382, 433}` and the cross-check set after exclusion `{382, 433}` are **identical**. The cross-check's extra raw hit is accounted for by a stated exclusion rule, not discarded silently. Claim N2 stands at 2.

### Claim N3 — The Codex hook carries exactly three `EPIC_MERGE_GATE_BLOCKED` sites: one deny reason and two throws

- **Complete Family:** every expression in `.codex/hooks/enforce-epic-merge-gate.ps1` that terminates the command with a blocking outcome, comprising both channels the file has — the emitted `permissionDecisionReason` and the `throw` path that reaches the entry-point `catch` and `exit 2`. Both channels are included because a `throw` in this file is observably a denial from the operator's point of view, and counting only the emitted reason would understate the family.
- **Exhaustive Search Scope:** all 187 lines, read end to end, plus the entry-point `try/catch` at lines 171-186 to confirm where each `throw` lands.
- **Inclusion Rules:** a `throw` whose message carries the token; a `permissionDecisionReason` assignment.
- **Exclusion Rules:** comment-block mentions (there are none in this file).
- **Primary Search Strategy or Query Expression:** **full sequential file read** (`Read` of lines 1-187), identifying `ConvertFrom-CodexMergeJson`'s two `throw` statements and the single decision object returned by `Invoke-CodexEpicMergeDecision`.
- **Primary Member Set:** line 22 (`throw "EPIC_MERGE_GATE_BLOCKED: $Name is empty."`), line 30 (`throw "EPIC_MERGE_GATE_BLOCKED: $Name is malformed JSON: $_"`), line 162 (`permissionDecisionReason = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'`).
- **Primary Count:** 3 (2 throws + 1 deny reason).
- **Cross-check Search Strategy or Query Expression:** a different strategy — **multi-alternative token grep** `Grep(pattern='EPIC_MERGE_GATE_BLOCKED|Get-EpicMergeGateBlockDecision|throw ', path=<the codex hook>)`. The alternation deliberately includes the Claude-side constructor name and a bare `throw ` so the search would also surface (a) any blocking site that omits the token and (b) any accidental use of the Claude constructor, either of which would mean the family was drawn too narrowly.
- **Cross-check Member Set:** lines 22, 30, 162. No `Get-EpicMergeGateBlockDecision` occurrence (confirming the two runtimes do not share a constructor) and no additional bare `throw ` beyond the two already in the set (confirming no tokenless blocking site exists).
- **Cross-check Count:** 3.
- **Member-set Comparison:** `{22, 30, 162}` from the sequential read and `{22, 30, 162}` from the alternation grep are **identical**, and the alternation's two extra probes each returned empty, confirming the family boundary. Claim N3 stands at 3.

---

## Behaviour Semantics — the branch-4 decision table

Ordering is load-bearing: branch 4 is evaluated **last**, after branches 1, 2, and 3 have each
declined. This preserves every existing allow exactly (a checkpoint that satisfies branch 1-3 never
reaches branch 4) and means branch 4 can only convert a current **deny** into an **allow**, never the
reverse.

| # | Command | Checkpoint state | Expected | Reason code |
| --- | --- | --- | --- | --- |
| 1 | `gh pr merge 691 --merge` | record naming 691, well-formed, session matches | **allow** | — |
| 2 | `gh pr merge 691 --merge` | record naming 777, well-formed | **deny** | `..._PR_MISMATCH` |
| 3 | `gh pr merge 691 --merge` | no `standalone_merge_authorizations` key anywhere | **deny** | `..._ABSENT` |
| 4 | `gh pr merge 691 --merge` | key present, value is `true` (blanket flag) | **deny** | `..._NOT_PR_SPECIFIC` |
| 5 | `gh pr merge 691 --merge` | record present, `pr_number` absent / `null` / `0` / `"*"` / a list | **deny** | `..._NOT_PR_SPECIFIC` |
| 6 | `gh pr merge 691 --merge` | record naming 691, `authorized_at` unparseable | **deny** | `..._MALFORMED` |
| 7 | `gh pr merge 691 --merge` | record naming 691, `basis` empty or whitespace | **deny** | `..._MALFORMED` |
| 8 | `gh pr merge 691 --merge` | record naming 691, `pr_url` ends `/pull/777` | **deny** | `..._MALFORMED` |
| 9 | `gh pr merge 691 --merge` | record naming 691, `session_id` differs from the envelope's | **deny** | `..._MALFORMED` (or a `..._SESSION_MISMATCH` sub-code) |
| 10 | `gh pr merge --merge` (bare) | record naming 691, well-formed | **deny** | existing `EPIC_MERGE_GATE_BLOCKED` — a PR-specific record cannot match a command naming no PR |
| 11 | `gh pr merge 691 --squash` | record naming 691, well-formed | **allow** | out of scope; **regression guard**, R10.3 |
| 12 | `gh pr merge 691 --merge` | checkpoint is malformed JSON | **deny** | existing `EPIC_MERGE_GATE_BLOCKED` (`ConvertFrom-EpicMergeGateJson` returns `$null`) |
| 13 | `cd /repo/worktrees/691 && gh pr merge --merge 777` | record naming 691 only | **deny** | `..._PR_MISMATCH` — the R5.3 analogue; extractor must return 777 |
| 14 | `gh pr merge 501 --merge` | branch-3 parallel checkpoint with item 501 `ci_green`, **and no** standalone key | **allow** | — **regression guard**, branch 3 unchanged |
| 15 | `gh pr merge --merge` | branch-1 child checkpoint `epic_mode: true`, `step9_status: passed` | **allow** | — **regression guard**, branch 1 unchanged |
| 16 | `printf '%s\n' "run gh pr merge --merge 688 ..."` | any | **allow** | out of scope; **regression guard** |

Case 13 is the mandatory non-tautological discriminator (R5.3). Case 14 and 15 are the must-not-widen
guards. Case 11 is the `--squash` guard from R10.3.

---

## Testing Implications (strategy only; no test code)

1. **New suite, not an extension.** `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` is
   at 455 of 500 lines. Add `enforce-epic-merge-gate.Authorization.Tests.ps1` in the same directory,
   following the naming precedent of `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`.
   Codex: add `enforce-epic-merge-gate-authorization.Tests.ps1` under `tests/scripts/codex-hooks/`
   (`legacy-codex-hook-contracts.Tests.ps1` is at 494 lines and is stated to be full at its own
   line 23-24).
2. **Load pattern:** dot-source both the hook and the new helpers file in `BeforeAll`, with the
   "deliberately redundant, idempotent" comment the existing suites carry.
3. **Table-driven `-ForEach`** over the sixteen rows above, in the style of
   `codex-epic-runtime-contracts.Tests.ps1:85-88`. Each row supplies the command text, a checkpoint
   JSON literal, the expected decision, and the expected reason token.
4. **Determinism block in the file header**, mirroring
   `enforce-epic-merge-gate.TriggerScoping.Tests.ps1:14-20`: every case drives the pure seam, every
   case mocks every checkpoint read seam, no case writes to disk, no case starts a process.
5. **Direct predicate coverage** for the new helpers' functions, parsing checkpoint literals with
   `ConvertFrom-Json` and calling the predicate by name — the existing pattern at Tests:245-289.
   This is what makes the 85%/75% thresholds reachable on a new file.
6. **Session-id seam.** If design (ii) is adopted, the `session_id` must be read from
   `$payload.Envelope`, and the test envelopes must carry a `session_id`. An existing test already
   supplies one (`Tests:406`), so the shape is established. **No temp file and no new seam are needed
   for the envelope leg.** If a disk leg against `.claude/state/current-session-id` is also wanted, it
   needs a fourth read seam and a `-ParameterFilter` mock in the Tests:232-243 style.
7. **Coverage evidence.** Because `CoveragePercentTarget = 0`, the plan must contain explicit
   baseline / post-change / comparison artifact tasks under
   `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/` per the
   evidence-and-timestamp conventions, with the new helpers file registered in `CodeCoverage.Path`
   before the baseline is taken (otherwise the baseline measures nothing for it).
8. **Python validator tests.** If the R6 validator is added:
   `tests/scripts/dev_tools/test_validate_orchestrator_state_standalone_merge.py`, asserting (a) a
   checkpoint omitting the key produces byte-identical output to before, and (b) one error per
   violated invariant. The back-compat assertion is the convention — see
   `test_validate_orchestrator_state_model_routing_backcompat.py`.
9. **Do not edit** any test listed in R5.4. Each is a regression guard; a change to one is a signal
   that the fix widened something.

---

## Open Questions for the Spec Author

1. **`--squash`.** The prompt asserts it "must remain denied in every configuration"; it is currently
   **allowed** (out of scope) on both runtimes and pinned that way by a passing test. Confirm whether
   the acceptance criterion should be "remains out of scope and allowed, and the record creates no
   new path to it" (what the code does and what F3 can deliver) or whether denying `--squash` is a
   separate wanted change. **Recommend the former; the latter is a new feature.**
2. **`agent_type` at Bash PreToolUse.** `enforce-epic-invocation-origin.ps1:18-20` and
   `pr-author.md:85` disagree about whether an agent-identity signal exists. Resolving it empirically
   would strengthen the `authorized_by` field from a declaration to an attestation. Not required for
   the recommended design; worth a bounded spike.
3. **Which checkpoints carry the block.** Recommended: all three already-read checkpoints, key-gated.
   Confirm whether the epic and per-feature checkpoints should also honour it, or only the parallel
   one. Scoping it to the parallel checkpoint alone is narrower but would leave an epic run with the
   same unlandable-fix problem.
4. **Claude-side checkpoint path anchoring (R1.7).** The Claude hook resolves checkpoint paths against
   the process cwd; the Codex mirror anchors to the repo root. This is squarely within the epic's
   defect class but outside F3's ruling. Recommend filing as a follow-up rather than absorbing it.
5. **Writer surface.** The record has to be produced by something. `.claude/skills/parallel-orchestrate/SKILL.md:327-334`
   already documents the merge-gate contract for the parallel surface and is the natural place to
   document how a coordinating session writes an authorization record. That edit is inside `.claude/**`
   and therefore carries the bundle-mirror obligation (R4.2).
