rule = {
    matches = {
        {
            { "node.name", "matches", "alsa_output.pci-*" },
        },
        {
            { "node.name", "matches", "alsa_output.usb-NVidia-*" },
        },
    },
    apply_properties = {
        ["device.disabled"] = true
    }
}

table.insert(alsa_monitor.rules, rule)