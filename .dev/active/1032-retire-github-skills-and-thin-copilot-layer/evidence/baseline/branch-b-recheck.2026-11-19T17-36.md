# Branch B Upstream Re-check ([P0-T2])

Timestamp: 2026-11-19T17-36
Plan: plan-agents-branch-b.md
Command: read of the greatest `phase0-upstream-child3.*.md` (`phase0-upstream-child3.2026-11-19T07-50.md`) plus the current `scripts/harness-generation/HarnessAgentGeneration.psm1` targets; grep of C1 `survey/difference-approval.md` `## Owner Overrides` and `## Disputed Cases`; sh SCRATCH/issue-1032-r1-run.sh issue-1032-bb-recheck.ps1 (git ls-files of `.github/agents`, git hash-object per file, frontmatter `handoffs:` test, ConvertFrom-Json of `config/harness-parity-matrix.json` `features`, Compare-Object with the matrix `source_path` values and with `github-native-inventory.2026-11-19T07-51.md`); read of `$script:AgentProfileLayout` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` and `Get-DocsAuthoringAgentPath` in `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1`
EXIT_CODE: 0
Output Summary: UB-2, UB-3 and UB-4 hold; UB-5 recorded with OVERRIDE-IDS empty. 50 agent files (20 handoff-bearing); 50 `copilot:agent:` ids and 20 `copilot:handoff:` ids; both cross-checks pass. No `blocked: premise_falsified`.

GithubAgentsTarget: no

## Assumptions

| ID | Result | Detail |
| --- | --- | --- |
| UB-2 | holds | `phase0-upstream-child3.2026-11-19T07-50.md` records `GithubAgentsTarget: no`; re-read in the current (post-sync) tree: `HarnessAgentGeneration.psm1` renders only a `claude` target and a `codex` target (`.codex/agents/<name>.toml`); no `.github/agents` target exists. |
| UB-3 | holds | `COPILOT-AGENT-FILES` under `.github/agents/`: 50 files, including the four `DOCS-AGENT-ROLES` (`docs-architect`, `docs-author`, `docs-coverage-reviewer`, `docs-reconciler`); 20 handoff-bearing (frontmatter `handoffs:`). Matrix: 50 `copilot:agent:` ids whose `source_path` set equals the file set (Compare-Object difference 0); 20 `copilot:handoff:` ids whose `source_path` set equals the handoff-bearing set (difference 0). Cross-check 1 (names against `github-native-inventory.2026-11-19T07-51.md`): 50 and 50, name difference 0 — pass. Cross-check 2 (counts against `phase0-upstream-child1.2026-11-19T07-48.md`: agent 50, handoff 20): pass. Four files changed hash since that inventory (`atomic_executor`, `atomic_planning`, `orchestrator`, `task-researcher`): the main plan's READ-FIRST-AGENTS edit; names and counts are unaffected. |
| UB-4 | holds | `$script:AgentProfileLayout['github-copilot']` is `@{ Directory = '.github/agents'; Suffix = '.agent.md' }`, so `Get-DiscoveryAgentProfilePath -HostName github-copilot` resolves `.github/agents/<role>.agent.md`; `Get-DocsAuthoringAgentPath` still returns `Copilot = ".github/agents/$Role.agent.md"` and its bundle copy for each docs role. |
| UB-5 | recorded | see OVERRIDE-IDS. |

## OVERRIDE-IDS:

- none. No `## Owner Overrides` row and no `## Disputed Cases` block (19 blocks, each with `Owner-Decision: A`) in C1 `survey/difference-approval.md` names a `copilot:agent:` or `copilot:handoff:` id (fixed-string count 0 for both prefixes over the file).
- Observation: the `## Owner Overrides` row `E3` (deferred: owner-run runbook not executed) states in its note that "copilot:agent entries keep their plan A disposition and stay provisional". The row names the entry class, not an id, so it adds nothing to OVERRIDE-IDS. It is the deferral that selects Branch B (`agents-branch-selection.2026-11-19T07-48.md`), and P1-T1 keeps those entries `provisional` with the deferral reference as spec R4 states; P1-T1 changes their disposition from `generated` to `native` because UB-2 shows no `.github/agents` generator target exists (the Branch B native case).

## Current matrix fields (before P1-T1 and P1-T2)

- 50 `copilot:agent:` entries: `disposition` `generated`, `decision_status` `provisional`, `decision_ref` `#1025:runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md`, one `target_paths` value, `generated_from` `pending-source:agent`.
- 20 `copilot:handoff:` entries: `disposition` `native`, `decision_status` `approved`, no `reason`, no `decision_ref`, no `target_paths`, no `generated_from`.

## Files (path | git hash-object | handoff-bearing)

- .github/agents/5.1-Beast-adjusted.agent.md | 22b823cb670b200878ebf6200d910e9658e10d75 | no
- .github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md | d85c25cc16bc433f23cb6ad25e371c963cb7bcae | no
- .github/agents/api-architect.agent.md | 1739e98f43da1624b144baee5a8b88e27242cf79 | no
- .github/agents/atomic_executor.agent.md | 941f334916123a7ed245ef74e502779b95f757e8 | no
- .github/agents/atomic_planning.agent.md | 75c3efce133e5c08c9e0943a1cea65e9ba3a97d8 | yes
- .github/agents/commentary-remediation.agent.md | cb3e3a3c49a022e8bf3183fa12f8f2d62f2bf0a3 | no
- .github/agents/commit-steward.agent.md | e904c6bdda282479563b44c03e15981a7899050d | no
- .github/agents/csharp-atomic-executor.agent.md | 684cce0abee70b084e78b7c648582266ac414ca7 | no
- .github/agents/csharp-atomic-planning.agent.md | 52020ac49b55cf34e013b70c41b03501dda9d288 | yes
- .github/agents/csharp-orchestrator.agent.md | 8b60291143ed2024f5d57c1912cac9a5cc197a91 | yes
- .github/agents/csharp-typed-engineer.agent.md | 9a6e925bfc33fb07c9d03ba515db1533e8117cf7 | yes
- .github/agents/discovery-capability-sentinel.agent.md | 3900333d960548cf5ff73e8ce5831b931236ddc0 | no
- .github/agents/docs-architect.agent.md | a74e5eb7688bebd1942546741a26c6b3a9696328 | no
- .github/agents/docs-author.agent.md | f73c7ba103f24754c46fb1a91be70fc1f99c6f36 | no
- .github/agents/docs-coverage-reviewer.agent.md | 2c941fa080036787bdb971433a9928aea7395fd3 | no
- .github/agents/docs-reconciler.agent.md | c42cbf9c572c13cede8f6a1ad570e2975aac3f84 | no
- .github/agents/epic-review.agent.md | 0c6343156a2089c5d3b4036ffed11a8fd6ac8c5d | yes
- .github/agents/expert-nextjs-developer.agent.md | 850cd6382a4c7d0d0775a22d18fbdd95e356c963 | no
- .github/agents/expert-react-frontend-engineer.agent.md | 11db56673646153dc270e634e22bc1ecb5e363b8 | no
- .github/agents/feature-review.agent.md | 1ede1734d7d0e252a4ddd915d7ac5d82405186e2 | yes
- .github/agents/gpt-5-beast-mode.agent.md | 508374142ca14fbb0a8a34237946b310fbbde6b5 | no
- .github/agents/hlbpa.agent.md | 1e0f83b6f9cbec8ef986c8d6c5821f3b4ea33226 | no
- .github/agents/legacy-parity-analyst.agent.md | c0c44879867e2cc56efe02a9fbddb46b19cdddaf | no
- .github/agents/mentor.agent.md | 7adf92418d3a99a0cda924613bcc8768866b88e6 | no
- .github/agents/migration-coverage-reviewer.agent.md | 76191bf699a4a66e93fef9b6ca7090e3c539b240 | no
- .github/agents/orchestrator.agent.md | 8399203c8af18f687a47f9cb25a85bc4afc62aca | yes
- .github/agents/Powershell DI Unit Test Engineer.agent.md | 39865d6cad88f7d5699c3b1ebefb7e2b6579ea46 | yes
- .github/agents/powershell-atomic-executor.agent.md | ba8a20bc4970c82c95ed761564f17f8dc3d84b65 | no
- .github/agents/powershell-atomic-planning.agent.md | c1d6fb11ad4fafe2f75f20038ec7423dcf397d43 | yes
- .github/agents/powershell-orchestrator.agent.md | 27667f9b4293f066fe2bc3bfcb41a3b22f7e1334 | yes
- .github/agents/powershell-typed-engineer.agent.md | ebd866e2af5fcd584e4925ab006de851bf942781 | yes
- .github/agents/pr-author.agent.md | 09ff047487576cc7ada6401ff16b032b21124265 | no
- .github/agents/prd-feature.agent.md | 529a88e93e618a3ae3afe164b1a68fce9014a31d | yes
- .github/agents/prd.agent.md | ea9003cbbc7b8ba63dcad7d10a6254b666587fc3 | no
- .github/agents/pytest-unit-test-coding.agent.md | ced33825452f400ced91572947f1b1efe34e5b00 | yes
- .github/agents/python-atomic-executor.agent.md | 24c0cee2c3aa0fcfb036737e2dbfd81a5e6e2463 | no
- .github/agents/python-atomic-planning.agent.md | ac3012413df6be3c3e2bebdd2899ba6828b63635 | yes
- .github/agents/python-execution-only-typed.agent.md | 91e3936913f606496f34c2ee70ea4ad1f118d61a | yes
- .github/agents/python-orchestrator.agent.md | fc73915bd1cddfecb5989b7d550a1d6b65a2602b | yes
- .github/agents/python-typed-engineer.agent.md | f531d717fa51c2e225bc4178ef5bf03d247d2453 | yes
- .github/agents/requirements-reconciler.agent.md | 3013146bb09c254fcc596dd8e71f4642488c4b8f | no
- .github/agents/runtime-characterization-analyst.agent.md | 33ad9bd3df6e97508589e653688ffa37e81f0086 | no
- .github/agents/staged-review.agent.md | 15eecf0605899b68055bc1a6cec7314dc624f121 | yes
- .github/agents/status_updater.agent.md | 90a84a39a80f8600c1d8583ebf5d742ffd8cb52f | yes
- .github/agents/task-researcher.agent.md | 9d732f74428aaee59b06f66cca15cd08fa22b726 | no
- .github/agents/tdd-green.agent.md | dbc3c58de63d923dad7407c3c1043d4ad43ec2a5 | no
- .github/agents/tdd-red.agent.md | a5f746fe8f703ec561250f6e7f61450a92d11443 | no
- .github/agents/tdd-refactor.agent.md | 9481e1bba4af0954add9577bc69d8053d1e568dd | no
- .github/agents/typescript-engineer.agent.md | db0651f0f91a77af873e05b3a724bff6540b6423 | yes
- .github/agents/voidbeast-gpt41enhanced.agent.md | 9f9100fb1ea3fa33e4eafd0e1d42cbf405c5cf40 | no
