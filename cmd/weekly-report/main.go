package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"labcontrolado/internal/zabbix"
)

func main() {
	zabbixURL := flag.String("zabbix-url", "", "Zabbix API URL")
	zabbixUser := flag.String("zabbix-user", "", "Zabbix username")
	zabbixPassword := flag.String("zabbix-password", "", "Zabbix password")
	outputDir := flag.String("output-dir", "", "Directory for generated reports")
	flag.Parse()

	if *zabbixURL == "" || *zabbixUser == "" || *zabbixPassword == "" || *outputDir == "" {
		fmt.Fprintln(os.Stderr, "missing required flags: --zabbix-url, --zabbix-user, --zabbix-password, --output-dir")
		os.Exit(2)
	}

	client := zabbix.NewClient(*zabbixURL)
	token, err := client.Login(*zabbixUser, *zabbixPassword)
	if err != nil {
		fmt.Fprintf(os.Stderr, "zabbix login failed: %v\n", err)
		os.Exit(1)
	}

	hosts, err := client.CountHosts(token)
	if err != nil {
		fmt.Fprintf(os.Stderr, "host summary failed: %v\n", err)
		os.Exit(1)
	}

	problems, err := client.CountOpenProblems(token)
	if err != nil {
		fmt.Fprintf(os.Stderr, "problem summary failed: %v\n", err)
		os.Exit(1)
	}

	path, err := writeReport(*outputDir, hosts, problems, time.Now())
	if err != nil {
		fmt.Fprintf(os.Stderr, "report write failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Report generated: %s\n", path)
}

func writeReport(outputDir string, hosts, problems int, now time.Time) (string, error) {
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return "", err
	}

	path := filepath.Join(outputDir, fmt.Sprintf("weekly_report_%s.md", now.Format("20060102_1504")))
	content := fmt.Sprintf(`# Weekly Monitoring Report

- Generated at: %s
- Total hosts in Zabbix: %d
- Open problems: %d

## Notes

- Review high severity triggers.
- Validate backup jobs and SSL expiration checks.
- Publish highlights to project README changelog.
`, now.Format("2006-01-02 15:04:05"), hosts, problems)

	return path, os.WriteFile(path, []byte(content), 0644)
}
