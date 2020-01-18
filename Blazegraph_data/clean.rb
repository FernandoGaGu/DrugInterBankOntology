remove = "\"The plasma half-life is approximately 2-3 minutes. However, when administered by subcutaneous or intramuscular injection, local vasoconstriction may delay absorption so that epinephrine's effects may last longer than the half-life suggests <sup class=\"text-reference-group\"><a class=\"reference-popover-link\" data-content=\"Medicines UK document\" href=\"#reference-L4361\">13</a></sup>.\"^^<https://w3id.org/2001/XMLSchema#string> ."
substitute = "\"UNKOWN\"^^<https://w3id.org/2001/XMLSchema#string> ."

file_string = File.read("DIBO_Data_3.rdf")
new_document = file_string.gsub(remove, substitute)
File.open("DIBO_data_3.clean.rdf", "w") { |file| file.puts new_document}