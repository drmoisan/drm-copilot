# Codex Root/Bundle Parity Evidence

Timestamp: `2026-08-10T20-25`

Task: `[P5-T3]`

Result: `PASS`

## Scope

- Enumerated contract paths: 36
- Equal root/resource pairs: 36
- Missing roots: 0
- Missing destinations: 0
- Byte mismatches: 0
- Registered hook paths: 28
- Registered hooks present at root: 28
- Registered hooks present in the Codex resource bundle: 28
- `.claude/**` paths selected for the Codex bundle: 0

`config/orchestration-routing.json` retains its established destination at
`extensions/drm-copilot/resources/config/orchestration-routing.json`. Every
other row retains the same repository-relative path under
`extensions/drm-copilot/resources/codex-and-agents-customizations/`.

## Pair Inventory

| Root-relative path | SHA-256 on both surfaces | Result |
| --- | --- | --- |
| `AGENTS.md` | `39C30EDFCF6C93A31A451F1379C84B2AB9E75A1733749DCA6250017611E80153` | equal |
| `.agents/skills/parallel-add/SKILL.md` | `D06F57D8EAD38A246AE05FCA85509429E1BF57D5789C7B53294157493B4AF99E` | equal |
| `.agents/skills/parallel-close/SKILL.md` | `F53C5EF7895BA90421156736D7C4DD306BD1F2FF12988A47D3B5379106471C0B` | equal |
| `.agents/skills/parallel-orchestrate/SKILL.md` | `EF6F4A5F75A271711DD9E984941D1D4C2C6F28147986DA98735B05D9D7FC63DC` | equal |
| `.agents/skills/parallel-plan/SKILL.md` | `9A4A4C8581A3D0B317241DEE4ADC931787181A49AB30C7111D33449A3E2E5173` | equal |
| `.agents/skills/parallel-remove/SKILL.md` | `D6D7F4333B477260B2AA379F87F2B7BA107E4F5F4F25408D998514461C6622CC` | equal |
| `.agents/skills/parallel-run/SKILL.md` | `6747A7C6769EA376060B02AA3072FC82673CA2F5DBCA7B8B079A702D6E50EE29` | equal |
| `.codex/agents/parallel-orchestrator.toml` | `E7BBE7ABD46A7E40BDB85104CC63EAE9965372B5B89E362D96349CAC2D8D0B2B` | equal |
| `.codex/agents/parallel-planner.toml` | `E8ADFC937F40FA009B2B9F2A2A91FA53056CB62E3B2BE9584F73981FB350A3A4` | equal |
| `.codex/config.toml` | `577B242F835C06DF8E4F1D6A17A6D8A8E4BFB8DF6739EAEC5018CECCED147284` | equal |
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | `E4F580B094EE48EFAF8A868C0126C959A749C81FE0FB2C5E1F6A175A9B0C7EF6` | equal |
| `.codex/hooks/codex-authority-store.ps1` | `8E2C81961712C05478B1CDAAF473D25453ED3803A7C41CD61F551F3832FB47F2` | equal |
| `.codex/hooks/enforce-codex-model-routing.ps1` | `154DBF32D87A01AD1221575DC80D8240622648EEA39DA856D238408C6D5E9FAB` | equal |
| `.codex/hooks/enforce-completion-consistency.ps1` | `749C72A5EA8CF84A9B6971E8FD724EB91E4CB2A7D409B6DB21CD5E7A5218513E` | equal |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | `D49091391500CB211935C59E4E88A3AD48F6F61BFB8F7522A19AF97D7E7DCE54` | equal |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | `6E88AFAF66B1C2EED4D3CCE69D9CE47E8F92AE95724B619D73C4A420F323FA2A` | equal |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | `AF9901587A0CB16E13288B42AFB39C86E2EFB06BE2965CE8352CE304838E1273` | equal |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | `E8B1877B70FA909AC5FCC35E24BA10EE48F3DEAA74CBE0E02FFD524D76F37D86` | equal |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | `4787FA4A01182B3D61139524BF8852E0BE8B3712D72034241A6138B8700CA502` | equal |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | `2A3204455FAD096F21B3BCEDEDAA8B3BD060712F0896C936E7EEE40834372FAB` | equal |
| `.codex/hooks/parallel-hook-common.ps1` | `771BBB67942BB3820DED7AF7871ADC433273D3BB1E7CCAC99F39CF3D09998562` | equal |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | `5CC5BDD808219B23AC26B84C057C9727DDB6706EE8C1816F19286AAA5EAA74EC` | equal |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | `8258011DCBCBE4C204824268AD8A898B2E111ECF807C9CA73FAEF4A6406140D7` | equal |
| `.codex/hooks/validate-parallel-agent-output.ps1` | `A3A898418FB5AA86DA6B84EF942E874CADCE29A0213F7705D1F130DD8D5EFCBA` | equal |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | `13C7DB731432143E6187D16858D7350B8D89F556D7E0126E1CAA5D79EA51DA14` | equal |
| `.codex/scripts/codex-child-launch-persistence.ps1` | `FBD1D27BDFB6DDB82357AAF086C16218788FFA390CA35F2AA10209F5CB019FD9` | equal |
| `.codex/scripts/codex-child-launch-resume.ps1` | `B1D8DE223994D0EA02124FA26B5916D03388CE1CF2F0E7C4384D69F565741780` | equal |
| `.codex/scripts/codex-child-launch-runtime.ps1` | `D843D16AFEBD9FEC1B455570EA7CF2B8237F9A8CD6E4EA5F4664F6380A7C69AC` | equal |
| `.codex/scripts/epic-child-launch-contract.ps1` | `91E43A76031A0B4B526788EA58FE0FF37183BAE25542751D3AAA462CBE8DAAB7` | equal |
| `.codex/scripts/launch-epic-child-wave.ps1` | `00EDE63BA41A642D82BC0B647C7D1E47DCDEDC9266DCB8588E58440F3688A93A` | equal |
| `.codex/scripts/launch-parallel-child-batch.ps1` | `9856826BC016B581B94824F9F22941AD49AEEDAEADAFE166C4BB00CCC10B5A8C` | equal |
| `.codex/scripts/parallel-child-launch-contract.ps1` | `6656ABE5FFC1B8C4DFD37EC07B6839C00E3D291EEA2D129DEDB60C7FF036C900` | equal |
| `.codex/scripts/parallel-child-post-session.ps1` | `A0DEDE7A061E865BB480F5E2D53B15CF654B2EC1462D561DD6889640C69007DF` | equal |
| `.codex/scripts/resume-epic-child.ps1` | `FFDAC48113E1912369775CA14E3A90311CDF522F8D7C3810096E9ECF7929DCA2` | equal |
| `.codex/scripts/resume-parallel-child.ps1` | `D60B9D702701AB454025126C439888D61DBC116D6E089E41F8B5122B49861E85` | equal |
| `config/orchestration-routing.json` | `C42C37D542FBD361568883AE3D8AC9C69DB0EA129CE901EA5AB4E2AF0D4E618F` | equal |

## Validation

- PoshQC format: passed for each of the six bounded synchronization batches.
- PoshQC analyze: passed for each of the six bounded synchronization batches.
- PowerShell parser: 50/50 root and resource-bundle files parsed without errors.
- File-size policy: 50/50 PowerShell files are at or below 500 physical lines.
- TOML parsing: 6/6 root and resource config/agent files passed.
- JSON parsing: 2/2 routing-config files passed.
- Focused resource contract: `7 passed in 0.15s`.
- Registered command targets: 28/28 exist at root and 28/28 exist in the resource bundle.
- `.claude` diff: 0 lines; no `.claude` path appears in the Codex resource selection.
- `.codex/state`: absent.

Commands included the bundled PoshQC format/analyze entrypoints, PowerShell
parser and SHA-256 inventory checks, TOML/JSON parsers, and:

`poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
