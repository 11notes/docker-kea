package main

import (
	"os"
  "github.com/11notes/go-eleven"
)

const APP_BIN string = "/usr/sbin/kea-dhcp4"
const APP_CONFIG string = "/kea/etc/main.conf"
const APP_CONFIG_ENV string = "KEA_CONFIG"
const APP_CONFIG_SUBNETS string = "/kea/etc/subnets.conf"
const APP_CONFIG_SUBNETS_ENV string = "KEA_SUBNETS_CONFIG"
const APP_CONFIG_SSL_ROOT string = "/kea/run"

func main(){
	// setup SSL certificates if not present
	if _, err := os.Stat(APP_CONFIG_SSL_ROOT + "/server.key"); os.IsNotExist(err) {
		_, err := eleven.Util.Run("/usr/local/bin/openssl", []string{"req", "-x509", "-newkey", "rsa:4096", "-sha256", "-days", "3650", "-nodes", "-keyout", APP_CONFIG_SSL_ROOT + "/server.key", "-out", APP_CONFIG_SSL_ROOT + "/server.crt", "-subj", "/CN=" + os.Getenv("HOSTNAME")}, []string{})
		if err != nil {
			eleven.LogFatal("openssl: %s", err.Error())
		}else{
			eleven.Log("INF", "self-signed SSL certificate generated at %s", APP_CONFIG_SSL_ROOT)
		}
	}

	// write env to file if set
	eleven.Container.EnvToFile(APP_CONFIG_ENV, APP_CONFIG)
	eleven.Container.EnvToFile(APP_CONFIG_SUBNETS_ENV, APP_CONFIG_SUBNETS)

	// start app
	eleven.Container.RunAbsolute(APP_BIN, []string{"-c", APP_CONFIG}, []string{})
}