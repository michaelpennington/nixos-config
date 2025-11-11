# ./vfio.nix
{
  config,
  pkgs,
  ...
}: {
  # 1. Enable IOMMU in the Kernel
  # Change to "intel_iommu=on" if you have an Intel CPU
  boot.kernelParams = ["amd_iommu=on" "iommu=pt" "vfio-pci.ids=1002:73bf"];

  # 2. Load VFIO modules early in the boot process
  boot.initrd.availableKernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];
  boot.kernelModules = ["vfio_pci"];

  # 3. Tell VFIO to "grab" your guest GPU before the host drivers do.
  #    Replace the IDs here with the ones you found in Step 1.

  # 4. (Optional but Recommended) Blacklist host drivers
  #    This prevents NixOS from trying to use the guest GPU.
  # boot.blacklistedKernelModules = ["nvidia" "nouveau" "amdgpu"];

  # 5. Enable Libvirt & QEMU
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      enable = true;
      # Enable UEFI (OVMF) support for the VM
      ovmf.enable = true;
      ovmf.packages = [pkgs.OVMFFull.fd];
      # Allow QEMU to access USB devices, etc.
      runAsRoot = true;
    };
  };

  # 6. Add your user to the 'libvirtd' group
  users.users.mpennington.extraGroups = ["libvirtd"];

  # 7. Install virt-manager (the GUI for managing VMs)
  environment.systemPackages = with pkgs; [
    virt-manager
    # VirtIO drivers for Windows
    virtio-win
  ];
}
