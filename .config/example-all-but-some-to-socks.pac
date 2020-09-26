function FindProxyForURL(url, host) {
    host = host.toLowerCase();

    var proxyConfig = "SOCKS5 127.0.0.1:9050";

    var useDirect = [
"firefox.com",
"mozilla.com",
"mozilla.org",
"mozilla.net"
    ];
    for (var i = 0; i < useDirect.length; i++) {
        if (dnsDomainIs(host, useDirect[i])) {
            return "DIRECT";
        }
    }

    return proxyConfig;
}
