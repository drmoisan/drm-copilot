#!/usr/bin/env bats
# Guard-registry enforcement gate for scripts/bash/cleanup_worktrees_dirt_lib.sh
# (issue #632, remediation cycle 2).
#
# SUBJECT. Two consecutive cycles shipped a guard whose removal left every checked-in
# scenario byte-identical, so the guard was covered by a passing test that could not fail
# when the guard was violated. This suite makes that class mechanically detectable: every
# guard-shaped line in the classifier carries a `# guard:<id>` marker, every marker is
# registered in tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv, and every
# registry row is required to show what neutralizing its guard changes.
#
# MECHANISM. For a registry row the harness composes a `sed` program as the $-anchored
# address /# guard:<id>$/ immediately followed by the row's `mutation` value, applies it
# to the library into a shell variable, rejects the result unless `bash -n` reading from a
# here-string accepts it, and evaluates the mutated text with `eval` in a child shell in
# place of sourcing the real library. The child still sources
# cleanup_worktrees_enumerate_lib.sh and cleanup_worktrees_lib.sh from disk, in that
# order, because the cleanup_wt_git seam that CLEANUP_WT_GIT_BIN drives is defined in the
# enumerate library. The composed program is passed to `sed` as a single argument and is
# never itself evaluated by the shell: two of the fixed mutations contain $blob and $agg,
# and evaluating the program would expand them to the empty string before `sed` saw them.
#
# The address is $-anchored because an unanchored /# guard:<id>/ matches every line whose
# marker merely begins with <id>, so an id that is a prefix of another id would silently
# mutate two guards under one row and destroy per-guard attribution.
#
# OBSERVATION CHANNEL. The record channel is the function group's full emitted record
# stream and its exit status, not the DIRTSUM| aggregate alone: stdout of
# classify_worktree_dirt, that call's exit status, stdout of clear_disposable_dirt, that
# call's exit status. The stub's `stub-git: <argv>` log travels on stderr and is captured
# into a separate argv channel, tagged with an ARGV prefix this harness adds, so it can
# never contaminate the record channel. A guard whose neutralization changes neither
# channel is EXEMPT and must say so with a fixed reason token; a guard that changes only
# the argv log is ARGV; anything else is SEPARATED. Each kind asserts the presence AND the
# absence it names, so no kind is satisfiable by writing a verdict into the registry.
#
# NO TEMPORARY FILES. The mutated source never reaches disk. Every scenario is checked in
# under tests/fixtures/cleanup_worktrees/scenarios/. No scratch directory is used.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    DIRTLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_dirt_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    REGISTRY="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv"
    WT="/repo-wt/dirt"
    # The arithmetic guard-shaped line predicate: a comparison of a variable against a
    # numeric literal inside an arithmetic command.
    GUARD_RE='\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)'
    chmod +x "${STUB}" 2>/dev/null || true
}

marked_line_for() { # marked_line_for <id> -> the library line carrying that marker
    grep -E "# guard:$1\$" "$DIRTLIB"
}

expr_for() { # expr_for <id> -> the arithmetic comparison text, empty when there is none
    local line e
    line="$(marked_line_for "$1")"
    e="$(printf '%s\n' "$line" | grep -oE "$GUARD_RE" | head -n 1 || true)"
    if [ -n "$e" ]; then
        e="${e:2}"
        e="${e:0:${#e}-2}"
    fi
    printf '%s' "$e"
}

mutate_lib() { # mutate_lib <id> <mutation> -> the mutated library source on stdout
    # The address is $-anchored; the mutation carries its own delimiter. The composed
    # program is one argument and is never evaluated by the shell.
    sed "/# guard:$1\$/$2" "$DIRTLIB"
}

norm_line() { # norm_line <line> -> the line with its marker comment stripped and
    # whitespace runs collapsed, which is what makes a comment-only or a
    # reindent-only mutation visible as "no change".
    local s="${1%%# guard:*}"
    s="${s//$'\t'/ }"
    while [ "${s//  / }" != "$s" ]; do
        s="${s//  / }"
    done
    s="${s# }"
    s="${s% }"
    printf '%s' "$s"
}

syntax_ok() { # syntax_ok <source> -> 0 when bash accepts the mutated text
    bash -n <<<"$1" 2>/dev/null
}

run_child() { # run_child <source> <scenario> -> sets CH_REC and CH_ARGV
    # One child per call. Its stdout carries the record channel; its stderr carries the
    # stub argv log and is tagged with an ARGV prefix before both are read back, so the
    # two channels are separated rather than merged.
    local src="$1" scen="$2" merged
    merged=$(
        {
            printf '%s\n' "$src" |
                env CLEANUP_WT_GIT_BIN="$STUB" \
                    CLEANUP_WT_STUB_SCENARIO="${SCEN}/${scen}" \
                    bash -c '
                        lib=$(cat)
                        source "$1"
                        source "$2"
                        eval "$lib"
                        classify_worktree_dirt "$3"
                        printf "CLASSIFY_RC=%s\n" "$?"
                        clear_disposable_dirt "$3"
                        printf "CLEAR_RC=%s\n" "$?"
                    ' _ "$ELIB" "$LIB" "$WT" 2>&1 1>&3 | sed 's/^/ARGV /'
        } 3>&1
    )
    CH_REC="$(printf '%s\n' "$merged" | grep -v '^ARGV ' || true)"
    CH_ARGV="$(printf '%s\n' "$merged" | grep '^ARGV ' || true)"
}

sibling_mutation() { # sibling_mutation <id> <mutation> -> the other admissible constant
    # Composed from the row's own marked line, never read from a registry column. Empty
    # for a mutation that is one of the eight fixed literals, which have no sibling.
    local e out=""
    case "$2" in
    's/(('*)
        e="$(expr_for "$1")"
        if [ -n "$e" ]; then
            if [ "$2" = "s/(($e))/((0))/" ]; then
                out="s/(($e))/((1))/"
            elif [ "$2" = "s/(($e))/((1))/" ]; then
                out="s/(($e))/((0))/"
            fi
        fi
        ;;
    esac
    printf '%s' "$out"
}

pin_count() { # pin_count <id> <any|arith|literal> <space-separated kinds> -> row count
    local want="$1" cls="$2" kinds="$3"
    local rid rkind rscen ragg rmut rreason n=0 mclass
    while IFS=$'\t' read -r rid rkind rscen ragg rmut rreason; do
        case "$rid" in '#'* | '') continue ;; esac
        [ "$rid" = "$want" ] || continue
        mclass=literal
        case "$rmut" in 's/(('*) mclass=arith ;; esac
        [ "$cls" = any ] || [ "$cls" = "$mclass" ] || continue
        case " $kinds " in *" $rkind "*) n=$((n + 1)) ;; esac
    done <"$REGISTRY"
    printf '%s' "$n"
}

@test "every guard-shaped line in the dirt library is marked and every registry row names a marked id" {
    # The nine named non-arithmetic verdict guards. The arithmetic predicate alone does
    # not match any of them, and three of them are the exact sites that produced cycle 1's
    # R1, R2 and R5, so a registry derived from the predicate alone would exclude the
    # shapes that carried the real defects. The ninth is the fail-closed test N3 adds: it
    # sets the flag that stops rungs 4 and 5 emitting a disposable verdict for an entry
    # whose X and Y columns are both content-bearing. Like the other eight it is a
    # [[ ... ]] test rather than an arithmetic comparison, so GUARD_RE does not compel a
    # marker onto it and its id and mutation are listed below instead.
    local -a LIT_IDS=(
        diff-header-skip
        rung1-y-column-gate
        hash-object-hard-fail
        rung4-untracked-main-present
        history-hit-nonempty
        rename-payload-split-gate
        unique-verdict-tally
        clear-requires-all-disposable
        index-and-worktree-both-hold-content
    )
    local -a LIT_MUTS=(
        's%continue ;;%;;%'
        's% && $y == " "%%'
        's% || \[\[ -z $blob \]\]%%'
        's%\[\[ -n $mainblob && $mainblob == "$blob" \]\]%[[ -n "x" ]]%'
        's%\[\[ -n $found \]\]%[[ -n "" ]]%'
        's%== C \]\]%== C || -n "x" \]\]%'
        's%\[\[ $verdict == "UNIQUE" \]\]%[[ -n "" ]]%'
        's%\[\[ $agg != "ALL_DISPOSABLE" \]\]%[[ -n "" ]]%'
        's%\[\[ $x == \[MARCTU\] && $y == \[MARCTU\] \]\]%[[ -n "" ]]%'
    )
    local unmarked="" idless="" unknown="" dupid="" duppair="" missingpair="" badmut=""
    local line id kind scen agg mut reason marked_ids e a0 a1 ok i hit row

    # The marked id set is read from the library, never from a list written here.
    marked_ids="$(grep -oE '# guard:[a-z0-9-]+$' "$DIRTLIB" | cut -d: -f2)"
    mapfile -t MARKED <<<"$marked_ids"
    mapfile -t ROWS <"$REGISTRY"

    # 1. every line matching the arithmetic predicate carries a marker.
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        case "$line" in
        *'# guard:'*) ;;
        *) unmarked="$unmarked [$line]" ;;
        esac
    done <<<"$(grep -E "$GUARD_RE" "$DIRTLIB")"

    # 2. every marked id backs at least one registry row. "At least one", not "exactly
    # one", so that a line carrying an arithmetic guard and a named non-arithmetic guard
    # may back two rows under one marker.
    for id in "${MARKED[@]}"; do
        if [ "$(pin_count "$id" any 'SEPARATED ARGV EXEMPT')" -eq 0 ]; then
            idless="$idless $id"
        fi
    done

    # 3. every registry row's id is a marked id.
    for row in "${ROWS[@]}"; do
        case "$row" in '#'* | '') continue ;; esac
        IFS=$'\t' read -r id kind scen agg mut reason <<<"$row"
        hit=0
        for i in "${MARKED[@]}"; do
            if [ "$i" = "$id" ]; then hit=1; fi
        done
        if [ "$hit" -eq 0 ]; then unknown="$unknown $id"; fi
    done

    # 4. no marker id occurs on two different library lines.
    dupid="$(grep -oE '# guard:[a-z0-9-]+$' "$DIRTLIB" | sort | uniq -d || true)"

    # 5. no two registry rows share the same (id, mutation) pair.
    duppair="$(awk -F'\t' '!/^#/ {print $1"\t"$5}' "$REGISTRY" | sort | uniq -d || true)"

    # 6. each of the eight named non-arithmetic (id, mutation) pairs is registered.
    for ((i = 0; i < ${#LIT_IDS[@]}; i++)); do
        hit=0
        for row in "${ROWS[@]}"; do
            case "$row" in '#'* | '') continue ;; esac
            IFS=$'\t' read -r id kind scen agg mut reason <<<"$row"
            if [ "$id" = "${LIT_IDS[i]}" ] && [ "$mut" = "${LIT_MUTS[i]}" ]; then hit=1; fi
        done
        if [ "$hit" -eq 0 ]; then missingpair="$missingpair ${LIT_IDS[i]}"; fi
    done

    # 7. every row's mutation is one of the eight literals, or is exactly
    # s/((EXPR))/((0))/ or s/((EXPR))/((1))/ with EXPR derived HERE from the row's own
    # marked line in the unmutated library. A marked line carrying no arithmetic
    # comparison yields an empty EXPR, and only the literal disjunct applies to it.
    for row in "${ROWS[@]}"; do
        case "$row" in '#'* | '') continue ;; esac
        IFS=$'\t' read -r id kind scen agg mut reason <<<"$row"
        ok=0
        for ((i = 0; i < ${#LIT_MUTS[@]}; i++)); do
            if [ "$mut" = "${LIT_MUTS[i]}" ]; then ok=1; fi
        done
        e="$(expr_for "$id")"
        if [ -n "$e" ]; then
            a0="s/(($e))/((0))/"
            a1="s/(($e))/((1))/"
            if [ "$mut" = "$a0" ] || [ "$mut" = "$a1" ]; then ok=1; fi
        fi
        if [ "$ok" -eq 0 ]; then badmut="$badmut [$id::$mut]"; fi
    done

    if [ -n "$unmarked" ]; then echo "INVARIANT-1 unmarked guard lines:$unmarked" >&2; fi
    if [ -n "$idless" ]; then echo "INVARIANT-2 markers with no registry row:$idless" >&2; fi
    if [ -n "$unknown" ]; then echo "INVARIANT-3 rows naming an unmarked id:$unknown" >&2; fi
    if [ -n "$dupid" ]; then echo "INVARIANT-4 marker id on two lines: $dupid" >&2; fi
    if [ -n "$duppair" ]; then echo "INVARIANT-5 duplicate (id,mutation): $duppair" >&2; fi
    if [ -n "$missingpair" ]; then echo "INVARIANT-6 missing literal pair:$missingpair" >&2; fi
    if [ -n "$badmut" ]; then echo "INVARIANT-7 inadmissible mutation:$badmut" >&2; fi

    [ -z "$unmarked" ]
    [ -z "$idless" ]
    [ -z "$unknown" ]
    [ -z "$dupid" ]
    [ -z "$duppair" ]
    [ -z "$missingpair" ]
    [ -z "$badmut" ]
}

@test "every registered guard is observable under its own neutralization" {
    local OB1="" OB2="" OB3="" OB4="" OB5="" EXEMPT_SIBLING_DIFFERED=""
    local row id kind scen agg mut reason
    local msrc ssrc sib ndiff uline mline i ok2
    local unmut_src
    declare -A UREC UARGV

    unmut_src="$(cat "$DIRTLIB")"
    mapfile -t UL <<<"$unmut_src"
    mapfile -t ROWS <"$REGISTRY"

    for row in "${ROWS[@]}"; do
        case "$row" in '#'* | '') continue ;; esac
        IFS=$'\t' read -r id kind scen agg mut reason <<<"$row"

        # Obligation 1. The named scenario directory exists and its name begins with
        # dirt_. A row failing this is NOT evaluated against obligations 2 through 6: a
        # missing directory makes the two channels unobtainable rather than unequal, and
        # recording it in a channel accumulator would make the failure attribution false.
        if [ ! -d "${SCEN}/${scen}" ] || [ "${scen#dirt_}" = "$scen" ]; then
            OB1="$OB1 $id"
            continue
        fi

        # Obligation 2. The composed program fired, exactly one line changed, that line
        # carries a marker, and the two versions of it still differ once the trailing
        # `# guard:` comment is stripped and whitespace runs are collapsed in both.
        msrc="$(mutate_lib "$id" "$mut")"
        mapfile -t ML <<<"$msrc"
        ndiff=0
        uline=""
        mline=""
        if [ "${#ML[@]}" -ne "${#UL[@]}" ]; then
            ndiff=-1
        else
            for ((i = 0; i < ${#UL[@]}; i++)); do
                if [ "${UL[i]}" != "${ML[i]}" ]; then
                    ndiff=$((ndiff + 1))
                    uline="${UL[i]}"
                    mline="${ML[i]}"
                fi
            done
        fi
        ok2=1
        if [ "$ndiff" -ne 1 ]; then ok2=0; fi
        case "$uline" in *'# guard:'*) ;; *) ok2=0 ;; esac
        if [ "$(norm_line "$uline")" = "$(norm_line "$mline")" ]; then ok2=0; fi
        if [ "$ok2" -eq 0 ]; then OB2="$OB2 $id"; fi

        # Obligation 3. bash accepts the mutated source.
        if ! syntax_ok "$msrc"; then OB3="$OB3 $id"; fi

        if [ -z "${UREC[$scen]+set}" ]; then
            run_child "$unmut_src" "$scen"
            UREC[$scen]="$CH_REC"
            UARGV[$scen]="$CH_ARGV"
        fi

        # Obligation 4. The UNMUTATED classify_worktree_dirt call emitted at least one
        # DIRTFILE| record, which is the proof that the ladder executed under this
        # scenario. clear_disposable_dirt never prints a DIRTFILE| record of its own — it
        # consumes the classifier's stdout through a command substitution — so a
        # DIRTFILE| line in the record channel can only have come from that first call.
        case "${UREC[$scen]}" in
        *'DIRTFILE|'*) ;;
        *) OB4="$OB4 $id" ;;
        esac

        run_child "$msrc" "$scen"

        # Obligation 5. Kind-specific, asserting the identity as well as the difference.
        case "$kind" in
        SEPARATED)
            if [ "$CH_REC" = "${UREC[$scen]}" ]; then OB5="$OB5 $id"; fi
            ;;
        ARGV)
            if [ "$CH_REC" != "${UREC[$scen]}" ] ||
                [ "$CH_ARGV" = "${UARGV[$scen]}" ] ||
                ! printf '%s' "$reason" | grep -qE '^ARGV-ONLY: *[^ ]'; then
                OB5="$OB5 $id"
            fi
            ;;
        EXEMPT)
            if [ "$CH_REC" != "${UREC[$scen]}" ] ||
                [ "$CH_ARGV" != "${UARGV[$scen]}" ] ||
                ! printf '%s' "$reason" | grep -qE '^RECORDS-AND-ARGV-IDENTICAL: *[^ ]'; then
                OB5="$OB5 $id"
            fi
            ;;
        *)
            OB5="$OB5 $id"
            ;;
        esac

        # Obligation 6. The EXEMPT both-direction rule. A form-2 row is EXEMPT only when
        # the guard is unobservable however it is forced, which is what removes the free
        # choice of constant that lets a separable guard be parked at EXEMPT.
        if [ "$kind" = "EXEMPT" ]; then
            sib="$(sibling_mutation "$id" "$mut")"
            if [ -n "$sib" ]; then
                ssrc="$(mutate_lib "$id" "$sib")"
                run_child "$ssrc" "$scen"
                if [ "$CH_REC" != "${UREC[$scen]}" ] || [ "$CH_ARGV" != "${UARGV[$scen]}" ]; then
                    EXEMPT_SIBLING_DIFFERED="$EXEMPT_SIBLING_DIFFERED $id"
                fi
            fi
        fi
    done

    # Every accumulator is printed before any assertion is made, so one run names every
    # offending row rather than aborting on the first.
    if [ -n "$OB1" ]; then echo "OBLIGATION-1 scenario absent or not dirt_:$OB1" >&2; fi
    if [ -n "$OB2" ]; then echo "OBLIGATION-2 mutation inert or not single-line:$OB2" >&2; fi
    if [ -n "$OB3" ]; then echo "OBLIGATION-3 mutated source failed bash -n:$OB3" >&2; fi
    if [ -n "$OB4" ]; then echo "OBLIGATION-4 unmutated run emitted no DIRTFILE:$OB4" >&2; fi
    if [ -n "$OB5" ]; then echo "OBLIGATION-5 channel comparison failed:$OB5" >&2; fi
    if [ -n "$EXEMPT_SIBLING_DIFFERED" ]; then
        echo "OBLIGATION-6 EXEMPT_SIBLING_DIFFERED:$EXEMPT_SIBLING_DIFFERED" >&2
    fi

    [ -z "$OB1" ]
    [ -z "$OB2" ]
    [ -z "$OB3" ]
    [ -z "$OB4" ]
    [ -z "$OB5" ]
    [ -z "$EXEMPT_SIBLING_DIFFERED" ]
}

@test "the eighteen pinned guard rows carry the registry kinds this plan fixes" {
    # Group A: twelve id-keyed SEPARATED pins. Each of these ids backs exactly one
    # registry row, so the id key is unambiguous.
    local -a GROUP_A=(
        build-artifact-vacuous-confinement
        rung4-tracked-path-in-main
        rung4-tracked-hard-fail
        find-object-hard-fail
        status-read-hard-fail
        clear-reset-hard-fail
        clear-clean-hard-fail
        clear-requires-all-disposable
        unique-verdict-tally
        history-hit-nonempty
        rung4-tracked-gate
        rung4-tracked-content-equal
    )
    # Group B: three id-keyed SEPARATED-or-ARGV pins, held because cycle 1 proved each of
    # R1's Y-column gate, R2's payload-split gate and R5's diff-header skip separable.
    local -a GROUP_B=(
        rung1-y-column-gate
        rename-payload-split-gate
        diff-header-skip
    )
    local missing="" id

    for id in "${GROUP_A[@]}"; do
        if [ "$(pin_count "$id" any SEPARATED)" -eq 0 ]; then
            missing="$missing A:$id"
        fi
    done
    for id in "${GROUP_B[@]}"; do
        if [ "$(pin_count "$id" any 'SEPARATED ARGV')" -eq 0 ]; then
            missing="$missing B:$id"
        fi
    done

    # Group C: three pair-keyed pins on the two library lines that each carry one marker
    # and back two registry rows. An id-keyed pin on either id is discharged by whichever
    # of that id's two rows happens to carry the demanded kind and leaves the other row
    # unconstrained, so each of these three is selected by id together with a plain string
    # test on whether the row's mutation begins with the four characters s/((. That test
    # is exact: every arithmetic mutation begins s/(( and every one of the eight fixed
    # literals begins s%.
    if [ "$(pin_count hash-object-hard-fail arith SEPARATED)" -eq 0 ]; then
        missing="$missing C1:hash-object-hard-fail-arithmetic"
    fi
    if [ "$(pin_count hash-object-hard-fail literal 'SEPARATED ARGV')" -eq 0 ]; then
        missing="$missing C2:hash-object-hard-fail-literal"
    fi
    if [ "$(pin_count rung4-untracked-main-present literal SEPARATED)" -eq 0 ]; then
        missing="$missing C3:rung4-untracked-main-present-literal"
    fi

    if [ -n "$missing" ]; then echo "PINS NOT SATISFIED:$missing" >&2; fi
    [ -z "$missing" ]
}
