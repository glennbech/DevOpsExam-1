# Eksamen PGR301 2023

Litt deploymentproblemer:
Resource handler returned message: "null (Service: S3, Status Code: 0, Request ID: null)" (RequestToken: e75e6e91-4738-10c7-56bd-9cc969a4184b, HandlerErrorCode: AlreadyExists)
Forsøk på å slette stacken manuelt i CloudFormation og deploye på nytt.

# Oppgave 1a)
Fjernet hardkodingen av bucketnavnet og la til en miljøvariabel som hentet ut "kandidat2010". 
Opprettet en worklow: sam_python.yml.

# - name: Deploy SAM Application
      if: github.ref == 'refs/heads/main'
      run: sam deploy --no-confirm-changeset --no-fail-on-empty-changeset --stack-name kandidat2010 --capabilities CAPABILITY_IAM --resolve-s3
      working-directory: ./kjell"
Denne delen sikrer at applikasjonen kun deployes ved push til main branch.

For at sensor skal kunne kjøre actions workflow ved en fork må h*n, i liket som meg konfiguere AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY. 
Dette gjøres i IAM. De må også legges til som actions secret i Github.

# Oppgave 1b)
Dockerfilen ligger under hello_world og fungerer til å kjøre gitt kommando. Se bilde under images.

# Oppgave 2 
Testet applikasjonen i terminal - se img/oppgave2.png

#A) Velfungerende dockerfil. 

```
# Fase 1: Bygge applikasjonen
FROM maven:3.6.3-jdk-11-slim AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

# Fase 2: Kjøre applikasjonen
FROM openjdk:11-jre-slim
COPY --from=build /home/app/target/*.jar /usr/local/lib/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/app.jar"]

```

#B)
Workflowen er laget, og heter aws_ecr.yml.


```
name: Build and deploy AWS ECR

on: [push]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: eu-west-1

    - name: Login to Amazon ECR
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build and Push to ECR
      if: github.ref == 'refs/heads/main'
      env:
        ECR_REGISTRY: 244530008913.dkr.ecr.eu-west-1.amazonaws.com
        ECR_REPOSITORY: kandidat2010ecr
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
```
Vellykket push til ECR med latest-tag: se img/oppgave2b.png

# Oppgave 3

#A)

Endret hardkoding av servicenavn, policy, ecr-uri og apprunner-service rolle. Kunne endret hardkodet port og.
```
variable "ecr_uri" {
  description = "ECR URI"
  type = string
}

variable "apprunner_name" {
  description = "Name of the AppRunner Service"
  type = string
}

variable "apprunner_role" {
  description = "IAM AppRunner Role"
  type = string
}

variable "policy_name" {
  description = "IAM Policy name"
  type = string
}
```

Fikk omsider endret CPU og memory - dette krevde en nyere versjon i provider.tf. 

#B)

```
 deploy-with-terraform:
    needs: [build-and-deploy]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1


      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
              aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
              aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
              aws-region: eu-west-1

      - name: Terraform Init
        working-directory: ./infra
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve -input=false
        working-directory: ./infra

        env:
          TF_VAR_ecr_uri: 244530008913.dkr.ecr.eu-west-1.amazonaws.com/kandidat2010ecr:latest
          TF_VAR_apprunner_name: kandidat2010
          TF_VAR_apprunner_role: kandidat2010role
          TF_VAR_policy_name: kandidat2010policy
          TF_VAR_cloudwatch_namespace: 2010namespace
          TF_VAR_cloudwatch_step: 10s
          TF_VAR_dashboard_name: 2010dashboard
          
```
Koden kjører nok uten at sensor endrer noe ved en fork, men for å endre til egne verdier slik at man får egen service og tilhørende,
må sensor endre navnene på variablene i aws_evr.yml filen. 

Igjen er også en forutsetning er AWS_ACCESS_KEY_ID og AWS_SECRET_ACCESS_KEY er konfiguert i IAM og koblet opp mot Github.

# Oppgave 4. Feedback

¨

Dere skal skrive en kort begrunnelse for hvorfor dere har valgt måleinstrumentene dere har gjort, og valgene må  være relevante.
Eksempelvis vil en en teller som øker hver gang en metode blir kalt ikke bli vurdert som en god besvarelse, dette fordi denne
metrikkene allerede leveres av Spring Boot/Actuator.


Fikk ikke metrics til å fungere slik som jeg ønsket. Usikker på hvor feilen ligger:

Det jeg ønsket - slik som du ser i RekognitionController tilhørende dashboard.tf: legge til funksjonalitet i "scan-ppe" med 
DistributionSummary metric for å sjekke, gjennomsnittlig, hvor mange personer det er i bilder med "violations". Er det ukult med 
utstyr? Blir de påvirket av folk rundt seg? Fikk ikke opp metrics på dashboardet. 

La også til et nytt endepunkt: 


### Vurderingskriterier

* Hensikten med å utvide kodebasen er å få flere naturlige steder å legge inn måleinstrumenter. Det gis ikke poeng for et stort kodevolum, men en god besvarelse vil legge til virkelig og nyttig funksjonalitet.
* En god besvarelse registrer både tekniske, og foretningsmessig metrikker.
* En god besvarelse bør bruke minst tre ulike måleinstrumenter på en god og relevant måte.

### B. CloudWatch Alarm og Terraform moduler

Lag en CloudWatch-alarm som sender et varsel på Epost dersom den utløses.Dere velger selv kriteriet for kriterier til at alarmen
skal løses ut, men dere  må skrive en kort redgjørelse for valget.

Rakk ikke dette.

Alarmen skal lages ved hjelp av Terraformkode. Koden skal lages som en separat Terraform modul. Legg vekt på å unngå
hardkoding  av verdier i modulen for maksimal gjenbrukbarhet. Pass samtidig på at brukere av modulen ikke må sette mange
variabler når de inkluderer den i koden sin.

# Oppgave 4. Drøfteoppgaver

## Det Første Prinsippet - Flyt

### A. Kontinuerlig Integrering
DevOps definerer kontinuerlig integrasjon som en viktig prosess eller et sett med prosesser som er definert og utført som en del av en rørledning kjent som "Build Pipeline" eller "CI Pipeline." 
DevOps-praksisen gir utviklingsteamet et enkelt versjonsstyringsystem som tilrettelegger for parallell jobbing.  
Ved kontinuerlig integrering kan man slå sammen individuelle utviklerkoder i en “hovedkopi” av koden for hovedgrenen som håndterer versjonskontroll. 
Det er heller ingen begrensning på hvor ofte en kodesammenslåing kan gjøres på en dag. 

Det at kodeendringer blir integrert og testet automatisk og regelmessig fører til at problemer i koden oppdages tidligere i utviklingsprossessen.
En annen ting er det faktum at KI fremmer en praksis med små og hyppige oppdateringer til kodebasen, slik at det reduserer risikoen for komplekse merge-konflikter. 

Rent i praksis jobber man i Github med et repository der kildekoden lagres.
Det opprettes egne brancher for medlemmene i utviklingsteamet som til slutt merges sammen.
Ved bruk av verktøy som Github Actions, slik som i vår oppgave, kan hele teamet bli varslet når en test eller build feiler.
Slik kan tidlig oppdaging av feil føre til høyere kodekvalitet. Det settes også gjerne kodestandarder som teamet må følge for mer ryddig integrasjon ved merging.  


### B. Sammenligning av Scrum/Smidig og DevOps fra et Utviklers Perspektiv

Scrum har en fleksibel og iterativ tilnærming til programvareutvikling og det legges vekt på regelmessige tilbakemeldinger og tilpassede endringer.
Det jobbes i korte sprinter – slik at man ofte kan evaluere og endre basert på feedback fra kunde/brukere.
Slik får man høyere produktkvalitet. 
I skrivende stund legger jeg merke til at det egentlig har mye til felles med DevOps – hvertfall sett i motsetning til tiden før Scrum, hvor man gjerne hadde lange prosjekter med en lanseringsdato uten særlig feedback underveis. 

DevOps er nok mer fokusert på å effektivisere og automatisere utviklingsprosessene. 
En kombinasjon av metodene bør ikke være utenkelig og jeg ser ikke nødvendigvis på de som motsettende metoder for utvikling.



#### Forventninger til Besvarelsen

- Din analyse bør være balansert, kritisk og godt underbygget med eksempler eller teoretiske argumenter.
- Reflekter over egne erfaringer eller hypotetiske scenarier for å støtte dine argumenter og konklusjoner.

### C. Det Andre Prinsippet - Feedback
Feedback er essensielt for å sikre at funksjonalitet møter brukernes behov. 
Blant former har vi intervjuer, spørreundersøkelser eller “overvåkning” av brukernes interaksjon med applikasjonen. 
Det er også, i tillegg til KI, noe som bidrar til kontinuerlig forbedring i DevOps.  

Med feedback som virkemiddel må også utviklingsteamet være forberedt på å gjøre justeringer.
Dette kan både gjelde å fikse bugs eller å legge til ekstra funksjoner. 
Feedack kan benyttes til å fikse nåværende behov, men også verne fremtidige forventninger. 
Det kan også benyttes til andre prosjekter, om du skulle ha noen gående.
