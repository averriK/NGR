# Detached jobs

Use an installed tmux session or a `nohup ... &` pair with an exit-status
marker when the selected heavy job must outlive the agent's turn. Neither
adds a product mode or makes the job survive host shutdown. Check the
installed tmux interface; a missing tool is not installation authority.

## Launch and record

Resolve the public command, arguments, CWD, environment, input generation and
destinations through the operation reference first. Give each attempt distinct
logs/results or preserve enough explicit identity to separate reused paths and
older rows. Record stdout/stderr and the actual command's exit status per job,
including failures before the product starts. A queue's final status must not
conceal earlier failures or missing result records.

A verified nohup shape (placeholders, not selected task values):

```text
cd PROJECT && nohup ngr render --manifest manifest.json >LOG 2>&1 & echo $!
# on completion: echo $? >LOG.exit   (via a wrapper that captures it)
```

Choose concurrent jobs from the task's resource budget and independent
writes, with sequential work inside each queue. Three queues is not a default.
Keep consumed inputs stable. Independent jobs must not replace the same output
or change sources another render is consuming; the native manifest batch is
sequential and stops at its first failure, and an outer queue's chosen
continue policy does not change that contract.

Before launching, reconcile any recorded attempt. In the task's durable state
retain the session/PID, exact command/CWD, input identity, log/result paths
and destinations. A successful launch proves only launch; a fast job may
finish before inspection.

## Resume and accept

Inspect the recorded process and bounded logs/results before launching
anything again. Monitor at a cadence appropriate to the job, not every
second; elapsed time alone does not justify killing or duplicating it. A
full-project render can run for hours with the book profile as the
bottleneck while revealjs aliases take seconds to minutes each.

If the process is gone, reconcile the exact attempt's completion record, logs
and destination. Distinguish success, failure, unattempted jobs and unknown
effects; an old success row or missing final row cannot establish this
attempt. Preserve verified successes and resolve only the still-authorized
remainder. Keep launch, process completion, product acceptance and
publication separate.

## NGR boundary

Each job selects project CWD, master/source, explicit profile or manifest
selection, and final destination. Use `ngr render`, including the required
profile for direct DOCX. A tmux/nohup launch or a `[render manifest]`
progress line does not prove final completion; the batch prints
`[render manifest] complete` and the output gate fails missing required
outputs. Apply [render acceptance](render.md#generation-and-output-acceptance)
to the current final tree and required QA before any separately authorized
deploy.
