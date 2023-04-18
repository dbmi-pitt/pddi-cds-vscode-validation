library AceArbPotassiumSparingCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'
codesystem "LOINC": 'http://loinc.org'

valueset "ACEis and ARBs": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-ACEis-ARBs'
valueset "Potassium Sparing Diuretic": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-potassium-sparing-diuretic'
valueset "eGFR":'https://loinc.org/kb/users-guide/loinc-technical-briefs/choosing-the-correct-loinc-for-estimated-glomerular-filtration-rate/'

code "Potassium Concentration": '2823-3' from "LOINC" display 'Potassium [Moles/volume] in Serum or Plasma'

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

define "ACEis and ARBs Rx":
    (
      [MedicationStatement: "ACEis and ARBs"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "ACEis and ARBs"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "Potassium Sparing Diuretic Rx":
    (
      [MedicationStatement: "Potassium Sparing Diuretic"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Potassium Sparing Diuretic"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


// Refer to class when looking at observation, and lists codes in above
define "High Potassium":
 (
  [Observation: "Potassium Concentration"] PC
    where System.Quantity {
        value: (PC.value).value, unit: 'mmol/L'
    } >= 5 'mmol/L'
    and
    (Today() - 100 days) < PC.effective.value
 )

define "Low Potassium":
(
  [Observation: "Potassium Concentration"] PC
    where System.Quantity {
        value: (PC.value).value, unit: 'mmol/L'
    } < 5 'mmol/L'
    and
    (Today() - 100 days) < PC.effective.value
 )

define "Low eGFR":
  (
      [Observation: "eGFR"] EG
      where
        (System.Quantity {
         value: (EG.value).value, unit: 'ml/min'
            } <= 60 'ml/min'
        )
        and
        (Today() - 100 days) < EG.effective.value
  )


define "High eGFR":
  (
      [Observation: "eGFR"] EG
      where
        (System.Quantity {
         value: (EG.value).value, unit: 'ml/min'
            } > 60 'ml/min'
        )
        and
        (Today() - 100 days) < EG.effective.value
  )




define "Inclusion criteria":
exists "ACEis and ARBs Rx"
and
exists "Potassium Sparing Diuretic Rx"

// Next steps define alerts based on above defined criteria
define "Potassium Concentration less than 5 mmol/L":
"Inclusion criteria"
and
exists "High Potassium"

define "eGRF less than 60 mL/min":
"Inclusion criteria"
and exists "Low Potassium"
and exists "Low eGFR"

define "Appropriate Potassium and Renal Function":
"Inclusion criteria"
and exists "Low Potassium"
and exists "High eGFR"




