# TypeScript coverage delta — [P11-T5] (AC-26)

Timestamp: 2026-09-29T20-54
Command: parse `LF`, `LH`, `BRF`, `BRH`, and `DA` lines from `extensions/drm-copilot/coverage/lcov.info` (written by [P11-T4]) for the six records whose `SF:` values (after `\` to `/`) equal the files below; changed line numbers from `git diff -U0 9438bdf5253e10903e2e74eab5cf51df988e0466 -- extensions/drm-copilot/src/lib/push-down/claude-customizations.ts extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` (new-side hunk ranges)
EXIT_CODE: 0
Output Summary: all six files are at or above 85% line and 75% branch coverage; none of the four pre-existing files is below its [P0-T15] baseline on either measure; zero changed lines have a `DA` hit count of 0. PASS.

Anchor note: the diff uses the pinned [P0-T2] anchor SHA, which equals `git merge-base HEAD origin/epic/push-down-payload-correctness-integration` (see ANCHOR_DRIFT in `final-scope-guard.2026-09-29T20-50.md`). #763 changed none of these four files.

## Post-change values

| File | LH/LF | Line % | BRH/BRF | Branch % | Zero-hit `DA` lines |
|---|---|---|---|---|---|
| src/lib/push-down/claude-exclusion-manifest.ts | 343/343 | 100.00 | 63/63 | 100.00 | none |
| src/lib/push-down/claude-exclusion-filter.ts | 335/337 | 99.41 | 45/47 | 95.74 | 330, 331 |
| src/lib/push-down/claude-customizations.ts | 496/496 | 100.00 | 61/63 | 96.83 | none |
| src/lib/push-down/push-down-service-call.ts | 214/214 | 100.00 | 27/28 | 96.43 | none |
| src/lib/push-down/copilot-customizations-engine.ts | 439/448 | 97.99 | 43/51 | 84.31 | 114, 115, 136, 137, 142, 143, 383, 384, 385 |
| src/repo-automation-command-registration-admin.ts | 407/420 | 96.90 | 58/65 | 89.23 | 97-101, 293, 294, 302, 303, 312, 313, 337, 338 |

## Baseline comparison (four pre-existing files)

| File | Baseline line % | Post line % | Baseline branch % | Post branch % | Result |
|---|---|---|---|---|---|
| claude-customizations.ts | 100.00 (419/419) | 100.00 (496/496) | 95.74 (45/47) | 96.83 (61/63) | not below |
| push-down-service-call.ts | 100.00 (201/201) | 100.00 (214/214) | 95.65 (22/23) | 96.43 (27/28) | not below |
| copilot-customizations-engine.ts | 97.99 (439/448) | 97.99 (439/448) | 84.31 (43/51) | 84.31 (43/51) | equal |
| repo-automation-command-registration-admin.ts | 96.80 (393/406) | 96.90 (407/420) | 88.33 (53/60) | 89.23 (58/65) | not below |

## Changed lines with a 0 hit count

| File | Changed new-side lines | Changed lines with `DA:<n>,0` |
|---|---|---|
| claude-customizations.ts | 82 | none |
| push-down-service-call.ts | 13 | none |
| copilot-customizations-engine.ts | 1 (the `export` on `stringifySorted`) | none |
| repo-automation-command-registration-admin.ts | 15 | none |

The zero-hit lines of `copilot-customizations-engine.ts` are identical to the [P0-T15] list; those of `repo-automation-command-registration-admin.ts` are the [P0-T15] list shifted by +2 (lines 95-99 to 97-101) and +14 (279-324 to 293-338), consistent with the lines this plan inserted above them. The two zero-hit lines of the new `claude-exclusion-filter.ts` (330, 331) are within the per-file thresholds.
