package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRequiredFilesExist(t *testing.T) {
	required := []string{
		"README.md",
		"docs/architecture.md",
		"docs/phases.md",
		"docs/runbook.md",
		"docs/checklist.md",
		"docs/execution-readiness.md",
		"docs/mock-tools.md",
		"infra/docker-compose.yml",
		"infra/.env.example",
		"infra/grafana/provisioning/datasources/datasource.yml",
		"infra/grafana/provisioning/dashboards/dashboards.yml",
		"infra/grafana/dashboards/linux-health.json",
		"ansible/requirements.yml",
		"ansible/inventory/hosts.ini",
		"ansible/group_vars/all.yml",
		"ansible/playbooks/linux-baseline.yml",
		"ansible/playbooks/zabbix-agent-linux.yml",
		"scripts/linux/auto-remediate-service.sh",
		"scripts/linux/backup-configs.sh",
		"scripts/linux/monitor-ssh-failures.sh",
		"scripts/linux/check-ssl-expiry.sh",
		"scripts/linux/file-integrity-check.sh",
		"scripts/linux/generate-weekly-report.sh",
		"scripts/mock-tools.ps1",
		"cmd/weekly-report/main.go",
		"cmd/readiness-check/main.go",
		"scripts/zabbix/install-zabbix-server-ubuntu.sh",
		"scripts/zabbix/install-grafana-zabbix-ubuntu.sh",
		"scripts/zabbix/install-zabbix-agent-windows.ps1",
		"zabbix/templates/template-active-directory.yaml",
		"zabbix/templates/template-file-server.yaml",
		"zabbix/templates/template-linux-security.yaml",
		"zabbix/actions/auto-remediation.yaml",
		"zabbix/discovery/network-discovery.yaml",
		"zabbix/web-scenarios/web-scenarios.yaml",
		"zabbix/agent/windows/userparameter_ad.conf",
		"zabbix/agent/windows/userparameter_fileserver.conf",
		"zabbix/agent/linux/userparameter_security.conf",
	}

	for _, path := range required {
		if info, err := os.Stat(filepath.FromSlash(path)); err != nil || info.IsDir() {
			t.Fatalf("required file missing: %s", path)
		}
	}
}

func TestNoLegacyScriptCodeRemains(t *testing.T) {
	var offenders []string
	err := filepath.WalkDir(".", func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() && (entry.Name() == ".git" || entry.Name() == "__pycache__") {
			return filepath.SkipDir
		}
		if strings.HasSuffix(entry.Name(), ".py") || strings.HasSuffix(entry.Name(), ".pyc") {
			offenders = append(offenders, path)
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(offenders) > 0 {
		t.Fatalf("legacy script artifacts remain: %s", strings.Join(offenders, ", "))
	}
}

func TestEnvExampleHasRequiredKeys(t *testing.T) {
	env := readFile(t, "infra/.env.example")
	required := []string{
		"POSTGRES_DB",
		"POSTGRES_USER",
		"POSTGRES_PASSWORD",
		"ZBX_SERVER_NAME",
		"ZBX_TIMEZONE",
		"GF_SECURITY_ADMIN_USER",
		"GF_SECURITY_ADMIN_PASSWORD",
	}

	for _, key := range required {
		if !strings.Contains(env, key+"=") {
			t.Fatalf("missing env key: %s", key)
		}
	}
}

func TestDockerComposeContract(t *testing.T) {
	compose := readFile(t, "infra/docker-compose.yml")
	expected := []string{
		"postgres:",
		"image: postgres:16",
		"zabbix-server:",
		"image: zabbix/zabbix-server-pgsql:alpine-7.0-latest",
		"zabbix-web:",
		"image: zabbix/zabbix-web-nginx-pgsql:alpine-7.0-latest",
		"grafana:",
		"image: grafana/grafana-oss:11.0.0",
		`"10051:10051"`,
		`"8080:8080"`,
		`"3000:3000"`,
	}

	for _, fragment := range expected {
		if !strings.Contains(compose, fragment) {
			t.Fatalf("docker compose missing fragment: %s", fragment)
		}
	}
}

func TestMockToolsDocumentationExists(t *testing.T) {
	readme := readFile(t, "README.md")
	mockDocs := readFile(t, "docs/mock-tools.md")
	readiness := readFile(t, "docs/execution-readiness.md")
	required := []string{
		"LAB_USE_MOCK_TOOLS",
		"go run ./cmd/readiness-check",
		"Docker",
		"Ansible",
		"Bash",
		"WSL",
	}

	for _, fragment := range required {
		if !strings.Contains(readme+mockDocs+readiness, fragment) {
			t.Fatalf("mock tools docs missing fragment: %s", fragment)
		}
	}
}

func TestGrafanaDashboardsAreValidJSON(t *testing.T) {
	matches, err := filepath.Glob(filepath.FromSlash("infra/grafana/dashboards/*.json"))
	if err != nil {
		t.Fatal(err)
	}
	if len(matches) == 0 {
		t.Fatal("no grafana dashboards found")
	}

	for _, path := range matches {
		var dashboard map[string]interface{}
		if err := json.Unmarshal([]byte(readFile(t, path)), &dashboard); err != nil {
			t.Fatalf("invalid dashboard JSON %s: %v", path, err)
		}
		if dashboard["title"] == "" || dashboard["panels"] == nil || dashboard["refresh"] == "" {
			t.Fatalf("dashboard missing required fields: %s", path)
		}
	}
}

func TestZabbixArtifactsCoverDocxImplementation(t *testing.T) {
	checks := map[string][]string{
		"zabbix/templates/template-active-directory.yaml": {
			"ad.service.ntds",
			"ad.replication.errors",
			"ad.users.locked",
			"service.info[DNS,state]",
		},
		"zabbix/templates/template-file-server.yaml": {
			"fileserver.smb.sessions",
			"fileserver.openfiles.total",
			"service.info[LanmanServer,state]",
			"fileserver.share.response",
		},
		"zabbix/templates/template-linux-security.yaml": {
			"security.ssh.failures",
			"security.fail2ban.banned",
			"security.passwd.checksum",
			"system.updates.pending",
		},
		"zabbix/actions/auto-remediation.yaml": {
			"Servico Linux parado",
			"Disco cheio > 90% Linux",
			"Falhas SSH excessivas",
		},
		"zabbix/discovery/network-discovery.yaml": {
			"Homelab Network Discovery",
			"192.168.10.1-254",
			"Auto-registration Linux",
		},
		"zabbix/web-scenarios/web-scenarios.yaml": {
			"Zabbix Frontend",
			"Grafana Dashboard",
			"pfSense WebGUI",
		},
	}

	for path, fragments := range checks {
		content := readFile(t, path)
		for _, fragment := range fragments {
			if !strings.Contains(content, fragment) {
				t.Fatalf("%s missing fragment %q", path, fragment)
			}
		}
	}
}

func TestLinuxScriptsHaveSafeShellContract(t *testing.T) {
	scripts, err := filepath.Glob(filepath.FromSlash("scripts/linux/*.sh"))
	if err != nil {
		t.Fatal(err)
	}
	zabbixScripts, err := filepath.Glob(filepath.FromSlash("scripts/zabbix/*.sh"))
	if err != nil {
		t.Fatal(err)
	}
	scripts = append(scripts, zabbixScripts...)
	if len(scripts) == 0 {
		t.Fatal("no linux scripts found")
	}

	for _, path := range scripts {
		content := readFile(t, path)
		if !strings.HasPrefix(content, "#!/usr/bin/env bash") {
			t.Fatalf("script does not use env bash shebang: %s", path)
		}
		if !strings.Contains(content, "set -euo pipefail") {
			t.Fatalf("script does not enable strict mode: %s", path)
		}
	}
}

func readFile(t *testing.T, path string) string {
	t.Helper()
	content, err := os.ReadFile(filepath.FromSlash(path))
	if err != nil {
		t.Fatalf("failed to read %s: %v", path, err)
	}
	return string(content)
}
