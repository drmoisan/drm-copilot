<#
.SYNOPSIS
    Regression corpus consumer for the issue #452 under-reporting corrections.

.DESCRIPTION
    Pins gap 1 (a separator-free repository-root shared surface is reachable
    from plan text) and gap 2 (a listed directory contends with a glob beneath
    it), in both directions, against the corpus at
    tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json. The
    same corpus is consumed by test_blast_radius_regression_452.py, so the two
    runtimes are pinned by one artifact.

    Scope is detection only: every verdict is asserted on the hashtable returned
    by Test-BlastRadiusConflict. Nothing here schedules, colors, or applies a
    tolerance layer, so the corpus holds whichever of #452 and #722 merges first.

    The corpus and both committed truth tables are located relative to this
    file. No temporary file is created and no external process is started.

.PARAMETER CorpusOverride
    Optional in-memory corpus hashtable. When supplied (through
    New-PesterContainer -Data), it replaces the committed corpus for every
    assertion; the mutation demonstration uses it. Normal runs leave it unset.
#>
param(
    [hashtable] $CorpusOverride
)

# Discovery-time corpus load. Pester runs the file body during discovery, so the
# case list must exist here for -ForEach to generate one It per case. Each entry
# wraps the raw case under the key Case, because the raw case carries an input
# key that would otherwise collide with the automatic input variable.
$discoveryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
if ($null -ne $CorpusOverride) {
    $corpus = $CorpusOverride
}
else {
    $corpusPath = Join-Path $discoveryRoot 'tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json'
    $corpus = Get-Content -LiteralPath $corpusPath -Raw | ConvertFrom-Json -AsHashtable
}
$caseList = @($corpus['cases'] | ForEach-Object { @{ CaseId = [string] $_['id']; Case = $_ } })
$corpusData = @(@{ Corpus = $corpus })

BeforeAll {
    # Discovery-time variables are not visible at run time in Pester 5, so the
    # repository root is resolved again: blast-radius -> claude-lib -> scripts ->
    # tests -> repository root.
    $script:RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
    $libRoot = Join-Path $script:RepoRoot '.claude/lib/blast-radius'
    # The facade force-imports its siblings, so it is imported first; importing
    # it after the config module would remove that module's global copy.
    Import-Module (Join-Path $libRoot 'BlastRadius.psm1') -Force
    Import-Module (Join-Path $libRoot 'BlastRadiusConfig.psm1') -Force

    $selfHostedPath = Join-Path $script:RepoRoot 'config/blast-radius.json'
    $bundledPath = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json'
    $script:SelfHostedConfig = Get-Content -LiteralPath $selfHostedPath -Raw | ConvertFrom-Json -AsHashtable
    $script:BundledConfig = Get-Content -LiteralPath $bundledPath -Raw | ConvertFrom-Json -AsHashtable

    $script:ExpectedCaseIds = @(
        'g1-plan-poetry-lock', 'g1-plan-package-lock', 'g1-plan-different-surfaces',
        'g1-plan-unconfigured-root-file', 'g1-plan-quality-tiers-mandate-read',
        'g1-radius-quality-tiers', 'g1-radius-quality-tiers-vs-poetry-lock',
        'g2-dir-vs-glob', 'g2-glob-vs-dir', 'g2-dir-vs-sibling-glob', 'g2-sibling-glob-vs-dir',
        'g2-artifacts-dir-vs-glob', 'g2-artifacts-glob-vs-dir',
        'g2-artifacts-dir-vs-sibling-glob', 'g2-artifacts-sibling-glob-vs-dir',
        'g2-empty-modules-dir-vs-glob', 'g2-empty-modules-dir-vs-sibling-glob'
    )
    $script:ToleranceSkipReason = 'Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.'
    $script:ComputedAtPattern = '^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$'

    # Report whether a mapping carries exactly the named keys, independent of order.
    function Test-ExactKeySet {
        [CmdletBinding()]
        [OutputType([bool])]
        param(
            [Parameter(Mandatory = $true)] [hashtable] $Map,
            [Parameter(Mandatory = $true)] [string[]] $Key
        )

        if ($Map.Count -ne $Key.Count) { return $false }
        return (@($Key | Where-Object { -not $Map.ContainsKey($_) }).Count -eq 0)
    }

    # Render a reason list as one ordered "kind|detail" text for exact comparison.
    function Get-ReasonText {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Reason
        )

        return (@($Reason | ForEach-Object { "$($_['kind'])|$($_['detail'])" }) -join '; ')
    }

    # Assert the input block of one case against its kind: two six-key radii for
    # radius_pair, the five plan inputs for plan_pair, with non-ISO timestamps.
    function Assert-CaseInputShape {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)] [hashtable] $CorpusCase
        )

        $id = [string] $CorpusCase['id']
        $data = $CorpusCase['input']
        $data | Should -BeOfType [hashtable] -Because "$id input must be an object"
        if ($CorpusCase['kind'] -ceq 'radius_pair') {
            Test-ExactKeySet -Map $data -Key @('radius_a', 'radius_b') | Should -BeTrue -Because "$id radius inputs"
            foreach ($side in @('radius_a', 'radius_b')) {
                $radiusKeys = @('paths', 'modules', 'shared_surfaces', 'contracts', 'source', 'computed_at')
                Test-ExactKeySet -Map $data[$side] -Key $radiusKeys | Should -BeTrue -Because "$id $side key set"
                [string] $data[$side]['computed_at'] | Should -MatchExactly $script:ComputedAtPattern -Because "$id $side computed_at"
            }
        }
        else {
            $planKeys = @('plan_a', 'plan_b', 'feature_folder_a', 'feature_folder_b', 'computed_at')
            Test-ExactKeySet -Map $data -Key $planKeys | Should -BeTrue -Because "$id plan inputs"
            [string] $data['computed_at'] | Should -MatchExactly $script:ComputedAtPattern -Because "$id computed_at"
        }
    }

    # Assert one case against the Case shape table of the corpus contract.
    function Assert-CaseShape {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)] [hashtable] $CorpusCase
        )

        $id = [string] $CorpusCase['id']
        $required = @('id', 'gap', 'kind', 'direction', 'paired_case_id', 'input', 'expected')
        $allowed = $required + @('doctrine_pin', 'config_ref', 'config')
        # Every required field is present and no field outside the contract appears.
        foreach ($key in $required) { $CorpusCase.ContainsKey($key) | Should -BeTrue -Because "$id must carry $key" }
        foreach ($key in $CorpusCase.Keys) { $allowed -ccontains $key | Should -BeTrue -Because "$id carries unexpected $key" }
        $id | Should -MatchExactly '^[a-z0-9]+(-[a-z0-9]+)*$' -Because "$id must be kebab-case"
        $gapIsInteger = $CorpusCase['gap'] -is [long] -or $CorpusCase['gap'] -is [int]
        ($gapIsInteger -and @(1, 2) -contains $CorpusCase['gap']) | Should -BeTrue -Because "$id gap"
        @('radius_pair', 'plan_pair') -ccontains $CorpusCase['kind'] | Should -BeTrue -Because "$id kind"
        @('must-conflict', 'must-not-conflict') -ccontains $CorpusCase['direction'] | Should -BeTrue -Because "$id direction"
        $CorpusCase['paired_case_id'] | Should -BeOfType [string] -Because "$id paired_case_id"
        ($CorpusCase.ContainsKey('config_ref') -xor $CorpusCase.ContainsKey('config')) | Should -BeTrue -Because "$id config choice"
        # Exactly one table source is present; validate whichever one it is.
        if ($CorpusCase.ContainsKey('config_ref')) {
            $CorpusCase['config_ref'] | Should -BeExactly 'self_hosted' -Because "$id config_ref"
        }
        else {
            $CorpusCase['config'] | Should -BeOfType [hashtable] -Because "$id config"
        }
        # A doctrine pin records designed non-conflict, so it cannot be a positive.
        if ($CorpusCase.ContainsKey('doctrine_pin')) {
            $CorpusCase['doctrine_pin'] | Should -BeOfType [bool] -Because "$id doctrine_pin"
            if ($CorpusCase['doctrine_pin']) {
                $CorpusCase['direction'] | Should -BeExactly 'must-not-conflict' -Because "$id pin must be negative"
            }
        }
        Assert-CaseInputShape -CorpusCase $CorpusCase
        $expected = $CorpusCase['expected']
        Test-ExactKeySet -Map $expected -Key @('conflict', 'reasons') | Should -BeTrue -Because "$id expected keys"
        $expected['conflict'] | Should -BeOfType [bool] -Because "$id expected.conflict"
        # Each expected reason is an object of two strings.
        foreach ($reason in @($expected['reasons'])) {
            Test-ExactKeySet -Map $reason -Key @('kind', 'detail') | Should -BeTrue -Because "$id reason keys"
        }
    }
}

Describe 'BlastRadius regression corpus for issue 452' {
    Context 'Corpus contract' {
        It 'declares the contracted top-level shape' -ForEach $corpusData {
            $Corpus['schema_version'] | Should -Be 1 -Because 'schema_version must be 1'
            $Corpus['issue'] | Should -Be 452 -Because 'issue must be 452'
            $Corpus['description'] | Should -BeOfType [string] -Because 'description must be a string'
            ([string] $Corpus['description']).Trim() | Should -Not -BeNullOrEmpty -Because 'description must not be empty'
            @($Corpus['cases']).Count | Should -BeGreaterThan 0 -Because 'cases must be non-empty'
        }

        It 'matches the case shape contract for every case' -ForEach $corpusData {
            # Validate each case independently so a failure names its case id.
            foreach ($corpusCase in @($Corpus['cases'])) { Assert-CaseShape -CorpusCase $corpusCase }
        }

        It 'carries every Case List id exactly once and no other id' -ForEach $corpusData {
            $ids = @($Corpus['cases'] | ForEach-Object { [string] $_['id'] })
            @($ids | Select-Object -Unique).Count | Should -Be $ids.Count -Because 'case ids must be unique'
            $ids.Count | Should -Be $script:ExpectedCaseIds.Count -Because 'the corpus must carry the 17 Case List ids'
            # Every Case List id must be present, which with equal counts proves set equality.
            foreach ($expectedId in $script:ExpectedCaseIds) {
                $ids -ccontains $expectedId | Should -BeTrue -Because "the corpus must carry $expectedId"
            }
        }

        It 'expects a verdict consistent with each case direction' -ForEach $corpusData {
            # A must-conflict case expects a conflict with reasons; a control expects neither.
            foreach ($corpusCase in @($Corpus['cases'])) {
                $positive = $corpusCase['direction'] -ceq 'must-conflict'
                $corpusCase['expected']['conflict'] | Should -Be $positive -Because "$($corpusCase['id']) verdict/direction"
                (@($corpusCase['expected']['reasons']).Count -gt 0) | Should -Be $positive -Because "$($corpusCase['id']) reasons"
            }
        }

        It 'resolves every pairing to an opposite-direction case of the same gap' -ForEach $corpusData {
            $index = @{}
            foreach ($corpusCase in @($Corpus['cases'])) { $index[[string] $corpusCase['id']] = $corpusCase }
            $unreciprocated = [System.Collections.Generic.List[string]]::new()
            # Resolve every pairing; a positive must be named back, a control may not be only if it is a pin.
            foreach ($id in @($index.Keys)) {
                $corpusCase = $index[$id]
                $partnerId = [string] $corpusCase['paired_case_id']
                $index.ContainsKey($partnerId) | Should -BeTrue -Because "$id names unknown case $partnerId"
                $partner = $index[$partnerId]
                $partner['direction'] | Should -Not -Be $corpusCase['direction'] -Because "$id pairs across directions"
                $partner['gap'] | Should -Be $corpusCase['gap'] -Because "$id pairs within its gap"
                $reciprocal = ([string] $partner['paired_case_id']) -ceq $id
                if ($corpusCase['direction'] -ceq 'must-conflict') {
                    $reciprocal | Should -BeTrue -Because "$id must be named back by $partnerId"
                }
                elseif (-not $reciprocal) {
                    $unreciprocated.Add($id)
                }
            }
            $pins = @($index.Keys | Where-Object { $index[$_]['doctrine_pin'] -eq $true } | Sort-Object)
            $pins.Count | Should -BeGreaterThan 0 -Because 'the corpus must declare a doctrine pin'
            (@($unreciprocated | Sort-Object) -join ',') | Should -BeExactly ($pins -join ',') -Because 'only doctrine pins may be unreciprocated'
        }

        It 'pins both directions for each gap' -ForEach $corpusData {
            $present = @($Corpus['cases'] | ForEach-Object { "$($_['gap'])|$($_['direction'])" })
            # Every combination of the two gaps and two directions must appear.
            foreach ($combination in @('1|must-conflict', '1|must-not-conflict', '2|must-conflict', '2|must-not-conflict')) {
                $present -ccontains $combination | Should -BeTrue -Because "combination $combination must be present"
            }
        }

        It 'follows the plan-line intent rule for every plan line' -ForEach $corpusData {
            $bt = [char]0x60
            $writeLine = "^- \[ \] \[P\d+-T\d+\] (Edit|Create) $bt[^$bt]+$bt\.$"
            $readLine = "^- \[ \] \[P\d+-T\d+\] Read $bt[^$bt]+$bt\.$"
            $planCases = @($Corpus['cases'] | Where-Object { $_['kind'] -ceq 'plan_pair' })
            $planCases.Count | Should -BeGreaterThan 0 -Because 'the corpus must declare a plan_pair case'
            # Each side of each plan case is one line; the doctrine pin reads, every other case writes.
            foreach ($corpusCase in $planCases) {
                $pattern = if ($corpusCase['doctrine_pin'] -eq $true) { $readLine } else { $writeLine }
                foreach ($line in @([string] $corpusCase['input']['plan_a'], [string] $corpusCase['input']['plan_b'])) {
                    $line.Contains("`n") | Should -BeFalse -Because "$($corpusCase['id']) plan text must be one line"
                    $line | Should -MatchExactly $pattern -Because "$($corpusCase['id']) plan line must follow the intent rule"
                }
            }
        }
    }

    Context 'Detection-level verdicts' {
        It 'reports the corpus verdict for <CaseId>' -ForEach $caseList {
            $data = $Case['input']
            # Route on kind: declared radii are passed as-is, plan radii are derived
            # under the self-hosted table, which is then the table contention reads.
            if ($Case['kind'] -ceq 'radius_pair') {
                $config = $Case['config']
                $radiusA = $data['radius_a']
                $radiusB = $data['radius_b']
            }
            else {
                $config = $script:SelfHostedConfig
                $radiusA = Get-BlastRadius -PlanText ([string] $data['plan_a']) -SpecText '' -FeatureFolder $data['feature_folder_a'] -Config $config -ComputedAt $data['computed_at']
                $radiusB = Get-BlastRadius -PlanText ([string] $data['plan_b']) -SpecText '' -FeatureFolder $data['feature_folder_b'] -Config $config -ComputedAt $data['computed_at']
            }

            $result = Test-BlastRadiusConflict -RadiusA $radiusA -RadiusB $radiusB -Config $config

            $result['conflict'] | Should -Be $Case['expected']['conflict'] -Because "case $CaseId verdict"
            $actualText = Get-ReasonText -Reason @($result['reasons'])
            $expectedText = Get-ReasonText -Reason @($Case['expected']['reasons'])
            $actualText | Should -BeExactly $expectedText -Because "case $CaseId reasons"
        }
    }

    Context 'Bundled configuration parity' {
        It 'admits the same separator-free root surfaces from both committed tables' {
            $selfHosted = @(Get-ConfigRootSurface -Config $script:SelfHostedConfig | Sort-Object)
            $bundled = @(Get-ConfigRootSurface -Config $script:BundledConfig | Sort-Object)
            $selfHosted.Count | Should -BeGreaterThan 0 -Because 'the self-hosted table must declare a root surface'
            ($bundled -join ',') | Should -BeExactly ($selfHosted -join ',') -Because 'the bundled subset must equal the self-hosted subset'
        }
    }

    Context 'Tolerance branch' {
        It 'keeps a scheduling edge for every must-conflict case at the strictest tolerance' {
            Set-ItResult -Skipped -Because $script:ToleranceSkipReason
        }
    }
}
