# P6-T26 Remediation Final Verification

Timestamp: 2026-08-23T04:11:38-04:00

## Final commands

Command: `git diff --check`

EXIT_CODE: 0

Output Summary: Git reported no whitespace errors. It emitted one informational working-copy line-ending warning for `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`; this did not identify a diff error or mutate the file.

Command: `poetry run pytest tests/scripts/dev_tools/test_analyze_coverage_policy.py`

EXIT_CODE: 0

Output Summary: Pytest collected and passed all `26` analyzer tests with zero failures in `0.08` seconds.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces --check`

EXIT_CODE: 0

Output Summary: `VERIFIED 20 orchestration customization surfaces`.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: 0

Output Summary: The Codex variant generator found no drift and produced no output.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles --check`

EXIT_CODE: 0

Output Summary: `VERIFIED 48 packaged customization mappings`.

Command: `PowerShell: define the exact 21-path $files array from P3-T6, then run $files | ForEach-Object { "$_|$((Get-Content -LiteralPath $_).Count)" }`

EXIT_CODE: 0

Output Summary: All `21` required Python production/test files exist and are at or below `500` physical lines.

Command: `poetry run python -c "import hashlib; from pathlib import Path; from scripts.dev_tools.synchronize_customization_bundles import MAPPINGS; rows=[]; [(rows.append((m.source.as_posix(),m.destination.as_posix(),hashlib.sha256(Path(m.source).read_bytes()).hexdigest().upper(),hashlib.sha256(Path(m.destination).read_bytes()).hexdigest().upper()))) for m in MAPPINGS]; print({'pairs':len(rows),'all_equal':all(a==b for _,_,a,b in rows)}); [print('|'.join((s,d,a,b,str(a==b)))) for s,d,a,b in rows]"`

EXIT_CODE: 0

Output Summary: All `48` exact canonical-root/generated-mirror mappings were present and byte-identical.

Command: `git status --short`

EXIT_CODE: 0

Output Summary: The working tree contains the expected remediation production, test, canonical-source, mechanically generated, plan, and evidence changes. `artifacts/orchestration/orchestrator-state.json` is absent from the change list.

Command: `git diff --cached --name-only`

EXIT_CODE: 0

Output Summary: Empty output; no file is staged.

Command: `git diff --quiet -- artifacts/orchestration/orchestrator-state.json`

EXIT_CODE: 0

Output Summary: The checkpoint has no working-tree diff.

Command: `rg -n "P6-T26" docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/plan.2026-08-17T07-06.md`

EXIT_CODE: 0

Output Summary: Original feature-plan line `221` remains `- [ ] [P6-T26]`; it is intentionally reserved for separately routed independent executor verification. The original plan has no working-tree change.

## Python production and test paths

| Path | Physical lines | Role |
|---|---:|---|
| `scripts/dev_tools/_orchestrator_state_codex_topology.py` | 253 | canonical production |
| `scripts/dev_tools/_orchestrator_state_codex_model_routing.py` | 224 | canonical production |
| `scripts/dev_tools/validate_orchestrator_state.py` | 486 | canonical production |
| `scripts/dev_tools/_orchestrator_state_complexity.py` | 201 | canonical production |
| `scripts/dev_tools/analyze_coverage_policy.py` | 500 | canonical production |
| `scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py` | 493 | canonical production |
| `scripts/dev_tools/synchronize_customization_bundles.py` | 370 | canonical production |
| `scripts/dev_tools/generate_codex_agent_variants.py` | 445 | canonical production |
| `scripts/dev_tools/generate_orchestration_customization_surfaces.py` | 495 | canonical production |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py` | 358 | canonical test |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py` | 309 | canonical test |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py` | 388 | canonical test |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` | 479 | canonical test |
| `tests/scripts/dev_tools/test_analyze_coverage_policy.py` | 444 | canonical test |
| `tests/scripts/dev_tools/test_parallel_drift_parity.py` | 426 | canonical test |
| `tests/scripts/dev_tools/test_parallel_mutation_parity.py` | 364 | canonical test |
| `tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py` | 290 | canonical test |
| `tests/scripts/dev_tools/test_validate_parallel_planner_state_bounds.py` | 116 | canonical test |
| `tests/scripts/dev_tools/test_synchronize_customization_bundles.py` | 296 | canonical test |
| `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` | 217 | canonical test |
| `tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py` | 259 | canonical test |

The final additional-hot-path ownership boundary is exactly these two production and two test paths:

- `scripts/dev_tools/validate_orchestrator_state.py`: `486` lines; working-tree delta `+3/-5`.
- `scripts/dev_tools/_orchestrator_state_complexity.py`: `201` lines; working-tree delta `+35/-41`.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`: `388` lines; working-tree delta `+55/-0`.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py`: `479` lines; working-tree delta `+95/-1`.

## Mechanically generated root outputs

The owner checks verified these exact generated roots without mutation or drift:

- `.claude/agents/feature-review.md`
- `.claude/agents/orchestrator.md`
- `.claude/agents/task-researcher.md`
- `.claude/rules/orchestrator-state.md`
- `.claude/skills/feature-review-workflow/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.claude/skills/research-issue/SKILL.md`
- `.codex/agents/feature-review.toml`
- `.codex/agents/feature-reviewer.toml`
- `.codex/agents/feature-reviewer-c1.toml`
- `.codex/agents/feature-reviewer-c2.toml`
- `.codex/agents/feature-reviewer-c3.toml`
- `.codex/agents/feature-reviewer-c3-elevated.toml`
- `.codex/agents/feature-reviewer-c4.toml`
- `.codex/agents/orchestrator.toml`
- `.codex/agents/orchestrator-c1.toml`
- `.codex/agents/orchestrator-c2.toml`
- `.codex/agents/orchestrator-c3.toml`
- `.codex/agents/orchestrator-c3-elevated.toml`
- `.codex/agents/orchestrator-c4.toml`
- `.codex/agents/task-researcher.toml`
- `.codex/agents/task-researcher-c1.toml`
- `.codex/agents/task-researcher-c2.toml`
- `.codex/agents/task-researcher-c3.toml`
- `.codex/agents/task-researcher-c3-elevated.toml`
- `.codex/agents/task-researcher-c4.toml`
- `.github/agents/feature-review.agent.md`
- `.github/agents/orchestrator.agent.md`
- `.github/agents/task-researcher.agent.md`
- `.github/prompts/orchestrate-work.prompt.md`
- `.github/prompts/orchestrate-python-work.prompt.md`
- `.github/prompts/orchestrate-powershell-work.prompt.md`
- `.github/prompts/orchestrate-csharp-work.prompt.md`
- `.github/prompts/research-issue.prompt.md`
- `.github/prompts/review-feature.prompt.md`
- `.github/skills/feature-review-workflow/SKILL.md`
- `.github/skills/remediation-handoff-atomic-planner/SKILL.md`

The bundle synchronizer mechanically owns every destination in the following `48`-pair table, including the three verified unchanged language-orchestrator mirrors. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` is also an owner-generated manifest and was not manually implemented.

## Canonical-root/generated-mirror SHA-256 identity

| Canonical root | Generated mirror | Root and mirror SHA-256 | Equal |
|---|---|---|---|
| `.codex/agents/feature-review.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | `C261975B7C99DF8AE5642998D14D4DE85A5B5639FBE788EBB2CC97D601A0E3E3` | yes |
| `.codex/agents/feature-reviewer.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer.toml` | `FCFF52A83C7FD6553DDC4E549E3A846FA5A3281C7D466DFF6C67FE7492560032` | yes |
| `.codex/agents/feature-reviewer-c1.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c1.toml` | `F7E81B59F50382F9A4D5136A93053A77F30F9FAC19E5AE5D63E4D90D96B33B0D` | yes |
| `.codex/agents/feature-reviewer-c2.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c2.toml` | `D38C113D15D511259B309AF32FB27909922B9D217A035AAD9FBB4271E374E28B` | yes |
| `.codex/agents/feature-reviewer-c3.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3.toml` | `3F59513CB43AC8CB969EB971C31BC7A46F9C8C56B92BA6E343DB901D46A532C5` | yes |
| `.codex/agents/feature-reviewer-c3-elevated.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c3-elevated.toml` | `6DF53E711606747940935709B6263C6E5CF214564AD19BAB640C5BC2023954B3` | yes |
| `.codex/agents/feature-reviewer-c4.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-reviewer-c4.toml` | `A68DA0DE64BE500E0B43E809A4A95569711D0787E808F915D7646EE8CE5EDD0D` | yes |
| `.agents/skills/feature-review/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md` | `A52DC54CD520AA42AC8CC6CF527245948E8F84989B253D95184DBC9DB4723655` | yes |
| `.agents/skills/feature-review-workflow/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | `C1C524AD6F13480448428D1B753DCFE8D883B342E08FD6EA97C0251C05DD500A` | yes |
| `.agents/skills/remediation-handoff-atomic-planner/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/remediation-handoff-atomic-planner/SKILL.md` | `A8F901C72678AEC51754359E5085731380E5E9D3D86B6482797B0B252C7770E5` | yes |
| `.github/agents/feature-review.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` | `52CBEEDA434B66EE5E0216A5AEE788230B748D87A157D781B4A002A7927C5FF2` | yes |
| `.github/prompts/review-feature.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md` | `FA08797B649C4EBFDA19683B04F37406437AA95AC4C6C148C8C4363F125AC10F` | yes |
| `.github/skills/feature-review-workflow/SKILL.md` | `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | `9BBEA2A097BC3B9ACF02A717F21830B9194F40FD5DD8C6FC4F7DC7D86F297B14` | yes |
| `.github/skills/remediation-handoff-atomic-planner/SKILL.md` | `extensions/drm-copilot/resources/customizations/.github/skills/remediation-handoff-atomic-planner/SKILL.md` | `CEAB50BBF581D95D806B6EDCEBA76EFA132A977A12D8350190E4BFB5E27EA42F` | yes |
| `.claude/agents/feature-review.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | `EFF5541F548A44584804FA0DB84C5DEDA6A266C2C4A8CA28FA1A0C62E02740F2` | yes |
| `.claude/skills/feature-review-workflow/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | `9BBEA2A097BC3B9ACF02A717F21830B9194F40FD5DD8C6FC4F7DC7D86F297B14` | yes |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `CEAB50BBF581D95D806B6EDCEBA76EFA132A977A12D8350190E4BFB5E27EA42F` | yes |
| `.codex/agents/orchestrator.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` | `CB51B12A635BAC1C9CA5E7D76215698B4C1B37E7213690089AAED462E1124614` | yes |
| `.codex/agents/orchestrator-c1.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c1.toml` | `801BA71F157A72D8B3C940FAED692D1912E69709E8BCA9196F53F826589E3E7B` | yes |
| `.codex/agents/orchestrator-c2.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c2.toml` | `29AD5B7E17C8F0D8B6ED636C42EBF92EB94007BCEC9D7D3B9C0028763EB9A958` | yes |
| `.codex/agents/orchestrator-c3.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3.toml` | `98635CC6072ED5517AB8BC1E827E9AE287B21469DF9A5EC2DD3BCFF41153F02B` | yes |
| `.codex/agents/orchestrator-c3-elevated.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c3-elevated.toml` | `4C156A0962B2296888D767BDD470BAB065BB93A3EED2D2283443413CE950F3C9` | yes |
| `.codex/agents/orchestrator-c4.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator-c4.toml` | `3DF703923A4F01D78E16B5C0C4F8A8DA056108AE09D6DF50845CECFDE4F343EC` | yes |
| `.agents/skills/orchestrate/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` | `7DBB4D31989A5EEB0F094C025B4E92705E68DF082E201CD00FA7C05C2B19B572` | yes |
| `.agents/skills/orchestrator-workflow/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` | `2C3B11095536316F80E2ED923AED43452F2E7A5C115685B488E28B0611C80108` | yes |
| `.github/agents/orchestrator.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md` | `A7580529AB68C6778FD27033CB05021AFBCBFF7C4CE1A5438CD8DB597F9E7669` | yes |
| `.github/agents/python-orchestrator.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md` | `67CB099C6C13901463BCD8CFB95C19123A48213E49F72D94A74A1A147C830081` | yes |
| `.github/agents/powershell-orchestrator.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md` | `343109EC3A2B2702829A142452F32BA9B8257F659E5EEF4A055851BE3A35AF3D` | yes |
| `.github/agents/csharp-orchestrator.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` | `28BBB2ED5C2B7A92599B492462E79B2F767B28277338FEA3F6F0AF1569E35997` | yes |
| `.github/prompts/orchestrate-work.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-work.prompt.md` | `2E2DAE8943350DAD68D941DF169797615779E1F9A920A1BB889DCD26F4A2775A` | yes |
| `.github/prompts/orchestrate-python-work.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md` | `41640248C0C35765B2E4867C3D680D7C1D977203CB8F296B9AB238A985AE8333` | yes |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-powershell-work.prompt.md` | `F4D13CB7ED9F9303F56BA9F0C7D641887BFA4189C57A3C355039E96254BDBEF9` | yes |
| `.github/prompts/orchestrate-csharp-work.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-csharp-work.prompt.md` | `6279D6ED7B990F97955DA7742FD5778A61A959B30EF1F3DA9A0554CC4DBA1259` | yes |
| `.claude/agents/orchestrator.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` | `383150E5D8C2A8964DA1F9FF9EF2368DE6E569BB22752D4E3614EE2929A4722D` | yes |
| `.claude/skills/orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | `557969E48007CFCD038113D22D01452F137E6F0B2EEE78E110422CF87660C101` | yes |
| `.claude/rules/orchestrator-state.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | `6778F137C69B20FEC4EE6879838D5E0FB57636E7513935F7A571AF395B65BBCC` | yes |
| `.codex/agents/task-researcher.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml` | `605B0CCF6C7F297B127535463A012BF894A0D491F8FE680FD30A388A63BFC86F` | yes |
| `.codex/agents/task-researcher-c1.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c1.toml` | `0231D5C57C1BB9DC717AE1DF2F4A59C4781889EBBA1CF25A2AD0AD67892975E2` | yes |
| `.codex/agents/task-researcher-c2.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c2.toml` | `8CA6506E303B99A9359BAFE649FCA5E5B70DEEA8D611079F3DC5F7D651B63873` | yes |
| `.codex/agents/task-researcher-c3.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c3.toml` | `8711449CF9936B7D3E89DB1BE2FF05B62D14BD622ECD8574A424AC881E414474` | yes |
| `.codex/agents/task-researcher-c3-elevated.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c3-elevated.toml` | `05C64703B25AE115095BA062555467AB686674C374816942A0AA780F74024AAD` | yes |
| `.codex/agents/task-researcher-c4.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher-c4.toml` | `55922A26B68175184BD3AF5973FD4407EFBE90DEFB76F4BF2F25EDB53694A9C3` | yes |
| `.agents/skills/research-issue/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md` | `62EEBC0FDE2AF6446CE38E3F6FBA01F90566F9491A3BA0068DCA4F2B505D66CE` | yes |
| `.github/agents/task-researcher.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md` | `76E2F022B6A1C0D7B5266B202562EF7BFA043326FD09E9C7EFC9CF8C892C3F40` | yes |
| `.github/prompts/research-issue.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/prompts/research-issue.prompt.md` | `922FCB705FC668FE2B1C792D26E2233BFE3F510F51C6EAAFB5D8BCDBCB5B3FF4` | yes |
| `.claude/agents/task-researcher.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md` | `980BBD214629707622F80E90448985F00B32398A766E2A4F7C331672B97A868B` | yes |
| `.claude/skills/research-issue/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md` | `0A00036EDA198C9749392EC334BAFAA5CDCFFC5CB3CF432A9CFDCCF2099CA018` | yes |
| `config/orchestration-routing.json` | `extensions/drm-copilot/resources/config/orchestration-routing.json` | `7A30F003994AE274F6B9BF7A2FCC1FF598F0CCE743CC8663060EB3DF50742231` | yes |

## Checkpoint identity and monotonic receipts

| Boundary | SHA-256 | Bytes | Topology total/unique | Model total/unique | Evidence |
|---|---|---:|---:|---:|---|
| P0-T11 | `3CAFE78895E04C42176717E442D8A4C246EA98D3D8A19E6968963FF1ADD7176F` | 115045 | 47 / 3 | 47 / 5 | `evidence/remediation-baseline/p6-t26-exact-benchmark.md` |
| P1-T1 | `E401F8AD9AC00D5BE0F728212DBEC463F5335E2800E82F5C01AA9443B079C0AF` | 121896 | 50 / 3 | 50 / 5 | `evidence/regression-testing/p6-t26-hot-path-diagnosis.md` |
| P2-T28 | `7564F7BDF316BA5BC58C350B63E9799A1323D9248998BA14193CD3140F4DA789` | 172408 | 69 / 8 | 69 / 5 | `evidence/regression-testing/p6-t26-additional-hot-paths-profile.md` |
| P3-T5 | `7564F7BDF316BA5BC58C350B63E9799A1323D9248998BA14193CD3140F4DA789` | 172408 | 69 / 8 | 69 / 5 | `evidence/qa-gates/p6-t26-remediation-exact-benchmark.md` |

Receipt totals never decrease. The P0-to-P1 and P1-to-P2 identity changes are documented monotonic, structurally valid receipt appends. The checkpoint is byte-identical from P2-T28 through P3-T5, and the remediation has no checkpoint working-tree diff.

## Clean Phase 3 evidence

- P3-T1: `evidence/qa-gates/p6-t26-python-black.md` — mutation-free across all 21 files.
- P3-T2: `evidence/qa-gates/p6-t26-python-ruff.md` — zero diagnostics.
- P3-T3: `evidence/qa-gates/p6-t26-python-pyright.md` — full repository, `0` errors / `0` warnings.
- P3-T4 analyzer: `evidence/qa-gates/p6-t26-coverage-analyzer-tests.md` — `26` passed.
- P3-T4 full coverage: `evidence/qa-gates/p6-t26-python-pytest-coverage.md` — `4,474` passed / `5` skipped / `0` failed; line `91.781685%`; branch `83.740831%`.
- P3-T4 policy: `evidence/qa-gates/p6-t26-python-coverage-analysis.md` and `.json` — overall `PASS`; configured-file, changed-line, and new-symbol verdicts pass.
- P3-T5: `evidence/qa-gates/p6-t26-remediation-exact-benchmark.md` — p50 `0.4471999127417803 ms`, p95 `0.47690002247691154 ms`, baseline p95 `0.507500022649765 ms`, ratio `0.9397044358479347 <= 1.10`.
- P2-T28 read-only profile: `evidence/regression-testing/p6-t26-additional-hot-paths-profile.md` — `2` successful complexity-floor calls per validation for `2` unique valid ordered tuples; zero non-strict route-membership and route-matrix-load calls.

## Invariant verification

- `test_non_strict_route_membership_skips_validation` passes and proves non-strict validation does not evaluate route membership.
- `test_strict_route_membership_invokes_validation_and_preserves_diagnostics` passes and proves strict diagnostics remain unchanged.
- `test_duplicate_complexity_signals_compute_floor_once_and_preserve_index_diagnostics` passes and proves the exact ordered signal-tuple key reuses one successful floor while preserving every entry index.
- `test_complexity_floor_cache_is_fresh_per_validation` passes and proves the cache is per invocation and cross-invocation input changes remain fresh.
- `test_invalid_complexity_signals_do_not_compute_floor_and_preserve_index_diagnostics` passes and proves invalid signals are never cached or computed and indexed diagnostics remain intact.
- Code inspection confirms cache insertion occurs only after a successful `compute_complexity_floor` return, and the valid-band rank comparison preserves the existing monotonic `band >= floor` ceiling rule.
- The complete P3-T4 suite and changed-line policy pass without a dependency, suppression, skip, threshold, benchmark command/input/baseline, receipt, or assertion change.
- Generated mirrors were produced only through their owners and are byte-identical to canonical sources; no generated mirror was manually implemented.
- Original P6-T26 remains unchecked for independent executor verification. No failing intermediate state was staged or committed; the index remains empty.

Result: PASS
