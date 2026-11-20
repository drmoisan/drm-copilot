[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Seam parameters mirror production signatures for testing')]
param()

Set-StrictMode -Version Latest

BeforeDiscovery {
    # The corpus is committed ASCII JSON shared with the Jest hash-parity test (issue #1049).
    $corpusPath = Join-Path $PSScriptRoot '../../../fixtures/push-down-manifest-hash/corpus.json'
    $script:CorpusCases = @((Get-Content -LiteralPath $corpusPath -Raw | ConvertFrom-Json).cases | ForEach-Object {
            @{ Name = $_.name; Text = $_.text; Sha256 = $_.sha256 }
        })
}

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root module (issue #392).
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force
    $script:vcCorpusPath = (Resolve-Path -Path (Join-Path $PSScriptRoot '../../../fixtures/push-down-manifest-hash/corpus.json')).Path

    InModuleScope -ModuleName PoshQC -Parameters @{ CorpusPath = $script:vcCorpusPath } -ScriptBlock {
        param([string] $CorpusPath)
        # The committed corpus is the only real file the default read and reparse seams touch.
        $script:vcCorpusPath = $CorpusPath
        $script:vcAbc = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
        # Builds UTF-8 manifest bytes from a files-object JSON fragment.
        $script:vcManifest = {
            param([string] $FilesJson, [string] $Version = '1.0.0', [string] $Extra = '')
            [Text.Encoding]::UTF8.GetBytes(('{{"schema_version": "{0}", "payload_version": "1.2.3", "selection": {{}}, "files": {1}{2}}}' -f $Version, $FilesJson, $Extra))
        }
        # Runs the status function over an in-memory destination rooted at /dest.
        $script:vcStatus = {
            param([string[]] $Candidates)
            $parameters = @{
                Root             = '/dest'
                CandidatePaths   = $Candidates
                ReadBytes        = { param([string] $Path) , $script:vcFiles[$Path] }
                TestPathExists   = { param([string] $Path) $script:vcFiles.ContainsKey($Path) }
                TestReparsePoint = { param([string] $Path) $script:vcReparse -ccontains $Path }
                WarningLogger    = { param([string] $Message) $script:vcWarnings.Add($Message) }
            }
            Get-PoshQCVendoredCoverageStatus @parameters
        }
    }
}

Describe 'Get-PoshQCCanonicalContentHash (issue #1049)' {
    It 'produces the corpus digest for <Name>' -ForEach $script:CorpusCases {
        InModuleScope -ModuleName PoshQC -Parameters @{ Text = $Text; Sha256 = $Sha256 } -ScriptBlock {
            param([string] $Text, [string] $Sha256)

            # Arrange: the un-normalized UTF-8 bytes of the corpus text.
            $bytes = [Text.Encoding]::UTF8.GetBytes($Text)

            # Act
            $digest = Get-PoshQCCanonicalContentHash -Bytes $bytes

            # Assert
            $digest | Should -BeExactly $Sha256
        }
    }

    It 'corpus file contains no carriage return and no non-ASCII byte' {
        # Arrange and Act
        $bytes = [IO.File]::ReadAllBytes($script:vcCorpusPath)

        # Assert: the corpus survives the eol=lf checkout rule unchanged.
        @($bytes | Where-Object { $_ -eq 0x0D }).Count | Should -Be 0
        @($bytes | Where-Object { $_ -gt 0x7F }).Count | Should -Be 0
    }
}

Describe 'Get-PoshQCVendoredCoverageStatus (issue #1049)' {
    # Each scenario starts from an empty in-memory destination, so no scenario reads the real filesystem.
    BeforeEach {
        InModuleScope PoshQC {
            $script:vcFiles = [System.Collections.Generic.Dictionary[string, byte[]]]::new([StringComparer]::Ordinal)
            $script:vcReparse = @()
            $script:vcWarnings = [System.Collections.Generic.List[string]]::new()
        }
    }

    It 'reports exempt for a listed present regular file whose hash matches' {
        InModuleScope PoshQC {
            # Arrange
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/a.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)
            $script:vcFiles['/dest/.claude/hooks/a.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')

            # Act
            $records = @(& $script:vcStatus @('.claude/hooks/a.ps1'))

            # Assert
            $records.Count | Should -Be 1
            $records[0].status | Should -Be 'exempt'
            $records[0].actual_sha256 | Should -Be $script:vcAbc
        }
    }

    It 'reports modified when the hash differs' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/a.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)
            $script:vcFiles['/dest/.claude/hooks/a.ps1'] = [Text.Encoding]::ASCII.GetBytes('abd')

            $records = @(& $script:vcStatus @('.claude/hooks/a.ps1'))

            $records[0].status | Should -Be 'modified'
            $records[0].actual_sha256 | Should -Not -Be $script:vcAbc
        }
    }

    It 'reports modified for a reparse point' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/a.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)
            $script:vcFiles['/dest/.claude/hooks/a.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')
            $script:vcReparse = @('/dest/.claude/hooks/a.ps1')

            $records = @(& $script:vcStatus @('.claude/hooks/a.ps1'))

            # Assert: a link is never exempt, even when its target content matches.
            $records[0].status | Should -Be 'modified'
            $records[0].actual_sha256 | Should -BeNullOrEmpty
        }
    }

    It 'reports missing for a listed absent file' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/gone.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)

            $records = @(& $script:vcStatus @())

            $records.Count | Should -Be 1
            $records[0].path | Should -Be '.claude/hooks/gone.ps1'
            $records[0].status | Should -Be 'missing'
        }
    }

    It 'reports unlisted for a candidate not in the manifest' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest '{}'
            $script:vcFiles['/dest/scripts/own.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')

            $records = @(& $script:vcStatus @('scripts/own.ps1'))

            $records[0].status | Should -Be 'unlisted'
            $records[0].manifest_sha256 | Should -BeNullOrEmpty
        }
    }

    It 'reports a case-renamed file unlisted' {
        InModuleScope PoshQC {
            # Arrange: the manifest lists Hook.ps1; the destination holds hook.ps1.
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/Hook.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)
            $script:vcFiles['/dest/.claude/hooks/hook.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')

            $records = @(& $script:vcStatus @('.claude/hooks/hook.ps1'))

            # Assert: ordinal matching keeps the renamed file in the denominator; output is sorted ordinally.
            @($records | ForEach-Object path) | Should -Be @('.claude/hooks/Hook.ps1', '.claude/hooks/hook.ps1')
            ($records | Where-Object { $_.path -ceq '.claude/hooks/hook.ps1' }).status | Should -Be 'unlisted'
            ($records | Where-Object { $_.path -ceq '.claude/hooks/Hook.ps1' }).status | Should -Be 'missing'
        }
    }

    It 'reports a destination-added .claude/hooks file unlisted' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/a.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)
            $script:vcFiles['/dest/.claude/hooks/a.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')
            $script:vcFiles['/dest/.claude/hooks/added.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')

            $records = @(& $script:vcStatus @('.claude/hooks/a.ps1', '.claude/hooks/added.ps1'))

            ($records | Where-Object { $_.path -ceq '.claude/hooks/added.ps1' }).status | Should -Be 'unlisted'
            ($records | Where-Object { $_.path -ceq '.claude/hooks/a.ps1' }).status | Should -Be 'exempt'
        }
    }

    It 'ignores unknown top-level and per-file fields' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.push-down-manifest.json'] = & $script:vcManifest ('{{".claude/hooks/a.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}", "note": "x"}}}}' -f $script:vcAbc) '1.0.0' ', "future": {"k": 1}'
            $script:vcFiles['/dest/.claude/hooks/a.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')

            $records = @(& $script:vcStatus @('.claude/hooks/a.ps1'))

            $records[0].status | Should -Be 'exempt'
        }
    }

    It 'accepts a known major with a higher minor schema_version' {
        InModuleScope PoshQC {
            $bytes = & $script:vcManifest ('{{".claude/lib/l.psm1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc) '1.1.0'

            $entries = @(ConvertFrom-PoshQCPushDownManifest -Bytes $bytes)

            $entries.Count | Should -Be 1
            $entries[0].Path | Should -Be '.claude/lib/l.psm1'
            $entries[0].Sha256 | Should -Be $script:vcAbc
        }
    }

    It 'throws naming .push-down-manifest.json for <Case>' -ForEach @(
        @{ Case = 'malformed JSON'; Text = '{"schema_version": "1.0.0", "files": {' }
        @{ Case = 'unknown major'; Text = '{"schema_version": "2.0.0", "files": {}}' }
        @{ Case = 'non-semver version'; Text = '{"schema_version": "1.0", "files": {}}' }
        @{ Case = 'missing files'; Text = '{"schema_version": "1.0.0"}' }
        @{ Case = 'absolute'; Text = '{"schema_version": "1.0.0", "files": {"/abs/a.ps1": {"sha256": "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"}}}' }
        @{ Case = 'drive-letter'; Text = '{"schema_version": "1.0.0", "files": {"C:/a.ps1": {"sha256": "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"}}}' }
        @{ Case = 'UNC'; Text = '{"schema_version": "1.0.0", "files": {"//server/share/a.ps1": {"sha256": "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"}}}' }
        @{ Case = 'backslash UNC'; Text = '{"schema_version": "1.0.0", "files": {"\\\\server\\share\\a.ps1": {"sha256": "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"}}}' }
        @{ Case = '..'; Text = '{"schema_version": "1.0.0", "files": {"a/../b.ps1": {"sha256": "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"}}}' }
        @{ Case = 'bad sha256'; Text = '{"schema_version": "1.0.0", "files": {"a.ps1": {"sha256": "BA7816BF"}}}' }
    ) {
        InModuleScope -ModuleName PoshQC -Parameters @{ Text = $Text } -ScriptBlock {
            param([string] $Text)

            # Arrange
            $script:vcFiles['/dest/.push-down-manifest.json'] = [Text.Encoding]::UTF8.GetBytes($Text)

            # Act and Assert: an invalid manifest fails closed with a message naming the file.
            { & $script:vcStatus @('a.ps1') } | Should -Throw -ExpectedMessage '*.push-down-manifest.json*'
        }
    }

    It 'logs one warning and exempts nothing when the manifest is absent' {
        InModuleScope PoshQC {
            $script:vcFiles['/dest/.claude/hooks/a.ps1'] = [Text.Encoding]::ASCII.GetBytes('abc')

            $records = @(& $script:vcStatus @('.claude/hooks/a.ps1', 'scripts/b.ps1'))

            $script:vcWarnings.Count | Should -Be 1
            $script:vcWarnings[0] | Should -BeLike '*.push-down-manifest.json*'
            @($records | Where-Object { $_.status -ne 'unlisted' }).Count | Should -Be 0
            $records.Count | Should -Be 2
        }
    }

    It 'default seams route the manifest and file reads through the reader and reparse helpers' {
        InModuleScope PoshQC {
            # Arrange: the read and reparse helpers are mocked in module scope, so the default seams run.
            $manifest = & $script:vcManifest ('{{"a.ps1": {{"layer": "claude", "pack": "core", "sha256": "{0}"}}}}' -f $script:vcAbc)
            Mock Read-PoshQCFileByte { if ($Path -like '*.push-down-manifest.json') { , $manifest } else { , [Text.Encoding]::ASCII.GetBytes('abc') } }
            Mock Test-PoshQCReparsePoint { $false }
            Mock Write-Warning { }

            # Act
            $records = @(Get-PoshQCVendoredCoverageStatus -Root '/dest' -CandidatePaths @('a.ps1') -TestPathExists { param([string] $Path) [void] $Path; $true })

            # Assert
            $records[0].status | Should -Be 'exempt'
            Should -Invoke Read-PoshQCFileByte -Times 2 -Exactly
            Should -Invoke Test-PoshQCReparsePoint -Times 1 -Exactly
        }
    }

    It 'default seams test existence on disk and warn through Write-Warning' {
        InModuleScope PoshQC {
            # Arrange: a root with no manifest on disk (the fixture folder).
            Mock Write-Warning { }
            $root = Split-Path -Parent $script:vcCorpusPath

            # Act
            $records = @(Get-PoshQCVendoredCoverageStatus -Root $root -CandidatePaths @('corpus.json'))

            # Assert
            $records[0].status | Should -Be 'unlisted'
            Should -Invoke Write-Warning -Times 1 -Exactly
        }
    }
}

Describe 'Vendored coverage file helpers (issue #1049)' {
    It 'reads bytes through the default reader' {
        InModuleScope PoshQC {
            $bytes = Read-PoshQCFileByte -Path $script:vcCorpusPath

            $bytes[0] | Should -Be 0x7B
            [Text.Encoding]::UTF8.GetString($bytes) | Should -BeLike '*"cases"*'
        }
    }

    It 'reports no reparse point for a committed file' {
        InModuleScope PoshQC {
            Test-PoshQCReparsePoint -Path $script:vcCorpusPath | Should -BeFalse
        }
    }
}

Describe 'Get-PoshQCVendoredCoverageOptIn (issue #1049)' {
    It 'returns the opt-in for <Case>' -ForEach @(
        @{ Case = 'absent'; Json = '{"version": 1, "roots": []}'; Expected = $false }
        @{ Case = 'true'; Json = '{"version": 1, "roots": [], "exempt_unchanged_push_down_files": true}'; Expected = $true }
        @{ Case = 'false'; Json = '{"version": 1, "roots": [], "exempt_unchanged_push_down_files": false}'; Expected = $false }
    ) {
        InModuleScope -ModuleName PoshQC -Parameters @{ Json = $Json; Expected = $Expected } -ScriptBlock {
            param([string] $Json, [bool] $Expected)

            $result = Get-PoshQCVendoredCoverageOptIn -Parsed ($Json | ConvertFrom-Json) -ConfigRelativePath 'config/poshqc-coverage.json'

            $result | Should -Be $Expected
        }
    }

    It 'throws for a non-boolean opt-in' {
        InModuleScope PoshQC {
            $parsed = '{"version": 1, "roots": [], "exempt_unchanged_push_down_files": "true"}' | ConvertFrom-Json

            { Get-PoshQCVendoredCoverageOptIn -Parsed $parsed -ConfigRelativePath 'config/poshqc-coverage.json' } | Should -Throw -ExpectedMessage '*config/poshqc-coverage.json*'
        }
    }
}

Describe 'Resolve-PoshQCVendoredCoverageExemption (issue #1049)' {
    It 'removes only exempt paths' {
        InModuleScope PoshQC {
            # Arrange
            $files = @(
                [pscustomobject]@{ RelativePath = '.claude/hooks/a.ps1'; FullPath = '/dest/.claude/hooks/a.ps1' }
                [pscustomobject]@{ RelativePath = '.claude/hooks/m.ps1'; FullPath = '/dest/.claude/hooks/m.ps1' }
                [pscustomobject]@{ RelativePath = 'scripts/own.ps1'; FullPath = '/dest/scripts/own.ps1' }
            )
            $getStatus = {
                param([string] $RootPath, [string[]] $Candidates)
                [void] $RootPath; [void] $Candidates
                [pscustomobject]@{ path = '.claude/hooks/a.ps1'; status = 'exempt'; manifest_sha256 = 'x'; actual_sha256 = 'x' }
                [pscustomobject]@{ path = '.claude/hooks/gone.ps1'; status = 'missing'; manifest_sha256 = 'y'; actual_sha256 = $null }
                [pscustomobject]@{ path = '.claude/hooks/m.ps1'; status = 'modified'; manifest_sha256 = 'x'; actual_sha256 = 'z' }
                [pscustomobject]@{ path = 'scripts/own.ps1'; status = 'unlisted'; manifest_sha256 = $null; actual_sha256 = $null }
            }

            # Act
            $result = Resolve-PoshQCVendoredCoverageExemption -Root '/dest' -Files $files -GetStatus $getStatus

            # Assert
            @($result.Paths) | Should -Be @('/dest/.claude/hooks/m.ps1', '/dest/scripts/own.ps1')
            @($result.Exemptions).Count | Should -Be 4
        }
    }
}

Describe 'Vendored coverage exemption report (issue #1049)' {
    It 'renders sorted report JSON without timestamps or absolute paths' {
        InModuleScope PoshQC {
            # Arrange: records out of ordinal order.
            $records = @(
                [pscustomobject]@{ path = 'b.ps1'; status = 'modified'; manifest_sha256 = 'aa'; actual_sha256 = 'bb' }
                [pscustomobject]@{ path = 'B.ps1'; status = 'unlisted'; manifest_sha256 = $null; actual_sha256 = $null }
                [pscustomobject]@{ path = 'a.ps1'; status = 'exempt'; manifest_sha256 = 'cc'; actual_sha256 = 'cc' }
            )

            # Act
            $json = ConvertTo-PoshQCVendoredCoverageReportJson -Exemptions $records
            $parsed = $json | ConvertFrom-Json

            # Assert
            @($parsed.entries | ForEach-Object path) | Should -Be @('B.ps1', 'a.ps1', 'b.ps1')
            $parsed.entries[0].manifest_sha256 | Should -BeNullOrEmpty
            $json.EndsWith("`n") | Should -BeTrue
            $json.Contains("`r") | Should -BeFalse
            $json | Should -Not -Match '\d{4}-\d{2}-\d{2}'
            $json | Should -Not -BeLike '*/dest*'
            @($parsed.PSObject.Properties.Name) | Should -Be @('entries')
        }
    }

    It 'renders an empty entries list' {
        InModuleScope PoshQC {
            $json = ConvertTo-PoshQCVendoredCoverageReportJson -Exemptions @()

            @(($json | ConvertFrom-Json).entries).Count | Should -Be 0
            $json.EndsWith("`n") | Should -BeTrue
        }
    }

    It 'writes the report beside the coverage output file for <Case>' -ForEach @(
        @{ Case = 'default path'; Output = 'artifacts/pester/coverage.xml'; Expected = '/run/artifacts/pester/vendored-coverage-exemptions.json' }
        @{ Case = 'shard path'; Output = '/run/artifacts/pester/parallel/shard-2/coverage.xml'; Expected = '/run/artifacts/pester/parallel/shard-2/vendored-coverage-exemptions.json' }
    ) {
        InModuleScope -ModuleName PoshQC -Parameters @{ Output = $Output; Expected = $Expected } -ScriptBlock {
            param([string] $Output, [string] $Expected)

            # Arrange
            $script:vcWrites = [System.Collections.Generic.List[string]]::new()
            $parameters = @{
                Root               = '/run'
                CoverageOutputPath = $Output
                Exemptions         = @([pscustomobject]@{ path = 'a.ps1'; status = 'exempt'; manifest_sha256 = 'cc'; actual_sha256 = 'cc' })
                EnsureDirectory    = { param([string] $Path) [void] $Path }
                WriteContent       = { param([string] $Path, [string] $Content) [void] $Content; $script:vcWrites.Add(($Path -replace '\\', '/')) }
            }

            # Act
            $written = Write-PoshQCVendoredCoverageReport @parameters

            # Assert
            ($written -replace '\\', '/') | Should -Be $Expected
            @($script:vcWrites) | Should -Be @($Expected)
        }
    }

    It 'writes the report under artifacts/pester when no coverage output path is given' {
        InModuleScope PoshQC {
            $script:vcDirectories = [System.Collections.Generic.List[string]]::new()
            $parameters = @{
                Root               = '/run'
                CoverageOutputPath = ''
                Exemptions         = @()
                EnsureDirectory    = { param([string] $Path) $script:vcDirectories.Add(($Path -replace '\\', '/')) }
                WriteContent       = { param([string] $Path, [string] $Content) [void] $Path; [void] $Content }
            }

            $written = Write-PoshQCVendoredCoverageReport @parameters

            ($written -replace '\\', '/') | Should -Be '/run/artifacts/pester/vendored-coverage-exemptions.json'
            @($script:vcDirectories) | Should -Be @('/run/artifacts/pester')
        }
    }

    It 'default writer seams create the directory and write only the report file' {
        InModuleScope PoshQC {
            # Arrange: the default seams call New-Item and Set-Content, both mocked so nothing is written.
            Mock New-Item { }
            Mock Set-Content { }

            # Act
            Write-PoshQCVendoredCoverageReport -Root '/run' -CoverageOutputPath '/run/artifacts/pester/coverage.xml' -Exemptions @() | Out-Null

            # Assert
            Should -Invoke New-Item -Times 1 -Exactly -ParameterFilter { $ItemType -eq 'Directory' }
            Should -Invoke Set-Content -Times 1 -Exactly
            Should -Invoke Set-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -like '*vendored-coverage-exemptions.json' }
            Should -Invoke Set-Content -Times 0 -Exactly -ParameterFilter { $LiteralPath -like '*config/poshqc-coverage.json' }
        }
    }
}
