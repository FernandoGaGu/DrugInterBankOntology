# Para el CORE de la ontologia
# https://w3id.org/def/DIBO
# Para los DATOS de la ontologia
# https://w3id.org/def/DIBOdata

require './ontology_design'

class RdfGenerator
  include Ontology
  def initialize
  end

  def generate_rdf(params = {})

    params_exception unless valid?(params)

    rdf_triples = []
    params.each do |entry_id, values|
      value = Ontology::ontology_struct values
      puts value



    end

  end

  private
  def ontology_exception  # <-------- ELIMINAR
    puts 'Ontology URI not provided'
    raise 'An error has occured, check #initialize params'
  end
  def params_exception
    puts 'Possibly incomplete data'
    #raise 'An errror has occured, check #generate_rdf_params'
  end

  def invalid_array?(arr)
    valid_interactions = %w(inhibitor agonism antagonism other neutral)
    valid_targets = %w(protein dna rna drug)
    # If the array is for hasOtherName always will be valid
    return false if arr[0].class != Array
    # If the array is for hasTarget we must check it
    arr.each do |value|
      return true unless valid_targets.include?(value[1]) && valid_interactions.include?(value[2])
    end
    false
  end

  def valid?(params = {})
    # Check empty fields
    params.each_value do |arr|
      arr.each_value do |value|
        # If the array is empty or the data that has is invalid return false
        #return false if value.class == Array && (value.empty? || invalid_array?(value))
        #
        # Initially we don't check if the array is valid, just if it is empty
        return false if value.class == Array && value.empty?
        next if value.class == Array
        # If the string is empty data not valid
        return false if value == ''
      end
    end
    true
  end

end





def make_triples(params = {})
  subject = params.fetch(:subject, nil)
  predicate = params.fetch(:predicate, nil)
  object_ = params.fetch(:predicate_uri, nil)
  # If we have literals we need to build a different URI
  object = object_.nil? ? params.fetch(:literal, nil) : object_
end



my_data = {'DRUG_NAME' => {
    'hasScientificName' => 'SCIENTIFIC_NAME', 'hasOtherName' => %w(NAME_2 NAME_2),
    'hasMolecularFormula' => 'MOLECULAR_FORMULA', 'hasMolecularMass' => 'MOLECULAR_MASS',
    'hasDrugBankId' => 'DRUGBANKID', 'hasChebiId' => 'CHEBI_ID',
    'functionallyGroupedIn' => 'FUNCTIONALLY_GROUPED', 'hasHalfLife' => 'HALF_LIFE',
    'hasTarget' => [%w(TARGET_1 protein agonism FUNCTION_1),
                    %w(TARGET_2 protein inhibitor FUNCTION_2)]
}}

generator = RdfGenerator.new



generator.generate_rdf(my_data)





