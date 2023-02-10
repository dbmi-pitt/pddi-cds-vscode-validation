library CitalopramQtProlongingAgentCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'

valueset "Citaloprams": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-citaloprams'
valueset "QT Prolonging Agents": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-QT-prolonging-agents'

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

define "Citalopram Rx":
    (
      [MedicationStatement: "Citaloprams"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01 
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Citaloprams"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01 
      return MR.medication.coding[0]
    )


define "QT Prolonging Rx":
    (
      [MedicationStatement: "QT Prolonging Agents"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01 
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "QT Prolonging Agents"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01 
      return MR.medication.coding[0]
    )


define "Citalopram Not High Dosage, QT":
  if 
  exists "QT Prolonging Rx"
  and
  ( exists
    (
    [MedicationStatement: "Citaloprams"] MS
    where 
        (System.Quantity { 
              value: (MS.dosage[0].doseAndRate[0].dose).value * 
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d' 
            } < 60 'mg/d' 
        )
    )
    or exists 
    (
    [MedicationRequest: "Citaloprams"] MR
    where 
      (System.Quantity { 
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value * 
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d' 
            } < 60 'mg/d' 
    )
    )
  )
  then true else false

define "Citalopram Not High Dosage, No QT":
 if 
  not exists "QT Prolonging Rx"
  and
  ( exists
    (
    [MedicationStatement: "Citaloprams"] MS
    where 
        (System.Quantity { 
              value: (MS.dosage[0].doseAndRate[0].dose).value * 
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d' 
            } < 60 'mg/d' 
        )
    )
    or exists 
    (
    [MedicationRequest: "Citaloprams"] MR
    where 
      (System.Quantity { 
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value * 
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d' 
            } < 60 'mg/d' 
    )
    )
  )
  then true else false

define "Citalopram High Dosage, QT":
   if 
  exists "QT Prolonging Rx"
  and
  ( exists
    (
    [MedicationStatement: "Citaloprams"] MS
    where 
        (System.Quantity { 
              value: (MS.dosage[0].doseAndRate[0].dose).value * 
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d' 
            } >= 60 'mg/d' 
        )
    )
    or exists 
    (
    [MedicationRequest: "Citaloprams"] MR
    where 
      (System.Quantity { 
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value * 
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d' 
            } >= 60 'mg/d' 
    )
    )
  )
  then true else false


define "Citalopram High Dosage, No QT": 
   if 
   not exists "QT Prolonging Rx"
   and
  ( exists
    (
    [MedicationStatement: "Citaloprams"] MS
    where 
        (System.Quantity { 
              value: (MS.dosage[0].doseAndRate[0].dose).value * 
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d' 
            } >= 60 'mg/d' 
        )
    )
    or exists 
    (
    [MedicationRequest: "Citaloprams"] MR
    where 
      (System.Quantity { 
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value * 
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d' 
            } >= 60 'mg/d' 
    )
    )
  )
  then true else false
  


define "Recommendation":
  if "Citalopram High Dosage, No QT" then ' Minimize risk and monitor ECG'
  else if "Citalopram High Dosage, QT" then ' Use only if benefit outweighs risk and monitor patient ECG'
  else if "Citalopram Not High Dosage, No QT" then ' No special precaution'
  else if "Citalopram Not High Dosage, QT" then ' No special precaution'
  else null


define "Rationale":
  if "Citalopram High Dosage, No QT" then ' Increased risk of prolonged QTc possible'
  else if "Citalopram High Dosage, QT" then ' Increased risk of prolonged QTc likely'
  else if "Citalopram Not High Dosage, No QT" then ' No special precaution'
  else if "Citalopram Not High Dosage, QT" then ' No special precaution'
  else null
