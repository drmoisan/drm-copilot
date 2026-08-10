<#
.SYNOPSIS
    Behavioral tests for the blast-radius text-extraction module.

.DESCRIPTION
    Mirrors the pytest suite in
    tests/scripts/dev_tools/test_blast_radius_extraction.py for the scanning
    half of the library: line normalization across LF, CRLF, and CR documents,
    atomic-plan line partitioning, and inline-code token extraction. Each It
    targets a single behavior with Arrange-Act-Assert structure. The tests invoke
    no external process and create no temporary files.

    Path-token classification, whole-plan aggregation, and contract extraction
    live in the authorized sibling BlastRadiusExtraction.Path.Tests.ps1; the
    split satisfies the 500-line file limit for task P4-T5 of the issue #447
    plan.
#>

BeforeAll {
    # Resolve the module four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    # Resolve-Path normalizes the separators so Pester's code-coverage
    # breakpoints bind to the same on-disk path the run settings name.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusExtraction.psm1").Path
    Import-Module $modulePath -Force
}

Describe 'ConvertTo-NormalizedLine' {
    Context 'Line-ending styles' {
        It 'splits an LF document into its lines' {
            # Arrange: a document terminated with line feeds.
            $text = "alpha`nbeta`ngamma"

            # Act: normalize the text.
            $lines = @(ConvertTo-NormalizedLine -Text $text)

            # Assert: each line is returned without a terminator.
            $lines | Should -Be @('alpha', 'beta', 'gamma')
        }

        It 'splits a CRLF document into its lines' {
            # Arrange: a Windows-terminated document, the plan-validator CRLF case.
            $text = "alpha`r`nbeta`r`ngamma"

            # Act: normalize the text.
            $lines = @(ConvertTo-NormalizedLine -Text $text)

            # Assert: no carriage return survives on any line.
            $lines | Should -Be @('alpha', 'beta', 'gamma')
        }

        It 'splits a CR-only document into its lines' {
            # Arrange: a classic-Mac-terminated document.
            $text = "alpha`rbeta`rgamma"

            # Act: normalize the text.
            $lines = @(ConvertTo-NormalizedLine -Text $text)

            # Assert: the carriage returns act as terminators.
            $lines | Should -Be @('alpha', 'beta', 'gamma')
        }

        It 'drops the single empty element a trailing terminator produces' {
            # Arrange: a document that ends with a terminator.
            $text = "alpha`nbeta`n"

            # Act: normalize the text.
            $lines = @(ConvertTo-NormalizedLine -Text $text)

            # Assert: the trailing empty element is discarded, matching splitlines().
            $lines.Count | Should -Be 2
            $lines[-1] | Should -Be 'beta'
        }

        It 'keeps an intentional blank line before a trailing terminator' {
            # Arrange: a document whose last content line is blank.
            $text = "alpha`n`n"

            # Act: normalize the text.
            $lines = @(ConvertTo-NormalizedLine -Text $text)

            # Assert: only one empty element is discarded, not both.
            $lines.Count | Should -Be 2
            $lines[1] | Should -Be ''
        }
    }

    Context 'Degenerate input' {
        It 'returns an empty collection for empty text' {
            # Arrange / Act: normalize the empty document.
            $lines = @(ConvertTo-NormalizedLine -Text '')

            # Assert: an empty string yields no lines at all.
            $lines.Count | Should -Be 0
        }

        It 'preserves trailing whitespace inside a line' {
            # Arrange: a line padded with trailing spaces.
            $text = "alpha   `nbeta"

            # Act: normalize the text.
            $lines = @(ConvertTo-NormalizedLine -Text $text)

            # Assert: normalization splits lines only; it does not trim them.
            $lines[0] | Should -Be 'alpha   '
        }
    }
}

Describe 'Get-PlanLineScan' {
    Context 'Task and phase line parsing' {
        It 'captures the title of a well-formed unchecked task line' {
            # Arrange: a canonical unchecked task line.
            $plan = '- [ ] [P1-T2] Create `scripts/dev_tools/thing.py`.'

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: the task body is captured and no prose line remains.
            @($scan['task_titles']) | Should -Be @('Create `scripts/dev_tools/thing.py`.')
            @($scan['other_lines']).Count | Should -Be 0
        }

        It 'captures the title of a checked task line in either letter case' -ForEach @('x', 'X') {
            # Arrange: a completed task line using the given state letter.
            $plan = "- [$_] [P10-T11] Done work."

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: both accepted state letters are recognized as tasks.
            @($scan['task_titles']) | Should -Be @('Done work.')
        }

        It 'captures the title of a phase heading' {
            # Arrange: a canonical phase heading using the em dash separator.
            $plan = '### Phase 4 — PowerShell Parity Implementation'

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: the heading title is captured as a phase title.
            @($scan['phase_titles']) | Should -Be @('PowerShell Parity Implementation')
        }

        It 'treats a malformed task line as prose so its paths are still scanned' {
            # Arrange: a task-like line missing the bracketed identifier.
            $plan = '- [ ] Create `docs/notes.md`.'

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: the strict pattern rejects it, and it falls through to prose.
            @($scan['task_titles']).Count | Should -Be 0
            @($scan['other_lines']).Count | Should -Be 1
        }

        It 'rejects a phase heading whose separator is a plain hyphen' {
            # Arrange: a heading using a hyphen rather than the required em dash.
            $plan = '### Phase 4 - PowerShell Parity Implementation'

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: the heading is prose because the separator does not match.
            @($scan['phase_titles']).Count | Should -Be 0
            @($scan['other_lines']).Count | Should -Be 1
        }

        It 'matches the phase heading case sensitively' {
            # Arrange: a lower-case heading keyword.
            $plan = '### phase 4 — Lower case'

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: matching mirrors Python's case-sensitive re module.
            @($scan['phase_titles']).Count | Should -Be 0
        }

        It 'places every source line in exactly one partition' {
            # Arrange: one task line, one phase line, and one prose line.
            $plan = "### Phase 1 — Title`n- [ ] [P1-T1] Body.`nProse line."

            # Act: partition the plan lines.
            $scan = Get-PlanLineScan -PlanText $plan

            # Assert: the three partitions account for all three lines.
            $total = @($scan['task_titles']).Count + @($scan['phase_titles']).Count +
            @($scan['other_lines']).Count
            $total | Should -Be 3
        }
    }
}

Describe 'Get-InlineCodeToken' {
    Context 'Span extraction' {
        It 'extracts a single token from one inline-code span' {
            # Arrange: a line with one backtick-delimited span.
            $line = 'See `scripts/dev_tools/thing.py` for detail.'

            # Act: extract the tokens.
            $tokens = @(Get-InlineCodeToken -Line $line)

            # Assert: the span contributes exactly its one token.
            $tokens | Should -Be @('scripts/dev_tools/thing.py')
        }

        It 'splits a multi-word span into whitespace-separated tokens' {
            # Arrange: a span holding a whole command line rather than one path.
            $line = 'Run `poetry run pytest tests/scripts/dev_tools/test_x.py`.'

            # Act: extract the tokens.
            $tokens = @(Get-InlineCodeToken -Line $line)

            # Assert: every whitespace-separated piece becomes its own token.
            $tokens.Count | Should -Be 4
            $tokens[-1] | Should -Be 'tests/scripts/dev_tools/test_x.py'
        }

        It 'preserves duplicate tokens in source order' {
            # Arrange: the same token cited twice on one line.
            $line = '`a/b.py` and `a/b.py`'

            # Act: extract the tokens.
            $tokens = @(Get-InlineCodeToken -Line $line)

            # Assert: this stage does not deduplicate; the caller does.
            $tokens.Count | Should -Be 2
        }

        It 'strips a defensive trailing carriage return from a span' {
            # Arrange: a span left holding a carriage return, which happens when
            # upstream text was split on newline alone rather than normalized.
            $line = '`a/b.py' + "`r" + '`'

            # Act: extract the tokens.
            $tokens = @(Get-InlineCodeToken -Line $line)

            # Assert: the carriage return does not leak into the token.
            $tokens | Should -Be @('a/b.py')
        }

        It 'returns nothing for a line with no inline-code span' {
            # Arrange: plain prose.
            $line = 'No code spans here at all.'

            # Act: extract the tokens.
            $tokens = @(Get-InlineCodeToken -Line $line)

            # Assert: an absent span contributes no token.
            $tokens.Count | Should -Be 0
        }

        It 'ignores an unterminated span such as a fenced-code opening fence' {
            # Arrange: a fence line, which has no closing backtick of its own.
            $line = '```powershell'

            # Act: extract the tokens.
            $tokens = @(Get-InlineCodeToken -Line $line)

            # Assert: matching per line keeps a fence from producing a token.
            $tokens.Count | Should -Be 0
        }
    }
}
