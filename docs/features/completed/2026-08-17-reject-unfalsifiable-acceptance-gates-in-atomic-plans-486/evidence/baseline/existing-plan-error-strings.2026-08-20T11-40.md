# Existing Plan-Validator Error Strings (Pre-Change Reference)

Timestamp: 2026-08-20T11-40
Task: [P0-T11]
Issue: #486

This artifact is the reference for the AC3 byte-identity tests. The seven strings below are the complete set emitted by the pre-change plan structural walk in each runtime, listed once per runtime in emission order.

## Python — `scripts/dev_tools/validate_orchestration_artifacts.py`

Emission order follows the source order of the `errors.append(...)` calls in `validate_plan_text`.

| # | Source lines | String (with f-string placeholders shown as written) |
| --- | --- | --- |
| 1 | 102-105 | ``Line {line_number}: phase heading must match `### Phase N — <Title>`.`` |
| 2 | 117-120 | ``Line {line_number}: task line must match `- [ ] [P#-T#] <Title>`.`` |
| 3 | 125-129 | `Line {line_number}: task appears before a canonical phase heading.` |
| 4 | 132-135 | `Line {line_number}: task phase P{task_phase} does not match current phase {current_phase}.` |
| 5 | 138-141 | `Line {line_number}: expected task number T{expected} for phase {task_phase}, found T{task_num}.` |
| 6 | 145 | `Plan does not contain any canonical phase headings.` |
| 7 | 147 | `Plan does not contain any canonical task lines.` |

Verbatim source excerpts:

```
102:                errors.append(
103:                    f"Line {line_number}: phase heading must match "
104:                    "`### Phase N — <Title>`."
105:                )
117:                errors.append(
118:                    f"Line {line_number}: task line must match "
119:                    "`- [ ] [P#-T#] <Title>`."
120:                )
125:                errors.append(
126:                    "Line "
127:                    f"{line_number}: task appears before a canonical phase "
128:                    "heading."
129:                )
132:                errors.append(
133:                    f"Line {line_number}: task phase P{task_phase} does not match "
134:                    f"current phase {current_phase}."
135:                )
138:                errors.append(
139:                    f"Line {line_number}: expected task number T{expected} for phase "
140:                    f"{task_phase}, found T{task_num}."
141:                )
145:        errors.append("Plan does not contain any canonical phase headings.")
147:        errors.append("Plan does not contain any canonical task lines.")
```

## TypeScript — `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`

Emission order follows the source order of the `errors.push(...)` calls in the plan validator.

| # | Source lines | String (template placeholders shown as written) |
| --- | --- | --- |
| 1 | 90-93 | ``Line ${lineNumber}: phase heading must match `### Phase N — <Title>`.`` |
| 2 | 110-113 | ``Line ${lineNumber}: task line must match `- [ ] [P#-T#] <Title>`.`` |
| 3 | 119-121 | `Line ${lineNumber}: task appears before a canonical phase heading.` |
| 4 | 125-128 | `Line ${lineNumber}: task phase P${taskPhase} does not match current phase ${currentPhase}.` |
| 5 | 135-138 | `Line ${lineNumber}: expected task number T${expected} for phase ${taskPhase}, found T${taskNum}.` |
| 6 | 145 | `Plan does not contain any canonical phase headings.` |
| 7 | 148 | `Plan does not contain any canonical task lines.` |

Verbatim source excerpts:

```
 90:        errors.push(
 91:          `Line ${lineNumber}: phase heading must match ` +
 92:            "`### Phase N — <Title>`.",
 93:        );
110:        errors.push(
111:          `Line ${lineNumber}: task line must match ` +
112:            "`- [ ] [P#-T#] <Title>`.",
113:        );
119:        errors.push(
120:          `Line ${lineNumber}: task appears before a canonical phase heading.`,
121:        );
125:        errors.push(
126:          `Line ${lineNumber}: task phase P${taskPhase} does not match ` +
127:            `current phase ${currentPhase}.`,
128:        );
135:        errors.push(
136:          `Line ${lineNumber}: expected task number T${expected} for phase ` +
137:            `${taskPhase}, found T${taskNum}.`,
138:        );
145:    errors.push("Plan does not contain any canonical phase headings.");
148:    errors.push("Plan does not contain any canonical task lines.");
```

## Naming of the seven

1. malformed phase heading
2. malformed task line
3. task-before-phase-heading
4. task-phase mismatch
5. unexpected task number
6. no-phase-headings
7. `Plan does not contain any canonical task lines.`

Output Summary: All seven strings were located in both runtimes and are textually equivalent between them after placeholder substitution. The plan referenced Python lines 102-147 and TypeScript lines 90-148; the observed spans are Python 102-147 and TypeScript 90-148, matching the plan's stated ranges.
