#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Installation de FireFox
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.mozilla.firefox
sudo flatpak override org.mozilla.firefox --filesystem=home

# Installation de CNIL Cookies List
wget "$COOKIES_LIST_URL" -O "$CTRL_HOME/$COOKIES_LIST_NAME"
flatpak run "org.mozilla.firefox" "$CTRL_HOME/$COOKIES_LIST_NAME"

# Récupération du chemin vers le profil FireFox
CTRL_MOZ_HOME="$CTRL_HOME/.mozilla/firefox"
PROFILE_NAME=$(cat "$CTRL_MOZ_HOME/profiles.ini" | grep Path= | grep release | sed "s/Path=//")
CTRL_MOZ_PROFILE="$CTRL_MOZ_HOME/$PROFILE_NAME"

# Modification des moteurs de recherche
cp "$SCRIPTS_ROOT/cnf/search.json.mozlz4" "$CTRL_MOZ_PROFILE/search.json.mozlz4"

# Configuration des paramètres
# Le fichier user.js n'existe pas de base mais est géré par firefox.
# Il n'est jamais modifié et s'appliquera a chaque ouverture
# Voir : https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences#Changing_defaults
cat >"$CTRL_MOZ_PROFILE/user.js" << EOF

//Désactive le fait de montrer la barre de menu quand on appuie sur alt... TODO : changer
//sticky_pref("ui.key.menuAccessKeyFocuses",false);

//Démarrer sur une page blanche
user_pref("browser.newtabpage.enabled",false);
user_pref("browser.startup.homepage","about:blank");

//Désactivation de l'option "Afficher les suggestions de rechercher"
user_pref("browser.search.suggest.enabled",false);

//Suppression de la barre de moteur de recherche dans l'écran principal
user_pref("browser.search.widget.inNavBar",false);

//Masque les moteurs de recherche autre que Wikipédia
user_pref("browser.search.hiddenOneOffs","Google,Amazon.fr,Bing,DuckDuckGo,eBay,Qwant");

//
user_pref("keyword.enabled",false);
user_pref("extensions.pocket.enabled",false);

//Désactiver les mises à jour auto des extensions
user_pref("extensions.update.autoUpdateDefault",false);

//Conserver l'historique selectionnée (par défaut);
user_pref("places.history.enabled", true);
user_pref("browser.formfill.enable", true);

//Désactiver toutes les protections contre le pistage
user_pref("browser.contentblocking.category","custom");
user_pref("pref.privacy.disable_button.tracking_protection_exceptions", false);
user_pref("privacy.trackingprotection.pbmode.enabled",false);

//Header "Do not Track" désactivé
user_pref("privacy.donottrackheader.enabled",false);

//Désactiver le blocage des popups
user_pref("dom.disable_open_during_load",false);

//Désactiver les options de blacage de contenus trompeurs/dangereux
user_pref("browser.safebrowsing.malware.enabled",false);
user_pref("brower.safebrowsing.phising.enabled",false);

//Désactiver les envois de rapports de plantage
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2",false);

//Pas de proxy
user_pref("network.proxy.type",0);

//Désactiver la MaJ auto des moteurs de recherche
user_pref("browser.search.update",false);
EOF
