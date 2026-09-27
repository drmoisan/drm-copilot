# Payload Sample Inventory — Issue #673 [P3-T1]

Timestamp: 2026-09-17T11-48

Command: two separate command sets were run, and this artifact records both.

1. The pinned fixed-string searches, the `cd` search, and the `It`-block count were run directly through the Bash tool with `grep`, once per scope. Each invocation and its exact result are recorded in the sections below.
2. The sample inventory itself was produced by `sh ".../scratchpad/f673-exec/p3gen.sh"` (route a-prime per `evidence/baseline/execution-route.md`), which runs `p3gen.ps1`. That script scans the seven protected test files for every payload-producing form, de-duplicates by decoded text, and emits this artifact. It does not re-run the `grep` searches; their results were transcribed into it from the Bash-tool runs.

EXIT_CODE: 0

Output Summary: 62 payload samples are inventoried: 6 Group A samples covering all six gated subagent types, 3 Group B gated Bash command shapes, and 53 Group C shapes covering every distinct payload the seven AC-19/AC-20 protected test files replay. Both pinned literals return zero matches over the five scoped trees. Over the repository search excluding `.git/`, `node_modules/`, and this feature's `evidence/` tree, the create literal returns exactly two matches, both documentary, and the edit literal returns zero. The `cd` command-word search across the seven protected files returns zero matches. The `It`-block count across those seven files is 103.

## Pinned fixed-string searches

Both searches use `grep -rnF`, a fixed-string search, not a regular expression. The first literal is two ampersand characters, a space, and `gh pr create`. The second is two ampersand characters, a space, and `gh pr edit`.

### Scope 1 — the five trees `.claude/`, `.codex/`, `scripts/`, `tests/`, `extensions/`

| literal | matches |
| --- | --- |
| create literal | **0** |
| edit literal | **0** |

Both invocations produced no output and exited 1 (no match). The invocations, with the workspace-root
prefix `<WORKTREE_ROOT>/` written as
`<ROOT>/` for readability:

```
grep -rnF -e '&& gh pr create' "<ROOT>/.claude/" "<ROOT>/.codex/" "<ROOT>/scripts/" "<ROOT>/tests/" "<ROOT>/extensions/"
grep -rnF -e '&& gh pr edit'   "<ROOT>/.claude/" "<ROOT>/.codex/" "<ROOT>/scripts/" "<ROOT>/tests/" "<ROOT>/extensions/"
```

### Scope 2 — the whole repository, excluding `.git/`, `node_modules/`, and `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/`

The evidence exclusion is applied by anchoring the filter at the start of the grep output line, so it removes result lines whose *path* is under that tree and not result lines whose *content* merely quotes that path. A content-anchored filter drops the `plan.2026-09-13T20-48.md:311` match, because the `[P1-T3]` task text quotes an evidence path on the same line.

| literal | matches | locations |
| --- | --- | --- |
| create literal | **2** | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md:311` and `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/research/2026-09-13T22-10-false-approval-elimination-research.md:205` |
| edit literal | **0** | none |

The invocations, with `<ROOT>/` again standing for the workspace root:

```
grep -rnF --exclude-dir=.git --exclude-dir=node_modules -e '&& gh pr create' "<ROOT>/" | grep -v "^<ROOT>/docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/"
grep -rnF --exclude-dir=.git --exclude-dir=node_modules -e '&& gh pr edit'   "<ROOT>/" | grep -v "^<ROOT>/docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/"
```

Both create-literal matches are documentary: one is the `[P1-T3]` task text in this plan, the other is the research note quoting the same reproduction payload. Neither is executable code and neither is replayed by a test. No target-bearing `gh pr create` or `gh pr edit` command shape therefore exists in executable or test code.

The `gh pr merge` shape quoted at `.claude/hooks/enforce-epic-merge-gate.ps1:152` is matched by neither literal and is sampled separately as B1.

## The seven AC-19/AC-20 protected test files

| file | `It`-block opening lines | distinct payload shapes contributed |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | 43 | 23 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 1 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 5 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 22 | 17 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1` | 9 | 3 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 2 | 2 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` | 15 | 2 |
| **total** | **103** | **53** |

The `It`-block count uses `grep -cE '^[[:space:]]*It '` over each file and totals 103, matching the plan's measured value.

A `cd` command-word search across the same seven files, `grep -nE "\bcd\b"`, produced no output and exited 1: **0 matches**. No protected row carries a target-bearing payload by way of a working-directory change.

Total payload-producing matches across the seven files, before de-duplication by decoded text: 79. De-duplicated: 53 distinct shapes.

De-duplication is by decoded payload text across the whole seven-file set, and the "distinct payload shapes contributed" column attributes each shape to the file in which it first occurs in the scan order listed in the table. A shape replayed by two files is therefore counted once, against the earlier file. The 53 distinct shapes are the complete set the seven files replay between them.

## The two required additional shapes

- `gh pr create --title "foo" --body-file artifacts/pr_body_1.md` at `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:33` — recorded as sample **B2**, and again at `:80` inside a full envelope carrying `tool_name` as sample **B3**.
- the `subagent_type` plus `prompt` Agent shape at `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1:64-67` — the hashtable form `@{ tool_name = 'Agent'; tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'x' } } | ConvertTo-Json -Compress -Depth 5`. Its decoded `prompt` value, `x`, is recorded in Group C from its first occurrence at `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1:27`. Every Agent payload in that file uses the same single-character `prompt` value.

## Sample inventory

Each sample records the verbatim JSON envelope, the source file path and line it was drawn from, the payload field the derivation reads, and the decoded text handed to derivation. A `\n` in a derivation-text value denotes a literal newline in the payload.

### Group A — one delegation payload per gated subagent type

The six gated subagent types are read from `.claude/hooks/enforce-model-routing-receipt.ps1:74-79`. Each prompt is the delegation-prompt material recorded for that type in the repository's orchestration and skill documents, with this feature's folder name and PR number substituted for the document's placeholder.

#### A1-atomic-planner

- Source: `.claude/skills/orchestrate/SKILL.md:260`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"atomic-planner","prompt":"Canonical issue number for this feature is 673. All artifact content, file paths, and cross-references must use this number."},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `Canonical issue number for this feature is 673. All artifact content, file paths, and cross-references must use this number.`

#### A2-atomic-executor

- Source: `.claude/skills/orchestrate/SKILL.md:260`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"atomic-executor","prompt":"Canonical issue number for this feature is 673. All artifact content, file paths, and cross-references must use this number."},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `Canonical issue number for this feature is 673. All artifact content, file paths, and cross-references must use this number.`

#### A3-feature-review

- Source: `.claude/skills/orchestrate/SKILL.md:260`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"feature-review","prompt":"Canonical issue number for this feature is 673. All artifact content, file paths, and cross-references must use this number."},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `Canonical issue number for this feature is 673. All artifact content, file paths, and cross-references must use this number.`

#### A4-task-researcher

- Source: `.claude/skills/orchestrate/SKILL.md:128`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"task-researcher","prompt":"docs/features/2026-09-13-false-approval-elimination-pr-author-model-routing-673/research/"},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `docs/features/2026-09-13-false-approval-elimination-pr-author-model-routing-673/research/`

#### A5-prd-feature

- Source: `.claude/skills/fill-feature-docs/SKILL.md:20`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"prd-feature","prompt":"docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md"},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md`

#### A6-pr-author

- Source: `.claude/skills/orchestrate/SKILL.md:186`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"pr-author","prompt":"artifacts/pr_body_1.md and the sibling receipt artifacts/pr_body_1.receipt.json"},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `artifacts/pr_body_1.md and the sibling receipt artifacts/pr_body_1.receipt.json`

### Group B — gated Bash command shapes

#### B1-gh-pr-merge

- Source: `.claude/hooks/enforce-epic-merge-gate.ps1:152`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_name":"Bash","tool_input":{"command":"gh pr merge 410 --merge"}}
```

- Decoded text handed to derivation: `gh pr merge 410 --merge`

#### B2-gh-pr-create-bare-toolinput

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:33`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body_1.md`

#### B3-gh-pr-create-full-envelope

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:80`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_name":"Bash","tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body_1.md`

### Group C — every distinct payload shape the seven protected test files replay

#### C1

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:39`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body \"inline string\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body "inline string"`

#### C2

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:46`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body=''inline text''"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body=''inline text''`

#### C3

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:60`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --body \"inline text\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --body "inline text"`

#### C4

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:68`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --body=''inline''"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --body=''inline''`

#### C5

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:76`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --title \"x\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --title "x"`

#### C6

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:88`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create`

#### C7

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:96`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"my feature\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "my feature"`

#### C8

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:110`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_12.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body_12.md`

#### C9

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:118`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --body-file artifacts/pr_body_12.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --body-file artifacts/pr_body_12.md`

#### C10

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:155`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --title \"new title\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --title "new title"`

#### C11

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:161`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --add-label bug"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --add-label bug`

#### C12

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:167`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr view 13"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr view 13`

#### C13

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:173`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr list"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr list`

#### C14

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:179`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr merge 42 --squash"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr merge 42 --squash`

#### C15

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:185`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr checkout 13"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr checkout 13`

#### C16

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:191`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh issue create --title foo"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh issue create --title foo`

#### C17

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:206`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body.md`

#### C18

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:239`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_5.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body_5.md`

#### C19

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:321`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --body-file artifacts/pr_body_1.md`

#### C20

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:326`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --body \"some text\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --body "some text"`

#### C21

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:372`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --body \"text\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --body "text"`

#### C22

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:377`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 5 --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 5 --body-file artifacts/pr_body_1.md`

#### C23

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:441`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo"`

#### C24

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:33`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body_1.md`

#### C25

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:25`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"x\" --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "x" --body-file artifacts/pr_body_1.md`

#### C26

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:39`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 5 --body-file artifacts/pr_body_5.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 5 --body-file artifacts/pr_body_5.md`

#### C27

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:49`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"x\" --base epic/foo-integration --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md`

#### C28

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:69`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"x\" --base main --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md`

#### C29

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:108`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --base epic/foo-integration --body-file artifacts/pr_body_1.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --base epic/foo-integration --body-file artifacts/pr_body_1.md`

#### C30

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:57`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"echo '{\"cmd\":\"gh pr create --body-file artifacts/pr_body_545.md\"}' > artifacts/receipt.json"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `echo '{"cmd":"gh pr create --body-file artifacts/pr_body_545.md"}' > artifacts/receipt.json`

#### C31

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:72`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md`

#### C32

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:81`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md`

#### C33

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:98`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --body-file artifacts/pr_body_545.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --body-file artifacts/pr_body_545.md`

#### C34

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:102`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --body \"inline text\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --body "inline text"`

#### C35

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:107`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_545.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title "foo" --body-file artifacts/pr_body_545.md`

#### C36

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:120`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"echo artifacts/pr_body_545.md | xargs gh pr create"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `echo artifacts/pr_body_545.md | xargs gh pr create`

#### C37

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:130`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"bash -c 'gh pr create --title x'"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `bash -c 'gh pr create --title x'`

#### C38

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:140`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"sh -c \"gh pr create --title x\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `sh -c "gh pr create --title x"`

#### C39

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:150`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"env gh pr create --title x"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `env gh pr create --title x`

#### C40

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:160`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"pwsh -NoProfile -Command \"gh pr create --title x\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `pwsh -NoProfile -Command "gh pr create --title x"`

#### C41

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:186`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"echo \"$(gh pr create --title x)\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `echo "$(gh pr create --title x)"`

#### C42

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:288`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"bash -c \"gh pr edit 42 --body 'x'\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `bash -c "gh pr edit 42 --body 'x'"`

#### C43

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:298`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"bash -c \"gh pr edit 42 --body-file artifacts/pr_body_545.md\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `bash -c "gh pr edit 42 --body-file artifacts/pr_body_545.md"`

#### C44

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:309`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr edit 42 --body-file artifacts/pr_body_545.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr edit 42 --body-file artifacts/pr_body_545.md`

#### C45

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:320`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"echo '{\"cmd\":\"gh pr edit 42 --body x\"}' > artifacts/receipt.json"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `echo '{"cmd":"gh pr edit 42 --body x"}' > artifacts/receipt.json`

#### C46

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1:57`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --body inline"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --body inline`

#### C47

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1:80`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh pr create --title t --body inline"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh pr create --title t --body inline`

#### C48

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1:90`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"git status --short"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `git status --short`

#### C49

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:38`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"gh --repo drmoisan/drm-copilot pr create --base epic/x --body-file artifacts/pr_body_545.md"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `gh --repo drmoisan/drm-copilot pr create --base epic/x --body-file artifacts/pr_body_545.md`

#### C50

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:52`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"echo \"gh pr create --base main\""},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `echo "gh pr create --base main"`

#### C51

- Source: `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1:27`
- Derivation field: `prompt`
- Payload JSON:

```json
{"tool_input":{"subagent_type":"atomic-planner","prompt":"x"},"tool_name":"Agent"}
```

- Decoded text handed to derivation: `x`

#### C52

- Source: `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1:34`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"echo hi"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `echo hi`

#### C-heredoc

- Source: `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:171`
- Derivation field: `command`
- Payload JSON:

```json
{"tool_input":{"command":"bash <<'EOF'\ngh pr create --title x\nEOF\n"},"tool_name":"Bash"}
```

- Decoded text handed to derivation: `bash <<'EOF'\ngh pr create --title x\nEOF\n`

