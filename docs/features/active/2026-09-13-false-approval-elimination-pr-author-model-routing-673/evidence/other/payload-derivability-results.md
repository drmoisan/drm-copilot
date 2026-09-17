# Payload Derivability Results — Issue #673 [P3-T2] and [P3-T3]

Timestamp: 2026-09-17T11-48

Command: `sh ".../scratchpad/f673-exec/p3gen.sh"` (route a-prime per `evidence/baseline/execution-route.md`), which runs `p3gen.ps1`. That script imports both F1 modules and calls `Resolve-WorktreeCallTarget -Text <decoded payload text> -SessionRoot "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe"` once per sample.

EXIT_CODE: 0

Output Summary: **0 of 62** samples derived a target. **62 of 62** did not. The four-state breakdown is SessionRoot 0, OtherWorktree 0, NoTarget 61, Ambiguous 1; no call raised. All six gated subagent types failed to derive a target, all three gated Bash command shapes failed, and all 53 payload shapes the seven protected test files replay failed. The verdict recorded in the `Derivability Verdict:` section below is GAP, and execution halts at this task. That section carries the single verdict line; the token is written exactly once in this file so no reader can mistake a prose mention for the verdict.

## Derivation call shape

`Resolve-WorktreeCallTarget` is the `<TARGET_DERIVATION>` function named in the binding table filled by [P2-T3]. Both F1 modules are imported, because F1's sibling import is module-scoped and re-exports nothing (recorded in `f1-binding-table.md`).

`-SessionRoot` is supplied explicitly and set to the recorded `F5_WORKSPACE_ROOT` so the run is reproducible and independent of the invoking process's working directory. Omitting it changes nothing about which state is returned for these samples: `WorktreeTargetResolution.psm1:259-266` only uses the session root to decide between `SessionRoot` and `OtherWorktree` once a target has already been resolved, and no sample resolves one.

## Result rows — one per sample

| id | group | source | field | status | reason code | resolved worktree root |
| --- | --- | --- | --- | --- | --- | --- |
| `A1-atomic-planner` | A | `.claude/skills/orchestrate/SKILL.md:260` | `prompt` | **NoTarget** | (none) | (null) |
| `A2-atomic-executor` | A | `.claude/skills/orchestrate/SKILL.md:260` | `prompt` | **NoTarget** | (none) | (null) |
| `A3-feature-review` | A | `.claude/skills/orchestrate/SKILL.md:260` | `prompt` | **NoTarget** | (none) | (null) |
| `A4-task-researcher` | A | `.claude/skills/orchestrate/SKILL.md:128` | `prompt` | **NoTarget** | (none) | (null) |
| `A5-prd-feature` | A | `.claude/skills/fill-feature-docs/SKILL.md:20` | `prompt` | **Ambiguous** | TARGET_WORKTREE_AMBIGUOUS | (null) |
| `A6-pr-author` | A | `.claude/skills/orchestrate/SKILL.md:186` | `prompt` | **NoTarget** | (none) | (null) |
| `B1-gh-pr-merge` | B | `.claude/hooks/enforce-epic-merge-gate.ps1:152` | `command` | **NoTarget** | (none) | (null) |
| `B2-gh-pr-create-bare-toolinput` | B | `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:33` | `command` | **NoTarget** | (none) | (null) |
| `B3-gh-pr-create-full-envelope` | B | `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:80` | `command` | **NoTarget** | (none) | (null) |
| `C1` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:39` | `command` | **NoTarget** | (none) | (null) |
| `C2` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:46` | `command` | **NoTarget** | (none) | (null) |
| `C3` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:60` | `command` | **NoTarget** | (none) | (null) |
| `C4` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:68` | `command` | **NoTarget** | (none) | (null) |
| `C5` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:76` | `command` | **NoTarget** | (none) | (null) |
| `C6` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:88` | `command` | **NoTarget** | (none) | (null) |
| `C7` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:96` | `command` | **NoTarget** | (none) | (null) |
| `C8` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:110` | `command` | **NoTarget** | (none) | (null) |
| `C9` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:118` | `command` | **NoTarget** | (none) | (null) |
| `C10` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:155` | `command` | **NoTarget** | (none) | (null) |
| `C11` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:161` | `command` | **NoTarget** | (none) | (null) |
| `C12` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:167` | `command` | **NoTarget** | (none) | (null) |
| `C13` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:173` | `command` | **NoTarget** | (none) | (null) |
| `C14` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:179` | `command` | **NoTarget** | (none) | (null) |
| `C15` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:185` | `command` | **NoTarget** | (none) | (null) |
| `C16` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:191` | `command` | **NoTarget** | (none) | (null) |
| `C17` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:206` | `command` | **NoTarget** | (none) | (null) |
| `C18` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:239` | `command` | **NoTarget** | (none) | (null) |
| `C19` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:321` | `command` | **NoTarget** | (none) | (null) |
| `C20` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:326` | `command` | **NoTarget** | (none) | (null) |
| `C21` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:372` | `command` | **NoTarget** | (none) | (null) |
| `C22` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:377` | `command` | **NoTarget** | (none) | (null) |
| `C23` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:441` | `command` | **NoTarget** | (none) | (null) |
| `C24` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:33` | `command` | **NoTarget** | (none) | (null) |
| `C25` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:25` | `command` | **NoTarget** | (none) | (null) |
| `C26` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:39` | `command` | **NoTarget** | (none) | (null) |
| `C27` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:49` | `command` | **NoTarget** | (none) | (null) |
| `C28` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:69` | `command` | **NoTarget** | (none) | (null) |
| `C29` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:108` | `command` | **NoTarget** | (none) | (null) |
| `C30` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:57` | `command` | **NoTarget** | (none) | (null) |
| `C31` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:72` | `command` | **NoTarget** | (none) | (null) |
| `C32` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:81` | `command` | **NoTarget** | (none) | (null) |
| `C33` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:98` | `command` | **NoTarget** | (none) | (null) |
| `C34` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:102` | `command` | **NoTarget** | (none) | (null) |
| `C35` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:107` | `command` | **NoTarget** | (none) | (null) |
| `C36` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:120` | `command` | **NoTarget** | (none) | (null) |
| `C37` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:130` | `command` | **NoTarget** | (none) | (null) |
| `C38` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:140` | `command` | **NoTarget** | (none) | (null) |
| `C39` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:150` | `command` | **NoTarget** | (none) | (null) |
| `C40` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:160` | `command` | **NoTarget** | (none) | (null) |
| `C41` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:186` | `command` | **NoTarget** | (none) | (null) |
| `C42` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:288` | `command` | **NoTarget** | (none) | (null) |
| `C43` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:298` | `command` | **NoTarget** | (none) | (null) |
| `C44` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:309` | `command` | **NoTarget** | (none) | (null) |
| `C45` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:320` | `command` | **NoTarget** | (none) | (null) |
| `C46` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1:57` | `command` | **NoTarget** | (none) | (null) |
| `C47` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1:80` | `command` | **NoTarget** | (none) | (null) |
| `C48` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1:90` | `command` | **NoTarget** | (none) | (null) |
| `C49` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:38` | `command` | **NoTarget** | (none) | (null) |
| `C50` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:52` | `command` | **NoTarget** | (none) | (null) |
| `C51` | C | `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1:27` | `prompt` | **NoTarget** | (none) | (null) |
| `C52` | C | `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1:34` | `command` | **NoTarget** | (none) | (null) |
| `C-heredoc` | C | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1:171` | `command` | **NoTarget** | (none) | (null) |

### Detail clauses for the rows that are not the common case

Every `NoTarget` row carries the same detail clause, quoted once here rather than 61 times:

```
the call names no feature folder, file path, or branch, so it has no target and the session root 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4da10d770a658efe' applies
```

- `A5-prd-feature` (**Ambiguous**): feature folder token 'docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673' matched 12 candidate worktrees; supply an absolute path inside exactly one worktree to disambiguate

## Counts

- Samples that derived a target (SessionRoot or OtherWorktree): **0**
- Samples that did not derive a target: **62**

Per-state counts over all sampled payload shapes:

| F1 state | sampled payload shapes returning it |
| --- | --- |
| `SessionRoot` | 0 |
| `OtherWorktree` | 0 |
| `NoTarget` | 61 |
| `Ambiguous` | 1 |
| `Error` | 0 |
| **total** | **62** |

Per-state counts restricted to Group A, the six gated subagent types:

| F1 state | Group A samples returning it |
| --- | --- |
| `SessionRoot` | 0 |
| `OtherWorktree` | 0 |
| `NoTarget` | 5 |
| `Ambiguous` | 1 |
| `Error` | 0 |

Per-state counts restricted to Group C, the shapes the seven protected test files replay:

| F1 state | Group C samples returning it |
| --- | --- |
| `SessionRoot` | 0 |
| `OtherWorktree` | 0 |
| `NoTarget` | 53 |
| `Ambiguous` | 0 |
| `Error` | 0 |

## Derivability Verdict:

DERIVABILITY: GAP

### Why

[P3-T3] requires the GAP verdict when either condition holds. Both hold.

1. **An ordinary, correctly-formed payload for a gated subagent type or a gated `gh pr` command failed to derive a target.** All six Group A subagent payloads failed: five returned `NoTarget` and one, the `prd-feature` payload whose prompt names this feature's folder as a repository-relative path, returned `Ambiguous` against 12 candidate worktrees. All three Group B gated `gh pr` command shapes returned `NoTarget`.
2. **Derivation returns no target for payload shapes replayed by the seven protected test files.** 53 of the 53 distinct Group C shapes failed to derive a target.

### Rows that would be affected

Every distinct payload shape the seven AC-19/AC-20 protected test files replay — all 53 of them — lands in a state F5's design assigns no action to. Those shapes are exercised across the 103 `It` rows of the seven files:

| file | `It` rows | distinct shapes it contributes | shapes deriving a target |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | 43 | 23 | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 1 | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 5 | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 22 | 17 | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1` | 9 | 3 | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 2 | 2 | 0 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` | 15 | 2 | 0 |

AC-19 and AC-20 permit no edit to those assertions, so no remediation is available downstream of the hook edits.

### The shape of the gap

The dominant failure is not `Ambiguous`. It is `NoTarget`, which F1 documents at `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:277` as meaning the call names no signal at all and the session root applies. F5's three-outcome design assigns no action to `NoTarget`, as recorded in the state-mapping table of `f1-binding-table.md`. Routing it to the resolved-target outcome reinstates the session-root fallback that `plan.2026-09-13T20-48.md:42` forbids by name; routing it to the ambiguity deny denies every gated call that carries no target signal, which is almost all of them.

The single `Ambiguous` result is informative in the other direction: a repository-relative feature-folder token is present in the payload and still does not place, because the same relative path exists in 12 worktrees. F1's `FilePathPattern` at `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:57` accepts only absolute file paths for the same reason, stated in the comment at `:55-56`. Ordinary delegation prompts and ordinary `gh pr` command lines in this repository use repository-relative paths.

### Action taken

Execution of this plan stops at [P3-T3]. Phase 4 is not started and no file under `.claude/hooks/` is edited. No cwd fallback is added, F1's derivation is not re-implemented or patched in F5, and no file under `.claude/lib/worktree-resolution/` is modified. The gap is raised upstream against F1 with the failing payload samples quoted in `payload-sample-inventory.md` and in the result rows above.
