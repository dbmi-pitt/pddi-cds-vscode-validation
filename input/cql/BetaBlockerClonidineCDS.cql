library BetaBlockerClonidineCDS version '0.1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm'


valueset "Oral Clonidine": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-oralclonidine'
valueset "Injectable Clonidine": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-injectableclonidine'
valueset "Topical Clonidine": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-topicalclonidine'
valueset "Selective BetaBlocker": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-selectivebetablocker'
valueset "Alpha-Blocking Agent": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-alphablockingagent'
valueset "Non-Selective Blocker":'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-nonselectiveblocker'
valueset "Systemic Timolol": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-systemictimolol'
valueset "Opthalmic Timolol Solution": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-opthalmictimololsolution'
valueset "Opthalmic Timolol Gel": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-opthalmictimololgel'



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

define "Oral Clonidine Rx":
    (
      [MedicationRequest: "Oral Clonidine"] MR
      where MR.authoredOn.value > (Today() - 100 days) and MR.status = 'stopped' // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )
    
define "Injectable Clonidine Rx":
    (
      [MedicationRequest: "Injectable Clonidine"] MR
      where MR.authoredOn.value > (Today() - 100 days) and MR.status = 'stopped' // or, could be hard-coded e.g., > @2022-11-01
      return MR.medication.coding[0]
    )

define "Topical Clonidine Rx":
    (
      [MedicationRequest: "Topical Clonidine"] MR
      where MR.authoredOn.value > (Today() - 100 days) and MR.status = 'stopped' // or, could be hard-coded e.g., > @2022-11-01
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

define "Systemic Timolol Rx":
    (
      [MedicationStatement: "Systemic Timolol"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Systemic Timolol"] MR
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

define "Alpha-Blocking Agent Rx":
    (
      [MedicationStatement: "Alpha-Blocking Agent"] MS
        where (Today() - 100 days) < MS.effective.start.value  // or, could be hard-coded e.g., > @2022-11-01
        return MS.medication.coding[0]
    )
    union
    (
      [MedicationRequest: "Alpha-Blocking Agent"] MR
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

define "Clonidine with Selective Beta Blocker or Alpha-blocking agent":
exists ("Oral Clonidine Rx" union "Injectable Clonidine Rx" union "Topical Clonidine Rx")
and (exists "Selective BetaBlocker Rx" or exists "Alpha-Blocking Agent Rx" )

define "Topical Clonidine with Non-Selective Beta Blocker":
exists "Topical Clonidine Rx"
and exists "Non-Selective Blocker Rx"

define "Oral or Injectable Clonidine with Non-selective Beta Blocker":
exists ("Oral Clonidine Rx" union "Injectable Clonidine Rx")
and exists "Non-Selective Blocker Rx"  

define "Oral or Injectable Clonidine with Systemic Timolol":
exists ("Oral Clonidine Rx" union "Injectable Clonidine Rx")
and exists "Systemic Timolol Rx"

define "Oral or Injectable Clonidine with Opthalmic Timolol solution":
exists ("Oral Clonidine Rx" union "Injectable Clonidine Rx")
and exists "Opthalmic Timolol Solution Rx"

define " Oral or Injectable Clonidine with Opthalmic Timolol gel":
exists ("Oral Clonidine Rx" union "Injectable Clonidine Rx")
and exists "Opthalmic Timolol Gel Rx"






