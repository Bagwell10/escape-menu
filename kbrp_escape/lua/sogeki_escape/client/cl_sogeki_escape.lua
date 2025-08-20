-- SRP Escape Menu — Style Arma 3 (Rouge épuré, texte centré)

-----------------------------
-- Palette & libellés
-----------------------------
local THEME = {
    accent    = Color(117, 23, 0),   -- rouge principal
    danger    = Color(255, 64, 64),   -- déconnexion
    bg_dim    = Color(6, 6, 8, 220),  -- voile sombre
    card      = Color(14, 16, 20, 245),
    header    = Color(18, 20, 26, 255),
    inner     = Color(20, 22, 28, 255),
    text      = Color(255, 255, 255),
    text_dim  = Color(255, 255, 255, 160),
    line      = Color(255, 255, 255, 22),
}

local TITLE        = "KB PROJECT"
local SUBTITLE     = "Menu principal"
local FOOTER_LEFT  = "Appuyez sur Échap pour reprendre"
local FOOTER_RIGHT = "Version 1.0"

-----------------------------
-- Sizing & fonts
-----------------------------
local x, y = ScrW(), ScrH()
local function mkFonts()
    surface.CreateFont("SRP_TitleFont", {
        font = "Lemon Milk",
        size = math.max(22, math.Round(y * 0.048)),
        weight = 800, antialias = true
    })
    surface.CreateFont("SRP_SubTitleFont", {
        font = "Lemon Milk",
        size = math.max(14, math.Round(y * 0.020)),
        weight = 600, antialias = true
    })
    surface.CreateFont("SRP_ButtonFont", {
        font = "Lemon Milk",
        size = math.max(16, math.Round(y * 0.030)), -- texte des boutons un peu plus gros
        weight = 700, antialias = true
    })
    surface.CreateFont("SRP_FooterFont", {
        font = "Lemon Milk",
        size = math.max(12, math.Round(y * 0.016)),
        weight = 500, antialias = true
    })
end
mkFonts()
hook.Add("OnScreenSizeChanged", "SRP_EscapeResize", function()
    x, y = ScrW(), ScrH()
    mkFonts()
end)

-----------------------------
-- Utils
-----------------------------
local blurMat = Material("pp/blurscreen")
local menu, isOpen, escReleased, openTime = nil, false, true, 0

local function DrawBlur(x0, y0, w, h, layers, density)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blurMat)
    for i = 1, density do
        blurMat:SetFloat("$blur", (i / 3) * (layers or 4))
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        render.SetScissorRect(x0, y0, x0 + w, y0 + h, true)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

local function Outline(x0, y0, w, h, col)
    surface.SetDrawColor(col or THEME.line)
    surface.DrawOutlinedRect(x0, y0, w, h, 1)
end

local function CloseMenu()
    if IsValid(menu) then
        menu:AlphaTo(0, 0.15, 0, function() if IsValid(menu) then menu:Remove() end end)
    end
    gui.EnableScreenClicker(false)
    isOpen = false
end

-----------------------------
-- Bouton centré
-----------------------------
local function CreateA3Button(parent, label, index, total, callback, isDanger)
    local listW = math.floor(x * 0.28)
    local cardW = math.floor(x * 0.62)
    local cardH = math.floor(y * 0.62)
    local cardX = math.floor((x - cardW) / 2)
    local cardY = math.floor((y - cardH) / 2)

    local headerH = math.floor(cardH * 0.22)
    local listX = cardX + math.floor(cardW * 0.06)
    local listY = cardY + headerH + math.floor(cardH * 0.05)

    local btnH = math.floor((cardH * 0.56) / total) - 8

    local btn = vgui.Create("DButton", parent)
    btn:SetSize(listW, btnH)
    btn:SetPos(listX, listY + (index - 1) * (btnH + 8))
    btn:SetText("")
    btn:SetCursor("hand")

    local hover = 0
    local activeColor = isDanger and THEME.danger or THEME.accent

    btn.Paint = function(self, w, h)
        hover = Lerp(FrameTime() * 10, hover, self:IsHovered() and 1 or 0)

        -- fond
        draw.RoundedBox(8, 0, 0, w, h, THEME.inner)

        -- barre gauche
        local bw = math.floor(w * 0.012)
        surface.SetDrawColor(activeColor.r, activeColor.g, activeColor.b, 120 + 120 * hover)
        surface.DrawRect(0, 0, bw, h)

        -- texte centré
        draw.SimpleText(label, "SRP_ButtonFont", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        Outline(0, 0, w, h)
    end

    btn.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        if callback then callback() end
    end
end

-----------------------------
-- Ouverture UI
-----------------------------
local function OpenMenu()
    if IsValid(menu) then return end

    menu = vgui.Create("DFrame")
    menu:SetSize(x, y)
    menu:SetPos(0, 0)
    menu:SetTitle("")
    menu:ShowCloseButton(false)
    menu:MakePopup()
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.2, 0)
    gui.EnableScreenClicker(true)
    isOpen = true

    local cardW, cardH = math.floor(x * 0.62), math.floor(y * 0.62)
    local cardX, cardY = math.floor((x - cardW) / 2), math.floor((y - cardH) / 2)

    menu.Paint = function(self, w, h)
        DrawBlur(0, 0, w, h, 2, 5)
        surface.SetDrawColor(THEME.bg_dim)
        surface.DrawRect(0, 0, w, h)

        -- Bandeau haut (avec ligne rouge)
        local topH = math.floor(y * 0.10)
        surface.SetDrawColor(THEME.header)
        surface.DrawRect(0, 0, w, topH)
        surface.SetDrawColor(THEME.accent)
        surface.DrawRect(0, topH - 2, w, 2)

        local cfgTitle = (istable(SogekiConfigurationEscape) and SogekiConfigurationEscape.Titre) or TITLE
        draw.SimpleText(cfgTitle, "SRP_TitleFont", math.floor(w * 0.03), topH * 0.55, THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(SUBTITLE, "SRP_SubTitleFont", math.floor(w * 0.03) + 2, topH * 0.85, THEME.text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Carte
        draw.RoundedBox(16, cardX, cardY, cardW, cardH, THEME.card)
        Outline(cardX, cardY, cardW, cardH)

        -- Header de la carte (sans barre rouge décorative)
        local headerH = math.floor(cardH * 0.22)
        surface.SetDrawColor(THEME.header)
        surface.DrawRect(cardX, cardY, cardW, headerH)

        draw.SimpleText(cfgTitle, "SRP_TitleFont", cardX + 26, cardY + headerH * 0.50, THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(SUBTITLE, "SRP_SubTitleFont", cardX + 28, cardY + headerH * 0.82, THEME.text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Footer
        local footH = math.floor(y * 0.05)
        surface.SetDrawColor(THEME.header)
        surface.DrawRect(0, h - footH, w, footH)
        draw.SimpleText(FOOTER_LEFT, "SRP_FooterFont", math.floor(w * 0.02), h - footH * 0.52, THEME.text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(FOOTER_RIGHT, "SRP_FooterFont", w - math.floor(w * 0.02), h - footH * 0.52, THEME.text_dim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Boutons (3)
    local txtResume  = (istable(SogekiConfigurationEscape) and SogekiConfigurationEscape.TexteReprendre) or "Reprendre"
    local txtOptions = (istable(SogekiConfigurationEscape) and SogekiConfigurationEscape.TexteParametre) or "Paramètres"
    local txtQuit    = (istable(SogekiConfigurationEscape) and SogekiConfigurationEscape.TexteAdieuBB) or "Se déconnecter"

    local totalButtons = 3

    CreateA3Button(menu, txtResume,  1, totalButtons, function() CloseMenu() end)
    CreateA3Button(menu, txtOptions, 2, totalButtons, function()
        RunConsoleCommand("gamemenucommand", "openoptionsdialog")
        timer.Simple(0, function() RunConsoleCommand("gameui_activate") end)
        CloseMenu()
    end)
    CreateA3Button(menu, txtQuit,    3, totalButtons, function()
        RunConsoleCommand("disconnect")
    end, true)
end

-----------------------------
-- Gestion ESC
-----------------------------
hook.Add("PreRender", "SRP_Escape_Open", function()
    if gui.IsGameUIVisible() then
        if not isOpen and input.IsKeyDown(KEY_ESCAPE) then
            isOpen = true
            openTime = CurTime()
            gui.HideGameUI()
            OpenMenu()
        elseif isOpen then
            gui.HideGameUI()
        end
    end
end)

hook.Add("Think", "SRP_Escape_Close", function()
    if isOpen and input.IsKeyDown(KEY_ESCAPE) and escReleased and CurTime() - openTime > 0.3 then
        escReleased = false
        CloseMenu()
    elseif not input.IsKeyDown(KEY_ESCAPE) then
        escReleased = true
    end
end)
