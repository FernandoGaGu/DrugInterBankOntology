module Ontology
  @prefix = {owl:'<https://w3id.org/2002/07/owl#',
             rdf:'<https://w3id.org/1999/02/22-rdf-syntax-ns#',
             xsd:'<https://w3id.org/2001/XMLSchema#>',
             rdfs: '<https://w3id.org/2000/01/rdf-schema#',
             dibo_core:'<https://w3id.org/def/DIBO',
             dibo_data:'<https://w3id.org/def/DIBO/data',
             string_type: '"^^xsd:string'}

  # To transform different synonyms to consensual names for interaction types
  @interaction_types = {'Agonism' => ['agonism', 'inducer', 'agonist'],
                        'Antagonism' => ['inhibitor', 'antagonism'],
                        'Neutral' => ['neutral', 'other']}

  # To transform different synonyms to consensual names for molecule type
  @target_types = ['protein', 'drug', 'dna', 'rna']

  def Ontology.ontology_struct(params)
    rdf_triples = []
    # dibo_data:interaction_instance   trdf:ype  dibo_core:Drug
    rdf_triples << generate_triplet({ subject: :dibo_data,
                                      predicate: :rdf,
                                      object: :dibo_core,
                                      subject_data: params['hasDrugBankId'],
                                      predicate_data: 'type',
                                      object_data: '/Drug'})

    # dibo_data:interaction_instance  dibo_core:hasScientificName  xsd:ScientificName
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasScientificName',
                                       object_data: "#{params['hasScientificName']}" })

    # dibo_data:interaction_instance hasMolecularFormula MolecularFormula
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularFormula',
                                       object_data: "#{params['hasMolecularFormula']}" })

    # dibo_data:interaction_instance hasMolecularMass MolecularMass
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularMass',
                                       object_data: "#{params['hasMolecularMass']}" })

    # dibo_data:interaction_instance hasDrugBankId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasDrugBankId',
                                       object_data: "#{params['hasDrugBankId']}" })

    # dibo_data:interaction_instance hasChebiId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasChebiId',
                                       object_data: "#{params['hasChebiId']}" })

    # dibo_data:interaction_instance functionallyGroupedIn xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#functionallyGroupedIn',
                                       object_data: "#{params['functionallyGroupedIn']}" })

    # dibo_data:interaction_instance hasHalfLife xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasHalfLife',
                                       object_data: "#{params['hasHalfLife']}" })

    # dibo_data:interaction_instance hasOtherName xsd:String
    params['hasOtherName'].each do |other_name|
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :string_type,
                                         subject_data: params['hasDrugBankId'],
                                         predicate_data: '#hasOtherName',
                                         object_data: "#{other_name}" })
    end


    params['hasTarget'].each do |target_info|

      # If there is some field empty return false
      return false if target_info.nil?
      target_info.each { |value| return false if value.nil?}


      # Interaction is a N-ary class 
      interaction_URI = RdfGenerator.unique_identifier

      # dibo_data:interaction_instance rdf:type dibo_core:Agonism/Antagonism/Neutral
      interaction_type = get_interaction_type target_info[1]
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: interaction_URI,
                                         predicate_data: 'type',
                                         object_data: "/#{interaction_type}" })
      
      # dibo_data:interaction_instance dibo_core:hasTarget dibo_data:target_instance
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :dibo_data,
                                         subject_data: interaction_URI,
                                         predicate_data: '#hasTarget',
                                         object_data: "/#{target_info[0]}" })

      # dibo_data:target_instance rdf:type dibo_core:Protein/Drug/DNA/RNA
      target_type = get_target_type target_info[2]
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: target_info[0],
                                         predicate_data: 'type',
                                         object_data: "/#{target_type}" })

      # dibo_data:target_instance dibo_core:hasFunction xsd:String
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :string_type,
                                         subject_data: target_info[0],
                                         predicate_data: '#hasFunction',
                                         object_data: "#{target_info[3]}" })

      # dibo_data:target_instance dibo_core:hasName xsd:String
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :string_type,
                                         subject_data: target_info[0],
                                         predicate_data: '#hasName',
                                         object_data: "#{target_info[0].gsub("_", " ")}" })

      # dibo_data:interaction_instance dibo_core:hasDrug dibo_data:drug_instance
      interaction_type = get_interaction_type target_info[1]
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :dibo_data,
                                         subject_data: interaction_URI,
                                         predicate_data: '#hasDrug',
                                         object_data: "/#{params['hasDrugBankId']}" })


      # dibo_data:drug_instance rdf:type dibo_core:Drug
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: "/#{params['hasDrugBankId']}",
                                         predicate_data: 'type',
                                         object_data: "/Drug" })


    end




    return rdf_triples

  end

  def Ontology.get_interaction_type(interaction)
    @interaction_types.each do |ontology_interaction, synonyms|
      return ontology_interaction if synonyms.include?(interaction.to_s.downcase)
    end
    puts "WARNING: Interaction type not present in synonyms list !!!!!"
    return 'Neutral'
  end

  def Ontology.get_target_type(target)
    puts "WARNING: Target type not protein/DNA/RNA/Drug -> #{target}" unless @target_types.include?(target.downcase)
    target.capitalize
  end

  def Ontology.generate_triplet(params = {})
    subject = params.fetch(:subject, nil)
    predicate = params.fetch(:predicate, nil)
    object = params.fetch(:object, nil)
    subject_data = params.fetch(:subject_data, nil)
    predicate_data = params.fetch(:predicate_data, nil)
    object_data = params.fetch(:object_data, nil)

    subject_construct = "#{@prefix[subject]}/#{subject_data}>\t"
    predicate_construct = "#{@prefix[predicate]}#{predicate_data}>\t"
    if object == :string_type
      object_contruct = "\"#{object_data}\"^^#{@prefix[:xsd]} ."
    else
      object_contruct = "#{@prefix[object]}#{object_data}> ."
    end
    RdfGenerator.new_triplet
    return (subject_construct + predicate_construct + object_contruct)
  end

end
