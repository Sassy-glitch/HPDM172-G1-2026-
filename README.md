# HPDM172 Group 1 2026 Project

## Website: 
https://sassy-glitch.github.io/HPDM172-G1-2026-/

## Project Description: 
A MySQL hospital database covering:
- Hospitals
- Doctors
- Patients
- Medications
- Prescriptions
- Diseases
- Appointments
- Lab Results

Built for HPDM172 Coursework by Group 1. 

## Contents: 
| Folder | Description |
|---|---|
| `Planning` | ERD, flowchart, pseudocode |
| `Data` | CSV files used for import |
| `SQL Tables` | Table creation scripts and the 19 query files |
| `SQL Code` | Full MySQL export (mysqldump) |
| `Group Admin` | Meeting agendas, minutes, action plan |
| `Gen AI` | How generative AI was used in this assignment |
| `README.md` | GitHub Pages content |

## Database Overview:
Entity–relationship diagram (ERD) of a healthcare database showing relationships between hospitals, doctors, patients, appointments, prescriptions, medications, diseases, and laboratory results.
<img width="1751" height="1348" alt="computational ERD" src="https://github.com/user-attachments/assets/5261d8eb-f09d-4caa-807a-f40b561b69fb" />


### Information Included:
| Table | Purpose | Rows |
|---|---|---|
| hospitals | Details of each hospital (beds, type, accreditation, emergency services) | 40 |
| doctors | Doctors and the hospital each works at | 100 |
| patients | Patients and their registered doctor | 600 |
| medications | Available medications | 30 |
| prescriptions | Medication prescribed to a patient by a doctor | 500 |
| diseases | List of diseases | 20 |
| disease_medication | Which medication treats which disease | 55 |
| disease_specialist | Which doctor specialises in which disease | 299 |
| appointments | Scheduled appointments | 300 |
| lab_results | Lab test results for patients | 300 |

  
### Key Relationships:

One hospital has many doctors; each doctor works at one hospital.

One doctor has many patients; each patient is registered to one doctor.

A prescription is for one patient, one doctor and one medication.

Diseases and medications are many-to-many, linked through diseases_medication.

Diseases and doctors are many-to-many (specialists), linked through disease_specialist.

Appointments and lab results each belong to one patient and are requested by one doctor.

### Naming Conventions:

Table Names: lowercase, plural, underscores between words.

Column Names: lowercase, plural, underscores between words.

- Primary keys: ?? -
- 
- Foreign keys: ?? -
- 
Link tables: the two table names joined by an underscore.

- Query files: numbered with a clear name -

## How To Use: 
1. Clone the repository
3. Create the database
4. Run a query
   
This project is coursework so the repository is no longer active; no contribution or upload instructions are provided.

## SQL Queries: 

## Members: 
1. Anuja Alias
2. Dana Basal
3. Maizy Carey 
4. Nsuhoridem Aman Ekong
5. Sassy Drake

(See Group Admin for Task Assignment)

## AI Declaration:
We declare that we have referenced use of generative AI outputs within our assessment in line with the University of Exeter referencing guidelines. 
(See GenAI folder for more information)
