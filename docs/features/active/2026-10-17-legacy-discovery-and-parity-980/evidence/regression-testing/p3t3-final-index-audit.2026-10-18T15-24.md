# p3t3-final-index-audit

Timestamp: 2026-10-18T15-24
Command: poetry run python SCRATCH/issue-980-p3t3-final-audit.py --final
EXIT_CODE: 0
Output Summary:   },;   "minimum_callable": 94.11764705882354,;   "findings": []; }

Working directory: .
Started: 2026-10-18T15:24:19.510099+00:00
Duration seconds: 2.622
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-audit.2026-10-18T15-24.json",
  "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-raw-coverage.2026-10-18T15-24.json",
  "bindings": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-test-bindings.2026-10-18T15-24.json",
  "paths": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/configuration.py",
      "sha256": "0193463923026c5c06d4154b6854a9445682e3a05f372a81f2859b422494d3d2",
      "git_blob": "a756c0b05f39d5e48944ef52c614510bf15d7112",
      "physical_lines": 310,
      "index_git_blob": "a756c0b05f39d5e48944ef52c614510bf15d7112",
      "index_sha256": "6d400df5b3399975f4d090b33f130dd606d265f20f368f01eaf70e0f3430b949",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py",
      "sha256": "dff3a775e99185523bfcae2de63d5eae70a1f397d221899944f28f87789c2bfa",
      "git_blob": "4d3cb9d2a9e79783bf5f4adb44d2485869842c5a",
      "physical_lines": 453,
      "index_git_blob": "4d3cb9d2a9e79783bf5f4adb44d2485869842c5a",
      "index_sha256": "a9d85200e96c73fc7caae24322056abf1b6f8f9d9123fef375ab2fa78d0b22fd",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py",
      "sha256": "e597f46b02e938afe9de51bab42081a66d9b1d277b4458f8ff22ece7bd3f0746",
      "git_blob": "771dfe685c7d2af14a7730f1c705e8038edf3c77",
      "physical_lines": 179,
      "index_git_blob": "771dfe685c7d2af14a7730f1c705e8038edf3c77",
      "index_sha256": "8c4af645ccc060a1747ea24f66b638954100b831de188ea1322317fc7bc13e78",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py",
      "sha256": "790613abf92e1355d14332d52cae3d125a5d139e093cfea0d25cae04eb36b164",
      "git_blob": "9a6ee85ce4a6a08ddce5e44a7a5bc37572a00b37",
      "physical_lines": 436,
      "index_git_blob": "9a6ee85ce4a6a08ddce5e44a7a5bc37572a00b37",
      "index_sha256": "d56547e5f6b4d480485a137e991279be9528a871c709d563abc3813bc00f7010",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "tests/discovery_runtime/test_configuration.py",
      "sha256": "e4d9c7549e8868e209c3df8df9e35fa77bc92a3330ec3f9c44be9a02f3acf425",
      "git_blob": "bd16f8b51c7d46683bcfeaf25f0077a60f13dc49",
      "physical_lines": 330,
      "index_git_blob": "bd16f8b51c7d46683bcfeaf25f0077a60f13dc49",
      "index_sha256": "8af086bf11d0d1f1eaa075d3e41579eafd8829fb3d77403bbfdd976078846cc9",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "tests/discovery_runtime/test_activation_store.py",
      "sha256": "8cc5f600177fa2ae5d3e51c3250e265780d41074bd521b9250f7f9a698ab58cd",
      "git_blob": "c71e675af670672023a3ec768893599c9b642708",
      "physical_lines": 465,
      "index_git_blob": "c71e675af670672023a3ec768893599c9b642708",
      "index_sha256": "c4e1ec325090e2bc9316d710bbf7d39fc33a6fb065ebb153dbb25d636f079544",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "tests/discovery_runtime/test_activation_filesystem.py",
      "sha256": "3d1ade9a26bba3755b7399922937c8ec7f35c06b46e033be1636fe2379f7a134",
      "git_blob": "bf2f24945969d34a5cd7fd12eda2b0e7352338b0",
      "physical_lines": 313,
      "index_git_blob": "bf2f24945969d34a5cd7fd12eda2b0e7352338b0",
      "index_sha256": "06e62b73969952e68842922c4d422057094f614bb88720505249c692baf62b04",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    },
    {
      "path": "tests/discovery_runtime/test_mutation_filesystem.py",
      "sha256": "582a880ea65afadaa103c147da82b4bc0e6ab9f2f79d44e71152583b31ce9e29",
      "git_blob": "bc8c0a1793c1126c334b4ab2383890e3a62e69d1",
      "physical_lines": 484,
      "index_git_blob": "bc8c0a1793c1126c334b4ab2383890e3a62e69d1",
      "index_sha256": "cf239a2551f2ff29b2b0a4a22be3fd889dfed38748a79f3b0ec00ee35388f13e",
      "index_equals_worktree": false,
      "only_checkout_line_endings_differ": true
    }
  ],
  "tests": {
    "pass2": {
      "name": "pytest",
      "errors": "0",
      "failures": "0",
      "skipped": "0",
      "tests": "134",
      "time": "42.895",
      "timestamp": "2026-10-18T11:15:33.881062-04:00",
      "hostname": "Megalodon4"
    },
    "reverse2": {
      "name": "pytest",
      "errors": "0",
      "failures": "0",
      "skipped": "0",
      "tests": "134",
      "time": "20.142",
      "timestamp": "2026-10-18T11:16:55.987787-04:00",
      "hostname": "Megalodon4"
    },
    "pass2-contracts": {
      "name": "pytest",
      "errors": "0",
      "failures": "0",
      "skipped": "0",
      "tests": "385",
      "time": "30.667",
      "timestamp": "2026-10-18T11:17:46.152619-04:00",
      "hostname": "Megalodon4"
    }
  },
  "minimum_callable": 94.11764705882354,
  "findings": []
}
```
