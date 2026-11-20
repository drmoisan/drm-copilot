# File sizes (NEW-PS)

Timestamp: 2026-11-07T22-00
Command: sh SCRATCH/issue-1038-scans.sh size (awk 'END { print NR }' <file>; a trailing line terminator adds no line)
EXIT_CODE: 0
Output Summary: every NEW-PS file is below 500 logical lines; the largest is 302.

- tests/scripts/claude-lib/docs/EpicManifest.TestSupport.psm1 | 302
- tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1 | 218
- tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 | 251
- tests/scripts/claude-lib/docs/DocumentationEstateFixture.TestSupport.psm1 | 163
- tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1 | 271
