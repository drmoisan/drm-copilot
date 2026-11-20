#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Guard suite for the retirement of the Copilot skill copies and the thinned Copilot layer (issue #1032).

.DESCRIPTION
    Each `CLR-` check is a pure function over text that a reader seam supplies, and returns one
    violation string per broken rule. The positive `It` blocks feed the checks the committed files of
    this repository; each `-REJECTS` block feeds the same check in-memory text that breaks its rule
    and asserts that the check reports it. The retired path is built at runtime from its two parts,
    so this file does not carry it as a literal. The suite reads files only and writes nothing.
#>

BeforeAll {
    $script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    $script:Bundle = 'extensions/drm-copilot/resources'
    $script:RetiredPath = (@('.github', 'skills') -join '/')
    $script:RetiredRoots = @($script:RetiredPath, "$($script:Bundle)/customizations/$($script:RetiredPath)")
    $script:BriefCopies = @(
        '.agents/skills/execution-environment/SKILL.md'
        '.claude/skills/execution-environment/SKILL.md'
        "$($script:Bundle)/claude-customizations/.claude/skills/execution-environment/SKILL.md"
        "$($script:Bundle)/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md"
    )
    $script:ContractCopies = @(
        '.agents/skills/atomic-plan-contract/SKILL.md'
        '.claude/skills/atomic-plan-contract/SKILL.md'
        "$($script:Bundle)/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md"
        "$($script:Bundle)/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md"
    )
    $script:ReadFirstAgents = @(
        foreach ($name in 'atomic_executor', 'atomic_planning', 'orchestrator', 'task-researcher') {
            ".github/agents/$name.agent.md"
            "$($script:Bundle)/customizations/.github/agents/$name.agent.md"
        }
    )
    $script:CurrentDocs = @(
        'docs/engineering/claude-code-architecture.md'
        '.agents/README.md'
        "$($script:Bundle)/codex-and-agents-customizations/.agents/README.md"
        'README.md'
        'docs/engineering/legacy-discovery-and-parity/maintainer-guide.md'
        'docs/engineering/legacy-discovery-and-parity/workflow.md'
        'docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md'
    )
    $script:BriefTargets = @(
        'byte-identical in four locations', 'in all four byte-identical copies', 'in the four `documentation-workflow` copies',
        'in the four copies of this brief', 'in the four `atomic-plan-contract` copies'
    )
    $script:BriefSources = @(
        'byte-identical in six locations', 'in all six byte-identical copies', 'in the six `documentation-workflow` copies',
        'in the six copies of this brief', 'in the six `atomic-plan-contract` copies'
    )
    $script:CollisionKeys = [ordered]@{
        'chat.agentSkillsLocations'       = '".claude/skills": false'
        'chat.instructionsFilesLocations' = '".claude/rules": false'
        'chat.agentFilesLocations'        = '".claude/agents": false'
        'chat.useClaudeMdFile'            = 'false'
    }
    $script:KeptDefaultKeys = @('chat.useAgentsMdFile', 'chat.useClaudeHooks', 'github.copilot.chat.codeGeneration.useInstructionFiles')
    # Writer tokens (H3 plan), built from parts so this file does not carry them as literals.
    $script:WriterScriptName = (@('sync', 'agents', 'from', 'instructions') -join '-')
    $script:WriterCommandName = (@('sync', 'Agents', 'From', 'Instructions') -join '')
    $script:WriterTokens = @($script:WriterScriptName, $script:WriterCommandName)
    $script:WriterFiles = @(
        "scripts/dev-tools/$($script:WriterScriptName).ps1"
        "$($script:Bundle)/templates/$($script:WriterScriptName).ps1"
        "tests/scripts/dev-tools/$($script:WriterScriptName).Tests.ps1"
    )
    $script:WriterCommandFiles = @(
        'extensions/drm-copilot/package.json'
        'extensions/drm-copilot/src/repo-automation-command-registration-admin.ts'
        'extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts'
        'scripts/dev_tools/push_down_copilot_customizations_rewrites.py'
        '.vscode/tasks.json'
        'config/poshqc-shard-weights.json'
    )

    function Read-ClrText {
        # Reader seam: returns the text of one repository-relative file, or $null when it is absent.
        param([Parameter(Mandatory)] [string] $RelativePath)
        $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
        return ([System.IO.File]::ReadAllText($path) -replace "`r`n", "`n")
    }

    function Get-ClrFileUnder {
        # Reader seam: returns the repository-relative path of every file under each root that exists.
        param([Parameter(Mandatory)] [string[]] $RelativeRoot)
        foreach ($root in $RelativeRoot) {
            $full = Join-Path -Path $script:RepoRoot -ChildPath $root
            if (-not (Test-Path -LiteralPath $full -PathType Container)) { continue }
            foreach ($file in Get-ChildItem -LiteralPath $full -Recurse -File) {
                [System.IO.Path]::GetRelativePath($script:RepoRoot, $file.FullName).Replace('\', '/')
            }
        }
    }

    function Get-ClrTextMap {
        # Returns an ordered map of repository-relative path to text for the named files.
        param([Parameter(Mandatory)] [string[]] $RelativePath)
        $map = [ordered]@{}
        foreach ($relative in $RelativePath) { $map[$relative] = Read-ClrText -RelativePath $relative }
        return $map
    }

    function Test-ClrSkillTreesAbsent {
        # CLR-SKILL-TREES-ABSENT: no file lies under either retired tree.
        param([AllowEmptyCollection()] [string[]] $FilePath = @(), [Parameter(Mandatory)] [string[]] $RetiredRoot)
        foreach ($path in $FilePath) {
            foreach ($root in $RetiredRoot) {
                if ($path.StartsWith("$root/", [System.StringComparison]::Ordinal)) { "file under a retired tree: $path" }
            }
        }
    }

    function Test-ClrBriefCount {
        # CLR-BRIEF-COUNT: every brief copy holds each S1 to S5 target and no source wording; every
        # contract copy holds the S6 target and not its source; no brief copy names the retired path.
        param([Parameter(Mandatory)] $BriefText, [Parameter(Mandatory)] $ContractText, [Parameter(Mandatory)] [string] $RetiredPath)
        foreach ($path in $BriefText.Keys) {
            $text = $BriefText[$path]
            if ($null -eq $text) { "missing brief copy: $path"; continue }
            foreach ($target in $script:BriefTargets) { if (-not $text.Contains($target)) { "${path}: lacks '$target'" } }
            foreach ($source in $script:BriefSources) { if ($text.Contains($source)) { "${path}: still holds '$source'" } }
            if ($text.Contains($RetiredPath)) { "${path}: names the retired path" }
        }
        foreach ($path in $ContractText.Keys) {
            $text = $ContractText[$path]
            if ($null -eq $text) { "missing contract copy: $path"; continue }
            if (-not $text.Contains('in all four byte-identical copies')) { "${path}: lacks the S6 target" }
            if ($text.Contains('in all six byte-identical copies')) { "${path}: still holds the S6 source wording" }
        }
    }

    function Test-ClrReadFirst {
        # CLR-READ-FIRST: each read-first agent file names the shared .agents brief.
        param([Parameter(Mandatory)] $AgentText)
        $line = 'Read `.agents/skills/execution-environment/SKILL.md` first'
        foreach ($path in $AgentText.Keys) {
            if ($null -eq $AgentText[$path] -or -not $AgentText[$path].Contains($line)) { "${path}: lacks the .agents read-first line" }
        }
    }

    function Test-ClrCopilotInstruction {
        # CLR-COPILOT-INSTRUCTIONS: the Copilot instructions hold no tone-policy token and equal the bundle copy.
        param([AllowNull()] [string] $Text, [AllowNull()] [string] $BundleText)
        if ($null -eq $Text) { 'the Copilot instructions file is missing'; return }
        foreach ($token in 'strictly professional', 'Do not use jokes') { if ($Text.Contains($token)) { "the Copilot instructions hold '$token'" } }
        if ($Text -cne $BundleText) { 'the Copilot instructions differ from the bundle copy' }
    }

    function Test-ClrCollisionControl {
        # CLR-COLLISION-CONTROLS: exactly one AD-3 case holds in full, no kept-default key is written,
        # and the retired settings_required file is absent.
        param([AllowNull()] [string] $ReadmeText, [AllowNull()] [string] $SettingsText, [bool] $RequiredFileExists)
        $settings = if ($SettingsText) { $SettingsText | ConvertFrom-Json -AsHashtable } else { @{} }
        $chatKeys = @($settings.Keys | Where-Object { $_.StartsWith('chat.', [System.StringComparison]::Ordinal) })
        $workspace = $true
        foreach ($key in $script:CollisionKeys.Keys) { if (-not $settings.ContainsKey($key)) { $workspace = $false } }
        if ($workspace) {
            foreach ($location in 'chat.agentSkillsLocations', 'chat.instructionsFilesLocations', 'chat.agentFilesLocations') {
                $folder = $script:CollisionKeys[$location].Split('"')[1]
                if ($settings[$location] -isnot [System.Collections.IDictionary] -or $settings[$location][$folder] -ne $false) { $workspace = $false }
            }
            if ($settings['chat.useClaudeMdFile'] -ne $false) { $workspace = $false }
        }
        $section = if ($ReadmeText) { [regex]::Match($ReadmeText, '(?ms)^### Copilot collision controls\n(?<body>.*?)(?=^#{2,3} |\z)').Groups['body'].Value } else { '' }
        $user = $section.Length -gt 0 -and $chatKeys.Count -eq 0
        foreach ($key in $script:CollisionKeys.Keys) {
            $value = $script:CollisionKeys[$key]
            $expected = if ($value -eq 'false') { """${key}"": false" } else { """${key}"": { $value }" }
            if (-not $section.Contains($expected)) { $user = $false }
        }
        if ($workspace -eq $user) { 'exactly one AD-3 case must hold in full' }
        foreach ($key in $script:KeptDefaultKeys) { if ($settings.ContainsKey($key)) { "settings.json writes the kept-default key $key" } }
        if ($RequiredFileExists) { '.vscode/settings_required.json exists' }
    }

    function Test-ClrRetiredPathAbsent {
        # CLR-AGENT-FILES, CLR-CURRENT-DOCS and CLR-PACK-MANIFESTS: no supplied text names the retired path.
        param([Parameter(Mandatory)] $Text, [Parameter(Mandatory)] [string] $RetiredPath)
        foreach ($path in $Text.Keys) {
            if ($null -ne $Text[$path] -and $Text[$path].Contains($RetiredPath)) { "${path}: names the retired path" }
        }
    }

    function Test-ClrWriterFilesAbsent {
        # CLR-WRITER-FILES-ABSENT: none of the retired writer files exists; the map holds each path's text or $null.
        param([Parameter(Mandatory)] $Text)
        foreach ($path in $Text.Keys) { if ($null -ne $Text[$path]) { "retired writer file present: $path" } }
    }

    function Test-ClrWriterCommandAbsent {
        # CLR-WRITER-COMMAND-ABSENT: no supplied text holds a writer token.
        param([Parameter(Mandatory)] $Text, [Parameter(Mandatory)] [string[]] $Token)
        foreach ($path in $Text.Keys) {
            if ($null -eq $Text[$path]) { "missing file: $path"; continue }
            foreach ($t in $Token) { if ($Text[$path].Contains($t)) { "${path}: holds a writer token" } }
        }
    }

    function Test-ClrWriterChangelog {
        # CLR-WRITER-CHANGELOG: the Unreleased section holds a Removed subsection whose entries name the removed command.
        param([AllowNull()] [string] $Text)
        if ($null -eq $Text) { 'the extension CHANGELOG is missing'; return }
        $unreleased = [regex]::Match($Text, '(?ms)^## \[Unreleased\]\n(?<body>.*?)(?=^## \[|\z)')
        if (-not $unreleased.Success) { 'the CHANGELOG has no Unreleased section'; return }
        $removed = [regex]::Match($unreleased.Groups['body'].Value, '(?ms)^### Removed\n(?<body>.*?)(?=^#{2,3} |\z)')
        if (-not $removed.Success) { 'the Unreleased section has no Removed subsection'; return }
        if (-not $removed.Groups['body'].Value.Contains('Sync AGENTS.md from Instructions')) { 'the Removed subsection does not name the removed command' }
    }
}

AfterAll {
    foreach ($name in 'Read-ClrText', 'Get-ClrFileUnder', 'Get-ClrTextMap', 'Test-ClrSkillTreesAbsent', 'Test-ClrBriefCount', 'Test-ClrReadFirst', 'Test-ClrCopilotInstruction', 'Test-ClrCollisionControl', 'Test-ClrRetiredPathAbsent', 'Test-ClrWriterFilesAbsent', 'Test-ClrWriterCommandAbsent', 'Test-ClrWriterChangelog') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'Copilot layer retirement (issue #1032)' {
    It 'CLR-SKILL-TREES-ABSENT finds no file under either retired tree' {
        # Arrange
        $files = @(Get-ClrFileUnder -RelativeRoot $script:RetiredRoots)

        # Act
        $violations = @(Test-ClrSkillTreesAbsent -FilePath $files -RetiredRoot $script:RetiredRoots)

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-SKILL-TREES-ABSENT-REJECTS a file under a retired tree' {
        # Act
        $violations = @(Test-ClrSkillTreesAbsent -FilePath @("$($script:RetiredPath)/x/SKILL.md") -RetiredRoot $script:RetiredRoots)

        # Assert
        $violations.Count | Should -Be 1
    }

    It 'CLR-BRIEF-COUNT holds every count target in each remaining brief and contract copy' {
        # Act
        $violations = @(Test-ClrBriefCount -BriefText (Get-ClrTextMap -RelativePath $script:BriefCopies) -ContractText (Get-ClrTextMap -RelativePath $script:ContractCopies) -RetiredPath $script:RetiredPath)

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-BRIEF-COUNT-REJECTS a source count and a missing S6 target' {
        # Arrange
        $brief = [ordered]@{ 'brief.md' = 'The same text is byte-identical in six locations.' }
        $contract = [ordered]@{ 'contract.md' = 'in all six byte-identical copies' }

        # Act
        $violations = @(Test-ClrBriefCount -BriefText $brief -ContractText $contract -RetiredPath $script:RetiredPath)

        # Assert
        ($violations -match 'still holds') | Should -Not -BeNullOrEmpty
        ($violations -match 'lacks the S6 target') | Should -Not -BeNullOrEmpty
    }

    It 'CLR-BRIEF-COUNT-REJECTS a brief copy that names the retired path' {
        # Arrange: every count target is present and no source wording, so only the retired-path rule can fire.
        $brief = [ordered]@{ 'brief.md' = (($script:BriefTargets -join "`n") + "`nSee $($script:RetiredPath)/execution-environment.") }
        $contract = [ordered]@{ 'contract.md' = 'in all four byte-identical copies' }

        # Act
        $violations = @(Test-ClrBriefCount -BriefText $brief -ContractText $contract -RetiredPath $script:RetiredPath)

        # Assert
        $violations.Count | Should -Be 1
        $violations[0] | Should -Match 'names the retired path'
    }

    It 'CLR-READ-FIRST names the .agents brief in each read-first agent file and bundle copy' {
        # Act
        $violations = @(Test-ClrReadFirst -AgentText (Get-ClrTextMap -RelativePath $script:ReadFirstAgents))

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-READ-FIRST-REJECTS a read-first line that names the retired brief' {
        # Arrange
        $agent = [ordered]@{ 'agent.md' = "Read ``$($script:RetiredPath)/execution-environment/SKILL.md`` first, before any other step." }

        # Act / Assert
        @(Test-ClrReadFirst -AgentText $agent).Count | Should -Be 1
    }

    It 'CLR-COPILOT-INSTRUCTIONS holds no tone-policy token and equals its bundle copy' {
        # Act
        $violations = @(Test-ClrCopilotInstruction -Text (Read-ClrText -RelativePath '.github/copilot-instructions.md') -BundleText (Read-ClrText -RelativePath "$($script:Bundle)/customizations/.github/copilot-instructions.md"))

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-COPILOT-INSTRUCTIONS-REJECTS tone-policy text and a differing bundle copy' {
        # Act
        $violations = @(Test-ClrCopilotInstruction -Text "- Do not use jokes.`n" -BundleText "# Copilot-only instructions`n")

        # Assert
        $violations.Count | Should -Be 2
    }

    It 'CLR-COLLISION-CONTROLS holds exactly one AD-3 case with no kept-default key' {
        # Arrange
        $requiredExists = Test-Path -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath '.vscode/settings_required.json') -PathType Leaf

        # Act
        $violations = @(Test-ClrCollisionControl -ReadmeText (Read-ClrText -RelativePath 'README.md') -SettingsText (Read-ClrText -RelativePath '.vscode/settings.json') -RequiredFileExists $requiredExists)

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-COLLISION-CONTROLS-REJECTS no complete case, a kept-default key, and a settings_required file' {
        # Arrange
        $settings = '{ "chat.useAgentsMdFile": true }'

        # Act
        $violations = @(Test-ClrCollisionControl -ReadmeText "# Readme`n" -SettingsText $settings -RequiredFileExists $true)

        # Assert
        $violations.Count | Should -Be 3
    }

    It 'CLR-COLLISION-CONTROLS-REJECTS a complete workspace case with a wrong value' {
        # Arrange: all four collision keys are present and correct except one location value, so only the value comparison can reject it.
        $settings = '{ "chat.agentSkillsLocations": { ".claude/skills": true }, "chat.instructionsFilesLocations": { ".claude/rules": false }, "chat.agentFilesLocations": { ".claude/agents": false }, "chat.useClaudeMdFile": false }'

        # Act
        $violations = @(Test-ClrCollisionControl -ReadmeText "# Readme`n" -SettingsText $settings -RequiredFileExists $false)

        # Assert
        $violations.Count | Should -Be 1
        $violations[0] | Should -Match 'exactly one AD-3 case must hold in full'
    }

    It 'CLR-AGENT-FILES finds no retired path in any Copilot agent file or bundle copy' {
        # Arrange
        $paths = @(Get-ClrFileUnder -RelativeRoot @('.github/agents', "$($script:Bundle)/customizations/.github/agents"))

        # Act
        $violations = @(Test-ClrRetiredPathAbsent -Text (Get-ClrTextMap -RelativePath $paths) -RetiredPath $script:RetiredPath)

        # Assert
        $paths.Count | Should -BeGreaterThan 0
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-AGENT-FILES-REJECTS an agent file that names the retired path' {
        # Act / Assert
        @(Test-ClrRetiredPathAbsent -Text ([ordered]@{ 'agent.md' = "See $($script:RetiredPath)/x." }) -RetiredPath $script:RetiredPath).Count | Should -Be 1
    }

    It 'CLR-CURRENT-DOCS finds no retired path in the current-fact documents' {
        # Act
        $violations = @(Test-ClrRetiredPathAbsent -Text (Get-ClrTextMap -RelativePath $script:CurrentDocs) -RetiredPath $script:RetiredPath)

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-CURRENT-DOCS-REJECTS a document that names the retired path' {
        # Act / Assert
        @(Test-ClrRetiredPathAbsent -Text ([ordered]@{ 'README.md' = "[skills]($($script:RetiredPath)/README.md)" }) -RetiredPath $script:RetiredPath).Count | Should -Be 1
    }

    It 'CLR-PACK-MANIFESTS finds no retired path in any pack manifest' {
        # Arrange
        $roots = @(foreach ($pack in 'claude-customizations', 'codex-and-agents-customizations', 'customizations') { "$($script:Bundle)/$pack/pack-manifests" })
        $paths = @(Get-ClrFileUnder -RelativeRoot $roots | Where-Object { $_ -like '*.json' })

        # Act
        $violations = @(Test-ClrRetiredPathAbsent -Text (Get-ClrTextMap -RelativePath $paths) -RetiredPath $script:RetiredPath)

        # Assert
        $paths.Count | Should -BeGreaterThan 0
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-PACK-MANIFESTS-REJECTS a manifest entry under the retired tree' {
        # Act / Assert
        @(Test-ClrRetiredPathAbsent -Text ([ordered]@{ 'core.json' = "{ ""path"": ""$($script:RetiredPath)/x/SKILL.md"" }" }) -RetiredPath $script:RetiredPath).Count | Should -Be 1
    }

    It 'CLR-WRITER-FILES-ABSENT finds none of the retired writer files' {
        # Act
        $violations = @(Test-ClrWriterFilesAbsent -Text (Get-ClrTextMap -RelativePath $script:WriterFiles))

        # Assert
        $script:WriterFiles.Count | Should -Be 3
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-WRITER-FILES-ABSENT-REJECTS a writer file that is present' {
        # Arrange
        $text = [ordered]@{ $script:WriterFiles[0] = '# writer'; $script:WriterFiles[1] = $null }

        # Act / Assert
        @(Test-ClrWriterFilesAbsent -Text $text).Count | Should -Be 1
    }

    It 'CLR-WRITER-COMMAND-ABSENT finds no writer token in the command, rewrite, task and shard-weight files' {
        # Act
        $violations = @(Test-ClrWriterCommandAbsent -Text (Get-ClrTextMap -RelativePath $script:WriterCommandFiles) -Token $script:WriterTokens)

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-WRITER-COMMAND-ABSENT-REJECTS a command id and a script reference' {
        # Arrange
        $text = [ordered]@{
            'package.json' = """command"": ""drmCopilotExtension.$($script:WriterCommandName)"""
            'tasks.json'   = '"${workspaceFolder}/scripts/dev-tools/' + $script:WriterScriptName + '.ps1"'
        }

        # Act / Assert
        @(Test-ClrWriterCommandAbsent -Text $text -Token $script:WriterTokens).Count | Should -Be 2
    }

    It 'CLR-WRITER-CHANGELOG records the command removal under Unreleased' {
        # Act
        $violations = @(Test-ClrWriterChangelog -Text (Read-ClrText -RelativePath 'extensions/drm-copilot/CHANGELOG.md'))

        # Assert
        $violations | Should -BeNullOrEmpty
    }

    It 'CLR-WRITER-CHANGELOG-REJECTS a removal recorded only under a released version' {
        # Arrange
        $text = "# Changelog`n`n## [Unreleased]`n`n### Added`n`n- x`n`n## [0.0.1] - 2026-05-02`n`n### Removed`n`n- Sync AGENTS.md from Instructions command.`n"

        # Act / Assert
        @(Test-ClrWriterChangelog -Text $text).Count | Should -Be 1
    }
}
