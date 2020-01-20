file_input = File.read("RDF_DATA.rdf")
file_input = file_input.gsub('ns0', 'dibo')
File.open("DIBO_DEFINITIVE.owl", "w") { |file| file.puts file_input}