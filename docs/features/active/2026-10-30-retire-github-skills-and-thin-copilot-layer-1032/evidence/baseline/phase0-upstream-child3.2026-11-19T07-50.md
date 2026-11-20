# Phase 0 Upstream Check: Child 3 (#1028) ([P0-T4])

Timestamp: 2026-11-19T07-50
Plan: plan.2026-10-30T18-39.md
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check (through sh SCRATCH/issue-1032-gencheck.sh skills); grep over AGENTS.md, CLAUDE.md, scripts/harness-generation/HarnessAgentGeneration.psm1, scripts/harness-generation/sources/skills/, .codex/agents/*.toml and the C3 spec and plan
EXIT_CODE: 0
Output Summary: generator check prints `harness-generation: no drift` and exits 0; UA-C3a, UA-C3b and UA-C3c hold; ClaudeMdPointer: agents-md; GithubAgentsTarget: no; 86 of 134 `.codex/agents/*.toml` files name `.github/agents`; CodexAgentsProvenance: unhandled. No `blocked: premise_falsified`.

`C3` = `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028` (merged into the integration branch by PR #1203).

## Generator

- Skill-mirror generator: `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills` (C3 `spec.md` `## API / CLI Surface`); check mode `-Surface skills -Check`.
- Check exit code: 0 (`harness-generation: no drift`).
- Mirror scope: `.agents/skills/<name>/` to `.claude/skills/<name>/` and its bundle copy, with per-skill substitution lists under `scripts/harness-generation/sources/skills/`. C3 decision D-14 excludes `atomic-plan-contract` and `feature-review-workflow` (among others) from the mirror: both copies of those skills stay hand-maintained, so P1-T11 edits the `.claude` copy of `atomic-plan-contract` directly rather than regenerating it. `execution-environment` is mirrored.

## Assumptions

| ID | Result | Observation |
| --- | --- | --- |
| UA-C3a | holds | `.agents/skills` is the shared source mirrored into `.claude/skills` by the generator above, with a check mode (exit 0). |
| UA-C3b | holds | Per-tool role-link handling (U4 input): each `DOCS-ROLE-LINK-SKILLS` member (`docs-author-page`, `docs-inventory-surface`, `docs-plan-ia`, `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`, `documentation-workflow`) and each of the nine `LEGACY-DISCOVERY-SKILLS` workflows has `scripts/harness-generation/sources/skills/<name>.substitutions.json`, which rewrites the `.agents` link `../../../.codex/agents/<role>.toml` to the `.claude` link `../../../.claude/agents/<role>.md`. The seven alias skills carry no role link. |
| UA-C3c | holds | `AGENTS.md` holds `Do not use jokes` (1 match). |
| UA-C3d | recorded | `HarnessAgentGeneration.psm1` names no `.github/agents` target. |
| UA-C3e | recorded | 86 of 134 `.codex/agents/*.toml` files hold `.github/agents` (provenance list lines such as `- .github/agents/api-architect.agent.md`); the C3 spec and plan name no task for them. |

ClaudeMdPointer: agents-md (`CLAUDE.md` first line after its frontmatter is `@AGENTS.md`; it names no `copilot-instructions.md`)
GithubAgentsTarget: no
CodexAgentsProvenance: unhandled (reference: C3 `spec.md` `### Surface: agents` and `plan.2026-10-30T18-30.md` contain no `.codex/agents` provenance task; spec `## Non-Goals` of this feature leaves those lines to child 3)
CodexAgentsProvenanceFileCount: 86
