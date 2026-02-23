# Copilot Customization Audit (2026-02-06)

## Sources reviewed
- VS Code 1.109 (January 2026) release notes (release date: 2026-02-04). Highlights emphasize multi-agent development, agent session management, agent customization, MCP integration, and trust/safety improvements.
- Copilot customization docs: custom instructions, prompt files, custom agents, agent skills, language models, MCP servers.
- Copilot agents docs: overview, tutorial, subagents, background agents, cloud agents, third-party agents.

## MECE role chart (global instructions vs file-based instructions vs prompts vs skills vs custom agents vs MCP servers)

| Artifact | Scope / trigger | Should do (in scope) | Should NOT do (out of scope) | Complements |
| --- | --- | --- | --- | --- |
| **Global instructions** (`.github/copilot-instructions.md`, optional `AGENTS.md`) | Always-on for all chats in workspace | Project-wide guardrails, coding values, repo purpose, top-level constraints, links to deeper policies | Task-specific workflows, tool invocation recipes, or per-language rules that belong in file-based instructions | Provide baseline expectations; keep minimal so other layers can specialize |
| **File-based instructions** (`.github/instructions/*.instructions.md`) | Auto-applied based on `applyTo` glob or attached manually | Language/toolchain policies, test/lint/typecheck rules, security constraints, docs standards for specific paths | One-off task prompting, agent orchestration, or deep workflow logic | Narrowly scopes behavior to file types and keeps global instructions short |
| **Prompt files** (`.github/prompts/*.prompt.md`) | On-demand (slash command) | One-shot, repeatable tasks with explicit instructions and context; optionally choose agent, tools, model | Long-lived personas, always-on policies, or external tool integration details | Trigger a custom agent or narrow workflow for a single task |
| **Agent skills** (`.github/skills/<skill>/SKILL.md`) | Loaded on demand by relevance | Reusable workflow capabilities + scripts/examples; portable across Copilot surfaces | Repo-wide policies, broad personas, or one-off prompts | Encapsulate domain workflows for multiple agents and prompts |
| **Custom agents** (`.github/agents/*.agent.md`) | Selected as agent or subagent | Role/persona with tool access + behavior rules; optional handoffs | General policy or toolchain rules that should live in instructions; or prompt-like one-shot tasks | Provide consistent behavior for workflows, can be invoked by prompts |
| **MCP servers** (config, not in repo here) | Session start/tool use | External tools and services (APIs, SCM, DBs); tool surface only | Policy, persona, or workflow instructions | Adds capabilities; prompts/agents decide when to use tools |

## Audit: `.github/agents/*.agent.md` (custom agents)

| File | Fit to custom agent role | What it does well | Gaps / misalignment | Move / change recommendation |
| --- | --- | --- | --- | --- |
| 5.1-Beast-adjusted.agent.md | Partial | Emphasizes persistence and policy precedence | Requires unavailable tools (Google, fetch_webpage, sequential_thinking), conflicts with repo and environment rules | Remove from repo or mark `user-invokable: false`; rework into a personal agent or a skills repo |
| 5.1-Thinking-Beast-Mode-adjusted.agent.md | Partial | Explicit policy precedence | Same tool availability conflicts; mandates Google and recursive web fetch | Same as above: remove or restrict to user profile |
| api-architect.agent.md | Partial | Clear persona and layered architecture expectations | Requires “Code Interpreter” and user saying “generate”; better as a prompt flow | Convert to prompt file with frontmatter; keep agent if toolset is validated |
| atomic_executor.agent.md | Strong | Properly scoped execution-only role | Very long; requires exact plan format but that is intended | Keep as agent; consider adding `user-invokable: false` if only used via handoff |
| atomic_planning.agent.md | Strong | Correct planning-only scope; clear format | Extremely strict; ok for plan-only workflows | Keep as agent; ensure prompts/handoffs use it consistently |
| commentary-remediation.agent.md | Strong | Clear policy order and toolchain loop | Heavy autonomy; ok for remediation tasks | Keep as agent; consider aligning tool list with actual availability |
| commit-steward.agent.md | Strong | Well-scoped commit message authoring | None; assumes “context file” exists | Keep; consider a prompt wrapper that passes context path |
| epic-review.agent.md | Strong | Clear audit outputs and handoffs | Very long; depends on docs/templates presence | Keep; ensure docs/templates exist in repo before use |
| expert-nextjs-developer.agent.md | Partial | Strong Next.js guidance | Hardcodes Next.js 16/React 19.2; may not match repo | Move to skill for React/Next.js workflows or keep as user profile agent |
| expert-react-frontend-engineer.agent.md | Partial | Good React best practices | Hardcodes React 19.2; not repo-specific | Move to skill or personal agent |
| feature-review.agent.md | Strong | Clear audit flow + remediation plan handoff | Assumes PR context artifacts | Keep; pair with prompt to generate PR context |
| gpt-5-beast-mode.agent.md | Partial | Persistence focus | Tool requirements conflict (Google, fetch_webpage), excessive mandates | Remove or keep as personal agent; not repo-scoped |
| hlbpa.agent.md | Partial | High-level architectural documentation focus | Forces file creation in docs; may not match repo docs layout | Convert to prompt or skill with configurable output path |
| mentor.agent.md | Partial | Clear mentoring persona | Mentions non-existent tools (giphy), lacks `name` | Keep as agent but update tools and frontmatter; or move to prompt |
| Powershell DI Unit Test Engineer.agent.md | Strong | Clear PowerShell testing + DI scope control | Very long; tools list may exceed actual tools | Keep; trim tools to only available ones |
| pr-author.agent.md | Strong | Clear PR authoring constraints | Assumes PR context artifacts | Keep; add prompt wrapper to supply context |
| prd-feature.agent.md | Strong | Focused doc completion | Needs accurate context paths from caller | Keep; pair with prompt (already exists) |
| prd.agent.md | Strong | PRD creation persona | Requires file creation; ok for agent | Keep; ensure prompts provide location |
| pytest-unit-test-coding.agent.md | Strong | Pytest scope + quality gates | Assumes ability to run toolchain | Keep; ensure prompt clarifies toolchain availability |
| python-execution-only-typed.agent.md | Partial | Strong Python guidance | Duplicate of python-typed-engineer; hard gate “approval before edits” | Consolidate with python-typed-engineer; keep one primary agent |
| python-typed-engineer.agent.md | Strong | Clear Python design + gates | Overlaps with python-execution-only-typed | Consolidate; deprecate duplicate |
| staged-review.agent.md | Strong | Scoped staged diff review | Depends on policy templates | Keep; ensure policy templates exist |
| status_updater.agent.md | Strong | Clear status sync behavior | Complex; relies on doc structure | Keep; use only when docs structure is present |
| task-researcher.agent.md | Strong | Research-only scope enforced | Only writes to artifacts/research (ok) | Keep |
| tdd-green.agent.md | Weak | TDD phase separation | Hardcodes C# tools and GitHub issue flow; not repo-aligned | Remove from repo or move to personal agent; not aligned to repo languages |
| tdd-red.agent.md | Weak | TDD red mindset | C#-specific and tool usage not available | Remove or move to personal agent |
| tdd-refactor.agent.md | Weak | TDD refactor focus | C# and external tools not used in repo | Remove or move to personal agent |
| typescript-engineer.agent.md | Strong | Aligns with TS policies and toolchain | Very long handoffs; ok | Keep |
| voidbeast-gpt41enhanced.agent.md | Weak | Generic autonomy | Tooling mandates not available; prompt generator rules conflict with repo policy | Remove or keep in personal profile |

## Audit: `.github/prompts/*.prompt.md` (prompt files)

| File | Fit to prompt role | What it does well | Gaps / misalignment | Move / change recommendation |
| --- | --- | --- | --- | --- |
| add-educational-comments.prompt.md | Strong | Clear one-shot task | Heavy line-count inflation; may conflict with repo comment policy | Consider converting to a skill or add guardrails to respect repo comment policies |
| breakdown-bug-prd.prompt.md | Strong | Uses `prd_creator` to fill bug spec | None | Keep |
| breakdown-epic-arch.prompt.md | Partial | Clear architectural output | Writes to `/docs/ways-of-work/plan/...` which may not exist | Move to `drafts/` or update paths to repo conventions |
| breakdown-epic-pm.prompt.md | Partial | Clear PRD output | Same path mismatch | Move to `drafts/` or update paths |
| breakdown-feature-implementation.prompt.md | Partial | Detailed plan prompt | Uses Epoch monorepo assumptions and /docs/ways-of-work paths | Move to `drafts/` or retarget to repo docs |
| breakdown-feature-prd.prompt.md | Partial | Feature PRD prompt | Writes to /docs/ways-of-work path | Move to `drafts/` or retarget |
| code-exemplars-blueprint-generator.prompt.md | Partial | Useful template for exemplar scanning | No frontmatter; contains raw template variables not supported by prompt files | Move to docs/templates or convert into a skill with SKILL.md |
| export-chat.prompt.md | Partial | Simple file creation instruction | No frontmatter; uses fixed path format without variables | Add frontmatter and use `${workspaceFolder}` or `${input:...}` for path |
| fillout-prd-feature.prompt.md | Strong | Properly calls `prd_feature` agent | None | Keep |
| generate-atomic-plan.prompt.md | Strong | Proper prompt for `atomic_planner` | None | Keep |
| generate-commit-message-repo.prompt.md | Weak | Duplicates commit-steward logic | Hardcoded path `/workspaces/transcript-etl-pipeline/...` | Replace with a thin prompt that calls `commit_steward` and passes `${workspaceFolder}` path |
| generate-pr.prompt.md | Weak | Duplicates PR Author agent | No frontmatter, duplicated content | Replace with prompt that invokes `pr-author` agent |
| javascript-typescript-jest.prompt.md | Weak | Generic test tips | Not a prompt; belongs in instructions or a skill | Move to a skill (e.g., `jest-testing`) or delete |
| remediate-comments.prompt.md | Strong | Proper loader for comment_remediator | None | Keep |
| research-issue.prompt.md | Strong | Research kickoff for Task Researcher | None | Keep |
| review-epic.prompt.md | Strong | Proper loader for epic_review_agent | None | Keep |
| review-feature.prompt.md | Strong | Proper loader for feature_code_review_agent | None | Keep |
| review-staged.prompt.md | Strong | Proper loader for staged_code_review_agent | None | Keep |
| update_status.prompt.md | Strong | Proper loader for status_updater_agent | None | Keep |

### Prompt drafts (`.github/prompts/drafts/*.prompt.md`)

| File | Fit | Notes / recommendation |
| --- | --- | --- |
| create-github-issues-feature-from-implementation-plan.prompt.md | Partial | Uses GitHub tools; ok as draft, but references tools not configured here. Keep in drafts or move to skills with MCP GitHub server config. |
| create-implementation-plan.prompt.md | Weak | Uses a custom plan template that conflicts with `atomic_planner` conventions. Keep as draft only or retire. |
| create-technical-spike.prompt.md | Partial | Good spike template but requires many tools; ok as draft. Add frontmatter and adjust tools list if promoted. |
| potential-feature-prd.prompt.md | Partial | References `docs/features/potential/template.md`; ok if template exists, otherwise keep as draft. |
| update-implementation-plan.prompt.md | Weak | Template conflicts with atomic planning rules; keep as draft or remove. |

## Audit: `.github/instructions/*.instructions.md` (file-based instructions)

| File | Fit to instruction role | What it does well | Gaps / misalignment | Move / change recommendation |
| --- | --- | --- | --- | --- |
| general-code-change.instructions.md | Strong | Clear repo-wide change policy | Very long but ok | Keep; avoid duplicating in agents |
| general-unit-test.instructions.md | Strong | Cross-language test policy | None | Keep |
| python-code-change.instructions.md | Strong | Python toolchain + typing rules | None | Keep |
| python-unit-test.instructions.md | Strong | Pytest rules + toolchain | None | Keep |
| python-suppressions.instructions.md | Strong | Strict suppression patterns | None | Keep |
| self-explanatory-code-commenting.instructions.md | Strong | Clear Python docstring/comment policy | None | Keep |
| typescript-code-change.instructions.md | Strong | TS toolchain policy | None | Keep |
| typescript-unit-test.instructions.md | Strong | Jest rules | None | Keep |
| typescript-suppressions.instructions.md | Strong | Suppression guardrails | None | Keep |
| powershell-code-change.instructions.md | Strong | PoshQC workflow and rules | None | Keep |
| powershell-unit-test.instructions.md | Strong | Pester rules | None | Keep |
| github-actions.instructions.md | Strong | Workflow policy | None | Keep |
| github-actions-ci-cd-best-practices.instructions.md | Partial | Very large best-practice doc | Might be too prescriptive for all workflows | Keep if intended, otherwise move to docs/ or create a skill |
| codexer.instructions.md | Partial | Placeholder only | No functional guidance | Remove if no longer required by tooling |

## Evaluation: `.github/copilot-instructions.md`

Current state: empty. This is **not** the best use of the always-on instruction layer. It should provide minimal, high-level guardrails and a pointer to the scoped instruction files, without duplicating the deep policies already in `.github/instructions/`.

Recommended usage:
- Add a short project overview, core goals, and a strict pointer to obey `.github/instructions/*.instructions.md`.
- Keep it brief (a few bullets) to avoid diluting file-based instructions.
- If AGENTS.md is generated from `.github/instructions`, keep the copilot-instructions file as the top-level “table of contents” and avoid repeating detailed policies.

## Cross-cutting recommendations (no edits made)

1. **Introduce skills** (`.github/skills/`) for reusable workflows (e.g., toolchain runs, audits, PR context generation). Skills are the best place for multi-step procedures with scripts and examples.
2. **Reduce duplicate agent/prompt content** by creating thin prompts that invoke the corresponding agent (e.g., `generate-pr` -> `pr-author`, `generate-commit` -> `commit-steward`).
3. **Retire or relocate non-repo-aligned agents** (Beast/voidbeast/TDD C# agents) to personal profiles or a separate skills repo to avoid conflicting instructions.
4. **Normalize prompt frontmatter** for any prompt intended for day-to-day use. Prompts without frontmatter should be treated as drafts or moved to docs/templates.

