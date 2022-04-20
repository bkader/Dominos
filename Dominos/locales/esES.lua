--[[ Translators: google = all lines need review ]] --
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("Dominos", "esES") or AceLocale:NewLocale("Dominos", "esMX")
if not L then return end
--system messages
L.NewPlayer = "Nuevo perfil creado para: %s"
L.Updated = "Actualizado a v%s"
--profiles
L.ProfileCreated = 'Creado nuevo perfil "%s"'
L.ProfileLoaded = 'Establecer perfil en "%s"'
L.ProfileDeleted = 'Perfil eliminado: "%s"'
L.ProfileCopied = 'Ajustes copiados de "%s"'
L.ProfileReset = 'Reiniciar perfil "%s"'
L.CantDeleteCurrentProfile = "No se puede eliminar el perfil actual"
L.InvalidProfile = 'Perfil inválido "%s"'
--slash command help
L.ShowOptionsDesc = "Muestra el menú de opciones."
L.ConfigDesc = "Alterna el modo de configuración"
L.SetScaleDesc = "Establece la escala de <frameList>"
L.SetAlphaDesc = "Establece la opacidad de <frameList>"
L.SetFadeDesc = "Establece la opacidad difuminada de <frameList>"
L.SetColsDesc = "Establece el número de columnas para <frameList>"
L.SetPadDesc = "Establece el relleno para <frameList>"
L.SetSpacingDesc = "Establece el espacio para <frameList>"
L.ShowFramesDesc = "Muestra <frameList>"
L.HideFramesDesc = "Oculta <frameList>"
L.ToggleFramesDesc = "Alterna <frameList>"
--slash commands for profiles
L.SetDesc = "Cambia los ajustes a <profile>"
L.SaveDesc = "Guarda los ajustes actuales y cambia a <profile>"
L.CopyDesc = "Copia los ajustes de <profile>"
L.DeleteDesc = "Elimina <profile>"
L.ResetDesc = "Vuelve a la configuración por defecto"
L.ListDesc = "Enumera todos los perfiles."
L.AvailableProfiles = "Perfiles Disponibles"
L.PrintVersionDesc = "Imprime la versión actual"
--dragFrame tooltips
L.ShowConfig = "<Clic derecho> para configurar"
L.HideBar = "<Clic central o Shift-clic derecho> para ocultar"
L.ShowBar = "<Clic central o Shift-clic derecho> para mostrar"
L.SetAlpha = "<Rueda del ratón> para establecer la opacidad (|cffffffff%d|r)"
--minimap button stuff
L.ConfigEnterTip = "<Clic izquierdo> para entrar en el modo de configuración"
L.ConfigExitTip = "<Clic izquierdo> para salir del modo de configuración"
L.BindingEnterTip = "<Shift Left Click> to enter binding mode" -- needs localization
L.BindingExitTip = "<Shift Left Click> to exit binding mode" -- needs localization
L.ShowOptionsTip = "<Clic derecho> para mostrar el menú de opciones"
--helper dialog stuff
L.ConfigMode = "Modo de configuración"
L.ConfigModeExit = "Salir del modo de configuración"
L.ConfigModeHelp = "<Arrastre> cualquier barra para moverla. <Clic derecho> para configurar. <Clic central> o <Shift-Click derecho> para alternar la visibilidad"
L.ConfigModeHelp = [[<Arrastre> cualquier barra para moverla.
<Clic derecho> para configurar.
<Clic central> o <Shift-Click derecho> para alternar la visibilidad.]]
--bar tooltips
L.TipRollBar = "Muestra marcos para rodar sobre elementos, cuando está en un grupo."
L.TipVehicleBar = [[
Muestra controles para apuntar y salir de un vehículo.
Todas las otras acciones del vehículo se muestran en la barra de posesión.]]
--xp bar
L.Texture = "Textura"
L.Width = "Ancho"
L.Height = "Altura"
L.AlwaysShowText = "Siempre mostrar texto"
L.AlwaysShowXP = "Siempre mostrar XP"
-- objectives tracker
L.QuestTracker = "Rastreador de objetivos"
L.QuestLClick1 = "<Clic izquierdo> para expandir el rastreador de objetivos."
L.QuestLClick2 = "<Clic izquierdo> para minimizar el rastreador de objetivos."
L.QuestRClick = "<Clic derecho> para alternar el registro de misiones."
L.QuestSClick = "Shift-clic para alternar la ventana de logros."
-- cast bar
L.ShowTime = "Mostrar tiempo"