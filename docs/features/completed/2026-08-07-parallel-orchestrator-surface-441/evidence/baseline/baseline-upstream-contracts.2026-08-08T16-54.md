# Baseline — Upstream-Landing State Re-Verification (P0-T7)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Task:** [P0-T7]
- **Working directory:** repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)
- **Branch:** `feature/parallel-orchestrator-surface-441` (based on `epic/parallel-orchestration-integration`)
- **HEAD at capture:** `ee0626e8`

Timestamp: 2026-08-08T16-54

Command (read-only verification set, all executed from the repository root):

```
ls -la .claude/rules/parallel-orchestration.md scripts/dev_tools/validate_parallel_orchestrator_state.py \
       scripts/dev_tools/validate_parallel_planner_state.py scripts/dev_tools/parallel_kickoff_contract.py \
       scripts/dev_tools/parallel_manifest_contract.py .claude/agents/parallel-planner.md \
       .claude/skills/parallel-plan/SKILL.md
grep -n "parallel" config/orchestration-routing.json
grep -rn "MERGE_STATUS|merge_status" scripts/dev_tools/_parallel_state_common.py
grep -rn "parallel-orchestrator-state|parallel-planner-state|parallel-kickoff" scripts/dev_tools/validate_orchestration_artifacts.py
grep -rn "parallel-orchestrator-state|parallel-planner-state|parallel-kickoff" extensions/drm-copilot/src/ --include=*.ts
grep -rn "parallel-kickoff|kickoff_prompt_path" .claude/skills/parallel-plan/SKILL.md .claude/agents/parallel-planner.md
git log --oneline -1 12174c418e304755fac707817abcd44bd13eb708
git log --oneline -1 -- <each key file>
```

EXIT_CODE: 0

## Output Summary

**Both F3 (issue #444) and F4 (issue #443) have landed on this branch.** Every design-document stand-in named in spec `## Assumptions` is therefore superseded by a landed artifact for all three items below. No Adjudicated Decision is altered by this verification.

### Item (a) — F3 landing, `merge_status` enum, and `artifact_type` strings

**Landed. Verified present:**

| Path | Size (bytes) |
| --- | --- |
| `.claude/rules/parallel-orchestration.md` | 23773 |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 11866 |
| `scripts/dev_tools/validate_parallel_planner_state.py` | 16243 |
| `scripts/dev_tools/parallel_manifest_contract.py` | 10767 |

Landing commit confirmed: `12174c41 merge(epic): fan in F3 parallel-schema-validators (#444)`. The originating change is `3eb6b348 feat(parallel): add parallel manifest and checkpoint schemas with validators`; `.claude/rules/parallel-orchestration.md` was last touched by `dac03eb3 docs(parallel): qualify cross-runtime parity claim in the parallel rule file`.

**Exact `merge_status` enum member set shipped** — eight members, read from the definition of `VALID_MERGE_STATUS` in `scripts/dev_tools/_parallel_state_common.py:46-51`:

1. `not_started`
2. `worktree_created`
3. `pr_open`
4. `ci_green`
5. `merged`
6. `worktree_removed`
7. `blocked_drift`
8. `blocked_ci_loop_limit`

Two derived groupings are also shipped and are load-bearing for the plan's barrier predicate: `MERGED_MERGE_STATUSES = ("merged", "worktree_removed")` (`_parallel_state_common.py:84`) and `BLOCKED_MERGE_STATUSES = ("blocked_drift", "blocked_ci_loop_limit")` (`_parallel_state_common.py:88`).

**Agreement with the plan:** this eight-member set is byte-for-byte the set the plan already enumerates in P2-T12 and asserts in P4-T4. No plan text requires amendment. The barrier predicate in P2-T4 (cohort `N+1` only after every cohort-`N` item is `merged` or `worktree_removed`) matches `MERGED_MERGE_STATUSES` exactly.

**Exact `artifact_type` strings shipped.** Three parallel artifact types are registered, not two. F3 shipped two; F4 shipped the third:

| `artifact_type` string | Owner | CLI registration | MCP registration |
| --- | --- | --- | --- |
| `parallel-orchestrator-state` | F3 | `validate_orchestration_artifacts.py:261` (subparser, with `--require-complete`) | `mcp-tool-definitions.ts:412`, `mcp-repo-automation-tool-definitions.ts:345`, `mcp-tool-inputs.ts:436` |
| `parallel-planner-state` | F3 | `validate_orchestration_artifacts.py:272` (subparser, with `--require-ready-for-execution`) | `mcp-tool-definitions.ts:413`, `mcp-repo-automation-tool-definitions.ts:346`, `mcp-tool-inputs.ts:437` |
| `parallel-kickoff` | F4 | `validate_orchestration_artifacts.py:183` (path-only subparser), dispatched at line 360 | `mcp-tool-definitions.ts:414`, `mcp-repo-automation-tool-definitions.ts:347`, `mcp-tool-inputs.ts:438` |

The TypeScript dispatch for all three lives in `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (cases at lines 263, 271, 279).

**Consequence for P1-T1:** the plan's `-ArtifactType parallel-orchestrator-state` is the exact shipped string. The P1-T1 parenthetical ("use the artifact-type string confirmed in P0-T7 if F3 landed a different one") is resolved: F3 landed no different string, so P1-T1 proceeds with `parallel-orchestrator-state` as written. Likewise the checkpoint path `artifacts/orchestration/parallel-orchestrator-state.json` is the shipped path (`.claude/rules/parallel-orchestration.md`, `parallel-orchestrator-state-core.ts:7`).

Manifest validation is deliberately **not** an `artifact_type`: it is the library call `validate_parallel_manifest_text` in `scripts/dev_tools/parallel_manifest_contract.py`, per the rule file's enforcement section.

### Item (b) — `parallel` route in `config/orchestration-routing.json`

**Landed and present.** The `"parallel"` route object begins at `config/orchestration-routing.json:100`, preceding the existing `"epic"` route at line 122. Shipped contents:

- `description`: "Parallel path for scheduling independent items into blast-radius cohorts across parallel worktrees; each item PRs to main independently with no integration branch."
- `requires_pr_gate`: `false`
- `required_agents`: `orchestrator`, `pr-author`
- `required_skills`: `parallel-orchestrate`, `orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `evidence-and-timestamp-conventions`, `pr-context-artifacts`, (continues)
- `required_mcp_tools`: `collect_pr_context`, `validate_orchestration_artifacts`

The route's `required_skills` already names `parallel-orchestrate` — the skill this feature delivers at `.claude/skills/parallel-orchestrate/SKILL.md` (P2-T1 through P2-T15). The route entry is mirrored byte-for-byte in `extensions/drm-copilot/resources/config/orchestration-routing.json` per the rule file. `config/orchestration-routing.json` was last touched by `3eb6b348`.

### Item (c) — F4 kickoff-artifact convention

**Landed and confirmed, with an important refinement: F4 shipped a two-path convention, not one path.**

Verified in `.claude/skills/parallel-plan/SKILL.md` `## Kickoff Artifact` (lines 350-354), verbatim:

> Write the working copy to `artifacts/orchestration/parallel-kickoff-<slug>.md` (a gitignored tree) and commit a byte-identical durable copy to `docs/features/parallel/<slug>/parallel-kickoff.md` on `parallel/<slug>-plan`.

Corroborated by `.claude/agents/parallel-planner.md:42-43`, which names both the working path and the durable path, and by `.claude/skills/parallel-plan/SKILL.md:416-417` listing both paths.

| Path | Role | Committed? |
| --- | --- | --- |
| `artifacts/orchestration/parallel-kickoff-<slug>.md` | working copy; the value F3 invariant **P9** requires `kickoff_prompt_path` to equal exactly | No — gitignored tree |
| `docs/features/parallel/<slug>/parallel-kickoff.md` | durable byte-identical copy, committed on `parallel/<slug>-plan` | Yes |

**The plan's P3-T1 assumption is confirmed.** P3-T1 specifies kickoff discovery "at the local path only (`docs/features/parallel/<slug>/parallel-kickoff.md`)". That path is exactly F4's landed **durable committed copy**, which is the correct discovery target for `/parallel-run`: it is the copy that exists in the repository. The `artifacts/orchestration/parallel-kickoff-<slug>.md` path is the planner's working copy in a gitignored tree and is therefore not a reliable discovery target for a fresh checkout. No P3-T1 amendment is required.

Two consistency points recorded so Phase 3 does not conflate them:

- F3 invariant **P9** (`.claude/rules/parallel-orchestration.md`) constrains the planner checkpoint field `kickoff_prompt_path` to `artifacts/orchestration/parallel-kickoff-<parallel_slug>.md`. It does **not** constrain where `/parallel-run` discovers the artifact. The TypeScript expectation is generated at `parallel-planner-state-core.ts:147`.
- F4's manifest-path regex is `docs/features/parallel/[a-z0-9][a-z0-9-]*/parallel\.md` (`scripts/dev_tools/parallel_kickoff_contract.py:61`), confirming the `docs/features/parallel/<slug>/` run-folder convention the plan assumes throughout.

`scripts/dev_tools/parallel_kickoff_contract.py` was last touched by `15656e4c fix(parallel-planner): bind kickoff template to its validator and correct the seam`.

## Governing Contract Source (required determination)

Per spec `## Assumptions`, where an F3/F4 artifact has landed, its shipped value supersedes the design-document stand-in; where it has not landed, the design document (§11, §12, §6) governs. All three items resolve to the landed artifact:

| # | Item | Governing contract source for the remainder of execution |
| --- | --- | --- |
| (a) | `merge_status` enum and `artifact_type` strings | **LANDED ARTIFACT (F3).** `scripts/dev_tools/_parallel_state_common.py` (`VALID_MERGE_STATUS`, 8 members) and `.claude/rules/parallel-orchestration.md` govern the enum; `scripts/dev_tools/validate_orchestration_artifacts.py` plus the MCP definition files govern the `artifact_type` strings. Design-document §11/§12 stand-ins are superseded. Shipped values are identical to the plan's existing text, so no plan delta arises. |
| (b) | `parallel` route | **LANDED ARTIFACT (F3).** `config/orchestration-routing.json:100-121` governs, mirrored in `extensions/drm-copilot/resources/config/orchestration-routing.json`. |
| (c) | Kickoff-artifact convention | **LANDED ARTIFACT (F4).** `.claude/skills/parallel-plan/SKILL.md` `## Kickoff Artifact` and `.claude/agents/parallel-planner.md` govern the two-path convention; F3 invariant P9 governs the checkpoint field only. Design-document §6 stand-in is superseded. The durable committed path named by P3-T1 is confirmed correct. |

**No Adjudicated Decision is altered.** Decisions 1 (parent performs per-item `gh pr merge --merge`; child unmodified), 2 (no `.claude/hooks/` file and no `.claude/settings.json` change), and 3 (F3 owns manifest and checkpoint schemas including the `merge_status` enum) stand unchanged. This verification confirms Decision 3 in particular: the enum is owned and shipped by F3, and F5 consumes it without extension, consistent with the rule file's "Enum Ownership (F6/F7/F8 consume, never extend)" section.

**Net effect on the plan:** zero required amendments. Every upstream value the plan anticipated matches what landed. Phase 1 may proceed exactly as written.
