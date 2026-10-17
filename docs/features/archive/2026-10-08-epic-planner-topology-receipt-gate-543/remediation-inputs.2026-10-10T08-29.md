# Remediation Inputs: Epic planner topology receipt gate (#543), review pass 1

- Date: 2026-10-10
- Branch: `bug/epic-planner-topology-receipt-gate-543` at `e7612e93a4e88f68eadae6ee9e34ead251c82872`
- Review artifacts:
  - `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/policy-audit.2026-10-10T08-29.md`
  - `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/code-review.2026-10-10T08-29.md`
  - `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/feature-audit.2026-10-10T08-29.md`

## Remediation-Required Findings

### PA-1 (Blocking): TypeScript coverage artifact absent

Trigger: "coverage artifact absent for TypeScript; coverage verification is mandatory for all languages with changed files." TypeScript has 3 changed files on the branch (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`, `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`). Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists. The executor's runs used `--coverageReporters=text --coverageReporters=text-summary`, which replaces the configured `lcov` reporter (`extensions/drm-copilot/jest.config.cjs:18`).

No production or test code change is expected. The recorded text figures (98.31% lines, 93.8% branches) already exceed the floors.

Steps:

1. From `extensions/drm-copilot/`, run `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary`. Do not pass `--passWithNoTests`, `--onlyChanged`, or `--lastCommit`.
2. Confirm `extensions/drm-copilot/coverage/lcov.info` exists and record its size and write time.
3. Locate the record whose `SF:` line ends in `src/lib/validate/epic-planner-state-core.ts` (path separators may be `\` on Windows). Record `LF`, `LH`, `BRF`, `BRH`, and the derived line and branch percentages.
4. Confirm that `DA:444`, `DA:445`, and `DA:446` (whichever are present) have non-zero hit counts.
5. Write `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/typescript-lcov-coverage.<ts>.md` with `Timestamp:` read from the host clock when the command runs, `Command:`, `EXIT_CODE:`, the lcov path and write time, the per-file values, the `DA` hit counts for the added lines, and the repo-wide `text-summary` lines.

Definition of done: `extensions/drm-copilot/coverage/lcov.info` exists; the `qa-gates` artifact records lcov-derived values of at least 85% lines and 75% branches for `epic-planner-state-core.ts`, no decrease from the baseline (98.3% lines, 93.57% branches), and non-zero hits on the added executable lines.

Constraints:

- Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`. The lcov file is gitignored tool output; cite it from the `qa-gates` evidence file.
- Do not edit `extensions/drm-copilot/jest.config.cjs`, any production file, or any test file.
- Do not change any `spec.md` checkbox; AC13 is already checked and evaluated PASS.

## Non-Blocking Items (optional; no re-review required)

- CR-2: optionally add a key-gated assertion that an absent per-feature `topology_receipt` still errors, or defer it to the follow-up issue.
- CR-1, CR-3, PA-2 to PA-5: informational; candidates for the follow-up issue described in `spec.md` Rollout & Follow-up.

## Re-review Scope

After PA-1 remediation, a re-review needs to confirm only the new `qa-gates` artifact and the presence of `extensions/drm-copilot/coverage/lcov.info`, and that `git diff e7612e93..HEAD` touches only the feature folder.
