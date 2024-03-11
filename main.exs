#!/usr/bin/env elixir

domain = System.argv()

defmodule GlobalDig do
  @dns_servers %{
    cloudflare: "1.1.1.1",
    dyn: "216.146.35.35",
    freedns: "37.235.1.174",
    google: "8.8.8.8",
    level3: "209.244.0.3",
    open_dns: "208.67.222.222",
    safe_dns: "195.46.39.39",
    quad9: "9.9.9.9",
    bahnhof_se: "213.80.98.2", # Sweden
    comodo_us: "8.26.56.26", # US
    dinamic: "181.205.187.218", # Colombia
    foxtel_net: "172.193.67.34", # Australia
    singnet: "58.185.92.216", # Singapore
    verisign_us: "64.6.64.6", # US
    hinet_tw: "168.95.1.1", # Taiwan
    securolytics_ca: "144.217.51.168", # Canada
    uunet_ch: "195.129.12.122", # Switzerland
    uunet_de: "192.76.144.66", # Germany
    uunet_uk: "158.43.240.3", # UK
    uunet_us: "198.6.100.25" # US
  }

  def start(pid, domain) do
    spawn(pid, domain)
    wait()
  end

  def wait do
    receive do
      {:ok, name, result} ->
        IO.puts(
          "#{Atom.to_string(name) |> String.upcase() |> String.replace("_", " ")}: \n#{result}"
        )

        wait()
    after
      5000 -> IO.puts("")
    end
  end

  def spawn(pid, domain) do
    @dns_servers
    |> Enum.each(fn {name, ip} ->
      spawn(fn ->
        {result, _status} =
          System.cmd(
            "dig",
            ["+nocmd", "@#{ip}", "#{domain}", "+noall", "+answer"]
          )

        send(pid, {:ok, name, result})
      end)
    end)
  end
end

GlobalDig.start(self(), System.argv())
