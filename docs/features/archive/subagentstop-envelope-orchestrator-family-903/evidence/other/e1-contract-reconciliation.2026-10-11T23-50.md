# E1 Contract Drift Check and Helper Reconciliation ([P0-T5])

Timestamp: 2026-10-11T23-50
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/e1-contract-drift.ps1 -SpecPath docs/features/active/subagentstop-envelope-core-897/spec.md -PinnedBlob bf86505ca3bd6a2bae05fb5c16f053110af9666d; sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/helper-surface.ps1 -HelperPath .claude/hooks/subagentstop-envelope.ps1; rg -n -F "Console]::In.ReadToEnd()" .claude/hooks/subagentstop-envelope.ps1; rg -n "CLAUDE_HOOK_INPUT" .claude/hooks/subagentstop-envelope.ps1; rg -n -e 'Import-Module' -e 'using module' -e '^\s*\. ' .claude/hooks/subagentstop-envelope.ps1
EXIT_CODE: 0
Output Summary: No contract drift (HeadingMismatchCount=0, PolicyIdentical=True, contract section identical to the pinned blob). Helper surface complete. The import search matches only help-text line 7; AST and statement-anchored checks find no import (see DEVIATION).

E1_SPEC_PATH: docs/features/active/subagentstop-envelope-core-897/spec.md
E1_SPEC_BLOB: 388e2c0b7fe680cb738114e6bffade8ab5e67f9f
HELPER_BLOB: 2cc85967e7755907f77ee7263298f0af7739d7aa

A11 output (EXIT_CODE: 0):
E1_SPEC_BLOB=388e2c0b7fe680cb738114e6bffade8ab5e67f9f
HEADING index=1 Present=True
HEADING index=2 Present=True
HEADING index=3 Present=True
POLICY-SUBSECTION CurrentLength=1054 PinnedLength=1054 Identical=True
CONTRACT-SECTION IdenticalToPinned=True
DRIFT-SUMMARY HeadingMismatchCount=0 PolicyIdentical=True

A12 output (EXIT_CODE: 0):
HELPER-FUNCTION name=Read-SubagentStopEnvelope Count=1 Parameters=InputText
HELPER-FUNCTION name=Get-SubagentStopEnvelopeAnomalyReason Count=1 Parameters=Anomaly
HELPER-FUNCTION name=Exit-SubagentStopBlock Count=1 Parameters=Message
HELPER-SURFACE-SUMMARY MissingCount=0 ReadParameters=InputText AnomalyParameters=Anomaly BlockParameters=Message

Search 1 (stdin source), exit 0:
86:            $text = [Console]::In.ReadToEnd()
Search 2 (CLAUDE_HOOK_INPUT), exit 1, no match.
Search 3 (imports), exit 0:
7:    either settings.json copy. It imports nothing (no Import-Module, no using module, no dot-source),

STDIN_SOURCE: 86:            $text = [Console]::In.ReadToEnd()
BLOCK_PARAMETER: Message
HELPER_READS_CLAUDE_HOOK_INPUT: NO
HELPER_IMPORTS_NOTHING: NO (literal formula: the third search exited 0)
HELPER_IMPORTS_NOTHING_BY_AST: YES

DEVIATION: The third search matches help-text line 7, which states that the helper imports nothing. It does not match an import statement. Supplementary checks:
- AST check (`<SCRATCHPAD>/helper-import-ast.ps1`, ParseFile over the helper): `AST-IMPORT ImportModuleCommands=0 DotSourceCommands=0 UsingStatements=0`.
- Statement-anchored search `rg -n -e '^\s*Import-Module' -e '^\s*using module' -e '^\s*\. ' .claude/hooks/subagentstop-envelope.ps1` exited 1 with no match.
The condition this field checks (the helper imports nothing, E1 contract bullet "Imports nothing") holds. The literal formula fails only because the search pattern also matches comment text. The executor did not halt on this field. Rule 8 targets real reconciliation failures, and the executor protocol does not allow blocking after execution begins. The deviation is reported to the caller for confirmation. All other [P0-T5] acceptance values are met as written.
