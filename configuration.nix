{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ### ===== ЗАГРУЗКА И ЯДРО =====
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
    extraConfig = "";
  };
  boot.loader.timeout = 5;
  boot.kernelParams = [ "splash" "amdgpu.ppfeaturemask=0xffffffff" ];
#  boot.kernelPackages = pkgs.linuxPackages_zen;
#  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_lqx;

  ### ===== СЕТЬ =====
  networking.hostName = "dalenix-pc";
  networking.networkmanager.enable = true;
  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 3080 22 ]; # 3080 для GNS3, 22 для SSH (если необходимо)
    allowedUDPPorts = [ 69 ]; # 69 для TFTP, если используется в GNS3
    allowedTCPPortRanges = [
    { from = 10000; to = 20000; } # Диапазон портов для динамических подключений GNS3
  ];
    allowPing = true; # Разрешить ICMP (ping)
  };

  ### ===== ВРЕМЯ И ЛОКАЛИЗАЦИЯ =====
  time.timeZone = "Europe/Kaliningrad";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT    = "ru_RU.UTF-8";
    LC_MONETARY       = "ru_RU.UTF-8";
    LC_NAME           = "ru_RU.UTF-8";
    LC_NUMERIC        = "ru_RU.UTF-8";
    LC_PAPER          = "ru_RU.UTF-8";
    LC_TELEPHONE      = "ru_RU.UTF-8";
    LC_TIME           = "ru_RU.UTF-8";
  };

  ### ===== ГРАФИКА И ВИДЕО =====
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ### ===== ДИСПЛЕЙ И РАБОЧЕЕ ОКРУЖЕНИЕ =====
  
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  ### ===== АУДИО =====
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ### ===== ПЕЧАТЬ =====
  services.printing.enable = false;

  ### ===== ПОЛЬЗОВАТЕЛИ =====
  users.users.dalenix = {
    isNormalUser = true;
    description = "dalenix";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "wireshark" ];
    packages = with pkgs; [

      # --- Редакторы и офис ---
      kdePackages.kate
      thunderbird
      onlyoffice-desktopeditors
      libreoffice

      # --- Сетевые инструменты и виртуализация ---
      gns3-gui

    ];
  };

  ### ===== СИСТЕМНЫЕ ПАКЕТЫ =====
  environment.systemPackages = with pkgs; [

    # --- Базовые утилиты ---
    vim
    wget
    git
    fastfetch
    micro

    # --- Графика и окружение ---
    mesa
    gparted
    gnome-disk-utility
    telegram-desktop
    xorg.libxcvt
    corectrl
    upscayl

    # --- VPN и сеть ---
    nekoray
    sing-geoip
    sing-geosite

    # --- Игры и гейминг ---
    protonplus
    dxvk
    lutris
    mangohud

    # --- Разработка ---
    meson
    libgpg-error
    libxml2
    nodejs_23
    zed-editor
    freetype
    gnutls
    openldap
    SDL2
    sqlite
    xml2
    zulu17
    zulu
    virt-manager
    qemu_full

    # --- Утилиты и оформление ---
    flatpak
    uwufetch
    pfetch
    iucode-tool
    glxinfo

    # --- Виртуализация и сети ---
    gns3-server

    # --- Настройки и GUI ---
    kdePackages.sddm-kcm

    # --- 32-битная поддержка ---
    pkgsi686Linux.gperftools
  ];

  ### ===== ШРИФТЫ =====
  fonts.packages = with pkgs; [
    corefonts
    vistafonts
  ];

  ### ===== ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ =====
  environment.variables = rec {
    GPERF32_PATH = "${pkgs.pkgsi686Linux.gperftools}";
  };

  ### ===== STEAM И ИГРЫ =====
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraPackages = [ pkgs.curl ];
  };

  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
    
  ### ===== УПРАВЛЕНИЕ GPU =====
  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  ### ===== ОПТИМИЗАЦИЯ И ПРОИЗВОДИТЕЛЬНОСТЬ =====
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  services.irqbalance.enable = true;

  ### ===== МИКРОКОД ЦПУ =====
  hardware.cpu.intel.updateMicrocode = true;

  ### ===== ТОЧКИ МОНТИРОВАНИЯ =====
  fileSystems."/mnt/sda1" = {
    device = "/dev/disk/by-uuid/50c80e30-f53e-4e4c-b6d7-abefb6222d4b";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  ### ===== FLATPAK =====
  services.flatpak.enable = true;

  ### ===== БРАУЗЕР =====
  programs.firefox.enable = true;

  ### ===== ПРОПРИЕТАРНОЕ ПО =====
  nixpkgs.config.allowUnfree = true;

  ### ===== ВЕРСИЯ СОСТОЯНИЯ СИСТЕМЫ =====
  system.stateVersion = "24.11";

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "dalenix" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = false;
  virtualisation.virtualbox.guest.dragAndDrop = false;

  ### ===== БЕЗОПАСНОСТЬ  =====
  security.sudo.enable = true;

  # Включаем службу libvirtd
  virtualisation.libvirtd.enable = true;

  # Загружаем модули ядра для поддержки виртуализации
  boot.kernelModules = [ "kvm-intel" ];

  # Включаем поддержку Wireshark
  programs.wireshark.enable = true;
}
