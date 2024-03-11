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
    # Sweden
    bahnhof_se: "213.80.98.2",
    # US
    comodo_us: "8.26.56.26",
    # Colombia
    dinamic: "181.205.187.218",
    # Australia
    foxtel_net: "172.193.67.34",
    # Singapore
    singnet: "58.185.92.216",
    # US
    verisign_us: "64.6.64.6",
    # Taiwan
    hinet_tw: "168.95.1.1",
    # Canada
    securolytics_ca: "144.217.51.168",
    # Switzerland
    uunet_ch: "195.129.12.122",
    # Germany
    uunet_de: "192.76.144.66",
    # UK
    uunet_uk: "158.43.240.3",
    # US
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
      5500 -> IO.puts("Check complete.")
    end
  end

  def spawn(pid, domain) do
    @dns_servers
    |> Enum.each(fn {name, ip} ->
      spawn(fn ->
        try do
          task =
            Task.async(fn ->
              {result, _status} =
                System.cmd(
                  "dig",
                  ["+nocmd", "@#{ip}", "#{domain}", "+noall", "+answer"]
                )

              result
            end)

          result = Task.await(task, 5500)

          send(pid, {:ok, name, result})
        catch
          :exit, _ ->
            IO.puts(
              "DNS #{Atom.to_string(name) |> String.upcase() |> String.replace("_", " ")} failed to resolve fast enough."
            )
        end
      end)
    end)
  end
end

GlobalDig.start(self(), System.argv())
