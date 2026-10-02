<#
.SYNOPSIS
    Unit tests for remediation-loop verdict accounting (issue #484, R5-R11).

.DESCRIPTION
    Covers the exported Get-OrchestratorStateRemediationAccountingError entry
    point on in-memory loop objects (ConvertFrom-Json of literal JSON), the
    private Get-RemediationReviewVerdict helper through InModuleScope over all
    32 subsets of the five remediability classes, case-sensitive rejection of
    every verdict and class literal, the drift guard against the #523
    non-mechanical blocked_reason partition, and a halt checkpoint with no
    cycles through Get-OrchestratorStateUnconditionalError.

    Interface assumed for the new module (fixed here for Phase 5): the entry
    point takes -RemediationLoop (the loop object) and -Cycle (the cycle list or
    $null); the private helper takes -Remediability (the class list).

    Expected messages are written locally from the spec message table. No file
    is written; the halt case reads one committed corpus file in place.
#>

# Discovery-time message helpers and case tables. Pester runs the file body
# during discovery, so expected strings are computed here and passed to each It.
function Get-R5Message([int] $I) { "Checkpoint remediation cycle #$I candidate_applied must be a boolean." }
function Get-R6Message([int] $I) { "Checkpoint remediation cycle #$I candidate_applied is true but execution_status is not 'complete'." }
function Get-R7bMessage([int] $N, [int] $K) { "Checkpoint remediation_loop completed_attempts is $N but $K cycles have candidate_applied true." }
function Get-R8bMessage([int] $J) { "Checkpoint remediation review outcome #$J must be an object." }
function Get-R9aMessage([int] $J, [string] $V) { "Checkpoint remediation review outcome #$J verdict must be one of PASS, REMEDIATION_REQUIRED, HALT_NON_REMEDIABLE, AWAITING_CI; got: $V" }
function Get-R9bMessage([int] $J) { "Checkpoint remediation review outcome #$J findings must be a list." }
function Get-R9cMessage([int] $J, [int] $M) { "Checkpoint remediation review outcome #$J finding #$M must be an object." }
function Get-R9dMessage([int] $J, [int] $M, [string] $V) { "Checkpoint remediation review outcome #$J finding #$M remediability must be one of autonomous, external_dependency, policy_hold, awaiting_ci, human_decision_required; got: $V" }
function Get-R10Message([int] $J, [string] $V, [string] $E) { "Checkpoint remediation review outcome #$J verdict $V does not match its findings (expected $E)." }
function Get-R11Message([int] $I) { "Checkpoint remediation cycle #$I opened_by_review must reference a review outcome whose verdict is REMEDIATION_REQUIRED." }
$r7a = 'Checkpoint remediation_loop completed_attempts must be a non-negative integer.'
$r8a = 'Checkpoint remediation_loop review_outcomes must be a list.'

$specVerdict = @('PASS', 'REMEDIATION_REQUIRED', 'HALT_NON_REMEDIABLE', 'AWAITING_CI')
$specClass = @('autonomous', 'external_dependency', 'policy_hold', 'awaiting_ci', 'human_decision_required')
$specHalt = @('external_dependency', 'policy_hold', 'human_decision_required')

# Valid legacy cycle JSON with extra members spliced in.
function Get-CycleJson([string] $Extra = '') {
    $base = '"plan_path": "docs/features/active/example/remediation-plan.2026-09-29T00-00.md", "preflight": {"iterations": 1, "final_status": "clear"}, "execution_status": "complete", "blocking_count": 1, "exit_condition_met": false'
    if ($Extra) { return '{' + $base + ', ' + $Extra + '}' }
    return '{' + $base + '}'
}
$rr = '{"verdict": "REMEDIATION_REQUIRED", "findings": [{"remediability": "autonomous"}]}'
$halt = '{"verdict": "HALT_NON_REMEDIABLE", "findings": [{"remediability": "external_dependency"}]}'
$wait = '{"verdict": "AWAITING_CI", "findings": [{"remediability": "awaiting_ci"}]}'
$passOutcome = '{"verdict": "PASS", "findings": []}'

$subsetCase = @(
    for ($mask = 0; $mask -lt 32; $mask++) {
        $classes = @(for ($bit = 0; $bit -lt 5; $bit++) { if ($mask -band (1 -shl $bit)) { $specClass[$bit] } })
        $expected = if ($classes.Count -eq 0) { 'PASS' }
        elseif ($classes -ccontains 'autonomous') { 'REMEDIATION_REQUIRED' }
        elseif (@($classes | Where-Object { $specHalt -ccontains $_ }).Count -gt 0) { 'HALT_NON_REMEDIABLE' }
        else { 'AWAITING_CI' }
        $label = if ($classes.Count -eq 0) { 'empty' } else { $classes -join '+' }
        @{ Label = $label; Classes = [string[]]$classes; Expected = $expected }
    }
)

$entryCase = @(
    @{ Label = 'R5 string candidate_applied'; Json = '{"cycles": [' + (Get-CycleJson '"candidate_applied": "yes"') + ']}'; Expected = @(Get-R5Message 0) }
    @{ Label = 'R5 integer candidate_applied'; Json = '{"cycles": [' + (Get-CycleJson '"candidate_applied": 1') + ']}'; Expected = @(Get-R5Message 0) }
    @{ Label = 'R5 null candidate_applied'; Json = '{"cycles": [' + (Get-CycleJson '"candidate_applied": null') + ']}'; Expected = @(Get-R5Message 0) }
    @{ Label = 'R6 true on failed execution'; Json = '{"cycles": [' + (Get-CycleJson '"candidate_applied": true, "execution_status": "failed"') + ']}'; Expected = @(Get-R6Message 0) }
    @{ Label = 'R6 accepted on complete execution'; Json = '{"completed_attempts": 1, "cycles": [' + (Get-CycleJson '"candidate_applied": true') + ']}'; Expected = @() }
    @{ Label = 'R7a negative attempts'; Json = '{"completed_attempts": -1}'; Expected = @($r7a) }
    @{ Label = 'R7a boolean attempts'; Json = '{"completed_attempts": true}'; Expected = @($r7a) }
    @{ Label = 'R7a string attempts'; Json = '{"completed_attempts": "1"}'; Expected = @($r7a) }
    @{ Label = 'R7a null attempts'; Json = '{"completed_attempts": null}'; Expected = @($r7a) }
    @{ Label = 'R7b mismatch'; Json = '{"completed_attempts": 2, "cycles": [' + (Get-CycleJson '"candidate_applied": true') + ']}'; Expected = @(Get-R7bMessage 2 1) }
    @{ Label = 'R7b zero without cycles'; Json = '{"completed_attempts": 0}'; Expected = @() }
    @{ Label = 'R7b positive without cycles'; Json = '{"completed_attempts": 1}'; Expected = @(Get-R7bMessage 1 0) }
    @{ Label = 'R8a outcomes string'; Json = '{"review_outcomes": "PASS"}'; Expected = @($r8a) }
    @{ Label = 'R8a outcomes object'; Json = '{"review_outcomes": {"verdict": "PASS"}}'; Expected = @($r8a) }
    @{ Label = 'R8b outcome integer'; Json = '{"review_outcomes": [7]}'; Expected = @(Get-R8bMessage 0) }
    @{ Label = 'R8b outcome null then pass'; Json = '{"review_outcomes": [null, ' + $passOutcome + ']}'; Expected = @(Get-R8bMessage 0) }
    @{ Label = 'R9a integer verdict'; Json = '{"review_outcomes": [{"verdict": 7, "findings": []}]}'; Expected = @(Get-R9aMessage 0 '7') }
    @{ Label = 'R9a null verdict'; Json = '{"review_outcomes": [{"verdict": null, "findings": []}]}'; Expected = @(Get-R9aMessage 0 'None') }
    @{ Label = 'R9b findings missing'; Json = '{"review_outcomes": [{"verdict": "PASS"}]}'; Expected = @(Get-R9bMessage 0) }
    @{ Label = 'R9a and R9b together'; Json = '{"review_outcomes": [{"verdict": "x", "findings": "y"}]}'; Expected = @((Get-R9aMessage 0 'x'), (Get-R9bMessage 0)) }
    @{ Label = 'R9c finding integer'; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [7]}]}'; Expected = @(Get-R9cMessage 0 0) }
    @{ Label = 'R9c then R9d in order'; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [7, {"remediability": "bad"}]}]}'; Expected = @((Get-R9cMessage 0 0), (Get-R9dMessage -J 0 -M 1 -V 'bad')) }
    @{ Label = 'R9d integer remediability'; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [{"remediability": 7}]}]}'; Expected = @(Get-R9dMessage -J 0 -M 0 -V '7') }
    @{ Label = 'R9d null remediability'; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [{"remediability": null}]}]}'; Expected = @(Get-R9dMessage -J 0 -M 0 -V 'None') }
    @{ Label = 'R10 pass with autonomous'; Json = '{"review_outcomes": [{"verdict": "PASS", "findings": [{"remediability": "autonomous"}]}]}'; Expected = @(Get-R10Message -J 0 -V 'PASS' -E 'REMEDIATION_REQUIRED') }
    @{ Label = 'R10 halt with empty findings'; Json = '{"review_outcomes": [{"verdict": "HALT_NON_REMEDIABLE", "findings": []}]}'; Expected = @(Get-R10Message -J 0 -V 'HALT_NON_REMEDIABLE' -E 'PASS') }
    @{ Label = 'R10 awaiting with policy hold'; Json = '{"review_outcomes": [{"verdict": "AWAITING_CI", "findings": [{"remediability": "policy_hold"}]}]}'; Expected = @(Get-R10Message -J 0 -V 'AWAITING_CI' -E 'HALT_NON_REMEDIABLE') }
    @{ Label = 'R10 halt precedence mixture accepted'; Json = '{"review_outcomes": [{"verdict": "HALT_NON_REMEDIABLE", "findings": [{"remediability": "policy_hold"}, {"remediability": "human_decision_required"}]}]}'; Expected = @() }
    @{ Label = 'R10 mixed autonomous accepted'; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [{"remediability": "autonomous"}, {"remediability": "human_decision_required"}]}]}'; Expected = @() }
    @{ Label = 'R11 accepted remediation target'; Json = '{"review_outcomes": [' + $rr + '], "cycles": [' + (Get-CycleJson '"opened_by_review": 0') + ']}'; Expected = @() }
    @{ Label = 'R11 halt target'; Json = '{"review_outcomes": [' + $halt + '], "cycles": [' + (Get-CycleJson '"opened_by_review": 0') + ']}'; Expected = @(Get-R11Message 0) }
    @{ Label = 'R11 awaiting target'; Json = '{"review_outcomes": [' + $wait + '], "cycles": [' + (Get-CycleJson '"opened_by_review": 0') + ']}'; Expected = @(Get-R11Message 0) }
    @{ Label = 'R11 out of range'; Json = '{"review_outcomes": [' + $rr + '], "cycles": [' + (Get-CycleJson '"opened_by_review": 5') + ']}'; Expected = @(Get-R11Message 0) }
    @{ Label = 'R11 negative index'; Json = '{"review_outcomes": [' + $rr + '], "cycles": [' + (Get-CycleJson '"opened_by_review": -1') + ']}'; Expected = @(Get-R11Message 0) }
    @{ Label = 'R11 boolean index'; Json = '{"review_outcomes": [' + $rr + '], "cycles": [' + (Get-CycleJson '"opened_by_review": true') + ']}'; Expected = @(Get-R11Message 0) }
    @{ Label = 'R11 outcomes absent'; Json = '{"cycles": [' + (Get-CycleJson '"opened_by_review": 0') + ']}'; Expected = @(Get-R11Message 0) }
    @{ Label = 'R11 non-object target'; Json = '{"review_outcomes": [7], "cycles": [' + (Get-CycleJson '"opened_by_review": 0') + ']}'; Expected = @((Get-R8bMessage 0), (Get-R11Message 0)) }
    @{ Label = 'error order across families'; Json = '{"cycles": [' + (Get-CycleJson '"candidate_applied": "yes", "opened_by_review": 3') + ', ' + (Get-CycleJson '"candidate_applied": true, "execution_status": "failed"') + '], "review_outcomes": [{"verdict": "Pass", "findings": []}, {"verdict": "PASS", "findings": "x"}], "completed_attempts": 5}'; Expected = @((Get-R9aMessage 0 'Pass'), (Get-R9bMessage 1), (Get-R5Message 0), (Get-R11Message 0), (Get-R6Message 1), (Get-R7bMessage 5 1)) }
    @{ Label = 'no new keys'; Json = '{"current_cycle": 0, "cycles": [' + (Get-CycleJson) + ']}'; Expected = @() }
)

$variantCase = @(
    foreach ($v in $specVerdict) {
        $lower = $v.ToLowerInvariant()
        $mixed = $v.Substring(0, 1) + $v.Substring(1).ToLowerInvariant()
        @{ Label = "verdict $v lowercased"; Json = '{"review_outcomes": [{"verdict": "' + $lower + '", "findings": []}]}'; Expected = @(Get-R9aMessage 0 $lower) }
        @{ Label = "verdict $v capitalized"; Json = '{"review_outcomes": [{"verdict": "' + $mixed + '", "findings": []}]}'; Expected = @(Get-R9aMessage 0 $mixed) }
    }
    foreach ($c in $specClass) {
        $upper = $c.ToUpperInvariant()
        $mixed = $c.Substring(0, 1).ToUpperInvariant() + $c.Substring(1)
        @{ Label = "class $c uppercased"; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [{"remediability": "' + $upper + '"}]}]}'; Expected = @(Get-R9dMessage -J 0 -M 0 -V $upper) }
        @{ Label = "class $c capitalized"; Json = '{"review_outcomes": [{"verdict": "REMEDIATION_REQUIRED", "findings": [{"remediability": "' + $mixed + '"}]}]}'; Expected = @(Get-R9dMessage -J 0 -M 0 -V $mixed) }
    }
)

BeforeAll {
    $moduleDirectory = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateUnconditional.psm1') -Force
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorState.psm1') -Force
    # Imported last: OrchestratorStateReceipts.psm1 (reached through the
    # unconditional module) re-imports this module with -Force, which would
    # remove a global import made before it.
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateRemediationAccounting.psm1') -Force
    $script:CorpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_remediation_loop").Path

    # Call the entry point with the loop object and its cycle list (or $null
    # when cycles is absent or not a list), as the receipts module does.
    function Invoke-AccountingEntry {
        [CmdletBinding()]
        [OutputType([System.Object[]])]
        param([Parameter(Mandatory = $true)] [string] $Json)

        $loop = $Json | ConvertFrom-Json
        $cycle = $null
        if ($loop.PSObject.Properties.Name -ccontains 'cycles' -and $loop.cycles -is [array]) {
            $cycle = $loop.cycles
        }
        return , [string[]]@(Get-OrchestratorStateRemediationAccountingError -RemediationLoop $loop -Cycle $cycle)
    }

    # Ordered, case-sensitive comparison returning the mismatch descriptions.
    function Compare-ErrorList {
        [CmdletBinding()]
        [OutputType([System.Object[]])]
        param(
            [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Actual,
            [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Expected
        )

        $mismatch = [System.Collections.Generic.List[string]]::new()
        if ($Actual.Count -ne $Expected.Count) { $mismatch.Add("count $($Actual.Count) -ne $($Expected.Count): $($Actual -join ' | ')") }
        for ($index = 0; $index -lt [Math]::Min($Actual.Count, $Expected.Count); $index++) {
            if (-not ($Actual[$index] -ceq $Expected[$index])) { $mismatch.Add("#${index}: '$($Actual[$index])'") }
        }
        return , $mismatch.ToArray()
    }
}

Describe 'Get-RemediationReviewVerdict' {
    It 'derives the spec verdict for subset <Label>' -ForEach $subsetCase {
        # Arrange / Act
        $observed = InModuleScope OrchestratorStateRemediationAccounting -Parameters @{ Classes = $Classes } {
            param([string[]] $Classes)
            Get-RemediationReviewVerdict -Remediability $Classes
        }
        # Assert
        $observed | Should -BeExactly $Expected
    }

    It 'throws a terminating error beginning invalid remediability for <Label>' -ForEach @(
        @{ Label = 'capitalized class'; Classes = [string[]]@('Autonomous') }
        @{ Label = 'verdict literal'; Classes = [string[]]@('PASS') }
        @{ Label = 'valid then invalid'; Classes = [string[]]@('autonomous', 'AWAITING_CI') }
    ) {
        # Arrange / Act
        $thrown = $null
        try {
            InModuleScope OrchestratorStateRemediationAccounting -Parameters @{ Classes = $Classes } {
                param([string[]] $Classes)
                Get-RemediationReviewVerdict -Remediability $Classes
            }
        } catch {
            $thrown = $_.Exception.Message
        }
        # Assert
        $thrown | Should -Not -BeNullOrEmpty
        $thrown.StartsWith('invalid remediability: ', [System.StringComparison]::Ordinal) | Should -BeTrue
    }
}

Describe 'Get-OrchestratorStateRemediationAccountingError' {
    It 'reports the spec errors for <Label>' -ForEach $entryCase {
        $mismatch = Compare-ErrorList -Actual (Invoke-AccountingEntry -Json $Json) -Expected ([string[]]$Expected)
        $mismatch | Should -BeNullOrEmpty
    }

    It 'rejects the case variant <Label>' -ForEach $variantCase {
        $mismatch = Compare-ErrorList -Actual (Invoke-AccountingEntry -Json $Json) -Expected ([string[]]$Expected)
        $mismatch | Should -BeNullOrEmpty
    }
}

Describe 'Remediation accounting vocabulary' {
    It 'keeps every non-remediable class inside the blocked-reason non-mechanical partition' {
        # Arrange
        $partition = @(InModuleScope OrchestratorState { $script:NON_MECHANICAL_BLOCKED_REASONS })
        $nonRemediable = @(InModuleScope OrchestratorStateRemediationAccounting { $script:NON_REMEDIABLE_CLASSES })
        # Act
        $missing = @($nonRemediable | Where-Object { $partition -cnotcontains $_ })
        # Assert
        $nonRemediable.Count | Should -Be 4
        $missing | Should -BeNullOrEmpty
    }

    It 'pins the vocabulary arrays to the spec tables' {
        $vocabulary = InModuleScope OrchestratorStateRemediationAccounting {
            @{
                Verdict = ($script:REVIEW_VERDICTS -join ',')
                Class   = ($script:REMEDIABILITY_CLASSES -join ',')
                NonRem  = ((@($script:NON_REMEDIABLE_CLASSES) | Sort-Object) -join ',')
                Halt    = ((@($script:HALT_CLASSES) | Sort-Object) -join ',')
            }
        }
        $vocabulary.Verdict | Should -BeExactly 'PASS,REMEDIATION_REQUIRED,HALT_NON_REMEDIABLE,AWAITING_CI'
        $vocabulary.Class | Should -BeExactly 'autonomous,external_dependency,policy_hold,awaiting_ci,human_decision_required'
        $vocabulary.NonRem | Should -BeExactly 'awaiting_ci,external_dependency,human_decision_required,policy_hold'
        $vocabulary.Halt | Should -BeExactly 'external_dependency,human_decision_required,policy_hold'
    }
}

Describe 'Remediation accounting through the unconditional block' {
    It 'validates a halt checkpoint without cycles cleanly' {
        # Arrange: the committed halt corpus checkpoint (no cycles,
        # blocked_reason external_dependency).
        $path = Join-Path -Path $script:CorpusDirectory -ChildPath 'halt_at_first_review_without_cycles.json'
        $state = (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).checkpoint
        # Act
        $errors = @(Get-OrchestratorStateUnconditionalError -State $state)
        # Assert: the full, unfiltered error list is empty.
        $errors | Should -BeNullOrEmpty
    }
}
