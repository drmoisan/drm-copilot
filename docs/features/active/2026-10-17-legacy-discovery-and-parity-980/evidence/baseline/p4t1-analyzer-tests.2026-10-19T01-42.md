Timestamp: 2026-10-19T01:42:59.928808+00:00
Command: poetry run python -m pytest tests\scripts\dev_tools\discovery\analyzer -q -o addopts= --cov=scripts.dev_tools.discovery.analyzer.models --cov=scripts.dev_tools.discovery.analyzer.pipeline --cov=scripts.dev_tools.discovery.analyzer.inventory --cov=scripts.dev_tools.discovery.analyzer.emitter --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p4t1-analyzer-coverage.2026-10-19T01-42.json
EXIT_CODE: 0
Output Summary:

```text
........................................................................ [ 37%]
........................................................................ [ 75%]
................................................                         [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------
scripts\dev_tools\discovery\analyzer\emitter.py        18      0      2      0   100%
scripts\dev_tools\discovery\analyzer\inventory.py      68      0     16      0   100%
scripts\dev_tools\discovery\analyzer\models.py         52      0      6      0   100%
scripts\dev_tools\discovery\analyzer\pipeline.py       42      0      6      0   100%
-----------------------------------------------------------------------------------------------
TOTAL                                                 180      0     30      0   100%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p4t1-analyzer-coverage.2026-10-19T01-42.json
192 passed in 0.54s

```

Elapsed seconds: 1.126859
Source and test bytes unchanged: True

```json
{
  "scripts/dev_tools/discovery/analyzer/__init__.py": "bda306382c2a7335f09f6e62add357089cdbe7acb0c0c52851cf738f4eae7c09",
  "scripts/dev_tools/discovery/analyzer/__main__.py": "8bffe5f2ac2471bcfb9cfd33fe1851cbca94254e41628a59b78cd5e7f73483d7",
  "scripts/dev_tools/discovery/analyzer/cli.py": "f775c05019116140cd28d0a2f353e7cd2ea26133eed587f5873546b42380b89a",
  "scripts/dev_tools/discovery/analyzer/dotnet_inventory.py": "36311764e88b19d07482cdc00c934b378441c9f755df8a4ce7d9ea0612f2a476",
  "scripts/dev_tools/discovery/analyzer/emitter.py": "7014add372728ab44f31c1f9d5e9b079db7c1876cebabe5ba49dc2a8d89a05e6",
  "scripts/dev_tools/discovery/analyzer/inventory.py": "655d49e2bfcbb608cdda3f8b1db420f12a34bf8f37940bb2d4ecb3bdac34d385",
  "scripts/dev_tools/discovery/analyzer/models.py": "987c1e1568c523742794ba1197792961a4718b248843b7233ebfd019647b85f6",
  "scripts/dev_tools/discovery/analyzer/pipeline.py": "5870b66ea1a3c0fb935c9f528c1595fa5f2744b93a2818802f9815b1737639d3",
  "scripts/dev_tools/discovery/analyzer/source_text.py": "5fb87349ca8c817d6939319db0c606e20c9d1399e34f40311744c5838e769319",
  "scripts/dev_tools/discovery/analyzer/stack_cli.py": "c4deed498726d01a493f653c5a117eb9b7841519f2b159502562263283a9c5fd",
  "scripts/dev_tools/discovery/analyzer/vsto_office.py": "34dcdcf022ad258bf92434bab44999f130a44b59c165e0a590c2a22380f8e722",
  "scripts/dev_tools/discovery/analyzer/vsto_patterns.py": "fce4a759b05315c92ecf28287ab128d437fc5b93661df2043e94b7e2596d4c4c",
  "tests/scripts/dev_tools/discovery/analyzer/__init__.py": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "tests/scripts/dev_tools/discovery/analyzer/test_cli.py": "a9874d052e56dadb892b2eb79be4ffffd974c41a7036af6d7271b41d6df2b735",
  "tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py": "dc2693cc6427e8cb74aa0d1b6cadea85599bbe3eb6ac29596d62cd630e75783e",
  "tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py": "401d0583377a4b28e5a9abbc2ee63f160d4efc31370f128b4ac9104f25fb7e97",
  "tests/scripts/dev_tools/discovery/analyzer/test_emitter.py": "707025c9a5b2ef80077a90428e42b25620c9ddf8445b30ab873589723152c55e",
  "tests/scripts/dev_tools/discovery/analyzer/test_inventory.py": "aaa245064b25e882a934274fbb60122933f8648060ed4a14a1b48efa39ed8b78",
  "tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py": "03c5b0f87c6ef6a98f42d51887105afa47a35da412ee7451bf94326c7a48a92f",
  "tests/scripts/dev_tools/discovery/analyzer/test_models.py": "c8d3644635c914ab351f3192572b504780653876adfa7b2f02420a9d1fd52042",
  "tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py": "29e460a2b090291d9ce1955bf9538efbe26214ba54b52e39dc09bf809ca9790e",
  "tests/scripts/dev_tools/discovery/analyzer/test_source_text.py": "2109820f4584f96cab5d022bffdc38f1fe6ebe7338a8e5c27407a296978e1add",
  "tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py": "bca794b2ec833cc7cef7460ea2d377f7a34a07696555cbc2bf1e2eaf77958985",
  "tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py": "b4e63e6a9662f0b6322201364c7c25964ff2fd124fac008c7235ee9e4596d427",
  "tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py": "c12c4d74e7a95b64e7323266a695a2a7b98f806b45f27a2088b49f979b55a8c7"
}
```
