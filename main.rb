#!/usr/bin/env ruby

module DigTheWorld
  module_function

  DNS_SERVERS = {
    bahnhof_se: "213.80.98.2",
    cloudflare: "1.1.1.1",
    comodo_us: "8.26.56.26",
    dyn: "216.146.35.35",
    freedns: "37.235.1.174",
    google: "8.8.8.8",
    level3: "209.244.0.3",
    open_dns: "208.67.222.222",
    safe_dns: "195.46.39.39",
    verisign_us: "64.6.64.6",
    yandex_ru: "77.88.8.88",
    hinet_tw: "168.95.1.1",
    quad9: "9.9.9.9",
    securolytics_ca: "144.217.51.168",
    uunet_ch: "195.129.12.122",
    uunet_de: "192.76.144.66",
    uunet_uk: "158.43.240.3",
    uunet_us: "198.6.100.25",
  }

  def call(domain)
    results = DNS_SERVERS.map do |name, ip|
      command = "dig @#{ip} #{domain}"
      result = `#{command} +noall +answer`.split("+cmd\n").last
      ["#{name.upcase.to_s.gsub('_', ' ')}: #{command}", result].join("\n")
    end.join("\n")

    puts results
  end
end

DigTheWorld.call(ARGV.first)
