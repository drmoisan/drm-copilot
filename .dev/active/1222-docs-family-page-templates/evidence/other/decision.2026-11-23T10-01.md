# Autonomous-mode decisions during execution (issue #1222)

Timestamp: 2026-11-23T10-01

Decisions taken with the recommended option; none required the owner.

- D1, evidence Pester counts: PoshQC MCP results carry no output, so the Pester and static results come from artifacts/pester/pester-junit.xml, artifacts/pester/powershell-coverage.xml, shard logs, and direct runs from scripts under SCRATCH. Format step: a read-only format-drift check (Invoke-Formatter output compared with the file text) with the repository settings file; PSScriptAnalyzer run with the same settings and the reload-and-retry that Invoke-PoshQCAnalyze applies to its intermittent engine NullReferenceException. The PoshQC format MCP tool was also run once for the two edited test folders and realigned the helper return map.
- D2, task checks batched: a Pester task check of the Markdown-only tasks P1-T1 to P1-T6 cannot pass per task (the architecture-overview byte-identity cases need P1-T5 and P1-T6), so one selection run after P1-T6 is recorded by six task-check files. P3-T1 and P3-T2 share one selection run for the same reason (the RepoGate case fails between the source edit and regeneration).
- D3, ordering of Phase 2 files: the two new test files and the helper key were authored under SCRATCH during Phase 1 and placed in the tree after the Phase 1 gate, so no Phase 2 file entered the Phase 1 gate.
- D4, worktree Python environment: env -u VIRTUAL_ENV poetry install was run once after confirming that the in-project path resolves inside the worktree, so the pytest launcher and the generator check could run.
- D5, Codex bundle SKILL.md: the generator wrote the .claude copy and the Claude bundle copy only; the Codex bundle copy was copied byte-identically from the .agents source by script.
- D6, expect-fail tagging: Pester has no native expect-fail; the tag is a suffix in the test title that P3-T2 removed. The P2 gate evidence names the 64 expected failures.
- D7, test-lock queue timeouts: launcher exit 75 was retried until the machine lock was free and is recorded as queue timeout, not failure.
