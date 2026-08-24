# Parity Verification After [P2-T6] — Pair 6 (`.agents/skills/general-code-change/SKILL.md`) (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item; Passed: 1; Failed: 0; Duration: 0.11s
- Verbatim result line: `1 passed in 0.11s`

This is the last `.agents/**` mirror edit in Phase 2, so this run is the authoritative post-change `.agents`-family parity evidence referenced by `[P4-T9]` / AC 9.

Edits applied in this task (repo-root file and bundled copy edited identically):

- `.agents/skills/general-code-change/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`

| Line | Before | After |
|---|---|---|
| 44 | ``5. **Unit tests** (e.g., Pytest, Vitest, MSTest, Pester) including property-based tests where applicable per `quality-tiers.md` `` | ``5. **Unit tests** (e.g., Pytest, Jest, MSTest, Pester) including property-based tests where applicable per `quality-tiers.md` `` |

This is the same correction applied to `.claude/rules/general-code-change.md` in `[P2-T3]`, kept in lockstep across the two runtime families.

Byte-parity check (in addition to the parity test):
```
diff .agents/skills/general-code-change/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md
```
Exit code 0, no output — the two files are byte-identical after the paired edits.
