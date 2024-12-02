{ lib, config, modulesPath, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.base-hardware-config;
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  options.base-hardware-config = {
    use-nvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to use NVIDIA graphics";
    };
  };
  config = {
    boot.initrd.availableKernelModules =
      [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/5e66a786-5dc1-4827-a80c-359d9665f880";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/ABA6-9797";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    swapDevices = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp2s0f0u7u3.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.nvidia.package = lib.mkIf cfg.use-nvidia config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
