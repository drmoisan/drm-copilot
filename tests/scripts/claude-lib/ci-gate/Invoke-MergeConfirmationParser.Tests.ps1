Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Unit tests for .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 (issue #952).
.DESCRIPTION
    The parser maps one pull-request snapshot (gh pr view --json output or a GraphQL
    pullRequest node) to merged, pending, not_queued, or closed. Every case passes a literal
    JSON string; no live gh, no network, no child process, and no temporary file is used.
#>

Describe 'Invoke-MergeConfirmationParser (issue #952)' {
    BeforeAll {
        # Dot-source the production script so its functions are defined in the test scope;
        # the entry point is skipped because $MyInvocation.InvocationName is '.'.
        $script:ParserPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1')).Path
        . $script:ParserPath

        $script:ClosedJson = '{"state":"CLOSED","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}'
    }

    It 'maps MERGED with a merge commit to merged with the commit SHA and merge time' {
        # Arrange: a merged pull request with a merge commit.
        $json = '{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","isInMergeQueue":false,"mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"autoMergeRequest":null}'

        # Act
        $result = Invoke-MergeConfirmationParser -PrJson $json

        # Assert: the status, the merge commit SHA, and the merge time are reported.
        $result.Status | Should -BeExactly 'merged'
        $result.MergeCommitSha | Should -BeExactly '0123456789abcdef0123456789abcdef01234567'
        $result.MergedAt | Should -BeExactly '2026-10-16T12:34:56Z' -Because 'the merge time is reported in UTC ISO-8601 form'
    }

    It 'throws when MERGED carries an empty merge commit oid' {
        $json = '{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","mergeCommit":{"oid":""}}'

        { Invoke-MergeConfirmationParser -PrJson $json } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser:*'
    }

    It 'throws when MERGED carries a null merge commit' {
        $json = '{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","mergeCommit":null}'

        { Invoke-MergeConfirmationParser -PrJson $json } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser:*'
    }

    It 'maps CLOSED to closed with an empty SHA and merge time' {
        $result = Invoke-MergeConfirmationParser -PrJson $script:ClosedJson

        $result.Status | Should -BeExactly 'closed'
        $result.MergeCommitSha | Should -BeExactly ''
        $result.MergedAt | Should -BeExactly ''
    }

    It 'maps OPEN with isInMergeQueue true to pending' {
        $json = '{"state":"OPEN","mergedAt":null,"isInMergeQueue":true,"mergeCommit":null,"autoMergeRequest":null}'

        $result = Invoke-MergeConfirmationParser -PrJson $json

        $result.Status | Should -BeExactly 'pending' -Because 'a pull request in the merge queue has not merged yet'
        $result.MergeCommitSha | Should -BeExactly ''
    }

    It 'maps OPEN with a non-null autoMergeRequest and no isInMergeQueue field to pending' {
        # gh pr view --json has no isInMergeQueue field; auto-merge alone marks the request pending.
        $json = '{"state":"OPEN","mergedAt":null,"mergeCommit":null,"autoMergeRequest":{"enabledAt":"2026-10-16T12:00:00Z"}}'

        $result = Invoke-MergeConfirmationParser -PrJson $json

        $result.Status | Should -BeExactly 'pending'
    }

    It 'maps OPEN with isInMergeQueue false and a null autoMergeRequest to not_queued' {
        $json = '{"state":"OPEN","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}'

        $result = Invoke-MergeConfirmationParser -PrJson $json

        $result.Status | Should -BeExactly 'not_queued'
    }

    It 'maps OPEN with neither field present to not_queued' {
        $json = '{"state":"OPEN"}'

        $result = Invoke-MergeConfirmationParser -PrJson $json

        $result.Status | Should -BeExactly 'not_queued'
        $result.MergedAt | Should -BeExactly ''
    }

    It 'throws on malformed JSON' {
        { Invoke-MergeConfirmationParser -PrJson '{not-json' } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser:*'
    }

    It 'throws on an unrecognized state' {
        { Invoke-MergeConfirmationParser -PrJson '{"state":"DRAFT"}' } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser:*DRAFT*'
    }

    It 'throws when the state field is absent' {
        { Invoke-MergeConfirmationParser -PrJson '{"mergedAt":null}' } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser:*'
    }

    It 'emits compressed JSON with Status, MergeCommitSha, and MergedAt when -AsJson is set' {
        $json = '{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","mergeCommit":{"oid":"abc123"}}'

        $text = Invoke-MergeConfirmationParser -PrJson $json -AsJson

        # Assert on the emitted text: parsing it back with ConvertFrom-Json would turn the
        # MergedAt string into a [datetime] and hide the exact emitted value.
        $text | Should -BeOfType [string]
        $text | Should -Not -Match "`n" -Because 'the JSON output is compressed onto one line'
        $text | Should -BeExactly '{"Status":"merged","MergeCommitSha":"abc123","MergedAt":"2026-10-16T12:34:56Z"}'
    }

    It 'runs the script entry point when invoked directly' {
        # The call operator runs the script in-process; InvocationName is not '.', so the
        # entry point executes. No child process is started.
        $result = & $script:ParserPath -PrJson $script:ClosedJson

        $result.Status | Should -BeExactly 'closed'
    }

    It 'maps MERGED with a null mergedAt to merged with an empty merge time' {
        # Arrange: gh can report a merged pull request whose mergedAt is null.
        $json = '{"state":"MERGED","mergedAt":null,"mergeCommit":{"oid":"abc123"}}'

        # Act
        $result = Invoke-MergeConfirmationParser -PrJson $json

        # Assert: the null merge time is rendered as an empty string, not an error.
        $result.Status | Should -BeExactly 'merged'
        $result.MergedAt | Should -BeExactly '' -Because 'a null mergedAt is handled (AC-12)'
    }

    It 'throws the null-or-empty message for an empty snapshot' {
        { Invoke-MergeConfirmationParser -PrJson '' } | Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser: the pull-request snapshot is null or empty.'
    }

    It 'renders a datetimeoffset merge time as UTC ISO-8601' {
        # Arrange: a +02:00 value. ConvertFrom-Json does not produce this type, so the branch is
        # exercised through the function directly.
        $value = [datetimeoffset]::new(2026, 10, 16, 14, 34, 56, [timespan]::FromHours(2))

        $text = ConvertTo-MergeConfirmationTimeText -Value $value

        $text | Should -BeExactly '2026-10-16T12:34:56Z'
    }

    It 'returns a non-date merge time value verbatim' {
        $text = ConvertTo-MergeConfirmationTimeText -Value 'not-a-date'

        $text | Should -BeExactly 'not-a-date'
    }
}
