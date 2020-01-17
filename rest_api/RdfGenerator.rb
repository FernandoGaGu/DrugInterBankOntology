require './ontology_design'

class RdfGenerator
  include Ontology
  @@unique_identifier = 1000000000
  @@number_of_triples = 0
  def initialize
    @rdf_data = []
  end
  def self.unique_identifier
    @@unique_identifier += 1
    @@unique_identifier.to_s
  end
  def self.new_triplet
    @@number_of_triples  += 1
  end
  def number_of_triples?
    puts "#{@@number_of_triples} triples generated !! :)"
  end
  def rdf
    @rdf_data.join("\n")
  end

  def generate_rdf(params = {})
    params_exception unless valid?(params)
    params.each do |entry_id, values|
      puts "Transforming #{entry_id} to RDF ..."
      value = Ontology::ontology_struct values
      next if value == false
      @rdf_data << value.join("\n")
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