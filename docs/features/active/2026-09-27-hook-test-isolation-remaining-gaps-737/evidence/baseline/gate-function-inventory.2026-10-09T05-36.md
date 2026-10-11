# P7-T1 Gate function inventory

Timestamp: 2026-10-09T05-36
Command: Route C: Parser::ParseFile over both canonical preimplementation gates; list FunctionDefinitionAst names via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
PARSE-ERRORS: claude | 0
GATE-FUNCTIONS: claude | ConvertFrom-CheckpointJson
GATE-FUNCTIONS: claude | Get-OrchestrationPreimplementationGateAllowDecision
GATE-FUNCTIONS: claude | Get-OrchestrationPreimplementationGateBlockDecision
GATE-FUNCTIONS: claude | Get-StringProperty
GATE-FUNCTIONS: claude | Invoke-OrchestrationPreimplementationGateDecision
GATE-FUNCTIONS: claude | Invoke-OrchestrationPreimplementationGateEntryPoint
GATE-FUNCTIONS: claude | Test-FeatureDocumentationOrEvidencePath
GATE-FUNCTIONS: claude | Test-ImplementationCommand
GATE-FUNCTIONS: claude | Test-ImplementationDelegation
GATE-FUNCTIONS: claude | Test-ImplementationPath
GATE-FUNCTIONS: claude | Test-OrchestrationReady
GATE-FUNCTIONS: claude | Test-PreparationModeDelegation
PARSE-ERRORS: codex | 0
GATE-FUNCTIONS: codex | ConvertFrom-CheckpointJson
GATE-FUNCTIONS: codex | Get-CheckpointContent
GATE-FUNCTIONS: codex | Get-OrchestrationModeDenyReason
GATE-FUNCTIONS: codex | Get-OrchestrationPreimplementationGateAllowDecision
GATE-FUNCTIONS: codex | Get-OrchestrationPreimplementationGateBlockDecision
GATE-FUNCTIONS: codex | Get-StringProperty
GATE-FUNCTIONS: codex | Invoke-OrchestrationPreimplementationGateDecision
GATE-FUNCTIONS: codex | Test-FeatureDocumentationOrEvidencePath
GATE-FUNCTIONS: codex | Test-ImplementationCommand
GATE-FUNCTIONS: codex | Test-ImplementationDelegation
GATE-FUNCTIONS: codex | Test-ImplementationPath
GATE-FUNCTIONS: codex | Test-OrchestrationReady
GATE-FUNCTIONS: codex | Test-PreparationModeDelegation
SHARED: ConvertFrom-CheckpointJson
SHARED: Get-OrchestrationPreimplementationGateAllowDecision
SHARED: Get-OrchestrationPreimplementationGateBlockDecision
SHARED: Get-StringProperty
SHARED: Invoke-OrchestrationPreimplementationGateDecision
SHARED: Test-FeatureDocumentationOrEvidencePath
SHARED: Test-ImplementationCommand
SHARED: Test-ImplementationDelegation
SHARED: Test-ImplementationPath
SHARED: Test-OrchestrationReady
SHARED: Test-PreparationModeDelegation
CLAUDE-ONLY: Invoke-OrchestrationPreimplementationGateEntryPoint
CODEX-ONLY: Get-CheckpointContent
CODEX-ONLY: Get-OrchestrationModeDenyReason
COUNTS: shared=11 claude-only=1 codex-only=2
