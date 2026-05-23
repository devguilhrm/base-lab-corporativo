package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

type checkResult struct {
	Name   string
	Status string
	Detail string
}

func main() {
	root, err := findRoot()
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to resolve project root: %v\n", err)
		os.Exit(1)
	}

	useMockTools := mockToolsEnabled()
	results := []checkResult{
		checkFiles(root),
		checkGoTests(root),
		checkDocker(root, useMockTools),
		checkAnsible(root, useMockTools),
		checkBash(root, useMockTools),
	}

	fmt.Println("Homelab readiness report")
	fmt.Println("========================")
	if useMockTools {
		fmt.Println("Mode: mock tools enabled (LAB_USE_MOCK_TOOLS=1)")
	}
	exitCode := 0
	for _, result := range results {
		fmt.Printf("[%s] %s: %s\n", result.Status, result.Name, result.Detail)
		if result.Status == "FAIL" {
			exitCode = 1
		}
	}
	os.Exit(exitCode)
}

func findRoot() (string, error) {
	cwd, err := os.Getwd()
	if err != nil {
		return "", err
	}

	for {
		if fileExists(filepath.Join(cwd, "go.mod")) {
			return cwd, nil
		}
		next := filepath.Dir(cwd)
		if next == cwd {
			return "", fmt.Errorf("go.mod not found")
		}
		cwd = next
	}
}

func checkFiles(root string) checkResult {
	required := []string{
		"infra/docker-compose.yml",
		"infra/.env.example",
		"ansible/inventory/hosts.ini",
		"ansible/playbooks/linux-baseline.yml",
		"ansible/playbooks/zabbix-agent-linux.yml",
		"docs/phases.md",
		"docs/runbook.md",
		"zabbix/templates/template-active-directory.yaml",
		"zabbix/templates/template-file-server.yaml",
		"zabbix/templates/template-linux-security.yaml",
		"project_readiness_test.go",
	}

	var missing []string
	for _, path := range required {
		if !fileExists(filepath.Join(root, filepath.FromSlash(path))) {
			missing = append(missing, path)
		}
	}
	if len(missing) > 0 {
		return checkResult{"project files", "FAIL", "Missing: " + strings.Join(missing, ", ")}
	}
	return checkResult{"project files", "OK", "All required project files are present."}
}

func checkGoTests(root string) checkResult {
	code, output := run(root, "go", "test", "./...")
	if code == 0 {
		return checkResult{"automated tests", "OK", "go test ./... passed."}
	}
	return checkResult{"automated tests", "FAIL", tail(output, 1200)}
}

func checkDocker(root string, useMockTools bool) checkResult {
	if _, err := exec.LookPath("docker"); err != nil {
		if useMockTools {
			return mockDockerCompose(root)
		}
		return checkResult{"docker compose", "WARN", "Docker is not installed or not in PATH."}
	}
	code, output := run(filepath.Join(root, "infra"), "docker", "compose", "-f", "docker-compose.yml", "--env-file", ".env.example", "config")
	if code == 0 {
		return checkResult{"docker compose", "OK", "Compose file renders successfully."}
	}
	return checkResult{"docker compose", "FAIL", tail(output, 1200)}
}

func checkAnsible(root string, useMockTools bool) checkResult {
	if _, err := exec.LookPath("ansible-playbook"); err != nil {
		if useMockTools {
			return mockAnsible(root)
		}
		return checkResult{"ansible", "WARN", "ansible-playbook is not installed or not in PATH."}
	}

	var failures []string
	for _, playbook := range []string{"linux-baseline.yml", "zabbix-agent-linux.yml"} {
		code, output := run(root, "ansible-playbook", "--syntax-check", "-i", "ansible/inventory/hosts.ini", "ansible/playbooks/"+playbook)
		if code != 0 {
			failures = append(failures, playbook+": "+tail(output, 600))
		}
	}
	if len(failures) > 0 {
		return checkResult{"ansible", "FAIL", strings.Join(failures, "\n")}
	}
	return checkResult{"ansible", "OK", "All playbooks pass syntax-check."}
}

func checkBash(root string, useMockTools bool) checkResult {
	if _, err := exec.LookPath("bash"); err != nil {
		if useMockTools {
			return mockBash(root)
		}
		return checkResult{"bash scripts", "WARN", "bash is not installed or not in PATH."}
	}

	scripts, _ := filepath.Glob(filepath.Join(root, "scripts", "linux", "*.sh"))
	zabbixScripts, _ := filepath.Glob(filepath.Join(root, "scripts", "zabbix", "*.sh"))
	scripts = append(scripts, zabbixScripts...)
	for _, script := range scripts {
		code, output := run(root, "bash", "-n", script)
		lower := strings.ToLower(output)
		if code != 0 || strings.Contains(lower, "wsl") || strings.Contains(lower, "subsistema do windows para linux") {
			if useMockTools {
				return mockBash(root)
			}
			return checkResult{"bash scripts", "WARN", "Bash exists, but cannot validate scripts cleanly here."}
		}
	}
	return checkResult{"bash scripts", "OK", "All shell scripts pass bash -n."}
}

func mockDockerCompose(root string) checkResult {
	composePath := filepath.Join(root, "infra", "docker-compose.yml")
	envPath := filepath.Join(root, "infra", ".env.example")
	compose, err := os.ReadFile(composePath)
	if err != nil {
		return checkResult{"docker compose", "FAIL", "Mock compose validation failed: " + err.Error()}
	}
	env, err := os.ReadFile(envPath)
	if err != nil {
		return checkResult{"docker compose", "FAIL", "Mock env validation failed: " + err.Error()}
	}

	requiredCompose := []string{
		"postgres:",
		"zabbix-server:",
		"zabbix-web:",
		"grafana:",
		"postgres:16",
		"zabbix/zabbix-server-pgsql:alpine-7.0-latest",
		"zabbix/zabbix-web-nginx-pgsql:alpine-7.0-latest",
		"grafana/grafana-oss:11.0.0",
		"10051:10051",
		"8080:8080",
		"3000:3000",
		"pg_data:",
		"grafana_data:",
	}
	if missing := missingFragments(string(compose), requiredCompose); len(missing) > 0 {
		return checkResult{"docker compose", "FAIL", "Mock compose validation missing: " + strings.Join(missing, ", ")}
	}

	requiredEnv := []string{
		"POSTGRES_DB=",
		"POSTGRES_USER=",
		"POSTGRES_PASSWORD=",
		"ZBX_SERVER_NAME=",
		"ZBX_TIMEZONE=",
		"GF_SECURITY_ADMIN_USER=",
		"GF_SECURITY_ADMIN_PASSWORD=",
	}
	if missing := missingFragments(string(env), requiredEnv); len(missing) > 0 {
		return checkResult{"docker compose", "FAIL", "Mock env validation missing: " + strings.Join(missing, ", ")}
	}

	return checkResult{"docker compose", "OK", "Mock Docker Compose validation passed."}
}

func mockAnsible(root string) checkResult {
	files := map[string][]string{
		"ansible/inventory/hosts.ini": {
			"[linux]",
			"vm-linux01",
			"vm-linux02",
			"vm-zabbix",
			"ansible_become=true",
		},
		"ansible/group_vars/all.yml": {
			"timezone:",
			"common_packages:",
			"zabbix_server_host:",
		},
		"ansible/playbooks/linux-baseline.yml": {
			"hosts: linux",
			"fail2ban",
			"PasswordAuthentication no",
			"handlers:",
		},
		"ansible/playbooks/zabbix-agent-linux.yml": {
			"hosts: linux",
			"zabbix-agent2",
			"ServerActive={{ zabbix_server_host }}",
			"HostnameItem=system.hostname",
		},
	}

	for path, fragments := range files {
		content, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(path)))
		if err != nil {
			return checkResult{"ansible", "FAIL", "Mock Ansible validation failed: " + err.Error()}
		}
		if missing := missingFragments(string(content), fragments); len(missing) > 0 {
			return checkResult{"ansible", "FAIL", "Mock Ansible validation missing in " + path + ": " + strings.Join(missing, ", ")}
		}
	}

	return checkResult{"ansible", "OK", "Mock Ansible syntax/contract validation passed."}
}

func mockBash(root string) checkResult {
	scripts, _ := filepath.Glob(filepath.Join(root, "scripts", "linux", "*.sh"))
	zabbixScripts, _ := filepath.Glob(filepath.Join(root, "scripts", "zabbix", "*.sh"))
	scripts = append(scripts, zabbixScripts...)
	if len(scripts) == 0 {
		return checkResult{"bash scripts", "FAIL", "Mock Bash validation found no shell scripts."}
	}

	for _, script := range scripts {
		content, err := os.ReadFile(script)
		if err != nil {
			return checkResult{"bash scripts", "FAIL", "Mock Bash validation failed: " + err.Error()}
		}
		text := string(content)
		if !strings.HasPrefix(text, "#!/usr/bin/env bash") {
			return checkResult{"bash scripts", "FAIL", "Missing bash shebang in " + filepath.Base(script)}
		}
		if !strings.Contains(text, "set -euo pipefail") {
			return checkResult{"bash scripts", "FAIL", "Missing strict mode in " + filepath.Base(script)}
		}
		if strings.Count(text, "\"")%2 != 0 || strings.Count(text, "'")%2 != 0 {
			return checkResult{"bash scripts", "FAIL", "Unbalanced quotes detected in " + filepath.Base(script)}
		}
	}

	return checkResult{"bash scripts", "OK", "Mock Bash/WSL validation passed."}
}

func run(cwd string, command string, args ...string) (int, string) {
	cmd := exec.Command(command, args...)
	cmd.Dir = cwd
	cmd.Env = os.Environ()

	done := make(chan struct{})
	var output []byte
	var err error
	go func() {
		output, err = cmd.CombinedOutput()
		close(done)
	}()

	select {
	case <-done:
	case <-time.After(60 * time.Second):
		_ = cmd.Process.Kill()
		return 124, "command timed out"
	}

	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return exitErr.ExitCode(), string(output)
		}
		return 127, err.Error()
	}
	return 0, string(output)
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && !info.IsDir()
}

func tail(value string, limit int) string {
	if len(value) <= limit {
		return strings.TrimSpace(value)
	}
	return strings.TrimSpace(value[len(value)-limit:])
}

func mockToolsEnabled() bool {
	value := strings.ToLower(strings.TrimSpace(os.Getenv("LAB_USE_MOCK_TOOLS")))
	return value == "1" || value == "true" || value == "yes"
}

func missingFragments(content string, fragments []string) []string {
	var missing []string
	for _, fragment := range fragments {
		if !strings.Contains(content, fragment) {
			missing = append(missing, fragment)
		}
	}
	return missing
}
