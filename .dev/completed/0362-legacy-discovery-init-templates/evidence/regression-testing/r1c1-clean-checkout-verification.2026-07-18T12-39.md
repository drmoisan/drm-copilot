# R1 Clean-Checkout Re-Verification (Phase 7 Re-Run) (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-39

Reason for re-run: Per P7-T7, the Phase 7 QA loop reformatted a test file (`tests/scripts/dev_tools/discovery/test_package_exports.py`, via Black) — a test-file change beyond evidence and the two AC documents. The P6-T2 clean-checkout verification was captured before that reformat, so a fresh verification against the post-QA tree is required.

Directive reconciliation: identical to the P6-T2 evidence — the no-commit directive is honored by capturing the post-QA tree via `git stash create` (HEAD unchanged) and creating the detached worktree from that snapshot object rather than from a new commit.

Command:
- `git add -A` (re-stage the post-QA tree, including the Black-reformatted test)
- `STASH=$(git stash create "r1c1 phase7 verification snapshot")` -> snapshot commit `d57e7b7bcd56d694859d8278b70682135418cd40` (HEAD remained `48d16f6f`, no commit performed)
- `git worktree add --detach /c/Users/DanMoisan/AppData/Local/Temp/r1c1-clean-check-362 d57e7b7b`
- clean-checkout cwd, root interpreter: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-17T10-10\.venv\Scripts\python.exe -m pytest tests/scripts/dev_tools/discovery -q`

EXIT_CODE: 0 (clean-checkout pytest run)

Output Summary:
- The detached clean checkout contains exactly the 8 discovery template files under `docs/discovery/`:
  1. docs/discovery/templates/artifacts/coverage-ledger.template.json
  2. docs/discovery/templates/artifacts/evidence-reference.template.json
  3. docs/discovery/templates/artifacts/feature-contract.template.json
  4. docs/discovery/templates/artifacts/parity-matrix.template.json
  5. docs/discovery/templates/artifacts/product-decision-record.template.json
  6. docs/discovery/templates/artifacts/runtime-characterization-scenario.template.json
  7. docs/discovery/templates/artifacts/unspecified-behavior-record.template.json
  8. docs/discovery/templates/domain-profile/domain-profile.yaml
- `pytest tests/scripts/dev_tools/discovery -q` (root interpreter) from the clean checkout: 84 passed in 0.37s, 0 skipped.
- `test_domain_neutrality` raised no `FileNotFoundError`.
- The temporary detached worktree was removed after the run (`git worktree list` no longer shows the `r1c1-clean-check-362` path).
