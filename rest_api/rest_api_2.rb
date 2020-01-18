require './WebRequest.rb'
require './RdfGenerator.rb'
require './WebMining.rb'
require 'nokogiri'

ontology_data = WebMining::get_info_from_web

processed_information = {}

generator = RdfGenerator.new

ontology_data.each do |key, value|
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

  molecule_types, target_functions = [], []
  unless value[:drugbank][:interaction_description][:interactions].empty?
    value[:drugbank][:interaction_description][:interactions].each do |interaction|
      molecule_types << interaction[:element_type]
      target_functions << interaction[:element_function]
    end
  end
  target_info = []
  molecule_types.length.times do |n|
    target_name = targets[n].nil? ? "Not_Found" : targets[n].gsub!(" ", "_")
    target_info << [target_name, target_types[n], molecule_types[n], target_functions[n]]
  end
  processed_information[drugbank_id[0]] = {
      'hasScientificName' => name, 'hasOtherName' => other_names.split("||"),
      'hasMolecularFormula' => formula, 'hasMolecularMass' => molecular_mass,
      'hasDrugBankId' => drugbank_id[0], 'hasChebiId' => chebi_id,
      'functionallyGroupedIn' => category, 'hasHalfLife' => half_life,
      'hasTarget' => target_info }
  generator.generate_rdf(processed_information)
  generator.number_of_triples?
  rdf_data = generator.rdf
  file = File.exists?("rdf_triples.rdf") ? File.open("rdf_triples.rdf", "a") :  File.open("rdf_triples.rdf", "w")
  file.puts rdf_data
  file.close

end

=begin
ERRORR =============
Traceback (most recent call last):
  8: from rest_api.rb:185:in `<main>'
  7: from rest_api.rb:185:in `each'
  6: from rest_api.rb:221:in `block in <main>'
  5: from /Users/fernandogarcia/Desktop/DrugInterBankOntology/rest_api/RdfGenerator.rb:26:in `generate_rdf'
  4: from /Users/fernandogarcia/Desktop/DrugInterBankOntology/rest_api/RdfGenerator.rb:26:in `each'
  3: from /Users/fernandogarcia/Desktop/DrugInterBankOntology/rest_api/RdfGenerator.rb:28:in `block in generate_rdf'
  2: from /Users/fernandogarcia/Desktop/DrugInterBankOntology/rest_api/ontology_design.rb:95:in `ontology_struct'
  1: from /Users/fernandogarcia/Desktop/DrugInterBankOntology/rest_api/ontology_design.rb:95:in `each'
/Users/fernandogarcia/Desktop/DrugInterBankOntology/rest_api/ontology_design.rb:140:in `block in ontology_struct': undefined method `gsub' for nil:NilClass (NoMethodError)

=end