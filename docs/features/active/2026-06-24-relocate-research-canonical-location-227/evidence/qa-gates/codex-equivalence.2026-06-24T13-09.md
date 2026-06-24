# Codex Translation Equivalence (P9-T6)

Timestamp: 2026-06-24T13-09
Command: grep counts for new-root references and `artifacts[/\\]research` matches across the six Codex files.
EXIT_CODE: 0

| Codex file | New-root refs | artifacts/research matches | Confirmed change |
|---|---|---|---|
| .codex/agents/task-researcher.toml | 7 | 0 | Embedded write-allowlist replaced with the two new Write globs (P5-T3); description, body output-location prose, constraint, and stop-hook body reference both new roots and the routing rule (P7-T1). No operational artifacts/research reference. |
| .codex/agents/orchestrator.toml | 1 | 0 | developer_instructions delegation prose references both new roots and the orchestrator routing rule (P7-T2). No artifacts/research reference. |
| .codex/hooks/enforce-evidence-locations.ps1 | 2 | 2 | 'artifacts/research/' added to the forbidden-prefix array and the docstring forbidden list (P4-T3); removed from the permitted list; docstring names the two new tracked roots. The 2 artifacts/research matches are the forbidden-prefix references (line 23 docstring forbidden list, line 71 $forbiddenPrefixes array) — correct operational rejection state, identical intent to the root hook. No permitted/routing artifacts/research reference remains. |
| .agents/skills/research-issue/SKILL.md | 4 | 0 | Output-path prose and description reference both new roots and the routing rule (P7-T3). No artifacts/research reference. |
| .agents/skills/orchestrate/SKILL.md | 1 | 0 | Delegation prose references both new roots and the routing rule; permitted-sub-path list no longer contains artifacts/research/ (P7-T4). No artifacts/research reference. |
| .agents/skills/evidence-and-timestamp-conventions/SKILL.md | 0 | 0 | artifacts/research/ removed from the allowed list (P7-T5). This file describes the allowed-path list only (not research routing), so it has no new-root reference by design; artifacts/orchestration/ remains. No artifacts/research reference. |

Acceptance: each Codex file reflects the new contract; no operational `artifacts/research/` path-routing reference remains. The only residual `artifacts/research/` strings (in the Codex enforce hook) are the intended forbidden-prefix entries that implement the rejection of the retired path, matching the root hook.
