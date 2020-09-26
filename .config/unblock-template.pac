function FindProxyForURL(url, host) {
    host = host.toLowerCase();

    var unblockingProxy = "SOCKS5 127.0.0.1:9050";

    var domainsToUnblock = [
"domain.to.unblock",
"anotherdomain.to.unblock"
    ];
    for (var i = 0; i < domainsToUnblock.length; i++) {
        if (dnsDomainIs(host, domainsToUnblock[i])) {
            return unblockingProxy;
        }
    }

    return "DIRECT";
}
