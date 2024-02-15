#!/usr/bin/env elixir

domain = System.argv()

defmodule GlobalDig do
  @dns_servers %{
    bahnhof_se: "213.80.98.2",
    cloudflare: "1.1.1.1",
    comodo_us: "8.26.56.26",
    dyn: "216.146.35.35",
    freedns: "37.235.1.174",
    foxtel_net: "172.193.67.34",
    google: "8.8.8.8",
    level3: "209.244.0.3",
    open_dns: "208.67.222.222",
    safe_dns: "195.46.39.39",
    verisign_us: "64.6.64.6",
    hinet_tw: "168.95.1.1",
    quad9: "9.9.9.9",
    securolytics_ca: "144.217.51.168",
    uunet_ch: "195.129.12.122",
    uunet_de: "192.76.144.66",
    uunet_uk: "158.43.240.3",
    uunet_us: "198.6.100.25"
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
