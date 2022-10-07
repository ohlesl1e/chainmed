-- MySQL Workbench Forward Engineering
SET
  @OLD_UNIQUE_CHECKS = @ @UNIQUE_CHECKS,
  UNIQUE_CHECKS = 0;

SET
  @OLD_FOREIGN_KEY_CHECKS = @ @FOREIGN_KEY_CHECKS,
  FOREIGN_KEY_CHECKS = 0;

SET
  @OLD_SQL_MODE = @ @SQL_MODE,
  SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb`;

USE `mydb`;

-- -----------------------------------------------------
-- Table `mydb`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`user` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `wallet` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`user_id`, `wallet`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `wallet_UNIQUE` (`wallet` ASC) VISIBLE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`medicine`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`medicine` (
  `medicine_id` INT NOT NULL,
  `PRODUCTID` VARCHAR(64) NOT NULL,
  `PRODUCTNDC` VARCHAR(16) NOT NULL,
  `PRODUCTTYPENAME` VARCHAR(31) NOT NULL,
  `PROPRIETARYNAME` VARCHAR(256),
  `PROPRIETARYNAMESUFFIX` VARCHAR(256),
  `NONPROPRIETARYNAME` VARCHAR(512),
  `DOSAGEFORMNAME` VARCHAR(64) NOT NULL,
  `ROUTENAME` VARCHAR(128),
  `STARTMARKETINGDATE` DECIMAL(64, 0) NOT NULL,
  `ENDMARKETINGDATE` DECIMAL(64, 0),
  `MARKETINGCATEGORYNAME` VARCHAR(64) NOT NULL,
  `APPLICATIONNUMBER` VARCHAR(32),
  `LABELERNAME` VARCHAR(256) NOT NULL,
  `SUBSTANCENAME` VARCHAR(4096),
  `ACTIVE_NUMERATOR_STRENGTH` VARCHAR(1024),
  `ACTIVE_INGRED_UNIT` VARCHAR(2048),
  `PHARM_CLASSES` VARCHAR(4096),
  `DEASCHEDULE` VARCHAR(8),
  `NDC_EXCLUDE_FLAG` BOOL NOT NULL,
  `LISTING_RECORD_CERTIFIED_THROUGH` DECIMAL(64, 0),
  PRIMARY KEY (`medicine_id`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`pharmacy`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`pharmacy` (
  `pharmacy_id` INT NOT NULL,
  `address` VARCHAR(45) NULL,
  `city` VARCHAR(45) NULL,
  `state` VARCHAR(45) NULL,
  `country` VARCHAR(45) NULL,
  `zipcode` INT NULL,
  PRIMARY KEY (`pharmacy_id`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`doctor` (
  `doctor_id` INT NOT NULL AUTO_INCREMENT,
  `user_user_id` INT NOT NULL,
  `user_wallet` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`doctor_id`, `user_user_id`, `user_wallet`),
  INDEX `fk_doctor_user_idx` (`user_user_id` ASC, `user_wallet` ASC) VISIBLE,
  CONSTRAINT `fk_doctor_user` FOREIGN KEY (`user_user_id`, `user_wallet`) REFERENCES `mydb`.`user` (`user_id`, `wallet`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`patient` (
  `patient_id` INT NOT NULL AUTO_INCREMENT,
  `patient_profile` VARCHAR(45) NOT NULL,
  `user_user_id` INT NOT NULL,
  `user_wallet` VARCHAR(45) NOT NULL,
  PRIMARY KEY (
    `patient_id`,
    `patient_profile`,
    `user_user_id`,
    `user_wallet`
  ),
  INDEX `fk_patient_user1_idx` (`user_user_id` ASC, `user_wallet` ASC) VISIBLE,
  CONSTRAINT `fk_patient_user1` FOREIGN KEY (`user_user_id`, `user_wallet`) REFERENCES `mydb`.`user` (`user_id`, `wallet`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`pharmacy_has_medicine`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`pharmacy_has_medicine` (
  `pharmacy_pharmacy_id` INT NOT NULL,
  `medicine_medicine_id` INT NOT NULL,
  PRIMARY KEY (`pharmacy_pharmacy_id`, `medicine_medicine_id`),
  INDEX `fk_pharmacy_has_medicine_medicine1_idx` (`medicine_medicine_id` ASC) VISIBLE,
  INDEX `fk_pharmacy_has_medicine_pharmacy1_idx` (`pharmacy_pharmacy_id` ASC) VISIBLE,
  CONSTRAINT `fk_pharmacy_has_medicine_pharmacy1` FOREIGN KEY (`pharmacy_pharmacy_id`) REFERENCES `mydb`.`pharmacy` (`pharmacy_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pharmacy_has_medicine_medicine1` FOREIGN KEY (`medicine_medicine_id`) REFERENCES `mydb`.`medicine` (`medicine_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`patient_has_pharmacy`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`patient_has_pharmacy` (
  `patient_patient_id` INT NOT NULL,
  `patient_patient_profile` VARCHAR(45) NOT NULL,
  `patient_user_user_id` INT NOT NULL,
  `patient_user_wallet` VARCHAR(45) NOT NULL,
  `pharmacy_pharmacy_id` INT NOT NULL,
  PRIMARY KEY (
    `patient_patient_id`,
    `patient_patient_profile`,
    `patient_user_user_id`,
    `patient_user_wallet`,
    `pharmacy_pharmacy_id`
  ),
  INDEX `fk_patient_has_pharmacy_pharmacy1_idx` (`pharmacy_pharmacy_id` ASC) VISIBLE,
  INDEX `fk_patient_has_pharmacy_patient1_idx` USING BTREE (
    `patient_patient_id`,
    `patient_patient_profile`,
    `patient_user_user_id`,
    `patient_user_wallet`
  ) VISIBLE,
  CONSTRAINT `fk_patient_has_pharmacy_patient1` FOREIGN KEY (
    `patient_patient_id`,
    `patient_patient_profile`,
    `patient_user_user_id`,
    `patient_user_wallet`
  ) REFERENCES `mydb`.`patient` (
    `patient_id`,
    `patient_profile`,
    `user_user_id`,
    `user_wallet`
  ) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_patient_has_pharmacy_pharmacy1` FOREIGN KEY (`pharmacy_pharmacy_id`) REFERENCES `mydb`.`pharmacy` (`pharmacy_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

USE `mydb`;

DELIMITER $ $ USE `mydb` $ $ CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`doctor_BEFORE_INSERT` BEFORE
INSERT
  ON `doctor` FOR EACH ROW BEGIN DECLARE uid INT;

SELECT
  user_id INTO @uid
FROM
  user
WHERE
  wallet = NEW.user_wallet;

IF @uid IS NULL
OR @uid = '' THEN
INSERT INTO
  user (wallet)
values
  (NEW.user_wallet);

SET
  NEW.user_user_id = LAST_INSERT_ID();

ELSE
SET
  NEW.user_user_id = @uid;

END IF;

END $ $ USE `mydb` $ $ CREATE DEFINER = `root` @`localhost` TRIGGER `patient_BEFORE_INSERT` BEFORE
INSERT
  ON `patient` FOR EACH ROW BEGIN DECLARE uid INT;

SELECT
  user_id INTO @uid
FROM
  user
WHERE
  wallet = NEW.user_wallet;

IF @uid IS NULL
OR @uid = '' THEN
INSERT INTO
  user (wallet)
values
  (NEW.user_wallet);

SET
  NEW.user_user_id = LAST_INSERT_ID();

ELSE
SET
  NEW.user_user_id = @uid;

END IF;

END $ $ DELIMITER;

SET
  SQL_MODE = @OLD_SQL_MODE;

SET
  FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;

SET
  UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;