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
#
# Divergence class 4 -- the unreadable manifest. The Python authority prints
# str(OSError) inside the parentheses of its `manifest unreadable` line, which
# names a Python errno string that bash cannot reproduce. Only the line's prefix
# `Lane assertion: manifest unreadable (` is therefore parity scoped, and the
# class is excluded from the shared corpus at
# tests/fixtures/parallel_lane_assertion/. Its bash-only fixture path lives
# under tests/fixtures/parallel_lane_assertion_bash/ for the same reason.

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

# The entry point .claude/lib/bash/report-lane-assertion.sh. Every case below
# invokes it as a separate process, so the exit status it reports is the
# contract's exit status and not this suite's.
ENTRY_POINT() {
    printf -- '%s' "${LIB_DIR}/report-lane-assertion.sh"
}

# The checked-in payload manifest declares exactly issue_num 101 and 202 and
# asserts no expected_conflict_components, so with no edges it derives two
# single-member components and reports no disagreement.
PAYLOAD_MANIFEST() {
    printf -- '%s' "${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/parallel.md"
}

@test "the entry point resolves its own directory before sourcing" {
    # Run from the filesystem root rather than the repository root. A source
    # written relative to the caller's working directory would fail to find
    # parallel-lane-assertion.sh here, so a successful report proves the script
    # resolved its own directory first.
    run bash -c "cd / && bash '$(ENTRY_POINT)' --manifest '$(PAYLOAD_MANIFEST)'"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Lane assertion: 2 derived conflict component(s); 0 disagreement(s)." ]
}

@test "the entry point calls pc_enforce_c_locale before any output is produced" {
    # Read the file and compare source positions: the top-level locale call must
    # precede the first printf, so every sort and character class the report
    # depends on is byte ordered before a byte of output is written.
    local script locale_line printf_line
    script="$(ENTRY_POINT)"
    locale_line="$(grep -n -- '^pc_enforce_c_locale$' "$script" | head -n 1 | cut -d: -f1)"
    printf_line="$(grep -n -- 'printf' "$script" | head -n 1 | cut -d: -f1)"
    [ -n "$locale_line" ]
    [ -n "$printf_line" ]
    [ "$locale_line" -lt "$printf_line" ]
}

@test "the entry point establishes set -euo pipefail as its first executable line" {
    # The shebang is a comment line, so the first line that is neither blank nor
    # a comment is the first line bash executes.
    local first
    first="$(grep -v -E -- '^[[:space:]]*(#|$)' "$(ENTRY_POINT)" | head -n 1)"
    [ "$first" = "set -euo pipefail" ]
}

@test "the entry point exits 2 only on a usage error" {
    # An unknown flag is a usage error: usage text on stderr, exit 2.
    run bash "$(ENTRY_POINT)" --unknown-flag --manifest "$(PAYLOAD_MANIFEST)"
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Usage: report-lane-assertion.sh --manifest <path> [--edges \"<a>:<b> ...\"]" ]

    # A missing --manifest is a usage error even when --edges is supplied.
    run bash "$(ENTRY_POINT)" --edges "101:202"
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Usage: report-lane-assertion.sh --manifest <path> [--edges \"<a>:<b> ...\"]" ]

    # No arguments at all is the same usage error.
    run bash "$(ENTRY_POINT)"
    [ "$status" -eq 2 ]

    # --help is a successful request for the usage text: stdout, exit 0.
    run bash "$(ENTRY_POINT)" --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Usage: report-lane-assertion.sh --manifest <path> [--edges \"<a>:<b> ...\"]" ]

    # The usage text of a usage error goes to stderr and not to stdout, so it
    # can never be mistaken for a report.
    run bash -c "bash '$(ENTRY_POINT)' --unknown-flag 2>/dev/null"
    [ "$status" -eq 2 ]
    [ "${#lines[@]}" -eq 0 ]

    # A well-formed invocation is not a usage error.
    run bash "$(ENTRY_POINT)" --manifest "$(PAYLOAD_MANIFEST)"
    [ "$status" -eq 0 ]
}

@test "the entry point rejects a --keys flag" {
    # The CLI surface is exactly --manifest and --edges. Item keys are read from
    # the manifest's items[].issue_num, never supplied on the command line, so a
    # --keys flag borrowed from compute-cohorts.sh is an unknown flag here. This
    # case pins that no --keys flag was added.
    run bash -c "cd '${REPO_ROOT}' && bash .claude/lib/bash/report-lane-assertion.sh --keys \"101 102\" --manifest tests/fixtures/parallel_manifest_payload/parallel.md"
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Usage: report-lane-assertion.sh --manifest <path> [--edges \"<a>:<b> ...\"]" ]

    # The usage text went to stderr, so stdout carried nothing.
    run bash -c "cd '${REPO_ROOT}' && bash .claude/lib/bash/report-lane-assertion.sh --keys \"101 102\" --manifest tests/fixtures/parallel_manifest_payload/parallel.md 2>/dev/null"
    [ "$status" -eq 2 ]
    [ "${#lines[@]}" -eq 0 ]
}

@test "an unreadable manifest prints the unreadable line and exits 0" {
    # Divergence class 4, declared in this file's header: only the prefix is
    # parity scoped, because the parenthesised detail is str(OSError) in the
    # Python authority. The path is deliberately absent from the tree.
    local missing="${REPO_ROOT}/tests/fixtures/parallel_lane_assertion_bash/no-such-manifest.md"
    [ ! -e "$missing" ]

    run bash "$(ENTRY_POINT)" --manifest "$missing"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    case "${lines[0]}" in
    "Lane assertion: manifest unreadable ("*) ;;
    *) return 1 ;;
    esac
    # The line ends with the fixed suffix, so the detail is the only free text.
    case "${lines[0]}" in
    *"); no comparison made.") ;;
    *) return 1 ;;
    esac

    # A directory is unreadable as a manifest for the same reason and takes the
    # same path, so the class is not limited to a missing file.
    run bash "$(ENTRY_POINT)" --manifest "${REPO_ROOT}/tests/fixtures"
    [ "$status" -eq 0 ]
    case "${lines[0]}" in
    "Lane assertion: manifest unreadable ("*) ;;
    *) return 1 ;;
    esac
}

@test "an unparseable manifest prints the M1 error and exits 0" {
    # The parenthesised text is the M1 message pm_parse_manifest appends to
    # PC_ERRORS, reused byte for byte rather than restated, so the assertion
    # below is the full line and not a prefix.
    run bash "$(ENTRY_POINT)" \
        --manifest "${REPO_ROOT}/tests/fixtures/parallel_lane_assertion_bash/not-a-mapping.md"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "Lane assertion: manifest unparseable (Parallel manifest frontmatter must be a mapping.)." ]
}

@test "an out-of-subset manifest prints the refusal line and exits 0" {
    # A non-empty flow collection is outside the scanner's modelled subset, so
    # pm_parse_manifest returns status 2 and the entry point refuses rather than
    # guessing a parse the Python authority might read differently.
    run bash "$(ENTRY_POINT)" \
        --manifest "${REPO_ROOT}/tests/fixtures/parallel_lane_assertion_bash/out-of-subset.md"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    case "${lines[0]}" in
    "Lane assertion: manifest outside the supported YAML subset ("*) ;;
    *) return 1 ;;
    esac
    case "${lines[0]}" in
    *"); no comparison made.") ;;
    *) return 1 ;;
    esac
    # The refusal line is distinct from the unparseable line, so a reader can
    # tell a manifest bash declined to read from one it read and rejected.
    case "${lines[0]}" in
    *"manifest unparseable"*) return 1 ;;
    esac

    # The out-of-subset construct appears in no file under the shared corpus
    # directory. While that directory does not yet exist the assertion holds
    # trivially; it becomes load-bearing once the corpus is populated.
    local corpus="${REPO_ROOT}/tests/fixtures/parallel_lane_assertion"
    if [ -d "$corpus" ]; then
        run grep -r -F -- "items: [101, 202]" "$corpus"
        [ "$status" -ne 0 ]
    fi
}

@test "the port drops an --edges endpoint outside the strict integer lexis" {
    # Divergence class 3, and its complete membership. Python's int() accepts a
    # leading zero, a leading '+', an underscore digit separator, and a
    # non-ASCII decimal digit, coercing each of the four first endpoints below
    # to 101 and merging the two items into one derived component. The port
    # applies the strict lexis ^-?(0|[1-9][0-9]*)$ that compute-cohorts.sh
    # already uses, drops the edge, and derives two components. The class has
    # exactly these four members.
    #
    # Interior or surrounding whitespace inside an endpoint is NOT a member of
    # this class. Both implementations split the --edges value on whitespace
    # before partitioning on the colon, so neither can see an endpoint carrying
    # interior whitespace and the two converge on that input. It is pinned as a
    # convergence record inside the shared corpus, not here.
    local manifest split_header merged_header form
    manifest="$(PAYLOAD_MANIFEST)"
    split_header="Lane assertion: 2 derived conflict component(s); 0 disagreement(s)."
    merged_header="Lane assertion: 1 derived conflict component(s); 0 disagreement(s)."

    # The fourth form is Arabic-Indic 101 (U+0661 U+0660 U+0661), written as its
    # explicit UTF-8 bytes so this file stays ASCII and the value does not
    # depend on the locale in which the suite is read.
    for form in "0101:202" "+101:202" "1_01:202" $'\xd9\xa1\xd9\xa0\xd9\xa1:202'; do
        run bash "$(ENTRY_POINT)" --manifest "$manifest" --edges "$form"
        [ "$status" -eq 0 ]
        [ "${lines[0]}" = "$split_header" ]
    done

    # Control: a well-formed edge over the same manifest is not dropped. Without
    # it the four assertions above would also pass against an entry point that
    # ignored --edges entirely.
    run bash "$(ENTRY_POINT)" --manifest "$manifest" --edges "101:202"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "$merged_header" ]
}

@test "no library file sources the diagnostic" {
    # The diagnostic is advisory and one-directional: the entry point sources
    # the library, and nothing else in .claude/lib/bash/ sources either file. If
    # a cohort, validation, or scheduling module sourced one of them, its
    # findings could reach a decision the diagnostic must never influence.
    local file base offenders=0
    for file in "${LIB_DIR}"/*.sh; do
        base="$(basename -- "$file")"
        # Only the entry point may source the pure library.
        if [ "$base" != "report-lane-assertion.sh" ]; then
            if grep -q -E -- '^[[:space:]]*(\.|source)[[:space:]].*parallel-lane-assertion\.sh' "$file"; then
                echo "sources the library: $base" >&2
                offenders=$((offenders + 1))
            fi
        fi
        # Nothing at all may source the entry point.
        if grep -q -E -- '^[[:space:]]*(\.|source)[[:space:]].*report-lane-assertion\.sh' "$file"; then
            echo "sources the entry point: $base" >&2
            offenders=$((offenders + 1))
        fi
    done
    [ "$offenders" -eq 0 ]

    # Control: the entry point does source the library, so the loop above is
    # searching for a pattern that the tree really contains somewhere.
    grep -q -E -- '^[[:space:]]*(\.|source)[[:space:]].*parallel-lane-assertion\.sh' \
        "${LIB_DIR}/report-lane-assertion.sh"
}
