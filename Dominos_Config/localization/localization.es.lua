--[[ Translators: google = all lines need review ]] --
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("Dominos-Config", "esES") or AceLocale:NewLocale("Dominos-Config", "esMX")
if not L then return end

L.Scale = "Escala"
L.Opacity = "Opacidad"
L.FadedOpacity = "Opacidad desvanecida"
L.Visibility = "Visibilidad"
L.Spacing = "Espaciado"
L.SpacingHor = "Espaciado horizontal"
L.SpacingVer = "Espaciado vertical"
L.Padding = "Acolchado"
L.PaddingHor = "Acolchado horizontal"
L.PaddingVer = "Acolchado vertical"
L.Layout = "Disposición"
L.Columns = "Columnas"
L.Size = "Tamaño"
L.Modifiers = "Modificadores"
L.QuickPaging = "Paginación rápida"
L.Help = "Ayudar"
L.Harm = "Dañar"
L.Targeting = "Apuntar"
L.ShowStates = "Mostrar estados"
L.Set = "Establecer"
L.Save = "Salvar"
L.Copy = "Copiar"
L.Delete = "Eliminar"
L.Bar = "Barra %d"
L.RightClickUnit = "Right Click Target"
L.RCUPlayer = "Yo"
L.RCUFocus = "Enfoque"
L.RCUToT = "Objetivo de objetivo"
L.EnterName = "Ingrese el nombre"
L.PossessBar = "Acciones de posesión/vehículo"
L.Profiles = "Perfiles"
L.ProfilesPanelDesc = "Le permite gestionar los diseños guardados de Dominos"
L.SelfcastKey = "Clave autocast"
L.QuickMoveKey = "Tecla de movimiento rápido"
L.ShowMacroText = "Mostrar texto de macro"
L.ShowBindingText = "Show Binding Text"
L.ShowEmptyButtons = "Mostrar botones vacíos"
L.LockActionButtons = "Bloquear posiciones de botones de acción"
L.EnterBindingMode = "Bind Keys..."
L.EnterConfigMode = "Configurar barras..."
L.ActionBarSettings = "Configuración de la barra de acción %d"
L.BarSettings = "Configuración de la barra %s"
L.ShowTooltips = "Show Tooltips"
L.UseCastbar = "Cast bar (Requiere UI Reload)"
L.UseMinimap = "Minimapa (Requires UI Reload)"
L.UseAuras = "Mejoras y desventajas (Requires UI Reload)"
L.UseQuest = "Rastreador de objetivos (Requires UI Reload)"
L.ATotemBar = "Barra de tótems predeterminada"
L.ReloadUI = "Recargar UI"
L.OneBag = "Una sola bolsa"
L.ShowKeyring = "Mostrar Llavero"
L.StickyBars = "barras adhesivas"
L.ShowMinimapButton = "Mostrar el botón del minimapa"
L.Advanced = "Avanzado"
L.LeftToRight = "Diseño de botones de izquierda a derecha"
L.TopToBottom = "Botones de diseño de arriba a abajo"
L.LinkedOpacity = "Las barras ancladas heredan la opacidad"
L.ALT_KEY_TEXT = "ALT"
L.AltShift = "ALT-" .. SHIFT_KEY_TEXT
L.CtrlShift = CTRL_KEY_TEXT .. "-" .. SHIFT_KEY_TEXT
L.CtrlAlt = CTRL_KEY_TEXT .. "-ALT"
L.CtrlAltShift = CTRL_KEY_TEXT .. "-ALT-" .. SHIFT_KEY_TEXT
--totems
L.ShowTotems = "Mostrar tótems"
L.ShowTotemRecall = "Mostrar Retiro"