# Archon

A general-purpose LLM agent CLI in Ruby. Sends a prompt to an LLM, runs an agentic tool-calling loop, and returns a structured JSON answer.

## Setup

```
bundle install
```

Set your xAI API key:

```
export XAI_API_KEY=your-key-here
```

## Usage

Archon accepts a prompt via stdin pipe, `--prompt-text`, or `--prompt-file`.

```bash
# Pipe from stdin
echo "What is 2+2?" | bundle exec ruby bin/archon

# Inline text
bundle exec ruby bin/archon --prompt-text "What is 2+2?"

# From a file
bundle exec ruby bin/archon --prompt-file prompt.txt
```

Output is a single JSON line:

```json
{"outcome":"success","value":"4"}
```

### Options

| Flag | Default | Description |
|---|---|---|
| `--prompt-text TEXT` | | Prompt string |
| `--prompt-file FILE` | | Read prompt from file |
| `--overflow N` | 10 | Max tool calls before auto-terminating |
| `--model MODEL` | grok-3-mini | Model name |
| `--provider PROVIDER` | grok | LLM provider |

## Running tests

```
bundle exec rspec
bundle exec rubocop
```
