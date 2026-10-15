Timestamp: 2026-10-02T02-47
Command: git diff --numstat HEAD -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence
EXIT_CODE: 0
Output Summary: Numstat prints exactly 27 lines, each 2 added and 1 deleted, naming exactly the 27 Phase 1 files. Porcelain companion lists those 27 paths as modified and otherwise 12 untracked rem1 artifacts (8 under evidence/remediation-baseline/, 4 under evidence/qa-gates/).

# Evidence-Folder Edit Footprint (Remediation Cycle 1, task P3-T5)

Loop iteration: 1

Primary command output (27 lines; every line reads 2 added, 1 deleted; FEATURE prefix shortened to `evidence/`):

  2 1 evidence/baseline/file-sizes.2026-09-30T03-18.md
  2 1 evidence/baseline/mirror-hashes.2026-09-30T03-18.md
  2 1 evidence/baseline/pester-doc-contracts.2026-09-30T03-18.md
  2 1 evidence/baseline/py-black.2026-09-30T03-18.md
  2 1 evidence/baseline/py-claude-bundle-parity.2026-09-30T03-18.md
  2 1 evidence/baseline/py-collect-verification-evidence.2026-09-30T03-18.md
  2 1 evidence/baseline/py-pyright.2026-09-30T03-18.md
  2 1 evidence/baseline/py-pytest-coverage.2026-09-30T03-18.md
  2 1 evidence/baseline/py-ruff.2026-09-30T03-18.md
  2 1 evidence/baseline/py-targeted-contracts.2026-09-30T03-18.md
  2 1 evidence/baseline/python-coverage-baseline.2026-09-30T03-18.md
  2 1 evidence/baseline/tracked-surfaces.2026-09-30T03-18.md
  2 1 evidence/baseline/ts-dependency-cruiser.2026-09-30T03-18.md
  2 1 evidence/baseline/ts-eslint.2026-09-30T03-18.md
  2 1 evidence/baseline/ts-jest-coverage.2026-09-30T03-18.md
  2 1 evidence/baseline/ts-jest-verification-evidence.2026-09-30T03-18.md
  2 1 evidence/baseline/ts-prettier.2026-09-30T03-18.md
  2 1 evidence/baseline/ts-tsc.2026-09-30T03-18.md
  2 1 evidence/other/py-shape06-comment-check.2026-09-30T03-18.md
  2 1 evidence/other/ts-comment-check.2026-09-30T03-18.md
  2 1 evidence/other/ts-comment-only-diff.2026-09-30T03-18.md
  2 1 evidence/regression-testing/fail-before-doc-contracts.2026-09-30T03-18.md
  2 1 evidence/regression-testing/fail-before-first-occurrence-module.2026-09-30T03-18.md
  2 1 evidence/regression-testing/fail-before-two-gate-first-occurrence.2026-09-30T03-18.md
  2 1 evidence/regression-testing/pass-after-parser-modules.2026-09-30T03-18.md
  2 1 evidence/regression-testing/pass-after-two-gate-first-occurrence.2026-09-30T03-18.md
  2 1 evidence/regression-testing/ts-jest-verification-evidence.2026-09-30T03-18.md

## Companion commands

  git status --porcelain --untracked-files=all -- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence  exit=0
    27 lines ` M` for the 27 paths listed above, then:
    ?? evidence/qa-gates/pr-context-rows-rem1.2026-10-02T02-02.md
    ?? evidence/qa-gates/timestamp-correction-lines-rem1.2026-10-02T02-02.md
    ?? evidence/qa-gates/timestamp-residue-rem1.2026-10-02T02-02.md
    ?? evidence/qa-gates/timestamp-values-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/evidence-locations-before-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/git-state-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/main-plan-validator-before-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/phase0-instructions-read-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/pr-context-rows-before-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/pytest-pr-context-before-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/remediation-plan-validator-rem1.2026-10-02T02-02.md
    ?? evidence/remediation-baseline/timestamp-rows-before-rem1.2026-10-02T02-02.md

## Acceptance check

- Numstat: exactly 27 lines, each 2 and 1, naming exactly the 27 Phase 1 files.
- Porcelain: the 27 paths as ` M`; every other line is `??` for a file ending `-rem1.2026-10-02T02-02.md` under evidence/remediation-baseline/ or evidence/qa-gates/.
