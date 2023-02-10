# pddi-cds-vscode-validation
A project that validates PDDI CDS rules written in CQL using a VS Code environment

This repository provides a walkthrough of building a FHIR content implementation guide (content IG) for a potential drug-drug interaction (PDDI). A content IG is a FHIR implementation guide that primarily contains knowledge artifacts such as decision support rules and quality measures. By using the FHIR publication toolchain, these artifacts are made available as FHIR resources, published within websites for documentation and dissemination, and distributed as part of NPM packages for implementation.

This walkthrough consists of 5 main steps:

1. [**Setup**](#basic-setup): Setting up and getting a basic build
2. [**Library**](#adding-a-library): Including a simple Library for a specific recommendation
3. [**Test Cases**](#adding-test-cases): Adding test cases to test the rule
4. [**Validation**](#validation-with-VScode): Validating the content works as expected via Visual Studio Code


## Basic Setup

The first step is to get a local [clone](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository) of the walkthrough repository.

To open a terminal in VS Code:

***Prerequisites***

- install a `git` client

***Steps***

- In the top menu, click `Terminal`
- click `New Terminal`
- in the `Terminal`, run

```bash
git clone https://github.com/dbmi-pitt/pddi-cds-vscode-validation.git
```

Once you have a local clone, you'll need to build:

### Dependencies

Before you're able to build this IG you'll need to install several dependencies

#### Java / IG Publisher

Go to [https://adoptopenjdk.net/](https://adoptopenjdk.net/) and download the latest (version 8 or higher) JDK for your platform, and install it.

There are scripts in this repository that will download and run the latest HL7 IG Publisher.

Please make sure that the Java bin directory is added to your path.

This project includes scripts that will automatically download the correct version of the IG-Publisher.

Documentation for the IG-Publisher is available at [https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation).

#### Ruby / Jekyll

Jekyll requires Ruby version 2.1 or greater. Depending on your operating system, you may already have Ruby bundled with it. Otherwise, or if you need a newer version, go to [https://www.ruby-lang.org/en/downloads/](https://www.ruby-lang.org/en/downloads/) for directions.

Jekyll

Go to [https://jekyllrb.com](https://jekyllrb.com) and follow the instructions there, for example gem install jekyll bundler. The end result of this should be that the binary "jekyll" is now in your path.

### Build

Once you have the dependencies installed, you can build the IG by first updating the publisher:

```
_updatePublisher
```

Once the publisher has been downloaded to your local environment, you can build the IG:

```
_genonce
```

Whenever you make changes to the source content, just rerun the `_genonce` script to rebuild the IG. The IG output will be in the output folder. Using a browser, open the `index.html` page to see the IG.

NOTE: This walkthrough uses "contentig" as the name of the implementation guide. The source ImplementationGuide resource is in the [contentig.xml](input/contentig.xml) file, and the [ig.ini](ig.ini) file refers to it. To change the name of the ig, be sure to update all references to `contentig` within the ImplementationGuide resource. Note that this name serves as part of the basis for the canonical URL for your IG, which is used to uniquely identify the implementation guide and all the resources published within it, so it's important to choose your canonical URL appropriately. For more information see the [Canonical URLs](https://www.hl7.org/fhir/references.html#canonical) discussion topic in the FHIR specification.

## Adding a Library

The next step in this walkthrough is to build the recommendation logic as expressions of [Clinical Quality Language](http://cql.hl7.org) (CQL). CQL is a high-level, author-friendly language that is used to express the logic used in clinical reasoning artifacts such as decision support rules, quality measurement population criteria, and public health reporting criteria.

### VSCode CQL Support

To validate and test CQL, use the [VSCode CQL Plugin](https://github.com/cqframework/vscode-cql). Follow the instructions there to install the plugin, then open VS Code on the root folder of this content IG walkthrough.

### Recommendation – Citalopram and QT prolonging agents

For this walkthrough, we'll be putting together a recommendation regarding the use of Citalopram in combination with QT prolonging agents.

Specifically, we'll be looking at the following recommendations:


> Patients taking a citalopram dose of more than 60 mg in combination with QT prolonging agent should continue use only if benefit outweighs the risk and have ECG monitored.

> Patients taking a citalopram dose of more than 60 mg without a QT prolonging agent should have risks minimized and ECG monitored.

> Patients taking a citalopram dose of less than 60 mg with or without a QT prolonging agent require no special precautions.


#### Pseudo-code for the Logic

First, we break down the recommendation into "pseudo-code" to get to a functional description of what needs to happen in order to apply the recommendations:

> If 60 mg or more dose of citalopram detected, and QT prolonging agent detected then recommend “Use only if benefit outweighs the risk and monitor patient ECG.”

> If 60 mg or more dose of citalopram detected, and QT prolonging agent not detected then recommend “Minimize risk and monitor ECG.”

> If less than 60 mg dose of citalopram detected then recommend “No special precaution.”


Essentially, we want to first check the dose of citalopram. If it is less than 60 mg, no special precautions are required. If the dose is greater than 60 mg, we check for a QT prolonging agent and either minimize risk or compare the benefits and risks of using the combination.

#### Data Elements

The next step is to characterize the data elements involved in the expression of the logic. For this interaction, we need to define Citalopram, QT prolonging agents, high dose citalopram (> 60 mg) with and without a QT prolonging agent, low dose citalopram (<60 mg). To express, we then need the following elements:

* Presence of Citalopram
* Presence of QT prolonging agent
* Dose of Citalopram


#### Presence of Citalopram and QT prolonging agents

For the detecting the presence of Citalopram and QT prolonging agents, we use value sets for both citalopram and QT prolonging agents:

```
valueset "Citaloprams": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-citaloprams'
valueset "QT Prolonging Agents": 'http://hl7.org/fhir/ig/PDDI-CDS/ValueSet/valueset-QT-prolonging-agents'

```

With these terminology elements defined, we can define what it means when a patient is taking a QT prolonging agent or citalopram:

```
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
	        where (Today() - 100 days) < MS.effective.start.value  
	        return MS.medication.coding[0]
	    )
	    union
	    (
	      [MedicationRequest: "QT Prolonging Agents"] MR
	      where MR.authoredOn.value > (Today() - 100 days) 
	      return MR.medication.coding[0]
	    )

```

#### Determining the dose of citalopram and the combination of Citalopram and QT prolonging agents

For the detecting the dose of citalopram, we make use of the following FHIRhelpers function:

```
define function ToQuantity(quantity FHIR.Quantity):
	  System.Quantity { value: quantity.value.value, unit: quantity.unit.value }

```
FHIRHelpers defines functions to convert between FHIR data types and CQL system-defined types, as well as functions to support FHIRPath implementation. For more information, the FHIRHelpers wiki page: https://github.com/cqframework/clinical_quality_language/wiki/FHIRHelpers

We can then define how to determine the dose and combination of medications using the above function and previously defined elements:

```
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

```

#### Recommendation and Rationale

Now that we have the required data elements, we can express previously mentioned recommendation:

```
define "Recommendation":
	  if "Citalopram High Dosage, No QT" then ' Minimize risk and monitor ECG'
	  else if "Citalopram High Dosage, QT" then ' Use only if benefit outweighs risk and monitor patient ECG'
	  else if "Citalopram Not High Dosage, No QT" then ' No special precaution'
	  else if "Citalopram Not High Dosage, QT" then ' No special precaution'
	  else null

```
We can also add a rationale using the require data elements:

```
define "Rationale":
	  if "Citalopram High Dosage, No QT" then ' Increased risk of prolonged QTc possible'
	  else if "Citalopram High Dosage, QT" then ' Increased risk of prolonged QTc likely'
	  else if "Citalopram Not High Dosage, No QT" then ' No special precaution'
	  else if "Citalopram Not High Dosage, QT" then ' No special precaution'
	  else null

```

### The Library resource

Now that we have the [CQL source defined](input/cql/CitalopramQtProlongingAgentCDS.cql), we can package it for inclusion in the IG using a [Library](http://hl7.org/fhir/library.html) resource. The Library resource can be used for a variety of knowledge artifact packaging purposes, but in this specific case, we'll use it as a content library to store the source and compiled [ELM](https://cql.hl7.org/04-logicalspecification.html) for the CQL.

First, we set up the [Library](input/resources/library-CitalopramQtProlongingAgentCDS.json), specifying basic metadata information like the `name`, `title`, and `status`:

```
{  
  "resourceType": "Library",
  "id": "CitalopramQtProlongingAgentCDS", 
  "name": "CitalopramQtProlongingAgentCDS",
  "title": "Citalopram and QT Prlonging Agents example CDS Logic",
  "status": "active",
  "experimental": true,
  "type": {
    "coding": [
      {
        "system": "http://hl7.org/fhir/codesystem-library-type.html",
        "code": "logic-library"
      }
    ]
  },
  "content": [
    {
      "id": "ig-loader-CitalopramQtProlongingAgentCDS.cql"
    }
  ]
}
```

In addition, we specify that it's a `logic-library`, meaning it specifically carries logic for evaluation as part of a knowledge artifact, and we then tell the publisher how to find the source CQL using the `content.id `element, setting it to the text `ig-loader-` followed by the name of the CQL source file. The publisher will then translate the CQL source and populate the rest of the metadata in the library (such as parameters, data requirements, and dependencies), and include the published library as a resource in the implementation guide.

Note that the `name` element of the FHIR Library resource is required to match exactly the `name` of the CQL Library. The refresh tooling will automatically set the url element as follows:

`<ig-base-canonical>/Library/<library-name>`

This is important because this is how FHIR-based environments will resolve library name references in CQL.

In addition, because the Library is being published as a conformance resource in a FHIR IG, the `id` of the resource must match the tail (i.e. final path segment) of the `url`, so in this context, the `id` must also match the name of the library. Because the [id] in FHIR cannot include underscores, this effectively means that CQL library names must not include underscores either.

## Adding Test Cases

To test that the logic behaves as expected, we can define tests along-side the content. The atom plugin expects a [`tests`](input/tests) folder to be defined within the IG `input` directory. Within this folder, the plugin expects a folder named the same as the CQL library under test, [`CitalopramQtProlongingAgentCDS`](input/tests/CitalopramQtProlongingAgentCDS) in this case, and within that folder, any number of test cases, defined as patient test cases with all their associated data.

For this walkthrough, we've defined four test cases, a `patient-with-Hcitalopram`, `patient-with-HcitalopramQT`, `patient-with-Lcitalopram`, and `patient-with-Hcitalopram`, and provided the Patient and Medication resources required.


## Validation with VScode

To execute the tests, open the CitalopramQtProlongingAgentCDS.cql file, right-click anywhere in the editor window and select CQL->Execute from the right-click menu. A new editor window will appear with the results of running the tests, displaying the result of evaluating each top-level item defined in the library.