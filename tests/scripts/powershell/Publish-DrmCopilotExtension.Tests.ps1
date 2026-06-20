Set-StrictMode -Version Latest

Describe "Publish-DrmCopilotExtension.ps1 - local package/dry-run modes" {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/powershell/Publish-DrmCopilotExtension.ps1")).Path
        # Dot-source the production script so its on-disk lines execute under Pester
        # coverage instrumentation. The script has no mandatory parameters (default
        # parameter set DryRun); the entry-point block is skipped because
        # $MyInvocation.InvocationName -eq '.' when dot-sourced.
        . $script:scriptPath
    }

    BeforeEach {
        $script:capturedVsceArgsList = [System.Collections.Generic.List[object]]::new()
        $script:capturedNpmArgsList = [System.Collections.Generic.List[object]]::new()
    }

    Context "manifest validation" {
        It "throws when the manifest is missing" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $false }

            {
                Test-ExtensionManifest -ManifestPath "/repo/extensions/drm-copilot/package.json" -ExtensionDir "/repo/extensions/drm-copilot"
            } | Should -Throw "*Extension manifest not found*"
        }

        It "throws when a required field is missing (not silently ignored)" {
            # Manifest present, all required keys present but several are empty
            # strings, which the validator must report as missing required fields.
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Get-Content -MockWith {
                param($LiteralPath, [switch]$Raw)
                $null = $LiteralPath; $null = $Raw
                return '{ "name": "drm-copilot", "version": "", "publisher": "", "engines": { "vscode": "" }, "main": "", "displayName": "", "description": "" }'
            }

            {
                Test-ExtensionManifest -ManifestPath "/repo/extensions/drm-copilot/package.json" -ExtensionDir "/repo/extensions/drm-copilot"
            } | Should -Throw "*missing required fields*"
        }
    }

    Context "forbidden-file scan (vsce ls)" {
        It "flags files outside the allowed set and ignores resources/.claude" {
            $listing = @(
                'extension.js'
                'resources/.claude/template.md'
                'docs/internal.md'
                '.claude/secret.md'
            )

            $forbidden = Get-ForbiddenPackagedFile -Listing $listing

            ($forbidden -join "`n") | Should -Match 'docs/internal.md'
            ($forbidden -join "`n") | Should -Match '\.claude/secret.md'
            ($forbidden -join "`n") | Should -Not -Match 'resources/\.claude/template.md'
        }
    }

    Context "DryRun mode" {
        It "validates the manifest and does not package or upload" {
            Mock -CommandName Test-ExtensionManifest -MockWith {
                param($ManifestPath, $ExtensionDir)
                $null = $ManifestPath; $null = $ExtensionDir
                return [pscustomobject]@{ publisher = 'DanMoisan'; name = 'drm-copilot'; version = '0.0.2' }
            }
            Mock -CommandName Get-VsceListing -MockWith { return @('extension.js') }
            Mock -CommandName Invoke-VsceExe -MockWith {
                param([string[]]$VsceArgs)
                $script:capturedVsceArgsList.Add($VsceArgs)
                throw "vsce package must not run in DryRun mode"
            }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $null = $NpmArgs
                return 0
            }
            Mock -CommandName Push-Location -MockWith { param($Path) $null = $Path }
            Mock -CommandName Pop-Location -MockWith { }

            $result = Invoke-ExtensionPackage -Mode 'DryRun' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix' -SkipBuild

            $result | Should -BeNullOrEmpty
            Should -Invoke -CommandName Invoke-VsceExe -Times 0 -Exactly
        }
    }

    Context "Package mode" {
        It "produces a .vsix path and does not invoke a publish/upload command" {
            Mock -CommandName Test-ExtensionManifest -MockWith {
                param($ManifestPath, $ExtensionDir)
                $null = $ManifestPath; $null = $ExtensionDir
                return [pscustomobject]@{ publisher = 'DanMoisan'; name = 'drm-copilot'; version = '0.0.2' }
            }
            Mock -CommandName Get-VsceListing -MockWith { return @('extension.js') }
            Mock -CommandName Invoke-VsceExe -MockWith {
                param([string[]]$VsceArgs)
                $script:capturedVsceArgsList.Add($VsceArgs)
                return 0
            }
            Mock -CommandName Push-Location -MockWith { param($Path) $null = $Path }
            Mock -CommandName Pop-Location -MockWith { }

            $result = Invoke-ExtensionPackage -Mode 'Package' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix' -SkipBuild

            $result | Should -Match 'drm-copilot-0\.0\.2-.*\.vsix$'
            Should -Invoke -CommandName Invoke-VsceExe -Times 1 -Exactly
            $flattened = @($script:capturedVsceArgsList | ForEach-Object { $_ }) -join " "
            $flattened | Should -Match 'package'
            $flattened | Should -Not -Match 'publish'
        }
    }

    Context "publish-side-effect absence" {
        It "the production script body invokes no vsce publish, npm version, or git tag" {
            $raw = Get-Content -LiteralPath (Resolve-Path -Path $script:scriptPath) -Raw
            $raw | Should -Not -Match 'vsce publish'
            $raw | Should -Not -Match 'npm version'
            $raw | Should -Not -Match 'git tag'
        }
    }

    Context "Test-ExtensionManifest (real validator, happy and edge paths)" {
        It "returns the parsed manifest and warns on missing recommended fields when required fields are present" {
            Mock -CommandName Get-Content -MockWith {
                param($LiteralPath, [switch]$Raw)
                $null = $LiteralPath; $null = $Raw
                # Recommended keys present but null/empty so the validator reports them.
                return '{ "name": "drm-copilot", "version": "0.0.2", "publisher": "DanMoisan", "engines": { "vscode": "^1.80.0" }, "main": "./out/extension.js", "displayName": "DRM Copilot", "description": "desc", "license": null, "repository": null, "categories": null }'
            }
            # Manifest exists; recommended files (LICENSE/CHANGELOG) absent, README present.
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath, $Path)
                $candidate = if ($LiteralPath) { $LiteralPath } else { $Path }
                if ($candidate -match 'package\.json$') { return $true }
                if ($candidate -match 'README\.md$') { return $true }
                return $false
            }
            Mock -CommandName Write-Warning -MockWith { param($Message) $null = $Message }

            $manifest = Test-ExtensionManifest -ManifestPath "/repo/ext/package.json" -ExtensionDir "/repo/ext"

            $manifest.name | Should -Be 'drm-copilot'
            $manifest.version | Should -Be '0.0.2'
            # Recommended fields and LICENSE/CHANGELOG absences are reported via warnings.
            Should -Invoke -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter { $Message -match 'recommended fields' }
        }

        It "throws when README.md is absent (vsce requires a README)" {
            Mock -CommandName Get-Content -MockWith {
                param($LiteralPath, [switch]$Raw)
                $null = $LiteralPath; $null = $Raw
                return '{ "name": "drm-copilot", "version": "0.0.2", "publisher": "DanMoisan", "engines": { "vscode": "^1.80.0" }, "main": "./out/extension.js", "displayName": "DRM Copilot", "description": "desc", "license": "MIT", "repository": "x", "categories": ["Other"] }'
            }
            # Manifest exists; README absent.
            Mock -CommandName Test-Path -MockWith {
                param($LiteralPath, $Path)
                $candidate = if ($LiteralPath) { $LiteralPath } else { $Path }
                if ($candidate -match 'package\.json$') { return $true }
                return $false
            }
            Mock -CommandName Write-Warning -MockWith { param($Message) $null = $Message }

            {
                Test-ExtensionManifest -ManifestPath "/repo/ext/package.json" -ExtensionDir "/repo/ext"
            } | Should -Throw "*README.md not found*"
        }
    }

    Context "build path (npm install + compile)" {
        BeforeEach {
            Mock -CommandName Test-ExtensionManifest -MockWith {
                param($ManifestPath, $ExtensionDir)
                $null = $ManifestPath; $null = $ExtensionDir
                return [pscustomobject]@{ publisher = 'DanMoisan'; name = 'drm-copilot'; version = '0.0.2' }
            }
            Mock -CommandName Get-VsceListing -MockWith { return @('extension.js') }
            Mock -CommandName Push-Location -MockWith { param($Path) $null = $Path }
            Mock -CommandName Pop-Location -MockWith { }
        }

        It "runs npm install then npm run compile when node_modules is absent" {
            # node_modules absent so install runs.
            Mock -CommandName Test-Path -MockWith { param($LiteralPath, $Path) $null = $LiteralPath; $null = $Path; return $false }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $script:capturedNpmArgsList.Add($NpmArgs)
                return 0
            }

            $result = Invoke-ExtensionPackage -Mode 'DryRun' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix'

            $result | Should -BeNullOrEmpty
            Should -Invoke -CommandName Invoke-NpmExe -Times 2 -Exactly
            $npmFlat = @($script:capturedNpmArgsList | ForEach-Object { $_ -join ' ' })
            $npmFlat | Should -Contain 'install'
            $npmFlat | Should -Contain 'run compile'
        }

        It "skips npm install but still compiles when node_modules is present" {
            # node_modules present so install is skipped.
            Mock -CommandName Test-Path -MockWith { param($LiteralPath, $Path) $null = $LiteralPath; $null = $Path; return $true }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $script:capturedNpmArgsList.Add($NpmArgs)
                return 0
            }

            $null = Invoke-ExtensionPackage -Mode 'DryRun' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix'

            Should -Invoke -CommandName Invoke-NpmExe -Times 1 -Exactly
            $npmFlat = @($script:capturedNpmArgsList | ForEach-Object { $_ -join ' ' })
            $npmFlat | Should -Contain 'run compile'
            $npmFlat | Should -Not -Contain 'install'
        }

        It "throws when npm install fails" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath, $Path) $null = $LiteralPath; $null = $Path; return $false }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 1 }

            {
                Invoke-ExtensionPackage -Mode 'DryRun' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix'
            } | Should -Throw "*npm install failed*"
        }

        It "throws when npm run compile fails" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath, $Path) $null = $LiteralPath; $null = $Path; return $true }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                if (($NpmArgs -join ' ') -match 'compile') { return 2 }
                return 0
            }

            {
                Invoke-ExtensionPackage -Mode 'DryRun' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix'
            } | Should -Throw "*npm run compile failed*"
        }
    }

    Context "forbidden-file warning and package failure" {
        BeforeEach {
            Mock -CommandName Test-ExtensionManifest -MockWith {
                param($ManifestPath, $ExtensionDir)
                $null = $ManifestPath; $null = $ExtensionDir
                return [pscustomobject]@{ publisher = 'DanMoisan'; name = 'drm-copilot'; version = '0.0.2' }
            }
            Mock -CommandName Push-Location -MockWith { param($Path) $null = $Path }
            Mock -CommandName Pop-Location -MockWith { }
            Mock -CommandName Write-Warning -MockWith { param($Message) $null = $Message }
        }

        It "warns when the vsce ls listing includes forbidden files" {
            Mock -CommandName Get-VsceListing -MockWith { return @('extension.js', 'docs/internal.md') }

            $null = Invoke-ExtensionPackage -Mode 'DryRun' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix' -SkipBuild

            Should -Invoke -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter { $Message -match 'potentially unwanted files' }
        }

        It "throws when vsce package fails in Package mode" {
            Mock -CommandName Get-VsceListing -MockWith { return @('extension.js') }
            Mock -CommandName Invoke-VsceExe -MockWith { param([string[]]$VsceArgs) $null = $VsceArgs; return 1 }

            {
                Invoke-ExtensionPackage -Mode 'Package' -ExtensionDir '/repo/ext' -ManifestPath '/repo/ext/package.json' -VsixOutDir '/repo/artifacts/vsix' -SkipBuild
            } | Should -Throw "*vsce package failed*"
        }
    }

    Context "entry point (script invoked, not dot-sourced)" {
        It "runs the DryRun entry-point path without uploading or tagging" {
            # Execute the production entry-point block in-process via the call
            # operator. All external seams are mocked so no real npm/vsce runs.
            Mock -CommandName Test-ExtensionManifest -MockWith {
                param($ManifestPath, $ExtensionDir)
                $null = $ManifestPath; $null = $ExtensionDir
                return [pscustomobject]@{ publisher = 'DanMoisan'; name = 'drm-copilot'; version = '0.0.2' }
            }
            Mock -CommandName Get-VsceListing -MockWith { return @('extension.js') }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }
            Mock -CommandName Invoke-VsceExe -MockWith { param([string[]]$VsceArgs) $null = $VsceArgs; throw "vsce must not run in DryRun" }
            Mock -CommandName New-Item -MockWith { param($Path) $null = $Path }
            Mock -CommandName Get-Command -MockWith { param($Name) $null = $Name; return [pscustomobject]@{ Name = 'vsce' } }
            Mock -CommandName Push-Location -MockWith { param($Path) $null = $Path }
            Mock -CommandName Pop-Location -MockWith { }
            # node_modules present so the entry-point build path is exercised quickly.
            Mock -CommandName Test-Path -MockWith { param($LiteralPath, $Path) $null = $LiteralPath; $null = $Path; return $true }

            { & $script:scriptPath -DryRun } | Should -Not -Throw
            Should -Invoke -CommandName Invoke-VsceExe -Times 0 -Exactly
        }
    }
}
