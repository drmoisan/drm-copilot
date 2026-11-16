# Gold Standard: translate-copilot-to-claude

## Objective

Translate GitHub Copilot native files, including instructions, agents, prompts, and skills, into the native Claude runtime. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: One or more source paths under `.github/`.
- **OB-2** Phase 1 — Intake and Section Extraction: Read the full file with `Read`.
- **OB-3** Phase 2 — Classification Taxonomy: Each section is classified by the first matching decision rule, applied in order: enforceable, declarative standard, reusable procedure, identity and preload manifest, handoff and delegation, repository-wide tone or policy precedence, and out-of-scope content.
- **OB-4** Phase 3 — Target Resolution: Rule: `.agents/skills/<topic>.md` where topic is the language (`python.md`, `csharp.md`, `powershell.md`, `typescript.md`) or cross-cutting concern (`tonality.md`, `general-code-change.md`, `general-unit-test.md`).
- **OB-5** Phase 4 — Existing State Diff: `Read` the existing file when it exists.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Phase 1 — Intake and Section Extraction, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Phase 2 — Classification Taxonomy, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Phase 3 — Target Resolution, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Phase 4 — Existing State Diff, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
