# 2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder (Remediation Plan, Cycle 1)

- **Issue:** #565 (bundles #568 and #696)
- **Branch:** `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565`
- **Work Mode:** full-bug. `spec.md` is the acceptance-criteria source. No `user-story.md` exists or is required.
- **Remediation inputs:** `remediation-inputs.2026-10-08T19-24.md`, `code-review.2026-10-08T19-24.md`, `policy-audit.2026-10-08T19-24.md`, `feature-audit.2026-10-08T19-24.md` (all folder-relative).
- **Status:** Draft, revision round 2 (pending validator and executor preflight).

**Scope.** Required: R1 (from CR-1). In scope as small, low-risk items: CR-4, PA-3, CR-3 (record only). Out of scope: CR-2 (spec amendment; recorded as a follow-up only), PA-1 (repo-wide PowerShell coverage), spec AC item 30 (awaiting PR CI; it stays unchecked), GitHub issue creation, any edit to `.claude/rules/`, `.github/instructions/`, `.claude/settings.json`, the shared resolver `feature-folder-resolution.ps1`, or `Find-OrchestrationModeRecord`.

**Fail-closed evidence rule.** Every evidence-producing task names its artifact. A missing baseline, QA, or coverage artifact makes the remediation verdict BLOCKED, never PASS.

**Evidence accounting rule.** Every artifact is written under `FEATURE/evidence/<kind>/` with kind in {`remediation-baseline`, `regression-testing`, `qa-gates`, `other`} and carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. No evidence is written under `artifacts/`.

**Clock rule.** Every `<ts>` in an artifact file name and every `Timestamp:` value is read from the clock by running `date +%Y-%m-%dT%H-%M` in the Bash tool immediately before the artifact is written. No timestamp is estimated or copied from another artifact.

**Superseded-artifact rule (prevents a recurrence of PA-3).** The PR-context collector renders every `*.md` under `evidence/qa-gates/`, `evidence/regression-testing/`, and `evidence/other/` (`scripts/dev_tools/pr_context/verification_evidence.py` lines 24-28) and normalizes `EXIT_CODE` against `ExpectedExitCode` (default 0). When a gate run in those folders fails and a later run of the same task supersedes it, move the failed artifact to `FEATURE/evidence/remediation-baseline/superseded/` (same file name, written with Write, original deleted with `git rm` or, when untracked, by deleting it through the PowerShell route) and add one line `Superseded: <path of the superseding artifact>` after its `Output Summary:` line. `evidence/remediation-baseline/` is not collected.

## Conventions

**Path abbreviations.** Substitute these literally before running anything.

- `FEATURE` = `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565`
- `CM` = `extensions/drm-copilot/resources/claude-customizations`
- `XM` = `extensions/drm-copilot/resources/codex-and-agents-customizations`
- `BRANCH` = `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565`
- `<RB>` = the 40-hex SHA recorded as `RemediationBase:` in `FEATURE/evidence/remediation-baseline/remediation-base.<ts>.md` (P0-T13). Every `git diff` in this plan is anchored to that SHA.

**Shells.** Inside the agent worktree, Bash text containing the PowerShell executable name is refused. Every PowerShell command therefore uses this route:

1. P0-T1 writes `<scratchpad>/c2-565-r1-run.sh` containing exactly two lines: `pwsh -NoProfile -File "$1"` and `exit $?`.
2. For each command, Write its body to `<scratchpad>/c2-565-r1-<task-id>.ps1` (suffix `-a`, `-b` for a task with several commands). For a template written as `pwsh -NoProfile -Command { BODY }`, the file holds BODY only. For SUITE, the file holds the quoted string only. For every other template or inline command, the file holds the command text as written. Then run `sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-<task-id>.ps1` in Bash from the worktree root. Its exit code is the command's exit code.
3. `<scratchpad>` is the executor's session scratchpad directory, written with forward slashes. The `Command:` field of an artifact records the `.ps1` body with the scratchpad prefix written as the literal `<scratchpad>`.
4. SUITE runs with `run_in_background` true; the task waits for completion before reading its output.

Commands written with `git`, `grep`, `date`, `poetry`, or `sh` run in the Bash tool from the worktree root, one `git` invocation per Bash call, with no pipe, separator, or redirection after `git`.

**Live-hook ordering (mandatory reading before execution).**

1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is registered on the Bash, Write|Edit, and Agent matchers (`.claude/settings.json` lines 107, 152, 185) and dot-sources `enforce-orchestration-preimplementation-gate-modes.ps1` without a guard (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 20). A parse error in either file would break every later Bash, Write, and Edit call. Therefore: RW01 is edited before RW03, so every parameter RW03 starts passing already exists; each of the two files is parse-checked immediately after its edit (P2-T3, P2-T5); the changed code is reached only on the Agent delegation leg (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 369-395), which the executor does not use. If a parse check reports `Errors=` greater than 0, run `git checkout HEAD -- <that path>` in Bash and stop. If that Bash call is itself denied, stop and report BLOCKED with the deny text; do not bypass any hook.
2. The three barrier hooks (RW05-RW07) run only on the Agent matcher; the executor issues no Agent calls.
3. `.codex/hooks/` files are not loaded by this Claude session.
4. `enforce-powershell-batch-budget.ps1` (`.claude/settings.json` line 144) limits the distinct production PowerShell paths edited per window. This plan edits seven production PowerShell files with Edit, in three windows of at most three files: W-R1 (P2-T1): RW01, RW03, RW02. W-R2 (P2-T7): RW04. W-R3 (P3-T5): RW05, RW06, RW07. Mirrors are made with `Copy-Item`. If a Write or Edit is denied with `POWERSHELL_LARGE_PATH_REQUIRED` after a reset, record the deny text in `FEATURE/evidence/other/batch-budget-deny.<ts>.md` and stop.

**Copy rule.** Mirrors are created only with `Copy-Item -LiteralPath <source> -Destination <target> -Force` on the PowerShell route. Any later change to a source file is followed by re-running its copy task before the next test run.

**Commit rule.** Each phase ends with one commit-and-push task. Staging uses explicit pathspecs, never `git add -A` without a pathspec. Push is `git push origin BRANCH`; force pushes of any kind are prohibited. If a hook denies a staging, commit, or push command, record the deny text in `FEATURE/evidence/other/commit-deny.<ts>.md` and stop.

**Test-integrity rule.** No existing assertion is weakened, deleted, or skipped. If an existing suite fails after the R1 fix (P2-T15, P5-T7), stop and report the failing case; do not edit the existing suite.

## Remediation Write Set (fixed)

| ID | Path | Change |
|---|---|---|
| RW01 | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | edit (ED-1..ED-6) |
| RW02 | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | edit (ED-1..ED-6) |
| RW03 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | edit (ED-7) |
| RW04 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | edit (ED-7) |
| RW05 | `.claude/hooks/enforce-epic-wave-barrier.ps1` | edit (ED-8) |
| RW06 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | edit (ED-8) |
| RW07 | `.claude/hooks/enforce-parallel-drift-gate.ps1` | edit (ED-8) |
| RW08 | `CM/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | Copy-Item of RW01 |
| RW09 | `CM/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Copy-Item of RW03 |
| RW10 | `CM/.claude/hooks/enforce-epic-wave-barrier.ps1` | Copy-Item of RW05 |
| RW11 | `CM/.claude/hooks/enforce-parallel-cohort-barrier.ps1` | Copy-Item of RW06 |
| RW12 | `CM/.claude/hooks/enforce-parallel-drift-gate.ps1` | Copy-Item of RW07 |
| RW13 | `XM/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | Copy-Item of RW02 |
| RW14 | `XM/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | Copy-Item of RW04 |
| RW15 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1` | edit (CAT-R1) |
| RW16 | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1` | edit (CAT-R1) |
| RW17 | `tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1` | edit (W9 assertion) |
| RW18 | `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1` | edit (C7 assertion) |
| RW19 | `tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1` | edit (D7 assertion) |

Feature-folder documentation changes (PA-3, CR-3, follow-ups) are listed in Phase 4.

**Write-set note (RW03, RW04).** `remediation-inputs.2026-10-08T19-24.md` lists only the two `-modes.ps1` files, but its required change 1 allows passing "the keyed value separately from the D3 fallback value". The gate main file is the only caller that holds the prompt (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 385-391; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 426-432), so the predicates cannot distinguish the keyed form from the bare hash form without a caller change. Alternatives were rejected: changing the default return of `Find-OrchestrationDelegationIssueNumber` breaks the pinned bare-hash case at `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` line 167 and loses the D3 fallback; passing the keyed flag through script-scoped state couples two functions through hidden state. Spec line 173 says the predicates "may" be retyped without edits to the gate main files; it does not prohibit such edits.

## Design Contract

**Path sets.**

- `R-PROD` (7, coverage-measured): RW01, RW02, RW03, RW04, RW05, RW06, RW07.
- `R-TESTS` (5, edited tests): RW15, RW16, RW17, RW18, RW19.
- `R-PAIRS` (7): (RW01,RW08), (RW03,RW09), (RW05,RW10), (RW06,RW11), (RW07,RW12), (RW02,RW13), (RW04,RW14).
- `R-EXISTING-PRE` (18, existing preimplementation suites, not edited): `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`.
- `R-EXISTING-BARRIER` (8, not edited): `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1`.
- `R-CONTRACTS` (2, not edited): `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`.

**R1 semantics after the fix.** `-IssueNumber` on both readiness predicates carries only the keyed form (`issue_num:` / `issue number:`) and is the only source of `Select-FeatureFolderTarget -DeclaredIssueNumber` (`.claude/hooks/feature-folder-resolution.ps1` lines 261-270). The new `-FallbackIssueNumber` carries the existing keyed-or-bare-hash value and is used only by the `Find-OrchestrationModeRecord` lookup, as `-IssueNumber $(if ($IssueNumber) { $IssueNumber } else { $FallbackIssueNumber })`. The D3 record lookup therefore receives the same value it receives today in every case, so the zero-candidate and unmatched-folder fallbacks are unchanged (M6a, M8, M8h). Several cited candidates with only a bare `#<n>` now remain `Ambiguous` and deny with `target-ambiguous` (M10p, M10e). `Find-OrchestrationModeRecord`, the keyed regexes, the shared resolver, and both `Test-*OrchestrationReady` wrappers are unchanged. The pre-existing Claude/Codex keyed-regex difference (`.claude/...-modes.ps1` line 263 accepts `issue number:`; `.codex/...-modes.ps1` line 263 does not) is left as is, and both surfaces receive identical edits.

**Exact edits, applied identically to RW01 and RW02** (line numbers are RW01 / RW02 at `<RB>`):

- **ED-1** (help, 255 / 255). Replace the line `        denies, so deny-by-default is preserved.` with these three lines:
  `        denies, so deny-by-default is preserved. -KeyedOnly returns the keyed form`
  `        or $null and never the bare hash form: the readiness tie-break among cited`
  `        candidates consumes only that value (issue #565, spec R4 and R6).`
- **ED-2** (259 / 259). In `Find-OrchestrationDelegationIssueNumber`, change `param([AllowNull()][AllowEmptyString()][string] $Prompt)` to `param([AllowNull()][AllowEmptyString()][string] $Prompt, [switch] $KeyedOnly)`. Anchor the Edit with the following blank line and `    if (-not $Prompt) { return $null }` (unique at line 261 in each file) because the same `param(...)` text also occurs in two other functions.
- **ED-3** (264 / 264). Directly after `    if ($keyed.Success) { return $keyed.Groups[1].Value }` insert `    if ($KeyedOnly) { return $null }`.
- **ED-4** (help, 372 and 439 / 369 and 436). After the epic help line `        #565); an unresolved tie fails as target-ambiguous.` and after the parallel help line `        unresolved tie fails as target-ambiguous.` insert, in each place, `        Only the keyed -IssueNumber breaks a tie; -FallbackIssueNumber feeds D3 only.`
- **ED-5** (param blocks, 379 and 446 / 376 and 443). In `Get-EpicOrchestrationReadinessFailure` and `Get-ParallelOrchestrationReadinessFailure` only, change `        [AllowNull()][AllowEmptyString()][string] $IssueNumber` to end with a comma and add the next line `        [AllowNull()][AllowEmptyString()][string] $FallbackIssueNumber`. Anchor each Edit with the following `    )`, blank line, `    if ($null -eq $Checkpoint) { return 'checkpoint-absent' }`, and the `route_id` line naming `'epic'` or `'parallel'`, because the same parameter text occurs in both `Test-*OrchestrationReady` wrappers, which are not edited.
- **ED-6** (404 and 467 / 401 and 464). Replace `-IssueNumber $IssueNumber` at the end of the `$record = Find-OrchestrationModeRecord -Records $features ...` line and of the `$record = Find-OrchestrationModeRecord -Records $items ...` line with `-IssueNumber $(if ($IssueNumber) { $IssueNumber } else { $FallbackIssueNumber })`.

**Edit order.** Apply ED-1 through ED-6 in numeric order, one Edit call per insertion point (ED-4, ED-5, and ED-6 are two Edit calls each). In that order each new parameter is declared (ED-2, ED-5) before it is read (ED-3, ED-6), and every intermediate state parses.

**ED-7, applied to RW03 (lines 386-391) and RW04 (lines 427-432).** Replace the six lines starting `        $issue = Find-OrchestrationDelegationIssueNumber -Prompt $prompt` and ending with the closing `        }` of the `$failure = if ($isEpic)` block with:

```
        # Only the keyed issue number breaks a tie among cited folders (#565 CR-1); the bare hash form feeds the D3 record lookup only.
        $issue = Find-OrchestrationDelegationIssueNumber -Prompt $prompt -KeyedOnly
        $fallbackIssue = Find-OrchestrationDelegationIssueNumber -Prompt $prompt
        $failure = if ($isEpic) {
            Get-EpicOrchestrationReadinessFailure -Checkpoint $modeCheckpoint -TargetFolder $folder -IssueNumber $issue -FallbackIssueNumber $fallbackIssue
        } else {
            Get-ParallelOrchestrationReadinessFailure -Checkpoint $modeCheckpoint -TargetFolder $folder -IssueNumber $issue -FallbackIssueNumber $fallbackIssue
        }
```

**ED-8 (CR-4), applied to RW05 (lines 270, 273), RW06 (lines 239, 242), RW07 (lines 321, 324).** In each file, replace the comment `    # A failed worktree-resolution import denies before any other logic (issue #690).` with `    # A failed dependency import denies before any other logic (issues #690 and #565).`, and replace the literal `the worktree-resolution module '` inside the deny string with `the dependency '`. The rest of each deny string is unchanged. The new wording covers both guarded imports in each hook (the worktree-resolution modules and `feature-folder-resolution.ps1`), which share one import-failure variable.

**Line budget (500-line cap).** At `<RB>`: RW01 489, RW02 486, RW03 466, RW04 487 lines. ED-1 adds 2, ED-3 adds 1, ED-4 adds 2, ED-5 adds 2, ED-2 and ED-6 add 0: RW01 becomes 496 and RW02 becomes 493. ED-7 adds 2: RW03 becomes 468 and RW04 becomes 489. ED-8 adds 0. The exact post-edit counts are gates (P2-T3, P2-T5, P2-T9, P3-T9, P5-T14). If a count differs, the edit deviated from this contract and is corrected before continuing; no line is removed elsewhere to compensate.

**Token counts after the fix (P2-T12).** RW01 and RW02 each: `$KeyedOnly` 2 (parameter, `if`), `$FallbackIssueNumber` 4 (two parameters, two uses), `-KeyedOnly` 1 (ED-1 help). RW03 and RW04 each: `-KeyedOnly` 1, `-FallbackIssueNumber $fallbackIssue` 2, `$KeyedOnly` 0, `$FallbackIssueNumber` 0.

## Test Case Catalogs

**CAT-R1 (RW15 Claude, RW16 Codex).** Each item is one `It` whose title begins `<ID>:`. Both suites get identical cases; only the decision helper differs (Claude envelope versus the Codex flat `tool_input`, following each suite's existing `Invoke-ModesEpicDecision` at RW15 lines 57-62 and RW16 lines 53-59).

BeforeAll additions (P1-T1, P1-T4), placed after the existing `$script:Features621` assignment:

- `$script:CrossRecords = '[{"feature_folder":"docs/features/active/target-a-with-a-much-longer-slug-301","issue_num":301,"depends_on":[],"merge_status":"merged"},' + '{"feature_folder":"docs/features/active/b-302","issue_num":302,"depends_on":[],"merge_status":"not_started"}]'` (one fixture for both epic `features` and parallel `items`).
- `$script:CrossTail = 'Execute docs/features/active/target-a-with-a-much-longer-slug-301 with context from docs/features/active/b-302 now.'`
- `$script:SingleRecord = '[{"feature_folder":"docs/features/active/child-b-301","issue_num":301,"depends_on":[],"merge_status":"not_started"}]'`
- A helper `Invoke-ModesParallelDecision` with parameters `[string] $Prompt, [string] $ItemsJson`, built exactly like the suite's `Invoke-ModesEpicDecision` but calling `ConvertTo-ModesParallelCheckpointJson -ItemsJson $ItemsJson` and passing `-ParallelCheckpointRaw $raw` (declared at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 307 and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` line 358).

Context `issue #565 CR-1: only the keyed issue number breaks a tie` (P1-T2, P1-T5):

- **M10p**: `Invoke-ModesParallelDecision -Prompt ('Parallel mode: true. Coordinate with #302. ' + $script:CrossTail) -ItemsJson $script:CrossRecords` → `permissionDecision` is `deny`; `permissionDecisionReason` matches `^PREIMPLEMENTATION_GATE_BLOCKED:`, `target-ambiguous`, `target-a-with-a-much-longer-slug-301`, and `b-302`. This is the review's reproduction prompt (`remediation-inputs.2026-10-08T19-24.md` line 28).
- **M10e**: `Invoke-ModesEpicDecision -Prompt ('Epic mode: true. Coordinate with #302. ' + $script:CrossTail) -FeaturesJson $script:CrossRecords` → same four assertions.
- **M11p**: parallel decision with prompt `'Parallel mode: true. issue_num: 301. Coordinate with #302. ' + $script:CrossTail` → `deny`; reason matches `predicate is 'merge_status'` and does not match `target-ambiguous` (the keyed number selects the terminal target 301 even though a bare `#302` is present).
- **M11e**: epic decision with prompt `'Epic mode: true. issue_num: 301. Coordinate with #302. ' + $script:CrossTail` → same two assertions.

Context `issue #565 CR-1: keyed-only issue source and the D3 hash fallback` (P1-T3, P1-T6):

- **M12a**: `Find-OrchestrationDelegationIssueNumber -Prompt 'Parallel mode: true. Coordinate with #302.' -KeyedOnly | Should -BeNullOrEmpty`.
- **M12b**: `Find-OrchestrationDelegationIssueNumber -Prompt 'Parallel mode: true. issue_num: 301. Coordinate with #302.' -KeyedOnly | Should -Be '301'`.
- **M12c**: `Find-OrchestrationDelegationIssueNumber -Prompt 'Parallel mode: true. Coordinate with #302.' | Should -Be '302'` (default behavior unchanged).
- **M8h**: `Invoke-ModesEpicDecision -Prompt 'Epic mode: true. Deliver the fix for #301 in this wave.' -FeaturesJson $script:SingleRecord` → `allow` (zero candidates; the bare hash form still reaches the D3 record lookup).
- **M8m**: same records, prompt `'Epic mode: true. Deliver the fix in this wave.'` → `deny`, reason matches `predicate is 'target-record'` (shows the M8h allow comes from the hash fallback).

Expected results: before the fix, M10p, M10e, M12a, and M12b fail (M10p/M10e currently allow; M12a/M12b bind an unknown parameter) and the other five pass, so each suite reports `Passed=21` and four `FAILED:` lines. After the fix, each suite reports `Passed=25` (16 existing cases plus 9). The deny-reason format `... the failed readiness predicate is '<failure>' ...` is produced by `Get-OrchestrationModeDenyReason` (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 112-125; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 325-337).

**CR-4 assertions (RW17, RW18, RW19).** Directly after the existing line `$decision.permissionDecisionReason | Should -Match 'feature-folder-resolution\.ps1'` in W9 (RW17 line 208), C7 (RW18 line 142), and D7 (RW19 line 144), add `$decision.permissionDecisionReason | Should -Match "the dependency 'feature-folder-resolution\.ps1' failed to import"`. No other line in those suites changes.

## Command Templates

Reused unchanged from `FEATURE/plan.2026-10-08T13-52.md` (Command Templates section, lines 118-130), with the `c2-565-r1-` script prefix: RESET, TPC, FMT, ANZ, SUITE, JUNIT, CRC, HASH, LC, PUR. CLC is reused with `$mb = '<RB>'`. Recorded runs of each template exist in this feature's evidence (for example `evidence/qa-gates/coverage-perfile.3.2026-10-08T19-13.md`, `evidence/qa-gates/pester-full-selfhosted.3.2026-10-08T19-13.md`, `evidence/qa-gates/mirror-hashes.3.2026-10-08T18-57.md`, `evidence/other/targeted-codex-contracts.2026-10-08T19-25.md`), so every asserted output line below is a line those templates print on a successful run. New templates:

- **PARSE** (PowerShell route): `foreach ($p in @(<PATHS>)) { $t = $null; $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $p).Path, [ref]$t, [ref]$e); 'PARSE ' + $p + ' Errors=' + $e.Count }`. Pass: every line ends `Errors=0`.
- **TOKENS** (PowerShell route): `foreach ($p in @(<PATHS>)) { $t = Get-Content -Raw -LiteralPath $p; $c = { param($s) ([regex]::Matches($t, [regex]::Escape($s))).Count }; 'TOKENS ' + $p + ' KeyedOnlyVar=' + (& $c '$KeyedOnly') + ' FallbackVar=' + (& $c '$FallbackIssueNumber') + ' KeyedOnlySwitch=' + (& $c '-KeyedOnly') + ' FallbackArg=' + (& $c '-FallbackIssueNumber $fallbackIssue') }`.
- **HASH-LIST-R** (PowerShell route): `foreach ($p in @(<the 19 RW paths, RW01..RW19, written literally>)) { (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash + ' ' + $p }`. Output: 19 lines.
- **FAILROWS** (PowerShell route): `$m = @(Select-String -LiteralPath artifacts/pr_context.summary.txt -SimpleMatch -Pattern 'Normalized result: fail' -Context 4,0); 'FAIL-ROWS=' + $m.Count; $m | ForEach-Object { 'FAIL-SOURCE ' + (($_.Context.PreContext | Where-Object { $_ -match 'Source: ' }) -replace '^\s*- Source: ', '') }; exit ([int]($m.Count -gt 0))`. The collector prints each verification row as `  - Source: <path>`, `  - Timestamp:`, `  - Command:`, `  - EXIT_CODE:`, then `  - Normalized result: <pass|fail>` (`scripts/dev_tools/pr_context/collector_documents.py` line 109; observed at `artifacts/pr_context.summary.txt` lines 869-873 on the reviewed head), so the `Source:` line is the fourth line of pre-context.
- **COLLECT** (Bash): `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt` (the command the policy audit ran, `policy-audit.2026-10-08T19-24.md` line 438).
- **PYADD** (PowerShell route): `$a = @(git diff -U0 '<RB>' -- <R-PROD paths> | Where-Object { $_ -match '^\+' -and $_ -notmatch '^\+\+\+' -and $_ -match '(?i)\b(python|poetry)\b' }); 'PYTHON-ADDED=' + $a.Count; $a`. Pass: `PYTHON-ADDED=0`.

## Phases

### Phase 0 — Policy Reads and Remediation Baseline

All Phase 0 artifacts are written under `FEATURE/evidence/remediation-baseline/`. No source file changes in this phase.

- [x] [P0-T1] Write `<scratchpad>/c2-565-r1-run.sh` with exactly the two lines `pwsh -NoProfile -File "$1"` and `exit $?`. Acceptance: the file exists with those two lines.
- [x] [P0-T2] Read `CLAUDE.md` in full; record it as policy entry 1 for P0-T12. Acceptance: file read.
- [x] [P0-T3] Read `.claude/rules/general-code-change.md` in full; record it as policy entry 2. Acceptance: file read.
- [x] [P0-T4] Read `.claude/rules/general-unit-test.md` in full; record it as policy entry 3. Acceptance: file read.
- [x] [P0-T5] Read `.claude/rules/quality-tiers.md` in full; record it as policy entry 4. Acceptance: file read.
- [x] [P0-T6] Read `.claude/rules/powershell.md` in full; record it as policy entry 5. Acceptance: file read.
- [x] [P0-T7] Read `FEATURE/remediation-inputs.2026-10-08T19-24.md` in full. Acceptance: file read; R1 and the non-blocking list (CR-2, CR-3, CR-4, PA-2, PA-3, AC item 30) noted.
- [x] [P0-T8] Read `FEATURE/code-review.2026-10-08T19-24.md` in full. Acceptance: file read; CR-1 through CR-7 noted.
- [x] [P0-T9] Read `FEATURE/policy-audit.2026-10-08T19-24.md` in full. Acceptance: file read; PA-1 through PA-5 noted.
- [x] [P0-T10] Read `FEATURE/feature-audit.2026-10-08T19-24.md` in full. Acceptance: file read; AC item 30 noted as UNVERIFIED.
- [x] [P0-T11] Read `FEATURE/spec.md` in full, including Proposed Fix R4 and R6 (lines 97-103), the Callers paragraph (line 173), and the Declared issue number contract (line 199). Acceptance: file read.
- [x] [P0-T12] Write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<ts>.md` with `Timestamp:`, `Command: Read tool (full-file reads)`, `EXIT_CODE: 0`, `Output Summary:`, `Policy Order:` listing P0-T2..P0-T6 in order, and the ten files read in P0-T2..P0-T11. Acceptance: the artifact exists with the five named fields (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `Policy Order:`) and ten file entries.
- [x] [P0-T13] Record the remediation base: run `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, and `git status --porcelain` as three Bash calls; write `FEATURE/evidence/remediation-baseline/remediation-base.<ts>.md` with the three outputs and `RemediationBase: <40-hex>` from the second. Acceptance: the first output is exactly `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565`, the SHA is 40 hex characters, and the porcelain output lists no path other than `FEATURE/remediation-plan.2026-10-08T19-24.md` and files under `FEATURE/evidence/remediation-baseline/`; otherwise stop.
- [x] [P0-T14] Line counts: run LC over R-PROD and R-TESTS (12 paths); write `FEATURE/evidence/remediation-baseline/line-counts.<ts>.md`. Acceptance: `LINES 489` for RW01, `LINES 486` for RW02, `LINES 466` for RW03, `LINES 487` for RW04, every value at most 500. A different value for RW01..RW04 means the tree differs from the one this plan was derived against; stop and report.
- [x] [P0-T15] Mirror parity: run HASH over R-PAIRS; write `FEATURE/evidence/remediation-baseline/mirror-hashes.<ts>.md`. Acceptance: 7 `MATCH` lines, 0 `MISMATCH`.
- [x] [P0-T16] Format check (non-writing): run FMT over R-PROD and R-TESTS (12 paths); write `FEATURE/evidence/remediation-baseline/format-check.<ts>.md`. Acceptance: 12 `FORMAT-CLEAN` lines and exit 0. A `FORMAT-DRIFT` line is recorded as pre-existing drift and named in the artifact; the final gate P5-T2 still requires `FORMAT-CLEAN` for all 12.
- [x] [P0-T17] Analyzer: run ANZ over R-PROD and R-TESTS (12 paths); write `FEATURE/evidence/remediation-baseline/analyze-selfhosted.<ts>.md`. Acceptance: the `Findings=` line is recorded with its number (expected `Findings=0`).
- [x] [P0-T18] Targeted tests: run TPC over R-TESTS (5 paths); write `FEATURE/evidence/remediation-baseline/targeted-pester.<ts>.md`. Acceptance: exit 0 and a summary line containing `Failed=0 FailedBlocks=0 FailedContainers=0`.
- [x] [P0-T19] Existing preimplementation suites: run TPC over R-EXISTING-PRE (18 paths); write `FEATURE/evidence/remediation-baseline/existing-preimplementation-pester.<ts>.md`. Acceptance: exit 0, `Failed=0 FailedBlocks=0 FailedContainers=0`, and the `Passed=` value recorded for comparison with P2-T15.
- [x] [P0-T20] Existing barrier and Codex contract suites: run TPC over R-EXISTING-BARRIER plus R-CONTRACTS (10 paths); write `FEATURE/evidence/remediation-baseline/existing-barrier-contract-pester.<ts>.md`. Acceptance: exit 0, `Failed=0 FailedBlocks=0 FailedContainers=0`, `Passed=` recorded.
- [x] [P0-T21] RESET (baseline window); write `FEATURE/evidence/other/batch-budget-reset-rem1-0.<ts>.md`. This also removes the `.claude/state/` batch-budget files that the issue #510 local false failure reads, before the contract and full-suite runs. Acceptance: `REMAINING 0`.
- [x] [P0-T22] Bundle contracts: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py`; write `FEATURE/evidence/remediation-baseline/pytest-bundle-contracts.<ts>.md`. Acceptance: exit 0 and a summary line containing `passed` with its count recorded.
- [x] [P0-T23] Full self-hosted suite with coverage: run SUITE; write `FEATURE/evidence/remediation-baseline/pester-full-selfhosted.<ts>.md` with the exit code, the `Tests Passed:` line, and the `Covered` line. Acceptance: both lines recorded with numbers, and `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` were written during this run (last-write time after the run start).
- [x] [P0-T24] Baseline failing set: run JUNIT; write `FEATURE/evidence/remediation-baseline/junit-failing-set.<ts>.md`. Acceptance: `JUnitFailures=2` and the two `FAILCASE` lines are identical to lines 11-12 of `FEATURE/evidence/baseline/junit-failing-set.2026-10-08T17-53.md`; `BlockOrContainerFailures=` equals the P0-T23 exit code minus 2 and is 0. When these hold, add `ExpectedExitCode: 2` to the P0-T23 artifact. Otherwise record the observed values verbatim in the artifact and stop: the baseline failing set differs from the one this plan compares against at P5-T10.
- [x] [P0-T25] Baseline per-file coverage: run CRC over R-PROD (7 paths); write `FEATURE/evidence/remediation-baseline/coverage-perfile.<ts>.md` with Covered, Missed, and percentage to two decimals per path. Acceptance: seven rows, each `Files=1`, each with numeric Covered and Missed values.
- [x] [P0-T26] PA-3 fail-before: run COLLECT, then FAILROWS; write `FEATURE/evidence/remediation-baseline/pr-context-fail-rows.<ts>.md` with both commands, FAILROWS's exit code as `EXIT_CODE:`, and `ExpectedExitCode: 1`. Acceptance: COLLECT exits 0; FAILROWS prints `FAIL-ROWS=1` and one `FAIL-SOURCE` line ending `evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md`. A different count is recorded verbatim and every listed source is added to the Phase 4 relocation set before P4-T1 runs.
- [x] [P0-T27] Commit and push Phase 0: Bash calls `git add FEATURE/remediation-plan.2026-10-08T19-24.md FEATURE/evidence/remediation-baseline FEATURE/evidence/other`, `git commit -m "docs(565): capture remediation cycle 1 baseline"`, `git push origin BRANCH`, `git rev-parse HEAD`, `git rev-parse origin/BRANCH`, `git status --porcelain`. Acceptance: commit and push exit 0, the two `rev-parse` outputs are equal, and the porcelain output lists at most `FEATURE/remediation-plan.2026-10-08T19-24.md` (this task's checkbox).

### Phase 1 — CR-1 Fail-Before Regression Tests

- [x] [P1-T1] RW15 (Claude): add the CAT-R1 BeforeAll additions (`$script:CrossRecords`, `$script:CrossTail`, `$script:SingleRecord`, `Invoke-ModesParallelDecision`) inside the existing `BeforeAll` after the `$script:Features621` assignment. Acceptance: the four names are defined once each in RW15 and no existing line is modified.
- [x] [P1-T2] RW15: add Context `issue #565 CR-1: only the keyed issue number breaks a tie` containing It cases M10p, M10e, M11p, M11e exactly as in CAT-R1. Acceptance: four `It` titles beginning `M10p:`, `M10e:`, `M11p:`, `M11e:` exist in RW15.
- [x] [P1-T3] RW15: add Context `issue #565 CR-1: keyed-only issue source and the D3 hash fallback` containing M12a, M12b, M12c, M8h, M8m exactly as in CAT-R1. Acceptance: five `It` titles beginning `M12a:`, `M12b:`, `M12c:`, `M8h:`, `M8m:` exist in RW15.
- [x] [P1-T4] RW16 (Codex): add the same BeforeAll additions, with `Invoke-ModesParallelDecision` using the flat `tool_input` idiom of RW16's `Invoke-ModesEpicDecision`. Acceptance: the four names are defined once each in RW16 and no existing line is modified.
- [x] [P1-T5] RW16: add the Context from P1-T2 with M10p, M10e, M11p, M11e. Acceptance: the four `It` titles exist in RW16.
- [x] [P1-T6] RW16: add the Context from P1-T3 with M12a, M12b, M12c, M8h, M8m. Acceptance: the five `It` titles exist in RW16.
- [x] [P1-T7] Test purity: run PUR over RW15 and RW16; write `FEATURE/evidence/other/purity-cr1-tests.<ts>.md`. Acceptance: two `PURITY-CLEAN` lines.
- [x] [P1-T8] [expect-fail] Fail-before (Claude): run TPC over RW15; write `FEATURE/evidence/regression-testing/fail-before-cr1-claude.<ts>.md` with `ExpectedExitCode: 1`. Acceptance: exit 1; summary line `Passed=21 Failed=4 FailedBlocks=0 FailedContainers=0`; exactly four `FAILED:` lines whose final segments begin `M10p:`, `M10e:`, `M12a:`, `M12b:`.
- [x] [P1-T9] [expect-fail] Fail-before (Codex): run TPC over RW16; write `FEATURE/evidence/regression-testing/fail-before-cr1-codex.<ts>.md` with `ExpectedExitCode: 1`. Acceptance: the same counts and the same four case IDs as P1-T8.
- [x] [P1-T10] Commit and push Phase 1: `git add` RW15, RW16, `FEATURE/evidence`, and `FEATURE/remediation-plan.2026-10-08T19-24.md`; `git commit -m "test(565): add keyed-only tie-break regression cases on both surfaces"`; `git push origin BRANCH`; then `git rev-parse HEAD`, `git rev-parse origin/BRANCH`, `git status --porcelain`. Acceptance: as P0-T27.

### Phase 2 — CR-1 Fix on Both Surfaces

- [x] [P2-T1] RESET (window W-R1); write `FEATURE/evidence/other/batch-budget-reset-rem1-1.<ts>.md`. Acceptance: `REMAINING 0`.
- [x] [P2-T2] Apply ED-1 through ED-6 to RW01 with Edit. Acceptance: each ED anchor was replaced exactly once and no other line changed.
- [x] [P2-T3] Parse and size RW01: run PARSE and LC over RW01; write `FEATURE/evidence/other/parse-size-rw01.<ts>.md`. Acceptance: `Errors=0` and `LINES 496`. On `Errors=` greater than 0, follow live-hook rule 1.
- [x] [P2-T4] Apply ED-7 to RW03 with Edit as one replacement. Acceptance: the six original lines are replaced by the eight ED-7 lines and no other line changed.
- [x] [P2-T5] Parse and size RW03: run PARSE and LC over RW03; write `FEATURE/evidence/other/parse-size-rw03.<ts>.md`. Acceptance: `Errors=0` and `LINES 468`. On `Errors=` greater than 0, follow live-hook rule 1.
- [x] [P2-T6] Apply ED-1 through ED-6 to RW02 with Edit (third file in W-R1). Acceptance: each ED anchor was replaced exactly once and no other line changed.
- [x] [P2-T7] RESET (window W-R2); write `FEATURE/evidence/other/batch-budget-reset-rem1-2.<ts>.md`. Acceptance: `REMAINING 0`.
- [x] [P2-T8] Apply ED-7 to RW04 with Edit as one replacement. Acceptance: the six original lines are replaced by the eight ED-7 lines and no other line changed.
- [x] [P2-T9] Parse and size the Codex files: run PARSE and LC over RW02 and RW04; write `FEATURE/evidence/other/parse-size-codex.<ts>.md`. Acceptance: two `Errors=0` lines, `LINES 493` for RW02, `LINES 489` for RW04.
- [x] [P2-T10] Copy mirrors: `Copy-Item` RW01→RW08, RW03→RW09, RW02→RW13, RW04→RW14 on the PowerShell route. Acceptance: four copies complete with exit 0.
- [x] [P2-T11] Mirror parity for the CR-1 pairs: run HASH over (RW01,RW08), (RW03,RW09), (RW02,RW13), (RW04,RW14); write `FEATURE/evidence/other/mirror-hashes-cr1.<ts>.md`. Acceptance: 4 `MATCH`, 0 `MISMATCH`.
- [x] [P2-T12] Surface symmetry: run TOKENS over RW01, RW02, RW03, RW04; write `FEATURE/evidence/other/cr1-symmetry.<ts>.md`. Acceptance: RW01 and RW02 each print `KeyedOnlyVar=2 FallbackVar=4 KeyedOnlySwitch=1 FallbackArg=0`; RW03 and RW04 each print `KeyedOnlyVar=0 FallbackVar=0 KeyedOnlySwitch=1 FallbackArg=2`.
- [x] [P2-T13] Pass-after (Claude): run TPC over RW15; write `FEATURE/evidence/regression-testing/pass-after-cr1-claude.<ts>.md`. Acceptance: exit 0 and `Passed=25 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0`.
- [x] [P2-T14] Pass-after (Codex): run TPC over RW16; write `FEATURE/evidence/regression-testing/pass-after-cr1-codex.<ts>.md`. Acceptance: exit 0 and `Passed=25 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0`.
- [x] [P2-T15] Existing preimplementation suites after the fix: run TPC over R-EXISTING-PRE (18 paths); write `FEATURE/evidence/regression-testing/existing-preimplementation-cr1.<ts>.md`. Acceptance: exit 0, `Failed=0 FailedBlocks=0 FailedContainers=0`, and `Passed=` equal to the P0-T19 value. A failure triggers the test-integrity rule (stop and report).
- [x] [P2-T16] Codex contract suites after the fix: run TPC over R-CONTRACTS; write `FEATURE/evidence/regression-testing/codex-contracts-cr1.<ts>.md`. Acceptance: exit 0 and `Failed=0 FailedBlocks=0 FailedContainers=0`.
- [x] [P2-T17] Commit and push Phase 2: `git add` RW01, RW02, RW03, RW04, RW08, RW09, RW13, RW14, `FEATURE/evidence`, and `FEATURE/remediation-plan.2026-10-08T19-24.md`; `git commit -m "fix(565): restrict the -modes tie-break to the keyed issue number"`; `git push origin BRANCH`; then `git rev-parse HEAD`, `git rev-parse origin/BRANCH`, `git status --porcelain`. Acceptance: as P0-T27.

### Phase 3 — CR-4 Barrier Import-Failure Wording

- [x] [P3-T1] RW17: add the CR-4 assertion line to W9 after RW17 line 208. Acceptance: W9 contains the new `Should -Match "the dependency 'feature-folder-resolution\.ps1' failed to import"` line and no other line changed.
- [x] [P3-T2] RW18: add the same assertion line to C7 after RW18 line 142. Acceptance: as P3-T1 for C7.
- [x] [P3-T3] RW19: add the same assertion line to D7 after RW19 line 144. Acceptance: as P3-T1 for D7.
- [x] [P3-T4] [expect-fail] Fail-before CR-4: run TPC over RW17, RW18, RW19; write `FEATURE/evidence/regression-testing/fail-before-cr4.<ts>.md` with `ExpectedExitCode: 1`. Acceptance: exit 1; `Failed=3 FailedBlocks=0 FailedContainers=0`; exactly three `FAILED:` lines whose final segments begin `W9:`, `C7:`, `D7:`.
- [x] [P3-T5] RESET (window W-R3); write `FEATURE/evidence/other/batch-budget-reset-rem1-3.<ts>.md`. Acceptance: `REMAINING 0`.
- [x] [P3-T6] Apply ED-8 to RW05 (lines 270 and 273). Acceptance: the comment line and the literal on line 273 are replaced; no other line changed.
- [x] [P3-T7] Apply ED-8 to RW06 (lines 239 and 242). Acceptance: as P3-T6.
- [x] [P3-T8] Apply ED-8 to RW07 (lines 321 and 324). Acceptance: as P3-T6.
- [x] [P3-T9] Parse and size the barriers: run PARSE and LC over RW05, RW06, RW07; write `FEATURE/evidence/other/parse-size-barriers.<ts>.md`. Acceptance: three `Errors=0` lines and each `LINES` value equal to its P0-T14 value.
- [x] [P3-T10] Copy mirrors: `Copy-Item` RW05→RW10, RW06→RW11, RW07→RW12. Acceptance: three copies complete with exit 0.
- [x] [P3-T11] Mirror parity for the CR-4 pairs: run HASH over (RW05,RW10), (RW06,RW11), (RW07,RW12); write `FEATURE/evidence/other/mirror-hashes-cr4.<ts>.md`. Acceptance: 3 `MATCH`, 0 `MISMATCH`.
- [x] [P3-T12] Pass-after CR-4: run TPC over RW17, RW18, RW19; write `FEATURE/evidence/regression-testing/pass-after-cr4.<ts>.md`. Acceptance: exit 0 and `Failed=0 FailedBlocks=0 FailedContainers=0`.
- [x] [P3-T13] Existing barrier suites after the wording change: run TPC over R-EXISTING-BARRIER (8 paths); write `FEATURE/evidence/regression-testing/existing-barrier-cr4.<ts>.md`. Acceptance: exit 0, `Failed=0 FailedBlocks=0 FailedContainers=0`.
- [x] [P3-T14] Old wording absent: in Bash run `grep -c "worktree-resolution module '" .claude/hooks/enforce-epic-wave-barrier.ps1 .claude/hooks/enforce-parallel-cohort-barrier.ps1 .claude/hooks/enforce-parallel-drift-gate.ps1` and `grep -c "the dependency '" .claude/hooks/enforce-epic-wave-barrier.ps1 .claude/hooks/enforce-parallel-cohort-barrier.ps1 .claude/hooks/enforce-parallel-drift-gate.ps1`; write `FEATURE/evidence/other/cr4-wording.<ts>.md` recording the second command's exit code as `EXIT_CODE:`. Acceptance: the first command prints `:0` for all three files; the second prints `:1` for all three files.
- [x] [P3-T15] Commit and push Phase 3: `git add` RW05, RW06, RW07, RW10, RW11, RW12, RW17, RW18, RW19, `FEATURE/evidence`, and `FEATURE/remediation-plan.2026-10-08T19-24.md`; `git commit -m "fix(565): name a failed barrier import as a dependency"`; `git push origin BRANCH`; then `git rev-parse HEAD`, `git rev-parse origin/BRANCH`, `git status --porcelain`. Acceptance: as P0-T27.

### Phase 4 — PA-3 Relocation, CR-3 Record, and Follow-Ups

**PA-3 decision.** The caller preferred `evidence/other/`. That folder is collected by the PR-context collector (`scripts/dev_tools/pr_context/verification_evidence.py` line 27), so a move there would keep the `fail` row. The artifact therefore moves to `FEATURE/evidence/remediation-baseline/superseded/`, which is the location the policy audit recommends (`policy-audit.2026-10-08T19-24.md` line 317) and is not collected. `.claude/hooks/enforce-evidence-locations.ps1` blocks only the `artifacts/` prefixes it lists (lines 17 and 70), so the nested path is permitted. Historical citations in the three review artifacts, `remediation-inputs.2026-10-08T19-24.md`, and the porcelain listings in `evidence/qa-gates/format-mcp.2.2026-10-08T19-56.md` and `format-mcp.3.2026-10-08T18-56.md` record the original location and are not edited.

- [x] [P4-T1] Write `FEATURE/evidence/remediation-baseline/superseded/analyze-selfhosted.1.2026-10-08T19-50.md` with the full content of `FEATURE/evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md`, unchanged, plus one line inserted directly after its `Output Summary:` line: `Superseded: evidence/qa-gates/analyze-selfhosted.3.2026-10-08T18-57.md (Findings=0). Relocated from evidence/qa-gates/ by remediation cycle 1 (PA-3) so the PR context does not render this iteration-1 result as a failing gate.` Acceptance: the new file exists with that line.
- [x] [P4-T2] Remove the original: in Bash run `git rm FEATURE/evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md`. Acceptance: exit 0 and the original path no longer exists on disk.
- [x] [P4-T3] Content-preservation check (PowerShell route): `$o = @(git show 'HEAD:FEATURE/evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md'); $n = @(Get-Content -LiteralPath 'FEATURE/evidence/remediation-baseline/superseded/analyze-selfhosted.1.2026-10-08T19-50.md' | Where-Object { $_ -notlike 'Superseded: *' }); if (($o -join "`n") -ceq ($n -join "`n")) { 'CONTENT-PRESERVED' } else { 'CONTENT-CHANGED'; exit 1 }` (FEATURE substituted); write `FEATURE/evidence/other/pa3-relocation.<ts>.md`. Acceptance: `CONTENT-PRESERVED` and exit 0.
- [x] [P4-T4] Update the one forward citation: in `FEATURE/evidence/qa-gates/qc-loop.2026-10-08T19-15.md` line 10, replace `qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md` with `remediation-baseline/superseded/analyze-selfhosted.1.2026-10-08T19-50.md`. Acceptance: in Bash, `grep -c "remediation-baseline/superseded/analyze-selfhosted.1" FEATURE/evidence/qa-gates/qc-loop.2026-10-08T19-15.md` prints `1`.
- [x] [P4-T5] CR-3 record: write `FEATURE/evidence/other/cr3-mode-record-deviation.<ts>.md` with `Command:` the Bash call `grep -n "function Find-OrchestrationModeRecord" .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, its `EXIT_CODE:`, and an `Output Summary:` stating: spec "Callers" (`FEATURE/spec.md` line 173) says `Find-OrchestrationModeRecord` becomes a thin delegate; it was left unchanged in both surfaces; it compares with case-insensitive `-eq` while `Find-FeatureFolderRecord` compares ordinally; its existing semantics are pinned by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` lines 238-239 (first-match issue fallback) and line 297 (renamed-folder fallback), and the Codex copy iterates per record (`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 340-351); this cycle records the deviation and does not refactor; conversion is a follow-up candidate for C1b (#732). Acceptance: the artifact exists with all four schema fields and the grep prints two matches.
- [x] [P4-T6] Follow-up record: write `FEATURE/evidence/other/follow-ups-remediation-1.<ts>.md` with `Command: none (record only)`, `EXIT_CODE: 0`, and an `Output Summary:` listing, each marked "recorded, not filed": CR-2 (extend the R1 trim set to `)`, `]`, `>`, `*`, `_`; requires a spec R1 amendment), CR-3 (P4-T5), PA-1 (repo-wide PowerShell line coverage below 85%, pre-existing, non-blocking under the 2026-09-30 operator decision), PA-2 (keep `evidence/other/timestamp-correction.2026-10-08T18-46.md` referenced in the PR description), and AC item 30 (seven contract suites must pass in CI on the pull request; unchecked; an epic-child PR may need a manual `workflow_dispatch` of `ci.yml`). Acceptance: the artifact exists and names all five items.
- [ ] [P4-T7] Commit and push Phase 4: `git add FEATURE/evidence FEATURE/remediation-plan.2026-10-08T19-24.md` (stages the P4-T2 removal, the new file, and the qc-loop edit); `git commit -m "docs(565): relocate the superseded analyzer artifact and record CR-3 and follow-ups"`; `git push origin BRANCH`; then `git rev-parse HEAD`, `git rev-parse origin/BRANCH`, `git status --porcelain`. Acceptance: as P0-T27.

### Phase 5 — Final QC Loop and Remediation Closure

Loop rule: run P5-T1 through P5-T18 as iteration n (starting at 1). If any task fails or changes a file (including P5-T3), fix the cause, apply the superseded-artifact rule to every failing artifact of iteration n, re-run any affected copy task (P2-T10, P3-T10), and restart at P5-T1 with n+1. Artifact names carry `.rem1-<n>.` before `<ts>`. The loop ends when one iteration passes every task with no file changed.

- [ ] [P5-T1] RESET (final, iteration n); write `FEATURE/evidence/other/batch-budget-reset-rem1-final-<n>.<ts>.md`. Acceptance: `REMAINING 0`.
- [ ] [P5-T2] Format check (non-writing): run FMT over R-PROD and R-TESTS (12 paths); write `FEATURE/evidence/qa-gates/format-check.rem1-<n>.<ts>.md`. Acceptance: 12 `FORMAT-CLEAN` lines, 0 `FORMAT-DRIFT`, exit 0.
- [ ] [P5-T3] PoshQC format, no-change observation: run HASH-LIST-R, then `git status --porcelain --untracked-files=all`, then call `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root absolute path (call argument only), then HASH-LIST-R and `git status --porcelain --untracked-files=all` again; write `FEATURE/evidence/qa-gates/format-mcp.rem1-<n>.<ts>.md` with the MCP result text (worktree root replaced by `<worktree-root>`), both HASH-LIST-R outputs, both porcelain outputs, and a `RESTORED:` line. Acceptance: the two HASH-LIST-R outputs are identical (19 lines each), and the two porcelain listings are identical after removing the paths listed on `RESTORED:`; the artifact's `Output Summary:` states "no change" in those words. A path outside RW01-RW19 and FEATURE that the formatter changed is restored with `git checkout -- <path>` and listed on `RESTORED:`; any change to an RW path fails the iteration.
- [ ] [P5-T4] Mirror parity: run HASH over R-PAIRS; write `FEATURE/evidence/qa-gates/mirror-hashes.rem1-<n>.<ts>.md`. Acceptance: 7 `MATCH`, 0 `MISMATCH`.
- [ ] [P5-T5] Analyzer: run ANZ over R-PROD and R-TESTS (12 paths); write `FEATURE/evidence/qa-gates/analyze-selfhosted.rem1-<n>.<ts>.md`. Acceptance: `Findings=0` and exit 0.
- [ ] [P5-T6] Targeted suites: run TPC over R-TESTS (5 paths); write `FEATURE/evidence/qa-gates/targeted-pester.rem1-<n>.<ts>.md`. Acceptance: exit 0, `Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0`, and `Passed=` equal to the P0-T18 value plus 18.
- [ ] [P5-T7] Existing suites: run TPC over R-EXISTING-PRE, R-EXISTING-BARRIER, and R-CONTRACTS (28 paths); write `FEATURE/evidence/qa-gates/existing-suites.rem1-<n>.<ts>.md`. Acceptance: exit 0, `Failed=0 FailedBlocks=0 FailedContainers=0`, and `Passed=` equal to the sum of the P0-T19 and P0-T20 values.
- [ ] [P5-T8] Bundle contracts: re-run the P0-T22 `poetry run pytest` command; write `FEATURE/evidence/qa-gates/pytest-bundle-contracts.rem1-<n>.<ts>.md`. Acceptance: exit 0 and a `passed` summary line whose count equals the P0-T22 count.
- [ ] [P5-T9] Full self-hosted suite with coverage: run SUITE; write `FEATURE/evidence/qa-gates/pester-full-selfhosted.rem1-<n>.<ts>.md` with the exit code, the `Tests Passed:` line, and the `Covered` line. Acceptance: both lines recorded with numbers; the `Tests Passed:` value equals the P0-T23 value plus 18 (the nine CAT-R1 cases on each surface; the W9, C7, and D7 changes add assertions, not cases); `artifacts/pester/powershell-coverage.xml` was written during this run.
- [ ] [P5-T10] Failing set: run JUNIT; write `FEATURE/evidence/qa-gates/junit-failing-set.rem1-<n>.<ts>.md`. Acceptance: `JUnitFailures=2`; the two `FAILCASE` lines are identical to lines 11-12 of `FEATURE/evidence/baseline/junit-failing-set.2026-10-08T17-53.md`; `BlockOrContainerFailures=0` (P5-T9 exit code minus 2). When all three hold, add `ExpectedExitCode: 2` to the P5-T9 artifact; otherwise the iteration fails.
- [ ] [P5-T11] Per-file coverage: run CRC over R-PROD (7 paths); write `FEATURE/evidence/qa-gates/coverage-perfile.rem1-<n>.<ts>.md` with percentages to two decimals. Acceptance: seven rows, each `Files=1`, each percentage at least 85.00, including both `-modes.ps1` rows (RW01, RW02), and each row's `Missed=` at most its P0-T25 value.
- [ ] [P5-T12] Changed-line coverage: run CLC with `$mb = '<RB>'` over R-PROD; write `FEATURE/evidence/qa-gates/coverage-changed-lines.rem1-<n>.<ts>.md`. Acceptance: for each of the seven paths, `Uncovered=` is empty.
- [ ] [P5-T13] Coverage comparison: write `FEATURE/evidence/qa-gates/coverage-comparison.rem1-<n>.<ts>.md` with `Command: comparison of P0-T25, P5-T11, P5-T12 outputs`, `EXIT_CODE: 0`, and one row per R-PROD path giving baseline percent (P0-T25), post-change percent (P5-T11), changed-line covered/executable (P5-T12), and verdict. Acceptance: seven rows, every verdict `PASS` (post-change at least 85.00, Missed not above baseline, no uncovered changed line).
- [ ] [P5-T14] Size: run LC over R-PROD and R-TESTS; write `FEATURE/evidence/qa-gates/line-counts.rem1-<n>.<ts>.md`. Acceptance: `LINES 496` (RW01), `LINES 493` (RW02), `LINES 468` (RW03), `LINES 489` (RW04), RW05-RW07 equal to their P0-T14 values, and every value at most 500.
- [ ] [P5-T15] Test purity: run PUR over R-TESTS (5 paths); write `FEATURE/evidence/qa-gates/test-purity.rem1-<n>.<ts>.md`. Acceptance: five `PURITY-CLEAN` lines.
- [ ] [P5-T16] No Python added: run PYADD; write `FEATURE/evidence/qa-gates/no-python.rem1-<n>.<ts>.md`. Acceptance: `PYTHON-ADDED=0`.
- [ ] [P5-T17] Test-scope check: in Bash run `git diff --stat <RB> -- tests` and `git status --porcelain -- tests`; write `FEATURE/evidence/qa-gates/test-scope.rem1-<n>.<ts>.md`. Acceptance: the diff stat lists exactly the five R-TESTS paths (after the Phase 1 and Phase 3 commits) and the porcelain output is empty, so no other test file was changed or created.
- [ ] [P5-T18] PR-context fail rows: run COLLECT, then FAILROWS; write `FEATURE/evidence/qa-gates/pr-context-fail-rows.rem1-<n>.<ts>.md` with FAILROWS's exit code as `EXIT_CODE:`. Acceptance: COLLECT exits 0; FAILROWS prints `FAIL-ROWS=0` and exits 0.
- [ ] [P5-T19] Loop record: write `FEATURE/evidence/qa-gates/qc-loop-rem1.<ts>.md` with `Command: record of P5-T1..P5-T18 iterations (no new command)`, `EXIT_CODE: 0`, and one row per iteration naming the failed or file-changing tasks and their remediation. Acceptance: the last row shows P5-T1..P5-T18 all passing with no file changed.
- [ ] [P5-T20] Commit and push the final state: `git add FEATURE/evidence FEATURE/remediation-plan.2026-10-08T19-24.md` plus any RW path changed during the loop; `git commit -m "docs(565): close the remediation cycle 1 final QC loop"`; `git push origin BRANCH`; then `git rev-parse HEAD`, `git rev-parse origin/BRANCH`, `git status --porcelain`. Acceptance: commit and push exit 0, the two `rev-parse` outputs are equal, and the porcelain output lists at most `FEATURE/remediation-plan.2026-10-08T19-24.md` (this task's own checkbox, which is checked after the push and reported in the executor's return rather than committed).

## Acceptance Traceability

| ID | Implementation | Tests | Evidence |
|---|---|---|---|
| R1 | P2-T2, P2-T4, P2-T6, P2-T8 (ED-1..ED-7) | CAT-R1 M10p, M10e, M11p, M11e, M12a-c, M8h, M8m on both surfaces | `regression-testing/fail-before-cr1-*.md`, `regression-testing/pass-after-cr1-*.md`, `other/cr1-symmetry.*.md` |
| CR-4 | P3-T6, P3-T7, P3-T8 (ED-8) | W9, C7, D7 wording assertions | `regression-testing/fail-before-cr4.*.md`, `regression-testing/pass-after-cr4.*.md`, `other/cr4-wording.*.md` |
| PA-3 | P4-T1, P4-T2, P4-T4 | FAILROWS (P0-T26 fail-before, P5-T18 pass-after) | `remediation-baseline/pr-context-fail-rows.*.md`, `qa-gates/pr-context-fail-rows.rem1-*.md`, `other/pa3-relocation.*.md` |
| CR-3 | P4-T5 (record only) | existing `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` lines 238-239 and 297, unchanged | `other/cr3-mode-record-deviation.*.md` |
| FOLLOW-UPS | P4-T6 | none (record only) | `other/follow-ups-remediation-1.*.md` |
| Spec AC 13, 14 | P2-T2..P2-T8 | RW15, RW16 (M1-M9 plus CAT-R1) | P2-T13, P2-T14, P5-T6 |
| Spec AC 17 | unchanged guards | M9, W9, C7, D7 | P5-T6 |
| Spec AC 19 | no edit to existing suites | R-EXISTING-PRE, R-EXISTING-BARRIER | P2-T15, P3-T13, P5-T7, P5-T17 |
| Spec AC 27, 28 | P2-T10, P3-T10 | HASH | P2-T11, P3-T11, P5-T4 |
| Spec AC 31 | line budget | LC | P2-T3, P2-T5, P2-T9, P3-T9, P5-T14 |
| Spec AC 32 | new lines reachable by CAT-R1 and W9/C7/D7 | SUITE + CRC + CLC | P5-T11, P5-T12, P5-T13 |
| Spec AC 33 | test edits | PUR | P1-T7, P5-T15 |
| Spec AC 34 | no Python | PYADD | P5-T16 |
| Spec AC 35 | final loop | FMT, PoshQC format, ANZ, SUITE | P5-T2, P5-T3, P5-T5, P5-T9, P5-T10, P5-T19 |

Spec AC item 30 is not checked off by this plan. No spec acceptance-criterion text is changed.
