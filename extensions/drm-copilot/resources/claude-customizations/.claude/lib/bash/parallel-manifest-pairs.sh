#!/usr/bin/env bash
# parallel-manifest-pairs.sh: sourceable bash port of invariant M9 of
# scripts/dev_tools/parallel_manifest_contract.py (issue #1164). Validates the
# optional pair_decisions key: one {a, b, reasons, hard, cost, benefit, verdict}
# entry per detected pair, written by the planner at seeding.
#
# Sourced by parallel-manifest-validate.sh, which defines PM_CONTEXT and
# pm_declared_issue_nums and sources the shared parser and predicates. Every
# error string is byte-identical to the Python authority; the shared corpus
# tests/fixtures/parallel_manifest_bash/*.json binds the two lanes. Only bash
# builtins are used, so the payload-only lane needs no further utility.

# The four conflict reason kinds, in canonical order (rule ## Enum Ownership).
PM_VALID_EDGE_REASONS="path_overlap, module_overlap, shared_surface_overlap, contract_dependency"

# The two pair verdicts of invariant M9.
PM_VALID_PAIR_VERDICTS="edge, tolerated"

# The canonical "a b" key of the entry most recently resolved by
# pm_pair_endpoints, or empty when its endpoints are unusable.
PM_PAIR_KEY=""

pm_pair_endpoints() {
	# Resolve one pair decision's endpoints and set PM_PAIR_KEY.
	#
	# Args: $1 = node path of the entry, $2 = entry context prefix,
	# $3 = space-separated declared issue_num values. Appends one error per
	# unresolved endpoint, or one normalization error when a >= b.
	# Returns: 0 always; PM_PAIR_KEY is "a:b" when both endpoints are usable.
	local path="$1" ctx="$2" declared="$3"
	local field type value failed=0
	PM_PAIR_KEY=""
	# Resolve both endpoints so a bad a does not hide a bad b.
	for field in a b; do
		type=$(yp_type_of "${path}.${field}")
		value=$(yp_value_of "${path}.${field}")
		if ! pc_is_positive_integer "$type" "$value" || ! pc_contains_word "$declared" "$value"; then
			pc_error_add "$ctx $field does not resolve to an items[] issue_num; found: $(pi_repr_at "${path}.${field}")."
			failed=1
		fi
	done
	((failed == 0)) || return 0
	local first second
	first=$(yp_value_of "${path}.a")
	second=$(yp_value_of "${path}.b")
	if ((first >= second)); then
		pc_error_add "$ctx must be normalized with a < b; found: (${first}, ${second})."
		return 0
	fi
	PM_PAIR_KEY="${first}:${second}"
}

pm_pair_reasons_valid() {
	# Return 0 when a reasons node is a non-empty sequence of enum members.
	#
	# Args: $1 = node path of the reasons list.
	# Returns: 0 when valid, 1 otherwise; prints nothing.
	local path="$1" count index type value
	[[ $(yp_type_of "$path") == seq ]] || return 1
	count=$(yp_count_of "$path")
	((count > 0)) || return 1
	# Every reason must be a string enum member; the first other entry fails the list.
	for ((index = 0; index < count; index++)); do
		type=$(yp_type_of "${path}[${index}]")
		value=$(yp_value_of "${path}[${index}]")
		[[ $type == str ]] || return 1
		pc_enum_members_contains "$PM_VALID_EDGE_REASONS" "$value" || return 1
	done
	return 0
}

pm_pair_fields() {
	# Check one pair decision's reasons, hard flag, estimates, and verdict.
	#
	# Args: $1 = node path of the entry, $2 = entry context prefix.
	# Returns: 0 unless pc_error_add fails; errors are appended through pc_error_add.
	local path="$1" ctx="$2" field hard_type hard_value type value
	if ! pm_pair_reasons_valid "${path}.reasons"; then
		pc_error_add "$ctx reasons must be a non-empty list drawn from $PM_VALID_EDGE_REASONS."
	fi
	hard_type=$(yp_type_of "${path}.hard")
	hard_value=$(yp_value_of "${path}.hard")
	if [[ $hard_type != bool ]]; then
		pc_error_add "$ctx hard must be a boolean."
	fi
	# Both integer-minute estimates are required on every pair decision.
	for field in cost benefit; do
		type=$(yp_type_of "${path}.${field}")
		value=$(yp_value_of "${path}.${field}")
		if ! pc_is_non_negative_integer "$type" "$value"; then
			pc_error_add "$ctx $field must be a non-negative integer; found: $(pi_repr_at "${path}.${field}")."
		fi
	done
	type=$(yp_type_of "${path}.verdict")
	value=$(yp_value_of "${path}.verdict")
	if [[ $type != str ]] || ! pc_enum_members_contains "$PM_VALID_PAIR_VERDICTS" "$value"; then
		pc_error_add "$(pc_enum_error "$ctx" "verdict" "$PM_VALID_PAIR_VERDICTS" "$(pi_repr_at "${path}.verdict")")"
	elif [[ $hard_type == bool && $hard_value == true && $value != edge ]]; then
		# A hard class is an edge at every tolerance (issue #722).
		pc_error_add "$ctx verdict must be edge when hard is true."
	fi
}

pm_validate_pair_decisions() {
	# Validate the optional pair_decisions key (invariant M9).
	#
	# Key gated, like M8: absence is the shape of every earlier manifest, so a
	# manifest without the key gains no error. Entries are validated in
	# document order: endpoint errors, then a repeated pair, then the fields.
	#
	# Args: none
	# Returns: 0 unless pc_error_add fails; errors are appended through pc_error_add.
	local root="pair_decisions"
	yp_has "$root" || return 0
	if [[ $(yp_type_of "$root") != seq ]]; then
		pc_error_add "$PM_CONTEXT $root must be a list."
		return 0
	fi

	local declared total index path ctx seen=""
	declared=$(pm_declared_issue_nums)
	total=$(yp_count_of "$root")
	# Validate every entry in document order and track the pairs already seen.
	for ((index = 0; index < total; index++)); do
		path="${root}[${index}]"
		ctx="$PM_CONTEXT ${root}[${index}]"
		if [[ $(yp_type_of "$path") != map ]]; then
			pc_error_add "$ctx must be an object."
			continue
		fi
		pm_pair_endpoints "$path" "$ctx" "$declared"
		if [[ -n $PM_PAIR_KEY ]]; then
			if pc_contains_word "$seen" "$PM_PAIR_KEY"; then
				pc_error_add "$ctx repeats pair (${PM_PAIR_KEY%%:*}, ${PM_PAIR_KEY##*:})."
			fi
			seen="$seen $PM_PAIR_KEY"
		fi
		pm_pair_fields "$path" "$ctx"
	done
}
