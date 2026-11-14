#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsProfileSourceRoot.psm1 (issue #1173 B6).

.DESCRIPTION
    Covers the starter source-root detection order (src, then the pyproject.toml package
    directory from [tool.poetry].packages[].include, else [project].name, else
    [tool.poetry].name with '-' mapped to '_', then the retained src fallback), the precedence of
    the three keys, the array-of-tables packages form, invalid and absent pyproject text, and the
    DOCS_PROFILE_SOURCE_ROOT_MISSING finding pointers. Listings and pyproject text are in-memory;
    no file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfileSourceRoot.psm1') -Force -ErrorAction Stop

    function New-TestListFile {
        # Returns a ListFile scriptblock over an in-memory path set and records each listed root.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $Path = @(), [System.Collections.Generic.List[string]] $Call)
        $paths = $Path
        $calls = $Call
        return {
            param($RelativeRoot)
            if ($null -ne $calls) { $calls.Add([string] $RelativeRoot) }
            $prefix = ([string] $RelativeRoot).TrimEnd('/') + '/'
            return , [string[]] @($paths | Where-Object { ([string] $_).StartsWith($prefix, [System.StringComparison]::Ordinal) })
        }.GetNewClosure()
    }
}

AfterAll {
    Remove-Module -Name DocsProfileSourceRoot, DocsTomlKeys, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\New-TestListFile -ErrorAction SilentlyContinue
}

Describe 'Get-DocsProfileSourceRootDefault' {
    It 'selects src when src lists files, whatever pyproject.toml names' {
        $pyproject = "[project]`nname = `"my-tool`"`n"
        Get-DocsProfileSourceRootDefault -PyprojectText $pyproject -ListFile (New-TestListFile -Path @('src/a.py', 'my_tool/b.py')) | Should -BeExactly 'src'
    }

    It 'selects the <Name> package directory when src lists no file' -ForEach @(
        @{ Name = 'inline packages include'; Text = "[tool.poetry]`nname = `"other`"`npackages = [{ include = `"pkg_inline`" }]`n"; Expected = 'pkg_inline' }
        @{ Name = 'multi-line packages include'; Text = "[tool.poetry]`npackages = [`n  { include = 'pkg_multi' },`n  { include = `"second`" },`n]`n"; Expected = 'pkg_multi' }
        @{ Name = 'array-of-tables packages include'; Text = "[[tool.poetry.packages]]`ninclude = `"pkg_table`"`n"; Expected = 'pkg_table' }
        @{ Name = 'project name'; Text = "[project]`nname = `"my-tool`"`nversion = `"1.0`"`n"; Expected = 'my_tool' }
        @{ Name = 'tool.poetry name'; Text = "[tool.poetry]`nname = 'poetry-app-x'`n"; Expected = 'poetry_app_x' }
    ) {
        $listing = New-TestListFile -Path @("$Expected/__init__.py", 'tests/test_a.py')
        Get-DocsProfileSourceRootDefault -PyprojectText $Text -ListFile $listing | Should -BeExactly $Expected
    }

    It 'prefers packages include over project name over tool.poetry name' {
        $all = "[project]`nname = `"proj-name`"`n[tool.poetry]`nname = `"poetry-name`"`npackages = [{ include = `"inc_pkg`" }]`n"
        $noInclude = "[project]`nname = `"proj-name`"`n[tool.poetry]`nname = `"poetry-name`"`n"
        $listing = New-TestListFile -Path @('inc_pkg/a.py', 'proj_name/a.py', 'poetry_name/a.py')
        Get-DocsProfileSourceRootDefault -PyprojectText $all -ListFile $listing | Should -BeExactly 'inc_pkg'
        Get-DocsProfileSourceRootDefault -PyprojectText $noInclude -ListFile $listing | Should -BeExactly 'proj_name'
    }

    It 'retains src when <Case>' -ForEach @(
        @{ Case = 'no pyproject.toml exists'; Text = $null }
        @{ Case = 'the package directory lists no file'; Text = "[project]`nname = `"absent-pkg`"`n" }
        @{ Case = 'pyproject.toml names no package'; Text = "[build-system]`nrequires = []`n" }
        @{ Case = 'pyproject.toml is invalid TOML'; Text = "[project`nname = `"x`"`n" }
        @{ Case = 'the package name is not a relative path'; Text = "[project]`nname = `"../outside`"`n" }
    ) {
        $calls = [System.Collections.Generic.List[string]]::new()
        Get-DocsProfileSourceRootDefault -PyprojectText $Text -ListFile (New-TestListFile -Path @('other/a.py', 'outside/b.py') -Call $calls) | Should -BeExactly 'src'
        $calls | Should -Not -Contain '../outside'
    }
}

Describe 'Get-DocsProfileSourceRootFinding' {
    It 'reports DOCS_PROFILE_SOURCE_ROOT_MISSING at the pointer of each source root that lists no file' {
        $findings = @(Get-DocsProfileSourceRootFinding -SourceRoot @('src', 'lib', 'pkg') -ListFile (New-TestListFile -Path @('lib/a.py')) -ProfilePath 'docs/documentation-estate/docs-profile.json')
        @($findings | ForEach-Object { $_['code'] + ' ' + $_['pointer'] + ' ' + $_['severity'] }) | Should -Be @('DOCS_PROFILE_SOURCE_ROOT_MISSING /surface_selection/source_roots/0 error', 'DOCS_PROFILE_SOURCE_ROOT_MISSING /surface_selection/source_roots/2 error')
        $findings[0]['artifact_path'] | Should -BeExactly 'docs/documentation-estate/docs-profile.json'
        $findings[0]['message'] | Should -BeLike "*'src'*"
    }

    It 'returns no finding when every root lists files and skips a root that is not a relative path without listing it' {
        $calls = [System.Collections.Generic.List[string]]::new()
        $findings = @(Get-DocsProfileSourceRootFinding -SourceRoot @('src', '/abs', '../up') -ListFile (New-TestListFile -Path @('src/a.py') -Call $calls) -ProfilePath 'p.json')
        $findings.Count | Should -Be 0
        $calls | Should -Be @('src')
        @(Get-DocsProfileSourceRootFinding -SourceRoot @() -ListFile (New-TestListFile) -ProfilePath 'p.json').Count | Should -Be 0
    }
}
