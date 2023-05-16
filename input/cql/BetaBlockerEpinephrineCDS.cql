library BetaBlockerEpinephrineCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'
codesystem "LOINC": 'http://loinc.org'

valueset "Inhaled Epinephrine": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Ophthalmic Epinephrine": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Injectable Epinephrine":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Selective BetaBlocker": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-selectivebetablocker'
valueset "Non-Selective Blocker":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-nonselectiveblocker'
valueset "Opthalmic Timolol Solution": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-opthalmictimololsolution'
valueset "Opthalmic Timolol Gel": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-opthalmictimololgel'
valueset "Carvediolol":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Labetalol":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Local Anesthetic":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Dermatological/Dental": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Plastic Surgery": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'
valueset "Anaphylaxis": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-'


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



define "Inhaled Epinephrine Rx":
    (
      [MedicationStatement: "Inhaled Epinephrine"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Inhaled Epinephrine"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )


define "Ophthalmic Epinephrine Rx":
    (
      [MedicationStatement: "Ophthalmic Epinephrine"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Ophthalmic Epinephrine"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Injectable Epinephrine Rx":
    (
      [MedicationStatement: "Injectable Epinephrine"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Injectable Epinephrine"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Selective BetaBlocker Rx":
    (
      [MedicationStatement: "Selective BetaBlocker"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Selective BetaBlocker"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Non-Selective Blocker Rx":
    (
      [MedicationStatement: "Non-Selective Blocker"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Non-Selective Blocker"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Opthalmic Timolol Solution Rx":
    (
      [MedicationStatement: "Opthalmic Timolol Solution"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Opthalmic Timolol Solution"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Opthalmic Timolol Gel Rx":
    (
      [MedicationStatement: "Opthalmic Timolol Gel"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Opthalmic Timolol Gel"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Carvediolol Rx":
    (
      [MedicationStatement: "Carvediolol"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Carvediolol"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Labetalol Rx":
    (
      [MedicationStatement: "Labetalol"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Labetalol"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Local Anesthetic Rx":
    (
      [MedicationStatement: "Local Anesthetic"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Local Anesthetic"] MR
      where MR.authoredOn.value > (Today() - 100 days) // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )



// Refer to class when looking at observation, and lists codes in above
define "Dose above 0.3 mg":
 (
    [MedicationStatement: "Injectable Epinephrine"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } > 0.3 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Injectable Epinephrine"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } > 0.3 'mg/d'
      )
    )

define "Dose below 0.5 mg":
(
    [MedicationStatement: "Injectable Epinephrine"] MS
    where
        (System.Quantity {
              value: (MS.dosage[0].doseAndRate[0].dose).value *
                ToDecimal(MS.dosage[0].timing.repeat.frequency), unit: 'mg/d'
            } < 0.6 'mg/d'
        )
    )
    union
    (
    [MedicationRequest: "Injectable Epinephrine"] MR
    where
      (System.Quantity {
        value: (MR.dosageInstruction[0].doseAndRate[0].dose).value *
           ToDecimal(MR.dosageInstruction[0].timing.repeat.frequency), unit: 'mg/d'
            } < 0.6 'mg/d'
      )
    )


define "Dermatological/Dental Condition":
[Condition: "Dermatological/Dental"]

define "Anaphylaxis Condition":
[Condition: "Anaphylaxis"]

define "Plastic Surgery Procedure":
[Condition: "Plastic Surgery"]

//Need to refer to epinephrine as it relates to medication start value





// Next steps define alerts based on above defined criteria






