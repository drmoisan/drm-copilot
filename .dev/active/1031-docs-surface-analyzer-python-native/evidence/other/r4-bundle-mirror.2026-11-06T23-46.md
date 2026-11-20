# [P4-T1] Bundle mirror of the eighteen helper files

Timestamp: 2026-11-06T23-46
Command: `sh SCRATCH/issue-1031-x-mirror.sh` (one copy script), then git status --porcelain --untracked-files=all and git diff --name-status HEAD over MIRROR/python
EXIT_CODE: 0
Output Summary: 18 files copied after the last Python edit, 18 digest pairs equal. The listing shows the six new copies and the eleven modified copies whose source changed in Phases 2 and 3; __init__.py did not change, so its copy is not listed. No __pycache__ path and no path outside the eighteen copies.

## Listing

```text
     M docs_python_native/architecture.py
     M docs_python_native/cli.py
     M docs_python_native/cli_argparse.py
     M docs_python_native/cli_click.py
     M docs_python_native/cli_typer.py
     M docs_python_native/imports.py
     M docs_python_native/protocol.py
     M docs_python_native/public_api.py
     M docs_python_native/routes.py
     M docs_python_native/source.py
     M run_docs_python_native.py
    ?? docs_python_native/call_sites.py
    ?? docs_python_native/facts.py
    ?? docs_python_native/module_names.py
    ?? docs_python_native/route_model.py
    ?? docs_python_native/route_sites.py
    ?? docs_python_native/walk.py
    M	docs_python_native/architecture.py
    M	docs_python_native/cli.py
    M	docs_python_native/cli_argparse.py
    M	docs_python_native/cli_click.py
    M	docs_python_native/cli_typer.py
    M	docs_python_native/imports.py
    M	docs_python_native/protocol.py
    M	docs_python_native/public_api.py
    M	docs_python_native/routes.py
    M	docs_python_native/source.py
    M	run_docs_python_native.py
```

## Digest pairs

| File | Source SHA-256 | Copy SHA-256 | Result |
|---|---|---|---|
| run_docs_python_native.py | eecf5941a64fe42cca75e970b5010ce0787eaffd42ae1d8f67ee1f24c2e53983 | eecf5941a64fe42cca75e970b5010ce0787eaffd42ae1d8f67ee1f24c2e53983 | equal |
| docs_python_native/__init__.py | b0ba39db297ffce0859cc2cdecd27992387264f839e151296f80fe12f857df4b | b0ba39db297ffce0859cc2cdecd27992387264f839e151296f80fe12f857df4b | equal |
| docs_python_native/architecture.py | ac538cdd4363f31cf9cc1f6169121d3af4fca2bf092fa75f4b5e1a21a5386d46 | ac538cdd4363f31cf9cc1f6169121d3af4fca2bf092fa75f4b5e1a21a5386d46 | equal |
| docs_python_native/call_sites.py | 9f364179bf5ad5cd0c877c0f9eecd59b32866f05044c068356d01f1fcbc01c84 | 9f364179bf5ad5cd0c877c0f9eecd59b32866f05044c068356d01f1fcbc01c84 | equal |
| docs_python_native/cli.py | c76ee9bc1e8e9562d5aa08cead45eaece23bc075615eed655dbe101e0cbf61cc | c76ee9bc1e8e9562d5aa08cead45eaece23bc075615eed655dbe101e0cbf61cc | equal |
| docs_python_native/cli_argparse.py | 3b4c2ae4189d698eee98201e165ad856db009a05212e1a2cada96da392374dfa | 3b4c2ae4189d698eee98201e165ad856db009a05212e1a2cada96da392374dfa | equal |
| docs_python_native/cli_click.py | 6ae835ab89fe94a210116175fce35ab2638e4de3747a88d0da94ba6562aae3ac | 6ae835ab89fe94a210116175fce35ab2638e4de3747a88d0da94ba6562aae3ac | equal |
| docs_python_native/cli_typer.py | 17c166745ebdd3e38b941b24c9882920c023d446ad9e1a974aa04de9e873d82a | 17c166745ebdd3e38b941b24c9882920c023d446ad9e1a974aa04de9e873d82a | equal |
| docs_python_native/facts.py | 6e0327583b8efc31b52122408c2fa118e3132ad7aa4cf2b74e258e6a1e796fed | 6e0327583b8efc31b52122408c2fa118e3132ad7aa4cf2b74e258e6a1e796fed | equal |
| docs_python_native/imports.py | 625de135e525c5e3a8188ac07dceffc5d6e8331d37f7d1781ce369ffb9a30bb8 | 625de135e525c5e3a8188ac07dceffc5d6e8331d37f7d1781ce369ffb9a30bb8 | equal |
| docs_python_native/module_names.py | 4f58ec38ce5aba67a105db9a309a9c4bebb42b45a9abd083ad50adf2bf2bfb85 | 4f58ec38ce5aba67a105db9a309a9c4bebb42b45a9abd083ad50adf2bf2bfb85 | equal |
| docs_python_native/protocol.py | ce190f45849da01eb37d41607bbfe272c4432753665b89b3fde917d7dea7cc0f | ce190f45849da01eb37d41607bbfe272c4432753665b89b3fde917d7dea7cc0f | equal |
| docs_python_native/public_api.py | 4fd11a6b9fb1d5ba0d56c458d61f8000598cf6862dbf829b15861a57e59b32e6 | 4fd11a6b9fb1d5ba0d56c458d61f8000598cf6862dbf829b15861a57e59b32e6 | equal |
| docs_python_native/route_model.py | 07e7192b3ccebe8f97b0a601102f9b5be073b92c34de1e5beaa46b12cc0c3fed | 07e7192b3ccebe8f97b0a601102f9b5be073b92c34de1e5beaa46b12cc0c3fed | equal |
| docs_python_native/route_sites.py | b74280bbf6c8486719d0fae507b4f7c1bdaff20fe0184c02fb83cbfbe598025d | b74280bbf6c8486719d0fae507b4f7c1bdaff20fe0184c02fb83cbfbe598025d | equal |
| docs_python_native/routes.py | 7deb1c2569891c488a5c60a879671b8f6c6c97ee35dc506f6bf6914bdfc3441c | 7deb1c2569891c488a5c60a879671b8f6c6c97ee35dc506f6bf6914bdfc3441c | equal |
| docs_python_native/source.py | a022846ee835f01f568bd89acda91cb0bca6c04de13f761432680312e707579c | a022846ee835f01f568bd89acda91cb0bca6c04de13f761432680312e707579c | equal |
| docs_python_native/walk.py | c3903f570ccc6e92aae5d4a5089e2e9cafa54f4686a2e292371c984f6b4163ed | c3903f570ccc6e92aae5d4a5089e2e9cafa54f4686a2e292371c984f6b4163ed | equal |
