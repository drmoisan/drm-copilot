# Final QA Gate 9 — Four-Copy Parity Hashes, Post-Change (issue #516)

Timestamp: 2026-08-24T16-40
Command: `Get-FileHash -Algorithm SHA256` over the four hook copies, after all edits and after the [P4-T6] clean pass
EXIT_CODE: 0

## Post-Change Hashes

| # | File | SHA256 |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207` |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD` |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD` |

## Pairwise Equality — acceptance condition

- **Claude family (1 == 2):** `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207` equals `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207`. **EQUAL.**
- **Codex family (3 == 4):** `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD` equals `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD`. **EQUAL.**

Both required pairwise equalities hold. The acceptance condition is satisfied.

## Change Against Baseline

| Family | Baseline hash ([P0-T13]) | Post-change hash | Changed |
| --- | --- | --- | --- |
| Claude | `F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C` | `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207` | **Yes** |
| Codex | `E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37` | `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD` | **Yes** |

Both families changed, as required — all four copies received the fix. Parity held at baseline and holds after the change; the two families remain correctly distinct from each other, since they differ in payload plumbing, in `apply_patch` handling, and in malformed-input behavior, none of which this item reconciles.

## Stability Through the QA Restarts

These two hash values have been constant since the moment each family was written, at [P2-T3] for the Claude pair and [P3-T4] for the Codex pair. They did not change across either of the two toolchain restarts recorded in the [P4-T6] artifact, because both restart causes were defects in the new test files rather than in any hook copy, nor across any format stage, because the formatter rewrote no file. The production change reached its final form on its first pass.

## Corroboration by an Independent Mechanism

The Claude-family equality is independently confirmed by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which asserts content equality for every repo `.claude/**` file against its bundled counterpart and passes 10 of 10 at [P4-T5]. The Codex-family equality is independently confirmed by the byte-identity assertion in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, which passes 43 of 43 at [P3-T5] and again in the [P4-T4] full run. Two independent mechanisms agree with the direct hash comparison for each family.

Output Summary: All four hook copies hashed after the change and after the clean pass. The two Claude copies are byte-identical to each other (`658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207`) and the two Codex copies are byte-identical to each other (`98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD`). Both pairwise equalities hold, both families differ from their baseline hashes confirming all four copies received the fix, and each equality is corroborated by an independent test-based parity gate.
