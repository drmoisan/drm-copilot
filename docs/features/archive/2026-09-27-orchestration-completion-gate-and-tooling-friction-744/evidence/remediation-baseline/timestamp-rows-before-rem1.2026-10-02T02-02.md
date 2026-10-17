Timestamp: 2026-10-02T02-38
Command: grep -r -l -e "^Timestamp: 2026-10-02T01-17" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence
EXIT_CODE: 0
Output Summary: 29 paths printed: the 27 paths of the remediation-inputs table plus evidence/baseline/phase0-instructions-read.md and evidence/baseline/scope-anchor.2026-09-30T03-18.md. Companion correction-line search exit=1 with no output. No stop condition.

# Timestamp Rows Before Correction (Remediation Cycle 1, task P0-T6)

Primary command output (29 paths; FEATURE prefix shortened to `evidence/`):

  evidence/baseline/file-sizes.2026-09-30T03-18.md
  evidence/baseline/mirror-hashes.2026-09-30T03-18.md
  evidence/baseline/pester-doc-contracts.2026-09-30T03-18.md
  evidence/baseline/phase0-instructions-read.md
  evidence/baseline/py-black.2026-09-30T03-18.md
  evidence/baseline/py-claude-bundle-parity.2026-09-30T03-18.md
  evidence/baseline/py-collect-verification-evidence.2026-09-30T03-18.md
  evidence/baseline/py-pyright.2026-09-30T03-18.md
  evidence/baseline/py-pytest-coverage.2026-09-30T03-18.md
  evidence/baseline/py-ruff.2026-09-30T03-18.md
  evidence/baseline/py-targeted-contracts.2026-09-30T03-18.md
  evidence/baseline/python-coverage-baseline.2026-09-30T03-18.md
  evidence/baseline/scope-anchor.2026-09-30T03-18.md
  evidence/baseline/tracked-surfaces.2026-09-30T03-18.md
  evidence/baseline/ts-dependency-cruiser.2026-09-30T03-18.md
  evidence/baseline/ts-eslint.2026-09-30T03-18.md
  evidence/baseline/ts-jest-coverage.2026-09-30T03-18.md
  evidence/baseline/ts-jest-verification-evidence.2026-09-30T03-18.md
  evidence/baseline/ts-prettier.2026-09-30T03-18.md
  evidence/baseline/ts-tsc.2026-09-30T03-18.md
  evidence/other/py-shape06-comment-check.2026-09-30T03-18.md
  evidence/other/ts-comment-check.2026-09-30T03-18.md
  evidence/other/ts-comment-only-diff.2026-09-30T03-18.md
  evidence/regression-testing/fail-before-doc-contracts.2026-09-30T03-18.md
  evidence/regression-testing/fail-before-first-occurrence-module.2026-09-30T03-18.md
  evidence/regression-testing/fail-before-two-gate-first-occurrence.2026-09-30T03-18.md
  evidence/regression-testing/pass-after-parser-modules.2026-09-30T03-18.md
  evidence/regression-testing/pass-after-two-gate-first-occurrence.2026-09-30T03-18.md
  evidence/regression-testing/ts-jest-verification-evidence.2026-09-30T03-18.md

## Companion commands

  grep -r -l -e "^Timestamp-Correction: " docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence  exit=1
    (no output)

## Acceptance check

- Primary exit 0 with exactly 29 paths: 18 baseline, 6 regression-testing, and 3 other table paths (27) plus the two baseline files kept at 01-17.
- Companion exit 1 with no output.
