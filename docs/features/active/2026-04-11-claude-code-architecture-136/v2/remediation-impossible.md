# Remediation Loop Analysis: Why the Review Agent Cannot Converge

**Date:** 2026-04-14
**Feature:** `feature/claude-code-architecture-136`
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Audit Cycles Reviewed:** 7 (T08-16, T09-58, T11-00, T11-06, T11-49, T22-07, T22-30)

---

## Summary

The feature review agent (`feature-review.agent.md`) has completed seven audit cycles on this feature without reaching a PASS verdict. The loop is structurally infinite under current conditions because of three independent causes.

---

## Root Cause 1: Seven acceptance criteria require a live Claude Code session that the reviewer cannot provide

Criteria 3, 4, 5, 6, 11, 12, 14 (mapped from `user-story.md`) require transcript-level evidence from a running Claude Code environment — invoking `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, probing the subagent allowlist, testing checkpoint resume, and verifying `SubagentStop` behavior.

The feature review agent runs inside GitHub Copilot / VS Code Chat. It does not and cannot run a Claude Code session. Every audit cycle follows the same path:

1. The reviewer evaluates these criteria as **UNVERIFIED** (correct per policy — no transcript exists).
2. The reviewer's rules state: *"Do not mark live-runtime criteria PASS without captured transcript or runtime evidence."*
3. The reviewer's rules also state: *"If remediation is needed, generate remediation inputs and delegate plan creation to atomic_planner."*
4. The remediation plan instructs the executor to "run the four skills in a live Claude Code session" — which the executor also cannot do.
5. The executor creates evidence notes stating "no live Claude Code session is available in this environment."
6. The next review cycle sees these as still UNVERIFIED and creates a new remediation input. Loop repeats.

**This is the primary infinite loop driver.** These 7 criteria are permanently unreachable by any agent in this runtime, but the agent's decision logic treats them as remediable defects.

---

## Root Cause 2: Each remediation cycle introduces new repo-controlled defects (cascade failures)

The progression across cycles demonstrates this:

| Cycle | What remediation fixed | What it broke |
|-------|----------------------|---------------|
| T08-16 → T09-58 | Orchestrator worker allowlist | PowerShell MCP test symbol still stale |
| T09-58 → T11-00 | Stale MCP symbol in runtime files | `.claude/settings.json` schema validation failure |
| T11-00 → T11-06 | Schema validation restored | Multi-folder `ScanFolders` transport binding error |
| T11-06 → T11-49 | Partial wrapper fix | All three PoshQC MCP wrappers still broken |
| T11-49 → T22-07 | Wrapper transport fully repaired | (No new functional break) |
| T22-07 → T22-30 | Checkpoint evidence refreshed | Three touched files now exceed 500-line limit |

The review agent is doing its job correctly on the repo-controlled defects — each cycle does fix the previous finding. The problem is that each code change introduces a new compliance violation, and the agent correctly flags it, which triggers another full loop iteration.

---

## Root Cause 3: Coverage accounting is unresolvable with current tooling

Every audit cycle flags "changed-scope coverage accounting" as unresolved. The reviewer requires per-changed-line coverage metrics, but the PowerShell coverage tooling (`Koverage`) does not emit that granularity. The reviewer correctly records it as unresolved, which contributes to the NEEDS REVISION / BLOCKED verdict, which contributes to remediation trigger, which cannot fix the tooling limitation.

---

## Structural Diagnosis

The feature review agent (`feature-review.agent.md`) has no mechanism to distinguish between:

- **Remediable blockers**: code defects that an executor can fix (stale symbols, wrapper bugs, file size violations)
- **Environment blockers**: validation gaps that require a fundamentally different runtime (live Claude Code session)
- **Tooling limitations**: metrics the current infrastructure cannot produce (per-line coverage)

Its decision function is: `if any criteria are not PASS → create remediation inputs → delegate to atomic_planner`. Since the 7 live-session criteria and the coverage gap can never reach PASS in this environment, the loop is infinite.

---

## Recommended Resolution Options

1. **Separate the acceptance criteria into "agent-verifiable" and "manual-verification-required" categories.** Add a mechanism in `spec.md` or `user-story.md` (or the review agent's rules) to tag criteria that require a specific runtime environment. The reviewer should report these as DEFERRED rather than triggering remediation.

2. **Add an exit condition to the review agent.** When the only remaining UNVERIFIED criteria are all environment-blockers that were already flagged in a previous cycle with no change to the blocking conditions, the reviewer should produce a "CONDITIONALLY PASS — pending manual live validation" verdict instead of creating another remediation cycle.

3. **Scope-reduce the acceptance criteria.** Remove or restructure criteria 3, 4, 5, 6 (live slash-command invocation), 11 (live allowlist probe), 12 (live checkpoint resume), 14 (live `SubagentStop`), and the equivalent spec.md items so they are documented as post-merge manual verification steps rather than automated review gates.

4. **Address the cascade-failure pattern.** The remediation executor should run the full toolchain (format → lint → type-check → test → file-size check) as a single validation gate *before* marking a remediation cycle complete, to prevent new defects from escaping into the next review cycle.
