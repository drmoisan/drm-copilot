# AC-18 Extraction and PD2 Narrowing (P7-T6)

Timestamp: 2026-10-10T08-31
Command: git grep -c -F "def resolve_published_paths(" -- scripts/dev_tools/push_down_claude_pack_selection.py; git grep -c -F "resolve_published_paths(" -- scripts/dev_tools/push_down_claude_customizations.py; poetry run python -c "import scripts.dev_tools.push_down_claude_customizations as m; print('PACK_MANIFEST_SUBDIR', m.PACK_MANIFEST_SUBDIR, 'IN_ALL', 'PACK_MANIFEST_SUBDIR' in m.__all__, 'HAS_PRIVATE', hasattr(m, '_resolve_published_paths'))"; git grep --no-index -l -F "def _resolve_published_paths" -- scripts/dev_tools; git grep -c -F "def _resolve_published_paths" -- scripts/dev_tools/push_down_claude_customizations.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 1. EXIT 0, printed `scripts/dev_tools/push_down_claude_pack_selection.py:1`.
- 2. EXIT 0, printed `scripts/dev_tools/push_down_claude_customizations.py:1`.
- 3. EXIT 0, printed `PACK_MANIFEST_SUBDIR pack-manifests IN_ALL True HAS_PRIVATE False`.
- 4. EXIT 0, printed exactly one line: `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (PD2: the only remaining directory-wide match is the Codex file that AC-20 keeps unchanged).
- 5. EXIT 1, printed nothing (pass condition: no `def _resolve_published_paths` in the Claude entry module).
- Result: PASS. Top-level EXIT_CODE is the last command's exit code, equal to the expected value 1.
