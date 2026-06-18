package main

import (
	"encoding/json"
  "github.com/11notes/go-eleven"
)

type Request struct {
	Command string   `json:"command"`
	Service []string `json:"service"`
}

type Status []struct {
	Arguments struct {
		CsvLeaseFile string `json:"csv-lease-file"`
		DhcpState    struct {
			DisabledByDbConnection  []interface{} `json:"disabled-by-db-connection"`
			DisabledByLocalCommand  []interface{} `json:"disabled-by-local-command"`
			DisabledByRemoteCommand []interface{} `json:"disabled-by-remote-command"`
			DisabledByUser          bool          `json:"disabled-by-user"`
			GloballyDisabled        bool          `json:"globally-disabled"`
		} `json:"dhcp-state"`
		MultiThreadingEnabled bool      `json:"multi-threading-enabled"`
		PacketQueueSize       int       `json:"packet-queue-size"`
		PacketQueueStatistics []float64 `json:"packet-queue-statistics"`
		Pid                   int       `json:"pid"`
		Reload                int       `json:"reload"`
		Sockets               struct {
			Status string `json:"status"`
		} `json:"sockets"`
		ThreadPoolSize int `json:"thread-pool-size"`
		Uptime         int `json:"uptime"`
	} `json:"arguments"`
	Result int `json:"result"`
}

func main(){
	cmd := Request{Command:"status-get", Service:[]string{"dhcp4"}}
	request, err := eleven.HTTP.PostJson("https://127.0.0.1:8004/", cmd, true)
	if err != nil {
		eleven.LogFatal("eleven.HTTP.PostJson error: %s", err.Error())
	}
	var status Status
	err = json.Unmarshal(request, &status)
	if err != nil {
		eleven.LogFatal(err.Error())
	}
	if len(status) > 0 {
		if status[0].Arguments.Sockets.Status == "ready" {
			eleven.Log("INF", "status: %s", status[0].Arguments.Sockets.Status)
		}else{
			eleven.LogFatal("unhealthy status received: %s", status[0].Arguments.Sockets.Status)
		}
	}else{
		eleven.LogFatal("no health status received: %#v", status)
	}
}