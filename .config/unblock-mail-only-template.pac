function FindProxyForURL(url, host) {
    host = host.toLowerCase();

    var unblockingProxy = "SOCKS5 127.0.0.1:9050";

    var domainsToUnblock = [
        "smtp.server.to.unblock",
        "imap.server.to.unblock",
        "pop.server.to.unblock"
    ];
    for (var i = 0; i < domainsToUnblock.length; i++) {
        if (dnsDomainIs(host, domainsToUnblock[i])) {
            return unblockingProxy;
        }
    }

    return "DIRECT";
}
