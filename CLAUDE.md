# CLAUDE.md

## Updating a component dependency

1. Edit the component's version (e.g. short commit hash) in `manifest.yaml`.
   Get the latest commit with `git ls-remote https://github.com/<owner>/<repo> HEAD`.
2. Run `./update.sh` (runs `builder --config=manifest.yaml --skip-compilation`),
   which regenerates `components.go`, `go.mod` and `go.sum`.
3. Verify with `go build .`.
