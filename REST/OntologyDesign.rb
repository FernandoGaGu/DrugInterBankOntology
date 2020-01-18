#
# @author Fernando García
#
# == Ontology
#
# This module works in conjunction with the RdfGenerator class.
# It is responsible for managing to implement the ontology conceptualization to
# transform non-ontological resources to ontological resources
#
# == Summary
#
# This module contains information about the prefixes required by the ontology and
# the structure of the ontology. The way to create new rdf triples is quite simple
# more information (see #generate_triplet).
# The user can define here the structure of the ontology and will automatically
# generate the corresponding rdf.
#
module Ontology
  # Ontology prefixes
  @prefix = {owl:'https://w3id.org/2002/07/owl#',
             rdf:'https://w3id.org/1999/02/22-rdf-syntax-ns#',
             xsd:'https://w3id.org/2001/XMLSchema#',
             rdfs: 'https://w3id.org/2000/01/rdf-schema#',
             uniprot: 'http://purl.uniprot.org/uniprot/',
             dibo_core:'https://w3id.org/def/DIBO',
             dibo_data:'https://w3id.org/def/DIBO/data/'}

  # To transform different synonyms to consensual names for interaction types
  @interaction_types = {'Agonism' => ['agonism', 'inducer', 'agonist', 'Agonism',
                                      'activator', 'positive allosteric modulator'],
                        'Antagonism' => ['inhibitor', 'antagonism', 'antagonist'],
                        'Neutral' => ['neutral', 'other']}

  # To transform different synonyms to consensual names for molecule type
  @target_types = ['protein', 'drug', 'dna', 'rna']

  # Function in which the structure of the ontology is defined.
  #
  # @param params [Hash] Hash whose structure must match the conceptualization
  #   of the structure in the RdfGenerator class (see class RdfGenerator).
  #
  # @return [Array] Array of triples
  #
  def Ontology.ontology_struct(params)
    rdf_triples = []
    # dibo_data:drug_instance   rdf:ype  dibo_core:Drug
    rdf_triples << generate_triplet({ subject: :dibo_data,
                                      predicate: :rdf,
                                      object: :dibo_core,
                                      subject_data: params['hasDrugBankId'],
                                      predicate_data: 'type',
                                      object_data: '/Drug'})

    # dibo_data:drug_instance  dibo_core:hasScientificName  xsd:ScientificName
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasScientificName',
                                       object_data: "#{params['hasScientificName']}",
                                       datatype: "string" })

    # dibo_data:drug_instance dibo_core:hasMolecularFormula MolecularFormula
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularFormula',
                                       object_data: "#{params['hasMolecularFormula']}",
                                       datatype: "string" })

    # dibo_data:drug_instance dibo_core:hasMolecularMass dibo_data:molecular_mass_instance
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :dibo_data,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasMolecularMass',
                                       object_data: "#{params['hasMolecularMass']}" })

    # dibo_data:molecular_mass_instance rdf:type dibo_core:MolecularMass
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :rdf,
                                       object: :dibo_core,
                                       subject_data: "#{params['hasMolecularMass']}",
                                       predicate_data: 'type',
                                       object_data:  "/MolecularMass"})

    #dibo_data:molecular_mass_instance dibo_core:hasUnit xsd:string
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: "#{params['hasMolecularMass']}",
                                       predicate_data: '#hasUnit',
                                       object_data:  "Da",
                                       datatype: "string"})

    #dibo_data:molecular_mass_instance dibo_core:hasValue xsd:double
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: "#{params['hasMolecularMass']}",
                                       predicate_data: '#hasValue',
                                       object_data:  "#{params['hasMolecularMass']}",
                                       datatype: "double"})

    # dibo_data:drug_instance dibo_core:hasDrugBankId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasDrugBankId',
                                       object_data: "#{params['hasDrugBankId']}",
                                       datatype: "string"  })

    # dibo_data:drug_instance dibo_core:hasChebiId xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasChebiId',
                                       object_data: "#{params['hasChebiId']}",
                                       datatype: "string" })

    # dibo_data:drug_instance dibo_core:functionallyGroupedIn dibo_core:PharmacologicSubstance
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :dibo_core,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#functionallyGroupedIn',
                                       object_data: "/#{params['functionallyGroupedIn']}"})

    # dibo_data:drug_instance dibo_core:hasHalfLife xsd:String
    rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                       predicate: :dibo_core,
                                       object: :xsd,
                                       subject_data: params['hasDrugBankId'],
                                       predicate_data: '#hasHalfLife',
                                       object_data: "#{params['hasHalfLife']}",
                                       datatype: "string"  })

    # dibo_data:drug_instance dibo_core:hasOtherName xsd:String
    params['hasOtherName'].each do |other_name|
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :xsd,
                                         subject_data: params['hasDrugBankId'],
                                         predicate_data: '#hasOtherName',
                                         object_data: "#{other_name}",
                                         datatype: "string" })
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
                                         object_data: "#{target_info[0]}" })

      # dibo_data:target_instance rdf:type dibo_core:Protein/Drug/DNA/RNA
      target_type = get_target_type target_info[2]
      return false if target_type.nil?
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: target_info[0],
                                         predicate_data: 'type',
                                         object_data: "/#{target_type}" })

      # dibo_data:target_instance dibo_core:hasFunction xsd:String
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :xsd,
                                         subject_data: target_info[0],
                                         predicate_data: '#hasFunction',
                                         object_data: "#{target_info[3]}",
                                         datatype: "string" })

      # dibo_data:target_instance dibo_core:hasName xsd:String
      return false if target_info[0].nil?
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :xsd,
                                         subject_data: target_info[0],
                                         predicate_data: '#hasName',
                                         object_data: "#{target_info[0].gsub("_", " ")}",
                                         datatype: "string"})

      # dibo_data:target_instance owl:equivalentClass uniprot:target_uniprot_id
      return false if target_info[4].nil?
      if target_type == "Protein"
        rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                           predicate: :owl,
                                           object: :uniprot,
                                           subject_data: target_info[0],
                                           predicate_data: 'equivalentClass',
                                           object_data: "#{target_info[4].upcase.gsub(" ", "_")}" })
      end


      # dibo_data:interaction_instance dibo_core:hasDrug dibo_data:drug_instance
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :dibo_core,
                                         object: :dibo_data,
                                         subject_data: interaction_URI,
                                         predicate_data: '#hasDrug',
                                         object_data: "#{params['hasDrugBankId']}" })

      # dibo_data:drug_instance rdf:type dibo_core:Drug
      rdf_triples <<  generate_triplet({ subject: :dibo_data,
                                         predicate: :rdf,
                                         object: :dibo_core,
                                         subject_data: "#{params['hasDrugBankId']}",
                                         predicate_data: 'type',
                                         object_data: "/Drug" })
    end
    # Return rdf_triples
    rdf_triples
  end

  # Function that standardizes the type of interaction, if it is not defined add "Neutral"
  # and displays a warning message.
  #
  # @param params [Hash] Hash wth drug-target interaction info
  #
  # @return [String] Interaction type
  #
  def Ontology.get_interaction_type(interaction)
    @interaction_types.each do |ontology_interaction, synonyms|
      return ontology_interaction if synonyms.include?(interaction.to_s.downcase)
    end
    puts "WARNING: Interaction type not present in synonyms list !!!!! -> #{interaction}"
    return 'Neutral'
  end

  # Function that standardizes the molecule type. If it is not defined
  # displays a warning message.
  #
  # @param params [String] Molecule type
  #
  # @return [String] Standard molecule type
  #
  def Ontology.get_target_type(target)
    @target_types.each do |target_type|
      return target_type.capitalize if target.downcase == target_type
    end
    puts "WARNING: Target type not protein/DNA/RNA/Drug -> #{target}"
    # return nil if the target type not match @target_types
    nil
  end

  # It allows to generate triples from the information of the prefix of the subject,
  # predicate and object and the values that each one will have.
  # This function allows the creation of new triples in a simple and comfortable way.
  #
  # @param params [Hash] Triplet information
  # @option opts [Symbol] :subject Subject prefix key
  # @option opts [Symbol] :predicate Predicate prefix key
  # @option opts [Symbol] :object Object prefix key
  # @option opts [String] :subject_data Subject data
  # @option opts [String] :predicate_data Predicate data
  # @option opts [String] :object_data Object data
  # @option opts [String] :datatype Optional param, It is only requiered for xsd prefix
  #
  # @return [String] Triplet
  #
  def Ontology.generate_triplet(params = {})
    subject = params.fetch(:subject, nil)
    predicate = params.fetch(:predicate, nil)
    object = params.fetch(:object, nil)
    subject_data = params.fetch(:subject_data, nil)
    predicate_data = params.fetch(:predicate_data, nil)
    object_data = params.fetch(:object_data, nil)

    # Create subject URI
    subject_construct = "<#{@prefix[subject]}#{subject_data}>\t"
    # Create predicate URI
    predicate_construct = "<#{@prefix[predicate]}#{predicate_data}>\t"

    if object == :xsd    # Create object xsd datatype URI
      datatype = params.fetch(:datatype, "string")
      object_contruct = "\"#{object_data}\"^^<#{@prefix[:xsd]}#{datatype}> ."
    else                 # Create a object URI
      object_contruct = "<#{@prefix[object]}#{object_data}> ."
    end
    RdfGenerator.new_triplet
    return (subject_construct + predicate_construct + object_contruct)
  end

end

