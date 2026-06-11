package main

import (
	"os"
  "github.com/11notes/go-eleven"
)

const APP_BIN string = "/usr/sbin/kea-dhcp4"
const APP_CONFIG_ENV string = "KEA_CONFIG"
const APP_CONFIG string = "/kea/etc/main.conf"
const ROOT_SSL string = "/kea/run"

func main(){
	// setup SSL certificates
	_, err := eleven.Util.Run("/usr/local/bin/openssl", []string{"req", "-x509", "-newkey", "rsa:4096", "-sha256", "-days", "3650", "-nodes", "-keyout", ROOT_SSL + "/server.key", "-out", ROOT_SSL + "/server.crt", "-subj", "/CN=" + os.Getenv("HOSTNAME")}, []string{})
	if err != nil {
		eleven.LogFatal("openssl: %s", err.Error())
	}

	// start app
	eleven.Container.RunAbsolute(APP_BIN, []string{"-c", APP_CONFIG}, []string{})
}