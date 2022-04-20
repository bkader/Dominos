-- à = \195\160
-- â = \195\162
-- ç = \195\167
-- è = \195\168
-- é = \195\169
-- ê = \195\170
-- î = \195\174
-- ï = \195\175
-- ô = \195\180
-- û = \195\187
local L = LibStub("AceLocale-3.0"):NewLocale("Dominos", "frFR")
if not L then return end
--system messages
L.NewPlayer = "Nouveau profil cr\195\169\195\169 pour %s"
L.Updated = "Mise \195\160 jour de v%s"
--profiles
L.ProfileCreated = 'Cr\195\169ation nouveau profil "%s"'
L.ProfileLoaded = 'Charger profil "%s"'
L.ProfileDeleted = 'Effacer profil "%s"'
L.ProfileCopied = 'R\195\169glages copi\195\169s de "%s"'
L.ProfileReset = 'R\195\169initialisation profil "%s"'
L.CantDeleteCurrentProfile = "Le profil courant ne peut \195\170tre effac\195\169"
L.InvalidProfile = 'Profile invalide "%s"'
--slash command help
L.ShowOptionsDesc = "Afficher le menu options"
L.ConfigDesc = "Basculer en mode configuration"
L.SetScaleDesc = "Fixe l'\195\169chelle de <frameList>"
L.SetAlphaDesc = "Fixe l'opacit\195\169 de <frameList>"
L.SetFadeDesc = "Fixe l'opacit\195\169 att\195\169nu\195\169e de <frameList>"
L.SetColsDesc = "Fixe le nombre de colonnes pour <frameList>"
L.SetPadDesc = "Fixe le niveau de remplissage de <frameList>"
L.SetSpacingDesc = "Fixe l'espacement de <frameList>"
L.ShowFramesDesc = "Montre la <frameList>"
L.HideFramesDesc = "Cache la <frameList>"
L.ToggleFramesDesc = "Bascule entre <frameList>"
--slash commands for profiles
L.SetDesc = "R\195\169glages activ\195\169s : <profile>"
L.SaveDesc = "R\195\169glages enregistr\195\169s et bascule sur <profile>"
L.CopyDesc = "Copie des r\195\169glages de <profile>"
L.DeleteDesc = "Effacer <profile>"
L.ResetDesc = "Retourn aux r\195\169glages par d\195\169faut"
L.ListDesc = "Liste des profils"
L.AvailableProfiles = "Profils disponibles"
L.PrintVersionDesc = "Afficher la version"
--dragFrame tooltips
L.ShowConfig = "<Clic droit> pour configurer"
L.HideBar = "<Clic milieu ou MAJ-Clic droit> pour cacher"
L.ShowBar = "<Clic milieu ou MAJ-Clic droit> pour montrer"
L.SetAlpha = "<Roue de souris> pour r\195\169gler l'opacit\195\169 (|cffffffff%d|r)"
--minimap button stuff
L.ConfigEnterTip = "<Clic gauche> mode configuration"
L.ConfigExitTip = "<Clic gauche> sortir du mode configuration"
L.BindingEnterTip = "<MAJ clic gauche> configurer les raccourcis"
L.BindingExitTip = "<MAJ clic gauche> arr\195\170ter la config. des raccourcis"
L.ShowOptionsTip = "<Clic droit> afficher le menu d'options"
--helper dialog stuff
L.ConfigMode = "Mode Configuration"
L.ConfigModeExit = "Sortir du Mode Config."
L.ConfigModeHelp = [[<Clic-drag> déplace la barre.
<Clic droit> configurer.
<Clic milieu> ou <MAJ-Clic droit> visible/invisible.]]
--bar tooltips
L.TipRollBar = "Affiche le cadre des objets tir\195\169s au sort, lorsqu'on est en groupe."
L.TipVehicleBar = [[
Affiche les contrôles de visée et de sortie du véhicule.
Toutes les autres actions sont sur la barre de contrôle du véhicule.]]
--xp bar
L.Texture = "Texture"
L.Width = "Largeur"
L.Height = "Hauteur"
L.AlwaysShowText = "Toujours afficher le texte"
L.AlwaysShowXP = "Toujours afficher l'XP"
-- objectives tracker
L.QuestTracker = "Suivi des objectifs"
L.QuestLClick1 = "Clic gauche pour agrandir le suivi des objectifs."
L.QuestLClick2 = "Clic gauche pour r\195\169duire le suivi des objectifs."
L.QuestRClick = "Clic droit pour afficher/cacher le journal de qu\195\170tes."
L.QuestSClick = "MAJ-clic pour afficher/cacher la fenêtre des hauts faits."
--cast bar
L.ShowTime = "Montrer le temps"