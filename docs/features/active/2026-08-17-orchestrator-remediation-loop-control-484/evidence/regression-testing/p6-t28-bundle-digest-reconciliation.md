Timestamp: 2026-08-23T09-14
Command: `git diff -- tests/scripts/dev_tools/test_mcp_bundle_parity.py`
EXIT_CODE: 0
Output Summary: Mechanical identity batch `PY-IDENTITY-A` replaced only the previously installed provisional fixed digest with the new complete P4-T11 digest. Relative to HEAD, exactly one fixed expected digest literal differs: one line added and one line removed. The existing `embedded_digests[0] == (...)` assertion, its structure, fixtures, and all other bytes remain unchanged. The file remains `115` physical lines and no production file, dependency, suppression, or assertion was added or weakened.
P4-T11 Complete Digest: `sha256:49831b959858755cad2399af16f7d6306b0a7c5e915a67f93b783e15400b7361`
Previously Installed Literal: `sha256:200c4f984c1ca8126c375cd205cfaf9d641965f392faafd5e7986b8bc47f4eb3`
HEAD Literal: `sha256:72937c91d2cf0ad6809dd1c970ffa38f06eae4248c73222aa45f47266d63b0f4`
New Literal: `sha256:49831b959858755cad2399af16f7d6306b0a7c5e915a67f93b783e15400b7361`
Diff Numstat: `1 1 tests/scripts/dev_tools/test_mcp_bundle_parity.py`
