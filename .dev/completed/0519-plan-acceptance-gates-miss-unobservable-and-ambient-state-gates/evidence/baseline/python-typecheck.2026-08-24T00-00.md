# Python Type-Check Baseline — [P0-T6]

Timestamp: 2026-08-26T07-53
Task: [P0-T6]
Command: `poetry run pyright`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8`
EXIT_CODE: 0

## Full output (4 content lines)

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6b0c3b38073271d8.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Exit-code capture method

Output redirected to a file; exit code read from `$?` with no pipe in the chain.

## Error and warning counts

**Errors: 0. Warnings: 0. Informations: 0.**

Read from the tool's own count line, `0 errors, 0 warnings, 0 informations`, not inferred from the exit code. `pyright` exits 1 when it reports any error, so the exit code and the count line agree.

## Two non-diagnostic lines, recorded rather than dropped

Two output lines are not diagnostics and do not affect the counts. They are reproduced above and characterized here so a later reader does not mistake either for a finding:

1. `venv .venv subdirectory not found in venv path ...` — a configuration notice. `[tool.pyright]` in `pyproject.toml` names a `venvPath`, and this worktree has no `.venv` subdirectory beneath it because the environment is Poetry-managed outside the worktree. Pyright falls back to the interpreter Poetry supplies through `poetry run`. The notice is emitted before analysis and does not suppress it: the run still produced a count line, and pyright reports a count line only after completing analysis.
2. The two-line new-version notice (v1.1.409 available as v1.1.411) — an advisory from the `pyright` Python wrapper, unrelated to the analyzed code. The installed version, 1.1.409, matches the version recorded in the `Environment` section of `issue.md`, so the baseline is taken on the version the defect was observed against.

Neither line contains an error or warning diagnostic, and neither is attributable to code in scope for this change.

## Write-mode status

`pyright` does not write. `[tool.pyright]` configures analysis only and the tool exposes no fix or write option, as recorded in the research document's Q3 inventory. It is therefore not a write-mode register member, and no observation-marker obligation attaches to it. The exit code plus the count line are the complete observation.

## Output Summary

`poetry run pyright` exited 0 reporting `0 errors, 0 warnings, 0 informations`. Two advisory lines were emitted — a `venvPath` notice caused by the Poetry-managed environment sitting outside the worktree, and a new-version advisory — neither of which is a diagnostic. No pre-existing Python type errors exist in this worktree at baseline.
