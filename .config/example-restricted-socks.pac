function FindProxyForURL(url, host) {
    host = host.toLowerCase();

    var proxyConfig = "SOCKS5 127.0.0.1:7060";

    var blackHole = "SOCKS5 127.0.0.1:51";

    var allowedDomains = [
"googlevideo.com",
"ytimg.com",
"ggpht.com",
"youtube.com",
"gstatic.com",
"googleusercontent.com",
"googleapis.com",
"example.com",
"firefox.com",
"mozilla.com",
"mozilla.org",
"mozilla.net"
    ];
    for (var i = 0; i < allowedDomains.length; i++) {
        if (dnsDomainIs(host, allowedDomains[i])) {
            return proxyConfig;
        }
    }

    return blackHole;
}
