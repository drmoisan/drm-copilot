# Codex Variants Regenerated (P8-T7)

Timestamp: 2026-09-29T20-40
Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants; git diff --name-only HEAD -- .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests; git status --porcelain -- <same three pathspecs>; git hash-object <manifest> and git rev-parse HEAD:<manifest> for each of the six listed manifests; git checkout -- <six manifests>; git status --porcelain -- <same three pathspecs>
EXIT_CODE: 0
Output Summary:
- Generator: exit 0, no output.
- git diff --name-only HEAD listed exactly 14 paths: `.codex/agents/python-orchestrator.toml`, `python-typed-engineer.toml`, `-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`, and the same seven file names under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`. Git also printed six `CRLF will be replaced by LF` warnings for the pack manifests.
- First status listed the 14 paths plus six pack manifests (`core.json`, `csharp-legacy.json`, `csharp-modern.json`, `powershell.json`, `python.json`, `typescript.json`) as `M`.
- Manifest hash comparison (worktree blob = HEAD blob for all six):
  - core.json 447b219d4c4a7b4afb677c112a2882078f123ffc = 447b219d4c4a7b4afb677c112a2882078f123ffc
  - csharp-legacy.json c331fef02f9ff1e2b22665dec96cb1d195bd6c74 = c331fef02f9ff1e2b22665dec96cb1d195bd6c74
  - csharp-modern.json 485d6fdcfa4a1d8f9e167712a921f712274c5281 = 485d6fdcfa4a1d8f9e167712a921f712274c5281
  - powershell.json c7c68cfd5d9964d745b6a84038bae7d291b2f85a = c7c68cfd5d9964d745b6a84038bae7d291b2f85a
  - python.json 97fcd7f31a791295cfb89d32e121ce366d258d19 = 97fcd7f31a791295cfb89d32e121ce366d258d19
  - typescript.json 87328f637603106b96d6bb94bdfce4e7afe98cb9 = 87328f637603106b96d6bb94bdfce4e7afe98cb9
- All six manifests restored with `git checkout --` (exit 0). The changes were CRLF-only rewrites by the generator; the committed Codex core manifest entry from Phase 4 is preserved (PD8). This restore is the pre-authorized handling for CRLF-only manifest rewrites.
- Final status lists exactly the 14 variant paths, each ` M`. No variant was hand-edited.
