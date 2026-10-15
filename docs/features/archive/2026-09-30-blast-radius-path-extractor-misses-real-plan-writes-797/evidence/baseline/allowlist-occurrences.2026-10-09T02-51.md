# Baseline Allowlist Occurrences (P0-T22)

Timestamp: 2026-10-09T02-51
Command: git grep -n -E "RECOGNIZED_PATH_EXTENSIONS|RecognizedPathExtension" -- scripts .claude extensions tests
EXIT_CODE: 0
Output Summary: exactly six lines, two in each of the Python extraction module, the PowerShell extraction module, and its bundled mirror.

## Output

```text
.claude/lib/blast-radius/BlastRadiusExtraction.psm1:88:$script:RecognizedPathExtension = [System.Collections.Generic.HashSet[string]]::new(
.claude/lib/blast-radius/BlastRadiusExtraction.psm1:335:    $hasExtension = $script:RecognizedPathExtension.Contains($extension)
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1:88:$script:RecognizedPathExtension = [System.Collections.Generic.HashSet[string]]::new(
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1:335:    $hasExtension = $script:RecognizedPathExtension.Contains($extension)
scripts/dev_tools/_blast_radius_extraction.py:92:RECOGNIZED_PATH_EXTENSIONS: frozenset[str] = frozenset(
scripts/dev_tools/_blast_radius_extraction.py:318:    has_extension = extension in RECOGNIZED_PATH_EXTENSIONS
```
