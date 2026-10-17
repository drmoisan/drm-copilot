Set-StrictMode -Version Latest

# Unit suite for the pure change-scope helpers in scripts/ci/CiChangeScope.psm1 (issue #962).
#
# Every row calls one exported function with in-memory input. The module is imported with
# -ErrorAction Stop in BeforeAll, so a missing module fails the whole container. No process, temporary
# file, or network call is made; run and job payloads are built in memory with ConvertTo-Json.

Describe 'CiChangeScope.psm1 pure change-scope helpers' {
    BeforeAll {
        $script:ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/CiChangeScope.psm1'
        Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

        # The section 9 allowlist of the issue #962 plan, held in the test so these rows do not depend on
        # the committed config file (the config suite pins that file separately).
        $script:ConfigJson = @'
{
  "version": 1,
  "include_prefixes": [
    "docs/features/active/",
    "docs/features/completed/",
    "docs/features/potential/",
    "docs/research/"
  ],
  "exclude_prefixes": [
    "docs/features/potential/template.md",
    "docs/features/templates/"
  ],
  "extensions": [".md", ".txt", ".log", ".json", ".xml"]
}
'@
        $script:Config = ConvertFrom-CiDocsOnlyPathConfig -Json $script:ConfigJson
        $script:Repository = 'drmoisan/drm-copilot'
        # The seven-prefix allowlist of issue #973 (spec decision D5), used only by the #973 rows.
        $script:SevenPrefixConfig = ConvertFrom-CiDocsOnlyPathConfig -Json '{"version":1,"include_prefixes":["docs/features/active/","docs/features/archive/","docs/features/completed/","docs/features/epics/","docs/features/parallel/","docs/features/potential/","docs/research/"],"exclude_prefixes":["docs/features/potential/template.md","docs/features/templates/"],"extensions":[".md",".txt",".log",".json",".xml"]}'

        # Builds one workflow-run entry shaped like the GitHub Actions runs API payload.
        function Get-TestRunEntry {
            param([long] $Id, [long] $RunNumber, [string] $Conclusion = 'success', [string] $HeadRepository = 'drmoisan/drm-copilot', [string] $HeadSha = ('a' * 40))
            return @{
                id              = $Id
                run_number      = $RunNumber
                conclusion      = $Conclusion
                head_sha        = $HeadSha
                head_repository = @{ full_name = $HeadRepository }
            }
        }

        # Serializes run entries into the runs payload text that Select-CiGreenBaseCandidates parses.
        function ConvertTo-TestRunListJson {
            param([object[]] $Runs)
            return (ConvertTo-Json -InputObject @{ workflow_runs = @($Runs) } -Depth 5)
        }

        # Serializes job entries into the jobs payload text that Test-CiFullRunMarker parses.
        function ConvertTo-TestJobListJson {
            param([object[]] $Jobs)
            return (ConvertTo-Json -InputObject @{ jobs = @($Jobs) } -Depth 5)
        }
    }

    Context 'event eligibility' {
        It 'Test-CiChangeScopeEventEligible returns EVENT_NOT_PULL_REQUEST for <EventName> (AC-1)' -ForEach @(
            @{ EventName = 'merge_group' }
            @{ EventName = 'push' }
            @{ EventName = 'workflow_dispatch' }
        ) {
            $result = Test-CiChangeScopeEventEligible -EventName $EventName -HeadRepository $script:Repository -Repository $script:Repository

            $result | Should -BeExactly 'EVENT_NOT_PULL_REQUEST' -Because "$EventName must always run the full CI"
        }

        It 'Test-CiChangeScopeEventEligible returns nothing for a same-repository pull_request (AC-1)' {
            $result = Test-CiChangeScopeEventEligible -EventName 'pull_request' -HeadRepository $script:Repository -Repository $script:Repository

            $result | Should -BeNullOrEmpty -Because 'a same-repository pull request may use the docs-only decision'
        }

        It 'Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a different head repository (AC-2)' {
            $result = Test-CiChangeScopeEventEligible -EventName 'pull_request' -HeadRepository 'someone/drm-copilot' -Repository $script:Repository

            $result | Should -BeExactly 'FORK_PULL_REQUEST' -Because 'a fork pull request always runs the full CI'
        }

        It 'Test-CiChangeScopeEventEligible returns FORK_PULL_REQUEST for a blank head repository (AC-2)' {
            $result = Test-CiChangeScopeEventEligible -EventName 'pull_request' -HeadRepository '' -Repository $script:Repository

            $result | Should -BeExactly 'FORK_PULL_REQUEST' -Because 'a missing head repository cannot be shown to be this repository'
        }
    }

    Context 'allowlist configuration parsing' {
        It 'ConvertFrom-CiDocsOnlyPathConfig parses a valid config and lower-cases the extensions (AC-14)' {
            # Arrange: a valid config whose single extension is upper case.
            $json = '{"version":1,"include_prefixes":["docs/research/"],"exclude_prefixes":[],"extensions":[".MD"]}'

            # Act
            $config = ConvertFrom-CiDocsOnlyPathConfig -Json $json

            # Assert
            $config.Version | Should -Be 1
            ($config.IncludePrefixes -join ',') | Should -BeExactly 'docs/research/'
            ($config.Extensions -join ',') | Should -BeExactly '.md' -Because 'extensions are compared case-insensitively, so they are stored lower case'
        }

        It 'ConvertFrom-CiDocsOnlyPathConfig rejects <Case> (AC-14)' -ForEach @(
            @{ Case = 'malformed JSON'; Json = '{bad'; Message = 'CI_DOCS_ONLY_CONFIG_INVALID: malformed JSON' }
            @{ Case = 'empty text'; Json = ''; Message = 'CI_DOCS_ONLY_CONFIG_INVALID: malformed JSON' }
            @{ Case = 'version 2'; Json = '{"version":2,"include_prefixes":["docs/research/"],"exclude_prefixes":[],"extensions":[".md"]}'; Message = 'CI_DOCS_ONLY_CONFIG_INVALID: version must be 1' }
            @{ Case = 'missing include_prefixes'; Json = '{"version":1,"exclude_prefixes":[],"extensions":[".md"]}'; Message = 'CI_DOCS_ONLY_CONFIG_INVALID: include_prefixes must be a non-empty array of non-blank strings' }
            @{ Case = 'empty include_prefixes'; Json = '{"version":1,"include_prefixes":[],"exclude_prefixes":[],"extensions":[".md"]}'; Message = 'CI_DOCS_ONLY_CONFIG_INVALID: include_prefixes must be a non-empty array of non-blank strings' }
            @{ Case = 'extension without a dot'; Json = '{"version":1,"include_prefixes":["docs/research/"],"exclude_prefixes":[],"extensions":["md"]}'; Message = "CI_DOCS_ONLY_CONFIG_INVALID: extension 'md' must start with '.'" }
        ) {
            { ConvertFrom-CiDocsOnlyPathConfig -Json $Json } | Should -Throw -ExpectedMessage $Message -Because "an invalid config ($Case) must fail with a specific message"
        }
    }

    Context 'path allowlist' {
        It 'Test-CiDocsOnlyPath accepts <Path> (AC-12)' -ForEach @(
            @{ Path = 'docs/features/active/x/evidence/a.md' }
            @{ Path = 'docs/features/completed/x/evidence/b.txt' }
            @{ Path = 'docs/features/potential/x/c.log' }
            @{ Path = 'docs/research/d.json' }
            @{ Path = 'docs/features/active/x/evidence/e.xml' }
            @{ Path = 'docs/features/active/x/evidence/RUN.MD' }
        ) {
            $result = Test-CiDocsOnlyPath -Path $Path -Config $script:Config

            $result | Should -BeTrue -Because "$Path is under an include prefix with an allowlisted extension"
        }

        It 'Test-CiDocsOnlyPath rejects <Path> (AC-13)' -ForEach @(
            @{ Path = 'docs/features/templates/README.md' }
            @{ Path = 'docs/features/potential/template.md' }
            @{ Path = 'docs/engineering/x.md' }
            @{ Path = 'docs/discovery/x.md' }
            @{ Path = 'docs/features/active/x/a.ps1' }
            @{ Path = 'docs/features/active/x/a.py' }
            @{ Path = 'docs/features/active/x/a.yml' }
            @{ Path = 'docs/features/active/../../scripts/a.md' }
            @{ Path = 'docs\features\active\x\a.md' }
            @{ Path = '/docs/features/active/a.md' }
            @{ Path = 'Docs/features/active/x.md' }
            @{ Path = 'config/ci-docs-only-paths.json' }
            @{ Path = 'docs/features/active/x/noextension' }
        ) {
            $result = Test-CiDocsOnlyPath -Path $Path -Config $script:Config

            $result | Should -BeFalse -Because "$Path must not be treated as docs-only"
        }
    }

    Context 'diff path list and path decision' {
        It 'ConvertFrom-CiNulPathList splits a NUL-terminated list (AC-8)' {
            $nul = [string][char]0
            $text = 'docs/x/a.md' + $nul + 'docs/x/b.md' + $nul

            $result = ConvertFrom-CiNulPathList -Text $text

            $result.Valid | Should -BeTrue
            ($result.Paths -join '|') | Should -BeExactly 'docs/x/a.md|docs/x/b.md' -Because 'git diff -z terminates every path with NUL'
        }

        It 'ConvertFrom-CiNulPathList returns an empty valid list for empty text (AC-9)' {
            $result = ConvertFrom-CiNulPathList -Text ''

            $result.Valid | Should -BeTrue
            @($result.Paths).Count | Should -Be 0 -Because 'an empty diff lists no path'
        }

        It 'ConvertFrom-CiNulPathList marks text without a trailing NUL invalid (AC-8)' {
            $result = ConvertFrom-CiNulPathList -Text 'docs/x/a.md'

            $result.Valid | Should -BeFalse -Because 'output that does not end in NUL is not git diff -z output'
        }

        It 'Get-CiChangeScopePathDecision returns EMPTY_DIFF for no paths (AC-9)' {
            $result = Get-CiChangeScopePathDecision -Paths @() -Config $script:Config

            $result | Should -BeExactly 'EMPTY_DIFF' -Because 'an empty diff fails closed to a full run'
        }

        It 'Get-CiChangeScopePathDecision names the first non-allowlisted path of a mixed set (AC-10)' {
            $paths = @('docs/features/active/x/evidence/a.md', 'scripts/ci/CiChangeScope.psm1')

            $result = Get-CiChangeScopePathDecision -Paths $paths -Config $script:Config

            $result | Should -BeExactly 'NON_ALLOWLISTED_PATH: scripts/ci/CiChangeScope.psm1' -Because 'one code path forces a full run'
        }

        It 'Get-CiChangeScopePathDecision returns nothing when every path is allowlisted (AC-11)' {
            $paths = @('docs/features/active/x/evidence/a.md', 'docs/research/d.json')

            $result = Get-CiChangeScopePathDecision -Paths $paths -Config $script:Config

            $result | Should -BeNullOrEmpty -Because 'an all-docs diff produces no full-run reason'
        }

        It 'Test-CiDocsOnlyPath accepts a Markdown path under <Prefix> with the seven-prefix allowlist (#973)' -ForEach @(
            @{ Prefix = 'docs/features/archive/' }
            @{ Prefix = 'docs/features/parallel/' }
            @{ Prefix = 'docs/features/epics/' }
        ) {
            $result = Test-CiDocsOnlyPath -Path ($Prefix + 'x/evidence/a.md') -Config $script:SevenPrefixConfig

            $result | Should -BeTrue -Because "$Prefix is an include prefix of the issue #973 allowlist"
        }

        It 'Get-CiChangeScopePathDecision returns NON_ALLOWLISTED_PATH for a rename <Direction> the allowlist (#973)' -ForEach @(
            @{ Direction = 'into'; Paths = @('scripts/x.ps1', 'docs/features/archive/x.md') }
            @{ Direction = 'out of'; Paths = @('docs/features/archive/x.md', 'scripts/x.ps1') }
        ) {
            # git diff --no-renames lists a rename on the green-run diff as the deleted old path and the added new path.
            $result = Get-CiChangeScopePathDecision -Paths $Paths -Config $script:SevenPrefixConfig

            $result | Should -BeExactly 'NON_ALLOWLISTED_PATH: scripts/x.ps1' -Because "a rename $Direction the allowlist has one side outside it"
        }
    }

    Context 'merge-base fallback helpers' {
        It 'Test-CiMergeBaseFallbackApplicable returns <Expected> for <PrimaryReason> with base ref <BaseRef> (#973)' -ForEach @(
            @{ PrimaryReason = 'NO_FULL_GREEN_RUN'; BaseRef = 'main'; Expected = $true }
            @{ PrimaryReason = 'BASE_NOT_PRESENT'; BaseRef = 'main'; Expected = $true }
            @{ PrimaryReason = 'BASE_NOT_ANCESTOR'; BaseRef = 'main'; Expected = $true }
            @{ PrimaryReason = 'NO_FULL_GREEN_RUN'; BaseRef = 'development'; Expected = $false }
            @{ PrimaryReason = 'NO_FULL_GREEN_RUN'; BaseRef = 'epic/x'; Expected = $false }
            @{ PrimaryReason = 'NO_FULL_GREEN_RUN'; BaseRef = ''; Expected = $false }
            @{ PrimaryReason = 'NO_FULL_GREEN_RUN'; BaseRef = 'Main'; Expected = $false }
            @{ PrimaryReason = 'RUN_LIST_FAILED'; BaseRef = 'main'; Expected = $false }
            @{ PrimaryReason = 'JOB_LIST_FAILED'; BaseRef = 'main'; Expected = $false }
            @{ PrimaryReason = 'ANCESTRY_CHECK_FAILED'; BaseRef = 'main'; Expected = $false }
        ) {
            $result = Test-CiMergeBaseFallbackApplicable -PrimaryReason $PrimaryReason -BaseRef $BaseRef

            $result | Should -BeExactly $Expected -Because 'only the three no-usable-base reasons fall back, and only for base ref main (case-sensitive)'
        }

        It 'ConvertFrom-CiMergeBaseOutput returns the SHA for <Case> (#973)' -ForEach @(
            @{ Case = '40 hex characters'; Text = ('0123456789abcdef0123' * 2); Expected = ('0123456789abcdef0123' * 2) }
            @{ Case = '40 hex characters with one trailing LF'; Text = (('e' * 40) + "`n"); Expected = ('e' * 40) }
            @{ Case = '64 hex characters'; Text = ('0123456789abcdef' * 4); Expected = ('0123456789abcdef' * 4) }
        ) {
            $result = ConvertFrom-CiMergeBaseOutput -Text $Text

            $result | Should -BeExactly $Expected -Because "$Case is exactly one full SHA"
        }

        It 'ConvertFrom-CiMergeBaseOutput returns an empty string for <Case> (#973)' -ForEach @(
            @{ Case = 'empty text'; Text = '' }
            @{ Case = 'two lines'; Text = (('e' * 40) + "`n" + ('a' * 40)) }
            @{ Case = '39 characters'; Text = ('e' * 39) }
            @{ Case = 'upper-case hex'; Text = ('E' * 40) }
            @{ Case = 'a non-hex character'; Text = (('e' * 39) + 'g') }
            @{ Case = 'a leading space'; Text = (' ' + ('e' * 40)) }
            @{ Case = 'a trailing space'; Text = (('e' * 40) + ' ') }
            @{ Case = 'two trailing LFs'; Text = (('e' * 40) + "`n`n") }
        ) {
            $result = ConvertFrom-CiMergeBaseOutput -Text $Text

            $result | Should -BeExactly '' -Because "$Case is not exactly one full lower-case SHA"
        }
    }

    Context 'green base candidate selection' {
        It 'Select-CiGreenBaseCandidates excludes the current run (AC-5)' {
            $json = ConvertTo-TestRunListJson -Runs @((Get-TestRunEntry -Id 900 -RunNumber 9), (Get-TestRunEntry -Id 1000 -RunNumber 10))

            $result = @(Select-CiGreenBaseCandidates -RunsJson $json -CurrentRunId '1000' -Repository $script:Repository)

            ($result.Id -join ',') | Should -BeExactly '900' -Because 'the run deciding the scope cannot be its own base'
        }

        It 'Select-CiGreenBaseCandidates excludes runs from a foreign head repository (AC-5)' {
            $json = ConvertTo-TestRunListJson -Runs @((Get-TestRunEntry -Id 900 -RunNumber 9), (Get-TestRunEntry -Id 901 -RunNumber 10 -HeadRepository 'someone/drm-copilot'))

            $result = @(Select-CiGreenBaseCandidates -RunsJson $json -CurrentRunId '1000' -Repository $script:Repository)

            ($result.Id -join ',') | Should -BeExactly '900' -Because 'a run whose head is in another repository is not a valid base'
        }

        It 'Select-CiGreenBaseCandidates orders unsorted runs by run_number descending (AC-5)' {
            $json = ConvertTo-TestRunListJson -Runs @((Get-TestRunEntry -Id 700 -RunNumber 7), (Get-TestRunEntry -Id 900 -RunNumber 9), (Get-TestRunEntry -Id 800 -RunNumber 8))

            $result = @(Select-CiGreenBaseCandidates -RunsJson $json -CurrentRunId '1000' -Repository $script:Repository)

            ($result.RunNumber -join ',') | Should -BeExactly '9,8,7' -Because 'the newest qualifying run is tried first'
        }

        It 'Select-CiGreenBaseCandidates excludes runs whose conclusion is not success (AC-5)' {
            $json = ConvertTo-TestRunListJson -Runs @((Get-TestRunEntry -Id 900 -RunNumber 9), (Get-TestRunEntry -Id 902 -RunNumber 11 -Conclusion 'failure'))

            $result = @(Select-CiGreenBaseCandidates -RunsJson $json -CurrentRunId '1000' -Repository $script:Repository)

            ($result.Id -join ',') | Should -BeExactly '900' -Because 'only a successful run can be a green base'
        }

        It 'Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID for malformed JSON (AC-3)' {
            { Select-CiGreenBaseCandidates -RunsJson '{bad' -CurrentRunId '1000' -Repository $script:Repository } |
                Should -Throw -ExpectedMessage 'CI_RUN_LIST_INVALID: malformed JSON' -Because 'an unreadable run list must not yield a base'
        }

        It 'Select-CiGreenBaseCandidates throws CI_RUN_LIST_INVALID when workflow_runs is missing (AC-3)' {
            { Select-CiGreenBaseCandidates -RunsJson '{"total_count":0}' -CurrentRunId '1000' -Repository $script:Repository } |
                Should -Throw -ExpectedMessage 'CI_RUN_LIST_INVALID: workflow_runs is missing' -Because 'a payload without workflow_runs is not a run list'
        }
    }

    Context 'full-run marker' {
        It 'Test-CiFullRunMarker returns true when CI full run concluded success (AC-6)' {
            $json = ConvertTo-TestJobListJson -Jobs @(@{ name = 'Change scope'; conclusion = 'success' }, @{ name = 'CI full run'; conclusion = 'success' })

            $result = Test-CiFullRunMarker -JobsJson $json

            $result | Should -BeTrue -Because 'a successful CI full run job marks the run as a full green run'
        }

        It 'Test-CiFullRunMarker returns false when CI full run concluded <Conclusion> (AC-6)' -ForEach @(
            @{ Conclusion = 'skipped' }
            @{ Conclusion = 'failure' }
            @{ Conclusion = 'cancelled' }
        ) {
            $json = ConvertTo-TestJobListJson -Jobs @(@{ name = 'CI full run'; conclusion = $Conclusion })

            $result = Test-CiFullRunMarker -JobsJson $json

            $result | Should -BeFalse -Because "a CI full run job with conclusion $Conclusion does not mark a full green run"
        }

        It 'Test-CiFullRunMarker returns false when no CI full run job exists (AC-6)' {
            $json = ConvertTo-TestJobListJson -Jobs @(@{ name = 'Change scope'; conclusion = 'success' })

            $result = Test-CiFullRunMarker -JobsJson $json

            $result | Should -BeFalse -Because 'a run without the marker job predates the gating or skipped it'
        }

        It 'Test-CiFullRunMarker throws CI_JOB_LIST_INVALID for malformed JSON (AC-4)' {
            { Test-CiFullRunMarker -JobsJson '{bad' } | Should -Throw -ExpectedMessage 'CI_JOB_LIST_INVALID: malformed JSON' -Because 'an unreadable job list must not mark a run'
        }
    }

    Context 'decision object' {
        It 'New-CiChangeScopeDecision renders code=false with the DOCS_ONLY_SINCE reason and base (AC-11)' {
            $base = 'a' * 40

            $decision = New-CiChangeScopeDecision -Code $false -Reason ('DOCS_ONLY_SINCE_' + $base) -BaseSha $base

            $decision.Code | Should -BeExactly 'false'
            $decision.OutputLine | Should -BeExactly 'code=false'
            $decision.LogLine | Should -BeExactly ('code=false reason=DOCS_ONLY_SINCE_' + $base)
            $decision.SummaryText | Should -BeExactly ('Change scope: code=false; reason=DOCS_ONLY_SINCE_' + $base + '; base=' + $base) -Because 'the summary names the reason and the base commit'
        }

        It 'New-CiChangeScopeDecision renders code=true with base none (AC-11)' {
            $decision = New-CiChangeScopeDecision -Code $true -Reason 'EMPTY_DIFF'

            $decision.OutputLine | Should -BeExactly 'code=true'
            $decision.LogLine | Should -BeExactly 'code=true reason=EMPTY_DIFF'
            $decision.SummaryText | Should -BeExactly 'Change scope: code=true; reason=EMPTY_DIFF; base=none' -Because 'a blank base is rendered as none'
        }

        It 'New-CiChangeScopeDecision throws when code is false without a DOCS_ONLY_SINCE reason (AC-11)' {
            { New-CiChangeScopeDecision -Code $false -Reason 'EMPTY_DIFF' } |
                Should -Throw -ExpectedMessage 'CI_CHANGE_SCOPE_DECISION_INVALID: code=false requires a DOCS_ONLY_SINCE_ reason' -Because 'code=false is only valid for a docs-only diff'
        }
    }

    Context 'module structure' {
        It 'CiChangeScope.psm1 defines only the ten pure functions and calls no git, gh, file, or network command (AC-17)' {
            # Arrange: parse the module file and collect its function definitions and command names.
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $script:ModulePath).Path, [ref] $tokens, [ref] $parseErrors)
            $expected = @('ConvertFrom-CiDocsOnlyPathConfig', 'ConvertFrom-CiMergeBaseOutput', 'ConvertFrom-CiNulPathList', 'Get-CiChangeScopePathDecision', 'New-CiChangeScopeDecision', 'Select-CiGreenBaseCandidates', 'Test-CiChangeScopeEventEligible', 'Test-CiDocsOnlyPath', 'Test-CiFullRunMarker', 'Test-CiMergeBaseFallbackApplicable')
            # The banned names are assembled from parts so this test file stays free of the literal cmdlet names.
            $banned = @('git', 'gh', 'Get-Content', ('Set-' + 'Content'), 'Add-Content', ('Out-' + 'File'), ('New-' + 'Item'), 'Remove-Item', 'Copy-Item', 'Move-Item', 'Test-Path', 'Get-ChildItem', 'Get-Item', ('Invoke-' + 'WebRequest'), ('Invoke-' + 'RestMethod'), ('Start-' + 'Process'), 'Import-Module', 'Invoke-Expression')

            # Act
            $defined = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object { $_.Name } | Sort-Object)
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() })
            $bannedHits = @($commands | Where-Object { $banned -contains $_ })

            # Assert
            @($parseErrors).Count | Should -Be 0
            ($defined -join ',') | Should -BeExactly ((@($expected) | Sort-Object) -join ',') -Because 'the module holds exactly the ten pure functions of the issue #962 and #973 specs'
            ($bannedHits -join ',') | Should -BeExactly '' -Because 'the pure module must not call git, gh, file, process, or network commands'
        }
    }
}
