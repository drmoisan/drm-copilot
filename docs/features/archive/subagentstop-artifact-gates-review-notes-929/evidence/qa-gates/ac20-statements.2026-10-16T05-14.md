# AC-20 Leading Statements and R3 Pattern (P9-T9)

Timestamp: 2026-10-16T05-14

Command: sh SCRATCH/929/P9-T9-1.sh
Script: `Select-String -Path .claude/hooks/validate-task-researcher-output.ps1 -SimpleMatch -Pattern 'function Invoke-TaskResearcherOutputValidation','$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix','if ($null -ne $dependencyDecision) { return $dependencyDecision }' | ForEach-Object { '{0} | {1}' -f $_.LineNumber, $_.Pattern }; 'R3_PATTERN_COUNT=' + @(Select-String -Path .claude/hooks/validate-prd-feature-output.ps1,.claude/hooks/validate-task-researcher-output.ps1 -SimpleMatch -Pattern '(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b').Count`
EXIT_CODE: 0
Output:
```
233 | function Invoke-TaskResearcherOutputValidation
239 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix
240 | if ($null -ne $dependencyDecision) { return $dependencyDecision }
285 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix
R3_PATTERN_COUNT=2
```

Output Summary: The function is at line 233, the dependency-decision assignment at 239, and the `if` return at 240, the two lines after its `param(...)` block (lines 236-238). The one further assignment match is the script-tail line 285, after the function's closing brace at line 279 (column-1 `}` found at line 279 by a line search), as expected. No P7-T2 or P8-T17 merge changed the file, so the fixed numbers apply. `R3_PATTERN_COUNT=2`: the R3 regular-expression literal is unchanged in both validators (AC-04, AC-20).
