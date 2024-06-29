require 'sketchup.rb'
require_relative 'ab_design_create.rb'

module AB_Extensions
  module AB_TpaExtension
    # Vérification du chargement du fichier
    unless file_loaded?(__FILE__)

      # Création de la barre d'outils
      toolbar = UI::Toolbar.new "AB Design"
      cmd = UI::Command.new("Toolbar Button") {
        AB_D::AB_Core.createProjet
      }
      icon = File.join( 'images','abdesign_64x64.png')
      cmd.small_icon = icon
      cmd.large_icon = icon
      cmd.tooltip = "Toolbar button test"
      cmd.status_bar_text = "This is status bar text"
      toolbar = toolbar.add_item cmd
      toolbar.show

      # Ajout des éléments de menu
      menu = UI.menu('Plugins').add_submenu('AB Design') 
      menu.add_item('Convertir vers TpaCad') { AB_D::AB_Core.createProjet } # Utilisation de la syntaxe complète pour appeler la méthode
      menu.add_item('Afficher la liste des pièces') { AB_D::AB_Core.createProjet } # Utilisation de la syntaxe complète pour appeler la méthode
      
      # Marquer le fichier comme chargé
      file_loaded(__FILE__)
    end

  end  # module AB_TpaExtension
  
end  # module AB_Extensions
