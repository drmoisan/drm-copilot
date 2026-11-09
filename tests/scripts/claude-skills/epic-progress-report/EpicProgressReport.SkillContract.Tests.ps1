# Pester contract tests for .claude/skills/epic-progress-report/SKILL.md, its core.json entries,
# and its bundle mirror (issues #1093, #1118, #1153). Every file is a committed repository file read through
# Join-Path from $PSScriptRoot; nothing is written. Fragment checks collapse whitespace first, so a
# fragment that wraps across lines in the Markdown still matches.

BeforeAll {
    $script:repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../..'
    $script:skillFolder = Join-Path -Path $script:repositoryRoot -ChildPath '.claude/skills/epic-progress-report'
    $script:skillPath = Join-Path -Path $script:skillFolder -ChildPath 'SKILL.md'
    $script:bundleRoot = Join-Path -Path $script:repositoryRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations'
    $script:manifestPath = Join-Path -Path $script:bundleRoot -ChildPath 'pack-manifests/core.json'
    $script:canonicalInvocation = 'pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'

    $script:skillText = (Get-Content -LiteralPath $script:skillPath -Raw) -replace "`r`n", "`n"
    $frontmatterMatch = [regex]::Match($script:skillText, '(?s)\A---\n(.*?)\n---\n')
    $script:frontmatter = $frontmatterMatch.Groups[1].Value
    $script:body = $script:skillText.Substring($frontmatterMatch.Length)

    function ConvertTo-TestFlatText {
        # Collapses every whitespace run to one space so wrapped Markdown reads as one line.
        param([string] $Text)
        ($Text -replace '\s+', ' ').Trim()
    }

    function Get-TestSection {
        # Returns the text under a level-2 heading, up to the next level-2 heading outside a fence.
        param([string] $Heading)
        $lines = $script:body -split "`n"
        $collected = [System.Collections.Generic.List[string]]::new()
        $inside = $false
        $inFence = $false
        foreach ($line in $lines) {
            if ($line -match '^\s*```') { $inFence = -not $inFence }
            if (-not $inFence -and $line -match '^## ') {
                if ($inside) { break }
                $inside = ($line -eq "## $Heading")
                continue
            }
            if ($inside) { $collected.Add($line) }
        }
        $collected -join "`n"
    }

    function Get-TestPromptBlock {
        # Returns the contents of each fenced text block under the Scheduling Prompts heading.
        $section = Get-TestSection -Heading 'Scheduling Prompts'
        @([regex]::Matches($section, '(?ms)^```text\n(.*?)^```') | ForEach-Object { $_.Groups[1].Value })
    }

    function Get-TestSkillFile {
        # Returns the repository-relative path of every file in the skill folder.
        $folder = (Resolve-Path -LiteralPath $script:skillFolder).ProviderPath
        $root = (Resolve-Path -LiteralPath $script:repositoryRoot).ProviderPath
        @(Get-ChildItem -LiteralPath $folder -Recurse -File | ForEach-Object {
                [System.IO.Path]::GetRelativePath($root, $_.FullName).Replace('\', '/')
            })
    }
}

Describe 'epic-progress-report SKILL.md frontmatter' {
    It 'declares the name epic-progress-report' {
        $script:frontmatter | Should -Match '(?m)^name: epic-progress-report$'
    }

    It 'describes a five-line TL;DR every 20 minutes (issue #1153, AC-45)' {
        $script:frontmatter.Contains('a five-line TL;DR every 20 minutes') | Should -BeTrue
    }

    It 'carries a single-quoted non-empty description and an argument-hint' {
        $description = [regex]::Match($script:frontmatter, "(?m)^description: '(.+)'$")

        $description.Success | Should -BeTrue
        $description.Groups[1].Value.Trim() | Should -Not -BeNullOrEmpty
        $script:frontmatter | Should -Match '(?m)^argument-hint: \S+'
    }

    It 'grants the canonical script, CronCreate, CronList, CronDelete and PushNotification' {
        $entries = @($script:frontmatter -split "`n" | Where-Object { $_ -match '^\s+- ' } | ForEach-Object { ($_ -replace '^\s+- ', '').Trim('"') })

        $entries | Should -Contain "Bash($($script:canonicalInvocation) *)"
        foreach ($tool in @('CronCreate', 'CronList', 'CronDelete', 'PushNotification')) {
            $entries | Should -Contain $tool
        }
    }

    It 'does not fork context and is not hidden from invocation' {
        $script:frontmatter | Should -Not -Match '(?m)^context:\s*fork'
        $script:frontmatter | Should -Not -Match '(?m)^user-invocable:\s*false'
    }
}

Describe 'epic-progress-report SKILL.md structure and content' {
    It 'contains every required heading' {
        $expected = @(
            '# Epic Progress Report', '## When to Use This Skill', '## Prerequisites', '## Inputs', '## Step Model', '## Report Formats',
            '## Calculation Rules', '## Starting the Reports', '## Scheduling Prompts', '## Resetting the Baseline After a Pause',
            '## Changing the Cadence', '## Stopping the Reports', '## After a Restart', '## State File',
            '## Known Behaviors and Measured Rates', '## Decisions', '## Notes'
        )
        $headings = [System.Collections.Generic.List[string]]::new()
        $inFence = $false
        foreach ($line in ($script:body -split "`n")) {
            if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
            if (-not $inFence -and $line -match '^#{1,2} ') { $headings.Add($line.TrimEnd()) }
        }

        $expected.Count | Should -Be 17
        ($headings -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'stays under 500 lines' {
        @(Get-Content -LiteralPath $script:skillPath).Count | Should -BeLessThan 500
    }

    It 'states the report format fragments' {
        $section = ConvertTo-TestFlatText (Get-TestSection -Heading 'Report Formats')
        $fragments = @(
            '**TL;DR:** Epic #<issue> is at <tdone> of <ttotal> tasks, <sdone> of <stotal> steps (<pct>%). <done-sentence> <running-sentence>'
            '**Elapsed:** <H h MM min>; critical path about <H h MM min> left (<chain>, cap <k>[; excludes <b> blocked: #<x>, #<y>]). **Weekly** quota is at <weekly>.'
            '**Now:** #<i> <type> (<elapsed> of median <m>)[, ...]. <k> of <n> types use defaults.'
            '**Velocity:** sequential <v> tasks / hr per feature (<source>, median of <n>, SD <sd>); aggregate <avg> tasks / hr average, <recent> recent, SD <isd> over <m> intervals (aggregate, informational).'
            '**Estimated time remaining:** range <fast> to <slow> (velocity +/- 2.05 SD, <sd-source>); serial sum <H h MM min> (upper bound, no parallelism).'
            '| Feature | State | Tasks | Rate | Source | Remaining | Start | Finish |', '**Critical path:** <chain>. Headline', '**Schedule inputs:** dependency source'
            '**Serial sum:** <H h MM min> (upper bound, no parallelism). **Range:** <range>.', '**Excluded (blocked):**', 'prints `excluded`'
            'no upper bound', 'range n/a (<reason>)', 'every `**` removed'
            'Item #<issue>', 'None of the <N> features is done yet.', '<K> of <N> features are done.', 'No feature is running.'
            'is running (<d> of <t> steps).', 'are running.', 'is blocked (<reason>).', 'over median'
            'Any non-finite value prints `n/a`', 'points since the epic started', 'None yet'
            '| State | Features |', '| Blocked | <blocked> |', '| Wave | Children | Steps | Done |'
            '| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |'
            'no measured duration; default <n> min', '**Unmapped and composite stage time:**', '(approx)'
        )
        # Issue #1153 (E1) superseded the #1118 sentence that no velocity or range line is printed.
        $section.Contains('No velocity, standard-deviation, straight-line, or range line is printed') | Should -BeFalse

        foreach ($fragment in $fragments) {
            $section.Contains($fragment) | Should -BeTrue -Because "the Report Formats section must state '$fragment'"
        }
    }

    It 'states the calculation rule values' {
        $section = ConvertTo-TestFlatText (Get-TestSection -Heading 'Calculation Rules')
        $values = @(
            '90 seconds', '(default 14)', 'newest 1000 samples per type', 'an even count averages the middle pair'
            'max(0, median - elapsed in step)', '(now - last tick - excluded seconds) / (number of newly checked tasks)'
            'stage duration divided by the task count', 'a `stage_timing` sample replaces a `tick` sample'
            'epoch seconds', 'cswap list --json', 'sum over types'
            # Issue #1153 rule values (E2 to E11).
            'at least 5 tasks and 15 active minutes', 'rate + 2.05 x SD and rate - 2.05 x SD', 'at or below 0.5 tasks per hour'
            'longer than 3600 s', 'at least 600 s', '3600 / the execution default', 'nearest lower wave', 'max_parallel_features'
            'ties by ascending issue number', 'predicted `main-sync`', 'equal to the cap-1 schedule'
        )

        foreach ($value in $values) {
            $section.Contains($value) | Should -BeTrue -Because "the Calculation Rules section must state '$value'"
        }
    }

    It 'carries both scheduling prompts with their cron expressions' {
        $section = ConvertTo-TestFlatText (Get-TestSection -Heading 'Scheduling Prompts')
        $blocks = @(Get-TestPromptBlock)

        $section.Contains('cron `*/20 * * * *`, recurring') | Should -BeTrue
        # Issue #1153 (E13): no 10-minute cron remains anywhere in SKILL.md.
        $script:skillText.Contains('*/10') | Should -BeFalse
        $section.Contains('cron `7 * * * *`, recurring') | Should -BeTrue
        $blocks.Count | Should -Be 2
        foreach ($block in $blocks) {
            $block.Contains("$($script:canonicalInvocation) -EpicFolder <epic-folder>") | Should -BeTrue
        }
        $blocks[0].Contains('-Mode TLDR') | Should -BeTrue
        $blocks[0].Contains('post its output verbatim as the TL;DR epic update (no push notification)') | Should -BeTrue
        $blocks[1].Contains('(full mode) from the repository root and post its output as the hourly epic update') | Should -BeTrue
        $blocks[1].Contains('send a PushNotification with the TL;DR line (under 200 characters)') | Should -BeTrue
        $blocks[1].Contains('stop and commit at 93%') | Should -BeTrue
    }

    It 'keeps baseline and pairing arguments out of the scheduling prompts' {
        $blocks = @(Get-TestPromptBlock)

        $blocks.Count | Should -Be 2
        foreach ($block in $blocks) {
            foreach ($argument in @('-StartUtc', '-BaselineDone', '-ResetBaseline', '-PairSamples')) {
                $block.Contains($argument) | Should -BeFalse -Because "a scheduled prompt must not carry $argument"
            }
        }
    }

    It 'states the push-notification text rule, local cron time and jitter' {
        $section = ConvertTo-TestFlatText (Get-TestSection -Heading 'Scheduling Prompts')

        foreach ($fragment in @('first TL;DR output line with every `**` removed', '200 characters or longer', 'drop the running-features sentence', 'Cron times are local time', '0 to 10 minutes late', '0 to 30 minutes late', '`https://code.claude.com/docs/en/scheduled-tasks`')) {
            $section.Contains($fragment) | Should -BeTrue -Because "the Scheduling Prompts section must state '$fragment'"
        }
        # Issue #1153 (E13) superseded the 10-minute jitter text.
        $script:skillText.Contains('up to 5 minutes late') | Should -BeFalse
    }

    It 'documents reset, cadence change, stopping and restart recovery' {
        $expected = @{
            'Resetting the Baseline After a Pause' = @('-ResetBaseline', 'Pass `-StartUtc` and `-BaselineDone`', 'duration ledger and the tick anchors are kept', 'weekly-quota baseline is kept', 'The scheduled prompts are not changed', 'is appended (decision E11)')
            'Changing the Cadence'                 = @('-PairSamples', '`CronDelete`', '`CronCreate`', 'one-shot', 'Pairing affects only the check-in samples')
            'Stopping the Reports'                 = @('`CronList`', '`CronDelete`')
            'After a Restart'                      = @('session-only', '`claude --resume` or `claude --continue`', 'expire 7 days after creation', 'recreate only the missing jobs', 'reset the baseline first')
        }

        foreach ($heading in $expected.Keys) {
            $section = ConvertTo-TestFlatText (Get-TestSection -Heading $heading)
            foreach ($fragment in $expected[$heading]) {
                $section.Contains($fragment) | Should -BeTrue -Because "the '$heading' section must state '$fragment'"
            }
        }
        # Issue #1153 (E13): the worked example is one doubling with one -PairSamples run.
        $cadence = ConvertTo-TestFlatText (Get-TestSection -Heading 'Changing the Cadence')
        $cadence.Contains('from 10 to 20 minutes') | Should -BeTrue
        $cadence.Contains('one run is enough for one doubling') | Should -BeTrue
    }

    It 'documents known behaviors, rates, delivery and quota policy' {
        $expected = @{
            'Known Behaviors and Measured Rates' = @('tick split divides a batch', 'Task totals drift', 'step total grows when a remediation cycle opens', 'uses the default durations', 'not recovered')
            'Notes'                              = @('rebuilt and reinstalled', '93%', '`.claude/skills/quota-throttling/SKILL.md`', 'read-only toward git and GitHub')
            'State File'                         = @('`-StatePath` overrides it', 'never committed', 'per checkout', '`git clean -fdX` deletes it', 'not migrated', '"version": 3', 'version 4 or higher', 'progress-item-<n>.json', '"baselineDoneTasks"', '"pauses"', 'a version-2 document keeps')
        }

        foreach ($heading in $expected.Keys) {
            $section = ConvertTo-TestFlatText (Get-TestSection -Heading $heading)
            foreach ($fragment in $expected[$heading]) {
                $section.Contains($fragment) | Should -BeTrue -Because "the '$heading' section must state '$fragment'"
            }
        }
    }

    It 'states the step model, default durations and decisions' {
        $stepModel = ConvertTo-TestFlatText (Get-TestSection -Heading 'Step Model')
        $decisions = ConvertTo-TestFlatText (Get-TestSection -Heading 'Decisions')
        $inputs = ConvertTo-TestFlatText (Get-TestSection -Heading 'Inputs')
        $defaults = @('| research | 13 min |', '| spec | 6 min |', '| plan | 11 min |', '| preflight | 10 min |', '| execution | 5 min per task |', '| review | 14 min |', '| pr | 3 min |', '| ci | 17 min |', '| merge | 5 min |', '| main-sync | 60 min |', '| integration-pr | 45 min |')

        foreach ($type in @('research', 'spec', 'plan', 'preflight', 'execution', 'review', 'pr', 'ci', 'merge', 'main-sync', 'integration-pr')) {
            $stepModel.Contains("``$type``") | Should -BeTrue -Because "the Step Model section must name the $type type"
        }
        foreach ($row in $defaults) {
            $stepModel.Contains($row) | Should -BeTrue -Because "the Step Model section must state the default '$row'"
        }
        foreach ($fragment in @('one step per attempt', '`light`', 'awaiting_ci', 'blocked_conflict_loop_limit', 'composite remediation time', 'unmapped time')) {
            $stepModel.Contains($fragment) | Should -BeTrue -Because "the Step Model section must state '$fragment'"
        }
        foreach ($number in 1..13) {
            $decisions.Contains("D$($number):") | Should -BeTrue -Because "the Decisions section must state D$number"
        }
        # Issue #1153 (E15): E1 to E15 are recorded, D7, D11, and D13 are superseded in place, and D10 is amended.
        foreach ($number in 1..15) {
            $decisions.Contains("E$($number):") | Should -BeTrue -Because "the Decisions section must state E$number"
        }
        foreach ($marker in @('D7: (superseded by #1153', 'D11: (superseded by #1153', 'D13: (superseded by #1153', 'D10: (amended by E11)')) {
            $decisions.Contains($marker) | Should -BeTrue -Because "the Decisions section must state '$marker'"
        }
        $decisions.Contains('`-WaveOverheadHours` stays accepted and affects no figure') | Should -BeTrue
        $inputs.Contains('| `-Issue` |') | Should -BeTrue
        $inputs.Contains('| `-StepDefaultMinutes` |') | Should -BeTrue
    }

    It 'lists the live stage-name aliases' {
        $flat = ConvertTo-TestFlatText $script:body

        foreach ($alias in @('feature_review', 'S7_feature_review', 'atomic_execution', 'S5_atomic_execution', 'S2_research', 'S3_spec', 'S4_atomic_planning', 'S4_preflight', 'S8_create_pr', 'S9_ci_gate', 'S9_ci_green', 'S3b_research', 'S2_feature_documents')) {
            $flat.Contains("``$alias``") | Should -BeTrue -Because "SKILL.md must name the stage alias '$alias'"
        }
    }

    It 'states the item-mode and singular report wording' {
        $formats = ConvertTo-TestFlatText (Get-TestSection -Heading 'Report Formats')

        foreach ($fragment in @('#<i> is not done yet.', 'The only feature is not done yet.', 'excludes 1 blocked: #<x>', 'points since the measurement started', "not this item's cost alone", '| State | Item |', 'the chain is `#<issue>` with no tail and no cap text')) {
            $formats.Contains($fragment) | Should -BeTrue -Because "the Report Formats section must state '$fragment'"
        }
    }

    It 'states the Now line form without a recorded start and the merged-item anchor removal' {
        $formats = ConvertTo-TestFlatText (Get-TestSection -Heading 'Report Formats')

        $formats.Contains('(start not recorded; median <m>)') | Should -BeTrue -Because 'the Report Formats section must state the Now line form for a step without a recorded start'
        (ConvertTo-TestFlatText $script:body).Contains('merge step is done') | Should -BeTrue -Because 'SKILL.md must state that a merged item loses its state entry'
    }

    It 'does not state that the report wording does not change' {
        $formats = ConvertTo-TestFlatText (Get-TestSection -Heading 'Report Formats')

        $formats.Contains('do not change') | Should -BeFalse
        $formats.Contains('does not change') | Should -BeFalse
        (ConvertTo-TestFlatText $script:body).Contains("are the script's output and do not change") | Should -BeFalse
    }

    It 'names no forbidden token and no scripts/dev-tools invocation' {
        foreach ($token in @('1019', 'TaskMaster', 'No-COM', '/workspaces', 'documentation-estate-tooling')) {
            $script:skillText.Contains($token) | Should -BeFalse -Because "SKILL.md must not contain '$token'"
        }
        # A drive-letter path; the lookbehind keeps a URL scheme such as https:// from matching.
        $script:skillText | Should -Not -Match '(?<![A-Za-z])[A-Za-z]:[\\/]'
        $script:skillText | Should -Not -Match '-File\s+scripts/dev-tools'
    }

    It 'names only existing skill-folder paths' {
        $paths = @([regex]::Matches($script:skillText, '\.claude/skills/epic-progress-report/[A-Za-z0-9._/-]+') | ForEach-Object { $_.Value.TrimEnd('.') } | Sort-Object -Unique)

        $paths.Count | Should -BeGreaterThan 0
        foreach ($path in $paths) {
            Test-Path -LiteralPath (Join-Path -Path $script:repositoryRoot -ChildPath $path) | Should -BeTrue -Because "$path is named in SKILL.md"
        }
    }
}

Describe 'epic-progress-report delivery' {
    It 'lists every skill-folder file exactly once in core.json' {
        $manifestPaths = @((Get-Content -LiteralPath $script:manifestPath -Raw | ConvertFrom-Json).paths)
        $files = @(Get-TestSkillFile)

        $files.Count | Should -Be 13
        foreach ($file in $files) {
            @($manifestPaths | Where-Object { $_ -ceq $file }).Count | Should -Be 1 -Because "$file must be listed once in core.json"
        }
    }

    It 'mirrors every skill-folder file byte-identically in the bundle' {
        $files = @(Get-TestSkillFile)

        $files.Count | Should -Be 13
        foreach ($file in $files) {
            $canonical = Join-Path -Path $script:repositoryRoot -ChildPath $file
            $copy = Join-Path -Path $script:bundleRoot -ChildPath $file
            Test-Path -LiteralPath $copy -PathType Leaf | Should -BeTrue -Because "$file must exist in the bundle"
            (Get-FileHash -LiteralPath $copy -Algorithm SHA256).Hash | Should -Be (Get-FileHash -LiteralPath $canonical -Algorithm SHA256).Hash -Because "$file must be byte-identical in the bundle"
        }
    }
}
