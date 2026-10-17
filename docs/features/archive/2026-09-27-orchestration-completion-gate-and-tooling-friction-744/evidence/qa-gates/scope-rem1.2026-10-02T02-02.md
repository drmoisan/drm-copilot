Timestamp: 2026-10-02T02-49
Command: git diff --numstat HEAD
EXIT_CODE: 0
Output Summary: Numstat prints exactly 28 lines: the 27 Phase 1 evidence files at 2 added / 1 deleted and FEATURE/plan.2026-09-30T03-18.md at 1 added / 0 deleted. Porcelain lists those 28 paths as modified, the one P0_STATUS line, and 16 untracked rem1 artifacts. No .py, .ts, .ps1, .psm1, .sh, .cjs, or .json path; nothing outside FEATURE; spec.md not listed.

# Repository Scope (Remediation Cycle 1, task P4-T4)

Loop iteration: 1

Primary command output (28 lines; FEATURE prefix shortened to `FEATURE/`):

  27 lines `2 1` for the Phase 1 files (identical to the P3-T5 listing):
    FEATURE/evidence/baseline/file-sizes.2026-09-30T03-18.md
    FEATURE/evidence/baseline/mirror-hashes.2026-09-30T03-18.md
    FEATURE/evidence/baseline/pester-doc-contracts.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-black.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-claude-bundle-parity.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-collect-verification-evidence.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-pyright.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-pytest-coverage.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-ruff.2026-09-30T03-18.md
    FEATURE/evidence/baseline/py-targeted-contracts.2026-09-30T03-18.md
    FEATURE/evidence/baseline/python-coverage-baseline.2026-09-30T03-18.md
    FEATURE/evidence/baseline/tracked-surfaces.2026-09-30T03-18.md
    FEATURE/evidence/baseline/ts-dependency-cruiser.2026-09-30T03-18.md
    FEATURE/evidence/baseline/ts-eslint.2026-09-30T03-18.md
    FEATURE/evidence/baseline/ts-jest-coverage.2026-09-30T03-18.md
    FEATURE/evidence/baseline/ts-jest-verification-evidence.2026-09-30T03-18.md
    FEATURE/evidence/baseline/ts-prettier.2026-09-30T03-18.md
    FEATURE/evidence/baseline/ts-tsc.2026-09-30T03-18.md
    FEATURE/evidence/other/py-shape06-comment-check.2026-09-30T03-18.md
    FEATURE/evidence/other/ts-comment-check.2026-09-30T03-18.md
    FEATURE/evidence/other/ts-comment-only-diff.2026-09-30T03-18.md
    FEATURE/evidence/regression-testing/fail-before-doc-contracts.2026-09-30T03-18.md
    FEATURE/evidence/regression-testing/fail-before-first-occurrence-module.2026-09-30T03-18.md
    FEATURE/evidence/regression-testing/fail-before-two-gate-first-occurrence.2026-09-30T03-18.md
    FEATURE/evidence/regression-testing/pass-after-parser-modules.2026-09-30T03-18.md
    FEATURE/evidence/regression-testing/pass-after-two-gate-first-occurrence.2026-09-30T03-18.md
    FEATURE/evidence/regression-testing/ts-jest-verification-evidence.2026-09-30T03-18.md
  1 line `1 0`:
    FEATURE/plan.2026-09-30T03-18.md

## Companion commands

  git status --porcelain --untracked-files=all  exit=0
    28 lines ` M` for the 28 paths above, then:
    ?? FEATURE/evidence/qa-gates/evidence-locations-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/evidence-numstat-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/main-plan-validator-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/pr-context-rows-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/pytest-pr-context-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/timestamp-correction-lines-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/timestamp-residue-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/qa-gates/timestamp-values-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/evidence-locations-before-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/git-state-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/main-plan-validator-before-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/phase0-instructions-read-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/pr-context-rows-before-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/pytest-pr-context-before-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/remediation-plan-validator-rem1.2026-10-02T02-02.md
    ?? FEATURE/evidence/remediation-baseline/timestamp-rows-before-rem1.2026-10-02T02-02.md
    ?? FEATURE/remediation-plan.2026-10-02T02-02.md   (the P0_STATUS line)

## Acceptance check

- Numstat: exactly 28 lines with the expected added/deleted counts.
- Porcelain: the 28 paths as ` M`; otherwise only the P0_STATUS line and `??` rem1 artifacts under evidence/remediation-baseline/ or evidence/qa-gates/.
- No listed path ends in .py, .ts, .ps1, .psm1, .sh, .cjs, or .json; none lies outside FEATURE; spec.md is not listed.
