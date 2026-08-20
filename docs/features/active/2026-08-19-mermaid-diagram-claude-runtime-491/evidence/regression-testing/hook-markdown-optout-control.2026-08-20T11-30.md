# Hook Markdown and Opt-Out Controls (issue #491, [P6-T3])

Timestamp: 2026-08-20T11-30

Invocation method for every control below: a real `pwsh -NoProfile -File
.claude/hooks/enforce-mermaid-validation.ps1` subprocess, with `$env:CLAUDE_TOOL_INPUT` set in the
parent and restored afterwards. No file was written to disk: the payload carries the content, and
the hook is a read-only gate.

Exit code 0 is CORRECT on both allow and deny. The hook communicates its decision exclusively in
the JSON on stdout; a non-zero exit is never used to signal a block, and the
`{"decision":"block"}` shape is never emitted. A reader who "fixes" the exit code to non-zero would
break the protocol.

Both controls use the SAME `file_path` (`docs/notes-control.md`) and the SAME invalid diagram body.
The only difference between them is the opt-out marker line, which isolates the marker as the cause
of the change in outcome.

## (a) Markdown Write with an invalid mermaid fence — expect deny

`content`:

````text
# Notes

```mermaid
flowchart TD
    A[Start --> B
    B ->> C
```
````

STDOUT, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"MERMAID_VALIDATION_BLOCKED: 'docs/notes-control.md' (the mermaid fence opening at line 3) declares 'flowchart' and has a Mermaid syntax defect: InvalidArrowToken at line 6: the token '->>' is not a valid edge form for a 'flowchart' diagram. See .claude/skills/mermaid-diagram/SKILL.md."}}
```

LASTEXITCODE: 0

The reason locates the defect twice over: the fence opens at file line 3, and the offending arrow is
at file line 6. The line number is file-relative, not block-relative, because the hook passes the
block's body start line as the validator's line offset. This is the D2 detection surface working:
the diagram lives in Markdown, not in a `.mmd` file.

## (b) The same Write with the opt-out marker immediately above the fence — expect allow

`content`:

````text
# Notes

<!-- mermaid-validator: ignore -->
```mermaid
flowchart TD
    A[Start --> B
    B ->> C
```
````

STDOUT, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

LASTEXITCODE: 0

## Assessment

Deny then allow, both with exit code 0. The D3 marker suppressed validation for exactly the block it
precedes, and nothing else about the payload changed. Live evidence for D2 and D3.
