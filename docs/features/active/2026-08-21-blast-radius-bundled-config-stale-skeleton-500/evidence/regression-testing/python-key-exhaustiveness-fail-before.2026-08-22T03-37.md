Timestamp: 2026-08-22T03-37
Command: python -c "import json,io;p='config/blast-radius.json';d=json.load(open(p,encoding='utf-8'));d['new_top_level_key']=['x'];open(p,'w',encoding='utf-8').write(json.dumps(d,indent=2)+chr(10))" && poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed. AssertionError: "config/blast-radius.json and
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json must declare the
same top-level key set; symmetric difference ['new_top_level_key']." This demonstrates the new
Python exhaustiveness case is falsifiable: injecting an unclassified top-level key into the
self-hosted copy alone fails the case and names the injected key.
