# Phase 0 — Policy Instructions Read (P0-T1)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Plan:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/plan.2026-08-07T11-11.md`
- **Task:** [P0-T1]

Timestamp: 2026-08-08T16-47

Policy Order:

1. `CLAUDE.md` — standing instructions (tone policy, policy compliance reading order, language-specific rule routing, four-layer runtime architecture).
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, module rigor tiers, mandatory seven-stage toolchain loop, 500-line file size limit, error handling, naming, I/O boundaries).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (five core principles, coverage requirements line >= 85% / branch >= 75%, coverage exclusion policy, scenario completeness, Arrange-Act-Assert, external dependency prohibitions, test file location, determinism infrastructure).
4. `.claude/rules/python.md` — Python toolchain and coding standards (Black, Ruff, Pyright, Pytest with `--cov --cov-branch --cov-report=term-missing`; PEP 8 naming, strong typing, dependency seams, Pytest rules, prohibited behaviors).
5. `.claude/rules/python-suppressions.md` — pre-authorized Ruff `# noqa` and Pyright `# type: ignore` suppression patterns, the escalation path before requesting approval, and the explicitly-not-authorized list.

Files Read (explicit list, in the order above):

- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69\CLAUDE.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69\.claude\rules\general-code-change.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69\.claude\rules\general-unit-test.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69\.claude\rules\python.md`
- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69\.claude\rules\python-suppressions.md`

Additional standing rules loaded in session context by path-scoped activation (recorded for completeness; not part of the five-file required order): `.claude/rules/tonality.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md`.

Command: Read tool invocations against the five paths listed above (no shell command required).

EXIT_CODE: 0

Output Summary: All five required policy files were read in the mandated `policy-compliance-order` sequence. Governing constraints carried forward into execution: seven-stage toolchain loop restarting from step 1 on any failure or file change; Python loop Black -> Ruff -> Pyright -> Pytest with coverage; uniform coverage thresholds line >= 85% and branch >= 75%; 500-line file size limit for test and production code; tests live under `tests/` mirroring source structure; no temp files or external processes in unit tests; suppressions only per pre-authorized patterns; policy files under `.claude/rules/` and `.github/instructions/` must not be modified.
