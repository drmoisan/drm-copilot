#Requires -Version 7.0
# Unit tests for scripts/harness/HarnessParityMatrix.psm1 (issue #1025, spec `## Data & State`).
# All matrices and inventories are built in memory; no file is created.

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../../scripts/harness/HarnessParityMatrix.psm1') -Force
    Import-Module (Join-Path $PSScriptRoot '../../../scripts/harness/HarnessInventory.psm1') -Force

    $script:Ref = '#1025:survey/difference-approval.md'

    function Get-ValidMatrix {
        # One entry per disposition plus a provisional pending-source entry, sorted ordinally by id.
        $features = @(
            [ordered]@{ id = 'claude:skill:orchestrate'; ecosystem = 'claude'; kind = 'skill'; name = 'orchestrate'; source_path = '.claude/skills/orchestrate/SKILL.md'; disposition = 'generated'; target_paths = @('.claude/skills/orchestrate/SKILL.md'); generated_from = '.agents/skills/orchestrate/SKILL.md'; parity_group = 'skill:orchestrate'; consumers = @('claude-code'); owner_child = 3; decision_status = 'provisional'; decision_ref = $script:Ref }
            [ordered]@{ id = 'codex:agent:orchestrator'; ecosystem = 'codex'; kind = 'agent'; name = 'orchestrator'; source_path = '.codex/agents/orchestrator.toml'; disposition = 'generated'; target_paths = @('.codex/agents/orchestrator.toml'); generated_from = 'pending-source:agent'; parity_group = 'agent:orchestrator'; consumers = @('codex'); owner_child = 3; decision_status = 'provisional'; decision_ref = $script:Ref }
            [ordered]@{ id = 'codex:skill:orchestrate'; ecosystem = 'codex'; kind = 'skill'; name = 'orchestrate'; source_path = '.agents/skills/orchestrate/SKILL.md'; disposition = 'shared'; target_paths = @('.claude/skills/orchestrate/SKILL.md'); parity_group = 'skill:orchestrate'; consumers = @('codex', 'copilot-vscode'); owner_child = 3; decision_status = 'approved' }
            [ordered]@{ id = 'copilot:skill:orchestrate'; ecosystem = 'copilot'; kind = 'skill'; name = 'orchestrate'; source_path = '.github/skills/orchestrate/SKILL.md'; disposition = 'dropped'; reason = 'Superseded by the shared skill.'; parity_group = 'skill:orchestrate'; consumers = @(); owner_child = 6; decision_status = 'provisional'; decision_ref = $script:Ref }
            [ordered]@{ id = 'cross-tool:instructions:AGENTS.md'; ecosystem = 'cross-tool'; kind = 'instructions'; name = 'AGENTS.md'; source_path = 'AGENTS.md'; disposition = 'native'; parity_group = 'instructions:AGENTS.md'; consumers = @('codex'); owner_child = $null; decision_status = 'approved' }
        )
        return [pscustomobject]@{
            '$schema'      = 'https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json'
            schema_version = '1.0.0'
            features       = @($features | ForEach-Object { [pscustomobject]$_ })
        }
    }

    function Get-Inventory {
        return @((Get-ValidMatrix).features | ForEach-Object { [pscustomobject]@{ id = $_.id } })
    }

    function Get-MatrixWithField {
        param($Matrix, [int] $Index, [string] $Name, $Value)
        $entry = $Matrix.features[$Index]
        if (@($entry.PSObject.Properties.Name) -contains $Name) { $entry.$Name = $Value } else { $entry | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
        return $Matrix
    }

    function Get-MatrixWithoutField {
        param($Matrix, [int] $Index, [string] $Name)
        $Matrix.features[$Index].PSObject.Properties.Remove($Name)
        return $Matrix
    }

    function Get-Violation {
        param($Matrix, [object[]] $Inventory = (Get-Inventory))
        return @(Get-HarnessParityMatrixViolation -Matrix $Matrix -InventoryFeature $Inventory)
    }

    function Assert-NamesId {
        param([object[]] $Violation, [string] $Id, [string] $Because)
        @($Violation | Where-Object { $_.Message.Contains($Id) }).Count | Should -BeGreaterThan 0 -Because "$Because (violations: $(@($Violation.Message) -join ' / '))"
    }
}

AfterAll {
    Remove-Module HarnessParityMatrix, HarnessInventory -Force -ErrorAction SilentlyContinue
}

Describe 'Get-HarnessParityMatrixViolation pass case' {
    It 'reports no violation for a valid matrix covering every disposition and a provisional pending-source entry' {
        $violations = Get-Violation -Matrix (Get-ValidMatrix)
        $violations.Count | Should -Be 0 -Because ($violations.Message -join ' / ')
    }

    It 'accepts a repository-relative target_paths item' {
        $violations = Get-Violation -Matrix (Get-ValidMatrix)
        @($violations | Where-Object { $_.Message.Contains('codex:skill:orchestrate') }).Count | Should -Be 0
    }
}

Describe 'Get-HarnessParityMatrixViolation failure cases from the spec' {
    It 'reports an inventoried feature with no entry' {
        $inventory = @(Get-Inventory) + [pscustomobject]@{ id = 'codex:skill:extra-skill' }
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-ValidMatrix) -Inventory $inventory) -Id 'codex:skill:extra-skill' -Because 'a missing entry names the inventoried id'
    }

    It 'reports an entry without disposition' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 4 -Name 'disposition')) -Id 'cross-tool:instructions:AGENTS.md' -Because 'the entry lacks disposition'
    }

    It 'reports an unknown enum value in <Field>' -ForEach @(
        @{ Field = 'disposition'; Index = 4; Value = 'mirrored' }
        @{ Field = 'kind'; Index = 4; Value = 'document' }
        @{ Field = 'ecosystem'; Index = 4; Value = 'cursor' }
        @{ Field = 'consumers'; Index = 4; Value = @('copilot-web') }
        @{ Field = 'decision_status'; Index = 4; Value = 'pending' }
    ) {
        $violations = Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index $Index -Name $Field -Value $Value)
        @($violations | Where-Object { $_.Rule -eq 'enum' -and $_.Message.Contains('cross-tool:instructions:AGENTS.md') }).Count | Should -BeGreaterThan 0 -Because ($violations.Message -join ' / ')
    }

    It 'reports dropped without reason' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 3 -Name 'reason')) -Id 'copilot:skill:orchestrate' -Because 'dropped requires reason'
    }

    It 'reports dropped with an empty reason' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 3 -Name 'reason' -Value '')) -Id 'copilot:skill:orchestrate' -Because 'reason has minLength 1'
    }

    It 'reports dropped without decision_ref' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 3 -Name 'decision_ref')) -Id 'copilot:skill:orchestrate' -Because 'dropped requires decision_ref'
    }

    It 'reports a duplicate id' {
        $matrix = Get-ValidMatrix
        $matrix.features = @($matrix.features[0], $matrix.features[1], $matrix.features[2], $matrix.features[2], $matrix.features[3], $matrix.features[4])
        @(Get-Violation -Matrix $matrix | Where-Object { $_.Rule -eq 'unique-id' -and $_.Message.Contains('codex:skill:orchestrate') }).Count | Should -Be 1
    }

    It 'reports a raw pipe in an id' {
        $matrix = Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 4 -Name 'id' -Value 'cross-tool:instructions:AGENTS|md'
        Assert-NamesId -Violation (Get-Violation -Matrix $matrix) -Id 'cross-tool:instructions:AGENTS|md' -Because 'the id pattern rejects a raw pipe'
    }

    It 'reports an id inconsistent with ecosystem' {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 2 -Name 'ecosystem' -Value 'claude') | Where-Object Rule -EQ 'id-ecosystem') -Id 'codex:skill:orchestrate' -Because 'the id ecosystem segment differs'
    }

    It 'reports an id inconsistent with kind' {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 2 -Name 'kind' -Value 'agent') | Where-Object Rule -EQ 'id-kind') -Id 'codex:skill:orchestrate' -Because 'the id kind segment differs'
    }

    It 'reports unsorted features' {
        $matrix = Get-ValidMatrix
        $matrix.features = @($matrix.features[1], $matrix.features[0], $matrix.features[2], $matrix.features[3], $matrix.features[4])
        Assert-NamesId -Violation @(Get-Violation -Matrix $matrix | Where-Object Rule -EQ 'ordering') -Id 'claude:skill:orchestrate' -Because 'the entry is out of ordinal order'
    }

    It 'reports an orphan entry that is not dropped' {
        $inventory = @(Get-Inventory | Where-Object { $_.id -ne 'cross-tool:instructions:AGENTS.md' })
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-ValidMatrix) -Inventory $inventory | Where-Object Rule -EQ 'orphan') -Id 'cross-tool:instructions:AGENTS.md' -Because 'a native orphan is reported'
    }

    It 'reports shared without target_paths' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 2 -Name 'target_paths')) -Id 'codex:skill:orchestrate' -Because 'shared requires target_paths'
    }

    It 'reports generated without target_paths' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 0 -Name 'target_paths')) -Id 'claude:skill:orchestrate' -Because 'generated requires target_paths'
    }

    It 'reports generated without generated_from' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 0 -Name 'generated_from')) -Id 'claude:skill:orchestrate' -Because 'generated requires generated_from'
    }

    It 'reports provisional without decision_ref' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 0 -Name 'decision_ref')) -Id 'claude:skill:orchestrate' -Because 'provisional requires decision_ref'
    }

    It 'reports a malformed decision_ref' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 0 -Name 'decision_ref' -Value 'survey/difference-approval.md')) -Id 'claude:skill:orchestrate' -Because 'decision_ref must match #<issue>:<path>'
    }

    It 'reports an unknown entry property' {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 4 -Name 'colour' -Value 'blue') | Where-Object Rule -EQ 'unknown-property') -Id 'cross-tool:instructions:AGENTS.md' -Because 'additionalProperties is false'
    }

    It 'reports pending-source with decision_status approved' {
        $matrix = Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 1 -Name 'decision_status' -Value 'approved'
        Assert-NamesId -Violation @(Get-Violation -Matrix $matrix | Where-Object Rule -EQ 'pending-source-requires-provisional') -Id 'codex:agent:orchestrator' -Because 'pending-source requires provisional'
    }
}

Describe 'Get-HarnessParityMatrixViolation entry-level rules' {
    It 'reports dropped with target_paths' {
        Assert-NamesId -Violation (Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 3 -Name 'target_paths' -Value @('.github/skills/orchestrate/SKILL.md'))) -Id 'copilot:skill:orchestrate' -Because 'dropped forbids target_paths'
    }

    It 'reports owner_child value <Label>' -ForEach @(
        @{ Label = 'two'; Value = 2 }
        @{ Label = 'eight'; Value = 8 }
        @{ Label = 'three point five'; Value = 3.5 }
        @{ Label = 'string four'; Value = '4' }
    ) {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 2 -Name 'owner_child' -Value $Value) | Where-Object Rule -EQ 'owner-child') -Id 'codex:skill:orchestrate' -Because "owner_child $Label is outside the integer range 3 to 7"
    }

    It 'reports source_path shape <Label>' -ForEach @(
        @{ Label = 'leading slash'; Value = '/AGENTS.md' }
        @{ Label = 'drive letter'; Value = 'C:/repo/AGENTS.md' }
        @{ Label = 'dot-dot segment'; Value = 'docs/../AGENTS.md' }
    ) {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 4 -Name 'source_path' -Value $Value) | Where-Object Rule -EQ 'path-shape') -Id 'cross-tool:instructions:AGENTS.md' -Because "source_path with a $Label is rejected"
    }

    It 'reports target_paths <Label>' -ForEach @(
        @{ Label = 'empty'; Value = @(); Rule = 'min-items' }
        @{ Label = 'with a duplicate item'; Value = @('.claude/skills/orchestrate/SKILL.md', '.claude/skills/orchestrate/SKILL.md'); Rule = 'unique-items' }
    ) {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 2 -Name 'target_paths' -Value $Value) | Where-Object Rule -EQ $Rule) -Id 'codex:skill:orchestrate' -Because "target_paths $Label is rejected"
    }

    It 'reports a target_paths item shape <Label>' -ForEach @(
        @{ Label = 'leading slash'; Value = '/.claude/skills/orchestrate/SKILL.md' }
        @{ Label = 'drive letter'; Value = 'C:/repo/.claude/skills/orchestrate/SKILL.md' }
        @{ Label = 'dot-dot segment'; Value = '.claude/../skills/orchestrate/SKILL.md' }
    ) {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 2 -Name 'target_paths' -Value @($Value)) | Where-Object Rule -EQ 'path-shape') -Id 'codex:skill:orchestrate' -Because "a target_paths item with a $Label is rejected"
    }

    It 'reports a duplicate consumers item' {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 2 -Name 'consumers' -Value @('codex', 'codex')) | Where-Object Rule -EQ 'unique-items') -Id 'codex:skill:orchestrate' -Because 'consumers has uniqueItems'
    }

    It 'reports generated_from shape <Label>' -ForEach @(
        @{ Label = 'pending-source with an invalid kind'; Value = 'pending-source:Agent_1' }
        @{ Label = 'empty string'; Value = '' }
        @{ Label = 'absolute path'; Value = '/abs/x.ps1' }
    ) {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 0 -Name 'generated_from' -Value $Value) | Where-Object Rule -EQ 'generated-from-shape') -Id 'claude:skill:orchestrate' -Because "generated_from $Label is rejected"
    }

    It 'reports a missing required field <Field>' -ForEach @(
        @{ Field = 'id' }, @{ Field = 'ecosystem' }, @{ Field = 'kind' }, @{ Field = 'name' }, @{ Field = 'source_path' },
        @{ Field = 'parity_group' }, @{ Field = 'consumers' }, @{ Field = 'owner_child' }, @{ Field = 'decision_status' }
    ) {
        $violations = @(Get-Violation -Matrix (Get-MatrixWithoutField -Matrix (Get-ValidMatrix) -Index 4 -Name $Field) | Where-Object Rule -EQ 'required')
        $subject = if ($Field -eq 'id') { 'features[4]' } else { 'cross-tool:instructions:AGENTS.md' }
        Assert-NamesId -Violation $violations -Id $subject -Because "a missing $Field is reported against $subject"
    }

    It 'reports an empty <Field>' -ForEach @(@{ Field = 'name' }, @{ Field = 'parity_group' }) {
        Assert-NamesId -Violation @(Get-Violation -Matrix (Get-MatrixWithField -Matrix (Get-ValidMatrix) -Index 4 -Name $Field -Value '') | Where-Object Rule -EQ 'min-length') -Id 'cross-tool:instructions:AGENTS.md' -Because "$Field has minLength 1"
    }
}

Describe 'Get-HarnessParityMatrixViolation top-level rules' {
    It 'reports a $schema that differs from the const' {
        $matrix = Get-ValidMatrix
        $matrix.'$schema' = 'https://example.invalid/schema.json'
        Assert-NamesId -Violation (Get-Violation -Matrix $matrix) -Id '$schema' -Because 'the $schema const is enforced'
    }

    It 'reports a schema_version that does not match the pattern' {
        $matrix = Get-ValidMatrix
        $matrix.schema_version = '1.0'
        Assert-NamesId -Violation (Get-Violation -Matrix $matrix) -Id 'schema_version' -Because 'schema_version must be x.y.z'
    }

    It 'reports empty features' {
        $matrix = Get-ValidMatrix
        $matrix.features = @()
        Assert-NamesId -Violation @(Get-Violation -Matrix $matrix -Inventory @() | Where-Object Rule -EQ 'min-items') -Id 'features' -Because 'features has minItems 1'
    }

    It 'reports an unknown top-level property' {
        $matrix = Get-ValidMatrix
        $matrix | Add-Member -NotePropertyName 'generated_at' -NotePropertyValue 'now'
        Assert-NamesId -Violation (Get-Violation -Matrix $matrix) -Id 'generated_at' -Because 'top-level additionalProperties is false'
    }

    It 'reports a missing top-level property <Property>' -ForEach @(@{ Property = '$schema' }, @{ Property = 'schema_version' }, @{ Property = 'features' }) {
        $matrix = Get-ValidMatrix
        $matrix.PSObject.Properties.Remove($Property)
        $inventory = if ($Property -eq 'features') { @() } else { Get-Inventory }
        Assert-NamesId -Violation @(Get-Violation -Matrix $matrix -Inventory $inventory | Where-Object Rule -EQ 'required') -Id $Property -Because "the removed property $Property is required"
    }
}

Describe 'New-HarnessParityMatrixSkeleton parity_group families' {
    It 'emits parity_group <Expected> for <Id>' -ForEach @(
        @{ Id = 'codex:skill:orchestrate'; Kind = 'skill'; Name = 'orchestrate'; Expected = 'skill:orchestrate' }
        @{ Id = 'claude:skill-frontmatter-field:allowed-tools'; Kind = 'skill-frontmatter-field'; Name = 'allowed-tools'; Expected = 'skill-field:allowed-tools' }
        @{ Id = 'codex:skill-metadata-file:codex-model-routing'; Kind = 'skill-metadata-file'; Name = 'codex-model-routing'; Expected = 'skill-metadata:codex-model-routing' }
        @{ Id = 'codex:agent:orchestrator-c3-elevated'; Kind = 'agent'; Name = 'orchestrator-c3-elevated'; Expected = 'agent:orchestrator' }
        @{ Id = 'claude:subagent-frontmatter-field:tools'; Kind = 'subagent-frontmatter-field'; Name = 'tools'; Expected = 'subagent-field:tools' }
        @{ Id = 'copilot:handoff:orchestrator'; Kind = 'handoff'; Name = 'orchestrator'; Expected = 'handoff:orchestrator' }
        @{ Id = 'copilot:prompt:commit-message'; Kind = 'prompt'; Name = 'commit-message'; Expected = 'prompt:commit-message' }
        @{ Id = 'codex:hook-registration:PreToolUse/%5EBash%24/validate-bash'; Kind = 'hook-registration'; Name = 'PreToolUse/^Bash$/validate-bash'; Expected = 'hook:validate-bash' }
        @{ Id = 'claude:permission:allow'; Kind = 'permission'; Name = 'allow'; Expected = 'permission:allow' }
        @{ Id = 'codex:setting:features'; Kind = 'setting'; Name = 'features'; Expected = 'setting:features' }
        @{ Id = 'claude:mcp-server:drm-copilot'; Kind = 'mcp-server'; Name = 'drm-copilot'; Expected = 'mcp:drm-copilot' }
        @{ Id = 'copilot:path-scoped-rule:python-code-change'; Kind = 'path-scoped-rule'; Name = 'python-code-change.instructions'; Expected = 'rule:python-code-change' }
        @{ Id = 'claude:instructions:CLAUDE.md'; Kind = 'instructions'; Name = 'CLAUDE.md'; Expected = 'instructions:CLAUDE.md' }
    ) {
        $feature = [pscustomobject]@{ id = $Id; ecosystem = $Id.Split(':')[0]; kind = $Kind; name = $Name; source_path = 'x/y.md' }
        $entry = @(New-HarnessParityMatrixSkeleton -InventoryFeature @($feature))[0]
        $entry.parity_group | Should -Be $Expected
        @($entry.consumers).Count | Should -Be 0
        $entry.owner_child | Should -BeNullOrEmpty
    }

    It 'skips features that already have an entry' {
        $features = @([pscustomobject]@{ id = 'codex:skill:a'; ecosystem = 'codex'; kind = 'skill'; name = 'a'; source_path = '.agents/skills/a/SKILL.md' }, [pscustomobject]@{ id = 'codex:skill:b'; ecosystem = 'codex'; kind = 'skill'; name = 'b'; source_path = '.agents/skills/b/SKILL.md'; source_pointer = 'x' })
        $entries = @(New-HarnessParityMatrixSkeleton -InventoryFeature $features -ExistingId @('codex:skill:a'))
        $entries.id | Should -Be @('codex:skill:b')
        $entries[0].source_pointer | Should -Be 'x'
    }
}

Describe 'Get-HarnessParityMatrixRuleSet and Import-HarnessParityMatrix' {
    It 'exposes the id pattern and schema id as data' {
        $rules = Get-HarnessParityMatrixRuleSet
        $rules.SchemaId | Should -Be 'https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json'
        'codex:skill:orchestrate' | Should -MatchExactly $rules.IdPattern
    }

    It 'parses matrix text through the injected reader' {
        $matrix = Import-HarnessParityMatrix -Path 'config/harness-parity-matrix.json' -ReadFile { param($Path) $null = $Path; '{"schema_version":"1.0.0","features":[]}' }
        $matrix.schema_version | Should -Be '1.0.0'
    }
}
