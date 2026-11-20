# Code Review: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
**Base Branch:** `main` (merge base `a90d522c6ac239bca858d7bc800d52860e823219`, equal to `origin/main`)
**Head Branch:** `bug/epic-subagent-nesting-depth` (`08e400844373251892289ce0c7562b1daff6af0e`)
**Review Type:** First review

---

## Executive Summary

The branch adds `.claude/hooks/epic-invocation-nesting-depth.ps1` (126 lines), wires it into `enforce-epic-invocation-origin.ps1` through the guarded dot-source pattern, and adds an Agent-tool preflight to `orchestrator.md` and the four coordinator agents, `## Nesting Depth` sections to seven skills, a brief line in six copies, bundle mirrors, a `core.json` entry, and a #1138 pin re-baseline.

The hook logic is correct. A real-process probe (`pwsh -NoProfile -File` on the head hook, the variable set in the child environment, envelope on stdin) confirmed that the check fires for exactly the chain pairs (main thread to each of the four coordinators, and each coordinator to `orchestrator`) and never for `orchestrator` to a specialist, main thread to `orchestrator` (the fallback path), or a coordinator to a non-`orchestrator` target. The origin rule still fires for an orchestrator caller. Mirrors are byte-identical, the six brief copies share one SHA-256, and the two pinned digests equal the SHA-256 of the head files.

One blocking finding: the coordinator agents are told to halt when a child returns `AGENT_TOOL_UNAVAILABLE:`, but not what to do when their own `Agent(orchestrator)` call is denied with `NESTING_DEPTH_INSUFFICIENT:`. Because all six coordinator skills run with `context: fork` (no Agent tool call, so the hook never sees the main-thread case for them), that deny is the signal a coordinator receives on the most likely path, and the agents give no instruction to halt instead of doing the child's work, which is the failure mode the issue reports.

**Top risks:**
1. F1 (blocking): coordinator response to the new hook deny is unspecified.
2. The hook reads only the configured value of the process environment; the settings `env` inheritance is an unverified spec assumption, so the instruction-level preflight remains the primary control.

**PR readiness recommendation:** **No-Go until F1 is fixed** (light remediation path).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.claude/agents/epic-planner.md`, `epic-orchestrator.md`, `parallel-planner.md`, `parallel-orchestrator.md` (and bundle copies) | `## Startup Protocol` lead paragraph | F1. The preflight covers two signals (Agent absent; child returns `AGENT_TOOL_UNAVAILABLE:`) but not a `NESTING_DEPTH_INSUFFICIENT:` deny of the coordinator's own `Agent(orchestrator)` call. The coordinator skills are `context: fork` with `agent:` set, so at a configured limit of 2 the coordinator keeps the Agent tool, passes its preflight, and its first `Agent(orchestrator)` call is denied by the hook. The agents give no instruction to halt and record `spawn_agent_unavailable` on that deny. | Add one sentence to each coordinator preflight paragraph: when an `Agent(orchestrator)` call is denied with a reason beginning `NESTING_DEPTH_INSUFFICIENT:`, halt with that reason, record `spawn_agent_unavailable`, and do not do the child's work. Mirror to the bundle, re-baseline the `epic-orchestrator.md` pin, and add the literal to the coordinator case of `NestingDepthContract.Tests.ps1`. | The issue's reported failure includes a coordinator doing child work itself; the branch introduces the deny signal without wiring the halt for it. | Skill frontmatter (`context: fork`, `agent: epic-planner` etc.); real-process probe: `epic-planner` caller to `orchestrator` at limit 2 returns `deny` with `NESTING_DEPTH_INSUFFICIENT:`; `grep` of the four agent files shows no `NESTING_DEPTH_INSUFFICIENT` reference |
| Low | `.claude/hooks/epic-invocation-nesting-depth.ps1` | `Get-EpicInvocationNestingDepthDenyReason`, `[int]::TryParse` | A value above `Int32.MaxValue` (probe: `99999999999`) denies with "is not an integer", although it is an integer and a sufficient limit. | Optionally parse as `[long]`, or word the message as "is not an integer in the supported range". | Fail-closed outcome is acceptable; the message is inaccurate. Such a value is unlikely in practice. | Real-process probe returned `deny` for `99999999999` |
| Info | `.claude/skills/*/SKILL.md` | `## Nesting Depth`, Fallback paragraph | The fallback tells the main session to launch each `Agent(orchestrator)` "with the same delegation prompt the coordinator would have sent", but does not say how the main session obtains that prompt once the coordinator has halted. | None required now; spec non-goals exclude making the coordinator emit launch prompts (research option C2). Consider a follow-up if operators need the fallback. | Spec-accepted design limitation. | `spec.md` Non-goals |
| Info | `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` | `hook integration` context | No hook-level allow case for `orchestrator` to a specialist or main thread to `orchestrator` at limit 2; both are covered at helper level ("caller and target matrix") and were confirmed by the reviewer's real-process probe. | Optional: add one allow `It` at hook level for `orchestrator` to `atomic-executor` at limit 2. | Pins the never-block-specialists property at the integration seam. | Test source; probe output |

No covered file reaches 700 lines (largest: `test_parallel_orchestrator_surface_contracts.py`, 499 logical lines; helper 126; origin hook 295); no file-size Warning applies and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well
- Decision logic isolated in a helper with a single environment reader (`Get-SubagentSpawnDepthSetting`), enforced by an AST test.
- `Test-EpicInvocationNestingDepthApplies` is a two-branch predicate: a null or whitespace caller applies only to the four coordinator targets; a non-null caller applies only when it is a coordinator and the target is exactly `orchestrator`. An `orchestrator` caller is never in the coordinator set, so no orchestrator-to-specialist delegation can be denied by the depth check.
- The depth check runs after target resolution and the anomaly deny, and before the non-gated allow; an empty or absent target never applies.
- Guarded dot-source: a load failure is recorded through `Add-HookDependencyFailure`, so `Invoke-EpicInvocationOriginDecision` denies with `EPIC_INVOCATION_ORIGIN_BLOCKED:` naming the helper (B1 row and "guarded import failure denies").
- Invariant-culture parse of the trimmed value; a set non-integer fails closed.
- `core.json` lists the helper next to the origin hook, so a push-down that delivers the hook also delivers its dependency (otherwise the dependency-failure deny would block every Agent call, since the hook runs on the `Agent` matcher).

#### Real-process probe (reviewer, head hook, cwd under `docs/`)

| Limit | Caller | Target | Decision |
|---|---|---|---|
| 2 | main | epic-planner, parallel-orchestrator | deny `NESTING_DEPTH_INSUFFICIENT:` |
| 2 | epic-planner, parallel-planner | orchestrator | deny `NESTING_DEPTH_INSUFFICIENT:` |
| 2 | orchestrator | atomic-executor, task-researcher | allow |
| 2 and 1 | main | orchestrator | allow |
| 2 | epic-planner | atomic-planner | allow |
| 2 | orchestrator | epic-planner | deny `EPIC_INVOCATION_ORIGIN_BLOCKED:` |
| unset, whitespace | main | epic-planner, epic-orchestrator | allow |
| 3 | epic-orchestrator | orchestrator | allow |
| abc | main | epic-orchestrator | deny (parse message) |

#### Mirror and pin parity
- `cmp` of all 15 live agent, skill, and hook files against `extensions/drm-copilot/resources/claude-customizations/.claude/`: identical.
- Six execution-environment brief copies: one SHA-256 prefix `2ddae7a97c819ddb`.
- `PINNED_FROZEN_SURFACE_HASHES`: `68e32052…` and `07c02db2…` equal the SHA-256 of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` at the head.
- Codex generator `--check` exits 0; no `.codex/` path and no added `.py` file in the diff.

### Python implementation audit
Test-only: a digest re-baseline with a #1138 comment block and a heading count of 17 with an updated docstring. No production Python changed.

### TypeScript and C# implementation audits
N/A. No TypeScript or C# file changed.

---

## Agent Preflight and Skill Wording

- The five agent preflights name both remedies and the three causes, place the check before step 1, and say "do no specialist work". The four coordinators add the child-halt rule. See F1 for the missing hook-deny case.
- The seven `## Nesting Depth` sections state the depth layout, the 2.1.219 and limit-3 requirement, main-session invocation, the outcome, and the fallback with `Preparation mode: true`. The `orchestrate` section correctly states that the main-session path needs depth 1 only, consistent with that skill having no `context: fork`.
- The depth model (limit N withholds Agent at depth N) is consistent across the agents, skills, brief, hook messages, and research.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1`, `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1`, the edited origin suite, and the two Python test files.
- `evidence/qa-gates/pester-final.2026-11-08T18-06.md`, `poshqc-static-final.2026-11-08T17-53.md`, `pytest-final.2026-11-08T18-06.md`, `python-static-final.2026-11-08T17-54.md`, `self-review.2026-11-08T18-09.md`.

### Quality assessment prompts
- Tests mock the seam per `It`, set no environment variable, and write no file.
- The matrix covers all eight applying pairs and four non-applying pairs; the contract suite asserts per-file literals with file-naming failure messages and byte-compares 14 bundle copies.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection |
| No unsafe subprocess or command construction | PASS | The helper starts no process |
| Input validation at boundaries | PASS | Trimmed invariant-culture parse; non-integer fails closed |
| Error handling remains explicit | PASS | Guarded dot-source denies on import failure |
| Configuration / path handling is safe | PASS | `Join-Path` from `$PSScriptRoot`; probe from a subdirectory cwd behaved identically |

---

## Research Log

No external research was required. Platform behavior was taken from `research/research.2026-11-08T16-51.md`.

---

## Verdict

REMEDIATION_REQUIRED. One blocking finding (F1, autonomous, contained) on the light path. The hook check is correct for every caller/target pair probed, never blocks orchestrator-to-specialist delegations, and mirrors and pins are in parity.
