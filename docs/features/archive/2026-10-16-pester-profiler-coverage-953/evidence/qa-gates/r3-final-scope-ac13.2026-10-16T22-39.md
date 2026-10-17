# r3 Final Scope, AC-13 and Check Name (P5-T13)

Timestamp: 2026-10-16T22-39
Command: git diff --name-only origin/main...HEAD; git status --porcelain; git diff --numstat 7558c7e42ec8c8955cb5f9997cca41afc6e3b797 -- .github/workflows (Bash tool); export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $mb = (git merge-base origin/main HEAD).Trim(); for every .github/workflows/*.yml compare the on: block (from ^on: through the line before the next ^\S line) of the worktree file with git show "${mb}:.github/workflows/<name>"; count lines matching ^  poshqc:\s*$ and ^    name: PowerShell QC\s*$ in .github/workflows/_poshqc.yml' (SCRATCH/issue-953-r3-p5-t13.sh)
EXIT_CODE: 0
Output Summary:
- `.github/workflows/ci.yml` in `git diff --name-only origin/main...HEAD`: 0 lines; in `git status --porcelain`: 0 lines.
- MERGE_BASE=d72ec6a1010223f7036b9c3d15dad102ae262f98
- on: block comparison: 14 workflow files, each identical=True; ON_BLOCK_DIFFERENCES=0
- `git diff --numstat 7558c7e42ec8c8955cb5f9997cca41afc6e3b797 -- .github/workflows`: empty (no workflow change in this cycle)
- POSHQC_JOB_KEY_LINES=1; POSHQC_NAME_LINES=1 (the check name stays `poshqc / PowerShell QC`)
- Result: PASS.
