use Mix.Config

config :logger,
  backends: [:console, RingLogger],
  level: :debug

config :detectino_panel, :viewport, %{
  name: :main_viewport,
  default_scene: {DetectinoPanel.Scene.Default, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Rpi
    },
    %{
      module: Scenic.Driver.Nerves.Touch,
      opts: [
        device: "FT5406 memory based driver",
        calibration: {{1, 0, 0}, {1, 0, 0}}
      ]
    }
  ]
}

# nerves network stuff
config :nerves_network,
  regulatory_domain: "IT"

config :nerves_network, :default,
  wlan0: [
    ssid: "YOUR-AP",
    psk: "greatpsk",
    key_mgmt: String.to_atom("WPA-PSK"),
    proto: :RSN,
    ipv4_address_method: :static,
    ipv4_address: "192.168.1.42",
    ipv4_subnet_mask: "255.255.255.0",
    # ipv4_gateway: "192.168.10.254",
    nameservers: ["192.168.1.1"]
  ]

# nerves ssh stuff
config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
  ]
