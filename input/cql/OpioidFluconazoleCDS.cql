library OpioidFluconazoleCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'
codesystem "v3-ActCode":'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem "LOINC": 'http://loinc.org'

valueset "Fentanyls": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-fentanyl'
valueset "Oxycodones": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-oxycodone'
valueset "Fluconazoles": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-fluconazoles'
valueset "eGFR":'https://loinc.org/kb/users-guide/loinc-technical-briefs/choosing-the-correct-loinc-for-estimated-glomerular-filtration-rate/'

code "Inpatient Encounter": 'IMP' from "v3-ActCode" display 'Inpatient Encounter'
code "Inpatient Acute": 'ACUTE' from "v3-ActCode" display 'Inpatient Acute'
code "Inpatient Non-Acute": 'NONAC' from "v3-ActCode" display 'Inpatient Non-Acute'

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

// Refer to class when looking at observation, and lists codes in above
define "Inpatient Visit":
 (
  [Encounter: class ~ "Inpatient Encounter"] IE
    where (Today() - 100 days) < IE.period.start.value
  )
  union
   (
  [Encounter: class ~ "Inpatient Acute"] IA
    where (Today() - 100 days) < IA.period.start.value
  )
  union
   (
  [Encounter: class ~ "Inpatient Non-Acute"] INA
    where (Today() - 100 days) < INA.period.start.value
  )



define "Low eGFR":
  (
      [Observation: "eGFR"] EG
      where
        (System.Quantity {
         value: (EG.value).value, unit: 'ml/min'
            } <= 30 'ml/min'
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


define "High dose oxycodone":
  (
    [MedicationStatement: "Oxycodones"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } > 10 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Oxycodones"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } > 10 'mg/d'
      )
    )

define "Low dose oxycodone":
  (
    [MedicationStatement: "Oxycodones"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } <= 10 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Oxycodones"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } <= 10 'mg/d'
      )
    )

define "High dose fluconazole":
  (
    [MedicationStatement: "Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } > 50 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } > 50 'mg/d'
      )
    )

define "Low dose fluconazole":
(
    [MedicationStatement: "Fluconazoles"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } <= 50 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Fluconazoles"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } <= 50 'mg/d'
      )
    )



define "Inclusion criteria":
(exists "Oxycodone Rx" or exists "Fentanyl Rx")
and
 exists ("Fluconazoles Rx")

// Next steps define alerts based on above defined criteria


define "Inpatient":
exists "Inpatient Visit"

define "eGFR less than 30 ml/min":
"Inclusion criteria" is not null
and
exists "Low eGFR"

define "Fentanyl with low dose fluconazole":
"Inclusion criteria" is not null
and
exists "High eGFR"
and exists "Fentanyl Rx"
and exists "Low dose fluconazole"

define "Fentanyl with high dose fluconazole":
"Inclusion criteria" is not null
and
exists "High eGFR"
and exists "Fentanyl Rx"
and exists "High dose fluconazole"

define "Low dose oxycodone with fluconazole":
"Inclusion criteria" is not null
and
exists "High eGFR"
and exists "Fluconazoles Rx"
and exists "Low dose oxycodone"

define "High dose oxycodone with High dose fluconazole":
"Inclusion criteria" is not null
and
exists "High eGFR"
and exists "High dose oxycodone"
and exists "High dose fluconazole"

define "High dose oxycodone with low dose fluconazole":
"Inclusion criteria" is not null
and
exists "High eGFR"
and exists "High dose oxycodone"
and exists "Low dose fluconazole"




