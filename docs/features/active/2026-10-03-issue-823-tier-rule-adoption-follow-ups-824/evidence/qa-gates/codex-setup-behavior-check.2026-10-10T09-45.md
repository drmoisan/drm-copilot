# P14-T3 Codex Setup Behavior Check (PD15, PD16)

Timestamp: 2026-10-10T09-45
Command: git diff -w --exit-code 2a045b8ae3793c3a3531554354f6fda130520242 -- .codex/codex-web-setup.sh; git diff --stat --minimal 2a045b8ae3793c3a3531554354f6fda130520242 -- .codex/codex-web-setup.sh; git status --porcelain -- .codex/codex-web-setup.sh; git diff -w --unified=0 --no-color --output=artifacts/orchestration/codex-setup-widening-w.diff b50df12b6467789d67118c994a5fd56a2fc8db81 -- .codex/codex-web-setup.sh; grep -c -e "^+.*list_root_solution_files" artifacts/orchestration/codex-setup-widening-w.diff; grep -c -e "^[-+].*vswhere" artifacts/orchestration/codex-setup-widening-w.diff
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- WIDEN_BASE: 2a045b8ae3793c3a3531554354f6fda130520242 (P12-T1 artifact). BASE_SHA: b50df12b6467789d67118c994a5fd56a2fc8db81 (P0-T3 artifact).
- git diff -w --exit-code WIDEN_BASE: exit 0; no output (no non-whitespace change since WIDEN_BASE; PD15).
- git diff --stat --minimal WIDEN_BASE: exit 0; summary line `1 file changed, 245 insertions(+), 245 deletions(-)` (the file did change).
- git status --porcelain: exit 0; printed ` M .codex/codex-web-setup.sh`.
- git diff -w --unified=0 --output=... BASE_SHA: exit 0 (diff written to the git-ignored scratch path artifacts/orchestration/codex-setup-widening-w.diff).
- grep "^+.*list_root_solution_files": exit 0; printed 3 (the added definition and two calls; the BASE_SHA diff carries the #824 change).
- grep "^[-+].*vswhere": exit 1; printed 0 (AC-14 holds under whitespace-insensitive comparison; PD16). Last command, so EXIT_CODE 1 is expected.
