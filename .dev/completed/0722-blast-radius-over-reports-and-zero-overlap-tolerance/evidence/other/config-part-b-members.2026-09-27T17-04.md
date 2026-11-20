# Part B Configuration Members (P9-T2, P9-T3, P9-T4)

Timestamp: 2026-09-27T17-04
Command: poetry run python SCRATCH/p9-config-check.py
EXIT_CODE: 0
Output Summary: Both config copies parse as JSON. Both append .github/copilot-instructions.md to mandate_reads, and the two mandate_reads lists are equal. Both carry write_intent_extraction true, inserted with path_roots immediately after conflict_tolerance (key order matches the Part B order of block B20). The self-hosted path_roots equals the ordinally sorted 17-entry P0-T28 list exactly; the bundled path_roots is an empty list.

## Printed output

```text
PARSED config/blast-radius.json
PARSED extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
SELF-HOSTED keys=['version', 'shared_surfaces', 'shared_surface_globs', 'mandate_reads', 'mergeable_paths', 'conflict_tolerance', 'write_intent_extraction', 'path_roots', 'modules', 'over_breadth_fraction']
BUNDLED keys=['version', 'shared_surfaces', 'shared_surface_globs', 'mandate_reads', 'mergeable_paths', 'conflict_tolerance', 'write_intent_extraction', 'path_roots', 'modules', 'over_breadth_fraction']
SELF-HOSTED mandate_reads-last=.github/copilot-instructions.md
SELF-HOSTED write_intent_extraction=True
PATH-ROOTS-EQUAL-P0-T28=True
PATH-ROOTS-ORDINALLY-SORTED=True
MANDATE-READS-EQUAL=True
WRITE-INTENT-EQUAL=True
BUNDLED-PATH-ROOTS=[]
```

## Script text (SCRATCH/p9-config-check.py)

```python
import json
from pathlib import Path

P0_T28 = [".agents", ".cache", ".claude", ".codex", ".devcontainer", ".github", ".vscode", "config", "docs", "examples", "extensions", "packages", "schemas", "scripts", "src", "tests", "virtual"]
self_hosted = json.loads(Path("config/blast-radius.json").read_text(encoding="utf-8"))
print("PARSED config/blast-radius.json")
bundled = json.loads(Path("extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json").read_text(encoding="utf-8"))
print("PARSED extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json")
print(f"SELF-HOSTED keys={list(self_hosted)}")
print(f"BUNDLED keys={list(bundled)}")
print(f"SELF-HOSTED mandate_reads-last={self_hosted['mandate_reads'][-1]}")
print(f"SELF-HOSTED write_intent_extraction={self_hosted['write_intent_extraction']!r}")
print(f"PATH-ROOTS-EQUAL-P0-T28={self_hosted['path_roots'] == P0_T28}")
print(f"PATH-ROOTS-ORDINALLY-SORTED={self_hosted['path_roots'] == sorted(self_hosted['path_roots'])}")
print(f"MANDATE-READS-EQUAL={self_hosted['mandate_reads'] == bundled['mandate_reads']}")
print(f"WRITE-INTENT-EQUAL={self_hosted['write_intent_extraction'] == bundled['write_intent_extraction'] and type(bundled['write_intent_extraction']) is bool}")
print(f"BUNDLED-PATH-ROOTS={bundled['path_roots']!r}")
```

The P0_T28 list is copied from evidence/baseline/config-value-inputs.2026-09-27T15-12.md.
SCRATCH denotes the executor session scratchpad directory (outside the repository).
