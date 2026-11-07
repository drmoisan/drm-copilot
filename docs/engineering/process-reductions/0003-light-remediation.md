# 0003: Light remediation

## Summary

reduction: 0003
Date: 2026-11-07
Issue: #1097
Merge commit: pending (PR #1097)

Adds a third remediation path for small review findings. When the review finds at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`, in a review-opened cycle whose prior cycle was not light, the reviewer writes `Remediation-Path: light` and a `## Light Fix Tasks` section, and the orchestrator runs one `atomic-executor` delegation over the inputs file with no `atomic-planner` delegation and no preflight. The checkpoint records `remediation_path: "light"`, and invariant 8 replaces invariant 2 for that cycle in all three validators. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, and the orchestrator replaces it with the pull request number right after PR creation.

## Reason and Evidence

Research section 5 of `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` found that, of 33 `remediation-inputs` files in `docs/features/active/` with a mode line, 31 were proportionate and 2 were design, so the planner delegation and the preflight were paid on nearly every cycle, including cycles whose fix was one line at a named location. The light path removes both for the contained cases and keeps the pre-R4 commit, the re-audit, cycle accounting, and the termination guard. The time saved is unknown until stage timing has data.

## Files Changed

- `scripts/dev_tools/_orchestrator_state_light_cycle.py`, new
- `scripts/dev_tools/_orchestrator_state_remediation_loop.py`
- `tests/scripts/dev_tools/test_orchestrator_state_light_cycle.py`, new
- `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py`, the corpus floor
- `tests/fixtures/orchestrator_state_remediation_loop/` (fourteen corpus files, new): `light_valid_accepted.json`, `light_three_findings_accepted.json`, `light_design_scope.json`, `light_absent_scope.json`, `light_four_findings.json`, `light_consecutive_light.json`, `light_preflight_present.json`, `light_opened_by_absent.json`, `light_opened_by_halt_outcome.json`, `light_non_autonomous_finding.json`, `full_no_preflight_fails_invariant_2.json`, `full_with_preflight_and_scope_accepted.json`, `path_value_case_variant.json`, `path_value_null.json`
- `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`
- `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, a byte-identical bundle copy
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateLightCycle.Tests.ps1`, new
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1`, the corpus floor
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`, new
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`
- `extensions/drm-copilot/jest.config.cjs`, the coverage threshold of the new module
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-light-cycle.test.ts`, new
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts`, the corpus floor
- `tests/scripts/claude-hooks/validate-executor-output.LightRemediation.Tests.ps1`, new
- `.claude/skills/feature-review-workflow/SKILL.md`
- `.agents/skills/feature-review-workflow/SKILL.md`
- `.github/skills/feature-review-workflow/SKILL.md`
- `.claude/agents/feature-review.md`
- `.agents/skills/feature-review/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.agents/skills/orchestrate/SKILL.md`
- `.claude/agents/orchestrator.md`
- `.claude/agents/atomic-executor.md`
- `.codex/agents/atomic-executor.toml`, the hand-edited Codex base agent
- `.codex/agents/atomic-executor-c1.toml`, `-c2`, `-c3`, `-c3-elevated`, and `-c4`, generated variants
- `.claude/rules/orchestrator-state.md`
- `.agents/skills/orchestrator-state/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-state/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml` and its five variants, generated bundle copies
- `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`, new
- `docs/engineering/process-reductions/README.md`, the index row of this entry

Deferred wording (K3, K6): `### Single-Pass Preflight` of `atomic-plan-contract`, which names proportionate cycles, and the light route in the `execution-environment` brief are not changed by this entry. The stage E plan updates them when this entry is in the tree, and the commit that lands that wording updates this entry.

## Prior Text

### Revert Block: scripts/dev_tools/_orchestrator_state_remediation_loop.py

````Current
    which run after the per-cycle checks and also when `cycles` is absent. Issue
    #1097 adds invariant 8 (light remediation), which runs last in the accounting
    stage and exempts an exact `light` cycle from invariant 2. The validators
    never modify their input.

````

````Prior
    which run after the per-cycle checks and also when `cycles` is absent. The
    validators never modify their input.

````

### Revert Block: scripts/dev_tools/_orchestrator_state_remediation_loop.py

````Current

from scripts.dev_tools._orchestrator_state_light_cycle import (
    LIGHT_REMEDIATION_PATH,
    REMEDIATION_PATH_KEY,
    validate_light_cycles,
)

````

````Prior
````

### Revert Block: scripts/dev_tools/_orchestrator_state_remediation_loop.py

````Current
    # Invariant 2 does not apply to an exact light cycle, which runs no preflight;
    # invariant 8 checks that cycle instead.
    execution_status = cycle.get("execution_status")
    if (
        execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT
        and cycle.get(REMEDIATION_PATH_KEY) != LIGHT_REMEDIATION_PATH
    ):

````

````Prior
    execution_status = cycle.get("execution_status")
    if execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT:

````

### Revert Block: scripts/dev_tools/_orchestrator_state_remediation_loop.py

````Current
    """Return the per-cycle R5, R6, R11 errors, then R7a or R7b, then invariant 8."""

````

````Prior
    """Return the per-cycle R5, R6, R11 errors, then R7a or R7b."""

````

### Revert Block: scripts/dev_tools/_orchestrator_state_remediation_loop.py

````Current
    errors.extend(
        validate_light_cycles(cycle_list, outcomes, _opens_remediation_review)
    )

````

````Prior
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts

````Current
 *     - Invariant 8 (issue #1097): a `remediation_path` cycle is checked by
 *       `validateLightCycles`, and an exact `light` cycle is exempt from the
 *       cleared-preflight invariant.

````

````Prior
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts

````Current
import {
  LIGHT_REMEDIATION_PATH,
  REMEDIATION_PATH_KEY,
  validateLightCycles,
} from "./orchestrator-state-light-cycle";

````

````Prior
````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts

````Current
  // cycle's preflight gate reports exactly the cleared status. An exact light
  // cycle runs no preflight and is checked by invariant 8 instead.
  const executionStatus = cycle["execution_status"];
  if (
    cycle[REMEDIATION_PATH_KEY] !== LIGHT_REMEDIATION_PATH &&

````

````Prior
  // cycle's preflight gate reports exactly the cleared status.
  const executionStatus = cycle["execution_status"];
  if (

````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts

````Current
 * Validate the accounting invariants: per cycle R5, R6, R11; then R7a or R7b;
 * then invariant 8.

````

````Prior
 * Validate the accounting invariants: per cycle R5, R6, R11; then R7a or R7b.

````

### Revert Block: extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts

````Current
  errors.push(
    ...validateLightCycles(cycleList, outcomes, opensRemediationReview),
  );

````

````Prior
````

### Revert Block: extensions/drm-copilot/jest.config.cjs

````Current
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/orchestrator-state-light-cycle.ts": {

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1

````Current
    # preflight cannot satisfy it. An exact light cycle runs no preflight and is
    # checked by invariant 8 instead.
    $executionStatus = (Get-CheckpointObjectMember -Owner $Cycle -Name 'execution_status').Value
    $remediationPath = (Get-CheckpointObjectMember -Owner $Cycle -Name 'remediation_path').Value
    $isLightCycle = ($remediationPath -is [string]) -and ([string]$remediationPath -ceq 'light')
    if (-not $isLightCycle -and $executionStatus -is [string] -and

````

````Prior
    # preflight cannot satisfy it.
    $executionStatus = (Get-CheckpointObjectMember -Owner $Cycle -Name 'execution_status').Value
    if ($executionStatus -is [string] -and

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1

````Current
    rules R5, R6, R7a, R7b, and R11, and the light-remediation invariant 8
    (issue #1097), matching the error-string templates in
    `scripts/dev_tools/_orchestrator_state_remediation_loop.py`,
    `scripts/dev_tools/_orchestrator_state_light_cycle.py`, and the rules

````

````Prior
    rules R5, R6, R7a, R7b, and R11, matching the error-string templates in
    `scripts/dev_tools/_orchestrator_state_remediation_loop.py` and the rules

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1

````Current

# Invariant 8 (light remediation) keys and limits. Pinned to the Python constants
# in _orchestrator_state_light_cycle.py.
$script:REMEDIATION_PATH_KEY = 'remediation_path'
$script:LIGHT_REMEDIATION_PATH = 'light'
$script:FULL_REMEDIATION_PATH = 'full'
$script:LIGHT_FINDING_LIMIT = 3
$script:CONTAINED_SCOPE = 'contained'

````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1

````Current
function Get-RemediationLightCycleError {
    <#
    .SYNOPSIS
        Return the invariant 8 errors of every cycle that carries remediation_path.
    .DESCRIPTION
        Private helper mirroring validate_light_cycles (issue #1097). Per object cycle
        whose key is present, in order: a value other than the exact string light or
        full yields rule 1 alone; full yields nothing; light yields rule 2 (a preflight
        key is present), rule 3 (opened_by_review is absent or fails the R11 predicate,
        which skips rules 4 to 6), rule 4 (more than 3 findings; a non-list findings
        value counts as empty), rule 5 per finding whose remediability is not exactly
        autonomous, rule 6 per finding whose scope is not exactly contained, and rule 7
        (the immediately prior element is an object whose remediation_path is exactly
        light). Every string value is tested with -is [string] before -ceq, because
        -ceq on an array filters rather than compares.
    .PARAMETER Cycle
        The loop's cycles list, or $null when cycles is absent or not a list.
    .PARAMETER Outcomes
        The raw review_outcomes value. May be $null.
    .OUTPUTS
        System.String[] - zero or more error strings.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object] $Cycle,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Outcomes
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $cycleItems = @()
    if ($null -ne $Cycle) { $cycleItems = @($Cycle) }

    # Walk the cycles in order so each light cycle can see its immediate prior.
    for ($index = 0; $index -lt $cycleItems.Count; $index++) {
        $item = $cycleItems[$index]
        if (-not (Test-CheckpointObjectValue -Value $item)) { continue }
        $member = Get-CheckpointObjectMember -Owner $item -Name $script:REMEDIATION_PATH_KEY
        if (-not $member.Present) { continue }

        # Rule 1 routes by exact value: full has no further rule, and anything other
        # than light is reported once and stops there.
        $path = $member.Value
        $isString = $path -is [string]
        if ($isString -and ([string]$path -ceq $script:FULL_REMEDIATION_PATH)) { continue }
        if (-not ($isString -and ([string]$path -ceq $script:LIGHT_REMEDIATION_PATH))) {
            $errors.Add("Checkpoint remediation cycle #$index remediation_path must be light or full.")
            continue
        }

        $prefix = "Checkpoint remediation cycle #$index remediation_path is light but"
        if ((Get-CheckpointObjectMember -Owner $item -Name 'preflight').Present) {
            $errors.Add("$prefix the cycle carries preflight.")
        }

        $opened = Get-CheckpointObjectMember -Owner $item -Name $script:OPENED_BY_REVIEW_KEY
        if (-not $opened.Present -or -not (Test-RemediationOpenedByReview -OpenedByReview $opened.Value -Outcomes $Outcomes)) {
            $errors.Add("$prefix opened_by_review does not name its opening review.")
        } else {
            $outcome = @($Outcomes)[[int]$opened.Value]
            $findings = (Get-CheckpointObjectMember -Owner $outcome -Name 'findings').Value
            $findingList = @()
            if (Test-CheckpointListValue -Value $findings) { $findingList = @($findings) }
            if ($findingList.Count -gt $script:LIGHT_FINDING_LIMIT) {
                $errors.Add("$prefix its opening review has $($findingList.Count) findings; the limit is $($script:LIGHT_FINDING_LIMIT).")
            }
            # Report every finding a light cycle may not fix autonomously, then every
            # finding whose fix is not contained; a non-object finding fails both.
            foreach ($key in @('remediability', 'scope')) {
                $required = if ($key -ceq 'remediability') { $script:REMEDIABLE_CLASS } else { $script:CONTAINED_SCOPE }
                for ($findingIndex = 0; $findingIndex -lt $findingList.Count; $findingIndex++) {
                    $finding = $findingList[$findingIndex]
                    $value = $null
                    if (Test-CheckpointObjectValue -Value $finding) { $value = (Get-CheckpointObjectMember -Owner $finding -Name $key).Value }
                    if (-not (($value -is [string]) -and ([string]$value -ceq $required))) {
                        $suffix = if ($key -ceq 'remediability') { 'is not autonomous.' } else { 'scope is not contained.' }
                        $errors.Add("$prefix finding #$findingIndex $suffix")
                    }
                }
            }
        }

        # Rule 7: two light cycles may not run back to back.
        if ($index -gt 0 -and (Test-CheckpointObjectValue -Value $cycleItems[$index - 1])) {
            $priorPath = (Get-CheckpointObjectMember -Owner $cycleItems[$index - 1] -Name $script:REMEDIATION_PATH_KEY).Value
            if (($priorPath -is [string]) -and ([string]$priorPath -ceq $script:LIGHT_REMEDIATION_PATH)) {
                $errors.Add("$prefix the prior cycle is light.")
            }
        }
    }

    return $errors.ToArray()
}


````

````Prior
````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1

````Current
        cycle in order, R5, R6, and R11; then R7a, otherwise R7b; then invariant 8
        through Get-RemediationLightCycleError. With none of the new keys present it
        returns nothing.

````

````Prior
        cycle in order, R5, R6, and R11; then R7a, otherwise R7b. With none of the
        new keys present it returns nothing.

````

### Revert Block: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1

````Current
    $errors.AddRange([string[]]@(Get-RemediationLightCycleError -Cycle $Cycle -Outcomes $outcomes))

````

````Prior
````

### Revert Block: .claude/skills/feature-review-workflow/SKILL.md

````Current
   - Choose the remediation path. Write one line `Remediation-Path: light` or `Remediation-Path: full` into the remediation inputs, and inside each blocking finding block one line `Finding-Scope: contained` or `Finding-Scope: design`. A missing path line reads as `full`, and a missing scope line reads as `design`. These lines never contain the substrings the orchestrator counts.
   - Write `Remediation-Path: light` only when all of these hold: at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`; no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; no change to a validator contract, hook decision, or production logic beyond the finding's named location; the cycle is opened by a review; and the prior cycle was not light. Otherwise write `Remediation-Path: full`. The orchestrator may move a cycle to a heavier path and never to a lighter one.
   - With `Remediation-Path: light`, also write a `## Light Fix Tasks` section: one canonical `- [ ] [P0-T1] ...` line per fix, numbered in order, each naming the file and the finding it fixes. Write no checkbox line anywhere else in the file, because the executor stop hook counts every checkbox line of the file it executes.
   - Create `remediation-inputs.<timestamp>.md` first.
   - With `Remediation-Path: full`, create the target remediation plan file from the canonical plan template.
   - With `Remediation-Path: full`, hand off plan creation through `remediation-handoff-atomic-planner`.
   - With `Remediation-Path: full`, do not report completion unless the remediation plan file exists when remediation was triggered. With `Remediation-Path: light`, create no remediation plan target: the inputs file is the light cycle's plan.

````

````Prior
   - Create `remediation-inputs.<timestamp>.md` first.
   - Create the target remediation plan file from the canonical plan template.
   - Hand off plan creation through `remediation-handoff-atomic-planner`.
   - Do not report completion unless the remediation plan file exists when remediation was triggered.

````

### Revert Block: .agents/skills/feature-review-workflow/SKILL.md

````Current
   - Choose the remediation path. Write one line `Remediation-Path: light` or `Remediation-Path: full` into the remediation inputs, and inside each blocking finding block one line `Finding-Scope: contained` or `Finding-Scope: design`. A missing path line reads as `full`, and a missing scope line reads as `design`. These lines never contain the substrings the orchestrator counts.
   - Write `Remediation-Path: light` only when all of these hold: at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`; no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; no change to a validator contract, hook decision, or production logic beyond the finding's named location; the cycle is opened by a review; and the prior cycle was not light. Otherwise write `Remediation-Path: full`. The orchestrator may move a cycle to a heavier path and never to a lighter one.
   - With `Remediation-Path: light`, also write a `## Light Fix Tasks` section: one canonical `- [ ] [P0-T1] ...` line per fix, numbered in order, each naming the file and the finding it fixes. Write no checkbox line anywhere else in the file, because the executor stop hook counts every checkbox line of the file it executes.
   - The remediation plan target stays for both paths, because this review contract requires it.

````

````Prior
````

### Revert Block: .github/skills/feature-review-workflow/SKILL.md

````Current
   - Choose the remediation path. Write one line `Remediation-Path: light` or `Remediation-Path: full` into the remediation inputs, and inside each blocking finding block one line `Finding-Scope: contained` or `Finding-Scope: design`. A missing path line reads as `full`, and a missing scope line reads as `design`. These lines never contain the substrings the orchestrator counts.
   - Write `Remediation-Path: light` only when all of these hold: at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`; no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; no change to a validator contract, hook decision, or production logic beyond the finding's named location; the cycle is opened by a review; and the prior cycle was not light. Otherwise write `Remediation-Path: full`. The orchestrator may move a cycle to a heavier path and never to a lighter one.
   - With `Remediation-Path: light`, also write a `## Light Fix Tasks` section: one canonical `- [ ] [P0-T1] ...` line per fix, numbered in order, each naming the file and the finding it fixes. Write no checkbox line anywhere else in the file, because the executor stop hook counts every checkbox line of the file it executes.
   - The remediation plan target stays for both paths, because this review contract requires it.

````

````Prior
````

### Revert Block: .claude/agents/feature-review.md

````Current
   - one line `Remediation-Path: light` or `Remediation-Path: full` (`full` when the line is absent). `light` is allowed only when there are at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`, the fix changes no spec acceptance criterion, public interface, validator contract, or hook decision, no file inventory beyond the branch diff plus tests and mirrors, and no production logic beyond the finding's named location, the cycle is opened by a review, and the prior cycle was not light.
   - inside each blocking finding block, one line `Finding-Scope: contained` or `Finding-Scope: design` (`design` when the line is absent).
   - with `Remediation-Path: light`, a `## Light Fix Tasks` section holding one canonical `- [ ] [P0-T1] ...` line per fix, numbered in order and naming the file and the finding, and no checkbox line anywhere else in the file. A light review creates no remediation plan target.

````

````Prior
````

### Revert Block: .agents/skills/feature-review/SKILL.md

````Current
- inside each blocking finding block, one line `Remediability-Evidence: <text>` stating why the class applies,
- one line `Remediation-Path: light` or `Remediation-Path: full` for the review (`full` when the line is absent),
- inside each blocking finding block, one line `Finding-Scope: contained` or `Finding-Scope: design` (`design` when the line is absent).

`Remediation-Path: light` is allowed only when there are at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`, the fix changes no spec acceptance criterion, public interface, validator contract, or hook decision, no file inventory beyond the branch diff plus tests and mirrors, and no production logic beyond the finding's named location, the cycle is opened by a review, and the prior cycle was not light. With that line the review also writes a `## Light Fix Tasks` section: one canonical `- [ ] [P0-T1] ...` line per fix, numbered in order and naming the file and the finding, and no checkbox line anywhere else in the file. The `remediation-plan.<timestamp>.md` target stays for both paths, because this review contract requires it.

````

````Prior
- inside each blocking finding block, one line `Remediability-Evidence: <text>` stating why the class applies.

````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current
6. Append a `remediation_loop.review_outcomes[]` entry (`verdict` plus one `findings[]` object with `remediability` per blocking finding) for every review, including `PASS`. Each `findings[]` object also records `scope` from the finding's `Finding-Scope:` line when that line is present.

````

````Prior
6. Append a `remediation_loop.review_outcomes[]` entry (`verdict` plus one `findings[]` object with `remediability` per blocking finding) for every review, including `PASS`.

````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current
Remediation mode. Before R1, or before R3 for a light cycle, the orchestrator writes exactly one line into the cycle's `remediation-inputs.<timestamp>.md`: `Remediation-Mode: light`, `Remediation-Mode: proportionate`, or `Remediation-Mode: design`. The classification rule: a cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; otherwise the cycle is design. CI-failure findings are normally proportionate. `Remediation-Mode:` stays orchestrator-owned. The orchestrator writes `Remediation-Mode: light` only when the reviewer wrote `Remediation-Path: light` and every mechanically checkable condition holds: the finding count and classes, a `Finding-Scope: contained` line for each finding, a non-empty `## Light Fix Tasks` section and no other checkbox line, `opened_by_review` set, a prior cycle that was not light, and the detection rule below. Otherwise it writes `Remediation-Mode: proportionate` or `Remediation-Mode: design` by the rule above. It may move a cycle to a heavier mode and never to a lighter one, and CI-failure and merge-conflict cycles are never light. Each new cycle records `remediation_path` as `light` or `full`.

- **Proportionate cycle.** R1 is one `atomic-planner` delegation that writes a short remediation plan carrying a `## Pre-Mortem` section and a final self-review task. R2 and R3 run as one `atomic-executor` delegation: the executor runs single-pass preflight with in-place trivial fixes (`### Single-Pass Preflight` in `atomic-plan-contract`) and then executes the plan. Record `preflight: {iterations: 1, final_status: "clear"}` on the cycle before `execution_status`. If preflight finds a substantive defect, the executor stops with `BLOCKED at preflight (before [P0-T1])`, a plan delta, and no checked task; the orchestrator rewrites the mode line to `Remediation-Mode: design` and the cycle continues as a design cycle with one planner revision. The pre-R4 commit, R4, and R5 are unchanged.
- **Design cycle.** R1 to R5 run as listed below, and R2 follows the single-pass preflight and at-most-one-return rule.
- **Light cycle.** The threshold is the reviewer's: at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`; no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; no change to a validator contract, hook decision, or production logic beyond the finding's named location; a review-opened cycle; and a prior cycle that was not light. Detection: as the last step before the execution delegation, record the cycle truthfully (`plan_path` naming the inputs file, `remediation_path: "light"`, `opened_by_review`, `execution_status: "in_progress"`, and no `preflight`) and validate the checkpoint through the repository-local Python CLI `scripts.dev_tools.validate_orchestration_artifacts` with its `orchestrator-state` subcommand, run through Poetry in module form in the item worktree, or through the MCP tool where the repository has no such CLI. Installed MCP applies invariant 8 only after the extension release that carries it is installed; until then the checkpoint is validated through the Python CLI, and a failed MCP checkpoint call records no receipt and is not repaired by editing the cycle. On that validation, an error naming that cycle means the route lacks invariant 8, so remove `execution_status`, set `remediation_path: "full"`, rewrite the mode line to `Remediation-Mode: proportionate` or `Remediation-Mode: design`, and continue at R1, after which `plan_path` names the remediation plan. No fix work has run at that point, so the record stays true. R1 and R2 do not run. R3 is one `atomic-executor` delegation with the inputs file as its plan and no preflight directive. If the executor stops with `BLOCKED at preflight (before [P0-T1])` before the first checked task, rewrite the mode line to `Remediation-Mode: design`, set `remediation_path: "full"`, remove `execution_status`, and enter the design chain at R1; `plan_path` then names the remediation plan, and no attempt number is consumed. The pre-R4 commit, R4, R5, cycle accounting (`candidate_applied` and `completed_attempts`), and the termination guard are unchanged. The cycle after a light cycle is full.

````

````Prior
Remediation mode. Before R1, the orchestrator writes exactly one line into the cycle's `remediation-inputs.<timestamp>.md`: `Remediation-Mode: proportionate` or `Remediation-Mode: design`. The classification rule: a cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; otherwise the cycle is design. CI-failure findings are normally proportionate.

- **Proportionate cycle.** R1 is one `atomic-planner` delegation that writes a short remediation plan carrying a `## Pre-Mortem` section and a final self-review task. R2 and R3 run as one `atomic-executor` delegation: the executor runs single-pass preflight with in-place trivial fixes (`### Single-Pass Preflight` in `atomic-plan-contract`) and then executes the plan. Record `preflight: {iterations: 1, final_status: "clear"}` on the cycle before `execution_status`. If preflight finds a substantive defect, the executor stops with `BLOCKED at preflight (before [P0-T1])`, a plan delta, and no checked task; the orchestrator rewrites the mode line to `Remediation-Mode: design` and the cycle continues as a design cycle with one planner revision. The pre-R4 commit, R4, and R5 are unchanged.
- **Design cycle.** R1 to R5 run as listed below, and R2 follows the single-pass preflight and at-most-one-return rule.

````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current
4. Append a `remediation_loop.review_outcomes[]` entry (`verdict` plus one `findings[]` object with `remediability` per blocking finding) for every review, including `PASS`. Each `findings[]` object also records `scope` from the finding's `Finding-Scope:` line when that line is present.

````

````Prior
4. Append a `remediation_loop.review_outcomes[]` entry (`verdict` plus one `findings[]` object with `remediability` per blocking finding) for every review, including `PASS`.

````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current
Remediation mode. Each cycle's `remediation-inputs.<timestamp>.md` carries exactly one line `Remediation-Mode: light`, `Remediation-Mode: proportionate`, or `Remediation-Mode: design`. A cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; otherwise it is design. CI-failure findings are normally proportionate. `Remediation-Mode:` stays orchestrator-owned. The orchestrator writes `Remediation-Mode: light` only when the reviewer wrote `Remediation-Path: light` and every mechanically checkable condition holds: the finding count and classes, a `Finding-Scope: contained` line for each finding, a non-empty `## Light Fix Tasks` section and no other checkbox line, `opened_by_review` set, a prior cycle that was not light, and the detection rule below. Otherwise it writes `Remediation-Mode: proportionate` or `Remediation-Mode: design` by the rule above. It may move a cycle to a heavier mode and never to a lighter one, and CI-failure and merge-conflict cycles are never light. Each new cycle records `remediation_path` as `light` or `full`.

- **Proportionate cycle.** One `atomic-planner` delegation produces a short plan with a `## Pre-Mortem` section and a final self-review task; R2 and R3 then run as one `atomic-executor` delegation that performs single-pass preflight with in-place trivial fixes and executes the plan. Record `preflight: {iterations: 1, final_status: "clear"}` before `execution_status`. A substantive defect stops the run with `BLOCKED at preflight (before [P0-T1])` and no checked task; rewrite the mode line to `Remediation-Mode: design` and continue as a design cycle with one planner revision.
- **Design cycle.** R1 to R5 run as listed below, with R2 under the single-pass preflight and at-most-one-return rule.
- **Light cycle.** The light path is unavailable until an extension release that carries invariant 8 is installed, because `## Hard Enforcement Boundary` requires the installed MCP validator with no fallback, and an installed release without invariant 8 rejects a cycle that records execution without a cleared preflight. Move every such cycle heavier until then. Detection: as the last step before the light execution delegation, record the cycle truthfully (`plan_path` naming the inputs file, `remediation_path: "light"`, `opened_by_review`, `execution_status: "in_progress"`, and no `preflight`) and validate the checkpoint with `validate_orchestration_artifacts`; an error naming that cycle means the route lacks invariant 8, so remove `execution_status`, set `remediation_path: "full"`, rewrite the mode line to `Remediation-Mode: proportionate` or `Remediation-Mode: design`, and continue at R1, after which `plan_path` names the remediation plan. No fix work has run at that point, so the record stays true. With a release that carries invariant 8, the threshold is the reviewer's: at most 3 blocking findings, every one `autonomous` with `Finding-Scope: contained`; no change to a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors; no change to a validator contract, hook decision, or production logic beyond the finding's named location; a review-opened cycle; and a prior cycle that was not light. R1 and R2 do not run. R3 is one `atomic-executor` delegation with the inputs file as its plan and no preflight directive. If the executor stops with `BLOCKED at preflight (before [P0-T1])` before the first checked task, rewrite the mode line to `Remediation-Mode: design`, set `remediation_path: "full"`, remove `execution_status`, and enter the design chain at R1; `plan_path` then names the remediation plan, and no attempt number is consumed. The pre-R4 commit, R4, R5, cycle accounting (`candidate_applied` and `completed_attempts`), and the termination guard are unchanged. The cycle after a light cycle is full. The review's remediation plan target stays, so the saving is the preflight.

````

````Prior
Remediation mode. Each cycle's `remediation-inputs.<timestamp>.md` carries exactly one line `Remediation-Mode: proportionate` or `Remediation-Mode: design`. A cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; otherwise it is design. CI-failure findings are normally proportionate.

- **Proportionate cycle.** One `atomic-planner` delegation produces a short plan with a `## Pre-Mortem` section and a final self-review task; R2 and R3 then run as one `atomic-executor` delegation that performs single-pass preflight with in-place trivial fixes and executes the plan. Record `preflight: {iterations: 1, final_status: "clear"}` before `execution_status`. A substantive defect stops the run with `BLOCKED at preflight (before [P0-T1])` and no checked task; rewrite the mode line to `Remediation-Mode: design` and continue as a design cycle with one planner revision.
- **Design cycle.** R1 to R5 run as listed below, with R2 under the single-pass preflight and at-most-one-return rule.

````

### Revert Block: .claude/agents/orchestrator.md

````Current
- `review_outcomes[].findings[].scope` — optional `contained` or `design`, recorded from the finding's `Finding-Scope:` line when that line is present. Only invariant 8 (light remediation) reads it.
- `cycles[]` — an ordered array of cycle records. Each cycle is an object with:
  - `entry_timestamp` — ISO-8601 timestamp when the cycle was entered.
  - `inputs_path` — path to the `remediation-inputs.<entry-ts>.md` that opened the cycle.
  - `plan_path` — path to the `remediation-plan.<entry-ts>.md` for the cycle; for a light cycle, the `remediation-inputs.<entry-ts>.md` that holds its `## Light Fix Tasks`.
  - `remediation_path` — `light` or `full`, recorded on every new cycle. A light cycle runs no planner and no preflight; invariant 8 in `.claude/rules/orchestrator-state.md` governs it.
  - `preflight` — an object `{iterations, final_status}` where `iterations` counts preflight passes and `final_status` is one of `clear`, `changes_requested`, or `pending`. A light cycle carries no `preflight` key.

````

````Prior
- `cycles[]` — an ordered array of cycle records. Each cycle is an object with:
  - `entry_timestamp` — ISO-8601 timestamp when the cycle was entered.
  - `inputs_path` — path to the `remediation-inputs.<entry-ts>.md` that opened the cycle.
  - `plan_path` — path to the `remediation-plan.<entry-ts>.md` for the cycle.
  - `preflight` — an object `{iterations, final_status}` where `iterations` counts preflight passes and `final_status` is one of `clear`, `changes_requested`, or `pending`.

````

### Revert Block: .claude/agents/orchestrator.md

````Current
- `execution_status` may be in `{in_progress, complete, failed}` only when `preflight.final_status == 'clear'`; any other preflight status with one of those execution statuses is malformed (execution recorded before preflight cleared). A cycle whose `remediation_path` is exactly `light` is exempt, because it runs no preflight.

````

````Prior
- `execution_status` may be in `{in_progress, complete, failed}` only when `preflight.final_status == 'clear'`; any other preflight status with one of those execution statuses is malformed (execution recorded before preflight cleared).

````

### Revert Block: .claude/agents/orchestrator.md

````Current
- Invariant 8: `remediation_path`, when present, is `light` or `full`; a `light` cycle carries no `preflight`, names its opening review in `opened_by_review`, has at most 3 findings in that review, each `autonomous` with `scope` exactly `contained`, and does not follow a light cycle.

Remediation mode lives in the inputs file: each `remediation-inputs.<entry-ts>.md` carries exactly one line `Remediation-Mode: light`, `Remediation-Mode: proportionate`, or `Remediation-Mode: design`, and the checkpoint records only the cycle's `remediation_path`. A cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; CI-failure findings are normally proportionate. A proportionate cycle runs one `atomic-planner` delegation and one `atomic-executor` delegation that performs single-pass preflight with in-place trivial fixes and then executes; the orchestrator records `preflight: {iterations: 1, final_status: "clear"}` before `execution_status`, which satisfies the malformed-cycle rule above. When that preflight finds a substantive defect, the executor stops with `BLOCKED at preflight (before [P0-T1])` and no checked task, and the cycle converts to design mode for one planner revision. A light cycle runs no planner and no preflight: its one `atomic-executor` delegation executes the `## Light Fix Tasks` of the inputs file, and the full rule is the **Light cycle.** bullet of `## Remediation Loop (R1–R5)` in `.claude/skills/orchestrate/SKILL.md`.

````

````Prior

Remediation mode lives in the inputs file, not in the checkpoint: each `remediation-inputs.<entry-ts>.md` carries exactly one line `Remediation-Mode: proportionate` or `Remediation-Mode: design`, so no checkpoint field is added. A cycle is proportionate when every `autonomous` finding can be fixed without changing a spec acceptance criterion, a public interface, or the item's file inventory beyond the files already in the branch diff plus their tests and mirrors; CI-failure findings are normally proportionate. A proportionate cycle runs one `atomic-planner` delegation and one `atomic-executor` delegation that performs single-pass preflight with in-place trivial fixes and then executes; the orchestrator records `preflight: {iterations: 1, final_status: "clear"}` before `execution_status`, which satisfies the malformed-cycle rule above. When that preflight finds a substantive defect, the executor stops with `BLOCKED at preflight (before [P0-T1])` and no checked task, and the cycle converts to design mode for one planner revision.

````

### Revert Block: .claude/agents/orchestrator.md

````Current
Each full cycle produces exactly five artifacts; a light cycle produces the four other than the remediation plan, because its inputs file is its plan:

````

````Prior
Each cycle produces exactly five artifacts:

````

### Revert Block: .claude/agents/orchestrator.md

````Current
`preflight.final_status` is one of `{clear, changes_requested, pending}`, extended by `blocked_preflight_iteration_limit` as defined in the remediation-handoff skill. A `changes_requested` status routes back to `atomic-planner` for plan revision at most once per cycle, carrying the full `PREFLIGHT-DEFECT:` list; when the confirming preflight still reports a substantive defect, the orchestrator records `blocked_preflight_iteration_limit` and halts the cycle. An `execution_status` in `{in_progress, complete, failed}` recorded while `final_status != clear` is malformed, except on a light cycle, which carries no `preflight`. `preflight.iterations` counts the number of preflight passes performed in the cycle; trivial defects fixed in place by the preflight executor do not add a pass.

````

````Prior
`preflight.final_status` is one of `{clear, changes_requested, pending}`, extended by `blocked_preflight_iteration_limit` as defined in the remediation-handoff skill. A `changes_requested` status routes back to `atomic-planner` for plan revision at most once per cycle, carrying the full `PREFLIGHT-DEFECT:` list; when the confirming preflight still reports a substantive defect, the orchestrator records `blocked_preflight_iteration_limit` and halts the cycle. An `execution_status` in `{in_progress, complete, failed}` recorded while `final_status != clear` is malformed. `preflight.iterations` counts the number of preflight passes performed in the cycle; trivial defects fixed in place by the preflight executor do not add a pass.

````

### Revert Block: .claude/agents/atomic-executor.md

````Current
Blocking is permitted only during preflight validation (before `[P0-T1]`). This includes a combined preflight-and-execute run of a proportionate remediation cycle: the run first performs single-pass preflight, fixes trivial defects in place, and stops before `[P0-T1]` only when a substantive defect remains. A light remediation run has no preflight, and stops the same way before `[P0-T1]` only when a fix task cannot be done at its named location. When preflight-blocked:

````

````Prior
Blocking is permitted only during preflight validation (before `[P0-T1]`). This includes a combined preflight-and-execute run of a proportionate remediation cycle: the run first performs single-pass preflight, fixes trivial defects in place, and stops before `[P0-T1]` only when a substantive defect remains. When preflight-blocked:

````

### Revert Block: .codex/agents/atomic-executor.toml

````Current
Blocking is permitted only during preflight validation (before `[P0-T1]`), including the preflight that opens a combined preflight-and-execute run of a proportionate remediation cycle. A light remediation run has no preflight, and stops the same way before `[P0-T1]` only when a fix task cannot be done at its named location. When preflight-blocked:

````

````Prior
Blocking is permitted only during preflight validation (before `[P0-T1]`), including the preflight that opens a combined preflight-and-execute run of a proportionate remediation cycle. When preflight-blocked:

````

### Revert Block: .claude/rules/orchestrator-state.md

````Current
2. **Execution requires cleared preflight.** A cycle's `execution_status` may be in `{in_progress, complete, failed}` only when that cycle's `preflight.final_status` is exactly `'clear'`. Any other preflight status with one of those execution statuses is a malformed cycle (execution was recorded before preflight cleared). The invariant does not apply to a cycle whose `remediation_path` is exactly the string `light`, compared ordinally, because a light cycle runs no preflight; invariant 8 governs that cycle.

````

````Prior
2. **Execution requires cleared preflight.** A cycle's `execution_status` may be in `{in_progress, complete, failed}` only when that cycle's `preflight.final_status` is exactly `'clear'`. Any other preflight status with one of those execution statuses is a malformed cycle (execution was recorded before preflight cleared).

````

### Revert Block: .claude/rules/orchestrator-state.md

````Current

8. **Light remediation (issue #1097).** When a cycle object carries `remediation_path`, the rules below run in the accounting stage, after the R7 checks, per cycle in order, with byte-identical messages in `scripts/dev_tools/_orchestrator_state_light_cycle.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`, and `Get-RemediationLightCycleError` in `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, pinned by the corpus `tests/fixtures/orchestrator_state_remediation_loop/`. A cycle without the key reaches none of them, so every existing checkpoint validates as before. `scope` on a finding is read only by these rules.
   1. A value other than exactly `light` or `full`, null included: `Checkpoint remediation cycle #N remediation_path must be light or full.` Nothing further runs for the cycle, and nothing further runs for `full`.
   2. A `preflight` key, whatever its value: `Checkpoint remediation cycle #N remediation_path is light but the cycle carries preflight.`
   3. `opened_by_review` absent, or not naming a `REMEDIATION_REQUIRED` outcome by the R11 predicate: `Checkpoint remediation cycle #N remediation_path is light but opened_by_review does not name its opening review.` Rules 4 to 6 are then skipped.
   4. More than 3 findings in that outcome (a non-list `findings` value counts as empty): `Checkpoint remediation cycle #N remediation_path is light but its opening review has M findings; the limit is 3.`
   5. Per finding K whose `remediability` is not exactly `autonomous`, a non-object finding included: `Checkpoint remediation cycle #N remediation_path is light but finding #K is not autonomous.`
   6. Per finding K whose `scope` is not exactly `contained`, absent included: `Checkpoint remediation cycle #N remediation_path is light but finding #K scope is not contained.`
   7. The immediately prior list element is an object whose `remediation_path` is exactly `light`: `Checkpoint remediation cycle #N remediation_path is light but the prior cycle is light.`

   Route (D9): the installed MCP validator applies invariant 8 only after the extension release that carries it is installed. Until then, a Claude run validates a light checkpoint through the repository-local Python CLI, and on Codex, whose completion boundary is the installed MCP validator, the light path is unavailable.

````

````Prior
````

### Revert Block: .agents/skills/orchestrator-state/SKILL.md

````Current
2. **Execution requires cleared preflight.** A cycle's `execution_status` may be in `{in_progress, complete, failed}` only when that cycle's `preflight.final_status` is exactly `'clear'`. Any other preflight status with one of those execution statuses is a malformed cycle (execution was recorded before preflight cleared). The invariant does not apply to a cycle whose `remediation_path` is exactly the string `light`, compared ordinally, because a light cycle runs no preflight; invariant 8 governs that cycle.

````

````Prior
2. **Execution requires cleared preflight.** A cycle's `execution_status` may be in `{in_progress, complete, failed}` only when that cycle's `preflight.final_status` is exactly `'clear'`. Any other preflight status with one of those execution statuses is a malformed cycle (execution was recorded before preflight cleared).

````

### Revert Block: .agents/skills/orchestrator-state/SKILL.md

````Current

8. **Light remediation (issue #1097).** When a cycle object carries `remediation_path`, the rules below run in the accounting stage, after the R7 checks, per cycle in order, with byte-identical messages in `scripts/dev_tools/_orchestrator_state_light_cycle.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`, and `Get-RemediationLightCycleError` in `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, pinned by the corpus `tests/fixtures/orchestrator_state_remediation_loop/`. A cycle without the key reaches none of them, so every existing checkpoint validates as before. `scope` on a finding is read only by these rules.
   1. A value other than exactly `light` or `full`, null included: `Checkpoint remediation cycle #N remediation_path must be light or full.` Nothing further runs for the cycle, and nothing further runs for `full`.
   2. A `preflight` key, whatever its value: `Checkpoint remediation cycle #N remediation_path is light but the cycle carries preflight.`
   3. `opened_by_review` absent, or not naming a `REMEDIATION_REQUIRED` outcome by the R11 predicate: `Checkpoint remediation cycle #N remediation_path is light but opened_by_review does not name its opening review.` Rules 4 to 6 are then skipped.
   4. More than 3 findings in that outcome (a non-list `findings` value counts as empty): `Checkpoint remediation cycle #N remediation_path is light but its opening review has M findings; the limit is 3.`
   5. Per finding K whose `remediability` is not exactly `autonomous`, a non-object finding included: `Checkpoint remediation cycle #N remediation_path is light but finding #K is not autonomous.`
   6. Per finding K whose `scope` is not exactly `contained`, absent included: `Checkpoint remediation cycle #N remediation_path is light but finding #K scope is not contained.`
   7. The immediately prior list element is an object whose `remediation_path` is exactly `light`: `Checkpoint remediation cycle #N remediation_path is light but the prior cycle is light.`

   Route (D9): the installed MCP validator applies invariant 8 only after the extension release that carries it is installed. Until then, a Claude run validates a light checkpoint through the repository-local Python CLI, and on Codex, whose completion boundary is the installed MCP validator, the light path is unavailable.

````

````Prior
````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, in the order of this entry. Then delete `scripts/dev_tools/_orchestrator_state_light_cycle.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`, the five new test files `tests/scripts/dev_tools/test_orchestrator_state_light_cycle.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-light-cycle.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateLightCycle.Tests.ps1`, `tests/scripts/claude-hooks/validate-executor-output.LightRemediation.Tests.ps1`, and `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`, and the fourteen corpus rows listed under `## Files Changed`.
2. Re-copy mirrors and bundles: copy each of these to its bundle path under `extensions/drm-copilot/resources/`: `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`, `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, `.claude/skills/feature-review-workflow/SKILL.md`, `.claude/agents/feature-review.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/agents/atomic-executor.md`, and `.claude/rules/orchestrator-state.md` under `claude-customizations/`; `.agents/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, and `.agents/skills/orchestrator-state/SKILL.md` under `codex-and-agents-customizations/`; and `.github/skills/feature-review-workflow/SKILL.md` under `customizations/`.
3. Regenerate Codex variants: applicable, because the base agent `.codex/agents/atomic-executor.toml` changed. Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form to rewrite the variants and their bundle copies, then run it with `--check`.
4. Restore pinned hashes: not applicable, because no pinned surface moved.
5. Restore contract-test literals: set the corpus floor back to 41 in `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py` (`MINIMUM_CORPUS_COUNT`), `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts` (`MINIMUM_CORPUS_COUNT`), and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1` (`$MinimumCorpusCount`).
6. Run the contract tests: run `test_single_pass_preflight_contracts.py`, `test_orchestrator_state_remediation_docs.py`, `test_codex_handoff_contract_parity.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_agent_wrapper_contracts.py`, `parallel-gate-wording.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`, and the three remediation-loop parity suites.

## Revert Signals

- A light cycle followed by a re-review that reports a design finding.
- A rise in fallbacks from the light path to the design chain.
- A defect traced to a finding the review classified as contained.
- No measured saving in stage-timing reports.
