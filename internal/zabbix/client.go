package zabbix

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type Client struct {
	URL        string
	HTTPClient *http.Client
}

type request struct {
	JSONRPC string      `json:"jsonrpc"`
	Method  string      `json:"method"`
	Params  interface{} `json:"params"`
	Auth    interface{} `json:"auth,omitempty"`
	ID      int         `json:"id"`
}

type response struct {
	Result json.RawMessage `json:"result"`
	Error  interface{}     `json:"error,omitempty"`
}

func NewClient(url string) *Client {
	return &Client{
		URL: url,
		HTTPClient: &http.Client{
			Timeout: 20 * time.Second,
		},
	}
}

func (c *Client) Login(username, password string) (string, error) {
	var token string
	err := c.call(request{
		JSONRPC: "2.0",
		Method:  "user.login",
		Params: map[string]string{
			"username": username,
			"password": password,
		},
		ID: 1,
	}, &token)
	return token, err
}

func (c *Client) CountHosts(auth string) (int, error) {
	return c.count(auth, "host.get", map[string]interface{}{
		"output":      []string{"hostid"},
		"countOutput": true,
	})
}

func (c *Client) CountOpenProblems(auth string) (int, error) {
	return c.count(auth, "trigger.get", map[string]interface{}{
		"output":      []string{"triggerid"},
		"filter":      map[string]int{"value": 1},
		"countOutput": true,
	})
}

func (c *Client) count(auth, method string, params map[string]interface{}) (int, error) {
	var raw string
	err := c.call(request{
		JSONRPC: "2.0",
		Method:  method,
		Params:  params,
		Auth:    auth,
		ID:      2,
	}, &raw)
	if err != nil {
		return 0, err
	}

	var count int
	if _, err := fmt.Sscanf(raw, "%d", &count); err != nil {
		return 0, fmt.Errorf("invalid count returned by %s: %q", method, raw)
	}
	return count, nil
}

func (c *Client) call(req request, result interface{}) error {
	body, err := json.Marshal(req)
	if err != nil {
		return err
	}

	httpReq, err := http.NewRequest(http.MethodPost, c.URL, bytes.NewReader(body))
	if err != nil {
		return err
	}
	httpReq.Header.Set("Content-Type", "application/json-rpc")

	resp, err := c.HTTPClient.Do(httpReq)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("zabbix API returned HTTP %d", resp.StatusCode)
	}

	var decoded response
	if err := json.NewDecoder(resp.Body).Decode(&decoded); err != nil {
		return err
	}
	if decoded.Error != nil {
		return fmt.Errorf("zabbix API error: %v", decoded.Error)
	}
	if len(decoded.Result) == 0 {
		return fmt.Errorf("zabbix API response has no result")
	}

	return json.Unmarshal(decoded.Result, result)
}
