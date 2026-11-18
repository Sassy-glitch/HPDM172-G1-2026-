-- Hospital Database SQL Queries

DELIMITER $$
-- All Doctors based at a particular Hospital

 DROP PROCEDURE IF EXISTS list_doctors_at_hospital$$
   CREATE PROCEDURE list_doctors_at_hospital(IN p_hospital_name VARCHAR(100))
   BEGIN
         SELECT d.DoctorID,
                CONCAT(d.FirstName,' ', d.LastName) AS DoctorName,
                d.Specialty,
                h.HospitalName
         FROM doctors d
         JOIN hospitals h ON h.HospitalID = d.HospitalID
         WHERE h.HospitalName = p_hospital_name
         ORDER BY d.LastName,d.FirstName;
   END$$

-- All Prescriptions for a particular patient,ordered by date
DROP PROCEDURE IF EXISTS list_prescriptions_for_patient$$
   CREATE PROCEDURE list_prescriptions_for_patient(IN p_patient_id INT)
   BEGIN
         SELECT pr.PrescriptionID,
                pr.PrescriptionDate,
                CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
                m.MedicationName,
                m.Dosage,
                CONCAT(d.FirstName,' ',d.LastName) AS DoctorName
         FROM prescriptions pr
         JOIN patients p ON p.PatientID = pr.PatientID
         JOIN medications m ON m.MedicationID = pr.MedicationID
         JOIN doctors d ON d.DoctorID = pr.DoctorID
         WHERE pr.PatientID = p_patient_id
         ORDER BY pr.PrescriptionDate;
  END$$

-- All prescriptions by particular Doctor
 
DROP PROCEDURE IF EXISTS list_prescriptions_by_doctor$$
   CREATE PROCEDURE  list_prescriptions_by_doctor(IN p_doctor_id INT)
   BEGIN
         SELECT pr.PrescriptionID,
                pr.PrescriptionDate,
                CONCAT(d.FirstName,' ',d.LastName) AS DoctorName,
                CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
                m.MedicationName,
                m.Dosage
         FROM prescriptions pr
         JOIN doctors d ON d.DoctorID = pr.DoctorID
         JOIN patients p ON p.PatientID = pr.PatientID
         JOIN medications m ON m.MedicationID = pr.MedicationID
         WHERE pr.DoctorID = p_doctor_id
         ORDER BY pr.PrescriptionDate;
   END$$

 DELIMITER ;
 -- All prescriptions orderd by patient name alphabetically
   CREATE OR REPLACE VIEW list_all_prescriptions_by_patient_name AS
   SELECT pr.PrescriptionID,
          p.LastName AS PatientLastName,
          p.FirstName AS PatientFirstName,
          m.MedicationName,
          m.Dosage,
          CONCAT(d.FirstName,' ',d.LastName) AS DoctorName,
          pr.PrescriptionDate
   FROM prescriptions pr
   JOIN patients p ON p.PatientID = pr.PatientID
   JOIN medications m ON m.MedicationID = pr.MedicationID
   JOIN doctors d ON d.DoctorID = pr.DoctorID
   ORDER BY p.LastName,p.FirstName,pr.PrescriptionDate;
 
DELIMITER $$
-- Add a new patient
   DROP PROCEDURE IF EXISTS add_new_patient$$
   CREATE PROCEDURE add_new_patient(
       IN p_first_name VARCHAR(50),
       IN p_last_name VARCHAR(50),
       IN p_dob DATE,
       IN p_address VARCHAR(255),
       IN p_doctor_id INT)
   BEGIN
       IF NOT EXISTS(SELECT 1 FROM doctors WHERE DoctorID = p_doctor_id) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Doctor does not exist - patient not added';
       END IF;
       INSERT INTO patients (FirstName, LastName, DateOfBirth, Address, DoctorID)
       VALUES (p_first_name, p_last_name, p_dob, p_address, p_doctor_id);
       SELECT LAST_INSERT_ID() AS NewPatientID;
  END$$

-- Modify address details of an existing patient
  DROP PROCEDURE IF EXISTS update_patient_address$$
   CREATE PROCEDURE update_patient_address(
       IN p_patient_id INT,
       IN p_new_address VARCHAR(255))
   BEGIN
       UPDATE patients
       SET Address = p_new_address
       WHERE PatientID = p_patient_id;
       SELECT ROW_COUNT() AS RowsUpdated;
   END$$

-- Names and addresses of patients registered to doctors at one hospital
  DROP PROCEDURE IF EXISTS list_patient_mailing_by_hospital$$
   CREATE PROCEDURE list_patient_mailing_by_hospital(IN p_hospital_name VARCHAR(100))
   BEGIN
       SELECT CONCAT(p.FirstName,' ',p.LastName) AS PatientName, p.Address
       FROM patients p
       JOIN doctors d ON d.DoctorID = p.DoctorID
       JOIN hospitals h ON h.HospitalID = d.HospitalID
       WHERE h.HospitalName = p_hospital_name
       ORDER BY p.LastName, p.FirstName;
  END$$

DELIMITER ;
 -- Doctors at Teaching hospitals accredited between 2015 and 2024
 CREATE OR REPLACE VIEW list_doctors_teaching_hospitals_accredited_2015_2024 AS
   SELECT d. DoctorID,
          CONCAT(d.FirstName,' ',d.LastName) as DoctorName,
          d.Specialty,
          h.HospitalName,
          h.AccreditationDate
   FROM doctors d
   JOIN hospitals h ON h.HospitalID = d.HospitalID
   WHERE h.HospitalType = 'Teaching'
      AND h.AccreditationDate >='2015-01-01'
      AND h.AccreditationDate < '2025-01-01'
   ORDER BY h.HospitalName, d.LastName;
 
DELIMITER $$
-- Patients who may have a particular disease, based on the medication they have been prescribed
  DROP PROCEDURE IF EXISTS list_patients_possibly_with_disease$$
   CREATE PROCEDURE list_patients_possibly_with_disease(IN p_disease_name VARCHAR(100))
   BEGIN
       SELECT DISTINCT
              p.PatientID,
              CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
              dis.DiseaseName,
              m.MedicationName AS MedicationPrescribed
       FROM diseases dis
       JOIN disease_medication dm ON dm.DiseaseID = dis.DiseaseID
       JOIN medications m ON m.MedicationID = dm.MedicationID
       JOIN prescriptions pr ON  pr.MedicationID = dm.MedicationID
       JOIN patients p ON p.PatientID = pr.PatientID
       WHERE dis.DiseaseName = p_disease_name
       ORDER BY PatientName;
   END$$

-- Doctors who specialise in a particular disease
  DROP PROCEDURE IF EXISTS list_doctors_specialising_in_disease$$
   CREATE PROCEDURE list_doctors_specialising_in_disease(IN p_disease_name VARCHAR(100))
   BEGIN
       SELECT d.DoctorID,
              CONCAT(d.FirstName,' ',d.LastName) AS DoctorName,
              d.Specialty,
              h.HospitalName,
              dis.DiseaseName
       FROM diseases dis
       JOIN disease_specialist ds ON ds. DiseaseID = dis.DiseaseID
       JOIN doctors d ON d.DoctorID = ds.DoctorID
       JOIN hosptals h ON h.HospitalID = d.HospitalID
       WHERE dis.DiseaseName = p_disease_name
       ORDER BY h.HospitalName,d.LastName;
  END$$

 DELIMITER ;
-- All lab results for all patients over 60 years of age
  CREATE OR REPLACE VIEW list_lab_results_patients_over_age_60 AS
   SELECT lr.LabResultID,
          CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
          TIMESTAMPDIFF(YEAR, p.DateOfBirth,CURDATE()) AS PatientAge,
          lr.TestType,
          lr.ResultValue,
          lr.TestDate
   FROM lab_results lr
   JOIN patients p ON p.PatientID = lr.PatientID
   WHERE TIMESTAMPDIFF(YEAR, p.DateOfBirth,CURDATE()) >60
   ORDER BY p.LastName, p.FirstName, lr.TestDate;
 

DELIMITER $$
-- All appointments for a given patient
  DROP PROCEDURE IF EXISTS list_appointments_for_patient$$
   CREATE PROCEDURE list_appointments_for_patient(IN p_patient_id INT)
   BEGIN
       SELECT a.AppointmentID,
              a.AppointmentDate,
              a.Status,
              CONCAT(p.FirstName,' ', p.LastName) AS PatientName,
              CONCAT(d.FirstName,' ', d.LastName) AS DoctorName,
              d.Specialty
       FROM appointments a
       JOIN patients p ON p.PatientID = a.PatientID
       JOIN doctors d ON d.DoctorID = a.DoctorID
       WHERE a.PatientID = p_patient_id
       ORDER BY a.AppointmentDate;
  END$$

-- All appointments for a given doctor
  DROP PROCEDURE IF EXISTS list_appointments_for_doctor$$
   CREATE PROCEDURE list_appointments_for_doctor(IN p_doctor_id INT)
   BEGIN
       SELECT a.AppointmentID,
              a.AppointmentDate,
              a.Status,
              CONCAT(d.FirstName,' ', d.LastName) AS DoctorName,
              CONCAT(p.FirstName,' ', p.LastName) AS PatientName
       FROM appointments a
       JOIN doctors d ON d.DoctorID = a.DoctorID
       JOIN patients p ON p.PatientID = a.PatientID
       WHERE a.DoctorID = p_doctor_id
       ORDER BY a.AppointmentDate;
  END$$

-- All prescriptions made from a particular hospital ordered alphabetically by medication name
  DROP PROCEDURE IF EXISTS list_prescriptions_by_hospital_report$$
    CREATE PROCEDURE  list_prescriptions_by_hospital_report(IN p_hospital_name VARCHAR(100))
    BEGIN
       SELECT m.MedicationName AS 'Medication Name',
              CONCAT(d.FirstName,' ',d.LastName) AS 'Doctor Name',
              CONCAT(p.FirstName,' ',p.LastName) AS 'Patient Name',
              h.HospitalName  AS 'Hospital Name'
       FROM prescriptions pr
       JOIN medications m ON m.MedicationID = pr.MedicationID
       JOIN doctors d ON d.DoctorID = pr.DoctorID
       JOIN patients p ON p.PatientID = pr.PatientID
       JOIN hospitals h ON h.HospitalID = d.HospitalID
       WHERE h.HospitalName = p_hospital_name
       ORDER BY m.MedicationName ASC;
  END$$

DELIMITER ;
-- All lab results from all hospitals accredited between 2013 and 2020
  CREATE OR REPLACE VIEW list_lab_results_hospitals_accredited_2013_2020 AS
   SELECT lr.LabResultID,
          lr.TestType,
          lr.ResultValue,
          lr.TestDate,
          CONCAT(p.FirstName,' ',p.LastName) AS 'Patient Name',
          h.HospitalName,
          h.AccreditationDate
   FROM lab_results lr
   JOIN doctors d ON d.DoctorID = lr.DoctorID
   JOIN hospitals h ON h.HospitalID = d.HospitalID
   JOIN patients p ON p.PatientID = lr.PatientID
   WHERE h.AccreditationDate >= '2013-01-01'
      AND h.AccreditationDate <'2021-01-01'
   ORDER BY lr.TestDate;
 
-- Most of the prescriptions made by which doctor
  CREATE OR REPLACE VIEW top_prescribing_doctor AS
    SELECT d.DoctorID,
           CONCAT(d.FirstName,' ',d.LastName) AS 'Doctor Name',
           d.Specialty ,
           h.HospitalName,
    COUNT(pr.PrescriptionID) AS TotalPrescriptions
    FROM doctors d
    JOIN prescriptions pr ON pr.DoctorID = d.DoctorID
    JOIN hospitals h ON h.HospitalID = d.HospitalID
    GROUP BY d.DOCTORID,d.FirstName,d.LastName,d.Specialty,h.HospitalName
    ORDER BY TotalPrescriptions DESC LIMIT 1;

-- All doctors at the hospital with the biggest size (number of beds)
  CREATE OR REPLACE VIEW list_doctors_at_largest_hospital AS
    SELECT d.DoctorID,
           CONCAT(d.FirstName,' ',d.LastName) AS 'Doctor Name',
           d.Specialty,
           h.HospitalName,
           h.NumberOfBeds
    FROM doctors d
    JOIN hospitals h ON h.HospitalID = d.HospitalID
    where h.NumberOfBeds = (SELECT MAX(NumberOfBeds) FROM hospitals)
    ORDER BY d.LastName,d.FirstName;

--  All hospital names accredited prior to 2015 that have Emergency Service facilities
  CREATE OR REPLACE VIEW list_pre2015_emergency_hospitals AS
   SELECT HospitalName FROM hospitals WHERE AccreditationDate <'2015-01-01' AND EmergencyServices = 'Yes'
   ORDER BY HospitalName;

--  All patients registered with doctors based at hospitals with < 400 beds
 CREATE OR REPLACE VIEW list_patients_at_small_hospitals AS
   SELECT p.PatientID,
   CONCAT(p.FirstName,' ', p.LastName) AS 'Patient Name',
          p.Address,
   CONCAT(d.FirstName,' '',d.LastName) AS 'Doctor Name',
          h.HospitalName,
          h.NumberOfBeds
  FROM patients p
  JOIN doctors d ON d.DoctorID = p.DoctorID
  JOIN hospitals h ON h.HospitalID = d.HospitalID
  WHERE h.NumberOfBeds <400
  ORDER BY h.HospitalName, p.LastName, p.FirstName;
 


 


 
 