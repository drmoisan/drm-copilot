# Task Check P3-T1 (issue #1231)

Timestamp: 2026-11-24T00-34
Changed files:
- scripts/harness-generation/sources/rules/orchestrator-state.md (## Release-Commit Allowance Scope: release pull-request legs paragraph, three bullets, and the policy-level-control disclosure; the existing #1201 bullets, including `destination-owned` and the statement that the command leg never applies to a Write, Edit, or delegation call, are unchanged)
- .agents/skills/execution-environment/SKILL.md (## Hook Execution Context: `Release pull-request legs (#1231)` bullet; ## Contract Tests That Pin Mirrored Files: `release-pull-request.Parity.Tests.ps1` entry)
- .agents/skills/pr-author/SKILL.md (new `## Checkpoint-Free Release Delegation (issue #1231)` after the #1169 section; the #1169 section is unchanged)
- scripts/harness-generation/sources/agents/pr-author.md (head section: one Precondition sentence naming the docs-only, cleanup, and release exemptions)
Selection rule: Markdown sources; the contract tests that read their generated targets (HarnessGeneration.RepoGate.Tests.ps1, pr-author-docs-estate-delegation-contract.Tests.ps1, the brief byte-identity test, and the push-down resource tests) run in P3-T2 after the generator, because the generated targets differ from the sources until then.

Command: grep -c -F <token> over the four sources for RELEASE_EXEMPTION_, RELEASE_DELEGATION_, RELEASE_RECEIPT_, destination-owned, and policy-level control
EXIT_CODE: 0
Output Summary:
- rule source: RELEASE_EXEMPTION_ 1, RELEASE_DELEGATION_ 1, RELEASE_RECEIPT_ 1, destination-owned 1, policy-level control 6
- execution-environment brief source: RELEASE_EXEMPTION_ 1, RELEASE_DELEGATION_ 1, RELEASE_RECEIPT_ 1
- pr-author skill source: RELEASE_EXEMPTION_ 1, RELEASE_DELEGATION_ 1, RELEASE_RECEIPT_ 1
- pr-author agent source (head section): RELEASE_EXEMPTION_ 1 (the Precondition sentence names the gh pr create exemption, the applicable family)
