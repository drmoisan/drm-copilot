# Bash Smoke Runs — [P3-T9]

Timestamp: 2026-10-10T08-19
Command: sh .claude/lib/bash/remove-parallel-item.sh decide --item 5 --state scheduled ; sh .claude/lib/bash/remove-parallel-item.sh recolor --unstarted "1 2" --edges "1:4" --pinned "4" --generation 0 --current-cohort 0 --highest-pinned-cohort 2 ; sh .claude/lib/bash/remove-parallel-item.sh entry --item 5 --prior-state scheduled --recompute true --generation 2 --at 2026-10-08T14-00
EXIT_CODE: 0
Output Summary:
- decide: exit 0; stdout `{"item_key":5,"prior_state":"scheduled","new_state":"withdrawn","disposition":null,"triggers_recompute":true}` (equals corpus row `decide-scheduled`).
- recolor: exit 0; stdout `{"cohort_assignments":{"1":3,"2":3},"generation":1}` (equals corpus row `recolor-pinned-edge-offset`).
- entry: exit 0; stdout `{"op":"remove","item_key":5,"at":"2026-10-08T14-00","prior_state":"scheduled","new_state":"withdrawn","disposition":null,"recolor_generation":3}` (equals corpus row `entry-unstarted-recompute`).
- All three subcommands exit 0 and print exactly the expected corpus literals.
