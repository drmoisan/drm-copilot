# Baseline mirror parity ([P0-T29], issue #905)

Timestamp: 2026-10-11T14-49
Command: git hash-object <source> ; git hash-object <mirror> (and Get-FileHash -Algorithm SHA256) for each of the four W-HOOKS pairs (<SCRATCHPAD>/r-hash.ps1 through R-ROUTE)
EXIT_CODE: 0
Output Summary: Four pairs, each equal under git hash-object and SHA256.

```text
PAIR: .claude/hooks/validate-discovery-artifact-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | sha256 7E4F386128988C34DBCB6B5BAEB00153B0F201D01D5F4A27B3E2529CF7554401 / 7E4F386128988C34DBCB6B5BAEB00153B0F201D01D5F4A27B3E2529CF7554401 | equal | git cfaaac856677665dd626fc1a8773227ee3007bf2 / cfaaac856677665dd626fc1a8773227ee3007bf2 | equal
PAIR: .claude/hooks/validate-pr-author-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | sha256 9391AC17538FC47D76BA73375DC35BF2933E51FAD201043CADC3197299AF5CE9 / 9391AC17538FC47D76BA73375DC35BF2933E51FAD201043CADC3197299AF5CE9 | equal | git 252109a5a2010db7e60716651faced581af86f09 / 252109a5a2010db7e60716651faced581af86f09 | equal
PAIR: .claude/hooks/validate-prd-feature-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | sha256 1CE666427FB53F20E72DE967EF7A7291465E728719C4B2457166474F02906AC0 / 1CE666427FB53F20E72DE967EF7A7291465E728719C4B2457166474F02906AC0 | equal | git 1cec366d63ced574b2e60e9ee9fd1f5462628ad1 / 1cec366d63ced574b2e60e9ee9fd1f5462628ad1 | equal
PAIR: .claude/hooks/validate-task-researcher-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | sha256 29201D9E5A82F2B606A2F4D6761986BC82065AEA0E67BFCB087178AB3E9F1745 / 29201D9E5A82F2B606A2F4D6761986BC82065AEA0E67BFCB087178AB3E9F1745 | equal | git 7ab10fb29cffe4d8ed47a52b9e9c91963f37c816 / 7ab10fb29cffe4d8ed47a52b9e9c91963f37c816 | equal
```
