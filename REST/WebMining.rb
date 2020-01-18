#
# @author Fernando García
#
# == WebMining
#
# This module has been designed to extract information from the kegg and DrugBank databases.
#
# == Summary
#
# First, it generates id for drugs by extracting information from Kegg-drug through the REST
# API togo. The format received is JSON, and in its fields it contains a DrugBank identifier.
# This identifier is used to extract information from DrugBank directly from the html. Finally,
# it collects all the information obtained in a hash and returns it.
#
#
module WebMining
  require 'json'
  require 'net/http'
  require 'nokogiri'

  # Function that receives an initial parameter (it must have at least 6 figures)
  # and the number of drugs to look for. These parameters allow the construction
  # of drug identifiers (Kegg identifiers). Synchronize all module operation to
  # extract data from Kegg-drug and DrugBank.
  #
  # @param params [Hash] Hash with the initial params
  # @option opts [Integer] :initial Initial identifier (Only the last 5 numbers
  #   are taken into account)
  # @option opts [Integer] :iterations Number of searches
  #
  # @return [Hash] Hash with web information
  #
  def WebMining.get_info_from_web(params = {})
    initial = params.fetch(:initial, 100_100)
    iterations = params.fetch(:iterations, 10)
    ontology_data = {}
    print "Web Scrapping from KEGG ... ["
    iterations.times do |i|
      initial += 1
      # Generate drug identifier
      entry = "D#{initial.to_s[1..]}"
      # Get KEGG drug information (see #get_from_kegg)
      ontology_data = get_from_kegg(entry, ontology_data)
      print "/"
    end
    print "]\n\tKEGG INFORMATION OBTAINED !!\n"
    print "\nWebScrapping from DrugBank ... ["
    # Get DrugBank ids to query DrugBank web
    drugbank_ids = ontology_data.map { |key, value| value[:drugbank]}

    ontology_data_ = {}  # Temp. hash
    drugbank_ids.each do |drug_id|
      # Get DrugBank information (see #get_from_drugbank)
      drugbank_data = get_from_drugbank(drug_id)
      # If there are any problem getting DrugBank data pass to the next id
      next if drugbank_data.nil?

      ontology_data.each do |entry, value|
        # Merge DrugBank and Kegg information in one hash by key
        if drugbank_data[:drugbank_id] == value[:drugbank][0]
          ontology_data_[entry] = {kegg: value, drugbank: drugbank_data}
        end
      end
      print "/"
    end
    print "]\n\tDRUGBANK INFORMATION OBTAINED !!\n\n"
    # Return information
    ontology_data_
  end

  # Function that allows to extract information from Kegg Drug, receives an entry and
  # a hash where to store the results. From the request you get the data in JSON format
  # and parse it by extracting the fields of interest.
  #
  # @param entry [String] Kegg entry id (see #get_info_from_web)
  # @param ontology_data [Hash] For structure (see #check_entry)
  #
  # @return [Hash] Hash with information from KEGG
  #
  def WebMining.get_from_kegg(entry, ontology_data)
    url = "http://togows.org/entry/kegg-drug/#{entry}.json"
    # Web request
    res = WebRequest::fetch(url)
    # Parse JSON file
    data = JSON.parse(res.body)
    # To check if all fields are complete (see #check_entry)
    result = check_entry(data)
    # If the result is not nill create a new entry and return the hash
    ontology_data[entry] = result unless result.nil?
    # Else return the same hash received
    ontology_data
  end

  # Function that checks the fields received in the KEEG request and returns them
  # in a structured way.
  # If there is any empty field, return nil and the entry will not be noted.
  #
  # @param data [Hash] Hash result of JSON.parse function (see #get_from_kegg)
  #
  # @return [Hash, nil] If everything is correct return a hash, else return nil
  #
  def WebMining.check_entry(data)
    return nil if data[0].nil?
    response = {
        name:data[0]["name"],
        other_names: data[0]["names"].join("||"),
        formula: data[0]["formula"],
        molecular_mass: data[0]["exact_mass"],
        drugbank: data[0]["dblinks"]["DrugBank"],
        chebi: data[0]["dblinks"]["ChEBI"]
    }
    # If there is some empty field return nil
    response.each_value { |value| return nil if value == "" || value.nil? }
    # Else return a hash
    response
  end

  # Function that allows to extract information from DrugBank, receives a DrugBank entry.
  # It extracts information directly from certain fields of the html, it is not guaranteed
  # that all the information is complete.
  #
  # @param entry [String] DrugBank entry id (see #get_info_from_web)
  #
  # @return [Hash] Hash with information from DrugBank
  #
  def WebMining.get_from_drugbank(entry)
    uri = URI("https://www.drugbank.ca/drugs/#{entry[0]}")
    # DrugBank web request
    res = Net::HTTP.get(uri)
    # html parse
    parsed_data = Nokogiri::HTML.parse(res)
    # Get <p> </p> tags
    p_tags = parsed_data.xpath("//p")

    # If there is some problem with the information manage the exception and return nil
    begin
    # Get drug interactions (see #get_interactions)
    drug_data = get_interactions(parsed_data)

    # Get drug category classification (see #get_category)
    category = get_category(p_tags[0])
    drug_data.merge!(category: category) unless category.nil?

    # Get information about the drug half-life (see #get_half_life)
    half_life = get_half_life(p_tags)
    drug_data.merge!(half_life: half_life) unless half_life.nil?

    # Get information about the drug target (see #get_interaction_description)
    interacion_description = get_interaction_description(parsed_data)
    drug_data.merge!(interaction_description: interacion_description) unless interacion_description.nil?
    drug_data.merge!(drugbank_id: entry[0])
    rescue
      return nil
    end

    # Return a hash with DrugBank data
    drug_data
  end

  # Function that extracts the category to which a drug belongs based on the
  # presence of keywords. Not all possible categories have been covered and
  # the keywords analyzed may be few.
  #
  # @param field [String] html <p> tag 1 with the drug description
  #
  # @return [String, nil] If no category was found else return nil
  #
  def WebMining.get_category(field)
    categories = {"AgentAffectingCardiovascularSystem" => [Regexp.new('hypertension', Regexp::IGNORECASE),
                                       Regexp.new('cardiovascular', Regexp::IGNORECASE)],
                  "AntineoplasicAgent" => [Regexp.new('cancer', Regexp::IGNORECASE),
                               Regexp.new('tumor', Regexp::IGNORECASE),
                               Regexp.new('tumoral', Regexp::IGNORECASE)],
                  "AntiInfectiveAgent" => [Regexp.new('antibiotic', Regexp::IGNORECASE),
                                            Regexp.new('bacterial', Regexp::IGNORECASE)],
                  "AgentAffectingNervousSystem" => [Regexp.new('antidepressants', Regexp::IGNORECASE),
                                            Regexp.new('anxiety', Regexp::IGNORECASE)]}
    categories.each do |key, value|
      value.each { |regex| return key if regex.match(field) }
    end
    nil
  end

  # Function that extracts the half-life information based on half-life keyword
  #
  # @param field [Nokogiri] nokogiri object from #xpath function (see #xpath)
  #
  # @return [String, nil] If no category was found else return nil
  #
  def WebMining.get_half_life(field)
    half_life = Regexp.new('>(.+half-life.+)<', Regexp::IGNORECASE)
    field.each { |tag| return $1.gsub("<(.*?)>","") if half_life.match(tag.to_s) }
    nil
  end

  # Function that extracts the target information directly from the html document
  #
  # @param field [String] html DrugBank response
  #
  # @return [String, nil] nil If it was not possible to find the information else
  #   return the target(s) information
  #
  def WebMining.get_interactions(field)
    # Define the regex for the table with information about the drug targets
    regex = Regexp.new("<table class=\"table table-sm responsive-table\" id=\"drug-moa-target-table\">(.*?)</table>")
    # Remove the new lines
    parsed_data = field.xpath("//table").to_s.gsub("\n",'')
    result = []
    # Regex match coincidence
    if regex.match(parsed_data)
      # Remove <span> tags and append a new line
      coincidence = $1.gsub(/<span.*?span>/, "").gsub("><", ">\n<")
      # Get values between > <
      values = coincidence.scan(/>(.*?)</)
      # INVALID targets names
      not_targets = ["agonism", "antagonism", "other",
                     "neutral", "inhibitor", "Organism",
                     "agonist", "A", "U"]
      n = 3 # The first three are the headers of the table where the information is
      while n < (values.length - 1) do
        target = values[n]
        effect = values[n + 1]
        return nil if effect.nil? || target.nil?
        n += 3
        # If target correspond to effect correct it (temporally disabled)
        #effect, target  = target, values[n - 1] if not_targets.include? target[0]
        result << {target: target[0], interaction_type: effect[0]}
      end
    end
    # If there are not results return nil
    result.empty? ? nil : {interactions: result}
  end

  # Function that extracts information about the target as its nature, and function
  #
  # @param field [String] html DrugBank response
  #
  # @return [Hash, nil] nil If it was not possible to find the information else
  #   return the target(s) information
  #
  def WebMining.get_interaction_description(field)
    # Extract <div class="bond-list-container targets">
    parsed_div = field.xpath("//div[@class=\"bond-list-container targets\"]")
    parsed_dd =  Nokogiri::HTML(parsed_div.to_s.downcase!)
    # Extract <dd> tags
    parsed_dd = parsed_dd.xpath("//dd")
    # Remove everything between < >
    parsed_dd = parsed_dd.map { |n| n.to_s.gsub!(/<.*?>/, "")}
    result = []
    field_type = 0 # Target type position
    field_function = 4 # Target function position
    uniprot = 7 # Extract uniprot id
    n = 0
    while n < (parsed_dd.length - 1)
      element_type = parsed_dd[field_type + n] # Extract target type
      element_function = parsed_dd[field_function + n] # Extract target function
      uniprot_id = parsed_dd[uniprot] # Extract uniprot id
      n += 10 # The information for each of the targets has 10 fields
      result << {element_type: element_type, element_function: element_function, uniprot_id: uniprot_id}
    end
    # If there are not results return false
    result.empty? ? nil : {interactions: result}
  end
end


