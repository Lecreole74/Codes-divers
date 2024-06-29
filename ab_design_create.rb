# Fichier : my_method.rb

require_relative 'ab_design_xml.rb'

module AB_D
    module AB_Core

        # Définir une classe pour stocker les données des composants
      class ComponentData
        attr_accessor :id, :name, :length, :width, :depth, :material, :occurrences
    
        def initialize(id, name, length, width, depth, material)
        @id = id
        @name = name
        @length = length
        @width = width
        @depth = depth
        @material = material
        @occurrences = 1
        end
    
        # Méthode pour incrémenter le nombre d'occurrences
        def increment_occurrences
        @occurrences += 1
        end
      end

      # Définir une classe pour stocker les données des composants
      class ProgramData
        attr_accessor :filename, :quantity, :length, :width, :depth, :material
    
        def initialize(filename, quantity, length, width, depth, material)
        @filename = filename  
        @quantity = quantity
        @length = length
        @width = width
        @depth = depth
        @material = material
        end
      end

      # Définir une classe pour stocker les données des composants
      class BarData
        attr_accessor :quantity, :length, :width, :depth, :material
    
        def initialize(quantity, length, width, depth, material)
        @quantity = quantity
        @length = length
        @width = width
        @depth = depth
        @material = material
        end
      end

        # Création du Dossier de sauvegarde
        def self.create_directory(directory_path)
            # # Vérifier si le dossier existe déjà
            # if File.directory?(directory_path)
            #   puts "Le dossier existe déjà."
            # else
            #   # Créer le dossier
            #   Dir.mkdir(directory_path)
            #   puts "Le dossier a été créé avec succès."
            # end
            # Vérifier si le dossier existe
          if Dir.exist?(directory_path)
            index = 1
            begin
              # Incrémenter le nom du dossier
              directory_path_incremente = "#{directory_path}_#{index}"
              index += 1
            end while Dir.exist?(directory_path_incremente)

            # Créer le dossier avec le nom incrémenté
            Dir.mkdir(directory_path_incremente)
            return directory_path_incremente
          else
            # Créer le dossier s'il n'existe pas
            Dir.mkdir(directory_path)
            return directory_path
          end
        end
          
        # Réorganise la dimension mini est l'épaisseur
        def self.reorder_dimensions_old(array)
            # Vérifier si l'entrée est un tableau et a au moins 3 éléments
            return nil unless array.is_a?(Array) && array.length >= 3
          
            # Trouver l'index de la plus petite valeur
            smallest_index = array.index(array.min)
          
            # Si la plus petite valeur n'est pas déjà à la dernière position, la réorganiser
            if smallest_index != array.length - 1
              array[smallest_index], array[-1] = array[-1], array[smallest_index]
            end
          
            return array
          end

        def self.reorder_dimensions(array)
          # Vérifier si l'entrée est un tableau et a au moins 3 éléments
          return nil unless array.is_a?(Array) && array.length >= 3
        
          # Trier le tableau en ordre croissant numérique
          sorted_array = array.sort_by(&:to_f).reverse
        
          return sorted_array
          end
          

        # Définir une méthode pour obtenir les dimensions d'un composant
        def self.get_dimensions(component_instance)
          # Récupérer les axes du composant
          transformation = component_instance.transformation
          axes = [
            Geom::Vector3d.new(transformation.xaxis),
            Geom::Vector3d.new(transformation.yaxis),
            Geom::Vector3d.new(transformation.zaxis)
          ]
        
          # Récupérer les dimensions du composant
          bounds = component_instance.definition.bounds
          width = bounds.width
          height = bounds.height
          depth = bounds.depth
        
          # Convertir les dimensions en vecteurs
          width_vector = Geom::Vector3d.new(width, 0, 0)
          height_vector = Geom::Vector3d.new(0, height, 0)
          depth_vector = Geom::Vector3d.new(0, 0, depth)
        
          # Transformer les vecteurs selon les axes internes
          width_dim = width_vector.transform(transformation)
          height_dim = height_vector.transform(transformation)
          depth_dim = depth_vector.transform(transformation)
          dimensions_i = width_dim, height_dim, depth_dim
          dim_d = reorder_dimensions([(dimensions_i[0].length.to_f*25.4).round(2),(dimensions_i[1].length.to_f*25.4).round(2),(dimensions_i[2].length.to_f*25.4).round(2)])
          return dim_d
        end

        #
        def self.createProjet
            current_path = __dir__.dup
            current_path.force_encoding("UTF-8") if current_path.respond_to?(:force_encoding)

            regex_module = /\b(MRT|MHT|MCT|MPT|MAT|FAT)\d{2}(?:#\d+)?\b/
            entities_data = []
            
            # Récupérer toutes les entités de la scène
            selection = Sketchup.active_model.selection
            

            if selection.length >= 1 && selection.first.is_a?(Sketchup::ComponentInstance)
              selection.each do |entity|
                entity_name = entity.definition.name
                if regex_module.match?(entity_name)
                  entity.definition.entities.each do |ent|
                    if ent.is_a?(Sketchup::ComponentInstance)
                      # puts ent.definition.name
                      entities_data << ent
                    end
                  end
                else
                  if entity.is_a?(Sketchup::ComponentInstance)
                    # puts entity.definition.name
                    entities_data << entity
                  end
                end
              end
            else
              Sketchup.active_model.entities.each do |entity|
                if entity.is_a?(Sketchup::ComponentInstance)
                  entity_name = entity.definition.name
                  if regex_module.match?(entity_name)
                    entity.definition.entities.each do |ent|
                      # if ent.is_a?(Sketchup::ComponentInstance)
                        # puts ent.definition.name
                        entities_data << ent
                      # end
                    end
                  else
                    # if entity.is_a?(Sketchup::ComponentInstance)
                      # puts entity.definition.name
                      entities_data << entity
                    # end
                  end
                end
              end
            end
            

            # Initialiser un tableau pour stocker les données des composants
            component_data = []
            programs_data = []
            bars_data = []

            # Parcourir toutes les entités
            entities_data.each do |entity|
            # Vérifier si l'entité est un composant
              if entity.is_a?(Sketchup::ComponentInstance) && entity.visible?
                  # Obtenir les informations du composant
                  name = entity.definition.name
                  material = entity.material ? entity.material.name : "No_Material"
                  id = entity.entityID
                  #length, width, depth = get_dimensions(entity)
                  length, width, depth = get_dimensions(entity)
                  if width>1250
                      tmp_length = length
                      length = width
                      width = tmp_length
                  end
                  # Vérifier si le composant existe déjà dans component_data
                  existing_component = component_data.find { |data| data.name == name && data.material == material && data.length == length && data.width == width && data.depth == depth }
                  
                  if existing_component
                  # Si le composant existe déjà, incrémenter le nombre d'occurrences
                  existing_component.increment_occurrences
                  else
                  # Si le composant n'existe pas encore, créer une nouvelle instance de ComponentData et l'ajouter à component_data
                  component = ComponentData.new(id, name, length, width, depth, material)
                  component_data << component
                  end

                  # Vérifier si le composant existe déjà dans component_data
                  existing_bar = bars_data.find { |data| data.material == material && data.width == width && data.depth == depth}
                  if !existing_bar
                    # Si la barre n'existe pas encore
                    new_bar = BarData.new(50, 2500, width, depth, material)
                    bars_data << new_bar
                  end
              
              end
            end

            # Trier le tableau par nom, material, longueur et largeur
            sorted_component_data = component_data.sort_by { |data| [data.material] }
            message = ""

            # Boite de dialogue pour choisir le dossier racine.
            selected_directory = UI.select_directory(title: "Sélectionner votre dossier projet de TpaCad")

            sketchup_filename = Sketchup.active_model.title

            # Crée dans le dossier racine, un dossier avec le nom du fichier Sketchup.
            # Ajout consition si fichier est sauvé, sinon demande de sauvegarder avant.
            dirpath = File.join(selected_directory, sketchup_filename)
            dirpath_return = create_directory(dirpath)

            # Crée le fichier TCN selon le type du composant
            piece_count = 0
            sorted_component_data.each do |data|
                # Fichier model
                input_file_path = File.join(current_path, "models", "#{data.name.match(/^(.*?)(?:#|$)/)&.captures&.first}.tcn")
                puts input_file_path
                defaut_piece = ""
                if !File.exist?(input_file_path)
                  input_file_path = File.join(current_path, "models", "piece.tcn")
                  defaut_piece = "_defaut"
                end
                # Construit le fichier output
                output_filename = "#{data.name}_#{data.length.to_s.to_i}X#{data.width.to_s.to_i}X#{data.depth.to_s.to_i}_#{data.material}_X#{data.occurrences}.tcn"
                piece_count+= data.occurrences
                message += "#{output_filename}\n"
                # message += "#{data.name}_#{data.length.to_s.to_i}X#{data.width.to_s.to_i}X#{data.depth.to_s.to_i}_#{data.material}_X#{data.occurrences}.tcn\n"
                if File.exist?(input_file_path)
                    file_content = File.read(input_file_path)
                    modified_content = file_content.gsub("#width#", data.length.to_s)
                    modified_content = modified_content.gsub("#heigth#", data.width.to_s)
                    modified_content = modified_content.gsub("#depth#", data.depth.to_s)
                    # output_filename = "#{data.name}_#{data.length.to_s.to_i}X#{data.width.to_s.to_i}X#{data.depth.to_s.to_i}_#{data.material}_X#{data.occurrences}.tcn"
                    
                    output_file_path = File.join(dirpath_return, output_filename)

                    #Crée le fichier program
                    program = ProgramData.new(output_file_path, data.occurrences, data.length.to_s, data.width.to_s, data.depth.to_s, data.material)
                    programs_data << program
                    # Enregistrer les modifications dans le nouveau fichier
                    File.open(output_file_path, "w") { |file| 
                        # file.binmode
                        file.puts modified_content 
                    }
                  else
                    puts "fichier modele n'existe pas pour #{input_file_path}"
                
                  end
            end
            
            # crée le fichier xml
            xml_filename = "#{sketchup_filename}.XMLBN"
            xml_file_path = File.join(dirpath_return, xml_filename)

            AB_D::AB_Xml.create_xml_file(xml_file_path)

            AB_D::AB_Xml.add_program_node(xml_file_path, programs_data, bars_data)

            UI.messagebox("Le fichier #{xml_filename} a été crée dans le dossier #{dirpath_return} \nNombre de pièces crées : #{programs_data.length} (#{piece_count})")
            # AB_D::AB_Xml.helloworld
        end
    end
end
  
