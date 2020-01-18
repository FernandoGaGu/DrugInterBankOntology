require './WebRequest.rb'
require './RdfGenerator.rb'
require './WebMining.rb'
require 'nokogiri'

# Function that allows linking the information obtained from the WebMining module
# with the RdfGenerator class generating rdf in the form of n-triples.
#
def adapt_to_ontology(value = {})
  processed_information = {}
  name = value[:kegg][:name].nil? ? "UNKNOWN" : value[:kegg][:name]
  other_names = value[:kegg][:other_names].nil? ? "UNKNOWN" : value[:kegg][:other_names]
  formula = value[:kegg][:formula].nil? ? "UNKNOWN" : value[:kegg][:formula]
  molecular_mass = value[:kegg][:molecular_mass].nil? ? "UNKNOWN" : value[:kegg][:molecular_mass]
  drugbank_id = value[:kegg][:drugbank].nil? ? "UNKNOWN" : value[:kegg][:drugbank]
  chebi_id = value[:kegg][:chebi].nil? ? "UNKNOWN" : value[:kegg][:chebi][0]
  category = value[:drugbank][:category].nil? ? "UNKNOWN": value[:drugbank][:category]
  half_life = value[:drugbank][:half_life].nil? ? "UNKNOWN" : value[:drugbank][:half_life]

  targets, target_types = [], []
  unless value[:drugbank][:interactions].empty?
    value[:drugbank][:interactions].each do |interaction|
      targets << interaction[:target]
      target_types << interaction[:interaction_type]
    end
  end

  molecule_types, target_functions, uniprot_ids = [], [], []
  unless value[:drugbank][:interaction_description][:interactions].empty?
    value[:drugbank][:interaction_description][:interactions].each do |interaction|
      molecule_types << interaction[:element_type]
      target_functions << interaction[:element_function]
      uniprot_ids << interaction[:uniprot_id]
    end
  end

  target_info = []
  molecule_types.length.times do |n|
    target_name = targets[n].nil? ? "Not_Found" : targets[n].gsub!(" ", "_")
    target_info << [target_name, target_types[n], molecule_types[n], target_functions[n], uniprot_ids[n].upcase]
  end

  processed_information[drugbank_id[0]] = {
      'hasScientificName' => name, 'hasOtherName' => other_names.split("||"),
      'hasMolecularFormula' => formula, 'hasMolecularMass' => molecular_mass,
      'hasDrugBankId' => drugbank_id[0], 'hasChebiId' => chebi_id,
      'functionallyGroupedIn' => category, 'hasHalfLife' => half_life,
      'hasTarget' => target_info }
  processed_information
end

def print_main
  puts ""
  puts <<-'EOF'
 _____                     _____       _              ____              _    
|  __ \                   |_   _|     | |            |  _ \            | |   
| |  | |_ __ _   _  __ _    | |  _ __ | |_ ___ _ __  | |_) | __ _ _ __ | | __
| |  | | '__| | | |/ _` |   | | | '_ \| __/ _ \ '__| |  _ < / _` | '_ \| |/ /
| |__| | |  | |_| | (_| |  _| |_| | | | ||  __/ |    | |_) | (_| | | | |   < 
|_____/|_|   \__,_|\__, | |_____|_| |_|\__\___|_|    |____/ \__,_|_| |_|_|\_\
                    __/ |                                                    
                   |___/                                                     
  ____        _        _                   
 / __ \      | |      | |                  
| |  | |_ __ | |_ ___ | | ___   __ _ _   _ 
| |  | | '_ \| __/ _ \| |/ _ \ / _` | | | |
| |__| | | | | || (_) | | (_) | (_| | |_| |
 \____/|_| |_|\__\___/|_|\___/ \__, |\__, |
                                __/ | __/ |
                               |___/ |___/ 
  .-.    __
 |   |  /\ \
 |   |  \_\/      __        .-.
 |___|        __ /\ \      /:::\
 |:::|       / /\\_\/     /::::/
 |:::|       \/_/        / `-:/
 ':::'__   _____ _____  /    /
     / /\ /     |:::::\ \   /
     \/_/ \     |:::::/  `"`
        __ `"""""""""`
       /\ \
       \_\/

  EOF
  puts ""
  puts ""
end


# |**********************************************|
# |******************|| MAIN ||******************|
# |**********************************************|
print_main

# Get from the output file name
print "Indicate the output file: "
user = gets.chomp!
valid_output = Regexp.new('[A-Za-z0-9]+\.rdf')
output_file = valid_output.match(user) ? user : "RDF_data.rdf"
puts ""
puts "Output file: #{output_file}"
puts ""

# Mine information
ontology_data = WebMining::get_info_from_web(initial:100_105, iterations:10)

# Create a new RdfGenerator object
generator = RdfGenerator.new

ontology_data.each do |key, value|
  # Adapt output to ontology design (see #adapt_to_ontology)
  processed_information = adapt_to_ontology value
  # Generate RDF using the RdfGenerator object
  generator.generate_rdf(processed_information)
  # Display the number of triples
  generator.number_of_triples?
  # Get the generated rdf data from RdfGenerator object
  rdf_data = generator.rdf
  # Save the rdf data in the output file
  file = File.exists?(output_file) ? File.open(output_file, "a") :  File.open(output_file, "w")
  file.puts rdf_data
  file.close
end
