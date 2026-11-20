<!-- markdownlint-disable-file -->

# Task Research Notes: .github bundled customization divergence audit

## Research Executed

### File Analysis

- `.github/agents/atomic_planning.agent.md`
  - Compared against `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md`; root and bundle diverge in allowed tool surface.
- `.github/agents/csharp-typed-engineer.agent.md`
  - Compared against bundled mirror; bundle retains `execute/awaitTerminal` while root does not.
- `.github/agents/mentor.agent.md`
  - Compared against bundled mirror; root adds `'drmcopilotextension/*'` while the bundle remains read-only.
- `.github/agents/staged-review.agent.md`
  - Compared against bundled mirror; root references MCP-based policy-audit template resolution while bundle references a repo-local template path.
- `.github/codex/execute-hard-lock.prompt.md`
  - Compared against bundled mirror; difference is trailing newline only.
- `.github/copilot-instructions.md`
  - Compared against bundled mirror; difference is trailing blank-line formatting only.
- `.github/skills/feature-promotion-lifecycle/SKILL.md`
  - Compared against bundled mirror; root documents VS Code commands in the fallback block while the bundle still documents direct script commands.
- `.github/skills/feature-review-workflow/SKILL.md`
  - Compared against bundled mirror; bundle is missing the explicit coverage-regression remediation trigger present in root.
- `.github/skills/pr-base-branch-merge-base/SKILL.md`
  - Compared against bundled mirror; root points collector invocation at MCP `collect_pr_context`, while bundle still references `scripts.dev_tools.pr_context.collector`.
- `.github/codex/codex-web-maintenance.sh`
  - Present in root only; no bundled counterpart exists in the mirror tree.
- `.github/codex/codex-web-setup.sh`
  - Present in root only; no bundled counterpart exists in the mirror tree.
- `.github/workflows/ci.yml`
  - Present in root only; no bundled counterpart exists in the mirror tree.

### Code Search Results

- `.github/**` vs `extensions/drm-copilot/resources/customizations/.github/**`
  - Scoped inventory found `9` content divergences, `3` root-only files, `96` line-ending-only differences, `0` mirror-only files, and `1` exact byte-for-byte match in the current checkout.
- `collect_pr_context|scripts.dev_tools.pr_context.collector|resolve_policy_audit_template_asset`
  - The divergent files cluster around three contract themes: PR-context collection surface, policy-audit template resolution surface, and direct command/tool exposure in agent metadata.
- `git log --oneline -- <root> <mirror>` for each divergent path
  - Recent commit history inside the in-scope trees shows several divergent root files were changed by newer synchronization or MCP-surface commits while the bundle remained on older wording.

### External Research

- #githubRepo:"drmoisan/drm-copilot .github customizations parity"
  - Repository-local history and file comparison were sufficient; no remote repository lookup was required.
- #fetch:repository-local-only
  - No external webpages were fetched because the requested narrowed scope is fully answerable from the two in-repo trees.

### Project Conventions

- Standards referenced: root `.github` files and bundled `.github` mirrors should be compared path-for-path inside the two in-scope trees; git history inside those same paths is admissible for recency judgment.
- Instructions followed: research-only constraints, `agent-customization` skill, `policy-compliance-order` skill, and `skill-canonical-location-audit` skill.

## Key Discoveries

### Project Structure

Within the narrowed scope, the divergence inventory is:

- **Content-diverged**: 9 files
- **Root-only**: 3 files
- **Line-ending-only**: 96 files
- **Mirror-only**: 0 files

The three root-only files all live under root `.github` subdirectories and have no corresponding file in the bundled `.github` tree.

### Implementation Patterns

The substantive divergences are not random. They fall into these groups:

1. **Agent tool-surface drift**
   - `agents/atomic_planning.agent.md`
   - `agents/csharp-typed-engineer.agent.md`
   - `agents/mentor.agent.md`

2. **Automation-surface wording drift**
   - `agents/staged-review.agent.md`
   - `skills/feature-promotion-lifecycle/SKILL.md`
   - `skills/pr-base-branch-merge-base/SKILL.md`

3. **Formatting-only drift misclassified by exact-byte comparison**
   - `codex/execute-hard-lock.prompt.md`
   - `copilot-instructions.md`

4. **Coverage-policy drift**
   - `skills/feature-review-workflow/SKILL.md`

### Complete Examples

```diff
diff --git a/.github/agents/staged-review.agent.md b/extensions/drm-copilot/resources/customizations/.github/agents/staged-review.agent.md
-   - MCP server `drmCopilotExtension` tool `resolve_policy_audit_template_asset` with the selector appropriate to the needed artifact:
-      - `asset: template` for `policy-audit.yyyy-MM-ddTHH-mm.md`
-      - `asset: code-review-template` for `code-review.yyyy-MM-ddTHH-mm.md`
-      - `asset: feature-audit-template` for `feature-audit.yyyy-MM-ddTHH-mm.md`
-      - `asset: agents` for `AGENTS.md`
+  - `docs/features/templates/policy_audit/AGENTS.md`
```

```diff
diff --git a/.github/skills/pr-base-branch-merge-base/SKILL.md b/extensions/drm-copilot/resources/customizations/.github/skills/pr-base-branch-merge-base/SKILL.md
- Use this skill when:
- - running via MCP server `drmCopilotExtension` tool `collect_pr_context`,
+ Use this skill when:
+ - running `scripts.dev_tools.pr_context.collector`,
```

### API and Schema Documentation

Only in-scope tree evidence was used for these surface names:

- Root `.github` currently uses `collect_pr_context` wording in:
  - `.github/agents/feature-review.agent.md`
  - `.github/skills/pr-base-branch-merge-base/SKILL.md`
- Root `.github` currently uses `resolve_policy_audit_template_asset` wording in:
  - `.github/agents/staged-review.agent.md`

### Configuration Examples

```text
content-diverged: 9
line-ending-only: 96
match: 1
root-only: 3
```

### Technical Requirements

- Any assessment in this note is limited to evidence visible inside `.github/**` and `extensions/drm-copilot/resources/customizations/.github/**`.
- Root-only files can only be judged from their absence in the bundled tree and their own in-tree git history.
- Line-ending-only differences should not be treated as semantic contract drift.

**Mandatory unachievable objective callout**:
- **A definitive “publisher scope” proof is intentionally omitted here** because the user asked to wipe all out-of-tree evidence from the research file. This note therefore uses only in-scope path comparison and in-scope git history, not publisher implementation files outside `.github/**` or the bundled `.github/**` tree.

## Recommended Approach

Use the root `.github` copy as the preferred source for most substantive divergences when its wording is both newer in git history and more internally consistent than the bundled copy. However, preserve two exceptions:

- `agents/mentor.agent.md`: the bundled copy appears safer because it keeps a narrower read-only tool contract.
- `skills/feature-promotion-lifecycle/SKILL.md`: neither side is fully correct because the root text changes the fallback examples without reconciling the surrounding fallback prose.

### File-by-file assessment

| Relative path | Divergence | Best-judgment correct side | Why |
|---|---|---|---|
| `agents/atomic_planning.agent.md` | Root has a revised, more granular tool list; bundle still has an older broader tool list. | **Root is likely correct.** | Recent in-scope history shows a newer synchronization commit touching this file. The root copy reads like an updated contract, while the bundle still carries a superset from an older state. |
| `agents/csharp-typed-engineer.agent.md` | Bundle still includes `execute/awaitTerminal`; root does not. | **Root is likely correct.** | The root contract is narrower and appears to be the current edited state from the latest synchronization commit in this file’s history. |
| `agents/mentor.agent.md` | Root adds `'drmcopilotextension/*'`; bundle remains read-only. | **Bundle is likely correct.** | Inside this file alone, the role is mentorship/guidance, not automation. The narrower bundled tool contract is more aligned with the described role. |
| `agents/staged-review.agent.md` | Root uses MCP policy-audit template resolution; bundle regresses to a repo-local path. | **Root is correct.** | Root is the newer wording in the in-scope history, and the MCP-based phrasing is more structured and explicit than the single bundled local-path reference. |
| `codex/execute-hard-lock.prompt.md` | Trailing newline only. | **Neither side is materially more correct.** | No semantic content difference exists. |
| `copilot-instructions.md` | Trailing blank line only. | **Neither side is materially more correct.** | No semantic content difference exists. |
| `skills/feature-promotion-lifecycle/SKILL.md` | Root fallback block switched to VS Code command examples; bundle still shows script commands. | **Neither side is fully correct.** | The root wording is newer in history, but the file still says scripts are the fallback. The fallback section and explanatory prose are inconsistent with each other. |
| `skills/feature-review-workflow/SKILL.md` | Bundle omits the explicit coverage-regression remediation trigger present in root. | **Root is correct.** | The root copy is newer in the in-scope history and preserves a stronger remediation gate. The bundle removes a concrete trigger without replacing it. |
| `skills/pr-base-branch-merge-base/SKILL.md` | Root points to MCP `collect_pr_context`; bundle still references the local collector script. | **Root is correct.** | The root wording is newer in the in-scope history and aligns with other in-scope root files that now reference MCP `collect_pr_context`. |
| `codex/codex-web-maintenance.sh` | Present only in root. | **Root-only appears to be the current correct state.** | No bundled counterpart exists anywhere in the in-scope tree, and the file has its own root-only history. |
| `codex/codex-web-setup.sh` | Present only in root. | **Root-only appears to be the current correct state.** | Same reasoning as `codex-web-maintenance.sh`: in-scope evidence shows a root file with no mirror counterpart. |
| `workflows/ci.yml` | Present only in root. | **Root-only appears to be the current correct state.** | The file exists only in the root `.github/workflows` subtree, with no bundled counterpart in the mirror tree. |

### Rejected alternatives

- **Treat every root file as correct by default** — rejected because `agents/mentor.agent.md` is better justified on the bundled side based on the file’s own role description.
- **Treat every bundled file as safer because it is packaged** — rejected because several bundled copies clearly retain older wording while root copies show newer synchronized changes in path-local history.
- **Use evidence from publisher scripts, tests, README files, or docs outside the two trees** — rejected because the user asked to wipe out-of-tree material from the research file.

### Full divergence inventory

#### Content-diverged

- `agents/atomic_planning.agent.md`
- `agents/csharp-typed-engineer.agent.md`
- `agents/mentor.agent.md`
- `agents/staged-review.agent.md`
- `codex/execute-hard-lock.prompt.md`
- `copilot-instructions.md`
- `skills/feature-promotion-lifecycle/SKILL.md`
- `skills/feature-review-workflow/SKILL.md`
- `skills/pr-base-branch-merge-base/SKILL.md`

#### Root-only

- `codex/codex-web-maintenance.sh`
- `codex/codex-web-setup.sh`
- `workflows/ci.yml`

#### Line-ending-only

- `agents/5.1-Beast-adjusted.agent.md`
- `agents/5.1-Thinking-Beast-Mode-adjusted.agent.md`
- `agents/api-architect.agent.md`
- `agents/atomic_executor.agent.md`
- `agents/commentary-remediation.agent.md`
- `agents/commit-steward.agent.md`
- `agents/csharp-atomic-executor.agent.md`
- `agents/csharp-atomic-planning.agent.md`
- `agents/csharp-orchestrator.agent.md`
- `agents/epic-review.agent.md`
- `agents/expert-nextjs-developer.agent.md`
- `agents/expert-react-frontend-engineer.agent.md`
- `agents/feature-review.agent.md`
- `agents/gpt-5-beast-mode.agent.md`
- `agents/hlbpa.agent.md`
- `agents/orchestrator.agent.md`
- `agents/Powershell DI Unit Test Engineer.agent.md`
- `agents/powershell-atomic-executor.agent.md`
- `agents/powershell-atomic-planning.agent.md`
- `agents/powershell-orchestrator.agent.md`
- `agents/powershell-typed-engineer.agent.md`
- `agents/pr-author.agent.md`
- `agents/prd-feature.agent.md`
- `agents/prd.agent.md`
- `agents/pytest-unit-test-coding.agent.md`
- `agents/python-atomic-executor.agent.md`
- `agents/python-atomic-planning.agent.md`
- `agents/python-execution-only-typed.agent.md`
- `agents/python-orchestrator.agent.md`
- `agents/python-typed-engineer.agent.md`
- `agents/status_updater.agent.md`
- `agents/task-researcher.agent.md`
- `agents/tdd-green.agent.md`
- `agents/tdd-red.agent.md`
- `agents/tdd-refactor.agent.md`
- `agents/typescript-engineer.agent.md`
- `agents/voidbeast-gpt41enhanced.agent.md`
- `instructions/csharp-code-change.instructions.md`
- `instructions/csharp-unit-test.instructions.md`
- `instructions/general-code-change.instructions.md`
- `instructions/general-unit-test.instructions.md`
- `instructions/github-actions-ci-cd-best-practices.instructions.md`
- `instructions/github-actions.instructions.md`
- `instructions/powershell-code-change.instructions.md`
- `instructions/powershell-unit-test.instructions.md`
- `instructions/python-code-change.instructions.md`
- `instructions/python-suppressions.instructions.md`
- `instructions/python-unit-test.instructions.md`
- `instructions/self-explanatory-code-commenting.instructions.md`
- `instructions/tonality.instructions.md`
- `instructions/typescript-code-change.instructions.md`
- `instructions/typescript-suppressions.instructions.md`
- `instructions/typescript-unit-test.instructions.md`
- `prompts/add-educational-comments.prompt.md`
- `prompts/breakdown-bug-prd.prompt.md`
- `prompts/breakdown-epic-arch.prompt.md`
- `prompts/breakdown-epic-pm.prompt.md`
- `prompts/breakdown-feature-implementation.prompt.md`
- `prompts/breakdown-feature-prd.prompt.md`
- `prompts/code-exemplars-blueprint-generator.prompt.md`
- `prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md`
- `prompts/drafts/create-implementation-plan.prompt.md`
- `prompts/drafts/create-technical-spike.prompt.md`
- `prompts/drafts/potential-feature-prd.prompt.md`
- `prompts/drafts/update-implementation-plan.prompt.md`
- `prompts/execute-plan-template.md`
- `prompts/export-chat.prompt.md`
- `prompts/fillout-prd-feature.prompt.md`
- `prompts/generate-atomic-plan.prompt.md`
- `prompts/generate-commit-message-repo.prompt.md`
- `prompts/generate-pr.prompt.md`
- `prompts/javascript-typescript-jest.prompt.md`
- `prompts/orchestrate-csharp-work.prompt.md`
- `prompts/orchestrate-powershell-work.prompt.md`
- `prompts/orchestrate-python-work.prompt.md`
- `prompts/orchestrate-work.prompt.md`
- `prompts/remediate-comments.prompt.md`
- `prompts/research-issue.prompt.md`
- `prompts/review-epic.prompt.md`
- `prompts/review-feature.prompt.md`
- `prompts/review-staged.prompt.md`
- `prompts/update_status.prompt.md`
- `skills/acceptance-criteria-tracking/SKILL.md`
- `skills/atomic-plan-contract/SKILL.md`
- `skills/csharp-change-budget-router/SKILL.md`
- `skills/csharp-orchestration-state-machine/SKILL.md`
- `skills/evidence-and-timestamp-conventions/SKILL.md`
- `skills/make-skill-template/SKILL.md`
- `skills/policy-audit-template-usage/SKILL.md`
- `skills/policy-compliance-order/SKILL.md`
- `skills/powershell-change-budget-router/SKILL.md`
- `skills/powershell-orchestration-state-machine/SKILL.md`
- `skills/pr-context-artifacts/SKILL.md`
- `skills/README.md`
- `skills/remediation-handoff-atomic-planner/SKILL.md`
- `skills/skill-canonical-location-audit/SKILL.md`

## Implementation Guidance

- **Objectives**: keep the research strictly limited to `.github/**` and `extensions/drm-copilot/resources/customizations/.github/**`; identify only in-scope divergences; judge each substantive divergence using only in-scope content and in-scope git history.
- **Key Tasks**: reconcile the 9 substantive divergences; decide whether to preserve `agents/mentor.agent.md` on the bundled side; repair the internal inconsistency in `skills/feature-promotion-lifecycle/SKILL.md`; optionally normalize line endings if byte-for-byte parity is needed locally.
- **Dependencies**: only the two in-scope trees and their git history.
- **Success Criteria**: the research note contains no out-of-scope evidence, every substantive divergence has a judgment, and the full in-scope divergence inventory is preserved.