# Follow-up notes and decisions (issue #901)

Timestamp: 2026-10-12T18-23
Command: grep -c '^FOLLOW-UP: ' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/other/follow-up-and-decisions.2026-10-11T10-38.md
EXIT_CODE: 0
Output Summary:
- Three documentation follow-ups recorded; no issue created.
- Decisions D1 to D12 of plan section 3 recorded by identifier.
- Result: RECORDED

FOLLOW-UP: .claude/agents/pr-author.md (the missing-checkpoint deny statement) does not describe the docs-only exemption.
FOLLOW-UP: .claude/skills/pr-author/SKILL.md (the hook-validates-the-checkpoint statement) does not describe the docs-only exemption.
FOLLOW-UP: .claude/agents/orchestrator.md and .claude/skills/orchestrate/SKILL.md describe the orchestrated path, which is unchanged; their "subprocess seam" wording is already stale since issue #475.
ISSUE-CREATED: none

DECISION: D1 The exemption is consulted only in the non-epic branch of Get-PrAuthorBypassReason, after the preflight reports errors, so a passing checkpoint never reaches git.
DECISION: D2 Eligibility is evaluated in the order E1 to E7, and each failure keeps the ORCHESTRATOR_STATE_PREFLIGHT_FAILED prefix with one appended sub-code.
DECISION: D3 No default base is assumed; a missing --base denies.
DECISION: D4 All git access goes through Invoke-PrAuthorDocsOnlyGitExe, which never throws, and each call is additionally wrapped in try/catch.
DECISION: D5 The local-HEAD versus remote-head residual risk and a top-level try/catch around the decision are not hardened in this item.
DECISION: D6 Both [int] casts of the body number are replaced by ConvertTo-PrAuthorBodyNumber, which rejects overflow, leading zeros, and non-ASCII digits.
DECISION: D7 #850 L20 is recorded only; the merge-gate files are outside the scope boundary.
DECISION: D8 #850 L21, L22, and L23 are not changed; rationale is recorded.
DECISION: D9 The stale .NOTES sentence is corrected in both the main hook and the helpers file.
DECISION: D10 No existing suite is edited; the existing preflight-failure rows stop at E2 or E3 before any git call.
DECISION: D11 Agent and skill documentation is not edited; follow-ups are recorded above.
DECISION: D12 The new sibling contains no read primitive and no artifacts/ literal, and each new suite copies the baseline mock block and interception probe.
