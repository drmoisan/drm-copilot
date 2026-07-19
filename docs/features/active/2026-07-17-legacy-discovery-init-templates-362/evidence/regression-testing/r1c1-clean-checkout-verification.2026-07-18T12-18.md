# R1 Clean-Checkout Re-Verification (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-18

Directive reconciliation: The orchestrator directive prohibits `git commit`, `git push`, and PR creation (deferred to the orchestrator). The plan's P6-T2 verifies a clean checkout of the remediated tree, which requires a commit-ish. To honor the no-commit directive while faithfully verifying R1, the remediated tree was captured with `git stash create` (a commit object built from the staged index + working tree, HEAD unchanged), and the detached worktree was created from that snapshot object instead of from `HEAD`. This is the only deviation from the literal P6-T2 command text; it verifies the exact remediated tree.

Command:
- `git add -A` (stage all remediation changes; all 8 templates now tracked in the index)
- `STASH=$(git stash create "r1c1 verification snapshot")` -> snapshot commit `189d326f675746ea4adba9c5cf03eac2aef9d7d6` (HEAD remained `48d16f6f`, no commit performed)
- `git worktree add --detach /c/Users/DanMoisan/AppData/Local/Temp/r1c1-clean-check-362 189d326f`
- clean-checkout cwd, root interpreter: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-17T10-10\.venv\Scripts\python.exe -m pytest tests/scripts/dev_tools/discovery -q`

EXIT_CODE: 0 (clean-checkout pytest run)

Output Summary:
- The detached clean checkout contains exactly the 8 discovery template files under `docs/discovery/` (7 of 8 were previously untracked/ignored; all 8 now present):
  1. docs/discovery/templates/artifacts/coverage-ledger.template.json
  2. docs/discovery/templates/artifacts/evidence-reference.template.json
  3. docs/discovery/templates/artifacts/feature-contract.template.json
  4. docs/discovery/templates/artifacts/parity-matrix.template.json
  5. docs/discovery/templates/artifacts/product-decision-record.template.json
  6. docs/discovery/templates/artifacts/runtime-characterization-scenario.template.json
  7. docs/discovery/templates/artifacts/unspecified-behavior-record.template.json
  8. docs/discovery/templates/domain-profile/domain-profile.yaml
- `poetry run pytest tests/scripts/dev_tools/discovery -q` (root interpreter) from the clean checkout: 84 passed in 0.44s, 0 skipped.
- `test_domain_neutrality` raised no `FileNotFoundError` (it reads all template files from the clean checkout successfully), confirming R1 is fixed: the templates are now tracked and available in a fresh checkout, not merely present on the working disk.
