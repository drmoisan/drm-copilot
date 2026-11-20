# Task Check P1-T12

Timestamp: 2026-11-19T10-02
Plan: plan.2026-10-30T18-39.md
Changed files: `docs/engineering/claude-code-architecture.md` — the skill row of `## 1. Copilot-to-Claude Equivalence Table` names the shared `.agents/skills/<name>/SKILL.md` source; `## 3. Sync Strategy` states that `.github/` is authoritative for the Copilot-native agents, prompts and hooks only; the `.claude/skills` and `CLAUDE.md` rows of `### Authoritative source by asset category` name `.agents/skills` and `AGENTS.md`; the migration map is headed `### Retired Copilot skill migration map`, carries a sentence holding `retired by issue #1032`, and its first column names `.agents/skills/<name>/SKILL.md` (with `.agents/skills/README.md` documentation-only); `### Manual sync procedure` describes regenerating `.claude/skills` from `.agents/skills` with child 3's generator and, as a related current-fact correction, the `CLAUDE.md` import of `AGENTS.md`. `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`: both `It` blocks (the new heading plus the `retired by issue #1032` sentence; `.agents/skills/README.md` documentation-only). `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: the row of `test_architecture_doc_lists_brief`.
Selection rule: tests that read the architecture document (`claude-architecture-doc.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `test_execution_environment_brief_contracts.py`, `test_discovery_documentation_contracts.py`), and the chain test, because entry 0005 holds a block on this document (REGION-MAP: outside for the edited anchors).

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `env -u VIRTUAL_ENV poetry run black --check` / `ruff check` / `pyright` (brief contract module) | 0 | unchanged; all checks passed; 0 errors |
| PSSA and formatter comparison (`claude-architecture-doc.Tests.ps1`) | 0 | 0 findings; 0 files differ |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` brief contracts and discovery documentation modules | 0 | 59 passed, including `test_architecture_doc_lists_brief` |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` `claude-architecture-doc`, `planning-contract-wording`, `ProcessReductionChain.Ledger` | 0 | Invoke-PoshQCParallelTest exit code 0 (workers 3, 118.37s) |
| Grep for RETIRED-PATH over the document and both tests | 0 | 0 matches (the brief contract module, which P1-T2 noted, now holds none) |
