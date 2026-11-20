# P2-T6 independent runtime identity probes

Timestamp: 2026-10-18T09-29

Command: `poetry run python SCRATCH/issue-980-probe-p2t6-runtime.py`

EXIT_CODE: 0

Output Summary: 2/2 cases passed with unchanged production hashes. Valid same-source observed runtime supports coverage. A target-local observed scenario with a fully pinned link to an imported source feature cannot satisfy the source ledger's runtime obligation; COVERAGE_RUNTIME is emitted, while upstream graph/evidence/claim/revision checks remain clean.

```text
{
  "probes": 2,
  "passed": 2,
  "failed": 0,
  "source_hashes": {
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py": "233cc452931fbcfecc0e257c0e7f657cc098031fe77eabe755c1dd2fff36d88a",
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py": "14114f09662b286866fdf092b2cf748694ad03829893139e6c9aef257b8b79ce"
  },
  "source_hashes_after": {
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py": "233cc452931fbcfecc0e257c0e7f657cc098031fe77eabe755c1dd2fff36d88a",
    "packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py": "14114f09662b286866fdf092b2cf748694ad03829893139e6c9aef257b8b79ce"
  },
  "results": [
    {
      "name": "same-source observed runtime supports source coverage",
      "coverage": [],
      "upstream": [],
      "passed": true
    },
    {
      "name": "target runtime cannot satisfy source required characterization",
      "coverage": [
        "COVERAGE_RUNTIME"
      ],
      "upstream": [],
      "passed": true
    }
  ]
}
```

The full case manifest is retained in SCRATCH/issue-980-p2t6-runtime-independent-results.json for final source-bound verification. This assertion-based result resolves the runtime provenance defect without modifying accepted prior rules.
