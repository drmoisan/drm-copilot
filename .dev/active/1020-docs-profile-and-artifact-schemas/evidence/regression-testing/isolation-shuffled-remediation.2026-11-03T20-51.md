# Seeded shuffled file-order isolation run (cycle 1, P2-T5)

Timestamp: 2026-11-03T20-51
Command: Invoke-Pester in one process per seed over the four touched suites in a seeded shuffled order (System.Random seeded with 101, 202, 303; helper and launcher under SCRATCH)
EXIT_CODE: 0
Output Summary: 3 seeds, 112 tests per seed (Docs.Manifest 7, DocsSchema 37, DocsProfileCommands 22, Invoke-DocsCommand 46), 0 failures for every seed. The executed container order equals the requested order for every seed.

Seed 101 order: Docs.Manifest, DocsSchema, DocsProfileCommands, Invoke-DocsCommand (112 passed, 0 failed)
Seed 202 order: DocsProfileCommands, Invoke-DocsCommand, Docs.Manifest, DocsSchema (112 passed, 0 failed)
Seed 303 order: Invoke-DocsCommand, Docs.Manifest, DocsSchema, DocsProfileCommands (112 passed, 0 failed)

All suites are under tests/scripts/claude-lib/docs. The new -WhatIf tests set the preference only inside their own scriptblock and create no files, so no state leaks between suites.
