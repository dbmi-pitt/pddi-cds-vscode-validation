library WarfarinNSAIDsCDS version '1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers



codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'

// NOTE: Valuesets should reference valuesets url in external folder
valueset "Topical Diclofenac": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-topicaldiclofenac'
valueset "Warfarins": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-warfarin'
valueset "NSAIDs": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-NSAIDS'
valueset "PPIs and Misoprostols": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-PPIS'
valueset "History of GI Bleeds": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-Hx-UGIB-snomed'
valueset "Systemic Corticosteroids": 'valueset-SCS'
valueset "Aldosterone Antagonists": 'valueset-AAS'


parameter ContextPrescriptionStatements List<MedicationStatement>
parameter ContextPrescriptionRequests List<MedicationRequest>
parameter ContextConditions List<Condition>


context Patient
// NOTE: These functions have been moved here from the Commmon library to boost performance
define function GetLevelAndDate(observation Observation):
  if observation is not null
    then ToString(ToQuantity(observation.value as Quantity))
      + ' and '
      + ToString(observation.effective.value)
  else 'NA'

define function GetMedicationNames(medications List<MedicationStatement>):
  medications M
    return ToCode(M.medication.coding[0]).display

define function GetCodeNames(codings List<FHIR.Coding>):
  Combine(
      codings coding
          return ToCode(coding).display
    , ', ')

define function ToCode(coding FHIR.Coding):
  System.Code {
    code: coding.code.value,
    system: coding.system.value,
    version: coding.version.value,
    display: coding.display.value
  }

define function ToQuantity(quantity FHIR.Quantity):
  System.Quantity { value: quantity.value.value, unit: quantity.unit.value }

define function ToString(value FHIR.Coding): value.display.value
define function ToString(value Code): value.display

define "Is context medication topical diclofenac":
  exists ("Topical Diclofenac Prescription")

define "Is not context medication topical diclofenac":
  not exists ("Topical Diclofenac Prescription")

define "Topical Diclofenac Prescription":
  (
   ContextPrescriptionStatements P
     where ToCode(P.medication.coding[0]) in "Topical Diclofenac"
     return P.medication.coding[0]
  ) 
  union
  (
   ContextPrescriptionRequests P
     where ToCode(P.medication.coding[0]) in "Topical Diclofenac"
     return P.medication.coding[0]
  )

define "Inclusion Criteria":
   "NSAID Rx exists" 
    and 
  "Warfarin Rx exists"


define "Warfarin Rx exists":
  exists ("Warfarin Rx")

define "Warfarin Rx":
   (
      [MedicationStatement: "Warfarins"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01 
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Warfarins"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01 
      return MR.medication.coding[0]
    )

define "NSAID Rx exists":
  exists ("NSAID Prescription")

define "NSAID Prescription":
 ( 
    [MedicationStatement: "NSAIDs"] P
      where P.effective.start.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01 
     return P.medication.coding[0]
  )
  union 
  ( 
    [MedicationRequest: "NSAIDs"] P
      where P.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01 
     return P.medication.coding[0]
  )
// Card 1: Base
define "Get Base Summary":
  'Potential Drug-Drug Interaction between warfarin ('
    + GetCodeNames("Warfarin Rx")
    + ') and NSAID ('
    + GetCodeNames("NSAID Prescription")
    + ').' 

define "Get Concomitant Description":
  if "Is context medication topical diclofenac"
    then 'Topical diclofenac has relatively low systemic absorption; in one study a topical gel (16 g/day) produced about 6% of the absorption seen with systemic administration of 150 mg/day. A higher than recommended dose of topical gel (48 g/day) produced 20% of a systemic dose of diclofenac.'
  else 'Increased risk of bleeding. \nBleeding is a serious potential clinical consequence because it can result in death, life-threatening hospitalization, and disability. \nNon-steroidal anti-inflammatory drugs (NSAIDs) have antiplatelet effects which increase the bleeding risk when combined with oral anticoagulants such as warfarin. The antiplatelet effect of NSAIDs lasts only as long as the NSAID is present in the circulation, unlike aspirin’s antiplatelet effect, which lasts for up to 2 weeks after aspirin is discontinued. NSAIDs also can cause peptic ulcers and most of the evidence for increased bleeding risk with NSAIDs plus warfarin is due to upper gastrointestinal bleeding (UGIB). \nunknown. \n unknown.'
      
define "Get Base Indicator":
  if "Is context medication topical diclofenac"
    then 'info'
  else 'warning'


define "Acetaminophen 325 MG": Code '313782' from "RXNORM" display 'Acetaminophen 325 MG Oral Tablet'
define "Acetaminophen 500 MG": Code '198440' from "RXNORM" display 'Acetaminophen 500 MG Oral Tablet'

define "Get Base Label 1":
  'Substitute NSAID ('
  + GetCodeNames("NSAID Prescription")
  + ') with APAP ('
  + ToString("Acetaminophen 325 MG")
  + ').'

define "Get Base Label 2":
  'Substitute NSAID ('
  + GetCodeNames("NSAID Prescription")
  + ') with APAP ('
  + ToString("Acetaminophen 500 MG")
  + ').' 

// Card 2: PPI or misoprostol
define "Get Card 2 Indicator":
  if "Taking PPI or misoprostol"
    then 'info'
  else 'critical'

define "Get Card 2 Summary":
  if "Taking PPI or misoprostol"
    then 'Patient is taking a proton pump inhibitor ('
    + GetCodeNames("PPIs and Misoprostols Rx")
    + ').' 
  else 'Patient is not taking a proton pump inhibitor or misoprostol.'

define "Get Card 2 Detail":
  'Proton pump inhibitors and misoprostol may reduce the risk of UGIB in patients receiving NSAIDs and warfarin.'

define "Get Card 2 Label":
  if "Taking PPI or misoprostol"
    then 'Assess risk and take action if necessary.'
  else 'Use only if benefit outweighs risk.'


define "Taking PPI or misoprostol":
  exists ("PPIs and Misoprostols Rx")

define "PPIs and Misoprostols Rx":
    (
      [MedicationStatement: "PPIs and Misoprostols"] MS
        where MS.effective.start.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01 
        return MS.medication.coding[0]
    )

// Card 3: History of UGIB/peptic ulcer or > 65 years old
define "Get Card 3 Indicator":
  if "Age > 65 years or Hx UGIB"
    then 'warning'
  else 'info'

define "Get Card 3 Summary":
  if "Age > 65 years or Hx UGIB"
    then 'Patient\'s age is at least 65 years old or the patient does have a history of upper gastrointestinal bleed '
    + ' (patient is ' + ToString(AgeInYears()) + ' years old. GI condition on record: '
    + GetCodeNames("GI Bleeds Condition")
    + ').' 
    else 'Patient is not 65 y/o and does not have a history of upper gastrointestinal bleed.'
 

define "Get Card 3 Detail":
  'Patients with a history of UGIB or peptic ulcer may have an increased risk of UGIB from this interaction. The extent to which older age is an independent risk factor for UGIB due to these interactions is not firmly established, but UGIB in general is known to increase with age.'

define "Get Card 3 Label":
  if "Taking PPI or misoprostol"
    then 'Assess risk and take action if necessary.'
  else if "Age > 65 years or Hx UGIB"
    then 'Use only if benefit outweighs risk.'
  else 'Assess risk and take action if necessary.'


define "Age > 65 years or Hx UGIB":
   "GI Bleeds Condition" is not null
   or
   AgeInYears() > 65

define "GI Bleeds Condition":
      (
       [Condition] C  // This fails using [Condition "History of GI Bleeds"] using the OMOPonFHIR server with synthetic data due to an internal error
       where ToCode(C.code.coding[0]) in "History of GI Bleeds"
       return C.code.coding[0]
       )