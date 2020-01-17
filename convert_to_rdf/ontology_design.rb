module Ontology
  @prefix = {owl:'<https://w3id.org/2002/07/owl#',
             rdf:'<https://w3id.org/1999/02/22-rdf-syntax-ns#',
             xsd:'<https://w3id.org/2001/XMLSchema#',
             rdfs: '<https://w3id.org/2000/01/rdf-schema#',
             dibo_core:'<https://w3id.org/def/DIBO',
             dibo_data:'<https://w3id.org/def/DIBOdata',
             string_type: '"^^xsd:string'}

  def Ontology.ontology_struct(params)
    rdf_triples = []
    # drug instance   type  Drug
    rdf_triples << generate_triplet({ subject: :dibo_data,
                                      predicate: :rdf,
                                      object: :dibo_core,
                                      subject_data: params['hasDrugBankId'],
                                      predicate_data: 'type',
                                      object_data: '/Drug'})

    # drug instance   hasScientificName  ScientificName
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasScientificName',
                                       object_data: "#{params['hasScientificName']}" })

    # drug instance hasMolecularFormula MolecularFormula
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularFormula',
                                       object_data: "#{params['hasMolecularFormula']}" })

    # drug instance hasMolecularMass MolecularMass
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularMass',
                                       object_data: "#{params['hasMolecularMass']}" })

    # drug instance hasDrugBankId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasDrugBankId',
                                       object_data: "#{params['hasDrugBankId']}" })

    # drug instance hasChebiId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasChebiId',
                                       object_data: "#{params['hasChebiId']}" })

    # drug instance functionallyGroupedIn xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#functionallyGroupedIn',
                                       object_data: "#{params['functionallyGroupedIn']}" })

    # drug instance hasHalfLife xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :string_type,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasHalfLife',
                                       object_data: "#{params['hasHalfLife']}" })


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

    return (subject_construct + predicate_construct + object_contruct)
  end

end
