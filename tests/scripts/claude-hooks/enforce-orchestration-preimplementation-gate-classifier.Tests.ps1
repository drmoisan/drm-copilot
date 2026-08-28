#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Classifier and preparation-mode cases for the Claude preimplementation gate.
.DESCRIPTION
    Issue #554, remediation cycle 1. These cases cover the classifier and
    preparation-mode functions of
    .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 that the
    cycle-1 review recorded as uncovered: the whole body of
    Test-PreparationModeDelegation, which lost its only production call site when
    this branch replaced Test-ImplementationDelegation (finding R2), and the
    classifier's non-orchestrator allow branch (finding R4).

    New sibling suite. The Claude-side edit target the remediation directive named,
    enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1, stands
    at 494 of 500 lines against the cap in .claude/rules/general-code-change.md,
    leaving six lines of headroom against the roughly fifty lines these cases
    require. The same reasoning placed that suite's own cases outside
    enforce-orchestration-preimplementation-gate.Tests.ps1 when it stood at 461 of
    500 lines, so this file follows the precedent the spec's Test Strategy set.
    No pre-existing test file is edited by this remediation.

    Determinism. Every fixture is a literal string or a [pscustomobject] built in
    the case body. The suite makes no temporary file, performs no filesystem write,
    reads no wall clock, opens no network connection, starts no external process,
    and registers no Mock. Checkpoint content reaches the decision function through
    its injection parameter, so each result is a pure function of its arguments.
#>

Describe 'enforce-orchestration-preimplementation-gate.ps1 classifier (issue #554)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        # Dot-sourced explicitly as well as through the gate hook above, so a future
        # change to the hook's dot-source line cannot silently leave these cases
        # asserting against functions and constants that came from somewhere else.
        # The file is pure, so redefining it is idempotent.
        $script:ModesUnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1").Path
        . $script:ModesUnderTest

        function New-ClassifierToolInput {
            # A flat tool_input object, which is the shape the classifier consumes after
            # the envelope has been unwrapped. Both reads it performs are field-scoped,
            # so a value placed anywhere other than 'prompt' cannot influence the result.
            param(
                [string] $SubagentType = 'orchestrator',
                [string] $Prompt = ''
            )

            return [pscustomobject]@{ subagent_type = $SubagentType; prompt = $Prompt }
        }

        function ConvertTo-ClassifierDelegationJson {
            # A full Agent delegation envelope as a literal JSON string, for the one
            # decision-level case below. No fixture value carries a double quote or a
            # backslash; every value is plain ASCII prose.
            param(
                [string] $SubagentType = 'orchestrator',
                [string] $Prompt = ''
            )

            return '{"tool_name":"Agent","tool_input":{"subagent_type":"' +
            $SubagentType + '","prompt":"' + $Prompt + '"}}'
        }

        function ConvertTo-ClassifierUnreadyCheckpointJson {
            # An UNREADY single-feature checkpoint: no route id and lifecycle_ready false.
            # It must be bound explicitly at every call site. An unbound value falls
            # through to the on-disk checkpoint, which is ready during an orchestrated
            # run, and an allow assertion would then pass vacuously.
            return '{"issue-num":"554","feature-folder":"docs/features/active/preimplementation-gate-blocks-epic-execution-554","route_id":"","lifecycle_ready":false}'
        }
    }

    Context 'the preparation-mode delegation predicate' {
        # Finding R2. Test-PreparationModeDelegation lost its only production call site
        # when this branch replaced Test-ImplementationDelegation, so its body became
        # uncovered on the Claude surface while the Codex copy kept coverage from
        # tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1. The function
        # is deliberately retained: spec.md lists it under "Not modified", and removing
        # it would break that passing Codex legacy-contract test. These four cases
        # restore coverage of all three conjuncts.

        It 'returns false for a null tool input' {
            # The null-tolerance contract spec.md pins at decision D2.
            Test-PreparationModeDelegation -ToolInput $null | Should -BeFalse
        }

        It 'returns false for a non-orchestrator subagent type carrying both preparation markers' {
            # Second conjunct: the delegated agent must be exactly 'orchestrator'. Both
            # markers are present, so only the subagent-type check can produce the false.
            $toolInput = New-ClassifierToolInput -SubagentType 'task-researcher' -Prompt 'Preparation mode: true. route_id: preparation. Promote only.'
            Test-PreparationModeDelegation -ToolInput $toolInput | Should -BeFalse
        }

        It 'returns false for an orchestrator carrying only one preparation marker' {
            # Third conjunct: BOTH markers must appear, with their trailing periods.
            $toolInput = New-ClassifierToolInput -SubagentType 'orchestrator' -Prompt 'Preparation mode: true. Do the work.'
            Test-PreparationModeDelegation -ToolInput $toolInput | Should -BeFalse
        }

        It 'returns true for an orchestrator carrying both preparation markers' {
            $toolInput = New-ClassifierToolInput -SubagentType 'orchestrator' -Prompt 'Preparation mode: true. route_id: preparation. Promote only.'
            Test-PreparationModeDelegation -ToolInput $toolInput | Should -BeTrue
        }
    }

    Context 'the duplicated preparation-marker rule' {
        It 'pins the preparation marker set equal to the preparation row of the mode table' {
            # The secondary concern recorded with R2. Retaining the orphaned function
            # leaves the preparation-marker rule with two independent implementations in
            # the same file: $script:PreparationModeMarkers in the gate hook and the
            # preparation row of $script:OrchestrationDelegationModeTable in the modes
            # sibling. Nothing else enforces that they stay in step, so this assertion
            # does. A divergence in a security-relevant gate would let one implementation
            # exempt a delegation the other would gate.
            $preparationRow = $script:OrchestrationDelegationModeTable | Where-Object { $_.Mode -eq 'preparation' }
            $preparationRow | Should -Not -BeNullOrEmpty
            Compare-Object $script:PreparationModeMarkers $preparationRow.Markers | Should -BeNullOrEmpty
        }
    }

    Context 'the classifier allow branch for a non-orchestrator agent' {
        It 'does not classify a non-orchestrator agent as an implementation delegation' {
            # Finding R4, closing line 210 of the gate hook: the one uncovered added line
            # the four-group characterization did not account for. Returning $false means
            # "not an implementation delegation", so the gate ALLOWS. The prompt carries
            # both legacy free-text tokens, which the pre-fix seven-token scan over the
            # serialized payload would have matched; the structural classifier reads
            # subagent_type instead, so the tokens no longer narrow the decision. This
            # documents the Fault-1 fix in the widening direction.
            $toolInput = New-ClassifierToolInput -SubagentType 'task-researcher' -Prompt 'Research the implementation and report before we execute anything.'
            Test-ImplementationDelegation -ToolInput $toolInput | Should -BeFalse
        }

        It 'allows a non-orchestrator delegation against an unready single-feature checkpoint' {
            # Closes non-blocking gap N4 by asserting the spec-sanctioned permissive
            # widening at the DECISION level rather than leaving it implicit at the
            # predicate level. -CheckpointRaw is bound explicitly with an unready value:
            # an unbound value would fall through to the on-disk checkpoint, which is
            # ready during an orchestrated run, and this allow assertion would then pass
            # vacuously whatever the classifier did.
            $json = ConvertTo-ClassifierDelegationJson -SubagentType 'task-researcher' -Prompt 'Research the implementation and report before we execute anything.'
            $checkpoint = ConvertTo-ClassifierUnreadyCheckpointJson

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
