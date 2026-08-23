# P6-T26 customization contract projection repair

Timestamp: 2026-08-23T01-49

Output Summary: PASS. P2-T15 changed only the two authorized Python generator
files, regenerated all affected outputs through their owners, and preserved the
unchanged generator tests. The first generator-test run detected the expected
checked-in output drift after the generator implementation changed. The owner
generation sequence corrected that drift, and the required local sequence was
restarted at Black. The clean pass completed with Black unchanged, Ruff clean,
focused Pyright at 0 errors and 0 warnings, and 27 generator tests passing. All
three final owner checks passed. Strict wrapper fragments, the blocked-state
wording, and the active-feature-document guard are present in their required
generated projections. No Codex projection contains GitHub extension-command or
Claude promotion-receipt identifiers.

## Authorized implementation paths

- `scripts/dev_tools/generate_codex_agent_variants.py`
- `scripts/dev_tools/generate_orchestration_customization_surfaces.py`

No test file, canonical Markdown source, dependency, suppression, public
generator interface, assertion, or literal contract was changed by P2-T15.

## Command results

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: First pass left all four files unchanged.

Command: `poetry run ruff check scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: First pass reported all checks passed.

Command: `poetry run pyright scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: First pass reported 0 errors and 0 warnings.

Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 1

Output Summary: Expected intermediate owner-output drift after the generator
implementation changed: 25 passed and 2 failed because orchestrator and
task-researcher aliases/variants had not yet been regenerated. No failing state
was staged or committed.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces`

EXIT_CODE: 0

Output Summary: Updated owner-generated `.codex/agents/feature-review.toml` and
verified 20 orchestration customization surfaces.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`

EXIT_CODE: 0

Output Summary: Regenerated the affected orchestrator and task-researcher base
aliases and routed variants in the repository and bundle.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles`

EXIT_CODE: 0

Output Summary: Updated the bundled feature-review agent and verified 48
packaged customization mappings.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces --check`

EXIT_CODE: 0

Output Summary: Verified 20 orchestration customization surfaces.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: 0

Output Summary: No Codex agent alias, routed variant, or manifest drift.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles --check`

EXIT_CODE: 0

Output Summary: Verified 48 packaged customization mappings.

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: Restarted clean pass left all four files unchanged.

Command: `poetry run ruff check scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: Restarted clean pass reported all checks passed.

Command: `poetry run pyright scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: Restarted clean pass reported 0 errors and 0 warnings.

Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: 0

Output Summary: 27 passed in 0.21 seconds.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces`

EXIT_CODE: 0

Output Summary: Final owner pass verified 20 orchestration customization
surfaces without further updates.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`

EXIT_CODE: 0

Output Summary: Final owner pass completed without further updates.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles`

EXIT_CODE: 0

Output Summary: Final owner pass verified 48 packaged customization mappings
without further updates.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces --check`

EXIT_CODE: 0

Output Summary: Final check verified 20 orchestration customization surfaces.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: 0

Output Summary: Final check found no Codex agent or manifest drift.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles --check`

EXIT_CODE: 0

Output Summary: Final check verified 48 packaged customization mappings.

## Python file-size gate

- `scripts/dev_tools/generate_codex_agent_variants.py`: 445 lines
- `scripts/dev_tools/generate_orchestration_customization_surfaces.py`: 499 lines
- `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`: 217 lines
- `tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`: 259 lines

## Contract verification

- `.codex/agents/feature-review.toml`: all unchanged
  `WRAPPER_REQUIRED_FRAGMENTS` literals present; canonical migration source is
  `.github/agents/feature-review.agent.md`.
- `.codex/agents/task-researcher.toml`: all unchanged
  `WRAPPER_REQUIRED_FRAGMENTS` literals present; canonical migration source is
  `.github/agents/task-researcher.agent.md`.
- `.codex/agents/orchestrator.toml` and all five routed orchestrator variants:
  exact `stop and report blocked state` wording present.
- `.codex/agents/orchestrator.toml` and all five routed orchestrator variants:
  exact ``Do not create or edit `${feature-folder}/issue.md`,
  `${feature-folder}/spec.md`, `${feature-folder}/user-story.md`, or `plan*.md`
  until`` guard present.
- All 13 affected Codex root files contain neither `drmCopilotExtension.` nor
  `delegation_receipts.promotion.`.
- The two generator tests have no working-tree diff.

## Mechanically generated root/mirror SHA-256 pairs

Each root hash equals the corresponding file below
`extensions/drm-copilot/resources/codex-and-agents-customizations/`.

| Generated path | Root SHA-256 | Mirror SHA-256 | Equal |
|---|---|---|---|
| `.codex/agents/feature-review.toml` | `C261975B7C99DF8AE5642998D14D4DE85A5B5639FBE788EBB2CC97D601A0E3E3` | `C261975B7C99DF8AE5642998D14D4DE85A5B5639FBE788EBB2CC97D601A0E3E3` | yes |
| `.codex/agents/orchestrator.toml` | `CB51B12A635BAC1C9CA5E7D76215698B4C1B37E7213690089AAED462E1124614` | `CB51B12A635BAC1C9CA5E7D76215698B4C1B37E7213690089AAED462E1124614` | yes |
| `.codex/agents/orchestrator-c1.toml` | `801BA71F157A72D8B3C940FAED692D1912E69709E8BCA9196F53F826589E3E7B` | `801BA71F157A72D8B3C940FAED692D1912E69709E8BCA9196F53F826589E3E7B` | yes |
| `.codex/agents/orchestrator-c2.toml` | `29AD5B7E17C8F0D8B6ED636C42EBF92EB94007BCEC9D7D3B9C0028763EB9A958` | `29AD5B7E17C8F0D8B6ED636C42EBF92EB94007BCEC9D7D3B9C0028763EB9A958` | yes |
| `.codex/agents/orchestrator-c3.toml` | `98635CC6072ED5517AB8BC1E827E9AE287B21469DF9A5EC2DD3BCFF41153F02B` | `98635CC6072ED5517AB8BC1E827E9AE287B21469DF9A5EC2DD3BCFF41153F02B` | yes |
| `.codex/agents/orchestrator-c3-elevated.toml` | `4C156A0962B2296888D767BDD470BAB065BB93A3EED2D2283443413CE950F3C9` | `4C156A0962B2296888D767BDD470BAB065BB93A3EED2D2283443413CE950F3C9` | yes |
| `.codex/agents/orchestrator-c4.toml` | `3DF703923A4F01D78E16B5C0C4F8A8DA056108AE09D6DF50845CECFDE4F343EC` | `3DF703923A4F01D78E16B5C0C4F8A8DA056108AE09D6DF50845CECFDE4F343EC` | yes |
| `.codex/agents/task-researcher.toml` | `605B0CCF6C7F297B127535463A012BF894A0D491F8FE680FD30A388A63BFC86F` | `605B0CCF6C7F297B127535463A012BF894A0D491F8FE680FD30A388A63BFC86F` | yes |
| `.codex/agents/task-researcher-c1.toml` | `0231D5C57C1BB9DC717AE1DF2F4A59C4781889EBBA1CF25A2AD0AD67892975E2` | `0231D5C57C1BB9DC717AE1DF2F4A59C4781889EBBA1CF25A2AD0AD67892975E2` | yes |
| `.codex/agents/task-researcher-c2.toml` | `8CA6506E303B99A9359BAFE649FCA5E5B70DEEA8D611079F3DC5F7D651B63873` | `8CA6506E303B99A9359BAFE649FCA5E5B70DEEA8D611079F3DC5F7D651B63873` | yes |
| `.codex/agents/task-researcher-c3.toml` | `8711449CF9936B7D3E89DB1BE2FF05B62D14BD622ECD8574A424AC881E414474` | `8711449CF9936B7D3E89DB1BE2FF05B62D14BD622ECD8574A424AC881E414474` | yes |
| `.codex/agents/task-researcher-c3-elevated.toml` | `05C64703B25AE115095BA062555467AB686674C374816942A0AA780F74024AAD` | `05C64703B25AE115095BA062555467AB686674C374816942A0AA780F74024AAD` | yes |
| `.codex/agents/task-researcher-c4.toml` | `55922A26B68175184BD3AF5973FD4407EFBE90DEFB76F4BF2F25EDB53694A9C3` | `55922A26B68175184BD3AF5973FD4407EFBE90DEFB76F4BF2F25EDB53694A9C3` | yes |

Staging status: no staged files.

Commit status: no commit created.
