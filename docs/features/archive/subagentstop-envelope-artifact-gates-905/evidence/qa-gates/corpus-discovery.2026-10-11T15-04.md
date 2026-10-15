# Corpus run: validate-discovery-artifact-gate.ps1 (AC-09, issue #905)

Timestamp: 2026-10-11T15-04
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/corpus-discovery.ps1 -Mode Before -Sha 2ef8d361e978ca8b7733a545d76a87e8418005ce
EXIT_CODE: 0
Output Summary: Before (unchanged hook): SOURCE-COUNT 17; 18 decisions (17 source files plus SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py); 6 ALLOW, 12 BLOCK; every BLOCK reason is "EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string." raised at .claude/hooks/validate-discovery-artifact-gate.ps1:184 (RS-21; expected, does not halt). BLOCKS 12, FALSE-POSITIVES 12. The stderr error records printed by the TOKEN loop for the same binding error are part of the printed output and are kept below (ANSI color codes removed).
CORPUS-COMMIT: 2ef8d361e978ca8b7733a545d76a87e8418005ce
ENUMERATION: git grep -l -I -E 'discovery/(profile|feature-contract|coverage-ledger|runtime-scenario|parity-matrix|unspecified-behavior|product-decision|evidence-reference)' <CORPUS-COMMIT>

Script SHA256 values (recorded by [P1-T1], `evidence/other/corpus-scripts.2026-10-11T15-01.md`):

- corpus-common.ps1: CF5B7CC93584EAEE664DA88F37CF3A2B5A6AFCBFB596C8D122D96DCC11D523F8
- corpus-discovery.ps1: 87CB739E16A64977256673AE27EDD6287132E65DFBCA8B03C63421338257711E

## Before

```text
MODE: Before
CORPUS-COMMIT: 2ef8d361e978ca8b7733a545d76a87e8418005ce
ENUMERATION: git grep -l -I -E 'discovery/(profile|feature-contract|coverage-ledger|runtime-scenario|parity-matrix|unspecified-behavior|product-decision|evidence-reference)' <CORPUS-COMMIT>
SOURCE-COUNT: 17
SOURCE: .claude/hooks/enforce-discovery-artifact-gate.ps1
SOURCE: .claude/hooks/validate-discovery-artifact-gate.ps1
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/code-review.2026-07-18T10-49.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/policy-audit.2026-07-18T10-49.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md
SOURCE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1
SOURCE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
SOURCE: extensions/drm-copilot/test/mcp-server.discovery.test.ts
SOURCE: extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts
SOURCE: extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts
SOURCE: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
SOURCE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
BLOCK: .claude/hooks/enforce-discovery-artifact-gate.ps1 | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
BLOCK: .claude/hooks/validate-discovery-artifact-gate.ps1 | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/code-review.2026-07-18T10-49.md | scripts/dev_tools/discovery/profile_cli.py | profile
BLOCK: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/code-review.2026-07-18T10-49.md | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md | scripts/dev_tools/discovery/profile_cli.py`: | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md | scripts/dev_tools/discovery/profile_cli.py | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md | scripts/dev_tools/discovery/profile_cli.py | profile
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md | scripts/dev_tools/discovery/profile_cli.py`. | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/policy-audit.2026-07-18T10-49.md | discovery/profile_cli.py | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/policy-audit.2026-07-18T10-49.md
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md | scripts/dev_tools/discovery/profile_cli.py | profile
BLOCK: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md | discovery/coverage-ledger.json | coverage-ledger
BLOCK: docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md | discovery/parity-matrix.yaml | parity-matrix
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
BLOCK: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
BLOCK: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: extensions/drm-copilot/test/mcp-server.discovery.test.ts | discovery/parity-matrix.yaml | parity-matrix
BLOCK: extensions/drm-copilot/test/mcp-server.discovery.test.ts | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts | discovery/profile.yaml | profile
BLOCK: extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts | discovery/profile.yaml | profile
BLOCK: extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | discovery/coverage-ledger/coverage-ledger.json | coverage-ledger
BLOCK: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
Get-DiscoveryArtifactType: <WORKSPACE_ROOT>\.claude\hooks\validate-discovery-artifact-gate.ps1:184:45
Line |
 184 |          if (Get-DiscoveryArtifactType -Path $trimmed) {
     |                                              ~~~~~~~~
     | Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | discovery/coverage-ledger/coverage-ledger.json | coverage-ledger
BLOCK: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | EXCEPTION: Cannot bind argument to parameter 'Path' because it is an empty string.
TOKEN: SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py | scripts/dev_tools/discovery/profile_cli.py | profile
ALLOW: SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py
BLOCKS: 12
FALSE-POSITIVES: 12
```

BEFORE-FALSE-POSITIVES: 12

## After

Timestamp: 2026-10-11T23-16
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/corpus-discovery.ps1 -Mode After -Sha 2ef8d361e978ca8b7733a545d76a87e8418005ce
EXIT_CODE: 0
Output Summary: After (converted validator with R4, envelope input through `-InputText`, agent_type general-purpose): SOURCE-COUNT 17 and the 17 SOURCE lines are byte-identical to the [P1-T4] Before lines (`cmp` exit 0); one ALLOW line per source plus one for `SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py`; BLOCKS 0; FALSE-POSITIVES 0; no BLOCK line, so no reason begins `EXCEPTION:` (the 12 Before `EXCEPTION:` blocks are removed by R4). Scripts unchanged since [P1-T1] (sha256 re-verified). `origin/main` re-fetched before the run: tip 2ef8d361e978ca8b7733a545d76a87e8418005ce, equal to CORPUS_SHA.

```text
MODE: After
CORPUS-COMMIT: 2ef8d361e978ca8b7733a545d76a87e8418005ce
ENUMERATION: git grep -l -I -E 'discovery/(profile|feature-contract|coverage-ledger|runtime-scenario|parity-matrix|unspecified-behavior|product-decision|evidence-reference)' <CORPUS-COMMIT>
SOURCE-COUNT: 17
SOURCE: .claude/hooks/enforce-discovery-artifact-gate.ps1
SOURCE: .claude/hooks/validate-discovery-artifact-gate.ps1
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/code-review.2026-07-18T10-49.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/policy-audit.2026-07-18T10-49.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md
SOURCE: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md
SOURCE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1
SOURCE: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
SOURCE: extensions/drm-copilot/test/mcp-server.discovery.test.ts
SOURCE: extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts
SOURCE: extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts
SOURCE: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
SOURCE: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: .claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
ALLOW: .claude/hooks/enforce-discovery-artifact-gate.ps1
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: .claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
ALLOW: .claude/hooks/validate-discovery-artifact-gate.ps1
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/code-review.2026-07-18T10-49.md | scripts/dev_tools/discovery/profile_cli.py | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/code-review.2026-07-18T10-49.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md | scripts/dev_tools/discovery/profile_cli.py`: | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md | scripts/dev_tools/discovery/profile_cli.py | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md | scripts/dev_tools/discovery/profile_cli.py | profile
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md | scripts/dev_tools/discovery/profile_cli.py`. | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/policy-audit.2026-07-18T10-49.md | discovery/profile_cli.py | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/policy-audit.2026-07-18T10-49.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md | scripts/dev_tools/discovery/profile_cli.py | profile
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md | discovery/coverage-ledger.json | coverage-ledger
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md
TOKEN: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md | discovery/parity-matrix.yaml | parity-matrix
ALLOW: docs/features/completed/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
ALLOW: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/profile | profile
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/feature-contract | feature-contract
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/coverage-ledger | coverage-ledger
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/runtime-scenario | runtime-scenario
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/parity-matrix | parity-matrix
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/unspecified-behavior | unspecified-behavior
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/product-decision | product-decision
TOKEN: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | discovery/evidence-reference | evidence-reference
ALLOW: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
TOKEN: extensions/drm-copilot/test/mcp-server.discovery.test.ts | discovery/parity-matrix.yaml | parity-matrix
ALLOW: extensions/drm-copilot/test/mcp-server.discovery.test.ts
TOKEN: extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts | discovery/profile.yaml | profile
ALLOW: extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts
TOKEN: extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts | discovery/profile.yaml | profile
ALLOW: extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts
TOKEN: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | discovery/coverage-ledger/coverage-ledger.json | coverage-ledger
ALLOW: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
TOKEN: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | discovery/coverage-ledger/coverage-ledger.json | coverage-ledger
ALLOW: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
TOKEN: SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py | scripts/dev_tools/discovery/profile_cli.py | profile
ALLOW: SYNTHETIC: scripts/dev_tools/discovery/profile_cli.py
BLOCKS: 0
FALSE-POSITIVES: 0
```

AFTER-FALSE-POSITIVES: 0
