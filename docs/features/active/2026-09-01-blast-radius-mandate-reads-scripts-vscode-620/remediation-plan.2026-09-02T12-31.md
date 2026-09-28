# blast-radius-mandate-reads-scripts-vscode-620 (Remediation Plan, cycle 2)

- **Issue:** #620
- **Feature folder:** `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/`
- **Remediation input:** `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/remediation-inputs.2026-09-02T12-31.md`
- **Status:** Minimal-audit remediation cycle (coverage artifact capture)

## Scope

Exactly one remediation action: run the TypeScript coverage command from the `extensions/drm-copilot` project directory and capture the resulting coverage artifact and text-summary output as evidence under the canonical evidence path `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/`.

**Rationale for this minimal plan:** A TypeScript file (`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`) was changed in remediation commit `bc92d6db` of the prior cycle. Per repository coverage-verification policy, a coverage artifact must exist for every language with a changed file. The prior remediation plan omitted the coverage-capture task, reasoning that the changed file is under `test/` and excluded from `jest.config.cjs`'s `collectCoverageFrom` scope (which is correct and policy-compliant). However, the repository policy requires an artifact to *exist* whenever any file in a language changes, regardless of whether that specific file contributes to the coverage denominator. This plan fulfills that unconditional requirement.

**Scope constraint:** No code changes. This is a command-run-and-capture-evidence task only.

## Remediation Acceptance Criteria (this cycle)

- **AC-1** — Coverage artifact exists at `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p1-t1-typescript-coverage.2026-09-02T12-31.md` (or a variant within the same minute timestamp range).
- **AC-2** — Artifact contains required fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with repo-wide line coverage and branch coverage percentages.
- **AC-3** — `EXIT_CODE: 0` (command completed successfully).
- **AC-4** — Repo-wide line coverage is >= 85% and branch coverage is >= 75%, per `.claude/rules/quality-tiers.md` and `.claude/rules/typescript.md`.
- **AC-5** — The changed file `config-carriage.test-helpers.ts` is not expected to report a numeric coverage value (it is under `test/`, correctly excluded by `collectCoverageFrom`); its absence from coverage does not constitute a defect.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, and `.claude/rules/quality-tiers.md`. Write `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/other/phase0-instructions-read.2026-09-02T12-31.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: the artifact exists and lists all five paths above in the order read.

---

### Phase 1 — Coverage Capture

- [x] [P1-T1] Run the TypeScript coverage command from `extensions/drm-copilot` directory:

  ```
  npm run test:coverage
  ```

  This command runs `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, which produces `coverage/lcov.info` and emits the text-summary coverage percentages to stdout.

  Capture the entire run output (stdout and stderr) and the resulting `coverage/lcov.info` file into an evidence artifact at `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p1-t1-typescript-coverage.2026-09-02T12-31.md`.

  Artifact MUST include:
  - `Timestamp: <ISO-8601>` (use `2026-09-02T12-31` or the actual minute of execution)
  - `Command: npm run test:coverage` (as run from `extensions/drm-copilot`)
  - `EXIT_CODE: <int>`
  - `Output Summary:` with the repo-wide line coverage percentage (e.g., "Line coverage: 92%") and branch coverage percentage (e.g., "Branch coverage: 88%") extracted from the text-summary output.
  - A copy of the `coverage/lcov.info` file contents or a reference to it appended to the artifact (for verification purposes).

  Acceptance: `EXIT_CODE: 0`; line coverage reported >= 85%; branch coverage reported >= 75%.

---

### Phase 2 — Verification

- [x] [P2-T1] Verify the coverage artifact exists and is well-formed. Read `docs/features/active/2026-09-01-blast-radius-mandate-reads-scripts-vscode-620/evidence/qa-gates/p1-t1-typescript-coverage.2026-09-02T12-31.md` and confirm:

  - The artifact file exists.
  - `Timestamp:` field is present and non-blank.
  - `Command:` field is present and contains `npm run test:coverage`.
  - `EXIT_CODE:` field is present and set to `0`.
  - `Output Summary:` field is present and contains numeric line and branch coverage percentages.
  - Line coverage percentage >= 85%.
  - Branch coverage percentage >= 75%.

  Acceptance: all five checks above pass.

- [x] [P2-T2] Verify that `coverage/lcov.info` exists in the `extensions/drm-copilot` directory and is non-empty. Command:

  ```
  # Verify the file exists and is not empty
  test -s extensions/drm-copilot/coverage/lcov.info
  ```

  (This command exits 0 if the file exists and is non-empty.)

  Acceptance: `EXIT_CODE: 0`.

---

## Verification Upon Plan Completion

All acceptance criteria (AC-1 through AC-5) are satisfied when:

1. The Phase 0 artifact (`phase0-instructions-read`) exists and lists all required policy files.
2. The Phase 1 evidence artifact (`p1-t1-typescript-coverage`) exists in the canonical `qa-gates` folder.
3. The artifact contains required schema fields and numeric coverage values meeting the repository threshold.
4. Phase 2 verification tasks confirm artifact well-formedness and `coverage/lcov.info` existence.

Upon completion of all phases, the blocking finding from the re-audit (missing coverage artifact) is resolved, and the branch is ready for re-review.
