# Upstream neutrality source (D-8)

Timestamp: 2026-11-07T20-41
Command: Read tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1; grep the tree for ConsumerIdentifierSha256
EXIT_CODE: 0
Output Summary: The 1020 digest list exists only as the `$script:ConsumerIdentifierSha256` assignment inside the BeforeAll block of DocsNeutrality.Tests.ps1 (no importable module exports it). D-8 therefore applies its second branch: the onboarding suite reads that file as text once and extracts the lowercase 64-hex tokens of that assignment.

DIGEST-SOURCE: tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1 | $script:ConsumerIdentifierSha256
DIGEST-COUNT: 2
TOKENIZATION: lowercase the text (ToLowerInvariant); collect every maximal match of [a-z0-9]+ and of [a-z0-9]+(?:[-_.][a-z0-9]+)+ into an ordinal set; hash each candidate as the lowercase hex SHA-256 of its UTF-8 text (Get-DocsSha256Hex in .claude/lib/docs/DocsJson.psm1); a candidate whose digest is in the list is a finding.
