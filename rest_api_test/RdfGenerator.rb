require './OntologyDesign'
#
# @author Fernando García
#
# == RdfGenerator
#
# This class allows to generate resources in the form of n-triples rdf from data passed in a
# hash following a certain scheme (see #generate_rdf) that can be generic for any ontology, and
# the Ontology module (see OntologyDesign.rb) in which the conceptual model of the ontology that
# is going to  be implemented to follow to generate the rdf in the form of n-triples.
#
# == Summary
#
# This class uses the Ontology module to generate rdf in the form of n-triples. It also
# implements data verification systems and counts the number of triples generated.
# The scheme of hash containing the data consists in Couples key value or key and a new hash.
#
#  KEY = {
#       'FIELD_NAME' => VARIABLE, 'OTHER_FIELD' => {'FIELD_ARRAY' = [ARRAY]}
#         }
# The structure of the array should be complementary to that defined in the ontology module.
#
#
class RdfGenerator
  include Ontology
  # Unique identifier for n-ary relation Interaction
  @@unique_identifier = 0
  # To count the number of generated triplets
  @@number_of_triples = 0

  # Function that initializes an RdfGenerator class object
  #
  # @return [RdfGenerator] RdfGenerator object
  #
  def initialize
    @rdf_data = []
  end

  # Class method that returns a unique identifier each time it is called
  #
  # @return [String] Unique identifier
  #
  def self.unique_identifier
    @@unique_identifier += 1
    @@unique_identifier.to_s
  end

  # Class method that count the number of triples
  #
  def self.new_triplet
    @@number_of_triples  += 1
  end

  # Function that print the number of generated triples
  #
  def number_of_triples?
    puts "\n#{@@number_of_triples} triples generated !! :)"
  end

  # Function that returns the rdf data for a given hash following the
  # general schema
  #
  # @return [String] rdf n-triples for a given instance
  #
  def rdf
    @rdf_data.join("\n")
  end

  # Function that the Ontology module uses to generate the rdf for a given
  # instance. Also check that all fields are complete and correct.
  #
  # @param params [Hash] Hash following the general scheme
  #
  def generate_rdf(params = {})
    # If the fields are not valid nothing is added
    @rdf_data << "" unless valid?(params)

    params.each do |entry_id, values|
      puts "\nTransforming #{entry_id} to RDF ..."
      value = Ontology::ontology_struct values
      next if value == false
      @rdf_data << value.join("\n")
    end
  end

  private

  # Function that checks if the fields are valid and contain consistent
  # information.
  #
  # @param params [Hash] (see #generate_rdf)
  #
  # @return [Boolean] Return false if the information is incorrect,
  # otherwise return true
  #
  def valid?(params = {})
    params.each_value do |arr|
      arr.each do |key, value|
        # hasOtherName always will be correct
        next if key == 'hasOtherName'
        # If the array is empty or the data that has is invalid return false
        # return false if the array is empty
        return false if value.class == Array && value.empty?
        # return false if the information is not correct
        return false if value.class == Array && invalid_interactions?(value)
        next if value.class == Array
        # If the string is empty data not valid
        return false if value == ''
      end
    end
    true
  end

  # Function that checks if the target information is correct
  #
  # @param arr [Array] (see #valid?)
  #
  # @return [Boolean] Return false if the information is incorrect,
  # otherwise return true
  #
  def invalid_interactions?(arr)
    valid_interactions = %w(inhibitor agonism antagonism other neutral agonist inducer antagonist)
    valid_targets = %w(protein dna rna drug)
    # If this is not an array is incorrect
    return false unless arr.class == Array
    # [OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}
    # (Regexp for UniProt id provided by UniProt)
    uniprot_regex = Regexp.new('[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}', Regexp::EXTENDED)
    arr.each do |value|
      # If value is not an array is incorrect
      return true unless value.class == Array
      return true unless valid_interactions.include?(value[1]) # Check interaction
      return true unless valid_targets.include?(value[2]) # Check molecule type
      return true unless uniprot_regex.match(value[4]) # Check uniprot uri
    end
    false
  end
end