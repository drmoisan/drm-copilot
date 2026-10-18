# P2-T6 independent coverage boundary probes

Timestamp: 2026-10-18T09-29

Command: `poetry run python SCRATCH/issue-980-probe-p2t6.py`

EXIT_CODE: 0

Output Summary: 46/46 cases passed. The script asserts zero failed cases and unchanged production hashes. Authoritative schema validation, existing reference/evidence/claim/revision composition, snapshot immutability, honest structural drafts, exact inventory accounting and the two scope regression cases passed.

```text
{
  "probes": 46,
  "passed": 46,
  "failed": 0,
  "source_hashes": {
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py": "233cc452931fbcfecc0e257c0e7f657cc098031fe77eabe755c1dd2fff36d88a",
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py": "14114f09662b286866fdf092b2cf748694ad03829893139e6c9aef257b8b79ce"
  },
  "source_hashes_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py": "233cc452931fbcfecc0e257c0e7f657cc098031fe77eabe755c1dd2fff36d88a",
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py": "14114f09662b286866fdf092b2cf748694ad03829893139e6c9aef257b8b79ce"
  }
}
[]
```

The full case manifest is retained in SCRATCH/issue-980-p2t6-independent-results.json for final source-bound verification. Final task acceptance remains dependent on specialist quality gates and the staged metrics audit.
