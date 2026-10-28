<#
    Shared case table for the file-size policy functions (issue #990). Data only: this
    file holds hashtable and array literals and no command. It is dot-sourced by
    FileSizePolicy.Tests.ps1, FileSizePolicy.HookDecision.Tests.ps1, and the Codex twin
    suite tests/scripts/codex-hooks/file-size-policy.Tests.ps1, so the Claude module and
    the dot-sourced Codex twin are held to the same rows.

    Content values are in-memory strings with explicit CRLF and LF terminators; no row
    reads or writes a file. Paths use forward slashes and '/repo'-style roots only, so
    the rows hold on the case-sensitive Linux hook job.
#>

$script:FileSizeLineCountCases = @(
    @{ Name = 'LF-terminated lines without a final terminator'; Content = "a`nb`nc"; Expected = 3 }
    @{ Name = 'CRLF-terminated lines without a final terminator'; Content = "a`r`nb`r`nc"; Expected = 3 }
    @{ Name = 'mixed CRLF and LF terminators'; Content = "a`nb`r`nc`n"; Expected = 3 }
    @{ Name = 'two lines without a trailing terminator'; Content = "a`nb"; Expected = 2 }
    @{ Name = 'two lines with a trailing LF terminator'; Content = "a`nb`n"; Expected = 2 }
    @{ Name = 'two lines with a trailing CRLF terminator'; Content = "a`r`nb`r`n"; Expected = 2 }
    @{ Name = 'a single line without a terminator'; Content = 'only'; Expected = 1 }
    @{ Name = 'a single empty line with a terminator'; Content = "`n"; Expected = 1 }
    @{ Name = 'an interior blank line'; Content = "a`n`nb`n"; Expected = 3 }
    @{ Name = 'empty content'; Content = ''; Expected = 0 }
)

$script:FileSizeTierCases = @(
    @{ LineCount = 0; Expected = 'Below' }
    @{ LineCount = 499; Expected = 'Below' }
    @{ LineCount = 500; Expected = 'Guidance' }
    @{ LineCount = 699; Expected = 'Guidance' }
    @{ LineCount = 700; Expected = 'Advisory' }
    @{ LineCount = 799; Expected = 'Advisory' }
    @{ LineCount = 800; Expected = 'HardLimit' }
    @{ LineCount = 801; Expected = 'HardLimit' }
)

$script:FileSizeCoveredPathCases = @(
    @{ Path = 'scripts/tool.py'; Expected = $true }
    @{ Path = 'scripts/tool.ps1'; Expected = $true }
    @{ Path = '.claude/lib/x/Module.psm1'; Expected = $true }
    @{ Path = 'src/app.ts'; Expected = $true }
    @{ Path = 'src/view.tsx'; Expected = $true }
    @{ Path = 'src/a.js'; Expected = $true }
    @{ Path = 'config/jest.config.cjs'; Expected = $true }
    @{ Path = 'src/esm.mjs'; Expected = $true }
    @{ Path = 'src/Program.cs'; Expected = $true }
    @{ Path = 'scripts/bash/run.sh'; Expected = $true }
    @{ Path = 'tests/shell/run.bats'; Expected = $true }
    @{ Path = 'SRC/TOOL.PY'; Expected = $true }
    @{ Path = 'scripts\windows\tool.ps1'; Expected = $true }
    @{ Path = 'README.md'; Expected = $false }
    @{ Path = 'config/settings.json'; Expected = $false }
    @{ Path = 'scripts/powershell/PoshQC/PoshQC.psd1'; Expected = $false }
    @{ Path = 'scripts/dev_tools/pr_context/render.py,cover'; Expected = $false }
    @{ Path = 'workflow.yml'; Expected = $false }
    @{ Path = 'Makefile'; Expected = $false }
    @{ Path = '.claude/worktrees/agent-1/scripts/tool.py'; Expected = $false }
    @{ Path = 'scripts/docs.py'; Expected = $true }
    @{ Path = 'scripts/Build/tool.py'; Expected = $true }
    @{ Path = ''; Expected = $false }
)

$script:FileSizeExcludedSegmentCases = @(
    @{ Segment = '.git' }, @{ Segment = 'node_modules' }, @{ Segment = 'artifacts' }, @{ Segment = 'coverage' },
    @{ Segment = 'dist' }, @{ Segment = 'out' }, @{ Segment = 'virtual' }, @{ Segment = 'docs' },
    @{ Segment = 'build' }, @{ Segment = '.venv' }, @{ Segment = 'venv' }, @{ Segment = 'env' },
    @{ Segment = '__pycache__' }, @{ Segment = '.pytest_cache' }, @{ Segment = '.mypy_cache' },
    @{ Segment = '.ruff_cache' }, @{ Segment = '.tox' }, @{ Segment = '.nox' }, @{ Segment = 'htmlcov' },
    @{ Segment = '.vscode-test' }
)

$script:FileSizeRelativePathCases = @(
    @{ Name = 'an absolute path under the root'; Path = '/repo/scripts/tool.py'; Root = '/repo'; Expected = 'scripts/tool.py' }
    @{ Name = 'an absolute path under a root with a trailing slash'; Path = '/repo/a/b.ps1'; Root = '/repo/'; Expected = 'a/b.ps1' }
    @{ Name = 'a drive-letter path under a drive-letter root'; Path = 'C:/work/repo/src/app.ts'; Root = 'C:/work/repo'; Expected = 'src/app.ts' }
    @{ Name = 'a drive-letter path with a case-variant root'; Path = 'c:/Work/Repo/src/app.ts'; Root = 'C:/work/repo'; Expected = 'src/app.ts' }
    @{ Name = 'an absolute path outside the root'; Path = '/scratch/issue-990/tool.ps1'; Root = '/repo'; Expected = $null }
    @{ Name = 'a sibling directory sharing the root prefix'; Path = '/repository/tool.py'; Root = '/repo'; Expected = $null }
    @{ Name = 'the root itself'; Path = '/repo/'; Root = '/repo'; Expected = $null }
    @{ Name = 'an already relative path'; Path = 'scripts/tool.py'; Root = '/repo'; Expected = 'scripts/tool.py' }
    @{ Name = 'a dot-prefixed relative path'; Path = './scripts/tool.py'; Root = '/repo'; Expected = 'scripts/tool.py' }
    @{ Name = 'a relative path that climbs above the root'; Path = '../other/tool.py'; Root = '/repo'; Expected = $null }
    @{ Name = 'an empty path'; Path = ''; Root = '/repo'; Expected = $null }
)

# Repository-gate ratchet rows from spec.md '### Repository gate (AC3)' that concern one
# file. Current = $null means no file on disk; Baseline = $null means no entry.
$script:FileSizeBaselineCases = @(
    @{ Name = 'S <= 800 with no entry passes'; Current = 650; Baseline = $null; ExpectedRule = $null }
    @{ Name = 'S == 800 with no entry passes'; Current = 800; Baseline = $null; ExpectedRule = $null }
    @{ Name = 'S <= 800 with an entry is a stale entry'; Current = 790; Baseline = 850; ExpectedRule = 'stale-entry' }
    @{ Name = 'S > 800 with no entry is a new file over the limit'; Current = 801; Baseline = $null; ExpectedRule = 'new-over-limit' }
    @{ Name = 'S > 800 above its entry is growth'; Current = 905; Baseline = 900; ExpectedRule = 'grew' }
    @{ Name = 'S > 800 equal to its entry passes'; Current = 900; Baseline = 900; ExpectedRule = $null }
    @{ Name = 'S > 800 below its entry must be tightened'; Current = 880; Baseline = 900; ExpectedRule = 'tighten' }
    @{ Name = 'an entry with no file on disk is stale'; Current = $null; Baseline = 900; ExpectedRule = 'missing-file' }
    @{ Name = 'no file and no entry passes'; Current = $null; Baseline = $null; ExpectedRule = $null }
)

# Hook decision rows (spec.md '## API / CLI Surface'). PreEdit = $null means a new file.
$script:FileSizeHookDecisionCases = @(
    @{ Name = 'a new covered file of 801 lines is denied'; Path = 'scripts/new.py'; Result = 801; PreEdit = $null; Allowed = $false }
    @{ Name = 'a new covered file of 800 lines is allowed'; Path = 'scripts/new.py'; Result = 800; PreEdit = $null; Allowed = $true }
    @{ Name = 'growing an 810-line file to 815 is denied'; Path = 'scripts/large.ps1'; Result = 815; PreEdit = 810; Allowed = $false }
    @{ Name = 'shrinking an 810-line file to 805 is allowed'; Path = 'scripts/large.ps1'; Result = 805; PreEdit = 810; Allowed = $true }
    @{ Name = 'keeping an 810-line file at 810 is allowed'; Path = 'scripts/large.ps1'; Result = 810; PreEdit = 810; Allowed = $true }
    @{ Name = 'growing a 790-line file to 801 is denied'; Path = 'src/app.ts'; Result = 801; PreEdit = 790; Allowed = $false }
    @{ Name = 'a Markdown file of any size is allowed'; Path = 'docs/guide.md'; Result = 5000; PreEdit = $null; Allowed = $true }
    @{ Name = 'a JSON file of any size is allowed'; Path = 'config/data.json'; Result = 5000; PreEdit = 10; Allowed = $true }
    @{ Name = 'a path outside the repository is allowed'; Path = ''; Result = 5000; PreEdit = $null; Allowed = $true }
)

# Edit-resolution rows. Expected is the edited text, or $null when Failure is set.
$script:FileSizeEditCases = @(
    @{ Name = 'a single unique replacement'; Content = "a`nb`nc`n"; Old = 'b'; New = "b1`nb2"; ReplaceAll = $false; Expected = "a`nb1`nb2`nc`n"; Failure = $null }
    @{ Name = 'a CRLF file edited with an LF old string'; Content = "a`r`nb`r`nc`r`n"; Old = "a`nb"; New = 'x'; ReplaceAll = $false; Expected = "x`nc`n"; Failure = $null }
    @{ Name = 'a dollar sign in the new string stays literal'; Content = 'cost'; Old = 'cost'; New = '$1 $_'; ReplaceAll = $false; Expected = '$1 $_'; Failure = $null }
    @{ Name = 'replace_all replaces every occurrence'; Content = "x`nx`nx`n"; Old = 'x'; New = "y`ny"; ReplaceAll = $true; Expected = "y`ny`ny`ny`ny`ny`n"; Failure = $null }
    @{ Name = 'a repeated old string without replace_all is ambiguous'; Content = "x`nx`n"; Old = 'x'; New = 'y'; ReplaceAll = $false; Expected = $null; Failure = 'ambiguous' }
    @{ Name = 'an absent old string is not found'; Content = "a`n"; Old = 'zzz'; New = 'y'; ReplaceAll = $false; Expected = $null; Failure = 'not-found' }
    @{ Name = 'an empty old string fails'; Content = "a`n"; Old = ''; New = 'y'; ReplaceAll = $false; Expected = $null; Failure = 'no-old-string' }
    @{ Name = 'a null old string fails'; Content = "a`n"; Old = $null; New = 'y'; ReplaceAll = $true; Expected = $null; Failure = 'no-old-string' }
    @{ Name = 'a null new string deletes the match'; Content = "a`nb`n"; Old = "b`n"; New = $null; ReplaceAll = $false; Expected = "a`n"; Failure = $null }
)
