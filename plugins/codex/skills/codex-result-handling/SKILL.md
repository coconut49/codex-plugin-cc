---
name: codex-result-handling
description: Internal guidance for presenting Codex helper output back to the user
user-invocable: false
---

# Codex Result Handling

When the helper returns Codex output:
- Preserve the structure Codex produced — verdict, summary, findings, next steps, plus any sections the prompt asked for, such as observed facts, inferences, open questions, or touched files.
- Present review findings first, ordered by severity.
- Use the file paths and line numbers exactly as the helper reports them.
- Preserve evidence boundaries. If Codex marked something as an inference, uncertainty, or follow-up question, keep that distinction.
- Review findings are presented for the user to triage — ask which issues to fix before changing any file.
- If there are no findings, say that explicitly and keep the residual-risk note brief.
- If Codex made edits, say so explicitly and list the touched files when the helper provides them.
- If the helper reports a failed run or malformed output, present the most actionable stderr lines and stop there instead of guessing.
- A failed or incomplete `codex:codex-rescue` run stays reported as a failure; it does not become a Claude-side implementation attempt or a substitute answer.
- If the helper reports that setup or authentication is required, direct the user to `/codex:setup` rather than improvising an alternate auth flow.
