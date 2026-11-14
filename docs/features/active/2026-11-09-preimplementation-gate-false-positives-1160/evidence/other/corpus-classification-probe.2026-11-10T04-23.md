# Corpus Classification Probe on the Unfixed Gates (P1-T2 precondition check)

Timestamp: 2026-11-10T04-22
Command: sh SCRATCH/issue-1160-probe.sh (PowerShell 7: dot-source the gate file, then `Test-ImplementationCommand -Command <row>` for every candidate row of the planned corpus), run once with `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and once with `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
EXIT_CODE: 0
Output Summary: Two AC-2 rows are not classified by today's gate on either surface: `pwsh -c "Invoke-Expression 'pytest'"` returns False, and `pwsh -c "[Diagnostics.Process]::Start('pytest')"` returns False. Every other research 6.2 row returns True, every research 6.3 row returns True (denied today, as expected for the fail-before), and every AC-3 non-goal row returns False on both surfaces.

## Why the two rows are unclassified today

- Stage 1 is the five unchanged patterns over `ScanText`. A `pwsh`-led segment is scanned raw. In both rows the word `pytest` is preceded by a single quote, not by whitespace or the start of the text, so pattern index 1 (`(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b`) does not match. Neither row contains `Invoke-Pester` or `tests/scripts/`, so pattern index 4 does not match. Neither row stages, so `$isStaging` is false.
- The spec's own invariants say stage 1 is unchanged and the change only removes classifications (`### Boundaries and invariants to preserve`, `#### Backward-compatibility expectations`, AC-3). So these two rows cannot be classified after the change either.

## Consequence for the plan

- Spec AC-2 lists both rows verbatim as classified and denied with today's deny text. Today's gate allows both. The criterion cannot be met for these two rows without widening stage 1, which AC-3 and D1 prohibit.
- [P1-T2] requires every AC-2 command to appear verbatim in the existing-denial table with its expected classification, and [P1-T3] asserts the existing-denial table as classified with the generic deny text. Both assertions would fail permanently for these two rows.

## Rows probed (both surfaces agree on every row)

- Research 6.2 and AC-2 (True on both, except the two rows above): `poetry run pytest tests/scripts`, `git add .`, `git commit -m "test"`, `poetry run black scripts --check`, `npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`, `git -C ../other-worktree add .`, `git --git-dir=../other/.git commit -m wip`, `git --work-tree=../other add .`, `git --future-unmodeled-option add .`, `(git add .)`, `$(git add .)`, `echo scripts/powershell/Sample.ps1 | xargs git add`, `bash -c 'git add .'`, `sh -c "git add ."`, `env git add .`, a `git add .` heredoc piped into `bash`, `echo "$(git add .)"`, `git add src/app.ps1`, `poetry run black src/`, `npx prettier --check .`, `git add src/feature.ps1`, `bash -c "git add src/feature.ps1"`, `git add docs/features/epics/sample/epic.md && poetry run pytest`, `env -u VIRTUAL_ENV poetry run pytest`, `timeout 60 pytest`, `FOO=1 pytest`, `python -m pytest`, `pytest | tee out.txt`, `echo pytest | bash`, a `pytest` heredoc piped into `bash`, `pwsh -NoProfile -File tests/scripts/run.ps1`, `pwsh -c "& ./tests/scripts/x.ps1"`, `xargs -n1 pytest`, `find . -name x -exec pytest {} ;`, `npm install prettier`, `rg --pre pytest x`, `git grep -O vim pytest`, `command -v pytest`, `echo "pytest`.
- Research 6.3 and AC-1 (True on both today): `ps aux | grep pytest`, `ps -ef | grep -i pytest`, `pgrep -f pytest`, `Get-Process -Name pytest`, `rg -n pytest pyproject.toml`, `grep -rn ruff docs/`, `git log --grep pytest`, `git grep black`, `which pytest`, `Get-Command pytest`, `poetry show pytest`, `pip show black`, `npm ls prettier`, `cat pytest.ini`, `echo git add docs`, `pwsh -NoProfile -Command "Get-Process | Where-Object { $_.CommandLine -match 'Invoke-Pester' }"`, `pwsh -c "Select-String -Path x -Pattern Invoke-Pester"`.
- AC-3 non-goals (False on both): `.venv/bin/pytest`, `npx --yes jest`, `node run-jest.cjs`, `npm test`, `Invoke-PoshQCParallelTest`, `Invoke-Pester`, `sh artifacts/launcher.sh`.
