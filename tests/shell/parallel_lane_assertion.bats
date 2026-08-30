#!/usr/bin/env bats
# Unit tests for the pure library .claude/lib/bash/parallel-lane-assertion.sh
# and, from Phase 2 onward, the CLI entry point
# .claude/lib/bash/report-lane-assertion.sh. The library is the bash port of
# scripts/dev_tools/parallel_lane_assertion.py; the Python module remains the
# repository authority, so every expected string below is the Python module's
# output reproduced byte for byte.
#
# Every input is a literal in this file or a checked-in fixture; no temporary
# file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-lane-assertion.sh"
    pc_enforce_c_locale
}

# Render a frontmatter document from the supplied body lines. The explicit
# newline after %b restores the terminator that command substitution strips.
document() {
    printf -- '---\n%b\n---\n\n# Parallel Run\n' "$1"
}

# Parse a document into the shared node table, failing the case if the parse
# did not succeed, so a later assertion cannot pass against a stale table.
parse_document() {
    pc_errors_reset
    pm_parse_manifest "$(document "$1")"
}

@test "the library declares the four finding-class tokens" {
    [ "$PLA_EXPECTED_TOGETHER_DERIVED_APART" = "expected_together_derived_apart" ]
    [ "$PLA_EXPECTED_APART_DERIVED_TOGETHER" = "expected_apart_derived_together" ]
    [ "$PLA_MEMBER_NAMES_NO_ITEM" = "member_names_no_item" ]
    [ "$PLA_ITEM_COVERED_BY_NO_COMPONENT" = "item_covered_by_no_component" ]
    # The informational set holds the fourth token and nothing else, so the
    # disagreement count in the report header excludes exactly that class.
    [ "$PLA_INFORMATIONAL_KINDS" = "item_covered_by_no_component" ]
    [ "$PLA_EDGE_SEPARATOR" = ":" ]
}

@test "parse_edges keeps input order and drops malformed tokens" {
    # An empty value and a whitespace-only value are the no-edge cases.
    pla_parse_edges ""
    [ "${#PLA_EDGES[@]}" -eq 0 ]
    pla_parse_edges "   "
    [ "${#PLA_EDGES[@]}" -eq 0 ]

    # Input order is preserved and is not sorted.
    pla_parse_edges "203:204 101:102"
    [ "${#PLA_EDGES[@]}" -eq 2 ]
    [ "${PLA_EDGES[0]}" = "203 204" ]
    [ "${PLA_EDGES[1]}" = "101 102" ]

    # A token with no colon, a token with two colons, a token whose endpoint is
    # not an integer, and a bare separator are each dropped; the well-formed
    # tokens around them survive in order.
    pla_parse_edges "101:102 909 1:2:3 40:x y:50 : 103:104"
    [ "${#PLA_EDGES[@]}" -eq 2 ]
    [ "${PLA_EDGES[0]}" = "101 102" ]
    [ "${PLA_EDGES[1]}" = "103 104" ]

    # Negative endpoints are inside the accepted lexis; a leading zero, a
    # leading plus, and an underscore separator are outside it.
    pla_parse_edges "-1:0 007:1 +5:6 1_0:2"
    [ "${#PLA_EDGES[@]}" -eq 1 ]
    [ "${PLA_EDGES[0]}" = "-1 0" ]
}

@test "read_manifest_inputs skips malformed entries without raising" {
    # expected_conflict_components[0] is a scalar rather than a map;
    # [1] omits members; [2] carries a scalar members; [3] carries a non-string
    # name and a members list mixing zero, a negative, a boolean, and a string
    # among one usable key; [4] repeats a member. items[] repeats a key, carries
    # a zero and a string issue_num, and ends with a scalar entry.
    parse_document 'parallel: alpha-run\ncreated_at: "t"\nitems:\n  - issue_num: 102\n  - issue_num: 101\n  - issue_num: 101\n  - issue_num: 0\n  - issue_num: "x"\n  - alpha\nexpected_conflict_components:\n  - alpha\n  - name: no-members\n  - name: scalar-members\n    members: 5\n  - name: 7\n    members:\n      - 101\n      - 0\n      - -3\n      - true\n      - notanumber\n  - name: dup-lane\n    members:\n      - 102\n      - 102'
    pla_read_manifest_inputs

    # Three of the five authored entries are unreadable and are skipped, so the
    # two survivors occupy positions 0 and 1.
    [ "$PLA_EXPECTED_COUNT" -eq 2 ]
    [ "${PLA_EXPECTED_HAS_NAME[0]}" -eq 0 ]
    [ "${PLA_EXPECTED_MEMBERS[0]}" = "101" ]
    [ "${PLA_EXPECTED_HAS_NAME[1]}" -eq 1 ]
    [ "${PLA_EXPECTED_NAMES[1]}" = "dup-lane" ]
    # Manifest order, no de-duplication.
    [ "${PLA_EXPECTED_MEMBERS[1]}" = "102 102" ]
    # Item keys are de-duplicated and ascending.
    [ "$PLA_ITEM_KEYS" = "101 102" ]

    # A non-list expected_conflict_components contributes no component, and a
    # manifest declaring no item contributes no key.
    parse_document 'parallel: alpha-run\ncreated_at: "t"\nitems: []\nexpected_conflict_components: hooks-lane'
    pla_read_manifest_inputs
    [ "$PLA_EXPECTED_COUNT" -eq 0 ]
    [ "$PLA_ITEM_KEYS" = "" ]
}

@test "derive_components partitions declared keys deterministically" {
    # A reversed edge, a duplicate of it, a self-loop, and two edges naming the
    # undeclared vertex 999 all collapse or drop; 104 is in no edge at all.
    pla_parse_edges "102:101 101:102 103:103 101:999 999:101"
    pla_derive_components "101 102 103 104"
    [ "${#PLA_COMPONENTS[@]}" -eq 3 ]
    [ "${PLA_COMPONENTS[0]}" = "101 102" ]
    [ "${PLA_COMPONENTS[1]}" = "103" ]
    [ "${PLA_COMPONENTS[2]}" = "104" ]

    # Components are ordered by lowest member, not by discovery of the edge.
    pla_parse_edges "3:4"
    pla_derive_components "1 2 3 4"
    [ "${#PLA_COMPONENTS[@]}" -eq 3 ]
    [ "${PLA_COMPONENTS[0]}" = "1" ]
    [ "${PLA_COMPONENTS[1]}" = "2" ]
    [ "${PLA_COMPONENTS[2]}" = "3 4" ]

    # A chain reached through two hops is one component with ascending members.
    pla_parse_edges "103:101 101:102"
    pla_derive_components "101 102 103"
    [ "${#PLA_COMPONENTS[@]}" -eq 1 ]
    [ "${PLA_COMPONENTS[0]}" = "101 102 103" ]

    # No declared key is the empty partition, not a single empty component.
    pla_parse_edges ""
    pla_derive_components ""
    [ "${#PLA_COMPONENTS[@]}" -eq 0 ]
}

# A manifest producing exactly one finding of each of the four classes:
# 'split-lane' asserts 103 with 104 but the two derive apart; the unnamed lanes
# at positions 1 and 2 assert 101 apart from 102 but the two derive together;
# 'ghost-lane' asserts the undeclared member 999; item 105 is asserted by no
# lane. 'dup-a' and 'dup-b' both claim 106, so the expected index resolves it to
# the later lane.
four_class_body() {
    printf -- 'parallel: alpha-run\ncreated_at: "t"\nitems:\n  - issue_num: 101\n  - issue_num: 102\n  - issue_num: 103\n  - issue_num: 104\n  - issue_num: 105\n  - issue_num: 106\nexpected_conflict_components:\n  - name: split-lane\n    members:\n      - 103\n      - 104\n  - members:\n      - 101\n  - members:\n      - 102\n  - name: ghost-lane\n    members:\n      - 999\n  - name: dup-a\n    members:\n      - 106\n  - name: dup-b\n    members:\n      - 106'
}

@test "compare emits findings in the fixed class order" {
    parse_document "$(four_class_body)"
    pla_read_manifest_inputs
    [ "$PLA_EXPECTED_COUNT" -eq 6 ]
    [ "$PLA_ITEM_KEYS" = "101 102 103 104 105 106" ]

    pla_parse_edges "101:102"
    pla_compare "$PLA_ITEM_KEYS"

    # Five derived components: the merged pair plus four singletons.
    [ "${#PLA_COMPONENTS[@]}" -eq 5 ]
    [ "${PLA_COMPONENTS[0]}" = "101 102" ]

    # A repeated key resolves to the LAST asserted lane that claims it, and no
    # finding is emitted for the repetition itself.
    [ "${PLA_EXPECTED_INDEX[106]}" = "5" ]

    [ "${#PLA_FINDING_KINDS[@]}" -eq 4 ]

    [ "${PLA_FINDING_KINDS[0]}" = "expected_together_derived_apart" ]
    [ "${PLA_FINDING_DETAILS[0]}" = "expected component 'split-lane' was derived apart: its members occupy 2 distinct conflict components" ]
    [ "${PLA_FINDING_MEMBERS[0]}" = "103 104" ]

    [ "${PLA_FINDING_KINDS[1]}" = "expected_apart_derived_together" ]
    [ "${PLA_FINDING_DETAILS[1]}" = "derived conflict component [101, 102] spans 2 expected components that were asserted apart" ]
    [ "${PLA_FINDING_MEMBERS[1]}" = "101 102" ]

    [ "${PLA_FINDING_KINDS[2]}" = "member_names_no_item" ]
    [ "${PLA_FINDING_DETAILS[2]}" = "expected member 999 names no manifest item" ]
    [ "${PLA_FINDING_MEMBERS[2]}" = "999" ]

    [ "${PLA_FINDING_KINDS[3]}" = "item_covered_by_no_component" ]
    [ "${PLA_FINDING_DETAILS[3]}" = "manifest item 105 is covered by no expected component" ]
    [ "${PLA_FINDING_MEMBERS[3]}" = "105" ]
}

# A manifest exercising every rendering rule the report has: the lane at
# position 0 carries no name and renders by position; the lane at position 1
# carries the empty string, which is still a string and renders quoted; the
# derived component {105, 106} is two-member and renders in the Python list
# form; and item 107 is asserted by no lane, so it produces the informational
# finding that the disagreement count must exclude.
rendering_body() {
    printf -- 'parallel: alpha-run\ncreated_at: "t"\nitems:\n  - issue_num: 101\n  - issue_num: 102\n  - issue_num: 103\n  - issue_num: 104\n  - issue_num: 105\n  - issue_num: 106\n  - issue_num: 107\nexpected_conflict_components:\n  - members:\n      - 101\n      - 102\n  - name: ""\n    members:\n      - 103\n      - 104\n  - name: lane-e\n    members:\n      - 105\n  - name: lane-f\n    members:\n      - 106'
}

@test "format_report renders the header, findings, and closing line" {
    parse_document "$(rendering_body)"
    pla_read_manifest_inputs
    pla_parse_edges "105:106"
    pla_compare "$PLA_ITEM_KEYS"
    pla_format_report

    # Six derived components; four findings, of which one is informational, so
    # the header reports three disagreements rather than four.
    [ "${#PLA_COMPONENTS[@]}" -eq 6 ]
    [ "${#PLA_FINDING_KINDS[@]}" -eq 4 ]
    [ "$(pla_disagreement_count)" = "3" ]

    expected="$(printf -- '%s\n%s\n%s\n%s\n%s\n%s' \
        "Lane assertion: 6 derived conflict component(s); 3 disagreement(s)." \
        "ADVISORY [expected_together_derived_apart] expected component component[0] was derived apart: its members occupy 2 distinct conflict components." \
        "ADVISORY [expected_together_derived_apart] expected component '' was derived apart: its members occupy 2 distinct conflict components." \
        "ADVISORY [expected_apart_derived_together] derived conflict component [105, 106] spans 2 expected components that were asserted apart." \
        "ADVISORY [item_covered_by_no_component] manifest item 107 is covered by no expected component." \
        "Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.")"
    [ "$PLA_REPORT" = "$expected" ]

    # An assertion that agrees with the derived graph renders the header and the
    # closing line and nothing between them.
    parse_document 'parallel: alpha-run\ncreated_at: "t"\nitems:\n  - issue_num: 101\n  - issue_num: 102\nexpected_conflict_components:\n  - name: only-lane\n    members:\n      - 101\n      - 102'
    pla_read_manifest_inputs
    pla_parse_edges "101:102"
    pla_compare "$PLA_ITEM_KEYS"
    pla_format_report
    [ "${#PLA_FINDING_KINDS[@]}" -eq 0 ]
    expected="$(printf -- '%s\n%s' \
        "Lane assertion: 1 derived conflict component(s); 0 disagreement(s)." \
        "Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.")"
    [ "$PLA_REPORT" = "$expected" ]
}
