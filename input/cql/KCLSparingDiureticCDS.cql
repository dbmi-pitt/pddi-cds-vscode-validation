library KCLSparingDiureticCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'
codesystem "LOINC": 'http://loinc.org'

valueset "KCL": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-potassiums'
valueset "Spironolactone": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-spironolactones'
valueset "Amiloride":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-amilorides'
valueset "Eplerenone":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-eplerenones'
valueset "Triamterene":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-triamterenes'

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

define "KCL Rx":
    (
      [MedicationStatement: "KCL"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "KCL"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "Spironolactone Rx":
    (
      [MedicationStatement: "Spironolactone"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Spironolactone"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Amiloride Rx":
    (
      [MedicationStatement: "Amiloride"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Amiloride"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Eplerenone Rx":
    (
      [MedicationStatement: "Eplerenone"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Eplerenone"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Triamterene Rx":
    (
      [MedicationStatement: "Triamterene"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Triamterene"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


// Refer to class when looking at observation, and lists codes in above
define "High Potassium":
 (
  [Observation: "Potassium Concentration"] PC
    where System.Quantity {
        value: (PC.value).value, unit: 'mmol/L'
    } >= 5.5 'mmol/L'
 )

define "Low Potassium":
(
  [Observation: "Potassium Concentration"] PC
    where System.Quantity {
        value: (PC.value).value, unit: 'mmol/L'
    } < 5.5 'mmol/L'
 )


define "Potassium between 5 and 5.5 within 48 hrs":
exists (
  [Observation: "Potassium Concentration"] PC
    where System.Quantity {
        value: (PC.value).value, unit: 'mmol/L'
    } < 5.5 'mmol/L'
    and
    (Today() - 100 days) < PC.effective.value
 )
and
exists (
  [Observation: "Potassium Concentration"] PC
    where System.Quantity {
        value: (PC.value).value, unit: 'mmol/L'
    } > 5 'mmol/L'
    and
    (Today() - 100 days) < PC.effective.value
 )


define "High dose Spironolactone":
  (
    [MedicationStatement: "Spironolactone"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 25 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Spironolactone"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 25 'mg/d'
      )
    )

define "Low dose Spironolactone":
  (
    [MedicationStatement: "Spironolactone"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 25 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Spironolactone"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 25 'mg/d'
      )
    )


define "High dose Amiloride":
(
    [MedicationStatement: "Amiloride"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 10 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Amiloride"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 10 'mg/d'
      )
    )

define "Low dose Amiloride":
(
    [MedicationStatement: "Amiloride"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 10 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Amiloride"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 10 'mg/d'
      )
    )


define "High dose Triamterene":
(
    [MedicationStatement: "Triamterene"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 37.5 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Triamterene"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 37.5 'mg/d'
      )
    )

define "Low dose Triamterene":
(
    [MedicationStatement: "Triamterene"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 37.5 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Triamterene"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } >= 37.5 'mg/d'
      )
    )





// Next steps define alerts based on above defined criteria

define "Spironolactone with Potassium conc. between 5 and 5.5 within 48 hours":
exists "KCL Rx"
and
"Potassium between 5 and 5.5 within 48 hrs"
and exists "Spironolactone Rx"


define "Spironlactone with dose less than 25 mg with Low Potassium":
exists "KCL Rx"
and exists "Low dose Spironolactone"
and exists "Low Potassium"

define "Spironlactone with dose more than 25 mg with Low Potassium":
exists "KCL Rx"
and exists "High dose Spironolactone"
and exists "Low Potassium"

define "Spironlactone with High potassium":
exists "KCL Rx"
and exists "High Potassium"
and exists "Spironolactone Rx"

define "Amiloride with Potassium conc. between 5 and 5.5 within 48 hours":
exists "KCL Rx"
and "Potassium between 5 and 5.5 within 48 hrs"
and exists "Amiloride Rx"


define "Amiloride with High Potassium":
exists "KCL Rx"
and exists "High Potassium"
and exists "Amiloride Rx"


define "Amiloride with dose less than 10 mg with Low Potassium":
exists "KCL Rx"
and exists "Low dose Amiloride"
and exists "Low Potassium"


define "Amiloride with dose more than 10 mg with Low Potassium":
exists "KCL Rx"
and exists "High dose Amiloride"
and exists "Low Potassium"


define "Eplereneone with KCL":
exists "KCL Rx"
and exists "Eplerenone Rx"


define "Triamterene with Potassium conc. between 5 and 5.5 within 48 hours":
exists "KCL Rx"
and "Potassium between 5 and 5.5 within 48 hrs"
and exists "Triamterene Rx"


define "Triamterene with High Potassium":
exists "KCL Rx"
and exists "Triamterene Rx"
and exists "High Potassium"


define "Triamterene with dose less than 37.5 mg with Low Potassium":
exists "KCL Rx"
and exists "Low dose Triamterene"
and exists "Low Potassium"


define "Triamterene with dose more than 37.5 mg with Low Potassium":
exists "KCL Rx"
and exists "High dose Triamterene"
and exists "High Potassium"









