#!/bin/bash
set -e

echo "Updating packages..."
sudo apt update

echo "Installing packages..."
sudo apt install -y \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-goodies \
    dbus-x11

echo "Creating VNC configuration..."
mkdir -p ~/.vnc

cat > ~/.vnc/xstartup <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF

chmod +x ~/.vnc/xstartup

echo "Set your VNC password..."
vncpasswd

echo "Configuring TigerVNC..."
echo ":1=$USER" | sudo tee /etc/tigervnc/vncserver.users >/dev/null

# Raspberry Pi OS Trixie / TigerVNC 1.14 uses Perl syntax here.
sudo tee /etc/tigervnc/vncserver-config-defaults >/dev/null <<'EOF'
$localhost = "no";
EOF

echo "Enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable --now tigervncserver@:1.service

mkdir -p ~/.local/share/applications
cp /var/lib/flatpak/exports/share/applications/com.orcaslicer.OrcaSlicer.desktop ~/.local/share/applications/
sed -i 's|^Exec=/usr/bin/flatpak run|Exec=env MESA_GL_VERSION_OVERRIDE=3.2 /usr/bin/flatpak run|' ~/.local/share/applications/com.orcaslicer.OrcaSlicer.desktop
update-desktop-database ~/.local/share/applications

echo
echo "Done."

IP=$(hostname -I | awk '{print $1}')
echo "Connect to:"
echo "${IP}:5901"

echo
echo "Verifying listener..."
sleep 2
ss -tulpn | grep 5901 || {
    echo "ERROR: VNC server did not start."
    echo "Check with:"
    echo "  sudo systemctl status tigervncserver@:1.service"
    echo "  cat ~/.vnc/*.log"
    exit 1
}
