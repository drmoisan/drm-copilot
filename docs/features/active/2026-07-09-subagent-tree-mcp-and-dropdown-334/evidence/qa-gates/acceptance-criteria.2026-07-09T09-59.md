# Acceptance Criteria Mapping — Issue #334

Timestamp: 2026-07-09T09-59
Work Mode: full-feature -> AC sources are spec.md AND user-story.md (both tracked).

Spec AC numbering below follows the 13 bullets under spec.md `## Acceptance Criteria`.
The user-story.md `## Acceptance Criteria` (8 bullets) maps onto the same evidence.

## Part 1 — Quick-pick dropdown (spec AC 1-3)

- AC1 (label format: timestamp-first `yyyy-MM-dd HH:mm` UTC + right-anchored path <=60 whose tail equals
  the real path tail; detail = full path): PASS.
  Tests: quick-pick-labels.test.ts — "renders a known epoch as an exact yyyy-MM-dd HH:mm UTC string",
  "left-truncates with an ellipsis ... preserving the tail", "composes the label with the timestamp
  first, then the truncated tail", "sets detail equal to the full absolute path even when the label is
  truncated". Evidence: phase1-ts-loop.
- AC2 (ordering desc; unreadable mtime last as `unknown`; equal timestamps by path asc; stat failure
  does not break prompt): PASS.
  Tests: quick-pick-labels.test.ts — "orders entries most-recent-first", "sorts candidates with an
  undefined mtime last", "breaks equal-timestamp ties by path ascending", "breaks ties between two
  unreadable-mtime candidates by path ascending"; subagent-tree-command.test.ts — "keeps the prompt
  working when one candidate's mtime is unreadable, sorting it last as 'unknown'".
- AC3 (selecting renders the same tree; single candidate bypasses prompt; stat failure tolerated): PASS.
  Tests: subagent-tree-command.test.ts — "maps the selected quick-pick entry back to its full transcript
  path", "auto-selects a single candidate without prompting even when a FileTimes is injected",
  "shows quick-pick entries ordered most-recent-first with formatted timestamp labels and matchOnDetail",
  plus the pre-existing tree-render assertions (unchanged buildSubagentTree/formatTree output).

## Part 2 — MCP (spec AC 4-6)

- AC4 (advertises render_subagent_tree, required session_id, optional workspace_root,
  additionalProperties:false; valid id -> ok:true, rendered_tree == formatTree(buildSubagentTree(...)),
  summary names id + transcript path): PASS.
  Tests: repo-automation-render-subagent-tree.test.ts — "returns ok:true with rendered_tree and a summary
  naming the session id and transcript path for a valid id", "listRepoAutomationTools advertisement ...";
  mcp-repo-automation-tool-definitions.test.ts — "includes a render_subagent_tree definition with required
  session_id and optional workspace_root"; mcp-server.test.ts advertised-tool list. Artifact: tool-advertised.
- AC5 (unknown id -> ok:false naming searched location; malformed id -> ok:false naming rule, no fs access):
  PASS. Tests: repo-automation-render-subagent-tree.test.ts — "returns ok:false naming the searched
  directory for a valid but unknown id", "returns ok:false naming the validation rule for a malformed id
  and never touches the filesystem"; session-transcript-resolver.test.ts validation suite (7 malformed-id
  cases asserting no filesystem method invoked).
- AC6 (resolver matches encoded dir + `-wt-` siblings case-insensitively; first dir with <id>.jsonl wins;
  tool description states scope): PASS. Tests: session-transcript-resolver.test.ts — "resolves the
  transcript in the exact-match encoded directory", "resolves the transcript in a -wt- worktree sibling
  directory", "matches encoded directories case-insensitively", "returns the first matching directory
  deterministically when several contain the transcript". Tool description states the search scope
  (mcp-repo-automation-tool-definitions.ts render_subagent_tree description).

## Hook and Skills (spec AC 7-9)

- AC7 (SessionStart hook: env-file append CLAUDE_SESSION_ID=<id>; state-file fallback; no write on
  malformed/empty; always exit 0): PASS. Pester (persist-session-id.Tests.ps1): "chooses the env-file
  channel...", "chooses the state-file channel...", "appends CLAUDE_SESSION_ID=<id> to the env file...",
  "writes the id to the state file (ensuring its directory)...", "performs no write on malformed JSON",
  "performs no write on empty input", plus default-writer mock tests. The script body ends with an
  unconditional `exit 0`. Evidence: phase6-ps-test.
- AC8 (identify-session-id resolves without human input; documents env var -> state file ->
  newest-mtime fallbacks; reports source): PASS. File: .claude/skills/identify-session-id/SKILL.md
  (frontmatter name/description/allowed-tools [Read, Bash]; ordered Resolution Order 1-3; Output section
  requires reporting the source).
- AC9 (show-my-agent-tree resolves via identify-session-id, invokes tool with session_id + explicit
  workspace_root, prints tree fenced in reply incl /btw; settings.json carries hook + allow-list): PASS.
  File: .claude/skills/show-my-agent-tree/SKILL.md (allowed-tools include
  mcp__drm-copilot__render_subagent_tree + Read/Bash; 3-step Flow; fenced-code-block output; /btw note).
  .claude/settings.json: SessionStart hook invoking persist-session-id.ps1; allow-list entries
  mcp__drm-copilot__render_subagent_tree, Skill(identify-session-id *), Skill(show-my-agent-tree *)
  (validated by the passing tests/scripts/claude-runtime suite).

## Quality Gates (spec AC 10-12; AC 13 deferred)

- AC10 (toolchain passes Prettier->ESLint->tsc->Jest; every new production file has per-file 85/75
  coverageThreshold; no production file excluded; PS hook passes PoshQC + Pester): PASS.
  Evidence: final-ts-format, final-ts-lint, final-ts-typecheck, final-ts-jest-coverage (per-file 85/75
  gates enforced in jest.config.cjs for all 6 new production files), final-ps-format, final-ps-analyze,
  final-ps-test, phase6-ps-test (hook 87.04% line).
- AC11 (all touched files < 500 lines; no new runtime dependency): PASS. Evidence: file-size-check
  (max production 487, max test 500), dependency-check (dependencies unchanged, only
  @modelcontextprotocol/sdk).
- AC12 (new src/lib/** modules import neither vscode nor node:fs; MCP bundle builds without esbuild
  changes): PASS. Evidence: host-neutrality-check (zero matches in quick-pick-labels.ts and
  session-transcript-resolver.ts), bundle-extension (no esbuild config modified), bundle-mcp-server.
- AC13 (Local feature-review clean of blocking findings): PENDING — verified by the downstream
  feature-review stage, not by this execution plan. Left unchecked.

## Check-Off Record (P9-T5)

- spec.md `## Acceptance Criteria`: bullets 1-12 set to [x]; bullet 13
  ("Local feature-review reports no blocking findings.") left [ ] (deferred to feature-review).
- spec.md `## Definition of Done`: all 7 items set to [x] (behavior, unit tests, Pester test,
  skills/settings wiring, toolchain pass, docs current).
- user-story.md `## Acceptance Criteria`: 8 verified bullets set to [x]; the final
  "Local feature-review clean of blocking findings." left [ ].
- No box was checked without cited evidence above.
