$ErrorActionPreference = "Stop"

$env:LAB_USE_MOCK_TOOLS = "1"
go run ./cmd/readiness-check

