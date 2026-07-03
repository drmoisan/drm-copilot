# Agent Frontmatter Smoke Check — model: haiku / model: sonnet

Timestamp: 2026-07-03T16-43

## Objective

Confirm the two new agent files do not carry frontmatter that the runtime would reject, with
specific attention to the `model: haiku` (new to the corpus) and `model: sonnet` (precedented)
values, per the spec Risk (frontmatter acceptance).

## Checks Performed and Results

1. YAML frontmatter parse: both `.claude/agents/commit-message.md` and
   `.claude/agents/human-exception-runbook.md` parse cleanly with `yaml.safe_load`.
   - `commit-message.md`: keys = [description, memory, model, name, skills, tools]; `model: haiku`;
     `skills: ['commit-message']`; `memory: project`. schema_ok: True.
   - `human-exception-runbook.md`: keys = [description, memory, model, name, skills, tools];
     `model: sonnet`; `skills: ['human-exception-runbook']`; `memory: project`. schema_ok: True.
   - Both match the observed agent frontmatter schema (dedicated `skills:` list, following the
     `pr-author.md` pattern, not the `task-researcher.md` anomaly).
   - EXIT_CODE: 0.

2. Model-value constraint search: repo-wide search of `extensions/drm-copilot/src` for any allowlist
   or enum constraining agent `model:` frontmatter values. Result: no mechanism found that
   enumerates or rejects `model:` values. The only `model`-related hit is the word "models" in the
   codex-native-converter module (unrelated to a model-tier allowlist).

3. Precedent: `model: sonnet` already appears in `.claude/agents/pr-author.md` and
   `.claude/agents/task-researcher.md`, so `sonnet` is confirmed-accepted by prior use. `model: haiku`
   is new to the agent corpus but is structurally identical (a plain YAML string under the same
   `model:` key).

## Determination

- Frontmatter is well-formed and schema-conformant for both files.
- No repository mechanism (validation hook, schema, or extension code) rejects `model: haiku` or
  `model: sonnet`.
- Live agent-registry hot-reload acceptance is not directly observable in this non-interactive
  execution session; the strongest available static verification was performed and found no
  rejection condition.

Result: ACCEPTED (static verification). No rejection error was produced or is producible by any repo
mechanism. This is not a blocking finding. If a future interactive load surfaces a rejection of the
`haiku` value, that would be recorded then; no such rejection is present in the repository text or
tooling now.
