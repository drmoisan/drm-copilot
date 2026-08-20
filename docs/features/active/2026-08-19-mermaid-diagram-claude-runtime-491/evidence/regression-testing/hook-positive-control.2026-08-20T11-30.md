# Hook Positive Control: Gate Allows a Valid Diagram (issue #491, [P6-T2])

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

`file_path`: `docs/diagrams/positive-control.mmd`
`content`:

```text
flowchart TD
    A[Start] --> B{Choice}
    B -->|yes| C(Done)
```

Command: `pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1`

## Observed result

STDOUT, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

LASTEXITCODE: 0

## Assessment

`permissionDecision` is `allow` in the explicit-allow envelope, with no reason field, and the exit
code is 0. Paired with [P6-T1], this shows the gate discriminates rather than denying everything:
the same hook, the same invocation method, and the same diagram type produce deny for the defective
content and allow for the valid content.
