Timestamp: 2026-10-02T02-46
Command: grep -r -e "^Timestamp: 2026-10-02T01-" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/baseline docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other
EXIT_CODE: 0
Output Summary: For all 27 Phase 1 files the printed value equals the value named by its Phase 1 task; 27 of 27 rows read match. Nine further lines (36 printed in total) for files outside Phase 1 were printed and are not assessed.

# Corrected Timestamp Values (Remediation Cycle 1, task P3-T4)

Loop iteration: 1

Paths are relative to FEATURE/evidence/; all names end `.2026-09-30T03-18.md`.

| Path | Printed value | Table value | Result |
|---|---|---|---|
| baseline/tracked-surfaces | 2026-10-02T01-18 | 2026-10-02T01-18 | match |
| baseline/file-sizes | 2026-10-02T01-18 | 2026-10-02T01-18 | match |
| baseline/mirror-hashes | 2026-10-02T01-18 | 2026-10-02T01-18 | match |
| baseline/py-black | 2026-10-02T01-19 | 2026-10-02T01-19 | match |
| baseline/py-ruff | 2026-10-02T01-19 | 2026-10-02T01-19 | match |
| baseline/py-pyright | 2026-10-02T01-19 | 2026-10-02T01-19 | match |
| baseline/py-pytest-coverage | 2026-10-02T01-21 | 2026-10-02T01-21 | match |
| baseline/python-coverage-baseline | 2026-10-02T01-22 | 2026-10-02T01-22 | match |
| baseline/py-collect-verification-evidence | 2026-10-02T01-22 | 2026-10-02T01-22 | match |
| baseline/py-targeted-contracts | 2026-10-02T01-22 | 2026-10-02T01-22 | match |
| baseline/py-claude-bundle-parity | 2026-10-02T01-22 | 2026-10-02T01-22 | match |
| baseline/pester-doc-contracts | 2026-10-02T01-22 | 2026-10-02T01-22 | match |
| baseline/ts-prettier | 2026-10-02T01-23 | 2026-10-02T01-23 | match |
| baseline/ts-eslint | 2026-10-02T01-23 | 2026-10-02T01-23 | match |
| baseline/ts-tsc | 2026-10-02T01-23 | 2026-10-02T01-23 | match |
| baseline/ts-dependency-cruiser | 2026-10-02T01-23 | 2026-10-02T01-23 | match |
| baseline/ts-jest-coverage | 2026-10-02T01-24 | 2026-10-02T01-24 | match |
| baseline/ts-jest-verification-evidence | 2026-10-02T01-24 | 2026-10-02T01-24 | match |
| regression-testing/fail-before-two-gate-first-occurrence | 2026-10-02T01-25 | 2026-10-02T01-25 | match |
| regression-testing/fail-before-first-occurrence-module | 2026-10-02T01-26 | 2026-10-02T01-26 | match |
| regression-testing/pass-after-two-gate-first-occurrence | 2026-10-02T01-27 | 2026-10-02T01-27 | match |
| regression-testing/pass-after-parser-modules | 2026-10-02T01-27 | 2026-10-02T01-27 | match |
| other/py-shape06-comment-check | 2026-10-02T01-27 | 2026-10-02T01-27 | match |
| other/ts-comment-check | 2026-10-02T01-28 | 2026-10-02T01-28 | match |
| other/ts-comment-only-diff | 2026-10-02T01-28 | 2026-10-02T01-28 | match |
| regression-testing/ts-jest-verification-evidence | 2026-10-02T01-29 | 2026-10-02T01-29 | match |
| regression-testing/fail-before-doc-contracts | 2026-10-02T01-31 | 2026-10-02T01-31 | match |

Lines for files outside Phase 1 (not assessed): baseline/phase0-instructions-read.md (01-17), baseline/scope-anchor (01-17), regression-testing/parallel-surface-r2-8-nodes (01-42), regression-testing/pass-after-doc-contracts (01-42), regression-testing/pester-doc-contracts (01-44), regression-testing/py-claude-bundle-parity (01-43), regression-testing/py-targeted-contracts (01-43), other/ac-checkbox-count-local (01-55), other/ac-status-summary-local (01-55).

## Acceptance check

- exit 0; 27 of 27 Phase 1 rows read match.
