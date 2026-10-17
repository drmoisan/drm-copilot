# Command-route probe and Python environment (P0-T4)

Timestamp: 2026-10-16T23-20
Command: sh SCRATCH/tools/run-cr.sh cr-probe
EXIT_CODE: 0
Second command: sh SCRATCH/tools/run-cr.sh cr-python-env
Second EXIT_CODE: 0
Output Summary: The sh launcher runs recipes with PowerShell 7.6.6 from the worktree root (Pester 5.9.0, PSScriptAnalyzer 1.25.0). poetry install completed (99 installs) and the import probe printed PYTHON-IMPORTS-OK; PYTHON-ENV-READY.

CR-ROUTE: sh-launcher

Route note: the launcher is invoked with the forward-slash Windows form of SCRATCH (`C:/.../issue-962/tools/run-cr.sh`). A first attempt with the MSYS form (`/c/...`) was refused by PowerShell 7 as an unrecognized script path, because the launcher sets MSYS_NO_PATHCONV=1; the plan's term for SCRATCH ("the forward-slash form of the resolved path") is the `C:/...` form, which works.

## cr-probe output

```
RUN-CR: cr-probe
PROBE-PWSH: 7.6.6
PROBE-PESTER: 5.9.0
PROBE-PSSA: 1.25.0
PROBE-CWD-IS-REPO-ROOT: True
EXIT_CODE_COMPUTED: 0
```

## cr-python-env output (99 per-package `Installing` lines condensed; host path redacted)

```
RUN-CR: cr-python-env
PYENV-INSTALL: Installing dependencies from lock file
PYENV-INSTALL: Package operations: 99 installs, 0 updates, 0 removals
PYENV-INSTALL:   - Installing absl-py (2.4.0)
PYENV-INSTALL:   ... (97 further package lines, including black 26.1.0, pyright 1.1.409, pytest 9.0.2, pytest-cov 7.0.0, pyyaml 6.0.3, ruff 0.15.12)
PYENV-INSTALL:   - Installing wrapt (2.0.1)
PYENV-INSTALL: Installing <WORKSPACE_ROOT>\.venv\Scripts\tensorboard.exe over existing file
PYENV-INSTALL: Installing the current project: drm-copilot (0.1.1)
PYENV-INSTALL-EXIT: 0
PYENV-PROBE: PYTHON-IMPORTS-OK
PYENV-PROBE-EXIT: 0
PYTHON-ENV-READY
EXIT_CODE_COMPUTED: 0
```
