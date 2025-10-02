# Lazy Neovim Config

A **minimal-but-mighty Neovim setup powered by [lazy.nvim]**.  
Everything lives in small, composable Lua files so you can start hacking right away instead of fighting an enormous “dot-files monolith”.

> **TL;DR**  
> 1. `git clone https://github.com/ArcheryLuna/lazy-neovim-config ~/.config/nvim`  
> 2. `nvim` → lazy.nvim bootstraps itself and installs the plugins.  
> 3. Profit 🎉

---

## ✨  Highlights

| What | How it’s done |
|------|---------------|
| **Zero-to-Neovim in one command** | [`init.lua`](./init.lua) only calls `require("config")` – the rest is pure Lua modules. :contentReference[oaicite:0]{index=0} |
| **Lazy-loaded plugin manager** | Automatic bootstrap & update logic for *lazy.nvim* lives in [`lua/config/lazy.lua`](./lua/config/lazy.lua). :contentReference[oaicite:1]{index=1} |
| **Sensible defaults** | Relative numbers, 4-space soft tabs, swap/backup disabled, 24-bit colours & transparent background. :contentReference[oaicite:2]{index=2} |
| **Treesitter everywhere** | `nvim-treesitter` with a wide language set (TS, JS, C, Go, Python, HTML, CSS, …) and `:TSUpdate` auto-build. :contentReference[oaicite:3]{index=3} |
| **Ergonomic key-maps** | Space is **leader**, ‟\\” is **local leader**; best-of-breed editing tricks (move blocks with `J/K`, keep cursor centred on search, clipboard-friendly paste, etc.). :contentReference[oaicite:4]{index=4} |

*(Open the linked Lua files to see the exact code.)*  

---

## ⚙️  Requirements

* **Neovim ≥ 0.9** (built with LuaJIT)  
* **Git ≥ 2.19** (needed for `--filter=blob:none` shallow clone)  
* Optional: a [Nerd Font](https://www.nerdfonts.com) for pretty icons

---

## 🚀  Installation

```bash
# 1. back-up any existing config
mv ~/.config/nvim{,.bak-$(date +%Y%m%d)}

# 2. clone this repo
git clone https://github.com/ArcheryLuna/lazy-neovim-config ~/.config/nvim

# 3. launch Neovim
nvim

