module AnalyzeComponent
  def self.analyze_faces_with_holes
    # Get the active model
    model = Sketchup.active_model
    
    # Get the current selection
    selection = model.selection
    
    # Check if a single component is selected
    if selection.count != 1 || !selection.first.is_a?(Sketchup::ComponentInstance)
      UI.messagebox("Please select a single component instance.")
      return
    end
    
    component_instance = selection.first
    definition = component_instance.definition

    face_labels = {
      [0, 0, 1] => 1,   # Face supérieure
      [0, 0, -1] => 2,  # Face inférieure
      [0, -1, 0] => 3,  # Face avant
      [1, 0, 0] => 4,   # Face latérale droite
      [0, 1, 0] => 5,   # Face arrière
      [-1, 0, 0] => 6   # Face latérale gauche
    }

    # Hash to store holes information by face number
    holes_by_face = Hash.new { |hash, key| hash[key] = [] }

    # Conversion factor from inches to millimeters
    inch_to_mm = 25.4

    # Iterate through all faces in the component definition
    definition.entities.grep(Sketchup::Face).each do |face|
      # Identify the face by its normal
      normal = face.normal.to_a.map(&:round)
      face_number = face_labels[normal]
      
      next unless face_number  # Skip if face is not one of the six main faces

      # Check each loop for holes
      face.loops.each do |loop|
        # Check if the loop is an inner loop (hole)
        if loop.outer?
          # Outer loop, skip
          next
        else
          # Inner loop (hole)
          hole_edges = loop.edges
          
          # Calculate the position and diameter of the hole
          center = Geom::Point3d.new(0, 0, 0)
          hole_edges.each do |edge|
            center = center + edge.start.position.to_a
          end
          center = Geom::Point3d.new(center.x / hole_edges.size, center.y / hole_edges.size, center.z / hole_edges.size)

          # Determine the diameter by measuring the distance between two opposite edges
          # This assumes the hole is circular
          first_edge = hole_edges.first
          second_edge = hole_edges[hole_edges.size / 2]
          radius = first_edge.start.position.distance(second_edge.start.position) / 2.0
          diameter = radius * 2.0 * inch_to_mm  # Convert diameter from inches to millimeters

          # Transform the center point to the component instance space
          world_center = component_instance.transformation * center
          
          # Store the hole information in the hash
          holes_by_face[face_number] << {
            center: [world_center.x * inch_to_mm, world_center.y * inch_to_mm],  # Convert position to millimeters
            diameter: diameter
          }
        end
      end
    end

    # Output the holes information grouped by face
    holes_by_face.each do |face_number, holes|
      puts "Face number: #{face_number}"
      puts "Number of holes: #{holes.size}"
      holes.each do |hole|
        puts "  Hole detected:"
        puts "    Center (X, Y): (#{hole[:center][0].round(2)}, #{hole[:center][1].round(2)}) mm"
        puts "    Diameter: #{hole[:diameter].round(2)} mm"
      end
    end
  end
end

# Add a menu item to trigger the script
UI.menu("Plugins").add_item("Analyze Component for Holes 5") {
  AnalyzeComponent.analyze_faces_with_holes
}
