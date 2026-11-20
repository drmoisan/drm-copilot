# P9-T7 Retired PowerShell validator compatibility contract

Timestamp: 2026-10-22T18-11
Task: [P9-T7] Retire independent PowerShell artifact semantics and preserve hook contracts.
Result: PASS

## Module delivered

- `.claude/lib/discovery-validation/DiscoveryValidation.psm1` (rewritten, 347 lines, mirrored byte-identically into the Claude bundle): the artifact-selected schema and profile parsing, the `$schema` resolution and every `Test-Json -SchemaFile` evaluation are removed. The ten previous export names are retained and two are added (`Get-DiscoveryValidationRequiredMessage`, `Get-DiscoveryValidationAuthority`).
- Retained as contract: the seven-entry artifact-type table (`Get-DiscoverySchemaArtifactType`, `Get-DiscoverySchemaFileName`, `Resolve-DiscoverySchemaFilePath` as documentation lookups) and the PowerShell 7.4 destination floor (`Get-DiscoveryRuntimeVersionError`, same message elements: required version, `Test-Json -SchemaFile` Draft 2020-12 reason, issue #475, host version).
- Replaced semantics: `Get-DiscoveryProfileTopLevelKey` reports no key; `Get-DiscoveryProfileValidationError`, `Get-DiscoverySchemaArtifactValidationError` and `Get-DiscoveryArtifactValidationError` return the floor error below 7.4 and otherwise a never-empty list ending in `DISCOVERY_VALIDATION_REQUIRED: ... validated only by the installed discovery service (validate_discovery_artifacts) ...`, with an unrecognized artifact type reported first; `Invoke-DiscoveryArtifactValidation` keeps the `@(<type>, <path>)` argument shape and the `@{ ExitCode; Output }` result and always returns `ExitCode = 1` (floor, then argument count, then `Artifact not found: <path>`, then the validation-required message); it tests the path through an injectable `[scriptblock]` seam and never reads artifact bytes.
- `Get-DiscoveryValidationAuthority` reports the protected activation of a workspace (`active`, `missing`, `inactive`, `invalid`) or `unsupported-host` when the trusted authority location cannot be resolved, through `DiscoveryAuthority`'s `Resolve-DiscoveryAuthorityLocation` and `Read-DiscoveryActivationState` with the injectable `ReadText` seam; every message is actionable and names the service.
- No Python interpreter, external process or artifact read exists in the module; its only imports are the sibling `DiscoveryEncoding` and `DiscoveryAuthority` modules with `-ErrorAction Stop`.

## Proof

- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (rewritten, 159 lines): the artifact-type table and committed schema files; exactly twelve exports; no profile key for a two-key profile; the validation-required result for a conforming, malformed and empty document through the schema and dispatch entries with `ExitCode = 1`; the unrecognized-type ordering; the D-2 result shape for caller-assembled lists; `Invoke-DiscoveryArtifactValidation` with an existing conforming artifact (exit 1, message names type and path, keys `ExitCode` and `Output` only), a missing path, one and zero arguments, the floor first on 7.3, and a probe seam proving the path is only tested while the module source carries no `Test-Json` invocation shape, `Get-Content`, `ReadAllText`, `ReadAllBytes`, `ConvertFrom-Json`, `ConvertFrom-Yaml`, `python` or `poetry` token; `Get-DiscoveryValidationAuthority` for an active, missing, deactivated and unreadable activation through the in-memory `Get-GateStore` and for a Windows host without `LocalAppData`.
- `DiscoveryValidation.VersionFloor.Tests.ps1`: floor boundary, message elements and fail-closed entry rows unchanged; the no-silent-degradation test now asserts that the supported host receives the validation-required message with `ExitCode = 1` and the unsupported host the floor message with `ExitCode = 1`, so neither host ever receives a pass from this module.
- `DiscoveryValidation.Manifest.Tests.ps1` (P9-T1, unchanged): byte-identical Claude-bundle mirror and manifest assertions rerun green after the mirror publish.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (500 lines): new context `retired discovery validator (issue #980)` asserts the compatibility module path is under a scan root, is enumerated by the guarded-file scan, and yields zero findings from `Get-PythonInvocationFinding` (direct and dynamic invocation classes), in addition to the repository-wide residual scan.
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`: new `S9` walks `Get-HookDependencyClosure` for every registered Claude and Codex hook on the repository and both bundle mirror roots and asserts no closure edge has leaf `DiscoveryValidation.psm1`, so no hook loads the retired validator directly or transitively and the old entry names cannot mint a passing gate; S1 to S8 pass unchanged for every registered hook.

## Gates

- PoshQC format clean (no file rewritten), analyze clean, PSScriptAnalyzer launcher zero findings on the five changed files; MCP Pester 1147/0 over discovery-validation and claude-runtime; launcher 34/34 Set J, 718/718 Set J plus manifest plus claude-runtime, 680/680 claude-runtime; Python 23 passed in the two suites that name the module. Changed files: module 347, Set J suite 159, VersionFloor 167, no-python suite 500, guard-completeness 252 lines; none exceeds 500.

## Carried notes

- `DiscoveryValidation.psm1` is imported by no hook since P9-T4; the compatibility surface exists for out-of-tree callers of the former entry names and for the bundle manifest, and it fails closed for all of them.
- The `DiscoveryGate.TestSupport.ps1` fixture is reused unchanged by the rewritten Set J suite.
- The pre-existing P7-T4 `CodexDiscoveryRouting.psm1` convention defect remains recorded for the P11 closing review; it is outside the folders this task runs.
