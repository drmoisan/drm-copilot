Set-StrictMode -Version Latest

# Unit suite for the pure npm audit gate module scripts/ci/NpmAuditGate.psm1 (issue #1204).
#
# Every case builds its exception-file text and its npm audit --json text in memory. The one file read is
# the committed config/npm-audit-exceptions.json in NAG-EXC-COMMITTED-FILE. No process, temporary file,
# environment variable, clock read, or network call is used.

BeforeDiscovery {
    $script:EntryHead = '{"id":"GHSA-fc5q-39xc-vjpf","package":"picomatch","scope":"dev","reason":"no patch","approved_at":"2026-11-18","expires":"2026-12-18"'
    $script:Wrap = { param([string] $Entries) '{"version":1,"exceptions":[' + $Entries + ']}' }

    $script:InvalidCases = @(
        @{ Name = 'NAG-EXC-WRONG-VERSION'; Label = 'version 2'; Json = '{"version":2,"exceptions":[]}' }
        @{ Name = 'NAG-EXC-WRONG-VERSION'; Label = 'version as a string'; Json = '{"version":"1","exceptions":[]}' }
        @{ Name = 'NAG-EXC-WRONG-VERSION'; Label = 'version 1.5'; Json = '{"version":1.5,"exceptions":[]}' }
        @{ Name = 'NAG-EXC-UNKNOWN-KEY'; Label = 'top-level key'; Json = '{"version":1,"exceptions":[],"extra":1}' }
        @{ Name = 'NAG-EXC-UNKNOWN-KEY'; Label = 'entry-level key'; Json = (& $script:Wrap ($script:EntryHead + ',"note":"x"}')) }
        @{ Name = 'NAG-EXC-DUPLICATE-ID'; Label = 'same id twice'; Json = (& $script:Wrap (($script:EntryHead + '}') + ',' + ($script:EntryHead + '}'))) }
        @{ Name = 'NAG-EXC-MISSING-FIELD'; Label = 'entry without reason'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"picomatch","scope":"dev","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-MISSING-FIELD'; Label = 'file without exceptions'; Json = '{"version":1}' }
        @{ Name = 'NAG-EXC-MISSING-FIELD'; Label = 'file without version'; Json = '{"exceptions":[]}' }
        @{ Name = 'NAG-EXC-EMPTY-FIELD'; Label = 'empty reason'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"picomatch","scope":"dev","reason":"","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-EMPTY-FIELD'; Label = 'blank package'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"  ","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-EMPTY-FIELD'; Label = 'boolean true reason'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":true,"approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-EMPTY-FIELD'; Label = 'boolean false scope'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":false,"reason":"r","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-EMPTY-FIELD'; Label = 'null package'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":null,"scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-MALFORMED-ID'; Label = 'not a GHSA id'; Json = (& $script:Wrap '{"id":"CVE-2026-1","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-MALFORMED-ID'; Label = 'lower-case prefix'; Json = (& $script:Wrap '{"id":"ghsa-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-MALFORMED-ID'; Label = 'two ids in one entry'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf GHSA-aaaa-bbbb-cccc","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-BAD-DATE'; Label = 'slash separators'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026/11/18","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-BAD-DATE'; Label = 'month 13'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-13-01"}') }
        @{ Name = 'NAG-EXC-BAD-DATE'; Label = 'date-time text'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-12-18T00:00:00"}') }
        @{ Name = 'NAG-EXC-BAD-DATE'; Label = 'impossible day'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026-02-30","expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-BAD-DATE'; Label = 'number instead of text'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":20261118,"expires":"2026-12-18"}') }
        @{ Name = 'NAG-EXC-EXPIRES-NOT-AFTER-APPROVED'; Label = 'expires equals approved_at'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-11-18"}') }
        @{ Name = 'NAG-EXC-EXPIRES-NOT-AFTER-APPROVED'; Label = 'expires before approved_at'; Json = (& $script:Wrap '{"id":"GHSA-fc5q-39xc-vjpf","package":"p","scope":"dev","reason":"r","approved_at":"2026-11-18","expires":"2026-11-17"}') }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'truncated object'; Json = '{' }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'blank text'; Json = '' }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'plain text'; Json = 'not json' }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'array root'; Json = '[]' }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'repeated key'; Json = '{"version":1,"version":1,"exceptions":[]}' }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'exceptions is not an array'; Json = '{"version":1,"exceptions":{}}' }
        @{ Name = 'NAG-EXC-UNPARSEABLE-JSON'; Label = 'entry is not an object'; Json = '{"version":1,"exceptions":[1]}' }
    )
}

Describe 'NpmAuditGate.psm1 exception file' {
    BeforeAll {
        $script:ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/NpmAuditGate.psm1'
        Import-Module -Name $script:ModulePath -Force
        $script:ValidJson = '{"version":1,"exceptions":[{"id":"GHSA-fc5q-39xc-vjpf","package":"picomatch","scope":"dev","reason":"no patch","approved_at":"2026-11-18","expires":"2026-12-18"}]}'
    }

    It 'NAG-EXC-VALID-PASSES accepts the contract-shaped file and returns its entry' {
        $result = ConvertFrom-NpmAuditException -Json $script:ValidJson

        $result.Valid | Should -BeTrue
        $result.ErrorDetail | Should -BeExactly ''
        @($result.Entries).Count | Should -Be 1
        $result.Entries[0].Id | Should -BeExactly 'GHSA-fc5q-39xc-vjpf'
        $result.Entries[0].Package | Should -BeExactly 'picomatch'
        $result.Entries[0].Expires | Should -BeExactly '2026-12-18'
    }

    It 'NAG-EXC-VALID-PASSES accepts an empty exception list' {
        $result = ConvertFrom-NpmAuditException -Json '{"version":1,"exceptions":[]}'

        $result.Valid | Should -BeTrue
        @($result.Entries).Count | Should -Be 0
    }

    It '<Name> rejects <Label> with NPM_AUDIT_EXCEPTION_INVALID' -ForEach $script:InvalidCases {
        $result = ConvertFrom-NpmAuditException -Json $Json

        $result.Valid | Should -BeFalse
        $result.ErrorDetail | Should -BeLike 'NPM_AUDIT_EXCEPTION_INVALID*'
        @($result.Entries).Count | Should -Be 0
    }

    It 'NAG-EXC-COMMITTED-FILE accepts the committed config/npm-audit-exceptions.json with its single excepted advisory' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath '../../../config/npm-audit-exceptions.json'

        $result = ConvertFrom-NpmAuditException -Json (Get-Content -Raw -LiteralPath $path)

        $result.Valid | Should -BeTrue -Because $result.ErrorDetail
        @($result.Entries).Count | Should -Be 1
        $result.Entries[0].Id | Should -BeExactly 'GHSA-fc5q-39xc-vjpf'
        $result.Entries[0].Package | Should -BeExactly 'picomatch'
        $result.Entries[0].Expires | Should -BeExactly '2026-12-18'
        [string]::CompareOrdinal($result.Entries[0].ApprovedAt, $result.Entries[0].Expires) | Should -BeLessThan 0
    }

    It 'NAG-EXC-VALID-PASSES leaves the module free of clock and file cmdlets' {
        $text = Get-Content -Raw -LiteralPath $script:ModulePath
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($text, [ref] $tokens, [ref] $parseErrors)
        $names = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) |
                ForEach-Object { $_.GetCommandName() } | Where-Object { $_ })

        $forbidden = @('Get-Date', 'Get-Content', 'Set-Content', 'Add-Content', 'Out-File', 'Test-Path')
        @($names | Where-Object { $forbidden -contains $_ }) | Should -BeNullOrEmpty
        $text | Should -Not -Match '\[Environment\]::|\[datetime\]::(Now|UtcNow|Today)|\[System\.IO\.'
    }
}

Describe 'NpmAuditGate.psm1 advisory extraction' {
    BeforeAll {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/NpmAuditGate.psm1') -Force

        # The via object has the shape observed from the real npm audit --json run (source, name, url, severity).
        function Get-TestVia {
            param([string] $Id = 'GHSA-fc5q-39xc-vjpf', [string] $Severity = 'high', [string] $Name = 'picomatch', [string] $Url = '', [switch] $NoUrl, [switch] $NoSource)
            $via = [ordered]@{}
            if (-not $NoSource) { $via['source'] = 1247710 }
            $via['name'] = $Name
            if (-not $NoUrl) {
                if ($Url) { $via['url'] = $Url } else { $via['url'] = "https://github.com/advisories/$Id" }
            }
            $via['severity'] = $Severity
            return $via
        }
        function Get-TestAuditJson {
            param([Parameter(Mandatory = $true)][System.Collections.IDictionary] $Vulnerabilities)
            return ConvertTo-Json -InputObject ([ordered]@{ auditReportVersion = 2; vulnerabilities = $Vulnerabilities; metadata = [ordered]@{} }) -Depth 8 -Compress
        }
    }

    It 'NAG-ADV-GHSA-FROM-URL takes the advisory id from the GHSA pattern in url' {
        $json = Get-TestAuditJson -Vulnerabilities ([ordered]@{ picomatch = [ordered]@{ name = 'picomatch'; severity = 'high'; via = @((Get-TestVia)) } })

        $result = Get-NpmAuditAdvisories -Json $json

        $result.Parsed | Should -BeTrue
        @($result.Advisories).Count | Should -Be 1
        $result.Advisories[0].Id | Should -BeExactly 'GHSA-fc5q-39xc-vjpf'
        $result.Advisories[0].Package | Should -BeExactly 'picomatch'
        $result.Advisories[0].Severity | Should -BeExactly 'high'
    }

    It 'NAG-ADV-SOURCE-FALLBACK falls back to the numeric source when url has no GHSA id' -ForEach @(
        @{ Label = 'no url'; Via = { Get-TestVia -NoUrl } }
        @{ Label = 'a url without a GHSA id'; Via = { Get-TestVia -Url 'https://example.test/advisory/1' } }
    ) {
        $json = Get-TestAuditJson -Vulnerabilities ([ordered]@{ picomatch = [ordered]@{ name = 'picomatch'; severity = 'high'; via = @((& $Via)) } })

        $result = Get-NpmAuditAdvisories -Json $json

        @($result.Advisories).Count | Should -Be 1
        $result.Advisories[0].Id | Should -BeExactly '1247710' -Because $Label
    }

    It 'NAG-ADV-SOURCE-FALLBACK labels an advisory with neither url nor source as UNIDENTIFIED' {
        $json = Get-TestAuditJson -Vulnerabilities ([ordered]@{ pkg = [ordered]@{ name = 'pkg'; severity = 'high'; via = @((Get-TestVia -NoUrl -NoSource -Name 'pkg')) } })

        $result = Get-NpmAuditAdvisories -Json $json

        $result.Advisories[0].Id | Should -BeExactly 'UNIDENTIFIED'
    }

    It 'NAG-ADV-STRING-VIA-IGNORED ignores string-only via entries and non-array via values' {
        $json = Get-TestAuditJson -Vulnerabilities ([ordered]@{
                jest     = [ordered]@{ name = 'jest'; severity = 'high'; via = @('picomatch', 'anymatch') }
                anymatch = [ordered]@{ name = 'anymatch'; severity = 'high'; via = 'picomatch' }
                none     = [ordered]@{ name = 'none'; severity = 'high' }
            })

        $result = Get-NpmAuditAdvisories -Json $json

        $result.Parsed | Should -BeTrue
        @($result.Advisories).Count | Should -Be 0
    }

    It 'NAG-ADV-DEDUPLICATED reports one advisory that several packages carry and keeps the highest severity' {
        $json = Get-TestAuditJson -Vulnerabilities ([ordered]@{
                picomatch = [ordered]@{ name = 'picomatch'; severity = 'high'; via = @((Get-TestVia)) }
                other     = [ordered]@{ name = 'other'; severity = 'critical'; via = @((Get-TestVia -Severity 'CRITICAL')) }
                third     = [ordered]@{ name = 'third'; severity = 'low'; via = @((Get-TestVia -Severity 'low')) }
            })

        $result = Get-NpmAuditAdvisories -Json $json

        @($result.Advisories).Count | Should -Be 1
        $result.Advisories[0].Severity | Should -BeExactly 'critical'
    }

    It 'NAG-ADV-UNPARSEABLE reports Parsed false for <Label>' -ForEach @(
        @{ Label = 'blank text'; Json = '' }
        @{ Label = 'plain text'; Json = 'npm ERR! audit endpoint returned an error' }
        @{ Label = 'an npm error object'; Json = '{"error":{"code":"ENOAUDIT","summary":"audit failed"}}' }
        @{ Label = 'an array root'; Json = '[]' }
        @{ Label = 'a vulnerabilities value that is not an object'; Json = '{"vulnerabilities":[]}' }
    ) {
        $result = Get-NpmAuditAdvisories -Json $Json

        $result.Parsed | Should -BeFalse
        @($result.Advisories).Count | Should -Be 0
        $result.ErrorDetail | Should -Not -BeNullOrEmpty
    }
}

Describe 'NpmAuditGate.psm1 gate decision' {
    BeforeAll {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/NpmAuditGate.psm1') -Force
        $script:ExceptionJson = '{"version":1,"exceptions":[{"id":"GHSA-fc5q-39xc-vjpf","package":"picomatch","scope":"dev","reason":"no patched version exists","approved_at":"2026-11-18","expires":"2026-12-18"}]}'

        # One via object per advisory (the real npm audit shape) plus string-only dependents of picomatch.
        function Get-TestAdvisoryVia {
            param([string] $Id, [string] $Severity, [string] $Name)
            return [ordered]@{ source = 1; name = $Name; url = "https://github.com/advisories/$Id"; severity = $Severity }
        }
        function Get-TestFullAuditJson {
            param([object[]] $Advisories = @())
            $vulnerabilities = [ordered]@{}
            foreach ($advisory in $Advisories) {
                $vulnerabilities[$advisory.Name] = [ordered]@{ name = $advisory.Name; severity = $advisory.Severity; via = @((Get-TestAdvisoryVia -Id $advisory.Id -Severity $advisory.Severity -Name $advisory.Name)) }
            }
            if ($Advisories.Count -gt 0) {
                foreach ($dependent in @('jest-util', 'jest-haste-map', 'anymatch')) {
                    $vulnerabilities[$dependent] = [ordered]@{ name = $dependent; severity = 'high'; via = @($Advisories[0].Name) }
                }
            }
            return ConvertTo-Json -InputObject ([ordered]@{ auditReportVersion = 2; vulnerabilities = $vulnerabilities; metadata = [ordered]@{} }) -Depth 8 -Compress
        }
        $script:Picomatch = [pscustomobject]@{ Id = 'GHSA-fc5q-39xc-vjpf'; Severity = 'high'; Name = 'picomatch' }
        $script:Other = [pscustomobject]@{ Id = 'GHSA-aaaa-bbbb-cccc'; Severity = 'high'; Name = 'otherpkg' }
        $script:LowOther = [pscustomobject]@{ Id = 'GHSA-dddd-eeee-ffff'; Severity = 'low'; Name = 'lowpkg' }

        function Invoke-TestDecision {
            param(
                [string] $ExceptionJson = $script:ExceptionJson,
                [string] $UtcDate = '2026-11-20',
                [string] $AuditLevel = 'moderate',
                [int] $ProductionExitCode = 0,
                [Parameter(Mandatory = $true)][AllowEmptyString()][string] $FullAuditJson
            )
            return Get-NpmAuditGateDecision -ExceptionJson $ExceptionJson -UtcDate $UtcDate -AuditLevel $AuditLevel -ProductionExitCode $ProductionExitCode -FullAuditJson $FullAuditJson
        }
    }

    It 'NAG-DEC-DEV-ONLY-EXCEPTED-PASSES passes when the only advisory is excepted and production is clean' {
        $decision = Invoke-TestDecision -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch))

        $decision.Passed | Should -BeTrue
        $decision.Code | Should -BeNullOrEmpty
        @($decision.Applied).Count | Should -Be 1
        @($decision.Unused).Count | Should -Be 0
    }

    It 'NAG-DEC-UNEXCEPTED-FAILS fails with NPM_AUDIT_UNEXCEPTED_ADVISORY for an advisory with no exception' {
        $decision = Invoke-TestDecision -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Other))

        $decision.Passed | Should -BeFalse
        $decision.Code | Should -BeExactly 'NPM_AUDIT_UNEXCEPTED_ADVISORY'
        $decision.SummaryText | Should -BeLike '*GHSA-aaaa-bbbb-cccc*'
    }

    It 'NAG-DEC-EXPIRED-FAILS fails with NPM_AUDIT_EXCEPTION_EXPIRED the day after expires' {
        $decision = Invoke-TestDecision -UtcDate '2026-12-19' -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch))

        $decision.Passed | Should -BeFalse
        $decision.Code | Should -BeExactly 'NPM_AUDIT_EXCEPTION_EXPIRED'
    }

    It 'NAG-DEC-EXPIRED-FAILS passes on the expires date itself with zero days remaining' {
        $decision = Invoke-TestDecision -UtcDate '2026-12-18' -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch))

        $decision.Passed | Should -BeTrue
        $decision.Applied[0].DaysRemaining | Should -Be 0
    }

    It 'NAG-DEC-PROD-FINDING-FAILS fails with NPM_AUDIT_PROD_FINDING when the production audit exits non-zero, even for an excepted advisory' {
        $decision = Invoke-TestDecision -ProductionExitCode 1 -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch))

        $decision.Passed | Should -BeFalse
        $decision.Code | Should -BeExactly 'NPM_AUDIT_PROD_FINDING'
    }

    It 'NAG-DEC-TRANSITIVE-COVERED covers the dependents of an excepted advisory that carry only string via entries' {
        $json = Get-TestFullAuditJson -Advisories @($script:Picomatch)
        (Get-NpmAuditAdvisories -Json $json).Advisories.Count | Should -Be 1 -Because 'three dependents are in the audit but add no advisory object'

        $decision = Invoke-TestDecision -FullAuditJson $json

        $decision.Passed | Should -BeTrue
    }

    It 'NAG-DEC-MIXED-FAILS fails when one advisory is excepted and another is not, and still reports the applied exception' {
        $decision = Invoke-TestDecision -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch, $script:Other))

        $decision.Passed | Should -BeFalse
        $decision.Code | Should -BeExactly 'NPM_AUDIT_UNEXCEPTED_ADVISORY'
        @($decision.Applied).Count | Should -Be 1
        $decision.SummaryText | Should -Not -BeLike '*GHSA-fc5q-39xc-vjpf (*'
    }

    It 'NAG-DEC-BELOW-LEVEL-IGNORED ignores a low advisory at level <Level> and fails it at level low' -ForEach @(
        @{ Level = 'moderate'; Passes = $true }
        @{ Level = 'high'; Passes = $true }
        @{ Level = 'critical'; Passes = $true }
        @{ Level = 'low'; Passes = $false }
        @{ Level = 'info'; Passes = $false }
    ) {
        $decision = Invoke-TestDecision -AuditLevel $Level -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:LowOther))

        $decision.Passed | Should -Be $Passes
    }

    It 'NAG-DEC-BELOW-LEVEL-IGNORED does not apply an exception to an advisory below the level' {
        $decision = Invoke-TestDecision -AuditLevel 'critical' -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch))

        $decision.Passed | Should -BeTrue
        @($decision.Applied).Count | Should -Be 0
        @($decision.Unused).Count | Should -Be 1
    }

    It 'NAG-DEC-BELOW-LEVEL-IGNORED ranks severities info < low < moderate < high < critical and an unknown or missing text above all' {
        $ranks = @('info', 'low', 'moderate', 'high', 'critical') | ForEach-Object { Get-NpmAuditSeverityRank -Severity $_ }

        ($ranks -join ',') | Should -BeExactly '0,1,2,3,4'
        Get-NpmAuditSeverityRank -Severity 'catastrophic' | Should -BeGreaterThan 4
        Get-NpmAuditSeverityRank -Severity '' | Should -BeGreaterThan 4
        Get-NpmAuditSeverityRank -Severity $null | Should -BeGreaterThan 4
    }

    It 'NAG-DEC-UNEXCEPTED-FAILS fails an advisory whose severity text is unknown, whatever the audit level' {
        $unknown = [pscustomobject]@{ Id = 'GHSA-gggg-hhhh-iiii'; Severity = 'catastrophic'; Name = 'oddpkg' }

        $decision = Invoke-TestDecision -AuditLevel 'critical' -FullAuditJson (Get-TestFullAuditJson -Advisories @($unknown))

        $decision.Code | Should -BeExactly 'NPM_AUDIT_UNEXCEPTED_ADVISORY'
    }

    It 'NAG-DEC-UNPARSEABLE-FAILS fails with NPM_AUDIT_OUTPUT_UNPARSEABLE for <Label>' -ForEach @(
        @{ Label = 'blank output'; Json = '' }
        @{ Label = 'plain text'; Json = 'npm ERR! network' }
        @{ Label = 'an npm error object'; Json = '{"error":{"code":"ENOAUDIT"}}' }
    ) {
        $decision = Invoke-TestDecision -FullAuditJson $Json

        $decision.Passed | Should -BeFalse
        $decision.Code | Should -BeExactly 'NPM_AUDIT_OUTPUT_UNPARSEABLE'
    }

    It 'NAG-DEC-UNUSED-INFORMATIONAL reports an exception absent from the audit without failing' {
        $decision = Invoke-TestDecision -FullAuditJson (Get-TestFullAuditJson -Advisories @())

        $decision.Passed | Should -BeTrue
        @($decision.Applied).Count | Should -Be 0
        @($decision.Unused).Count | Should -Be 1
        $decision.SummaryText | Should -BeLike '*Exception unused (informational): id=GHSA-fc5q-39xc-vjpf*'
    }

    It 'NAG-DEC-ORDER returns <Expected> when <Label>' -ForEach @(
        @{ Label = 'the exception file is invalid and everything else is wrong too'; Json = '{'; Date = '2026-12-19'; Prod = 1; Full = 'junk'; Expected = 'NPM_AUDIT_EXCEPTION_INVALID' }
        @{ Label = 'an exception is expired and the production audit and the full output also fail'; Json = $null; Date = '2026-12-19'; Prod = 1; Full = 'junk'; Expected = 'NPM_AUDIT_EXCEPTION_EXPIRED' }
        @{ Label = 'the production audit fails and the full output is unreadable'; Json = $null; Date = '2026-11-20'; Prod = 1; Full = 'junk'; Expected = 'NPM_AUDIT_PROD_FINDING' }
        @{ Label = 'the production audit passes and the full output is unreadable'; Json = $null; Date = '2026-11-20'; Prod = 0; Full = 'junk'; Expected = 'NPM_AUDIT_OUTPUT_UNPARSEABLE' }
    ) {
        $exceptionJson = $script:ExceptionJson
        if ($null -ne $Json) { $exceptionJson = $Json }

        $decision = Invoke-TestDecision -ExceptionJson $exceptionJson -UtcDate $Date -ProductionExitCode $Prod -FullAuditJson $Full

        $decision.Code | Should -BeExactly $Expected
    }

    It 'NAG-DEC-ORDER fails closed with an unexcepted advisory after the earlier checks pass' {
        $decision = Invoke-TestDecision -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Other))

        $decision.Code | Should -BeExactly 'NPM_AUDIT_UNEXCEPTED_ADVISORY'
    }

    It 'NAG-DEC-ORDER rejects a UTC date that is not yyyy-MM-dd' {
        { Invoke-TestDecision -UtcDate '18/11/2026' -FullAuditJson '{}' } | Should -Throw
    }

    It 'NAG-DEC-APPLIED-REPORT prints id, package, scope, reason, approved_at, expires, and days remaining for each applied exception' {
        $decision = Invoke-TestDecision -FullAuditJson (Get-TestFullAuditJson -Advisories @($script:Picomatch))

        $applied = $decision.Applied[0]
        $applied.Id | Should -BeExactly 'GHSA-fc5q-39xc-vjpf'
        $applied.Package | Should -BeExactly 'picomatch'
        $applied.Scope | Should -BeExactly 'dev'
        $applied.Reason | Should -BeExactly 'no patched version exists'
        $applied.ApprovedAt | Should -BeExactly '2026-11-18'
        $applied.Expires | Should -BeExactly '2026-12-18'
        $applied.DaysRemaining | Should -Be 28
        $decision.SummaryText | Should -BeLike 'NPM Audit Gate: PASS*'
        $decision.SummaryText | Should -BeLike '*Exception applied: id=GHSA-fc5q-39xc-vjpf package=picomatch scope=dev approved_at=2026-11-18 expires=2026-12-18 days_remaining=28 reason=no patched version exists*'
    }

    It 'NAG-DEC-APPLIED-REPORT starts a failing summary with the failure code' {
        $decision = Invoke-TestDecision -ProductionExitCode 2 -FullAuditJson '{}'

        $decision.SummaryText | Should -BeLike 'NPM Audit Gate: FAIL NPM_AUDIT_PROD_FINDING: *'
    }
}
