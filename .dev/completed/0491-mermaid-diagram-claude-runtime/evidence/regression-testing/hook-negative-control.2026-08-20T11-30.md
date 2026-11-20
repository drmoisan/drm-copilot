# Hook Negative Control: Gate Denies End to End (issue #491, [P6-T1])

Timestamp: 2026-08-20T11-30

Invocation method for every control below: a real `pwsh -NoProfile -File
.claude/hooks/enforce-mermaid-validation.ps1` subprocess, with `$env:CLAUDE_TOOL_INPUT` set in the
parent and restored afterwards. No file was written to disk: the payload carries the content, and
the hook is a read-only gate.

Exit code 0 is CORRECT on both allow and deny. The hook communicates its decision exclusively in
the JSON on stdout; a non-zero exit is never used to signal a block, and the
`{"decision":"block"}` shape is never emitted. A reader who "fixes" the exit code to non-zero would
break the protocol.

## Payload

`file_path`: `docs/diagrams/negative-control.mmd`
`content` (a flowchart declaration carrying a sequence arrow AND an unclosed bracket):

```text
flowchart TD
    A[Start --> B
    B ->> C
```

Command: `pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1`

## Observed result

STDOUT, verbatim and on a single line:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"MERMAID_VALIDATION_BLOCKED: 'docs/diagrams/negative-control.mmd' declares 'flowchart' and has a Mermaid syntax defect: InvalidArrowToken at line 3: the token '->>' is not a valid edge form for a 'flowchart' diagram. See .claude/skills/mermaid-diagram/SKILL.md."}}
```

LASTEXITCODE: 0

## Assessment

- `permissionDecision` is `deny`.
- The reason carries the `MERMAID_VALIDATION_BLOCKED:` token.
- It names the defect class (`InvalidArrowToken`), the line number (3), the declared diagram type,
  the offending token, and the corrective pointer to the skill.
- Exit code 0, as the protocol requires.

Both defects are present in the payload; the reason reports the first finding, which is the arrow on
line 3. The unclosed `[` opened on line 2 is reported by the validator as a second finding and would
surface once the arrow is corrected.

The gate is demonstrated capable of failing end to end. AC-17 end-to-end evidence.
