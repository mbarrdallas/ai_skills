# Locations Template

Copy this template to `LOCATIONS.md` in your workflow directory.

---

```markdown
# Locations

All paths used by this workflow. No hardcoded paths in agents - always reference this file.

## Workflow Directory
workflow_dir: ~/WORKSPACE/active_workflows/[workflow-name]

## Code Repository
code_repo: /path/to/your/project/repo

## Worktrees Directory
worktrees_dir: /path/to/worktrees
# Recommended: ../worktrees relative to code_repo
# Or absolute: ~/WORKSPACE/worktrees/[workflow-name]

## Skills Directory
skills_dir: ~/WORKSPACE/REPOS/ai_skills/skills

## Agents Directory  
agents_dir: ~/WORKSPACE/REPOS/ai_skills/AGENTS

## Output Locations (relative to workflow_dir)
outputs:
  design: ./design
  planning: ./planning
  orchestrator: ./orchestrator
  reviews: ./reviews
  docs: ./docs
  lessons: ./lessons

## Code Locations (relative to code_repo)
code:
  src: ./src
  tests: ./tests
```

---

## Path Resolution

Agents should resolve paths as follows:

```python
# Example path resolution logic
import os

def resolve_path(locations, key):
    """Resolve a path from LOCATIONS.md"""
    path = locations[key]
    
    # Expand ~ to home directory
    if path.startswith('~'):
        path = os.path.expanduser(path)
    
    # Resolve relative paths against workflow_dir
    if not os.path.isabs(path):
        path = os.path.join(locations['workflow_dir'], path)
    
    return os.path.normpath(path)
```

## Paths by Agent

| Agent | Reads From | Writes To |
|-------|------------|-----------|
| Context Agent | code_repo | workflow_dir/PROJECT_CONTEXT.md |
| Requirements Agent | workflow_dir | workflow_dir/REQUIREMENTS.md |
| Design Agent | workflow_dir | outputs.design |
| Planning Agent | workflow_dir, outputs.design | outputs.planning |
| Orchestrator | workflow_dir, code_repo | outputs.orchestrator |
| Test Agent | outputs.design, outputs.planning | code.tests (in worktree) |
| Coder Agent | outputs.design, code.tests | code.src (in worktree) |
| Reviewer Agent | code.src, code.tests | outputs.reviews |
| Documentation Agent | workflow_dir, code_repo | outputs.docs |

## Worktree Paths

For parallel task execution, worktrees are created at:
```
{worktrees_dir}/{workflow_name}/task-{task_id}-{task_name}/
```

Example:
```
~/WORKSPACE/worktrees/user-auth/
├── task-T1-api-endpoints/
├── task-T2-database-models/
└── task-T3-auth-middleware/
```

Each worktree is a full copy of the repository on its own branch.

## Example LOCATIONS.md

```markdown
# Locations

## Workflow Directory
workflow_dir: ~/WORKSPACE/active_workflows/user-authentication

## Code Repository
code_repo: ~/projects/myapp

## Worktrees Directory
worktrees_dir: ~/WORKSPACE/worktrees

## Skills Directory
skills_dir: ~/WORKSPACE/REPOS/ai_skills/skills

## Agents Directory
agents_dir: ~/WORKSPACE/REPOS/ai_skills/AGENTS

## Output Locations
outputs:
  design: ./design
  planning: ./planning
  orchestrator: ./orchestrator
  reviews: ./reviews
  docs: ./docs
  lessons: ./lessons

## Code Locations
code:
  src: ./src
  tests: ./tests
```

## Security Notes

- Never commit LOCATIONS.md with absolute paths to shared repos
- Use environment variables or relative paths for portable configurations
- Ensure workflow_dir is in a safe location (not system directories)
- Worktrees_dir should have sufficient disk space
