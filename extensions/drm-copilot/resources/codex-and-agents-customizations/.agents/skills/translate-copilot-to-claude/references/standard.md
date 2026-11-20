# Gold Standard: translate-copilot-to-claude

## Objective

Translate GitHub Copilot native files, including instructions, agents, prompts, and skills, into the native Claude runtime. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill requires one or more source paths under `.github/` and accepts the optional `mode=plan-only` (the default, which writes nothing and emits the translation plan), `mode=apply` (which applies the plan after it is produced and approved in the same turn), `target-scope=<agent|rule|skill|hook|all>` and `timestamp-override=<ISO-8601>` inputs, and applying requires explicit confirmation.
- **OB-2** Phase 1 — Intake and Section Extraction: For each input file the skill reads the full source file, parses its YAML frontmatter (name, description, tools, applyTo, agent, handoffs, model and other keys), splits the body into top-level sections at `#`, `##` and `###` headings, classifies each section as declarative, procedural, enforceable, identity or handoff by the Phase 2 taxonomy, and records each section as `{source_path, heading, classification, raw_content}` in an in-memory list, never modifying or deleting a source file because translation copies forward.
- **OB-3** Phase 2 — Classification Taxonomy: Each section is classified by the first matching decision rule, applied in order: enforceable, declarative standard, reusable procedure, identity and preload manifest, handoff and delegation, repository-wide tone or policy precedence, and out-of-scope content.
- **OB-4** Phase 3 — Target Resolution: For each classified section the skill computes a concrete target path of one of six kinds, a hook script with a verb-noun name whose verb is `check`, `enforce` or `validate`, a rule file named for its language or cross-cutting topic, a skill folder with a kebab-case name (verb-first for action skills and a topic name for contract skills), an agent persona with a kebab-case name, the single repository-wide standing-instruction file at the workspace root, or the hooks and permissions sections of the runtime settings file, and it records the target paths in the plan without writing anything yet.
- **OB-5** Phase 4 — Existing State Diff: For every target path the skill reads the existing target file when it exists and computes a per-section delta of add, replace, merge, skip or conflict, computes add-only updates to the hook arrays and allowed permissions of the runtime configuration file without removing an existing permission unless explicitly instructed, prefers merge over replace for agent personas already present, and flags every conflict row in the plan so that the row stops in Phase 6 until it is resolved.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Phase 1 — Intake and Section Extraction, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Phase 2 — Classification Taxonomy, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Phase 3 — Target Resolution, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Phase 4 — Existing State Diff, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
