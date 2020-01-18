module Ontology
  @prefix = {owl:'<https://w3id.org/2002/07/owl#',
             rdf:'<https://w3id.org/1999/02/22-rdf-syntax-ns#',
             xsd:'<https://w3id.org/2001/XMLSchema#',
             rdfs: '<https://w3id.org/2000/01/rdf-schema#',
             dibo_core:'<https://w3id.org/def/DIBO',
             dibo_data:'<https://w3id.org/def/DIBOdata',
             string_type: '"^^xsd:string'}

  # To transform different synonyms to consensual names for interaction types
  @interaction_types = {'Agonism' => ['agonism', 'inducer'],
                        'Antagonism' => ['inhibitor', 'antagonism'],
                        'Neutral' => ['neutral', 'other']}

  # To transform different synonyms to consensual names for molecule type
  @target_types = ['Protein', 'Drug', 'DNA', 'RNA']

  def Ontology.ontology_struct(params)
    rdf_triples = []
    # drug_instance   type  Drug
    rdf_triples << generate_triplet({ subject: :dibo_data,
                                      predicate: :rdf,
                                      object: :dibo_core,
                                      subject_data: params['hasDrugBankId'],
                                      predicate_data: 'type',
                                      object_data: '/Drug'})

    # drug_instance   hasScientificName  ScientificName
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasScientificName',
                                       object_data: "#{params['hasScientificName']}" })

    # drug_instance hasMolecularFormula MolecularFormula
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularFormula',
                                       object_data: "#{params['hasMolecularFormula']}" })

    # drug_instance hasMolecularMass MolecularMass
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularMass',
                                       object_data: "#{params['hasMolecularMass']}" })

    # drug_instance hasDrugBankId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasDrugBankId',
                                       object_data: "#{params['hasDrugBankId']}" })

    # drug_instance hasChebiId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasChebiId',
                                       object_data: "#{params['hasChebiId']}" })

    # drug_instance functionallyGroupedIn xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#functionallyGroupedIn',
                                       object_data: "#{params['functionallyGroupedIn']}" })

    # drug_instance hasHalfLife xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasHalfLife',
                                       object_data: "#{params['hasHalfLife']}" })

    # drug_instance hasOtherName xsd:String
    params['hasOtherName'].each do |other_name|
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :string_type,
                                         subject_data: params['hasDrugBankId'],
                                         predicate_data: '#hasOtherName',
                                         object_data: "#{other_name}" })
    end


    params['hasTarget'].each do |target_info|
      #puts "Target inf"
      #puts target_info.to_s
      # drug_instance hasTarget xsd:String
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :string_type,
                                         subject_data: params['hasDrugBankId'],
                                         predicate_data: '#hasTarget',
                                         object_data: "#{target_info[0]}" })

      # Interaction_type rdf:type dibo:Interaction
      interaction_type = get_interaction_type target_info[2]
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: RdfGenerator.unique_identifier,
                                         predicate_data: 'type',
                                         object_data: "/#{interaction_type}" })

      # target_instance rdf:type dibo:Target
      target_type = get_target_type target_info[1]
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: target_info[0],
                                         predicate_data: 'type',
                                         object_data: "/#{target_type}" })

      # target_instance dibo:hasFunction xsd:String
      target_type = get_target_type target_info[1]
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :string_type,
                                         subject_data: target_info[0],
                                         predicate_data: 'hasFunction',
                                         object_data: "#{target_info[3]}" })

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

    puts "WARNING: Target type not protein/DNA/RNA/Drug #{target}" unless @target_types.include?(target.capitalize)
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
      object_contruct = "\"#{object_data}#{@prefix[object]} ."
    else
      object_contruct = "#{@prefix[object]}#{object_data}> ."
    end
    RdfGenerator.new_triplet
    return (subject_construct + predicate_construct + object_contruct)
  end

end
