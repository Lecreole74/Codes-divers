# Fichier : ab_design_xml.rb
require 'rexml/document'

module AB_D
    module AB_Xml
      # Création du fichier XML pour Tpa BarNesting
      def self.create_xml_file(file_path)
        # Ouvrir un nouveau fichier XML en écriture
        xml = File.open(file_path, "w")
      
        # Écrire l'en-tête XML
        xml.puts('<?xml version="1.0" encoding="utf-8"?>')
        xml.puts('<MAIN>')
        xml.puts('  <BARS>')
        xml.puts('  </BARS>')
        xml.puts('  <PROGRAMS>')
        xml.puts('  </PROGRAMS>')
        xml.puts('</MAIN>')
      
        # Fermer le fichier XML
        xml.close
      
        # puts "Fichier XML créé avec succès : #{file_path}"
      end

      # Ajout du noeud program
      def self.add_program_node(file_path, programs_data, bars_data)
        # Ouvrir le fichier XML en lecture
        # puts file_path
        xml_file = File.read(file_path)
      
        # Analyser le contenu XML
        xml_doc = REXML::Document.new(xml_file)
      
        # Trouver le nœud "PROGRAMS"
        programs_node = REXML::XPath.first(xml_doc, "//PROGRAMS")

        programs_data.each do |program_data|
          # Créer le nœud "PROGRAM"
          
          program_node = REXML::Element.new("PROGRAM")
          program_node.add_attribute("Row", "1")
        
          pathname_node = REXML::Element.new("PATHNAME")
          pathname_node.text = program_data.filename
          program_node.add_element(pathname_node)
        
          qty_node = REXML::Element.new("QTY")
          qty_node.text = program_data.quantity.to_s
          program_node.add_element(qty_node)
        
          l_node = REXML::Element.new("L")
          l_node.text = program_data.length.to_s
          program_node.add_element(l_node)
        
          w_node = REXML::Element.new("W")
          w_node.text = program_data.width.to_s
          program_node.add_element(w_node)
        
          t_node = REXML::Element.new("T")
          t_node.text = program_data.depth.to_s
          program_node.add_element(t_node)
        
          mat_node = REXML::Element.new("MAT")
          mat_node.text = program_data.material
          program_node.add_element(mat_node)
        
          # Ajouter le nœud "PROGRAM" à "PROGRAMS"
          programs_node.add_element(program_node)
        end
        # bars
        bars_data.each do |bar_data|
          # Trouver le nœud "BARS"
          bars_node = REXML::XPath.first(xml_doc, "//BARS")
        
          # Créer le nœud "BAR"
          bar_node = REXML::Element.new("BAR")
          bar_node.add_attribute("Row", 1)
        
          qty_node = REXML::Element.new("QTY")
          qty_node.text = bar_data.quantity.to_s
          bar_node.add_element(qty_node)
        
          l_node = REXML::Element.new("L")
          l_node.text = bar_data.length.to_s
          bar_node.add_element(l_node)
        
          w_node = REXML::Element.new("W")
          w_node.text = bar_data.width.to_s
          bar_node.add_element(w_node)
        
          t_node = REXML::Element.new("T")
          t_node.text = bar_data.depth.to_s
          bar_node.add_element(t_node)
        
          mat_node = REXML::Element.new("MAT")
          mat_node.text = bar_data.material
          bar_node.add_element(mat_node)
        
          # Ajouter le nœud "BAR" à "BARS"
          bars_node.add_element(bar_node)

        end

        # Écrire les modifications dans le fichier
        File.open(file_path, "w") do |file|
          xml_doc.write(file)
        end
        # puts "Noeud PROGRAM ajouté avec succès dans le fichier : #{file_path}"
      end

      # Ajout du noeud bar
      def self.add_bar_node(file_path, bar_data)
        # Ouvrir le fichier XML en lecture
        xml_file = File.read(file_path)
      
        # Analyser le contenu XML
        xml_doc = REXML::Document.new(xml_file)
      
        # Trouver le nœud "BARS"
        bars_node = REXML::XPath.first(xml_doc, "//BARS")
      
        # Créer le nœud "BAR"
        bar_node = REXML::Element.new("BAR")
        bar_node.add_attribute("Row", bar_data[:Row])
      
        qty_node = REXML::Element.new("QTY")
        qty_node.text = bar_data[:QTY].to_s
        bar_node.add_element(qty_node)
      
        l_node = REXML::Element.new("L")
        l_node.text = bar_data[:L].to_s
        bar_node.add_element(l_node)
      
        w_node = REXML::Element.new("W")
        w_node.text = bar_data[:W].to_s
        bar_node.add_element(w_node)
      
        t_node = REXML::Element.new("T")
        t_node.text = bar_data[:T].to_s
        bar_node.add_element(t_node)
      
        mat_node = REXML::Element.new("MAT")
        mat_node.text = bar_data[:MAT]
        bar_node.add_element(mat_node)
      
        # Ajouter le nœud "BAR" à "BARS"
        bars_node.add_element(bar_node)
      
        # Écrire les modifications dans le fichier
        File.open(file_path, "w") do |file|
          xml_doc.write(file)
        end
      
        # puts "Noeud BAR ajouté avec succès dans le fichier : #{file_path}"
      end 
    end # end module AB_Xml
end # end module AB_D
  