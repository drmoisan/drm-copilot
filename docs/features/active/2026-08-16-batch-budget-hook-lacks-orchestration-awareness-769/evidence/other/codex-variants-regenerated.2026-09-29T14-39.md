# Codex Variant Regeneration (#769, P7-T5) — ACCEPTANCE NOT MET, EXECUTION STOPPED

Timestamp: 2026-09-29T14-39
Command: poetry run python -m scripts.dev_tools.generate_codex_agent_variants; git status --porcelain -- .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests
EXIT_CODE: 0
Output Summary:
Generator exit code: 0.
git status --porcelain listed 18 paths, each with status M:
- the twelve expected paths: .codex/agents/powershell-typed-engineer.toml, -c1, -c2, -c3, -c3-elevated, -c4 and the same six under extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/
- six additional paths not anticipated by the plan: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json, csharp-legacy.json, csharp-modern.json, powershell.json, python.json, typescript.json

Diagnosis (read-only):
- `git diff --stat HEAD -- .../pack-manifests` prints no file lines; git reports "CRLF will be replaced by LF the next time Git touches it" for each of the six manifests.
- `git hash-object <manifest>` equals `git rev-parse HEAD:<manifest>` for all six (core a40e01b0, csharp-legacy c331fef0, csharp-modern 485d6fdc, powershell c7c68cfd, python 97fcd7f3, typescript 87328f63). The generator rewrote the manifests with CRLF line endings on disk; their normalized content is identical to HEAD.
- `git diff --name-only HEAD` over the same three pathspecs lists exactly the twelve expected TOML paths (content-level changes).
- Repository settings: core.autocrlf=true; the manifests carry the attribute eol=lf.

Initial acceptance: NOT MET as written ("no other path"). Execution stopped at P7-T5 and was reported to the orchestrator.

## Orchestrator-authorized deviation (resolution)

The orchestrator verified the six manifest blob hashes independently and authorized restoring them. The generator's CRLF rewrite of the six manifests was reverted: their blob hashes are identical to HEAD, and the on-disk difference comes from the generator writing CRLF under `core.autocrlf=true` while the files carry `eol=lf`.

Command: git checkout -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json .../csharp-legacy.json .../csharp-modern.json .../powershell.json .../python.json .../typescript.json
EXIT_CODE: 0

Re-run of the P7-T5 status check (git status --porcelain -- .codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests) listed exactly the twelve expected paths, each with status M, and no other path:
.codex/agents/powershell-typed-engineer.toml, -c1.toml, -c2.toml, -c3.toml, -c3-elevated.toml, -c4.toml, and the same six under extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/.
No variant was hand-edited.

Final acceptance: MET after the orchestrator-authorized restore.
