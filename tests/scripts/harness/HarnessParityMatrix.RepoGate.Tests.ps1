#Requires -Version 7.0
# Repository gate for the harness parity matrix (issue #1025): reads the real tree, the committed matrix
# config/harness-parity-matrix.json and the schema config/harness-parity-matrix.schema.json. Read-only.

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/harness/HarnessInventory.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot 'scripts/harness/HarnessParityMatrix.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot 'scripts/harness/HarnessSkillContract.psm1') -Force
    $script:MatrixPath = Join-Path $script:RepoRoot 'config/harness-parity-matrix.json'
    $script:SchemaPath = Join-Path $script:RepoRoot 'config/harness-parity-matrix.schema.json'
    $script:Matrix = Import-HarnessParityMatrix -Path $script:MatrixPath
    $script:Schema = [IO.File]::ReadAllText($script:SchemaPath) | ConvertFrom-Json -AsHashtable
    $script:Rules = Get-HarnessParityMatrixRuleSet
    $script:Inventory = Get-HarnessInventory -RepositoryRoot $script:RepoRoot

    function Get-SortedText {
        param([AllowEmptyCollection()][object[]] $Value = @())
        $array = [string[]]@($Value | ForEach-Object { [string]$_ })
        [Array]::Sort($array, [StringComparer]::Ordinal)
        return ($array -join '|')
    }
}

AfterAll {
    Remove-Module HarnessSkillContract, HarnessParityMatrix, HarnessInventory -Force -ErrorAction SilentlyContinue
}

Describe 'Harness parity matrix repository gate' {
    It 'schema declares Draft 2020-12 and the 1.0.0 id' {
        $script:Schema['$schema'] | Should -BeExactly 'https://json-schema.org/draft/2020-12/schema'
        $script:Schema['$id'] | Should -BeExactly $script:Rules.SchemaId
    }

    It 'schema enums required fields and conditional rules agree with the module rule set' {
        $feature = $script:Schema['$defs']['feature']
        (Get-SortedText @($script:Schema['properties'].Keys)) | Should -BeExactly (Get-SortedText $script:Rules.TopLevelProperties) -Because 'top-level property names agree'
        (Get-SortedText $script:Schema['required']) | Should -BeExactly (Get-SortedText $script:Rules.TopLevelRequired) -Because 'top-level required lists agree'
        (Get-SortedText @($feature['properties'].Keys)) | Should -BeExactly (Get-SortedText $script:Rules.EntryProperties) -Because 'feature-entry property names agree'
        (Get-SortedText $feature['required']) | Should -BeExactly (Get-SortedText $script:Rules.EntryRequired) -Because 'feature-entry required lists agree'
        foreach ($field in @('ecosystem', 'kind', 'disposition', 'decision_status')) {
            (Get-SortedText $feature['properties'][$field]['enum']) | Should -BeExactly (Get-SortedText $script:Rules.Enums[$field]) -Because "$field enum agrees"
        }
        (Get-SortedText $feature['properties']['consumers']['items']['enum']) | Should -BeExactly (Get-SortedText $script:Rules.Enums['consumers']) -Because 'consumers enum agrees'
        $feature['properties']['id']['pattern'] | Should -BeExactly $script:Rules.IdPattern -Because 'id pattern agrees'
        $schemaRules = @($feature['allOf'] | ForEach-Object {
                $ifProperties = $_['if']['properties']
                $property = @($ifProperties.Keys)[0]
                $condition = $ifProperties[$property]
                $when = if ($condition.ContainsKey('const')) { [string]$condition['const'] } elseif ($condition.ContainsKey('enum')) { Get-SortedText $condition['enum'] } else { [string]$condition['pattern'] }
                $then = $_['then']
                $required = if ($then.ContainsKey('required')) { Get-SortedText $then['required'] } else { '' }
                $forbidden = if ($then.ContainsKey('not')) { Get-SortedText $then['not']['required'] } else { '' }
                $requiredValue = if ($then.ContainsKey('properties')) { (@($then['properties'].Keys) | ForEach-Object { "$_=$($then['properties'][$_]['const'])" }) -join '|' } else { '' }
                "$property|$when|$required|$forbidden|$requiredValue"
            })
        $moduleRules = @($script:Rules.ConditionalRules | ForEach-Object {
                $when = if ($_.PSObject.Properties.Name -contains 'IfPattern') { $_.IfPattern } elseif (@($_.IfValues).Count -gt 1) { Get-SortedText $_.IfValues } else { [string]$_.IfValues[0] }
                $requiredValue = ''
                if ($_.PSObject.Properties.Name -contains 'RequiredValue') {
                    $valueTable = $_.RequiredValue
                    $requiredValue = (@($valueTable.Keys) | ForEach-Object { "$_=$($valueTable[$_])" }) -join '|'
                }
                $required = @($_.Required | Where-Object { $_ })
                "$($_.IfProperty)|$when|$(Get-SortedText $required)|$(Get-SortedText @($_.Forbidden | Where-Object { $_ }))|$requiredValue"
            })
        (Get-SortedText $schemaRules) | Should -BeExactly (Get-SortedText $moduleRules) -Because 'the five conditional rules agree'
    }

    It 'committed matrix has no violation against the live inventory' {
        $violations = @(Get-HarnessParityMatrixViolation -Matrix $script:Matrix -InventoryFeature $script:Inventory)
        $violations.Count | Should -Be 0 -Because ("violations:`n" + (@($violations.Message) -join "`n"))
    }

    It 'every hook-registration permission and subagent-frontmatter-field entry has a parity_group' {
        $kinds = @('hook-registration', 'permission', 'subagent-frontmatter-field')
        $inventoried = @($script:Inventory | Where-Object { $kinds -contains $_.kind } | ForEach-Object id)
        $byId = @{}
        foreach ($entry in @($script:Matrix.features)) { $byId[[string]$entry.id] = $entry }
        $lacking = @($inventoried | Where-Object { -not $byId.ContainsKey($_) -or -not ([string]$byId[$_].parity_group) })
        $lacking.Count | Should -Be 0 -Because ("entries without a parity_group:`n" + ($lacking -join "`n"))
    }

    It 'every shared codex skill has a conforming contract' {
        $violations = @(Get-HarnessSkillContractSetViolation -Matrix $script:Matrix -RepositoryRoot $script:RepoRoot)
        $violations.Count | Should -Be 0 -Because ("contract violations:`n" + (@($violations.Message) -join "`n"))
    }

    It 'matrix and schema files are UTF-8 without BOM with LF endings and two-space indentation' {
        $offending = [System.Collections.Generic.List[string]]::new()
        foreach ($path in @($script:MatrixPath, $script:SchemaPath)) {
            $bytes = [System.IO.File]::ReadAllBytes($path)
            $name = Split-Path -Leaf $path
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $offending.Add("${name}: byte-order mark") }
            if ([Array]::IndexOf($bytes, [byte]0x0D) -ge 0) { $offending.Add("${name}: carriage return byte") }
            $lines = [System.Text.Encoding]::UTF8.GetString($bytes).Split([char]10)
            $badIndent = @($lines | Where-Object { $_ -match '^(\s*)' -and ($Matches[1] -match '[^ ]' -or $Matches[1].Length % 2 -ne 0) })
            if ($badIndent.Count -gt 0) { $offending.Add("${name}: $($badIndent.Count) lines with tab or odd indentation") }
            if (@($lines | Where-Object { $_ -match '^  \S' }).Count -eq 0) { $offending.Add("${name}: no line starts with exactly two spaces") }
        }
        $offending.Count | Should -Be 0 -Because ($offending -join '; ')
    }

    It 'committed matrix passes Test-Json on PowerShell 7.4 or later' -Skip:($PSVersionTable.PSVersion -lt [version]'7.4') {
        Test-Json -Path $script:MatrixPath -SchemaFile $script:SchemaPath | Should -BeTrue
    }
}
