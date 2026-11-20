# Mirror Parity and Protected Regions — Issue #1106 (P5-T2)

Timestamp: 2026-11-07T15-13
Command: sh SCRATCH/issue-1106-parity.sh (pair hashes over every bundle path in `git diff --name-only MB HEAD`; `git show MB:<file>` and `git show HEAD:<file>` occurrence counts of ten protected tokens per changed .md/.toml file; `git diff --word-diff=porcelain MB HEAD` over the seven Q5 same-line overlap files) followed by sh SCRATCH/issue-1106-gen.sh check (PY -m scripts.dev_tools.generate_codex_agent_variants --check). MB = merge base of origin/main and HEAD.
EXIT_CODE: 0
Output Summary: `git status --porcelain` empty. 29 canonical-and-bundle pairs changed since MB, all EQUAL. Generator `--check` exit 0. Protected-token counts equal at MB and HEAD for every changed policy file and bundle copy. Same-line overlap lines change only the named version or framework token. `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` is absent from `git diff --name-only MB HEAD` (count 0).

## Pair check (canonical vs bundle, `git hash-object`)

All 29 pairs EQUAL: `.claude/agents/csharp-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/rules/csharp.md`, `.claude/rules/powershell.md`, `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.codex/agents/csharp-atomic-executor.toml`, `.codex/agents/powershell-di-unit-test-engineer.toml`, `.codex/agents/powershell-typed-engineer.toml` and its `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants, `.github/agents/Powershell DI Unit Test Engineer.agent.md`, `.github/agents/commit-steward.agent.md`, `.github/agents/csharp-atomic-executor.agent.md`, `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/tdd-red.agent.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/prompts/generate-commit-message-repo.prompt.md`, `.github/prompts/remediate-comments.prompt.md`, `docs/features/templates/policy_audit/AGENTS.md`, `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`.

## Protected-token counts (MB / HEAD)

Tokens: `>= 90%`, `85%`, `75%`, `single gate run`, `debugging only`, `Invoke-PoshQCParallelTest`, `poetry run pytest -n auto`, `N/A - no pre-change run`, `run_poshqc_test`, `parallel test gates`.

Every changed policy file (canonical and bundle, 61 files including README.md, pyproject.toml, and docs/features/templates/policy_audit/README.md) reports identical MB and HEAD counts for all ten tokens. Examples: `.claude/skills/csharp-qa-gate/SKILL.md` `>= 90%` 1/1, `single gate run` 7/7, `debugging only` 1/1; `.claude/rules/csharp.md` `85%` 1/1, `75%` 3/3; `.claude/rules/powershell.md` `85%` 2/2, `run_poshqc_test` 1/1; policy-audit template `>= 90%` 1/1, `Invoke-PoshQCParallelTest` 4/4, `poetry run pytest -n auto` 5/5, `N/A - no pre-change run` 5/5.

Excluded from the count comparison: `docs/features/potential/promoted/2026-11-07-policy-file-consistency-mstest-pester6.md`, the issue's lifecycle record added by this branch (not present at MB, not a policy file). Its MB count is undefined, not a changed protected region.

## Same-line overlap word diffs (MB..HEAD)

Removed/added word pairs across `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`, `.claude/rules/powershell.md`, `.agents/skills/powershell/SKILL.md`, `README.md`: only `(v5.x)**:`->`(v6.x)**:`, `(v5.x)`->`(v6.x)`, `xUnit`->`MSTest`, `**xUnit`->`**MSTest`, `xUnit)`->`MSTest)`, `v5`->`v6`, `v5):`->`v6):`, `(xUnit`->`(MSTest`, `` `Verify.Xunit` ``->`` `Verify.MSTest` ``. No other word changes on the overlapping lines.

`.github/instructions/python-unit-test.instructions.md`: one removed word (`--cov=src/lexile_corpus_tuner`) and no added word on the approved-command line (verified in P3-T1; the word begins with `-`, so the porcelain filter used for the other files does not print it).
