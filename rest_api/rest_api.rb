require './WebRequest.rb'
require 'json'
require 'net/http'
require 'nokogiri'

def check_entry(data)
  response = {
      name:data[0]["name"],
      other_names: data[0]["names"].join(","),
      formula: data[0]["formula"],
      molecular_mass: data[0]["exact_mass"],
      drugbank: data[0]["dblinks"]["DrugBank"],
      chebi: data[0]["dblinks"]["ChEBI"]
  }
  # Si hay algún campo vacio la función retorna nil
  response.each_value { |value| return nil if value == "" || value.nil? }
  response
end

def get_category(field)
  categories = {"Cardiovascular" => [Regexp.new('hypertension', Regexp::IGNORECASE),
                                     Regexp.new('cardiovascular', Regexp::IGNORECASE)],
                "Cancer" => [Regexp.new('cancer', Regexp::IGNORECASE),
                             Regexp.new('tumor', Regexp::IGNORECASE),
                             Regexp.new('tumoral', Regexp::IGNORECASE)],
                "Infectious Diseases" => [Regexp.new('antibiotic', Regexp::IGNORECASE),
                                          Regexp.new('bacterial', Regexp::IGNORECASE)],
                "Psychiatric Disease" => [Regexp.new('antidepressants', Regexp::IGNORECASE),
                                          Regexp.new('anxiety', Regexp::IGNORECASE)]}
  categories.each do |key, value|
    value.each { |regex| return key if regex.match(field) }
  end
  nil
end

def get_half_life(field)
  half_life = Regexp.new('>(.+half-life.+)<', Regexp::IGNORECASE)
  field.each { |tag| return $1 if half_life.match(tag.to_s) }
  nil
end

def get_interactions(field)
  regex = Regexp.new("<table class=\"table table-sm responsive-table\" id=\"drug-moa-target-table\">(.*?)</table>")

  # Es necesario quitar los separadores para que la expresión regular funcione
  parsed_data = field.xpath("//table").to_s.gsub("\n",'')
  result = []
  if regex.match(parsed_data)
    # Para poner los separadores que se quitaron anteriormente
    # Es necesario eliminar la etiqueta span ya que da problemas
    coincidence = $1.gsub(/<span.*?span>/, "").gsub("><", ">\n<")

    # Para conseguir toda la informacion no html
    values = coincidence.scan(/>(.*?)</)

    # Es necesario comprobar que no nos pone estoe en targets
    # A veces debido a la estructura de los recursos no cuadra bien el ciclo
    # Esto permite prevenir errores
    not_targets = ["agonism", "antagonism", "other",
                   "neutral", "inhibitor", "Organism",
                   "agonist", "A", "U"]

    # Los tres primeros campos son la cabezera de la tabla que no nos interesa (además tiene un primer campo vacio)
    n = 3
    while n < (values.length - 1) do
      target = values[n]
      effect = values[n + 1]
      # Es necesario no incluirlo cuando es igual a 1 para evitar introducir datos erroneos
      n += 3
      next if not_targets.include? target[0]

      result << {target: target[0], interaction_type: effect[0]}
    end

  end
  # Si los datos están vacios se devuelve nil
  result.empty? ? nil : {interactions: result}
end

def get_interaction_description(field)
  parsed_div = field.xpath("//div[@class=\"bond-list-container targets\"]")
  parsed_dd =  Nokogiri::HTML(parsed_div.to_s.downcase!)

  # En total hay 10 campos por entrada
  parsed_dd = parsed_dd.xpath("//dd")
  parsed_dd = parsed_dd.map { |n| n.to_s.gsub!(/<.*?>/, "")}
  result = []
  field_type = 0
  field_function = 4
  n = 0
  while n < (parsed_dd.length - 1)
    element_type = parsed_dd[field_type + n]
    element_function = parsed_dd[field_function + n]
    n += 10
    result << {element_type: element_type, element_function: element_function}
  end
  # Si los datos están vacios se devuelve nil
  result.empty? ? nil : {interactions: result}
end

def get_from_kegg(entry, ontology_data)

  url = "http://togows.org/entry/kegg-drug/#{entry}.json"
  res = WebRequest::fetch(url)
  data = JSON.parse(res.body)
  # Genera un diccionario con los campos mostrados en la función #check_entry
  result = check_entry(data)
  # Crea una nueva entrada con los datos solo si todos los campos estan completos
  ontology_data[entry] = result unless result.nil?
  ontology_data
end

def get_from_drugbank(entry)
  uri = URI("https://www.drugbank.ca/drugs/#{entry[0]}")  # DRUGBANK
  res = Net::HTTP.get(uri) # => String

  parsed_data = Nokogiri::HTML.parse(res)
  p_tags = parsed_data.xpath("//p")

  # HECHO ============================ INTERACCIONES DEL FÁRMACO
  # Para conseguir las interacciones
  drug_data = get_interactions(parsed_data)
  drug_data unless drug_data.nil?


  # HECHO ============================ CATEGORIA DEL FÁRMACO

  # Para conseguir la CATEGORIA a la que pertenece un fármaco
  category = get_category(p_tags[0])
  drug_data.merge!(category: category) unless category.nil?

  # HECHO ============================ VIDA MEDIA DEL FÁRMACO
  half_life = get_half_life(p_tags)
  drug_data.merge!(half_life: half_life) unless half_life.nil?


  interacion_description = get_interaction_description(parsed_data)
  drug_data.merge!(interaction_description: interacion_description) unless interacion_description.nil?
  drug_data.merge!(drugbank_id: entry[0])
  drug_data
end

def start_gfw(params = {})
  #initial = params.fetch(:initial, 100_100)
  #iterations = params.fetch(:iterations, 5)

  initial = 100105
  iterations = 1


  ontology_data = {}
  print "Web Scrapping from KEGG .. ["
  iterations.times do |i|
    initial += 1
    entry = "D#{initial.to_s[1..]}"
    ontology_data = get_from_kegg(entry, ontology_data)
    print "/"
  end
  print "]\n\tKEGG INFORMATION OBTAINED !!\n"
  print "\nStarting with DrugBank ...["
  drugbank_ids = ontology_data.map { |key, value| value[:drugbank]}

  ontology_data_ = {}  # hash temporal ya que no se pueden modificar durante una iteracion
  drugbank_ids.each do |drug_id|
    drugbank_data = get_from_drugbank(drug_id)
    ontology_data.each do |entry, value|
      if drugbank_data[:drugbank_id] == value[:drugbank][0]
        ontology_data_[entry] = {kegg: value, drugbank: drugbank_data}
      end
    end
    # merge drugbank_data with ontology_data by key
    print "/"
  end
  ontology_data = ontology_data_
  print "]\n\tDRUGBANK INFORMATION OBTAINED !!\n"
  ontology_data_
end


ontology_data = start_gfw()
csv_output = "name\tother_names\tformula\tmolecular_mass\tdrugbank\tchebi\tcategory\thalf_life\ttarget\titeraction_type\ttarget_type\ttarget_function"
ontology_data.each do |key, value|
  entry = []
  name = value[:kegg][:name].nil? ? "UNKNOWN" : value[:kegg][:name]
  other_names = value[:kegg][:other_names].nil? ? "UNKNOWN" : value[:kegg][:other_names]
  formula = value[:kegg][:formula].nil? ? "UNKNOWN" : value[:kegg][:formula]
  molecular_mass = value[:kegg][:molecular_mass].nil? ? "UNKNOWN" : value[:kegg][:molecular_mass]
  drugbank_id = value[:kegg][:drugbank].nil? ? "UNKNOWN" : value[:kegg][:drugbank]
  chebi_id = value[:kegg][:chebi].nil? ? "UNKNOWN" : value[:kegg][:chebi]
  category = value[:drugbank][:category].nil? ? "UNKNOWN": value[:drugbank][:category]
  half_life = value[:drugbank][:half_life].nil? ? "UNKNOWN" : value[:drugbank][:half_life]

  #puts name
  #puts other_names
  #puts formula
  #puts molecular_mass
  #puts drugbank_id
  #puts chebi_id
  #puts category
  #puts half_life

  entry << name << "\t" << other_names << "\t" << formula << "\t" << molecular_mass << "\t"
  entry << drugbank_id << "\t" << chebi_id << "\t" << category << "\t" << half_life << "\t"

  targets, target_types = [], []
  unless value[:drugbank][:interactions].empty?
    value[:drugbank][:interactions].each do |interaction|
       targets << interaction[:target]
       target_types << interaction[:interaction_type]
    end
  end

  molecule_types, target_fucntions = [], []
  unless value[:drugbank][:interaction_description][:interactions].empty?
    value[:drugbank][:interaction_description][:interactions].each do |interaction|
      molecule_types << interaction[:element_type]
      target_fucntions << interaction[:element_function]
    end
  end

  targets = targets.join("||")
  target_types = target_types.join("||")
  molecule_types = molecule_types.join("||")
  target_fucntions = target_fucntions.join("||")
  puts target_fucntions
  entry << targets << "\t" << target_types << "\t"
  entry << molecule_types << "\t" << target_fucntions << "\n"


  #drug_target = value[:drugbank][:interactions][0][:target]                   # ARRAY TYPE'
  #interaction_type = value[:drugbank][:interactions][0][:interaction_type]    # ARRAY TYPE
  #target_type = value[:drugbank][:interaction_description][:interactions][0][:element_type] # ARRAY TYPE
  #target_function = value[:drugbank][:interaction_description][:interactions][0][:element_function] # ARRAY TYPE

  file = File.exist?("dataset.txt") ? File.open("dataset.txt", "a") : File.open("dataset.txt", "w")
  file << entry.join("")
  file.close

end