Set-StrictMode -Version Latest

# Workflow-invariant suite for the issue #1204 change to .github/workflows/_npm-audit-gate.yml.
#
# The workflow is read from disk as text and partitioned into step blocks: a step begins at a line of six
# spaces, a dash, and 'name:' under the job, and runs to the line before the next step (the text-read
# technique of CiRequiredGateWorkflow.Tests.ps1). No YAML module, process, temporary file, or network call
# is used.

Describe '_npm-audit-gate.yml gate step invariants' {
    BeforeAll {
        $workflowPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../.github/workflows/_npm-audit-gate.yml'
        $script:WorkflowLines = @(Get-Content -LiteralPath $workflowPath -ErrorAction Stop | ForEach-Object { $_.TrimEnd() })
        $script:WorkflowText = $script:WorkflowLines -join "`n"

        $steps = [ordered]@{}
        $current = $null
        foreach ($line in $script:WorkflowLines) {
            if ($line -match '^ {6}- name: (?<StepName>.+)$') {
                $current = [System.Collections.Generic.List[string]]::new()
                $steps[$Matches['StepName']] = $current
                continue
            }
            if ($null -ne $current) { $current.Add($line) }
        }
        $script:AuditStepName = 'Audit dependencies'
        $script:AuditStepLines = @()
        if ($steps.Contains($script:AuditStepName)) { $script:AuditStepLines = @($steps[$script:AuditStepName]) }
        $script:AuditStepText = $script:AuditStepLines -join "`n"
    }

    It 'NAW-JOB-ID-NAME-UNCHANGED keeps the job id npm-audit, its name, and the three-manifest matrix' {
        $script:WorkflowLines | Should -Contain '  npm-audit:'
        $script:WorkflowLines | Should -Contain '    name: npm audit (${{ matrix.manifest }})'
        $script:WorkflowLines | Should -Contain '          - "."'
        $script:WorkflowLines | Should -Contain '          - extensions/drm-copilot'
        $script:WorkflowLines | Should -Contain '          - packages/mcp-server'
    }

    It 'NAW-NODE-VERSION-LINE keeps the node-version line' {
        $script:WorkflowLines | Should -Contain '          node-version: "26.13.0"'
    }

    It 'NAW-STEP-CALLS-GATE-SCRIPT keeps the Audit dependencies step and makes it call Invoke-NpmAuditGate.ps1' {
        $script:AuditStepLines.Count | Should -BeGreaterThan 0 -Because 'the Audit dependencies step must still exist'
        $script:AuditStepText | Should -Match '(?m)^ {8}run: \$\{\{ github\.workspace \}\}/scripts/ci/Invoke-NpmAuditGate\.ps1 '
        $script:AuditStepLines | Should -Contain '        working-directory: ${{ matrix.manifest }}'
    }

    It 'NAW-BARE-AUDIT-LINE-ABSENT removes the bare npm audit line and never omits dev dependencies in the workflow' {
        $script:WorkflowText.Contains('npm audit --audit-level') | Should -BeFalse
        $script:WorkflowText.Contains('--omit') | Should -BeFalse -Because 'the strict production pass and the full pass are run by the gate script'
    }

    It 'NAW-EXCEPTIONS-PATH-PASSED passes the committed exception file through github.workspace' {
        $script:AuditStepText.Contains('-ExceptionsPath "${{ github.workspace }}/config/npm-audit-exceptions.json"') | Should -BeTrue
    }

    It 'NAW-AUDIT-LEVEL-FROM-ENV passes the AUDIT_LEVEL environment value unchanged and keeps the moderate default' {
        $script:AuditStepLines | Should -Contain '          AUDIT_LEVEL: ${{ inputs.audit-level }}'
        $script:AuditStepText.Contains('-AuditLevel "$env:AUDIT_LEVEL"') | Should -BeTrue
        ([regex]::Matches($script:WorkflowText, '(?m)^ {8}default: moderate$')).Count | Should -Be 2 -Because 'both triggers keep the moderate default'
    }

    It 'NAW-SHELL-PWSH runs the Audit dependencies step with shell pwsh directly above its run line' {
        $shellIndex = [array]::IndexOf($script:AuditStepLines, '        shell: pwsh')
        $shellIndex | Should -BeGreaterOrEqual 0
        $script:AuditStepLines[$shellIndex + 1] | Should -BeLike '        run: *'
    }
}
