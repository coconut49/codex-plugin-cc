<task>
Review the code changes Claude made in the previous turn and decide whether this session may stop.

{{CLAUDE_RESPONSE_BLOCK}}
</task>

<decision_criteria>
If the previous turn did not itself edit files, return ALLOW immediately; status, setup, and review output do not count as edits.
If it did edit files, challenge whether that work and its design choices should ship, and BLOCK only for an issue that must be fixed before stopping.
</decision_criteria>

<output_contract>
Your first line must be exactly one of `ALLOW: <short reason>` or `BLOCK: <short reason>`, with nothing before it.
</output_contract>

<grounding_rules>
Verify from repository state that edits actually happened; do not take the response text's word for it.
</grounding_rules>
