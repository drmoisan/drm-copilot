Timestamp: 2026-10-08T02-49
Command: poetry run python -c "import json;d=json.load(open('artifacts/python/launcher-coverage.json'));[print(k,v['summary']['covered_lines'],v['summary']['num_statements'],round(100*v['summary']['covered_lines']/v['summary']['num_statements'],2),v['summary']['covered_branches'],v['summary']['num_branches'],round(100*v['summary']['covered_branches']/v['summary']['num_branches'],2)) for k,v in d['files'].items()]"
EXIT_CODE: 0
Output Summary: Two printed lines (file covered_lines num_statements line% covered_branches num_branches branch%):
scripts\dev_tools\new_active_feature_folder_io.py 107 110 97.27 44 50 88.0
scripts\dev_tools\new_potential_bug_entry.py 102 111 91.89 23 30 76.67
Floors line >= 85, branch >= 75: both files meet them. Both equal the P0-T11 baseline (io 97.27/88.0, bug_entry 91.89/76.67). This is the Python half of the AC-4 evidence.
