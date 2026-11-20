# subagent-tree-command

- Work Mode: minor-audit
- Issue: [#320](https://github.com/drmoisan/drm-copilot/issues/320)

## Problem / Why

The `drm-copilot` VS Code extension has no way to inspect the subagent call tree of a
Claude Code session. Transcripts on disk (`.claude/projects/**`) record a root session
plus flattened subagent transcripts with meta files that encode a deterministic
parent→child spawn relationship. A command that renders this tree helps operators
understand delegation structure and detect mid-session model switches.

## Implementation Intent

Add a VS Code command `drmCopilotExtension.showSubagentTree` ("drm-copilot: Show
Subagent Tree"). Given a root session (user-picked `.jsonl` under `.claude/projects/**`
or the active session), build and display the subagent tree.

Design for testability per `.claude/rules/general-unit-test.md`:

- A pure, host-neutral module exposing `buildSubagentTree(rootSessionPath): TreeNode`
  and `formatTree(node): string`, with full unit tests.
- A thin host-bound command file that only does VS Code wiring (session pick, output
  channel). Uncovered host lines kept minimal; no production file excluded from coverage.

Data contract (verified transcript facts):

- Root session: `.claude/projects/<project-dir>/<session-id>.jsonl` — one JSON object per line.
- Subagent transcripts (all descendants, flattened):
  `.claude/projects/<project-dir>/<session-id>/subagents/agent-<agentId>.jsonl`,
  each with a sibling `agent-<agentId>.meta.json`.
- `meta.json` fields: `agentType`, `description`, `toolUseId` (spawning call id),
  `spawnDepth`, optional `worktreePath` / `worktreeBranch`.
- Per-turn model is `message.model` in each `.jsonl`.

Deterministic tree algorithm (port exactly):

1. Scan the root `.jsonl` and every `subagents/*.jsonl`. For each transcript collect
   (a) the set of `message.model` values, and (b) the ordered list of `Agent`
   tool-use `id`s (assistant `message.content[]` blocks where `type=="tool_use"` and
   `name=="Agent"`), preserving file line order.
2. For each child, read its `meta.json`; map `meta.toolUseId → agentId`.
3. Parent→child edge: a child whose `meta.toolUseId` equals an `Agent` tool-use `id`
   found in transcript X is a child of X (exact 1:1 match; no timestamps/heuristics).
4. Order siblings by the line order of their spawning tool-use in the parent transcript.
5. Render each node as `agentType · [sorted,comma-joined models] · depth · description`.
   A node with more than one distinct model prints all of them.

## Acceptance Criteria

- [x] AC1: Command `drmCopilotExtension.showSubagentTree` ("drm-copilot: Show Subagent Tree")
  is registered in `extensions/drm-copilot/package.json` under `contributes.commands`
  and wired/activated in the extension; invoking it renders the tree for a
  selected/active session.
- [x] AC2: Pure builder `buildSubagentTree` and renderer `formatTree` are implemented in
  a host-neutral module with no VS Code imports.
- [x] AC3: Unit tests cover positive, empty-subagents, multi-model node, multi-depth
  nesting, and orphan/unmatched `toolUseId` handled gracefully.
- [x] AC4: Full TypeScript toolchain passes for the extension: format → lint → type-check
  → arch tests → unit tests; coverage >= 85% line and >= 75% branch for the new
  production files; no production file excluded from coverage.
- [x] AC5: Local feature-review (policy-audit, code-review, feature-audit) is clean of
  blocking findings.

## Dependencies / Risks

- No new dependencies without approval. `fast-check` is not installed in the extension;
  the module is dev-tooling (T3/T4), so property tests are not required by tier rules —
  standard Jest unit tests satisfy the coverage gate.
- The extension's actual test toolchain is Jest (v8 coverage), not Vitest; follow the
  extension's established pattern and add per-file coverage thresholds in
  `jest.config.cjs` for the new production files.
- Files under 500 lines each.

## Verification Steps

- Run the extension toolchain from `extensions/drm-copilot/`:
  `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`.
- Confirm command registration and activation.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
