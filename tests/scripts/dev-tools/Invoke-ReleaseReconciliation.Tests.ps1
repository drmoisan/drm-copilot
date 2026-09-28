Set-StrictMode -Version Latest

Describe "Invoke-ReleaseReconciliation.ps1 - tag-versus-registry reconciliation" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-ReleaseReconciliation.ps1")).Path
        # Dot-source (never execute) the production module so its on-disk lines run
        # under Pester coverage instrumentation, which attributes coverage only to
        # the file that is actually dot-sourced. The entry-point block is skipped
        # because $MyInvocation.InvocationName -eq '.' when dot-sourced, so loading
        # the file starts no process and performs no network call.
        . $script:scriptPath

        # Every input below is an in-memory string collection. Get-UnpublishedTagVersion
        # is a pure set difference, so these tests need no seam, no mock, no network,
        # no temporary file, and no wall-clock wait.
        $script:publishedSet = @('1.0.25', '1.1.0', '1.1.1')
    }

    It "returns an empty result when every tag version is published" {
        $result = @(Get-UnpublishedTagVersion -TagVersion @('1.1.0', '1.1.1') -PublishedVersion $script:publishedSet)

        $result.Count | Should -Be 0
    }

    It "returns the single unpublished version when one tag version is missing from the registry set" {
        # This is the 1.0.25 shape of the defect: a release tag exists for the version
        # but the registry never received it, so a retroactive sweep is the only layer
        # that can surface it.
        $result = @(Get-UnpublishedTagVersion -TagVersion @('1.1.0', '1.1.2', '1.1.1') -PublishedVersion $script:publishedSet)

        $result.Count | Should -Be 1
        $result[0] | Should -Be '1.1.2'
    }

    It "returns an empty result for an empty tag set" {
        # An empty tag set must yield an empty array rather than $null, so the caller
        # can count and index the result without a null guard.
        $result = @(Get-UnpublishedTagVersion -TagVersion @() -PublishedVersion $script:publishedSet)

        $result.Count | Should -Be 0
    }

    It "returns every tag version when the published set is empty" {
        # A registry query that legitimately reports no published versions must not be
        # read as "everything is published"; the whole tag set is the divergence.
        $result = @(Get-UnpublishedTagVersion -TagVersion @('1.1.0', '1.1.1') -PublishedVersion @())

        $result.Count | Should -Be 2
    }

    It "ignores blank entries and trims surrounding whitespace before comparing" {
        # A version list parsed out of command output carries stray blank lines and
        # padding. Treating a padded '1.1.0' as unpublished would raise a false alarm.
        $result = @(Get-UnpublishedTagVersion -TagVersion @(' 1.1.0 ', '', '   ', '1.1.2') -PublishedVersion @('1.1.0', ' '))

        $result.Count | Should -Be 1
        $result[0] | Should -Be '1.1.2'
    }

    It "collapses a duplicated tag version to a single result entry in tag-set order" {
        # Deterministic output: a duplicate tag must not be reported twice, and the
        # tag set's ordering is preserved so the reported divergence is stable.
        $result = @(Get-UnpublishedTagVersion -TagVersion @('1.1.3', '1.1.2', '1.1.3') -PublishedVersion $script:publishedSet)

        $result.Count | Should -Be 2
        $result[0] | Should -Be '1.1.3'
        $result[1] | Should -Be '1.1.2'
    }

    It "reports a zero exit code and a none message when no tag version is unpublished" {
        # The scheduled sweep must be silent when there is nothing to report; a sweep
        # that signalled on every run would be ignored by the time it mattered.
        $report = Get-ReconciliationReport -TagVersion @('1.1.0') -PublishedVersion $script:publishedSet

        $report.ExitCode | Should -Be 0
        $report.Message | Should -Be 'UNPUBLISHED_TAG_VERSIONS: none'
        @($report.UnpublishedVersion).Count | Should -Be 0
    }

    It "reports a non-zero exit code and names every unpublished version when the sets diverge" {
        # The exit code is what the scheduled workflow turns into a visible failure, and
        # the message is what names the versions an operator has to act on.
        $report = Get-ReconciliationReport -TagVersion @('1.1.2', '1.1.3') -PublishedVersion $script:publishedSet

        $report.ExitCode | Should -Be 1
        $report.Message | Should -Be 'UNPUBLISHED_TAG_VERSIONS: 1.1.2, 1.1.3'
        @($report.UnpublishedVersion).Count | Should -Be 2
    }
}
