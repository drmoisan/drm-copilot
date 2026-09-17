# 2026-09-13-preimplementation-gate-worktree-selector (Remediation Plan R1)

- **Issue:** #671
- **Parent:** epic `worktree-scoped-state-resolution`, feature F2
- **Owner:** drmoisan
- **Last Updated:** 2026-09-17T08-44
- **Status:** Draft
- **Version:** 0.1
- **Work Mode:** full-bug
- **Remediation cycle:** R1 (remediation planning)
- **Branch:** `feature/2026-09-13-preimplementation-gate-worktree-selector-671`, base `epic/worktree-scoped-state-resolution-integration`, merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`
- **Requirements source:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, amended by Phase 1 of this plan. `user-story.md` is correctly absent for a `full-bug` plan and must not be created.
- **Remediation inputs:** `remediation-inputs.2026-09-17T08-40.md` (RF-1, RF-2, RF-3 blocking; RF-4, RF-5 required; RF-6, RF-7 non-blocking), with `code-review.2026-09-17T08-40.md`, `policy-audit.2026-09-17T08-40.md`, and `feature-audit.2026-09-17T08-40.md`, all in the feature folder.
- **Prior plan (state record, not re-executed):** `plan.2026-09-13T20-46.md`, 42 of 52 tasks checked.

**Fail-closed evidence rule:** every task below names its artifact path. A missing artifact, or an artifact missing a required field, makes the task INCOMPLETE, never PASS. Do not check a task box without its artifact on disk.

**Evidence location (non-overridable):** every artifact resolves under
`docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/<kind>/`, where `<kind>` is one of `remediation-baseline`, `regression-testing`, `qa-gates`, `issue-updates`, or `other`. Below, `<EVID>` abbreviates `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence`. Paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/` are forbidden for evidence output. `artifacts/pester/` is the Pester runner's own report location; it is read, never used as an evidence location.

**Filename timestamps** are fixed by this plan so every acceptance condition names one path. The `Timestamp:` field inside each artifact records the actual execution time.

---

## Scope of this remediation

Required outcomes, mapped to the inputs:

1. **RF-1.** Close the pre-existing empty-token fail-open. `Test-ExemptOrchestrationSegmentToken` declares `$Token` without `[AllowEmptyString()]` (current `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` line 296; pre-change line 221 at the merge base, which is the coordinate the caller cited). A `""` token fails parameter binding, the call at current line 428 is skipped under the default `Continue` preference, and `Test-ExemptOrchestrationStagingCommand` reaches `return $true` at line 432. The fix adds `[AllowEmptyString()]` to that parameter and wraps the per-segment loop (current lines 426–431) in a fail-closed `try`/`catch`. Spec amendment first (Phase 1).
2. **RF-2.** Replace the L3a and L3b fixture commands with commands the gate's staging trigger classifies, and that reach the L3 rejection at current helpers lines 252–254.
3. **RF-3.** Restore `.claude/hooks` helpers per-file line coverage to at least the baseline 112/118 (94.92%), and cover the L3 lines (current 253, 254), the L8 lines (current 258, 259), and the subcommand rejection (current 319).
4. **RF-4.** Close the PoshQC loop (format, analyze, test) in one clean pass. The only failing Pester nodes permitted are the two baseline failures named in `<EVID>/baseline/poshqc-test-coverage.2026-09-13T22-40.md` lines 20–21.
5. **RF-5.** Re-verify hash parity, the line cap, diff confinement, purity literals, and the 20-row reproduction.
6. **RF-6 (cheap part only).** Add unit-level rows that call `Test-ExemptOrchestrationSelector` directly, add one node that pins the fail-closed guard, and state in the predicate's comment-based help that the caller checks subcommand identity. The alternative, checking `add`/`commit` inside the predicate, is rejected: it would make the subcommand rejection at current line 319 unreachable again, which contradicts RF-3.
7. **RF-7.** Reconcile the prior plan's and the spec's checkboxes with the evidence.

### Binding constraints

- Do not weaken the pathspec, option, or metacharacter restrictions. The spec amendment in Phase 1 only narrows what the gate allows.
- Do not edit the four `enforce-orchestration-preimplementation-gate.ps1` gate files (the two Codex copies are at exactly 500 lines), the four `-modes.ps1` files, any `hook-command-invocation.ps1` copy, or `.claude/hooks/enforce-epic-merge-gate.ps1`.
- The helpers files are 433 lines each today. After this plan they are **441** lines each (433 + 2 help lines + 6 guard lines). The cap is 500.
- No Python leg, no new production file, no `Import-Module`, and no disk, process, network, or environment access in the helpers module. The purity literals `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, `env:`, and `Import-Module` must not appear in any helpers copy, including in comments.
- Do not delete, reverse, or weaken any pre-existing D4 row or allow row, and do not change the label of any existing `issue #671` row. Only the `Command` values of L3a and L3b change.
- Tests assert decisions and booleans only, never `Write-Debug` text. Probe scripts in the scratchpad may read debug records, because they are evidence, not tests.
- No runsettings `exclude` entry, no lowered threshold, and no temporary files in tests.
- Out of scope, unchanged: the F1 upstream closure, `SharedModuleNames` for the modes file, and the `PARALLEL_WORKTREE_REMOVAL_BLOCKED` misclassification. Because of that misclassification, which `<EVID>/other/git-attached-selector-probe.2026-09-13T22-40.md` line 8 records, no Bash-tool git command in this plan uses a `-C` option.

### Static verification of the replacement fixtures (planner re-derivation, to be confirmed by the executed probe in [P0-T9])

The gate classifies a Bash command as staging when either leg fires (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 133, 139–143; the Codex copy at lines 151, 158–161). Leg 1 is the regex `(^|\s)git\s+(add|commit)\b` applied to per-segment scan text. Leg 2 is `Test-CommandLineInvocation`, which skips the modelled git global options before it looks for the subcommand (`.claude/hooks/hook-command-invocation.ps1` lines 32–35 and 207–234; `-C` takes an argument, and `--no-pager` stands alone). Only a staging-classified command reaches `Test-ExemptOrchestrationStagingCommand` (gate line 151).

| Fixture | Trigger leg | Exemption path (current helpers lines) | Gate decision |
| --- | --- | --- | --- |
| L3a `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` | leg 1 on segment 2; leg 2 on segment 2 | segment 1 tokens `git`,`-C`,`C:/repo/wt`; 309 → 310 → 244 passes, 248 passes, 252 true (`Count -lt 4`) → 253–254 | deny |
| L3b `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` | leg 2 (`-C` skips 2 tokens, `--no-pager` skips 1, then `add`) | `$Token[3]` is `--no-pager` → 252 true → 253–254 | deny |
| RF-3 `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` | leg 1 and leg 2 on segment 2 | segment 1 accepted by the predicate (278), absorbed at 315, `$subcommand` is `status` → 318–319 | deny |
| Former L3a `git -C C:/repo/wt` and former L3b `git -C C:/repo/wt -- docs/features/active/x/spec.md` | neither leg | exemption never consulted | allow, which is why both rows fail today |

The shared scanner emits an empty token for `""` (`.claude/hooks/hook-command-scanner.ps1` lines 77–80 and 83–88), so leg 2 also fires for `git -C "" add ...`. After RF-1 that row reaches the L8 rejection at helpers lines 257–259. An empty operand reaches `Test-ExemptOrchestrationOperand`, where lines 179–180 return false.

If [P0-T9] contradicts any row of this table, stop before Phase 1 and report `PLAN REVISION REQUIRED` with the observed values. Do not substitute other fixtures.

---

## Execution environment and routing

- **PowerShell route.** The executor has no PowerShell tool. Each direct PowerShell step is a script written to the session scratchpad and run with `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/<script>.ps1`, where `<scratchpad>` is the session scratchpad directory `C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-09-13T08-30/edea1a9d-6671-4ea6-8e13-6405d6284a83/scratchpad`. Before [P0-T1], write `<scratchpad>/f671-r1/run.sh` containing exactly three lines: `cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686 || exit 9`, `pwsh -NoProfile -NonInteractive -File "$1"`, and `echo "EXIT_CODE: $?"`. Place every scratchpad script in `<scratchpad>/f671-r1/`. Do not use any other `run.sh`. Because `run.sh` changes directory before it starts `pwsh`, always pass the script as an absolute path; relative paths inside the script then resolve against the worktree root. Scratchpad scripts resolve outside the worktree, so they consume no batch-budget slot (`.claude/hooks/enforce-powershell-batch-budget.ps1` lines 24–25). Every `Select-String`, `Get-FileHash`, `Get-Content`, `Get-ChildItem`, `Get-Item`, `Copy-Item`, and `[xml]` read in this plan runs inside such a script.
- **Git route.** Issue each read-only git command through the Bash tool as one plain command from the worktree root, with no `cd`, no chaining, no pipe, and no `-C` option. Exception: the `git show`, `git rev-parse`, and `git merge-base` calls that [P0-T4] runs inside its scratchpad script.
- **MCP route.** Use `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, each with the worktree root as the workspace root.
- **Live-hook note.** `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` is the live helpers file for this session's own gate. Phase 2 edits it with three exact replacements. Tree readiness for implementation writes is the orchestrator's checkpoint responsibility and is outside this plan.

## Governing derivations (EA-4, binding)

**D1 — MCP results carry no script output.** The PoshQC MCP tools return a fixed summary and no captured stdout. The `EXIT_CODE:` recorded for an MCP call is its disposition: `0` when it returned `ok: true`, and otherwise the code in its "Command exited with code N." summary. No count, finding, node result, or percentage in this plan is read from an MCP result.

**D2 — Test totals and node results** come from `artifacts/pester/pester-junit.xml` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 14–15), loaded with `[xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')`.
- *Totals:* the root `testsuites` attributes `tests`, `failures`, `errors`, and `disabled`.
- *Per-suite totals:* the `testsuite` element whose `name`, with `\` normalized to `/`, ends with the suite's repository-relative path.
- *Node selection:* select every `testcase` whose `classname`, normalized the same way, ends with the suite's repository-relative path **and** whose `name` ends with `.` followed by the asserted `It` text. Pester emits one `testcase` per `-ForEach` row, with the `<Label>` template expanded.
- *Node result:* a node is PASSED only when exactly one `testcase` matches and its `status` is `Passed`. Zero matches and multiple matches are both failures.
- *Suite checks:* `<testsuite errors="0">` alone verifies nothing. Every suite-level claim also asserts `tests` equal to a stated number and `failures="0"`.

**D3 — Analyzer findings** come from a direct call per path: `Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information`, recording `@($findings).Count`. `Invoke-PoshQCAnalyze` returns nothing and throws on any finding (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 181–183). A zero-finding MCP call is therefore anchored to the zero branch at line 185, whose literal is `PSScriptAnalyzer passed: no findings under`: an MCP call that returns `ok: true` reached that branch.

**D4 — Coverage** comes from `artifacts/pester/powershell-coverage.xml` (runsettings lines 21–22, JaCoCo-shaped).
- *Repository-wide:* the report-level `counter type="LINE"`; percentage = `covered / (covered + missed)`.
- *Per-file:* select the `sourcefile` named `enforce-orchestration-preimplementation-gate-helpers.ps1` whose parent `package` `name`, normalized to `/`, ends with `/.claude/hooks` and does not contain `/resources/`. Apply the same rule with `/.codex/hooks` for the Codex copy. Only these two copies are measured (runsettings lines 135 and 229).
- *Selection failures:* zero matches is `UNMEASURED — no sourcefile entry emitted`, and more than one match is `AMBIGUOUS`. Both make the owning task INCOMPLETE.
- *Hit count:* a line's hit count is the `ci` attribute of the `line` child whose `nr` equals the line number.
- `CoveragePercentTarget = 0` (runsettings line 285), so every threshold in this plan is an explicit numeric comparison.

**D5 — Post-change coordinates of the lines RF-3 names.** Line numbers move when Phase 2 inserts lines, so each asserted line is derived mechanically from the current file. Take the line number of the single line that contains the anchor literal, then add the offset. Expected values after Phase 2 are given for cross-checking, and a mismatch makes the owning task INCOMPLETE.

| Id | Anchor literal (exactly one matching line) | Offset | Pre-remediation line | Expected post-Phase-2 line |
| --- | --- | --- | --- | --- |
| K1 | `PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value.` | 0 | 253 | 255 |
| K2 | same as K1 | +1 | 254 | 256 |
| K3 | `PREIMPL_SELECTOR_MALFORMED: the selector value is empty.` | 0 | 258 | 260 |
| K4 | same as K3 | +1 | 259 | 261 |
| K5 | `if ($subcommand -cne 'add' -and $subcommand -cne 'commit') {` | +1 | 319 | 321 |
| K6 | `if (-not $Operand) {` | +1 | 180 | 180 |
| K7 | `} catch {` | +1 | absent | 438 |

**D6 — Write-mode formatter observation.** `mcp__drm-copilot__run_poshqc_format` rewrites files and still returns the same disposition. Its acceptance is therefore always paired `(Get-FileHash -LiteralPath <path>).Hash` captures taken immediately before and after the call for the named files, plus paired `git status --porcelain` captures.

**D7 — Line counts** use `@(Get-Content -LiteralPath <path>).Count`.

**D8 — Batch budget.** The budget hook denies a fourth distinct production or test PowerShell file per session (`.claude/hooks/enforce-powershell-batch-budget.ps1` lines 284–293, caps at lines 316–317). This plan writes one production file with the Edit tool (the canonical helpers copy) and two test files. It produces the three helpers mirrors with `Copy-Item`, which consumes no slot. Resets are scheduled at [P0-T3], [P2-T7], and before each Python run.
- *Reset procedure:* delete every `.claude/state/powershell-batch-budget.*.json` file.
- *Reset check:* `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue` returns zero items.
- *Unscheduled resets:* repeat the reset whenever the hook denies an edit, and record it in `<EVID>/other/remediation-batch-budget-reset.2026-09-17T08-50.md`.

**D9 — Report freshness.** A report left over from an earlier run would satisfy D2 and D4 even if the MCP call wrote nothing. Every `mcp__drm-copilot__run_poshqc_test` call in this plan ([P0-T7], [P4-T1], [P6-T3]) is therefore bracketed by two scratchpad captures, taken immediately before and immediately after the call. Each capture records `(Get-Item -LiteralPath <p>).LastWriteTimeUtc` for `artifacts/pester/pester-junit.xml` and for `artifacts/pester/powershell-coverage.xml`, or the word `absent` when the file does not exist. The owning artifact records all four values. The freshness condition holds when each post-call value is a timestamp later than its pre-call value, or when the pre-call value is `absent` and the post-call value is a timestamp. Otherwise the owning task is INCOMPLETE.

---

## Verbatim edit payloads

Each payload is quoted exactly. Where a payload is a replacement, the old text is quoted first. Inside a fenced block, copy the text verbatim with its indentation.

### Payload S1 — spec L3a row (old, then new)

```
| `issue #671 LACS L3a - selector with no subcommand after the value` | `git -C C:/repo/wt` | deny |
```

```
| `issue #671 LACS L3a - selector with no subcommand after the value` | `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` | deny |
```

### Payload S2 — spec L3b row (old, then new)

```
| `issue #671 LACS L3b - subcommand not immediately after the selector value` | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | deny |
```

```
| `issue #671 LACS L3b - subcommand not immediately after the selector value` | `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` | deny |
```

### Payload S3 — spec deny-Context heading (old, then new) and the new row inserted immediately after the `issue #671 LACS L8 - empty selector value` row

```
Context `issue #671 worktree selector deny cases` — 17 rows, all NEW:
```

```
Context `issue #671 worktree selector deny cases` — 18 rows, all NEW (the row immediately after the L8 row was added by remediation R1):
```

```
| `issue #671 selector followed by an unmodelled subcommand` | `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` | deny |
```

### Payload S4 — spec text inserted immediately after the paragraph ending `and the row must isolate the selector axis.`

```

Every row in these tables must be classified by the gate's staging trigger, meaning it contains a
`git add` or `git commit` invocation, or the gate allows it without consulting the exemption and
the row cannot fail for the reason its label states. Remediation R1 replaced the original L3a and
L3b commands for that reason: neither carried a subcommand the trigger recognizes.

Context `issue #671 empty-token fail-closed cases` — 5 rows, all NEW (remediation R1):

| Label | Command | Expected |
| --- | --- | --- |
| `issue #671 empty commit message beside an exempt operand` | `git commit -m "" -- docs/features/active/x/spec.md` | allow |
| `issue #671 empty token beside a non-exempt operand` | `git add "" -- src/foo.ps1` | deny |
| `issue #671 empty token after the separator beside a non-exempt operand` | `git add -- "" scripts/powershell/Sample.ps1` | deny |
| `issue #671 trailing empty token after a non-exempt operand` | `git add -- src/foo.ts ""` | deny |
| `issue #671 empty commit message beside a non-exempt operand` | `git commit -m "" -- src/foo.ts` | deny |

Decision (remediation R1): an empty message value is consumed by `-m` and is not a pathspec, so
`git commit -m "" -- <exempt operand>` allows. That command already allowed before remediation R1,
through the empty-token fail-open, so its row pins an unchanged decision. The four deny rows pin
decisions that remediation R1 changes from allow to deny.

Context `issue #671 selector predicate and fail-closed guard` — 16 nodes, all NEW (remediation R1).
The accept and reject rows call `Test-ExemptOrchestrationSelector -Token` directly through
`It 'accepts <Label>'` and `It 'rejects <Label>'`. The guard node
`It 'returns false when segment classification raises an error'` mocks
`Test-ExemptOrchestrationSegmentToken` to throw and asserts that
`Test-ExemptOrchestrationStagingCommand` returns false. The predicate checks only that a
non-option token follows the selector value; the caller rejects any subcommand other than `add` or
`commit`, and accept row 3 pins that division.

| Label | Token array | Expected |
| --- | --- | --- |
| `issue #671 predicate accept 1 - drive-letter selector followed by add` | `git`, `-C`, `C:/repo/wt`, `add`, `--`, `docs/features/active/x/spec.md` | true |
| `issue #671 predicate accept 2 - rooted selector followed by commit` | `git`, `-C`, `/repo/wt`, `commit`, `-m`, `msg`, `--`, `docs/features/active/x/spec.md` | true |
| `issue #671 predicate accept 3 - non-option token after the value is left to the caller` | `git`, `-C`, `C:/repo/wt`, `status` | true |
| `issue #671 predicate L1a - single token segment` | `git` | false |
| `issue #671 predicate L1b - option other than the selector at index 1` | `git`, `-c`, `core.worktree=C:/repo/wt`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L2 - repeated selector` | `git`, `-C`, `C:/repo/wt`, `-C`, `C:/repo/other`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L3a - no token after the selector value` | `git`, `-C`, `C:/repo/wt` | false |
| `issue #671 predicate L3b - option token after the selector value` | `git`, `-C`, `C:/repo/wt`, `--no-pager`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L4a - relative selector` | `git`, `-C`, `subdir`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L4b - UNC selector` | `git`, `-C`, `//server/share/wt`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L5a - parent-directory segment` | `git`, `-C`, `C:/repo/wt/../other`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L5b - current-directory segment` | `git`, `-C`, `C:/repo/./wt`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L6 - wildcard` | `git`, `-C`, `C:/repo/wt-?`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L7 - stray colon` | `git`, `-C`, `C:/repo/wt:branch`, `add`, `docs/features/active/x/spec.md` | false |
| `issue #671 predicate L8 - empty selector value` | `git`, `-C`, (empty string), `add`, `docs/features/active/x/spec.md` | false |
```

### Payload S5 — spec matrix intro sentence (old, then new)

```
the acceptance criteria key on the expanded node names. The same 24 rows are added to both suites.
```

```
the acceptance criteria key on the expanded node names. The same 24 rows are added to both suites,
and remediation R1 adds the same further 22 nodes to both suites (one row in the selector deny
Context and the two Contexts described below it), for 46 new nodes per suite.
```

### Payload S6 — spec INV-6 (old three lines, then new)

```
- **INV-6 — Chaining semantics unchanged.** The all-segments rule
  (`Test-ExemptOrchestrationStagingCommand`, helpers lines 342–347) stays byte-unchanged. LACS is
  evaluated per segment.
```

```
- **INV-6 — Chaining semantics unchanged.** The all-segments rule
  (`Test-ExemptOrchestrationStagingCommand`, pre-change helpers lines 342–347) keeps its
  semantics. Remediation R1 wraps that per-segment loop, unchanged except for indentation, in a
  fail-closed `try`/`catch` whose `catch` returns `$false`, so an error raised while classifying
  any segment answers false instead of letting the caller reach `return $true`. LACS is evaluated
  per segment.
```

### Payload S7 — spec function-impact table (two old rows, then three new rows)

```
| `Test-ExemptOrchestrationSegmentToken` — selector absorption in the prologue, between the current lines 232 and 233 | `-helpers.ps1` | modified | about 14 changed or added lines |
| `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand` | `-helpers.ps1` | **unchanged** | 0 |
```

```
| `Test-ExemptOrchestrationSegmentToken` — selector absorption in the prologue, between the pre-change lines 232 and 233, plus `[AllowEmptyString()]` on the `$Token` parameter declaration at pre-change line 221 (remediation R1) | `-helpers.ps1` | modified | about 15 changed or added lines |
| `Test-ExemptOrchestrationStagingCommand` — per-segment loop wrapped in a fail-closed `try`/`catch` (remediation R1) | `-helpers.ps1` | modified | about 6 added lines |
| `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand` | `-helpers.ps1` | **unchanged** | 0 |
```

### Payload S8 — spec backward-compatibility bullet, inserted immediately before the line beginning `- **Every command line that is denied today stays denied`

```
- **Remediation R1 exception (narrowing only).** A command line whose segment carries an empty
  quoted token was allowed before remediation R1 only because the token failed parameter binding
  and the caller continued past the error. Such a line now allows only when every operand is
  exempt, and denies otherwise; the fail-closed guard denies on any other classification error. No
  command line that denied before remediation R1 allows after it.
```

### Payload S9 — spec acceptance criterion 11 (the whole line beginning `- [x] The helpers diff is confined to one axis:` is replaced by this line, which is deliberately unchecked)

```
- [ ] The helpers diff is confined to one axis plus the remediation R1 fail-closed repair: in `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every removed content line is one of (a) a line whose text occurs within the pre-change lines 227–236 block, (b) the pre-change line 221 `$Token` parameter declaration of `Test-ExemptOrchestrationSegmentToken`, re-added with `[AllowEmptyString()]` as its only change, or (c) a line of the pre-change per-segment loop at lines 342–347 of `Test-ExemptOrchestrationStagingCommand` whose whitespace-trimmed text equals the whitespace-trimmed text of a line added inside that function's fail-closed `try` block; and no other hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks.
```

### Payload S10 — spec acceptance criterion 19 (the whole line beginning `- [ ] Line coverage is at or above 85%` is replaced by)

```
- [ ] Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/`; the per-file line coverage of the `.claude/hooks` copy of `enforce-orchestration-preimplementation-gate-helpers.ps1`, read from `artifacts/pester/powershell-coverage.xml`, is at or above its pre-change baseline of 94.92% (112 covered of 118); and every instrumented line of that file listed in the changed-line set of the helpers diff has a hit count above zero. Pester does not measure branch coverage, so no branch-coverage gate applies to PowerShell.
```

### Payload S11 — spec acceptance criterion 20 (the whole line beginning `- [ ] The full PowerShell toolchain passes in a single pass` is replaced by)

```
- [ ] The full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format` leaves the SHA256 hash of each of the four helpers copies and the three test files unchanged, as recorded by paired `Get-FileHash` captures taken before and after the call; a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` reports zero findings for each of those seven files, alongside a `mcp__drm-copilot__run_poshqc_analyze` call that returns without error; and `mcp__drm-copilot__run_poshqc_test` writes an `artifacts/pester/pester-junit.xml` whose failing nodes are none, or only one or both of the two failures present at the pre-change baseline (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` and `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`), with no failing node whose name contains `issue #671`.
```

### Payload S12 — spec acceptance criteria 25 and 26, appended as two new lines immediately after the line beginning `- [x] The nested-subdirectory widening is recorded`

```
- [ ] The remediation R1 regression rows pass: nodes `denies issue #671 LACS L8 - empty selector value`, `denies issue #671 selector followed by an unmodelled subcommand`, `denies issue #671 empty token beside a non-exempt operand`, `denies issue #671 empty token after the separator beside a non-exempt operand`, `denies issue #671 trailing empty token after a non-exempt operand`, `denies issue #671 empty commit message beside a non-exempt operand`, and `allows issue #671 empty commit message beside an exempt operand` pass in both command-exemption suites, and an executed probe records `Test-ExemptOrchestrationStagingCommand` returning `False` with zero error records for `git add "" -- src/foo.ps1` and `git add -- "" scripts/powershell/Sample.ps1`.
- [ ] The selector predicate and the fail-closed guard are pinned at the unit level (remediation R1): in both command-exemption suites, under the Context `issue #671 selector predicate and fail-closed guard`, the three `accepts issue #671 predicate accept` nodes, the twelve `rejects issue #671 predicate` nodes, and node `returns false when segment classification raises an error` all pass.
```

### Payload S13 — spec Risks & Mitigations record, inserted immediately after the three-line `  - **Rollback:**` sub-bullet and before `## Rollout & Follow-up`

```
  - **Remediation R1 amendment (2026-09-17).** The first review
    (`remediation-inputs.2026-09-17T08-40.md`) found three blocking defects. This amendment changes
    criterion wording and fixture tables only; it adds no feature scope.
    - The L3a and L3b fixtures carried no `add` or `commit` subcommand, so the gate never consulted
      the exemption for them. They are replaced with commands the staging trigger classifies and
      that reach the L3 rejection.
    - A pre-existing empty-token fail-open let `Test-ExemptOrchestrationStagingCommand` answer true
      after a parameter-binding error. The amendment permits exactly two further helpers edits:
      `[AllowEmptyString()]` on the `$Token` parameter of `Test-ExemptOrchestrationSegmentToken`,
      and a fail-closed `try`/`catch` around the per-segment loop of
      `Test-ExemptOrchestrationStagingCommand`. The one-axis diff criterion is widened to exactly
      those edits. The earlier statements that exactly one function body changes and that
      `Test-ExemptOrchestrationStagingCommand` is unchanged are superseded to that extent.
    - Direction: the amendment only narrows what the gate allows. Command lines that allowed only
      through the fail-open now deny unless every operand is exempt. No command line that denied
      before the amendment allows after it.
    - Coverage: a deny row whose accepted selector is followed by a subcommand other than `add` or
      `commit` restores coverage of the subcommand rejection in
      `Test-ExemptOrchestrationSegmentToken`, and unit-level rows call
      `Test-ExemptOrchestrationSelector` directly.
```

### Payload S14 — spec metadata (old two lines, then new two lines; each replaced in place)

```
- **Last Updated:** 2026-09-13T22-10
- **Version:** 0.2
```

```
- **Last Updated:** 2026-09-17T08-44
- **Version:** 0.3
```

### Payload H1 — helpers comment-based help: insert these two lines immediately after the line `        The tokens are not contractual and change no decision.` (current line 235)

```
        L3 checks only that a non-option token follows the value; the caller
        Test-ExemptOrchestrationSegmentToken rejects any subcommand other than add or commit.
```

### Payload H2 — helpers parameter declaration (old, unique in the file, then new)

```
    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)
```

```
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)
```

### Payload H3 — helpers per-segment loop (old seven lines, current 426–432, then new thirteen lines)

```
    foreach ($segment in $segments) {
        $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)
        if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {
            return $false
        }
    }
    return $true
```

```
    # Fail closed (issue #671): an error raised while classifying any segment is a parse
    # ambiguity, so it answers false instead of letting the caller continue past it.
    try {
        foreach ($segment in $segments) {
            $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)
            if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {
                return $false
            }
        }
    } catch {
        return $false
    }
    return $true
```

### Payload T1 — Claude suite rows (old L3a and L3b lines, then new; then the RF-3 row inserted immediately after the `issue #671 LACS L8 - empty selector value` row)

```
            @{ Label = 'issue #671 LACS L3a - selector with no subcommand after the value'; Command = 'git -C C:/repo/wt' }
            @{ Label = 'issue #671 LACS L3b - subcommand not immediately after the selector value'; Command = 'git -C C:/repo/wt -- docs/features/active/x/spec.md' }
```

```
            @{ Label = 'issue #671 LACS L3a - selector with no subcommand after the value'; Command = 'git -C C:/repo/wt && git add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L3b - subcommand not immediately after the selector value'; Command = 'git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md' }
```

```
            @{ Label = 'issue #671 selector followed by an unmodelled subcommand'; Command = 'git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md' }
```

The Codex suite uses the identical three row lines (Payload T1 applies to both suites unchanged).

### Payload T2 — new Contexts, inserted between the closing `    }` of `Context 'issue #671 worktree selector deny cases'` and the final `}` of the `Describe` block

In the Codex suite, replace both occurrences of `Get-ExemptionDecisionForCommand` in this payload with `Get-CodexExemptionDecisionForCommand` (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` line 54). Everything else is identical in both suites.

```

    Context 'issue #671 empty-token fail-closed cases' {
        # Remediation R1 (issue #671): an empty quoted token is an ordinary token to the
        # classifier. It is never an exempt operand, and after -m it is the message value.
        It 'allows <Label>' -ForEach @(
            @{ Label = 'issue #671 empty commit message beside an exempt operand'; Command = 'git commit -m "" -- docs/features/active/x/spec.md' }
        ) {
            # Act
            $decision = Get-ExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'an empty message value is not a pathspec and every operand is exempt'
        }

        It 'denies <Label>' -ForEach @(
            @{ Label = 'issue #671 empty token beside a non-exempt operand'; Command = 'git add "" -- src/foo.ps1' }
            @{ Label = 'issue #671 empty token after the separator beside a non-exempt operand'; Command = 'git add -- "" scripts/powershell/Sample.ps1' }
            @{ Label = 'issue #671 trailing empty token after a non-exempt operand'; Command = 'git add -- src/foo.ts ""' }
            @{ Label = 'issue #671 empty commit message beside a non-exempt operand'; Command = 'git commit -m "" -- src/foo.ts' }
        ) {
            # Act
            $decision = Get-ExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an empty token never makes a non-exempt operand exempt'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'issue #671 selector predicate and fail-closed guard' {
        # Direct calls to the helpers the gate dot-sources in BeforeAll. The predicate checks
        # only that a non-option token follows the selector value; the caller rejects any
        # subcommand other than add or commit, which accept 3 pins.
        It 'accepts <Label>' -ForEach @(
            @{ Label = 'issue #671 predicate accept 1 - drive-letter selector followed by add'; Token = @('git', '-C', 'C:/repo/wt', 'add', '--', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate accept 2 - rooted selector followed by commit'; Token = @('git', '-C', '/repo/wt', 'commit', '-m', 'msg', '--', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate accept 3 - non-option token after the value is left to the caller'; Token = @('git', '-C', 'C:/repo/wt', 'status') }
        ) {
            # Act
            $result = Test-ExemptOrchestrationSelector -Token $Token

            # Assert
            $result | Should -BeTrue -Because 'the selector satisfies LACS L1 through L8'
        }

        It 'rejects <Label>' -ForEach @(
            @{ Label = 'issue #671 predicate L1a - single token segment'; Token = @('git') }
            @{ Label = 'issue #671 predicate L1b - option other than the selector at index 1'; Token = @('git', '-c', 'core.worktree=C:/repo/wt', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L2 - repeated selector'; Token = @('git', '-C', 'C:/repo/wt', '-C', 'C:/repo/other', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L3a - no token after the selector value'; Token = @('git', '-C', 'C:/repo/wt') }
            @{ Label = 'issue #671 predicate L3b - option token after the selector value'; Token = @('git', '-C', 'C:/repo/wt', '--no-pager', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L4a - relative selector'; Token = @('git', '-C', 'subdir', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L4b - UNC selector'; Token = @('git', '-C', '//server/share/wt', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L5a - parent-directory segment'; Token = @('git', '-C', 'C:/repo/wt/../other', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L5b - current-directory segment'; Token = @('git', '-C', 'C:/repo/./wt', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L6 - wildcard'; Token = @('git', '-C', 'C:/repo/wt-?', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L7 - stray colon'; Token = @('git', '-C', 'C:/repo/wt:branch', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L8 - empty selector value'; Token = @('git', '-C', '', 'add', 'docs/features/active/x/spec.md') }
        ) {
            # Act
            $result = Test-ExemptOrchestrationSelector -Token $Token

            # Assert
            $result | Should -BeFalse -Because 'the selector violates the LACS condition named in the label'
        }

        It 'returns false when segment classification raises an error' {
            # Arrange
            Mock Test-ExemptOrchestrationSegmentToken { throw 'simulated segment classification failure' }

            # Act
            $result = Test-ExemptOrchestrationStagingCommand -CommandText 'git add -- docs/features/active/x/spec.md'

            # Assert
            $result | Should -BeFalse -Because 'an error while classifying a segment is a parse ambiguity and answers false'
            Should -Invoke Test-ExemptOrchestrationSegmentToken -Times 1 -Exactly
        }
    }
```

### Payload P — probe rows used by [P0-T9] and [P2-T10]

The probe script dot-sources `./.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`. The dot-source guard at that file's lines 483–486 stops the entry point from running, and the dot-source makes the helpers, scanner, and invocation functions available.

For each row, the script does the following:
1. Sets `$DebugPreference = 'Continue'` and runs `$raw = @(Test-ExemptOrchestrationStagingCommand -CommandText $row -ErrorVariable rowErrors 5>&1 2>$null)`.
2. Resets `$DebugPreference = 'SilentlyContinue'`.
3. Records these values:
   - `Result`: the `[bool]` elements of `$raw`;
   - `ErrorCount`: `@($rowErrors).Count`;
   - `Debug`: the `Message` values of the `DebugRecord` elements of `$raw`;
   - `Decision`: `(Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ tool_name = 'Bash'; tool_input = @{ command = $row } } | ConvertTo-Json -Compress -Depth 5) -CheckpointRaw '{"issue-num":"","feature-folder":"","route_id":"","lifecycle_ready":false}').hookSpecificOutput.permissionDecision`.

The script creates no file.

| Row | Command |
| --- | --- |
| Q1 | `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` |
| Q2 | `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` |
| Q3 | `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` |
| Q4 | `git -C C:/repo/wt` |
| Q5 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` |
| Q6 | `git add "" -- src/foo.ps1` |
| Q7 | `git add -- "" scripts/powershell/Sample.ps1` |
| Q8 | `git add -- src/foo.ts ""` |
| Q9 | `git -C "" add -- docs/features/active/x/spec.md` |
| Q10 | `git commit -m "" -- src/foo.ts` |
| Q11 | `git commit -m "" -- docs/features/active/x/spec.md` |

[P2-T10] additionally runs the twenty rows listed in `<EVID>/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` lines 19–38, in that order, recording `Result` and `ErrorCount` for each.

---

### Phase 0 — Policy reading, remediation baseline, and executed pre-fix probe

- [ ] [P0-T1] Read, in this order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, and `.claude/rules/plan-acceptance-gates.md`, then write `<EVID>/remediation-baseline/phase0-instructions-read.2026-09-17T08-50.md` containing `Timestamp:`, a `Policy Order:` field naming the six files in the order read, and an explicit list of the files read. Acceptance: the file exists, and `Select-String -SimpleMatch -Pattern 'Policy Order:'` over it returns exactly one line.
- [ ] [P0-T2] Read `remediation-inputs.2026-09-17T08-40.md`, `code-review.2026-09-17T08-40.md`, `policy-audit.2026-09-17T08-40.md`, `feature-audit.2026-09-17T08-40.md`, `spec.md`, and this plan, all in `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/`, then write `<EVID>/other/remediation-inputs-read.2026-09-17T08-50.md` with `Timestamp:`, the six paths, the blocking-finding count stated by the remediation inputs, and the counts of `- [x] ` and `- [ ] ` lines in `spec.md` from `Select-String -SimpleMatch`. Acceptance: the artifact records a blocking count of `3`, a `- [x] ` count of `23`, and a `- [ ] ` count of `6`.
- [ ] [P0-T3] Run the batch-budget reset procedure of governing derivation D8 and record it in `<EVID>/other/remediation-batch-budget-reset.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, listing the state files present before deletion. Acceptance: the post-deletion `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue` returns zero items, and the artifact states that count.
- [ ] [P0-T4] Capture the remediation baseline into `<EVID>/remediation-baseline/surface-hashes-and-line-counts.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, recording `Get-FileHash` and the D7 line count for:
  - the four helpers copies;
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`;
  - the four gate files, the four modes files, the four `hook-command-invocation.ps1` copies, and `.claude/hooks/enforce-epic-merge-gate.ps1`.

  In the same script, also record:
  - `(Get-Location).Path` and the output of `git rev-parse --show-toplevel`;
  - the output of `git rev-parse HEAD`, as observed;
  - the `$LASTEXITCODE` of `git merge-base --is-ancestor 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD`;
  - from `git show 79fd5a95c00cd99238b69a3195788206ae96f4cd:.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, the pre-change line number of the single line containing `[AllowEmptyCollection()][string[]] $Token)` and of the single line containing `foreach ($segment in $segments) {`.

  Through the Git route, also run `git diff --stat 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD -- docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `git diff --name-status 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD`, and `git status --porcelain`, and record all three outputs verbatim. Acceptance: all of the following hold.
  - Both location values, with `\` normalized to `/`, equal `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`.
  - The four helpers hashes collapse to one distinct value, and each helpers copy counts `433` lines.
  - The three suites count `350`, `357`, and `54` lines respectively.
  - The recorded helpers hash equals the hash recorded at `<EVID>/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` line 7, which makes that artifact the valid pre-fix reference for the 20-row comparison.
  - The two pre-change line numbers are `221` and `342`.
  - `git merge-base --is-ancestor 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD` exits `0`, and `git diff --stat 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD` limited to spec.md, the four helpers copies, and the three suites prints nothing. Together these make `03f4f305…` a valid base for [P1-T15]'s spec.md diff even after the orchestrator commits the review artifacts and this plan.
  - Neither the `--name-status` capture nor the porcelain capture lists a path ending in `.ps1` or `.py`, so commits made after `03f4f305…` cannot change [P5-T4]'s path union.

  Any other value blocks Phase 1: report `PLAN REVISION REQUIRED` with the observed values.
- [ ] [P0-T5] Run `mcp__drm-copilot__run_poshqc_format` with the D6 observation over the seven files named in [P0-T4]'s first two groups, and record `<EVID>/remediation-baseline/poshqc-format.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), `Output Summary:`, both hash tables, both `git status --porcelain` captures, and a section headed `Formatter-rewritten paths:` that lists every path whose hash or porcelain status changed, or the single word `none`. Acceptance: the artifact carries both hash tables and both porcelain captures, and the `Formatter-rewritten paths:` section is present. If that section names any path, stop before Phase 1 and report `PLAN REVISION REQUIRED` with the list, because a rewritten `.ps1` would fail [P5-T4], and a rewrite of one of the seven files would invalidate the Payload H and T1 old texts.
- [ ] [P0-T6] Run `mcp__drm-copilot__run_poshqc_analyze`, then derive per-path findings by D3 for the seven files named in [P0-T4]'s first two groups. Record `<EVID>/remediation-baseline/poshqc-analyze.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), and `Output Summary:`. For each path, record `@($findings).Count` and one row per finding with `RuleName`, `Severity`, `Line`, and `Message`. Acceptance: all seven paths appear with a numeric count and a matching number of finding rows. This is a baseline, so a non-zero count does not fail the task.
- [ ] [P0-T7] Run `mcp__drm-copilot__run_poshqc_test` (coverage is enabled by the runsettings), with the D9 report-freshness observation, then derive by D2 and D4. Record `<EVID>/remediation-baseline/poshqc-test-coverage.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), and `Output Summary:` carrying:
  - the D9 pre-call and post-call `LastWriteTimeUtc` values of both reports;
  - the root `tests`, `failures`, `errors`, and `disabled` values;
  - the `name` and `classname` of every `testcase` whose `status` is `Failed`;
  - the report-level LINE `covered`, `missed`, and percentage;
  - the per-file `covered`, `missed`, and percentage for the `.claude/hooks` and `.codex/hooks` helpers copies;
  - the `ci` of the `.claude/hooks` copy at lines 180, 253, 254, 258, 259, and 319.

  Acceptance: the D9 freshness condition holds for both reports; every value is numeric; the failing-node enumeration has exactly `failures` entries; and the six listed lines each record `ci` as a number, with `0` expected for 253, 254, 258, 259, and 319. Each `Failed` testcase's `name` either equals one of the two Payload S11 baseline names or contains `issue #671`. Any other failing node stops the plan before Phase 1 with `PLAN REVISION REQUIRED`.
- [ ] [P0-T8] Run the D8 reset procedure, then run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -p no:cacheprovider --no-cov`, and record `<EVID>/remediation-baseline/python-pushdown-contracts.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the passed and failed counts from pytest's final summary line. Acceptance: both counts are numeric.
- [ ] [P0-T9] [expect-fail] Run the Payload P probe (rows Q1–Q11) against the unmodified helpers file, and record `<EVID>/regression-testing/remediation-fail-before-probe.2026-09-17T08-50.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, the helpers hash at run time, and one table row per probe row carrying `Result`, `ErrorCount`, `Debug`, and `Decision`. Acceptance:
  - Q1 and Q2 each record `Result` `False` and `Decision` `deny`, and their `Debug` value contains `PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value.`
  - Q3 records `Result` `False`, `Decision` `deny`, and no `Debug` value containing `PREIMPL_SELECTOR_`.
  - Q4 and Q5 each record `Decision` `allow`.
  - Q6, Q7, and Q9 each record `Result` `True`, `ErrorCount` of at least `1`, and `Decision` `allow`. These rows are the fail-before evidence for RF-1.
  - Q8, Q10, and Q11 are recorded with their observed values.

  Any deviation in Q1–Q7 or Q9 blocks Phase 1: report `PLAN REVISION REQUIRED` with the observed values.

### Phase 1 — Spec amendment (criteria wording and fixture tables only)

- [ ] [P1-T1] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, replace the L3a table row with Payload S1. Acceptance: `Select-String -SimpleMatch -Pattern 'LACS L3a - selector with no subcommand after the value'` over spec.md returns exactly one line, and that line contains `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md`.
- [ ] [P1-T2] In the same file, replace the L3b table row with Payload S2. Acceptance: `Select-String -SimpleMatch -Pattern 'LACS L3b - subcommand not immediately after the selector value'` over spec.md returns exactly one line, and that line contains `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md`.
- [ ] [P1-T3] In the same file, apply Payload S3: replace the deny-Context heading, and insert the new row immediately after the `issue #671 LACS L8 - empty selector value` row. Acceptance: `Select-String -SimpleMatch -Pattern '18 rows, all NEW'` over spec.md returns exactly one line; `Select-String -SimpleMatch -Pattern 'issue #671 selector followed by an unmodelled subcommand'` returns exactly one line (at this point, before [P1-T12] adds a second occurrence); and that line's number is one greater than the number of the line containing `LACS L8 - empty selector value`.
- [ ] [P1-T4] In the same file, insert Payload S4 immediately after the line `and the row must isolate the selector axis.`. Acceptance: `Select-String -SimpleMatch` over spec.md returns exactly one line for each of `issue #671 empty-token fail-closed cases`, `issue #671 selector predicate and fail-closed guard`, and `issue #671 predicate accept 3 - non-option token after the value is left to the caller`, and returns at least one line for `Decision (remediation R1)`.
- [ ] [P1-T5] In the same file, replace the matrix intro sentence with Payload S5. Acceptance: `Select-String -SimpleMatch -Pattern 'for 46 new nodes per suite'` over spec.md returns exactly one line.
- [ ] [P1-T6] In the same file, replace INV-6 with Payload S6. Acceptance: `Select-String -SimpleMatch -Pattern 'wraps that per-segment loop'` over spec.md returns exactly one line, and `Select-String -SimpleMatch -Pattern 'helpers lines 342–347) stays byte-unchanged'` returns no line.
- [ ] [P1-T7] In the same file, replace the two function-impact table rows with the three rows of Payload S7. Acceptance: `Select-String -SimpleMatch -Pattern 'per-segment loop wrapped in a fail-closed'` over spec.md returns exactly one line, `Select-String -SimpleMatch -Pattern '**unchanged**'` returns exactly three lines, and none of those three lines contains `Test-ExemptOrchestrationStagingCommand`. Before this task, one of them does: spec.md line 315.
- [ ] [P1-T8] In the same file, insert Payload S8 immediately before the line beginning `- **Every command line that is denied today stays denied`. Acceptance: `Select-String -SimpleMatch -Pattern 'Remediation R1 exception (narrowing only)'` over spec.md returns exactly one line, and its line number is less than that of the line containing `Every command line that is denied today stays denied`.
- [ ] [P1-T9] In the same file, replace acceptance criterion 11 with Payload S9. Acceptance: `Select-String -SimpleMatch -Pattern 'plus the remediation R1 fail-closed repair'` over spec.md returns exactly one line, and that line begins with `- [ ] `.
- [ ] [P1-T10] In the same file, replace acceptance criterion 19 with Payload S10. Acceptance: `Select-String -SimpleMatch -Pattern 'pre-change baseline of 94.92% (112 covered of 118)'` over spec.md returns exactly one line, and that line begins with `- [ ] `.
- [ ] [P1-T11] In the same file, replace acceptance criterion 20 with Payload S11. Acceptance: `Select-String -SimpleMatch -Pattern 'leaves the SHA256 hash of each of the four helpers copies'` over spec.md returns exactly one line, that line begins with `- [ ] `, and `Select-String -SimpleMatch -Pattern 'reports zero failed tests'` returns no line.
- [ ] [P1-T12] In the same file, append the two criteria of Payload S12 immediately after the line beginning `- [x] The nested-subdirectory widening is recorded`. Acceptance: `Select-String -SimpleMatch -Pattern 'The remediation R1 regression rows pass'` over spec.md returns exactly one line; `Select-String -SimpleMatch -Pattern 'are pinned at the unit level (remediation R1)'` returns exactly one line; and both lines begin with `- [ ] `.
- [ ] [P1-T13] In the same file, insert Payload S13 immediately after the `  - **Rollback:**` sub-bullet and before `## Rollout & Follow-up`. Acceptance: `Select-String -SimpleMatch -Pattern 'Remediation R1 amendment (2026-09-17)'` over spec.md returns exactly one line, and its line number is less than that of the line `## Rollout & Follow-up`.
- [ ] [P1-T14] In the same file, apply Payload S14 to the metadata block. Acceptance: `Select-String -SimpleMatch -Pattern '- **Last Updated:** 2026-09-17T08-44'` returns exactly one line, and `Select-String -SimpleMatch -Pattern '- **Version:** 0.3'` returns exactly one line.
- [ ] [P1-T15] Record `<EVID>/other/spec-amendment-r1.2026-09-17T09-10.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying:
  - the post-amendment `Select-String -SimpleMatch` line counts of `- [x] ` and `- [ ] ` in spec.md;
  - the count of lines under `## Acceptance Criteria` that begin with `- [`;
  - the verbatim output of `git diff --unified=0 03f4f305765e15745b9275f3a8fd42758f2c6873 -- docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` and of `git status --porcelain`;
  - a table of every removed content line in that diff.

  The diff base is the reviewed commit `03f4f305…`, not `HEAD`. [P0-T4] verified that this commit is an ancestor of `HEAD` and that spec.md is unchanged between them. The diff therefore shows exactly the Phase 1 edits, whether or not they have been committed.

  Acceptance: the `- [x] ` count is `22`, the `- [ ] ` count is `9`, and the acceptance-criteria count is `26`. The expected counts follow from the edits: criterion 11 becomes unchecked, and criteria 25 and 26 are added unchecked. The diff removes exactly `14` content lines, and each one is an old text quoted in Payload S1 (1), S2 (1), S3 (1), S5 (1), S6 (3), S7 (2), S9 (the old criterion 11 line), S10 (the old criterion 19 line), S11 (the old criterion 20 line), or S14 (2). A removed line outside that set means an unplanned spec edit, including any change to an existing allow row or regression-guard row, and fails this task.

### Phase 2 — Production fix on the canonical copy, then mirrors

- [ ] [P2-T1] In `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, insert the two lines of Payload H1 immediately after the line `        The tokens are not contractual and change no decision.`. Acceptance: `Select-String -SimpleMatch -Pattern 'rejects any subcommand other than add or commit'` over that file returns exactly one line, and its line number is `237`.
- [ ] [P2-T2] In the same file, replace the parameter declaration of Payload H2. Acceptance: `Select-String -SimpleMatch -Pattern '[AllowEmptyCollection()][string[]] $Token)'` over that file returns no line, and `Select-String -SimpleMatch -Pattern '[AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)'` returns exactly two lines: the predicate's declaration at line 243 (current line 241, moved by the two lines [P2-T1] inserted) and the segment-token declaration at line 298 (current line 296).
- [ ] [P2-T3] In the same file, replace the per-segment loop with Payload H3. Acceptance: `Select-String -SimpleMatch -Pattern '} catch {'` over that file returns exactly one line, at line `437`, and `Select-String -SimpleMatch -Pattern 'Fail closed (issue #671)'` returns exactly one line.
- [ ] [P2-T4] Verify the canonical copy and record `<EVID>/regression-testing/remediation-canonical-copy-check.2026-09-17T09-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The artifact records:
  - the error count from `[System.Management.Automation.Language.Parser]::ParseFile`;
  - the D7 line count;
  - the D5 line numbers K1–K7;
  - the `Select-String -SimpleMatch` counts for each of the seven purity literals;
  - the count for `Pure string logic only: no disk, process, network, or environment access`;
  - the count for `Accepted widening`.

  Acceptance: the parse error count is `0`; the line count is `441`; K1–K7 equal `255`, `256`, `260`, `261`, `321`, `180`, and `438`; every purity-literal count is `0`; the purity-sentence count is `1`; and the `Accepted widening` count is at least `1`.
- [ ] [P2-T5] Run `Copy-Item -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 -Destination .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 -Force` in a scratchpad script, not with the Write or Edit tool. Acceptance: the two `Get-FileHash` values are equal, as recorded in [P2-T9].
- [ ] [P2-T6] Copy the canonical file the same way onto `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Acceptance: the two `Get-FileHash` values are equal, as recorded in [P2-T9].
- [ ] [P2-T7] Scheduled production-side reset between the third and fourth helpers surface. Run the D8 procedure unconditionally, and append a section with `Timestamp:` and the observed state-file list to `<EVID>/other/remediation-batch-budget-reset.2026-09-17T08-50.md`. Acceptance: the post-deletion `Get-ChildItem` returns zero items.
- [ ] [P2-T8] Copy the canonical file the same way onto `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Acceptance: the two `Get-FileHash` values are equal, as recorded in [P2-T9].
- [ ] [P2-T9] Record `<EVID>/other/remediation-helpers-surface-parity.2026-09-17T09-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each of the four helpers paths with its `Get-FileHash` value and D7 line count. Acceptance: the four hashes collapse to exactly one distinct value, that value differs from the [P0-T4] helpers hash, and each line count is `441`.
- [ ] [P2-T10] Run the Payload P probe (rows Q1–Q11 plus the twenty rows) against the edited file, and record `<EVID>/regression-testing/remediation-pass-after-probe.2026-09-17T09-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, the helpers hash at run time, and a row-by-row comparison against [P0-T9] and against `<EVID>/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md`. Acceptance:
  - Q1–Q5 record the same `Result`, `Debug`, and `Decision` values as [P0-T9], with `ErrorCount` `0`.
  - Q6–Q10 each record `Result` `False`, `ErrorCount` `0`, and `Decision` `deny`. Q9's `Debug` contains `PREIMPL_SELECTOR_MALFORMED: the selector value is empty.`
  - Q11 records `Result` `True`, `ErrorCount` `0`, and `Decision` `allow`.
  - Of the twenty rows, rows 2, 3, and 9 are `True`, and rows 1–19 are identical to the prior pass-after artifact.
  - Row 20 is `False` with `ErrorCount` `0`, and the artifact states that this change from `True` is the intended RF-1 outcome.
  - Every one of the thirty-one probe calls records `ErrorCount` `0`.

### Phase 3 — Test rows in the two command-exemption suites

- [ ] [P3-T1] In `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, replace the L3a row line with its Payload T1 replacement. Acceptance: `Select-String -SimpleMatch -Pattern 'LACS L3a - selector with no subcommand after the value'` over that file returns exactly one line, and that line contains `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md`.
- [ ] [P3-T2] In the same file, replace the L3b row line with its Payload T1 replacement. Acceptance: the single line containing `LACS L3b - subcommand not immediately after the selector value` contains `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md`.
- [ ] [P3-T3] In the same file, insert the Payload T1 RF-3 row immediately after the `issue #671 LACS L8 - empty selector value` row. Acceptance: `Select-String -SimpleMatch -Pattern 'issue #671 selector followed by an unmodelled subcommand'` over that file returns exactly one line, and its line number is one greater than that of the line containing `LACS L8 - empty selector value`.
- [ ] [P3-T4] In the same file, insert Payload T2, unchanged, between the closing brace of `Context 'issue #671 worktree selector deny cases'` and the final closing brace of the `Describe` block. Acceptance: `Select-String -SimpleMatch` over that file returns exactly one line for each of `Context 'issue #671 empty-token fail-closed cases'`, `Context 'issue #671 selector predicate and fail-closed guard'`, and `It 'returns false when segment classification raises an error'`, and returns no line for `Get-CodexExemptionDecisionForCommand`.
- [ ] [P3-T5] In `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, replace the L3a row line with its Payload T1 replacement. Acceptance: the single line of that file containing `LACS L3a - selector with no subcommand after the value` contains `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md`.
- [ ] [P3-T6] In the Codex suite, replace the L3b row line with its Payload T1 replacement. Acceptance: the single line containing `LACS L3b - subcommand not immediately after the selector value` contains `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md`.
- [ ] [P3-T7] In the Codex suite, insert the Payload T1 RF-3 row immediately after the `issue #671 LACS L8 - empty selector value` row. Acceptance: `Select-String -SimpleMatch -Pattern 'issue #671 selector followed by an unmodelled subcommand'` over that file returns exactly one line, directly after the L8 row line.
- [ ] [P3-T8] In the Codex suite, insert Payload T2 with the Codex helper-name substitution, at the same position as in [P3-T4]. Acceptance: `Select-String -SimpleMatch` over that file returns exactly one line for each of `Context 'issue #671 empty-token fail-closed cases'`, `Context 'issue #671 selector predicate and fail-closed guard'`, and `It 'returns false when segment classification raises an error'`, and returns no line for `Get-ExemptionDecisionForCommand -Command`.
- [ ] [P3-T9] Record `<EVID>/regression-testing/remediation-suite-edits.2026-09-17T09-45.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. For each of the two suites, record:
  - the `ParseFile` error count;
  - the D7 line count;
  - the count of lines containing `@{ Label = 'issue #671 `.

  Acceptance: both parse error counts are `0`; both line counts are at most `500`; and the `@{ Label = 'issue #671 ` count is `45` in each suite. The count is 7 allow rows, 18 deny rows, 5 empty-token rows, and 15 predicate rows; the guard node is an `It` with no row.

### Phase 4 — Targeted verification run

- [ ] [P4-T1] Run `mcp__drm-copilot__run_poshqc_test` with the D9 report-freshness observation, then read `artifacts/pester/pester-junit.xml` by D2. Record `<EVID>/regression-testing/remediation-exemption-suites.2026-09-17T10-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), and `Output Summary:` carrying the D9 pre-call and post-call `LastWriteTimeUtc` values of both reports and, for each of the two command-exemption suites:
  - the `testsuite` `tests`, `failures`, `errors`, `skipped`, and `disabled` values;
  - the count of `testcase` elements whose `name` contains `.issue #671 ` and the count of those with `status` `Passed`;
  - the match count and `status` for each of the ten named nodes listed below.

  The ten named nodes are the seven nodes named in Payload S12's first criterion, plus `denies issue #671 LACS L3a - selector with no subcommand after the value`, `denies issue #671 LACS L3b - subcommand not immediately after the selector value`, and `returns false when segment classification raises an error`.

  Acceptance: the D9 freshness condition holds for both reports, and, in each suite:
  - `tests` is `105`, `failures` is `0`, and `errors` is `0`;
  - the `.issue #671 ` count is `46`, and all `46` are `Passed`;
  - each of the ten named nodes matches exactly one `testcase` with `status` `Passed`.

  Any other value fails this task. Fix the cause and restart from [P4-T1]. Do not weaken a row.
- [ ] [P4-T2] From the same JUnit report, record `<EVID>/regression-testing/remediation-regression-guards.2026-09-17T10-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying, per command-exemption suite:
  - the count of `testcase` elements whose `name` contains `.issue #539 fail-closed rule table deny cases.`, and how many are `Passed`;
  - the count of those whose `name` contains `.issue #539 orchestration-tree staging exemption allow cases.`, and how many are `Passed`;
  - the match count and `status` for `denies D4 row 14b - a directory-relocating option before the subcommand`, `denies D4 row 14c - a git-dir option before the subcommand`, and `denies D4 row 14d - a work-tree option before the subcommand`.

  The artifact also records the `testsuite` values and the two node results for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`. Acceptance:
  - in each command-exemption suite, `45` of `45` deny rows and `8` of `8` allow rows are `Passed`, and each of the three D4 row 14 nodes matches exactly one `Passed` `testcase`;
  - the parity suite has `tests` `2` and `failures` `0`;
  - both parity nodes are `Passed`: `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` and `keeps every surface copy of the helpers module under the 500-line cap`.

### Phase 5 — Invariant re-verification (RF-5)

- [ ] [P5-T1] Run `git diff --stat 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 .claude/hooks/enforce-epic-merge-gate.ps1` and `git status --porcelain`. Record both verbatim in `<EVID>/qa-gates/remediation-diff-confinement-protected.2026-09-17T10-15.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the `git diff --stat` output is empty, and none of the thirteen paths appears in the porcelain capture.
- [ ] [P5-T2] Run `git diff 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `git diff --unified=0 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Record `<EVID>/qa-gates/remediation-diff-confinement-helpers.2026-09-17T10-15.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, both captures, and a table of every removed content line. Each row gives the pre-change line number, the text, and its class under Payload S9: (a) inside pre-change lines 227–236, (b) the pre-change line 221 declaration, or (c) a pre-change line in 342–347 whose trimmed text equals the trimmed text of an added line inside the `try` block. The artifact also carries:
  - a section headed `Changed-line set:` listing the post-image line numbers of every added content line, derived from the zero-context hunk headers;
  - `Helpers hash at capture:` with the current `Get-FileHash` value.

  Acceptance: every removed line is assigned one of (a), (b), or (c); the class (b) row's added counterpart differs only by the inserted `[AllowEmptyString()]`; and no hunk touches a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, or the three pre-existing `$script:` constant blocks. `Changed-line set:` must be present and non-empty, and its count must equal the diff's added-line count. An unclassifiable removed line fails this task.
- [ ] [P5-T3] Run `git diff --numstat 79fd5a95c00cd99238b69a3195788206ae96f4cd -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and record it verbatim in `<EVID>/qa-gates/remediation-diff-additive-only.2026-09-17T10-15.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: both rows show a removed-line count of `0`.
- [ ] [P5-T4] Run `git diff --name-status 79fd5a95c00cd99238b69a3195788206ae96f4cd` and `git status --porcelain`, and record both verbatim in `<EVID>/qa-gates/remediation-changed-path-set.2026-09-17T10-15.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, listing the union of `.ps1` paths from both captures. Acceptance:
  - the union contains exactly four `.ps1` paths outside `tests/`, all named `enforce-orchestration-preimplementation-gate-helpers.ps1`;
  - it contains exactly three `.ps1` paths under `tests/`: the two command-exemption suites and the parity suite;
  - neither capture lists a path ending in `.py`.
- [ ] [P5-T5] For each of the four helpers copies, run `Select-String -SimpleMatch` for `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, `env:`, `Import-Module`, `Pure string logic only: no disk, process, network, or environment access`, and `Accepted widening`. Record the 36 counts in `<EVID>/qa-gates/remediation-helpers-purity.2026-09-17T10-15.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: each of the first seven literals counts `0` in every copy, the purity sentence counts `1` in every copy, and `Accepted widening` counts at least `1` in every copy.

### Phase 6 — Final QA loop (format, analyze, test; restart from [P6-T1] on any failure or file change)

- [ ] [P6-T1] Run `mcp__drm-copilot__run_poshqc_format` with the D6 observation over the seven files: the four helpers copies and the three suites. Record `<EVID>/qa-gates/remediation-poshqc-format.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), `Output Summary:`, both hash tables, and both porcelain captures. Acceptance: all seven before-and-after hash pairs are equal, and the two porcelain captures are byte-identical. If any pair differs, the formatter rewrote a file. In that case, re-run [P2-T4]'s K1–K7 derivation and [P5-T2], re-run the helpers mirrors [P2-T5], [P2-T6], and [P2-T8] if a helpers copy changed, and restart from [P6-T1]. This task is unconditional; `EXIT_CODE: SKIPPED` is not a passing outcome.
- [ ] [P6-T2] Run `mcp__drm-copilot__run_poshqc_analyze`, then derive per-path findings by D3 for the same seven files. Record `<EVID>/qa-gates/remediation-poshqc-analyze.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), and `Output Summary:` naming all seven paths with `@($findings).Count`. Acceptance: every count is `0` with no finding rows, and the MCP disposition is `ok: true`, which by D3 means the zero-findings branch was reached. A non-zero count fails this task: fix the finding and restart from [P6-T1]. This task is unconditional.
- [ ] [P6-T3] Run `mcp__drm-copilot__run_poshqc_test` with the D9 report-freshness observation, then derive by D2 and D4. Record `<EVID>/qa-gates/remediation-poshqc-test-coverage.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (D1), `ExpectedExitCode:`, and `Output Summary:`. `ExpectedExitCode:` equals the number of failing nodes whose `name` is one of the two baseline names in Payload S11. `Output Summary:` carries:
  - the D9 pre-call and post-call `LastWriteTimeUtc` values of both reports;
  - the root `tests`, `failures`, `errors`, and `disabled` values;
  - the `name` and `classname` of every `Failed` `testcase`;
  - the report-level LINE `covered`, `missed`, and percentage, with the [P0-T7] values restated;
  - the per-file `covered`, `missed`, and percentage of the `.claude/hooks` and `.codex/hooks` helpers copies;
  - the `ci` values of the `.claude/hooks` copy at the K1–K7 lines from [P2-T4].

  Acceptance:
  - (0) The D9 freshness condition holds for both reports; otherwise this task is INCOMPLETE.
  - (a) `errors` is `0`, every failing node's `name` equals one of the two baseline names in Payload S11, and no failing node's `name` contains `issue #671`.
  - (b) The report-level LINE percentage is at least `85`.
  - (c) The `.claude/hooks` per-file ratio `covered / (covered + missed)` is at least `112 / 118`, and so is the `.codex/hooks` ratio.
  - (d) Each K1–K7 line has `ci` greater than `0`.

  Any failure restarts the loop from [P6-T1] after the cause is fixed. This task is unconditional.
- [ ] [P6-T4] Record `<EVID>/qa-gates/remediation-coverage-comparison.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying:
  - the baseline report-level and `.claude/hooks` per-file `covered`/`missed` pairs from [P0-T7], and the post-change pairs from [P6-T3];
  - the changed-line coverage of the `.claude/hooks` copy: from the D4-selected `sourcefile`, the `line` children whose `nr` is in [P5-T2]'s `Changed-line set:`, reported as the count with `ci` greater than `0` over the count present.

  Before computing, compare the current `Get-FileHash` of the canonical helpers file with [P5-T2]'s `Helpers hash at capture:`. If they differ, re-run [P5-T2] first and note the re-run. Acceptance: the restated pairs match their source artifacts; the post-change report-level percentage is at least `85`; the post-change per-file ratio is at least `112 / 118`; and the changed-line ratio is `100%`. A changed line with `ci` of `0` fails this task. Name each such line by its `nr`; this fails the task, it does not excuse the line.
- [ ] [P6-T5] Run the D8 reset procedure, then run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -p no:cacheprovider --no-cov -v`. Record `<EVID>/qa-gates/remediation-python-pushdown-contracts.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the passed and failed counts from the final summary line and the `-v` result line for `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Acceptance: `EXIT_CODE` is `0`, the failed count is `0`, and that test's result line reads `PASSED`. This task is unconditional.
- [ ] [P6-T6] From the [P6-T3] JUnit report, record the must-not-regress roll-up in `<EVID>/qa-gates/remediation-must-not-regress-rollup.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance, by D2:
  - In `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, nodes `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` and `blocks an implementation write when the checkpoint omits the feature folder` each match one `Passed` `testcase`.
  - In both command-exemption suites, nodes `allows staging an epic document under the epics tree` and `allows a chained two-segment line whose every segment is independently exempt` each match one `Passed` `testcase`.
  - In `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, nodes `keeps the canonical hooks byte-identical to their bundled copies` and `parse-checks each root and bundled hook and keeps every file within 500 lines` each match one `Passed` `testcase`.
  - Each of these five suites has a `testsuite` element with `failures` `0` and a recorded numeric `tests` greater than `0`: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`.

  An absent `testsuite` element fails this task.
- [ ] [P6-T7] Record `<EVID>/qa-gates/remediation-toolchain-single-pass.2026-09-17T10-30.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the [P6-T1], [P6-T2], and [P6-T3] invocations that ran consecutively with no restart between them, each with its artifact path, and stating the number of restarts before that sequence. Acceptance: the named sequence is one format, one analyze, and one test invocation, whose artifacts each meet their task's acceptance, and no file changed between the first and the last of them. The recorded [P6-T1] post-call hashes must equal the hashes read immediately after [P6-T3], and the artifact records both sets.

### Phase 7 — Acceptance-criteria and checkbox reconciliation

- [ ] [P7-T1] After [P4-T1] and [P6-T3] pass, change the spec.md line beginning `- [ ] Each LACS condition L1 through L8` to begin `- [x] `, changing no other character. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] Each LACS condition L1 through L8'` over spec.md returns exactly one line.
- [ ] [P7-T2] After [P5-T2] passes, change the spec.md line beginning `- [ ] The helpers diff is confined to one axis plus the remediation R1 fail-closed repair` to begin `- [x] `. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] The helpers diff is confined to one axis plus'` over spec.md returns exactly one line.
- [ ] [P7-T3] After [P6-T3] and [P6-T4] pass, change the spec.md line beginning `- [ ] Line coverage is at or above 85%` to begin `- [x] `. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] Line coverage is at or above 85%'` over spec.md returns exactly one line.
- [ ] [P7-T4] After [P6-T7] passes, change the spec.md line beginning `- [ ] The full PowerShell toolchain passes in a single pass` to begin `- [x] `. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] The full PowerShell toolchain passes in a single pass'` over spec.md returns exactly one line.
- [ ] [P7-T5] After [P4-T1] and [P2-T10] pass, change the spec.md line beginning `- [ ] The remediation R1 regression rows pass` to begin `- [x] `. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] The remediation R1 regression rows pass'` over spec.md returns exactly one line.
- [ ] [P7-T6] After [P4-T1] passes, change the spec.md line beginning `- [ ] The selector predicate and the fail-closed guard are pinned` to begin `- [x] `. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] The selector predicate and the fail-closed guard are pinned'` over spec.md returns exactly one line.
- [ ] [P7-T7] Write `<EVID>/qa-gates/remediation-acceptance-criteria-reconciliation.2026-09-17T10-45.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing all 26 spec acceptance criteria, each with its state, the task that last verified it (this plan's task, or the prior plan's task where this plan did not re-verify it), and the backing evidence path. The artifact also records the spec.md `Select-String -SimpleMatch` counts of `- [x] ` and `- [ ] `. Acceptance: the `- [x] ` count is `28` and the `- [ ] ` count is `3`, so all 26 criteria plus the two metadata lines are checked and the three severity lines are unchecked. Every one of the 26 criteria must name an existing evidence path. A criterion whose re-verification in Phases 4–6 failed must be left unchecked, recorded as a gap, and reported as INCOMPLETE.
- [ ] [P7-T8] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md`, change exactly four task lines from `- [ ] ` to `- [x] `: those beginning `- [ ] [P3-T7]`, `- [ ] [P4-T4]`, `- [ ] [P5-T10]`, and `- [ ] [P6-T8]`. Each of those tasks' target spec lines is now checked, and each task's intermediate count condition is superseded by [P7-T7]. Leave these six lines unchecked:
  - `[P0-T5]`, because its artifact `<EVID>/other/git-attached-selector-probe.2026-09-13T22-40.md` line 8 records INCOMPLETE and the task text requires the box to stay unchecked;
  - `[P3-T3]`, `[P3-T5]`, `[P6-T3]`, `[P6-T7]`, and `[P7-T1]`, whose named artifacts record failures and whose checks this plan supersedes.

  Acceptance: `Select-String -SimpleMatch -Pattern '- [ ] [P'` over that plan returns exactly `6` lines, and `Select-String -SimpleMatch -Pattern '- [x] [P'` returns exactly `46` lines.
- [ ] [P7-T9] Write `<EVID>/other/remediation-plan-checkbox-reconciliation.2026-09-17T10-45.md` with `Timestamp:` listing the ten prior-plan tasks that were unchecked, the disposition of each from [P7-T8], and for each disposition the evidence path or the superseding task of this plan. Acceptance: the artifact lists exactly ten task identifiers: `P0-T5`, `P3-T3`, `P3-T5`, `P3-T7`, `P4-T4`, `P5-T10`, `P6-T3`, `P6-T7`, `P6-T8`, and `P7-T1`.
- [ ] [P7-T10] Write the issue-update mirror `<EVID>/issue-updates/issue-671.2026-09-17T10-45.md` with `Timestamp:`, the exact update text for issue #671, and `PostedAs:` recording `body`, `comment`, or `unknown`. The update text summarizes the R1 remediation: the L3 fixture replacement, the empty-token fail-open closure and its direction (narrowing only), the fail-closed guard, the unit-level predicate rows, and the numeric post-change per-file and repository-wide coverage from [P6-T3]. Acceptance: the file exists and carries a `PostedAs:` field with one of those three values.
