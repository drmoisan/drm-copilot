# Follow-ups for the Orchestrator to File (P12-T1)

Timestamp: 2026-10-01T23-14
Task: P12-T1
Source: `spec.md` `## Rollout & Follow-up`, "Post-fix monitoring or clean-up tasks", items 1-7. Item 1 is the AC-6 write-up in `spec.md` `## Out-of-Scope Follow-up: Published-MCP Contract Lag`.
Filing route: the orchestrator files these through the MCP promotion path. The executor has not filed any of them.

1. Detect published-MCP contract lag before orchestration: compute a deterministic contract fingerprint (blocked-reason members, generated agent families, routing matrix, remediation-loop vocabularies) in Python and in the TypeScript server, expose it with the package version through an MCP tool, and add an orchestrator S0 preflight in both orchestrate skills that records a mismatch as an `external_dependency` halt. Source: `spec.md` `## Rollout & Follow-up` item 1 and `## Out-of-Scope Follow-up: Published-MCP Contract Lag` (title, summary, scope, rationale; issue AC-6).
2. Reconcile the flat `remediation-inputs.<timestamp>.md` form with the `remediation/<entry-ts>/remediation-inputs.md` form prescribed by the remediation-handoff skills. Source: `spec.md` `## Rollout & Follow-up` item 2; research section 1.3.
3. Resolve the TypeScript `blocking_count: false` divergence from Python and PowerShell. Source: `spec.md` `## Rollout & Follow-up` item 3; research section 5.1.
4. Apply the verdict and accounting contract to the Copilot `.github/` surface and its mirrors. Source: `spec.md` `## Rollout & Follow-up` item 4; research section 6.
5. `no_staged_changes` in `.agents/skills/orchestrator-workflow/SKILL.md` is a validator-rejected literal on the no-candidate path; the #523 follow-up 1 that covers it should account for the `candidate_applied` recording. Source: `spec.md` `## Rollout & Follow-up` item 5.
6. Python `response not in HUMAN_INTERACTION_RESPONSE_ENUM` in `_orchestrator_state_human_interaction.py` likely raises `TypeError` for list or dict values (inference; not executed). Source: `spec.md` `## Rollout & Follow-up` item 6.
7. TypeScript cannot distinguish JSON `2.0` from `2`, so the integer checks (R7a, R11) accept a float-formatted integer that Python rejects; the corpus excludes floats. Record for the cross-runtime rendering follow-up. Source: `spec.md` `## Rollout & Follow-up` item 7.

## Additional observations from execution (not spec follow-ups; for the orchestrator's judgment)

- The folder-scoped Pester run over `tests/scripts/claude-lib/orchestrator-state` fails 38 cases in `OrchestratorStateIssueAdoption.Tests.ps1` (an issue #509 file) with `The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized`; the same cases pass in the full PoshQC gate. Present at baseline (P0-T30) and unchanged (deviation D10).
- The full PoshQC gate fails two hook tests that were already failing at baseline (P0-T32): `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` and `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`.
