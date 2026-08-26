@{
    Run          = @{
        Path = @('scripts', 'tests/powershell', 'tests/scripts')
        Exit = $true
    }
    Should       = @{
        ErrorAction = 'Stop'
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
    TestResult   = @{
        Enabled      = $true
        OutputFormat = 'JUnitXml'
        OutputPath   = 'artifacts/pester/pester-junit.xml'
    }
    CodeCoverage = @{
        Enabled               = $true
        # Use Pester's CoverageGutters format so VS Code Coverage Gutters
        # can map file paths correctly.
        OutputFormat          = 'CoverageGutters'
        OutputPath            = 'artifacts/pester/powershell-coverage.xml'
        Path                  = @(
            # Scope coverage to hook files with deterministic Pester coverage in this branch.
            # Broader script/module globs include bootstrap and one-shot automation paths that
            # are validated by their own suites but not meaningfully covered by this hook batch.
            '.claude/hooks/validate-bash.ps1'
            '.claude/hooks/check-python-test-purity.ps1'
            '.claude/hooks/check-powershell-test-purity.ps1'
            '.claude/hooks/enforce-python-batch-budget.ps1'
            '.claude/hooks/enforce-powershell-batch-budget.ps1'
            # Issue #272 hardened this PreToolUse hook with a new orchestrator-state preflight
            # check; measured here so the change produces real per-file coverage evidence.
            '.claude/hooks/enforce-pr-author-skill.ps1'
            # Issue #214 added/changed these four release scripts and provided dedicated
            # Pester suites; they are measured here to produce real per-file changed-line
            # coverage rather than relying on behavioral-only evidence.
            'scripts/powershell/Publish-DrmCopilotExtension.ps1'
            'scripts/dev-tools/Invoke-FullRelease.ps1'
            'scripts/dev-tools/Invoke-MarketplacePublish.ps1'
            'scripts/dev-tools/Invoke-ReleaseTagPush.ps1'
            # Issue #275 remediation cycle 1 (fix #3): measure the epic-orchestrate hook set and
            # its dot-sourced sibling module so no production hook is excluded from coverage.
            '.claude/hooks/enforce-epic-merge-gate.ps1'
            '.claude/hooks/enforce-epic-wave-barrier.ps1'
            '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'
            '.claude/hooks/enforce-pr-author-skill.ps1'
            '.claude/hooks/validate-orchestrator-output.ps1'
            '.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1'
            # Issue #301 remediation cycle 1 (fix #1): measure the completion-consistency
            # hook set (Claude and Codex variants) so their Pester coverage is captured.
            '.claude/hooks/enforce-completion-consistency.ps1'
            '.claude/hooks/enforce-completion-helpers.ps1'
            '.codex/hooks/enforce-completion-consistency.ps1'
            '.codex/hooks/enforce-completion-helpers.ps1'
            # Issue #298 fixed ConvertTo-CommandResult's handling of an empty array Output
            # parameter in this script; measured here so the change produces real per-file
            # coverage evidence going forward.
            'scripts/dev-tools/Invoke-FullReleaseFlow.ps1'
            # Issue #305 added this PreToolUse model-routing-receipt deterrent hook; measured
            # here so the new production hook is not excluded from coverage.
            '.claude/hooks/enforce-model-routing-receipt.ps1'
            # Issue #312 added the .claude-resident PowerShell model-routing library so the
            # push-down bundle no longer cites missing scripts/dev_tools references; measured
            # here so the new production module is not excluded from coverage.
            '.claude/lib/model-routing/ModelRouting.psm1'
            # The portable orchestrator-state modules make the pushed-down enforcement hooks
            # work in consumer repos without scripts/dev_tools; measured here so the new
            # production modules are not excluded from coverage.
            '.claude/lib/orchestrator-state/OrchestratorState.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1'
            # Issue #328 added this dev-tools worktree launcher script; measured here so the
            # changed production file is in the coverage denominator (R1). The test suite
            # dot-sources the file (guarded body) so line attribution is valid.
            'scripts/dev-tools/new-claude-worktree-session.ps1'
            # Issue #334 added this SessionStart hook that persists the current session id;
            # measured here so the new production hook is not excluded from coverage. The
            # test suite dot-sources the file (guarded body) so line attribution is valid.
            '.claude/hooks/persist-session-id.ps1'
            # Issue #344 remediation cycle 1 (R2): measure the new production ScanConfig module
            # so it is not excluded from coverage; PoshQC.psm1 sub-module loading was refactored
            # to AST-based scriptblocks (Parser::ParseFile(...).GetScriptBlock()) so Pester
            # coverage breakpoints bind to the on-disk source file.
            'scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1'
            # Issue #357 remediation cycle 1 (fix #1): measure the atomic-planner SubagentStop
            # hook so its Pester coverage is captured in the canonical artifact.
            '.claude/hooks/validate-planner-output.ps1'
            # Issue #366 added the discovery-artifact completion-gate hooks (PreToolUse and
            # SubagentStop); measured here so the new production hooks are not excluded from
            # coverage.
            '.claude/hooks/enforce-discovery-artifact-gate.ps1'
            '.claude/hooks/validate-discovery-artifact-gate.ps1'
            # Issue #475 added the portable discovery-validation module so both discovery
            # hooks stop invoking a Python interpreter; measured here so the new production
            # module is not excluded from coverage.
            '.claude/lib/discovery-validation/DiscoveryValidation.psm1'
            # Issue #475 added the portable orchestrator-state parity modules so the
            # completion hook validates the checkpoint without a Python interpreter;
            # measured here so the new production modules are not excluded from coverage.
            '.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1'
            # Issue #475 added the portable Codex routing resolvers so the U6.X and U6.T
            # checkpoint checks resolve deployments and topologies without a Python
            # interpreter; measured here so the new production modules are not excluded.
            '.claude/lib/codex-routing/CodexDeployment.psm1'
            '.claude/lib/codex-routing/CodexTopology.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1'
            '.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1'
            # Issue #392 changed the Invoke-PoshQCTest default seams ($EnsureModule -Global
            # import and the global-session-state $InvokePester trampoline) so the bundled
            # entry path hosts the Pester run in the global session state; measured here so
            # the fix produces real per-file changed-line coverage evidence.
            'scripts/powershell/PoshQC/PoshQC.Testing.psm1'
            # Issue #415 remediation cycle 1 (R1): the PreToolUse hook transport fix added the
            # shared payload-parsing module and rewired seven Codex hooks to consume it. Those
            # production files were absent from this list, so the changed surface was outside
            # the coverage denominator. Measured here so the changed production surface is not
            # excluded from coverage.
            '.codex/hooks/codex-pretooluse-file-mapping.ps1'
            '.codex/hooks/check-python-test-purity.ps1'
            '.codex/hooks/check-powershell-test-purity.ps1'
            '.codex/hooks/enforce-python-batch-budget.ps1'
            '.codex/hooks/enforce-powershell-batch-budget.ps1'
            '.codex/hooks/enforce-evidence-locations.ps1'
            '.codex/hooks/enforce-checkpoint-monotonic.ps1'
            '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
            # Issue #539 extracted the command-branch pathspec classifier into this
            # dot-sourced sibling for headroom; registered so the new production file stays
            # in the coverage denominator per the Coverage Exclusion Policy.
            '.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1'
            # Issue #415 remediation cycle 2 (R-COV): the detached-HEAD null-guard fix changed
            # these two Codex PreToolUse hooks. Both were absent from this list, so the changed
            # production surface was outside the coverage denominator. Measured here so the
            # changed production surface is not excluded from coverage.
            '.codex/hooks/enforce-epic-child-worktree-binding.ps1'
            '.codex/hooks/enforce-epic-planning-only.ps1'
            # Issue #447 added the .claude-resident PowerShell blast-radius library, the
            # two-language mirror of scripts/dev_tools/compute_blast_radius.py and its
            # helper modules. The set is split across seven files only to satisfy the
            # 500-line limit; measured here so no new production module is excluded from
            # coverage.
            # Issue #489 added BlastRadiusNormalization.psm1, which holds the
            # read-by-mandate exclusion plus Get-ContractIdentifier and
            # Resolve-BlastRadiusModule relocated out of the two modules that had run
            # out of headroom. The relocation moves already-measured lines, so the new
            # file is registered here to keep them in the coverage denominator.
            # Issue #502 added BlastRadiusTokenShape.psm1, the seventh file. It holds the
            # new placeholder-marker predicate plus Test-MultipleFeatureFolderSpan
            # relocated out of BlastRadiusExtraction.psm1, which had two lines of
            # headroom left. CodeCoverage.Path is an explicit per-file allow-list, so
            # without this entry the new production module and the relocated
            # already-measured lines would both sit outside the coverage denominator,
            # which the Coverage Exclusion Policy forbids.
            '.claude/lib/blast-radius/BlastRadiusExtraction.psm1'
            '.claude/lib/blast-radius/BlastRadiusGlob.psm1'
            '.claude/lib/blast-radius/BlastRadiusConfig.psm1'
            '.claude/lib/blast-radius/BlastRadiusValidation.psm1'
            '.claude/lib/blast-radius/BlastRadius.psm1'
            '.claude/lib/blast-radius/BlastRadiusNormalization.psm1'
            '.claude/lib/blast-radius/BlastRadiusTokenShape.psm1'
            # Issue #440 added the two parallel enforcement hooks (the Layer 1 cohort
            # barrier and the worktree removal gate) and extended the invocation-origin
            # hook with the parallel-agent family; measured here so no new or changed
            # production hook is excluded from coverage.
            '.claude/hooks/enforce-parallel-cohort-barrier.ps1'
            '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'
            '.claude/hooks/enforce-epic-invocation-origin.ps1'
            # Issue #446 added this Layer-1 parallel drift-gate PreToolUse hook; measured here so
            # the new production hook is not excluded from coverage.
            '.claude/hooks/enforce-parallel-drift-gate.ps1'
            # Issue #446 remediation cycle 1 split the seven shape-and-derivation helpers out of
            # that hook into this dot-sourced sibling module; measured here so the Coverage
            # Exclusion Policy's no-production-file-excluded rule still holds after the split.
            '.claude/hooks/enforce-parallel-drift-gate-helpers.ps1'
            # Issue #442 added this PreToolUse abandon-gate hook, which guards the destructive
            # parallel abandon disposition; measured here so the new production hook is not
            # excluded from coverage. The test suite dot-sources the file (guarded body) so
            # line attribution is valid.
            '.claude/hooks/enforce-parallel-abandon-gate.ps1'
            # Issue #491 added the Mermaid validation PreToolUse hook and its dependency-free
            # validator library; measured here so the new production files are not excluded from
            # coverage. The hook's test suite dot-sources the file (guarded body) and the library
            # suites import the modules, so line attribution is valid.
            '.claude/hooks/enforce-mermaid-validation.ps1'
            '.claude/lib/mermaid/MermaidGrammar.psm1'
            '.claude/lib/mermaid/MermaidLineScanner.psm1'
            '.claude/lib/mermaid/MermaidMarkdownFences.psm1'
            '.claude/lib/mermaid/MermaidValidation.psm1'
            # Issue #501 fixed the PreToolUse payload transport and shape across the whole
            # hook surface. CodeCoverage.Path is an explicit per-file allow-list, so the new
            # shared payload module, the six hooks that were changed but never registered,
            # and the two dot-sourced helper siblings extracted for headroom are registered
            # here. Without them the changed production surface would sit outside the
            # coverage denominator, which the Coverage Exclusion Policy forbids.
            '.claude/lib/hook-payload/HookPayload.psm1'
            '.claude/hooks/enforce-promotion-mcp-only.ps1'
            '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'
            # Issue #539 extracted the command-branch pathspec classifier into this
            # dot-sourced sibling for headroom; registered so the new production file stays
            # in the coverage denominator per the Coverage Exclusion Policy.
            '.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1'
            '.claude/hooks/enforce-evidence-locations.ps1'
            '.claude/hooks/enforce-feature-folder-order.ps1'
            '.claude/hooks/enforce-checkpoint-monotonic.ps1'
            '.claude/hooks/enforce-prd-feature-before-planner.ps1'
            '.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1'
            '.claude/hooks/enforce-pr-author-skill-helpers.ps1'
            # Issue #526 added this out-of-band release-verification module (Layer B of the
            # missed-npm-publish defence). CodeCoverage.Path is an explicit per-file
            # allow-list, so the new production file is registered here; without it the file
            # would sit outside the coverage denominator, which the Coverage Exclusion Policy
            # forbids. Its Pester suite dot-sources the file (guarded entry-point body), so
            # line attribution is valid.
            'scripts/dev-tools/Invoke-ReleaseVerification.ps1'
            # Issue #526 added this release-reconciliation module (Layer C of the
            # missed-npm-publish defence). CodeCoverage.Path is an explicit per-file
            # allow-list, so the new production file is registered here; without it the file
            # would sit outside the coverage denominator, which the Coverage Exclusion Policy
            # forbids. Its Pester suite dot-sources the file (guarded entry-point body), so
            # line attribution is valid.
            'scripts/dev-tools/Invoke-ReleaseReconciliation.ps1'
        )
        # Optional: don't fail the run on coverage percentage
        CoveragePercentTarget = 0
    }
}








