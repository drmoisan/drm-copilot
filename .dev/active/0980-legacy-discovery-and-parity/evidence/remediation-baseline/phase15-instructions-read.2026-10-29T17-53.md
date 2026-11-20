# Phase 15 instructions read and remediation baseline (remediation cycle 1)

Timestamp: 2026-10-29T17-53
Command: git status --porcelain; git branch --show-current; git merge-base origin/main HEAD
EXIT_CODE: 0
Output Summary: working tree clean (zero porcelain lines) on `feature/legacy-discovery-and-parity-980`; the scope anchor is the merge base of origin/main and HEAD; every policy file, the four review artifacts and the research were read in full before any implementation task; no implementation has preceded this record (the only change since the review set is the preflight fix record and four in-place task-text fixes).

## Policy Order (policy-compliance-order)

1. .github/copilot-instructions.md
2. .github/instructions/general-code-change.instructions.md
3. .github/instructions/general-unit-test.instructions.md
4. Language-specific, for the three languages Phase 15 touches:
   - .github/instructions/python-code-change.instructions.md
   - .github/instructions/python-unit-test.instructions.md
   - .github/instructions/powershell-code-change.instructions.md
   - .github/instructions/powershell-unit-test.instructions.md
   - .github/instructions/typescript-code-change.instructions.md
   - .github/instructions/typescript-unit-test.instructions.md

The runtime also loaded the mirrored rule files CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, .claude/rules/quality-tiers.md, .claude/rules/tonality.md, .claude/rules/plan-acceptance-gates.md, .claude/rules/python.md, .claude/rules/python-suppressions.md, .claude/rules/self-explanatory-code-commenting.md and .claude/rules/powershell.md.

## Files read

Policy (in the order above): the nine files listed under Policy Order.

Review set (stamp 2026-10-29T13-16):
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/policy-audit.2026-10-29T13-16.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/code-review.2026-10-29T13-16.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/feature-audit.2026-10-29T13-16.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/remediation-inputs.2026-10-29T13-16.md

Research:
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/research/2026-10-29T13-16-host-identity-sources-research.md

Plan of record: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md (preamble, `## Revision: remediation cycle 1 (host identity from hook payloads)`, Phases 15 and 16, and the Set P, Q and R dispositions). Hard-lock prompt: artifacts/hard_lock_prompt.txt.

## Head state

- Branch: `feature/legacy-discovery-and-parity-980`
- `git status --porcelain`: empty
- Scope anchor: the merge base of origin/main and HEAD (derived with `git merge-base origin/main HEAD` at write time; the review set recorded the same derivation)

## The eight decisions of the revision section (final; no task reopens them)

1. Identity comes from each host's own hook payload and fails closed: `agent_id` with a discovery `agent_type` is a specialist, `agent_id` absent is the root, `parent_agent_id` (Copilot `parentAgentId`) is the parent when present, else the literal `root`; every `DRM_DISCOVERY_*` read site is removed from PowerShell, TypeScript and tests.
2. The PreToolUse hook writes a one-use root grant for a root call of `prepare_discovery_agent`, `run_discovery_doctor`, the sentinel tool and every controlled tool called without `invocation_ref` (user option A, including the read-only controlled tools); the server consumes it by tool, operation and input digest; root setup tools keep `local-user` without a grant; `run_discovery_doctor` without a grant answers `unsupported` with `context-missing`; `prepare_discovery_agent` and every controlled call without a grant refuse; nothing falls back to `local-user` for a controlled call.
3. A specialist's controlled call is bound by `invocation_ref`: the hook requires `tool_input.invocation_ref` to equal the `invocation_id` of the one started invocation bound to the payload `agent_id`; the server resolves the partition from `invocation_ref` alone, consumes by `invocation_ref` plus input digest, and takes identity from the consumed record.
4. Binding happens at the specialist's first controlled PreToolUse on every host: with no started invocation for `agent_id`, exactly one `prepared` invocation for the payload session, parent and agent type is started by the gate; zero or more than one denies. Equality of `agent_id` between SubagentStart and PreToolUse is not assumed.
5. Start hooks are observational on every host: they record the attestation when exactly one prepared invocation matches and never claim to prevent a start.
6. The capability probe proves attribution from host observations written by the gate for a sentinel agent and reports `unsupported` otherwise; presence of `agent_id` on a host's PreToolUse for MCP calls inside a subagent is observed, never assumed; the VS Code legacy Local harness is unsupported.
7. `.github/hooks/discovery.json` adopts the documented Copilot shape (`version` 1, `powershell` and `bash` keys) and the converter fixture follows.
8. The installed-host evidence stops claiming real-host coverage from environment-variable launchers.

## Remediation baseline: gate figures the review verified

| Language | Figure | Source artifact |
| --- | --- | --- |
| Python | 96.70% lines, 93.62% branches (15668 passed, 6 skipped) | evidence/qa-gates/p14-python-tests.2026-10-29T12-45.md; parsed by the review from artifacts/python/lcov.info |
| PowerShell | 93.28% lines (20003/21443; 12605 passed, 10 skipped) | evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml |
| TypeScript | unverified (executor records only: extension 97.13% / 93.58%, root 98.22% / 93.3%; no retained artifact; ten changed executable files without a per-file threshold) | evidence/qa-gates/p14-typescript-{root,extension}-tests.2026-10-29T10-50.md; review finding R1 |

Review verdict: REMEDIATION_REQUIRED, proportionate mode; blocking findings R1 (TypeScript coverage artifact absent), R2 (evidence-location validator exits nonzero), R3 (probe self-attests trusted attribution), R4 (no production supplier of the trusted agent identity); one Major (Python re-admits a consumed grant and ignores `expires_at`) and the Minor items the remediation inputs list.

## Scratch location

SCRATCH resolves to the session scratchpad under `issue-980/`; scratch file names of this cycle start with `issue-980-p15-` or `issue-980-p16-`. No scratch path is recorded in evidence.
