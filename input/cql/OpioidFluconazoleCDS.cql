library OpioidFluconazoleCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'
codesystem "v3-ActCode":'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem "LOINC": 'http://loinc.org'

valueset "Fentanyls": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-fentanyl'
valueset "Oxycodones": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-oxycodone'
valueset "Fluconazoles": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-fluconazole'
valueset "InpatientEncounters": 'http://terminology.hl7.org/ValueSet/v3-ActEncounterCode'
valueset "eGFR":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-eGFR'


parameter ContextPrescriptionStatements List<MedicationStatement>
parameter ContextPrescriptionRequests List<MedicationRequest>

context Patient

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

define "Fentanyl Rx":
    (
      [MedicationStatement: "Fentanyls"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Fentanyls"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "Oxycodone Rx":
    (
      [MedicationStatement: "Oxycodones"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Oxycodones"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Fluconazoles Rx":
 (
      [MedicationStatement: "Fluconazoles"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Fluconazoles"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "Inpatient Visit":
  (
  [Encounter: "InpatientEncounters"] I
    where (Today() - 100 days) < I.period.start.value
  )

define "Low eGFR":
  (
      [Observation: "eGFR"] EG
      where
        (System.Quantity { 
         value: (EG.value).value, unit: 'ml/min' 
            } < 30 'ml/min' 
    )
  )
define "High eGFR":
  (
      [Observation: "eGFR"] EG
      where
        (System.Quantity { 
         value: (EG.value).value, unit: 'ml/min' 
            } > 30 'ml/min' 
    )
  )


    