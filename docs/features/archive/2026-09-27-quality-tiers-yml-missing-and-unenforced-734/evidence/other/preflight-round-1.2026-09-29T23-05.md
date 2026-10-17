# Preflight Round 1

Timestamp: 2026-09-29T23-05
Command: Agent(atomic-executor) DIRECTIVE: PREFLIGHT VALIDATION ONLY against plan.2026-09-29T21-45.md
EXIT_CODE: 1
Output Summary: PREFLIGHT: REVISIONS REQUIRED; CONVERGENCE: FURTHER ROUNDS LIKELY.

Defects reported:

- D1 (blocking): P1-T4 fakes use subprocess.CompletedProcess; the Python test-purity hook denies `import subprocess` in tests. Use a test-local FakeRunResult dataclass and a GitRunResult Protocol on the production `run` parameter; extend the P8-T17 hermeticity pattern.
- D2 (blocking): actionlint tasks P0-T34, P5-T5, P8-T16 invoke pwsh, which the worktree isolation guard refuses. Call `actionlint` directly.
- D3 (blocking): P6-T11 / P8-T11 deferral depends on a baseline failure (#510, `.claude/state/`) that may not exist at P0-T24 time. Add an explicit condition (b).
- D4 (moderate): AC-12 exact-text check can pass on inexact edits. Assert two exact single-line tokens with `git grep -c -F`.
- D5 (moderate): Phase 10 CI tasks lack bounded retry for run registration and Bash timeout, and literal job names.
- D6 (minor): declared write set omits the plan file (task check-off).

G4 warnings on P0-T24 and P8-T11 (`--cov --cov-branch`) were assessed as false positives: pytest-cov `--cov` uses `nargs='?'`, and argparse does not bind a following `-`-prefixed token.
