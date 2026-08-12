# Translation Plan: Claude Parallel Runtime to Codex

Timestamp: `2026-08-10T20-25`

Mode: `apply`

Research basis:
`docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`

EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...

## Inputs

- `.claude/settings.json`, limited to the registered parallel hook and permission surfaces.
- `.claude/rules/parallel-orchestration.md`.
- The six delivered parallel skill contracts: `parallel-plan`, `parallel-run`,
  `parallel-orchestrate`, `parallel-add`, `parallel-remove`, and `parallel-close`.
  Their shared Codex targets are under `.agents/skills/`.
- `.claude/agents/parallel-planner.md` and
  `.claude/agents/parallel-orchestrator.md`.
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1`.
- `.claude/hooks/enforce-parallel-drift-gate.ps1` and its focused helper.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
- `.claude/hooks/enforce-parallel-abandon-gate.ps1`.
- The parallel `SubagentStop` registration that invokes
  `.claude/hooks/validate-orchestrator-output.ps1`.
- Existing Codex targets in `AGENTS.md`, `.agents/`, `.codex/`, and the CI
  workflow/test surfaces used as conflict and reuse inputs.

Skipped inputs are `.claude/agent-memory/**`, non-parallel Claude rules,
non-parallel skills and agents, unrelated hooks, and all runtime state.
`.claude/**` is immutable source input and is never a translation target.

## Mapping Table

| Source element | Kind | Codex target | Action | Trust required | Output class |
|---|---|---|---|---|---|
| Parallel skill contracts | skill | `.agents/skills/parallel-{plan,run,orchestrate,add,remove,close}/SKILL.md` | skip: already delivered and verified | no | shared skill |
| Parallel planner and orchestrator personas | agent | `.codex/agents/parallel-planner.toml`; `.codex/agents/parallel-orchestrator.toml` | skip: already delivered and verified | yes | agent profile |
| Parallel artifact rule | prompt-level rule | `AGENTS.md` plus the delivered shared skills and validators | skip: no duplicate invariant prose | no | instruction/validator |
| Native stdin and decision contract | process gate | `.codex/hooks/parallel-hook-common.ps1` | add | yes | hook module |
| Explicit root invocation and persona provenance | process gate | `.codex/hooks/authorize-root-parallel-invocation.ps1`; `.codex/hooks/enforce-parallel-root-invocation.ps1`; additive branches in existing routing hooks | add/merge | yes | hook and receipt validation |
| Cohort barrier | process gate | `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | add | yes | hook |
| Drift quiescence | process gate | `.codex/hooks/enforce-parallel-drift-gate.ps1` | add | yes | hook |
| Child/worktree/launch binding | process gate | `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | add | yes | hook |
| Matching worktree removal | process gate | `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | add | yes | hook |
| Confirmed detach/abandon | process gate | `.codex/hooks/enforce-parallel-abandon-gate.ps1` | add | yes | hook |
| Parallel child output stop validation | process gate | `.codex/hooks/validate-parallel-agent-output.ps1`; additive parallel dispatch in existing stop/completion hooks | add/merge | yes | continuation hook |
| Parallel permissions and absent per-agent tool allowlist | OS/process gate | targeted parallel profiles, agent bindings, MCP restrictions, and hook matchers in `.codex/config.toml` | merge | yes | permission/config |
| Parallel hook registrations | process gate | nested `UserPromptSubmit`, `PreToolUse`, `SubagentStart`, and `SubagentStop` handlers in `.codex/config.toml` | merge | yes | config |
| Registered transport and compatibility proof | test | `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1` plus focused extensions of existing epic/provenance/launcher suites | add/merge | no | test |
| Hard rejection after `SubagentStop` continuation | required merge gate | `.github/workflows/_poshqc.yml` and `.github/workflows/ci.yml` parallel completion validation | merge | no | CI backstop |
| Apply evidence | evidence | `<FEATURE>/evidence/other/translation-diff.2026-08-10T20-25.md` and `<FEATURE>/evidence/other/translation-snapshots/` | add | no | evidence |

## Action and Trust Summary

- Add: nine focused native hook entrypoints/modules, one registered-transport
  test owner, the translation diff, and target snapshots.
- Merge: existing routing/model/completion hooks, `.codex/config.toml`, focused
  PowerShell contract tests, and the two CI workflow surfaces.
- Skip: six already-delivered shared skills, two already-delivered Codex agent
  profiles, and duplicate parallel rule prose.
- Replace: none.
- Conflict: none.
- All `.codex/` config, hook, and agent targets require a trusted project and
  one-time hook trust review. Skills, tests, CI definitions, and evidence do
  not depend on Codex project trust at discovery time.

## Conflicts

None. Existing parallel skills and agent profiles are retained as verified
targets. Existing hooks and configuration receive additive branches or nested
handlers only; no existing permission, matcher, or behavior is removed.

## Target Files

### New files

- `.codex/hooks/parallel-hook-common.ps1`
- `.codex/hooks/authorize-root-parallel-invocation.ps1`
- `.codex/hooks/enforce-parallel-root-invocation.ps1`
- `.codex/hooks/enforce-parallel-cohort-barrier.ps1`
- `.codex/hooks/enforce-parallel-drift-gate.ps1`
- `.codex/hooks/enforce-parallel-child-worktree-binding.ps1`
- `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1`
- `.codex/hooks/enforce-parallel-abandon-gate.ps1`
- `.codex/hooks/validate-parallel-agent-output.ps1`
- `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1`
- `<FEATURE>/evidence/other/translation-diff.2026-08-10T20-25.md`
- `<FEATURE>/evidence/other/translation-snapshots/**`

### Updated files

- `.codex/config.toml`
- `.codex/hooks/record-subagent-routing-attestation.ps1`
- `.codex/hooks/enforce-codex-model-routing.ps1`
- `.codex/hooks/validate-codex-subagent-routing.ps1`
- `.codex/hooks/enforce-completion-consistency.ps1`
- `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1`
- `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1`
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- `.github/workflows/_poshqc.yml`
- `.github/workflows/ci.yml`

## Config Delta

- Additive permission profiles bind planner, orchestrator, and item-child
  filesystem/network authority without weakening existing profiles.
- Additive agent bindings retain the exact generated profile, model, reasoning,
  permission, topology, and model-routing receipts.
- Additive MCP enabled/disabled tool settings and PreToolUse matchers implement
  the tested compensation for the absent per-agent tool allowlist.
- Nested handlers are added under `hooks.UserPromptSubmit`,
  `hooks.PreToolUse`, `hooks.SubagentStart`, and `hooks.SubagentStop` using the
  current command/`command_windows`/timeout/status schema.
- No existing hook, permission, MCP server, agent, or matcher is removed.
- Required user-level trust precondition:
  `projects."C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25".trust_level = "trusted"`.
- The project requires one-time native hook trust review before local hook
  execution; CI uses its approved non-interactive hook trust mechanism.

## CI Backstops

- Add a required `parallel-completion-gate` path through the existing PoshQC
  reusable workflow and root CI workflow.
- The job runs the same full parallel state and immutable completion-receipt
  validators used by the root completion hook and fails on invalid final state.
- This CI check supplies the mechanical hard rejection that Codex
  `SubagentStop` continuation alone cannot provide.
- CI contract tests must resolve and prove the required job rather than infer it
  from a workflow filename.

## Enforceability Preservation Ledger

| Gate ID | Claude mechanical gate | Claude class | Codex target/control | Codex class | Status | Compensating control and test owner |
|---|---|---|---|---|---|---|
| G01 | Explicit root parallel invocation mints run authority | process-enforced | `authorize-root-parallel-invocation.ps1` plus the authority store | process-enforced | PRESERVED | Root/ordinary/child/epic provenance cases in `parallel-provenance.Tests.ps1` |
| G02 | Planner, orchestrator, and child per-agent tool allowlists | process-enforced | Exact agent profiles plus sandbox/permission boundaries, MCP restrictions, PreToolUse denial, and sealed external launch | OS- and process-enforced compensation | DEGRADED | Forced profile and permission denial in `parallel-provenance.Tests.ps1`, `parallel-child-worktree-launcher.Tests.ps1`, and registered transport tests |
| G03 | Only the parallel planner/orchestrator personas may receive root authority | process-enforced | `enforce-parallel-root-invocation.ps1` and topology receipt validation | process-enforced | PRESERVED | Root-persona positive and fallback-negative provenance matrix |
| G04 | Exact routed model, reasoning effort, and no fallback | process-enforced | Additive parallel branch in `enforce-codex-model-routing.ps1` with immutable routing receipts | process-enforced | PRESERVED | Parallel model-routing and no-fallback process cases |
| G05 | Mutations bind to the same authorized run identity | process-enforced | Shared mutation authority plus root authority/attestation receipt binding | process-enforced | PRESERVED | Add/remove/close/detach/abandon authority-positive and mismatch-negative cases |
| G06 | Planner remains planning-only and execution requires committed readiness | process-enforced | Planner permission profile, readiness validator, and committed kickoff binding | process-enforced | PRESERVED | Planner mutation denial and kickoff readiness contract suites |
| G07 | Per-call cohort admission blocks premature later-cohort launch | process-enforced | `enforce-parallel-cohort-barrier.ps1` over the shared receipt-bound cohort validator | process-enforced | PRESERVED | Registered allow/deny cohort-barrier process matrix |
| G08 | Retrospective cohort ordering rejects invalid persisted scheduling | process-enforced | Python/MCP orchestrator-state cohort validation on completion and resume | process-enforced | PRESERVED | Python/TypeScript receipt-cohort parity plus root-completion refusal |
| G09 | Unresolved drift quiesces admission and persists deterministic halt/requeue | process-enforced | `enforce-parallel-drift-gate.ps1` over shared Python/MCP drift decisions | process-enforced | PRESERVED | Registered drift gate plus six-case shared parity corpus |
| G10 | Child launch is bound to one exact item, repository, branch, worktree, and launch hash | process-enforced | `enforce-parallel-child-worktree-binding.ps1` and immutable launch receipt validation | process-enforced | PRESERVED | Wrong identity and bound-worktree launcher/process cases |
| G11 | Each item uses one current-head PR targeting `main`, with no integration/fan-in path | process-enforced | Parallel post-session and completion-receipt validators | process-enforced | PRESERVED | Exact-head, main-only, stale-check, and fan-in rejection tests |
| G12 | Only the matching merged item worktree may be removed | process-enforced | `enforce-parallel-worktree-removal-gate.ps1` plus completion receipt binding | process-enforced | PRESERVED | Registered removal gate and matching/remnant worktree tests |
| G13 | Detach/abandon requires the exact operation, item, worktree, and confirmation token | process-enforced | `enforce-parallel-abandon-gate.ps1` over the shared mutation authority | process-enforced | PRESERVED | Registered abandon allow/deny matrix and mutation parity corpus |
| G14 | Write-heavy children launch externally with isolated `CODEX_HOME` and immutable argv/environment | OS- and process-enforced | Shared child-launch core/runtime with bound worktree process execution | OS- and process-enforced | PRESERVED | Scheduler/process tests assert argv, environment isolation, hashes, exits, and streams |
| G15 | Filesystem, network, MCP, and mutation authority are least privilege | OS-enforced | Parallel `.codex/config.toml` permission profiles and MCP enabled/disabled tools | OS-enforced | PRESERVED | Permission-profile contract and forbidden tool/path process tests |
| G16 | Invalid `SubagentStop` output is hard-rejected before downstream use | process-enforced | One native continuation plus root refusal, immutable completion receipt, and required `parallel-completion-gate` CI status | process-enforced compensation | DEGRADED | One-continuation/repeat-stop tests and CI contract proving invalid final state fails the required job |
| G17 | Root completion requires the full transition validator and immutable terminal receipts | process-enforced | Parallel dispatch in `enforce-completion-consistency.ps1` plus the shared Python/MCP validators | process-enforced | PRESERVED | Completion allow/deny, residual worktree, open-mode, and receipt mismatch cases |
| G18 | Registered hooks use native stdin/decision/exit semantics and ignore legacy Claude environment variables | process-enforced | `parallel-hook-common.ps1` and nested `.codex/config.toml` handlers | process-enforced | PRESERVED | Registration-derived allow/deny/malformed/missing/poisoned-environment transport matrix |

Ledger totals: **16 PRESERVED, 2 DEGRADED, 0 LOST**.

Every mechanical source gate has exactly one row. `G02` and `G16` are the
only degraded rows. Their compensating controls are mandatory P4-T10 test
targets; a missing or failed control changes the corresponding row to `LOST`
and blocks apply.

## Output Classes

- Feature implementation: `.codex/hooks/**`, additive `.codex/config.toml`
  entries, existing hook branches, tests, and CI workflow updates.
- Evidence: translation plan, translation diff, and repository-relative target
  snapshots under `<FEATURE>/evidence/other/`.
- Immutable source: all `.claude/**` files.
- Out of scope: publisher/pack membership and portable payload publication,
  which remain assigned to Phase 5.

## Apply Boundary

`mode=apply` is authorized, but apply remains mechanically ordered behind the
completed P4-T2 ledger. P4-T3 through P4-T10 deliver and test the mapped native
controls. P4-T11 captures the deterministic diff and snapshots only after all
rows are conflict-free and both degraded controls are proven.
