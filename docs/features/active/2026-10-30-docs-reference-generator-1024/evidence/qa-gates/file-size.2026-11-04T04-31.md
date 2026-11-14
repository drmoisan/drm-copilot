# File Size (issue 1024)

Timestamp: 2026-11-04T04-31
Task: [P9-T6]
Command: wc -l over NEW-MODULES, tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1 and NEW-SUITES; each file was checked to end in exactly one LF, so the wc count equals the logical line count
EXIT_CODE: 0
Output Summary: Six production modules, largest 411 logical lines (limit 500). Thirteen test files, largest 646 logical lines (limit 800). No file reaches the 700-line advisory tier. All within limits.

## Production modules (limit 500)

| File | Logical lines | Within limit |
|---|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | 411 | yes |
| `.claude/lib/docs/DocsReferenceRender.psm1` | 184 | yes |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | 382 | yes |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | 253 | yes |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | 377 | yes |
| `.claude/lib/docs/DocsReferenceReport.psm1` | 191 | yes |

## Test files (limit 800)

| File | Logical lines | Within limit |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` | 646 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceBoundary.Tests.ps1` | 278 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Properties.Tests.ps1` | 210 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1` | 296 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1` | 314 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceMarkers.Properties.Tests.ps1` | 269 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceMarkers.Tests.ps1` | 347 | yes |
| `tests/scripts/claude-lib/docs/DocsReferencePlan.Properties.Tests.ps1` | 290 | yes |
| `tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1` | 412 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceRender.Tests.ps1` | 341 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Errors.Tests.ps1` | 285 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Properties.Tests.ps1` | 286 | yes |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1` | 314 | yes |
