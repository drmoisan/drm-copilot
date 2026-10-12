# Static checks: validate-discovery-artifact-gate (issue #905)

## [P7-T1] Conversion of .claude/hooks/validate-discovery-artifact-gate.ps1 (including R4)

Timestamp: 2026-10-11T23-13
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-discovery-artifact-gate.ps1 -Absent 'CLAUDE_HOOK_INPUT||RawPayload||\.output\b' -Simple '<line E>||Read-SubagentStopEnvelope -InputText $InputText||Exit-SubagentStopBlock -Message||<R4 new line>||<R4 old line>||DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly' -TrimLine '$hasErrorOutput = -not [string]::IsNullOrWhiteSpace($validatorResult[''Output''])'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `RawPayload`, `\.output\b` returns no match; counts are 1 for line E, 1 for `Read-SubagentStopEnvelope -InputText $InputText`, 0 for `Exit-SubagentStopBlock -Message`; R4: 1 for `if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {` and 0 for `if (Get-DiscoveryArtifactType -Path $trimmed) {`; the trimmed `$hasErrorOutput = -not [string]::IsNullOrWhiteSpace($validatorResult['Output'])` line matches exactly one line (234); `DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly` present (2). In `git diff -U0 1011d98d7830aea7e53511a972b0868b323d5a44 -- .claude/hooks/validate-discovery-artifact-gate.ps1` (MERGE_BASE), exactly one hunk has an old-side range intersecting lines 156-192: `@@ -184 +190 @@`, which removes `if (Get-DiscoveryArtifactType -Path $trimmed) {` and adds `if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {` only (the neighbouring hunks are `-38,0` and `-197,2`). Mirror byte identity is asserted by [P7-T5]. R-RESET: `P7-T1: none present`.

Recorded `git diff -U0 <MERGE_BASE>` output follows the static-check output.

```text
FILE: .claude/hooks/validate-discovery-artifact-gate.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , RawPayload , \.output\b | matches=0
SIMPLE-COUNT: try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ } | 1
SIMPLE-COUNT: Read-SubagentStopEnvelope -InputText $InputText | 1
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 0
SIMPLE-COUNT: if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) { | 1
SIMPLE-COUNT: if (Get-DiscoveryArtifactType -Path $trimmed) { | 0
SIMPLE-COUNT: DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly | 2
TRIMLINE-COUNT: $hasErrorOutput = -not [string]::IsNullOrWhiteSpace($validatorResult['Output']) | 1 | lines=234
LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | 253
```

```text
diff --git a/.claude/hooks/validate-discovery-artifact-gate.ps1 b/.claude/hooks/validate-discovery-artifact-gate.ps1
index cfaaac856..242a56eaf 100644
--- a/.claude/hooks/validate-discovery-artifact-gate.ps1
+++ b/.claude/hooks/validate-discovery-artifact-gate.ps1
@@ -8,6 +8,7 @@
-    generic-agent matcher group. The hook reads $env:CLAUDE_HOOK_INPUT JSON
-    containing .output (the terminating subagent's final text), scans that
-    text for discovery-artifact path references via Get-DiscoveryArtifactType,
-    and for each recognized reference (when a required-artifact declaration is
-    present) invokes the discovery validator CLI via
-    Invoke-DiscoveryValidatorExe.
+    generic-agent matcher group. The hook reads the SubagentStop envelope JSON
+    from stdin through the shared envelope helper (subagentstop-envelope.ps1),
+    takes its last_assistant_message field (the terminating subagent's last
+    assistant message), scans that text for discovery-artifact path references
+    via Get-DiscoveryArtifactType, and for each recognized reference (when a
+    required-artifact declaration is present) invokes the discovery validator
+    via Invoke-DiscoveryValidatorExe.
@@ -16,5 +17,9 @@
-    termination: the hook writes an error with a
-    DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix and exits with a non-zero code.
-    When no reference fails validation, or when no discovery-artifact path is
-    referenced, or when the required-artifact declaration is absent
-    (fail-open), the hook allows termination.
+    termination: the hook writes the reason with a
+    DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix to stderr and exits 2 through the
+    shared envelope helper. An invalid envelope (empty, not valid JSON, not a
+    JSON object, or without a string last_assistant_message) also blocks, with
+    a "DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly" reason. The hook
+    allows termination when the last assistant message is blank, when it
+    references no discovery-artifact path, when the required-artifact
+    declaration is absent (fail-open), or when every referenced artifact
+    passes validation.
@@ -38,0 +44 @@ $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot
+try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }
@@ -184 +190 @@ function Find-DiscoveryArtifactReference {
-        if (Get-DiscoveryArtifactType -Path $trimmed) {
+        if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {
@@ -197,2 +203,2 @@ function Invoke-DiscoveryArtifactGateValidation {
-        Parses CLAUDE_HOOK_INPUT and returns an Ok/Message validation result
-        for a discovery-artifact completion gate.
+        Reads the SubagentStop envelope and returns an Ok/Message validation
+        result for a discovery-artifact completion gate.
@@ -203 +209 @@ function Invoke-DiscoveryArtifactGateValidation {
-        [string] $RawPayload,
+        [AllowNull()] [AllowEmptyString()] [string] $InputText,
@@ -209,0 +216,3 @@ function Invoke-DiscoveryArtifactGateValidation {
+    $envelope = if ($PSBoundParameters.ContainsKey('InputText')) { Read-SubagentStopEnvelope -InputText $InputText } else { Read-SubagentStopEnvelope }
+    if (-not $envelope.IsValid) { return @{ Ok = $false; Message = "DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly - $(Get-SubagentStopEnvelopeAnomalyReason -Anomaly $envelope.Anomaly)" } }
+    $assistantMessage = [string]$envelope.AssistantText
@@ -211,17 +220 @@ function Invoke-DiscoveryArtifactGateValidation {
-    if ([string]::IsNullOrWhiteSpace($RawPayload)) {
-        return @{ Ok = $false; Message = 'discovery artifact gate hook: CLAUDE_HOOK_INPUT is empty' }
-    }
-
-    try {
-        $payload = $RawPayload | ConvertFrom-Json -ErrorAction Stop
-    }
-    catch {
-        return @{ Ok = $false; Message = "discovery artifact gate hook: CLAUDE_HOOK_INPUT is not valid JSON: $_" }
-    }
-
-    $outputText = ''
-    if ($null -ne $payload -and ($payload.PSObject.Properties.Name -contains 'output')) {
-        $outputText = [string]$payload.output
-    }
-
-    $references = Find-DiscoveryArtifactReference -OutputText $outputText
+    $references = Find-DiscoveryArtifactReference -OutputText $assistantMessage
@@ -240,4 +233,4 @@ function Invoke-DiscoveryArtifactGateValidation {
-        $result = Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $reference)
-        $hasErrorOutput = -not [string]::IsNullOrWhiteSpace($result.Output)
-        if ($result.ExitCode -ne 0 -or $hasErrorOutput) {
-            return @{ Ok = $false; Message = "DISCOVERY_ARTIFACT_GATE_BLOCKED: $($result.Output)" }
+        $validatorResult = Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $reference)
+        $hasErrorOutput = -not [string]::IsNullOrWhiteSpace($validatorResult['Output'])
+        if ($validatorResult['ExitCode'] -ne 0 -or $hasErrorOutput) {
+            return @{ Ok = $false; Message = "DISCOVERY_ARTIFACT_GATE_BLOCKED: $($validatorResult['Output'])" }
@@ -258,6 +251,2 @@ if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecis
-$result = Invoke-DiscoveryArtifactGateValidation -RawPayload $env:CLAUDE_HOOK_INPUT
-if (-not $result.Ok) {
-    Write-Error $result.Message
-    exit 1
-}
-
+$result = Invoke-DiscoveryArtifactGateValidation
+if (-not $result.Ok) { Write-Error $result.Message; exit 1 }
```

## [P7-T2] Pure-function tests of validate-discovery-artifact-gate.Tests.ps1

Timestamp: 2026-10-11T23-14
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 -Absent 'RawPayload||ConvertTo-DiscoveryHookInput||CLAUDE_HOOK_INPUT is empty||Should -Be 1'
EXIT_CODE: 0
Output Summary: the scan returns no match; R-ITS prints PARSE-ERRORS: 0, each of the eleven D titles once, and `R4 skips a token that is empty after trimming | TAGS: NONE` once. `ConvertTo-DiscoveryHookInput` is replaced by `ConvertTo-DiscoveryEnvelopeJson -AssistantMessage`; every pure-function call passes `-InputText`; the contexts `empty or absent CLAUDE_HOOK_INPUT`, `malformed CLAUDE_HOOK_INPUT JSON`, and `payload with no output field` are replaced by `Context 'invalid envelope'` (two payload-anomaly tests) and `Context 'empty assistant message'` (one test); `Context 'script entrypoint (end-to-end)'` is deleted; the D1 to D11 context and the R4 context are unchanged ([P2-T9] added no probe). The edit was applied by splicing a scratchpad head file over lines 1-211 (`<SCRATCHPAD>/e905-splice.ps1`), keeping line 212 onward byte-identical. R-RESET: `P7-T2: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: RawPayload , ConvertTo-DiscoveryHookInput , CLAUDE_HOOK_INPUT is empty , Should -Be 1 | matches=0
LINES: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | 357
```

```text
FILE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
IT-TITLE: returns Ok = $true and invokes the validator exactly once | TAGS: NONE
IT-TITLE: returns Ok = $false with the validator text embedded verbatim | TAGS: NONE
IT-TITLE: returns Ok = $true without invoking the validator | TAGS: NONE
IT-TITLE: returns Ok = $true without invoking the validator when the seam reports absent | TAGS: NONE
IT-TITLE: returns Ok = $false with a payload anomaly message for empty input text | TAGS: NONE
IT-TITLE: returns Ok = $false with a payload anomaly message for malformed input text | TAGS: NONE
IT-TITLE: returns Ok = $false identically to any other non-conforming result | TAGS: NONE
IT-TITLE: contains no TaskMaster/TMW/Outlook/VSTO token in its own source text | TAGS: NONE
IT-TITLE: returns Ok = $true without invoking the validator when last_assistant_message is an empty string | TAGS: NONE
IT-TITLE: reports Present = $true with the declaration when the profile reader returns a value | TAGS: NONE
IT-TITLE: returns Ok = $true when the validator reports success with EMPTY output | TAGS: NONE
IT-TITLE: returns Ok = $false when the validator reports success but emits a success line | TAGS: NONE
IT-TITLE: returns Ok = $true when the validator reports success with whitespace-only output | TAGS: NONE
IT-TITLE: exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message references a conforming artifact | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message carries no discovery artifact reference | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 0 when the required-artifact declaration is absent | TAGS: E3-Entry
IT-TITLE: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
IT-TITLE: exits 2 in a separate process when stdin is not a JSON envelope | TAGS: E3-Entry
IT-TITLE: R4 skips a token that is empty after trimming | TAGS: NONE
PARSE-ERRORS: 0
```

## [P7-T3] validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 needs no change

Timestamp: 2026-10-11T23-14
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
EXIT_CODE: 0
Output Summary: `git diff --stat 1011d98d7830aea7e53511a972b0868b323d5a44 -- tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` printed nothing (exit 0). R-SCOPED: SUMMARY: passed=4 failed=0 skipped=0 notrun=0; CONTAINER-ERRORS: 0.

```text
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns ExitCode 1 and the module-not-found message when the shared module is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns ExitCode 0 with EMPTY Output when the shared module reports no error
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns a non-zero ExitCode and non-empty Output for an artifact that is not on disk
PASSED-TEST: tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | returns a non-zero ExitCode and non-empty Output when ValidatorArgs is incomplete
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=4 failed=0 skipped=0 notrun=0
```

## [P7-T5] Mirror R4 counts

Timestamp: 2026-10-11T23-15
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 -Simple '<R4 new line>||<R4 old line>'
EXIT_CODE: 0
Output Summary: after R-MIRROR (both hash kinds `equal`, `evidence/other/mirror-log.md` entry [P7-T5]), the mirror carries `if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {` exactly once and `if (Get-DiscoveryArtifactType -Path $trimmed) {` zero times.

```text
FILE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
PARSE-ERRORS: 0
SIMPLE-COUNT: if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) { | 1
SIMPLE-COUNT: if (Get-DiscoveryArtifactType -Path $trimmed) { | 0
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | 253
```

## [P8-T1] Blocking switch of .claude/hooks/validate-discovery-artifact-gate.ps1

Timestamp: 2026-10-11T23-16
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-discovery-artifact-gate.ps1 -Absent 'CLAUDE_HOOK_INPUT||\bexit 1\b||Write-Error' -Simple 'Exit-SubagentStopBlock -Message' -TrimLine 'exit 0'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `\bexit 1\b`, `Write-Error` returns no match; `Exit-SubagentStopBlock -Message` count is 1; the trimmed line `exit 0` matches exactly one line (253). Only the tail block line changed (`git diff --stat e2284acf4 -- .claude/hooks/validate-discovery-artifact-gate.ps1`: 1 insertion, 1 deletion). R-RESET: `P8-T1: none present`.

```text
FILE: .claude/hooks/validate-discovery-artifact-gate.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , \bexit 1\b , Write-Error | matches=0
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 1
TRIMLINE-COUNT: exit 0 | 1 | lines=253
LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | 253
```
