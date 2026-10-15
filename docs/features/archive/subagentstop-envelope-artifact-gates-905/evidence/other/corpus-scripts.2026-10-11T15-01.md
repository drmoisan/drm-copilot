# Section 7 corpus scripts ([P1-T1], issue #905)

Timestamp: 2026-10-11T15-01
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/p1t1-parse.ps1 ([System.Management.Automation.Language.Parser]::ParseFile over each script; Get-FileHash -Algorithm SHA256)
EXIT_CODE: 0
Output Summary: The seven section 7 scripts were extracted verbatim from the plan's fenced powershell blocks (<SCRATCHPAD>/extract-s7.ps1) and each parses with 0 errors. SHA256 values and full texts follow.

```text
SCRIPT-PARSE: corpus-common.ps1 | errors=0
SCRIPT-PARSE: corpus-task-researcher.ps1 | errors=0
SCRIPT-PARSE: corpus-prd-feature.ps1 | errors=0
SCRIPT-PARSE: corpus-discovery.ps1 | errors=0
SCRIPT-PARSE: corpus-pr-author.ps1 | errors=0
SCRIPT-PARSE: ac11-ordering.ps1 | errors=0
SCRIPT-PARSE: r3-check.ps1 | errors=0
SCRIPT-SHA256: corpus-common.ps1 | CF5B7CC93584EAEE664DA88F37CF3A2B5A6AFCBFB596C8D122D96DCC11D523F8
SCRIPT-SHA256: corpus-task-researcher.ps1 | 9DF16524D9A63D1D7F4F0EDC13CE9D329F5270A90680BCAAF4367D6CE511F94A
SCRIPT-SHA256: corpus-prd-feature.ps1 | B89DC692A0482C384DB95995C7A069209533082D2878AE9EE16B218EC54156B2
SCRIPT-SHA256: corpus-discovery.ps1 | 87CB739E16A64977256673AE27EDD6287132E65DFBCA8B03C63421338257711E
SCRIPT-SHA256: corpus-pr-author.ps1 | 08FBD108CDDAF2ECCDD0D89D9CE2DA93745424338622543B5088615F2E58CF82
SCRIPT-SHA256: ac11-ordering.ps1 | 6EAB0294A4CAB38F6E7D6FE693AABCC575FC0F3199D4236F3E9E889B6EF69DA0
SCRIPT-SHA256: r3-check.ps1 | FEB4C0F78FDF76E47062AE2A4707C2A89C5B2B0DF3D47213B49C04A4FE5E25C6
```

## corpus-common.ps1

SHA256: CF5B7CC93584EAEE664DA88F37CF3A2B5A6AFCBFB596C8D122D96DCC11D523F8

```powershell
# Read-only helpers for the E3 corpus runs (issue #905). Writes no file.
function Get-CorpusTreePath {
    param([string] $Sha, [string] $Root, [string] $Pattern)
    $lines = @(& git ls-tree -r --name-only $Sha -- $Root)
    if ($LASTEXITCODE -ne 0) { throw "git ls-tree failed for $Sha -- $Root" }
    return @($lines | Where-Object { $_ -match $Pattern } | Sort-Object)
}
function Get-CorpusBlobText {
    param([string] $Sha, [string] $Path)
    $lines = @(& git show "${Sha}:$Path")
    if ($LASTEXITCODE -ne 0) { throw "git show failed for $Path" }
    return ($lines -join "`n")
}
function Get-CorpusDrift {
    param([string] $Sha, [string] $Root, [string[]] $Path)
    $treeBlob = @{}
    foreach ($line in @(& git ls-tree -r $Sha -- $Root)) {
        if ($line -match '^\d+ blob ([0-9a-f]+)\t(.+)$') { $treeBlob[$Matches[2]] = $Matches[1] }
    }
    $present = @($Path | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    $drift = [System.Collections.Generic.List[string]]::new()
    foreach ($p in @($Path | Where-Object { $present -notcontains $_ })) { $drift.Add("MISSING $p") }
    if ($present.Count -gt 0) {
        $workHash = @($present | & git hash-object --stdin-paths)
        for ($i = 0; $i -lt $present.Count; $i++) {
            if ($treeBlob[$present[$i]] -ne $workHash[$i]) { $drift.Add("CHANGED $($present[$i])") }
        }
    }
    return $drift.ToArray()
}
function New-CorpusEnvelopeJson {
    param([string] $AgentType, [string] $Message)
    return ([ordered]@{ session_id = 'e3-905-corpus'; hook_event_name = 'SubagentStop'; agent_type = $AgentType; stop_hook_active = $false; last_assistant_message = $Message } | ConvertTo-Json -Compress)
}
function New-CorpusLegacyPayload {
    param([string] $Message)
    return (@{ output = $Message } | ConvertTo-Json -Compress)
}
function Get-EvidenceFailureClass {
    # Spec v0.5 "Corpus false-positive classification (mechanical)". CHECKER-DEFECT counts as a false positive.
    param([string] $Text, [string] $Message)
    $labels = @('Complete Family', 'Exhaustive Search Scope', 'Inclusion Rules', 'Exclusion Rules', 'Primary Search Strategy or Query Expression', 'Primary Member Set', 'Primary Count', 'Cross-check Search Strategy or Query Expression', 'Cross-check Member Set', 'Cross-check Count', 'Member-set Comparison')
    $section = [regex]::Match($Text, '(?ims)^##\s+Numeric\s+Derivation\s+Evidence\s*$.*?(?=^##\s|\z)')
    $sectionText = if ($section.Success) { $section.Value } else { '' }
    $missing = [regex]::Match($Message, 'numeric derivation evidence is missing (?<label>.+)\.$')
    if ($missing.Success -and ($labels -ccontains $missing.Groups['label'].Value)) {
        $label = $missing.Groups['label'].Value
        if ([regex]::IsMatch($sectionText, "(?im)^[\t ]*[-*]?[\t ]*$([regex]::Escape($label))[\t ]*:[\t ]*\S")) { return "CHECKER-DEFECT | missing-label rule: a line for '$label' is present" }
        return "ARTIFACT-DEFECT | missing-label rule: no line for '$label'"
    }
    if ($Message.Contains('does not declare an exhaustive repository search scope')) {
        $scope = [regex]::Match($sectionText, '(?im)^[\t ]*[-*]?[\t ]*Exhaustive Search Scope[\t ]*:[\t ]*(?<value>\S(?:.*\S)?)[\t ]*$')
        $value = if ($scope.Success) { $scope.Groups['value'].Value.Trim() } else { '' }
        if ($value -match '(?i)\b(entire|whole|all)\b.*\b(repository|repo|worktree|source tree|tree)\b') { return "CHECKER-DEFECT | scope rule: value '$value' matches the classification pattern" }
        return "ARTIFACT-DEFECT | scope rule: value '$value' does not match the classification pattern"
    }
    return 'ARTIFACT-DEFECT | other-message rule'
}
```

## corpus-task-researcher.ps1

SHA256: 9DF16524D9A63D1D7F4F0EDC13CE9D329F5270A90680BCAAF4367D6CE511F94A

```powershell
param([Parameter(Mandatory)][ValidateSet('Before', 'After')][string] $Mode, [Parameter(Mandatory)][string] $Sha)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$root = (Get-Location).Path
. (Join-Path $PSScriptRoot 'corpus-common.ps1')
. (Join-Path $root '.claude/hooks/validate-task-researcher-output.ps1')
$r1 = '^(?:(?:\d{4}-\d{2}-\d{2}(?:T\d{2}-?\d{2})?|\d{8})-[A-Za-z0-9][A-Za-z0-9-]*[-.]research|research(?:-addendum)?\.\d{4}-\d{2}-\d{2}(?:T\d{2}-\d{2})?)\.md$'
function Get-RejectionClass {
    param([string] $Path, [string] $Reason, [string] $Text)
    $name = [System.IO.Path]::GetFileName($Path)
    $underRoot = ($Path.StartsWith('docs/features/') -and $Path.Contains('/research/')) -or $Path.StartsWith('docs/research/')
    if ($Reason.StartsWith('task-researcher hook: autonomous-execution', [System.StringComparison]::Ordinal) -and -not [regex]::IsMatch($Text, '(?m)^## Automation Feasibility[\t ]*$')) {
        return 'TRUE-REJECTION: content rule (no exact ## Automation Feasibility heading line)'
    }
    if ($Reason.StartsWith('task-researcher hook: numeric', [System.StringComparison]::Ordinal)) {
        if (-not [regex]::IsMatch($Text, '(?m)^## Numeric Derivation Evidence[\t ]*$')) { return 'TRUE-REJECTION: content rule (no exact ## Numeric Derivation Evidence heading line)' }
        $evidenceClass = Get-EvidenceFailureClass -Text $Text -Message $Reason
        if ($evidenceClass.StartsWith('ARTIFACT-DEFECT', [System.StringComparison]::Ordinal)) { return "TRUE-REJECTION: content rule ($evidenceClass)" }
        return "FALSE-POSITIVE (content rule: $evidenceClass)"
    }
    if ([regex]::IsMatch($name, $r1)) {
        if ($underRoot) { return 'FALSE-POSITIVE (a form R1 accepts, under a documented research root)' }
        return 'TRUE-REJECTION: outside the documented research roots (.claude/agents/task-researcher.md:30-31)'
    }
    if (-not $name.EndsWith('.md', [System.StringComparison]::Ordinal)) { return 'TRUE-REJECTION: R1 extension other than lower-case .md (not a form R1 accepts)' }
    if ($name -notmatch '\d{4}-\d{2}-\d{2}|\d{8}') { return 'TRUE-REJECTION: R1 name with no date stamp (not a form R1 accepts)' }
    if ($name -notmatch '^(?:\d{4}-\d{2}-\d{2}|\d{8}|research)') { return 'TRUE-REJECTION: R1 free-form name with the stamp only as a suffix (not a form R1 accepts)' }
    if ($name -notmatch '^research' -and $name -notmatch '[-.]research\.md$') { return 'TRUE-REJECTION: R1 leading stamp without a -research.md or .research.md ending (not a form R1 accepts)' }
    if ($name -notmatch '^research' -and $name -match '^(?:\d{4}-\d{2}-\d{2}(?:T\d{2}-?\d{2})?|\d{8})-') { return 'TRUE-REJECTION: R1 short name empty, hyphen-led, or not limited to ASCII letters, digits and hyphens (not a form R1 accepts)' }
    return 'TRUE-REJECTION: R1 stamp in another shape (not a form R1 accepts)'
}
$paths = Get-CorpusTreePath -Sha $Sha -Root 'docs' -Pattern '/research/[^/]+$'
"MODE: $Mode"
"CORPUS-COMMIT: $Sha"
'ENUMERATION: git ls-tree -r --name-only <CORPUS-COMMIT> -- docs, filtered by the regex /research/[^/]+$'
"CORPUS-COUNT: $($paths.Count)"
$drift = @(Get-CorpusDrift -Sha $Sha -Root 'docs' -Path $paths)
"CORPUS-DRIFT: $($drift.Count)"
foreach ($d in $drift) { "DRIFT: $d" }
$blocks = 0; $falsePositives = 0
foreach ($path in $paths) {
    $message = "research-path: $path"
    try {
        if ($Mode -eq 'Before') { $result = Invoke-TaskResearcherOutputValidation -RawPayload (New-CorpusLegacyPayload -Message $message) }
        else { $result = Invoke-TaskResearcherOutputValidation -InputText (New-CorpusEnvelopeJson -AgentType 'task-researcher' -Message $message) }
        $ok = [bool]$result.Ok; $reason = [string]$result.Message
    }
    catch { $ok = $false; $reason = "EXCEPTION: $($_.Exception.Message)" }
    if ($ok) { "ALLOW: $path"; continue }
    $blocks++
    $class = Get-RejectionClass -Path $path -Reason $reason -Text (Get-CorpusBlobText -Sha $Sha -Path $path)
    if ($class.StartsWith('FALSE-POSITIVE')) { $falsePositives++ }
    "BLOCK: $path | $reason"
    "CLASS: $path | $class"
}
"BLOCKS: $blocks"
"FALSE-POSITIVES: $falsePositives"
```

## corpus-prd-feature.ps1

SHA256: B89DC692A0482C384DB95995C7A069209533082D2878AE9EE16B218EC54156B2

```powershell
param([Parameter(Mandatory)][ValidateSet('Before', 'After')][string] $Mode, [Parameter(Mandatory)][string] $Sha)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$root = (Get-Location).Path
. (Join-Path $PSScriptRoot 'corpus-common.ps1')
. (Join-Path $root '.claude/hooks/validate-prd-feature-output.ps1')
$units = 'seconds|minutes|hours|days|weeks|milliseconds|lines|bytes|characters|percent|is|as|us|has|was|does|this|its|thus|plus|less|unless|across|always|yes'
$r2 = '\b(?:all|exactly|the|these|those)\s+(?:[1-9]\d*|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty)\s+(?:(?!(?:' + $units + ')\b)[\w`./-]+\s+){0,3}?(?!(?:' + $units + ')\b)[a-z][\w-]*s\b'
$policyMarkers = @('.claude/rules/', '.github/instructions/', '.github/copilot-instructions.md')
$specs = Get-CorpusTreePath -Sha $Sha -Root 'docs/features' -Pattern '(^|/)spec\.md$'
"MODE: $Mode"
"CORPUS-COMMIT: $Sha"
'ENUMERATION: git ls-tree -r --name-only <CORPUS-COMMIT> -- docs/features, filtered by the regex (^|/)spec\.md$; content read with git show <CORPUS-COMMIT>:<path>'
"SPEC-COUNT: $($specs.Count)"
$triggered = 0; $nonDerivedShape = 0
$triggeredSpecs = [System.Collections.Generic.List[string]]::new()
foreach ($path in $specs) {
    $text = Get-CorpusBlobText -Sha $Sha -Path $path
    $section = [regex]::Match($text, '(?ims)^##\s+Acceptance\s+Criteria\s*$.*?(?=^##\s|\z)')
    if (-not $section.Success) { continue }
    $startLine = ([regex]::Matches($text.Substring(0, $section.Index), "`n")).Count + 1
    $sectionLines = $section.Value -split "`n"
    $specTriggered = $false
    for ($k = 0; $k -lt $sectionLines.Length; $k++) {
        $line = $sectionLines[$k].TrimEnd("`r")
        if ($line -notmatch '^\s*[-*]\s*\[.\]') { continue }
        if (-not (Test-SpecNumericCriterion -SpecContent ("## Acceptance Criteria`n" + $line))) { continue }
        $triggered++; $specTriggered = $true
        $normalized = $line -replace '\\', '/'
        $cited = @($policyMarkers | Where-Object { $normalized.Contains($_) }).Count -gt 0
        $shape = [regex]::Match($line, $r2, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $kind = if ($shape.Success -and -not $cited) { 'DERIVED-SHAPE' } else { 'NON-DERIVED-SHAPE' }
        if ($kind -eq 'NON-DERIVED-SHAPE') { $nonDerivedShape++ }
        $span = if ($shape.Success) { $shape.Value } else { 'NONE' }
        "TRIGGER: ${path}:$($startLine + $k) | $kind | MATCH: $span | $line"
    }
    if ($specTriggered) { $triggeredSpecs.Add($path) }
}
"TRIGGERED-LINES: $triggered"
"NON-DERIVED-SHAPE-LINES: $nonDerivedShape"
foreach ($s in $triggeredSpecs) { "TRIGGERED-SPEC: $s" }
$research = Get-CorpusTreePath -Sha $Sha -Root 'docs' -Pattern '/research/[^/]+$'
$evidenceFiles = 0; $evidenceFailures = 0; $checkerDefects = 0
foreach ($path in $research) {
    $text = Get-CorpusBlobText -Sha $Sha -Path $path
    if (-not [regex]::IsMatch($text, '(?im)^##\s+Numeric\s+Derivation\s+Evidence\s*$')) { continue }
    $evidenceFiles++
    $check = Test-NumericDerivationEvidence -Content $text
    if ($check.Ok) { "EVIDENCE-OK: $path"; continue }
    $evidenceFailures++
    $evidenceClass = Get-EvidenceFailureClass -Text $text -Message ([string]$check.Message)
    if ($evidenceClass.StartsWith('CHECKER-DEFECT', [System.StringComparison]::Ordinal)) { $checkerDefects++ }
    "EVIDENCE-FAIL: $path | $($check.Message)"
    "EVIDENCE-CLASS: $path | $evidenceClass"
}
"EVIDENCE-FILES: $evidenceFiles"
"EVIDENCE-FAILURES: $evidenceFailures"
"CHECKER-DEFECTS: $checkerDefects"
```

## corpus-discovery.ps1

SHA256: 87CB739E16A64977256673AE27EDD6287132E65DFBCA8B03C63421338257711E

```powershell
param([Parameter(Mandatory)][ValidateSet('Before', 'After')][string] $Mode, [Parameter(Mandatory)][string] $Sha)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$root = (Get-Location).Path
. (Join-Path $PSScriptRoot 'corpus-common.ps1')
. (Join-Path $root '.claude/hooks/validate-discovery-artifact-gate.ps1')
$typePattern = 'discovery/(profile|feature-contract|coverage-ledger|runtime-scenario|parity-matrix|unspecified-behavior|product-decision|evidence-reference)'
$grep = @(& git grep -l -I -E $typePattern $Sha)
if ($LASTEXITCODE -gt 1) { throw 'git grep failed' }
$sources = @($grep | ForEach-Object { $_.Substring($Sha.Length + 1) } | Sort-Object)
"MODE: $Mode"
"CORPUS-COMMIT: $Sha"
"ENUMERATION: git grep -l -I -E '$typePattern' <CORPUS-COMMIT>"
"SOURCE-COUNT: $($sources.Count)"
foreach ($s in $sources) { "SOURCE: $s" }
$messages = [ordered]@{}
foreach ($s in $sources) { $messages[$s] = Get-CorpusBlobText -Sha $Sha -Path $s }
$messages['SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py'] = 'Updated scripts/dev_tools/discovery/profile_cli.py to add an output option.'
$blocks = 0
foreach ($key in $messages.Keys) {
    $text = $messages[$key]
    foreach ($token in @(Find-DiscoveryArtifactReference -OutputText $text)) { "TOKEN: $key | $token | $(Get-DiscoveryArtifactType -Path $token)" }
    try {
        if ($Mode -eq 'Before') { $result = Invoke-DiscoveryArtifactGateValidation -RawPayload (New-CorpusLegacyPayload -Message $text) }
        else { $result = Invoke-DiscoveryArtifactGateValidation -InputText (New-CorpusEnvelopeJson -AgentType 'general-purpose' -Message $text) }
        $ok = [bool]$result.Ok; $reason = [string]$result.Message
    }
    catch { $ok = $false; $reason = "EXCEPTION: $($_.Exception.Message)" }
    if ($ok) { "ALLOW: $key" } else { $blocks++; "BLOCK: $key | $reason" }
}
"BLOCKS: $blocks"
"FALSE-POSITIVES: $blocks"
```

## corpus-pr-author.ps1

SHA256: 08FBD108CDDAF2ECCDD0D89D9CE2DA93745424338622543B5088615F2E58CF82

```powershell
param([Parameter(Mandatory)][ValidateSet('Before', 'After')][string] $Mode, [Parameter(Mandatory)][string] $Sha)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$root = (Get-Location).Path
. (Join-Path $PSScriptRoot 'corpus-common.ps1')
. (Join-Path $root '.claude/hooks/validate-pr-author-output.ps1')
$numbers = @(@(& git grep -h -o -I -E 'drm-copilot/pull/[0-9]+' $Sha -- docs) | ForEach-Object { if ($_ -match 'pull/(\d+)$') { [int]$Matches[1] } } | Sort-Object -Unique)
if ($numbers.Count -eq 0) { throw 'no PR number found in tracked docs' }
"MODE: $Mode"
"CORPUS-COMMIT: $Sha"
"ENUMERATION: git grep -h -o -I -E 'drm-copilot/pull/[0-9]+' <CORPUS-COMMIT> -- docs, distinct numbers ascending"
"PR-NUMBERS: $($numbers -join ', ')"
$falsePositives = 0; $controlBlocks = 0; $controlAllows = 0
foreach ($n in $numbers) {
    $forms = [ordered]@{
        URL               = "Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/$n."
        PR_REF            = "Created PR #$n for the feature branch."
        GH_PR_CREATE      = "Ran gh pr create; the new pull request is #$n."
        GH_PR_EDIT        = "Ran gh pr edit on #$n to update the body."
        CONTROL_REFS_ONLY = "Refs #$n"
    }
    foreach ($form in $forms.Keys) {
        $message = $forms[$form]
        try {
            if ($Mode -eq 'Before') { $decision = Get-PrAuthorOutputDecision -HookInputRaw (New-CorpusLegacyPayload -Message $message) }
            else { $decision = Get-PrAuthorOutputDecision -InputText (New-CorpusEnvelopeJson -AgentType 'pr-author' -Message $message) }
            $allowed = [bool]$decision['allowed']; $reason = [string]$decision['reason']
        }
        catch { $allowed = $false; $reason = "EXCEPTION: $($_.Exception.Message)" }
        $verdict = if ($allowed) { 'ALLOW' } else { 'BLOCK' }
        "DECISION: $form | #$n | $verdict | $reason | $message"
        if ($form -eq 'CONTROL_REFS_ONLY') { if ($allowed) { $controlAllows++ } else { $controlBlocks++ } }
        elseif (-not $allowed) { $falsePositives++ }
    }
}
"CONTROL-BLOCKS: $controlBlocks"
"CONTROL-ALLOWS: $controlAllows"
"FALSE-POSITIVES: $falsePositives"
```

## ac11-ordering.ps1

SHA256: 6EAB0294A4CAB38F6E7D6FE693AABCC575FC0F3199D4236F3E9E889B6EF69DA0

```powershell
param([string] $Hook, [string] $Evidence, [string] $CorpusAfterCommit, [string] $SwitchCommit)
function Get-FunctionText {
    param([string] $Text)
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$null, [ref]$null)
    return (@($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object { $_.Extent.Text }) -join "`n---`n")
}
"VALIDATOR: $Hook"
foreach ($sha in @(& git log --format=%H --reverse -- $Evidence $Hook)) { "LOG: $sha" }
& git merge-base --is-ancestor $CorpusAfterCommit $SwitchCommit
"ANCESTRY-EXIT: $LASTEXITCODE"
$atCorpus = (@(& git show "${CorpusAfterCommit}:$Hook") -join "`n")
$atSwitch = (@(& git show "${SwitchCommit}:$Hook") -join "`n")
$token = [regex]::Escape('Exit-SubagentStopBlock -Message')
"CORPUS-AFTER-SWITCH-CALLS: $([regex]::Matches($atCorpus, $token).Count)"
"SWITCH-CALLS: $([regex]::Matches($atSwitch, $token).Count)"
$evidenceAtCorpus = (@(& git show "${CorpusAfterCommit}:$Evidence") -join "`n")
"EVIDENCE-ZERO-AT-CORPUS-AFTER: $([regex]::IsMatch($evidenceAtCorpus, '(?m)^AFTER-FALSE-POSITIVES: 0\s*$'))"
"SCOPE-RECHECK-ZERO-AT-CORPUS-AFTER: $([regex]::IsMatch($evidenceAtCorpus, '(?m)^SCOPE-RECHECK-FAILED: 0\s*$'))"
$same = if ((Get-FunctionText $atCorpus) -eq (Get-FunctionText $atSwitch)) { 'YES' } else { 'NO' }
"FUNCTIONS-IDENTICAL: $same"
```

## r3-check.ps1

SHA256: FEB4C0F78FDF76E47062AE2A4707C2A89C5B2B0DF3D47213B49C04A4FE5E25C6

```powershell
param([Parameter(Mandatory)][string] $Hook, [Parameter(Mandatory)][string] $BaseSha)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$old = '(?i)\b(entire|all|complete)\b.*\b(repository|repo|source tree|tree)\b'
$new = '(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b'
function Get-NamedFunctionText {
    param([string] $Text, [string] $Name)
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$null, [ref]$null)
    $found = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $Name }, $true))
    if ($found.Count -ne 1) { throw "expected one function $Name, found $($found.Count)" }
    return $found[0].Extent.Text
}
$baseLines = @(& git show "${BaseSha}:$Hook")
if ($LASTEXITCODE -ne 0) { throw "git show failed for $Hook" }
$baseFunction = Get-NamedFunctionText -Text ($baseLines -join "`n") -Name 'Test-NumericDerivationEvidence'
$currentFunction = Get-NamedFunctionText -Text (@(Get-Content -LiteralPath $Hook) -join "`n") -Name 'Test-NumericDerivationEvidence'
"HOOK: $Hook"
"BASE: $BaseSha"
"BASE-OLD-PATTERN-COUNT: $([regex]::Matches($baseFunction, [regex]::Escape($old)).Count)"
"CURRENT-NEW-PATTERN-COUNT: $([regex]::Matches($currentFunction, [regex]::Escape($new)).Count)"
"CURRENT-OLD-PATTERN-COUNT: $([regex]::Matches($currentFunction, [regex]::Escape($old)).Count)"
$only = if ($baseFunction.Replace($old, $new) -eq $currentFunction) { 'YES' } else { 'NO' }
"R3-ONLY-CHANGE: $only"
foreach ($value in @('entire worktree.', 'the whole worktree, all directories.', 'entire repository', 'the hooks folder')) { "R3-PATTERN: $value | $($value -match $new)" }
```
