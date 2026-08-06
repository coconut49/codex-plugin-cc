---
description: Delegate investigation, an explicit fix request, or follow-up rescue work to the Codex rescue subagent
argument-hint: "[--background|--wait] [--resume|--fresh] [--model <model>] [--effort <effort>] [what Codex should investigate, solve, or continue]"
allowed-tools: Bash(node:*), AskUserQuestion, Agent
---

Invoke the `codex:codex-rescue` subagent via the `Agent` tool (`subagent_type: "codex:codex-rescue"`), forwarding the user's request as the prompt.
`codex:codex-rescue` is a subagent, not a skill — do not call `Skill(codex:codex-rescue)` (no such skill) or `Skill(codex:rescue)` (that re-enters this command and hangs the session). This command runs inline so the `Agent` tool stays in scope; forked general-purpose subagents do not expose it.
The final user-visible response is Codex's output verbatim, with nothing added before or after it.

Raw user request:
$ARGUMENTS

Execution mode:

- `--background` runs the subagent in the background, `--wait` runs it in the foreground, and neither flag means foreground.
- `--background`, `--wait`, `--model`, and `--effort` are runtime controls. Forward them alongside the request, and keep them out of the natural-language task text.

Thread continuation:

- If the request already includes `--resume` or `--fresh`, honor that choice and leave the flag in the forwarded request.
- Otherwise, before starting Codex, check for a resumable rescue thread from this Claude session by running:

```bash
node "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" task-resume-candidate --json
```

- If that helper reports `available: false`, route normally without asking.
- If it reports `available: true`, use `AskUserQuestion` exactly once with these two choices:
  - `Continue current Codex thread`
  - `Start a new Codex thread`
- If the user is clearly giving a follow-up instruction such as "continue", "keep going", "resume", "apply the top fix", or "dig deeper", put `Continue current Codex thread (Recommended)` first. Otherwise put `Start a new Codex thread (Recommended)` first.
- Add `--resume` to the forwarded request when the user chooses to continue, `--fresh` when the user chooses a new thread.

Model selection for the forwarded task:

- If the user named a model or effort, pass it through as-is.
- If the task is delegated work with a concrete deliverable and a mechanically checkable outcome (tests, compilation, or data to verify against), pass `--model gpt-5.6-luna`.
- Otherwise — second opinions, review, diagnosis, or anything you are unsure about — leave model and effort unset so the user's Codex config decides. Misrouting upward only costs quota; misrouting downward delivers below expectation.

When drafting the delegated task text (especially when you initiate the delegation), include:

- the goal and the concrete deliverable
- acceptance criteria: how completion will be verified
- known evidence and constraints: data locations, error output, what has been tried

Write it outcome-first: state what done looks like; do not prescribe step-by-step process.

If the helper reports that Codex is missing or unauthenticated, stop and tell the user to run `/codex:setup`.
If the user did not supply a request, ask what Codex should investigate or fix.
