# R1 .gitignore Anchor Verification (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-18
Command:
- `git check-ignore -q -- docs/discovery/templates/artifacts/feature-contract.template.json`
- `git check-ignore -q -- artifacts/orchestration/orchestrator-state.json`
- `git status --porcelain --untracked-files=all -- docs/discovery/templates/`
- `git status --porcelain`
EXIT_CODE: 0 (verification commands completed; check-ignore exit codes recorded below)

Output Summary:
- `.gitignore` line 6 changed from bare `artifacts` to root-anchored `/artifacts`.
- `git check-ignore` on the nested template exited 1 (NOT ignored) — correct.
- `git check-ignore` on `artifacts/orchestration/orchestrator-state.json` exited 0 (still ignored) — correct; the root orchestration directory remains ignored.
- The seven `docs/discovery/templates/artifacts/*.template.json` files are now visible as untracked (`??`):
  - coverage-ledger.template.json
  - evidence-reference.template.json
  - feature-contract.template.json
  - parity-matrix.template.json
  - product-decision-record.template.json
  - runtime-characterization-scenario.template.json
  - unspecified-behavior-record.template.json
  (Count verified: exactly 7. The 8th template, `domain-profile/domain-profile.yaml`, was already tracked, consistent with the R1 finding that 7 of 8 templates were untracked.)
- Full `git status --porcelain` shows no newly visible path outside the allowed scope: `.gitignore` (modified), `docs/discovery/templates/artifacts/` (the seven templates), and this feature's own `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/` files (modified spec.md/user-story.md plus untracked review/evidence/plan artifacts). No unrelated repository path became visible.
