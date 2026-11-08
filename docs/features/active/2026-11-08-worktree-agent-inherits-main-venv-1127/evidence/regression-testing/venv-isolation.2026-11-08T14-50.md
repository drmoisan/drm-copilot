# AC20 integration evidence: worktree install leaves the main .venv unchanged (P3-T1)

Timestamp: 2026-11-08T14-50
Command: sh SCRATCH/issue-1127-venv-snapshot.sh before; env -u VIRTUAL_ENV poetry install (from <item worktree>); env -u VIRTUAL_ENV poetry env info -p; sh SCRATCH/issue-1127-venv-snapshot.sh after; cmp SCRATCH/issue-1127-venv-snapshot-before.txt SCRATCH/issue-1127-venv-snapshot-after.txt
EXIT_CODE: 0
Output Summary:
- Snapshot script: lists the names and contents of the `*.pth` files in `<main checkout>/.venv/Lib/site-packages` and runs that environment's `python -m pip list` (listing only, no install).
- `before` snapshot: 119 lines, 4 `.pth` files (`drm_copilot.pth` points at `<main checkout>`).
- `env -u VIRTUAL_ENV poetry install`: exit 0; "No dependencies to install or update"; installed the current project into the worktree environment.
- `env -u VIRTUAL_ENV poetry env info -p`: exit 0; result `<item worktree>/.venv`.
- `after` snapshot: 119 lines, 4 `.pth` files.
- `cmp` before vs after: EXIT_CODE 0 (byte-identical). The main checkout's `.pth` files and installed package list are unchanged.
