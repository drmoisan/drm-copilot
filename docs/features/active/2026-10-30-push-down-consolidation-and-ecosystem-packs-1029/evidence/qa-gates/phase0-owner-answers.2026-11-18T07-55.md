# Phase 0 Owner Answers (P0-T3)

Timestamp: 2026-11-18T07-55
Command: gh issue view 1029 --json state,comments,updatedAt; gh issue view 1018 --json state,comments,updatedAt; gh issue view 1029 --json body (searched for O-<n>, Q1, answer); gh issue view 1018 --json body (searched for O-<n>, Q1, answer, 1029); read spec.md `## Open Owner Questions`
EXIT_CODE: 0
Output Summary: Issue #1029 is open with 0 comments (last updated 2026-10-30T22:36:40Z); issue #1018 is open with 0 comments (last updated 2026-10-30T19:51:47Z). Neither body contains an answer to Q1 or O-1 to O-12. All thirteen questions take the spec's recommended default; no task, file set or assertion changes.

Result: PASS

| Question | Owner answered | Applied |
| --- | --- | --- |
| Q1 contracts delivered with skills | no | default: deliver each `references/standard.md` with its skill |
| O-1 pipeline is TypeScript MCP-command code | no | default: TypeScript |
| O-2 unified MCP tool | no | default: three wrappers only |
| O-3 apply requires a prior dry run | no | default: no; `dry_run` optional |
| O-4 differing files without a manifest | no | default: `unmanaged-conflict`, opt-in `overwrite_unmanaged` |
| O-5 omitted `packs` reuses recorded selection | no | default: yes, else full tree |
| O-6 pinned TypeScript declarations | no | default: unchanged |
| O-7 delete orphaned files | no | default: report only |
| O-8 exclusions for all ecosystems | no | default: yes |
| O-9 push generators down | no | default: no |
| O-10 root files published | no | default: yes (`AGENTS.md` shared; `CLAUDE.md`, `.mcp.json` Claude; `.github/copilot-instructions.md` Copilot) |
| O-11 manifest committed; no-op definition | no | default: committed; no file outside `artifacts/` changes |
| O-12 close manifest gaps | no | default: yes, with a Jest full-bundle completeness test |
