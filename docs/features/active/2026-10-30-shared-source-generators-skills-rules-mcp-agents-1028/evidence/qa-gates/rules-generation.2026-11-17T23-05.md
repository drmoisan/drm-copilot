# Path-scoped rules — first generation ([P4-T3])

Timestamp: 2026-11-17T23-05
Command: sh SCRATCH/issue-1028-gen.sh rules (`scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface rules` in write mode); sh SCRATCH/issue-1028-gen.sh rules check; git status --porcelain; git diff --stat; head -3 .github/instructions/general-unit-test.instructions.md extensions/drm-copilot/resources/customizations/.github/instructions/general-unit-test.instructions.md
EXIT_CODE: 0
Output Summary: The write run wrote 8 files. The check run printed "harness-generation: no drift" and exited 0. `.github/instructions/general-unit-test.instructions.md` and its bundle copy now begin with `---`. `test_claude_rules_frontmatter.py`, `test_push_down_tier_rule_adoption_gate.py` and `test_typescript_toolchain_instruction_contracts.py` pass (105 passed). `ProcessReductionChain.Ledger.Tests.ps1` passes, including `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-LEDGER-NO-EXCEPTIONS` and `PRC-LEDGER-END-STATE-RECORDED`. With `ProcessReductionLedger.Tests.ps1`, `test-cadence-wording.Tests.ps1` and `HarnessParityMatrix.RepoGate.Tests.ps1`, the Pester selection reports 220 passed and 0 failed.

Changed paths (`git status --porcelain` after the write run; every other rendered target and bundle copy already equalled its source):

```text
 M .github/instructions/general-unit-test.instructions.md
 M .github/instructions/self-explanatory-code-commenting.instructions.md
 M .github/instructions/tonality.instructions.md
 M .github/instructions/typescript-unit-test.instructions.md
 M extensions/drm-copilot/resources/customizations/.github/instructions/general-unit-test.instructions.md
 M extensions/drm-copilot/resources/customizations/.github/instructions/self-explanatory-code-commenting.instructions.md
 M extensions/drm-copilot/resources/customizations/.github/instructions/tonality.instructions.md
 M extensions/drm-copilot/resources/customizations/.github/instructions/typescript-unit-test.instructions.md
```

`git diff --stat`: 8 files changed, 6 insertions(+), 6 deletions(-). The changes are as follows:
- `general-unit-test` adds the opening `---` line;
- `typescript-unit-test` removes the blank line before the opening `---`;
- `tonality` and `self-explanatory-code-commenting` each end with a line feed.

No Claude rule and no Codex rule-skill changed. No file was renamed or deleted.
