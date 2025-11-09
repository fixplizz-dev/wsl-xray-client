# Development Workflow

## Branch Strategy

### Main Branch (`main`)
- **Always stable and production-ready**
- Contains only tested and approved releases
- Protected branch - no direct commits
- Only merges from `development` after approval and testing

### Development Branch (`development`)
- Active development of new phases
- All new features and iterations
- Must pass all tests before merging to main
- Creates releases as separate branches for approval

## Release Process

### Phase Development
1. Work happens in `development` branch
2. Implement next phase (Phase 4: User Story 2, etc.)
3. All tests must pass
4. Update version in `.version` file

### Release Creation
1. Create release branch from `development`: `git checkout -b release/v0.2.0`
2. Final testing and documentation updates
3. Create Pull Request to `main`
4. **Wait for approval** before merging
5. Tag release after merge: `git tag v0.2.0`

### Hotfixes
1. Create branch from `main`: `git checkout -b hotfix/v0.1.1`
2. Fix issue and test
3. Merge to both `main` AND `development`

## Current Status

- **v0.1.0**: Initial MVP (Phases 1-3 complete)
  - ✅ Setup, Foundation, User Story 1
  - ✅ Install, config generation, IP checking
  - ✅ Systemd service management
  - ✅ Full validation and error handling

- **Next**: Phase 4 - User Story 2 (Management Commands)
  - start/stop/restart/status/logs actions
  - autostart control
  - Enhanced diagnostics

## Commands

```bash
# Switch to development
git checkout development

# Start new phase work
git pull origin development

# Create release when ready
git checkout -b release/v0.2.0
git push -u origin release/v0.2.0
# Create PR to main, wait for approval

# After approval and merge, tag
git checkout main
git pull origin main
git tag v0.2.0
git push origin v0.2.0
```

## Testing Requirements

Before any merge to `main`:
- [ ] All existing tests pass
- [ ] New functionality has tests
- [ ] Manual testing in clean WSL environment
- [ ] Documentation updated
- [ ] Version number updated