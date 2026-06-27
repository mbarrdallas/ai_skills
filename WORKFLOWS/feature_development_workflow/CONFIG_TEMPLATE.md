# Workflow Configuration Template

Copy this template to `WORKFLOW_CONFIG.md` in your workflow directory.

---

```markdown
# Workflow Configuration

## Workflow Info
- **Name:** [workflow-name]
- **Created:** [ISO timestamp]
- **Description:** [Brief description of what's being built]

## Mode
mode: interactive | autonomous

## Project Type
project_type: greenfield | existing

## Checkpoints (Interactive Mode)
checkpoints:
  requirements_approval: true
  design_approval: true
  final_signoff: true

## Budget (Orchestrator Discretion)
budget:
  guidance: normal | conservative | aggressive
  notes: |
    [Any specific budget guidance]
    When tight, prioritize quality over new code.

## Git Configuration
git:
  main_branch: main
  development_branch: develop
  feature_branch_prefix: feature/
  commit_style: conventional  # conventional | simple

## Quality Settings
quality:
  max_review_iterations: 3
  require_all_tests_pass: true
  require_linting_pass: true

## Agent Configuration
agents:
  context_agent:
    enabled: true  # false for greenfield
  documentation_agent:
    enabled: true
    generate_api_docs: true
    generate_developer_guide: true

## Custom Settings
custom:
  # Add workflow-specific settings here
```

---

## Configuration Options

### Mode

| Value | Description |
|-------|-------------|
| `interactive` | Pauses at checkpoints for human approval |
| `autonomous` | Runs end-to-end without human intervention |

### Project Type

| Value | Description |
|-------|-------------|
| `greenfield` | New project, no existing codebase |
| `existing` | Modifying an existing codebase |

### Checkpoints

Only apply in interactive mode:
- `requirements_approval`: Pause after requirements gathered
- `design_approval`: Pause after design complete
- `final_signoff`: Pause before merging

### Budget Guidance

The orchestrator has discretion over budget, but guidance can be provided:
- `normal`: Standard resource allocation
- `conservative`: Be careful with resources, prefer simpler solutions
- `aggressive`: Prioritize thoroughness, more retries allowed

### Git Configuration

- `main_branch`: Branch that requires human merge (typically `main`)
- `development_branch`: Branch orchestrator can merge to (typically `develop`)
- `feature_branch_prefix`: Prefix for feature branches
- `commit_style`: Commit message format

### Quality Settings

- `max_review_iterations`: How many times to retry after review failure
- `require_all_tests_pass`: Block completion if tests fail
- `require_linting_pass`: Block completion if linting fails

### Agent Configuration

Enable/disable specific agents or features:
- Context Agent can be disabled for greenfield projects
- Documentation Agent options control what docs are generated

## Example Configurations

### Interactive Feature Development
```yaml
mode: interactive
project_type: existing
checkpoints:
  requirements_approval: true
  design_approval: true
  final_signoff: true
budget:
  guidance: normal
```

### Autonomous Quick Feature
```yaml
mode: autonomous
project_type: existing
checkpoints:
  requirements_approval: false
  design_approval: false
  final_signoff: false
budget:
  guidance: conservative
quality:
  max_review_iterations: 2
```

### Greenfield Project
```yaml
mode: interactive
project_type: greenfield
agents:
  context_agent:
    enabled: false
```
