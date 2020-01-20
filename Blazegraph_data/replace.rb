file_input = File.read("RDF_long.rdf")
file_input = file_input.gsub('ns0', 'dibo')
File.open("DIBO_DEFINITIVE.long.owl", "w") { |file| file.puts file_input}
