# Final QA — PowerShell Format (P7-T1)

Timestamp: 2026-09-27T15-43

Iteration: 1

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/file-hashes.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 Hash=B6BAF530C492DB1489EB729AD1CCCE5559EDB94D179188BFBE5F8D4B5A061AD5
```

Command: MCP mcp__drm-copilot__run_poshqc_format, workspace_root `<worktree root>`, scan_folders ["tests/scripts/claude-lib/blast-radius"]

EXIT_CODE: 0

Output: {"ok":true,"tool":"run_poshqc_format","workspace_root":"`<worktree root>`","summary":"Ran bundled PoshQC format against '`<worktree root>`' with 1 selected scan folder(s)."}

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/file-hashes.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 Hash=B6BAF530C492DB1489EB729AD1CCCE5559EDB94D179188BFBE5F8D4B5A061AD5
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/poshqc-format.ps1 -ScanFolder tests/scripts/claude-lib/blast-radius

EXIT_CODE: 0

Output: 15 lines of the form "Already formatted: `<worktree root>`\tests\scripts\claude-lib\blast-radius\<file>" (one per file in the folder, including BlastRadius.Regression452.Tests.ps1), followed by:

```
SELF_HOSTED_FORMAT_DONE=True
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/file-hashes.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

```
tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 Hash=B6BAF530C492DB1489EB729AD1CCCE5559EDB94D179188BFBE5F8D4B5A061AD5
```

## Porcelain handling (Loop Re-entry and Recovery item 3)

- Step (a): all three hashes are identical; no formatter change; no commit.
- Step (b): fresh capture.

Command: git status --porcelain -- tests/scripts/claude-lib/blast-radius

EXIT_CODE: 0

Output: (empty)

- Step (c): the capture does not list the Pester consumer; not applicable.
- Step (d): the capture lists no other entry; no restore performed; no pre-existing drift.
- Step (e) and (f): not applicable; the acceptance is evaluated on this iteration.

## Acceptance evaluation

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| MCP call disposition | returns (EXIT_CODE 0) | returned, ok true | pass |
| Three hashes | identical | identical (B6BAF530...061AD5) | pass |
| Self-hosted helper marker | SELF_HOSTED_FORMAT_DONE=True | printed | pass |
| Fresh porcelain capture after item 3 handling | empty | empty | pass |

Output Summary: PASS (iteration 1). Both the MCP formatter and the repository formatter left the Pester consumer unchanged (three identical SHA256 hashes); the self-hosted formatter reported every file in the folder as already formatted; the porcelain capture of the folder is empty. No commit or restore was needed.
