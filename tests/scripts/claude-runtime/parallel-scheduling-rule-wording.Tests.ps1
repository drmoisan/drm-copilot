Set-StrictMode -Version Latest

# Contract guard for issue #1164: the parallel planning surfaces state the
# scheduling rule in one pinned sentence followed by the same rule paragraph,
# carry the per-surface procedure wording of spec B5.3 to B10.4, and no longer
# call the scheduling fields tolerated-not-validated. Each file is read once;
# backticks are removed and whitespace runs collapsed before a case-insensitive
# ordinal match, so a case tolerates line wrapping and code-span formatting.
# Files are read in place; the suite writes nothing.

BeforeDiscovery {
    $script:MirrorPrefix = 'extensions/drm-copilot/resources/claude-customizations/'
    $script:PinnedSource = @(
        '.claude/skills/parallel-plan/SKILL.md', '.claude/skills/parallel-add/SKILL.md', '.claude/skills/parallel-run/SKILL.md',
        '.claude/agents/parallel-planner.md', '.claude/agents/parallel-orchestrator.md', '.claude/rules/parallel-orchestration.md'
    )
    $script:PinnedFile = @($script:PinnedSource) + @($script:PinnedSource | ForEach-Object { "$($script:MirrorPrefix)$_" })
    $script:OrchestrateSkill = @('.claude/skills/parallel-orchestrate/SKILL.md', "$($script:MirrorPrefix).claude/skills/parallel-orchestrate/SKILL.md")
    $script:RuleElement = @(
        'Both estimates are integer minutes', 'merge time is the summed overlap-class weights', 'a path that one side only reads costs 0',
        'gain is the shorter of the two band durations', 'Hard classes are always edges',
        'At tolerance_percent 100 the rule is exactly merge time greater than gain', 'a tie runs in parallel',
        '--after flags and planner-proposed orderings pass the same test', 'unless marked as a correctness ordering with --reason'
    )
    $script:SurfaceToken = [ordered]@{
        '.claude/rules/parallel-orchestration.md'      = @(
            'are checked when present', 'after the extension release that carries the TypeScript port', 'until then installed MCP accepts the fields',
            'never removes it from blast_radius.paths', 'the optional separable weight', 'pair_decisions', 'kind: "correctness"'
        )
        '.claude/skills/parallel-plan/SKILL.md'        = @(
            '[--reason', 'a --reason binds to the immediately preceding --after', 'without --reason the entry records kind: "cost"',
            'with --reason the entry records kind: "correctness"', 'source: "operator"', 'source: "planner"',
            'run test-precedence after the scheduling entry point returns', 'a rejected flag stops the scheduling step',
            'derive read_paths with access-paths', 'with a one-line rationale per path', 'pair_decisions',
            '{a, b, reason, hard, cost, benefit}', '{a, b, reasons, cost, benefit}'
        )
        '.claude/skills/parallel-add/SKILL.md'         = @(
            '[--reason', 'a --reason binds to the immediately preceding --after', 'without --reason the entry records kind: "cost"',
            'with --reason the entry records kind: "correctness"', 'source: "operator"', 'run test-precedence after the scheduling entry point returns',
            'a rejected flag stops the scheduling step', 'admissions after seeding are not written to pair_decisions', 'are checked when present'
        )
        '.claude/agents/parallel-planner.md'           = @(
            'source: "planner"', 'run test-precedence after the scheduling entry point returns', 'derive read_paths with access-paths',
            'with a one-line rationale per path', 'pair_decisions', 'are checked when present'
        )
        '.claude/skills/parallel-orchestrate/SKILL.md' = @('precedence_not_justified', 'legacy entry without kind')
    }
    $script:SurfaceCase = @(foreach ($source in $script:SurfaceToken.Keys) {
            foreach ($file in @($source, "$($script:MirrorPrefix)$source")) {
                foreach ($token in $script:SurfaceToken[$source]) { @{ File = $file; Token = $token } }
            }
        })
    $script:ElementCase = @(foreach ($file in $script:PinnedFile) { foreach ($element in $script:RuleElement) { @{ File = $file; Element = $element } } })
    $script:RuleCopy = @('.claude/rules/parallel-orchestration.md', "$($script:MirrorPrefix).claude/rules/parallel-orchestration.md")
    $script:HelperCopy = @('.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1', "$($script:MirrorPrefix).claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1")
    $script:HelpCase = @(foreach ($file in $script:HelperCopy) { foreach ($token in @('test-precedence', 'access-paths', 'precedence_not_justified')) { @{ File = $file; Token = $token } } })
    $script:AbsenceFile = @($script:PinnedFile) + @($script:OrchestrateSkill)
}

Describe 'Parallel scheduling rule wording' {
    BeforeAll {
        # Walk up from this file so the suite does not depend on the working directory.
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $script:PinnedSentence = 'Two items run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel.'
        $script:FormerStatement = @(
            'No validator reads these fields', '(tolerated-not-validated, returned by the scheduling entry point)',
            'Get-BlastRadiusConflictEdge (tolerated-not-validated)', 'operator precedence entries (tolerated-not-validated',
            'tolerated extra fields hard, cost, and benefit', 'Every field below is tolerated and not validated'
        )
        $script:RawText = @{}

        <#
        .SYNOPSIS
            Returns the raw text of a repository file, read once per path.
        .PARAMETER RelativePath
            The repository-relative path of the file.
        .OUTPUTS
            [string] The file text.
        #>
        function Get-PsrwRawText {
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory = $true)][string] $RelativePath)

            if (-not $script:RawText.ContainsKey($RelativePath)) {
                $script:RawText[$RelativePath] = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepoRoot -ChildPath $RelativePath))
            }
            return $script:RawText[$RelativePath]
        }

        <#
        .SYNOPSIS
            Returns a file's text with backticks removed and whitespace runs collapsed.
        .PARAMETER RelativePath
            The repository-relative path of the file.
        .OUTPUTS
            [string] The normalized text.
        #>
        function Get-PsrwText {
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory = $true)][string] $RelativePath)

            return ((Get-PsrwRawText -RelativePath $RelativePath) -replace '`', '' -replace '\s+', ' ')
        }
    }

    It 'carries the pinned sentence in <File>' -ForEach @($script:PinnedFile | ForEach-Object { @{ File = $_ } }) {
        (Get-PsrwText -RelativePath $File).IndexOf($script:PinnedSentence, [System.StringComparison]::OrdinalIgnoreCase) | Should -BeGreaterOrEqual 0
    }

    It 'names precedence_not_justified in <File>' -ForEach @($script:PinnedFile | ForEach-Object { @{ File = $_ } }) {
        (Get-PsrwText -RelativePath $File).IndexOf('precedence_not_justified', [System.StringComparison]::OrdinalIgnoreCase) | Should -BeGreaterOrEqual 0
    }

    It 'carries rule element <Element> after the pinned sentence in <File>' -ForEach $script:ElementCase {
        $text = Get-PsrwText -RelativePath $File
        $pinned = $text.IndexOf($script:PinnedSentence, [System.StringComparison]::OrdinalIgnoreCase)
        $pinned | Should -BeGreaterOrEqual 0 -Because 'the rule paragraph follows the pinned sentence'
        $text.IndexOf($Element, $pinned + $script:PinnedSentence.Length, [System.StringComparison]::OrdinalIgnoreCase) | Should -BeGreaterThan $pinned
    }

    It 'states <Token> in <File>' -ForEach $script:SurfaceCase {
        (Get-PsrwText -RelativePath $File).IndexOf($Token, [System.StringComparison]::OrdinalIgnoreCase) | Should -BeGreaterOrEqual 0
    }

    It 'lists precedence_not_justified in the Admission output signal paragraph of <File>' -ForEach @($script:RuleCopy | ForEach-Object { @{ File = $_ } }) {
        $paragraph = @((Get-PsrwRawText -RelativePath $File) -split '\r?\n\s*\r?\n' | Where-Object { $_.StartsWith('**Admission output signal.**', [System.StringComparison]::Ordinal) })
        $paragraph.Count | Should -Be 1
        $paragraph[0].IndexOf('precedence_not_justified', [System.StringComparison]::Ordinal) | Should -BeGreaterOrEqual 0
    }

    It 'lists <Token> in the helper .DESCRIPTION of <File>' -ForEach $script:HelpCase {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput((Get-PsrwRawText -RelativePath $File), [ref] $tokens, [ref] $parseErrors)
        $description = $ast.GetHelpContent().Description -replace '\s+', ' '
        $description.IndexOf($Token, [System.StringComparison]::Ordinal) | Should -BeGreaterOrEqual 0
    }

    It 'states no tolerated-not-validated scheduling field in <File>' -ForEach @($script:AbsenceFile | ForEach-Object { @{ File = $_ } }) {
        $text = Get-PsrwText -RelativePath $File
        @($script:FormerStatement | Where-Object { $text.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }) | Should -BeNullOrEmpty
    }
}
