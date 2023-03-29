library ImmunosuppressantsFluconazoleCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'

valueset "Immunosuppressant": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-immunosuppressants'
valueset "PO Fluconazoles": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-pofluconazoles'
valueset "IV Fluconazoles": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-ivfluconazoles'

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

define "Immunosuppressant Rx":
    (
      [MedicationStatement: "Immunosuppressant"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Immunosuppressant"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "PO Fluconazoles Rx":
    (
      [MedicationStatement: "PO Fluconazoles"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "PO Fluconazoles"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "IV Fluconazoles Rx":
 (
      [MedicationStatement: "IV Fluconazoles"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "IV Fluconazoles"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "Low dose PO fluconazole":
(
    [MedicationStatement: "PO Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } < 100 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "PO Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } < 100 'mg/d'
    )
    )
define "High dose PO fluconazole":
(
    [MedicationStatement: "PO Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 100 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "PO Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 100 'mg/d'
    )
    )

define "Low dose IV fluconazole":
(
    [MedicationStatement: "IV Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } < 200 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "IV Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } < 200 'mg/d'
    )
    )

define "High dose IV fluconazole":
(
    [MedicationStatement: "IV Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 200 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "IV Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 200 'mg/d'
    )
    )

define "Low dose PO Fluconazole with Immunosuppressant":
exists "Immunosuppressant Rx"
and exists "Low dose PO fluconazole"


define "High dose PO Fluconazole with Immunosuppressant":
if
  exists "Immunosuppressant Rx"
  and
( exists
    (
    [MedicationStatement: "PO Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 100 'mg/d'
        )
    )
    or exists
    (
    [MedicationRequest: "PO Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 100 'mg/d'
    )
    )
  )
  then true else false


define "High dose IV Fluconazole with Immunosuppressant":
if
  exists "Immunosuppressant Rx"
  and
( exists
    (
    [MedicationStatement: "IV Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 200 'mg/d'
        )
    )
    or exists
    (
    [MedicationRequest: "IV Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 200 'mg/d'
    )
    )
  )
  then true else false

define "Low dose IV Fluconazole with Immunosuppressant":
 if
  exists "Immunosuppressant Rx"
  and
  ( exists
    (
    [MedicationStatement: "IV Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } < 200 'mg/d'
        )
    )
    or exists
    (
    [MedicationRequest: "IV Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } < 200 'mg/d'
    )
    )
  )
 then true else false

define "Age greater than 18 years":
 AgeInYears() > 18
/*
 and
exists "PO Fluconazoles Rx"
and
exists "IV Fluconazoles Rx"
*/



/*

define "Recommendation":
  if ("Low dose IV Fluconazole with Immunosuppressant" or "Low dose PO Fluconazole with Immunosuppressant")
      then 'No special precaution'
  else if ("High dose IV Fluconazole with Immunosuppressant" or "High dose PO Fluconazole with Immunosuppressant")
      then 'Use only if benefit outweighs risk'
  else if "Age greater than 18 years"
      then 'Use only if benefit outweighs risk'
  else null


define "Rationale":
  if ("Low dose IV Fluconazole with Immunosuppressant" or "Low dose PO Fluconazole with Immunosuppressant")
      then 'Increased risk of immunosuppressant toxicity unlikely'
  else if ("High dose IV Fluconazole with Immunosuppressant" or "High dose PO Fluconazole with Immunosuppressant")
      then 'Increased risk of immunosuppressant toxicity likely'
  else if "Age greater than 18 years"
      then 'Increased risk of immunosuppressant toxicity likely'
  else null
*/

