# p1t2-installed-smoke

Timestamp: 2026-10-18T04-52
Command: poetry run python -I -S SCRATCH/issue-980-p1t2-installed-smoke.py --installation SCRATCH/issue-980-p1t2-installed --dependencies .venv/Lib/site-packages --wheel SCRATCH/issue-980-p1t2-dist/drm_copilot_discovery-2.0.0-py3-none-any.whl
EXIT_CODE: 0
Output Summary:   "wheel": "drm_copilot_discovery-2.0.0-py3-none-any.whl",;   "wheel_sha256": "d24139d8de67ad5ae4aa81487e4fc79b66be3741e6f3171790c2f6e309de380e",;   "working_directory": "SCRATCH/issue-980-p1t2-independent-cwd"; }

Working directory: .
Started: 2026-10-18T04:52:18.229161+00:00
Duration seconds: 0.930
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
{
  "all_installed_modules_imported": [
    "drm_copilot_discovery/__init__.py",
    "drm_copilot_discovery/domain_profile.py",
    "drm_copilot_discovery/domain_profile_models.py",
    "drm_copilot_discovery/init_models.py",
    "drm_copilot_discovery/io.py",
    "drm_copilot_discovery/rendering.py",
    "drm_copilot_discovery/resources.py"
  ],
  "installed_package": "SCRATCH/issue-980-p1t2-installed/drm_copilot_discovery",
  "isolated_interpreter": true,
  "resource_count": 7,
  "resource_hashes": {
    "schemas/discovery/v1/coverage-ledger.schema.json": "5c55f4199f8a03ac4dc06c494d8ae4fd3e52117251b7db5eda919bf1ea773319",
    "schemas/discovery/v1/evidence-reference.schema.json": "216728595bc3f8da90b26f3e22ae2dc33333bb6e1088d40d6305c3f461c5bb7a",
    "schemas/discovery/v1/feature-contract.schema.json": "97776cdb4974792ce796600c9a27508bcb610e47ca4dc54813b681e71e82bb54",
    "schemas/discovery/v1/parity-matrix.schema.json": "dcc4e21e53e7d38b7ba241aaac78285ca5212f38bf79d9eeb50c69e8a833b399",
    "schemas/discovery/v1/product-decision-record.schema.json": "da47c8e724dfcfdd7d2deba527b45144f588fec96cbaf710d75d17712c9deadb",
    "schemas/discovery/v1/runtime-characterization-scenario.schema.json": "0422570bef83be0da608bd9583a4e9fc9ab3ce031919a91b9ca7066ece5639df",
    "schemas/discovery/v1/unspecified-behavior-record.schema.json": "530b962f8945c22b400227468dc750b4197dde5aee4826fdf36e05b146100c62"
  },
  "runtime_dependencies": [
    "PyYAML (>=6.0)",
    "jsonschema (>=4.25.1,<5.0.0)",
    "lxml (>=5.3.0)",
    "referencing (>=0.37,<0.38)"
  ],
  "runtime_version": "2.0.0",
  "site_startup_disabled": true,
  "source_checkout_imports": false,
  "wheel": "drm_copilot_discovery-2.0.0-py3-none-any.whl",
  "wheel_sha256": "d24139d8de67ad5ae4aa81487e4fc79b66be3741e6f3171790c2f6e309de380e",
  "working_directory": "SCRATCH/issue-980-p1t2-independent-cwd"
}
```
