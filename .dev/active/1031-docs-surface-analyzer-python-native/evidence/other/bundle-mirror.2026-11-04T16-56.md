# [P5-T1] Bundle mirror copy

Timestamp: 2026-11-04T16-56
Command: sh SCRATCH/issue-1031-mirror.sh (copies after the last edit of each file; LIB = .claude/lib/docs, MIRROR = extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs)
EXIT_CODE: 0
Output Summary: all seventeen source/copy SHA-256 pairs are equal; the union of the porcelain and name-status listings holds exactly fourteen new and three modified copies; no __pycache__ or .pyc path under MIRROR (and none under LIB/python before the copy).

## Digest pairs (source = copy)

| File (relative to LIB and MIRROR) | SHA-256 |
|---|---|
| python/run_docs_python_native.py | 6e8ae2f6468a3a4e33a8d37730df1504e42c27557c0bc0b8ca5c3db7fd74b9d2 |
| python/docs_python_native/__init__.py | b0ba39db297ffce0859cc2cdecd27992387264f839e151296f80fe12f857df4b |
| python/docs_python_native/protocol.py | 567ca0df762fc9ed0deb328e3b3f5c5ead7894ba58fcf23a0251c82d319474a9 |
| python/docs_python_native/source.py | 50530393316fc3709ccca4fa29f09ea7ae9ba93222a3ba929d43e5d97f47eeb3 |
| python/docs_python_native/imports.py | 97710472fe7d597061195d10931da0600fe024744c6c5be84cf774def91f33b6 |
| python/docs_python_native/cli.py | b0fc2e5c640eff4e3aaec6e59d60f10a8836c89a26b496bc26cae4e01ae3b259 |
| python/docs_python_native/cli_argparse.py | c04014d3f64c4d05b1e4d4c852c3b28ff82ea94743e6b01f929218b83a600dac |
| python/docs_python_native/cli_click.py | 7f5e1cbb128a156139d139cbae0d0939cc6a00002bcb3a0e2fd2288efb9c31e6 |
| python/docs_python_native/cli_typer.py | 1668b13779a828557e2c5fcfd81131c4bdd8b62427ca96330bf8016f20dc2e5b |
| python/docs_python_native/routes.py | a6ba4474fe0f4852fc3a0ca07147d6083136241e118b2d13be3ab849fa871fb4 |
| python/docs_python_native/public_api.py | 49e1fc676f8f0103fe927d4b0205cc077bf09e7b0e869e0551e725a491b707b0 |
| python/docs_python_native/architecture.py | 68c1470b15980f466f33ea1a5e005afc15fd46539a4abc30bdde4280b98b71fa |
| DocsAnalyzerPythonNative.psm1 | 2ae5d38d71407831eba7b2b487f2102a7e80943f7ff7d25bf439da266b419786 |
| DocsPythonNativeProtocol.psm1 | 623a343c0e555f21cca956db259082b45063915a0e36775676568790887be200 |
| DocsAnalyzerRegistry.psm1 | 0a0edccff612654f959ca326ceaec0f547713a604bef14bbb790b0e6c22e4176 |
| DocsInventory.psm1 | c5670cb554ee613edef1ad2c658ada484b3ed86e72dd49cc7fc139012758a3dc |
| Invoke-DocsCommand.ps1 | 17c3be408f5a0f38df69def172ed131b3aad8a39c01be1019b74975f7984a76f |

## Listing (union of git status --porcelain --untracked-files=all and git diff --name-status MERGE_BASE over MIRROR)

Modified (3): DocsAnalyzerRegistry.psm1, DocsInventory.psm1, Invoke-DocsCommand.ps1.

New (14): DocsAnalyzerPythonNative.psm1, DocsPythonNativeProtocol.psm1, python/run_docs_python_native.py, python/docs_python_native/__init__.py, architecture.py, cli.py, cli_argparse.py, cli_click.py, cli_typer.py, imports.py, protocol.py, public_api.py, routes.py, source.py.

__pycache__ / .pyc under MIRROR: none.
