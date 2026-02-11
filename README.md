# Auto Runbook ⚡
Automated Runbook Engine for Incident Response, DevOps, and AI-assisted Operations.

## Why Auto-Runbook?
Modern systems fail fast. Manual troubleshooting is slow and error-prone.

Auto-Runbook enables:
- ⚡ Automated incident diagnosis
- 🔁 Self-healing workflows
- 🤖 AI-assisted troubleshooting
- 📜 Reusable operational playbooks
- 🚀 Faster MTTR

## Use Cases
- DevOps / SRE automation
- Incident response
- AI Ops / Observability
- Self-healing infrastructure
- Automated troubleshooting

## Quick Demo
```bash
git clone https://github.com/vijayanandmit/auto-runbook
cd auto-runbook
python runbook.py
```

## Contributing
PRs welcome. Ideas → Issues.

When working with complex systems, infrastructure, or long-running troubleshooting sessions, it's easy to lose track of what you did, why you did it, and the results. This tool:

- **Automatically logs your entire terminal session** to a file
- **Converts the session log into a structured runbook** using an AI model
- **Version controls all runbooks** in a git repository
- **Provides reproducible documentation** for future reference or onboarding

Perfect for:
- Linux based CLI environment
- Software development and configuration tasks
- Troubleshooting and incident response
- Creating operational documentation on the fly
- Session replay and knowledge capture

## Features

- **Tmux-based session isolation** - Creates isolated sessions with automatic logging
- **AI-powered runbook generation** - Converts raw terminal output into structured Markdown
- **Version control integration** - Automatically commits runbooks to git
- **Structured documentation** - Always produces consistent, readable runbooks
- **Raw log preservation** - Keeps full session logs for detailed review

## Installation

1. Clone this repository:
```bash
git clone https://github.com/vijayanandmit/auto-runbook.git
cd auto-runbook
```

2. Make sure you have required tools:
```bash
# tmux for session management
sudo apt install tmux

# ollama for AI-powered runbook generation (optional but recommended)
# See: https://ollama.com
ollama pull glm-4.7  # or your preferred model
```

3. Configure the auto-runbook location (default: `~/auto-runbook`):
```bash
export AUTO_RUNBOOK_DIR="$HOME/auto-runbook"
```

## Usage

### Start a New Runbook Session

```bash
./bin/runbook_start.sh <session_name>
```

Example:
```bash
./bin/runbook_start.sh esxi_vm_check
```

This will:
1. Create a new session directory with a timestamp
2. Start a tmux session with logging enabled
3. Attach you to the session

### What Happens After Exit

When you exit the tmux session (type `exit`), the system will:
1. Summarize the session and generate a runbook
2. Commit the runbook to git
3. Display the runbook location

### Finish the Latest Runbook

If you need to regenerate or finish a session that's still open:

```bash
./bin/runbook_finish_latest.sh
```

### Summarize a Specific Session

If you want to summarize a specific session manually:

```bash
./bin/summarize_run.sh <session_dir> [model]
```

Example:
```bash
./bin/summarize_run.sh ~/auto-runbook/runs/2026-02-11_130747_cla_session glm-4.7
```

## Directory Structure

```
auto-runbook/
├── bin/
│   ├── runbook_start.sh      # Start a new session
│   ├── runbook_finish_latest.sh  # Finish the latest session
│   └── summarize_run.sh      # Summarize a specific session
├── templates/
│   └── runbook_template.md   # Runbook template
├── runs/
│   └── YYYY-MM-DD_HHMMSS_session_name/
│       ├── runbook.md        # AI-generated runbook
│       ├── session.log       # Raw terminal log
│       └── meta.txt          # Session metadata
└── README.md
```

## Runbook Structure

Each generated runbook includes:

1. **Objective** - What the session was trying to achieve
2. **Environment** - OS, tools, and network details
3. **Steps** - Step-by-step actions taken
4. **Commands** - Extracted commands in code blocks
5. **Errors & Fixes** - Any issues encountered and resolved
6. **Result** - Final outcome
7. **Artifacts** - Links to raw logs and session files

## AI Configuration

The system uses Ollama to generate runbooks. Configure your model:

1. Install Ollama: https://ollama.com
2. Pull a model:
```bash
ollama pull glm-4.7  # or llama3.1, codellama, etc.
```

3. Edit `bin/summarize_run.sh` to change the default model:
```bash
MODEL="${2:-your-preferred-model}"
```

## Version Control

All runbooks are automatically committed to git. After starting a session:

```bash
cd ~/auto-runbook
git status  # See your uncommitted runbooks
git log -1  # View the last runbook commit
```

# Contributing PRs welcome. Ideas → Issues.

# Star ⭐ if useful
