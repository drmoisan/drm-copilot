# P4-T3 Native Parallel Hook Adapter Evidence

- Task: `[P4-T3]`.
- Production owner: `.codex/hooks/parallel-hook-common.ps1` (220 lines).
- Reused seam: native payload/error conventions from
  `codex-pretooluse-file-mapping.ps1` and the ordered deny-envelope convention
  used by existing completion hooks.
- API: `ConvertFrom-CodexParallelHookPayload`,
  `ConvertTo-CodexParallelHookDenyEnvelope`,
  `ConvertTo-CodexParallelHookResult`,
  `Invoke-CodexParallelHookValidation`, and
  `Write-CodexParallelHookResult`.

## Verification

- PoshQC format: PASS after the required restart.
- PoshQC analyze: PASS with zero findings. The first analysis found only two
  pure-constructor `New-` verb warnings; both constructors were renamed to the
  non-mutating `ConvertTo-` verb before the clean restart.
- In-memory transport smoke: PASS.
  - allow: exit 0, stdout length 0, stderr length 0;
  - deny: exit 0, exactly one compact native `PreToolUse` deny envelope,
    stderr length 0;
  - missing stdin: exit 2, stdout length 0, stable hook-named stderr.
- The parser requires `hook_event_name`, `tool_name`, and object-valued
  `tool_input` from native stdin.
- Static purity check found no `CLAUDE_TOOL_INPUT`, `CLAUDE_SESSION_ID`, or
  filesystem mutation command.
- `git diff --check`: PASS.
