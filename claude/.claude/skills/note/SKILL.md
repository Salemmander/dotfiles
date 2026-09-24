---
name: note
description: Append a quick note to weekly-notes.md for the weekly update. Invoke with /note <your note>.
allowed-tools: Bash(date:*), Read, Edit
---

# Quick Weekly Note

Append a timestamped note to the weekly notes file for use in the weekly update.

## Invocation

```
/note <text>
```

- `text` can be a direct note, a casual remark, or a reference to recent work.

## Instructions

### Step 1: Interpret the note

Figure out what the user actually wants noted:

- **Direct note** (e.g., `/note fixed the SSoT sync issue`): Use the text as-is.
- **Casual / messy phrasing** (e.g., `/note note that we finished that thing`): Strip filler ("note that", "make note of") and extract the core content.
- **References conversation context** (e.g., `/note make note of the work we just did`): Summarize what was accomplished in the current session into 1-2 concise sentences.

Clean up the note into a concise, professional bullet point. Strip filler words, fix grammar, keep it brief. Do not use emojis.

### Step 2: Append the note

The notes file is at: `~/Documents/Projects/weekly-updates/weekly-notes.md`

Get today's date:

```bash
date +%Y-%m-%d
```

If the file does not exist, create it. If it exists, read it then append to it.

Add the note in this format:

```
- [YYYY-MM-DD] <cleaned up note>
```

Append to the end of the file. Do not modify any existing content.

### Step 3: Confirm

Reply with just: "Noted." Do not be verbose.
