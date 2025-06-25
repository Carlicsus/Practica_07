-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: hospital_general_8a_idgs_220526
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tbb_aprobaciones`
--

DROP TABLE IF EXISTS `tbb_aprobaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_aprobaciones` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Solicitud_ID` int unsigned NOT NULL,
  `Comentario` text,
  `Estatus` enum('En Proceso','Pausado','Aprobado','Reprogramado','Cancelado') NOT NULL,
  `Tipo` enum('Servicio Interno','Traslados','Subrogado','Administrativo') NOT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_aprobaciones_idx` (`Personal_Medico_ID`),
  KEY `fk_aprobaciones_solicitud_idx` (`Solicitud_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_aprobaciones`
--

LOCK TABLES `tbb_aprobaciones` WRITE;
/*!40000 ALTER TABLE `tbb_aprobaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_aprobaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_aprobaciones_BEFORE_INSERT` BEFORE INSERT ON `tbb_aprobaciones` FOR EACH ROW BEGIN
    -- Declaración de variables
    DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'En Proceso';
    DECLARE v_tipo_solicitud VARCHAR(20) DEFAULT 'Servicio Interno';
    DECLARE personal_medico VARCHAR(200) DEFAULT 'No Aplica';
    DECLARE v_personal_medico_id INT;
    DECLARE v_solicitud_id INT;
    DECLARE solicitud VARCHAR(200) DEFAULT 'Sin datos de Solicitud';

	-- Restringir titulo
	-- DECLARE v_titulo VARCHAR(20);
    
    -- Asignar el id del personal médico
    SET v_personal_medico_id = NEW.personal_medico_id;
    
    -- Asignación de la solicitud
    SET v_solicitud_id = NEW.solicitud_id;
    
    
    -- ----------------------------------
        -- Verificar mediante una condicion si el Titulo es permitido
    /*
    SELECT p.Titulo INTO v_titulo
    FROM tbb_personas p
    WHERE p.id = v_personal_medico_id;

    IF v_titulo NOT IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo no permitido. La Solicitud solo está permitida para Dr., Dra., Lic., Ing, Tec., Q.F.C.';
    END IF;
    */
	-- ----------------------------------
    -- Intentar obtener el nombre del personal médico con su rol
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET personal_medico = 'No Aplica - Sin Rol';
        SELECT CONCAT(p.Titulo, ' ', p.Nombre, ' ', p.Primer_Apellido, ' ', COALESCE(p.Segundo_Apellido, ''), ' - ', COALESCE(r.nombre, 'Sin Rol'))
        INTO personal_medico
        FROM tbb_personas p
        LEFT JOIN tbc_roles r ON p.id = r.id
        WHERE p.id = v_personal_medico_id AND p.Titulo IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.');
    END;

    -- Intentar obtener la descripción de la solicitud
    BEGIN
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET solicitud = 'Sin datos de Solicitud';
		SELECT CONCAT('Prioridad: ', Prioridad, ' - ', 'Estatus: ', Estatus, ' ')
		INTO solicitud
		FROM tbd_solicitudes
		WHERE id = v_solicitud_id;
	END;
    
    -- Validación del estatus del registro
    CASE NEW.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;

    -- Validación del tipo de solicitud
    CASE NEW.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;

    -- Inserción en la tabla tbi_bitacora
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Create',
        'tbb_aprobaciones',
        CONCAT(
            'Se ha registrado una nueva aprobación con los siguientes datos:', '\n',
            'Personal Médico: ', personal_medico, '\n',
            'Datos de Solicitud: ', solicitud , '\n',
            'Comentario: ', COALESCE(NEW.comentario, 'Sin Comentarios'), '\n',
            'Estatus: ', v_estatus_descripcion, '\n',
            'Tipo: ', v_tipo_solicitud, '\n',
            'Fecha de Registro: ', COALESCE(NEW.fecha_registro, 'N/A'), '\n',
            'Fecha de Actualización: ', COALESCE(NEW.fecha_actualizacion, 'N/A')
        ),
        default,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_aprobaciones_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_aprobaciones` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_aprobaciones_AFTER_UPDATE` AFTER UPDATE ON `tbb_aprobaciones` FOR EACH ROW BEGIN

	  -- Declaración de variables
    DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'En Proceso';
    DECLARE v_tipo_solicitud VARCHAR(20) DEFAULT 'Servicio Interno';
    DECLARE personal_medico VARCHAR(200) DEFAULT 'No Aplica';
    DECLARE v_personal_medico_id INT;
    DECLARE v_solicitud_id INT;
    DECLARE solicitud VARCHAR(200) DEFAULT 'Sin datos de Solicitud';

	-- Restringir titulo
	-- DECLARE v_titulo VARCHAR(20);
    
    -- Asignar el id del personal médico
    SET v_personal_medico_id = NEW.personal_medico_id;
    
    -- Asignación de la solicitud
    SET v_solicitud_id = NEW.solicitud_id;
    
    
    -- ----------------------------------
        -- Verificar mediante una condicion si el Titulo es permitido
    /*
    SELECT p.Titulo INTO v_titulo
    FROM tbb_personas p
    WHERE p.id = v_personal_medico_id;

    IF v_titulo NOT IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo no permitido. La Solicitud solo está permitida para Dr., Dra., Lic., Ing, Tec., Q.F.C.';
    END IF;
    */
	-- ----------------------------------
    -- Intentar obtener el nombre del personal médico con su rol
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET personal_medico = 'No Aplica - Sin Rol';
        SELECT CONCAT(p.Titulo, ' ', p.Nombre, ' ', p.Primer_Apellido, ' ', COALESCE(p.Segundo_Apellido, ''), ' - ', COALESCE(r.nombre, 'Sin Rol'))
        INTO personal_medico
        FROM tbb_personas p
        LEFT JOIN tbc_roles r ON p.id = r.id
        WHERE p.id = v_personal_medico_id AND p.Titulo IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.');
    END;

    -- Intentar obtener la descripción de la solicitud
    BEGIN
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET solicitud = 'Sin datos de Solicitud';
		SELECT CONCAT('Su Prioridad es: ', Prioridad, ' - ', 'Su estatus es: ', Estatus, ' ')
		INTO solicitud
		FROM tbd_solicitudes
		WHERE id = v_solicitud_id;
	END;
    
    -- Validación del estatus del registro
    CASE NEW.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;
    
	CASE OLD.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;

    -- Validación del tipo de solicitud
    CASE NEW.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;
    
	CASE OLD.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;

    -- Inserción en la tabla tbi_bitacora
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Update',
        'tbb_aprobaciones',
        CONCAT(
            'Se ha registrado una nueva aprobación con los siguientes datos:', '\n',
            'Personal Médico: ', personal_medico, '\n',
            'Solicitud: ', solicitud , '\n',
			'Comentario: ', COALESCE(CONCAT('- Se Complementó: ', NEW.comentario), COALESCE(old.comentario, 'Sin Nuevos Comentarios')),'\n',
            'Estatus Inicial: ', v_estatus_descripcion, '\n',
			'Estatus: ', COALESCE(CONCAT('- Actualizado: ', NEW.Estatus), COALESCE(old.Estatus, 'Sin Cambio de Estado')),'\n',
            'Tipo: ', v_tipo_solicitud, '\n',
			'Tipo: ', COALESCE(CONCAT('- Se Actualizo: ', NEW.Tipo), COALESCE(old.Tipo, 'Sin Cambio')),'\n',
            'Fecha de Registro: ', COALESCE(NEW.fecha_registro, 'N/A'), '\n',
            'Fecha de Actualización: ', COALESCE(NEW.fecha_actualizacion, 'N/A')
        ),
        default,
        NOW()
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_aprobaciones_AFTER_DELETE` AFTER DELETE ON `tbb_aprobaciones` FOR EACH ROW BEGIN
    -- Declaración de variables
    DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'En Proceso';
    DECLARE v_tipo_solicitud VARCHAR(20) DEFAULT 'Servicio Interno';
    DECLARE personal_medico VARCHAR(200) DEFAULT 'No Aplica';
    DECLARE v_personal_medico_id INT;
    DECLARE v_solicitud_id INT;
    DECLARE solicitud VARCHAR(200) DEFAULT 'Sin datos de Solicitud';

	-- Restringir titulo
	-- DECLARE v_titulo VARCHAR(20);
    
    -- Asignar el id del personal médico
    SET v_personal_medico_id = old.personal_medico_id;
    
    -- Asignación de la solicitud
    SET v_solicitud_id = old.solicitud_id;
    
    
    -- ----------------------------------
        -- Verificar mediante una condicion si el Titulo es permitido
    /*
    SELECT p.Titulo INTO v_titulo
    FROM tbb_personas p
    WHERE p.id = v_personal_medico_id;

    IF v_titulo NOT IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Titulo no permitido. La Solicitud solo está permitida para Dr., Dra., Lic., Ing, Tec., Q.F.C.';
    END IF;
    */
	-- ----------------------------------
    -- Intentar obtener el nombre del personal médico con su rol
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET personal_medico = 'No Aplica - Sin Rol';
        SELECT CONCAT(p.Titulo, ' ', p.Nombre, ' ', p.Primer_Apellido, ' ', COALESCE(p.Segundo_Apellido, ''), ' - ', COALESCE(r.nombre, 'Sin Rol'))
        INTO personal_medico
        FROM tbb_personas p
        LEFT JOIN tbc_roles r ON p.id = r.id
        WHERE p.id = v_personal_medico_id AND p.Titulo IN ('Dr.', 'Dra.',  'Lic.', 'Ing.', 'Tec.', 'Q.F.C.');
    END;

    -- Intentar obtener la descripción de la solicitud
    BEGIN
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET solicitud = 'Sin datos de Solicitud';
		SELECT CONCAT('Su Prioridad es: ', Prioridad, ' - ', 'Su estatus es: ', Estatus, ' ')
		INTO solicitud
		FROM tbd_solicitudes
		WHERE id = v_solicitud_id;
	END;
    
    -- Validación del estatus del registro
    CASE old.Estatus
        WHEN 'En Proceso' THEN SET v_estatus_descripcion = 'En Proceso';
        WHEN 'Pausado' THEN SET v_estatus_descripcion = 'Pausado';
        WHEN 'Aprobado' THEN SET v_estatus_descripcion = 'Aprobado';
        WHEN 'Reprogramado' THEN SET v_estatus_descripcion = 'Reprogramado';
        WHEN 'Cancelado' THEN SET v_estatus_descripcion = 'Cancelado';
    END CASE;

    -- Validación del tipo de solicitud
    CASE old.tipo
        WHEN 'Servicio Interno' THEN SET v_tipo_solicitud = 'Servicio Interno';
        WHEN 'Traslados' THEN SET v_tipo_solicitud = 'Traslados';
        WHEN 'Subrogado' THEN SET v_tipo_solicitud = 'Subrogado';
        WHEN 'Administrativo' THEN SET v_tipo_solicitud = 'Administrativo';
    END CASE;

    -- Inserción en la tabla tbi_bitacora
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Delete',
        'tbb_aprobaciones',
        CONCAT(
            'Se ha Eliminado un Registro con los Siguientes Datos:', '\n',
            'Personal Médico: ', personal_medico, '\n',
            'Solicitud: ', solicitud , '\n',
            'Comentario: ', COALESCE(old.comentario, 'Sin Comentarios'), '\n',
            'Estatus: ', v_estatus_descripcion, '\n',
            'Tipo: ', v_tipo_solicitud, '\n',
            'Fecha de Registro: ', COALESCE(old.fecha_registro, 'N/A'), '\n',
            'Fecha de Actualización: ', COALESCE(old.fecha_actualizacion, 'N/A')
        ),
        default,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_cirugias`
--

DROP TABLE IF EXISTS `tbb_cirugias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_cirugias` (
  `ID` char(36) NOT NULL COMMENT 'Descripción: Identificador principal del conjunto de registros.\\nNaturaleza: Cuantitativo\\nDominio: Carácteres   Hexadecimal (0-F)\\nCompocición:  8(0-F)4+''-''+4(0-F)4+''-''+4(0-F)4+''-''+4(0-F)4+''-''+''-''+12(0-F)11',
  `Paciente_ID` char(36) NOT NULL COMMENT 'Descripción: Identificador único del paciente al que se le realiza la cirugía.\n\nNaturaleza: Alfanumérico.\n\nDominio: UUID en formato CHAR(36), representado en notación hexadecimal.\n\nComposición: 8(0-F)4+''-''+4(0-F)4+''-''+4(0-F)4+''-''+4(0-F)4+''-''+12(0-F)11.',
  `Espacio_Medico_ID` char(36) NOT NULL COMMENT 'Descripción: Identificador único del espacio médico donde se realiza la cirugía.\n\nNaturaleza: Alfanumérico.\n\nDominio: UUID en formato CHAR(36), representado en notación hexadecimal.\n\nComposición: 8(0-F)4+''-''+4(0-F)4+''-''+4(0-F)4+''-''+4(0-F)4+''-''+12(0-F)11.',
  `Tipo` varchar(50) NOT NULL COMMENT 'Descripción: Categoría o clasificación de la cirugía realizada.\n\nNaturaleza: Cualitativo.\n\nDominio: Cadena de texto con un máximo de 50 caracteres (VARCHAR(50)).\n\nComposición: Texto descriptivo que define el tipo de cirugía, como "Cirugía General", "Cardiovascular", "Neurocirugía", "Ortopédica", entre otros.',
  `Nombre` varchar(100) NOT NULL COMMENT 'Descripción: Denominación específica de la cirugía realizada.\n\nNaturaleza: Cualitativo.\n\nDominio: Cadena de texto con un máximo de 100 caracteres (VARCHAR(100)).\n\nComposición: Texto descriptivo que indica el nombre exacto de la cirugía, como "Apendicectomía", "Bypass Coronario", "Reemplazo de Cadera", "Craneotomía", entre otros.',
  `Descripcion` text NOT NULL COMMENT 'Descripción: Detalles adicionales sobre la cirugía realizada.\n\nNaturaleza: Cualitativo.\n\nDominio: Texto libre (TEXT).\n\nComposición: Composición: (a-z|A-Z).',
  `Nivel_Urgencia` enum('Bajo','Medio','Alto') NOT NULL COMMENT 'Descripción: Grado de prioridad con el que debe realizarse la cirugía.\\n\\nNaturaleza: Cualitativo.\\n\\nDominio: Enumeración (ENUM(''Bajo'', ''Medio'', ''Alto'')).\\n\\nComposición: 0("Bajo"|"Medio"|"Alto")5',
  `Observaciones` text NOT NULL COMMENT 'Descripción: Notas adicionales sobre la cirugía, registradas por el personal médico para detallar aspectos relevantes del procedimiento.\n\n\nNaturaleza: Cualitativo.\n\n\nDominio: Caracteres alfanumericos.\n\n\nComposición: 0(cadena de caracteres)∞',
  `Estatus` enum('Programada','En curso','Completada','Cancelada') NOT NULL COMMENT 'Descripción: Estado actual de la cirugía dentro del sistema, indicando su progreso o finalización.\n\n\nNaturaleza: Cualitativo.\n\n\nDominio: Caracteres Alfabeticos\nComposición: 0("Programada" | "En curso" | "Completada" | "Cancelada")4',
  `Fecha_Registro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Descripción: Momento en que se registró la cirugía en el sistema.\n\n\nNaturaleza: Cuantitativo.\n\n\nDominio: Formato de fecha y hora (TIMESTAMP).\n\n\nComposición: (YYYY-MM-DD HH:MM:SS)',
  `Fecha_Actualizacion` datetime NOT NULL COMMENT 'Descripción: Última modificación realizada en el registro de la cirugía.\n\n\nNaturaleza: Cuantitativo.\n\n\nDominio: Formato de fecha y hora (DATETIME).\n\n\nComposición: YYYY-MM-DD HH:MM:SS',
  PRIMARY KEY (`ID`),
  KEY `fk_paciente_idx` (`Paciente_ID`),
  KEY `fk_espacio_idx` (`Espacio_Medico_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Esta tabla almacenará la información de las cirugías realizadas en el sistema. Representa una superentidad, ya que sus datos serán heredados por subentidades que detallan tipos específicos de cirugías o procedimientos médicos asociados.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_cirugias`
--

LOCK TABLES `tbb_cirugias` WRITE;
/*!40000 ALTER TABLE `tbb_cirugias` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_cirugias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbb_citas_medicas`
--

DROP TABLE IF EXISTS `tbb_citas_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_citas_medicas` (
  `ID` char(36) NOT NULL DEFAULT (uuid()),
  `Personal_Medico_ID` char(36) NOT NULL,
  `Paciente_ID` char(36) NOT NULL,
  `Servicio_Medico_ID` char(36) NOT NULL,
  `Folio` varchar(60) NOT NULL,
  `Tipo` enum('Revisión','Diagnóstico','Tratamiento','Rehabilitación','Preoperatoria','Postoperatoria','Proceminientos','Seguimiento') NOT NULL,
  `Espacio_ID` char(36) NOT NULL,
  `Fecha_Programada` datetime NOT NULL,
  `Fecha_Inicio` datetime DEFAULT NULL,
  `Fecha_Termino` datetime DEFAULT NULL,
  `Observaciones` text NOT NULL,
  `Estatus` enum('Programada','Atendida','Cancelada','Reprogramada','No Atendida','EnProceso') NOT NULL,
  `Fecha_Registro` datetime NOT NULL,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Folio` (`Folio`),
  KEY `fk_citas_personal` (`Personal_Medico_ID`),
  KEY `fk_citas_paciente` (`Paciente_ID`),
  KEY `fk_citas_servicio` (`Servicio_Medico_ID`),
  KEY `fk_citas_espacio` (`Espacio_ID`),
  CONSTRAINT `fk_citas_espacio` FOREIGN KEY (`Espacio_ID`) REFERENCES `tbc_espacios` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_citas_paciente` FOREIGN KEY (`Paciente_ID`) REFERENCES `tbb_pacientes` (`Persona_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_citas_personal` FOREIGN KEY (`Personal_Medico_ID`) REFERENCES `tbb_personal_medico` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_citas_servicio` FOREIGN KEY (`Servicio_Medico_ID`) REFERENCES `tbc_servicios_medicos` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_citas_medicas`
--

LOCK TABLES `tbb_citas_medicas` WRITE;
/*!40000 ALTER TABLE `tbb_citas_medicas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_citas_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_citas_medicas_AFTER_INSERT` AFTER INSERT ON `tbb_citas_medicas` FOR EACH ROW BEGIN

    DECLARE descripcion_cita TEXT;

    -- Construir descripción para la bitácora
    SET descripcion_cita = CONCAT_WS('\n',
        CONCAT('Se ha registrado una nueva CITA MÉDICA con ID: ', NEW.ID),
        CONCAT('Folio: ', NEW.Folio),
        CONCAT('ID del Paciente: ', NEW.Paciente_ID),
        CONCAT('ID del Médico: ', NEW.Personal_Medico_ID),
        CONCAT('Servicio Médico: ', NEW.Servicio_Medico_ID),
        CONCAT('Tipo de Cita: ', NEW.Tipo),
        CONCAT('Espacio Asignado: ', NEW.Espacio_ID),
        CONCAT('Fecha Programada: ', NEW.Fecha_Programada),
        CONCAT('Estatus: ', NEW.Estatus)
    );

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Create',
        'tbb_citas_medicas',
        descripcion_cita,
        b'1',
        NOW()
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_citas_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_citas_medicas` FOR EACH ROW BEGIN
   SET new.Fecha_Actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_citas_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbb_citas_medicas` FOR EACH ROW BEGIN
    DECLARE descripcion_actualizacion TEXT;

    -- Construir descripción de la actualización
    SET descripcion_actualizacion = CONCAT_WS('\n',
        CONCAT('Se ha actualizado una CITA MÉDICA con ID: ', OLD.ID),
        CONCAT('Folio anterior: ', OLD.Folio, ' → nuevo: ', NEW.Folio),
        CONCAT('Paciente_ID: ', OLD.Paciente_ID, ' → ', NEW.Paciente_ID),
        CONCAT('Personal_Medico_ID: ', OLD.Personal_Medico_ID, ' → ', NEW.Personal_Medico_ID),
        CONCAT('Servicio_Medico_ID: ', OLD.Servicio_Medico_ID, ' → ', NEW.Servicio_Medico_ID),
        CONCAT('Tipo: ', OLD.Tipo, ' → ', NEW.Tipo),
        CONCAT('Espacio_ID: ', OLD.Espacio_ID, ' → ', NEW.Espacio_ID),
        CONCAT('Fecha Programada: ', OLD.Fecha_Programada, ' → ', NEW.Fecha_Programada),
        CONCAT('Fecha Inicio: ', OLD.Fecha_Inicio, ' → ', NEW.Fecha_Inicio),
        CONCAT('Fecha Término: ', OLD.Fecha_Termino, ' → ', NEW.Fecha_Termino),
        CONCAT('Estatus: ', OLD.Estatus, ' → ', NEW.Estatus)
    );

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Update',
        'tbb_citas_medicas',
        descripcion_actualizacion,
        b'1',
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_citas_medicas_AFTER_DELETE` AFTER DELETE ON `tbb_citas_medicas` FOR EACH ROW BEGIN

    DECLARE descripcion_eliminacion TEXT;

    -- Construir descripción de la eliminación
    SET descripcion_eliminacion = CONCAT_WS('\n',
        CONCAT('Se ha ELIMINADO una CITA MÉDICA con ID: ', OLD.ID),
        CONCAT('Folio: ', OLD.Folio),
        CONCAT('Paciente_ID: ', OLD.Paciente_ID),
        CONCAT('Personal_Medico_ID: ', OLD.Personal_Medico_ID),
        CONCAT('Servicio_Medico_ID: ', OLD.Servicio_Medico_ID),
        CONCAT('Tipo: ', OLD.Tipo),
        CONCAT('Espacio_ID: ', OLD.Espacio_ID),
        CONCAT('Fecha Programada: ', OLD.Fecha_Programada),
        CONCAT('Estatus en el momento de eliminación: ', OLD.Estatus)
    );

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Delete',
        'tbb_citas_medicas',
        descripcion_eliminacion,
        b'1',
        NOW()
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_nacimientos`
--

DROP TABLE IF EXISTS `tbb_nacimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_nacimientos` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Padre` varchar(100) NOT NULL,
  `Madre` varchar(100) NOT NULL,
  `Signos_vitales` varchar(10) NOT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Calificacion_APGAR` int NOT NULL,
  `Observaciones` varchar(45) NOT NULL,
  `Genero` enum('M','F') NOT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_nacimientos`
--

LOCK TABLES `tbb_nacimientos` WRITE;
/*!40000 ALTER TABLE `tbb_nacimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_nacimientos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_nacimientos_AFTER_INSERT` AFTER INSERT ON `tbb_nacimientos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora 
    VALUES ( default,
        current_user(), 
        'Create',
        'tbb_nacimientos', 
        CONCAT_WS('', 
            'Se ha agregado un nuevo registro en tbb_nacimientos con el ID: ', NEW.ID,
            ', con los siguientes datos; ',
            'Nombre del Padre: ', NEW.Padre,
            ', Nombre de la Madre: ', NEW.Madre,
            ', Signos Vitales: ', NEW.Signos_vitales,
            ', Estatus: ', NEW.Estatus,
            ', Calificación APGAR: ', NEW.Calificacion_APGAR,
            ', Observaciones: ', NEW.Observaciones,
            ', Genero: ', NEW.Genero
        ), 
        default,
        default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_nacimientos_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_nacimientos` FOR EACH ROW BEGIN
	SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_nacimientos_AFTER_UPDATE` AFTER UPDATE ON `tbb_nacimientos` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora 
    VALUES ( default,
		current_user(),
        'Update', 
        'tbb_nacimientos', 
        CONCAT_WS('', 
            'Se ha actualizado el registro en tbb_nacimientos con el ID: ', NEW.ID,
            ', con los siguientes datos actualizados; ',
            'Nombre del Padre: ', NEW.Padre,
            ', Nombre de la Madre: ', NEW.Madre,
            ', Signos Vitales: ', NEW.Signos_vitales,
            ', Estatus: ', NEW.Estatus,
            ', Calificación APGAR: ', NEW.Calificacion_APGAR,
            ', Observaciones: ', NEW.Observaciones,
            ', Genero: ', NEW.Genero
        ), 
        default,
        default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_nacimientos_AFTER_DELETE` AFTER DELETE ON `tbb_nacimientos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES ( default,
		current_user(),
        'Delete', 
        'tbb_nacimientos',
        CONCAT_WS('', 
            'Se ha eliminado un registro en tbb_nacimientos con el ID: ', OLD.ID,
            ', que contenía los siguientes datos; ',
            'Nombre del Padre: ', OLD.Padre,
            ', Nombre de la Madre: ', OLD.Madre,
            ', Signos Vitales: ', OLD.Signos_vitales,
            ', Estatus: ', OLD.Estatus,
            ', Calificación APGAR: ', OLD.Calificacion_APGAR,
            ', Observaciones: ', OLD.Observaciones,
            ', Genero: ', OLD.Genero
        ), 
        default,
        default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_pacientes`
--

DROP TABLE IF EXISTS `tbb_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_pacientes` (
  `Persona_ID` char(36) NOT NULL,
  `NSS` varchar(15) DEFAULT NULL,
  `Tipo_Seguro` varchar(50) NOT NULL,
  `Fecha_Ultima_Cita` datetime DEFAULT NULL,
  `Estatus_Medico` varchar(100) DEFAULT 'Normal',
  `Estatus_Vida` enum('Vivo','Finado','Coma','Vegetativo') NOT NULL DEFAULT 'Vivo',
  `Estatus` binary(1) DEFAULT '',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Persona_ID`),
  UNIQUE KEY `NSS_UNIQUE` (`NSS`),
  CONSTRAINT `fk_pacientes_persona` FOREIGN KEY (`Persona_ID`) REFERENCES `tbb_personas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='	';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_pacientes`
--

LOCK TABLES `tbb_pacientes` WRITE;
/*!40000 ALTER TABLE `tbb_pacientes` DISABLE KEYS */;
INSERT INTO `tbb_pacientes` VALUES ('5253f56b-0ff8-11f0-b70d-3c557613b8e0','988915916521954','IMSS','2024-11-14 00:00:00','Normal','Finado',_binary '1','2025-04-02 13:26:05',NULL);
/*!40000 ALTER TABLE `tbb_pacientes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_pacientes_AFTER_INSERT` AFTER INSERT ON `tbb_pacientes` FOR EACH ROW BEGIN
	  declare v_estatus varchar(20) default 'Activo';
      
		if not new.Estatus then
			set v_estatus = 'Inactivo';
		end if;
      
      insert into tbi_bitacora values(
		default,
		current_user(),
		'Create',
		'tbb_pacientes',
		concat_ws(' ','Se ha creado un nuevo paciente con los siguientes datos: \n',
		'NSS: ', new.NSS, '\n', 
		'TIPO SEGURO: ', new.Tipo_Seguro, '\n', 
		'ESTATUS MEDICO: ', new.Estatus_Medico, '\n', 
		'ESTATUS VIDA: ', new.Estatus_Vida, '\n',
        'ESTATUS: ', v_estatus, '\n'),
		default,
		default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_pacientes_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_pacientes` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp(); 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_pacientes_AFTER_UPDATE` AFTER UPDATE ON `tbb_pacientes` FOR EACH ROW BEGIN
	 declare v_estatus_old varchar(20) default 'Activo';
     declare v_estatus_new varchar(20) default 'Activo';
      
		if not new.Estatus then
			set v_estatus_new = 'Inactivo';
		end if;
        if not new.Estatus then
			set v_estatus_old = 'Inactivo';
		end if;
        
    
    insert into tbi_bitacora values(
			default,
			current_user(),
			'Update',
			'tbb_pacientes',
			concat_ws(' ','Se ha creado un modificado al paciente con NSS: ',old.NSS,'con los siguientes datos: \n',
			'NSS: ', old.NSS,' -> ',new.NSS, '\n', 
			'TIPO SEGURO: ', old.Tipo_Seguro,' -> ',new.Tipo_Seguro, '\n', 
			'ESTATUS MEDICO: ', old.Estatus_Medico,' -> ',new.Estatus_Medico, '\n', 
			'ESTATUS VIDA: ', old.	Estatus_Vida,' -> ',new.Estatus_Vida, '\n',
            'ESTATUS: ', v_estatus_old, '->',v_estatus_new, '\n'),
			default,
			default
		);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_pacientes_AFTER_DELETE` AFTER DELETE ON `tbb_pacientes` FOR EACH ROW BEGIN
	declare v_estatus varchar(20) default 'Activo';
      
		if not old.Estatus then
			set v_estatus = 'Inactivo';
		end if;
    
    insert into tbi_bitacora values(
		default,
		current_user(),
		'Delete',
		'tbb_pacientes',
		concat_ws(' ','Se ha eliminado un paciente existente con NSS: ',old.NSS,'y con los siguientes datos: \n',
		'TIPO SEGURO: ', old.Tipo_Seguro, '\n', 
		'ESTATUS MEDICO: ', old.Estatus_Medico, '\n', 
		'ESTATUS VIDA: ', old.Estatus_Vida, '\n'
        'ESTATUS: ', v_estatus, '\n'),
		default,
		default
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_personal_medico`
--

DROP TABLE IF EXISTS `tbb_personal_medico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_personal_medico` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `persona_id` char(36) NOT NULL,
  `departamento_id` char(36) NOT NULL,
  `cedula_profesional` varchar(100) NOT NULL,
  `tipo` enum('Medico','Enfermero','Administrativo','Directivo','Apoyo','Residente','Interno') NOT NULL,
  `especialidad` varchar(255) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL,
  `fecha_contratacion` datetime NOT NULL,
  `fecha_termino_contrato` datetime DEFAULT NULL,
  `salario` decimal(10,2) NOT NULL,
  `estatus` enum('Activo','Inactivo') DEFAULT 'Activo',
  `fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cedula_profesional` (`cedula_profesional`),
  KEY `persona_id` (`persona_id`),
  KEY `departamento_id` (`departamento_id`),
  CONSTRAINT `tbb_personal_medico_ibfk_1` FOREIGN KEY (`persona_id`) REFERENCES `tbb_personas` (`id`),
  CONSTRAINT `tbb_personal_medico_ibfk_2` FOREIGN KEY (`departamento_id`) REFERENCES `tbc_departamentos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_personal_medico`
--

LOCK TABLES `tbb_personal_medico` WRITE;
/*!40000 ALTER TABLE `tbb_personal_medico` DISABLE KEYS */;
INSERT INTO `tbb_personal_medico` VALUES ('12604477-0ff8-11f0-b70d-3c557613b8e0','125e9a19-0ff8-11f0-b70d-3c557613b8e0','7fe03142-0ff7-11f0-b70d-3c557613b8e0','CED-516008eb','Medico',NULL,'2025-04-02 13:24:18','2016-10-02 00:00:00',NULL,29651.13,'Activo',NULL);
/*!40000 ALTER TABLE `tbb_personal_medico` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personal_medico_AFTER_INSERT` AFTER INSERT ON `tbb_personal_medico` FOR EACH ROW BEGIN
 DECLARE persona_nombre_completo VARCHAR(255);
    DECLARE departamento_nombre VARCHAR(255);

    -- Obtener el nombre completo de la persona
    SELECT CONCAT_WS(' ',Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = NEW.Persona_ID;
    
    -- Obtener el nombre del departamento
    SELECT nombre 
    INTO departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = NEW.Departamento_ID;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora
    VALUES
    (
        DEFAULT,
        current_user(),
        'Create',
        'tbb_personal_medico',
        CONCAT_WS(' ',
            'Se ha creado nuevo personal medico con los siguientes datos:', '\n',
            'Nombre de la Persona: ', persona_nombre_completo, '\n',
            'Nombre del Departamento: ', departamento_nombre, '\n',
            'Especialidad: ', NEW.Especialidad, '\n',
            'Tipo: ', NEW.Tipo, '\n',
            'Cedula Profesional: ', NEW.Cedula_Profesional, '\n',
            'Estatus: ', NEW.Estatus, '\n',
            'Fecha de Contratación: ', NEW.Fecha_Contratacion, '\n',
            'Salario: ', NEW.Salario, '\n',
            'Fecha de Actualización: ', NEW.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personal_medico_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_personal_medico` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personal_medico_AFTER_UPDATE` AFTER UPDATE ON `tbb_personal_medico` FOR EACH ROW BEGIN
 DECLARE old_persona_nombre_completo VARCHAR(255);
    DECLARE new_persona_nombre_completo VARCHAR(255);
    DECLARE old_departamento_nombre VARCHAR(255);
    DECLARE new_departamento_nombre VARCHAR(255);

    -- Obtener el nombre completo de la persona antes de la actualización
    SELECT CONCAT_WS(' ', Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO old_persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = OLD.Persona_ID;
    
    -- Obtener el nombre completo de la persona después de la actualización
    SELECT CONCAT_WS(' ', Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO new_persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = NEW.Persona_ID;

    -- Obtener el nombre del departamento antes de la actualización
    SELECT nombre 
    INTO old_departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = OLD.Departamento_ID;
    
    -- Obtener el nombre del departamento después de la actualización
    SELECT nombre 
    INTO new_departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = NEW.Departamento_ID;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora
    VALUES
    (
        DEFAULT,
        current_user(),
        'Update',
        'tbb_personal_medico',
        concat_ws(' ',
            'Se ha modificado el personal médico con los siguientes datos:', '\n',
            'Nombre de la Persona: ', old_persona_nombre_completo, ' -> ', new_persona_nombre_completo, '\n',
            'Nombre del Departamento: ', old_departamento_nombre, ' -> ', new_departamento_nombre, '\n',
            'Especialidad: ', OLD.Especialidad, ' -> ', NEW.Especialidad, '\n',
            'Tipo: ', OLD.Tipo, ' -> ', NEW.Tipo, '\n',
            'Cédula Profesional: ', OLD.Cedula_Profesional, ' -> ', NEW.Cedula_Profesional, '\n',
            'Estatus: ', OLD.Estatus, ' -> ', NEW.Estatus, '\n',
            'Fecha de Contratación: ', OLD.Fecha_Contratacion, ' -> ', NEW.Fecha_Contratacion, '\n',
            'Salario: ', OLD.Salario, ' -> ', NEW.Salario, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personal_medico_AFTER_DELETE` AFTER DELETE ON `tbb_personal_medico` FOR EACH ROW BEGIN
DECLARE persona_nombre_completo VARCHAR(255);
    DECLARE departamento_nombre VARCHAR(255);

    -- Obtener el nombre completo de la persona
    SELECT CONCAT_WS(' ', Nombre, ' ', Primer_Apellido, ' ', Segundo_Apellido) 
    INTO persona_nombre_completo 
    FROM tbb_personas 
    WHERE ID = OLD.Persona_ID;
    
    -- Obtener el nombre del departamento
    SELECT nombre 
    INTO departamento_nombre 
    FROM tbc_departamentos 
    WHERE ID = OLD.Departamento_ID;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora VALUES
    (
        DEFAULT,
        current_user(),
        'Delete',
        'tbb_personal_medico',
        CONCAT_WS(' ',
            'Se ha eliminado personal médico existente con los siguientes datos:',
            '\nNombre de la Persona: ', persona_nombre_completo,
            '\nNombre del Departamento: ', departamento_nombre,
            '\nEspecialidad: ', OLD.Especialidad,
            '\nTipo: ', OLD.Tipo,
            'Cédula Profesional: ', OLD.Cedula_Profesional,
            '\nEstatus: ', OLD.Estatus,
            '\nFecha de Contratación: ', OLD.Fecha_Contratacion,
            '\nSalario: ', OLD.Salario
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_personas`
--

DROP TABLE IF EXISTS `tbb_personas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_personas` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `titulo` varchar(20) DEFAULT NULL,
  `nombre` varchar(80) NOT NULL,
  `primer_apellido` varchar(80) NOT NULL,
  `segundo_apellido` varchar(80) DEFAULT NULL,
  `curp` varchar(18) DEFAULT NULL,
  `genero` enum('M','F','N/B') NOT NULL,
  `grupo_sanguineo` enum('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `estatus` tinyint(1) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `curp` (`curp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_personas`
--

LOCK TABLES `tbb_personas` WRITE;
/*!40000 ALTER TABLE `tbb_personas` DISABLE KEYS */;
INSERT INTO `tbb_personas` VALUES ('09057c00-0ff8-11f0-b70d-3c557613b8e0',NULL,'Fernanda','Castillo','Gutiérrez','CSGF880622FN61','F','O+','1988-06-22',1,'2025-04-02 13:24:02',NULL),('125e9a19-0ff8-11f0-b70d-3c557613b8e0',NULL,'Alex','Rojas','Delgado','RSDA781208N/BO68','N/B','A+','1978-12-08',1,'2025-04-02 13:24:18',NULL),('26f93a89-11a9-11f0-b70d-3c557613b8e0','Lic.','Juan','Rodríguez','Ramírez','RRRJ980929MD63','M','A+','1998-09-29',1,'2025-04-04 17:04:24',NULL),('5253f56b-0ff8-11f0-b70d-3c557613b8e0',NULL,'Andrea','Torres','Gutiérrez','TTGA970301FK45','F','B+','1997-03-01',1,'2025-04-02 13:26:05',NULL),('bdb8af10-11a9-11f0-b70d-3c557613b8e0',NULL,'Miguel','Ramírez','Hernández','RMHM070303MT27','M','B+','2007-03-03',1,'2025-04-04 17:08:37',NULL),('d5732ae1-11a9-11f0-b70d-3c557613b8e0',NULL,'Fernando','Rodríguez','Cruz','RRCF220317MJ30','M','O+','2022-03-17',1,'2025-04-04 17:09:17',NULL),('ee0c917b-11a9-11f0-b70d-3c557613b8e0',NULL,'Javier','Sánchez','Hernández','SSHJ170203MX67','M','A+','2017-02-03',1,'2025-04-04 17:09:58',NULL),('ee9a4acd-51e8-11f0-9f2b-00155d276843','Lic.','Ricardo','González','Rodríguez','GGRR781109MU41','M','O+','1978-11-09',1,'2025-06-25 11:22:12',NULL),('ee9b71d2-51e8-11f0-9f2b-00155d276843','Lic.','Chris','Domínguez','Escobar','DDEC520827N/BZ35','N/B','A+','1952-08-27',1,'2025-06-25 11:22:12',NULL),('ee9c3b3e-51e8-11f0-9f2b-00155d276843','Dr.','Casey','Domínguez','Delgado','DDDC530204N/BA26','N/B','A-','1953-02-04',1,'2025-06-25 11:22:12',NULL),('ee9d6a0f-51e8-11f0-9f2b-00155d276843','Dr.','Javier','Rodríguez','García','RRGJ481226MV57','M','O+','1948-12-26',1,'2025-06-25 11:22:12',NULL),('ee9e122a-51e8-11f0-9f2b-00155d276843',NULL,'Juan','Martínez','López','MRLJ031207MH66','M','O+','2003-12-07',1,'2025-06-25 11:22:12',NULL),('ee9ec858-51e8-11f0-9f2b-00155d276843','Lic.','Gabriela','Navarro','Ortega','NVOG710413FJ73','F','A+','1971-04-13',1,'2025-06-25 11:22:12',NULL),('ee9f751b-51e8-11f0-9f2b-00155d276843','Dr.','Dani','Rojas','Delgado','RSDD640421N/BW89','N/B','AB+','1964-04-21',1,'2025-06-25 11:22:12',NULL),('eea01918-51e8-11f0-9f2b-00155d276843','Lic.','Andrea','Jiménez','Ortega','JJOA820601FM81','F','A+','1982-06-01',1,'2025-06-25 11:22:12',NULL),('eea1037f-51e8-11f0-9f2b-00155d276843','Ing.','María','Castillo','Torres','CSTM701209FU23','F','A+','1970-12-09',1,'2025-06-25 11:22:12',NULL),('eea1f674-51e8-11f0-9f2b-00155d276843','Ing.','Sofía','Castillo','Navarro','CSNS460818FS93','F','A+','1946-08-18',1,'2025-06-25 11:22:12',NULL),('eea29c6d-51e8-11f0-9f2b-00155d276843','Ing.','Robin','Delgado','Silva','DDSR870123N/BB13','N/B','O+','1987-01-23',1,'2025-06-25 11:22:12',NULL),('eea3597d-51e8-11f0-9f2b-00155d276843','Lic.','Carlos','Rodríguez','Ramírez','RRRC490402MF47','M','A+','1949-04-02',1,'2025-06-25 11:22:12',NULL),('eea43c8b-51e8-11f0-9f2b-00155d276843','Lic.','Juan','García','Cruz','GRCJ771129MT27','M','A+','1977-11-29',1,'2025-06-25 11:22:12',NULL),('eea51c97-51e8-11f0-9f2b-00155d276843','Lic.','Chris','Aguilar','Mendoza','AGMC670602N/BC98','N/B','A+','1967-06-02',1,'2025-06-25 11:22:12',NULL),('eea5c0c8-51e8-11f0-9f2b-00155d276843','Dr.','Fernanda','Ortega','Vargas','OVF901217FX44','F','O+','1990-12-17',1,'2025-06-25 11:22:12',NULL),('eea6a481-51e8-11f0-9f2b-00155d276843','Dr.','Juan','Rodríguez','Martínez','RRMJ550805MC26','M','A+','1955-08-05',1,'2025-06-25 11:22:12',NULL),('eea76932-51e8-11f0-9f2b-00155d276843','Dr.','María','Torres','Ortega','TTOM650929FN74','F','O+','1965-09-29',1,'2025-06-25 11:22:12',NULL),('eea81e94-51e8-11f0-9f2b-00155d276843','Ing.','Miguel','Pérez','Sánchez','PPSM540218MJ79','M','B+','1954-02-18',1,'2025-06-25 11:22:12',NULL),('eea8e0ce-51e8-11f0-9f2b-00155d276843','Ing.','Sofía','Torres','Morales','TTMS740110FR61','F','AB+','1974-01-10',1,'2025-06-25 11:22:12',NULL),('eea99b9b-51e8-11f0-9f2b-00155d276843','Ing.','Isabel','Torres','Ortega','TTOI520425FQ12','F','O+','1952-04-25',1,'2025-06-25 11:22:12',NULL),('eeaa7040-51e8-11f0-9f2b-00155d276843','Ing.','Jordan','Rojas','Vega','RSVJ740424N/BK42','N/B','A+','1974-04-24',1,'2025-06-25 11:22:12',NULL),('eeab9744-51e8-11f0-9f2b-00155d276843','Dr.','Jordan','Medina','Delgado','MDJ800920N/BW36','N/B','A-','1980-09-20',1,'2025-06-25 11:22:12',NULL),('eeac62e6-51e8-11f0-9f2b-00155d276843',NULL,'Robin','Medina','Silva','MSR010523N/BQ47','N/B','O+','2001-05-23',1,'2025-06-25 11:22:12',NULL),('eead2537-51e8-11f0-9f2b-00155d276843','Ing.','Sky','Vega','Flores','VFS860130N/BH16','N/B','A+','1986-01-30',1,'2025-06-25 11:22:12',NULL),('eeae018f-51e8-11f0-9f2b-00155d276843','Dr.','Sofía','Ortega','Gutiérrez','OGS470126FP59','F','O+','1947-01-26',1,'2025-06-25 11:22:12',NULL),('eeaebc83-51e8-11f0-9f2b-00155d276843','Lic.','Fernanda','Navarro','Castillo','NVCF820905FX38','F','O-','1982-09-05',1,'2025-06-25 11:22:12',NULL),('eeaf9396-51e8-11f0-9f2b-00155d276843','Ing.','Lucía','Gutiérrez','Navarro','GGNL711001FX28','F','O+','1971-10-01',1,'2025-06-25 11:22:12',NULL),('eeb0a035-51e8-11f0-9f2b-00155d276843',NULL,'Fernando','García','Ramírez','GRRF011024MD87','M','B-','2001-10-24',1,'2025-06-25 11:22:12',NULL),('eeb1512a-51e8-11f0-9f2b-00155d276843','Lic.','Camila','Gutiérrez','Fernández','GGFC540622FZ83','F','O+','1954-06-22',1,'2025-06-25 11:22:12',NULL),('eeb21369-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Torres','Ortega','TTOC491017FV62','F','A+','1949-10-17',1,'2025-06-25 11:22:12',NULL),('eeb2eebb-51e8-11f0-9f2b-00155d276843','Lic.','Valeria','Castillo','Morales','CSMV910105FF40','F','O+','1991-01-05',1,'2025-06-25 11:22:12',NULL),('eeb3b2c3-51e8-11f0-9f2b-00155d276843','Dr.','Alejandra','Torres','Fernández','TTFA831121FJ75','F','A+','1983-11-21',1,'2025-06-25 11:22:12',NULL),('eeb4978b-51e8-11f0-9f2b-00155d276843','Ing.','Fernanda','Morales','Ortega','MLOF680813FN10','F','A+','1968-08-13',1,'2025-06-25 11:22:12',NULL),('eeb5736d-51e8-11f0-9f2b-00155d276843','Dr.','Alejandra','Ortega','Navarro','ONA551206FQ53','F','A+','1955-12-06',1,'2025-06-25 11:22:12',NULL),('eeb67c4b-51e8-11f0-9f2b-00155d276843','Dr.','Miguel','Martínez','García','MRGM860319MK84','M','A-','1986-03-19',1,'2025-06-25 11:22:12',NULL),('eeb7442e-51e8-11f0-9f2b-00155d276843',NULL,'Alejandro','Sánchez','García','SSGA030916MR52','M','A+','2003-09-16',1,'2025-06-25 11:22:12',NULL),('eeb8168b-51e8-11f0-9f2b-00155d276843','Ing.','Andrea','Navarro','Vargas','NVVA831113FM13','F','A+','1983-11-13',1,'2025-06-25 11:22:12',NULL),('eeb8d665-51e8-11f0-9f2b-00155d276843','Lic.','María','Reyes','Morales','RRMM520928FR10','F','A-','1952-09-28',1,'2025-06-25 11:22:12',NULL),('eeb97c48-51e8-11f0-9f2b-00155d276843','Ing.','Alex','Aguilar','Delgado','AGDA840423N/BB54','N/B','O+','1984-04-23',1,'2025-06-25 11:22:12',NULL),('eeba145c-51e8-11f0-9f2b-00155d276843',NULL,'Andrés','López','López','LLLA040529ML37','M','O+','2004-05-29',1,'2025-06-25 11:22:12',NULL),('eebaab40-51e8-11f0-9f2b-00155d276843','Ing.','Javier','López','González','LLGJ770513ME91','M','AB-','1977-05-13',1,'2025-06-25 11:22:12',NULL),('eebb5108-51e8-11f0-9f2b-00155d276843','Dr.','Luis','Pérez','Ramírez','PPRL791102MX54','M','AB+','1979-11-02',1,'2025-06-25 11:22:12',NULL),('eebc05bf-51e8-11f0-9f2b-00155d276843','Ing.','Lucía','Torres','Fernández','TTFL530622FL26','F','A+','1953-06-22',1,'2025-06-25 11:22:12',NULL),('eebcb99f-51e8-11f0-9f2b-00155d276843','Ing.','Fernando','Sánchez','Hernández','SSHF630709MS98','M','O-','1963-07-09',1,'2025-06-25 11:22:12',NULL),('eebd873a-51e8-11f0-9f2b-00155d276843','Ing.','Andrés','Sánchez','López','SSLA570404MO85','M','A+','1957-04-04',1,'2025-06-25 11:22:12',NULL),('eebe2348-51e8-11f0-9f2b-00155d276843','Dr.','Sofía','Gutiérrez','Reyes','GGRS950302FR79','F','O-','1995-03-02',1,'2025-06-25 11:22:12',NULL),('eebeb478-51e8-11f0-9f2b-00155d276843','Dr.','Sam','Aguilar','Silva','AGSS461215N/BE19','N/B','O+','1946-12-15',1,'2025-06-25 11:22:12',NULL),('eebf5688-51e8-11f0-9f2b-00155d276843','Ing.','Taylor','Mendoza','Rojas','MRT560623N/BV73','N/B','O+','1956-06-23',1,'2025-06-25 11:22:12',NULL),('eec041c9-51e8-11f0-9f2b-00155d276843','Lic.','Luis','González','González','GGGL970310MT33','M','O+','1997-03-10',1,'2025-06-25 11:22:12',NULL),('eec0dbcf-51e8-11f0-9f2b-00155d276843','Dr.','Miguel','López','González','LLGM990722MK98','M','B+','1999-07-22',1,'2025-06-25 11:22:12',NULL),('eec185c0-51e8-11f0-9f2b-00155d276843',NULL,'Sky','Domínguez','Medina','DDMS031208N/BP21','N/B','O-','2003-12-08',1,'2025-06-25 11:22:12',NULL),('eec26215-51e8-11f0-9f2b-00155d276843','Dr.','Fernando','Martínez','Ramírez','MRRF640317MP74','M','B+','1964-03-17',1,'2025-06-25 11:22:12',NULL),('eec302ec-51e8-11f0-9f2b-00155d276843','Lic.','Robin','Flores','Escobar','FFER530128N/BE69','N/B','O-','1953-01-28',1,'2025-06-25 11:22:12',NULL),('eec39853-51e8-11f0-9f2b-00155d276843','Dr.','Javier','Pérez','Cruz','PPCJ600513MX55','M','O-','1960-05-13',1,'2025-06-25 11:22:12',NULL),('eec44ab3-51e8-11f0-9f2b-00155d276843','Ing.','Dani','Medina','Medina','MMD650714N/BM91','N/B','O+','1965-07-14',1,'2025-06-25 11:22:12',NULL),('eec508df-51e8-11f0-9f2b-00155d276843','Lic.','Taylor','Mendoza','Vega','MVT750227N/BQ76','N/B','B+','1975-02-27',1,'2025-06-25 11:22:12',NULL),('eec59ae1-51e8-11f0-9f2b-00155d276843','Ing.','Morgan','Vega','Aguilar','VAM800620N/BP15','N/B','A+','1980-06-20',1,'2025-06-25 11:22:12',NULL),('eec640a1-51e8-11f0-9f2b-00155d276843','Lic.','Eduardo','Ramírez','Martínez','RMME750824MK66','M','B-','1975-08-24',1,'2025-06-25 11:22:12',NULL),('eec6e665-51e8-11f0-9f2b-00155d276843','Ing.','Luis','García','Rodríguez','GRRL520218MJ21','M','A+','1952-02-18',1,'2025-06-25 11:22:12',NULL),('eec787c3-51e8-11f0-9f2b-00155d276843','Dr.','Dani','Flores','Aguilar','FFAD890305N/BM45','N/B','A+','1989-03-05',1,'2025-06-25 11:22:12',NULL),('eec82d5e-51e8-11f0-9f2b-00155d276843','Dr.','Sky','Flores','Vega','FFVS581209N/BW46','N/B','A+','1958-12-09',1,'2025-06-25 11:22:12',NULL),('eec8c8c1-51e8-11f0-9f2b-00155d276843','Ing.','Eduardo','Sánchez','Pérez','SSPE730508MP29','M','O+','1973-05-08',1,'2025-06-25 11:22:12',NULL),('eec97250-51e8-11f0-9f2b-00155d276843','Lic.','Sam','Mendoza','Flores','MFS661101N/BK49','N/B','A-','1966-11-01',1,'2025-06-25 11:22:12',NULL),('eeca1082-51e8-11f0-9f2b-00155d276843','Ing.','Andrea','Reyes','Morales','RRMA460407FB13','F','O+','1946-04-07',1,'2025-06-25 11:22:12',NULL),('eecaaa94-51e8-11f0-9f2b-00155d276843','Lic.','Robin','Domínguez','Delgado','DDDR470213N/BP84','N/B','O+','1947-02-13',1,'2025-06-25 11:22:12',NULL),('eecb25f8-51e8-11f0-9f2b-00155d276843',NULL,'Fernando','Pérez','García','PPGF030418MJ16','M','O+','2003-04-18',1,'2025-06-25 11:22:12',NULL),('eecbac99-51e8-11f0-9f2b-00155d276843','Dr.','Casey','Aguilar','Flores','AGFC580426N/BR58','N/B','B+','1958-04-26',1,'2025-06-25 11:22:12',NULL),('eecc27de-51e8-11f0-9f2b-00155d276843','Ing.','Juan','Martínez','García','MRGJ770612MK80','M','B+','1977-06-12',1,'2025-06-25 11:22:12',NULL),('eecc943a-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Ortega','Gutiérrez','OGC970702FC49','F','A-','1997-07-02',1,'2025-06-25 11:22:12',NULL),('eecd0e68-51e8-11f0-9f2b-00155d276843','Lic.','Valeria','Ortega','Gutiérrez','OGV901119FW91','F','A-','1990-11-19',1,'2025-06-25 11:22:12',NULL),('eecd7a93-51e8-11f0-9f2b-00155d276843','Dr.','Fernando','Martínez','Rodríguez','MRRF831217MT42','M','A+','1983-12-17',1,'2025-06-25 11:22:12',NULL),('eecded6d-51e8-11f0-9f2b-00155d276843','Dr.','Dani','Medina','Medina','MMD740831N/BB94','N/B','A+','1974-08-31',1,'2025-06-25 11:22:12',NULL),('eece6f36-51e8-11f0-9f2b-00155d276843','Dr.','Ricardo','González','Hernández','GGHR600624MH79','M','O+','1960-06-24',1,'2025-06-25 11:22:12',NULL),('eeceff9e-51e8-11f0-9f2b-00155d276843','Dr.','Andrés','Pérez','García','PPGA890608MG52','M','A+','1989-06-08',1,'2025-06-25 11:22:12',NULL),('eecf6da0-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Jiménez','Jiménez','JJJC960516FP87','F','A+','1996-05-16',1,'2025-06-25 11:22:12',NULL),('eecfd760-51e8-11f0-9f2b-00155d276843','Lic.','Valeria','Ortega','Vargas','OVV660518FB88','F','O+','1966-05-18',1,'2025-06-25 11:22:12',NULL),('eed068f2-51e8-11f0-9f2b-00155d276843','Dr.','Lucía','Morales','Vargas','MLVL790526FQ10','F','O+','1979-05-26',1,'2025-06-25 11:22:12',NULL),('eed0e166-51e8-11f0-9f2b-00155d276843','Ing.','Valeria','Morales','Jiménez','MLJV491002FO68','F','A+','1949-10-02',1,'2025-06-25 11:22:12',NULL),('eed15b01-51e8-11f0-9f2b-00155d276843',NULL,'Miguel','Ramírez','Hernández','RMHM050111MX61','M','O+','2005-01-11',1,'2025-06-25 11:22:12',NULL),('eed1cc5c-51e8-11f0-9f2b-00155d276843','Ing.','Javier','Pérez','Martínez','PPMJ700919ML34','M','AB-','1970-09-19',1,'2025-06-25 11:22:12',NULL),('eed23f7f-51e8-11f0-9f2b-00155d276843','Lic.','Javier','Sánchez','López','SSLJ731202MC81','M','B+','1973-12-02',1,'2025-06-25 11:22:12',NULL),('eed2cec6-51e8-11f0-9f2b-00155d276843','Dr.','Eduardo','López','Rodríguez','LLRE850412MR40','M','B+','1985-04-12',1,'2025-06-25 11:22:12',NULL),('eed36481-51e8-11f0-9f2b-00155d276843','Dr.','Jordan','Delgado','Domínguez','DDDJ910401N/BC65','N/B','O-','1991-04-01',1,'2025-06-25 11:22:12',NULL),('eed3e8d0-51e8-11f0-9f2b-00155d276843','Dr.','Fernanda','Gutiérrez','Vargas','GGVF701130FF34','F','A+','1970-11-30',1,'2025-06-25 11:22:12',NULL),('eed45ce2-51e8-11f0-9f2b-00155d276843','Lic.','Alejandra','Jiménez','Torres','JJTA850408FT53','F','O+','1985-04-08',1,'2025-06-25 11:22:12',NULL),('eed4f40a-51e8-11f0-9f2b-00155d276843','Ing.','Sky','Delgado','Mendoza','DDMS650121N/BF80','N/B','O+','1965-01-21',1,'2025-06-25 11:22:12',NULL),('eed578fc-51e8-11f0-9f2b-00155d276843','Ing.','Alejandro','González','Ramírez','GGRA811215MT32','M','O+','1981-12-15',1,'2025-06-25 11:22:12',NULL),('eed63091-51e8-11f0-9f2b-00155d276843','Lic.','Isabel','Jiménez','Ortega','JJOI961119FL85','F','O-','1996-11-19',1,'2025-06-25 11:22:12',NULL),('eed6b63a-51e8-11f0-9f2b-00155d276843','Lic.','Alex','Rojas','Delgado','RSDA740428N/BO50','N/B','A+','1974-04-28',1,'2025-06-25 11:22:12',NULL),('eed74bff-51e8-11f0-9f2b-00155d276843','Lic.','Valeria','Reyes','Castillo','RRCV570815FF75','F','O+','1957-08-15',1,'2025-06-25 11:22:12',NULL),('eed7c738-51e8-11f0-9f2b-00155d276843','Lic.','Eduardo','Cruz','Rodríguez','CCRE680803MN83','M','A+','1968-08-03',1,'2025-06-25 11:22:12',NULL),('eed84bc2-51e8-11f0-9f2b-00155d276843','Lic.','Ricardo','González','González','GGGR990111MB57','M','A+','1999-01-11',1,'2025-06-25 11:22:12',NULL),('eed8d310-51e8-11f0-9f2b-00155d276843','Ing.','Andrea','Ortega','Navarro','ONA470926FC54','F','O+','1947-09-26',1,'2025-06-25 11:22:12',NULL),('eed98ddd-51e8-11f0-9f2b-00155d276843','Dr.','Dani','Mendoza','Escobar','MED671216N/BJ56','N/B','A+','1967-12-16',1,'2025-06-25 11:22:12',NULL),('eeda1714-51e8-11f0-9f2b-00155d276843','Lic.','Carlos','Hernández','López','HHLC850516MI23','M','B+','1985-05-16',1,'2025-06-25 11:22:13',NULL),('eedaa68e-51e8-11f0-9f2b-00155d276843',NULL,'Eduardo','García','García','GRGE060825MX51','M','A+','2006-08-25',1,'2025-06-25 11:22:13',NULL),('eedb2611-51e8-11f0-9f2b-00155d276843','Dr.','Dani','Vega','Medina','VMD640419N/BS20','N/B','A+','1964-04-19',1,'2025-06-25 11:22:13',NULL),('eedbb1c1-51e8-11f0-9f2b-00155d276843','Dr.','Andrés','González','Pérez','GGPA691003MD85','M','O-','1969-10-03',1,'2025-06-25 11:22:13',NULL),('eedc3476-51e8-11f0-9f2b-00155d276843','Dr.','Chris','Mendoza','Silva','MSC721113N/BH19','N/B','A+','1972-11-13',1,'2025-06-25 11:22:13',NULL),('eedcbaf3-51e8-11f0-9f2b-00155d276843','Dr.','Chris','Flores','Flores','FFFC660728N/BC43','N/B','A+','1966-07-28',1,'2025-06-25 11:22:13',NULL),('eedd3369-51e8-11f0-9f2b-00155d276843','Lic.','Alex','Rojas','Domínguez','RSDA490404N/BJ77','N/B','A+','1949-04-04',1,'2025-06-25 11:22:13',NULL),('eeddc783-51e8-11f0-9f2b-00155d276843','Lic.','Casey','Silva','Vega','SVC890513N/BO93','N/B','O+','1989-05-13',1,'2025-06-25 11:22:13',NULL),('eede449a-51e8-11f0-9f2b-00155d276843','Ing.','Isabel','Torres','Fernández','TTFI780324FH79','F','O+','1978-03-24',1,'2025-06-25 11:22:13',NULL),('eedeb756-51e8-11f0-9f2b-00155d276843',NULL,'Taylor','Flores','Escobar','FFET031229N/BW49','N/B','A+','2003-12-29',1,'2025-06-25 11:22:13',NULL),('eedf4740-51e8-11f0-9f2b-00155d276843','Dr.','Chris','Delgado','Silva','DDSC480920N/BS19','N/B','O+','1948-09-20',1,'2025-06-25 11:22:13',NULL),('eedfc0c2-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Gutiérrez','Fernández','GGFC740329FW20','F','O+','1974-03-29',1,'2025-06-25 11:22:13',NULL),('eee041e4-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Medina','Escobar','MEJ810809N/BE88','N/B','A-','1981-08-09',1,'2025-06-25 11:22:13',NULL),('eee0eeb1-51e8-11f0-9f2b-00155d276843','Dr.','Sam','Domínguez','Domínguez','DDDS760429N/BR34','N/B','O+','1976-04-29',1,'2025-06-25 11:22:13',NULL),('eee16c6a-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Silva','Rojas','SRJ590528N/BR73','N/B','A+','1959-05-28',1,'2025-06-25 11:22:13',NULL),('eee1e5e6-51e8-11f0-9f2b-00155d276843','Ing.','Robin','Silva','Aguilar','SAR640528N/BX40','N/B','O+','1964-05-28',1,'2025-06-25 11:22:13',NULL),('eee257d6-51e8-11f0-9f2b-00155d276843','Ing.','Valeria','Vargas','Fernández','VRFV801109FE26','F','A+','1980-11-09',1,'2025-06-25 11:22:13',NULL),('eee2eca0-51e8-11f0-9f2b-00155d276843','Ing.','Alejandra','Ortega','Torres','OTA670906FZ68','F','O+','1967-09-06',1,'2025-06-25 11:22:13',NULL),('eee38373-51e8-11f0-9f2b-00155d276843','Ing.','Casey','Rojas','Rojas','RSRC461027N/BZ22','N/B','A+','1946-10-27',1,'2025-06-25 11:22:13',NULL),('eee40133-51e8-11f0-9f2b-00155d276843','Ing.','Miguel','Hernández','Sánchez','HHSM900626MS53','M','O+','1990-06-26',1,'2025-06-25 11:22:13',NULL),('eee47363-51e8-11f0-9f2b-00155d276843',NULL,'Sky','Rojas','Domínguez','RSDS060522N/BF25','N/B','O+','2006-05-22',1,'2025-06-25 11:22:13',NULL),('eee4f140-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Jiménez','Morales','JJMC940416FQ59','F','A-','1994-04-16',1,'2025-06-25 11:22:13',NULL),('eee58730-51e8-11f0-9f2b-00155d276843','Lic.','Dani','Medina','Domínguez','MDD971222N/BB24','N/B','A+','1997-12-22',1,'2025-06-25 11:22:13',NULL),('eee600f2-51e8-11f0-9f2b-00155d276843',NULL,'Sofía','Navarro','Jiménez','NVJS030523FS80','F','B+','2003-05-23',1,'2025-06-25 11:22:13',NULL),('eee67d2a-51e8-11f0-9f2b-00155d276843','Lic.','Camila','Gutiérrez','Vargas','GGVC670312FN88','F','AB+','1967-03-12',1,'2025-06-25 11:22:13',NULL),('eee6eefa-51e8-11f0-9f2b-00155d276843','Ing.','Lucía','Navarro','Navarro','NVNL820126FH23','F','A-','1982-01-26',1,'2025-06-25 11:22:13',NULL),('eee768d9-51e8-11f0-9f2b-00155d276843',NULL,'Fernando','Pérez','Hernández','PPHF040822MV32','M','B+','2004-08-22',1,'2025-06-25 11:22:13',NULL),('eee7ecca-51e8-11f0-9f2b-00155d276843','Ing.','Eduardo','López','Pérez','LLPE461031MY86','M','A+','1946-10-31',1,'2025-06-25 11:22:13',NULL),('eee880b7-51e8-11f0-9f2b-00155d276843','Lic.','Taylor','Aguilar','Escobar','AGET931015N/BM55','N/B','O+','1993-10-15',1,'2025-06-25 11:22:13',NULL),('eee8f9a1-51e8-11f0-9f2b-00155d276843',NULL,'Dani','Flores','Mendoza','FFMD001107N/BM71','N/B','O+','2000-11-07',1,'2025-06-25 11:22:13',NULL),('eee96bb3-51e8-11f0-9f2b-00155d276843','Ing.','Carlos','Sánchez','Hernández','SSHC760924MM30','M','A+','1976-09-24',1,'2025-06-25 11:22:13',NULL),('eee9f897-51e8-11f0-9f2b-00155d276843','Dr.','Taylor','Aguilar','Escobar','AGET960717N/BE49','N/B','A+','1996-07-17',1,'2025-06-25 11:22:13',NULL),('eeea986e-51e8-11f0-9f2b-00155d276843','Lic.','Andrés','García','Pérez','GRPA750916MP60','M','O+','1975-09-16',1,'2025-06-25 11:22:13',NULL),('eeeb1c24-51e8-11f0-9f2b-00155d276843','Dr.','Sofía','Jiménez','Ortega','JJOS710825FT73','F','O+','1971-08-25',1,'2025-06-25 11:22:13',NULL),('eeeb8ac6-51e8-11f0-9f2b-00155d276843','Ing.','Sofía','Morales','Morales','MLMS470105FP49','F','A+','1947-01-05',1,'2025-06-25 11:22:13',NULL),('eeebf895-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Delgado','Delgado','DDDJ601128N/BB12','N/B','A-','1960-11-28',1,'2025-06-25 11:22:13',NULL),('eeec7734-51e8-11f0-9f2b-00155d276843','Ing.','Sky','Domínguez','Escobar','DDES640105N/BQ61','N/B','O+','1964-01-05',1,'2025-06-25 11:22:13',NULL),('eeecf5f9-51e8-11f0-9f2b-00155d276843','Ing.','Sofía','Jiménez','Ortega','JJOS930223FD30','F','B+','1993-02-23',1,'2025-06-25 11:22:13',NULL),('eeedc04f-51e8-11f0-9f2b-00155d276843','Dr.','Robin','Vega','Medina','VMR960528N/BO80','N/B','O+','1996-05-28',1,'2025-06-25 11:22:13',NULL),('eeee33d8-51e8-11f0-9f2b-00155d276843','Lic.','Luis','López','Martínez','LLML741225MI41','M','AB+','1974-12-25',1,'2025-06-25 11:22:13',NULL),('eeeec51e-51e8-11f0-9f2b-00155d276843','Ing.','Ricardo','Martínez','Martínez','MRMR861020MJ39','M','A+','1986-10-20',1,'2025-06-25 11:22:13',NULL),('eeef522a-51e8-11f0-9f2b-00155d276843','Dr.','Fernando','Cruz','Rodríguez','CCRF590121MI98','M','O+','1959-01-21',1,'2025-06-25 11:22:13',NULL),('eeefce21-51e8-11f0-9f2b-00155d276843','Lic.','Ricardo','Sánchez','Ramírez','SSRR980104MK69','M','O+','1998-01-04',1,'2025-06-25 11:22:13',NULL),('eef042c2-51e8-11f0-9f2b-00155d276843','Lic.','Isabel','Gutiérrez','Torres','GGTI841023FH94','F','O-','1984-10-23',1,'2025-06-25 11:22:13',NULL),('eef0e93e-51e8-11f0-9f2b-00155d276843','Lic.','Alejandra','Castillo','Ortega','CSOA710818FQ90','F','A+','1971-08-18',1,'2025-06-25 11:22:13',NULL),('eef16b40-51e8-11f0-9f2b-00155d276843','Ing.','Ricardo','García','López','GRLR970704MT87','M','O+','1997-07-04',1,'2025-06-25 11:22:13',NULL),('eef1eaca-51e8-11f0-9f2b-00155d276843','Lic.','Alejandra','Vargas','Gutiérrez','VRGA650119FP84','F','A+','1965-01-19',1,'2025-06-25 11:22:13',NULL),('eef26ff9-51e8-11f0-9f2b-00155d276843','Dr.','Fernanda','Reyes','Ortega','RROF531022FF18','F','AB+','1953-10-22',1,'2025-06-25 11:22:13',NULL),('eef30cee-51e8-11f0-9f2b-00155d276843','Lic.','Dani','Medina','Domínguez','MDD510204N/BW85','N/B','A+','1951-02-04',1,'2025-06-25 11:22:13',NULL),('eef38d7d-51e8-11f0-9f2b-00155d276843',NULL,'Fernanda','Jiménez','Reyes','JJRF010430FO10','F','A+','2001-04-30',1,'2025-06-25 11:22:13',NULL),('eef40188-51e8-11f0-9f2b-00155d276843',NULL,'Dani','Flores','Mendoza','FFMD010804N/BO13','N/B','A+','2001-08-04',1,'2025-06-25 11:22:13',NULL),('eef48956-51e8-11f0-9f2b-00155d276843','Lic.','Andrea','Castillo','Fernández','CSFA590810FQ55','F','A+','1959-08-10',1,'2025-06-25 11:22:13',NULL),('eef4fe54-51e8-11f0-9f2b-00155d276843','Dr.','Taylor','Medina','Mendoza','MMT590902N/BN83','N/B','A+','1959-09-02',1,'2025-06-25 11:22:13',NULL),('eef57648-51e8-11f0-9f2b-00155d276843','Ing.','Camila','Castillo','Gutiérrez','CSGC490620FO78','F','O+','1949-06-20',1,'2025-06-25 11:22:13',NULL),('eef5ff75-51e8-11f0-9f2b-00155d276843','Dr.','Andrea','Castillo','Jiménez','CSJA610418FS73','F','A+','1961-04-18',1,'2025-06-25 11:22:13',NULL),('eef66cab-51e8-11f0-9f2b-00155d276843','Dr.','Sam','Flores','Silva','FFSS700110N/BM15','N/B','AB+','1970-01-10',1,'2025-06-25 11:22:13',NULL),('eef6efac-51e8-11f0-9f2b-00155d276843','Dr.','Taylor','Delgado','Silva','DDST961104N/BZ64','N/B','O+','1996-11-04',1,'2025-06-25 11:22:13',NULL),('eef78b59-51e8-11f0-9f2b-00155d276843','Lic.','Taylor','Escobar','Rojas','ERRT590523N/BS90','N/B','A+','1959-05-23',1,'2025-06-25 11:22:13',NULL),('eef8244c-51e8-11f0-9f2b-00155d276843','Lic.','Andrés','Cruz','Ramírez','CCRA751010MB56','M','A+','1975-10-10',1,'2025-06-25 11:22:13',NULL),('eef8a2eb-51e8-11f0-9f2b-00155d276843','Dr.','Dani','Escobar','Domínguez','ERDD550321N/BE90','N/B','B-','1955-03-21',1,'2025-06-25 11:22:13',NULL),('eef9144a-51e8-11f0-9f2b-00155d276843','Ing.','Andrés','Martínez','González','MRGA660421MB97','M','B+','1966-04-21',1,'2025-06-25 11:22:13',NULL),('eef991f7-51e8-11f0-9f2b-00155d276843','Ing.','Taylor','Rojas','Aguilar','RSAT920120N/BU25','N/B','A+','1992-01-20',1,'2025-06-25 11:22:13',NULL),('eefa0e69-51e8-11f0-9f2b-00155d276843','Dr.','Casey','Aguilar','Flores','AGFC550221N/BY55','N/B','A+','1955-02-21',1,'2025-06-25 11:22:13',NULL),('eefa88b5-51e8-11f0-9f2b-00155d276843','Ing.','Jordan','Domínguez','Vega','DDVJ581201N/BB34','N/B','O+','1958-12-01',1,'2025-06-25 11:22:13',NULL),('eefafbb7-51e8-11f0-9f2b-00155d276843',NULL,'Juan','Rodríguez','González','RRGJ041112MP14','M','A+','2004-11-12',1,'2025-06-25 11:22:13',NULL),('eefb6d9d-51e8-11f0-9f2b-00155d276843','Ing.','Valeria','Reyes','Morales','RRMV960219FV81','F','A+','1996-02-19',1,'2025-06-25 11:22:13',NULL),('eefbe2a4-51e8-11f0-9f2b-00155d276843','Dr.','Eduardo','Rodríguez','López','RRLE750710MC24','M','A+','1975-07-10',1,'2025-06-25 11:22:13',NULL),('eefc91f0-51e8-11f0-9f2b-00155d276843',NULL,'Carlos','González','Ramírez','GGRC050604ME92','M','O+','2005-06-04',1,'2025-06-25 11:22:13',NULL),('eefd13b0-51e8-11f0-9f2b-00155d276843','Ing.','Alex','Rojas','Aguilar','RSAA530831N/BR26','N/B','O-','1953-08-31',1,'2025-06-25 11:22:13',NULL),('eefd8224-51e8-11f0-9f2b-00155d276843','Dr.','Sam','Medina','Escobar','MES950807N/BX40','N/B','B-','1995-08-07',1,'2025-06-25 11:22:13',NULL),('eefdf675-51e8-11f0-9f2b-00155d276843','Dr.','Jordan','Domínguez','Mendoza','DDMJ610101N/BH81','N/B','O+','1961-01-01',1,'2025-06-25 11:22:13',NULL),('eefe740a-51e8-11f0-9f2b-00155d276843','Dr.','Lucía','Gutiérrez','Reyes','GGRL810828FA64','F','O+','1981-08-28',1,'2025-06-25 11:22:13',NULL),('eeff03ee-51e8-11f0-9f2b-00155d276843','Lic.','Fernando','Martínez','García','MRGF831210MG75','M','A-','1983-12-10',1,'2025-06-25 11:22:13',NULL),('eeff7aa4-51e8-11f0-9f2b-00155d276843','Ing.','Fernanda','Castillo','Vargas','CSVF490228FL69','F','O+','1949-02-28',1,'2025-06-25 11:22:13',NULL),('eefff1f8-51e8-11f0-9f2b-00155d276843','Dr.','Juan','López','Rodríguez','LLRJ970402MM82','M','A+','1997-04-02',1,'2025-06-25 11:22:13',NULL),('ef006266-51e8-11f0-9f2b-00155d276843','Dr.','Fernanda','Vargas','Morales','VRMF570207FJ31','F','O+','1957-02-07',1,'2025-06-25 11:22:13',NULL),('ef00de83-51e8-11f0-9f2b-00155d276843','Lic.','Ricardo','Cruz','García','CCGR700521MW92','M','AB-','1970-05-21',1,'2025-06-25 11:22:13',NULL),('ef0170bb-51e8-11f0-9f2b-00155d276843','Dr.','Juan','González','López','GGLJ781009MG81','M','O+','1978-10-09',1,'2025-06-25 11:22:13',NULL),('ef01f264-51e8-11f0-9f2b-00155d276843','Lic.','Alejandra','Gutiérrez','Ortega','GGOA940617FD60','F','A+','1994-06-17',1,'2025-06-25 11:22:13',NULL),('ef026833-51e8-11f0-9f2b-00155d276843','Lic.','Andrea','Jiménez','Torres','JJTA710406FJ73','F','A+','1971-04-06',1,'2025-06-25 11:22:13',NULL),('ef02fb84-51e8-11f0-9f2b-00155d276843','Dr.','Carlos','Rodríguez','Rodríguez','RRRC570513MW16','M','B+','1957-05-13',1,'2025-06-25 11:22:13',NULL),('ef038493-51e8-11f0-9f2b-00155d276843','Dr.','Alex','Aguilar','Aguilar','AGAA640215N/BO92','N/B','A-','1964-02-15',1,'2025-06-25 11:22:13',NULL),('ef04166d-51e8-11f0-9f2b-00155d276843','Ing.','Sky','Vega','Flores','VFS701019N/BP91','N/B','B+','1970-10-19',1,'2025-06-25 11:22:13',NULL),('ef04886a-51e8-11f0-9f2b-00155d276843','Lic.','Carlos','Pérez','García','PPGC960725MC71','M','O+','1996-07-25',1,'2025-06-25 11:22:13',NULL),('ef04f9ff-51e8-11f0-9f2b-00155d276843','Dr.','Robin','Escobar','Domínguez','ERDR510428N/BX47','N/B','A+','1951-04-28',1,'2025-06-25 11:22:13',NULL),('ef0567d2-51e8-11f0-9f2b-00155d276843','Dr.','Andrea','Fernández','Castillo','FFCA510626FA93','F','A+','1951-06-26',1,'2025-06-25 11:22:13',NULL),('ef05da6b-51e8-11f0-9f2b-00155d276843',NULL,'Eduardo','Ramírez','Cruz','RMCE070515MH44','M','O+','2007-05-15',1,'2025-06-25 11:22:13',NULL),('ef068905-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Castillo','Fernández','CSFC960530FN71','F','AB+','1996-05-30',1,'2025-06-25 11:22:13',NULL),('ef073294-51e8-11f0-9f2b-00155d276843','Ing.','Andrés','Hernández','Cruz','HHCA990813ML14','M','O-','1999-08-13',1,'2025-06-25 11:22:13',NULL),('ef07d1a1-51e8-11f0-9f2b-00155d276843','Ing.','Javier','Martínez','Rodríguez','MRRJ880518MB11','M','O-','1988-05-18',1,'2025-06-25 11:22:13',NULL),('ef084420-51e8-11f0-9f2b-00155d276843','Ing.','Camila','Fernández','Vargas','FFVC491101FQ57','F','B+','1949-11-01',1,'2025-06-25 11:22:13',NULL),('ef08d803-51e8-11f0-9f2b-00155d276843','Dr.','Juan','Cruz','Rodríguez','CCRJ710529MN23','M','O+','1971-05-29',1,'2025-06-25 11:22:13',NULL),('ef095028-51e8-11f0-9f2b-00155d276843','Lic.','Camila','Vargas','Fernández','VRFC810524FU89','F','O+','1981-05-24',1,'2025-06-25 11:22:13',NULL),('ef09c1e6-51e8-11f0-9f2b-00155d276843','Ing.','Sofía','Jiménez','Ortega','JJOS950624FX51','F','A+','1995-06-24',1,'2025-06-25 11:22:13',NULL),('ef0a321e-51e8-11f0-9f2b-00155d276843',NULL,'Sam','Flores','Medina','FFMS040331N/BO10','N/B','O+','2004-03-31',1,'2025-06-25 11:22:13',NULL),('ef0aaaf8-51e8-11f0-9f2b-00155d276843','Ing.','Lucía','Morales','Castillo','MLCL660721FB17','F','O+','1966-07-21',1,'2025-06-25 11:22:13',NULL),('ef0b3d84-51e8-11f0-9f2b-00155d276843','Lic.','Chris','Vega','Silva','VSC670305N/BQ40','N/B','B+','1967-03-05',1,'2025-06-25 11:22:13',NULL),('ef0bce6c-51e8-11f0-9f2b-00155d276843','Dr.','Morgan','Medina','Mendoza','MMM600413N/BJ21','N/B','A+','1960-04-13',1,'2025-06-25 11:22:13',NULL),('ef0c4554-51e8-11f0-9f2b-00155d276843','Ing.','Andrea','Torres','Reyes','TTRA600430FB32','F','O+','1960-04-30',1,'2025-06-25 11:22:13',NULL),('ef0cb9b8-51e8-11f0-9f2b-00155d276843','Dr.','María','Fernández','Jiménez','FFJM840626FG23','F','AB-','1984-06-26',1,'2025-06-25 11:22:13',NULL),('ef0d38de-51e8-11f0-9f2b-00155d276843','Dr.','Camila','Fernández','Reyes','FFRC840302FP23','F','A-','1984-03-02',1,'2025-06-25 11:22:13',NULL),('ef0dbb33-51e8-11f0-9f2b-00155d276843','Ing.','Juan','Sánchez','Pérez','SSPJ870718MF12','M','A+','1987-07-18',1,'2025-06-25 11:22:13',NULL),('ef0e58e3-51e8-11f0-9f2b-00155d276843','Lic.','Robin','Domínguez','Delgado','DDDR960524N/BN32','N/B','A+','1996-05-24',1,'2025-06-25 11:22:13',NULL),('ef0ed0e0-51e8-11f0-9f2b-00155d276843','Dr.','Gabriela','Ortega','Vargas','OVG581216FO98','F','O+','1958-12-16',1,'2025-06-25 11:22:13',NULL),('ef0f4853-51e8-11f0-9f2b-00155d276843',NULL,'Morgan','Vega','Mendoza','VMM050401N/BT92','N/B','O+','2005-04-01',1,'2025-06-25 11:22:13',NULL),('ef0fce9c-51e8-11f0-9f2b-00155d276843',NULL,'Robin','Domínguez','Domínguez','DDDR020514N/BZ17','N/B','A+','2002-05-14',1,'2025-06-25 11:22:13',NULL),('ef108a26-51e8-11f0-9f2b-00155d276843','Ing.','Eduardo','Ramírez','Cruz','RMCE740713MN44','M','A+','1974-07-13',1,'2025-06-25 11:22:13',NULL),('ef1141da-51e8-11f0-9f2b-00155d276843','Dr.','Casey','Delgado','Delgado','DDDC531129N/BX76','N/B','O+','1953-11-29',1,'2025-06-25 11:22:13',NULL),('ef11b901-51e8-11f0-9f2b-00155d276843','Dr.','Chris','Escobar','Escobar','EREC950213N/BI32','N/B','O+','1995-02-13',1,'2025-06-25 11:22:13',NULL),('ef125a98-51e8-11f0-9f2b-00155d276843','Dr.','María','Castillo','Jiménez','CSJM580312FM39','F','O+','1958-03-12',1,'2025-06-25 11:22:13',NULL),('ef12feb8-51e8-11f0-9f2b-00155d276843','Dr.','Andrés','González','López','GGLA770528ME44','M','A+','1977-05-28',1,'2025-06-25 11:22:13',NULL),('ef13be7a-51e8-11f0-9f2b-00155d276843','Lic.','Carlos','Rodríguez','Pérez','RRPC990426MW34','M','B+','1999-04-26',1,'2025-06-25 11:22:13',NULL),('ef14680c-51e8-11f0-9f2b-00155d276843',NULL,'Eduardo','Sánchez','Rodríguez','SSRE050805MV33','M','AB+','2005-08-05',1,'2025-06-25 11:22:13',NULL),('ef14fe31-51e8-11f0-9f2b-00155d276843','Lic.','Juan','González','García','GGGJ951105MJ96','M','B+','1995-11-05',1,'2025-06-25 11:22:13',NULL),('ef15aa40-51e8-11f0-9f2b-00155d276843','Dr.','Casey','Aguilar','Medina','AGMC600716N/BU64','N/B','B+','1960-07-16',1,'2025-06-25 11:22:13',NULL),('ef164345-51e8-11f0-9f2b-00155d276843','Lic.','Sky','Domínguez','Medina','DDMS610711N/BB49','N/B','B-','1961-07-11',1,'2025-06-25 11:22:13',NULL),('ef16e091-51e8-11f0-9f2b-00155d276843','Lic.','María','Morales','Castillo','MLCM860923FW42','F','O+','1986-09-23',1,'2025-06-25 11:22:13',NULL),('ef17941c-51e8-11f0-9f2b-00155d276843','Ing.','Carlos','Hernández','López','HHLC961222MR53','M','A+','1996-12-22',1,'2025-06-25 11:22:13',NULL),('ef18656b-51e8-11f0-9f2b-00155d276843','Ing.','María','Torres','Ortega','TTOM680112FI27','F','B-','1968-01-12',1,'2025-06-25 11:22:13',NULL),('ef191157-51e8-11f0-9f2b-00155d276843','Lic.','Alejandro','Ramírez','González','RMGA830913MM87','M','O-','1983-09-13',1,'2025-06-25 11:22:13',NULL),('ef19d52e-51e8-11f0-9f2b-00155d276843','Ing.','Camila','Navarro','Navarro','NVNC831004FI80','F','A-','1983-10-04',1,'2025-06-25 11:22:13',NULL),('ef1aae5b-51e8-11f0-9f2b-00155d276843','Lic.','Miguel','López','Pérez','LLPM650415MZ90','M','A+','1965-04-15',1,'2025-06-25 11:22:13',NULL),('ef1b3fc3-51e8-11f0-9f2b-00155d276843','Dr.','Andrea','Navarro','Jiménez','NVJA601016FV84','F','A+','1960-10-16',1,'2025-06-25 11:22:13',NULL),('ef1c05f5-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Silva','Medina','SMJ820823N/BC22','N/B','A+','1982-08-23',1,'2025-06-25 11:22:13',NULL),('ef1c9115-51e8-11f0-9f2b-00155d276843','Lic.','Andrea','Gutiérrez','Morales','GGMA880916FK39','F','A+','1988-09-16',1,'2025-06-25 11:22:13',NULL),('ef1d41c2-51e8-11f0-9f2b-00155d276843','Dr.','Ricardo','Pérez','Sánchez','PPSR501201MB52','M','O+','1950-12-01',1,'2025-06-25 11:22:13',NULL),('ef1db9d6-51e8-11f0-9f2b-00155d276843','Lic.','Valeria','Jiménez','Morales','JJMV731124FK79','F','A+','1973-11-24',1,'2025-06-25 11:22:13',NULL),('ef1e60d7-51e8-11f0-9f2b-00155d276843','Dr.','Juan','Hernández','Rodríguez','HHRJ591209MX26','M','O+','1959-12-09',1,'2025-06-25 11:22:13',NULL),('ef1ee00a-51e8-11f0-9f2b-00155d276843','Lic.','Valeria','Reyes','Gutiérrez','RRGV560424FK20','F','O+','1956-04-24',1,'2025-06-25 11:22:13',NULL),('ef1f78b2-51e8-11f0-9f2b-00155d276843','Dr.','Alejandro','Cruz','Cruz','CCCA950930MB41','M','A+','1995-09-30',1,'2025-06-25 11:22:13',NULL),('ef20029d-51e8-11f0-9f2b-00155d276843','Ing.','Luis','Martínez','González','MRGL681021MZ14','M','O+','1968-10-21',1,'2025-06-25 11:22:13',NULL),('ef20d16c-51e8-11f0-9f2b-00155d276843','Ing.','Eduardo','Rodríguez','López','RRLE930617MS36','M','A+','1993-06-17',1,'2025-06-25 11:22:13',NULL),('ef215512-51e8-11f0-9f2b-00155d276843','Dr.','Miguel','Martínez','Pérez','MRPM891119MX59','M','O+','1989-11-19',1,'2025-06-25 11:22:13',NULL),('ef21fb8b-51e8-11f0-9f2b-00155d276843','Lic.','Fernanda','Fernández','Jiménez','FFJF791208FE53','F','A-','1979-12-08',1,'2025-06-25 11:22:13',NULL),('ef22d066-51e8-11f0-9f2b-00155d276843',NULL,'Eduardo','Ramírez','López','RMLE020607MG50','M','A+','2002-06-07',1,'2025-06-25 11:22:13',NULL),('ef235faa-51e8-11f0-9f2b-00155d276843','Lic.','Sofía','Ortega','Morales','OMS770813FC73','F','O+','1977-08-13',1,'2025-06-25 11:22:13',NULL),('ef23f327-51e8-11f0-9f2b-00155d276843','Dr.','Juan','Rodríguez','Cruz','RRCJ471101MH63','M','O+','1947-11-01',1,'2025-06-25 11:22:13',NULL),('ef247468-51e8-11f0-9f2b-00155d276843','Dr.','Taylor','Rojas','Silva','RSST460318N/BL97','N/B','A+','1946-03-18',1,'2025-06-25 11:22:13',NULL),('ef250312-51e8-11f0-9f2b-00155d276843','Ing.','Dani','Vega','Escobar','VED970811N/BY29','N/B','O+','1997-08-11',1,'2025-06-25 11:22:13',NULL),('ef25a91c-51e8-11f0-9f2b-00155d276843','Ing.','Sam','Mendoza','Mendoza','MMS730516N/BJ79','N/B','B+','1973-05-16',1,'2025-06-25 11:22:13',NULL),('ef26211c-51e8-11f0-9f2b-00155d276843','Lic.','Alex','Escobar','Domínguez','ERDA750501N/BI41','N/B','AB+','1975-05-01',1,'2025-06-25 11:22:13',NULL),('ef26cc10-51e8-11f0-9f2b-00155d276843','Lic.','Ricardo','Hernández','Sánchez','HHSR961211MK69','M','O+','1996-12-11',1,'2025-06-25 11:22:13',NULL),('ef2785b1-51e8-11f0-9f2b-00155d276843','Dr.','Casey','Escobar','Silva','ERSC860627N/BD11','N/B','A+','1986-06-27',1,'2025-06-25 11:22:13',NULL),('ef281aba-51e8-11f0-9f2b-00155d276843','Lic.','Alejandro','Rodríguez','Rodríguez','RRRA650912MM38','M','O+','1965-09-12',1,'2025-06-25 11:22:13',NULL),('ef28b382-51e8-11f0-9f2b-00155d276843','Dr.','Sky','Vega','Delgado','VDS650908N/BK81','N/B','B+','1965-09-08',1,'2025-06-25 11:22:13',NULL),('ef294b3d-51e8-11f0-9f2b-00155d276843','Dr.','Alejandra','Reyes','Reyes','RRRA580124FO77','F','O+','1958-01-24',1,'2025-06-25 11:22:13',NULL),('ef29fc6a-51e8-11f0-9f2b-00155d276843',NULL,'Andrés','Pérez','López','PPLA001014MB72','M','O+','2000-10-14',1,'2025-06-25 11:22:13',NULL),('ef2a8a57-51e8-11f0-9f2b-00155d276843','Ing.','Lucía','Torres','Jiménez','TTJL660909FW66','F','A+','1966-09-09',1,'2025-06-25 11:22:13',NULL),('ef2b1b77-51e8-11f0-9f2b-00155d276843','Ing.','Robin','Aguilar','Delgado','AGDR680920N/BM88','N/B','A-','1968-09-20',1,'2025-06-25 11:22:13',NULL),('ef2ba795-51e8-11f0-9f2b-00155d276843','Lic.','Sam','Silva','Medina','SMS471020N/BD14','N/B','O-','1947-10-20',1,'2025-06-25 11:22:13',NULL),('ef2c604b-51e8-11f0-9f2b-00155d276843','Ing.','Alejandro','Martínez','Martínez','MRMA840821MF73','M','AB-','1984-08-21',1,'2025-06-25 11:22:13',NULL),('ef2d1265-51e8-11f0-9f2b-00155d276843','Ing.','Jordan','Vega','Aguilar','VAJ900830N/BZ58','N/B','B+','1990-08-30',1,'2025-06-25 11:22:13',NULL),('ef2dcf6e-51e8-11f0-9f2b-00155d276843','Ing.','Isabel','Navarro','Castillo','NVCI930226FV85','F','B+','1993-02-26',1,'2025-06-25 11:22:13',NULL),('ef2e5b43-51e8-11f0-9f2b-00155d276843','Ing.','Juan','Pérez','Pérez','PPPJ490215MD71','M','O+','1949-02-15',1,'2025-06-25 11:22:13',NULL),('ef2f10b2-51e8-11f0-9f2b-00155d276843','Ing.','Andrés','García','Hernández','GRHA920604MA18','M','A+','1992-06-04',1,'2025-06-25 11:22:13',NULL),('ef2f8d1c-51e8-11f0-9f2b-00155d276843','Ing.','Robin','Rojas','Domínguez','RSDR480727N/BA30','N/B','O+','1948-07-27',1,'2025-06-25 11:22:13',NULL),('ef30349b-51e8-11f0-9f2b-00155d276843','Ing.','Taylor','Delgado','Delgado','DDDT670429N/BS51','N/B','O+','1967-04-29',1,'2025-06-25 11:22:13',NULL),('ef30c12a-51e8-11f0-9f2b-00155d276843','Ing.','Sofía','Reyes','Navarro','RRNS560216FN47','F','A+','1956-02-16',1,'2025-06-25 11:22:13',NULL),('ef31911d-51e8-11f0-9f2b-00155d276843','Ing.','Javier','Pérez','García','PPGJ900319MW17','M','AB+','1990-03-19',1,'2025-06-25 11:22:13',NULL),('ef3357f1-51e8-11f0-9f2b-00155d276843','Lic.','Alex','Mendoza','Silva','MSA701014N/BR49','N/B','O+','1970-10-14',1,'2025-06-25 11:22:13',NULL),('ef342f41-51e8-11f0-9f2b-00155d276843','Ing.','Robin','Medina','Vega','MVR730426N/BR53','N/B','A+','1973-04-26',1,'2025-06-25 11:22:13',NULL),('ef34d458-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Rojas','Vega','RSVJ761106N/BJ50','N/B','O+','1976-11-06',1,'2025-06-25 11:22:13',NULL),('ef3560c5-51e8-11f0-9f2b-00155d276843','Ing.','Camila','Morales','Gutiérrez','MLGC870813FW22','F','O+','1987-08-13',1,'2025-06-25 11:22:13',NULL),('ef36035b-51e8-11f0-9f2b-00155d276843','Lic.','Juan','González','López','GGLJ770721ML30','M','AB+','1977-07-21',1,'2025-06-25 11:22:13',NULL),('ef36b6eb-51e8-11f0-9f2b-00155d276843','Lic.','Alejandra','Gutiérrez','Castillo','GGCA561018FW33','F','B+','1956-10-18',1,'2025-06-25 11:22:13',NULL),('ef3746b6-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Silva','Silva','SSJ570315N/BH62','N/B','O+','1957-03-15',1,'2025-06-25 11:22:13',NULL),('ef37ed4e-51e8-11f0-9f2b-00155d276843','Ing.','Isabel','Vargas','Torres','VRTI570605FQ87','F','A+','1957-06-05',1,'2025-06-25 11:22:13',NULL),('ef386cd2-51e8-11f0-9f2b-00155d276843','Ing.','Camila','Navarro','Fernández','NVFC910618FJ36','F','A+','1991-06-18',1,'2025-06-25 11:22:13',NULL),('ef390f44-51e8-11f0-9f2b-00155d276843','Dr.','Andrés','Ramírez','González','RMGA760720MO29','M','A+','1976-07-20',1,'2025-06-25 11:22:13',NULL),('ef3990b7-51e8-11f0-9f2b-00155d276843','Lic.','Luis','Pérez','García','PPGL820514MZ65','M','O+','1982-05-14',1,'2025-06-25 11:22:13',NULL),('ef3a2690-51e8-11f0-9f2b-00155d276843','Ing.','Javier','Sánchez','Pérez','SSPJ560828MK82','M','O-','1956-08-28',1,'2025-06-25 11:22:13',NULL),('ef3ad2ef-51e8-11f0-9f2b-00155d276843',NULL,'Alejandro','González','Rodríguez','GGRA051019MX57','M','B-','2005-10-19',1,'2025-06-25 11:22:13',NULL),('ef3b5b48-51e8-11f0-9f2b-00155d276843','Ing.','Alejandro','Cruz','Cruz','CCCA510304MI12','M','O+','1951-03-04',1,'2025-06-25 11:22:13',NULL),('ef3bda30-51e8-11f0-9f2b-00155d276843','Ing.','Morgan','Rojas','Flores','RSFM611028N/BJ61','N/B','B+','1961-10-28',1,'2025-06-25 11:22:13',NULL),('ef3c5d92-51e8-11f0-9f2b-00155d276843',NULL,'Juan','Ramírez','Martínez','RMMJ010215MP35','M','A+','2001-02-15',1,'2025-06-25 11:22:13',NULL),('ef3d5f33-51e8-11f0-9f2b-00155d276843','Ing.','Lucía','Vargas','Morales','VRML490206FC50','F','O+','1949-02-06',1,'2025-06-25 11:22:13',NULL),('ef3de08d-51e8-11f0-9f2b-00155d276843','Ing.','Alex','Silva','Flores','SFA580911N/BA26','N/B','B+','1958-09-11',1,'2025-06-25 11:22:13',NULL),('ef3e6e20-51e8-11f0-9f2b-00155d276843','Dr.','Lucía','Navarro','Ortega','NVOL660301FP97','F','O+','1966-03-01',1,'2025-06-25 11:22:13',NULL),('ef3ef5ad-51e8-11f0-9f2b-00155d276843','Ing.','Sky','Domínguez','Vega','DDVS470904N/BD67','N/B','O-','1947-09-04',1,'2025-06-25 11:22:13',NULL),('ef3faa54-51e8-11f0-9f2b-00155d276843','Lic.','Isabel','Ortega','Ortega','OOI811224FT59','F','A+','1981-12-24',1,'2025-06-25 11:22:13',NULL),('ef402e1c-51e8-11f0-9f2b-00155d276843','Lic.','María','Reyes','Gutiérrez','RRGM800717FH98','F','O+','1980-07-17',1,'2025-06-25 11:22:13',NULL),('ef40bbcc-51e8-11f0-9f2b-00155d276843','Lic.','Taylor','Medina','Rojas','MRT451007N/BM33','N/B','A-','1945-10-07',1,'2025-06-25 11:22:13',NULL),('ef415602-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Escobar','Medina','ERMJ460408N/BB85','N/B','O+','1946-04-08',1,'2025-06-25 11:22:13',NULL),('ef41da14-51e8-11f0-9f2b-00155d276843','Ing.','Morgan','Rojas','Silva','RSSM000202N/BR11','N/B','O+','2000-02-02',1,'2025-06-25 11:22:13',NULL),('ef425d5f-51e8-11f0-9f2b-00155d276843','Dr.','Eduardo','Hernández','Martínez','HHME531119MV13','M','A+','1953-11-19',1,'2025-06-25 11:22:13',NULL),('ef42eae1-51e8-11f0-9f2b-00155d276843','Lic.','Juan','Pérez','Ramírez','PPRJ620421MX66','M','A+','1962-04-21',1,'2025-06-25 11:22:13',NULL),('ef438ae0-51e8-11f0-9f2b-00155d276843','Ing.','Gabriela','Torres','Vargas','TTVG000607FQ29','F','O+','2000-06-07',1,'2025-06-25 11:22:13',NULL),('ef441ece-51e8-11f0-9f2b-00155d276843','Dr.','Ricardo','Pérez','Cruz','PPCR941124MY95','M','A-','1994-11-24',1,'2025-06-25 11:22:13',NULL),('ef44a2e0-51e8-11f0-9f2b-00155d276843','Dr.','Robin','Escobar','Mendoza','ERMR470425N/BI47','N/B','O+','1947-04-25',1,'2025-06-25 11:22:13',NULL),('ef4546af-51e8-11f0-9f2b-00155d276843','Ing.','Ricardo','Pérez','Sánchez','PPSR701105MB36','M','O+','1970-11-05',1,'2025-06-25 11:22:13',NULL),('ef45f992-51e8-11f0-9f2b-00155d276843','Dr.','Robin','Vega','Rojas','VRR890725N/BO43','N/B','O+','1989-07-25',1,'2025-06-25 11:22:13',NULL),('ef4688bc-51e8-11f0-9f2b-00155d276843','Lic.','Jordan','Delgado','Delgado','DDDJ590213N/BT71','N/B','O+','1959-02-13',1,'2025-06-25 11:22:13',NULL),('ef4717e1-51e8-11f0-9f2b-00155d276843','Lic.','Eduardo','Hernández','Sánchez','HHSE851004MV32','M','B+','1985-10-04',1,'2025-06-25 11:22:13',NULL),('ef47a397-51e8-11f0-9f2b-00155d276843',NULL,'Miguel','González','García','GGGM020807MM65','M','A+','2002-08-07',1,'2025-06-25 11:22:13',NULL),('ef484f3b-51e8-11f0-9f2b-00155d276843',NULL,'Andrea','Reyes','Ortega','RROA000714FG67','F','A+','2000-07-14',1,'2025-06-25 11:22:13',NULL),('ef48f9de-51e8-11f0-9f2b-00155d276843',NULL,'Luis','Hernández','García','HHGL040108MS70','M','O+','2004-01-08',1,'2025-06-25 11:22:13',NULL),('ef498728-51e8-11f0-9f2b-00155d276843','Lic.','Fernanda','Fernández','Castillo','FFCF601222FF71','F','AB+','1960-12-22',1,'2025-06-25 11:22:13',NULL),('ef4a14d9-51e8-11f0-9f2b-00155d276843','Lic.','Andrés','González','González','GGGA960906MP58','M','A-','1996-09-06',1,'2025-06-25 11:22:13',NULL),('ef4ab2fa-51e8-11f0-9f2b-00155d276843','Lic.','Sam','Medina','Mendoza','MMS661003N/BU75','N/B','O+','1966-10-03',1,'2025-06-25 11:22:13',NULL),('ef4b4650-51e8-11f0-9f2b-00155d276843','Lic.','Ricardo','Sánchez','López','SSLR760125ME22','M','O+','1976-01-25',1,'2025-06-25 11:22:13',NULL),('ef4bcac0-51e8-11f0-9f2b-00155d276843','Ing.','Juan','González','López','GGLJ720905MZ96','M','O-','1972-09-05',1,'2025-06-25 11:22:13',NULL),('ef4c508a-51e8-11f0-9f2b-00155d276843','Ing.','Gabriela','Fernández','Reyes','FFRG720901FP78','F','O+','1972-09-01',1,'2025-06-25 11:22:13',NULL),('ef4cebd1-51e8-11f0-9f2b-00155d276843','Lic.','Javier','González','Ramírez','GGRJ981210MD52','M','A-','1998-12-10',1,'2025-06-25 11:22:13',NULL),('ef4d8ffe-51e8-11f0-9f2b-00155d276843','Dr.','Eduardo','Ramírez','Ramírez','RMRE890611MC36','M','O+','1989-06-11',1,'2025-06-25 11:22:13',NULL),('ef4e1734-51e8-11f0-9f2b-00155d276843',NULL,'Luis','Rodríguez','Pérez','RRPL070527MF12','M','A+','2007-05-27',1,'2025-06-25 11:22:13',NULL),('ef4e9c63-51e8-11f0-9f2b-00155d276843',NULL,'María','Morales','Ortega','MLOM030318FM70','F','A-','2003-03-18',1,'2025-06-25 11:22:13',NULL);
/*!40000 ALTER TABLE `tbb_personas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personas_AFTER_INSERT` AFTER INSERT ON `tbb_personas` FOR EACH ROW BEGIN
    DECLARE nombre_persona VARCHAR(255);

    -- Construir el nombre completo directamente desde NEW
    SET nombre_persona = CONCAT_WS(' ', NEW.nombre, NEW.primer_apellido, NEW.segundo_apellido);

    -- Insertar en la bitácora con la estructura correcta
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Create',
        'tbb_personas',
        CONCAT_WS('\n',
            CONCAT('Se ha agregado una nueva PERSONA con el ID: ', NEW.id),
            CONCAT('Nombre: ', nombre_persona),
            CONCAT('Título: ', NEW.titulo),
            CONCAT('Primer Apellido: ', NEW.primer_apellido),
            CONCAT('Segundo Apellido: ', NEW.segundo_apellido),
            CONCAT('CURP: ', NEW.curp),
            CONCAT('Género: ', NEW.genero),
            CONCAT('Grupo Sanguíneo: ', NEW.grupo_sanguineo),
            CONCAT('Fecha de Nacimiento: ', NEW.fecha_nacimiento),
            CONCAT('Estatus: ', NEW.estatus)
        ),
        b'1',
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personas_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_personas` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personas_AFTER_UPDATE` AFTER UPDATE ON `tbb_personas` FOR EACH ROW BEGIN
    DECLARE nombre_persona_old VARCHAR(255);
    DECLARE nombre_persona_new VARCHAR(255);

    -- Construcción de nombre completo (antes y después de la actualización)
    SET nombre_persona_old = CONCAT_WS(' ', OLD.nombre, OLD.primer_apellido, OLD.segundo_apellido);
    SET nombre_persona_new = CONCAT_WS(' ', NEW.nombre, NEW.primer_apellido, NEW.segundo_apellido);

    -- Insertar en bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro

    ) VALUES (
        DEFAULT,
        USER(),
        'Update',
        'tbb_personas',
        CONCAT_WS('\n',
            CONCAT('Se ha actualizado la PERSONA con ID: ', OLD.id),
            CONCAT('Nombre anterior: ', nombre_persona_old),
            CONCAT('Nombre nuevo: ', nombre_persona_new),
            CONCAT('Título: ', NEW.titulo),
            CONCAT('Primer Apellido: ', NEW.primer_apellido),
            CONCAT('Segundo Apellido: ', NEW.segundo_apellido),
            CONCAT('CURP: ', NEW.curp),
            CONCAT('Género: ', NEW.genero),
            CONCAT('Grupo Sanguíneo: ', NEW.grupo_sanguineo),
            CONCAT('Fecha de Nacimiento: ', NEW.fecha_nacimiento),
            CONCAT('Estatus anterior: ', OLD.estatus),
            CONCAT('Estatus nuevo: ', NEW.estatus)
        ),
		b'1',
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_personas_AFTER_DELETE` AFTER DELETE ON `tbb_personas` FOR EACH ROW BEGIN
    DECLARE nombre_persona VARCHAR(255);

    -- Construcción del nombre completo antes de la eliminación
    SET nombre_persona = CONCAT_WS(' ', OLD.nombre, OLD.primer_apellido, OLD.segundo_apellido);

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro

    ) VALUES (
        DEFAULT,
        USER(),
        'Delete',
        'tbb_personas',
        CONCAT_WS('\n',
            CONCAT('Se ha eliminado la PERSONA con el ID: ', OLD.id),
            CONCAT('Nombre: ', nombre_persona),
            CONCAT('Título: ', OLD.titulo),
            CONCAT('Primer Apellido: ', OLD.primer_apellido),
            CONCAT('Segundo Apellido: ', OLD.segundo_apellido),
            CONCAT('CURP: ', OLD.curp),
            CONCAT('Género: ', OLD.genero),
            CONCAT('Grupo Sanguíneo: ', OLD.grupo_sanguineo),
            CONCAT('Fecha de Nacimiento: ', OLD.fecha_nacimiento),
            CONCAT('Estatus: ', OLD.estatus)
        ),
        b'1',
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbb_usuarios`
--

DROP TABLE IF EXISTS `tbb_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_usuarios` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `persona_id` char(36) NOT NULL,
  `nombre_usuario` varchar(40) NOT NULL,
  `correo_electronico` varchar(100) NOT NULL,
  `contrasena` varchar(60) NOT NULL,
  `numero_telefonico_movil` char(19) NOT NULL,
  `estatus` enum('Activo','Inactivo','Bloqueado','Suspendido') DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo_electronico` (`correo_electronico`),
  UNIQUE KEY `numero_telefonico_movil` (`numero_telefonico_movil`),
  UNIQUE KEY `nombre_usuario_UNIQUE` (`nombre_usuario`),
  UNIQUE KEY `persona_id_UNIQUE` (`persona_id`),
  KEY `persona_id` (`persona_id`),
  CONSTRAINT `tbb_usuarios_ibfk_1` FOREIGN KEY (`persona_id`) REFERENCES `tbb_personas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_usuarios`
--

LOCK TABLES `tbb_usuarios` WRITE;
/*!40000 ALTER TABLE `tbb_usuarios` DISABLE KEYS */;
INSERT INTO `tbb_usuarios` VALUES ('09081bd7-0ff8-11f0-b70d-3c557613b8e0','09057c00-0ff8-11f0-b70d-3c557613b8e0','fernanda.castillo910','fernanda.castillo910@correo.com','123456','+52 826 116 0629','Activo','2025-04-02 13:24:02',NULL),('125f31e8-0ff8-11f0-b70d-3c557613b8e0','125e9a19-0ff8-11f0-b70d-3c557613b8e0','alex.rojas972','alex.rojas972@correo.com','123456','+52 981 536 7750','Activo','2025-04-02 13:24:18',NULL),('26fd5f79-11a9-11f0-b70d-3c557613b8e0','26f93a89-11a9-11f0-b70d-3c557613b8e0','juan.rodríguez578','juan.rodríguez578@ejemplo.com','f8ad477e','+52 222 246 1232','Activo','2025-04-04 17:04:24',NULL),('5254a4c9-0ff8-11f0-b70d-3c557613b8e0','5253f56b-0ff8-11f0-b70d-3c557613b8e0','andrea.torres822','andrea.torres822@correo.com','123456','+52 984 035 7217','Activo','2025-04-02 13:26:05',NULL),('ba6db346-51e8-11f0-9f2b-00155d276843','bdb8af10-11a9-11f0-b70d-3c557613b8e0','miguel.ramírez','miguel.ramírez@ejemplo.com','4d6f9f28','+52 314 560 1617','Activo','2025-06-25 11:20:45',NULL),('ba6eda76-51e8-11f0-9f2b-00155d276843','d5732ae1-11a9-11f0-b70d-3c557613b8e0','fernando.rodríguez','fernando.rodríguez@ejemplo.com','e2b13a2c','+52 984 284 1911','Activo','2025-06-25 11:20:45',NULL),('ba6fa70e-51e8-11f0-9f2b-00155d276843','ee0c917b-11a9-11f0-b70d-3c557613b8e0','javier.sánchez','javier.sánchez@ejemplo.com','82f0ec1c','+52 998 610 9298','Activo','2025-06-25 11:20:45',NULL),('ef4f7361-51e8-11f0-9f2b-00155d276843','ee9a4acd-51e8-11f0-9f2b-00155d276843','ricardo.gonzález652','ricardo.gonzález652@ejemplo.com','60f6733d','+52 311 773 7024','Activo','2025-06-25 11:22:13',NULL),('ef4fe4d6-51e8-11f0-9f2b-00155d276843','ee9b71d2-51e8-11f0-9f2b-00155d276843','chris.domínguez382','chris.domínguez382@ejemplo.com','b96ba72c','+52 728 788 5955','Activo','2025-06-25 11:22:13',NULL),('ef5024bd-51e8-11f0-9f2b-00155d276843','ee9c3b3e-51e8-11f0-9f2b-00155d276843','casey.domínguez117','casey.domínguez117@ejemplo.com','3fcd12c4','+52 953 818 3829','Activo','2025-06-25 11:22:13',NULL),('ef505d45-51e8-11f0-9f2b-00155d276843','ee9d6a0f-51e8-11f0-9f2b-00155d276843','javier.rodríguez354','javier.rodríguez354@ejemplo.com','5828421a','+52 229 829 1178','Activo','2025-06-25 11:22:13',NULL),('ef5089d7-51e8-11f0-9f2b-00155d276843','ee9e122a-51e8-11f0-9f2b-00155d276843','juan.martínez391','juan.martínez391@ejemplo.com','9cdb57f2','+52 984 098 4144','Activo','2025-06-25 11:22:13',NULL),('ef50acd2-51e8-11f0-9f2b-00155d276843','ee9ec858-51e8-11f0-9f2b-00155d276843','gabriela.navarro451','gabriela.navarro451@ejemplo.com','a448bf57','+52 962 597 6151','Activo','2025-06-25 11:22:13',NULL),('ef50d31f-51e8-11f0-9f2b-00155d276843','ee9f751b-51e8-11f0-9f2b-00155d276843','dani.rojas682','dani.rojas682@ejemplo.com','418621e6','+52 671 010 4223','Activo','2025-06-25 11:22:13',NULL),('ef50f47c-51e8-11f0-9f2b-00155d276843','eea01918-51e8-11f0-9f2b-00155d276843','andrea.jiménez326','andrea.jiménez326@ejemplo.com','42abe955','+52 745 168 0539','Activo','2025-06-25 11:22:13',NULL),('ef511766-51e8-11f0-9f2b-00155d276843','eea1037f-51e8-11f0-9f2b-00155d276843','maría.castillo762','maría.castillo762@ejemplo.com','702eafa7','+52 441 798 3045','Activo','2025-06-25 11:22:13',NULL),('ef513dba-51e8-11f0-9f2b-00155d276843','eea1f674-51e8-11f0-9f2b-00155d276843','sofía.castillo998','sofía.castillo998@ejemplo.com','0d57daee','+52 449 206 0942','Activo','2025-06-25 11:22:13',NULL),('ef5161c7-51e8-11f0-9f2b-00155d276843','eea29c6d-51e8-11f0-9f2b-00155d276843','robin.delgado124','robin.delgado124@ejemplo.com','f2312eab','+52 311 027 6637','Activo','2025-06-25 11:22:13',NULL),('ef5189e8-51e8-11f0-9f2b-00155d276843','eea3597d-51e8-11f0-9f2b-00155d276843','carlos.rodríguez626','carlos.rodríguez626@ejemplo.com','496751b6','+52 352 795 0361','Activo','2025-06-25 11:22:13',NULL),('ef51dbe1-51e8-11f0-9f2b-00155d276843','eea43c8b-51e8-11f0-9f2b-00155d276843','juan.garcía620','juan.garcía620@ejemplo.com','a93437fc','+52 621 456 6448','Activo','2025-06-25 11:22:13',NULL),('ef521ea6-51e8-11f0-9f2b-00155d276843','eea51c97-51e8-11f0-9f2b-00155d276843','chris.aguilar908','chris.aguilar908@ejemplo.com','bb3c154a','+52 247 231 2679','Activo','2025-06-25 11:22:13',NULL),('ef525180-51e8-11f0-9f2b-00155d276843','eea5c0c8-51e8-11f0-9f2b-00155d276843','fernanda.ortega456','fernanda.ortega456@ejemplo.com','3155e34c','+52 314 336 6955','Activo','2025-06-25 11:22:13',NULL),('ef527890-51e8-11f0-9f2b-00155d276843','eea6a481-51e8-11f0-9f2b-00155d276843','juan.rodríguez971','juan.rodríguez971@ejemplo.com','cdd6ee7a','+52 618 753 8785','Activo','2025-06-25 11:22:13',NULL),('ef52ac56-51e8-11f0-9f2b-00155d276843','eea76932-51e8-11f0-9f2b-00155d276843','maría.torres119','maría.torres119@ejemplo.com','6889fbf6','+52 55 3080 0417','Activo','2025-06-25 11:22:13',NULL),('ef52e2a0-51e8-11f0-9f2b-00155d276843','eea81e94-51e8-11f0-9f2b-00155d276843','miguel.pérez127','miguel.pérez127@ejemplo.com','3a54a5d6','+52 661 581 2784','Activo','2025-06-25 11:22:13',NULL),('ef53092a-51e8-11f0-9f2b-00155d276843','eea8e0ce-51e8-11f0-9f2b-00155d276843','sofía.torres770','sofía.torres770@ejemplo.com','8258284e','+52 448 430 1838','Activo','2025-06-25 11:22:13',NULL),('ef532f4e-51e8-11f0-9f2b-00155d276843','eea99b9b-51e8-11f0-9f2b-00155d276843','isabel.torres212','isabel.torres212@ejemplo.com','f7548b1d','+52 722 469 5181','Activo','2025-06-25 11:22:13',NULL),('ef5353ae-51e8-11f0-9f2b-00155d276843','eeaa7040-51e8-11f0-9f2b-00155d276843','jordan.rojas518','jordan.rojas518@ejemplo.com','008fa502','+52 844 199 8348','Activo','2025-06-25 11:22:13',NULL),('ef538166-51e8-11f0-9f2b-00155d276843','eeab9744-51e8-11f0-9f2b-00155d276843','jordan.medina485','jordan.medina485@ejemplo.com','e8dcf01d','+52 315 512 3869','Activo','2025-06-25 11:22:13',NULL),('ef53b3a1-51e8-11f0-9f2b-00155d276843','eeac62e6-51e8-11f0-9f2b-00155d276843','robin.medina349','robin.medina349@ejemplo.com','05191482','+52 312 562 1047','Activo','2025-06-25 11:22:13',NULL),('ef53e81f-51e8-11f0-9f2b-00155d276843','eead2537-51e8-11f0-9f2b-00155d276843','sky.vega586','sky.vega586@ejemplo.com','488ae0da','+52 352 298 5825','Activo','2025-06-25 11:22:13',NULL),('ef544353-51e8-11f0-9f2b-00155d276843','eeae018f-51e8-11f0-9f2b-00155d276843','sofía.ortega171','sofía.ortega171@ejemplo.com','7055ee4e','+52 674 883 3481','Activo','2025-06-25 11:22:13',NULL),('ef5468e0-51e8-11f0-9f2b-00155d276843','eeaebc83-51e8-11f0-9f2b-00155d276843','fernanda.navarro622','fernanda.navarro622@ejemplo.com','ffc0a576','+52 733 803 2467','Activo','2025-06-25 11:22:13',NULL),('ef549bb2-51e8-11f0-9f2b-00155d276843','eeaf9396-51e8-11f0-9f2b-00155d276843','lucía.gutiérrez535','lucía.gutiérrez535@ejemplo.com','d58d3572','+52 953 962 4411','Activo','2025-06-25 11:22:13',NULL),('ef54c7f3-51e8-11f0-9f2b-00155d276843','eeb0a035-51e8-11f0-9f2b-00155d276843','fernando.garcía114','fernando.garcía114@ejemplo.com','a24df721','+52 228 054 3342','Activo','2025-06-25 11:22:13',NULL),('ef54f66c-51e8-11f0-9f2b-00155d276843','eeb1512a-51e8-11f0-9f2b-00155d276843','camila.gutiérrez538','camila.gutiérrez538@ejemplo.com','8b0e9df2','+52 246 678 9364','Activo','2025-06-25 11:22:13',NULL),('ef55276c-51e8-11f0-9f2b-00155d276843','eeb21369-51e8-11f0-9f2b-00155d276843','camila.torres727','camila.torres727@ejemplo.com','1f3929d4','+52 626 474 1321','Activo','2025-06-25 11:22:13',NULL),('ef554dd4-51e8-11f0-9f2b-00155d276843','eeb2eebb-51e8-11f0-9f2b-00155d276843','valeria.castillo885','valeria.castillo885@ejemplo.com','2ca7772f','+52 981 633 4729','Activo','2025-06-25 11:22:13',NULL),('ef557207-51e8-11f0-9f2b-00155d276843','eeb3b2c3-51e8-11f0-9f2b-00155d276843','alejandra.torres902','alejandra.torres902@ejemplo.com','10c7c8bd','+52 961 876 5325','Activo','2025-06-25 11:22:13',NULL),('ef5591cc-51e8-11f0-9f2b-00155d276843','eeb4978b-51e8-11f0-9f2b-00155d276843','fernanda.morales149','fernanda.morales149@ejemplo.com','35c9ea2c','+52 661 339 3677','Activo','2025-06-25 11:22:13',NULL),('ef55b5e6-51e8-11f0-9f2b-00155d276843','eeb5736d-51e8-11f0-9f2b-00155d276843','alejandra.ortega581','alejandra.ortega581@ejemplo.com','008219fe','+52 448 404 0045','Activo','2025-06-25 11:22:13',NULL),('ef55dc01-51e8-11f0-9f2b-00155d276843','eeb67c4b-51e8-11f0-9f2b-00155d276843','miguel.martínez997','miguel.martínez997@ejemplo.com','ef1b30c5','+52 833 084 7703','Activo','2025-06-25 11:22:13',NULL),('ef55fb61-51e8-11f0-9f2b-00155d276843','eeb7442e-51e8-11f0-9f2b-00155d276843','alejandro.sánchez800','alejandro.sánchez800@ejemplo.com','40ced494','+52 914 351 8766','Activo','2025-06-25 11:22:13',NULL),('ef565980-51e8-11f0-9f2b-00155d276843','eeb8168b-51e8-11f0-9f2b-00155d276843','andrea.navarro280','andrea.navarro280@ejemplo.com','b8640c12','+52 966 827 3044','Activo','2025-06-25 11:22:13',NULL),('ef56cb37-51e8-11f0-9f2b-00155d276843','eeb8d665-51e8-11f0-9f2b-00155d276843','maría.reyes761','maría.reyes761@ejemplo.com','ef397507','+52 668 263 4356','Activo','2025-06-25 11:22:13',NULL),('ef56f935-51e8-11f0-9f2b-00155d276843','eeb97c48-51e8-11f0-9f2b-00155d276843','alex.aguilar106','alex.aguilar106@ejemplo.com','150f5032','+52 312 346 7700','Activo','2025-06-25 11:22:13',NULL),('ef5723c6-51e8-11f0-9f2b-00155d276843','eeba145c-51e8-11f0-9f2b-00155d276843','andrés.lópez170','andrés.lópez170@ejemplo.com','269497d3','+52 319 603 8333','Activo','2025-06-25 11:22:13',NULL),('ef576781-51e8-11f0-9f2b-00155d276843','eebaab40-51e8-11f0-9f2b-00155d276843','javier.lópez477','javier.lópez477@ejemplo.com','ce5837e4','+52 55 0264 6088','Activo','2025-06-25 11:22:13',NULL),('ef57a8cd-51e8-11f0-9f2b-00155d276843','eebb5108-51e8-11f0-9f2b-00155d276843','luis.pérez639','luis.pérez639@ejemplo.com','31586ff7','+52 669 165 5929','Activo','2025-06-25 11:22:13',NULL),('ef5839a2-51e8-11f0-9f2b-00155d276843','eebc05bf-51e8-11f0-9f2b-00155d276843','lucía.torres531','lucía.torres531@ejemplo.com','8a0b9059','+52 613 655 0750','Activo','2025-06-25 11:22:13',NULL),('ef586190-51e8-11f0-9f2b-00155d276843','eebcb99f-51e8-11f0-9f2b-00155d276843','fernando.sánchez152','fernando.sánchez152@ejemplo.com','f5c4eb4f','+52 351 277 7047','Activo','2025-06-25 11:22:13',NULL),('ef588284-51e8-11f0-9f2b-00155d276843','eebd873a-51e8-11f0-9f2b-00155d276843','andrés.sánchez133','andrés.sánchez133@ejemplo.com','cf0ecf66','+52 223 191 6498','Activo','2025-06-25 11:22:13',NULL),('ef589efd-51e8-11f0-9f2b-00155d276843','eebe2348-51e8-11f0-9f2b-00155d276843','sofía.gutiérrez108','sofía.gutiérrez108@ejemplo.com','2d28d589','+52 413 241 8231','Activo','2025-06-25 11:22:13',NULL),('ef58dd38-51e8-11f0-9f2b-00155d276843','eebeb478-51e8-11f0-9f2b-00155d276843','sam.aguilar293','sam.aguilar293@ejemplo.com','62cb50cb','+52 981 421 7013','Activo','2025-06-25 11:22:13',NULL),('ef591065-51e8-11f0-9f2b-00155d276843','eebf5688-51e8-11f0-9f2b-00155d276843','taylor.mendoza847','taylor.mendoza847@ejemplo.com','f2215171','+52 229 055 9111','Activo','2025-06-25 11:22:13',NULL),('ef5936dc-51e8-11f0-9f2b-00155d276843','eec041c9-51e8-11f0-9f2b-00155d276843','luis.gonzález504','luis.gonzález504@ejemplo.com','2e19b7a9','+52 661 019 7292','Activo','2025-06-25 11:22:13',NULL),('ef595dac-51e8-11f0-9f2b-00155d276843','eec0dbcf-51e8-11f0-9f2b-00155d276843','miguel.lópez948','miguel.lópez948@ejemplo.com','d690e676','+52 317 238 3441','Activo','2025-06-25 11:22:13',NULL),('ef5983d1-51e8-11f0-9f2b-00155d276843','eec185c0-51e8-11f0-9f2b-00155d276843','sky.domínguez885','sky.domínguez885@ejemplo.com','ecc22f8a','+52 221 153 9673','Activo','2025-06-25 11:22:13',NULL),('ef59aaea-51e8-11f0-9f2b-00155d276843','eec26215-51e8-11f0-9f2b-00155d276843','fernando.martínez921','fernando.martínez921@ejemplo.com','1ccb1ab6','+52 667 504 9384','Activo','2025-06-25 11:22:13',NULL),('ef59d8a6-51e8-11f0-9f2b-00155d276843','eec302ec-51e8-11f0-9f2b-00155d276843','robin.flores318','robin.flores318@ejemplo.com','c55a82a6','+52 667 722 5510','Activo','2025-06-25 11:22:13',NULL),('ef5a09b2-51e8-11f0-9f2b-00155d276843','eec39853-51e8-11f0-9f2b-00155d276843','javier.pérez390','javier.pérez390@ejemplo.com','86fed9e2','+52 618 934 9933','Activo','2025-06-25 11:22:13',NULL),('ef5a379b-51e8-11f0-9f2b-00155d276843','eec44ab3-51e8-11f0-9f2b-00155d276843','dani.medina923','dani.medina923@ejemplo.com','96ae51b9','+52 981 176 0928','Activo','2025-06-25 11:22:13',NULL),('ef5a641d-51e8-11f0-9f2b-00155d276843','eec508df-51e8-11f0-9f2b-00155d276843','taylor.mendoza633','taylor.mendoza633@ejemplo.com','f6d4a455','+52 772 665 4057','Activo','2025-06-25 11:22:13',NULL),('ef5a825c-51e8-11f0-9f2b-00155d276843','eec59ae1-51e8-11f0-9f2b-00155d276843','morgan.vega231','morgan.vega231@ejemplo.com','f4c1e9f4','+52 313 970 6426','Activo','2025-06-25 11:22:13',NULL),('ef5aa0af-51e8-11f0-9f2b-00155d276843','eec640a1-51e8-11f0-9f2b-00155d276843','eduardo.ramírez233','eduardo.ramírez233@ejemplo.com','2d2f6959','+52 984 032 5903','Activo','2025-06-25 11:22:13',NULL),('ef5abdc5-51e8-11f0-9f2b-00155d276843','eec6e665-51e8-11f0-9f2b-00155d276843','luis.garcía144','luis.garcía144@ejemplo.com','3fd94be0','+52 953 556 4426','Activo','2025-06-25 11:22:13',NULL),('ef5adabb-51e8-11f0-9f2b-00155d276843','eec787c3-51e8-11f0-9f2b-00155d276843','dani.flores980','dani.flores980@ejemplo.com','260b563a','+52 55 2200 0725','Activo','2025-06-25 11:22:13',NULL),('ef5afa4e-51e8-11f0-9f2b-00155d276843','eec82d5e-51e8-11f0-9f2b-00155d276843','sky.flores610','sky.flores610@ejemplo.com','90af6766','+52 844 390 6452','Activo','2025-06-25 11:22:13',NULL),('ef5b32aa-51e8-11f0-9f2b-00155d276843','eec8c8c1-51e8-11f0-9f2b-00155d276843','eduardo.sánchez459','eduardo.sánchez459@ejemplo.com','6aca653d','+52 228 170 7569','Activo','2025-06-25 11:22:13',NULL),('ef5b7dae-51e8-11f0-9f2b-00155d276843','eec97250-51e8-11f0-9f2b-00155d276843','sam.mendoza158','sam.mendoza158@ejemplo.com','ab14a38c','+52 832 927 3572','Activo','2025-06-25 11:22:13',NULL),('ef5ba636-51e8-11f0-9f2b-00155d276843','eeca1082-51e8-11f0-9f2b-00155d276843','andrea.reyes113','andrea.reyes113@ejemplo.com','1d417309','+52 315 252 2379','Activo','2025-06-25 11:22:13',NULL),('ef5bcb57-51e8-11f0-9f2b-00155d276843','eecaaa94-51e8-11f0-9f2b-00155d276843','robin.domínguez981','robin.domínguez981@ejemplo.com','d029830b','+52 668 401 7032','Activo','2025-06-25 11:22:13',NULL),('ef5bf495-51e8-11f0-9f2b-00155d276843','eecb25f8-51e8-11f0-9f2b-00155d276843','fernando.pérez742','fernando.pérez742@ejemplo.com','cad52e0e','+52 983 352 9414','Activo','2025-06-25 11:22:13',NULL),('ef5c1761-51e8-11f0-9f2b-00155d276843','eecbac99-51e8-11f0-9f2b-00155d276843','casey.aguilar723','casey.aguilar723@ejemplo.com','8cb2f095','+52 271 520 9776','Activo','2025-06-25 11:22:13',NULL),('ef5c3c46-51e8-11f0-9f2b-00155d276843','eecc27de-51e8-11f0-9f2b-00155d276843','juan.martínez786','juan.martínez786@ejemplo.com','104ab355','+52 988 107 0856','Activo','2025-06-25 11:22:13',NULL),('ef5c6833-51e8-11f0-9f2b-00155d276843','eecc943a-51e8-11f0-9f2b-00155d276843','camila.ortega655','camila.ortega655@ejemplo.com','ce053248','+52 999 531 1881','Activo','2025-06-25 11:22:13',NULL),('ef5c8d9d-51e8-11f0-9f2b-00155d276843','eecd0e68-51e8-11f0-9f2b-00155d276843','valeria.ortega787','valeria.ortega787@ejemplo.com','4f1fdd8b','+52 913 523 6232','Activo','2025-06-25 11:22:13',NULL),('ef5cb174-51e8-11f0-9f2b-00155d276843','eecd7a93-51e8-11f0-9f2b-00155d276843','fernando.martínez186','fernando.martínez186@ejemplo.com','6e5dc7fd','+52 671 576 5510','Activo','2025-06-25 11:22:13',NULL),('ef5cd6ac-51e8-11f0-9f2b-00155d276843','eecded6d-51e8-11f0-9f2b-00155d276843','dani.medina189','dani.medina189@ejemplo.com','3077f54f','+52 311 343 5226','Activo','2025-06-25 11:22:13',NULL),('ef5cfeda-51e8-11f0-9f2b-00155d276843','eece6f36-51e8-11f0-9f2b-00155d276843','ricardo.gonzález221','ricardo.gonzález221@ejemplo.com','e68bcae0','+52 623 127 6404','Activo','2025-06-25 11:22:13',NULL),('ef5d267f-51e8-11f0-9f2b-00155d276843','eeceff9e-51e8-11f0-9f2b-00155d276843','andrés.pérez283','andrés.pérez283@ejemplo.com','3e582995','+52 828 955 3612','Activo','2025-06-25 11:22:13',NULL),('ef5d4780-51e8-11f0-9f2b-00155d276843','eecf6da0-51e8-11f0-9f2b-00155d276843','camila.jiménez151','camila.jiménez151@ejemplo.com','0f66252d','+52 247 350 0244','Activo','2025-06-25 11:22:13',NULL),('ef5d8a2c-51e8-11f0-9f2b-00155d276843','eecfd760-51e8-11f0-9f2b-00155d276843','valeria.ortega988','valeria.ortega988@ejemplo.com','aef36f23','+52 352 674 1527','Activo','2025-06-25 11:22:13',NULL),('ef5dca8d-51e8-11f0-9f2b-00155d276843','eed068f2-51e8-11f0-9f2b-00155d276843','lucía.morales975','lucía.morales975@ejemplo.com','976fa20a','+52 674 882 4179','Activo','2025-06-25 11:22:13',NULL),('ef5df76e-51e8-11f0-9f2b-00155d276843','eed0e166-51e8-11f0-9f2b-00155d276843','valeria.morales614','valeria.morales614@ejemplo.com','81ad8ce8','+52 414 062 9866','Activo','2025-06-25 11:22:13',NULL),('ef5e1ba6-51e8-11f0-9f2b-00155d276843','eed15b01-51e8-11f0-9f2b-00155d276843','miguel.ramírez367','miguel.ramírez367@ejemplo.com','cc2e4de1','+52 953 128 5853','Activo','2025-06-25 11:22:13',NULL),('ef5e3a66-51e8-11f0-9f2b-00155d276843','eed1cc5c-51e8-11f0-9f2b-00155d276843','javier.pérez843','javier.pérez843@ejemplo.com','a2f3664d','+52 618 002 8750','Activo','2025-06-25 11:22:13',NULL),('ef5efc09-51e8-11f0-9f2b-00155d276843','eed23f7f-51e8-11f0-9f2b-00155d276843','javier.sánchez344','javier.sánchez344@ejemplo.com','e752da02','+52 228 570 7177','Activo','2025-06-25 11:22:13',NULL),('ef5f2674-51e8-11f0-9f2b-00155d276843','eed2cec6-51e8-11f0-9f2b-00155d276843','eduardo.lópez177','eduardo.lópez177@ejemplo.com','48d97fac','+52 413 523 3052','Activo','2025-06-25 11:22:13',NULL),('ef5f501a-51e8-11f0-9f2b-00155d276843','eed36481-51e8-11f0-9f2b-00155d276843','jordan.delgado647','jordan.delgado647@ejemplo.com','645dd126','+52 319 265 5836','Activo','2025-06-25 11:22:13',NULL),('ef5f82c9-51e8-11f0-9f2b-00155d276843','eed3e8d0-51e8-11f0-9f2b-00155d276843','fernanda.gutiérrez746','fernanda.gutiérrez746@ejemplo.com','473d1b95','+52 623 707 4714','Activo','2025-06-25 11:22:13',NULL),('ef5fb0b1-51e8-11f0-9f2b-00155d276843','eed45ce2-51e8-11f0-9f2b-00155d276843','alejandra.jiménez174','alejandra.jiménez174@ejemplo.com','156150b6','+52 862 150 4561','Activo','2025-06-25 11:22:13',NULL),('ef600058-51e8-11f0-9f2b-00155d276843','eed4f40a-51e8-11f0-9f2b-00155d276843','sky.delgado225','sky.delgado225@ejemplo.com','bd37eb0d','+52 622 301 2714','Activo','2025-06-25 11:22:13',NULL),('ef603661-51e8-11f0-9f2b-00155d276843','eed578fc-51e8-11f0-9f2b-00155d276843','alejandro.gonzález176','alejandro.gonzález176@ejemplo.com','10f0116e','+52 414 149 1804','Activo','2025-06-25 11:22:13',NULL),('ef606641-51e8-11f0-9f2b-00155d276843','eed63091-51e8-11f0-9f2b-00155d276843','isabel.jiménez750','isabel.jiménez750@ejemplo.com','b812236d','+52 223 765 9272','Activo','2025-06-25 11:22:13',NULL),('ef608f44-51e8-11f0-9f2b-00155d276843','eed6b63a-51e8-11f0-9f2b-00155d276843','alex.rojas888','alex.rojas888@ejemplo.com','ce9ffc06','+52 668 629 4434','Activo','2025-06-25 11:22:13',NULL),('ef60b619-51e8-11f0-9f2b-00155d276843','eed74bff-51e8-11f0-9f2b-00155d276843','valeria.reyes842','valeria.reyes842@ejemplo.com','1082c17a','+52 998 859 0009','Activo','2025-06-25 11:22:13',NULL),('ef60e376-51e8-11f0-9f2b-00155d276843','eed7c738-51e8-11f0-9f2b-00155d276843','eduardo.cruz235','eduardo.cruz235@ejemplo.com','a3a02950','+52 315 652 4149','Activo','2025-06-25 11:22:13',NULL),('ef610926-51e8-11f0-9f2b-00155d276843','eed84bc2-51e8-11f0-9f2b-00155d276843','ricardo.gonzález955','ricardo.gonzález955@ejemplo.com','6aca6552','+52 962 199 2758','Activo','2025-06-25 11:22:13',NULL),('ef613d15-51e8-11f0-9f2b-00155d276843','eed8d310-51e8-11f0-9f2b-00155d276843','andrea.ortega684','andrea.ortega684@ejemplo.com','3d7eb7f1','+52 55 5060 1041','Activo','2025-06-25 11:22:13',NULL),('ef617d79-51e8-11f0-9f2b-00155d276843','eed98ddd-51e8-11f0-9f2b-00155d276843','dani.mendoza695','dani.mendoza695@ejemplo.com','3a0aae92','+52 999 420 2371','Activo','2025-06-25 11:22:13',NULL),('ef61a9ad-51e8-11f0-9f2b-00155d276843','eeda1714-51e8-11f0-9f2b-00155d276843','carlos.hernández307','carlos.hernández307@ejemplo.com','2a64fad7','+52 668 154 5020','Activo','2025-06-25 11:22:13',NULL),('ef61cd68-51e8-11f0-9f2b-00155d276843','eedaa68e-51e8-11f0-9f2b-00155d276843','eduardo.garcía527','eduardo.garcía527@ejemplo.com','31020508','+52 614 954 9935','Activo','2025-06-25 11:22:13',NULL),('ef61f126-51e8-11f0-9f2b-00155d276843','eedb2611-51e8-11f0-9f2b-00155d276843','dani.vega422','dani.vega422@ejemplo.com','b26daaaa','+52 826 048 1458','Activo','2025-06-25 11:22:13',NULL),('ef621630-51e8-11f0-9f2b-00155d276843','eedbb1c1-51e8-11f0-9f2b-00155d276843','andrés.gonzález586','andrés.gonzález586@ejemplo.com','20a7d276','+52 626 159 5439','Activo','2025-06-25 11:22:13',NULL),('ef6269a0-51e8-11f0-9f2b-00155d276843','eedc3476-51e8-11f0-9f2b-00155d276843','chris.mendoza368','chris.mendoza368@ejemplo.com','a11334c6','+52 55 8237 5577','Activo','2025-06-25 11:22:13',NULL),('ef62a297-51e8-11f0-9f2b-00155d276843','eedcbaf3-51e8-11f0-9f2b-00155d276843','chris.flores639','chris.flores639@ejemplo.com','4958bd79','+52 913 625 1833','Activo','2025-06-25 11:22:13',NULL),('ef62cd48-51e8-11f0-9f2b-00155d276843','eedd3369-51e8-11f0-9f2b-00155d276843','alex.rojas639','alex.rojas639@ejemplo.com','46f13e11','+52 623 713 6800','Activo','2025-06-25 11:22:13',NULL),('ef62efa8-51e8-11f0-9f2b-00155d276843','eeddc783-51e8-11f0-9f2b-00155d276843','casey.silva206','casey.silva206@ejemplo.com','a7d02363','+52 246 152 4273','Activo','2025-06-25 11:22:13',NULL),('ef6317f4-51e8-11f0-9f2b-00155d276843','eede449a-51e8-11f0-9f2b-00155d276843','isabel.torres152','isabel.torres152@ejemplo.com','5c835ea8','+52 492 474 5018','Activo','2025-06-25 11:22:13',NULL),('ef633c35-51e8-11f0-9f2b-00155d276843','eedeb756-51e8-11f0-9f2b-00155d276843','taylor.flores447','taylor.flores447@ejemplo.com','128f2cf2','+52 771 407 5372','Activo','2025-06-25 11:22:13',NULL),('ef635cf0-51e8-11f0-9f2b-00155d276843','eedf4740-51e8-11f0-9f2b-00155d276843','chris.delgado888','chris.delgado888@ejemplo.com','e10fcc74','+52 626 350 6425','Activo','2025-06-25 11:22:13',NULL),('ef637b9e-51e8-11f0-9f2b-00155d276843','eedfc0c2-51e8-11f0-9f2b-00155d276843','camila.gutiérrez331','camila.gutiérrez331@ejemplo.com','bb47fc74','+52 771 259 8732','Activo','2025-06-25 11:22:13',NULL),('ef639978-51e8-11f0-9f2b-00155d276843','eee041e4-51e8-11f0-9f2b-00155d276843','jordan.medina212','jordan.medina212@ejemplo.com','524d1174','+52 831 734 4737','Activo','2025-06-25 11:22:13',NULL),('ef63b7c9-51e8-11f0-9f2b-00155d276843','eee0eeb1-51e8-11f0-9f2b-00155d276843','sam.domínguez198','sam.domínguez198@ejemplo.com','5fc3ef41','+52 747 874 7881','Activo','2025-06-25 11:22:13',NULL),('ef63d5d0-51e8-11f0-9f2b-00155d276843','eee16c6a-51e8-11f0-9f2b-00155d276843','jordan.silva311','jordan.silva311@ejemplo.com','466d882e','+52 646 559 9687','Activo','2025-06-25 11:22:13',NULL),('ef640371-51e8-11f0-9f2b-00155d276843','eee1e5e6-51e8-11f0-9f2b-00155d276843','robin.silva707','robin.silva707@ejemplo.com','9c00a70c','+52 352 211 4519','Activo','2025-06-25 11:22:13',NULL),('ef642a06-51e8-11f0-9f2b-00155d276843','eee257d6-51e8-11f0-9f2b-00155d276843','valeria.vargas707','valeria.vargas707@ejemplo.com','9fb32750','+52 448 170 5601','Activo','2025-06-25 11:22:13',NULL),('ef64578b-51e8-11f0-9f2b-00155d276843','eee2eca0-51e8-11f0-9f2b-00155d276843','alejandra.ortega835','alejandra.ortega835@ejemplo.com','c41e5d5a','+52 312 374 5185','Activo','2025-06-25 11:22:13',NULL),('ef64870d-51e8-11f0-9f2b-00155d276843','eee38373-51e8-11f0-9f2b-00155d276843','casey.rojas652','casey.rojas652@ejemplo.com','4d2c94ae','+52 241 644 5181','Activo','2025-06-25 11:22:13',NULL),('ef64cebc-51e8-11f0-9f2b-00155d276843','eee40133-51e8-11f0-9f2b-00155d276843','miguel.hernández576','miguel.hernández576@ejemplo.com','ce77bdfb','+52 988 733 7265','Activo','2025-06-25 11:22:13',NULL),('ef650d47-51e8-11f0-9f2b-00155d276843','eee47363-51e8-11f0-9f2b-00155d276843','sky.rojas771','sky.rojas771@ejemplo.com','11243cdd','+52 773 462 2422','Activo','2025-06-25 11:22:13',NULL),('ef653f5b-51e8-11f0-9f2b-00155d276843','eee4f140-51e8-11f0-9f2b-00155d276843','camila.jiménez172','camila.jiménez172@ejemplo.com','d419bd5d','+52 913 117 2548','Activo','2025-06-25 11:22:13',NULL),('ef6578c3-51e8-11f0-9f2b-00155d276843','eee58730-51e8-11f0-9f2b-00155d276843','dani.medina180','dani.medina180@ejemplo.com','ffd0bcce','+52 862 776 7916','Activo','2025-06-25 11:22:13',NULL),('ef65ae33-51e8-11f0-9f2b-00155d276843','eee600f2-51e8-11f0-9f2b-00155d276843','sofía.navarro319','sofía.navarro319@ejemplo.com','e2e74a9d','+52 444 941 8900','Activo','2025-06-25 11:22:13',NULL),('ef65e7fa-51e8-11f0-9f2b-00155d276843','eee67d2a-51e8-11f0-9f2b-00155d276843','camila.gutiérrez586','camila.gutiérrez586@ejemplo.com','9d9d0140','+52 667 148 1868','Activo','2025-06-25 11:22:13',NULL),('ef661b7c-51e8-11f0-9f2b-00155d276843','eee6eefa-51e8-11f0-9f2b-00155d276843','lucía.navarro529','lucía.navarro529@ejemplo.com','15c2ddab','+52 674 534 9959','Activo','2025-06-25 11:22:13',NULL),('ef664339-51e8-11f0-9f2b-00155d276843','eee768d9-51e8-11f0-9f2b-00155d276843','fernando.pérez875','fernando.pérez875@ejemplo.com','0a48798d','+52 247 500 4973','Activo','2025-06-25 11:22:13',NULL),('ef666adb-51e8-11f0-9f2b-00155d276843','eee7ecca-51e8-11f0-9f2b-00155d276843','eduardo.lópez766','eduardo.lópez766@ejemplo.com','0537432e','+52 621 335 9287','Activo','2025-06-25 11:22:13',NULL),('ef66a2b1-51e8-11f0-9f2b-00155d276843','eee880b7-51e8-11f0-9f2b-00155d276843','taylor.aguilar382','taylor.aguilar382@ejemplo.com','07b7a584','+52 832 683 2664','Activo','2025-06-25 11:22:13',NULL),('ef672b5c-51e8-11f0-9f2b-00155d276843','eee8f9a1-51e8-11f0-9f2b-00155d276843','dani.flores812','dani.flores812@ejemplo.com','6951636d','+52 55 1501 7147','Activo','2025-06-25 11:22:13',NULL),('ef6758d2-51e8-11f0-9f2b-00155d276843','eee96bb3-51e8-11f0-9f2b-00155d276843','carlos.sánchez299','carlos.sánchez299@ejemplo.com','5f5a9059','+52 221 164 2407','Activo','2025-06-25 11:22:13',NULL),('ef678a58-51e8-11f0-9f2b-00155d276843','eee9f897-51e8-11f0-9f2b-00155d276843','taylor.aguilar943','taylor.aguilar943@ejemplo.com','60d5f7e9','+52 625 170 6948','Activo','2025-06-25 11:22:13',NULL),('ef67b36b-51e8-11f0-9f2b-00155d276843','eeea986e-51e8-11f0-9f2b-00155d276843','andrés.garcía464','andrés.garcía464@ejemplo.com','bc7ce1cc','+52 744 244 8307','Activo','2025-06-25 11:22:13',NULL),('ef67dd9b-51e8-11f0-9f2b-00155d276843','eeeb1c24-51e8-11f0-9f2b-00155d276843','sofía.jiménez235','sofía.jiménez235@ejemplo.com','dd207f45','+52 223 150 6892','Activo','2025-06-25 11:22:13',NULL),('ef684e96-51e8-11f0-9f2b-00155d276843','eeeb8ac6-51e8-11f0-9f2b-00155d276843','sofía.morales846','sofía.morales846@ejemplo.com','ad726d6f','+52 997 855 1422','Activo','2025-06-25 11:22:13',NULL),('ef687bbd-51e8-11f0-9f2b-00155d276843','eeebf895-51e8-11f0-9f2b-00155d276843','jordan.delgado379','jordan.delgado379@ejemplo.com','ec146f1a','+52 776 107 9724','Activo','2025-06-25 11:22:13',NULL),('ef689ead-51e8-11f0-9f2b-00155d276843','eeec7734-51e8-11f0-9f2b-00155d276843','sky.domínguez544','sky.domínguez544@ejemplo.com','90db9255','+52 314 768 0295','Activo','2025-06-25 11:22:13',NULL),('ef68c671-51e8-11f0-9f2b-00155d276843','eeecf5f9-51e8-11f0-9f2b-00155d276843','sofía.jiménez207','sofía.jiménez207@ejemplo.com','18d52372','+52 962 688 3904','Activo','2025-06-25 11:22:13',NULL),('ef68ec45-51e8-11f0-9f2b-00155d276843','eeedc04f-51e8-11f0-9f2b-00155d276843','robin.vega188','robin.vega188@ejemplo.com','cbc7f007','+52 913 907 5400','Activo','2025-06-25 11:22:13',NULL),('ef692626-51e8-11f0-9f2b-00155d276843','eeee33d8-51e8-11f0-9f2b-00155d276843','luis.lópez122','luis.lópez122@ejemplo.com','15551ea5','+52 271 526 6260','Activo','2025-06-25 11:22:13',NULL),('ef698b2e-51e8-11f0-9f2b-00155d276843','eeeec51e-51e8-11f0-9f2b-00155d276843','ricardo.martínez809','ricardo.martínez809@ejemplo.com','c2a2568f','+52 317 121 9920','Activo','2025-06-25 11:22:13',NULL),('ef69d1ac-51e8-11f0-9f2b-00155d276843','eeef522a-51e8-11f0-9f2b-00155d276843','fernando.cruz358','fernando.cruz358@ejemplo.com','0ce3fb63','+52 353 186 5687','Activo','2025-06-25 11:22:13',NULL),('ef69ff62-51e8-11f0-9f2b-00155d276843','eeefce21-51e8-11f0-9f2b-00155d276843','ricardo.sánchez549','ricardo.sánchez549@ejemplo.com','7901615c','+52 844 111 7379','Activo','2025-06-25 11:22:13',NULL),('ef6a2b8c-51e8-11f0-9f2b-00155d276843','eef042c2-51e8-11f0-9f2b-00155d276843','isabel.gutiérrez105','isabel.gutiérrez105@ejemplo.com','55aeb661','+52 351 214 0653','Activo','2025-06-25 11:22:13',NULL),('ef6a6fe6-51e8-11f0-9f2b-00155d276843','eef0e93e-51e8-11f0-9f2b-00155d276843','alejandra.castillo720','alejandra.castillo720@ejemplo.com','b5ffcd23','+52 999 373 6559','Activo','2025-06-25 11:22:13',NULL),('ef6aa3ce-51e8-11f0-9f2b-00155d276843','eef16b40-51e8-11f0-9f2b-00155d276843','ricardo.garcía995','ricardo.garcía995@ejemplo.com','b7eea991','+52 674 824 6976','Activo','2025-06-25 11:22:13',NULL),('ef6acbbf-51e8-11f0-9f2b-00155d276843','eef1eaca-51e8-11f0-9f2b-00155d276843','alejandra.vargas365','alejandra.vargas365@ejemplo.com','f8a0abac','+52 962 605 1604','Activo','2025-06-25 11:22:13',NULL),('ef6af916-51e8-11f0-9f2b-00155d276843','eef26ff9-51e8-11f0-9f2b-00155d276843','fernanda.reyes694','fernanda.reyes694@ejemplo.com','abfc0c1a','+52 317 769 5420','Activo','2025-06-25 11:22:13',NULL),('ef6b1e1a-51e8-11f0-9f2b-00155d276843','eef30cee-51e8-11f0-9f2b-00155d276843','dani.medina561','dani.medina561@ejemplo.com','dc1ba83f','+52 481 934 9405','Activo','2025-06-25 11:22:13',NULL),('ef6b43a1-51e8-11f0-9f2b-00155d276843','eef38d7d-51e8-11f0-9f2b-00155d276843','fernanda.jiménez507','fernanda.jiménez507@ejemplo.com','9467c0d3','+52 271 351 7201','Activo','2025-06-25 11:22:13',NULL),('ef6b6653-51e8-11f0-9f2b-00155d276843','eef40188-51e8-11f0-9f2b-00155d276843','dani.flores925','dani.flores925@ejemplo.com','b90c76a3','+52 246 909 8434','Activo','2025-06-25 11:22:13',NULL),('ef6bb5aa-51e8-11f0-9f2b-00155d276843','eef48956-51e8-11f0-9f2b-00155d276843','andrea.castillo863','andrea.castillo863@ejemplo.com','ce310884','+52 764 586 9639','Activo','2025-06-25 11:22:13',NULL),('ef6c06c1-51e8-11f0-9f2b-00155d276843','eef4fe54-51e8-11f0-9f2b-00155d276843','taylor.medina870','taylor.medina870@ejemplo.com','83b40833','+52 646 631 3159','Activo','2025-06-25 11:22:13',NULL),('ef6cb4ae-51e8-11f0-9f2b-00155d276843','eef57648-51e8-11f0-9f2b-00155d276843','camila.castillo134','camila.castillo134@ejemplo.com','3502bf61','+52 747 997 3061','Activo','2025-06-25 11:22:13',NULL),('ef6ce494-51e8-11f0-9f2b-00155d276843','eef5ff75-51e8-11f0-9f2b-00155d276843','andrea.castillo865','andrea.castillo865@ejemplo.com','335711bf','+52 482 939 4302','Activo','2025-06-25 11:22:13',NULL),('ef6d14a7-51e8-11f0-9f2b-00155d276843','eef66cab-51e8-11f0-9f2b-00155d276843','sam.flores521','sam.flores521@ejemplo.com','261a8ba8','+52 861 442 7924','Activo','2025-06-25 11:22:13',NULL),('ef6d36e1-51e8-11f0-9f2b-00155d276843','eef6efac-51e8-11f0-9f2b-00155d276843','taylor.delgado649','taylor.delgado649@ejemplo.com','3d25b19e','+52 621 783 9727','Activo','2025-06-25 11:22:13',NULL),('ef6d5c79-51e8-11f0-9f2b-00155d276843','eef78b59-51e8-11f0-9f2b-00155d276843','taylor.escobar590','taylor.escobar590@ejemplo.com','432820e9','+52 313 036 4655','Activo','2025-06-25 11:22:13',NULL),('ef6d8ef3-51e8-11f0-9f2b-00155d276843','eef8244c-51e8-11f0-9f2b-00155d276843','andrés.cruz539','andrés.cruz539@ejemplo.com','1c892a24','+52 861 005 9165','Activo','2025-06-25 11:22:13',NULL),('ef6dc92c-51e8-11f0-9f2b-00155d276843','eef8a2eb-51e8-11f0-9f2b-00155d276843','dani.escobar483','dani.escobar483@ejemplo.com','fa4bc9aa','+52 55 0756 5780','Activo','2025-06-25 11:22:13',NULL),('ef6e07f4-51e8-11f0-9f2b-00155d276843','eef9144a-51e8-11f0-9f2b-00155d276843','andrés.martínez578','andrés.martínez578@ejemplo.com','ed46f2ad','+52 81 4713 9921','Activo','2025-06-25 11:22:13',NULL),('ef6e5f55-51e8-11f0-9f2b-00155d276843','eef991f7-51e8-11f0-9f2b-00155d276843','taylor.rojas731','taylor.rojas731@ejemplo.com','c332e8da','+52 745 561 6570','Activo','2025-06-25 11:22:13',NULL),('ef6e8f5f-51e8-11f0-9f2b-00155d276843','eefa0e69-51e8-11f0-9f2b-00155d276843','casey.aguilar730','casey.aguilar730@ejemplo.com','4d017510','+52 997 465 0313','Activo','2025-06-25 11:22:13',NULL),('ef6ed36b-51e8-11f0-9f2b-00155d276843','eefa88b5-51e8-11f0-9f2b-00155d276843','jordan.domínguez438','jordan.domínguez438@ejemplo.com','e3ff3258','+52 722 011 5366','Activo','2025-06-25 11:22:13',NULL),('ef6f039f-51e8-11f0-9f2b-00155d276843','eefafbb7-51e8-11f0-9f2b-00155d276843','juan.rodríguez261','juan.rodríguez261@ejemplo.com','d0e5578a','+52 669 289 5560','Activo','2025-06-25 11:22:13',NULL),('ef6f2e69-51e8-11f0-9f2b-00155d276843','eefb6d9d-51e8-11f0-9f2b-00155d276843','valeria.reyes208','valeria.reyes208@ejemplo.com','7152503f','+52 412 383 2462','Activo','2025-06-25 11:22:13',NULL),('ef6f560d-51e8-11f0-9f2b-00155d276843','eefbe2a4-51e8-11f0-9f2b-00155d276843','eduardo.rodríguez964','eduardo.rodríguez964@ejemplo.com','6f81b0e1','+52 771 999 4370','Activo','2025-06-25 11:22:13',NULL),('ef6f83b1-51e8-11f0-9f2b-00155d276843','eefc91f0-51e8-11f0-9f2b-00155d276843','carlos.gonzález836','carlos.gonzález836@ejemplo.com','75d2ee1c','+52 449 763 9745','Activo','2025-06-25 11:22:13',NULL),('ef6fb04a-51e8-11f0-9f2b-00155d276843','eefd13b0-51e8-11f0-9f2b-00155d276843','alex.rojas815','alex.rojas815@ejemplo.com','242ea441','+52 764 088 8856','Activo','2025-06-25 11:22:13',NULL),('ef6fdf05-51e8-11f0-9f2b-00155d276843','eefd8224-51e8-11f0-9f2b-00155d276843','sam.medina426','sam.medina426@ejemplo.com','9b2d30f3','+52 223 605 8513','Activo','2025-06-25 11:22:13',NULL),('ef700735-51e8-11f0-9f2b-00155d276843','eefdf675-51e8-11f0-9f2b-00155d276843','jordan.domínguez171','jordan.domínguez171@ejemplo.com','ab62b783','+52 441 607 2813','Activo','2025-06-25 11:22:13',NULL),('ef70360c-51e8-11f0-9f2b-00155d276843','eefe740a-51e8-11f0-9f2b-00155d276843','lucía.gutiérrez121','lucía.gutiérrez121@ejemplo.com','9ebbdefa','+52 312 223 5464','Activo','2025-06-25 11:22:13',NULL),('ef706ed8-51e8-11f0-9f2b-00155d276843','eeff03ee-51e8-11f0-9f2b-00155d276843','fernando.martínez860','fernando.martínez860@ejemplo.com','c2bd7f82','+52 313 486 6693','Activo','2025-06-25 11:22:13',NULL),('ef70e5e1-51e8-11f0-9f2b-00155d276843','eeff7aa4-51e8-11f0-9f2b-00155d276843','fernanda.castillo772','fernanda.castillo772@ejemplo.com','2d0d7a89','+52 966 820 3119','Activo','2025-06-25 11:22:13',NULL),('ef715409-51e8-11f0-9f2b-00155d276843','eefff1f8-51e8-11f0-9f2b-00155d276843','juan.lópez745','juan.lópez745@ejemplo.com','8a4d85ac','+52 352 946 8009','Activo','2025-06-25 11:22:13',NULL),('ef71cb23-51e8-11f0-9f2b-00155d276843','ef006266-51e8-11f0-9f2b-00155d276843','fernanda.vargas410','fernanda.vargas410@ejemplo.com','4223bf60','+52 771 307 4529','Activo','2025-06-25 11:22:13',NULL),('ef71fd9f-51e8-11f0-9f2b-00155d276843','ef00de83-51e8-11f0-9f2b-00155d276843','ricardo.cruz422','ricardo.cruz422@ejemplo.com','551c81e7','+52 674 765 4971','Activo','2025-06-25 11:22:13',NULL),('ef722256-51e8-11f0-9f2b-00155d276843','ef0170bb-51e8-11f0-9f2b-00155d276843','juan.gonzález101','juan.gonzález101@ejemplo.com','57ddb90a','+52 81 6618 4391','Activo','2025-06-25 11:22:13',NULL),('ef724089-51e8-11f0-9f2b-00155d276843','ef01f264-51e8-11f0-9f2b-00155d276843','alejandra.gutiérrez665','alejandra.gutiérrez665@ejemplo.com','b261a12d','+52 241 007 1998','Activo','2025-06-25 11:22:13',NULL),('ef725f4d-51e8-11f0-9f2b-00155d276843','ef026833-51e8-11f0-9f2b-00155d276843','andrea.jiménez415','andrea.jiménez415@ejemplo.com','167f97e9','+52 954 860 1958','Activo','2025-06-25 11:22:13',NULL),('ef727fbb-51e8-11f0-9f2b-00155d276843','ef02fb84-51e8-11f0-9f2b-00155d276843','carlos.rodríguez519','carlos.rodríguez519@ejemplo.com','a329f1e2','+52 414 464 0119','Activo','2025-06-25 11:22:14',NULL),('ef72a950-51e8-11f0-9f2b-00155d276843','ef038493-51e8-11f0-9f2b-00155d276843','alex.aguilar366','alex.aguilar366@ejemplo.com','db2055a8','+52 324 480 2463','Activo','2025-06-25 11:22:14',NULL),('ef72cefc-51e8-11f0-9f2b-00155d276843','ef04166d-51e8-11f0-9f2b-00155d276843','sky.vega780','sky.vega780@ejemplo.com','f3b9f0b1','+52 315 139 5249','Activo','2025-06-25 11:22:14',NULL),('ef733fd9-51e8-11f0-9f2b-00155d276843','ef04886a-51e8-11f0-9f2b-00155d276843','carlos.pérez461','carlos.pérez461@ejemplo.com','44bb0c39','+52 482 957 1094','Activo','2025-06-25 11:22:14',NULL),('ef73ba61-51e8-11f0-9f2b-00155d276843','ef04f9ff-51e8-11f0-9f2b-00155d276843','robin.escobar594','robin.escobar594@ejemplo.com','393cecfc','+52 444 987 0184','Activo','2025-06-25 11:22:14',NULL),('ef73fa91-51e8-11f0-9f2b-00155d276843','ef0567d2-51e8-11f0-9f2b-00155d276843','andrea.fernández793','andrea.fernández793@ejemplo.com','81fd9e15','+52 614 021 4892','Activo','2025-06-25 11:22:14',NULL),('ef7423e3-51e8-11f0-9f2b-00155d276843','ef05da6b-51e8-11f0-9f2b-00155d276843','eduardo.ramírez723','eduardo.ramírez723@ejemplo.com','9d6eda63','+52 228 422 3192','Activo','2025-06-25 11:22:14',NULL),('ef744a79-51e8-11f0-9f2b-00155d276843','ef068905-51e8-11f0-9f2b-00155d276843','camila.castillo403','camila.castillo403@ejemplo.com','0aadd64a','+52 613 114 8885','Activo','2025-06-25 11:22:14',NULL),('ef746a07-51e8-11f0-9f2b-00155d276843','ef073294-51e8-11f0-9f2b-00155d276843','andrés.hernández420','andrés.hernández420@ejemplo.com','1559eb53','+52 981 198 9294','Activo','2025-06-25 11:22:14',NULL),('ef748cc6-51e8-11f0-9f2b-00155d276843','ef07d1a1-51e8-11f0-9f2b-00155d276843','javier.martínez725','javier.martínez725@ejemplo.com','89d06853','+52 728 926 8472','Activo','2025-06-25 11:22:14',NULL),('ef74b93a-51e8-11f0-9f2b-00155d276843','ef084420-51e8-11f0-9f2b-00155d276843','camila.fernández724','camila.fernández724@ejemplo.com','7c82d14c','+52 747 795 3270','Activo','2025-06-25 11:22:14',NULL),('ef74f10a-51e8-11f0-9f2b-00155d276843','ef08d803-51e8-11f0-9f2b-00155d276843','juan.cruz869','juan.cruz869@ejemplo.com','9ce6a1da','+52 833 722 5451','Activo','2025-06-25 11:22:14',NULL),('ef752c2f-51e8-11f0-9f2b-00155d276843','ef095028-51e8-11f0-9f2b-00155d276843','camila.vargas981','camila.vargas981@ejemplo.com','4d47e272','+52 444 411 5128','Activo','2025-06-25 11:22:14',NULL),('ef758d93-51e8-11f0-9f2b-00155d276843','ef09c1e6-51e8-11f0-9f2b-00155d276843','sofía.jiménez903','sofía.jiménez903@ejemplo.com','3af5b2e3','+52 352 622 7538','Activo','2025-06-25 11:22:14',NULL),('ef75f871-51e8-11f0-9f2b-00155d276843','ef0a321e-51e8-11f0-9f2b-00155d276843','sam.flores757','sam.flores757@ejemplo.com','4e72d2e0','+52 444 272 0355','Activo','2025-06-25 11:22:14',NULL),('ef7636a4-51e8-11f0-9f2b-00155d276843','ef0aaaf8-51e8-11f0-9f2b-00155d276843','lucía.morales268','lucía.morales268@ejemplo.com','c183593f','+52 661 865 1317','Activo','2025-06-25 11:22:14',NULL),('ef766513-51e8-11f0-9f2b-00155d276843','ef0b3d84-51e8-11f0-9f2b-00155d276843','chris.vega268','chris.vega268@ejemplo.com','22481ad4','+52 614 705 3270','Activo','2025-06-25 11:22:14',NULL),('ef768f51-51e8-11f0-9f2b-00155d276843','ef0bce6c-51e8-11f0-9f2b-00155d276843','morgan.medina179','morgan.medina179@ejemplo.com','05ea234e','+52 745 851 5143','Activo','2025-06-25 11:22:14',NULL),('ef76b830-51e8-11f0-9f2b-00155d276843','ef0c4554-51e8-11f0-9f2b-00155d276843','andrea.torres243','andrea.torres243@ejemplo.com','b198aac1','+52 481 937 9509','Activo','2025-06-25 11:22:14',NULL),('ef76dfa4-51e8-11f0-9f2b-00155d276843','ef0cb9b8-51e8-11f0-9f2b-00155d276843','maría.fernández541','maría.fernández541@ejemplo.com','64a36b30','+52 481 744 5307','Activo','2025-06-25 11:22:14',NULL),('ef770f28-51e8-11f0-9f2b-00155d276843','ef0d38de-51e8-11f0-9f2b-00155d276843','camila.fernández569','camila.fernández569@ejemplo.com','2502ddab','+52 728 400 0338','Activo','2025-06-25 11:22:14',NULL),('ef773d64-51e8-11f0-9f2b-00155d276843','ef0dbb33-51e8-11f0-9f2b-00155d276843','juan.sánchez178','juan.sánchez178@ejemplo.com','f8f5c160','+52 228 904 6171','Activo','2025-06-25 11:22:14',NULL),('ef7764f3-51e8-11f0-9f2b-00155d276843','ef0e58e3-51e8-11f0-9f2b-00155d276843','robin.domínguez778','robin.domínguez778@ejemplo.com','281572a4','+52 449 880 9347','Activo','2025-06-25 11:22:14',NULL),('ef778ccc-51e8-11f0-9f2b-00155d276843','ef0ed0e0-51e8-11f0-9f2b-00155d276843','gabriela.ortega441','gabriela.ortega441@ejemplo.com','078cc9e0','+52 966 886 6557','Activo','2025-06-25 11:22:14',NULL),('ef790c20-51e8-11f0-9f2b-00155d276843','ef0f4853-51e8-11f0-9f2b-00155d276843','morgan.vega140','morgan.vega140@ejemplo.com','3d419f83','+52 983 767 2293','Activo','2025-06-25 11:22:14',NULL),('ef793ec5-51e8-11f0-9f2b-00155d276843','ef0fce9c-51e8-11f0-9f2b-00155d276843','robin.domínguez781','robin.domínguez781@ejemplo.com','de20308a','+52 626 340 5594','Activo','2025-06-25 11:22:14',NULL),('ef796c30-51e8-11f0-9f2b-00155d276843','ef108a26-51e8-11f0-9f2b-00155d276843','eduardo.ramírez300','eduardo.ramírez300@ejemplo.com','a50a5bf7','+52 621 666 3217','Activo','2025-06-25 11:22:14',NULL),('ef799030-51e8-11f0-9f2b-00155d276843','ef1141da-51e8-11f0-9f2b-00155d276843','casey.delgado971','casey.delgado971@ejemplo.com','3c0e3213','+52 722 963 0614','Activo','2025-06-25 11:22:14',NULL),('ef79b4f0-51e8-11f0-9f2b-00155d276843','ef11b901-51e8-11f0-9f2b-00155d276843','chris.escobar932','chris.escobar932@ejemplo.com','a87ae4a6','+52 247 358 0097','Activo','2025-06-25 11:22:14',NULL),('ef79d974-51e8-11f0-9f2b-00155d276843','ef125a98-51e8-11f0-9f2b-00155d276843','maría.castillo141','maría.castillo141@ejemplo.com','e36f7124','+52 442 789 3729','Activo','2025-06-25 11:22:14',NULL),('ef79fd25-51e8-11f0-9f2b-00155d276843','ef12feb8-51e8-11f0-9f2b-00155d276843','andrés.gonzález989','andrés.gonzález989@ejemplo.com','1e96e13f','+52 241 756 1385','Activo','2025-06-25 11:22:14',NULL),('ef7a404e-51e8-11f0-9f2b-00155d276843','ef13be7a-51e8-11f0-9f2b-00155d276843','carlos.rodríguez188','carlos.rodríguez188@ejemplo.com','9b8af7f0','+52 623 416 3235','Activo','2025-06-25 11:22:14',NULL),('ef7abc5c-51e8-11f0-9f2b-00155d276843','ef14680c-51e8-11f0-9f2b-00155d276843','eduardo.sánchez668','eduardo.sánchez668@ejemplo.com','1dcc7267','+52 442 551 7773','Activo','2025-06-25 11:22:14',NULL),('ef7b14b4-51e8-11f0-9f2b-00155d276843','ef14fe31-51e8-11f0-9f2b-00155d276843','juan.gonzález810','juan.gonzález810@ejemplo.com','9364e140','+52 624 537 4288','Activo','2025-06-25 11:22:14',NULL),('ef7ba9a5-51e8-11f0-9f2b-00155d276843','ef15aa40-51e8-11f0-9f2b-00155d276843','casey.aguilar498','casey.aguilar498@ejemplo.com','8c6106ed','+52 983 644 1322','Activo','2025-06-25 11:22:14',NULL),('ef7bdc78-51e8-11f0-9f2b-00155d276843','ef164345-51e8-11f0-9f2b-00155d276843','sky.domínguez231','sky.domínguez231@ejemplo.com','0892b352','+52 81 4056 3576','Activo','2025-06-25 11:22:14',NULL),('ef7c0bea-51e8-11f0-9f2b-00155d276843','ef16e091-51e8-11f0-9f2b-00155d276843','maría.morales410','maría.morales410@ejemplo.com','8b0b3c54','+52 732 958 3641','Activo','2025-06-25 11:22:14',NULL),('ef7c3881-51e8-11f0-9f2b-00155d276843','ef17941c-51e8-11f0-9f2b-00155d276843','carlos.hernández375','carlos.hernández375@ejemplo.com','fa0a4f1c','+52 745 862 4188','Activo','2025-06-25 11:22:14',NULL),('ef7c6aca-51e8-11f0-9f2b-00155d276843','ef18656b-51e8-11f0-9f2b-00155d276843','maría.torres290','maría.torres290@ejemplo.com','ddf05825','+52 998 182 1641','Activo','2025-06-25 11:22:14',NULL),('ef7cd69c-51e8-11f0-9f2b-00155d276843','ef191157-51e8-11f0-9f2b-00155d276843','alejandro.ramírez778','alejandro.ramírez778@ejemplo.com','d8c336df','+52 831 626 3806','Activo','2025-06-25 11:22:14',NULL),('ef7d0da9-51e8-11f0-9f2b-00155d276843','ef19d52e-51e8-11f0-9f2b-00155d276843','camila.navarro596','camila.navarro596@ejemplo.com','9186f3ce','+52 482 093 2703','Activo','2025-06-25 11:22:14',NULL),('ef7d43c7-51e8-11f0-9f2b-00155d276843','ef1aae5b-51e8-11f0-9f2b-00155d276843','miguel.lópez302','miguel.lópez302@ejemplo.com','0241dedf','+52 81 2549 1272','Activo','2025-06-25 11:22:14',NULL),('ef7d7ea6-51e8-11f0-9f2b-00155d276843','ef1b3fc3-51e8-11f0-9f2b-00155d276843','andrea.navarro637','andrea.navarro637@ejemplo.com','f24428db','+52 728 880 1716','Activo','2025-06-25 11:22:14',NULL),('ef7e18aa-51e8-11f0-9f2b-00155d276843','ef1c05f5-51e8-11f0-9f2b-00155d276843','jordan.silva529','jordan.silva529@ejemplo.com','f4b0f703','+52 722 250 9599','Activo','2025-06-25 11:22:14',NULL),('ef7e3f91-51e8-11f0-9f2b-00155d276843','ef1c9115-51e8-11f0-9f2b-00155d276843','andrea.gutiérrez425','andrea.gutiérrez425@ejemplo.com','97e8fa74','+52 844 785 3598','Activo','2025-06-25 11:22:14',NULL),('ef7ea0d4-51e8-11f0-9f2b-00155d276843','ef1d41c2-51e8-11f0-9f2b-00155d276843','ricardo.pérez421','ricardo.pérez421@ejemplo.com','e39cd1b1','+52 612 050 6979','Activo','2025-06-25 11:22:14',NULL),('ef7ed0df-51e8-11f0-9f2b-00155d276843','ef1db9d6-51e8-11f0-9f2b-00155d276843','valeria.jiménez148','valeria.jiménez148@ejemplo.com','82af8065','+52 312 775 2538','Activo','2025-06-25 11:22:14',NULL),('ef7f3f12-51e8-11f0-9f2b-00155d276843','ef1e60d7-51e8-11f0-9f2b-00155d276843','juan.hernández639','juan.hernández639@ejemplo.com','c8889e57','+52 826 805 5310','Activo','2025-06-25 11:22:14',NULL),('ef7f8c49-51e8-11f0-9f2b-00155d276843','ef1ee00a-51e8-11f0-9f2b-00155d276843','valeria.reyes399','valeria.reyes399@ejemplo.com','1f4ea6c6','+52 618 501 5870','Activo','2025-06-25 11:22:14',NULL),('ef801085-51e8-11f0-9f2b-00155d276843','ef1f78b2-51e8-11f0-9f2b-00155d276843','alejandro.cruz781','alejandro.cruz781@ejemplo.com','0b3b7508','+52 966 796 3405','Activo','2025-06-25 11:22:14',NULL),('ef803cf5-51e8-11f0-9f2b-00155d276843','ef20029d-51e8-11f0-9f2b-00155d276843','luis.martínez640','luis.martínez640@ejemplo.com','1c20f2c9','+52 674 516 2544','Activo','2025-06-25 11:22:14',NULL),('ef806322-51e8-11f0-9f2b-00155d276843','ef20d16c-51e8-11f0-9f2b-00155d276843','eduardo.rodríguez788','eduardo.rodríguez788@ejemplo.com','0fe08463','+52 624 571 7155','Activo','2025-06-25 11:22:14',NULL),('ef809028-51e8-11f0-9f2b-00155d276843','ef215512-51e8-11f0-9f2b-00155d276843','miguel.martínez659','miguel.martínez659@ejemplo.com','e6142e87','+52 981 281 8379','Activo','2025-06-25 11:22:14',NULL),('ef80d35c-51e8-11f0-9f2b-00155d276843','ef21fb8b-51e8-11f0-9f2b-00155d276843','fernanda.fernández222','fernanda.fernández222@ejemplo.com','4e4c4027','+52 668 361 4517','Activo','2025-06-25 11:22:14',NULL),('ef80f97d-51e8-11f0-9f2b-00155d276843','ef22d066-51e8-11f0-9f2b-00155d276843','eduardo.ramírez535','eduardo.ramírez535@ejemplo.com','e533a2a0','+52 313 149 1035','Activo','2025-06-25 11:22:14',NULL),('ef812025-51e8-11f0-9f2b-00155d276843','ef235faa-51e8-11f0-9f2b-00155d276843','sofía.ortega144','sofía.ortega144@ejemplo.com','feec2c0c','+52 914 864 9467','Activo','2025-06-25 11:22:14',NULL),('ef815d32-51e8-11f0-9f2b-00155d276843','ef23f327-51e8-11f0-9f2b-00155d276843','juan.rodríguez788','juan.rodríguez788@ejemplo.com','07bd779c','+52 831 599 3475','Activo','2025-06-25 11:22:14',NULL),('ef81880a-51e8-11f0-9f2b-00155d276843','ef247468-51e8-11f0-9f2b-00155d276843','taylor.rojas479','taylor.rojas479@ejemplo.com','62611a83','+52 55 5155 3863','Activo','2025-06-25 11:22:14',NULL),('ef81a77f-51e8-11f0-9f2b-00155d276843','ef250312-51e8-11f0-9f2b-00155d276843','dani.vega737','dani.vega737@ejemplo.com','4da5e279','+52 831 282 6077','Activo','2025-06-25 11:22:14',NULL),('ef81c731-51e8-11f0-9f2b-00155d276843','ef25a91c-51e8-11f0-9f2b-00155d276843','sam.mendoza865','sam.mendoza865@ejemplo.com','8b8df1a9','+52 353 175 8261','Activo','2025-06-25 11:22:14',NULL),('ef81e5c8-51e8-11f0-9f2b-00155d276843','ef26211c-51e8-11f0-9f2b-00155d276843','alex.escobar498','alex.escobar498@ejemplo.com','5e6c60ca','+52 981 417 1535','Activo','2025-06-25 11:22:14',NULL),('ef820523-51e8-11f0-9f2b-00155d276843','ef26cc10-51e8-11f0-9f2b-00155d276843','ricardo.hernández823','ricardo.hernández823@ejemplo.com','7e791a61','+52 315 841 7462','Activo','2025-06-25 11:22:14',NULL),('ef8221e5-51e8-11f0-9f2b-00155d276843','ef2785b1-51e8-11f0-9f2b-00155d276843','casey.escobar928','casey.escobar928@ejemplo.com','43580d03','+52 222 929 5425','Activo','2025-06-25 11:22:14',NULL),('ef823f19-51e8-11f0-9f2b-00155d276843','ef281aba-51e8-11f0-9f2b-00155d276843','alejandro.rodríguez772','alejandro.rodríguez772@ejemplo.com','ab44962e','+52 732 651 6591','Activo','2025-06-25 11:22:14',NULL),('ef8276f8-51e8-11f0-9f2b-00155d276843','ef28b382-51e8-11f0-9f2b-00155d276843','sky.vega784','sky.vega784@ejemplo.com','51fbf3d0','+52 271 226 1500','Activo','2025-06-25 11:22:14',NULL),('ef82a467-51e8-11f0-9f2b-00155d276843','ef294b3d-51e8-11f0-9f2b-00155d276843','alejandra.reyes343','alejandra.reyes343@ejemplo.com','4442c7ef','+52 826 785 0703','Activo','2025-06-25 11:22:14',NULL),('ef82cf49-51e8-11f0-9f2b-00155d276843','ef29fc6a-51e8-11f0-9f2b-00155d276843','andrés.pérez315','andrés.pérez315@ejemplo.com','997b7ca5','+52 732 960 9936','Activo','2025-06-25 11:22:14',NULL),('ef831ac6-51e8-11f0-9f2b-00155d276843','ef2a8a57-51e8-11f0-9f2b-00155d276843','lucía.torres379','lucía.torres379@ejemplo.com','df3a7b90','+52 773 030 1273','Activo','2025-06-25 11:22:14',NULL),('ef834739-51e8-11f0-9f2b-00155d276843','ef2b1b77-51e8-11f0-9f2b-00155d276843','robin.aguilar938','robin.aguilar938@ejemplo.com','0112b9b9','+52 646 493 1993','Activo','2025-06-25 11:22:14',NULL),('ef8395f6-51e8-11f0-9f2b-00155d276843','ef2ba795-51e8-11f0-9f2b-00155d276843','sam.silva415','sam.silva415@ejemplo.com','5873624b','+52 728 727 0790','Activo','2025-06-25 11:22:14',NULL),('ef83d457-51e8-11f0-9f2b-00155d276843','ef2c604b-51e8-11f0-9f2b-00155d276843','alejandro.martínez738','alejandro.martínez738@ejemplo.com','23d34223','+52 998 438 9838','Activo','2025-06-25 11:22:14',NULL),('ef83f6bf-51e8-11f0-9f2b-00155d276843','ef2d1265-51e8-11f0-9f2b-00155d276843','jordan.vega163','jordan.vega163@ejemplo.com','891b62a5','+52 999 678 0656','Activo','2025-06-25 11:22:14',NULL),('ef8419d3-51e8-11f0-9f2b-00155d276843','ef2dcf6e-51e8-11f0-9f2b-00155d276843','isabel.navarro571','isabel.navarro571@ejemplo.com','eb9c3748','+52 744 018 8455','Activo','2025-06-25 11:22:14',NULL),('ef843d29-51e8-11f0-9f2b-00155d276843','ef2e5b43-51e8-11f0-9f2b-00155d276843','juan.pérez126','juan.pérez126@ejemplo.com','60855a1d','+52 745 540 7155','Activo','2025-06-25 11:22:14',NULL),('ef846192-51e8-11f0-9f2b-00155d276843','ef2f10b2-51e8-11f0-9f2b-00155d276843','andrés.garcía655','andrés.garcía655@ejemplo.com','9ed6b45c','+52 352 938 9579','Activo','2025-06-25 11:22:14',NULL),('ef848f73-51e8-11f0-9f2b-00155d276843','ef2f8d1c-51e8-11f0-9f2b-00155d276843','robin.rojas367','robin.rojas367@ejemplo.com','7c31faf4','+52 351 264 6364','Activo','2025-06-25 11:22:14',NULL),('ef84b5f8-51e8-11f0-9f2b-00155d276843','ef30349b-51e8-11f0-9f2b-00155d276843','taylor.delgado963','taylor.delgado963@ejemplo.com','b9719266','+52 614 714 7248','Activo','2025-06-25 11:22:14',NULL),('ef84dd0c-51e8-11f0-9f2b-00155d276843','ef30c12a-51e8-11f0-9f2b-00155d276843','sofía.reyes222','sofía.reyes222@ejemplo.com','068ad6b1','+52 671 715 0657','Activo','2025-06-25 11:22:14',NULL),('ef85090b-51e8-11f0-9f2b-00155d276843','ef31911d-51e8-11f0-9f2b-00155d276843','javier.pérez806','javier.pérez806@ejemplo.com','23883897','+52 324 374 8537','Activo','2025-06-25 11:22:14',NULL),('ef852e3a-51e8-11f0-9f2b-00155d276843','ef3357f1-51e8-11f0-9f2b-00155d276843','alex.mendoza321','alex.mendoza321@ejemplo.com','83c69439','+52 621 654 5288','Activo','2025-06-25 11:22:14',NULL),('ef85b565-51e8-11f0-9f2b-00155d276843','ef342f41-51e8-11f0-9f2b-00155d276843','robin.medina899','robin.medina899@ejemplo.com','1b15bf23','+52 998 140 2409','Activo','2025-06-25 11:22:14',NULL),('ef85efcc-51e8-11f0-9f2b-00155d276843','ef34d458-51e8-11f0-9f2b-00155d276843','jordan.rojas605','jordan.rojas605@ejemplo.com','6242c619','+52 618 085 8046','Activo','2025-06-25 11:22:14',NULL),('ef864b44-51e8-11f0-9f2b-00155d276843','ef3560c5-51e8-11f0-9f2b-00155d276843','camila.morales713','camila.morales713@ejemplo.com','8c56767f','+52 984 071 4942','Activo','2025-06-25 11:22:14',NULL),('ef86744c-51e8-11f0-9f2b-00155d276843','ef36035b-51e8-11f0-9f2b-00155d276843','juan.gonzález320','juan.gonzález320@ejemplo.com','0be19973','+52 412 572 3750','Activo','2025-06-25 11:22:14',NULL),('ef8695a4-51e8-11f0-9f2b-00155d276843','ef36b6eb-51e8-11f0-9f2b-00155d276843','alejandra.gutiérrez908','alejandra.gutiérrez908@ejemplo.com','558ee592','+52 55 5336 2317','Activo','2025-06-25 11:22:14',NULL),('ef86b4b7-51e8-11f0-9f2b-00155d276843','ef3746b6-51e8-11f0-9f2b-00155d276843','jordan.silva241','jordan.silva241@ejemplo.com','95dae984','+52 317 670 3744','Activo','2025-06-25 11:22:14',NULL),('ef86da9c-51e8-11f0-9f2b-00155d276843','ef37ed4e-51e8-11f0-9f2b-00155d276843','isabel.vargas118','isabel.vargas118@ejemplo.com','f7825e93','+52 772 714 9705','Activo','2025-06-25 11:22:14',NULL),('ef86fccd-51e8-11f0-9f2b-00155d276843','ef386cd2-51e8-11f0-9f2b-00155d276843','camila.navarro442','camila.navarro442@ejemplo.com','b5378974','+52 223 934 5873','Activo','2025-06-25 11:22:14',NULL),('ef87b11b-51e8-11f0-9f2b-00155d276843','ef390f44-51e8-11f0-9f2b-00155d276843','andrés.ramírez775','andrés.ramírez775@ejemplo.com','5416e97f','+52 732 650 8584','Activo','2025-06-25 11:22:14',NULL),('ef87dbb3-51e8-11f0-9f2b-00155d276843','ef3990b7-51e8-11f0-9f2b-00155d276843','luis.pérez777','luis.pérez777@ejemplo.com','ba96a52e','+52 621 542 8754','Activo','2025-06-25 11:22:14',NULL),('ef87fdba-51e8-11f0-9f2b-00155d276843','ef3a2690-51e8-11f0-9f2b-00155d276843','javier.sánchez396','javier.sánchez396@ejemplo.com','49d56395','+52 961 486 7374','Activo','2025-06-25 11:22:14',NULL),('ef881f4e-51e8-11f0-9f2b-00155d276843','ef3ad2ef-51e8-11f0-9f2b-00155d276843','alejandro.gonzález195','alejandro.gonzález195@ejemplo.com','a9659548','+52 646 978 0531','Activo','2025-06-25 11:22:14',NULL),('ef88667f-51e8-11f0-9f2b-00155d276843','ef3b5b48-51e8-11f0-9f2b-00155d276843','alejandro.cruz797','alejandro.cruz797@ejemplo.com','bde9ed76','+52 747 046 5130','Activo','2025-06-25 11:22:14',NULL),('ef889a78-51e8-11f0-9f2b-00155d276843','ef3bda30-51e8-11f0-9f2b-00155d276843','morgan.rojas202','morgan.rojas202@ejemplo.com','2491f61f','+52 622 731 6916','Activo','2025-06-25 11:22:14',NULL),('ef88bb86-51e8-11f0-9f2b-00155d276843','ef3c5d92-51e8-11f0-9f2b-00155d276843','juan.ramírez322','juan.ramírez322@ejemplo.com','3b79601e','+52 352 202 6954','Activo','2025-06-25 11:22:14',NULL),('ef88d9ae-51e8-11f0-9f2b-00155d276843','ef3d5f33-51e8-11f0-9f2b-00155d276843','lucía.vargas655','lucía.vargas655@ejemplo.com','439f4448','+52 319 257 5298','Activo','2025-06-25 11:22:14',NULL),('ef88fca0-51e8-11f0-9f2b-00155d276843','ef3de08d-51e8-11f0-9f2b-00155d276843','alex.silva705','alex.silva705@ejemplo.com','a08d44a4','+52 229 914 3997','Activo','2025-06-25 11:22:14',NULL),('ef891d12-51e8-11f0-9f2b-00155d276843','ef3e6e20-51e8-11f0-9f2b-00155d276843','lucía.navarro783','lucía.navarro783@ejemplo.com','e7fac3a8','+52 997 779 1955','Activo','2025-06-25 11:22:14',NULL),('ef893f57-51e8-11f0-9f2b-00155d276843','ef3ef5ad-51e8-11f0-9f2b-00155d276843','sky.domínguez939','sky.domínguez939@ejemplo.com','df127fbf','+52 913 197 7139','Activo','2025-06-25 11:22:14',NULL),('ef896038-51e8-11f0-9f2b-00155d276843','ef3faa54-51e8-11f0-9f2b-00155d276843','isabel.ortega533','isabel.ortega533@ejemplo.com','37c4e48c','+52 221 701 0373','Activo','2025-06-25 11:22:14',NULL),('ef898434-51e8-11f0-9f2b-00155d276843','ef402e1c-51e8-11f0-9f2b-00155d276843','maría.reyes656','maría.reyes656@ejemplo.com','8aaa1d82','+52 624 441 0057','Activo','2025-06-25 11:22:14',NULL),('ef89a694-51e8-11f0-9f2b-00155d276843','ef40bbcc-51e8-11f0-9f2b-00155d276843','taylor.medina967','taylor.medina967@ejemplo.com','7e9ba19a','+52 951 480 9457','Activo','2025-06-25 11:22:14',NULL),('ef89c842-51e8-11f0-9f2b-00155d276843','ef415602-51e8-11f0-9f2b-00155d276843','jordan.escobar658','jordan.escobar658@ejemplo.com','443a998b','+52 317 242 9224','Activo','2025-06-25 11:22:14',NULL),('ef89f0f2-51e8-11f0-9f2b-00155d276843','ef41da14-51e8-11f0-9f2b-00155d276843','morgan.rojas890','morgan.rojas890@ejemplo.com','4d970f31','+52 441 365 7945','Activo','2025-06-25 11:22:14',NULL),('ef8a1a63-51e8-11f0-9f2b-00155d276843','ef425d5f-51e8-11f0-9f2b-00155d276843','eduardo.hernández838','eduardo.hernández838@ejemplo.com','3c49b49f','+52 81 7908 1874','Activo','2025-06-25 11:22:14',NULL),('ef8a43a4-51e8-11f0-9f2b-00155d276843','ef42eae1-51e8-11f0-9f2b-00155d276843','juan.pérez344','juan.pérez344@ejemplo.com','432c0d6a','+52 962 621 4800','Activo','2025-06-25 11:22:14',NULL),('ef8a6fdf-51e8-11f0-9f2b-00155d276843','ef438ae0-51e8-11f0-9f2b-00155d276843','gabriela.torres783','gabriela.torres783@ejemplo.com','b21bfd90','+52 747 111 3331','Activo','2025-06-25 11:22:14',NULL),('ef8b60a6-51e8-11f0-9f2b-00155d276843','ef441ece-51e8-11f0-9f2b-00155d276843','ricardo.pérez471','ricardo.pérez471@ejemplo.com','bb7d9026','+52 773 847 3920','Activo','2025-06-25 11:22:14',NULL),('ef8bc8b5-51e8-11f0-9f2b-00155d276843','ef44a2e0-51e8-11f0-9f2b-00155d276843','robin.escobar114','robin.escobar114@ejemplo.com','66d16a0b','+52 223 637 5083','Activo','2025-06-25 11:22:14',NULL),('ef8bf4fa-51e8-11f0-9f2b-00155d276843','ef4546af-51e8-11f0-9f2b-00155d276843','ricardo.pérez309','ricardo.pérez309@ejemplo.com','990b8fb0','+52 81 0266 0930','Activo','2025-06-25 11:22:14',NULL),('ef8c25a9-51e8-11f0-9f2b-00155d276843','ef45f992-51e8-11f0-9f2b-00155d276843','robin.vega519','robin.vega519@ejemplo.com','7301873f','+52 914 488 8227','Activo','2025-06-25 11:22:14',NULL),('ef8c573a-51e8-11f0-9f2b-00155d276843','ef4688bc-51e8-11f0-9f2b-00155d276843','jordan.delgado912','jordan.delgado912@ejemplo.com','a9801e81','+52 319 510 8653','Activo','2025-06-25 11:22:14',NULL),('ef8c8b8f-51e8-11f0-9f2b-00155d276843','ef4717e1-51e8-11f0-9f2b-00155d276843','eduardo.hernández965','eduardo.hernández965@ejemplo.com','2740f688','+52 731 632 1813','Activo','2025-06-25 11:22:14',NULL),('ef8cbf60-51e8-11f0-9f2b-00155d276843','ef47a397-51e8-11f0-9f2b-00155d276843','miguel.gonzález717','miguel.gonzález717@ejemplo.com','c04383b8','+52 954 458 1240','Activo','2025-06-25 11:22:14',NULL),('ef8d4097-51e8-11f0-9f2b-00155d276843','ef484f3b-51e8-11f0-9f2b-00155d276843','andrea.reyes508','andrea.reyes508@ejemplo.com','04ca4e78','+52 966 929 8551','Activo','2025-06-25 11:22:14',NULL),('ef8dc2c5-51e8-11f0-9f2b-00155d276843','ef48f9de-51e8-11f0-9f2b-00155d276843','luis.hernández348','luis.hernández348@ejemplo.com','e4ac4134','+52 962 832 2698','Activo','2025-06-25 11:22:14',NULL),('ef8e2c9f-51e8-11f0-9f2b-00155d276843','ef498728-51e8-11f0-9f2b-00155d276843','fernanda.fernández820','fernanda.fernández820@ejemplo.com','1b56c585','+52 966 150 2859','Activo','2025-06-25 11:22:14',NULL),('ef8eb79e-51e8-11f0-9f2b-00155d276843','ef4a14d9-51e8-11f0-9f2b-00155d276843','andrés.gonzález413','andrés.gonzález413@ejemplo.com','6b765b89','+52 772 134 2376','Activo','2025-06-25 11:22:14',NULL),('ef8ee475-51e8-11f0-9f2b-00155d276843','ef4ab2fa-51e8-11f0-9f2b-00155d276843','sam.medina523','sam.medina523@ejemplo.com','5f8d0910','+52 414 870 3471','Activo','2025-06-25 11:22:14',NULL),('ef8f09a0-51e8-11f0-9f2b-00155d276843','ef4b4650-51e8-11f0-9f2b-00155d276843','ricardo.sánchez385','ricardo.sánchez385@ejemplo.com','bc854c01','+52 247 655 8472','Activo','2025-06-25 11:22:14',NULL),('ef900100-51e8-11f0-9f2b-00155d276843','ef4bcac0-51e8-11f0-9f2b-00155d276843','juan.gonzález580','juan.gonzález580@ejemplo.com','e2619005','+52 247 457 4998','Activo','2025-06-25 11:22:14',NULL),('ef903c77-51e8-11f0-9f2b-00155d276843','ef4c508a-51e8-11f0-9f2b-00155d276843','gabriela.fernández592','gabriela.fernández592@ejemplo.com','e6ecbfbf','+52 55 7988 1640','Activo','2025-06-25 11:22:14',NULL),('ef907b15-51e8-11f0-9f2b-00155d276843','ef4cebd1-51e8-11f0-9f2b-00155d276843','javier.gonzález513','javier.gonzález513@ejemplo.com','8597c138','+52 966 936 5497','Activo','2025-06-25 11:22:14',NULL),('ef90bb2f-51e8-11f0-9f2b-00155d276843','ef4d8ffe-51e8-11f0-9f2b-00155d276843','eduardo.ramírez368','eduardo.ramírez368@ejemplo.com','f3c5f803','+52 733 532 4403','Activo','2025-06-25 11:22:14',NULL),('ef90f9a8-51e8-11f0-9f2b-00155d276843','ef4e1734-51e8-11f0-9f2b-00155d276843','luis.rodríguez203','luis.rodríguez203@ejemplo.com','7fb69049','+52 324 766 5024','Activo','2025-06-25 11:22:14',NULL),('ef913676-51e8-11f0-9f2b-00155d276843','ef4e9c63-51e8-11f0-9f2b-00155d276843','maría.morales292','maría.morales292@ejemplo.com','21963ee5','+52 312 782 6810','Activo','2025-06-25 11:22:14',NULL);
/*!40000 ALTER TABLE `tbb_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbb_valoraciones_medicas`
--

DROP TABLE IF EXISTS `tbb_valoraciones_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbb_valoraciones_medicas` (
  `id` int NOT NULL,
  `paciente_id` int DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `antecedentes_personales` text,
  `antecedentes_familiares` text,
  `antecedentes_medicos` text,
  `sintomas_signos` text,
  `examen_fisico` text,
  `pruebas_diagnosticas` text,
  `diagnostico` text,
  `plan_tratamiento` text,
  `seguimiento` text,
  `fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbb_valoraciones_medicas`
--

LOCK TABLES `tbb_valoraciones_medicas` WRITE;
/*!40000 ALTER TABLE `tbb_valoraciones_medicas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbb_valoraciones_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_AFTER_INSERT` AFTER INSERT ON `tbb_valoraciones_medicas` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (
        id,
        usuario,
        operacion,
        tabla,
        descripcion
    ) VALUES (
        default,
        current_user(),
        'Create',
        'tbb_valoraciones_medicas',
        concat_ws('', 
            'Se ha registrado una nueva valoracion medica con los siguientes datos:', 
            'Id: ', NEW.id,'\n',
            'Paciente: ', NEW.paciente_id,'\n',
            'Fecha: ', NEW.fecha,'\n',
            'Antecedentes Personales: ', NEW.antecedentes_personales,'\n',
            'Antecedentes Familiares: ', NEW.antecedentes_familiares,'\n',
            'Antecedentes Medicos: ', NEW.antecedentes_medicos,'\n',
            'Sintomas y Signos: ', NEW.sintomas_signos,'\n',
            'Examen Fisico: ', NEW.examen_fisico,'\n',
            'Pruebas Diagnosticas: ', NEW.pruebas_diagnosticas,'\n',
            'Diagnostico: ', NEW.diagnostico,'\n',
            'Plan de Tratamiento: ', NEW.plan_tratamiento,'\n',
            'Seguimiento: ', NEW.seguimiento)
            
            
            
            
            
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbb_valoraciones_medicas` FOR EACH ROW SET new.fecha_actualizacion = current_timestamp() */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbb_valoraciones_medicas` FOR EACH ROW BEGIN

    INSERT INTO tbi_bitacora (
        id,
        usuario,
        operacion,
        tabla,
        descripcion
    ) VALUES (
        default,
        current_user(),
        'update',
        'tbb_valoraciones_medicas',
        concat_ws('', 
            'Se ha modificado al usuario con ID: ',old.id, "con los 
        siguientes datos \n",
			'Paciente: ', OLD.paciente_id, ' -> ', NEW.paciente_id, '\n',
            'Fecha: ', OLD.fecha, ' -> ', NEW.fecha, '\n',
            'Antecedentes Personales: ', OLD.antecedentes_personales, ' -> ', NEW.antecedentes_personales, '\n',
            'Antecedentes Familiares: ', OLD.antecedentes_familiares, ' -> ', NEW.antecedentes_familiares, '\n',
            'Antecedentes Medicos: ', OLD.antecedentes_medicos, ' -> ', NEW.antecedentes_medicos, '\n',
            'Sintomas y Signos: ', OLD.sintomas_signos, ' -> ', NEW.sintomas_signos, '\n',
            'Examen Fisico: ', OLD.examen_fisico, ' -> ', NEW.examen_fisico, '\n',
            'Pruebas Diagnosticas: ', OLD.pruebas_diagnosticas, ' -> ', NEW.pruebas_diagnosticas, '\n',
            'Diagnostico: ', OLD.diagnostico, ' -> ', NEW.diagnostico, '\n',
            'Plan de Tratamiento: ', OLD.plan_tratamiento, ' -> ', NEW.plan_tratamiento, '\n',
            'Seguimiento: ', OLD.seguimiento, ' -> ', NEW.seguimiento)
            
            
            
            
            
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_valoraciones_medicas_AFTER_DELETE` AFTER DELETE ON `tbb_valoraciones_medicas` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (
        id,
        usuario,
        operacion,
        tabla,
        descripcion
    ) VALUES (
        default,
        current_user(),
        'Delete',
        'tbb_valoraciones_medicas',
        concat_ws('', 
            'Se ha eliminado una valoracion medica con los siguientes datos:', 
            'Id: ', old.id,'\n',
            'Paciente: ', old.paciente_id,'\n',
            'Fecha: ', old.fecha,'\n',
            'Antecedentes Personales: ', old.antecedentes_personales,'\n',
            'Antecedentes Familiares: ', old.antecedentes_familiares,'\n',
            'Antecedentes Medicos: ', old.antecedentes_medicos,'\n',
            'Sintomas y Signos: ', old.sintomas_signos,'\n',
            'Examen Fisico: ', old.examen_fisico,'\n',
            'Pruebas Diagnosticas: ', old.pruebas_diagnosticas,'\n',
            'Diagnostico: ', old.diagnostico,'\n',
            'Plan de Tratamiento: ', old.plan_tratamiento,'\n',
            'Seguimiento: ', old.seguimiento)
            
            
            
            
            
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_areas_medicas`
--

DROP TABLE IF EXISTS `tbc_areas_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_areas_medicas` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `nombre` varchar(150) NOT NULL,
  `abreviatura` varchar(20) NOT NULL,
  `descripcion` text,
  `estatus` enum('Activo','Inactivo') DEFAULT NULL,
  `fecha_registro` datetime NOT NULL,
  `fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_areas_medicas`
--

LOCK TABLES `tbc_areas_medicas` WRITE;
/*!40000 ALTER TABLE `tbc_areas_medicas` DISABLE KEYS */;
INSERT INTO `tbc_areas_medicas` VALUES ('7d67e532-0ff7-11f0-b70d-3c557613b8e0','Servicios Medicos','SM','Por definir','Activo','2025-04-02 13:20:08','2025-04-02 13:20:08'),('7d685e34-0ff7-11f0-b70d-3c557613b8e0','Servicios de Apoyo','SA','Por definir','Activo','2025-04-02 13:20:08','2025-04-02 13:20:08'),('7d68c571-0ff7-11f0-b70d-3c557613b8e0','Servicios Medico - Administrativos','SMA','Por definir','Activo','2025-04-02 13:20:08','2025-04-02 13:20:08'),('7d693e28-0ff7-11f0-b70d-3c557613b8e0','Servicios de Enfermeria','SE','Por definir','Activo','2025-04-02 13:20:08','2025-04-02 13:20:08'),('7d6993f0-0ff7-11f0-b70d-3c557613b8e0','Departamentos Administrativos','DA','Por definir','Activo','2025-04-02 13:20:08','2025-04-02 13:20:08');
/*!40000 ALTER TABLE `tbc_areas_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_areas_medicas_AFTER_INSERT` AFTER INSERT ON `tbc_areas_medicas` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (
        CURRENT_USER(),
        'Create',
        'tbc_areas_medicas',
        CONCAT('Se ha creado una nueva área médica con los siguientes datos:',
            '\nID: ', NEW.ID,
            '\nNombre: ', NEW.Nombre,
            '\nAbreviatura: ', NEW.abreviatura,
            '\nDescripción: ', NEW.Descripcion,
            '\nEstatus: ', NEW.Estatus,
            '\nFecha de Registro: ', NEW.Fecha_Registro),
            
        1,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_areas_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_areas_medicas` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_areas_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbc_areas_medicas` FOR EACH ROW BEGIN
   IF OLD.Nombre != NEW.Nombre OR OLD.Descripcion != NEW.Descripcion OR OLD.Estatus != NEW.Estatus THEN
        INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
        VALUES (
            CURRENT_USER(),
            'Update',
            'tbc_areas_medicas',
            CONCAT('Se ha actualizado un área médica. Detalles de la actualización:',
                '\nID: ', NEW.ID,
                '\nNombre Anterior: ', OLD.Nombre,
                '\nNuevo Nombre: ', NEW.Nombre,
                '\nNueva Abreviatura: ', NEW.abreviatura,
                '\nDescripción Anterior: ', OLD.Descripcion,
                '\nNueva Descripción: ', NEW.Descripcion,
                '\nEstatus Anterior: ', OLD.Estatus,
                '\nNuevo Estatus: ', NEW.Estatus,
                '\nFecha de Actualización: ', NOW()),
            1,
            NOW()
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_areas_medicas_AFTER_DELETE` AFTER DELETE ON `tbc_areas_medicas` FOR EACH ROW BEGIN
 INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro)
    VALUES (
        CURRENT_USER(),
        'Delete',
        'tbc_areas_medicas',
        CONCAT('Se ha eliminado un área médica. Detalles de la eliminación:',
            '\nID: ', OLD.ID,
            '\nNombre: ', OLD.Nombre,
            '\nAbreviatura: ', OLD.abreviatura,
            '\nDescripción: ', OLD.Descripcion,
            '\nEstatus: ', OLD.Estatus,
            '\nFecha de Registro: ', OLD.Fecha_Registro),
        1,
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_consumibles`
--

DROP TABLE IF EXISTS `tbc_consumibles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_consumibles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `departamento` varchar(50) NOT NULL,
  `cantidad_existencia` int NOT NULL,
  `detalle` text,
  `fecha_registro` datetime NOT NULL,
  `fecha_actualizacion` datetime NOT NULL,
  `estatus` bit(1) DEFAULT NULL,
  `observaciones` text,
  `espacio_medico` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_consumibles`
--

LOCK TABLES `tbc_consumibles` WRITE;
/*!40000 ALTER TABLE `tbc_consumibles` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_consumibles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_consumibles_AFTER_INSERT` AFTER INSERT ON `tbc_consumibles` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    IF NOT NEW.estatus THEN
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        USER(),
        "Create",
        "tbc_consumibles",
        CONCAT_WS(" ", "Se ha insertado un nuevo consumible con los siguientes datos:",
            "NOMBRE =", NEW.nombre,
            "DESCRIPCION =", NEW.descripcion,
            "TIPO =", NEW.tipo,
            "DEPARTAMENTO =", NEW.departamento,
            "CANTIDAD EXISTENCIA =", NEW.cantidad_existencia,
            "DETALLE =", NEW.detalle,
            "FECHA DE REGISTRO =", NEW.fecha_registro,
            "ESTATUS =", v_estatus),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_consumibles_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_consumibles` FOR EACH ROW BEGIN
SET NEW.fecha_actualizacion = CURRENT_TIMESTAMP();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_consumibles_AFTER_UPDATE` AFTER UPDATE ON `tbc_consumibles` FOR EACH ROW BEGIN
DECLARE v_estatus_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 'Activo';

    IF NOT OLD.estatus THEN
        SET v_estatus_old = "Inactivo";
    END IF;
    IF NOT NEW.estatus THEN
        SET v_estatus_new = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbc_consumibles',
        CONCAT_WS(" ", "Se ha modificado un consumible existente con los siguientes datos:",
            "NOMBRE =", OLD.nombre, ' - ', NEW.nombre,
            "DESCRIPCION =", OLD.descripcion, ' - ', NEW.descripcion,
            "TIPO =", OLD.tipo, ' - ', NEW.tipo,
            "DEPARTAMENTO =", OLD.departamento, ' - ', NEW.departamento,
            "CANTIDAD EXISTENCIA =", OLD.cantidad_existencia, ' - ', NEW.cantidad_existencia,
            "DETALLE =", OLD.detalle, ' - ', NEW.detalle,
            "FECHA DE REGISTRO =", OLD.fecha_registro, ' - ', NEW.fecha_registro,
            "ESTATUS =", v_estatus_old, ' - ', v_estatus_new),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_consumibles_BEFORE_DELETE` BEFORE DELETE ON `tbc_consumibles` FOR EACH ROW BEGIN
  DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    IF NOT OLD.estatus THEN
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbc_consumibles',
        CONCAT_WS(" ", "Se ha eliminado un consumible con los siguientes datos:",
            "NOMBRE =", OLD.nombre,
            "DESCRIPCION =", OLD.descripcion,
            "TIPO =", OLD.tipo,
            "DEPARTAMENTO =", OLD.departamento,
            "CANTIDAD EXISTENCIA =", OLD.cantidad_existencia,
            "DETALLE =", OLD.detalle,
            "FECHA DE REGISTRO =", OLD.fecha_registro,
            "ESTATUS =", v_estatus),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_consumibles_AFTER_DELETE` AFTER DELETE ON `tbc_consumibles` FOR EACH ROW BEGIN


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_departamentos`
--

DROP TABLE IF EXISTS `tbc_departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_departamentos` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `nombre` varchar(100) NOT NULL,
  `area_medica_id` char(36) DEFAULT NULL,
  `departamento_superior_id` char(36) DEFAULT NULL,
  `responsable_id` char(36) DEFAULT NULL,
  `estatus` tinyint(1) NOT NULL,
  `fecha_registro` datetime NOT NULL,
  `fecha_actualizacion` datetime DEFAULT NULL,
  `abreviatura` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `area_medica_id` (`area_medica_id`),
  KEY `departamento_superior_id` (`departamento_superior_id`),
  KEY `responsable_id` (`responsable_id`),
  CONSTRAINT `fk_departamentos_perosnal_medico` FOREIGN KEY (`responsable_id`) REFERENCES `tbb_personal_medico` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tbc_departamentos_ibfk_1` FOREIGN KEY (`area_medica_id`) REFERENCES `tbc_areas_medicas` (`id`),
  CONSTRAINT `tbc_departamentos_ibfk_2` FOREIGN KEY (`departamento_superior_id`) REFERENCES `tbc_departamentos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_departamentos`
--

LOCK TABLES `tbc_departamentos` WRITE;
/*!40000 ALTER TABLE `tbc_departamentos` DISABLE KEYS */;
INSERT INTO `tbc_departamentos` VALUES ('7fe02f2d-0ff7-11f0-b70d-3c557613b8e0','Dirección General','7d68c571-0ff7-11f0-b70d-3c557613b8e0',NULL,NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DG'),('7fe03142-0ff7-11f0-b70d-3c557613b8e0','Junta de Gobierno','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','JG'),('7fe0321f-0ff7-11f0-b70d-3c557613b8e0','Departamento de Calidad','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DC'),('7fe032d6-0ff7-11f0-b70d-3c557613b8e0','Comité de Transplante','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CT'),('7fe03356-0ff7-11f0-b70d-3c557613b8e0','Sub-Dirección Médica','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SM'),('7fe033bb-0ff7-11f0-b70d-3c557613b8e0','Sub-Dirección Administrativa','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SA'),('7fe0343c-0ff7-11f0-b70d-3c557613b8e0','Comités Hospitalarios','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CH'),('7fe034de-0ff7-11f0-b70d-3c557613b8e0','Atención a Quejas','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','AQ'),('7fe03587-0ff7-11f0-b70d-3c557613b8e0','Seguridad del Paciente','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SP'),('7fe03624-0ff7-11f0-b70d-3c557613b8e0','Comunicación Social','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CS'),('7fe036c5-0ff7-11f0-b70d-3c557613b8e0','Relaciones Públicas','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RP'),('7fe0374b-0ff7-11f0-b70d-3c557613b8e0','Coordinación de Asuntos Jurídicos y Administrativos','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CAJAA'),('7fe037c6-0ff7-11f0-b70d-3c557613b8e0','Violencia Intrafamiliar','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','VI'),('7fe03860-0ff7-11f0-b70d-3c557613b8e0','Medicinal Legal','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','ML'),('7fe038fd-0ff7-11f0-b70d-3c557613b8e0','Trabajo Social','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','TS'),('7fe039a1-0ff7-11f0-b70d-3c557613b8e0','Unidad de Vigilancia Epidemiológica Hospitalaria','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','UVEH'),('7fe03a41-0ff7-11f0-b70d-3c557613b8e0','Centro de Investigación de Estudios de la Salud','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CIES'),('7fe03ae2-0ff7-11f0-b70d-3c557613b8e0','Ética e Investigación','7d68c571-0ff7-11f0-b70d-3c557613b8e0','7fe02f2d-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','EI'),('7fe03b7f-0ff7-11f0-b70d-3c557613b8e0','División de Medicina Interna','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DMI'),('7fe03bf0-0ff7-11f0-b70d-3c557613b8e0','División de Cirugía','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DCI'),('7fe03c5a-0ff7-11f0-b70d-3c557613b8e0','División de Pediatría','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DP'),('7fe03cc3-0ff7-11f0-b70d-3c557613b8e0','Servicio de Urgencias Adultos','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SUA'),('7fe03d0e-0ff7-11f0-b70d-3c557613b8e0','Servicio de Urgencias Pediátricas','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SUP'),('7fe03d4c-0ff7-11f0-b70d-3c557613b8e0','Terapia Intensiva','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','TI'),('7fe03d88-0ff7-11f0-b70d-3c557613b8e0','Terapia Intermedia','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','TIM'),('7fe03dc3-0ff7-11f0-b70d-3c557613b8e0','Quirófano y Anestesiología','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','QA'),('7fe03e00-0ff7-11f0-b70d-3c557613b8e0','Servicio de Traumatología','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','ST'),('7fe03e3d-0ff7-11f0-b70d-3c557613b8e0','Programación Quirúrgica','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','PQ'),('7fe03e78-0ff7-11f0-b70d-3c557613b8e0','Centro de Mezclas','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CM'),('7fe03eb5-0ff7-11f0-b70d-3c557613b8e0','Radiología e Imagen','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RI'),('7fe03ef2-0ff7-11f0-b70d-3c557613b8e0','Genética','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','G'),('7fe03f2f-0ff7-11f0-b70d-3c557613b8e0','Laboratorio de Análisis Clínicos','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','LAC'),('7fe03f6d-0ff7-11f0-b70d-3c557613b8e0','Laboratorio de Histocompatibilidad','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','LH'),('7fe03faa-0ff7-11f0-b70d-3c557613b8e0','Hemodialisis','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','H'),('7fe03fe7-0ff7-11f0-b70d-3c557613b8e0','Laboratorio de Patología','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','LP'),('7fe04023-0ff7-11f0-b70d-3c557613b8e0','Rehabilitación Pulmonar','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RPUL'),('7fe0405f-0ff7-11f0-b70d-3c557613b8e0','Medicina Genómica','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','MG'),('7fe0409b-0ff7-11f0-b70d-3c557613b8e0','Banco de Sangre','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','BS'),('7fe040d8-0ff7-11f0-b70d-3c557613b8e0','Aféresis','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','AF'),('7fe04114-0ff7-11f0-b70d-3c557613b8e0','Tele-Robótica','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','TR'),('7fe04150-0ff7-11f0-b70d-3c557613b8e0','Jefatura de Enseñanza Médica','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','JEM'),('7fe0418d-0ff7-11f0-b70d-3c557613b8e0','Consulta Externa','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CE'),('7fe041ca-0ff7-11f0-b70d-3c557613b8e0','Terapia y Rehabilitación Física','7d67e532-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','TRF'),('7fe04206-0ff7-11f0-b70d-3c557613b8e0','Jefatura de Enfermería','7d693e28-0ff7-11f0-b70d-3c557613b8e0','7fe03356-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','JE'),('7fe04275-0ff7-11f0-b70d-3c557613b8e0','Subjefatura de Enfermeras','7d693e28-0ff7-11f0-b70d-3c557613b8e0','7fe04206-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SE'),('7fe042e5-0ff7-11f0-b70d-3c557613b8e0','Coordinación Enseñanza Enfermería','7d693e28-0ff7-11f0-b70d-3c557613b8e0','7fe04206-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CEE'),('7fe04355-0ff7-11f0-b70d-3c557613b8e0','Supervisoras de Turno','7d693e28-0ff7-11f0-b70d-3c557613b8e0','7fe04206-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','STUR'),('7fe043c2-0ff7-11f0-b70d-3c557613b8e0','Jefas de Servicio','7d693e28-0ff7-11f0-b70d-3c557613b8e0','7fe04206-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','JS'),('7fe0442f-0ff7-11f0-b70d-3c557613b8e0','Clínicas y Programas','7d693e28-0ff7-11f0-b70d-3c557613b8e0','7fe04206-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CP'),('7fe0449e-0ff7-11f0-b70d-3c557613b8e0','Recursos Humanos','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RH'),('7fe04520-0ff7-11f0-b70d-3c557613b8e0','Archivo y Correspondencia','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','AC'),('7fe0459c-0ff7-11f0-b70d-3c557613b8e0','Recursos Financieros','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RF'),('7fe04617-0ff7-11f0-b70d-3c557613b8e0','Departamento Administrativo Hemodinamia','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DAH'),('7fe04692-0ff7-11f0-b70d-3c557613b8e0','Farmacia del Seguro Popular','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','FSP'),('7fe0470d-0ff7-11f0-b70d-3c557613b8e0','Enlace Administrativo','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','EA'),('7fe04789-0ff7-11f0-b70d-3c557613b8e0','Control de Gastos Catastróficos','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','CGC'),('7fe04804-0ff7-11f0-b70d-3c557613b8e0','Informática','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','INF'),('7fe04881-0ff7-11f0-b70d-3c557613b8e0','Tecnología en la Salud','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','TS'),('7fe048fc-0ff7-11f0-b70d-3c557613b8e0','Registros Médicos','7d6993f0-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RM'),('7fe04977-0ff7-11f0-b70d-3c557613b8e0','Biomédica Conservación y Mantenimiento','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','BCM'),('7fe049ca-0ff7-11f0-b70d-3c557613b8e0','Validación','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','VAL'),('7fe04a1a-0ff7-11f0-b70d-3c557613b8e0','Recursos Materiales','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','RMAT'),('7fe04a6a-0ff7-11f0-b70d-3c557613b8e0','Almacén','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','ALM'),('7fe04aba-0ff7-11f0-b70d-3c557613b8e0','Insumos Especializados','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','IE'),('7fe04b09-0ff7-11f0-b70d-3c557613b8e0','Servicios Generales','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','SG'),('7fe04b59-0ff7-11f0-b70d-3c557613b8e0','Intendencia','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','INT'),('7fe04ba9-0ff7-11f0-b70d-3c557613b8e0','Ropería','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','ROP'),('7fe04bf9-0ff7-11f0-b70d-3c557613b8e0','Vigilancia','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','VIG'),('7fe04c49-0ff7-11f0-b70d-3c557613b8e0','Dietética','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','DIE'),('7fe04c99-0ff7-11f0-b70d-3c557613b8e0','Farmacia Intrahospitalaria','7d685e34-0ff7-11f0-b70d-3c557613b8e0','7fe033bb-0ff7-11f0-b70d-3c557613b8e0',NULL,1,'2025-04-02 13:20:12','2025-04-02 13:20:12','FIH');
/*!40000 ALTER TABLE `tbc_departamentos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_departamentos_AFTER_INSERT` AFTER INSERT ON `tbc_departamentos` FOR EACH ROW BEGIN

    DECLARE descripcion_insert TEXT;

    SET descripcion_insert = CONCAT_WS('\n',
        CONCAT('Se ha agregado un nuevo DEPARTAMENTO con ID: ', NEW.id),
        CONCAT('Nombre: ', NEW.nombre),
        CONCAT('Área Médica ID: ', NEW.area_medica_id),
        CONCAT('Departamento Superior ID: ', NEW.departamento_superior_id),
        CONCAT('Responsable ID: ', NEW.responsable_id),
        CONCAT('Estatus: ', NEW.estatus),
        CONCAT('Abreviatura: ', NEW.abreviatura)
    );

    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Create',
        'tbc_departamentos',
        descripcion_insert,
        b'1',
        NOW()
    );


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_departamentos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_departamentos` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_departamentos_AFTER_UPDATE` AFTER UPDATE ON `tbc_departamentos` FOR EACH ROW BEGIN

    DECLARE descripcion_update TEXT;

    SET descripcion_update = CONCAT_WS('\n',
        CONCAT('Se ha ACTUALIZADO el DEPARTAMENTO con ID: ', OLD.id),
        CONCAT('Nombre: ', OLD.nombre, ' → ', NEW.nombre),
        CONCAT('Área Médica ID: ', OLD.area_medica_id, ' → ', NEW.area_medica_id),
        CONCAT('Departamento Superior ID: ', OLD.departamento_superior_id, ' → ', NEW.departamento_superior_id),
        CONCAT('Responsable ID: ', OLD.responsable_id, ' → ', NEW.responsable_id),
        CONCAT('Estatus: ', OLD.estatus, ' → ', NEW.estatus),
        CONCAT('Abreviatura: ', OLD.abreviatura, ' → ', NEW.abreviatura)
    );

    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Update',
        'tbc_departamentos',
        descripcion_update,
        b'1',
        NOW()
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_departamentos_AFTER_DELETE` AFTER DELETE ON `tbc_departamentos` FOR EACH ROW BEGIN

    DECLARE descripcion_delete TEXT;

    SET descripcion_delete = CONCAT_WS('\n',
        CONCAT('Se ha ELIMINADO el DEPARTAMENTO con ID: ', OLD.id),
        CONCAT('Nombre: ', OLD.nombre),
        CONCAT('Área Médica ID: ', OLD.area_medica_id),
        CONCAT('Departamento Superior ID: ', OLD.departamento_superior_id),
        CONCAT('Responsable ID: ', OLD.responsable_id),
        CONCAT('Estatus al eliminar: ', OLD.estatus),
        CONCAT('Abreviatura: ', OLD.abreviatura)
    );

    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro
    ) VALUES (
        DEFAULT,
        USER(),
        'Delete',
        'tbc_departamentos',
        descripcion_delete,
        b'1',
        NOW()
    );


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_espacios`
--

DROP TABLE IF EXISTS `tbc_espacios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_espacios` (
  `ID` char(36) NOT NULL DEFAULT (uuid()),
  `Tipo` enum('Piso','Consultorio','Laboratorio','Quirófano','Sala de Espera','Edificio','Estacionamiento','Habitación','Cama','Sala Maternidad','Cunero','Morgue','Oficina','Sala de Juntas','Auditorio','Cafeteria','Capilla','Farmacia','Ventanilla','Recepción') NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Departamento_ID` char(36) NOT NULL,
  `Estatus` enum('Activo','Inactivo','En remodelación','Clausurado','Reubicado','Temporal') NOT NULL DEFAULT 'Activo',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  `Capacidad` int NOT NULL DEFAULT '0',
  `Espacio_Superior_ID` char(36) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Nombre_UNIQUE` (`Nombre`),
  KEY `fk_departamentos_3_idx` (`Departamento_ID`),
  KEY `fk_espacios_1_idx` (`Espacio_Superior_ID`),
  CONSTRAINT `fk_espacios_departamento` FOREIGN KEY (`Departamento_ID`) REFERENCES `tbc_departamentos` (`id`),
  CONSTRAINT `fk_espacios_espacio_superior` FOREIGN KEY (`Espacio_Superior_ID`) REFERENCES `tbc_espacios` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_espacios`
--

LOCK TABLES `tbc_espacios` WRITE;
/*!40000 ALTER TABLE `tbc_espacios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_espacios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_espacios_AFTER_INSERT` AFTER INSERT ON `tbc_espacios` FOR EACH ROW BEGIN
 DECLARE v_estatus VARCHAR(20);
    DECLARE departamento_nombre VARCHAR(255);
    DECLARE espacio_superior_nombre VARCHAR(255);

   SET v_estatus = CASE 
                        WHEN NEW.Estatus = 'Activo' THEN 'Activo'
                        WHEN NEW.Estatus = 'Inactivo' THEN 'Inactivo'
                        WHEN NEW.Estatus = 'En remodelación' THEN 'En remodelación'
                        WHEN NEW.Estatus = 'Clausurado' THEN 'Clausurado'
                        WHEN NEW.Estatus = 'Reubicado' THEN 'Reubicado'
                        WHEN NEW.Estatus = 'Temporal' THEN 'Temporal'
                        ELSE 'Desconocido'
                    END;

    -- Obtener el nombre del departamento
    SET departamento_nombre = (SELECT Nombre FROM tbc_departamentos WHERE ID = NEW.Departamento_ID);
    
    -- Obtener el nombre del espacio superior
    SET espacio_superior_nombre = (SELECT Nombre FROM tbc_espacios WHERE ID = NEW.Espacio_superior_ID);

    -- Registrar la inserción del nuevo espacio en la bitácora
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (
        CURRENT_USER(), 
        'Create', 
        'tbc_espacios', 
        CONCAT_WS('\n',
            CONCAT('Se ha agregado un nuevo ESPACIO con el Nombre: ', NEW.Nombre),
            CONCAT('Tipo: ', NEW.Tipo),
            CONCAT('Departamento: ', IFNULL(departamento_nombre, 'Desconocido')),
            CONCAT('Estatus: ', v_estatus),
            CONCAT('Fecha de Registro: ', NEW.Fecha_Registro),
            CONCAT('Fecha de Actualización: ', IFNULL(NEW.Fecha_Actualizacion, 'NULL')),
            CONCAT('Capacidad: ', NEW.Capacidad),
            CONCAT('Espacio Superior: ', IFNULL(espacio_superior_nombre, 'Ninguno'))
        ),
        b'1', -- Estatus activo
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_espacios_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_espacios` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_espacios_AFTER_UPDATE` AFTER UPDATE ON `tbc_espacios` FOR EACH ROW BEGIN
   DECLARE v_estatus VARCHAR(20);
    DECLARE departamento_nombre VARCHAR(255);
    DECLARE espacio_superior_nombre VARCHAR(255);

    -- Asignar el valor de estatus
    SET v_estatus = CASE 
                        WHEN NEW.Estatus = 'Activo' THEN 'Activo'
                        WHEN NEW.Estatus = 'Inactivo' THEN 'Inactivo'
                        WHEN NEW.Estatus = 'En remodelación' THEN 'En remodelación'
                        WHEN NEW.Estatus = 'Clausurado' THEN 'Clausurado'
                        WHEN NEW.Estatus = 'Reubicado' THEN 'Reubicado'
                        WHEN NEW.Estatus = 'Temporal' THEN 'Temporal'
                        ELSE 'Desconocido'
                    END;

    -- Obtener el nombre del departamento
    SET departamento_nombre = (SELECT Nombre FROM tbc_departamentos WHERE ID = NEW.Departamento_ID);
    
    -- Obtener el nombre del espacio superior
    SET espacio_superior_nombre = (SELECT Nombre FROM tbc_espacios WHERE ID = NEW.Espacio_superior_ID);

    -- Registrar la actualización del espacio en la bitácora
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (
        CURRENT_USER(), 
        'Update', 
        'tbc_espacios', 
        CONCAT_WS('\n',
            CONCAT('Se ha actualizado un ESPACIO con el Nombre: ', NEW.Nombre),
            CONCAT('Tipo: ', NEW.Tipo),
            CONCAT('Departamento: ', IFNULL(departamento_nombre, 'Desconocido')),
            CONCAT('Estatus: ', v_estatus),
            CONCAT('Fecha de Registro: ', NEW.Fecha_Registro),
            CONCAT('Fecha de Actualización: ', IFNULL(NEW.Fecha_Actualizacion, 'NULL')),
            CONCAT('Capacidad: ', NEW.Capacidad),
            CONCAT('Espacio Superior: ', IFNULL(espacio_superior_nombre, 'Ninguno'))
        ),
        b'1', -- Estatus activo
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_espacios_AFTER_DELETE` AFTER DELETE ON `tbc_espacios` FOR EACH ROW BEGIN
 DECLARE v_estatus VARCHAR(20);
    DECLARE departamento_nombre VARCHAR(255);
    DECLARE espacio_superior_nombre VARCHAR(255);

    -- Asignar el valor de estatus
    SET v_estatus = CASE 
                        WHEN OLD.Estatus = 'Activo' THEN 'Activo'
                        WHEN OLD.Estatus = 'Inactivo' THEN 'Inactivo'
                        WHEN OLD.Estatus = 'En remodelación' THEN 'En remodelación'
                        WHEN OLD.Estatus = 'Clausurado' THEN 'Clausurado'
                        WHEN OLD.Estatus = 'Reubicado' THEN 'Reubicado'
                        WHEN OLD.Estatus = 'Temporal' THEN 'Temporal'
                        ELSE 'Desconocido'
                    END;

    -- Obtener el nombre del departamento
    SET departamento_nombre = (SELECT Nombre FROM tbc_departamentos WHERE ID = OLD.Departamento_ID);
    
    -- Obtener el nombre del espacio superior
    SET espacio_superior_nombre = (SELECT Nombre FROM tbc_espacios WHERE ID = OLD.Espacio_superior_ID);

    -- Registrar la eliminación del espacio en la bitácora
    INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (
        CURRENT_USER(), 
        'Delete', 
        'tbc_espacios', 
        CONCAT_WS('\n',
            CONCAT('Se ha eliminado un ESPACIO con el Nombre: ', OLD.Nombre),
            CONCAT('Tipo: ', OLD.Tipo),
            CONCAT('Departamento: ', IFNULL(departamento_nombre, 'Desconocido')),
            CONCAT('Estatus: ', v_estatus),
            CONCAT('Fecha de Registro: ', OLD.Fecha_Registro),
            CONCAT('Fecha de Actualización: ', IFNULL(OLD.Fecha_Actualizacion, 'NULL')),
            CONCAT('Capacidad: ', OLD.Capacidad),
            CONCAT('Espacio Superior: ', IFNULL(espacio_superior_nombre, 'Ninguno'))
        ),
        b'1', -- Estatus activo
        NOW()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_estudios`
--

DROP TABLE IF EXISTS `tbc_estudios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_estudios` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Tipo` varchar(50) NOT NULL,
  `Nivel_Urgencia` varchar(50) NOT NULL,
  `SolicitudID` int unsigned NOT NULL,
  `ConsumiblesID` int DEFAULT NULL,
  `Estatus` varchar(50) NOT NULL,
  `Total_Costo` decimal(10,2) NOT NULL,
  `Dirigido_A` varchar(100) DEFAULT NULL,
  `Observaciones` text,
  `Fecha_Registro` datetime NOT NULL,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  `ConsumibleID` int DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_estudios`
--

LOCK TABLES `tbc_estudios` WRITE;
/*!40000 ALTER TABLE `tbc_estudios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_estudios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_estudios_AFTER_INSERT` AFTER INSERT ON `tbc_estudios` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbb_estudios',
        CONCAT_WS(' ', 
            'Se ha creado un nuevo estudio médico con los siguientes datos:\n',
            'ID: ', NEW.ID, '\n',
            'Tipo: ', NEW.Tipo, '\n',
            'Estatus: ', NEW.Estatus, '\n',
            'Total Costo: ', NEW.Total_Costo, '\n',
            'Dirigido A: ', NEW.Dirigido_A, '\n',
            'Observaciones: ', NEW.Observaciones, '\n',
            'Nivel Urgencia: ', NEW.Nivel_Urgencia, '\n',
            'Fecha Registro: ', NEW.Fecha_Registro, '\n'),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbb_estudios_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_estudios` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_estudios_AFTER_UPDATE` AFTER UPDATE ON `tbc_estudios` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbb_estudios',
        CONCAT_WS('',
            'Se ha actualizado un estudio médico con los siguientes datos:\n',
            'ID: ', NEW.ID, '\n',
            'Tipo: ', NEW.Tipo, '\n',
            'Estatus: ', NEW.Estatus, '\n',
            'Total Costo: ', NEW.Total_Costo, '\n',
            'Dirigido A: ', NEW.Dirigido_A, '\n',
            'Observaciones: ', NEW.Observaciones, '\n',
            'Nivel Urgencia: ', NEW.Nivel_Urgencia, '\n',
            'Fecha Registro: ', NEW.Fecha_Registro, '\n',
            'Fecha Actualización: ', NEW.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_estudios_AFTER_DELETE` AFTER DELETE ON `tbc_estudios` FOR EACH ROW BEGIN
	INSERT INTO tbi_bitacora (
        ID,
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbb_estudios',
        CONCAT_WS('',
            'Se ha eliminado un estudio médico con los siguientes datos:\n',
            'ID: ', OLD.ID, '\n',
            'Tipo: ', OLD.Tipo, '\n',
            'Estatus: ', OLD.Estatus, '\n',
            'Total Costo: ', OLD.Total_Costo, '\n',
            'Dirigido A: ', OLD.Dirigido_A, '\n',
            'Observaciones: ', OLD.Observaciones, '\n',
            'Nivel Urgencia: ', OLD.Nivel_Urgencia, '\n',
            'Fecha Registro: ', OLD.Fecha_Registro, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_medicamentos`
--

DROP TABLE IF EXISTS `tbc_medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_medicamentos` (
  `ID` char(36) NOT NULL,
  `Nombre_comercial` varchar(80) NOT NULL,
  `Nombre_generico` varchar(80) NOT NULL,
  `Via_administracion` enum('Oral','Intravenoso','Rectal','Cutaneo','Subcutaneo','Oftalmica','Otica','Nasal','Topica','Parental') NOT NULL,
  `Presentacion` enum('Comprimidos','Grageas','Capsulas','Jarabes','Gotas','Solucion','Pomada','Jabon','Supositorios','Viales') NOT NULL,
  `Tipo` enum('Analgesicos','Antibioticos','Antidepresivos','Antihistaminicos','Antiinflamatorios','Antipsicoticos') NOT NULL,
  `Cantidad` int unsigned NOT NULL,
  `Volumen` decimal(10,2) NOT NULL,
  `Fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_medicamentos`
--

LOCK TABLES `tbc_medicamentos` WRITE;
/*!40000 ALTER TABLE `tbc_medicamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_medicamentos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_medicamentos_AFTER_INSERT` AFTER INSERT ON `tbc_medicamentos` FOR EACH ROW BEGIN
 INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbc_medicamentos',
        CONCAT_WS(' ', 
            'Se ha insertado un nuevo medicamento con ID:', NEW.ID,
            '\n Nombre Comercial:', NEW.Nombre_comercial,
            '\n Nombre Genérico:', NEW.Nombre_generico,
            '\n Vía de Administración:', NEW.Via_administracion,
            '\n Presentación:', NEW.Presentacion,
            '\n Tipo:', NEW.Tipo,
            '\n Cantidad:', NEW.Cantidad,
            '\n Volumen:', NEW.Volumen
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_medicamentos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_medicamentos` FOR EACH ROW BEGIN
	set new.Fecha_Actualizacion = current_time();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_medicamentos_AFTER_UPDATE` AFTER UPDATE ON `tbc_medicamentos` FOR EACH ROW BEGIN
   INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbc_medicamentos',
        CONCAT_WS(' ', 
            'Se ha actualizado el medicamento con ID:', OLD.ID,
            '\n Nombre Comercial:', OLD.Nombre_comercial, '-', NEW.Nombre_comercial,
            '\n Nombre Genérico:', OLD.Nombre_generico, '-', NEW.Nombre_generico,
            '\n Vía de Administración:', OLD.Via_administracion, '-', NEW.Via_administracion,
            '\n Presentación:', OLD.Presentacion, '-', NEW.Presentacion,
            '\n Tipo:', OLD.Tipo, '-', NEW.Tipo,
            '\n Cantidad:', OLD.Cantidad, '-', NEW.Cantidad,
            '\n Volumen:', OLD.Volumen, '-', NEW.Volumen
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_medicamentos_AFTER_DELETE` AFTER DELETE ON `tbc_medicamentos` FOR EACH ROW BEGIN
  INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbc_medicamentos',
        CONCAT_WS(' ', 
            'Se ha eliminado el medicamento con ID:', OLD.ID,
            '\n Nombre Comercial:', OLD.Nombre_comercial,
            '\n Nombre Genérico:', OLD.Nombre_generico
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_organos`
--

DROP TABLE IF EXISTS `tbc_organos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_organos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(45) NOT NULL,
  `Aparato_Sistema` varchar(50) NOT NULL,
  `Descripcion` text NOT NULL,
  `Detalle_Organo_ID` int unsigned NOT NULL,
  `Disponibilidad` varchar(45) NOT NULL,
  `Tipo` varchar(45) NOT NULL,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  `Fecha_Registro` datetime DEFAULT NULL,
  `Estatus` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Detalle_Organo_ID_UNIQUE` (`Detalle_Organo_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_organos`
--

LOCK TABLES `tbc_organos` WRITE;
/*!40000 ALTER TABLE `tbc_organos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_organos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_organos_AFTER_INSERT` AFTER INSERT ON `tbc_organos` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus para asignarle su valor textual 
    IF NOT NEW.Estatus THEN 
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora (ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (DEFAULT, CURRENT_USER(), 'Create','tbc_organos', CONCAT_WS(' ', 'Se ha registrado un nuevo órgano con los siguientes datos: ', 
                         ' Nombre: ', NEW.Nombre, 
                         ', Aparato Sistema: ', NEW.Aparato_Sistema, 
                         ', Descripcion: ', NEW.Descripcion, 
                         ', Disponibilidad: ', NEW.Disponibilidad, 
                         ', Tipo: ', NEW.Tipo, 
                         ', Estatus: ', v_estatus),
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_organos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_organos` FOR EACH ROW BEGIN
 SET NEW.Fecha_Actualizacion = CURRENT_TIMESTAMP();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_organos_AFTER_UPDATE` AFTER UPDATE ON `tbc_organos` FOR EACH ROW BEGIN
 DECLARE v_estatus_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus antiguo y nuevo para asignar sus valores textuales 
    IF NOT OLD.Estatus THEN 
        SET v_estatus_old = "Inactivo";
    END IF;

    IF NOT NEW.Estatus THEN 
        SET v_estatus_new = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora ( ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) 
    VALUES (DEFAULT, CURRENT_USER(),'Update','tbc_organos', CONCAT_WS(' ', 'Se ha actualizado un órgano con los siguientes datos:', 
                         ' Nombre Antiguo: ', OLD.Nombre, ', Nombre Nuevo: ', NEW.Nombre, 
                         ', Aparato Sistema Antiguo: ', OLD.Aparato_Sistema, ', Aparato Sistema Nuevo: ', NEW.Aparato_Sistema, 
                         ', Descripcion Antiguo: ', OLD.Descripcion, ', Descripcion Nuevo: ', NEW.Descripcion, 
                         ', Disponibilidad Antiguo: ', OLD.Disponibilidad, ', Disponibilidad Nuevo: ', NEW.Disponibilidad, 
                         ', Tipo Antiguo: ', OLD.Tipo, ', Tipo Nuevo: ', NEW.Tipo, 
                         ', Estatus Antiguo: ', v_estatus_old, ', Estatus Nuevo: ', v_estatus_new),
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_organos_AFTER_DELETE` AFTER DELETE ON `tbc_organos` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el estatus para asignarle su valor textual 
    IF NOT OLD.Estatus THEN 
        SET v_estatus = "Inactivo";
    END IF;

    INSERT INTO tbi_bitacora ( ID,  Usuario,   Operacion,   Tabla,   Descripcion,   Estatus,  Fecha_Registro ) VALUES ( DEFAULT,  CURRENT_USER(),
        'Delete',
        'tbc_organos',
        CONCAT_WS(' ', 'Se ha eliminado un órgano con los siguientes datos:', 
                         ' Nombre: ', OLD.Nombre, 
                         ', Aparato Sistema: ', OLD.Aparato_Sistema, 
                         ', Descripcion: ', OLD.Descripcion, 
                         ', Disponibilidad: ', OLD.Disponibilidad, 
                         ', Tipo: ', OLD.Tipo, 
                         ', Estatus: ', v_estatus),
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_puestos`
--

DROP TABLE IF EXISTS `tbc_puestos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_puestos` (
  `PuestoID` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Salario` decimal(10,2) DEFAULT NULL,
  `Turno` enum('Mañana','Tarde','Noche') DEFAULT NULL,
  `Creado` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Modificado` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`PuestoID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_puestos`
--

LOCK TABLES `tbc_puestos` WRITE;
/*!40000 ALTER TABLE `tbc_puestos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_puestos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbc_roles`
--

DROP TABLE IF EXISTS `tbc_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_roles` (
  `ID` char(36) NOT NULL DEFAULT (uuid()),
  `Nombre` varchar(50) NOT NULL,
  `Descripcion` text,
  `Estatus` tinyint NOT NULL DEFAULT '1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_roles`
--

LOCK TABLES `tbc_roles` WRITE;
/*!40000 ALTER TABLE `tbc_roles` DISABLE KEYS */;
INSERT INTO `tbc_roles` VALUES ('823b1a21-0ff7-11f0-b70d-3c557613b8e0','Administrador','Usuario Administrador del Sistema que permitirá modificar datos críticos',1,'2025-04-02 13:20:16','2025-04-02 13:20:16'),('823d3678-0ff7-11f0-b70d-3c557613b8e0','Direccion General','Usuario de la Máxima Autoridad del Hospital, que le permitirá acceder a módulos para el control y operación del servicio del Hospital',1,'2025-04-02 13:20:16',NULL),('823daf15-0ff7-11f0-b70d-3c557613b8e0','Paciente','Usuario que tendrá acceso a consultar la información médica asociada a su salud',1,'2025-04-02 13:20:16',NULL),('823e3ba2-0ff7-11f0-b70d-3c557613b8e0','Médico General','Usuario que tendrá acceso a consultar y modificar la información de salud de los pacientes y sus citas médicas',1,'2025-04-02 13:20:16',NULL),('823e94e2-0ff7-11f0-b70d-3c557613b8e0','Médico Especialista','Usuario que tendrá acceso a consultar y modificar la información de salud de los pacientes específicos a una especialidad médica',1,'2025-04-02 13:20:16',NULL),('823eed81-0ff7-11f0-b70d-3c557613b8e0','Enfermero','Usuario que apoya en la gestión y desarrollo de los servicios médicos proporcionados a los pacientes.',1,'2025-04-02 13:20:16',NULL),('823f4d24-0ff7-11f0-b70d-3c557613b8e0','Familiar del Paciente','Usuario que puede consultar y verificar la información de un paciente en caso de que no esté en capacidad o conciencia propia',0,'2025-04-02 13:20:16','2025-04-02 13:20:16'),('824032f7-0ff7-11f0-b70d-3c557613b8e0','Administrativo','Empleado que apoya en las actividades de cada departamento',1,'2025-04-02 13:20:16',NULL);
/*!40000 ALTER TABLE `tbc_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_AFTER_INSERT` AFTER INSERT ON `tbc_roles` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 1;
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT new.Estatus THEN
     SET v_estatus = 0;
	END IF;
    
    INSERT INTO tbi_bitacora VALUES(
		default, 
        current_user(), 
        'Create', 
        'tbc_roles', 
        CONCAT_WS(' ','Se ha agregado un nuevo rol de usuario con los siguientes datos:',
        'NOMBRE:',new.nombre, 'DESCRIPCION:', new.descripcion, 'ESTATUS:', v_estatus),
        DEFAULT, 
        DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_roles` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_AFTER_UPDATE` AFTER UPDATE ON `tbc_roles` FOR EACH ROW BEGIN
DECLARE v_estatus_old VARCHAR(20) DEFAULT 1;
    DECLARE v_estatus_new VARCHAR(20) DEFAULT 0;
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT new.Estatus THEN
     SET v_estatus_new = 0;
	END IF;
    
    IF NOT old.Estatus THEN
     SET v_estatus_old = 0;
	END IF;
    
    INSERT INTO tbi_bitacora VALUES(
		default, 
        current_user(), 
        'Update', 
        'tbc_roles', 
        CONCAT_WS(' ','Se ha modificado un rol de usuario existente con los siguientes datos:',
        'NOMBRE:',old.nombre,' - ', new.nombre, 
        'DESCRIPCION:', old.descripcion, ' - ', new.descripcion, 
        'ESTATUS:', v_estatus_old, ' - ', v_estatus_new),
        DEFAULT, 
        DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_roles_AFTER_DELETE` AFTER DELETE ON `tbc_roles` FOR EACH ROW BEGIN
DECLARE v_estatus VARCHAR(20) DEFAULT 1;
    
    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NOT old.Estatus THEN
     SET v_estatus = 0;
	END IF;
    
    INSERT INTO tbi_bitacora VALUES(
		default, 
        current_user(), 
        'Delete', 
        'tbc_roles', 
        CONCAT_WS(' ','Se ha eliminado un rol de usuario existente con los siguientes datos:',
        'NOMBRE:',old.nombre, 'DESCRIPCION:', old.descripcion, 'ESTATUS:', v_estatus),
        DEFAULT, 
        DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbc_servicios_medicos`
--

DROP TABLE IF EXISTS `tbc_servicios_medicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbc_servicios_medicos` (
  `ID` char(36) NOT NULL DEFAULT (uuid()),
  `Nombre` varchar(255) NOT NULL COMMENT 'Descripción: Nombre del servicio médico. Este campo almacena el nombre único de cada servicio registrado.\nNaturaleza: Cualitativo.\nDominio: Caracteres alfanuméricos con espacios.\nComposición:\nTipo de dato: VARCHAR(255).\nNo permite valores nulos (NOT NULL).\nDebe ser único en la tabla (UNIQUE).\nPuede contener hasta 255 caracteres.\nSolo permite letras (a-z, A-Z), números (0-9) y espacios.',
  `Descripcion` text NOT NULL COMMENT 'Descripción: Texto descriptivo que proporciona detalles sobre el servicio médico, incluyendo su propósito y alcance.\nNaturaleza: Cualitativo.\nDominio: Caracteres alfanuméricos y símbolos especiales permitidos en un campo de texto.\nComposición:\nTipo de dato: TEXT.\nPuede contener una cantidad variable de caracteres.\nPuede aceptar valores NULL.',
  `Observaciones` text COMMENT 'Descripción: Información adicional o comentarios sobre el servicio médico, tales como condiciones, restricciones o notas importantes.\nNaturaleza: Cualitativo.\nDominio: Caracteres alfanuméricos y símbolos permitidos en un campo de texto.\nComposición:\nTipo de dato: TEXT.\nPuede contener una cantidad variable de caracteres.\nPuede aceptar valores NULL.',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Descripción: Fecha y hora en la que se registró el servicio médico en el sistema. Se asigna automáticamente al crear un nuevo registro.\nNaturaleza: Cuantitativo.\nDominio: Formato de fecha y hora (YYYY-MM-DD HH:MM:SS).\nComposición:\nTipo de dato: DATETIME.\nNo permite valores nulos (NOT NULL).\nSe asigna automáticamente la fecha y hora actual en el momento del registro (DEFAULT CURRENT_TIMESTAMP).',
  `Fecha_Actualizacion` datetime DEFAULT NULL COMMENT 'Descripción: Fecha y hora de la última modificación realizada en el servicio médico. Se actualiza cada vez que se edita el registro.\nNaturaleza: Cuantitativo.\nDominio: Formato de fecha y hora (YYYY-MM-DD HH:MM:SS).\nComposición:\nTipo de dato: DATETIME.\nPuede aceptar valores NULL.\nNo se actualiza automáticamente, requiere que el sistema lo modifique cuando se realice un cambio en el registro.',
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Nombre_UNIQUE` (`Nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbc_servicios_medicos`
--

LOCK TABLES `tbc_servicios_medicos` WRITE;
/*!40000 ALTER TABLE `tbc_servicios_medicos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbc_servicios_medicos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_servicios_medicos_AFTER_INSERT` AFTER INSERT ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbc_servicios_medicos',
        CONCAT_WS(' ',
            'Se ha registrado un nuevo servicio médico con los siguientes datos:','\n',
            'NOMBRE:', NEW.nombre,'\n',
            'DESCRIPCION:', NEW.descripcion,'\n',
            'OBSERVACIONES:', NEW.observaciones,'\n',
            'FECHA REGISTRO:', NEW.fecha_registro,'\n',
            'FECHA ACTUALIZACION:', NEW.fecha_actualizacion,'\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_servicios_medicos_BEFORE_UPDATE` BEFORE UPDATE ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_servicios_medicos_AFTER_UPDATE` AFTER UPDATE ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update', 
        'tbc_servicios_medicos', 
        CONCAT_WS(' ', 
            'Se ha modificado un servicio médico con los siguientes datos:', '\n',
            'NOMBRE:', OLD.nombre, '-', NEW.nombre, '\n',
            'DESCRIPCION:', OLD.descripcion, '-', NEW.descripcion, '\n',
            'OBSERVACIONES:', OLD.observaciones, '-', NEW.observaciones, '\n',
            'FECHA REGISTRO:', OLD.fecha_registro, '-', NEW.fecha_registro, '\n',
            'FECHA ACTUALIZACION:', OLD.fecha_actualizacion, '-', NEW.fecha_actualizacion, '\n'
        ), 
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbc_servicios_medicos_AFTER_DELETE` AFTER DELETE ON `tbc_servicios_medicos` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbc_servicios_medicos',
        CONCAT_WS(' ',
            'Se ha eliminado un servicio médico con los siguientes datos:','\n',
            'NOMBRE:', OLD.nombre,'\n',
            'DESCRIPCION:', OLD.descripcion,'\n',
            'OBSERVACIONES:', OLD.observaciones,'\n',
            'FECHA REGISTRO:', OLD.fecha_registro,'\n',
            'FECHA ACTUALIZACION:', OLD.fecha_actualizacion,'\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_cirugias_personal_medico`
--

DROP TABLE IF EXISTS `tbd_cirugias_personal_medico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_cirugias_personal_medico` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Cirugia_ID` int unsigned NOT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_personal_medico_cirugia_idx` (`Personal_Medico_ID`),
  KEY `fk_cirugia_1_idx` (`Cirugia_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_cirugias_personal_medico`
--

LOCK TABLES `tbd_cirugias_personal_medico` WRITE;
/*!40000 ALTER TABLE `tbd_cirugias_personal_medico` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_cirugias_personal_medico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbd_departamentos_servicios`
--

DROP TABLE IF EXISTS `tbd_departamentos_servicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_departamentos_servicios` (
  `Departamento_ID` char(36) NOT NULL,
  `Servicio_ID` char(36) NOT NULL,
  `Requisitos` text,
  `Restricciones` text,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Departamento_ID`,`Servicio_ID`),
  KEY `fk_servicios_medicos_1_idx` (`Servicio_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_departamentos_servicios`
--

LOCK TABLES `tbd_departamentos_servicios` WRITE;
/*!40000 ALTER TABLE `tbd_departamentos_servicios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_departamentos_servicios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_AFTER_INSERT` AFTER INSERT ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
DECLARE v_departamento_nombre VARCHAR(100);
    DECLARE v_servicio_nombre VARCHAR(100);
    
    -- Obtener el nombre del departamento
    SELECT nombre INTO v_departamento_nombre
    FROM tbc_departamentos
    WHERE id = NEW.Departamento_ID;
    
    -- Obtener el nombre del servicio médico
    SELECT nombre INTO v_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = NEW.Servicio_ID;
    
    INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbd_departamentos_servicios',
        CONCAT_WS(' ',
            'Se ha registrado un nuevo departamento-servicio con los siguientes datos:', '\n',
            'Departamento:', v_departamento_nombre, '\n',
            'Servicio Médico:', v_servicio_nombre, '\n',
            'Requisitos:', NEW.Requisitos, '\n',
            'Restricciones:', NEW.Restricciones, '\n',
            'Estatus:', 'Activo', '\n',  -- Modificado a "activo"
            'Fecha_Registro:', NEW.Fecha_Registro, '\n',
            'Fecha_Actualizacion:', NEW.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_AFTER_UPDATE` AFTER UPDATE ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
  DECLARE v_old_departamento_nombre VARCHAR(100);
    DECLARE v_old_servicio_nombre VARCHAR(100);
    DECLARE v_new_departamento_nombre VARCHAR(100);
    DECLARE v_new_servicio_nombre VARCHAR(100);
    
    -- Obtener el nombre del departamento antes del cambio
    SELECT nombre INTO v_old_departamento_nombre
    FROM tbc_departamentos
    WHERE id = OLD.Departamento_ID;
    
    -- Obtener el nombre del servicio médico antes del cambio
    SELECT nombre INTO v_old_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = OLD.Servicio_ID;
    
    -- Obtener el nombre del departamento después del cambio
    SELECT nombre INTO v_new_departamento_nombre
    FROM tbc_departamentos
    WHERE id = NEW.Departamento_ID;
    
    -- Obtener el nombre del servicio médico después del cambio
    SELECT nombre INTO v_new_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = NEW.Servicio_ID;
    
    INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update', 
        'tbd_departamentos_servicios', 
        CONCAT_WS(' ', 
            'Se ha modificado un departamento-servicio con los siguientes datos:', '\n',
            'Departamento (antes):', v_old_departamento_nombre, ' -> ', v_new_departamento_nombre, '\n',
            'Servicio Médico (antes):', v_old_servicio_nombre, ' -> ', v_new_servicio_nombre, '\n',
            'Requisitos (antes):', OLD.Requisitos, ' -> ', NEW.Requisitos, '\n',
            'Restricciones (antes):', OLD.Restricciones, ' -> ', NEW.Restricciones, '\n',
            'Estatus (antes):','activo', ' -> ', 'activo', '\n',  -- Modificado a "activo"
            'Fecha_Registro (antes):', OLD.Fecha_Registro, ' -> ', NEW.Fecha_Registro, '\n',
            'Fecha_Actualizacion:', OLD.Fecha_Actualizacion, ' -> ', NEW.Fecha_Actualizacion, '\n'
        ), 
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_departamentos_servicios_AFTER_DELETE` AFTER DELETE ON `tbd_departamentos_servicios` FOR EACH ROW BEGIN
 DECLARE v_departamento_nombre VARCHAR(100);
    DECLARE v_servicio_nombre VARCHAR(100);
    
    -- Obtener el nombre del departamento eliminado
    SELECT nombre INTO v_departamento_nombre
    FROM tbc_departamentos
    WHERE id = OLD.Departamento_ID;
    
    -- Obtener el nombre del servicio médico eliminado
    SELECT nombre INTO v_servicio_nombre
    FROM tbc_servicios_medicos
    WHERE id = OLD.Servicio_ID;
    
    INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbd_departamentos_servicios',
        CONCAT_WS(' ',
            'Se ha eliminado un departamento-servicio con los siguientes datos:', '\n',
            'Departamento:', v_departamento_nombre, '\n',
            'Servicio Médico:', v_servicio_nombre, '\n',
            'Requisitos:', OLD.Requisitos, '\n',
            'Restricciones:', OLD.Restricciones, '\n',
            'Estatus:', 'Inactivo', '\n',
            'Fecha_Registro:', OLD.Fecha_Registro, '\n',
            'Fecha_Actualizacion:', OLD.Fecha_Actualizacion, '\n'
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_dispensaciones`
--

DROP TABLE IF EXISTS `tbd_dispensaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_dispensaciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `RecetaMedica_id` int unsigned DEFAULT NULL,
  `PersonalMedico_id` int unsigned NOT NULL,
  `Departamento_id` int unsigned NOT NULL,
  `Solicitud_id` int unsigned DEFAULT NULL,
  `Estatus` enum('Abastecida','Parcialmente abastecida') NOT NULL,
  `Tipo` enum('Publica','Privada','Mixta') NOT NULL,
  `TotalMedicamentosEntregados` int NOT NULL,
  `Total_costo` float NOT NULL,
  `Fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_dispensaciones`
--

LOCK TABLES `tbd_dispensaciones` WRITE;
/*!40000 ALTER TABLE `tbd_dispensaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_dispensaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_dispensaciones_AFTER_INSERT` AFTER INSERT ON `tbd_dispensaciones` FOR EACH ROW BEGIN
 DECLARE v_estatus_new VARCHAR(50) DEFAULT NEW.Estatus;
    DECLARE v_tipo_new VARCHAR(50) DEFAULT NEW.Tipo;
    DECLARE v_solicitud_id VARCHAR(50);
    DECLARE v_receta_medica_id VARCHAR(50);

    IF NEW.Solicitud_id IS NULL THEN
        SET v_solicitud_id = 'no aplica';
    ELSE
        SET v_solicitud_id = CAST(NEW.Solicitud_id AS CHAR);
    END IF;

    IF NEW.RecetaMedica_id IS NULL THEN
        SET v_receta_medica_id = 'no aplica';
    ELSE
        SET v_receta_medica_id = CAST(NEW.RecetaMedica_id AS CHAR);
    END IF;

    INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbb_dispensaciones',
        CONCAT_WS(' ', 
            'Se ha insertado una nueva dispensación con ID:', NEW.id, 
            '\nReceta Medica:', v_receta_medica_id, 
            '\nPersonal Medico:', NEW.PersonalMedico_id, 
            '\nDepartamento:', NEW.Departamento_id, 
            '\nSolicitud:', v_solicitud_id, 
            '\nEstatus:', v_estatus_new, 
            '\nTipo:', v_tipo_new, 
            '\nMedicamentos entregados:', NEW.TotalMedicamentosEntregados, 
            '\nCosto:', NEW.Total_costo
        ),
       default,
       default
    ); 


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_dispensaciones_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_dispensaciones` FOR EACH ROW BEGIN
	set new.Fecha_Actualizacion = current_time();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_dispensaciones_AFTER_UPDATE` AFTER UPDATE ON `tbd_dispensaciones` FOR EACH ROW BEGIN
 DECLARE v_estatus_old VARCHAR(50) DEFAULT OLD.Estatus;
    DECLARE v_estatus_new VARCHAR(50) DEFAULT NEW.Estatus;
    DECLARE v_tipo_old VARCHAR(50) DEFAULT OLD.Tipo;
    DECLARE v_tipo_new VARCHAR(50) DEFAULT NEW.Tipo;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbb_dispensaciones',
        CONCAT_WS(' ', 
            'Se ha actualizado la dispensación con ID:', OLD.id, 
            '\n Receta Medica:', OLD.RecetaMedica_id, '-', NEW.RecetaMedica_id, 
            '\n Personal Medico:', OLD.PersonalMedico_id, '-', NEW.PersonalMedico_id, 
            '\n Departamento:', OLD.Departamento_id, '-', NEW.Departamento_id, 
            '\n Solicitud:', OLD.Solicitud_id, '-', NEW.Solicitud_id, 
            '\n Estatus:', v_estatus_old, '-', v_estatus_new, 
            '\n Tipo:', v_tipo_old, '-', v_tipo_new, 
            '\n Medicamentos entregados:', OLD.TotalMedicamentosEntregados, '-', NEW.TotalMedicamentosEntregados, 
            '\n Costo:', OLD.Total_costo, '-', NEW.Total_costo
        ),
        DEFAULT,
        DEFAULT
    ); 


END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_dispensaciones_AFTER_DELETE` AFTER DELETE ON `tbd_dispensaciones` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora VALUES(
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbb_dispensaciones',
        CONCAT_WS(' ', 
            'Se ha eliminado la dispensación con ID:', OLD.id, 
            '\n Receta Medica:', COALESCE(OLD.RecetaMedica_id, 'no aplica'), 
            '\n Solicitud: ', COALESCE(OLD.Solicitud_id, 'no aplica'),
            '\n Estatus:', OLD.Estatus
        ),
        DEFAULT,
        DEFAULT
    ); 

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_expedientes_clinicos`
--

DROP TABLE IF EXISTS `tbd_expedientes_clinicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_expedientes_clinicos` (
  `Persona_ID` int unsigned NOT NULL,
  `Antecendentes_Medicos_Patologicos` varchar(80) NOT NULL,
  `Antecendentes_Medicos_NoPatologicos` varchar(80) NOT NULL,
  `Antecendentes_Medicos_Patologicos_HeredoFamiliares` varchar(80) NOT NULL,
  `Interrogatorio_Sistemas` varchar(80) NOT NULL,
  `Padecimiento_Actual` varchar(80) NOT NULL,
  `Notas_Medicas` varchar(80) DEFAULT NULL,
  `Estatus` bit(1) NOT NULL DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Persona_ID`),
  KEY `fk_expedientes_1_idx` (`Persona_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_expedientes_clinicos`
--

LOCK TABLES `tbd_expedientes_clinicos` WRITE;
/*!40000 ALTER TABLE `tbd_expedientes_clinicos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_expedientes_clinicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbd_horarios`
--

DROP TABLE IF EXISTS `tbd_horarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_horarios` (
  `horario_id` int NOT NULL AUTO_INCREMENT,
  `empleado_id` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `especialidad` varchar(100) NOT NULL,
  `dia_semana` varchar(20) NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `turno` varchar(20) NOT NULL,
  `nombre_departamento` varchar(100) NOT NULL,
  `nombre_sala` varchar(100) NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`horario_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_horarios`
--

LOCK TABLES `tbd_horarios` WRITE;
/*!40000 ALTER TABLE `tbd_horarios` DISABLE KEYS */;
INSERT INTO `tbd_horarios` VALUES (1,1,'Marvin','Traumatologia','Lunes','10:10:00','11:10:00','Matutino','Dep1','Sala1','2024-06-20 16:14:38','2024-06-20 16:14:38'),(2,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-06-20 16:15:57','2024-06-20 16:15:57'),(3,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-06-20 16:15:57','2024-06-20 16:15:57'),(4,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-06-20 16:15:57','2024-06-20 16:15:57'),(5,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-06-20 16:15:57','2024-06-20 16:15:57'),(6,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-06-20 16:15:57','2024-06-20 16:15:57'),(7,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 07:46:18','2024-08-03 07:46:18'),(8,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 07:46:18','2024-08-03 07:46:18'),(9,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 07:46:18','2024-08-03 07:46:18'),(10,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 07:46:18','2024-08-03 07:46:18'),(11,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 07:46:18','2024-08-03 07:46:18'),(12,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 07:57:01','2024-08-03 07:57:01'),(13,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 07:57:01','2024-08-03 07:57:01'),(14,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 07:57:01','2024-08-03 07:57:01'),(15,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 07:57:01','2024-08-03 07:57:01'),(16,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 07:57:01','2024-08-03 07:57:01'),(17,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 08:10:11','2024-08-03 08:10:11'),(18,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 08:10:11','2024-08-03 08:10:11'),(19,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 08:10:11','2024-08-03 08:10:11'),(20,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 08:10:11','2024-08-03 08:10:11'),(21,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 08:10:11','2024-08-03 08:10:11'),(22,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 08:15:30','2024-08-03 08:15:30'),(23,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 08:15:30','2024-08-03 08:15:30'),(24,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 08:15:30','2024-08-03 08:15:30'),(25,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 08:15:30','2024-08-03 08:15:30'),(26,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 08:15:30','2024-08-03 08:15:30'),(27,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 08:22:43','2024-08-03 08:22:43'),(28,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 08:22:43','2024-08-03 08:22:43'),(29,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 08:22:43','2024-08-03 08:22:43'),(30,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 08:22:43','2024-08-03 08:22:43'),(31,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 08:22:43','2024-08-03 08:22:43'),(32,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 08:28:34','2024-08-03 08:28:34'),(33,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 08:28:34','2024-08-03 08:28:34'),(34,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 08:28:34','2024-08-03 08:28:34'),(35,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 08:28:34','2024-08-03 08:28:34'),(36,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 08:28:34','2024-08-03 08:28:34'),(37,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 08:57:44','2024-08-03 08:57:44'),(38,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 08:57:44','2024-08-03 08:57:44'),(39,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 08:57:44','2024-08-03 08:57:44'),(40,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 08:57:44','2024-08-03 08:57:44'),(41,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 08:57:44','2024-08-03 08:57:44'),(42,1,'Doctor 1','Especialidad 1','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 2','2024-08-03 09:06:41','2024-08-03 09:06:41'),(43,2,'Doctor 2','Especialidad 2','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 1','2024-08-03 09:06:41','2024-08-03 09:06:41'),(44,3,'Doctor 3','Especialidad 3','Lunes','08:00:00','16:00:00','Matutino','Departamento 1','Sala 2','2024-08-03 09:06:41','2024-08-03 09:06:41'),(45,4,'Doctor 4','Especialidad 4','Lunes','08:00:00','16:00:00','Matutino','Departamento 2','Sala 1','2024-08-03 09:06:41','2024-08-03 09:06:41'),(46,5,'Doctor 5','Especialidad 5','Lunes','08:00:00','16:00:00','Matutino','Departamento 3','Sala 2','2024-08-03 09:06:41','2024-08-03 09:06:41');
/*!40000 ALTER TABLE `tbd_horarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_horarios_AFTER_INSERT` AFTER INSERT ON `tbd_horarios` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Create',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha agregado un nuevo horario con los siguientes datos:',
            '\n ID Empleado:', NEW.empleado_id,
            '\n Nombre:', NEW.nombre,
            '\n Especialidad:', NEW.especialidad,
            '\n Día de la Semana:', NEW.dia_semana,
            '\n Hora de Inicio:', NEW.hora_inicio,
            '\n Hora de Fin:', NEW.hora_fin,
            '\n Turno:', NEW.turno,
            '\n Departamento:', NEW.nombre_departamento,
            '\n Sala:', NEW.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_horarios_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_horarios` FOR EACH ROW BEGIN
    -- No es necesario establecer NEW.fecha_actualizacion porque se maneja automáticamente por el campo de la tabla
    
    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Update',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha actualizado un horario con los siguientes cambios:',
            '\n ID Empleado:', OLD.empleado_id, '->', NEW.empleado_id,
            '\n Nombre:', OLD.nombre, '->', NEW.nombre,
            '\n Especialidad:', OLD.especialidad, '->', NEW.especialidad,
            '\n Día de la Semana:', OLD.dia_semana, '->', NEW.dia_semana,
            '\n Hora de Inicio:', OLD.hora_inicio, '->', NEW.hora_inicio,
            '\n Hora de Fin:', OLD.hora_fin, '->', NEW.hora_fin,
            '\n Turno:', OLD.turno, '->', NEW.turno,
            '\n Departamento:', OLD.nombre_departamento, '->', NEW.nombre_departamento,
            '\n Sala:', OLD.nombre_sala, '->', NEW.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_horarios_AFTER_UPDATE` AFTER UPDATE ON `tbd_horarios` FOR EACH ROW BEGIN
    DECLARE v_turno_old VARCHAR(20) DEFAULT 'Activo';
    DECLARE v_turno_new VARCHAR(20) DEFAULT 'Activo';

    -- Validamos el turno del registro y le asignamos una etiqueta para la descripción
    IF NEW.turno = 'Inactivo' THEN
        SET v_turno_new = 'Inactivo';
    ELSEIF NEW.turno = 'Bloqueado' THEN
        SET v_turno_new = 'Bloqueado';
    ELSEIF NEW.turno = 'Suspendido' THEN
        SET v_turno_new = 'Suspendido';
    END IF;

    IF OLD.turno = 'Inactivo' THEN
        SET v_turno_old = 'Inactivo';
    ELSEIF OLD.turno = 'Bloqueado' THEN
        SET v_turno_old = 'Bloqueado';
    ELSEIF OLD.turno = 'Suspendido' THEN
        SET v_turno_old = 'Suspendido';
    END IF;

    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Update',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha modificado el horario existente con los siguientes datos:',
            '\n ID Empleado:', OLD.empleado_id, '-', NEW.empleado_id,
            '\n Nombre:', OLD.nombre, '-', NEW.nombre,
            '\n Especialidad:', OLD.especialidad, '-', NEW.especialidad,
            '\n Día de la Semana:', OLD.dia_semana, '-', NEW.dia_semana,
            '\n Hora de Inicio:', OLD.hora_inicio, '-', NEW.hora_inicio,
            '\n Hora de Fin:', OLD.hora_fin, '-', NEW.hora_fin,
            '\n Turno:', v_turno_old, '-', v_turno_new,
            '\n Departamento:', OLD.nombre_departamento, '-', NEW.nombre_departamento,
            '\n Sala:', OLD.nombre_sala, '-', NEW.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_horarios_AFTER_DELETE` AFTER DELETE ON `tbd_horarios` FOR EACH ROW BEGIN
    DECLARE v_turno VARCHAR(20) DEFAULT 'Activo';

    INSERT INTO tbi_bitacora (
        Usuario,
        Operacion,
        Tabla,
        Descripcion,
        Estatus,
        Fecha_Registro
    ) VALUES (
        CURRENT_USER(),
        'Delete',
        'tbd_horarios',
        CONCAT_WS(' ', 'Se ha eliminado un horario con los siguientes datos:',
            '\n ID Empleado:', OLD.empleado_id,
            '\n Nombre:', OLD.nombre,
            '\n Especialidad:', OLD.especialidad,
            '\n Día de la Semana:', OLD.dia_semana,
            '\n Hora de Inicio:', OLD.hora_inicio,
            '\n Hora de Fin:', OLD.hora_fin,
            '\n Turno:', v_turno,
            '\n Departamento:', OLD.nombre_departamento,
            '\n Sala:', OLD.nombre_sala),
        b'1',
        CURRENT_TIMESTAMP()
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_lotes_medicamentos`
--

DROP TABLE IF EXISTS `tbd_lotes_medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_lotes_medicamentos` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Medicamento_ID` int unsigned NOT NULL,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Clave` varchar(50) NOT NULL,
  `Estatus` enum('Reservado','En transito','Recibido','Rechazado') NOT NULL,
  `Costo_Total` decimal(10,2) NOT NULL,
  `Cantidad` int unsigned NOT NULL,
  `Ubicacion` varchar(100) NOT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_lotes_medicamentos`
--

LOCK TABLES `tbd_lotes_medicamentos` WRITE;
/*!40000 ALTER TABLE `tbd_lotes_medicamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_lotes_medicamentos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_AFTER_INSERT` AFTER INSERT ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN

	DECLARE v_estatus_descripcion VARCHAR(20) DEFAULT 'Reservado';

    -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
    IF NEW.Estatus = 'Reservado' THEN
        SET v_estatus_descripcion = 'Reservado';
    ELSEIF NEW.Estatus = 'En transito' THEN
        SET v_estatus_descripcion = 'En transito';
    ELSEIF NEW.Estatus = 'Recibido' THEN
        SET v_estatus_descripcion = 'Recibido';
    ELSEIF NEW.Estatus = 'Rechazado' THEN
        SET v_estatus_descripcion = 'Rechazado';
    END IF;

    -- Insertamos el evento en la bitácora
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbb_lotes_medicamentos',
        CONCAT_WS(' ', 'Se ha insertado un nuevo lote de medicamento con ID:', NEW.ID,
        '\n Medicamento_ID:', NEW.Medicamento_ID,
        '\n Personal_Medico_ID:', NEW.Personal_Medico_ID,
        '\n Clave:', NEW.Clave,
        '\n Estatus:', NEW.Estatus,
        '\n Costo_Total:', NEW.Costo_Total,
        '\n Cantidad:', NEW.Cantidad,
        '\n y Ubicacion:', NEW.Ubicacion),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN
	set new.Fecha_Actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_AFTER_UPDATE` AFTER UPDATE ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN
	DECLARE v_estatus_descripcion VARCHAR(20);

    -- Asignamos una descripción al estatus del lote de medicamento
    CASE NEW.Estatus
        WHEN 'Reservado' THEN SET v_estatus_descripcion := 'Reservado';
        WHEN 'En transito' THEN SET v_estatus_descripcion := 'En transito';
        WHEN 'Recibido' THEN SET v_estatus_descripcion := 'Recibido';
        WHEN 'Rechazado' THEN SET v_estatus_descripcion := 'Rechazado';
    END CASE;

    -- Insertamos el evento en la bitácora
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbb_lotes_medicamentos',
        CONCAT_WS(' ', 
            'Se ha actualización el Lote Medicamento:',
            '\n ID del Lote:', OLD.ID,
            '\n Medicamento_ID:', OLD.Medicamento_ID, '-', NEW.Medicamento_ID,
            '\n Personal_Medico_ID:', OLD.Personal_Medico_ID, '-', NEW.Personal_Medico_ID,
            '\n Clave:', OLD.Clave, '-', NEW.Clave,
            '\n Estatus:', OLD.Estatus, '-', v_estatus_descripcion,
            '\n Costo Total:', OLD.Costo_Total, '-', NEW.Costo_Total,
            '\n Cantidad:', OLD.Cantidad, '-', NEW.Cantidad,
            '\n y Ubicación:', OLD.Ubicacion, '-', NEW.Ubicacion
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_lotes_medicamentos_AFTER_DELETE` AFTER DELETE ON `tbd_lotes_medicamentos` FOR EACH ROW BEGIN
	DECLARE v_estatus_descripcion VARCHAR(20);

    -- Asignamos una descripción al estatus del lote de medicamento
    CASE OLD.Estatus
        WHEN 'Reservado' THEN SET v_estatus_descripcion := 'Reservado';
        WHEN 'En transito' THEN SET v_estatus_descripcion := 'En transito';
        WHEN 'Recibido' THEN SET v_estatus_descripcion := 'Recibido';
        WHEN 'Rechazado' THEN SET v_estatus_descripcion := 'Rechazado';
    END CASE;

    -- Insertamos el evento en la bitácora
    INSERT INTO tbi_bitacora VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbb_lotes_medicamentos',
        CONCAT_WS(' ', 
            'Se ha eliminado el Lote Medicamento con:',
            '\n ID del Lote:', OLD.ID,
            '\nMedicamento_ID:', OLD.Medicamento_ID,
            '\n Personal_Medico_ID:', OLD.Personal_Medico_ID,
            '\n Clave:', OLD.Clave,
            '\n Estatus:', v_estatus_descripcion,
            '\n Costo Total:', OLD.Costo_Total,
            '\nCantidad:', OLD.Cantidad,
            '\n y con Ubicación:', OLD.Ubicacion
        ),
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_puestos_departamentos`
--

DROP TABLE IF EXISTS `tbd_puestos_departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_puestos_departamentos` (
  `PuestoID` int unsigned NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Salario` decimal(10,2) DEFAULT NULL,
  `Turno` enum('Mañana','Tarde','Noche') DEFAULT NULL,
  `Creado` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Modificado` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DepartamentoID` int unsigned NOT NULL,
  PRIMARY KEY (`PuestoID`),
  KEY `DepartamentoID` (`DepartamentoID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_puestos_departamentos`
--

LOCK TABLES `tbd_puestos_departamentos` WRITE;
/*!40000 ALTER TABLE `tbd_puestos_departamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_puestos_departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbd_recetas_medicas`
--

DROP TABLE IF EXISTS `tbd_recetas_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_recetas_medicas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `paciente_nombre` varchar(100) NOT NULL,
  `paciente_edad` int unsigned NOT NULL,
  `medico_nombre` varchar(100) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` date DEFAULT NULL,
  `diagnostico` varchar(255) DEFAULT NULL,
  `medicamentos` text,
  `indicaciones` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_recetas_medicas`
--

LOCK TABLES `tbd_recetas_medicas` WRITE;
/*!40000 ALTER TABLE `tbd_recetas_medicas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_recetas_medicas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_recetas_medicas_AFTER_INSERT` AFTER INSERT ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
DECLARE v_usuario varchar(100) default (select paciente_nombre from
    tbd_recetas_medicas where id = new.id);
 INSERT INTO tbi_bitacora 
    VALUES (
    default,
	current_user(),
    'Create',
    'tbd_recetas_medicas',
    CONCAT_WS(' ', 'Se ha creado una nueva receta médica con ID: ',NEW.id,'\n',
    "Para el usuario:",v_usuario),
    default, 
    default);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_recetas_medicas_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
SET new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_recetas_medicas_AFTER_UPDATE` AFTER UPDATE ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
   
    INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbd_recetas_medicas',
         CONCAT_WS(' ', 
        'Se ha actualizado la receta médica con ID: ', NEW.id,'\n',
        'Del usuario: ', old.paciente_nombre,'\n', 
        'Nombre de usuario Actualizado:', new.paciente_nombre, '\n',
        'Se modificaron las indicaciones:',old.indicaciones,'\n',
        'por las nuevas:', new.indicaciones,'\n',
        'Diagnostico Actual:', old.diagnostico,'\n',
        'Diagnostico Actualizado:',new.diagnostico,'\n',
        'Medicamentos Sumistrados:', old.medicamentos,'\n',
		'Medicamentos Actualizados',new.medicamentos
        ),
        
        DEFAULT,
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_recetas_medicas_AFTER_DELETE` AFTER DELETE ON `tbd_recetas_medicas` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora VALUES (
    DEFAULT,
    CURRENT_USER(),
    'Delete',
    'tbd_recetas_medicas',
    CONCAT_WS(' ', 
		'se ha eliminado la receta del usuario:', old.paciente_nombre,'\n',
        'con el id:', old.id ),
    DEFAULT,
    DEFAULT
);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_resultados_estudios`
--

DROP TABLE IF EXISTS `tbd_resultados_estudios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_resultados_estudios` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Paciente_ID` int unsigned NOT NULL,
  `Personal_Medico_ID` int unsigned NOT NULL,
  `Estudio_ID` int unsigned NOT NULL,
  `Folio` varchar(11) NOT NULL,
  `Resultados` text NOT NULL,
  `Observaciones` text NOT NULL,
  `Estatus` enum('Pendiente','En Proceso','Completado','Aprobado','Rechazado') DEFAULT NULL,
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Folio` (`Folio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_resultados_estudios`
--

LOCK TABLES `tbd_resultados_estudios` WRITE;
/*!40000 ALTER TABLE `tbd_resultados_estudios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_resultados_estudios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_resultados_estudios_AFTER_INSERT` AFTER INSERT ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbd_resultados_estudios',
        CONCAT_WS(' ',
            'Se ha registrado un nuevo resultado de estudio con los siguientes datos:','\n',
            'PACIENTE_ID:', NEW.Paciente_ID,'\n',
            'PERSONAL_MEDICO_ID:', NEW.Personal_Medico_ID,'\n',
            'ESTUDIO_ID:', NEW.Estudio_ID,'\n',
            'FOLIO:', NEW.Folio,'\n',
            'RESULTADOS:', NEW.Resultados,'\n',
            'OBSERVACIONES:', NEW.Observaciones,'\n',
            'ESTATUS:', new.estatus,'\n'
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_resultados_estudios_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
	set new.fecha_actualizacion = current_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_resultados_estudios_AFTER_UPDATE` AFTER UPDATE ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
    INSERT INTO tbi_bitacora 
    VALUES (
        DEFAULT, 
        CURRENT_USER(), 
        'Update', 
        'tbd_resultados_estudios', 
        CONCAT_WS(' ', 
            'Se ha modificado un resultado de estudio con ID:', OLD.ID, 'con los siguientes datos:', '\n',
            'PACIENTE_ID:', OLD.Paciente_ID, '-', NEW.Paciente_ID, '\n',
            'PERSONAL_MEDICO_ID:', OLD.Personal_Medico_ID, '-', NEW.Personal_Medico_ID, '\n',
            'ESTUDIO_ID:', OLD.Estudio_ID, '-', NEW.Estudio_ID, '\n',
            'FOLIO:', OLD.Folio, '-', NEW.Folio, '\n',
            'RESULTADOS:', OLD.Resultados, '-', NEW.Resultados, '\n',
            'OBSERVACIONES:', OLD.Observaciones, '-', NEW.Observaciones, '\n',
            'ESTATUS:', OLD.Estatus, '-', NEW.Estatus,'\n'
        ), 
        DEFAULT, 
        DEFAULT
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_resultados_estudios_AFTER_DELETE` AFTER DELETE ON `tbd_resultados_estudios` FOR EACH ROW BEGIN
 INSERT INTO tbi_bitacora
    VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Delete',
        'tbd_resultados_estudios',
        CONCAT_WS(' ',
            'Se ha eliminado un nuevo resultado de estudio con los siguientes datos:','\n',
            'PACIENTE_ID:', old.Paciente_ID,'\n',
            'PERSONAL_MEDICO_ID:', old.Personal_Medico_ID,'\n',
            'ESTUDIO_ID:', old.Estudio_ID,'\n',
            'FOLIO:', old.Folio,'\n',
            'RESULTADOS:', old.Resultados,'\n',
            'OBSERVACIONES:', old.Observaciones,'\n',
            'ESTATUS:', old.estatus,'\n'
        ),
        DEFAULT,
        DEFAULT
    );

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_solicitudes`
--

DROP TABLE IF EXISTS `tbd_solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_solicitudes` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Paciente_ID` int unsigned NOT NULL,
  `Medico_ID` int unsigned NOT NULL,
  `Servicio_ID` int unsigned NOT NULL,
  `Prioridad` enum('Urgente','Alta','Moderada','Emergente','Normal') NOT NULL,
  `Descripcion` text NOT NULL,
  `Estatus` enum('Registrada','Programada','Cancelada','Reprogramada','En Proceso','Realizada') NOT NULL DEFAULT 'Registrada',
  `Estatus_Aprobacion` bit(1) NOT NULL DEFAULT b'0',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_personal_medico_1_idx` (`Medico_ID`),
  KEY `fk_paciente_1_idx` (`Paciente_ID`),
  KEY `fk_servicios_medicos_2_idx` (`Servicio_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_solicitudes`
--

LOCK TABLES `tbd_solicitudes` WRITE;
/*!40000 ALTER TABLE `tbd_solicitudes` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbd_solicitudes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_solicitudes_AFTER_INSERT` AFTER INSERT ON `tbd_solicitudes` FOR EACH ROW BEGIN
   DECLARE nombre_paciente VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio VARCHAR(100) DEFAULT NULL;
   DECLARE v_estatus_aprobacion VARCHAR(20) DEFAULT 'Activo';

   -- Validamos el estatus del registro y le asignamos una etiqueta para la descripcion
   IF NOT NEW.Estatus_Aprobacion THEN
      SET v_estatus_aprobacion = 'Inactivo';
   END IF;

   -- Obtener el nombre del paciente recién insertado
   SET nombre_paciente = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = NEW.paciente_ID);

   -- Obtener el nombre del personal médico recién insertado
   SET nombre_medico = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = NEW.medico_ID);
                         
   -- Obtener el nombre del servicio recién insertado
   SET nombre_servicio = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = NEW.servicio_ID);

   INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) VALUES (
      CURRENT_USER(), 
      'Create', 
      'tbd_solicitudes', 
      CONCAT_WS(" ", 'Se ha creado una nueva solicitud con los siguientes datos: ',
      'Nombre del Paciente: ', nombre_paciente, '\n',
      'Nombre del Medico: ', nombre_medico, '\n',
      'Nombre del Servicio: ', nombre_servicio, '\n',
      'Prioridad: ', NEW.Prioridad, '\n',
      'Descripcion: ', NEW.Descripcion, '\n',
      'Estatus de la solicitud: ', NEW.Estatus, '\n',
      'Estatus de Aprobación: ', v_estatus_aprobacion),
      DEFAULT,
      DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_solicitudes_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_solicitudes` FOR EACH ROW BEGIN
   SET NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_solicitudes_AFTER_UPDATE` AFTER UPDATE ON `tbd_solicitudes` FOR EACH ROW BEGIN
   DECLARE nombre_paciente_new VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico_new VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio_new VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_paciente_old VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico_old VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio_old VARCHAR(100) DEFAULT NULL;
   DECLARE v_estatus_aprobacion_old VARCHAR(20) DEFAULT 'Activo';
   DECLARE v_estatus_aprobacion_new VARCHAR(20) DEFAULT 'Activo';
   
   -- Validamos el estatus del registro antiguo y nuevo y les asignamos una etiqueta para la descripción
   IF NOT OLD.Estatus_Aprobacion THEN
      SET v_estatus_aprobacion_old = 'Inactivo';
   END IF;

   IF NOT NEW.Estatus_Aprobacion THEN
      SET v_estatus_aprobacion_new = 'Inactivo';
   END IF;

   -- Obtener el nombre del paciente antes y después de la actualización
   SET nombre_paciente_new = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                             FROM tbb_personas p
                             WHERE p.id = NEW.paciente_ID);
   SET nombre_paciente_old = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                             FROM tbb_personas p
                             WHERE p.id = OLD.paciente_ID);

   -- Obtener el nombre del personal medico antes y después de la actualización
   SET nombre_medico_new = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                           FROM tbb_personas p
                           WHERE p.id = NEW.medico_ID);
   SET nombre_medico_old = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                           FROM tbb_personas p
                           WHERE p.id = OLD.medico_ID);
                         
   -- Obtener el nombre del servicio antes y después de la actualización
   SET nombre_servicio_new = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = NEW.servicio_ID);
   SET nombre_servicio_old = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = OLD.servicio_ID);

   INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) VALUES (
      CURRENT_USER(), 
      'Update', 
      'tbd_solicitudes', 
      CONCAT_WS(" ", 'Se ha modificado una solicitud con los siguientes datos:',
      'Nombre del Paciente: ', nombre_paciente_old, ' - ', nombre_paciente_new, '\n',
      'Nombre del Medico: ', nombre_medico_old, ' - ', nombre_medico_new, '\n',
      'Nombre del Servicio: ', nombre_servicio_old, ' - ', nombre_servicio_new, '\n',
      'Prioridad: ', OLD.Prioridad, ' - ', NEW.Prioridad, '\n',
      'Descripcion: ', OLD.Descripcion, ' - ', NEW.Descripcion, '\n',
      'Estatus de la solicitud: ', OLD.Estatus, ' - ', NEW.Estatus, '\n',
      'Estatus de Aprobación: ', v_estatus_aprobacion_old, ' - ',v_estatus_aprobacion_new),
      DEFAULT,
      DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_solicitudes_AFTER_DELETE` AFTER DELETE ON `tbd_solicitudes` FOR EACH ROW BEGIN
   DECLARE nombre_paciente VARCHAR(150) DEFAULT NULL;
   DECLARE nombre_medico VARCHAR(100) DEFAULT NULL;
   DECLARE nombre_servicio VARCHAR(100) DEFAULT NULL;
   DECLARE v_estatus_aprobacion VARCHAR(20) DEFAULT 'Activo';
   
   -- Validamos el estatus del registro y le asignamos una etiqueta para la descripción
   IF NOT OLD.Estatus_Aprobacion THEN
      SET v_estatus_aprobacion = 'Inactivo';
   END IF;

   -- Obtener el nombre del paciente eliminado
   SET nombre_paciente = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = OLD.paciente_ID);

   -- Obtener el nombre del médico eliminado
   SET nombre_medico = (SELECT CONCAT_WS(" ", p.Nombre, p.Primer_Apellido, p.Segundo_Apellido)
                         FROM tbb_personas p
                         WHERE p.id = OLD.medico_ID);

   -- Obtener el nombre del servicio eliminado
   SET nombre_servicio = (SELECT nombre FROM tbc_servicios_medicos s WHERE s.id = OLD.servicio_ID);

   INSERT INTO tbi_bitacora (Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro) VALUES (
      CURRENT_USER(), 
      'Delete', 
      'tbd_solicitudes', 
      CONCAT_WS(" ", 'Se ha eliminado una solicitud existente con los siguientes datos: ',
      'ID: ', OLD.ID, '\n',
      'Nombre del Paciente: ', nombre_paciente, '\n',
      'Nombre del Medico: ', nombre_medico, '\n',
      'Nombre del Servicio: ', nombre_servicio, '\n',
      'Prioridad: ', OLD.Prioridad, '\n',
      'Descripcion: ', OLD.Descripcion, '\n',
      'Estatus de la solicitud: ', OLD.Estatus, '\n',
      'Estatus de Aprobación: ', v_estatus_aprobacion),
      DEFAULT,
      DEFAULT);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbd_usuarios_roles`
--

DROP TABLE IF EXISTS `tbd_usuarios_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbd_usuarios_roles` (
  `Usuario_ID` char(36) NOT NULL DEFAULT (uuid()),
  `Rol_ID` char(36) NOT NULL DEFAULT (uuid()),
  `Estatus` bit(1) DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Fecha_Actualizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`Usuario_ID`,`Rol_ID`),
  KEY `Rol_ID` (`Rol_ID`),
  CONSTRAINT `FK_Rol_1` FOREIGN KEY (`Rol_ID`) REFERENCES `tbc_roles` (`ID`),
  CONSTRAINT `FK_Usuario_1` FOREIGN KEY (`Usuario_ID`) REFERENCES `tbb_usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbd_usuarios_roles`
--

LOCK TABLES `tbd_usuarios_roles` WRITE;
/*!40000 ALTER TABLE `tbd_usuarios_roles` DISABLE KEYS */;
INSERT INTO `tbd_usuarios_roles` VALUES ('09081bd7-0ff8-11f0-b70d-3c557613b8e0','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:20:45',NULL),('125f31e8-0ff8-11f0-b70d-3c557613b8e0','823e3ba2-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-04-02 13:24:18',NULL),('26fd5f79-11a9-11f0-b70d-3c557613b8e0','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-04-04 17:04:24',NULL),('5254a4c9-0ff8-11f0-b70d-3c557613b8e0','823daf15-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-04-02 13:26:05',NULL),('ba6db346-51e8-11f0-9f2b-00155d276843','823d3678-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:20:45',NULL),('ba6eda76-51e8-11f0-9f2b-00155d276843','823daf15-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:20:45',NULL),('ba6fa70e-51e8-11f0-9f2b-00155d276843','823daf15-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:20:45',NULL),('ef4f7361-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef4fe4d6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5024bd-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef505d45-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5089d7-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef50acd2-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef50d31f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef50f47c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef511766-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef513dba-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5161c7-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5189e8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef51dbe1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef521ea6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef525180-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef527890-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef52ac56-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef52e2a0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef53092a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef532f4e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5353ae-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef538166-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef53b3a1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef53e81f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef544353-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5468e0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef549bb2-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef54c7f3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef54f66c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef55276c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef554dd4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef557207-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5591cc-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef55b5e6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef55dc01-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef55fb61-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef565980-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef56cb37-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef56f935-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5723c6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef576781-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef57a8cd-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5839a2-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef586190-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef588284-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef589efd-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef58dd38-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef591065-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5936dc-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef595dac-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5983d1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef59aaea-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef59d8a6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5a09b2-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5a379b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5a641d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5a825c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5aa0af-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5abdc5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5adabb-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5afa4e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5b32aa-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5b7dae-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5ba636-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5bcb57-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5bf495-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5c1761-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5c3c46-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5c6833-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5c8d9d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5cb174-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5cd6ac-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5cfeda-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5d267f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5d4780-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5d8a2c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5dca8d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5df76e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5e1ba6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5e3a66-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5efc09-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5f2674-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5f501a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5f82c9-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef5fb0b1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef600058-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef603661-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef606641-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef608f44-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef60b619-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef60e376-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef610926-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef613d15-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef617d79-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef61a9ad-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef61cd68-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef61f126-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef621630-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6269a0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef62a297-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef62cd48-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef62efa8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6317f4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef633c35-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef635cf0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef637b9e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef639978-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef63b7c9-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef63d5d0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef640371-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef642a06-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef64578b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef64870d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef64cebc-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef650d47-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef653f5b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6578c3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef65ae33-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef65e7fa-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef661b7c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef664339-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef666adb-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef66a2b1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef672b5c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6758d2-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef678a58-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef67b36b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef67dd9b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef684e96-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef687bbd-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef689ead-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef68c671-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef68ec45-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef692626-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef698b2e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef69d1ac-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef69ff62-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6a2b8c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6a6fe6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6aa3ce-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6acbbf-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6af916-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6b1e1a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6b43a1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6b6653-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6bb5aa-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6c06c1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6cb4ae-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6ce494-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6d14a7-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6d36e1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6d5c79-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6d8ef3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6dc92c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6e07f4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6e5f55-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6e8f5f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6ed36b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6f039f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6f2e69-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6f560d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6f83b1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6fb04a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef6fdf05-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef700735-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef70360c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef706ed8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef70e5e1-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef715409-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef71cb23-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef71fd9f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef722256-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef724089-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef725f4d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:13',NULL),('ef727fbb-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef72a950-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef72cefc-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef733fd9-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef73ba61-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef73fa91-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7423e3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef744a79-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef746a07-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef748cc6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef74b93a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef74f10a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef752c2f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef758d93-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef75f871-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7636a4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef766513-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef768f51-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef76b830-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef76dfa4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef770f28-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef773d64-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7764f3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef778ccc-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef790c20-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef793ec5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef796c30-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef799030-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef79b4f0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef79d974-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef79fd25-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7a404e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7abc5c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7b14b4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7ba9a5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7bdc78-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7c0bea-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7c3881-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7c6aca-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7cd69c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7d0da9-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7d43c7-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7d7ea6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7e18aa-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7e3f91-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7ea0d4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7ed0df-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7f3f12-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef7f8c49-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef801085-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef803cf5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef806322-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef809028-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef80d35c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef80f97d-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef812025-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef815d32-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef81880a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef81a77f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef81c731-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef81e5c8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef820523-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8221e5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef823f19-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8276f8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef82a467-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef82cf49-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef831ac6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef834739-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8395f6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef83d457-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef83f6bf-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8419d3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef843d29-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef846192-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef848f73-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef84b5f8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef84dd0c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef85090b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef852e3a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef85b565-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef85efcc-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef864b44-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef86744c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8695a4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef86b4b7-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef86da9c-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef86fccd-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef87b11b-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef87dbb3-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef87fdba-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef881f4e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef88667f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef889a78-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef88bb86-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef88d9ae-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef88fca0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef891d12-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef893f57-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef896038-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef898434-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef89a694-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef89c842-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef89f0f2-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8a1a63-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8a43a4-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8a6fdf-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8b60a6-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8bc8b5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8bf4fa-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8c25a9-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8c573a-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8c8b8f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8cbf60-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8d4097-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8dc2c5-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8e2c9f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8eb79e-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8ee475-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef8f09a0-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef900100-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef903c77-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef907b15-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef90bb2f-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef90f9a8-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL),('ef913676-51e8-11f0-9f2b-00155d276843','823b1a21-0ff7-11f0-b70d-3c557613b8e0',_binary '','2025-06-25 11:22:14',NULL);
/*!40000 ALTER TABLE `tbd_usuarios_roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_AFTER_INSERT` AFTER INSERT ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
    DECLARE v_email_usuario VARCHAR(60);
    DECLARE v_nombre_rol VARCHAR(50);

    -- Obtener correo del usuario
    SELECT correo_electronico 
    INTO v_email_usuario
    FROM tbb_usuarios
    WHERE id = NEW.usuario_id;

    -- Obtener nombre del rol
    SELECT nombre 
    INTO v_nombre_rol
    FROM tbc_roles
    WHERE id = NEW.rol_id;

    -- Insertar en bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro

    ) VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Create',
        'tbd_usuarios_roles',
        CONCAT_WS('\n',
            CONCAT('Se ha asignado el ROL: ', v_nombre_rol),
            CONCAT('Al USUARIO con correo: ', v_email_usuario),
            CONCAT('Estatus: ', NEW.estatus)
        ),
		b'1',
        NOW()

    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_BEFORE_UPDATE` BEFORE UPDATE ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
   SET new.fecha_actualizacion = current_timestamp();

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_AFTER_UPDATE` AFTER UPDATE ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
    DECLARE v_email_usuario VARCHAR(60);
    DECLARE v_nombre_rol_old VARCHAR(50);
    DECLARE v_nombre_rol_new VARCHAR(50);

    -- Obtener correo del usuario
    SELECT correo_electronico 
    INTO v_email_usuario
    FROM tbb_usuarios
    WHERE id = OLD.usuario_id;

    -- Obtener nombre del rol antiguo
    SELECT nombre 
    INTO v_nombre_rol_old
    FROM tbc_roles
    WHERE id = OLD.rol_id;

    -- Obtener nombre del rol nuevo
    SELECT nombre 
    INTO v_nombre_rol_new
    FROM tbc_roles
    WHERE id = NEW.rol_id;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro

    ) VALUES (
        DEFAULT,
        CURRENT_USER(),
        'Update',
        'tbd_usuarios_roles',
        CONCAT_WS('\n',
            CONCAT('Se ha actualizado el ROL del usuario con correo: ', v_email_usuario),
            CONCAT('Rol anterior: ', v_nombre_rol_old),
            CONCAT('Rol nuevo: ', v_nombre_rol_new),
            CONCAT('Estatus anterior: ', OLD.estatus),
            CONCAT('Estatus nuevo: ', NEW.estatus)
        ),
		b'1',
        NOW()

    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tbd_usuarios_roles_AFTER_DELETE` AFTER DELETE ON `tbd_usuarios_roles` FOR EACH ROW BEGIN
    DECLARE v_email_usuario VARCHAR(60);
    DECLARE v_nombre_rol VARCHAR(50);

    -- Obtener correo electrónico del usuario eliminado
    SELECT correo_electronico 
    INTO v_email_usuario
    FROM tbb_usuarios
    WHERE id = OLD.usuario_id;

    -- Obtener nombre del rol eliminado
    SELECT nombre 
    INTO v_nombre_rol
    FROM tbc_roles
    WHERE id = OLD.rol_id;

    -- Insertar en la bitácora
    INSERT INTO tbi_bitacora (
        ID, Usuario, Operacion, Tabla, Descripcion, Estatus, Fecha_Registro

    ) VALUES (
        DEFAULT,
        USER(),
        'Delete',
        'tbd_usuarios_roles',
        CONCAT_WS('\n',
            CONCAT('Se ha eliminado el ROL: ', v_nombre_rol),
            CONCAT('Al USUARIO con correo: ', v_email_usuario),
            CONCAT('Estatus antes de eliminar: ', OLD.estatus)
        ),
		b'1',
        NOW()

    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tbi_bitacora`
--

DROP TABLE IF EXISTS `tbi_bitacora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbi_bitacora` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `Usuario` varchar(50) NOT NULL,
  `Operacion` enum('Create','Read','Update','Delete') NOT NULL,
  `Tabla` varchar(50) NOT NULL,
  `Descripcion` text NOT NULL,
  `Estatus` bit(1) DEFAULT b'1',
  `Fecha_Registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=777 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbi_bitacora`
--

LOCK TABLES `tbi_bitacora` WRITE;
/*!40000 ALTER TABLE `tbi_bitacora` DISABLE KEYS */;
INSERT INTO `tbi_bitacora` VALUES (1,'root@localhost','Create','tbc_areas_medicas','Se ha creado una nueva área médica con los siguientes datos:\nID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicios Medicos\nAbreviatura: SM\nDescripción: Por definir\nEstatus: Activo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(2,'root@localhost','Create','tbc_areas_medicas','Se ha creado una nueva área médica con los siguientes datos:\nID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicios de Apoyo\nAbreviatura: SA\nDescripción: Por definir\nEstatus: Activo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(3,'root@localhost','Create','tbc_areas_medicas','Se ha creado una nueva área médica con los siguientes datos:\nID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicios Medico - Administrativos\nAbreviatura: SMA\nDescripción: Por definir\nEstatus: Activo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(4,'root@localhost','Create','tbc_areas_medicas','Se ha creado una nueva área médica con los siguientes datos:\nID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicios de Enfermeria\nAbreviatura: SE\nDescripción: Por definir\nEstatus: Activo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(5,'root@localhost','Create','tbc_areas_medicas','Se ha creado una nueva área médica con los siguientes datos:\nID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nNombre: Departamentos Administrativos\nAbreviatura: DA\nDescripción: Por definir\nEstatus: Activo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(6,'root@localhost','Create','tbc_areas_medicas','Se ha creado una nueva área médica con los siguientes datos:\nID: 7d69fdf1-0ff7-11f0-b70d-3c557613b8e0\nNombre: Nueva Área Médica\nAbreviatura: NAM\nDescripción: Por definir\nEstatus: Activo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(7,'root@localhost','Update','tbc_areas_medicas','Se ha actualizado un área médica. Detalles de la actualización:\nID: 7d69fdf1-0ff7-11f0-b70d-3c557613b8e0\nNombre Anterior: Nueva Área Médica\nNuevo Nombre: Nueva Área Médica\nNueva Abreviatura: NAM\nDescripción Anterior: Por definir\nNueva Descripción: Por definir\nEstatus Anterior: Activo\nNuevo Estatus: Inactivo\nFecha de Actualización: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(8,'root@localhost','Delete','tbc_areas_medicas','Se ha eliminado un área médica. Detalles de la eliminación:\nID: 7d69fdf1-0ff7-11f0-b70d-3c557613b8e0\nNombre: Nueva Área Médica\nAbreviatura: NAM\nDescripción: Por definir\nEstatus: Inactivo\nFecha de Registro: 2025-04-02 13:20:08',_binary '','2025-04-02 13:20:08'),(9,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe02f2d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Dirección General\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DG',_binary '','2025-04-02 13:20:12'),(10,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03142-0ff7-11f0-b70d-3c557613b8e0\nNombre: Junta de Gobierno\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: JG',_binary '','2025-04-02 13:20:12'),(11,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0321f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Departamento de Calidad\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DC',_binary '','2025-04-02 13:20:12'),(12,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe032d6-0ff7-11f0-b70d-3c557613b8e0\nNombre: Comité de Transplante\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CT',_binary '','2025-04-02 13:20:12'),(13,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03356-0ff7-11f0-b70d-3c557613b8e0\nNombre: Sub-Dirección Médica\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SM',_binary '','2025-04-02 13:20:12'),(14,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe033bb-0ff7-11f0-b70d-3c557613b8e0\nNombre: Sub-Dirección Administrativa\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SA',_binary '','2025-04-02 13:20:12'),(15,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0343c-0ff7-11f0-b70d-3c557613b8e0\nNombre: Comités Hospitalarios\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CH',_binary '','2025-04-02 13:20:12'),(16,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe034de-0ff7-11f0-b70d-3c557613b8e0\nNombre: Atención a Quejas\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: AQ',_binary '','2025-04-02 13:20:12'),(17,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03587-0ff7-11f0-b70d-3c557613b8e0\nNombre: Seguridad del Paciente\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SP',_binary '','2025-04-02 13:20:12'),(18,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03624-0ff7-11f0-b70d-3c557613b8e0\nNombre: Comunicación Social\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CS',_binary '','2025-04-02 13:20:12'),(19,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe036c5-0ff7-11f0-b70d-3c557613b8e0\nNombre: Relaciones Públicas\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RP',_binary '','2025-04-02 13:20:12'),(20,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0374b-0ff7-11f0-b70d-3c557613b8e0\nNombre: Coordinación de Asuntos Jurídicos y Administrativos\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CAJAA',_binary '','2025-04-02 13:20:12'),(21,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe037c6-0ff7-11f0-b70d-3c557613b8e0\nNombre: Violencia Intrafamiliar\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: VI',_binary '','2025-04-02 13:20:12'),(22,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03860-0ff7-11f0-b70d-3c557613b8e0\nNombre: Medicinal Legal\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: ML',_binary '','2025-04-02 13:20:12'),(23,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe038fd-0ff7-11f0-b70d-3c557613b8e0\nNombre: Trabajo Social\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: TS',_binary '','2025-04-02 13:20:12'),(24,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe039a1-0ff7-11f0-b70d-3c557613b8e0\nNombre: Unidad de Vigilancia Epidemiológica Hospitalaria\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: UVEH',_binary '','2025-04-02 13:20:12'),(25,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03a41-0ff7-11f0-b70d-3c557613b8e0\nNombre: Centro de Investigación de Estudios de la Salud\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CIES',_binary '','2025-04-02 13:20:12'),(26,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03ae2-0ff7-11f0-b70d-3c557613b8e0\nNombre: Ética e Investigación\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: EI',_binary '','2025-04-02 13:20:12'),(27,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03b7f-0ff7-11f0-b70d-3c557613b8e0\nNombre: División de Medicina Interna\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DMI',_binary '','2025-04-02 13:20:12'),(28,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03bf0-0ff7-11f0-b70d-3c557613b8e0\nNombre: División de Cirugía\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DCI',_binary '','2025-04-02 13:20:12'),(29,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03c5a-0ff7-11f0-b70d-3c557613b8e0\nNombre: División de Pediatría\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DP',_binary '','2025-04-02 13:20:12'),(30,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03cc3-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicio de Urgencias Adultos\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SUA',_binary '','2025-04-02 13:20:12'),(31,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03d0e-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicio de Urgencias Pediátricas\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SUP',_binary '','2025-04-02 13:20:12'),(32,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03d4c-0ff7-11f0-b70d-3c557613b8e0\nNombre: Terapia Intensiva\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: TI',_binary '','2025-04-02 13:20:12'),(33,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03d88-0ff7-11f0-b70d-3c557613b8e0\nNombre: Terapia Intermedia\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: TIM',_binary '','2025-04-02 13:20:12'),(34,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03dc3-0ff7-11f0-b70d-3c557613b8e0\nNombre: Quirófano y Anestesiología\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: QA',_binary '','2025-04-02 13:20:12'),(35,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03e00-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicio de Traumatología\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: ST',_binary '','2025-04-02 13:20:12'),(36,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03e3d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Programación Quirúrgica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: PQ',_binary '','2025-04-02 13:20:12'),(37,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03e78-0ff7-11f0-b70d-3c557613b8e0\nNombre: Centro de Mezclas\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CM',_binary '','2025-04-02 13:20:12'),(38,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03eb5-0ff7-11f0-b70d-3c557613b8e0\nNombre: Radiología e Imagen\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RI',_binary '','2025-04-02 13:20:12'),(39,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03ef2-0ff7-11f0-b70d-3c557613b8e0\nNombre: Genética\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: G',_binary '','2025-04-02 13:20:12'),(40,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03f2f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Laboratorio de Análisis Clínicos\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: LAC',_binary '','2025-04-02 13:20:12'),(41,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03f6d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Laboratorio de Histocompatibilidad\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: LH',_binary '','2025-04-02 13:20:12'),(42,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03faa-0ff7-11f0-b70d-3c557613b8e0\nNombre: Hemodialisis\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: H',_binary '','2025-04-02 13:20:12'),(43,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe03fe7-0ff7-11f0-b70d-3c557613b8e0\nNombre: Laboratorio de Patología\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: LP',_binary '','2025-04-02 13:20:12'),(44,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04023-0ff7-11f0-b70d-3c557613b8e0\nNombre: Rehabilitación Pulmonar\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RPUL',_binary '','2025-04-02 13:20:12'),(45,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0405f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Medicina Genómica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: MG',_binary '','2025-04-02 13:20:12'),(46,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0409b-0ff7-11f0-b70d-3c557613b8e0\nNombre: Banco de Sangre\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: BS',_binary '','2025-04-02 13:20:12'),(47,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe040d8-0ff7-11f0-b70d-3c557613b8e0\nNombre: Aféresis\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: AF',_binary '','2025-04-02 13:20:12'),(48,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04114-0ff7-11f0-b70d-3c557613b8e0\nNombre: Tele-Robótica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: TR',_binary '','2025-04-02 13:20:12'),(49,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04150-0ff7-11f0-b70d-3c557613b8e0\nNombre: Jefatura de Enseñanza Médica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: JEM',_binary '','2025-04-02 13:20:12'),(50,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0418d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Consulta Externa\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CE',_binary '','2025-04-02 13:20:12'),(51,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe041ca-0ff7-11f0-b70d-3c557613b8e0\nNombre: Terapia y Rehabilitación Física\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: TRF',_binary '','2025-04-02 13:20:12'),(52,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04206-0ff7-11f0-b70d-3c557613b8e0\nNombre: Jefatura de Enfermería\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: JE',_binary '','2025-04-02 13:20:12'),(53,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04275-0ff7-11f0-b70d-3c557613b8e0\nNombre: Subjefatura de Enfermeras\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SE',_binary '','2025-04-02 13:20:12'),(54,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe042e5-0ff7-11f0-b70d-3c557613b8e0\nNombre: Coordinación Enseñanza Enfermería\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CEE',_binary '','2025-04-02 13:20:12'),(55,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04355-0ff7-11f0-b70d-3c557613b8e0\nNombre: Supervisoras de Turno\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: STUR',_binary '','2025-04-02 13:20:12'),(56,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe043c2-0ff7-11f0-b70d-3c557613b8e0\nNombre: Jefas de Servicio\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: JS',_binary '','2025-04-02 13:20:12'),(57,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0442f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Clínicas y Programas\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CP',_binary '','2025-04-02 13:20:12'),(58,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0449e-0ff7-11f0-b70d-3c557613b8e0\nNombre: Recursos Humanos\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RH',_binary '','2025-04-02 13:20:12'),(59,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04520-0ff7-11f0-b70d-3c557613b8e0\nNombre: Archivo y Correspondencia\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: AC',_binary '','2025-04-02 13:20:12'),(60,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0459c-0ff7-11f0-b70d-3c557613b8e0\nNombre: Recursos Financieros\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RF',_binary '','2025-04-02 13:20:12'),(61,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04617-0ff7-11f0-b70d-3c557613b8e0\nNombre: Departamento Administrativo Hemodinamia\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DAH',_binary '','2025-04-02 13:20:12'),(62,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04692-0ff7-11f0-b70d-3c557613b8e0\nNombre: Farmacia del Seguro Popular\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: FSP',_binary '','2025-04-02 13:20:12'),(63,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe0470d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Enlace Administrativo\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: EA',_binary '','2025-04-02 13:20:12'),(64,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04789-0ff7-11f0-b70d-3c557613b8e0\nNombre: Control de Gastos Catastróficos\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: CGC',_binary '','2025-04-02 13:20:12'),(65,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04804-0ff7-11f0-b70d-3c557613b8e0\nNombre: Informática\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: INF',_binary '','2025-04-02 13:20:12'),(66,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04881-0ff7-11f0-b70d-3c557613b8e0\nNombre: Tecnología en la Salud\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: TS',_binary '','2025-04-02 13:20:12'),(67,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe048fc-0ff7-11f0-b70d-3c557613b8e0\nNombre: Registros Médicos\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RM',_binary '','2025-04-02 13:20:12'),(68,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04977-0ff7-11f0-b70d-3c557613b8e0\nNombre: Biomédica Conservación y Mantenimiento\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: BCM',_binary '','2025-04-02 13:20:12'),(69,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe049ca-0ff7-11f0-b70d-3c557613b8e0\nNombre: Validación\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: VAL',_binary '','2025-04-02 13:20:12'),(70,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04a1a-0ff7-11f0-b70d-3c557613b8e0\nNombre: Recursos Materiales\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: RMAT',_binary '','2025-04-02 13:20:12'),(71,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04a6a-0ff7-11f0-b70d-3c557613b8e0\nNombre: Almacén\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: ALM',_binary '','2025-04-02 13:20:12'),(72,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04aba-0ff7-11f0-b70d-3c557613b8e0\nNombre: Insumos Especializados\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: IE',_binary '','2025-04-02 13:20:12'),(73,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04b09-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicios Generales\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: SG',_binary '','2025-04-02 13:20:12'),(74,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04b59-0ff7-11f0-b70d-3c557613b8e0\nNombre: Intendencia\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: INT',_binary '','2025-04-02 13:20:12'),(75,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04ba9-0ff7-11f0-b70d-3c557613b8e0\nNombre: Ropería\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: ROP',_binary '','2025-04-02 13:20:12'),(76,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04bf9-0ff7-11f0-b70d-3c557613b8e0\nNombre: Vigilancia\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: VIG',_binary '','2025-04-02 13:20:12'),(77,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04c49-0ff7-11f0-b70d-3c557613b8e0\nNombre: Dietética\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: DIE',_binary '','2025-04-02 13:20:12'),(78,'root@localhost','Create','tbc_departamentos','Se ha agregado un nuevo DEPARTAMENTO con ID: 7fe04c99-0ff7-11f0-b70d-3c557613b8e0\nNombre: Farmacia Intrahospitalaria\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1\nAbreviatura: FIH',_binary '','2025-04-02 13:20:12'),(79,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe02f2d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Dirección General → Dirección General\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DG → DG',_binary '','2025-04-02 13:20:12'),(80,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03142-0ff7-11f0-b70d-3c557613b8e0\nNombre: Junta de Gobierno → Junta de Gobierno\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: JG → JG',_binary '','2025-04-02 13:20:12'),(81,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0321f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Departamento de Calidad → Departamento de Calidad\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DC → DC',_binary '','2025-04-02 13:20:12'),(82,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe032d6-0ff7-11f0-b70d-3c557613b8e0\nNombre: Comité de Transplante → Comité de Transplante\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CT → CT',_binary '','2025-04-02 13:20:12'),(83,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03356-0ff7-11f0-b70d-3c557613b8e0\nNombre: Sub-Dirección Médica → Sub-Dirección Médica\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SM → SM',_binary '','2025-04-02 13:20:12'),(84,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe033bb-0ff7-11f0-b70d-3c557613b8e0\nNombre: Sub-Dirección Administrativa → Sub-Dirección Administrativa\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SA → SA',_binary '','2025-04-02 13:20:12'),(85,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0343c-0ff7-11f0-b70d-3c557613b8e0\nNombre: Comités Hospitalarios → Comités Hospitalarios\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CH → CH',_binary '','2025-04-02 13:20:12'),(86,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe034de-0ff7-11f0-b70d-3c557613b8e0\nNombre: Atención a Quejas → Atención a Quejas\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: AQ → AQ',_binary '','2025-04-02 13:20:12'),(87,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03587-0ff7-11f0-b70d-3c557613b8e0\nNombre: Seguridad del Paciente → Seguridad del Paciente\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SP → SP',_binary '','2025-04-02 13:20:12'),(88,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03624-0ff7-11f0-b70d-3c557613b8e0\nNombre: Comunicación Social → Comunicación Social\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CS → CS',_binary '','2025-04-02 13:20:12'),(89,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe036c5-0ff7-11f0-b70d-3c557613b8e0\nNombre: Relaciones Públicas → Relaciones Públicas\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RP → RP',_binary '','2025-04-02 13:20:12'),(90,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0374b-0ff7-11f0-b70d-3c557613b8e0\nNombre: Coordinación de Asuntos Jurídicos y Administrativos → Coordinación de Asuntos Jurídicos y Administrativos\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CAJAA → CAJAA',_binary '','2025-04-02 13:20:12'),(91,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe037c6-0ff7-11f0-b70d-3c557613b8e0\nNombre: Violencia Intrafamiliar → Violencia Intrafamiliar\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: VI → VI',_binary '','2025-04-02 13:20:12'),(92,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03860-0ff7-11f0-b70d-3c557613b8e0\nNombre: Medicinal Legal → Medicinal Legal\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: ML → ML',_binary '','2025-04-02 13:20:12'),(93,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe038fd-0ff7-11f0-b70d-3c557613b8e0\nNombre: Trabajo Social → Trabajo Social\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: TS → TS',_binary '','2025-04-02 13:20:12'),(94,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe039a1-0ff7-11f0-b70d-3c557613b8e0\nNombre: Unidad de Vigilancia Epidemiológica Hospitalaria → Unidad de Vigilancia Epidemiológica Hospitalaria\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: UVEH → UVEH',_binary '','2025-04-02 13:20:12'),(95,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03a41-0ff7-11f0-b70d-3c557613b8e0\nNombre: Centro de Investigación de Estudios de la Salud → Centro de Investigación de Estudios de la Salud\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CIES → CIES',_binary '','2025-04-02 13:20:12'),(96,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03ae2-0ff7-11f0-b70d-3c557613b8e0\nNombre: Ética e Investigación → Ética e Investigación\nÁrea Médica ID: 7d68c571-0ff7-11f0-b70d-3c557613b8e0 → 7d68c571-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: EI → EI',_binary '','2025-04-02 13:20:12'),(97,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03b7f-0ff7-11f0-b70d-3c557613b8e0\nNombre: División de Medicina Interna → División de Medicina Interna\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DMI → DMI',_binary '','2025-04-02 13:20:12'),(98,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03bf0-0ff7-11f0-b70d-3c557613b8e0\nNombre: División de Cirugía → División de Cirugía\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DCI → DCI',_binary '','2025-04-02 13:20:12'),(99,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03c5a-0ff7-11f0-b70d-3c557613b8e0\nNombre: División de Pediatría → División de Pediatría\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DP → DP',_binary '','2025-04-02 13:20:12'),(100,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03cc3-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicio de Urgencias Adultos → Servicio de Urgencias Adultos\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SUA → SUA',_binary '','2025-04-02 13:20:12'),(101,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03d0e-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicio de Urgencias Pediátricas → Servicio de Urgencias Pediátricas\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SUP → SUP',_binary '','2025-04-02 13:20:12'),(102,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03d4c-0ff7-11f0-b70d-3c557613b8e0\nNombre: Terapia Intensiva → Terapia Intensiva\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: TI → TI',_binary '','2025-04-02 13:20:12'),(103,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03d88-0ff7-11f0-b70d-3c557613b8e0\nNombre: Terapia Intermedia → Terapia Intermedia\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: TIM → TIM',_binary '','2025-04-02 13:20:12'),(104,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03dc3-0ff7-11f0-b70d-3c557613b8e0\nNombre: Quirófano y Anestesiología → Quirófano y Anestesiología\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: QA → QA',_binary '','2025-04-02 13:20:12'),(105,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03e00-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicio de Traumatología → Servicio de Traumatología\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: ST → ST',_binary '','2025-04-02 13:20:12'),(106,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03e3d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Programación Quirúrgica → Programación Quirúrgica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: PQ → PQ',_binary '','2025-04-02 13:20:12'),(107,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03e78-0ff7-11f0-b70d-3c557613b8e0\nNombre: Centro de Mezclas → Centro de Mezclas\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CM → CM',_binary '','2025-04-02 13:20:12'),(108,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03eb5-0ff7-11f0-b70d-3c557613b8e0\nNombre: Radiología e Imagen → Radiología e Imagen\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RI → RI',_binary '','2025-04-02 13:20:12'),(109,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03ef2-0ff7-11f0-b70d-3c557613b8e0\nNombre: Genética → Genética\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: G → G',_binary '','2025-04-02 13:20:12'),(110,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03f2f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Laboratorio de Análisis Clínicos → Laboratorio de Análisis Clínicos\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: LAC → LAC',_binary '','2025-04-02 13:20:12'),(111,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03f6d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Laboratorio de Histocompatibilidad → Laboratorio de Histocompatibilidad\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: LH → LH',_binary '','2025-04-02 13:20:12'),(112,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03faa-0ff7-11f0-b70d-3c557613b8e0\nNombre: Hemodialisis → Hemodialisis\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: H → H',_binary '','2025-04-02 13:20:12'),(113,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe03fe7-0ff7-11f0-b70d-3c557613b8e0\nNombre: Laboratorio de Patología → Laboratorio de Patología\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: LP → LP',_binary '','2025-04-02 13:20:12'),(114,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04023-0ff7-11f0-b70d-3c557613b8e0\nNombre: Rehabilitación Pulmonar → Rehabilitación Pulmonar\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RPUL → RPUL',_binary '','2025-04-02 13:20:12'),(115,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0405f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Medicina Genómica → Medicina Genómica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: MG → MG',_binary '','2025-04-02 13:20:12'),(116,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0409b-0ff7-11f0-b70d-3c557613b8e0\nNombre: Banco de Sangre → Banco de Sangre\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: BS → BS',_binary '','2025-04-02 13:20:12'),(117,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe040d8-0ff7-11f0-b70d-3c557613b8e0\nNombre: Aféresis → Aféresis\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: AF → AF',_binary '','2025-04-02 13:20:12'),(118,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04114-0ff7-11f0-b70d-3c557613b8e0\nNombre: Tele-Robótica → Tele-Robótica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: TR → TR',_binary '','2025-04-02 13:20:12'),(119,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04150-0ff7-11f0-b70d-3c557613b8e0\nNombre: Jefatura de Enseñanza Médica → Jefatura de Enseñanza Médica\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: JEM → JEM',_binary '','2025-04-02 13:20:12'),(120,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0418d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Consulta Externa → Consulta Externa\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CE → CE',_binary '','2025-04-02 13:20:12'),(121,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe041ca-0ff7-11f0-b70d-3c557613b8e0\nNombre: Terapia y Rehabilitación Física → Terapia y Rehabilitación Física\nÁrea Médica ID: 7d67e532-0ff7-11f0-b70d-3c557613b8e0 → 7d67e532-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: TRF → TRF',_binary '','2025-04-02 13:20:12'),(122,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04206-0ff7-11f0-b70d-3c557613b8e0\nNombre: Jefatura de Enfermería → Jefatura de Enfermería\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0 → 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: JE → JE',_binary '','2025-04-02 13:20:12'),(123,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04275-0ff7-11f0-b70d-3c557613b8e0\nNombre: Subjefatura de Enfermeras → Subjefatura de Enfermeras\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0 → 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SE → SE',_binary '','2025-04-02 13:20:12'),(124,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe042e5-0ff7-11f0-b70d-3c557613b8e0\nNombre: Coordinación Enseñanza Enfermería → Coordinación Enseñanza Enfermería\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0 → 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CEE → CEE',_binary '','2025-04-02 13:20:12'),(125,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04355-0ff7-11f0-b70d-3c557613b8e0\nNombre: Supervisoras de Turno → Supervisoras de Turno\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0 → 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: STUR → STUR',_binary '','2025-04-02 13:20:12'),(126,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe043c2-0ff7-11f0-b70d-3c557613b8e0\nNombre: Jefas de Servicio → Jefas de Servicio\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0 → 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: JS → JS',_binary '','2025-04-02 13:20:12'),(127,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0442f-0ff7-11f0-b70d-3c557613b8e0\nNombre: Clínicas y Programas → Clínicas y Programas\nÁrea Médica ID: 7d693e28-0ff7-11f0-b70d-3c557613b8e0 → 7d693e28-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CP → CP',_binary '','2025-04-02 13:20:12'),(128,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0449e-0ff7-11f0-b70d-3c557613b8e0\nNombre: Recursos Humanos → Recursos Humanos\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RH → RH',_binary '','2025-04-02 13:20:12'),(129,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04520-0ff7-11f0-b70d-3c557613b8e0\nNombre: Archivo y Correspondencia → Archivo y Correspondencia\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: AC → AC',_binary '','2025-04-02 13:20:12'),(130,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0459c-0ff7-11f0-b70d-3c557613b8e0\nNombre: Recursos Financieros → Recursos Financieros\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RF → RF',_binary '','2025-04-02 13:20:12'),(131,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04617-0ff7-11f0-b70d-3c557613b8e0\nNombre: Departamento Administrativo Hemodinamia → Departamento Administrativo Hemodinamia\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DAH → DAH',_binary '','2025-04-02 13:20:12'),(132,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04692-0ff7-11f0-b70d-3c557613b8e0\nNombre: Farmacia del Seguro Popular → Farmacia del Seguro Popular\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: FSP → FSP',_binary '','2025-04-02 13:20:12'),(133,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe0470d-0ff7-11f0-b70d-3c557613b8e0\nNombre: Enlace Administrativo → Enlace Administrativo\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: EA → EA',_binary '','2025-04-02 13:20:12'),(134,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04789-0ff7-11f0-b70d-3c557613b8e0\nNombre: Control de Gastos Catastróficos → Control de Gastos Catastróficos\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: CGC → CGC',_binary '','2025-04-02 13:20:12'),(135,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04804-0ff7-11f0-b70d-3c557613b8e0\nNombre: Informática → Informática\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: INF → INF',_binary '','2025-04-02 13:20:12'),(136,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04881-0ff7-11f0-b70d-3c557613b8e0\nNombre: Tecnología en la Salud → Tecnología en la Salud\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: TS → TS',_binary '','2025-04-02 13:20:12'),(137,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe048fc-0ff7-11f0-b70d-3c557613b8e0\nNombre: Registros Médicos → Registros Médicos\nÁrea Médica ID: 7d6993f0-0ff7-11f0-b70d-3c557613b8e0 → 7d6993f0-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RM → RM',_binary '','2025-04-02 13:20:12'),(138,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04977-0ff7-11f0-b70d-3c557613b8e0\nNombre: Biomédica Conservación y Mantenimiento → Biomédica Conservación y Mantenimiento\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: BCM → BCM',_binary '','2025-04-02 13:20:12'),(139,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe049ca-0ff7-11f0-b70d-3c557613b8e0\nNombre: Validación → Validación\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: VAL → VAL',_binary '','2025-04-02 13:20:12'),(140,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04a1a-0ff7-11f0-b70d-3c557613b8e0\nNombre: Recursos Materiales → Recursos Materiales\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: RMAT → RMAT',_binary '','2025-04-02 13:20:12'),(141,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04a6a-0ff7-11f0-b70d-3c557613b8e0\nNombre: Almacén → Almacén\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: ALM → ALM',_binary '','2025-04-02 13:20:12'),(142,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04aba-0ff7-11f0-b70d-3c557613b8e0\nNombre: Insumos Especializados → Insumos Especializados\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: IE → IE',_binary '','2025-04-02 13:20:12'),(143,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04b09-0ff7-11f0-b70d-3c557613b8e0\nNombre: Servicios Generales → Servicios Generales\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: SG → SG',_binary '','2025-04-02 13:20:12'),(144,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04b59-0ff7-11f0-b70d-3c557613b8e0\nNombre: Intendencia → Intendencia\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: INT → INT',_binary '','2025-04-02 13:20:12'),(145,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04ba9-0ff7-11f0-b70d-3c557613b8e0\nNombre: Ropería → Ropería\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: ROP → ROP',_binary '','2025-04-02 13:20:12'),(146,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04bf9-0ff7-11f0-b70d-3c557613b8e0\nNombre: Vigilancia → Vigilancia\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: VIG → VIG',_binary '','2025-04-02 13:20:12'),(147,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04c49-0ff7-11f0-b70d-3c557613b8e0\nNombre: Dietética → Dietética\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: DIE → DIE',_binary '','2025-04-02 13:20:12'),(148,'root@localhost','Update','tbc_departamentos','Se ha ACTUALIZADO el DEPARTAMENTO con ID: 7fe04c99-0ff7-11f0-b70d-3c557613b8e0\nNombre: Farmacia Intrahospitalaria → Farmacia Intrahospitalaria\nÁrea Médica ID: 7d685e34-0ff7-11f0-b70d-3c557613b8e0 → 7d685e34-0ff7-11f0-b70d-3c557613b8e0\nEstatus: 1 → 1\nAbreviatura: FIH → FIH',_binary '','2025-04-02 13:20:12'),(149,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Admin DESCRIPCION: Usuario Administrador del Sistema que permitirá modificar datos críticos ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(150,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Direccion General DESCRIPCION: Usuario de la Máxima Autoridad del Hospital, que le permitirá acceder a módulos para el control y operación del servicio del Hospital ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(151,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Paciente DESCRIPCION: Usuario que tendrá acceso a consultar la información médica asociada a su salud ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(152,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Médico General DESCRIPCION: Usuario que tendrá acceso a consultar y modificar la información de salud de los pacientes y sus citas médicas ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(153,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Médico Especialista DESCRIPCION: Usuario que tendrá acceso a consultar y modificar la información de salud de los pacientes específicos a una especialidad médica ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(154,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Enfermero DESCRIPCION: Usuario que apoya en la gestión y desarrollo de los servicios médicos proporcionados a los pacientes. ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(155,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Familiar del Paciente DESCRIPCION: Usuario que puede consultar y verificar la información de un paciente en caso de que no esté en capacidad o conciencia propia ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(156,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Paciente IMSS DESCRIPCION: Este usuario es de prueba para testear el borrado en bitácora ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(157,'root@localhost','Create','tbc_roles','Se ha agregado un nuevo rol de usuario con los siguientes datos: NOMBRE: Administrativo DESCRIPCION: Empleado que apoya en las actividades de cada departamento ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(158,'root@localhost','Update','tbc_roles','Se ha modificado un rol de usuario existente con los siguientes datos: NOMBRE: Admin  -  Administrador DESCRIPCION: Usuario Administrador del Sistema que permitirá modificar datos críticos  -  Usuario Administrador del Sistema que permitirá modificar datos críticos ESTATUS: 1  -  0',_binary '','2025-04-02 13:20:16'),(159,'root@localhost','Update','tbc_roles','Se ha modificado un rol de usuario existente con los siguientes datos: NOMBRE: Familiar del Paciente  -  Familiar del Paciente DESCRIPCION: Usuario que puede consultar y verificar la información de un paciente en caso de que no esté en capacidad o conciencia propia  -  Usuario que puede consultar y verificar la información de un paciente en caso de que no esté en capacidad o conciencia propia ESTATUS: 1  -  0',_binary '','2025-04-02 13:20:16'),(160,'root@localhost','Delete','tbc_roles','Se ha eliminado un rol de usuario existente con los siguientes datos: NOMBRE: Paciente IMSS DESCRIPCION: Este usuario es de prueba para testear el borrado en bitácora ESTATUS: 1',_binary '','2025-04-02 13:20:16'),(161,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: 09057c00-0ff8-11f0-b70d-3c557613b8e0\nNombre: Fernanda Castillo Gutiérrez\nPrimer Apellido: Castillo\nSegundo Apellido: Gutiérrez\nCURP: CSGF880622FN61\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1988-06-22\nEstatus: 1',_binary '','2025-04-02 13:24:02'),(162,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: 125e9a19-0ff8-11f0-b70d-3c557613b8e0\nNombre: Alex Rojas Delgado\nPrimer Apellido: Rojas\nSegundo Apellido: Delgado\nCURP: RSDA781208N/BO68\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1978-12-08\nEstatus: 1',_binary '','2025-04-02 13:24:18'),(163,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Médico General\nAl USUARIO con correo: alex.rojas972@correo.com\nEstatus: ',_binary '','2025-04-02 13:24:18'),(164,'root@localhost','Create','tbb_personal_medico','Se ha creado nuevo personal medico con los siguientes datos: \n Nombre de la Persona:  Alex   Rojas   Delgado \n Nombre del Departamento:  Junta de Gobierno \n Especialidad:  \n Tipo:  Medico \n Cedula Profesional:  CED-516008eb \n Estatus:  Activo \n Fecha de Contratación:  2016-10-02 00:00:00 \n Salario:  29651.13 \n Fecha de Actualización:  \n',_binary '','2025-04-02 13:24:18'),(165,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: 5253f56b-0ff8-11f0-b70d-3c557613b8e0\nNombre: Andrea Torres Gutiérrez\nPrimer Apellido: Torres\nSegundo Apellido: Gutiérrez\nCURP: TTGA970301FK45\nGénero: F\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1997-03-01\nEstatus: 1',_binary '','2025-04-02 13:26:05'),(166,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Paciente\nAl USUARIO con correo: andrea.torres822@correo.com\nEstatus: ',_binary '','2025-04-02 13:26:05'),(167,'root@localhost','Create','tbb_pacientes','Se ha creado un nuevo paciente con los siguientes datos: \n NSS:  988915916521954 \n TIPO SEGURO:  IMSS \n ESTATUS MEDICO:  Normal \n ESTATUS VIDA:  Finado \n ESTATUS:  Activo \n',_binary '','2025-04-02 13:26:05'),(168,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: 26f93a89-11a9-11f0-b70d-3c557613b8e0\nNombre: Juan Rodríguez Ramírez\nTítulo: Lic.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Ramírez\nCURP: RRRJ980929MD63\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1998-09-29\nEstatus: 1',_binary '','2025-04-04 17:04:24'),(169,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.rodríguez578@ejemplo.com\nEstatus: ',_binary '','2025-04-04 17:04:24'),(170,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: bdb8af10-11a9-11f0-b70d-3c557613b8e0\nNombre: Miguel Ramírez Hernández\nPrimer Apellido: Ramírez\nSegundo Apellido: Hernández\nCURP: RMHM070303MT27\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 2007-03-03\nEstatus: 1',_binary '','2025-04-04 17:08:37'),(171,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: d5732ae1-11a9-11f0-b70d-3c557613b8e0\nNombre: Fernando Rodríguez Cruz\nPrimer Apellido: Rodríguez\nSegundo Apellido: Cruz\nCURP: RRCF220317MJ30\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2022-03-17\nEstatus: 1',_binary '','2025-04-04 17:09:17'),(172,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee0c917b-11a9-11f0-b70d-3c557613b8e0\nNombre: Javier Sánchez Hernández\nPrimer Apellido: Sánchez\nSegundo Apellido: Hernández\nCURP: SSHJ170203MX67\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2017-02-03\nEstatus: 1',_binary '','2025-04-04 17:09:58'),(173,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.castillo910@correo.com\nEstatus: ',_binary '','2025-06-25 11:20:45'),(174,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Direccion General\nAl USUARIO con correo: miguel.ramírez@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:20:45'),(175,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Paciente\nAl USUARIO con correo: fernando.rodríguez@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:20:45'),(176,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Paciente\nAl USUARIO con correo: javier.sánchez@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:20:45'),(177,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9a4acd-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo González Rodríguez\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: Rodríguez\nCURP: GGRR781109MU41\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1978-11-09\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(178,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9b71d2-51e8-11f0-9f2b-00155d276843\nNombre: Chris Domínguez Escobar\nTítulo: Lic.\nPrimer Apellido: Domínguez\nSegundo Apellido: Escobar\nCURP: DDEC520827N/BZ35\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1952-08-27\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(179,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9c3b3e-51e8-11f0-9f2b-00155d276843\nNombre: Casey Domínguez Delgado\nTítulo: Dr.\nPrimer Apellido: Domínguez\nSegundo Apellido: Delgado\nCURP: DDDC530204N/BA26\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1953-02-04\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(180,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9d6a0f-51e8-11f0-9f2b-00155d276843\nNombre: Javier Rodríguez García\nTítulo: Dr.\nPrimer Apellido: Rodríguez\nSegundo Apellido: García\nCURP: RRGJ481226MV57\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1948-12-26\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(181,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9e122a-51e8-11f0-9f2b-00155d276843\nNombre: Juan Martínez López\nPrimer Apellido: Martínez\nSegundo Apellido: López\nCURP: MRLJ031207MH66\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2003-12-07\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(182,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9ec858-51e8-11f0-9f2b-00155d276843\nNombre: Gabriela Navarro Ortega\nTítulo: Lic.\nPrimer Apellido: Navarro\nSegundo Apellido: Ortega\nCURP: NVOG710413FJ73\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1971-04-13\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(183,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ee9f751b-51e8-11f0-9f2b-00155d276843\nNombre: Dani Rojas Delgado\nTítulo: Dr.\nPrimer Apellido: Rojas\nSegundo Apellido: Delgado\nCURP: RSDD640421N/BW89\nGénero: N/B\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1964-04-21\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(184,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea01918-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Jiménez Ortega\nTítulo: Lic.\nPrimer Apellido: Jiménez\nSegundo Apellido: Ortega\nCURP: JJOA820601FM81\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1982-06-01\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(185,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea1037f-51e8-11f0-9f2b-00155d276843\nNombre: María Castillo Torres\nTítulo: Ing.\nPrimer Apellido: Castillo\nSegundo Apellido: Torres\nCURP: CSTM701209FU23\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1970-12-09\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(186,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea1f674-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Castillo Navarro\nTítulo: Ing.\nPrimer Apellido: Castillo\nSegundo Apellido: Navarro\nCURP: CSNS460818FS93\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1946-08-18\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(187,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea29c6d-51e8-11f0-9f2b-00155d276843\nNombre: Robin Delgado Silva\nTítulo: Ing.\nPrimer Apellido: Delgado\nSegundo Apellido: Silva\nCURP: DDSR870123N/BB13\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1987-01-23\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(188,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea3597d-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Rodríguez Ramírez\nTítulo: Lic.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Ramírez\nCURP: RRRC490402MF47\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1949-04-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(189,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea43c8b-51e8-11f0-9f2b-00155d276843\nNombre: Juan García Cruz\nTítulo: Lic.\nPrimer Apellido: García\nSegundo Apellido: Cruz\nCURP: GRCJ771129MT27\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1977-11-29\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(190,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea51c97-51e8-11f0-9f2b-00155d276843\nNombre: Chris Aguilar Mendoza\nTítulo: Lic.\nPrimer Apellido: Aguilar\nSegundo Apellido: Mendoza\nCURP: AGMC670602N/BC98\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1967-06-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(191,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea5c0c8-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Ortega Vargas\nTítulo: Dr.\nPrimer Apellido: Ortega\nSegundo Apellido: Vargas\nCURP: OVF901217FX44\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1990-12-17\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(192,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea6a481-51e8-11f0-9f2b-00155d276843\nNombre: Juan Rodríguez Martínez\nTítulo: Dr.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Martínez\nCURP: RRMJ550805MC26\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1955-08-05\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(193,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea76932-51e8-11f0-9f2b-00155d276843\nNombre: María Torres Ortega\nTítulo: Dr.\nPrimer Apellido: Torres\nSegundo Apellido: Ortega\nCURP: TTOM650929FN74\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1965-09-29\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(194,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea81e94-51e8-11f0-9f2b-00155d276843\nNombre: Miguel Pérez Sánchez\nTítulo: Ing.\nPrimer Apellido: Pérez\nSegundo Apellido: Sánchez\nCURP: PPSM540218MJ79\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1954-02-18\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(195,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea8e0ce-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Torres Morales\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Morales\nCURP: TTMS740110FR61\nGénero: F\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1974-01-10\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(196,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eea99b9b-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Torres Ortega\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Ortega\nCURP: TTOI520425FQ12\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1952-04-25\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(197,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeaa7040-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Rojas Vega\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Vega\nCURP: RSVJ740424N/BK42\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1974-04-24\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(198,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeab9744-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Medina Delgado\nTítulo: Dr.\nPrimer Apellido: Medina\nSegundo Apellido: Delgado\nCURP: MDJ800920N/BW36\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1980-09-20\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(199,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeac62e6-51e8-11f0-9f2b-00155d276843\nNombre: Robin Medina Silva\nPrimer Apellido: Medina\nSegundo Apellido: Silva\nCURP: MSR010523N/BQ47\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2001-05-23\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(200,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eead2537-51e8-11f0-9f2b-00155d276843\nNombre: Sky Vega Flores\nTítulo: Ing.\nPrimer Apellido: Vega\nSegundo Apellido: Flores\nCURP: VFS860130N/BH16\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1986-01-30\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(201,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeae018f-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Ortega Gutiérrez\nTítulo: Dr.\nPrimer Apellido: Ortega\nSegundo Apellido: Gutiérrez\nCURP: OGS470126FP59\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1947-01-26\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(202,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeaebc83-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Navarro Castillo\nTítulo: Lic.\nPrimer Apellido: Navarro\nSegundo Apellido: Castillo\nCURP: NVCF820905FX38\nGénero: F\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1982-09-05\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(203,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeaf9396-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Gutiérrez Navarro\nTítulo: Ing.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Navarro\nCURP: GGNL711001FX28\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1971-10-01\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(204,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb0a035-51e8-11f0-9f2b-00155d276843\nNombre: Fernando García Ramírez\nPrimer Apellido: García\nSegundo Apellido: Ramírez\nCURP: GRRF011024MD87\nGénero: M\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 2001-10-24\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(205,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb1512a-51e8-11f0-9f2b-00155d276843\nNombre: Camila Gutiérrez Fernández\nTítulo: Lic.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Fernández\nCURP: GGFC540622FZ83\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1954-06-22\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(206,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb21369-51e8-11f0-9f2b-00155d276843\nNombre: Camila Torres Ortega\nTítulo: Dr.\nPrimer Apellido: Torres\nSegundo Apellido: Ortega\nCURP: TTOC491017FV62\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1949-10-17\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(207,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb2eebb-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Castillo Morales\nTítulo: Lic.\nPrimer Apellido: Castillo\nSegundo Apellido: Morales\nCURP: CSMV910105FF40\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1991-01-05\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(208,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb3b2c3-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Torres Fernández\nTítulo: Dr.\nPrimer Apellido: Torres\nSegundo Apellido: Fernández\nCURP: TTFA831121FJ75\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1983-11-21\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(209,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb4978b-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Morales Ortega\nTítulo: Ing.\nPrimer Apellido: Morales\nSegundo Apellido: Ortega\nCURP: MLOF680813FN10\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1968-08-13\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(210,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb5736d-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Ortega Navarro\nTítulo: Dr.\nPrimer Apellido: Ortega\nSegundo Apellido: Navarro\nCURP: ONA551206FQ53\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1955-12-06\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(211,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb67c4b-51e8-11f0-9f2b-00155d276843\nNombre: Miguel Martínez García\nTítulo: Dr.\nPrimer Apellido: Martínez\nSegundo Apellido: García\nCURP: MRGM860319MK84\nGénero: M\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1986-03-19\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(212,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb7442e-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro Sánchez García\nPrimer Apellido: Sánchez\nSegundo Apellido: García\nCURP: SSGA030916MR52\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2003-09-16\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(213,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb8168b-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Navarro Vargas\nTítulo: Ing.\nPrimer Apellido: Navarro\nSegundo Apellido: Vargas\nCURP: NVVA831113FM13\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1983-11-13\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(214,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb8d665-51e8-11f0-9f2b-00155d276843\nNombre: María Reyes Morales\nTítulo: Lic.\nPrimer Apellido: Reyes\nSegundo Apellido: Morales\nCURP: RRMM520928FR10\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1952-09-28\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(215,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeb97c48-51e8-11f0-9f2b-00155d276843\nNombre: Alex Aguilar Delgado\nTítulo: Ing.\nPrimer Apellido: Aguilar\nSegundo Apellido: Delgado\nCURP: AGDA840423N/BB54\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1984-04-23\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(216,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeba145c-51e8-11f0-9f2b-00155d276843\nNombre: Andrés López López\nPrimer Apellido: López\nSegundo Apellido: López\nCURP: LLLA040529ML37\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2004-05-29\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(217,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebaab40-51e8-11f0-9f2b-00155d276843\nNombre: Javier López González\nTítulo: Ing.\nPrimer Apellido: López\nSegundo Apellido: González\nCURP: LLGJ770513ME91\nGénero: M\nGrupo Sanguíneo: AB-\nFecha de Nacimiento: 1977-05-13\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(218,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebb5108-51e8-11f0-9f2b-00155d276843\nNombre: Luis Pérez Ramírez\nTítulo: Dr.\nPrimer Apellido: Pérez\nSegundo Apellido: Ramírez\nCURP: PPRL791102MX54\nGénero: M\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1979-11-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(219,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebc05bf-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Torres Fernández\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Fernández\nCURP: TTFL530622FL26\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1953-06-22\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(220,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebcb99f-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Sánchez Hernández\nTítulo: Ing.\nPrimer Apellido: Sánchez\nSegundo Apellido: Hernández\nCURP: SSHF630709MS98\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1963-07-09\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(221,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebd873a-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Sánchez López\nTítulo: Ing.\nPrimer Apellido: Sánchez\nSegundo Apellido: López\nCURP: SSLA570404MO85\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1957-04-04\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(222,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebe2348-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Gutiérrez Reyes\nTítulo: Dr.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Reyes\nCURP: GGRS950302FR79\nGénero: F\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1995-03-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(223,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebeb478-51e8-11f0-9f2b-00155d276843\nNombre: Sam Aguilar Silva\nTítulo: Dr.\nPrimer Apellido: Aguilar\nSegundo Apellido: Silva\nCURP: AGSS461215N/BE19\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1946-12-15\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(224,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eebf5688-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Mendoza Rojas\nTítulo: Ing.\nPrimer Apellido: Mendoza\nSegundo Apellido: Rojas\nCURP: MRT560623N/BV73\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1956-06-23\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(225,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec041c9-51e8-11f0-9f2b-00155d276843\nNombre: Luis González González\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: González\nCURP: GGGL970310MT33\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1997-03-10\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(226,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec0dbcf-51e8-11f0-9f2b-00155d276843\nNombre: Miguel López González\nTítulo: Dr.\nPrimer Apellido: López\nSegundo Apellido: González\nCURP: LLGM990722MK98\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1999-07-22\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(227,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec185c0-51e8-11f0-9f2b-00155d276843\nNombre: Sky Domínguez Medina\nPrimer Apellido: Domínguez\nSegundo Apellido: Medina\nCURP: DDMS031208N/BP21\nGénero: N/B\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 2003-12-08\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(228,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec26215-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Martínez Ramírez\nTítulo: Dr.\nPrimer Apellido: Martínez\nSegundo Apellido: Ramírez\nCURP: MRRF640317MP74\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1964-03-17\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(229,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec302ec-51e8-11f0-9f2b-00155d276843\nNombre: Robin Flores Escobar\nTítulo: Lic.\nPrimer Apellido: Flores\nSegundo Apellido: Escobar\nCURP: FFER530128N/BE69\nGénero: N/B\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1953-01-28\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(230,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec39853-51e8-11f0-9f2b-00155d276843\nNombre: Javier Pérez Cruz\nTítulo: Dr.\nPrimer Apellido: Pérez\nSegundo Apellido: Cruz\nCURP: PPCJ600513MX55\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1960-05-13\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(231,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec44ab3-51e8-11f0-9f2b-00155d276843\nNombre: Dani Medina Medina\nTítulo: Ing.\nPrimer Apellido: Medina\nSegundo Apellido: Medina\nCURP: MMD650714N/BM91\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1965-07-14\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(232,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec508df-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Mendoza Vega\nTítulo: Lic.\nPrimer Apellido: Mendoza\nSegundo Apellido: Vega\nCURP: MVT750227N/BQ76\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1975-02-27\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(233,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec59ae1-51e8-11f0-9f2b-00155d276843\nNombre: Morgan Vega Aguilar\nTítulo: Ing.\nPrimer Apellido: Vega\nSegundo Apellido: Aguilar\nCURP: VAM800620N/BP15\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1980-06-20\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(234,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec640a1-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Ramírez Martínez\nTítulo: Lic.\nPrimer Apellido: Ramírez\nSegundo Apellido: Martínez\nCURP: RMME750824MK66\nGénero: M\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 1975-08-24\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(235,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec6e665-51e8-11f0-9f2b-00155d276843\nNombre: Luis García Rodríguez\nTítulo: Ing.\nPrimer Apellido: García\nSegundo Apellido: Rodríguez\nCURP: GRRL520218MJ21\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1952-02-18\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(236,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec787c3-51e8-11f0-9f2b-00155d276843\nNombre: Dani Flores Aguilar\nTítulo: Dr.\nPrimer Apellido: Flores\nSegundo Apellido: Aguilar\nCURP: FFAD890305N/BM45\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1989-03-05\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(237,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec82d5e-51e8-11f0-9f2b-00155d276843\nNombre: Sky Flores Vega\nTítulo: Dr.\nPrimer Apellido: Flores\nSegundo Apellido: Vega\nCURP: FFVS581209N/BW46\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1958-12-09\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(238,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec8c8c1-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Sánchez Pérez\nTítulo: Ing.\nPrimer Apellido: Sánchez\nSegundo Apellido: Pérez\nCURP: SSPE730508MP29\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1973-05-08\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(239,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eec97250-51e8-11f0-9f2b-00155d276843\nNombre: Sam Mendoza Flores\nTítulo: Lic.\nPrimer Apellido: Mendoza\nSegundo Apellido: Flores\nCURP: MFS661101N/BK49\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1966-11-01\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(240,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeca1082-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Reyes Morales\nTítulo: Ing.\nPrimer Apellido: Reyes\nSegundo Apellido: Morales\nCURP: RRMA460407FB13\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1946-04-07\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(241,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecaaa94-51e8-11f0-9f2b-00155d276843\nNombre: Robin Domínguez Delgado\nTítulo: Lic.\nPrimer Apellido: Domínguez\nSegundo Apellido: Delgado\nCURP: DDDR470213N/BP84\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1947-02-13\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(242,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecb25f8-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Pérez García\nPrimer Apellido: Pérez\nSegundo Apellido: García\nCURP: PPGF030418MJ16\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2003-04-18\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(243,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecbac99-51e8-11f0-9f2b-00155d276843\nNombre: Casey Aguilar Flores\nTítulo: Dr.\nPrimer Apellido: Aguilar\nSegundo Apellido: Flores\nCURP: AGFC580426N/BR58\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1958-04-26\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(244,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecc27de-51e8-11f0-9f2b-00155d276843\nNombre: Juan Martínez García\nTítulo: Ing.\nPrimer Apellido: Martínez\nSegundo Apellido: García\nCURP: MRGJ770612MK80\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1977-06-12\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(245,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecc943a-51e8-11f0-9f2b-00155d276843\nNombre: Camila Ortega Gutiérrez\nTítulo: Dr.\nPrimer Apellido: Ortega\nSegundo Apellido: Gutiérrez\nCURP: OGC970702FC49\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1997-07-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(246,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecd0e68-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Ortega Gutiérrez\nTítulo: Lic.\nPrimer Apellido: Ortega\nSegundo Apellido: Gutiérrez\nCURP: OGV901119FW91\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1990-11-19\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(247,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecd7a93-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Martínez Rodríguez\nTítulo: Dr.\nPrimer Apellido: Martínez\nSegundo Apellido: Rodríguez\nCURP: MRRF831217MT42\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1983-12-17\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(248,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecded6d-51e8-11f0-9f2b-00155d276843\nNombre: Dani Medina Medina\nTítulo: Dr.\nPrimer Apellido: Medina\nSegundo Apellido: Medina\nCURP: MMD740831N/BB94\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1974-08-31\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(249,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eece6f36-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo González Hernández\nTítulo: Dr.\nPrimer Apellido: González\nSegundo Apellido: Hernández\nCURP: GGHR600624MH79\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1960-06-24\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(250,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeceff9e-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Pérez García\nTítulo: Dr.\nPrimer Apellido: Pérez\nSegundo Apellido: García\nCURP: PPGA890608MG52\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1989-06-08\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(251,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecf6da0-51e8-11f0-9f2b-00155d276843\nNombre: Camila Jiménez Jiménez\nTítulo: Dr.\nPrimer Apellido: Jiménez\nSegundo Apellido: Jiménez\nCURP: JJJC960516FP87\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1996-05-16\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(252,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eecfd760-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Ortega Vargas\nTítulo: Lic.\nPrimer Apellido: Ortega\nSegundo Apellido: Vargas\nCURP: OVV660518FB88\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1966-05-18\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(253,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed068f2-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Morales Vargas\nTítulo: Dr.\nPrimer Apellido: Morales\nSegundo Apellido: Vargas\nCURP: MLVL790526FQ10\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1979-05-26\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(254,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed0e166-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Morales Jiménez\nTítulo: Ing.\nPrimer Apellido: Morales\nSegundo Apellido: Jiménez\nCURP: MLJV491002FO68\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1949-10-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(255,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed15b01-51e8-11f0-9f2b-00155d276843\nNombre: Miguel Ramírez Hernández\nPrimer Apellido: Ramírez\nSegundo Apellido: Hernández\nCURP: RMHM050111MX61\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2005-01-11\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(256,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed1cc5c-51e8-11f0-9f2b-00155d276843\nNombre: Javier Pérez Martínez\nTítulo: Ing.\nPrimer Apellido: Pérez\nSegundo Apellido: Martínez\nCURP: PPMJ700919ML34\nGénero: M\nGrupo Sanguíneo: AB-\nFecha de Nacimiento: 1970-09-19\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(257,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed23f7f-51e8-11f0-9f2b-00155d276843\nNombre: Javier Sánchez López\nTítulo: Lic.\nPrimer Apellido: Sánchez\nSegundo Apellido: López\nCURP: SSLJ731202MC81\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1973-12-02\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(258,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed2cec6-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo López Rodríguez\nTítulo: Dr.\nPrimer Apellido: López\nSegundo Apellido: Rodríguez\nCURP: LLRE850412MR40\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1985-04-12\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(259,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed36481-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Delgado Domínguez\nTítulo: Dr.\nPrimer Apellido: Delgado\nSegundo Apellido: Domínguez\nCURP: DDDJ910401N/BC65\nGénero: N/B\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1991-04-01\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(260,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed3e8d0-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Gutiérrez Vargas\nTítulo: Dr.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Vargas\nCURP: GGVF701130FF34\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1970-11-30\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(261,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed45ce2-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Jiménez Torres\nTítulo: Lic.\nPrimer Apellido: Jiménez\nSegundo Apellido: Torres\nCURP: JJTA850408FT53\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1985-04-08\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(262,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed4f40a-51e8-11f0-9f2b-00155d276843\nNombre: Sky Delgado Mendoza\nTítulo: Ing.\nPrimer Apellido: Delgado\nSegundo Apellido: Mendoza\nCURP: DDMS650121N/BF80\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1965-01-21\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(263,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed578fc-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro González Ramírez\nTítulo: Ing.\nPrimer Apellido: González\nSegundo Apellido: Ramírez\nCURP: GGRA811215MT32\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1981-12-15\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(264,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed63091-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Jiménez Ortega\nTítulo: Lic.\nPrimer Apellido: Jiménez\nSegundo Apellido: Ortega\nCURP: JJOI961119FL85\nGénero: F\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1996-11-19\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(265,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed6b63a-51e8-11f0-9f2b-00155d276843\nNombre: Alex Rojas Delgado\nTítulo: Lic.\nPrimer Apellido: Rojas\nSegundo Apellido: Delgado\nCURP: RSDA740428N/BO50\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1974-04-28\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(266,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed74bff-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Reyes Castillo\nTítulo: Lic.\nPrimer Apellido: Reyes\nSegundo Apellido: Castillo\nCURP: RRCV570815FF75\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1957-08-15\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(267,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed7c738-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Cruz Rodríguez\nTítulo: Lic.\nPrimer Apellido: Cruz\nSegundo Apellido: Rodríguez\nCURP: CCRE680803MN83\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1968-08-03\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(268,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed84bc2-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo González González\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: González\nCURP: GGGR990111MB57\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1999-01-11\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(269,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed8d310-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Ortega Navarro\nTítulo: Ing.\nPrimer Apellido: Ortega\nSegundo Apellido: Navarro\nCURP: ONA470926FC54\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1947-09-26\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(270,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eed98ddd-51e8-11f0-9f2b-00155d276843\nNombre: Dani Mendoza Escobar\nTítulo: Dr.\nPrimer Apellido: Mendoza\nSegundo Apellido: Escobar\nCURP: MED671216N/BJ56\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1967-12-16\nEstatus: 1',_binary '','2025-06-25 11:22:12'),(271,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeda1714-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Hernández López\nTítulo: Lic.\nPrimer Apellido: Hernández\nSegundo Apellido: López\nCURP: HHLC850516MI23\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1985-05-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(272,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedaa68e-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo García García\nPrimer Apellido: García\nSegundo Apellido: García\nCURP: GRGE060825MX51\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2006-08-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(273,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedb2611-51e8-11f0-9f2b-00155d276843\nNombre: Dani Vega Medina\nTítulo: Dr.\nPrimer Apellido: Vega\nSegundo Apellido: Medina\nCURP: VMD640419N/BS20\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1964-04-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(274,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedbb1c1-51e8-11f0-9f2b-00155d276843\nNombre: Andrés González Pérez\nTítulo: Dr.\nPrimer Apellido: González\nSegundo Apellido: Pérez\nCURP: GGPA691003MD85\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1969-10-03\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(275,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedc3476-51e8-11f0-9f2b-00155d276843\nNombre: Chris Mendoza Silva\nTítulo: Dr.\nPrimer Apellido: Mendoza\nSegundo Apellido: Silva\nCURP: MSC721113N/BH19\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1972-11-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(276,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedcbaf3-51e8-11f0-9f2b-00155d276843\nNombre: Chris Flores Flores\nTítulo: Dr.\nPrimer Apellido: Flores\nSegundo Apellido: Flores\nCURP: FFFC660728N/BC43\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1966-07-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(277,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedd3369-51e8-11f0-9f2b-00155d276843\nNombre: Alex Rojas Domínguez\nTítulo: Lic.\nPrimer Apellido: Rojas\nSegundo Apellido: Domínguez\nCURP: RSDA490404N/BJ77\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1949-04-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(278,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeddc783-51e8-11f0-9f2b-00155d276843\nNombre: Casey Silva Vega\nTítulo: Lic.\nPrimer Apellido: Silva\nSegundo Apellido: Vega\nCURP: SVC890513N/BO93\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1989-05-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(279,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eede449a-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Torres Fernández\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Fernández\nCURP: TTFI780324FH79\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1978-03-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(280,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedeb756-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Flores Escobar\nPrimer Apellido: Flores\nSegundo Apellido: Escobar\nCURP: FFET031229N/BW49\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2003-12-29\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(281,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedf4740-51e8-11f0-9f2b-00155d276843\nNombre: Chris Delgado Silva\nTítulo: Dr.\nPrimer Apellido: Delgado\nSegundo Apellido: Silva\nCURP: DDSC480920N/BS19\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1948-09-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(282,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eedfc0c2-51e8-11f0-9f2b-00155d276843\nNombre: Camila Gutiérrez Fernández\nTítulo: Dr.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Fernández\nCURP: GGFC740329FW20\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1974-03-29\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(283,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee041e4-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Medina Escobar\nTítulo: Lic.\nPrimer Apellido: Medina\nSegundo Apellido: Escobar\nCURP: MEJ810809N/BE88\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1981-08-09\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(284,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee0eeb1-51e8-11f0-9f2b-00155d276843\nNombre: Sam Domínguez Domínguez\nTítulo: Dr.\nPrimer Apellido: Domínguez\nSegundo Apellido: Domínguez\nCURP: DDDS760429N/BR34\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1976-04-29\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(285,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee16c6a-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Silva Rojas\nTítulo: Lic.\nPrimer Apellido: Silva\nSegundo Apellido: Rojas\nCURP: SRJ590528N/BR73\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1959-05-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(286,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee1e5e6-51e8-11f0-9f2b-00155d276843\nNombre: Robin Silva Aguilar\nTítulo: Ing.\nPrimer Apellido: Silva\nSegundo Apellido: Aguilar\nCURP: SAR640528N/BX40\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1964-05-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(287,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee257d6-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Vargas Fernández\nTítulo: Ing.\nPrimer Apellido: Vargas\nSegundo Apellido: Fernández\nCURP: VRFV801109FE26\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1980-11-09\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(288,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee2eca0-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Ortega Torres\nTítulo: Ing.\nPrimer Apellido: Ortega\nSegundo Apellido: Torres\nCURP: OTA670906FZ68\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1967-09-06\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(289,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee38373-51e8-11f0-9f2b-00155d276843\nNombre: Casey Rojas Rojas\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Rojas\nCURP: RSRC461027N/BZ22\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1946-10-27\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(290,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee40133-51e8-11f0-9f2b-00155d276843\nNombre: Miguel Hernández Sánchez\nTítulo: Ing.\nPrimer Apellido: Hernández\nSegundo Apellido: Sánchez\nCURP: HHSM900626MS53\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1990-06-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(291,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee47363-51e8-11f0-9f2b-00155d276843\nNombre: Sky Rojas Domínguez\nPrimer Apellido: Rojas\nSegundo Apellido: Domínguez\nCURP: RSDS060522N/BF25\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2006-05-22\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(292,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee4f140-51e8-11f0-9f2b-00155d276843\nNombre: Camila Jiménez Morales\nTítulo: Dr.\nPrimer Apellido: Jiménez\nSegundo Apellido: Morales\nCURP: JJMC940416FQ59\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1994-04-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(293,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee58730-51e8-11f0-9f2b-00155d276843\nNombre: Dani Medina Domínguez\nTítulo: Lic.\nPrimer Apellido: Medina\nSegundo Apellido: Domínguez\nCURP: MDD971222N/BB24\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1997-12-22\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(294,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee600f2-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Navarro Jiménez\nPrimer Apellido: Navarro\nSegundo Apellido: Jiménez\nCURP: NVJS030523FS80\nGénero: F\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 2003-05-23\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(295,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee67d2a-51e8-11f0-9f2b-00155d276843\nNombre: Camila Gutiérrez Vargas\nTítulo: Lic.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Vargas\nCURP: GGVC670312FN88\nGénero: F\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1967-03-12\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(296,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee6eefa-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Navarro Navarro\nTítulo: Ing.\nPrimer Apellido: Navarro\nSegundo Apellido: Navarro\nCURP: NVNL820126FH23\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1982-01-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(297,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee768d9-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Pérez Hernández\nPrimer Apellido: Pérez\nSegundo Apellido: Hernández\nCURP: PPHF040822MV32\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 2004-08-22\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(298,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee7ecca-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo López Pérez\nTítulo: Ing.\nPrimer Apellido: López\nSegundo Apellido: Pérez\nCURP: LLPE461031MY86\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1946-10-31\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(299,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee880b7-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Aguilar Escobar\nTítulo: Lic.\nPrimer Apellido: Aguilar\nSegundo Apellido: Escobar\nCURP: AGET931015N/BM55\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1993-10-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(300,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee8f9a1-51e8-11f0-9f2b-00155d276843\nNombre: Dani Flores Mendoza\nPrimer Apellido: Flores\nSegundo Apellido: Mendoza\nCURP: FFMD001107N/BM71\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2000-11-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(301,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee96bb3-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Sánchez Hernández\nTítulo: Ing.\nPrimer Apellido: Sánchez\nSegundo Apellido: Hernández\nCURP: SSHC760924MM30\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1976-09-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(302,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eee9f897-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Aguilar Escobar\nTítulo: Dr.\nPrimer Apellido: Aguilar\nSegundo Apellido: Escobar\nCURP: AGET960717N/BE49\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1996-07-17\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(303,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeea986e-51e8-11f0-9f2b-00155d276843\nNombre: Andrés García Pérez\nTítulo: Lic.\nPrimer Apellido: García\nSegundo Apellido: Pérez\nCURP: GRPA750916MP60\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1975-09-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(304,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeeb1c24-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Jiménez Ortega\nTítulo: Dr.\nPrimer Apellido: Jiménez\nSegundo Apellido: Ortega\nCURP: JJOS710825FT73\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1971-08-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(305,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeeb8ac6-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Morales Morales\nTítulo: Ing.\nPrimer Apellido: Morales\nSegundo Apellido: Morales\nCURP: MLMS470105FP49\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1947-01-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(306,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeebf895-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Delgado Delgado\nTítulo: Lic.\nPrimer Apellido: Delgado\nSegundo Apellido: Delgado\nCURP: DDDJ601128N/BB12\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1960-11-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(307,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeec7734-51e8-11f0-9f2b-00155d276843\nNombre: Sky Domínguez Escobar\nTítulo: Ing.\nPrimer Apellido: Domínguez\nSegundo Apellido: Escobar\nCURP: DDES640105N/BQ61\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1964-01-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(308,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeecf5f9-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Jiménez Ortega\nTítulo: Ing.\nPrimer Apellido: Jiménez\nSegundo Apellido: Ortega\nCURP: JJOS930223FD30\nGénero: F\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1993-02-23\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(309,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeedc04f-51e8-11f0-9f2b-00155d276843\nNombre: Robin Vega Medina\nTítulo: Dr.\nPrimer Apellido: Vega\nSegundo Apellido: Medina\nCURP: VMR960528N/BO80\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1996-05-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(310,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeee33d8-51e8-11f0-9f2b-00155d276843\nNombre: Luis López Martínez\nTítulo: Lic.\nPrimer Apellido: López\nSegundo Apellido: Martínez\nCURP: LLML741225MI41\nGénero: M\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1974-12-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(311,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeeec51e-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Martínez Martínez\nTítulo: Ing.\nPrimer Apellido: Martínez\nSegundo Apellido: Martínez\nCURP: MRMR861020MJ39\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1986-10-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(312,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeef522a-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Cruz Rodríguez\nTítulo: Dr.\nPrimer Apellido: Cruz\nSegundo Apellido: Rodríguez\nCURP: CCRF590121MI98\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1959-01-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(313,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeefce21-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Sánchez Ramírez\nTítulo: Lic.\nPrimer Apellido: Sánchez\nSegundo Apellido: Ramírez\nCURP: SSRR980104MK69\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1998-01-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(314,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef042c2-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Gutiérrez Torres\nTítulo: Lic.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Torres\nCURP: GGTI841023FH94\nGénero: F\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1984-10-23\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(315,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef0e93e-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Castillo Ortega\nTítulo: Lic.\nPrimer Apellido: Castillo\nSegundo Apellido: Ortega\nCURP: CSOA710818FQ90\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1971-08-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(316,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef16b40-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo García López\nTítulo: Ing.\nPrimer Apellido: García\nSegundo Apellido: López\nCURP: GRLR970704MT87\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1997-07-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(317,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef1eaca-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Vargas Gutiérrez\nTítulo: Lic.\nPrimer Apellido: Vargas\nSegundo Apellido: Gutiérrez\nCURP: VRGA650119FP84\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1965-01-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(318,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef26ff9-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Reyes Ortega\nTítulo: Dr.\nPrimer Apellido: Reyes\nSegundo Apellido: Ortega\nCURP: RROF531022FF18\nGénero: F\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1953-10-22\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(319,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef30cee-51e8-11f0-9f2b-00155d276843\nNombre: Dani Medina Domínguez\nTítulo: Lic.\nPrimer Apellido: Medina\nSegundo Apellido: Domínguez\nCURP: MDD510204N/BW85\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1951-02-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(320,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef38d7d-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Jiménez Reyes\nPrimer Apellido: Jiménez\nSegundo Apellido: Reyes\nCURP: JJRF010430FO10\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2001-04-30\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(321,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef40188-51e8-11f0-9f2b-00155d276843\nNombre: Dani Flores Mendoza\nPrimer Apellido: Flores\nSegundo Apellido: Mendoza\nCURP: FFMD010804N/BO13\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2001-08-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(322,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef48956-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Castillo Fernández\nTítulo: Lic.\nPrimer Apellido: Castillo\nSegundo Apellido: Fernández\nCURP: CSFA590810FQ55\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1959-08-10\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(323,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef4fe54-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Medina Mendoza\nTítulo: Dr.\nPrimer Apellido: Medina\nSegundo Apellido: Mendoza\nCURP: MMT590902N/BN83\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1959-09-02\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(324,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef57648-51e8-11f0-9f2b-00155d276843\nNombre: Camila Castillo Gutiérrez\nTítulo: Ing.\nPrimer Apellido: Castillo\nSegundo Apellido: Gutiérrez\nCURP: CSGC490620FO78\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1949-06-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(325,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef5ff75-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Castillo Jiménez\nTítulo: Dr.\nPrimer Apellido: Castillo\nSegundo Apellido: Jiménez\nCURP: CSJA610418FS73\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1961-04-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(326,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef66cab-51e8-11f0-9f2b-00155d276843\nNombre: Sam Flores Silva\nTítulo: Dr.\nPrimer Apellido: Flores\nSegundo Apellido: Silva\nCURP: FFSS700110N/BM15\nGénero: N/B\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1970-01-10\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(327,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef6efac-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Delgado Silva\nTítulo: Dr.\nPrimer Apellido: Delgado\nSegundo Apellido: Silva\nCURP: DDST961104N/BZ64\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1996-11-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(328,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef78b59-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Escobar Rojas\nTítulo: Lic.\nPrimer Apellido: Escobar\nSegundo Apellido: Rojas\nCURP: ERRT590523N/BS90\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1959-05-23\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(329,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef8244c-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Cruz Ramírez\nTítulo: Lic.\nPrimer Apellido: Cruz\nSegundo Apellido: Ramírez\nCURP: CCRA751010MB56\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1975-10-10\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(330,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef8a2eb-51e8-11f0-9f2b-00155d276843\nNombre: Dani Escobar Domínguez\nTítulo: Dr.\nPrimer Apellido: Escobar\nSegundo Apellido: Domínguez\nCURP: ERDD550321N/BE90\nGénero: N/B\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 1955-03-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(331,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef9144a-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Martínez González\nTítulo: Ing.\nPrimer Apellido: Martínez\nSegundo Apellido: González\nCURP: MRGA660421MB97\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1966-04-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(332,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eef991f7-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Rojas Aguilar\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Aguilar\nCURP: RSAT920120N/BU25\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1992-01-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(333,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefa0e69-51e8-11f0-9f2b-00155d276843\nNombre: Casey Aguilar Flores\nTítulo: Dr.\nPrimer Apellido: Aguilar\nSegundo Apellido: Flores\nCURP: AGFC550221N/BY55\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1955-02-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(334,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefa88b5-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Domínguez Vega\nTítulo: Ing.\nPrimer Apellido: Domínguez\nSegundo Apellido: Vega\nCURP: DDVJ581201N/BB34\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1958-12-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(335,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefafbb7-51e8-11f0-9f2b-00155d276843\nNombre: Juan Rodríguez González\nPrimer Apellido: Rodríguez\nSegundo Apellido: González\nCURP: RRGJ041112MP14\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2004-11-12\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(336,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefb6d9d-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Reyes Morales\nTítulo: Ing.\nPrimer Apellido: Reyes\nSegundo Apellido: Morales\nCURP: RRMV960219FV81\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1996-02-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(337,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefbe2a4-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Rodríguez López\nTítulo: Dr.\nPrimer Apellido: Rodríguez\nSegundo Apellido: López\nCURP: RRLE750710MC24\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1975-07-10\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(338,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefc91f0-51e8-11f0-9f2b-00155d276843\nNombre: Carlos González Ramírez\nPrimer Apellido: González\nSegundo Apellido: Ramírez\nCURP: GGRC050604ME92\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2005-06-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(339,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefd13b0-51e8-11f0-9f2b-00155d276843\nNombre: Alex Rojas Aguilar\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Aguilar\nCURP: RSAA530831N/BR26\nGénero: N/B\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1953-08-31\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(340,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefd8224-51e8-11f0-9f2b-00155d276843\nNombre: Sam Medina Escobar\nTítulo: Dr.\nPrimer Apellido: Medina\nSegundo Apellido: Escobar\nCURP: MES950807N/BX40\nGénero: N/B\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 1995-08-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(341,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefdf675-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Domínguez Mendoza\nTítulo: Dr.\nPrimer Apellido: Domínguez\nSegundo Apellido: Mendoza\nCURP: DDMJ610101N/BH81\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1961-01-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(342,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefe740a-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Gutiérrez Reyes\nTítulo: Dr.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Reyes\nCURP: GGRL810828FA64\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1981-08-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(343,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeff03ee-51e8-11f0-9f2b-00155d276843\nNombre: Fernando Martínez García\nTítulo: Lic.\nPrimer Apellido: Martínez\nSegundo Apellido: García\nCURP: MRGF831210MG75\nGénero: M\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1983-12-10\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(344,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eeff7aa4-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Castillo Vargas\nTítulo: Ing.\nPrimer Apellido: Castillo\nSegundo Apellido: Vargas\nCURP: CSVF490228FL69\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1949-02-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(345,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: eefff1f8-51e8-11f0-9f2b-00155d276843\nNombre: Juan López Rodríguez\nTítulo: Dr.\nPrimer Apellido: López\nSegundo Apellido: Rodríguez\nCURP: LLRJ970402MM82\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1997-04-02\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(346,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef006266-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Vargas Morales\nTítulo: Dr.\nPrimer Apellido: Vargas\nSegundo Apellido: Morales\nCURP: VRMF570207FJ31\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1957-02-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(347,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef00de83-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Cruz García\nTítulo: Lic.\nPrimer Apellido: Cruz\nSegundo Apellido: García\nCURP: CCGR700521MW92\nGénero: M\nGrupo Sanguíneo: AB-\nFecha de Nacimiento: 1970-05-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(348,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0170bb-51e8-11f0-9f2b-00155d276843\nNombre: Juan González López\nTítulo: Dr.\nPrimer Apellido: González\nSegundo Apellido: López\nCURP: GGLJ781009MG81\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1978-10-09\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(349,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef01f264-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Gutiérrez Ortega\nTítulo: Lic.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Ortega\nCURP: GGOA940617FD60\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1994-06-17\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(350,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef026833-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Jiménez Torres\nTítulo: Lic.\nPrimer Apellido: Jiménez\nSegundo Apellido: Torres\nCURP: JJTA710406FJ73\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1971-04-06\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(351,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef02fb84-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Rodríguez Rodríguez\nTítulo: Dr.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Rodríguez\nCURP: RRRC570513MW16\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1957-05-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(352,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef038493-51e8-11f0-9f2b-00155d276843\nNombre: Alex Aguilar Aguilar\nTítulo: Dr.\nPrimer Apellido: Aguilar\nSegundo Apellido: Aguilar\nCURP: AGAA640215N/BO92\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1964-02-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(353,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef04166d-51e8-11f0-9f2b-00155d276843\nNombre: Sky Vega Flores\nTítulo: Ing.\nPrimer Apellido: Vega\nSegundo Apellido: Flores\nCURP: VFS701019N/BP91\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1970-10-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(354,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef04886a-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Pérez García\nTítulo: Lic.\nPrimer Apellido: Pérez\nSegundo Apellido: García\nCURP: PPGC960725MC71\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1996-07-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(355,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef04f9ff-51e8-11f0-9f2b-00155d276843\nNombre: Robin Escobar Domínguez\nTítulo: Dr.\nPrimer Apellido: Escobar\nSegundo Apellido: Domínguez\nCURP: ERDR510428N/BX47\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1951-04-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(356,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0567d2-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Fernández Castillo\nTítulo: Dr.\nPrimer Apellido: Fernández\nSegundo Apellido: Castillo\nCURP: FFCA510626FA93\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1951-06-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(357,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef05da6b-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Ramírez Cruz\nPrimer Apellido: Ramírez\nSegundo Apellido: Cruz\nCURP: RMCE070515MH44\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2007-05-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(358,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef068905-51e8-11f0-9f2b-00155d276843\nNombre: Camila Castillo Fernández\nTítulo: Dr.\nPrimer Apellido: Castillo\nSegundo Apellido: Fernández\nCURP: CSFC960530FN71\nGénero: F\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1996-05-30\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(359,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef073294-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Hernández Cruz\nTítulo: Ing.\nPrimer Apellido: Hernández\nSegundo Apellido: Cruz\nCURP: HHCA990813ML14\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1999-08-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(360,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef07d1a1-51e8-11f0-9f2b-00155d276843\nNombre: Javier Martínez Rodríguez\nTítulo: Ing.\nPrimer Apellido: Martínez\nSegundo Apellido: Rodríguez\nCURP: MRRJ880518MB11\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1988-05-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(361,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef084420-51e8-11f0-9f2b-00155d276843\nNombre: Camila Fernández Vargas\nTítulo: Ing.\nPrimer Apellido: Fernández\nSegundo Apellido: Vargas\nCURP: FFVC491101FQ57\nGénero: F\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1949-11-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(362,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef08d803-51e8-11f0-9f2b-00155d276843\nNombre: Juan Cruz Rodríguez\nTítulo: Dr.\nPrimer Apellido: Cruz\nSegundo Apellido: Rodríguez\nCURP: CCRJ710529MN23\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1971-05-29\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(363,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef095028-51e8-11f0-9f2b-00155d276843\nNombre: Camila Vargas Fernández\nTítulo: Lic.\nPrimer Apellido: Vargas\nSegundo Apellido: Fernández\nCURP: VRFC810524FU89\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1981-05-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(364,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef09c1e6-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Jiménez Ortega\nTítulo: Ing.\nPrimer Apellido: Jiménez\nSegundo Apellido: Ortega\nCURP: JJOS950624FX51\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1995-06-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(365,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0a321e-51e8-11f0-9f2b-00155d276843\nNombre: Sam Flores Medina\nPrimer Apellido: Flores\nSegundo Apellido: Medina\nCURP: FFMS040331N/BO10\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2004-03-31\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(366,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0aaaf8-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Morales Castillo\nTítulo: Ing.\nPrimer Apellido: Morales\nSegundo Apellido: Castillo\nCURP: MLCL660721FB17\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1966-07-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(367,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0b3d84-51e8-11f0-9f2b-00155d276843\nNombre: Chris Vega Silva\nTítulo: Lic.\nPrimer Apellido: Vega\nSegundo Apellido: Silva\nCURP: VSC670305N/BQ40\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1967-03-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(368,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0bce6c-51e8-11f0-9f2b-00155d276843\nNombre: Morgan Medina Mendoza\nTítulo: Dr.\nPrimer Apellido: Medina\nSegundo Apellido: Mendoza\nCURP: MMM600413N/BJ21\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1960-04-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(369,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0c4554-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Torres Reyes\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Reyes\nCURP: TTRA600430FB32\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1960-04-30\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(370,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0cb9b8-51e8-11f0-9f2b-00155d276843\nNombre: María Fernández Jiménez\nTítulo: Dr.\nPrimer Apellido: Fernández\nSegundo Apellido: Jiménez\nCURP: FFJM840626FG23\nGénero: F\nGrupo Sanguíneo: AB-\nFecha de Nacimiento: 1984-06-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(371,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0d38de-51e8-11f0-9f2b-00155d276843\nNombre: Camila Fernández Reyes\nTítulo: Dr.\nPrimer Apellido: Fernández\nSegundo Apellido: Reyes\nCURP: FFRC840302FP23\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1984-03-02\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(372,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0dbb33-51e8-11f0-9f2b-00155d276843\nNombre: Juan Sánchez Pérez\nTítulo: Ing.\nPrimer Apellido: Sánchez\nSegundo Apellido: Pérez\nCURP: SSPJ870718MF12\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1987-07-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(373,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0e58e3-51e8-11f0-9f2b-00155d276843\nNombre: Robin Domínguez Delgado\nTítulo: Lic.\nPrimer Apellido: Domínguez\nSegundo Apellido: Delgado\nCURP: DDDR960524N/BN32\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1996-05-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(374,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0ed0e0-51e8-11f0-9f2b-00155d276843\nNombre: Gabriela Ortega Vargas\nTítulo: Dr.\nPrimer Apellido: Ortega\nSegundo Apellido: Vargas\nCURP: OVG581216FO98\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1958-12-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(375,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0f4853-51e8-11f0-9f2b-00155d276843\nNombre: Morgan Vega Mendoza\nPrimer Apellido: Vega\nSegundo Apellido: Mendoza\nCURP: VMM050401N/BT92\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2005-04-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(376,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef0fce9c-51e8-11f0-9f2b-00155d276843\nNombre: Robin Domínguez Domínguez\nPrimer Apellido: Domínguez\nSegundo Apellido: Domínguez\nCURP: DDDR020514N/BZ17\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2002-05-14\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(377,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef108a26-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Ramírez Cruz\nTítulo: Ing.\nPrimer Apellido: Ramírez\nSegundo Apellido: Cruz\nCURP: RMCE740713MN44\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1974-07-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(378,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1141da-51e8-11f0-9f2b-00155d276843\nNombre: Casey Delgado Delgado\nTítulo: Dr.\nPrimer Apellido: Delgado\nSegundo Apellido: Delgado\nCURP: DDDC531129N/BX76\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1953-11-29\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(379,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef11b901-51e8-11f0-9f2b-00155d276843\nNombre: Chris Escobar Escobar\nTítulo: Dr.\nPrimer Apellido: Escobar\nSegundo Apellido: Escobar\nCURP: EREC950213N/BI32\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1995-02-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(380,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef125a98-51e8-11f0-9f2b-00155d276843\nNombre: María Castillo Jiménez\nTítulo: Dr.\nPrimer Apellido: Castillo\nSegundo Apellido: Jiménez\nCURP: CSJM580312FM39\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1958-03-12\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(381,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef12feb8-51e8-11f0-9f2b-00155d276843\nNombre: Andrés González López\nTítulo: Dr.\nPrimer Apellido: González\nSegundo Apellido: López\nCURP: GGLA770528ME44\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1977-05-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(382,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef13be7a-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Rodríguez Pérez\nTítulo: Lic.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Pérez\nCURP: RRPC990426MW34\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1999-04-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(383,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef14680c-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Sánchez Rodríguez\nPrimer Apellido: Sánchez\nSegundo Apellido: Rodríguez\nCURP: SSRE050805MV33\nGénero: M\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 2005-08-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(384,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef14fe31-51e8-11f0-9f2b-00155d276843\nNombre: Juan González García\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: García\nCURP: GGGJ951105MJ96\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1995-11-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(385,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef15aa40-51e8-11f0-9f2b-00155d276843\nNombre: Casey Aguilar Medina\nTítulo: Dr.\nPrimer Apellido: Aguilar\nSegundo Apellido: Medina\nCURP: AGMC600716N/BU64\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1960-07-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(386,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef164345-51e8-11f0-9f2b-00155d276843\nNombre: Sky Domínguez Medina\nTítulo: Lic.\nPrimer Apellido: Domínguez\nSegundo Apellido: Medina\nCURP: DDMS610711N/BB49\nGénero: N/B\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 1961-07-11\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(387,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef16e091-51e8-11f0-9f2b-00155d276843\nNombre: María Morales Castillo\nTítulo: Lic.\nPrimer Apellido: Morales\nSegundo Apellido: Castillo\nCURP: MLCM860923FW42\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1986-09-23\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(388,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef17941c-51e8-11f0-9f2b-00155d276843\nNombre: Carlos Hernández López\nTítulo: Ing.\nPrimer Apellido: Hernández\nSegundo Apellido: López\nCURP: HHLC961222MR53\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1996-12-22\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(389,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef18656b-51e8-11f0-9f2b-00155d276843\nNombre: María Torres Ortega\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Ortega\nCURP: TTOM680112FI27\nGénero: F\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 1968-01-12\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(390,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef191157-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro Ramírez González\nTítulo: Lic.\nPrimer Apellido: Ramírez\nSegundo Apellido: González\nCURP: RMGA830913MM87\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1983-09-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(391,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef19d52e-51e8-11f0-9f2b-00155d276843\nNombre: Camila Navarro Navarro\nTítulo: Ing.\nPrimer Apellido: Navarro\nSegundo Apellido: Navarro\nCURP: NVNC831004FI80\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1983-10-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(392,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1aae5b-51e8-11f0-9f2b-00155d276843\nNombre: Miguel López Pérez\nTítulo: Lic.\nPrimer Apellido: López\nSegundo Apellido: Pérez\nCURP: LLPM650415MZ90\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1965-04-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(393,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1b3fc3-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Navarro Jiménez\nTítulo: Dr.\nPrimer Apellido: Navarro\nSegundo Apellido: Jiménez\nCURP: NVJA601016FV84\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1960-10-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(394,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1c05f5-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Silva Medina\nTítulo: Lic.\nPrimer Apellido: Silva\nSegundo Apellido: Medina\nCURP: SMJ820823N/BC22\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1982-08-23\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(395,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1c9115-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Gutiérrez Morales\nTítulo: Lic.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Morales\nCURP: GGMA880916FK39\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1988-09-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(396,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1d41c2-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Pérez Sánchez\nTítulo: Dr.\nPrimer Apellido: Pérez\nSegundo Apellido: Sánchez\nCURP: PPSR501201MB52\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1950-12-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(397,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1db9d6-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Jiménez Morales\nTítulo: Lic.\nPrimer Apellido: Jiménez\nSegundo Apellido: Morales\nCURP: JJMV731124FK79\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1973-11-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(398,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1e60d7-51e8-11f0-9f2b-00155d276843\nNombre: Juan Hernández Rodríguez\nTítulo: Dr.\nPrimer Apellido: Hernández\nSegundo Apellido: Rodríguez\nCURP: HHRJ591209MX26\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1959-12-09\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(399,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1ee00a-51e8-11f0-9f2b-00155d276843\nNombre: Valeria Reyes Gutiérrez\nTítulo: Lic.\nPrimer Apellido: Reyes\nSegundo Apellido: Gutiérrez\nCURP: RRGV560424FK20\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1956-04-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(400,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef1f78b2-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro Cruz Cruz\nTítulo: Dr.\nPrimer Apellido: Cruz\nSegundo Apellido: Cruz\nCURP: CCCA950930MB41\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1995-09-30\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(401,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef20029d-51e8-11f0-9f2b-00155d276843\nNombre: Luis Martínez González\nTítulo: Ing.\nPrimer Apellido: Martínez\nSegundo Apellido: González\nCURP: MRGL681021MZ14\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1968-10-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(402,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef20d16c-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Rodríguez López\nTítulo: Ing.\nPrimer Apellido: Rodríguez\nSegundo Apellido: López\nCURP: RRLE930617MS36\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1993-06-17\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(403,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef215512-51e8-11f0-9f2b-00155d276843\nNombre: Miguel Martínez Pérez\nTítulo: Dr.\nPrimer Apellido: Martínez\nSegundo Apellido: Pérez\nCURP: MRPM891119MX59\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1989-11-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(404,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef21fb8b-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Fernández Jiménez\nTítulo: Lic.\nPrimer Apellido: Fernández\nSegundo Apellido: Jiménez\nCURP: FFJF791208FE53\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1979-12-08\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(405,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef22d066-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Ramírez López\nPrimer Apellido: Ramírez\nSegundo Apellido: López\nCURP: RMLE020607MG50\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2002-06-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(406,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef235faa-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Ortega Morales\nTítulo: Lic.\nPrimer Apellido: Ortega\nSegundo Apellido: Morales\nCURP: OMS770813FC73\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1977-08-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(407,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef23f327-51e8-11f0-9f2b-00155d276843\nNombre: Juan Rodríguez Cruz\nTítulo: Dr.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Cruz\nCURP: RRCJ471101MH63\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1947-11-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(408,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef247468-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Rojas Silva\nTítulo: Dr.\nPrimer Apellido: Rojas\nSegundo Apellido: Silva\nCURP: RSST460318N/BL97\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1946-03-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(409,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef250312-51e8-11f0-9f2b-00155d276843\nNombre: Dani Vega Escobar\nTítulo: Ing.\nPrimer Apellido: Vega\nSegundo Apellido: Escobar\nCURP: VED970811N/BY29\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1997-08-11\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(410,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef25a91c-51e8-11f0-9f2b-00155d276843\nNombre: Sam Mendoza Mendoza\nTítulo: Ing.\nPrimer Apellido: Mendoza\nSegundo Apellido: Mendoza\nCURP: MMS730516N/BJ79\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1973-05-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(411,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef26211c-51e8-11f0-9f2b-00155d276843\nNombre: Alex Escobar Domínguez\nTítulo: Lic.\nPrimer Apellido: Escobar\nSegundo Apellido: Domínguez\nCURP: ERDA750501N/BI41\nGénero: N/B\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1975-05-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(412,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef26cc10-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Hernández Sánchez\nTítulo: Lic.\nPrimer Apellido: Hernández\nSegundo Apellido: Sánchez\nCURP: HHSR961211MK69\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1996-12-11\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(413,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2785b1-51e8-11f0-9f2b-00155d276843\nNombre: Casey Escobar Silva\nTítulo: Dr.\nPrimer Apellido: Escobar\nSegundo Apellido: Silva\nCURP: ERSC860627N/BD11\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1986-06-27\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(414,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef281aba-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro Rodríguez Rodríguez\nTítulo: Lic.\nPrimer Apellido: Rodríguez\nSegundo Apellido: Rodríguez\nCURP: RRRA650912MM38\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1965-09-12\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(415,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef28b382-51e8-11f0-9f2b-00155d276843\nNombre: Sky Vega Delgado\nTítulo: Dr.\nPrimer Apellido: Vega\nSegundo Apellido: Delgado\nCURP: VDS650908N/BK81\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1965-09-08\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(416,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef294b3d-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Reyes Reyes\nTítulo: Dr.\nPrimer Apellido: Reyes\nSegundo Apellido: Reyes\nCURP: RRRA580124FO77\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1958-01-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(417,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef29fc6a-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Pérez López\nPrimer Apellido: Pérez\nSegundo Apellido: López\nCURP: PPLA001014MB72\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2000-10-14\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(418,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2a8a57-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Torres Jiménez\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Jiménez\nCURP: TTJL660909FW66\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1966-09-09\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(419,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2b1b77-51e8-11f0-9f2b-00155d276843\nNombre: Robin Aguilar Delgado\nTítulo: Ing.\nPrimer Apellido: Aguilar\nSegundo Apellido: Delgado\nCURP: AGDR680920N/BM88\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1968-09-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(420,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2ba795-51e8-11f0-9f2b-00155d276843\nNombre: Sam Silva Medina\nTítulo: Lic.\nPrimer Apellido: Silva\nSegundo Apellido: Medina\nCURP: SMS471020N/BD14\nGénero: N/B\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1947-10-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(421,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2c604b-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro Martínez Martínez\nTítulo: Ing.\nPrimer Apellido: Martínez\nSegundo Apellido: Martínez\nCURP: MRMA840821MF73\nGénero: M\nGrupo Sanguíneo: AB-\nFecha de Nacimiento: 1984-08-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(422,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2d1265-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Vega Aguilar\nTítulo: Ing.\nPrimer Apellido: Vega\nSegundo Apellido: Aguilar\nCURP: VAJ900830N/BZ58\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1990-08-30\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(423,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2dcf6e-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Navarro Castillo\nTítulo: Ing.\nPrimer Apellido: Navarro\nSegundo Apellido: Castillo\nCURP: NVCI930226FV85\nGénero: F\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1993-02-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(424,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2e5b43-51e8-11f0-9f2b-00155d276843\nNombre: Juan Pérez Pérez\nTítulo: Ing.\nPrimer Apellido: Pérez\nSegundo Apellido: Pérez\nCURP: PPPJ490215MD71\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1949-02-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(425,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2f10b2-51e8-11f0-9f2b-00155d276843\nNombre: Andrés García Hernández\nTítulo: Ing.\nPrimer Apellido: García\nSegundo Apellido: Hernández\nCURP: GRHA920604MA18\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1992-06-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(426,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef2f8d1c-51e8-11f0-9f2b-00155d276843\nNombre: Robin Rojas Domínguez\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Domínguez\nCURP: RSDR480727N/BA30\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1948-07-27\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(427,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef30349b-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Delgado Delgado\nTítulo: Ing.\nPrimer Apellido: Delgado\nSegundo Apellido: Delgado\nCURP: DDDT670429N/BS51\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1967-04-29\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(428,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef30c12a-51e8-11f0-9f2b-00155d276843\nNombre: Sofía Reyes Navarro\nTítulo: Ing.\nPrimer Apellido: Reyes\nSegundo Apellido: Navarro\nCURP: RRNS560216FN47\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1956-02-16\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(429,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef31911d-51e8-11f0-9f2b-00155d276843\nNombre: Javier Pérez García\nTítulo: Ing.\nPrimer Apellido: Pérez\nSegundo Apellido: García\nCURP: PPGJ900319MW17\nGénero: M\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1990-03-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(430,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3357f1-51e8-11f0-9f2b-00155d276843\nNombre: Alex Mendoza Silva\nTítulo: Lic.\nPrimer Apellido: Mendoza\nSegundo Apellido: Silva\nCURP: MSA701014N/BR49\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1970-10-14\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(431,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef342f41-51e8-11f0-9f2b-00155d276843\nNombre: Robin Medina Vega\nTítulo: Ing.\nPrimer Apellido: Medina\nSegundo Apellido: Vega\nCURP: MVR730426N/BR53\nGénero: N/B\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1973-04-26\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(432,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef34d458-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Rojas Vega\nTítulo: Lic.\nPrimer Apellido: Rojas\nSegundo Apellido: Vega\nCURP: RSVJ761106N/BJ50\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1976-11-06\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(433,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3560c5-51e8-11f0-9f2b-00155d276843\nNombre: Camila Morales Gutiérrez\nTítulo: Ing.\nPrimer Apellido: Morales\nSegundo Apellido: Gutiérrez\nCURP: MLGC870813FW22\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1987-08-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(434,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef36035b-51e8-11f0-9f2b-00155d276843\nNombre: Juan González López\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: López\nCURP: GGLJ770721ML30\nGénero: M\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1977-07-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(435,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef36b6eb-51e8-11f0-9f2b-00155d276843\nNombre: Alejandra Gutiérrez Castillo\nTítulo: Lic.\nPrimer Apellido: Gutiérrez\nSegundo Apellido: Castillo\nCURP: GGCA561018FW33\nGénero: F\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1956-10-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(436,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3746b6-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Silva Silva\nTítulo: Lic.\nPrimer Apellido: Silva\nSegundo Apellido: Silva\nCURP: SSJ570315N/BH62\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1957-03-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(437,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef37ed4e-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Vargas Torres\nTítulo: Ing.\nPrimer Apellido: Vargas\nSegundo Apellido: Torres\nCURP: VRTI570605FQ87\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1957-06-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(438,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef386cd2-51e8-11f0-9f2b-00155d276843\nNombre: Camila Navarro Fernández\nTítulo: Ing.\nPrimer Apellido: Navarro\nSegundo Apellido: Fernández\nCURP: NVFC910618FJ36\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1991-06-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(439,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef390f44-51e8-11f0-9f2b-00155d276843\nNombre: Andrés Ramírez González\nTítulo: Dr.\nPrimer Apellido: Ramírez\nSegundo Apellido: González\nCURP: RMGA760720MO29\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1976-07-20\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(440,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3990b7-51e8-11f0-9f2b-00155d276843\nNombre: Luis Pérez García\nTítulo: Lic.\nPrimer Apellido: Pérez\nSegundo Apellido: García\nCURP: PPGL820514MZ65\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1982-05-14\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(441,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3a2690-51e8-11f0-9f2b-00155d276843\nNombre: Javier Sánchez Pérez\nTítulo: Ing.\nPrimer Apellido: Sánchez\nSegundo Apellido: Pérez\nCURP: SSPJ560828MK82\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1956-08-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(442,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3ad2ef-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro González Rodríguez\nPrimer Apellido: González\nSegundo Apellido: Rodríguez\nCURP: GGRA051019MX57\nGénero: M\nGrupo Sanguíneo: B-\nFecha de Nacimiento: 2005-10-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(443,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3b5b48-51e8-11f0-9f2b-00155d276843\nNombre: Alejandro Cruz Cruz\nTítulo: Ing.\nPrimer Apellido: Cruz\nSegundo Apellido: Cruz\nCURP: CCCA510304MI12\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1951-03-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(444,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3bda30-51e8-11f0-9f2b-00155d276843\nNombre: Morgan Rojas Flores\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Flores\nCURP: RSFM611028N/BJ61\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1961-10-28\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(445,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3c5d92-51e8-11f0-9f2b-00155d276843\nNombre: Juan Ramírez Martínez\nPrimer Apellido: Ramírez\nSegundo Apellido: Martínez\nCURP: RMMJ010215MP35\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2001-02-15\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(446,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3d5f33-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Vargas Morales\nTítulo: Ing.\nPrimer Apellido: Vargas\nSegundo Apellido: Morales\nCURP: VRML490206FC50\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1949-02-06\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(447,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3de08d-51e8-11f0-9f2b-00155d276843\nNombre: Alex Silva Flores\nTítulo: Ing.\nPrimer Apellido: Silva\nSegundo Apellido: Flores\nCURP: SFA580911N/BA26\nGénero: N/B\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1958-09-11\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(448,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3e6e20-51e8-11f0-9f2b-00155d276843\nNombre: Lucía Navarro Ortega\nTítulo: Dr.\nPrimer Apellido: Navarro\nSegundo Apellido: Ortega\nCURP: NVOL660301FP97\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1966-03-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(449,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3ef5ad-51e8-11f0-9f2b-00155d276843\nNombre: Sky Domínguez Vega\nTítulo: Ing.\nPrimer Apellido: Domínguez\nSegundo Apellido: Vega\nCURP: DDVS470904N/BD67\nGénero: N/B\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1947-09-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(450,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef3faa54-51e8-11f0-9f2b-00155d276843\nNombre: Isabel Ortega Ortega\nTítulo: Lic.\nPrimer Apellido: Ortega\nSegundo Apellido: Ortega\nCURP: OOI811224FT59\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1981-12-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(451,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef402e1c-51e8-11f0-9f2b-00155d276843\nNombre: María Reyes Gutiérrez\nTítulo: Lic.\nPrimer Apellido: Reyes\nSegundo Apellido: Gutiérrez\nCURP: RRGM800717FH98\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1980-07-17\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(452,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef40bbcc-51e8-11f0-9f2b-00155d276843\nNombre: Taylor Medina Rojas\nTítulo: Lic.\nPrimer Apellido: Medina\nSegundo Apellido: Rojas\nCURP: MRT451007N/BM33\nGénero: N/B\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1945-10-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(453,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef415602-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Escobar Medina\nTítulo: Lic.\nPrimer Apellido: Escobar\nSegundo Apellido: Medina\nCURP: ERMJ460408N/BB85\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1946-04-08\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(454,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef41da14-51e8-11f0-9f2b-00155d276843\nNombre: Morgan Rojas Silva\nTítulo: Ing.\nPrimer Apellido: Rojas\nSegundo Apellido: Silva\nCURP: RSSM000202N/BR11\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2000-02-02\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(455,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef425d5f-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Hernández Martínez\nTítulo: Dr.\nPrimer Apellido: Hernández\nSegundo Apellido: Martínez\nCURP: HHME531119MV13\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1953-11-19\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(456,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef42eae1-51e8-11f0-9f2b-00155d276843\nNombre: Juan Pérez Ramírez\nTítulo: Lic.\nPrimer Apellido: Pérez\nSegundo Apellido: Ramírez\nCURP: PPRJ620421MX66\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 1962-04-21\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(457,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef438ae0-51e8-11f0-9f2b-00155d276843\nNombre: Gabriela Torres Vargas\nTítulo: Ing.\nPrimer Apellido: Torres\nSegundo Apellido: Vargas\nCURP: TTVG000607FQ29\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2000-06-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(458,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef441ece-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Pérez Cruz\nTítulo: Dr.\nPrimer Apellido: Pérez\nSegundo Apellido: Cruz\nCURP: PPCR941124MY95\nGénero: M\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1994-11-24\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(459,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef44a2e0-51e8-11f0-9f2b-00155d276843\nNombre: Robin Escobar Mendoza\nTítulo: Dr.\nPrimer Apellido: Escobar\nSegundo Apellido: Mendoza\nCURP: ERMR470425N/BI47\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1947-04-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(460,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4546af-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Pérez Sánchez\nTítulo: Ing.\nPrimer Apellido: Pérez\nSegundo Apellido: Sánchez\nCURP: PPSR701105MB36\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1970-11-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(461,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef45f992-51e8-11f0-9f2b-00155d276843\nNombre: Robin Vega Rojas\nTítulo: Dr.\nPrimer Apellido: Vega\nSegundo Apellido: Rojas\nCURP: VRR890725N/BO43\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1989-07-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(462,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4688bc-51e8-11f0-9f2b-00155d276843\nNombre: Jordan Delgado Delgado\nTítulo: Lic.\nPrimer Apellido: Delgado\nSegundo Apellido: Delgado\nCURP: DDDJ590213N/BT71\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1959-02-13\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(463,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4717e1-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Hernández Sánchez\nTítulo: Lic.\nPrimer Apellido: Hernández\nSegundo Apellido: Sánchez\nCURP: HHSE851004MV32\nGénero: M\nGrupo Sanguíneo: B+\nFecha de Nacimiento: 1985-10-04\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(464,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef47a397-51e8-11f0-9f2b-00155d276843\nNombre: Miguel González García\nPrimer Apellido: González\nSegundo Apellido: García\nCURP: GGGM020807MM65\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2002-08-07\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(465,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef484f3b-51e8-11f0-9f2b-00155d276843\nNombre: Andrea Reyes Ortega\nPrimer Apellido: Reyes\nSegundo Apellido: Ortega\nCURP: RROA000714FG67\nGénero: F\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2000-07-14\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(466,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef48f9de-51e8-11f0-9f2b-00155d276843\nNombre: Luis Hernández García\nPrimer Apellido: Hernández\nSegundo Apellido: García\nCURP: HHGL040108MS70\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 2004-01-08\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(467,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef498728-51e8-11f0-9f2b-00155d276843\nNombre: Fernanda Fernández Castillo\nTítulo: Lic.\nPrimer Apellido: Fernández\nSegundo Apellido: Castillo\nCURP: FFCF601222FF71\nGénero: F\nGrupo Sanguíneo: AB+\nFecha de Nacimiento: 1960-12-22\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(468,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4a14d9-51e8-11f0-9f2b-00155d276843\nNombre: Andrés González González\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: González\nCURP: GGGA960906MP58\nGénero: M\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1996-09-06\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(469,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4ab2fa-51e8-11f0-9f2b-00155d276843\nNombre: Sam Medina Mendoza\nTítulo: Lic.\nPrimer Apellido: Medina\nSegundo Apellido: Mendoza\nCURP: MMS661003N/BU75\nGénero: N/B\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1966-10-03\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(470,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4b4650-51e8-11f0-9f2b-00155d276843\nNombre: Ricardo Sánchez López\nTítulo: Lic.\nPrimer Apellido: Sánchez\nSegundo Apellido: López\nCURP: SSLR760125ME22\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1976-01-25\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(471,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4bcac0-51e8-11f0-9f2b-00155d276843\nNombre: Juan González López\nTítulo: Ing.\nPrimer Apellido: González\nSegundo Apellido: López\nCURP: GGLJ720905MZ96\nGénero: M\nGrupo Sanguíneo: O-\nFecha de Nacimiento: 1972-09-05\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(472,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4c508a-51e8-11f0-9f2b-00155d276843\nNombre: Gabriela Fernández Reyes\nTítulo: Ing.\nPrimer Apellido: Fernández\nSegundo Apellido: Reyes\nCURP: FFRG720901FP78\nGénero: F\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1972-09-01\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(473,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4cebd1-51e8-11f0-9f2b-00155d276843\nNombre: Javier González Ramírez\nTítulo: Lic.\nPrimer Apellido: González\nSegundo Apellido: Ramírez\nCURP: GGRJ981210MD52\nGénero: M\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 1998-12-10\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(474,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4d8ffe-51e8-11f0-9f2b-00155d276843\nNombre: Eduardo Ramírez Ramírez\nTítulo: Dr.\nPrimer Apellido: Ramírez\nSegundo Apellido: Ramírez\nCURP: RMRE890611MC36\nGénero: M\nGrupo Sanguíneo: O+\nFecha de Nacimiento: 1989-06-11\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(475,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4e1734-51e8-11f0-9f2b-00155d276843\nNombre: Luis Rodríguez Pérez\nPrimer Apellido: Rodríguez\nSegundo Apellido: Pérez\nCURP: RRPL070527MF12\nGénero: M\nGrupo Sanguíneo: A+\nFecha de Nacimiento: 2007-05-27\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(476,'root@localhost','Create','tbb_personas','Se ha agregado una nueva PERSONA con el ID: ef4e9c63-51e8-11f0-9f2b-00155d276843\nNombre: María Morales Ortega\nPrimer Apellido: Morales\nSegundo Apellido: Ortega\nCURP: MLOM030318FM70\nGénero: F\nGrupo Sanguíneo: A-\nFecha de Nacimiento: 2003-03-18\nEstatus: 1',_binary '','2025-06-25 11:22:13'),(477,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.gonzález652@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(478,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.domínguez382@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(479,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.domínguez117@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(480,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.rodríguez354@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(481,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.martínez391@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(482,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: gabriela.navarro451@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(483,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.rojas682@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(484,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.jiménez326@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(485,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.castillo762@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(486,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.castillo998@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(487,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.delgado124@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(488,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.rodríguez626@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(489,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.garcía620@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(490,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.aguilar908@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(491,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.ortega456@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(492,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.rodríguez971@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(493,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.torres119@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(494,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.pérez127@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(495,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.torres770@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(496,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.torres212@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(497,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.rojas518@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(498,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.medina485@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(499,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.medina349@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(500,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.vega586@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(501,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.ortega171@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(502,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.navarro622@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(503,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.gutiérrez535@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(504,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.garcía114@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(505,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.gutiérrez538@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(506,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.torres727@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(507,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.castillo885@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(508,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.torres902@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(509,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.morales149@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(510,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.ortega581@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(511,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.martínez997@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(512,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.sánchez800@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(513,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.navarro280@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(514,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.reyes761@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(515,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.aguilar106@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(516,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.lópez170@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(517,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.lópez477@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(518,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.pérez639@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(519,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.torres531@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(520,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.sánchez152@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(521,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.sánchez133@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(522,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.gutiérrez108@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(523,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.aguilar293@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(524,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.mendoza847@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(525,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.gonzález504@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(526,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.lópez948@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(527,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.domínguez885@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(528,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.martínez921@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(529,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.flores318@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(530,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.pérez390@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(531,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.medina923@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(532,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.mendoza633@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(533,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: morgan.vega231@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(534,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.ramírez233@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(535,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.garcía144@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(536,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.flores980@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(537,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.flores610@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(538,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.sánchez459@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(539,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.mendoza158@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(540,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.reyes113@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(541,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.domínguez981@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(542,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.pérez742@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(543,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.aguilar723@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(544,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.martínez786@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(545,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.ortega655@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(546,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.ortega787@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(547,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.martínez186@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(548,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.medina189@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(549,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.gonzález221@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(550,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.pérez283@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(551,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.jiménez151@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(552,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.ortega988@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(553,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.morales975@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(554,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.morales614@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(555,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.ramírez367@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(556,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.pérez843@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(557,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.sánchez344@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(558,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.lópez177@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(559,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.delgado647@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(560,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.gutiérrez746@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(561,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.jiménez174@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(562,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.delgado225@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(563,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.gonzález176@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(564,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.jiménez750@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(565,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.rojas888@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(566,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.reyes842@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(567,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.cruz235@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(568,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.gonzález955@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(569,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.ortega684@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(570,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.mendoza695@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(571,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.hernández307@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(572,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.garcía527@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(573,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.vega422@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(574,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.gonzález586@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(575,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.mendoza368@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(576,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.flores639@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(577,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.rojas639@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(578,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.silva206@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(579,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.torres152@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(580,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.flores447@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(581,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.delgado888@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(582,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.gutiérrez331@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(583,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.medina212@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(584,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.domínguez198@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(585,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.silva311@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(586,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.silva707@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(587,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.vargas707@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(588,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.ortega835@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(589,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.rojas652@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(590,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.hernández576@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(591,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.rojas771@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(592,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.jiménez172@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(593,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.medina180@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(594,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.navarro319@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(595,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.gutiérrez586@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(596,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.navarro529@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(597,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.pérez875@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(598,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.lópez766@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(599,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.aguilar382@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(600,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.flores812@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(601,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.sánchez299@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(602,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.aguilar943@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(603,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.garcía464@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(604,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.jiménez235@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(605,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.morales846@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(606,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.delgado379@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(607,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.domínguez544@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(608,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.jiménez207@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(609,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.vega188@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(610,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.lópez122@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(611,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.martínez809@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(612,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.cruz358@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(613,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.sánchez549@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(614,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.gutiérrez105@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(615,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.castillo720@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(616,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.garcía995@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(617,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.vargas365@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(618,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.reyes694@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(619,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.medina561@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(620,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.jiménez507@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(621,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.flores925@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(622,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.castillo863@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(623,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.medina870@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(624,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.castillo134@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(625,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.castillo865@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(626,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.flores521@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(627,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.delgado649@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(628,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.escobar590@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(629,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.cruz539@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(630,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.escobar483@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(631,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.martínez578@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(632,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.rojas731@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(633,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.aguilar730@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(634,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.domínguez438@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(635,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.rodríguez261@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(636,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.reyes208@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(637,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.rodríguez964@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(638,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.gonzález836@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(639,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.rojas815@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(640,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.medina426@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(641,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.domínguez171@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(642,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.gutiérrez121@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(643,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernando.martínez860@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(644,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.castillo772@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(645,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.lópez745@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(646,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.vargas410@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(647,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.cruz422@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(648,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.gonzález101@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(649,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.gutiérrez665@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(650,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.jiménez415@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:13'),(651,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.rodríguez519@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(652,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.aguilar366@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(653,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.vega780@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(654,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.pérez461@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(655,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.escobar594@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(656,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.fernández793@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(657,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.ramírez723@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(658,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.castillo403@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(659,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.hernández420@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(660,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.martínez725@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(661,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.fernández724@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(662,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.cruz869@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(663,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.vargas981@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(664,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.jiménez903@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(665,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.flores757@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(666,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.morales268@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(667,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.vega268@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(668,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: morgan.medina179@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(669,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.torres243@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(670,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.fernández541@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(671,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.fernández569@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(672,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.sánchez178@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(673,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.domínguez778@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(674,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: gabriela.ortega441@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(675,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: morgan.vega140@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(676,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.domínguez781@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(677,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.ramírez300@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(678,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.delgado971@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(679,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: chris.escobar932@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(680,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.castillo141@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(681,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.gonzález989@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(682,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.rodríguez188@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(683,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.sánchez668@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(684,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.gonzález810@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(685,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.aguilar498@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(686,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.domínguez231@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(687,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.morales410@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(688,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: carlos.hernández375@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(689,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.torres290@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(690,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.ramírez778@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(691,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.navarro596@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(692,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.lópez302@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(693,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.navarro637@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(694,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.silva529@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(695,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.gutiérrez425@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(696,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.pérez421@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(697,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.jiménez148@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(698,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.hernández639@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(699,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: valeria.reyes399@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(700,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.cruz781@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(701,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.martínez640@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(702,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.rodríguez788@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(703,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.martínez659@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(704,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.fernández222@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(705,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.ramírez535@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(706,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.ortega144@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(707,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.rodríguez788@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(708,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.rojas479@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(709,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: dani.vega737@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(710,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.mendoza865@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(711,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.escobar498@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(712,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.hernández823@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(713,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: casey.escobar928@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(714,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.rodríguez772@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(715,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.vega784@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(716,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.reyes343@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(717,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.pérez315@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(718,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.torres379@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(719,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.aguilar938@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(720,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.silva415@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(721,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.martínez738@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(722,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.vega163@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(723,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.navarro571@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(724,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.pérez126@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(725,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.garcía655@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(726,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.rojas367@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(727,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.delgado963@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(728,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sofía.reyes222@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(729,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.pérez806@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(730,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.mendoza321@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(731,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.medina899@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(732,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.rojas605@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(733,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.morales713@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(734,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.gonzález320@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(735,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandra.gutiérrez908@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(736,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.silva241@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(737,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.vargas118@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(738,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: camila.navarro442@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(739,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.ramírez775@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(740,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.pérez777@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(741,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.sánchez396@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(742,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.gonzález195@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(743,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alejandro.cruz797@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(744,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: morgan.rojas202@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(745,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.ramírez322@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(746,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.vargas655@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(747,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: alex.silva705@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(748,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: lucía.navarro783@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(749,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sky.domínguez939@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(750,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: isabel.ortega533@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(751,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.reyes656@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(752,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: taylor.medina967@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(753,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.escobar658@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(754,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: morgan.rojas890@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(755,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.hernández838@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(756,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.pérez344@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(757,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: gabriela.torres783@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(758,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.pérez471@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(759,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.escobar114@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(760,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.pérez309@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(761,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: robin.vega519@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(762,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: jordan.delgado912@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(763,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.hernández965@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(764,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: miguel.gonzález717@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(765,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrea.reyes508@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(766,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.hernández348@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(767,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: fernanda.fernández820@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(768,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: andrés.gonzález413@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(769,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: sam.medina523@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(770,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: ricardo.sánchez385@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(771,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: juan.gonzález580@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(772,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: gabriela.fernández592@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(773,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: javier.gonzález513@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(774,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: eduardo.ramírez368@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(775,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: luis.rodríguez203@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14'),(776,'root@localhost','Create','tbd_usuarios_roles','Se ha asignado el ROL: Administrador\nAl USUARIO con correo: maría.morales292@ejemplo.com\nEstatus: ',_binary '','2025-06-25 11:22:14');
/*!40000 ALTER TABLE `tbi_bitacora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_grupos_sanguineos`
--

DROP TABLE IF EXISTS `vista_grupos_sanguineos`;
/*!50001 DROP VIEW IF EXISTS `vista_grupos_sanguineos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_grupos_sanguineos` AS SELECT 
 1 AS `Grupo_Sanguineo`,
 1 AS `Genero`,
 1 AS `cantidad_personas`,
 1 AS `porcentaje`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_roles_usuarios`
--

DROP TABLE IF EXISTS `vista_roles_usuarios`;
/*!50001 DROP VIEW IF EXISTS `vista_roles_usuarios`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_roles_usuarios` AS SELECT 
 1 AS `Rol`,
 1 AS `Total_Usuarios`,
 1 AS `Total_Hombres`,
 1 AS `Total_Mujeres`,
 1 AS `Total_N/B`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'hospital_general_8a_idgs_220526'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `db_evento` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `db_evento` ON SCHEDULE EVERY 1 MINUTE STARTS '2025-03-19 09:50:03' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN 
call hospital_general_8a_idgs_220219.SP_InsertarPersonas(10, 'M', '1990-10-01', '2024-01-01');
call hospital_general_8a_idgs_220219.SP_LimpiarPersonas();
SELECT * FROM hospital_general_8a_idgs_220219.vista_grupos_sanguineos;
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `hospital_general_8a_idgs_220219` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `hospital_general_8a_idgs_220219` ON SCHEDULE EVERY 1 MINUTE STARTS '2025-03-19 09:47:51' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN 
call hospital_general_8a_idgs_220219.SP_InsertarPersonas(10, 'M', '1990-10-01', '2024-01-01');
call hospital_general_8a_idgs_220219.SP_LimpiarPersonas();
SELECT * FROM hospital_general_8a_idgs_220219.vista_grupos_sanguineos;
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'hospital_general_8a_idgs_220526'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_calcula_edad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcula_edad`(v_fecha_nacimiento DATE) RETURNS int
    DETERMINISTIC
BEGIN
RETURN TIMESTAMPDIFF(YEAR, v_fecha_nacimiento, CURDATE());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_apellido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_apellido`(p_Genero ENUM('M', 'F', 'N/B')) RETURNS varchar(80) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE apellido VARCHAR(80);

    -- Seleccionar un apellido aleatorio
    IF p_Genero = 'M' THEN
        SET apellido = (SELECT ELT(FLOOR(1 + (RAND() * 10)), 
            'García', 'López', 'Martínez', 'Hernández', 'González', 'Pérez', 'Rodríguez', 'Sánchez', 'Ramírez', 'Cruz',  
            'Flores', 'Gutiérrez', 'Jiménez', 'Morales', 'Castillo', 'Ortega', 'Navarro', 'Reyes', 'Aguilar', 'Delgado',  
            'Mendoza', 'Rojas', 'Vega', 'Silva', 'Medina', 'Domínguez', 'Escobar', 'Ortiz', 'Guerrero', 'Paredes',  
            'Campos', 'Luna', 'Vázquez', 'Valenzuela', 'Salinas', 'Fuentes', 'Carrillo', 'Maldonado', 'Mejía', 'Contreras',  
            'Miranda', 'Peralta', 'Álvarez', 'Romero', 'Nuñez', 'Zamora', 'Méndez', 'Chávez', 'Pizarro', 'Ramos',  
            'Suárez', 'Benítez', 'León', 'Montoya', 'Peña', 'Cabrera', 'Cárdenas', 'Espinoza', 'Castro', 'Riviera',  
            'Cordero', 'Arriaga', 'Figueroa', 'Esquivel', 'Bermúdez', 'Galindo', 'Gómez', 'Solís', 'Del Río', 'Sepúlveda',  
            'Villanueva', 'Crespo', 'Estévez', 'Rebolledo', 'Carmona', 'Varela', 'Sandoval', 'Palacios', 'Rico', 'Ojeda',  
            'Valverde', 'Arce', 'Montes', 'Cedillo', 'Ibarra', 'Acevedo', 'Padilla', 'Mora', 'Santos', 'Arellano',  
            'Espinosa', 'Plascencia', 'Valladares', 'Olivares', 'Quezada', 'Salcedo', 'Escamilla', 'Tovar', 'Guevara', 'Barrios'));  
    ELSEIF p_Genero = 'F' THEN
        SET apellido = (SELECT ELT(FLOOR(1 + (RAND() * 10)), 
            'Fernández', 'Torres', 'Vargas', 'Jiménez', 'Castillo', 'Morales', 'Gutiérrez', 'Ortega', 'Navarro', 'Reyes',  
            'Maldonado', 'Miranda', 'Peralta', 'Álvarez', 'Romero', 'Nuñez', 'Zamora', 'Méndez', 'Chávez', 'Pizarro',  
            'Ramos', 'Suárez', 'Benítez', 'León', 'Montoya', 'Peña', 'Cabrera', 'Cárdenas', 'Espinoza', 'Castro',  
            'Riviera', 'Cordero', 'Arriaga', 'Figueroa', 'Esquivel', 'Bermúdez', 'Galindo', 'Gómez', 'Solís', 'Del Río',  
            'Sepúlveda', 'Villanueva', 'Crespo', 'Estévez', 'Rebolledo', 'Carmona', 'Varela', 'Sandoval', 'Palacios', 'Rico',  
            'Ojeda', 'Valverde', 'Arce', 'Montes', 'Cedillo', 'Ibarra', 'Acevedo', 'Padilla', 'Mora', 'Santos',  
            'Arellano', 'Espinosa', 'Plascencia', 'Valladares', 'Olivares', 'Quezada', 'Salcedo', 'Escamilla', 'Tovar', 'Guevara',  
            'Barrios', 'Campos', 'Luna', 'Vázquez', 'Valenzuela', 'Salinas', 'Fuentes', 'Carrillo', 'Mejía', 'Contreras',  
            'García', 'López', 'Martínez', 'Hernández', 'González', 'Pérez', 'Rodríguez', 'Sánchez', 'Ramírez', 'Cruz'  
        ));  
    ELSE
        SET apellido = (SELECT ELT(FLOOR(1 + (RAND() * 10)), 
            'Aguilar', 'Delgado', 'Flores', 'Mendoza', 'Rojas', 'Vega', 'Silva', 'Medina', 'Domínguez', 'Escobar',  
            'Ortiz', 'Guerrero', 'Paredes', 'Campos', 'Luna', 'Vázquez', 'Valenzuela', 'Salinas', 'Fuentes', 'Carrillo',  
            'Maldonado', 'Mejía', 'Contreras', 'Miranda', 'Peralta', 'Álvarez', 'Romero', 'Nuñez', 'Zamora', 'Méndez',  
            'Chávez', 'Pizarro', 'Ramos', 'Suárez', 'Benítez', 'León', 'Montoya', 'Peña', 'Cabrera', 'Cárdenas',  
            'Espinoza', 'Castro', 'Riviera', 'Cordero', 'Arriaga', 'Figueroa', 'Esquivel', 'Bermúdez', 'Galindo', 'Gómez',  
            'Solís', 'Del Río', 'Sepúlveda', 'Villanueva', 'Crespo', 'Estévez', 'Rebolledo', 'Carmona', 'Varela', 'Sandoval',  
            'Palacios', 'Rico', 'Ojeda', 'Valverde', 'Arce', 'Montes', 'Cedillo', 'Ibarra', 'Acevedo', 'Padilla',  
            'Mora', 'Santos', 'Arellano', 'Espinosa', 'Plascencia', 'Valladares', 'Olivares', 'Quezada', 'Salcedo', 'Escamilla',  
            'Tovar', 'Guevara', 'Barrios', 'García', 'López', 'Martínez', 'Hernández', 'González', 'Pérez', 'Rodríguez',  
            'Sánchez', 'Ramírez', 'Fernández', 'Torres', 'Vargas', 'Jiménez', 'Castillo', 'Morales', 'Gutiérrez', 'Ortega',  
            'Navarro', 'Reyes'  
        )); 
    END IF;

    RETURN apellido;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_curp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_curp`(
    p_Nombre VARCHAR(80),
    p_PrimerApellido VARCHAR(80),
    p_SegundoApellido VARCHAR(80),
    p_FechaNacimiento DATE,
    p_Genero ENUM('M', 'F', 'N/B')
) RETURNS varchar(18) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE curp VARCHAR(18);
    DECLARE anio CHAR(2);
    DECLARE mes CHAR(2);
    DECLARE dia CHAR(2);
    
    -- Obtener los dos últimos dígitos del año
    SET anio = RIGHT(YEAR(p_FechaNacimiento), 2);
    -- Obtener mes y día con formato de dos dígitos
    SET mes = LPAD(MONTH(p_FechaNacimiento), 2, '0');
    SET dia = LPAD(DAY(p_FechaNacimiento), 2, '0');
    
    SET curp = CONCAT(
        UPPER(LEFT(p_PrimerApellido, 1)), 
        UPPER(SUBSTRING(p_PrimerApellido, LOCATE('A', p_PrimerApellido)+1, 1)), 
        UPPER(LEFT(p_SegundoApellido, 1)), 
        UPPER(LEFT(p_Nombre, 1)), 
        anio, mes, dia, 
        UPPER(p_Genero), 
        ELT(FLOOR(1 + (RAND() * 26)), 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'),
        FLOOR(10 + (RAND() * 89)) -- Dos números aleatorios
    );
    
    RETURN curp;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_fecha_nacimiento` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_fecha_nacimiento`(fecha_inicio DATE, fecha_fin DATE) RETURNS date
    DETERMINISTIC
BEGIN
    DECLARE min_dias INT;
    DECLARE max_dias INT;
    DECLARE dias_aleatorios INT;
    DECLARE fecha_aleatoria DATE;

    SET min_dias = DATEDIFF(fecha_inicio, '1900-01-01');
    SET max_dias = DATEDIFF(fecha_fin, '1900-01-01');
    SET dias_aleatorios = fn_numero_aleatorio_rangos(min_dias, max_dias);
    SET fecha_aleatoria = DATE_ADD('1900-01-01', INTERVAL dias_aleatorios DAY);

    RETURN fecha_aleatoria;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_genero` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_genero`() RETURNS enum('M','F','N/B') CHARSET utf8mb4
    DETERMINISTIC
RETURN (SELECT ELT(FLOOR(1 + (RAND() * 3)), 'M', 'F', 'N/B')) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_grupo_sanguineo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_grupo_sanguineo`() RETURNS enum('A+','A-','B+','B-','O+','O-','AB+','AB-') CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE r FLOAT;
    SET r = RAND() * 100;

    RETURN CASE 
        WHEN r < 37 THEN 'O+'
        WHEN r < 71 THEN 'A+'
        WHEN r < 81 THEN 'B+'
        WHEN r < 85 THEN 'AB+'
        WHEN r < 91 THEN 'O-'
        WHEN r < 97 THEN 'A-'
        WHEN r < 99 THEN 'B-'
        ELSE 'AB-'
    END;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_nombre_simple` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_nombre_simple`(p_Genero ENUM('M', 'F', 'N/B')) RETURNS varchar(80) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE nombre VARCHAR(80);

    -- Seleccionar un nombre aleatorio según el género
    IF p_Genero = 'M' THEN
        SET nombre = (SELECT ELT(FLOOR(1 + (RAND() * 10)), 
            'Juan', 'Carlos', 'Luis', 'Miguel', 'Fernando', 'Alejandro', 'Ricardo', 'Eduardo', 'Javier', 'Andrés',  
            'Hugo', 'Daniel', 'Adrián', 'Manuel', 'Raúl', 'Francisco', 'Diego', 'Sebastián', 'Iván', 'Emilio',  
            'Enrique', 'Gerardo', 'Antonio', 'Jesús', 'Pablo', 'Roberto', 'Sergio', 'Martín', 'Joel', 'Gustavo',  
            'Arturo', 'Ramón', 'José', 'Ángel', 'Benjamín', 'Héctor', 'Rubén', 'Federico', 'Oscar', 'Efraín',  
            'Ernesto', 'Baltazar', 'Leandro', 'Maximiliano', 'Cristian', 'Adolfo', 'Vicente', 'Salvador', 'Elías', 'Abraham',  
            'Jonathan', 'Ismael', 'Matías', 'Mauricio', 'Joaquín', 'Mariano', 'Kevin', 'Abel', 'Ezequiel', 'Leonardo',  
            'Saúl', 'Esteban', 'Raúl', 'Humberto', 'Aníbal', 'Nicolás', 'Germán', 'Felipe', 'Rodrigo', 'Tobías',  
            'Agustín', 'Hernán', 'Axel', 'Ulises', 'Fausto', 'Julián', 'Camilo', 'Iván', 'Omar', 'Luciano',  
            'Simón', 'Orlando', 'Álvaro', 'Ramiro', 'Bruno', 'Damián', 'Fabián', 'Bautista', 'Emmanuel', 'Gastón',  
            'César', 'Tomás', 'Cristóbal', 'Fernando', 'Emanuel', 'Ignacio', 'Renato', 'Diego', 'Fabricio', 'Octavio',  
            'Sebastián', 'Gabriel', 'Rafael', 'Andrés', 'Marco', 'René', 'Jared', 'Josué', 'Adriano', 'Patricio',  
            'Lionel', 'Xavier', 'Darío', 'Jairo', 'Guillermo', 'Eduard', 'Lorenzo', 'Jacobo', 'Tristán', 'Valentín',  
            'Santiago', 'Elian', 'Gael', 'Dante', 'Celso', 'Emiliano', 'Franco', 'Ciro', 'Erick', 'León',  
            'Manuel', 'Nahuel', 'Thiago', 'Elián', 'Hugo', 'Mateo', 'Alberto', 'Felipe', 'Dorian', 'Lucio',  
            'Máximo', 'Facundo', 'Valerio', 'Marcos', 'Isidro', 'Armando', 'Claudio', 'Evaristo', 'Gregorio', 'Lázaro',  
            'Silvio', 'Tadeo', 'Vladímir', 'Boris', 'Estanislao', 'Fernando', 'Julio', 'Teodoro', 'Calixto', 'Cándido'  
        )); 
    ELSEIF p_Genero = 'F' THEN
        SET nombre = (SELECT ELT(FLOOR(1 + (RAND() * 10)), 
            'María', 'Gabriela', 'Fernanda', 'Sofía', 'Valeria', 'Alejandra', 'Isabel', 'Camila', 'Lucía', 'Andrea',  
            'Paula', 'Elena', 'Carla', 'Natalia', 'Diana', 'Patricia', 'Verónica', 'Beatriz', 'Rocío', 'Mónica',  
            'Laura', 'Silvia', 'Carmen', 'Blanca', 'Antonia', 'Esperanza', 'Renata', 'Claudia', 'Consuelo', 'Lourdes',  
            'Cristina', 'Bárbara', 'Ana', 'Eva', 'Daniela', 'Fabiola', 'Julieta', 'Magdalena', 'Rosalía', 'Virginia',  
            'Josefina', 'Gloria', 'Nuria', 'Miranda', 'Bianca', 'Estefanía', 'Margarita', 'Raquel', 'Brenda', 'Florencia',  
            'Lorena', 'Cecilia', 'Aurora', 'Adriana', 'Vanessa', 'Melissa', 'Emilia', 'Zaira', 'Maribel', 'Carolina',  
            'Cristal', 'Celeste', 'Genoveva', 'Nicolle', 'Pilar', 'Mireya', 'Montserrat', 'Jimena', 'Eugenia', 'Salomé',  
            'Regina', 'Ángela', 'Miriam', 'Tatiana', 'Elsa', 'Rebeca', 'Amelia', 'Josefa', 'Leticia', 'Mariana',  
            'Noemí', 'Aleida', 'Gabriella', 'Ágata', 'Ariadna', 'Natalie', 'Fabiana', 'Zulema', 'Anahí', 'Violeta',  
            'Beatriz', 'Micaela', 'Inés', 'Carina', 'Ester', 'Isidora', 'Tamara', 'Anabel', 'Milagros', 'Flor',  
            'Paloma', 'Itzel', 'Perla', 'Araceli', 'Berenice', 'Guadalupe', 'Alicia', 'Dafne', 'Andrea', 'Graciela',  
            'Valentina', 'Lina', 'Ximena', 'Malena', 'Sandra', 'Lilian', 'Emma', 'Teresa', 'Edith', 'Dalia',  
            'Camille', 'Samanta', 'Melina', 'Adela', 'Belén', 'Vania', 'Yolanda', 'Livia', 'Verena', 'Brianna',  
            'Elisa', 'Amparo', 'Tatiana', 'Odette', 'Priscila', 'Mirna', 'Marisol', 'Liliana', 'Zoraida', 'Dora'  
        )); 
    ELSE
        SET nombre = (SELECT ELT(FLOOR(1 + (RAND() * 10)), 
            'Alex', 'Sam', 'Jordan', 'Chris', 'Taylor', 'Morgan', 'Dani', 'Robin', 'Sky', 'Casey',  
            'Jessie', 'Jamie', 'Charlie', 'Blake', 'Devin', 'Parker', 'Riley', 'Cameron', 'Sasha', 'Quinn',  
            'Leslie', 'Dana', 'Reese', 'Finley', 'Kendall', 'Marion', 'Avery', 'Rowan', 'Dakota', 'Hayden',  
            'Lane', 'Jordan', 'River', 'Sage', 'Shay', 'Tatum', 'Kris', 'Kai', 'Luca', 'Emerson',  
            'Phoenix', 'Elliot', 'Jules', 'Arden', 'Frankie', 'Indigo', 'Peyton', 'Jaden', 'Aspen', 'Justice'  
        ));
    END IF;

    RETURN nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_numero_telefonico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_numero_telefonico`() RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE idx INT;
    DECLARE area_code VARCHAR(10);  -- Se aumentó el tamaño de 5 a 10
    DECLARE sub_number VARCHAR(10);
    DECLARE area_length INT;
    -- Selecciona un código de área aleatorio entre 1 y 89 (total de códigos en la lista)
    SET idx = FLOOR(1 + RAND() * 89);
    SET area_code = ELT(idx,
      '449','776','764',
      '646','661',
      '612','613','624',
      '981',
      '961','962','966',
      '614','625','626',
      '55',
      '844','861','862',
      '312','313','314',
      '618','671','674',
      '55','722','728',
      '412','413','414',
      '744','745','747',
      '771','772','773',
      '312','315','317',
      '351','352','353',
      '731','732','733',
      '311','319','324',
      '81','826','828',
      '951','953','954',
      '221','222','223',
      '442','441','448',
      '983','984','998',
      '444','481','482',
      '667','668','669',
      '621','622','623',
      '993','913','914',
      '831','832','833',
      '241','246','247',
      '228','229','271',
      '999','988','997',
      '492','493','494'
    );
    SET area_length = CHAR_LENGTH(area_code);
    IF area_length = 2 THEN
         -- Para códigos de área de 2 dígitos (ej. Ciudad de México o Estado de México)
         SET sub_number = LPAD(FLOOR(RAND()*100000000), 8, '0');
         RETURN CONCAT('+52 ', area_code, ' ', SUBSTRING(sub_number, 1, 4), ' ', SUBSTRING(sub_number, 5, 4));
    ELSE
         -- Para códigos de área de 3 dígitos (la mayoría de los estados)
         SET sub_number = LPAD(FLOOR(RAND()*10000000), 7, '0');
         RETURN CONCAT('+52 ', area_code, ' ', SUBSTRING(sub_number, 1, 3), ' ', SUBSTRING(sub_number, 4, 4));
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_genera_titulo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_genera_titulo`() RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
RETURN (SELECT ELT(FLOOR(1 + (RAND() * 3)), 'Dr.', 'Ing.', 'Lic.')) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_numero_aleatorio_rangos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_numero_aleatorio_rangos`(v_limite_inferior int,
 v_limite_superior INT) RETURNS int
    DETERMINISTIC
BEGIN
     DECLARE v_numero_generado INT DEFAULT FLOOR(Rand()* (v_limite_superior-v_limite_inferior+1)+v_limite_inferior);
     SET @numero_generado = v_numero_generado;
RETURN v_numero_generado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_observacion_por_servicio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_observacion_por_servicio`(
    p_servicio_id CHAR(36),
    p_tipo_cita VARCHAR(30)
) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE v_nombre_servicio VARCHAR(100);
    DECLARE v_observacion TEXT;

    -- Obtener el nombre del servicio
    SELECT Nombre INTO v_nombre_servicio
    FROM tbc_servicios_medicos
    WHERE ID = p_servicio_id
    LIMIT 1;

    -- Lógica condicional con IF
    IF v_nombre_servicio LIKE 'localhostCardiologíalocalhost' THEN
        IF p_tipo_cita = 'Revisión' THEN
            SET v_observacion = 'Revisión rutinaria de presión arterial y ritmo cardiaco.';
        ELSEIF p_tipo_cita = 'Diagnóstico' THEN
            SET v_observacion = 'Evaluación de posibles arritmias mediante ECG.';
        ELSEIF p_tipo_cita = 'Tratamiento' THEN
            SET v_observacion = 'Seguimiento a tratamiento con betabloqueadores.';
        ELSE
            SET v_observacion = CONCAT('Cita de tipo ', p_tipo_cita, ' en el área de Cardiología.');
        END IF;

    ELSEIF v_nombre_servicio LIKE 'localhostPediatríalocalhost' THEN
        IF p_tipo_cita = 'Revisión' THEN
            SET v_observacion = 'Control de crecimiento y desarrollo infantil.';
        ELSEIF p_tipo_cita = 'Diagnóstico' THEN
            SET v_observacion = 'Revisión de síntomas de infección respiratoria.';
        ELSEIF p_tipo_cita = 'Tratamiento' THEN
            SET v_observacion = 'Aplicación de tratamiento para fiebre y malestar general.';
        ELSE
            SET v_observacion = CONCAT('Cita de tipo ', p_tipo_cita, ' en el área de Pediatría.');
        END IF;

    ELSEIF v_nombre_servicio LIKE 'localhostOdontologíalocalhost' THEN
        IF p_tipo_cita = 'Revisión' THEN
            SET v_observacion = 'Revisión de caries y limpieza dental.';
        ELSEIF p_tipo_cita = 'Procedimientos' THEN
            SET v_observacion = 'Extracción de molar en mal estado.';
        ELSE
            SET v_observacion = CONCAT('Cita de tipo ', p_tipo_cita, ' en el área de Odontología.');
        END IF;

    ELSE
        -- Observación genérica si no se reconoce el área
        SET v_observacion = CONCAT('Cita de tipo ', p_tipo_cita, ' correspondiente al servicio médico solicitado.');
    END IF;

    RETURN v_observacion;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_random_cedula` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_random_cedula`() RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    RETURN CONCAT('CED-', SUBSTRING(MD5(RAND()), 1, 8));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_random_fecha_contratacion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_random_fecha_contratacion`(start_date DATE, end_date DATE) RETURNS date
    DETERMINISTIC
BEGIN
    RETURN DATE_ADD(start_date, INTERVAL FLOOR(RAND() * DATEDIFF(end_date, start_date)) DAY);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_random_salary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_random_salary`(p_tipo VARCHAR(20)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    IF p_tipo = 'Médico' THEN
       RETURN ROUND(10000 + RAND() * (30000 - 10000), 2);
    ELSEIF p_tipo = 'Enfermero' THEN
       RETURN ROUND(5000 + RAND() * (15000 - 5000), 2);
    ELSE
       RETURN 0;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `hola` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `hola`() RETURNS int
    DETERMINISTIC
BEGIN

RETURN 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `eliminar_llaves_foraneas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_llaves_foraneas`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tabla_nombre VARCHAR(255);
    DECLARE llave_nombre VARCHAR(255);
    DECLARE cur CURSOR FOR
        SELECT table_name, constraint_name
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE table_schema = 'hospital_general_8a_idgs_220219'
        AND referenced_table_name IS NOT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    loop_eliminar: LOOP
        FETCH cur INTO tabla_nombre, llave_nombre;
        IF done THEN
            LEAVE loop_eliminar;
        END IF;

        SET @sql = CONCAT('ALTER TABLE ', tabla_nombre, ' DROP FOREIGN KEY ', llave_nombre, ';');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fn_insert_area_medica_si_no_existe` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fn_insert_area_medica_si_no_existe`(
    IN p_Nombre VARCHAR(100),
    IN p_Descripcion TEXT,
    IN p_abreviatura VARCHAR(20)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM tbc_areas_medicas WHERE nombre = p_Nombre
    ) THEN
        INSERT INTO tbc_areas_medicas (
            id, nombre, abreviatura, descripcion, estatus, fecha_registro, fecha_actualizacion
        ) VALUES (
            UUID(), p_Nombre, p_abreviatura, p_Descripcion, 'Activo', NOW(), NOW()
        );
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fn_insert_espacio_si_no_existe` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fn_insert_espacio_si_no_existe`(
    IN p_Nombre VARCHAR(100),
    IN p_Tipo VARCHAR(50),
    IN p_Departamento_ID CHAR(36),
    IN p_Espacio_Superior_ID CHAR(36)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM tbc_espacios WHERE Nombre = p_Nombre
    ) THEN
        INSERT INTO tbc_espacios (
            ID, Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus
        ) VALUES (
            UUID(), p_Tipo, p_Nombre, p_Departamento_ID, p_Espacio_Superior_ID, DEFAULT, DEFAULT
        );
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fn_insert_rol_si_no_existe` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `fn_insert_rol_si_no_existe`(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM tbc_roles WHERE nombre = p_nombre
    ) THEN
        INSERT INTO tbc_roles (
            ID, nombre, descripcion, estatus, fecha_registro, fecha_actualizacion
        ) VALUES (
            UUID(), p_nombre, p_descripcion, b'1', NOW(), NULL
        );
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insertar_departamento_servicio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_departamento_servicio`(
    IN p_dpto_id CHAR(36), 
    IN p_servicio_id CHAR(36)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM tbd_departamentos_servicios 
        WHERE Departamento_ID = p_dpto_id AND Servicio_ID = p_servicio_id
    ) THEN
        INSERT INTO tbd_departamentos_servicios 
        VALUES (p_dpto_id, p_servicio_id, "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT, NULL);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_asigna_responsables_departamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_asigna_responsables_departamentos`()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_departamento_id CHAR(36);
    DECLARE cur CURSOR FOR
        SELECT id FROM tbc_departamentos WHERE responsable_id IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_departamento_id;
        IF done THEN 
            LEAVE read_loop; 
        END IF;

        -- Intentar encontrar al médico con más antigüedad en ese departamento
        UPDATE tbc_departamentos d
        JOIN (
            SELECT id 
            FROM tbb_personal_medico 
            WHERE departamento_id = v_departamento_id 
              AND tipo = 'Médico'
            ORDER BY fecha_contratacion ASC
            LIMIT 1
        ) pm ON d.id = v_departamento_id
        SET d.responsable_id = pm.id;

    END LOOP;
    CLOSE cur;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estatus_bd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estatus_bd`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
	-- Subquery / Subconsultas
    
	(SELECT "TABLAS CATALOGO" as Tabla, "--------------------" as TotalRegistros, 
    "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
	UNION
	(SELECT "tbb_aprobaciones" as Tabla,   
    (SELECT COUNT(*) FROM  tbb_aprobaciones) as TotalRegistros, "Tabla Débil", "Genérica", "Dirección General", "Dirección General", "Todos")
    UNION
    (SELECT "tbc_areas_medicas" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_areas_medicas) as TotalRegistros, "Tabla Fuerte", "Genérica", "Áreas Médicas", "Recursos Humanos, Dirección General", "Todos")
    UNION
	(SELECT "tbc_consumibles" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_consumibles) as TotalRegistros, "Tabla Cátalogo", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria, Recursos Materiales", "Todos")
    UNION
    (SELECT "tbc_departamentos" as Tabla,
    (SELECT COUNT(*) FROM  tbc_departamentos) as TotalRegistros, "Tabla Fuerte", "Genérica", "Recursos Humanos", "Recursos Humanos, Dirección General", "Todos")
    UNION
    (SELECT "tbc_espacios" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_espacios) as TotalRegistros, "Tabla Fuerte", "Genérica", "Dirección General", "Dirección General, Recursos Materiales, Programación Quirúrgica, Farmacia Intrahospitalaria, Radiología e Imagen, Pediatría, Recursos Humanos, Registros Médicos, Comité de Trasplante", "Todos")
     UNION
    (SELECT "tbc_estudios" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_estudios) as TotalRegistros, "Tabla Catalogo", "Genérica", "Radiologia e Imagen", "Dirección General, Radiología e Imagen, Registros Médicos, Programación Quirúrgica", "Todos")
    UNION
	(SELECT "tbc_medicamentos" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_medicamentos) as TotalRegistros, "Tabla Fuerte", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria, Recursos Materiales", "Todos")
   UNION
   (SELECT "tbc_organos" AS Tabla,
	(SELECT COUNT(*) FROM tbc_organos) AS TotalRegistros, "Tabla Fuerte", "Generica", "Comite de Transplantes", "Direccion General, Comite de Transpalntes", "Direccion General, Comite de Transpalntes")    UNION
    (SELECT "tbc_puestos" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_puestos) as TotalRegistros, "Tabla Debil", "Genérica", "Personal Medico",  "Personal Medico, Recursos Humanos", "Todos")
    UNION
    (SELECT "tbc_roles" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_roles) as TotalRegistros, "Tabla Fuerte", "Genérica", "Dirección General", "Dirección General, Registros Médicos, Recursos Humanos", "Todos")
    UNION
     (SELECT "tbc_servicios_medicos" as Tabla,   
    (SELECT COUNT(*) FROM  tbc_servicios_medicos) as TotalRegistros, "Tabla Cátalogo", "Genérica", "Radiología e Imagen", "Dirección General, Radiología e Imagen, Pediatria, Recursos Humanos, Programacion Quirurgica, Registros Médicos,", "Recursos Materiales")
    UNION
    
    
   

    (SELECT "TABLAS BASE" as Tabla, "--------------------" as TotalRegistros
    , "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
    UNION
    (SELECT "tbb_citas_medicas" AS Tabla,
	(select count(*) from tbb_citas_medicas) as TotalRegistros, "Tabla Débil", "Genérica", "Radiologia e Imagen","Dirección General, Radiología e Imagen, Pediatria, Recursos Humanos, Programación Quirúrgica, Registros Médicos, 
  Farmacia Intrahospitalaria, Comité de Trasplante", "Todos")
	UNION
	(SELECT "tbb_cirugias" AS Tabla,
	(select count(*) from tbb_cirugias) as TotalRegistros, "Tabla Débil", "Genérica", "Programación Quirúrgica", "Dirección General, Radiología e Imagen, Pediatría, Recursos Materiales, Comité de Trasplantes, Farmacia Intrahospitalaria", "Todos")
	UNION
    (SELECT "tbb_nacimientos" AS Tabla,
	(select count(*) from tbb_nacimientos) as TotalRegistros, "Tabla Débil", "Genérica", "Pediatria","Pediatria, Registros Médicos", "Pediatria, Registros Médicos, Cirugia, Dirección General")
    UNION
    (SELECT "tbb_pacientes" AS Tabla,
	(select count(*) from tbb_pacientes) as TotalRegistros, "Tabla Débil", "Subentidad", "Registros Médicos","Registros Médicos", "Radiología e Imagen, Pediatría, Programación Quirúrgica, Registros Médicos, Farmacia Intrahospitalaria, Comité de Transplantes, Pacientes")
	UNION
    (SELECT "tbb_personal_medico" AS Tabla,
	(select count(*) from tbb_personal_medico) as TotalRegistros, "Tabla Débil", "Subentidad", "Recursos Humanos","Recursos Humanos, Registros Médicos", "Todos")
    UNION
	(SELECT "tbd_solicitudes" AS Tabla,
	(select count(*) from tbd_solicitudes) as TotalRegistros, "Tabla Débil", "Genérica", "Comite de Transplantes", "Comite de Transplantes, Personal Medico", "Direccion General, Radiologia e Imagen, Pediatria, Recursos Humanos, Programacion Quirurgica, Farmacia Intrahospitalaria, Comite de Transplantes")
    UNION
    (SELECT "tbb_usuarios" as Tabla, 
    (SELECT COUNT(*) FROM  tbb_usuarios) as TotalRegistros, "Tabla Débil", "Subentidad", "Registros Médicos", "Registros Médicos, Paciente", "Todos"  )
    UNION
    
	(SELECT "tbb_personas" AS Tabla,
	(select count(*) from tbb_personas) as TotalRegistros, "Tabla Débil", "Superentidad", "Registros Medicos", "Recursos Humanos", "Todos")
	UNION
    (SELECT "tbb_valoraciones_medicas" AS Tabla,
	(select count(*) from tbb_valoraciones_medicas) as TotalRegistros, "Tabla Débil", "Genérica", "Pediatria","Pediatria, Registros Médicos", "Todos")
	UNION
    

    
    (SELECT "TABLAS DERIVADAS" as Tabla, "--------------------" as TotalRegistros,
    "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
   UNION
    (SELECT "tbd_departamentos_servicios" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_departamentos_servicios) as TotalRegistros, "Tabla Derivada", "Genérica", "Radiología e Imagen", "Dirección General, Radiología e Imagen, Pediatria, Recursos Humanos, Programacion Quirurgica, Registros Médicos", "Todos")
   UNION
    (SELECT "tbd_dispensaciones" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_dispensaciones) as TotalRegistros, "Tabla Derivada", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria", "Pacientes, Registros Medicos")
    
    UNION
    (SELECT "tbd_lotes_medicamentos" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_lotes_medicamentos) as TotalRegistros, "Tabla Derivada", "Genérica", "Farmacia Intrahospitalaria", "Farmacia Intrahospitalaria, Dirección General", "Todos")
    UNION
    (SELECT "tbd_usuarios_roles" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_usuarios_roles) as TotalRegistros, "Tabla Derivada", "Genérica", "Registros Médicos", "Registros Médicos", "Todos")
	UNION
    (SELECT "tbd_expedientes_clinicos" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_expedientes_clinicos) as TotalRegistros, "Tabla Derivada", "Genérica", "Registros Médicos", "Personal Medico", "Todos")
    UNION
    (SELECT "tbd_recetas_medicas" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_recetas_medicas) as TotalRegistros, "Tabla Derivada", "Genérica", "Pediatria", "Personal Medico", "Personal Medico,Farmacia, Pidiatria")
    UNION
	(SELECT "tbd_resultados_estudios" as Tabla, 
    (SELECT COUNT(*) FROM  tbd_resultados_estudios) as TotalRegistros, "Tabla Derivada", "Genérica", "Radiología e Imagen", "Dirección General, Radiología e Imagen ", "Comité de Trasplantes, Dirección General, Farmacia Intrahospitalaria, Pediatría, Programación Quirúrgica, Radiología e Imagen, Recursos Materiales, Registros Médicos")
    UNION
    (SELECT "TABLAS ISLA" as Tabla, "--------------------" as TotalRegistros,
    "--------------" as TipoTabla, "--------------" as Jerarquia, "--------------" as UDN_Owner, "--------------"  as UDN_Editors,  "--------------" as UDN_Readers)
    UNION
    (SELECT "tbi_bitacora" as Tabla, 
    (SELECT COUNT(*) FROM  tbi_bitacora) as TotalRegistros, "Tabla Isla", "Genérica", "Dirección General", "-", "-");
    
    
    
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_generar_pacientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_pacientes`(IN cantidad INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_persona_id CHAR(36);
    DECLARE v_usuario_id CHAR(36);
    DECLARE v_nombre VARCHAR(80);
    DECLARE v_apellido1 VARCHAR(80);
    DECLARE v_apellido2 VARCHAR(80);
    DECLARE v_curp VARCHAR(18);
    DECLARE v_genero ENUM('M','F','N/B');
    DECLARE v_grupo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-');
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_usuario VARCHAR(40);
    DECLARE v_correo VARCHAR(100);
    DECLARE v_contrasena VARCHAR(40);
    DECLARE v_numero_tel CHAR(19);
    DECLARE v_rol_id CHAR(36);
    DECLARE v_tipo_seguro VARCHAR(50);
    DECLARE v_estatus_vida ENUM('Vivo', 'Finado', 'Coma', 'Vegetativo');
    DECLARE v_fecha_ultima_cita DATE;

    -- Obtener el ID del rol de paciente
    SELECT ID INTO v_rol_id FROM tbc_roles WHERE Nombre = 'Paciente' LIMIT 1;

    WHILE i < cantidad DO
        -- Generar datos de persona
        SET v_persona_id = uuid();
        SET v_genero = fn_genera_genero();
        SET v_nombre = fn_genera_nombre_simple(v_genero);
        SET v_apellido1 = fn_genera_apellido(v_genero);
        SET v_apellido2 = fn_genera_apellido(v_genero);
        SET v_fecha_nacimiento = fn_genera_fecha_nacimiento('1935-01-01', '2007-01-01');
        SET v_curp = fn_genera_curp(v_nombre, v_apellido1, v_apellido2, v_fecha_nacimiento, v_genero);
        SET v_grupo_sanguineo = fn_genera_grupo_sanguineo();

        -- Insertar persona
        INSERT INTO tbb_personas (id, nombre, primer_apellido, segundo_apellido, curp, genero, grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro)
        VALUES (v_persona_id, v_nombre, v_apellido1, v_apellido2, v_curp, v_genero, v_grupo_sanguineo, v_fecha_nacimiento, 1, NOW());

        -- Generar datos de usuario
        SET v_usuario_id = uuid();
        SET v_usuario = LOWER(CONCAT(v_nombre, '.', v_apellido1, FLOOR(RAND() * 1000)));
        SET v_correo = CONCAT(v_usuario, '@correo.com');
        SET v_contrasena = '123456'; -- En producción deberías hashearla
        SET v_numero_tel = fn_genera_numero_telefonico();

        -- Insertar usuario
        INSERT INTO tbb_usuarios (id, persona_id, nombre_usuario, correo_electronico, contrasena, numero_telefonico_movil, estatus, fecha_registro)
        VALUES (v_usuario_id, v_persona_id, v_usuario, v_correo, v_contrasena, v_numero_tel, 'Activo', NOW());

        -- Asignar rol de paciente
        INSERT INTO tbd_usuarios_roles (Usuario_ID, Rol_ID, Estatus, Fecha_Registro)
        VALUES (v_usuario_id, v_rol_id, 1, NOW());

        -- Elegir aleatoriamente el tipo de seguro
        SET v_tipo_seguro = ELT(FLOOR(1 + (RAND() * 5)), 'IMSS', 'ISSSTE', 'Seguro Popular', 'Privado', 'SIN SEGURO');

        -- Elegir aleatoriamente el estatus de vida
        SET v_estatus_vida = ELT(FLOOR(1 + (RAND() * 4)), 'Vivo', 'Finado', 'Coma', 'Vegetativo');

        -- Generar aleatoriamente la fecha de última cita (50% NULL)
        IF RAND() < 0.5 THEN
            SET v_fecha_ultima_cita = fn_genera_fecha_nacimiento('2022-01-01', CURDATE());
        ELSE
            SET v_fecha_ultima_cita = NULL;
        END IF;

        -- Insertar en tbb_pacientes
        INSERT INTO tbb_pacientes (Persona_ID, NSS, Tipo_Seguro, Estatus_Medico, Estatus_Vida, Estatus, Fecha_Registro, Fecha_Ultima_Cita)
        VALUES (v_persona_id, LPAD(FLOOR(RAND() * 999999999999999), 15, '0'), v_tipo_seguro, 'Normal', v_estatus_vida, 1, NOW(), v_fecha_ultima_cita);

        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_genera_personal_medico_especifico_chahci` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_genera_personal_medico_especifico_chahci`(
    IN p_cantidad INT,
    IN p_departamento_nombre VARCHAR(100),
    IN p_rol_nombre VARCHAR(50)
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_persona_id CHAR(36);
    DECLARE v_usuario_id CHAR(36);
    DECLARE v_nombre VARCHAR(80);
    DECLARE v_apellido1 VARCHAR(80);
    DECLARE v_apellido2 VARCHAR(80);
    DECLARE v_curp VARCHAR(18);
    DECLARE v_genero ENUM('M','F','N/B');
    DECLARE v_grupo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-');
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_usuario VARCHAR(40);
    DECLARE v_correo VARCHAR(100);
    DECLARE v_contrasena VARCHAR(40);
    DECLARE v_numero_tel CHAR(19);
    DECLARE v_rol_id CHAR(36);
    DECLARE v_departamento_id CHAR(36);
    DECLARE v_cedula VARCHAR(100);
    DECLARE v_fecha_contratacion DATE;
    DECLARE v_salario DECIMAL(10,2);
    DECLARE v_especialidad VARCHAR(255);

    -- Obtener ID del rol
    SELECT ID INTO v_rol_id FROM tbc_roles WHERE Nombre = p_rol_nombre LIMIT 1;

    -- Obtener ID del departamento
    SELECT ID INTO v_departamento_id FROM tbc_departamentos WHERE Nombre = p_departamento_nombre LIMIT 1;

    WHILE i < p_cantidad DO
        -- Generar datos de persona
        SET v_persona_id = uuid();
        SET v_genero = fn_genera_genero();
        SET v_nombre = fn_genera_nombre_simple(v_genero);
        SET v_apellido1 = fn_genera_apellido(v_genero);
        SET v_apellido2 = fn_genera_apellido(v_genero);
        SET v_fecha_nacimiento = fn_genera_fecha_nacimiento('1965-01-01', '1999-12-31');
        SET v_curp = fn_genera_curp(v_nombre, v_apellido1, v_apellido2, v_fecha_nacimiento, v_genero);
        SET v_grupo_sanguineo = fn_genera_grupo_sanguineo();

        -- Insertar persona
        INSERT INTO tbb_personas (id, nombre, primer_apellido, segundo_apellido, curp, genero, grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro)
        VALUES (v_persona_id, v_nombre, v_apellido1, v_apellido2, v_curp, v_genero, v_grupo_sanguineo, v_fecha_nacimiento, 1, NOW());

        -- Generar datos de usuario
        SET v_usuario_id = uuid();
        SET v_usuario = LOWER(CONCAT(v_nombre, '.', v_apellido1, FLOOR(RAND() * 1000)));
        SET v_correo = CONCAT(v_usuario, '@correo.com');
        SET v_contrasena = '123456';
        SET v_numero_tel = fn_genera_numero_telefonico();

        -- Insertar usuario
        INSERT INTO tbb_usuarios (id, persona_id, nombre_usuario, correo_electronico, contrasena, numero_telefonico_movil, estatus, fecha_registro)
        VALUES (v_usuario_id, v_persona_id, v_usuario, v_correo, v_contrasena, v_numero_tel, 'Activo', NOW());

        -- Asignar rol
        INSERT INTO tbd_usuarios_roles (Usuario_ID, Rol_ID, Estatus, Fecha_Registro)
        VALUES (v_usuario_id, v_rol_id, 1, NOW());

        -- Generar datos del personal médico
        SET v_cedula = fn_random_cedula();
        SET v_fecha_contratacion = fn_random_fecha_contratacion('2010-01-01', CURDATE());
        SET v_salario = fn_random_salary('Médico');

        IF p_rol_nombre = 'Médico Especialista' THEN
            SET v_especialidad = ELT(FLOOR(1 + RAND()*4),
              'Cardiología',
              'Pediatría',
              'Gastroenterología',
              'Traumatología'
            );
        ELSE
            SET v_especialidad = NULL;
        END IF;

        -- Insertar en tbb_personal_medico
        INSERT INTO tbb_personal_medico (
           Persona_ID,
           Departamento_ID,
           Cedula_Profesional,
           Tipo,
           Especialidad,
           Fecha_Contratacion,
           Salario,
           Estatus,
           Fecha_Registro
        )
        VALUES (
           v_persona_id,
           v_departamento_id,
           v_cedula,
           'Médico',
           v_especialidad,
           v_fecha_contratacion,
           v_salario,
           'Activo',
           NOW()
        );

        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_InsertaRolesPersonas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertaRolesPersonas`()
BEGIN
    DECLARE v_UsuarioID CHAR(36);
    DECLARE v_PersonaID CHAR(36);
    DECLARE v_Nombre VARCHAR(80);
    DECLARE v_Apellido VARCHAR(80);
    DECLARE v_Titulo VARCHAR(50);
    DECLARE v_RolID CHAR(36);
    DECLARE v_RolNombre VARCHAR(50);
    DECLARE v_NombreUsuario VARCHAR(60);
    DECLARE v_CorreoElectronico VARCHAR(100);
    DECLARE v_Contrasena VARCHAR(40);
    DECLARE v_NumeroTelefonico VARCHAR(20);
    DECLARE random_val FLOAT;
    DECLARE done INT DEFAULT 0;
    DECLARE admin_assigned INT DEFAULT 0;
    DECLARE director_assigned INT DEFAULT 0;

    -- Cursor para recorrer personas sin usuario
    DECLARE cur_personas CURSOR FOR 
        SELECT ID, Nombre, Primer_Apellido, Titulo 
        FROM tbb_personas
        WHERE ID NOT IN (SELECT Persona_ID FROM tbb_usuarios);
        
    -- Cursor para recorrer usuarios sin rol
    DECLARE cur_usuarios CURSOR FOR 
        SELECT u.ID, u.Persona_ID
        FROM tbb_usuarios u
        WHERE u.ID NOT IN (SELECT Usuario_ID FROM tbd_usuarios_roles);
        
    -- Handlers
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Crear usuarios para personas sin usuario
    OPEN cur_personas;
    read_personas: LOOP
        FETCH cur_personas INTO v_PersonaID, v_Nombre, v_Apellido, v_Titulo;
        IF done THEN 
            LEAVE read_personas; 
        END IF;

        -- Verificación de valores nulos o vacíos
        IF v_Nombre IS NULL OR v_Nombre = '' THEN 
            SET v_Nombre = 'usuario';
        END IF;

        IF v_Apellido IS NULL OR v_Apellido = '' THEN 
            SET v_Apellido = 'generico';
        END IF;

        -- **Evita que `Titulo` se use en `Nombre_Usuario`**
        IF v_Titulo IN ('Dr.', 'Lic.', 'Ing.') THEN
            SET v_Titulo = ''; -- Se limpia el título
        END IF;

        -- Generar nombre de usuario basado en Nombre y Apellido (sin Título)
        SET v_NombreUsuario = CONCAT(LOWER(REPLACE(v_Nombre, ' ', '')), '.', LOWER(REPLACE(v_Apellido, ' ', '')));
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Nombre_Usuario = v_NombreUsuario) DO
            SET v_NombreUsuario = CONCAT(v_NombreUsuario, FLOOR(10 + RAND() * 90));
        END WHILE;

        -- Generar correo electrónico sin incluir títulos
        SET v_CorreoElectronico = CONCAT(v_NombreUsuario, '@ejemplo.com');
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Correo_Electronico = v_CorreoElectronico) DO
            SET v_CorreoElectronico = CONCAT(v_NombreUsuario, FLOOR(10 + RAND() * 90), '@ejemplo.com');
        END WHILE;

        SET v_Contrasena = SUBSTRING(MD5(RAND()), 1, 8);
        SET v_NumeroTelefonico = fn_genera_numero_telefonico();
        SET v_UsuarioID = UUID();

        -- Insertar en tbb_usuarios
        INSERT INTO tbb_usuarios (
            ID, Persona_ID, Nombre_Usuario, Correo_Electronico, Contrasena, numero_telefonico_movil, Estatus, Fecha_Registro
        ) VALUES (
            v_UsuarioID, 
            v_PersonaID,
            v_NombreUsuario,
            v_CorreoElectronico,
            v_Contrasena,
            v_NumeroTelefonico,
            'Activo',
            NOW()
        );
    END LOOP;
    CLOSE cur_personas;

    -- Asignar roles a los usuarios sin rol
    SET done = 0;
    OPEN cur_usuarios;
    read_usuarios: LOOP
        FETCH cur_usuarios INTO v_UsuarioID, v_PersonaID;
        IF done THEN
            LEAVE read_usuarios;
        END IF;

        -- Asignar roles únicos (Administrador y Dirección General)
        IF admin_assigned = 0 THEN
            SET v_RolNombre = 'Administrador';
            SET admin_assigned = 1;
        ELSEIF director_assigned = 0 THEN
            SET v_RolNombre = 'Direccion General';
            SET director_assigned = 1;
        ELSE 
            -- Asignación basada en distribución aleatoria
            SET random_val = RAND();
            IF random_val < 0.5 THEN
                SET v_RolNombre = 'Médico General';
            ELSE
                SET v_RolNombre = 'Paciente';
            END IF;
        END IF;

        -- Obtener el ID del rol
        SELECT ID INTO v_RolID
        FROM tbc_roles
        WHERE Nombre = v_RolNombre
        LIMIT 1;

        -- Insertar en la tabla de relación roles-usuarios
        INSERT INTO tbd_usuarios_roles (Usuario_ID, Rol_ID, Estatus, Fecha_Registro)
        VALUES (v_UsuarioID, v_RolID, b'1', NOW());
    END LOOP;
    CLOSE cur_usuarios;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_InsertaRolesUsuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertaRolesUsuarios`()
BEGIN
    DECLARE v_UsuarioID CHAR(36);
    DECLARE v_PersonaID CHAR(36);
    DECLARE v_Titulo VARCHAR(50);
    DECLARE v_RolID CHAR(36);
    DECLARE v_RolNombre VARCHAR(50);
    DECLARE v_NombreUsuario VARCHAR(60);
    DECLARE v_CorreoElectronico VARCHAR(100);
    DECLARE v_Contrasena VARCHAR(40);
    DECLARE v_NumeroTelefonico VARCHAR(20);
    DECLARE random_val FLOAT;
    DECLARE done INT DEFAULT 0;
    DECLARE admin_assigned INT DEFAULT 0;
    DECLARE director_assigned INT DEFAULT 0;

    -- Cursor para recorrer personas sin usuario
    DECLARE cur_personas CURSOR FOR 
        SELECT ID, Titulo
        FROM tbb_personas
        WHERE ID NOT IN (SELECT Persona_ID FROM tbb_usuarios);
        
    -- Cursor para recorrer usuarios sin rol
    DECLARE cur_usuarios CURSOR FOR 
        SELECT u.ID, u.Persona_ID, p.Titulo
        FROM tbb_usuarios u
        JOIN tbb_personas p ON u.Persona_ID = p.ID
        WHERE u.ID NOT IN (SELECT Usuario_ID FROM tbd_usuarios_roles);
        
    -- Handlers
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Crear usuarios para personas sin usuario
    OPEN cur_personas;
    read_personas: LOOP
        FETCH cur_personas INTO v_PersonaID, v_Titulo;
        IF done THEN 
            LEAVE read_personas; 
        END IF;

        -- Generar valores únicos para usuario y correo
        SET v_NombreUsuario = CONCAT(LOWER(SUBSTRING_INDEX(v_Titulo, '.', 1)), '.', FLOOR(1000 + RAND() * 9000));
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Nombre_Usuario = v_NombreUsuario) DO
            SET v_NombreUsuario = CONCAT(v_NombreUsuario, FLOOR(10 + RAND() * 90));
        END WHILE;

        SET v_CorreoElectronico = CONCAT(v_NombreUsuario, '@ejemplo.com');
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Correo_Electronico = v_CorreoElectronico) DO
            SET v_CorreoElectronico = CONCAT(v_NombreUsuario, FLOOR(10 + RAND() * 90), '@ejemplo.com');
        END WHILE;

        SET v_Contrasena = SUBSTRING(MD5(RAND()), 1, 8);
        SET v_NumeroTelefonico = fn_genera_numero_telefonico();
        SET v_UsuarioID = UUID();

        -- Insertar en tbb_usuarios
        INSERT INTO tbb_usuarios (
            ID, Persona_ID, Nombre_Usuario, Correo_Electronico, Contrasena, numero_telefonico_movil, Estatus, Fecha_Registro
        ) VALUES (
            v_UsuarioID, 
            v_PersonaID,
            v_NombreUsuario,
            v_CorreoElectronico,
            v_Contrasena,
            v_NumeroTelefonico,
            'Activo',
            NOW()
        );
    END LOOP;
    CLOSE cur_personas;

    -- Asignar roles a los usuarios sin rol
    SET done = 0;
    OPEN cur_usuarios;
    read_usuarios: LOOP
        FETCH cur_usuarios INTO v_UsuarioID, v_PersonaID, v_Titulo;
        IF done THEN
            LEAVE read_usuarios;
        END IF;

        -- Asignar roles únicos (Administrador y Dirección General)
        IF admin_assigned = 0 THEN
            SET v_RolNombre = 'Administrador';
            SET admin_assigned = 1;
        ELSEIF director_assigned = 0 THEN
            SET v_RolNombre = 'Direccion General';
            SET director_assigned = 1;
        ELSE 
            -- Asignación basada en el título
            IF v_Titulo = 'DR.' THEN
                SET random_val = RAND();
                IF random_val < 0.5 THEN
                    SET v_RolNombre = 'Médico General';
                ELSE
                    SET v_RolNombre = 'Médico Especialista';
                END IF;
            ELSEIF v_Titulo = 'Enf.' THEN
                SET v_RolNombre = 'Enfermero';
            ELSE 
                SET v_RolNombre = 'Paciente';
            END IF;
        END IF;

        -- Obtener el ID del rol
        SELECT ID INTO v_RolID
        FROM tbc_roles
        WHERE Nombre = v_RolNombre
        LIMIT 1;

        -- Insertar en la tabla de relación roles-usuarios
        INSERT INTO tbd_usuarios_roles (Usuario_ID, Rol_ID, Estatus, Fecha_Registro)
        VALUES (v_UsuarioID, v_RolID, b'1', NOW());
    END LOOP;
    CLOSE cur_usuarios;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_InsertarPersonas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertarPersonas`(
    IN cantidad INT,
    IN p_Genero ENUM('M', 'F', 'N/B'),
    IN p_FechaInicio DATE,
    IN p_FechaFin DATE
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_Genero ENUM('M', 'F', 'N/B');
    DECLARE v_Nombre VARCHAR(80);
    DECLARE v_PrimerApellido VARCHAR(80);
    DECLARE v_SegundoApellido VARCHAR(80);
    DECLARE v_FechaNacimiento DATE;
    DECLARE v_CURP VARCHAR(18);
    DECLARE v_Titulo VARCHAR(50);
    DECLARE v_Edad INT;

    WHILE i < cantidad DO
        -- Usar el género si se proporciona, si no, generar uno aleatorio
        IF p_Genero IS NOT NULL THEN
            SET v_Genero = p_Genero;
        ELSE
            SET v_Genero = fn_genera_genero();
        END IF;

        -- Generar datos personales
        SET v_Nombre = fn_genera_nombre_simple(v_Genero);
        SET v_PrimerApellido = fn_genera_apellido(v_Genero);
        SET v_SegundoApellido = fn_genera_apellido(v_Genero);

        -- Generar fecha de nacimiento dentro del rango dado
        SET v_FechaNacimiento = fn_genera_fecha_nacimiento(p_FechaInicio, p_FechaFin);

        -- Calcular edad
        SET v_Edad = TIMESTAMPDIFF(YEAR, v_FechaNacimiento, CURDATE());

        -- Asignar título según la edad
        IF v_Edad >= 25 THEN
            SET v_Titulo = fn_genera_titulo();
        ELSE
            SET v_Titulo = NULL;
        END IF;

        -- Generar CURP
        SET v_CURP = fn_genera_curp(v_Nombre, v_PrimerApellido, v_SegundoApellido, v_FechaNacimiento, v_Genero);

        -- Insertar datos en la tabla
        INSERT INTO tbb_personas (
            ID, Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro
        ) VALUES (
            UUID(),
            v_Titulo,
            v_Nombre,
            v_PrimerApellido,
            v_SegundoApellido,
            v_CURP,
            v_Genero,
            fn_genera_grupo_sanguineo(),
            v_FechaNacimiento,
            1,
            NOW()
        );

        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertar_aprobaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_aprobaciones`(IN num_solicitudes INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE status ENUM('En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');
    DECLARE tipo ENUM('Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');
    DECLARE comentario TEXT;
    DECLARE idx INT;
    DECLARE fecha_registro DATETIME;
    DECLARE fecha_actualizacion DATETIME;

    WHILE i <= num_solicitudes DO
        -- Generar fecha de registro aleatoria entre el año 2000 y la fecha actual
        SET fecha_registro = DATE_ADD('2000-01-01', INTERVAL FLOOR(RAND() * DATEDIFF(NOW(), '2000-01-01')) DAY);
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 24) HOUR); -- Agregar horas aleatorias
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 60) MINUTE); -- Agregar minutos aleatorios
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 60) SECOND); -- Agregar segundos aleatorios

        -- Generar valores aleatorios para cada iteración
        SET tipo = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');
        SET status = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');

        -- Verificar si hay una actualización previa para esta solicitud y si el nuevo status es "En Proceso"
        SELECT MAX(fecha_actualizacion) INTO fecha_actualizacion
        FROM tbb_aprobaciones
        WHERE solicitud_id = i;

        IF fecha_actualizacion IS NOT NULL AND status = 'En Proceso' THEN
            -- Si hay una fecha de actualización previa y el nuevo estatus es "En Proceso", seleccionar otro estatus aleatorio que no sea "En Proceso"
            SET status = ELT(FLOOR(2 + (RAND() * 4)), 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado'); -- Evitar 'En Proceso'
        ELSE
            -- Generar fecha de actualización dentro de un rango de 2 a 3 días si el estatus no está en "En Proceso"
            IF status != 'En Proceso' THEN
                SET fecha_actualizacion = DATE_ADD(fecha_registro, INTERVAL 2 + FLOOR(RAND() * 2) DAY); -- Fecha aleatoria entre 2 y 3 días después de la fecha de registro
                SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 24) HOUR); -- Agregar horas aleatorias
                SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 60) MINUTE); -- Agregar minutos aleatorios
                SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 60) SECOND); -- Agregar segundos aleatorios
            ELSE
                SET fecha_actualizacion = NULL; -- Dejar fecha_actualizacion como NULL si el estatus es "En Proceso"
            END IF;
        END IF;

        SET idx = FLOOR(1 + (RAND() * 100)); -- Generar un número aleatorio entre 1 y 100

        -- Selección de comentario aleatorio
        CASE idx
            WHEN 1 THEN SET comentario = 'Paciente muestra signos de mejoría.';
            WHEN 2 THEN SET comentario = 'Requiere monitoreo constante.';
            WHEN 3 THEN SET comentario = 'Se recomienda cambio de medicación.';
            WHEN 4 THEN SET comentario = 'Alta programada para mañana.';
            WHEN 5 THEN SET comentario = 'Necesita intervención quirúrgica.';
            WHEN 6 THEN SET comentario = 'Paciente estable, continuar tratamiento actual.';
            WHEN 7 THEN SET comentario = 'Realizar análisis de sangre adicional.';
            WHEN 8 THEN SET comentario = 'Se observa reacción alérgica, cambiar antibiótico.';
            WHEN 9 THEN SET comentario = 'Consultar con especialista en cardiología.';
            WHEN 10 THEN SET comentario = 'Requiere traslado a unidad de cuidados intensivos.';
            WHEN 11 THEN SET comentario = 'Paciente presenta fiebre alta.';
            WHEN 12 THEN SET comentario = 'Iniciar tratamiento con antibióticos.';
            WHEN 13 THEN SET comentario = 'Mantener en observación 24 horas.';
            WHEN 14 THEN SET comentario = 'Evaluar función renal y hepática.';
            WHEN 15 THEN SET comentario = 'Paciente no responde al tratamiento.';
            WHEN 16 THEN SET comentario = 'Administrar líquidos intravenosos.';
            WHEN 17 THEN SET comentario = 'Preparar para radiografía de tórax.';
            WHEN 18 THEN SET comentario = 'Recomendar dieta baja en sodio.';
            WHEN 19 THEN SET comentario = 'Paciente en recuperación postoperatoria.';
            WHEN 20 THEN SET comentario = 'Reevaluar síntomas en 48 horas.';
            WHEN 21 THEN SET comentario = 'Realizar electrocardiograma (ECG).';
            WHEN 22 THEN SET comentario = 'Observar por posibles complicaciones.';
            WHEN 23 THEN SET comentario = 'Paciente presenta dolor agudo.';
            WHEN 24 THEN SET comentario = 'Administrar analgésicos según prescripción.';
            WHEN 25 THEN SET comentario = 'Evaluar función pulmonar.';
            WHEN 26 THEN SET comentario = 'Paciente reporta mareos frecuentes.';
            WHEN 27 THEN SET comentario = 'Recomendar descanso absoluto.';
            WHEN 28 THEN SET comentario = 'Administrar antihistamínicos.';
            WHEN 29 THEN SET comentario = 'Programar sesión de fisioterapia.';
            WHEN 30 THEN SET comentario = 'Realizar pruebas de función tiroidea.';
            WHEN 31 THEN SET comentario = 'Paciente presenta náuseas y vómitos.';
            WHEN 32 THEN SET comentario = 'Iniciar tratamiento para hipertensión.';
            WHEN 33 THEN SET comentario = 'Recomendar control de glucemia.';
            WHEN 34 THEN SET comentario = 'Paciente muestra signos de deshidratación.';
            WHEN 35 THEN SET comentario = 'Administrar suero oral.';
            WHEN 36 THEN SET comentario = 'Evaluar respuesta a la medicación.';
            WHEN 37 THEN SET comentario = 'Paciente en estado crítico.';
            WHEN 38 THEN SET comentario = 'Mantener en unidad de cuidados intensivos.';
            WHEN 39 THEN SET comentario = 'Realizar tomografía computarizada (TC).';
            WHEN 40 THEN SET comentario = 'Paciente con historial de alergias.';
            WHEN 41 THEN SET comentario = 'Administrar epinefrina en caso de emergencia.';
            WHEN 42 THEN SET comentario = 'Monitorizar niveles de oxígeno en sangre.';
            WHEN 43 THEN SET comentario = 'Paciente requiere ventilación asistida.';
            WHEN 44 THEN SET comentario = 'Evaluar necesidad de transfusión sanguínea.';
            WHEN 45 THEN SET comentario = 'Paciente presenta síntomas de infección.';
            WHEN 46 THEN SET comentario = 'Iniciar aislamiento preventivo.';
            WHEN 47 THEN SET comentario = 'Realizar pruebas de función hepática.';
            WHEN 48 THEN SET comentario = 'Paciente en estado de shock.';
            WHEN 49 THEN SET comentario = 'Administrar fluidos intravenosos rápidamente.';
            WHEN 50 THEN SET comentario = 'Recomendar consulta con endocrinólogo.';
            WHEN 51 THEN SET comentario = 'Paciente presenta convulsiones.';
            WHEN 52 THEN SET comentario = 'Administrar anticonvulsivantes.';
            WHEN 53 THEN SET comentario = 'Recomendar seguimiento neurológico.';
            WHEN 54 THEN SET comentario = 'Paciente con dolor torácico persistente.';
            WHEN 55 THEN SET comentario = 'Realizar angiografía coronaria.';
            WHEN 56 THEN SET comentario = 'Paciente presenta erupción cutánea.';
            WHEN 57 THEN SET comentario = 'Administrar corticosteroides tópicos.';
            WHEN 58 THEN SET comentario = 'Evaluar signos de sepsis.';
            WHEN 59 THEN SET comentario = 'Iniciar tratamiento antibiótico de amplio espectro.';
            WHEN 60 THEN SET comentario = 'Paciente con historial de enfermedades cardíacas.';
            WHEN 61 THEN SET comentario = 'Recomendar prueba de esfuerzo.';
            WHEN 62 THEN SET comentario = 'Paciente presenta dificultad respiratoria.';
            WHEN 63 THEN SET comentario = 'Administrar broncodilatadores.';
            WHEN 64 THEN SET comentario = 'Paciente en recuperación post-anestesia.';
            WHEN 65 THEN SET comentario = 'Monitorizar signos vitales cada 30 minutos.';
            WHEN 66 THEN SET comentario = 'Realizar ecografía abdominal.';
            WHEN 67 THEN SET comentario = 'Paciente con signos de anemia.';
            WHEN 68 THEN SET comentario = 'Administrar suplemento de hierro.';
            WHEN 69 THEN SET comentario = 'Paciente requiere evaluación psiquiátrica.';
            WHEN 70 THEN SET comentario = 'Iniciar terapia cognitivo-conductual.';
            WHEN 71 THEN SET comentario = 'Paciente con historial de diabetes.';
            WHEN 72 THEN SET comentario = 'Recomendar control estricto de glucosa.';
            WHEN 73 THEN SET comentario = 'Realizar prueba de función pulmonar.';
            WHEN 74 THEN SET comentario = 'Paciente presenta ictericia.';
            WHEN 75 THEN SET comentario = 'Evaluar función hepática y biliar.';
            WHEN 76 THEN SET comentario = 'Paciente con síntomas de migraña.';
            WHEN 77 THEN SET comentario = 'Administrar triptanos según prescripción.';
            WHEN 78 THEN SET comentario = 'Realizar resonancia magnética (RM).';
            WHEN 79 THEN SET comentario = 'Paciente con dolor lumbar agudo.';
            WHEN 80 THEN SET comentario = 'Recomendar fisioterapia y ejercicios de estiramiento.';
            WHEN 81 THEN SET comentario = 'Paciente muestra signos de fatiga crónica.';
            WHEN 82 THEN SET comentario = 'Evaluar por posibles trastornos del sueño.';
            WHEN 83 THEN SET comentario = 'Paciente con historial de cáncer.';
            WHEN 84 THEN SET comentario = 'Programar seguimiento oncológico.';
            WHEN 85 THEN SET comentario = 'Paciente presenta hipertensión arterial.';
            WHEN 86 THEN SET comentario = 'Ajustar medicación antihipertensiva.';
            WHEN 87 THEN SET comentario = 'Realizar evaluación oftalmológica.';
            WHEN 88 THEN SET comentario = 'Paciente con dolor abdominal persistente.';
            WHEN 89 THEN SET comentario = 'Realizar endoscopia digestiva alta.';
            WHEN 90 THEN SET comentario = 'Paciente con antecedentes de asma.';
            WHEN 91 THEN SET comentario = 'Administrar corticosteroides inhalados.';
            WHEN 92 THEN SET comentario = 'Paciente presenta signos de depresión.';
            WHEN 93 THEN SET comentario = 'Iniciar tratamiento con antidepresivos.';
            WHEN 94 THEN SET comentario = 'Recomendar terapia psicológica.';
            WHEN 95 THEN SET comentario = 'Paciente en estado de desnutrición.';
            WHEN 96 THEN SET comentario = 'Iniciar dieta rica en nutrientes.';
            WHEN 97 THEN SET comentario = 'Paciente presenta dolor articular.';
            WHEN 98 THEN SET comentario = 'Administrar antiinflamatorios no esteroideos (AINEs).';
            WHEN 99 THEN SET comentario = 'Recomendar seguimiento con reumatólogo.';
            WHEN 100 THEN SET comentario = 'Paciente requiere atención odontológica.';
            ELSE SET comentario = 'No hay comentarios adicionales.';
        END CASE;

        -- Insertar la solicitud en la tabla
        INSERT INTO tbb_aprobaciones (id, personal_medico_id, solicitud_id, comentario, estatus, tipo, fecha_registro, fecha_actualizacion)
        VALUES (i, i, i, comentario, status, tipo, fecha_registro, fecha_actualizacion);

        -- Actualizar aleatoriamente algunos registros después de la inserción
        IF RAND() < 0.5 THEN -- Aproximadamente el 50localhost de las veces
            -- Generar un nuevo tipo y estatus aleatorio para un registro aleatorio
            UPDATE tbb_aprobaciones
            SET tipo = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo'),
                estatus = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado')
            WHERE id = i AND estatus != 'En Proceso'; -- Evitar actualizar a 'En Proceso'
        END IF;
        
        -- Eliminar Registros de manera aleatoria
        IF RAND() < 0.2 then  -- Aproximadamente el 20localhost de las veces
			DELETE FROM tbb_aprobaciones 
			WHERE id = i; -- Elimina el Registro actual
        END IF;

        -- Incrementar el contador
        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertar_aprobaciones23` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_aprobaciones23`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE p_medico_id INT;
    DECLARE solicitud_id INT;
    DECLARE comentario TEXT;
    DECLARE random_status ENUM('En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');
    DECLARE random_type ENUM('Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');
    DECLARE num_solicitudes INT;
    DECLARE num_medicos INT;
    DECLARE idx INT;
    DECLARE random_index INT;
    DECLARE last_insert_id INT;

    -- Cursors
    DECLARE solicitud_cursor CURSOR FOR 
        SELECT ID FROM tbd_solicitudes;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Get the total number of Solicitud_IDs
    SELECT COUNT(*) INTO num_solicitudes FROM tbd_solicitudes;

    -- Get the total number of Personal_Medico_IDs
    SELECT COUNT(*) INTO num_medicos FROM tbb_personal_medico;

    -- Open cursor for Solicitud_IDs
    OPEN solicitud_cursor;

    -- Loop through Solicitud_IDs
    solicitud_loop: LOOP
        FETCH solicitud_cursor INTO solicitud_id;
        IF done THEN
            LEAVE solicitud_loop;  -- Exit loop when no more Solicitud_IDs
        END IF;

        -- Select a random Personal_Medico_ID for this Solicitud_ID
        SET random_index = FLOOR(1 + (RAND() * num_medicos));

        -- Retrieve a random Personal_Medico_ID
        SET @sql = CONCAT('SELECT Persona_ID INTO @p_medico_id FROM tbb_personal_medico ORDER BY RAND() LIMIT 1');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Generate random values
        SET idx = FLOOR(1 + (RAND() * 100));
        SET random_status = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');
        SET random_type = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');

        -- Select a random comment
        CASE idx
            WHEN 1 THEN SET comentario = 'Paciente muestra signos de mejoría.';
            WHEN 2 THEN SET comentario = 'Requiere monitoreo constante.';
            WHEN 3 THEN SET comentario = 'Se recomienda cambio de medicación.';
            WHEN 4 THEN SET comentario = 'Alta programada para mañana.';
            WHEN 5 THEN SET comentario = 'Necesita intervención quirúrgica.';
            WHEN 6 THEN SET comentario = 'Paciente estable, continuar tratamiento actual.';
            WHEN 7 THEN SET comentario = 'Realizar análisis de sangre adicional.';
            WHEN 8 THEN SET comentario = 'Se observa reacción alérgica, cambiar antibiótico.';
            WHEN 9 THEN SET comentario = 'Consultar con especialista en cardiología.';
            WHEN 10 THEN SET comentario = 'Requiere traslado a unidad de cuidados intensivos.';
            WHEN 11 THEN SET comentario = 'Paciente presenta fiebre alta.';
            WHEN 12 THEN SET comentario = 'Iniciar tratamiento con antibióticos.';
            WHEN 13 THEN SET comentario = 'Mantener en observación 24 horas.';
            WHEN 14 THEN SET comentario = 'Evaluar función renal y hepática.';
            WHEN 15 THEN SET comentario = 'Paciente no responde al tratamiento.';
            WHEN 16 THEN SET comentario = 'Administrar líquidos intravenosos.';
            WHEN 17 THEN SET comentario = 'Preparar para radiografía de tórax.';
            WHEN 18 THEN SET comentario = 'Recomendar dieta baja en sodio.';
            WHEN 19 THEN SET comentario = 'Paciente en recuperación postoperatoria.';
            WHEN 20 THEN SET comentario = 'Reevaluar síntomas en 48 horas.';
            WHEN 21 THEN SET comentario = 'Realizar electrocardiograma (ECG).';
            WHEN 22 THEN SET comentario = 'Observar por posibles complicaciones.';
            WHEN 23 THEN SET comentario = 'Paciente presenta dolor agudo.';
            WHEN 24 THEN SET comentario = 'Administrar analgésicos según prescripción.';
            WHEN 25 THEN SET comentario = 'Evaluar función pulmonar.';
            WHEN 26 THEN SET comentario = 'Paciente reporta mareos frecuentes.';
            WHEN 27 THEN SET comentario = 'Recomendar descanso absoluto.';
            WHEN 28 THEN SET comentario = 'Administrar antihistamínicos.';
            WHEN 29 THEN SET comentario = 'Programar sesión de fisioterapia.';
            WHEN 30 THEN SET comentario = 'Realizar pruebas de función tiroidea.';
            WHEN 31 THEN SET comentario = 'Paciente presenta náuseas y vómitos.';
            WHEN 32 THEN SET comentario = 'Iniciar tratamiento para hipertensión.';
            WHEN 33 THEN SET comentario = 'Recomendar control de glucemia.';
            WHEN 34 THEN SET comentario = 'Paciente muestra signos de deshidratación.';
            WHEN 35 THEN SET comentario = 'Administrar suero oral.';
            WHEN 36 THEN SET comentario = 'Evaluar respuesta a la medicación.';
            WHEN 37 THEN SET comentario = 'Paciente en estado crítico.';
            WHEN 38 THEN SET comentario = 'Mantener en unidad de cuidados intensivos.';
            WHEN 39 THEN SET comentario = 'Realizar tomografía computarizada (TC).';
            WHEN 40 THEN SET comentario = 'Paciente con historial de alergias.';
            WHEN 41 THEN SET comentario = 'Administrar epinefrina en caso de emergencia.';
            WHEN 42 THEN SET comentario = 'Monitorizar niveles de oxígeno en sangre.';
            WHEN 43 THEN SET comentario = 'Paciente requiere ventilación asistida.';
            WHEN 44 THEN SET comentario = 'Evaluar necesidad de transfusión sanguínea.';
            WHEN 45 THEN SET comentario = 'Paciente presenta síntomas de infección.';
            WHEN 46 THEN SET comentario = 'Iniciar aislamiento preventivo.';
            WHEN 47 THEN SET comentario = 'Realizar pruebas de función hepática.';
            WHEN 48 THEN SET comentario = 'Paciente en estado de shock.';
            WHEN 49 THEN SET comentario = 'Administrar fluidos intravenosos rápidamente.';
            WHEN 50 THEN SET comentario = 'Recomendar consulta con endocrinólogo.';
            WHEN 51 THEN SET comentario = 'Paciente presenta convulsiones.';
            WHEN 52 THEN SET comentario = 'Administrar anticonvulsivantes.';
            WHEN 53 THEN SET comentario = 'Recomendar seguimiento neurológico.';
            WHEN 54 THEN SET comentario = 'Paciente con dolor torácico persistente.';
            WHEN 55 THEN SET comentario = 'Realizar angiografía coronaria.';
            WHEN 56 THEN SET comentario = 'Paciente presenta erupción cutánea.';
            WHEN 57 THEN SET comentario = 'Administrar corticosteroides tópicos.';
            WHEN 58 THEN SET comentario = 'Evaluar signos de sepsis.';
            WHEN 59 THEN SET comentario = 'Iniciar tratamiento antibiótico de amplio espectro.';
            WHEN 60 THEN SET comentario = 'Paciente con historial de enfermedades cardíacas.';
            WHEN 61 THEN SET comentario = 'Recomendar prueba de esfuerzo.';
            WHEN 62 THEN SET comentario = 'Paciente presenta dificultad respiratoria.';
            WHEN 63 THEN SET comentario = 'Administrar broncodilatadores.';
            WHEN 64 THEN SET comentario = 'Paciente en recuperación post-anestesia.';
            WHEN 65 THEN SET comentario = 'Monitorizar signos vitales cada 30 minutos.';
            WHEN 66 THEN SET comentario = 'Realizar ecografía abdominal.';
            WHEN 67 THEN SET comentario = 'Paciente con signos de anemia.';
            WHEN 68 THEN SET comentario = 'Administrar suplemento de hierro.';
            WHEN 69 THEN SET comentario = 'Paciente requiere evaluación psiquiátrica.';
            WHEN 70 THEN SET comentario = 'Iniciar terapia cognitivo-conductual.';
            WHEN 71 THEN SET comentario = 'Paciente con historial de diabetes.';
            WHEN 72 THEN SET comentario = 'Recomendar control estricto de glucosa.';
            WHEN 73 THEN SET comentario = 'Realizar prueba de función pulmonar.';
            WHEN 74 THEN SET comentario = 'Paciente presenta ictericia.';
            WHEN 75 THEN SET comentario = 'Evaluar función hepática y biliar.';
            WHEN 76 THEN SET comentario = 'Paciente con síntomas de migraña.';
            WHEN 77 THEN SET comentario = 'Administrar triptanos según prescripción.';
            WHEN 78 THEN SET comentario = 'Realizar resonancia magnética (RM).';
            WHEN 79 THEN SET comentario = 'Paciente con dolor lumbar agudo.';
            WHEN 80 THEN SET comentario = 'Recomendar fisioterapia y ejercicios de estiramiento.';
            WHEN 81 THEN SET comentario = 'Paciente muestra signos de fatiga crónica.';
            WHEN 82 THEN SET comentario = 'Evaluar por posibles trastornos del sueño.';
            WHEN 83 THEN SET comentario = 'Paciente con historial de cáncer.';
            WHEN 84 THEN SET comentario = 'Programar seguimiento oncológico.';
            WHEN 85 THEN SET comentario = 'Paciente presenta hipertensión arterial.';
            WHEN 86 THEN SET comentario = 'Ajustar medicación antihipertensiva.';
            WHEN 87 THEN SET comentario = 'Realizar evaluación oftalmológica.';
            WHEN 88 THEN SET comentario = 'Paciente con dolor abdominal persistente.';
            WHEN 89 THEN SET comentario = 'Realizar endoscopia digestiva alta.';
            WHEN 90 THEN SET comentario = 'Paciente con antecedentes de asma.';
            WHEN 91 THEN SET comentario = 'Administrar corticosteroides inhalados.';
            WHEN 92 THEN SET comentario = 'Paciente presenta signos de depresión.';
            WHEN 93 THEN SET comentario = 'Iniciar tratamiento con antidepresivos.';
            WHEN 94 THEN SET comentario = 'Recomendar terapia psicológica.';
            WHEN 95 THEN SET comentario = 'Paciente en estado de desnutrición.';
            WHEN 96 THEN SET comentario = 'Iniciar dieta rica en nutrientes.';
            WHEN 97 THEN SET comentario = 'Paciente presenta dolor articular.';
            WHEN 98 THEN SET comentario = 'Administrar antiinflamatorios no esteroideos (AINEs).';
            WHEN 99 THEN SET comentario = 'Recomendar seguimiento con reumatólogo.';
            WHEN 100 THEN SET comentario = 'Paciente requiere atención odontológica.';
            ELSE SET comentario = 'No hay comentarios adicionales.';
        END CASE;

        -- Insert into tbb_aprobaciones
        INSERT INTO tbb_aprobaciones (Personal_Medico_ID, Solicitud_ID, Comentario, Estatus, Tipo)
        VALUES (@p_medico_id, solicitud_id, comentario, random_status, random_type);

        -- Obtener el ID del registro insertado
        SET last_insert_id = LAST_INSERT_ID();

        -- Actualizar aleatoriamente algunos registros después de la inserción
        IF RAND() < 0.5 THEN -- Aproximadamente el 50localhost de las veces
            -- Generar un nuevo tipo y estatus aleatorio para un registro aleatorio
            UPDATE tbb_aprobaciones
            SET Tipo = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo'),
                Estatus = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado')
            WHERE id = last_insert_id AND Estatus != 'En Proceso'; -- Evitar actualizar a 'En Proceso'
        END IF;

        -- Eliminar Registros de manera aleatoria
        IF RAND() < 0.2 THEN  -- Aproximadamente el 20localhost de las veces
            DELETE FROM tbb_aprobaciones 
            WHERE id = last_insert_id; -- Elimina el Registro actual
        END IF;

    END LOOP;

    CLOSE solicitud_cursor;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertar_aprobaciones_random` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_aprobaciones_random`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE p_medico_id INT;
    DECLARE solicitud_id INT;
    DECLARE comentario TEXT;
    DECLARE random_status ENUM('En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');
    DECLARE random_type ENUM('Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');
    DECLARE num_solicitudes INT;
    DECLARE num_medicos INT;
    DECLARE idx INT;
    DECLARE random_index INT;
    DECLARE last_insert_id INT;
    DECLARE inserted_rows INT DEFAULT 0;
    DECLARE fecha_registro DATETIME;
    DECLARE fecha_actualizacion DATETIME;

    -- Cursors
    DECLARE solicitud_cursor CURSOR FOR 
        SELECT ID FROM tbd_solicitudes;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Get the total number of Solicitud_IDs
    SELECT COUNT(*) INTO num_solicitudes FROM tbd_solicitudes;

    -- Get the total number of Personal_Medico_IDs
    SELECT COUNT(*) INTO num_medicos FROM tbb_personal_medico;

    -- Open cursor for Solicitud_IDs
    OPEN solicitud_cursor;

    -- Loop through Solicitud_IDs
    solicitud_loop: LOOP
        FETCH solicitud_cursor INTO solicitud_id;
        IF done THEN
            LEAVE solicitud_loop;  -- Exit loop when no more Solicitud_IDs
        END IF;

        -- Select a random Personal_Medico_ID for this Solicitud_ID
        SET random_index = FLOOR(1 + (RAND() * num_medicos));

        -- Retrieve a random Personal_Medico_ID
        SET @sql = CONCAT('SELECT Persona_ID INTO @p_medico_id FROM tbb_personal_medico ORDER BY RAND() LIMIT 1');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Generate random values
        SET idx = FLOOR(1 + (RAND() * 100));
        SET random_status = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado');
        SET random_type = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo');

        -- Select a random comment
        CASE idx
            WHEN 1 THEN SET comentario = 'Paciente muestra signos de mejoría.';
            WHEN 2 THEN SET comentario = 'Requiere monitoreo constante.';
            WHEN 3 THEN SET comentario = 'Se recomienda cambio de medicación.';
            WHEN 4 THEN SET comentario = 'Alta programada para mañana.';
            WHEN 5 THEN SET comentario = 'Necesita intervención quirúrgica.';
            WHEN 6 THEN SET comentario = 'Paciente estable, continuar tratamiento actual.';
            WHEN 7 THEN SET comentario = 'Realizar análisis de sangre adicional.';
            WHEN 8 THEN SET comentario = 'Se observa reacción alérgica, cambiar antibiótico.';
            WHEN 9 THEN SET comentario = 'Consultar con especialista en cardiología.';
            WHEN 10 THEN SET comentario = 'Requiere traslado a unidad de cuidados intensivos.';
            WHEN 11 THEN SET comentario = 'Paciente presenta fiebre alta.';
            WHEN 12 THEN SET comentario = 'Iniciar tratamiento con antibióticos.';
            WHEN 13 THEN SET comentario = 'Mantener en observación 24 horas.';
            WHEN 14 THEN SET comentario = 'Evaluar función renal y hepática.';
            WHEN 15 THEN SET comentario = 'Paciente no responde al tratamiento.';
            WHEN 16 THEN SET comentario = 'Administrar líquidos intravenosos.';
            WHEN 17 THEN SET comentario = 'Preparar para radiografía de tórax.';
            WHEN 18 THEN SET comentario = 'Recomendar dieta baja en sodio.';
            WHEN 19 THEN SET comentario = 'Paciente en recuperación postoperatoria.';
            WHEN 20 THEN SET comentario = 'Reevaluar síntomas en 48 horas.';
            WHEN 21 THEN SET comentario = 'Realizar electrocardiograma (ECG).';
            WHEN 22 THEN SET comentario = 'Observar por posibles complicaciones.';
            WHEN 23 THEN SET comentario = 'Paciente presenta dolor agudo.';
            WHEN 24 THEN SET comentario = 'Administrar analgésicos según prescripción.';
            WHEN 25 THEN SET comentario = 'Evaluar función pulmonar.';
            WHEN 26 THEN SET comentario = 'Paciente reporta mareos frecuentes.';
            WHEN 27 THEN SET comentario = 'Recomendar descanso absoluto.';
            WHEN 28 THEN SET comentario = 'Administrar antihistamínicos.';
            WHEN 29 THEN SET comentario = 'Programar sesión de fisioterapia.';
            WHEN 30 THEN SET comentario = 'Realizar pruebas de función tiroidea.';
            WHEN 31 THEN SET comentario = 'Paciente presenta náuseas y vómitos.';
            WHEN 32 THEN SET comentario = 'Iniciar tratamiento para hipertensión.';
            WHEN 33 THEN SET comentario = 'Recomendar control de glucemia.';
            WHEN 34 THEN SET comentario = 'Paciente muestra signos de deshidratación.';
            WHEN 35 THEN SET comentario = 'Administrar suero oral.';
            WHEN 36 THEN SET comentario = 'Evaluar respuesta a la medicación.';
            WHEN 37 THEN SET comentario = 'Paciente en estado crítico.';
            WHEN 38 THEN SET comentario = 'Mantener en unidad de cuidados intensivos.';
            WHEN 39 THEN SET comentario = 'Realizar tomografía computarizada (TC).';
            WHEN 40 THEN SET comentario = 'Paciente con historial de alergias.';
            WHEN 41 THEN SET comentario = 'Administrar epinefrina en caso de emergencia.';
            WHEN 42 THEN SET comentario = 'Monitorizar niveles de oxígeno en sangre.';
            WHEN 43 THEN SET comentario = 'Paciente requiere ventilación asistida.';
            WHEN 44 THEN SET comentario = 'Evaluar necesidad de transfusión sanguínea.';
            WHEN 45 THEN SET comentario = 'Paciente presenta síntomas de infección.';
            WHEN 46 THEN SET comentario = 'Iniciar aislamiento preventivo.';
            WHEN 47 THEN SET comentario = 'Realizar pruebas de función hepática.';
            WHEN 48 THEN SET comentario = 'Paciente en estado de shock.';
            WHEN 49 THEN SET comentario = 'Administrar fluidos intravenosos rápidamente.';
            WHEN 50 THEN SET comentario = 'Recomendar consulta con endocrinólogo.';
            WHEN 51 THEN SET comentario = 'Paciente presenta convulsiones.';
            WHEN 52 THEN SET comentario = 'Administrar anticonvulsivantes.';
            WHEN 53 THEN SET comentario = 'Recomendar seguimiento neurológico.';
            WHEN 54 THEN SET comentario = 'Paciente con dolor torácico persistente.';
            WHEN 55 THEN SET comentario = 'Realizar angiografía coronaria.';
            WHEN 56 THEN SET comentario = 'Paciente presenta erupción cutánea.';
            WHEN 57 THEN SET comentario = 'Administrar corticosteroides tópicos.';
            WHEN 58 THEN SET comentario = 'Evaluar signos de sepsis.';
            WHEN 59 THEN SET comentario = 'Iniciar tratamiento antibiótico de amplio espectro.';
            WHEN 60 THEN SET comentario = 'Paciente con historial de enfermedades cardíacas.';
            WHEN 61 THEN SET comentario = 'Recomendar prueba de esfuerzo.';
            WHEN 62 THEN SET comentario = 'Paciente presenta dificultad respiratoria.';
            WHEN 63 THEN SET comentario = 'Administrar broncodilatadores.';
            WHEN 64 THEN SET comentario = 'Paciente en recuperación post-anestesia.';
            WHEN 65 THEN SET comentario = 'Monitorizar signos vitales cada 30 minutos.';
            WHEN 66 THEN SET comentario = 'Realizar ecografía abdominal.';
            WHEN 67 THEN SET comentario = 'Paciente con signos de anemia.';
            WHEN 68 THEN SET comentario = 'Administrar suplemento de hierro.';
            WHEN 69 THEN SET comentario = 'Paciente requiere evaluación psiquiátrica.';
            WHEN 70 THEN SET comentario = 'Iniciar terapia cognitivo-conductual.';
            WHEN 71 THEN SET comentario = 'Paciente con historial de diabetes.';
            WHEN 72 THEN SET comentario = 'Recomendar control estricto de glucosa.';
            WHEN 73 THEN SET comentario = 'Realizar prueba de función pulmonar.';
            WHEN 74 THEN SET comentario = 'Paciente presenta ictericia.';
            WHEN 75 THEN SET comentario = 'Evaluar función hepática y biliar.';
            WHEN 76 THEN SET comentario = 'Paciente con síntomas de migraña.';
            WHEN 77 THEN SET comentario = 'Administrar triptanos según prescripción.';
            WHEN 78 THEN SET comentario = 'Realizar resonancia magnética (RM).';
            WHEN 79 THEN SET comentario = 'Paciente con dolor lumbar agudo.';
            WHEN 80 THEN SET comentario = 'Recomendar fisioterapia y ejercicios de estiramiento.';
            WHEN 81 THEN SET comentario = 'Paciente muestra signos de fatiga crónica.';
            WHEN 82 THEN SET comentario = 'Evaluar por posibles trastornos del sueño.';
            WHEN 83 THEN SET comentario = 'Paciente con historial de cáncer.';
            WHEN 84 THEN SET comentario = 'Programar seguimiento oncológico.';
            WHEN 85 THEN SET comentario = 'Paciente requiere cuidados paliativos.';
            WHEN 86 THEN SET comentario = 'Administrar analgésicos según necesidad.';
            WHEN 87 THEN SET comentario = 'Paciente con signos de infección urinaria.';
            WHEN 88 THEN SET comentario = 'Iniciar tratamiento con antibióticos.';
            WHEN 89 THEN SET comentario = 'Realizar endoscopia digestiva alta.';
            WHEN 90 THEN SET comentario = 'Paciente con antecedentes de asma.';
            WHEN 91 THEN SET comentario = 'Administrar corticosteroides inhalados.';
            WHEN 92 THEN SET comentario = 'Paciente presenta signos de depresión.';
            WHEN 93 THEN SET comentario = 'Iniciar tratamiento con antidepresivos.';
            WHEN 94 THEN SET comentario = 'Recomendar terapia psicológica.';
            WHEN 95 THEN SET comentario = 'Paciente en estado de desnutrición.';
            WHEN 96 THEN SET comentario = 'Iniciar dieta rica en nutrientes.';
            WHEN 97 THEN SET comentario = 'Paciente presenta dolor articular.';
            WHEN 98 THEN SET comentario = 'Administrar antiinflamatorios no esteroideos (AINEs).';
            WHEN 99 THEN SET comentario = 'Recomendar seguimiento con reumatólogo.';
            WHEN 100 THEN SET comentario = 'Paciente requiere atención odontológica.';
            ELSE SET comentario = 'No hay comentarios adicionales.';
        END CASE;

        -- Generar fecha de registro aleatoria entre el año 2000 y la fecha actual
        SET fecha_registro = DATE_ADD('2000-01-01', INTERVAL FLOOR(RAND() * DATEDIFF(NOW(), '2000-01-01')) DAY);
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 24) HOUR); -- Agregar horas aleatorias
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 60) MINUTE); -- Agregar minutos aleatorios
        SET fecha_registro = DATE_ADD(fecha_registro, INTERVAL FLOOR(RAND() * 60) SECOND); -- Agregar segundos aleatorios

        -- Verificar si hay una actualización previa para esta solicitud y si el nuevo status es "En Proceso"
        SELECT MAX(fecha_actualizacion) INTO fecha_actualizacion
        FROM tbb_aprobaciones
        WHERE solicitud_id = solicitud_id;

        IF fecha_actualizacion IS NOT NULL AND random_status = 'En Proceso' THEN
            -- Si hay una fecha de actualización previa y el nuevo estatus es "En Proceso", seleccionar otro estatus aleatorio que no sea "En Proceso"
            SET random_status = ELT(FLOOR(2 + (RAND() * 4)), 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado'); -- Evitar 'En Proceso'
        END IF;

        -- Generar fecha de actualización dentro de un rango de 2 a 3 días si el estatus no está en "En Proceso"
        IF random_status != 'En Proceso' THEN
            SET fecha_actualizacion = DATE_ADD(fecha_registro, INTERVAL 2 + FLOOR(RAND() * 2) DAY); -- Fecha aleatoria entre 2 y 3 días después de la fecha de registro
            SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 24) HOUR); -- Agregar horas aleatorias
            SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 60) MINUTE); -- Agregar minutos aleatorios
            SET fecha_actualizacion = DATE_ADD(fecha_actualizacion, INTERVAL FLOOR(RAND() * 60) SECOND); -- Agregar segundos aleatorios
        ELSE
            SET fecha_actualizacion = NULL; -- Dejar fecha_actualizacion como NULL si el estatus es "En Proceso"
        END IF;

        -- Insert into tbb_aprobaciones
        INSERT INTO tbb_aprobaciones (Personal_Medico_ID, Solicitud_ID, Comentario, Estatus, Tipo, Fecha_Registro, Fecha_Actualizacion)
        VALUES (@p_medico_id, solicitud_id, comentario, random_status, random_type, fecha_registro, fecha_actualizacion);

        -- Obtener el ID del registro insertado
        SET last_insert_id = LAST_INSERT_ID();
        SET inserted_rows = inserted_rows + 1;

        -- Actualizar aleatoriamente algunos registros después de la inserción
        IF RAND() < 0.5 AND inserted_rows < num_solicitudes - 1 THEN -- Aproximadamente el 50localhost de las veces
            -- Generar un nuevo tipo y estatus aleatorio para un registro aleatorio
            UPDATE tbb_aprobaciones
            SET Tipo = ELT(FLOOR(1 + (RAND() * 4)), 'Servicio Interno', 'Traslados', 'Subrogado', 'Administrativo'),
                Estatus = ELT(FLOOR(1 + (RAND() * 5)), 'En Proceso', 'Pausado', 'Aprobado', 'Reprogramado', 'Cancelado')
            WHERE id = last_insert_id AND Estatus != 'En Proceso'; -- Evitar actualizar a 'En Proceso'
        END IF;

        -- Eliminar Registros de manera aleatoria
        IF RAND() < 0.2 AND inserted_rows < num_solicitudes - 1 THEN  -- Aproximadamente el 20localhost de las veces
            DELETE FROM tbb_aprobaciones 
            WHERE id = last_insert_id; -- Elimina el Registro actual
        END IF;

    END LOOP;

    CLOSE solicitud_cursor;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insertar_horario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_horario`(
    IN p_empleado_id INT,
    IN p_nombre VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_dia_semana VARCHAR(20),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_turno ENUM('Matutino', 'Vespertino', 'Nocturno'),
    IN p_nombre_departamento VARCHAR(100),
    IN p_nombre_sala VARCHAR(100)
)
BEGIN
    INSERT INTO tbd_horarios (
        empleado_id, 
        nombre, 
        especialidad, 
        dia_semana, 
        hora_inicio, 
        hora_fin, 
        turno, 
        nombre_departamento, 
        nombre_sala
    ) VALUES (
        p_empleado_id, 
        p_nombre, 
        p_especialidad, 
        p_dia_semana, 
        p_hora_inicio, 
        p_hora_fin, 
        p_turno, 
        p_nombre_departamento, 
        p_nombre_sala
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_InsertaUsuariosPersonas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertaUsuariosPersonas`(
    IN cantidad INT,
    IN p_tipo_usuario VARCHAR(50),
    IN edad_minima INT,
    IN edad_maxima INT
)
BEGIN
    -- Declaraciones de variables
    DECLARE v_PersonaID CHAR(36);
    DECLARE v_Nombre VARCHAR(80);
    DECLARE v_PrimerApellido VARCHAR(80);
    DECLARE v_FechaNacimiento DATE;
    DECLARE v_NombreUsuario VARCHAR(60);
    DECLARE v_CorreoElectronico VARCHAR(100);
    DECLARE v_Contrasena VARCHAR(40);
    DECLARE v_NumeroTelefonico VARCHAR(20);
    DECLARE v_UserID CHAR(36);
    DECLARE v_RolID CHAR(36);
    DECLARE done INT DEFAULT 0;
    DECLARE inserted_count INT DEFAULT 0;
    DECLARE total_personas INT;
    DECLARE personas_faltantes INT;

    -- Declaración del cursor
    DECLARE cur CURSOR FOR 
        SELECT ID, Nombre, Primer_Apellido, Fecha_Nacimiento
        FROM tbb_personas
        WHERE ID NOT IN (SELECT Persona_ID FROM tbb_usuarios)
          AND TIMESTAMPDIFF(YEAR, Fecha_Nacimiento, CURDATE()) BETWEEN edad_minima AND edad_maxima;

    -- Declarar el handler para manejar el final del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Validación de cantidad mínima
    IF cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad de usuarios a insertar debe ser mayor a 0.';
    END IF;

    -- Obtener el ID del rol
    SELECT ID INTO v_RolID
    FROM tbc_roles
    WHERE Nombre = p_tipo_usuario
    LIMIT 1;

    IF v_RolID IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El rol especificado no existe.';
    END IF;

    -- Contar cuántas personas cumplen con la condición
    SELECT COUNT(*) INTO total_personas
    FROM tbb_personas
    WHERE ID NOT IN (SELECT Persona_ID FROM tbb_usuarios)
      AND TIMESTAMPDIFF(YEAR, Fecha_Nacimiento, CURDATE()) BETWEEN edad_minima AND edad_maxima;

    -- Calcular cuántas personas faltan
    SET personas_faltantes = cantidad - total_personas;

    -- Si no hay suficientes personas, llamamos a SP_InsertarPersonas para crearlas
    IF personas_faltantes > 0 THEN
        CALL SP_InsertarPersonas(personas_faltantes, NULL, DATE_SUB(CURDATE(), INTERVAL edad_maxima YEAR), DATE_SUB(CURDATE(), INTERVAL edad_minima YEAR));
    END IF;

    -- Iniciar transacción
    START TRANSACTION;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_PersonaID, v_Nombre, v_PrimerApellido, v_FechaNacimiento;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF inserted_count >= cantidad THEN
            LEAVE read_loop;
        END IF;

        -- Generar valores únicos para usuario y correo
        SET v_NombreUsuario = CONCAT(LOWER(v_Nombre), '.', LOWER(v_PrimerApellido), FLOOR(100 + RAND() * 900));

        -- Verificar si el usuario ya existe
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Nombre_Usuario = v_NombreUsuario) DO
            SET v_NombreUsuario = CONCAT(LOWER(v_Nombre), '.', LOWER(v_PrimerApellido), FLOOR(100 + RAND() * 900));
        END WHILE;

        -- Generar correo basado en el usuario
        SET v_CorreoElectronico = CONCAT(v_NombreUsuario, '@ejemplo.com');

        -- Verificar si el correo ya existe
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Correo_Electronico = v_CorreoElectronico) DO
            SET v_CorreoElectronico = CONCAT(v_NombreUsuario, FLOOR(10 + RAND() * 90), '@ejemplo.com');
        END WHILE;

        SET v_Contrasena = SUBSTRING(MD5(RAND()), 1, 8);
        SET v_NumeroTelefonico = fn_genera_numero_telefonico();
        SET v_UserID = UUID();

        -- Insertar en tbb_usuarios
        INSERT INTO tbb_usuarios (
            ID, Persona_ID, Nombre_Usuario, Correo_Electronico, Contrasena, numero_telefonico_movil, Estatus, Fecha_Registro
        ) VALUES (
            v_UserID, 
            v_PersonaID,
            v_NombreUsuario,
            v_CorreoElectronico,
            v_Contrasena,
            v_NumeroTelefonico,
            'Activo',
            NOW()
        );

        -- Insertar en tbd_usuarios_roles
        INSERT INTO tbd_usuarios_roles (
            Usuario_ID, Rol_ID, Estatus, Fecha_Registro
        ) VALUES (
            v_UserID,
            v_RolID,
            b'1',
            NOW()
        );

        SET inserted_count = inserted_count + 1;
    END LOOP;
    CLOSE cur;

    -- Confirmar la transacción
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_InsertaUsuariosPersonasAuto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_InsertaUsuariosPersonasAuto`()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_RolNombre VARCHAR(50);
    DECLARE v_Cantidad INT;
    DECLARE v_RolID CHAR(36);

    -- Variables de usuario/persona
    DECLARE v_PersonaID CHAR(36);
    DECLARE v_Nombre VARCHAR(80);
    DECLARE v_PrimerApellido VARCHAR(80);
    DECLARE v_FechaNacimiento DATE;
    DECLARE v_NombreUsuario VARCHAR(60);
    DECLARE v_CorreoElectronico VARCHAR(100);
    DECLARE v_Contrasena VARCHAR(40);
    DECLARE v_NumeroTelefonico VARCHAR(20);
    DECLARE v_UserID CHAR(36);
    DECLARE v_edad_minima INT;
    DECLARE v_edad_maxima INT;
    DECLARE inserted_count INT;
    DECLARE edad_rango_random FLOAT;
    DECLARE total_personas INT;
    DECLARE personas_faltantes INT;

    -- Primero se declaran todos los CURSORES antes del HANDLER
    DECLARE cur_roles CURSOR FOR SELECT nombre FROM tbc_roles;
    DECLARE cur_usuarios CURSOR FOR 
        SELECT ID, Nombre, Primer_Apellido, Fecha_Nacimiento
        FROM tbb_personas
        WHERE ID NOT IN (SELECT Persona_ID FROM tbb_usuarios)
        AND TIMESTAMPDIFF(YEAR, Fecha_Nacimiento, CURDATE()) 
            BETWEEN v_edad_minima AND v_edad_maxima;

    -- Handler para ambas partes del flujo
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Recorremos los roles
    OPEN cur_roles;
    read_roles: LOOP
        FETCH cur_roles INTO v_RolNombre;
        IF done THEN LEAVE read_roles; END IF;

        -- Proporción por rol
        CASE v_RolNombre
            WHEN 'Paciente' THEN
                SET v_Cantidad = FLOOR(30 + RAND() * 40);
            WHEN 'Médico General' THEN
                SET v_Cantidad = FLOOR(4 + RAND() * 4);
            WHEN 'Médico Especialista' THEN
                SET v_Cantidad = FLOOR(4 + RAND() * 4);
            WHEN 'Enfermero' THEN
                SET v_Cantidad = FLOOR(5 + RAND() * 5);
            WHEN 'Administrativo' THEN
                SET v_Cantidad = FLOOR(2 + RAND() * 3);
            ELSE
                SET v_Cantidad = FLOOR(1 + RAND() * 2);
        END CASE;

        -- Rango de edad
        IF v_RolNombre = 'Paciente' THEN
            SET v_edad_minima = 0;
            SET v_edad_maxima = 90;
        ELSE
            SET edad_rango_random = RAND();
            IF edad_rango_random < 0.20 THEN
                SET v_edad_minima = 20;
                SET v_edad_maxima = 29;
            ELSEIF edad_rango_random < 0.50 THEN
                SET v_edad_minima = 30;
                SET v_edad_maxima = 39;
            ELSEIF edad_rango_random < 0.75 THEN
                SET v_edad_minima = 40;
                SET v_edad_maxima = 49;
            ELSEIF edad_rango_random < 0.90 THEN
                SET v_edad_minima = 50;
                SET v_edad_maxima = 59;
            ELSE
                SET v_edad_minima = 60;
                SET v_edad_maxima = 65;
            END IF;
        END IF;

        -- Obtener ID del rol
        SELECT ID INTO v_RolID
        FROM tbc_roles
        WHERE Nombre = v_RolNombre
        LIMIT 1;

        IF v_RolID IS NULL THEN
            ITERATE read_roles;
        END IF;

        -- Verificar personas disponibles
        SELECT COUNT(*) INTO total_personas
        FROM tbb_personas
        WHERE ID NOT IN (SELECT Persona_ID FROM tbb_usuarios)
        AND TIMESTAMPDIFF(YEAR, Fecha_Nacimiento, CURDATE()) 
            BETWEEN v_edad_minima AND v_edad_maxima;

        SET personas_faltantes = v_Cantidad - total_personas;

        IF personas_faltantes > 0 THEN
            CALL SP_InsertarPersonas(
                personas_faltantes,
                NULL,
                DATE_SUB(CURDATE(), INTERVAL v_edad_maxima YEAR),
                DATE_SUB(CURDATE(), INTERVAL v_edad_minima YEAR)
            );
        END IF;

        -- Insertar usuarios
        SET inserted_count = 0;
        SET done = 0;

        OPEN cur_usuarios;
        read_loop: LOOP
            FETCH cur_usuarios INTO v_PersonaID, v_Nombre, v_PrimerApellido, v_FechaNacimiento;
            IF done THEN LEAVE read_loop; END IF;
            IF inserted_count >= v_Cantidad THEN LEAVE read_loop; END IF;

            -- Generar datos
            SET v_NombreUsuario = CONCAT(LOWER(v_Nombre), '.', LOWER(v_PrimerApellido), FLOOR(100 + RAND() * 900));
            WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Nombre_Usuario = v_NombreUsuario) DO
                SET v_NombreUsuario = CONCAT(LOWER(v_Nombre), '.', LOWER(v_PrimerApellido), FLOOR(100 + RAND() * 900));
            END WHILE;

            SET v_CorreoElectronico = CONCAT(v_NombreUsuario, '@ejemplo.com');
            WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Correo_Electronico = v_CorreoElectronico) DO
                SET v_CorreoElectronico = CONCAT(v_NombreUsuario, FLOOR(10 + RAND() * 90), '@ejemplo.com');
            END WHILE;

            SET v_Contrasena = SUBSTRING(MD5(RAND()), 1, 8);
            SET v_NumeroTelefonico = fn_genera_numero_telefonico();
            SET v_UserID = UUID();

            START TRANSACTION;
            INSERT INTO tbb_usuarios (
                ID, Persona_ID, Nombre_Usuario, Correo_Electronico, Contrasena,
                numero_telefonico_movil, Estatus, Fecha_Registro
            ) VALUES (
                v_UserID, v_PersonaID, v_NombreUsuario, v_CorreoElectronico, v_Contrasena,
                v_NumeroTelefonico, 'Activo', NOW()
            );

            INSERT INTO tbd_usuarios_roles (
                Usuario_ID, Rol_ID, Estatus, Fecha_Registro
            ) VALUES (
                v_UserID, v_RolID, b'1', NOW()
            );
            COMMIT;

            SET inserted_count = inserted_count + 1;
        END LOOP;
        CLOSE cur_usuarios;

        SET done = 0; -- reset handler
    END LOOP;
    CLOSE cur_roles;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_LimpiarBD-TABLAS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER="root"@"localhost" PROCEDURE "SP_LimpiarBD-TABLAS"()
BEGIN
    -- Deshabilitar restricciones de clave foránea temporalmente
    SET FOREIGN_KEY_CHECKS = 0;

    -- Eliminar registros de todas las tablas
    DELETE FROM tbb_personas;
    DELETE FROM tbb_usuarios;
    DELETE FROM tbc_areas_medicas;
    DELETE FROM tbb_citas_medicas;
    DELETE FROM tbc_departamentos;
    DELETE FROM tbc_espacios;
    DELETE FROM tbb_pacientes;
    DELETE FROM tbb_personal_medico;
    DELETE FROM tbc_roles;
    DELETE FROM tbc_servicios_medicos;
    DELETE FROM tbi_bitacora;
    DELETE FROM tbd_usuarios_roles;

    -- Reiniciar AUTO_INCREMENT solo donde aplica (por ejemplo: tbb_usuarios y tbi_bitacora si usan INT AUTO_INCREMENT)
    ALTER TABLE tbb_usuarios AUTO_INCREMENT = 1;
    ALTER TABLE tbi_bitacora AUTO_INCREMENT = 1;
    ALTER TABLE tbc_roles AUTO_INCREMENT = 1;

    -- Habilitar restricciones de clave foránea nuevamente
    SET FOREIGN_KEY_CHECKS = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_LimpiarPersonas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LimpiarPersonas`()
BEGIN
    -- Deshabilitar restricciones de clave foránea temporalmente
    SET FOREIGN_KEY_CHECKS = 0;

    -- Elimina todos los registros de la tabla tbb_personas
    DELETE FROM tbb_personas;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbb_personas AUTO_INCREMENT = 1;

	DELETE FROM tbb_usuarios;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbb_usuarios AUTO_INCREMENT = 1;
    
    DELETE FROM tbc_areas_medicas;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbc_areas_medicas AUTO_INCREMENT = 1;
    
    DELETE FROM tbb_citas_medicas;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbb_citas_medicas AUTO_INCREMENT = 1;

    DELETE FROM tbc_citas_medicas;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbc_citas_medicas AUTO_INCREMENT = 1;
    
	DELETE FROM tbc_departamentos;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbc_departamentos AUTO_INCREMENT = 1;
    
	DELETE FROM tbc_espacios;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbc_espacios AUTO_INCREMENT = 1;    
    
	DELETE FROM tbb_pacientes;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbb_pacientes AUTO_INCREMENT = 1;
    
	DELETE FROM tbb_personal_medico;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbb_personal_medico AUTO_INCREMENT = 1;
    
	DELETE FROM tbc_roles;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbc_roles AUTO_INCREMENT = 1;
    
	DELETE FROM tbc_servicios_medicos;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbc_servicios_medicos AUTO_INCREMENT = 1;




    -- Elimina todos los registros de la tabla tbi_bitacora
   DELETE FROM tbi_bitacora;
    -- Reinicia el ID autoincremental (si aplica)
   ALTER TABLE tbi_bitacora AUTO_INCREMENT = 1;

    -- Habilitar restricciones de clave foránea nuevamente
    SET FOREIGN_KEY_CHECKS = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_LimpiarUsuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LimpiarUsuarios`()
BEGIN
    -- Deshabilitar restricciones de clave foránea temporalmente
    SET FOREIGN_KEY_CHECKS = 0;

    -- Elimina todos los registros de la tabla tbb_personas
    DELETE FROM tbb_usuarios;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbb_usuarios AUTO_INCREMENT = 1;

    -- Elimina todos los registros de la tabla tbi_bitacora
    DELETE FROM tbd_usuarios_roles;
    -- Reinicia el ID autoincremental (si aplica)
    ALTER TABLE tbd_usuarios_roles AUTO_INCREMENT = 1;
    

    -- Habilitar restricciones de clave foránea nuevamente
    SET FOREIGN_KEY_CHECKS = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_limpiar_bd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_limpiar_bd`(v_password varchar(10))
    DETERMINISTIC
BEGIN
	IF v_password = "xYz$123" THEN
    

 
    
	delete from tbd_cirugias_personal_medico;
	ALTER TABLE tbd_cirugias_personal_medico AUTO_INCREMENT=1;
    
	delete from tbb_cirugias;
	ALTER TABLE tbb_cirugias AUTO_INCREMENT=1;
    
    -- Eliminamos los datos de las tablas débiles
    DELETE FROM tbd_usuarios_roles;
    DELETE FROM tbb_citas_medicas;
    ALTER TABLE tbb_citas_medicas AUTO_INCREMENT=1;
    
    -- Eliminamos los datos de las tablas fuertes
-- -------------------------------------------------------  
    	DELETE FROM tbb_aprobaciones;
	ALTER TABLE tbb_aprobaciones AUTO_INCREMENT=1;
	
	DELETE FROM tbd_solicitudes;
	ALTER TABLE tbd_solicitudes AUTO_INCREMENT=1;
-- -------------------------------------------------------  
	DELETE FROM tbb_pacientes;
	ALTER TABLE tbb_pacientes AUTO_INCREMENT=1;
    DELETE FROM tbb_usuarios;
    ALTER TABLE tbb_usuarios AUTO_INCREMENT=1;
	DELETE FROM tbd_expedientes_clinicos;
	ALTER TABLE tbd_expedientes_clinicos AUTO_INCREMENT=1;
    DELETE FROM tbd_recetas_medicas;
    ALTER TABLE tbd_recetas_medicas AUTO_INCREMENT=1;
    DELETE FROM tbb_personal_medico;    
    DELETE FROM tbb_personas;
	ALTER TABLE tbb_personas AUTO_INCREMENT=1;
    DELETE FROM tbc_roles;
    ALTER TABLE tbc_roles AUTO_INCREMENT=1;
    UPDATE tbc_espacios SET espacio_superior_id = NULL;
	DELETE FROM tbc_espacios;
    ALTER TABLE tbc_espacios AUTO_INCREMENT=1;
    
    
    DELETE FROM tbd_departamentos_servicios;
    
	DELETE FROM tbc_servicios_medicos;
    ALTER TABLE tbc_servicios_medicos AUTO_INCREMENT=1;
    /* DELETE FROM tbc_areas_medicas;
    ALTER TABLE tbc_areas_medicas AUTO_INCREMENT=1;*/

    
	DELETE FROM tbd_resultados_estudios;
	ALTER TABLE tbd_resultados_estudios AUTO_INCREMENT=1;
    DELETE FROM tbd_dispensaciones;
	ALTER TABLE tbd_dispensaciones AUTO_INCREMENT=1;
    DELETE FROM tbd_lotes_medicamentos;
	ALTER TABLE tbd_lotes_medicamentos AUTO_INCREMENT=1;
	DELETE FROM tbc_consumibles;
	ALTER TABLE tbc_consumibles AUTO_INCREMENT=1;


    DELETE FROM tbc_organos;
	ALTER TABLE tbc_organos AUTO_INCREMENT=1;
    DELETE FROM tbc_espacios;
	ALTER TABLE tbc_espacios AUTO_INCREMENT=1;


    DELETE FROM tbc_puestos;
    ALTER TABLE tbc_puestos AUTO_INCREMENT=1;
    DELETE FROM tbc_estudios;
    ALTER TABLE tbc_estudios AUTO_INCREMENT=1;

	DELETE FROM tbb_valoraciones_medicas;
    ALTER TABLE tbb_valoraciones_medicas AUTO_INCREMENT=1;
    DELETE FROM tbb_nacimientos;
    ALTER TABLE tbb_nacimientos AUTO_INCREMENT=1;
    DELETE FROM tbc_medicamentos;
    ALTER TABLE tbc_medicamentos AUTO_INCREMENT=1;
    
    DELETE FROM tbi_bitacora;
	ALTER TABLE tbi_bitacora AUTO_INCREMENT=1;
    
    	ELSE
		SELECT "La contraseña es incorrecta" AS Mensaje;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_Aprobaciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_Aprobaciones`(IN v_password VARCHAR(255))
BEGIN
    IF v_password = '1234' THEN
        -- Insertar
		INSERT INTO tbb_aprobaciones (`id`, `personal_medico_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('1', '1', '1', 'Preuba de Solicitud', 'En Proceso', 'Servicio Interno', now());

		INSERT INTO tbb_aprobaciones (`id`, `personal_medico_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('2', '2', '2', 'Traslado a la sala de Cuidados Intensivos', 'En Proceso', 'Servicio Interno', now());

		INSERT INTO tbb_aprobaciones (`id`, `personal_medico_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('3', '3', '3', 'Traslado a la sala de Cuidados Intensivos', 'En Proceso', 'Servicio Interno', now());
                    
		INSERT INTO tbb_aprobaciones (`id`, `personal_medico_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('4', '2', '4', 'Solicitud de Cunas en Area de Maternida', 'Aprobado', 'Servicio Interno', now());
         
         /* Depende del numero solicitudes registradas en la tbd_solicitudes
		INSERT INTO tbb_aprobaciones (`id`, `personal_medico_id`, `solicitud_id`, `comentario`, `estatus`, `tipo`, `fecha_registro`) 
					VALUES ('5', '1', '5', 'Solicitud de Apertura de Area de Maternidad ', 'Aprobado', 'Servicio Interno', now());
		*/
        -- Actualizar
		UPDATE tbb_aprobaciones SET Estatus = 'Aprobado' WHERE Estatus = 'En Proceso' and ID = 1;
		UPDATE tbb_aprobaciones SET Tipo = 'Subrogado' WHERE Tipo = 'Servicio Interno' and ID  = 4;
		UPDATE tbb_aprobaciones SET Comentario = 'Solicitud de traslado a la UTI' WHERE Comentario = 'Preuba de Solicitud' and id = 1;
        
        -- Eliminar
		delete from tbb_aprobaciones where id = 2;
        
    ELSE
        SELECT 'La contraseña es incorrecta, no puedo mostrarte los nacimientos de la base de datos' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_areas_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_areas_medicas`(IN v_password VARCHAR(50))
BEGIN
    DECLARE id_val INT;

    IF v_password = "xYz$123" THEN
        -- Realizar la inserción inicial
        INSERT INTO tbc_areas_medicas (Nombre, Descripcion, Estatus, Fecha_Registro, Fecha_Actualizacion)
        VALUES
        ('Servicios Medicos', 'Por definir', 'Activo', '2024-01-21 16:00:41', NOW()),
        ('Servicios de Apoyo', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Servicios Medico - Administrativos', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Servicios de Enfermeria', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Departamentos Administrativos', 'Por definir', 'Activo', '2024-01-21 16:06:31', NOW()),
        ('Nueva Área Médica', 'Por definir', 'Activo', '2024-06-18 12:00:00', NOW()); -- Inserción de la nueva área médica

        -- Obtener el último ID insertado
        SET id_val = LAST_INSERT_ID();

        -- Mostrar los datos insertados
        SELECT * FROM tbc_areas_medicas;

        -- Actualizar el estado a 'Inactivo' para el registro 'Nueva Área Médica'
        UPDATE tbc_areas_medicas
        SET Estatus = 'Inactivo'
        WHERE Nombre = 'Nueva Área Médica';

        -- Mostrar los datos actualizados
        SELECT * FROM tbc_areas_medicas;

        -- Eliminar el registro 'Nueva Área Médica'
        DELETE FROM tbc_areas_medicas
        WHERE Nombre = 'Nueva Área Médica';

        -- Mostrar los datos después de la eliminación
        SELECT * FROM tbc_areas_medicas;

    ELSE
        -- Mostrar mensaje de error si la contraseña es incorrecta
        SELECT 'Contraseña incorrecta' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_cirugias` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_cirugias`(v_password VARCHAR (20))
BEGIN

    DECLARE id_persona INT DEFAULT 0;
    DECLARE id_paciente INT DEFAULT 0;
    DECLARE id_paciente2 INT DEFAULT 0;
    DECLARE id_paciente3 INT DEFAULT 0;
     DECLARE id_paciente4 INT DEFAULT 0;
    DECLARE id_espacio_superior_1 INT DEFAULT 0;
    DECLARE id_espacio_superior_2 INT DEFAULT 0;
    DECLARE id_espacio_medico INT DEFAULT 0;
	DECLARE id_espacio_medico1 INT DEFAULT 0;
    DECLARE id_espacio_medico2 INT DEFAULT 0;
    DECLARE id_espacio_medico3 INT DEFAULT 0;

    IF v_password = "xyz#$localhost" THEN

        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
        INSERT INTO tbb_personas 
        (Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, 
        Fecha_Registro, Fecha_Actualizacion) 
        VALUES 
        ("Dr.", "Alejandro", "Barrera", "Fernández", "BAFA810525HVZLRR05", "M", "O+", "1981-05-25", DEFAULT, DEFAULT, NULL);
        SET id_persona = last_insert_id(); -- Captura el ID de la persona
        -- Insertamos los datos médicos del empleado
        INSERT INTO tbb_personal_medico 
        (Persona_ID, Departamento_ID, Cedula_Profesional, Tipo, Especialidad, Fecha_Registro, Fecha_Contratacion, 
        Fecha_Termino_Contrato, Salario, Estatus, Fecha_Actualizacion) 
        VALUES 
        (id_persona, 13, "25515487", "Médico", "Pediatría", "2012-08-22 08:50:25", "2015-09-16 09:10:52", NULL, 35000, DEFAULT, NULL);
		
         -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
		INSERT INTO tbb_personas(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus,
        Fecha_Registro, Fecha_Actualizacion) 
        VALUES
        ("Dra.", "María José", "Álvarez", "Fonseca","ALFM900620MPLLNR2A", "F", "O-", "1990-06-20", DEFAULT, DEFAULT,NULL);
        set id_persona=last_insert_id();
        -- Insertamos los datos médicos del empledo
        INSERT INTO tbb_personal_medico
        (Persona_ID, Departamento_ID, Cedula_Profesional, Tipo, Especialidad, Fecha_Registro, Fecha_Contratacion, 
        Fecha_Termino_Contrato, Salario, Estatus, Fecha_Actualizacion) 
        VALUES 
        (id_persona, 11, "11422587", "Médico",NULL, 
        "2018-05-10 08:50:25", "2018-05-10 09:10:52", NULL, 10000,DEFAULT,NULL);
		
        INSERT INTO tbb_personas(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus,
        Fecha_Registro, Fecha_Actualizacion) 
        VALUES 
        ("Dr.", "Alfredo", "Carrasco", "Lechuga", "CALA710115HCSRCL25", "M", "AB-", "1971-01-15", DEFAULT, DEFAULT,NULL);
		set id_persona=last_insert_id();
        -- Insertamos los datos médicos del empledo
        INSERT INTO tbb_personal_medico
        (Persona_ID, Departamento_ID, Cedula_Profesional, Tipo, Especialidad, Fecha_Registro, Fecha_Contratacion, 
        Fecha_Termino_Contrato, Salario, Estatus, Fecha_Actualizacion) 
        VALUES
        (id_persona, 1, "3256884", "Administrativo",NULL, 
        "2000-01-01 11:50:25", "2000-01-02 09:00:00", NULL, 40000,DEFAULT,NULL);
        
-- -------------------------------------------------------------------------------------------------------------------------

        -- Insertamos los datos de la persona del primer paciente
        INSERT INTO tbb_personas 
        (Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento,
        Estatus, Fecha_Registro, Fecha_Actualizacion)
        VALUES
        ('Sra.', 'María', 'López', 'Martínez', 'LOMJ850202MDFRPL01', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL);
        SET id_persona = last_insert_id(); -- Captura el ID de la persona del paciente
        INSERT INTO `tbb_pacientes` 
        (Persona_ID, NSS, Tipo_Seguro, Fecha_Ultima_Cita, Estatus_Medico, Estatus_Vida, Estatus, Fecha_Registro, Fecha_Actualizacion) 
        VALUES 
        (id_persona, NULL, 'Sin Seguro', '2009-03-17 17:31:00', DEFAULT, 'Vivo', 1, '2001-02-15 06:23:05', NULL);
        SET id_paciente = last_insert_id(); -- Captura el ID del paciente para usarlo más adelante
        
        -- Insertamos los datos de la persona del segundo paciente
		INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		(NULL, 'Ana', 'Hernández', 'Ruiz', 'HERA900303HDFRRL01', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL);
		SET id_persona = last_insert_id();
        INSERT INTO `tbb_pacientes` VALUES (id_persona,NULL,'Sin Seguro','2019-05-01 13:15:29',default,'Vivo',1,'2020-06-28 18:46:37',NULL);
		SET id_paciente2 = last_insert_id();
        -- Insertamos los datos de la persona del tercer paciente
		INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		('Dr.', 'Carlos', 'García', 'Rodríguez', 'GARC950404HDFRRL06', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL);
        SET id_persona = last_insert_id();
		INSERT INTO `tbb_pacientes` VALUES (id_persona,'G9OA6QW29V8DVXS','Seguro Popular','2024-02-16 13:10:48',default,'Vivo',1,'2024-02-18 16:05:14',NULL);
		SET id_paciente3 = last_insert_id();
        -- Insertamos los datos de la persona del cuarto paciente
		INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		('Lic.', 'Laura', 'Martínez', 'Gómez', 'MALG000505MDFRRL07', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL);
        SET id_persona = last_insert_id();
		INSERT INTO `tbb_pacientes` VALUES (id_persona,"12254185844-3",'Particular','2022-08-16 12:05:35',default,'Vivo',1,'2022-08-16 11:50:00',NULL);
		SET id_paciente4 = last_insert_id();
        
-- --------------------------------------------------------------------------------------------------------------------------------
        -- INSERTAMOS EL EDIFICIO 1 - Medicina General
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Edificio', 'Medicina General',1 ,NULL,DEFAULT, DEFAULT);
        SET id_espacio_superior_1 = last_insert_id();

        -- Espacios de Nivel 2 
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Piso', 'Planta Baja',56 ,id_espacio_superior_1,DEFAULT,DEFAULT);
        SET id_espacio_superior_2 = last_insert_id();

        -- Espacios de Nivel 3
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Quirófano', 'A-106',16 ,id_espacio_superior_2,DEFAULT, DEFAULT);
         SET id_espacio_medico = last_insert_id(); -- Captura el ID del espacio médico
         INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Quirófano', 'A-107',16 ,id_espacio_superior_2,DEFAULT, DEFAULT);
		set id_espacio_medico1 = last_insert_id();
		INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Quirófano', 'A-108',16 ,id_espacio_superior_2,DEFAULT, DEFAULT);
		set id_espacio_medico2 = last_insert_id();
		INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Quirófano', 'A-109',16 ,id_espacio_superior_2,DEFAULT, DEFAULT);
         SET id_espacio_medico3 = last_insert_id(); -- Captura el ID del espacio médico
        
        -- Inserta la cirugía en tbb_cirugias usando el ID correcto del paciente y del espacio médico
        INSERT INTO tbb_cirugias 
        (Paciente_ID, Espacio_Medico_ID, Tipo, Nombre, Descripcion, Nivel_Urgencia, Horario, Observaciones, Valoracion_Medica, Estatus, Consumible, Fecha_Registro, Fecha_Actualizacion) 
        VALUES
        (id_paciente, 
        id_espacio_medico,
        'Ortopédica', 
        'Reemplazo de Rodilla', 
        'Cirugía para reemplazar una articulación de rodilla dañada con una prótesis.',
        'Alto', 
        '2024-06-20 09:00:00', 
        'Paciente con antecedentes de artritis severa.', 
        'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
        'Programada', 
        'Prótesis de rodilla, Instrumental quirúrgico', 
        DEFAULT, 
        NOW()),
         (id_paciente2, 
        id_espacio_medico1,
         'Ginecológica', 
            'Cesárea', 
            'Cirugía para el nacimiento de un bebé a través de una incisión en el abdomen y el útero de la madre.',
            'Medio', 
            '2024-06-25 10:00:00', 
            'Paciente con antecedentes de parto complicado.', 
            'Valoración preoperatoria completa, paciente en condiciones adecuadas.', 
            'Programada', 
            'Instrumental quirúrgico, Equipo de monitoreo fetal',
            default,
            NOW()),
            (id_paciente3, 
        id_espacio_medico2,
         'Cardíaca', 
            'Bypass Coronario', 
            'Cirugía para redirigir la sangre alrededor de una arteria coronaria bloqueada o parcialmente bloqueada.',
            'Alto', 
            '2024-07-15 08:00:00',
            'Paciente con antecedentes de enfermedad coronaria.', 
            'Valoración preoperatoria completa, riesgo elevado pero aceptable.', 
            'Programada', 
            'Bypass, Instrumental quirúrgico', 
            DEFAULT, 
            NOW()),
            (id_paciente4,
            id_espacio_medico3,
			'Neurológica', 
            'Resección de Tumor Cerebral', 
            'Cirugía para remover un tumor localizado en el lóbulo frontal del cerebro.',
            'Medio', 
            '2024-08-10 13:00:00',
            'Paciente con síntomas de presión intracraneal.', 
            'Valoración preoperatoria completa, paciente estable.', 
            'Programada', 
            'Instrumental neuroquirúrgico, Sistema de navegación', 
            DEFAULT,
            NOW());
            -- Actualizar datos
             UPDATE tbb_cirugias SET Estatus= 'Completada' WHERE ID = '1';
             UPDATE tbb_cirugias SET Estatus= 'Completada' WHERE ID = '2';
			-- Eliminación
            DELETE FROM tbb_cirugias WHERE ID = '4';
        ELSE
        SELECT "La contraseña es incorrecta, no puedo proceder con la inserción de registros" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_cirugias_personal_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_cirugias_personal_medico`(v_password VARCHAR(20))
BEGIN
    DECLARE id_personal_medico INT;
    DECLARE id_cirugia INT;
    DECLARE id_personal_medico1 INT;
    DECLARE id_cirugia1 INT;
    DECLARE id_personal_medico2 INT;
    DECLARE id_cirugia2 INT;

    

    IF v_password = "xyz#$localhost" THEN

        -- Obtener ID del personal médico usando la cédula
        SELECT Persona_ID INTO id_personal_medico
        FROM tbb_personal_medico
        WHERE Cedula_Profesional = '25515487';
		
        
        SELECT Persona_ID INTO id_personal_medico1
        FROM tbb_personal_medico
        WHERE Cedula_Profesional = '11422587'; 
		
        
        SELECT Persona_ID INTO id_personal_medico2
        FROM tbb_personal_medico
        WHERE Cedula_Profesional = '3256884';
        
        
        -- Obtener ID de la cirugía usando el nombre
        SELECT ID INTO id_cirugia
        FROM tbb_cirugias
        WHERE ID = '1';

        SELECT ID INTO id_cirugia1
        FROM tbb_cirugias
        WHERE ID = '2';

        SELECT ID INTO id_cirugia2
        FROM tbb_cirugias
        WHERE ID = '3';
        

        -- Insertar datos en tbd_cirugias_personal_medico
        INSERT INTO tbd_cirugias_personal_medico (
            Personal_Medico_ID, Cirugia_ID, Estatus, Fecha_Registro, Fecha_Actualizacion
        ) VALUES 
            (id_personal_medico, id_cirugia, b'1', DEFAULT, NOW()),
            (id_personal_medico1, id_cirugia1, b'1', DEFAULT, NOW()),
            (id_personal_medico2, id_cirugia2, b'1', DEFAULT, NOW());
            
            -- Actualizar datos
             UPDATE tbd_cirugias_personal_medico SET Estatus = 0  WHERE ID = '1';
             
			-- Eliminación
            DELETE FROM tbd_cirugias_personal_medico WHERE ID = '3';
        ELSE
        SELECT "La contraseña es incorrecta, no puedo proceder con la inserción de registros" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_citas_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_citas_medicas`(v_password VARCHAR(20))
BEGIN
	
	IF v_password = "1234" THEN
    
    
    
	INSERT INTO tbb_citas_medicas (Tipo, Paciente_ID, Personal_medico_ID, Servicio_Medico_ID,
    Espacio_ID, Fecha_Programada, Estatus, Observaciones)
	VALUES
	('Revisión',  5, 1,1, 3, '2024-08-15 10:00:00','Programada', 'Sin Observaciones'),
	('Diagnóstico',  5, 2,5, 3, '2024-07-18 10:20:00', 'En proceso','Sin Observaciones'),
	('Seguimiento', 6, 3, 1,5, '2024-06-30 11:00:00', 'Atendida',  'El paciente se encuentra estable'),
	('Revisión',  7, 3, 1,5, '2024-05-02 09:45:00', 'Cancelada','Sin Observaciones'),
    ('Diagnóstico', 7,3, 1, 6, '2024-07-01 09:00:00','Atendida', 
    'Se diagnosticó en el paciente una gripa estacionaria, se le asigno tratamiento.');
    
	UPDATE tbb_citas_medicas 
    SET Fecha_Programada = '2024-08-30 09:30:00', Estatus = "Reprogramada" WHERE ID = 1;
    
	DELETE FROM tbb_citas_medicas WHERE ID=4;
    
	ELSE
	SELECT "La contraseña es incorrecta, no puedo realizar la operación" AS ErrorMessage;
	END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_consumibles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_consumibles`(IN v_password VARCHAR(20))
BEGIN
    DECLARE v_estatus VARCHAR(20) DEFAULT 'Activo';
    
    IF v_password = 'xYz$123' THEN
        -- Insertar en la tabla tbc_consumibles
        INSERT INTO tbc_consumibles 
        (nombre, descripcion, tipo, departamento, cantidad_existencia, detalle, fecha_registro, fecha_actualizacion, estatus, observaciones, espacio_medico) 
        VALUES 
        ('Guantes', 'Guantes latex', 'Proteccion', 'Almacen', 500, 'Caja de 100 guantes', NOW(), NOW(), 1, 'Revisar antes de entrar', 'Emergencias'),
        ('Gasas', 'Gasas estériles', 'Material Médico', 'Almacen', 1000, 'Paquete de 50 gasas', NOW(), NOW(), 1, 'Mantener en ambiente seco', 'Urgencias'),
        ('Jeringas', 'Jeringas desechables', 'Material Médico', 'Almacen', 800, 'Caja de 100 jeringas', NOW(), NOW(), 1, 'Manipular con cuidado', 'Consultas Externas'),
        ('Vendas', 'Vendas elásticas', 'Material Médico', 'Almacen', 1200, 'Rollo de 10 metros', NOW(), NOW(), 1, 'Utilizar para vendajes compresivos', 'Emergencias'),
        ('Analgésico', 'Medicamento', 'Farmacia', 'Estantería A', 500, 'Tabletas para alivio del dolor moderado a severo', NOW(), NOW(), 1, 'Mantener en lugar fresco y seco', 'Consultas Externas');

        -- Actualizar un registro en la tabla tbc_consumibles
        UPDATE tbc_consumibles 
        SET cantidad_existencia = 600, fecha_actualizacion = NOW() 
        WHERE nombre = 'Guantes';

        -- Eliminar un registro en la tabla tbc_consumibles
        DELETE FROM tbc_consumibles 
        WHERE nombre = 'Analgésico';

        -- Determinar el estatus para la bitácora
    ELSE
        SELECT 'La contraseña es incorrecta' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_dispensacion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_dispensacion`(IN v_password VARCHAR(20))
BEGIN
    IF v_password = 'xYz$123' THEN
        -- Insertar registros predefinidos
        INSERT INTO tbd_dispensaciones 
            (RecetaMedica_id, PersonalMedico_id, Departamento_id, Solicitud_id, Estatus, Tipo, TotalMedicamentosEntregados, Total_costo, Fecha_registro)
            VALUES 
            (NULL, 2, 3, 4, 'Abastecida', 'Publica', 10, 100.00, NOW()),
            (2, 3, 4, NULL, 'Parcialmente abastecida', 'Privada', 5, 50.00, NOW());

        -- Actualizar un registro específico predefinido
        UPDATE tbd_dispensaciones
        SET Estatus = 'Parcialmente abastecida', 
            Tipo = 'Mixta', 
            TotalMedicamentosEntregados = 20, 
            Total_costo = 200.00
            WHERE id = 1;
        
        -- Eliminar un registro específico predefinido
        DELETE FROM tbd_dispensaciones 
        WHERE id = 2;
    
    ELSE
        SELECT 'La contraseña es incorrecta' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_espacios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_espacios`(v_password VARCHAR(20))
BEGIN
	DECLARE id_espacio_superior_1 INT DEFAULT 0;
    DECLARE id_espacio_superior_2 INT DEFAULT 0;
    IF v_password = "xYz$123" THEN
        -- Insertar varios registros en la tabla tbd_espacio
        
        
        -- INSERTAMOS EL EDIFICIO 1 - Medicina General
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Edificio', 'Medicina General',1 ,NULL,DEFAULT, DEFAULT);
        SET id_espacio_superior_1= last_insert_id();
		
        -- Espacios de Nivel 2 
       INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Piso', 'Planta Baja',56 ,id_espacio_superior_1,DEFAULT,DEFAULT);
        SET id_espacio_superior_2= last_insert_id();
        -- Espacios de Nivel 3
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Consultorio', 'A-101',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-102',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-103',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-104',17 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Consultorio', 'A-105',17 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Quirófano', 'A-106',16 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Quirófano', 'A-107',16 ,id_espacio_superior_2,DEFAULT, DEFAULT), 
        ('Sala de Espera', 'A-108',16 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Sala de Espera', 'A-109',16 ,id_espacio_superior_2,DEFAULT, DEFAULT);
           
             
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Piso', 'Planta Alta',56, id_espacio_superior_1,DEFAULT, DEFAULT);
        SET id_espacio_superior_2= last_insert_id();
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus) VALUES
        ('Habitación', 'A-201',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-202',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-203',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-204',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Habitación', 'A-205',11 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Laboratorio', 'A206',23 ,id_espacio_superior_2,DEFAULT, DEFAULT),
        ('Capilla', 'A-207',56 ,id_espacio_superior_2,DEFAULT, DEFAULT), 
        ('Recepción', 'A-208',1 ,id_espacio_superior_2,DEFAULT, DEFAULT);
        
        /*
        -- INSERTAMOS EL EDIFICIO 2 - Medicina de Especialidad
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Estatus, Capacidad, Espacio_Superior_ID) VALUES
        ('Oficina', 'Oficina Quirúrgica', 'Recursos Humanos', 'Activo', 10, 'Piso 3, Edificio Principal');
        -- INSERTAMOS EL EDFICIO 3 -  Areas Administrativas
        INSERT INTO tbc_espacios(Tipo, Nombre, Departamento_ID, Estatus, Capacidad, Espacio_Superior_ID) VALUES
        ('Oficina', 'Oficina Quirúrgica', 'Recursos Humanos', 'Activo', 10, 'Piso 3, Edificio Principal');
        */
      


        -- Realizar algunas actualizaciones o eliminaciones si es necesario
        UPDATE tbc_espacios SET Estatus= 'En remodelación' WHERE nombre = 'A-105';
        UPDATE tbc_espacios SET Capacidad = 80 WHERE nombre = 'A-109';
        
        DELETE FROM tbc_espacios WHERE nombre = 'A-207';
        

    ELSE
        SELECT "La contraseña es incorrecta, no puedo proceder con la inserción de registros" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_estudios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_estudios`(v_password VARCHAR(60))
BEGIN
	IF v_password="123" THEN
        -- Insertar datos en la tabla tbc_estudios
        INSERT INTO tbc_estudios (
            Tipo,
            Nivel_Urgencia,
            SolicitudID,
            ConsumiblesID,
            Estatus,
            Total_Costo,
            Dirigido_A,
            Observaciones,
            Fecha_Registro,
            Fecha_Actualizacion,
            ConsumibleID
        ) VALUES (
            'MRI',
            'Alta',
            23,
            12,
            'Completado',
            500.00,
            'Dr. Juan Pérez',
            'Resultados del primer estudio',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            2
        );
        
        INSERT INTO tbc_estudios (
            Tipo,
            Nivel_Urgencia,
            SolicitudID,
            ConsumiblesID,
            Estatus,
            Total_Costo,
            Dirigido_A,
            Observaciones,
            Fecha_Registro,
            Fecha_Actualizacion,
            ConsumibleID
        ) VALUES (
            'Ultrasonido',
            'Media',
            11,
            11,
            'Completado',
            300.00,
            'Dr. Ana Gómez',
            'Resultados del segundo estudio',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            11
        );

        -- Actualizar datos en la tabla tbc_estudios
        UPDATE tbc_estudios 
        SET 
            Tipo = 'Ecografía',
            Nivel_Urgencia = 'Baja',
            SolicitudID = 12,
            ConsumiblesID = 459,
            Estatus = 'Completado',
            Total_Costo = 180.00,
            Dirigido_A = 'Dr. Laura Martínez',
            Observaciones = 'Sin observaciones',
            Fecha_Actualizacion = CURRENT_TIMESTAMP,
            ConsumibleID = 793
        WHERE 
            ID = 1;

        -- Eliminar datos de la tabla tbc_estudios
        DELETE FROM tbc_estudios 
        WHERE ID = 1;

    ELSE 
        SELECT "La contraseña es incorrecta, no se puede realizar modificación en la tabla Resultados Estudios" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_expedientes_clinicos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_expedientes_clinicos`(v_password varchar(20))
BEGIN
	if v_password = "1234" then
		-- Primera Persona
		 INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		('Sra.', 'Laura', 'López', 'Martínez', 'LAMJ850302PDFRPL01', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL);
		-- Primero Expediente
		insert into tbd_expedientes_clinicos values(last_insert_id(),'Asma bronquial','Alergia a la penicilina','Alzheimer en abuelo materno','Todo bien','Gripe','Mas vitaminas',default, default, null);
        
        -- Segunda Persona
		INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		('C.', 'Danela', 'Sanchez', 'Ruiz', 'HERA900380HDFRIL01', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL);
		-- Segundo Expediente
        insert into tbd_expedientes_clinicos values(last_insert_id(),'Hipertensión arterial','Cirugía de apéndice a los 12 años.','Enfermedad cardíaca coronaria en padre y tíos paternos.','Frecuencia Cardiaca baja','Sano','Hidratarse más',default, default, null);

		-- Tercer Persona
        INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		('Dr.', 'Juan', 'Alinis', 'Rodríguez', 'GARC950404NDTRRL06', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL);
		-- Tercer Expediente
        insert into tbd_expedientes_clinicos values(last_insert_id(),'Hepatitis B previa','Historial de viajes a países tropicales','Cáncer colorrectal en primo hermano','Frecuencia Reepiratoria baja','En buenas condiciones','Necesita mas actividad fisica',default, default, null);

		-- Cuarta Persona
		INSERT INTO tbb_personas 
		(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
		VALUES
		('Lic.', 'Yaret', 'Martínez', 'Gómez', 'YALG000505TDFRRL07', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL);
		-- Cuarto Expediente
        insert into tbd_expedientes_clinicos values(last_insert_id(),'Artritis reumatoide','Ausencia de alergias conocidas a medicamentos.','Asma en hermano menor.','Presion baja','Salud Optima','No come bien',default, default, null);


		update tbd_expedientes_clinicos set Notas_Medicas = 'Necesita paracetamol' where Interrogatorio_sistemas = 'Presion baja';
		update tbd_expedientes_clinicos set estatus = b'0' where Interrogatorio_sistemas = 'Frecuencia Reepiratoria baja';
			
		delete from tbd_expedientes_clinicos where Interrogatorio_sistemas = 'Frecuencia Cardiaca baja';
		else
			select "La contraseña es incorrecta, no puedo mostrarte el estatus de la Base de Datos" as ErrorMessage;
		end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_lotes_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_lotes_medicamentos`(v_password VARCHAR(20))
BEGIN
	IF v_password = "xYz$123" THEN
        -- Insertar registros en la tabla tbd_lotes_medicamentos
        INSERT INTO tbd_lotes_medicamentos (Medicamento_ID, Personal_Medico_ID, Clave, Estatus, Costo_Total, Cantidad, Ubicacion)
        VALUES
        (1, 101, 'ABC123', 'Reservado', 100.00, 10, 'Almacen A'),
        (2, 102, 'DEF456', 'En transito', 200.00, 20, 'Almacen B'),
        (3, 103, 'GHI789', 'Recibido', 300.00, 30, 'Almacen C');
        -- (4, 104, 'JKL012', 'Rechazado', 400.00, 40, 'Almacen D'),
        -- (5, 105, 'MNO345', 'Reservado', 500.00, 50, 'Almacen E');

        -- Actualización 1
        UPDATE tbd_lotes_medicamentos 
        SET Estatus = 'Rechazado', Ubicacion = 'Almacén W' 
        WHERE ID = 2;

        -- Actualización 2
        UPDATE tbd_lotes_medicamentos 
        SET Estatus = 'Reservado', Cantidad = 15 
        WHERE ID = 3;

        -- Eliminación
        DELETE FROM tbd_lotes_medicamentos 
        WHERE ID = 3;

    ELSE
        SELECT "La contraseña es incorrecta, no puedo mostrarte el estatus de llenado de la Base de datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_medicamentos`(IN v_password VARCHAR(20))
BEGIN
 IF v_password = 'xYz$123' THEN
  -- Inserción de cinco registros reales
    INSERT INTO tbc_medicamentos (Nombre_comercial, Nombre_generico, Via_administracion, Presentacion, Tipo, Cantidad, Volumen)
    VALUES
    ('Tylenol', 'Paracetamol', 'Oral', 'Comprimidos', 'Analgesicos', 100, 0.0),
    ('Amoxil', 'Amoxicilina', 'Oral', 'Capsulas', 'Antibioticos', 50, 0.0),
    ('Zoloft', 'Sertralina', 'Oral', 'Comprimidos', 'Antidepresivos', 200, 0.0),
    ('Claritin', 'Loratadina', 'Oral', 'Grageas', 'Antihistaminicos', 150, 0.0),
    ('Advil', 'Ibuprofeno', 'Oral', 'Comprimidos', 'Antiinflamatorios', 300, 0.0);

    -- Actualización de uno de los registros
    UPDATE tbc_medicamentos
    SET Cantidad = 120, Volumen = 10.0, Fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE Nombre_comercial = 'Tylenol';

    -- Eliminación de uno de los registros
    DELETE FROM tbc_medicamentos
    WHERE Nombre_comercial = 'Amoxil';
  END IF;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_nacimientos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_nacimientos`(v_password varchar(20))
BEGIN
	IF v_password = "1234" THEN
	insert into tbb_nacimientos values 
	(default, 'Juan Pérez', 'María Gómez', '80-120', b'1', 8, 'Observaciones aquí', 'M', NOW(), NULL),
	(default, 'Antonio López', 'Laura Martínez', '80-120', b'1', 8, 'Observaciones adicionales aquí', 'F', NOW(), NULL),
	(default, 'Carlos Rodríguez', 'Ana Sánchez', '80-120', b'1', 9, 'Observaciones adicionales aquí', 'M', NOW(), NULL),
	(default, 'Juan García', 'Carmen Ruiz', '80-120', b'1', 8, 'Observaciones adicionales aquí', 'F', NOW(), NULL),
	(default, 'Pedro López', 'Marta Pérez', '80-120', b'1', 7, 'Observaciones adicionales aquí', 'M', NOW(), NULL);

	update tbb_nacimientos set Padre = "Juan Pérez", Madre = "Claudia Sheinbaun" where Madre = "María Gómez";

	delete from tbb_nacimientos where Padre = "Pedro López";

ELSE
	select "La contraseña es incorrecta, no puedo mostrarte los nacimientos de la base de datos"  AS ErrorMessage;
END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_organos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_organos`(
    IN p_password VARCHAR(255)
)
BEGIN
DECLARE v_correct_password VARCHAR(255) DEFAULT 'xYz$123';
    
    -- Verificamos la contraseña
    IF p_password = v_correct_password THEN
        
        -- Insertar registros de prueba
        INSERT INTO tbc_organos ( Nombre, Aparato_Sistema, Descripcion, Detalle_Organo_ID, Disponibilidad, Tipo, Fecha_Registro, Estatus)
        VALUES 
            ( 'Cerebro', 'Nervioso', 'Órgano principal del sistema nervioso.', 1, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ( 'Corazón', 'Cardiovascular', 'Órgano muscular que bombea sangre a través del sistema circulatorio.', 2, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ('Pulmón', 'Respiratorio', 'Órgano que permite la oxigenación de la sangre.', 3, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ( 'Hígado', 'Digestivo', 'Órgano que procesa nutrientes y desintoxica sustancias.', 4, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1'),
            ( 'Riñón', 'Urinario', 'Órgano que filtra desechos de la sangre y produce orina.', 5, 'Disponible', 'Órgano Principal', CURRENT_TIMESTAMP(), b'1');
    
    ELSE
        -- Si la contraseña no es correcta, lanzamos un error
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_pacientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_pacientes`(v_password varchar(10))
    DETERMINISTIC
BEGIN
IF v_password = "1234" then		
-- Insertamos los datos de la persona del primer paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Sra.', 'María', 'López', 'Martínez', 'LOMJ850202MDFRPL01', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),NULL,'Sin Seguro','2009-03-17 17:31:00',default,'Vivo',1,'2001-02-15 06:23:05',NULL);
-- Insertamos los datos de la persona del segundo paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
(NULL, 'Ana', 'Hernández', 'Ruiz', 'HERA900303HDFRRL01', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),NULL,'Sin Seguro','2019-05-01 13:15:29',default,'Vivo',1,'2020-06-28 18:46:37',NULL);
-- Insertamos los datos de la persona del tercer paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Dr.', 'Carlos', 'García', 'Rodríguez', 'GARC950404HDFRRL06', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),'G9OA6QW29V8DVXS','Seguro Popular','2024-02-16 13:10:48',default,'Vivo',1,'2024-02-18 16:05:14',NULL);
-- Insertamos los datos de la persona del cuarto paciente
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Lic.', 'Laura', 'Martínez', 'Gómez', 'MALG000505MDFRRL07', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL);
INSERT INTO `tbb_pacientes` VALUES (last_insert_id(),"12254185844-3",'Particular','2022-08-16 12:05:35',default,'Vivo',1,'2022-08-16 11:50:00',NULL);

update tbb_pacientes set NSS = "JL4HVKXPI3PX999" where NSS = "G9OA6QW29V8DVXS";
delete from tbb_pacientes where NSS = "JL4HVKXPI3PX999";
    
    
    else
		select "La contraseña es incorrecta" as mensaje;
        end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_personal_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_personal_medico`(v_password varchar(20))
BEGIN
    IF v_password = 'xyz#$localhost' THEN
    
    START TRANSACTION;
    
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
        INSERT INTO tbb_personas (titulo, nombre, primer_apellido, segundo_apellido, curp, genero, grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro)
        VALUES ("Dr.", "Alejandro", "Barrera", "Fernández", "BAFA810525HVZLRR05", "M", "O+", "1981-05-25", 1, NOW());
        
        -- Insertamos los datos médicos del empleado
        INSERT INTO tbb_personal_medico (persona_id, departamento_id, cedula_profesional, tipo, especialidad, fecha_registro, fecha_contratacion, salario, estatus)
        VALUES (LAST_INSERT_ID(), 13, "25515487", "Médico", "Pediatría", NOW(), "2015-09-16 09:10:52", 35000, "Activo");
        
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
        INSERT INTO tbb_personas (titulo, nombre, primer_apellido, segundo_apellido, curp, genero, grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro)
        VALUES ("Dra.", "María José", "Álvarez", "Fonseca", "ALFM900620MPLLNR2A", "F", "O-", "1990-06-20", 1, NOW());
        
        -- Insertamos los datos médicos del empleado
        INSERT INTO tbb_personal_medico (persona_id, departamento_id, cedula_profesional, tipo, especialidad, fecha_registro, fecha_contratacion, salario, estatus)
        VALUES (LAST_INSERT_ID(), 11, "11422587", "Médico", NULL, NOW(), "2018-05-10 09:10:52", 10000, "Activo");
        
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
        INSERT INTO tbb_personas (titulo, nombre, primer_apellido, segundo_apellido, curp, genero, grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro)
        VALUES ("Dr.", "Alfredo", "Carrasco", "Lechuga", "CALA710115HCSRCL25", "M", "AB-", "1971-01-15", 1, NOW());
        
        -- Insertamos los datos médicos del empleado
        INSERT INTO tbb_personal_medico (persona_id, departamento_id, cedula_profesional, tipo, especialidad, fecha_registro, fecha_contratacion, salario, estatus)
        VALUES (LAST_INSERT_ID(), 1, "3256884", "Administrativo", NULL, NOW(), "2000-01-02 09:00:00", 40000, "Activo");
        
        -- Inserta los datos de la persona antes de sus datos cómo empleado del Hospital
        INSERT INTO tbb_personas (titulo, nombre, primer_apellido, segundo_apellido, curp, genero, grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro)
        VALUES ("Lic.", "Fernanda", "García", "Méndez", "ABCD", "N/B", "A+", "1995-05-10", 1, NOW());
        
        -- Insertamos los datos médicos del empleado
        INSERT INTO tbb_personal_medico (persona_id, departamento_id, cedula_profesional, tipo, especialidad, fecha_registro, fecha_contratacion, salario, estatus)
        VALUES (LAST_INSERT_ID(), 9, "1458817", "Apoyo", NULL, NOW(), "2008-01-02 19:00:00", 8000, "Activo");
        
        -- Actualizamos el salario del director general
        UPDATE tbb_personal_medico 
        SET salario = 45000 
        WHERE cedula_profesional = "3256884";
         
        -- Eliminamos a un empleado
        DELETE FROM tbb_personal_medico 
        WHERE cedula_profesional = "1458817";
    
    COMMIT;
    
    ELSE
        -- Mensaje de error si la contraseña es incorrecta
        SELECT "La contraseña es incorrecta, no puedo insertar datos en la Base de Datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_personas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_personas`(v_password varchar(20))
BEGIN
if v_password="1234" then
INSERT INTO tbb_personas 
(Titulo, Nombre, Primer_Apellido, Segundo_Apellido, CURP, Genero, Grupo_Sanguineo, Fecha_Nacimiento, Estatus, Fecha_Registro, Fecha_Actualizacion)
VALUES
('Sra.', 'María', 'López', 'Martínez', 'LOMJ850202MDFRPL02', 'F', 'A+', '1985-02-02', b'1', NOW(), NULL),
('C.', 'Ana', 'Hernández', 'Ruiz', 'HERA900303HDFRRL03', 'F', 'B+', '1990-03-03', b'1', NOW(), NULL),
('Dr.', 'Carlos', 'García', 'Rodríguez', 'GARC950404HDFRRL04', 'M', 'AB+', '1995-04-04', b'1', NOW(), NULL),
('Lic.', 'Laura', 'Martínez', 'Gómez', 'MALG000505MDFRRL05', 'F', 'O-', '2000-05-05', b'1', NOW(), NULL),
('C.', 'Luis', 'Pérez', 'Sánchez', 'PESL010606HDFRRL06', 'M', 'A-', '2001-06-06', b'1', NOW(), NULL),
('C.', 'Mónica', 'López', 'Hernández', 'LOHM020707MDFRRL07', 'F', 'B-', '2002-07-07', b'1', NOW(), NULL),
('C.', 'Pedro', 'Gómez', 'Pérez', 'GOPP030808HDFRRL08', 'M', 'AB-', '2003-08-08', b'1', NOW(), NULL),
('C.', 'Sofía', 'Ruiz', 'López', 'RULS040909HDFRRL09', 'F', 'O+', '2004-09-09', b'1', NOW(), NULL),
('C.', 'José', 'Sánchez', 'García', 'SAGJ051010HDFRRL10', 'M', 'A+', '2005-10-10', b'1', NOW(), NULL);

UPDATE tbb_personas SET Primer_Apellido = 'Hernández', Estatus = b'0' WHERE ID = 1;

DELETE FROM tbb_personas where ID=2;
	 else
		select "La contraseña es incorrecta, no puedo mostrar el estatus de la Base de Datos" As ErrorMessage;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_puestos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_puestos`(IN v_password VARCHAR(20))
BEGIN
    IF v_password = '1234' THEN
        -- Insertar puestos en la tabla tbc_puestos
        INSERT INTO tbc_puestos (Nombre, Descripcion, Salario, Turno, Creado, Modificado) VALUES 
        ('Médicos', 'Profesionales médicos que diagnostican y tratan a los pacientes', 5000.00, 'Mañana', NOW(), NOW()),
        ('Enfermeras', 'Proporcionan cuidados directos a los pacientes', 3000.00, 'Tarde', NOW(), NOW()),
        ('Técnicos de laboratorio', 'Realizan análisis clínicos y pruebas de laboratorio', 2500.00, 'Mañana', NOW(), NOW()),
        ('Técnicos radiológicos', 'Realizan estudios por imágenes como radiografías y resonancias', 2600.00, 'Tarde', NOW(), NOW()),
        ('Técnicos de farmacia', 'Ayudan en la dispensación y gestión de medicamentos', 2400.00, 'Mañana', NOW(), NOW()),
        ('Asistentes médicos', 'Apoyan a los médicos en consultas y procedimientos', 2800.00, 'Mañana', NOW(), NOW()),
        ('Personal administrativo', 'Gestiona tareas administrativas y de recepción', 2200.00, 'Mañana', NOW(), NOW()),
        ('Personal de limpieza', 'Mantiene la limpieza y el orden en las instalaciones', 1800.00, 'Noche', NOW(), NOW()),
        ('Terapeutas ocupacionales', 'Ayudan a pacientes a recuperar habilidades para la vida diaria', 2700.00, 'Mañana', NOW(), NOW()),
        ('Fisioterapeutas', 'Realizan terapias físicas para la rehabilitación de pacientes', 2800.00, 'Tarde', NOW(), NOW()),
        ('Logopedas', 'Especializados en trastornos del habla y lenguaje', 2600.00, 'Mañana', NOW(), NOW()),
        ('Administradores de salud', 'Gestionan operaciones y recursos en el ámbito de la salud', 3500.00, 'Tarde', NOW(), NOW()),
        ('Cocineros', 'Preparan comidas nutritivas para pacientes y personal', 2000.00, 'Mañana', NOW(), NOW()),
        ('Dietistas', 'Planifican dietas personalizadas según necesidades de los pacientes', 2300.00, 'Tarde', NOW(), NOW()),
        ('Personal de seguridad', 'Garantizan la seguridad y el orden dentro del hospital', 2100.00, 'Noche', NOW(), NOW()),
        ('Personal de mantenimiento', 'Realizan mantenimiento preventivo y correctivo de instalaciones', 1900.00, 'Tarde', NOW(), NOW()),
        ('Investigadores médicos', 'Conductores de investigación clínica y científica', 3800.00, 'Mañana', NOW(), NOW()), -- Cambiado a 'Mañana'
        ('Educadores médicos', 'Imparten conocimientos y formación a profesionales de la salud', 3200.00, 'Mañana', NOW(), NOW()),
        ('Voluntarios', 'Ofrecen su tiempo y servicios de manera voluntaria', 0.00, 'Noche', NOW(), NOW());

        -- Actualizar un puesto específico
        -- Ejemplo: Actualizar el salario del puesto con nombre 'Médicos'
        UPDATE tbc_puestos
        SET Salario = 5200.00, Modificado = NOW()
        WHERE Nombre = 'Médicos';

        -- Eliminar un puesto específico
        -- Ejemplo: Eliminar el puesto con nombre 'Educadores médicos'
        DELETE FROM tbc_puestos
        WHERE Nombre = 'Educadores médicos';
    ELSE
        SELECT "La contraseña es incorrecta, no puedo mostrar el estatus de la Base de Datos" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_puestos_departamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_puestos_departamentos`(IN v_password VARCHAR(20))
BEGIN
    IF v_password = '1234' THEN
        -- Inserción de cinco registros reales
        INSERT INTO tbd_puestos_departamentos (Nombre, Descripcion, Salario, Turno, DepartamentoID)
        VALUES
        ('Medico General', 'Responsable de consultas generales', 50000.00, 'Mañana', 1),
        ('Enfermero', 'Responsable de cuidado de pacientes', 30000.00, 'Tarde', 2),
        ('Cirujano', 'Responsable de realizar cirugías', 70000.00, 'Noche', 3),
        ('Pediatra', 'Especialista en cuidado de niños', 55000.00, 'Mañana', 1),
        ('Radiologo', 'Responsable de estudios de imagen', 60000.00, 'Tarde', 4);

        -- Actualización de uno de los registros
        UPDATE tbd_puestos_departamentos
        SET Salario = 52000.00, Modificado = CURRENT_TIMESTAMP
        WHERE Nombre = 'Medico General';

        -- Eliminación de uno de los registros
        DELETE FROM tbd_puestos_departamentos
        WHERE Nombre = 'Enfermero';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_recetas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_recetas`(v_password varchar(20))
BEGIN
IF v_password = "141002" THEN
	SET SQL_SAFE_UPDATES = 0;

	delete from tbd_recetas_medicas;
	alter table tbd_recetas_medicas auto_increment = 1;
	INSERT INTO tbd_recetas_medicas VALUES 
	(1,'Juan Pérez',
    35, 'Dr. García',
    '2024-06-06', '2024-06-06',
    'Gripe común', 'Paracetamol, Ibuprofeno',
    'Tomar una tableta de Paracetamol cada 6 horas y una tableta de Ibuprofeno cada 8 horas durante 3 días.'),
    (2,'Mario López',
    55, 'Dr. Goku',
    '2024-05-04', '2024-06-06',
    'Hipertensión arterial', 'Losartán, Amlodipino', 
    'Tomar una tableta de Losartán y una tableta de Amlodipino diariamente antes del desayuno.'),
	(3,
    'María López', 45, 
    'Dr. Martínez', 
    '2024-06-05', '2024-06-06', 
    'Hipertensión arterial', 'Losartán, Amlodipino', 
    'Tomar una tableta de Losartán y una tableta de Amlodipino diariamente antes del desayuno.'),
    (4,
    'Yair Tolentino', 21, 
    'Dr. Jesus', 
    '2024-06-05', '2024-06-06', 
    'Sindrome de Dawn', 'Ibuprofeno, Aspirinas', 
    'Tomar una tableta de aspirina y una tableta de ibuprofeno antes de dormir'),
    (5,
	 'Ana García', 30,
	 'Dr. Rodríguez',
	 '2024-06-10', '2024-06-10',
	 'Infección de garganta',
	 'Amoxicilina, Ibuprofeno',
	 'Tomar una tableta de Amoxicilina cada 8 horas y una tableta de Ibuprofeno cada 6 horas durante 5 días.'),
	(6,
	 'Pedro Ramírez', 40,
	 'Dr. Gómez',
	 '2024-06-12', '2024-06-12',
	 'Diabetes tipo 2',
	 'Metformina, Glibenclamida',
	 'Tomar una tableta de Metformina y una tableta de Glibenclamida antes de cada comida principal.'),
	(7,
	 'Luisa Martínez', 50,
	 'Dr. Sánchez',
	 '2024-06-14', '2024-06-14',
	 'Osteoartritis',
	 'Paracetamol, Meloxicam',
	 'Tomar una tableta de Paracetamol cada 6 horas y una tableta de Meloxicam diariamente.'),
	(8,
	 'Carlos Hernández', 60,
	 'Dr. Pérez',
	 '2024-06-15', '2024-06-15',
	 'Dolor de espalda crónico',
	 'Ibuprofeno, Naproxeno',
	 'Tomar una tableta de Ibuprofeno cada 8 horas y una tableta de Naproxeno cada 12 horas.'),
	(9,
	 'Laura Ramírez', 25,
	 'Dr. Díaz',
	 '2024-06-16', '2024-06-16',
	 'Migraña',
	 'Sumatriptán, Paracetamol',
	 'Tomar una tableta de Sumatriptán al inicio de la migraña y una tableta de Paracetamol cada 6 horas si persiste el dolor.'),
	(10,
	 'Javier Pérez', 48,
	 'Dr. Ramírez',
	 '2024-06-18', '2024-06-18',
	 'Gastritis crónica',
	 'Omeprazol, Ranitidina',
	 'Tomar una cápsula de Omeprazol antes del desayuno y una tableta de Ranitidina antes de la cena.');
		
    
	UPDATE tbd_recetas_medicas SET paciente_nombre = 'Pedro González' WHERE id = 1;
    UPDATE tbd_recetas_medicas SET paciente_nombre = 'Marvin Perez' WHERE id = 2;
	UPDATE tbd_recetas_medicas SET medicamentos = 'Marihuanol, Clonazepan', diagnostico ='VIH' WHERE id = 2;
	UPDATE tbd_recetas_medicas SET indicaciones = 'Reposo' WHERE id = 3;
    UPDATE tbd_recetas_medicas SET medicamentos = 'Clonazepan, inyeccion letal', diagnostico ='VIH' WHERE id = 4;
    
		
	delete from tbd_recetas_medicas where id= 1;
    
else
	select "La contraseña es incorrecta"  AS ErrorMessage;
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_resultados_estudios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_resultados_estudios`(v_password VARCHAR(60))
BEGIN
IF v_password="xYz$123" THEN
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (23, 12, 2, '1234', 'Resultados del primer estudio', 'Observaciones', 'Completado');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (11, 11, 11, '12444', 'Resultados del segundo estudio', 'Observaciones', 'Completado');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (8, 15, 5, '5678', 'Resultados del tercer estudio', 'Observaciones', 'Pendiente');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (17, 10, 3, '98765', 'Resultados del cuarto estudio', 'Observaciones', 'En Proceso');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (9, 18, 8, '555', 'Resultados del quinto estudio', 'Observaciones', 'Aprobado');
        INSERT INTO tbd_resultados_estudios (Paciente_ID, Personal_Medico_ID, Estudio_ID, Folio, Resultados, Observaciones, Estatus)
        VALUES (14, 9, 7, '777', 'Resultados del sexto estudio', 'Observaciones', 'Rechazado');


UPDATE  tbd_resultados_estudios set Paciente_ID=12, Observaciones='Sin observaciones' where ID=1;
UPDATE  tbd_resultados_estudios set Paciente_ID=24, Observaciones='Sin observaciones' where ID=3;

delete from tbd_resultados_estudios where ID=1;

ELSE 
SELECT "La contraseña es incorrecta, no se puede realizar modificacion en la tabla Resultados Estudios" AS ErrorMessage;
end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_roles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_roles`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
		
		INSERT INTO tbc_roles VALUES (default, 'Admin', 'Usuario Administrador del Sistema que permitira modificar datos críticos', default, default, null),
        (default, 'Direccion General', 'Usuario de la Máxima Autoridad del Hospital, que le permitirá acceder a módulos para el control y operacion del servicio del Hospital', default, default, null),
        (default, 'Paciente', 'Usuario que tendra acceso a consultar la información médica asociada a su salud', default, default, null),
        (default, 'Médico General', 'Usuario que tendra acceso a consultar y modificar la información de salud de los pacientes y sus citas médicas', default, default, null),
        (default, 'Médico Especialista', 'Usuario que tendrá a acceso consultar y modificar la información de salud de los pacientes específicos a una especialidad médica', default, default, null),
        (default, 'Enfermero', 'Usuario que apoya en la gestión y desarrollo de los servicios médico proporcionados a los pacientes.', default, default, null), 
        (default, 'Familiar del Paciente', 'Usuario que puede consultar, y verificar la información de un paciente en caso de que no este en capacidad o conciencia propia', default, default, null),
        (default, 'Paciente IMSS', 'Este usuario es de prueba para testear el borrado en bitacora', default, default, null),
        (default, 'Administrativo', 'Empleado que apoya en las actividades de cada departamento', default, default, null);
        UPDATE tbc_roles SET nombre = 'Administrador' WHERE nombre = 'Admin';
        UPDATE tbc_roles set estatus = b'0' where nombre = 'Familiar del Paciente';
        
        DELETE FROM tbc_roles WHERE nombre= "Paciente IMSS";
        
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_roles_usuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_roles_usuarios`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
		
		INSERT INTO tbd_usuarios_roles (usuario_id, rol_id)
        VALUES 
        (1,4),(1,1), (2,3), (3,6) , (5,3), (5,6);
		
        UPDATE tbd_usuarios_roles SET rol_id = 5 WHERE usuario_id =1 and rol_id= 4; 
        DELETE FROM tbd_usuarios_roles WHERE usuario_id=5 and rol_id=6;
        
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_servicios_medicos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_servicios_medicos`(v_password VARCHAR(20))
BEGIN
 IF v_password = "1234" THEN
        -- Insertar nuevos registros en tbc_servicio_medico
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Consulta Médica General', 'Revisión general del paciente por parte de un médico autorizado', 'Horario de Atención de 08:00 a 20:00');

        -- Se asignan los servicios al departamento que los brinda
        INSERT INTO tbd_departamentos_servicios VALUES
        (17, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT, NULL),
        (40, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT, NULL);
		
        
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Consulta Médica Especializada', 'Revisión médica de especialidad', 'Previa cita, asignada despúes de una revisión general');
        
         -- Se asignan los servicios al departamento que los brinda
        INSERT INTO tbd_departamentos_servicios VALUES
        (10, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (11, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (12, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (14, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (15, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
        
		
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Consulta Médica a Domicilio', 'Revision médica en el domicilio del paciente', 'Solo para casos de extrema urgencia');
        
		INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
		VALUES ('Examen Físico Completo', 'Examen detallado de salud física del paciente', 'Asistir con ropa lijera y 6 a 8 de horas
        de ayuno previo');

		INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
		VALUES ('Extracción de Sangre', 'Toma de muestra para análisis de sangre', 'Ayuno previo, muestras antes de las 10:00 a.m.');
        
        -- Se agrega un nuevo servicio medico
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Parto Natural', 'Asistencia en el proceso de alumbramiento de un bebé', 'Sin observaciones');
        -- Asignamos el departamento que brinda ese servicio.
        INSERT INTO tbd_departamentos_servicios VALUES
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (14, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
               
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Estudio de Desarrollo Infantil', 'Valoración de Crecimiento del Infante', 'Mediciones de Talla, Peso y Nutrición');
        INSERT INTO tbd_departamentos_servicios VALUES
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
        
        INSERT INTO tbc_servicios_medicos (nombre, descripcion, observaciones)
        VALUES ('Toma de Signos Vitales', 'Registro de Talla, Peso, Temperatura, Oxigenación en la Sangre , Frecuencia Cardiaca 
        (Sistólica y  Diastólica, Frecuencia Respiratoria', 'Necesarias para cualquier servicio médico.');
        INSERT INTO tbd_departamentos_servicios VALUES
        (13, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL), 
        (14, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (12, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (25, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL),
        (23, last_insert_id(), "Ayuno previo de 1 hr.", "Sin restricciones", DEFAULT, DEFAULT,NULL);
        
        DELETE FROM tbd_departamentos_servicios WHERE departamento_id=25;
        UPDATE tbd_departamentos_servicios SET Estatus=b'0' WHERE departamento_id=23;
        
        
        
        

        -- Actualizar un registro en tbc_servicio_medico
        UPDATE tbc_servicios_medicos 
        SET nombre="Estudio de Química Sanguínea" WHERE nombre='Extracción de Sangre';
        
        -- Eliminar un registro en tbc_servicio_medico
        DELETE FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica a Domicilio';
        
        
        
        

    ELSE 
        SELECT "La contraseña es incorrecta, no se puede realizar modificación en la tabla Servicio Medico" AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_solicitudes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_solicitudes`(v_password VARCHAR(10))
BEGIN
    IF v_password = 'xYz$123' THEN
    
        INSERT INTO tbd_solicitudes (Paciente_ID, Medico_ID, Servicio_ID, Prioridad, Descripcion, Estatus, Estatus_Aprobacion, Fecha_Registro, Fecha_Actualizacion)
        VALUES 
        (5, 1, 1, 'Moderada', 'Revisión médica anual para monitorear mi salud general.', 'Registrada', b'1', DEFAULT, NULL),
        (6, 1, 2, 'Emergente', 'Tratamiento médico para mejorar mi bienestar.', 'Programada', b'1', DEFAULT, NULL),
        (6, 2, 2, 'Alta', 'Consulta especializada para manejar una condición específica.', 'Reprogramada', b'1', DEFAULT, NULL),
        (5, 3, 4, 'Normal', 'Revisión mensual para monitorear mi condición cardiaca.', 'En Proceso', b'1', DEFAULT, NULL),
        (7, 3, 5, 'Urgente', 'Revisión médica para ver mis niveles de salud.', 'Realizada', b'1', DEFAULT, NULL);

        -- Actualizar registros existentes
        UPDATE tbd_solicitudes SET Prioridad = 'Normal' WHERE ID = 1;
        UPDATE tbd_solicitudes SET Estatus = 'Cancelada' WHERE ID = 2;

        -- Eliminar un registro específico
        DELETE FROM tbd_solicitudes WHERE ID = 5;
    ELSE
        SELECT 'La contraseña es incorrecta, no puede mostrar el estatus de la Base de Datos' AS ErrorMessage;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_usuarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_usuarios`(v_password VARCHAR(20))
BEGIN  
	
    IF v_password = "xYz$123" THEN
		
		INSERT INTO tbb_usuarios 
        VALUES 
        (DEFAULT, 1, "marco.rahe", "marco.rahe@hotmail.com", "qwerty123", "(+52) 764 100 17 25", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 2, "juan.perez", "j.perez@hotmail.com", "mipass", "(+52) 555 553 19 32", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 3, "patito25", "patricia.reyes@hospitalito.mx", "gest#2235", "(+52) 222 235 44 01", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 4, "liliana99", "lili.santamaria@privilegecare.com", "dasT8832", "(+52) 778 145 22 87", DEFAULT, DEFAULT, NULL),
        (DEFAULT, 5, "hugo.vera", "solnanov_hugo@gmail.com", "12345", "(+52) 758 98 16 32", DEFAULT, DEFAULT, NULL);
        
	
        UPDATE tbb_usuarios SET correo_electronico= "marco.rahe@gmail.com" WHERE nombre_usuario="marco.rahe";
        UPDATE tbb_usuarios SET estatus= "Bloqueado" WHERE correo_electronico="j.perez@hotmail.com";
        UPDATE tbb_usuarios SET estatus= "Suspendido" WHERE nombre_usuario="hugo.vera";
        
        DELETE FROM tbb_usuarios WHERE nombre_usuario="liliana99";
        
        
        
        
    ELSE 
      SELECT "La contraseña es incorrecta, no puedo mostrarte el 
      estatus de la Base de Datos" AS ErrorMessage;
    
    END IF;
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_poblar_valoraciones_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_poblar_valoraciones_medicas`(v_password varchar(20))
BEGIN
IF v_password = "hola123" THEN
	




INSERT INTO tbb_valoraciones_medicas (
	id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES (1, 1,'2024-06-06','Sin antecedentes personales relevantes', 'Madre con diabetes tipo 2',
    'Hipertensión arterial diagnosticada hace 5 años', 'Dolor abdominal, náuseas', 'Abdomen distendido, signo de Murphy positivo', 'Ecografía abdominal',
    'Colecistitis aguda', 'Colecistectomía laparoscópica programada', 'Control postoperatorio en una semana');

INSERT INTO tbb_valoraciones_medicas (
	id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES (2, 2, '2024-06-07', 'Fumador ocasional', 'Padre con hipertensión', 'Asma diagnosticada en la infancia',
    'Tos persistente, dificultad para respirar', 'Sibilancias en ambos campos pulmonares', 'Espirometría', 'Asma bronquial', 'Tratamiento con broncodilatadores',
    'Revisión en dos semanas');

INSERT INTO tbb_valoraciones_medicas (
    id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES(3, 3, '2024-06-07', 'Deportista regular, sin antecedentes de tabaquismo', 'Madre con osteoporosis',
    'Ninguno', 'Dolor en la rodilla derecha al correr', 'Inflamación en la rodilla derecha', 'Radiografía de rodilla', 'Tendinitis rotuliana', 'Fisioterapia y antiinflamatorios',
    'Revisión en un mes');

INSERT INTO tbb_valoraciones_medicas (
id, paciente_id, fecha, antecedentes_personales, antecedentes_familiares, antecedentes_medicos, sintomas_signos, examen_fisico, pruebas_diagnosticas,
    diagnostico, plan_tratamiento, seguimiento) VALUES (4, 4, '2024-06-07', 'Alergia a los mariscos', 'Hermano con asma', 'Alergias estacionales',
    'Erupción cutánea y picazón después de comer mariscos', 'Erupciones eritematosas en brazos y piernas', 'Pruebas de alergia cutánea', 'Alergia alimentaria a mariscos',
    'Antihistamínicos y evitar mariscos', 'Revisión en tres meses');

UPDATE tbb_valoraciones_medicas
SET plan_tratamiento = 'Nuevo plan de tratamiento'
WHERE id = 1;


DELETE FROM tbb_valoraciones_medicas
WHERE paciente_id = 1;



ELSE
	select "La contraseña es incorrecta, no puedo mostrarte el estatus de la base de datos"  AS ErrorMessage;
END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_Populate_AllData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_Populate_AllData`()
BEGIN

	
    -- 1. Catálogos base
    SELECT 'Inicio: Población de roles' AS paso;
    CALL sp_populate_roles();
    
    SELECT 'Poblacion de medicamentos' AS paso;
    CALL sp_populate_medicamentos();
    
    SELECT 'Población de usuarios y personas' AS paso;
    CALL SP_InsertaUsuariosPersonasAuto();
    
    SELECT 'Población de áreas médicas' AS paso;
    CALL sp_populate_areas_medicas();
    
    SELECT 'Población de departamentos' AS paso;
    CALL sp_populate_departamentos();
    
    SELECT 'Población de espacios' AS paso;
    CALL sp_populate_espacios();
    
    SELECT 'Población de servicios médicos' AS paso;
    CALL sp_populate_servicios_medicos();

    -- 2. Personas, usuarios y roles (repetido, ¿intencional?)
    SELECT 'Segunda pasada: usuarios y personas' AS paso;
    CALL SP_InsertaUsuariosPersonasAuto();

    -- 3. Personal médico
    SELECT 'Población de personal médico' AS paso;
    CALL sp_populate_personal_medico(FLOOR(20 + RAND() * 40));

    -- 4. Asignar responsables
    SELECT 'Asignación de responsables a departamentos' AS paso;
    CALL sp_asigna_responsables_departamentos();

    -- 5. Pacientes
    SELECT 'Población de pacientes' AS paso;
    CALL sp_populate_pacientes();

    -- 6. Citas médicas
    SELECT 'Población de citas médicas' AS paso;
    CALL sp_populate_citas_medicas(FLOOR(20 + RAND() * 40));

    SELECT 'FIN DEL PROCEDIMIENTO' AS paso;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_areas_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_areas_medicas`()
BEGIN
    -- Insertar áreas médicas usando la función personalizada
    CALL fn_insert_area_medica_si_no_existe('Servicios Medicos', 'Por definir', 'SM');
    CALL fn_insert_area_medica_si_no_existe('Servicios de Apoyo', 'Por definir', 'SA');
    CALL fn_insert_area_medica_si_no_existe('Servicios Medico - Administrativos', 'Por definir', 'SMA');
    CALL fn_insert_area_medica_si_no_existe('Servicios de Enfermeria', 'Por definir', 'SE');
    CALL fn_insert_area_medica_si_no_existe('Departamentos Administrativos', 'Por definir', 'DA');
    CALL fn_insert_area_medica_si_no_existe('Nueva Área Médica', 'Por definir', 'NAM');

    -- Actualizar y eliminar si existen
    IF EXISTS (SELECT 1 FROM tbc_areas_medicas WHERE Nombre = 'Nueva Área Médica') THEN
        UPDATE tbc_areas_medicas
        SET Estatus = 'Inactivo'
        WHERE Nombre = 'Nueva Área Médica';

        DELETE FROM tbc_areas_medicas
        WHERE Nombre = 'Nueva Área Médica';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_citas_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_citas_medicas`(IN num_registros INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_medico_id CHAR(36);
    DECLARE v_paciente_id CHAR(36);
    DECLARE v_servicio_id CHAR(36);
    DECLARE v_espacio_id CHAR(36);
    DECLARE v_observacion TEXT;
    DECLARE v_tipo_cita VARCHAR(30);
    DECLARE v_estatus VARCHAR(30);
    DECLARE v_rand DECIMAL(5,4);
    DECLARE v_fecha_programada DATETIME;
    DECLARE v_fecha_inicio DATETIME;
    DECLARE v_fecha_termino DATETIME;

    WHILE i < num_registros DO
        -- 1. Seleccionar datos aleatorios válidos
        SELECT ID INTO v_medico_id
        FROM tbb_personal_medico
        ORDER BY RAND()
        LIMIT 1;

        SELECT Persona_ID INTO v_paciente_id
        FROM tbb_pacientes
        ORDER BY RAND()
        LIMIT 1;

        SELECT ID INTO v_servicio_id
        FROM tbc_servicios_medicos
        ORDER BY RAND()
        LIMIT 1;

        SELECT ID INTO v_espacio_id
        FROM tbc_espacios
        ORDER BY RAND()
        LIMIT 1;

        -- 2. Tipo de cita (distribución realista)
        SET v_rand = RAND();
        SET v_tipo_cita = CASE
            WHEN v_rand <= 0.30 THEN 'Revisión'
            WHEN v_rand <= 0.55 THEN 'Diagnóstico'
            WHEN v_rand <= 0.70 THEN 'Tratamiento'
            WHEN v_rand <= 0.80 THEN 'Rehabilitación'
            WHEN v_rand <= 0.85 THEN 'Preoperatoria'
            WHEN v_rand <= 0.90 THEN 'Postoperatoria'
            WHEN v_rand <= 0.95 THEN 'Proceminientos'
            ELSE 'Seguimiento'
        END;

        -- 3. Estatus
        SET v_rand = RAND();
        SET v_estatus = CASE
            WHEN v_rand <= 0.60 THEN 'Programada'
            WHEN v_rand <= 0.70 THEN 'EnProceso'
            WHEN v_rand <= 0.85 THEN 'Atendida'
            WHEN v_rand <= 0.90 THEN 'Reprogramada'
            WHEN v_rand <= 0.95 THEN 'Cancelada'
            ELSE 'No Atendida'
        END;

        -- 4. Fechas
        IF v_estatus IN ('Programada', 'Reprogramada') THEN
            SET v_fecha_programada = NOW() + INTERVAL FLOOR(RAND() * 15) DAY;
        ELSEIF v_estatus IN ('Atendida', 'EnProceso', 'No Atendida') THEN
            SET v_fecha_programada = NOW() - INTERVAL FLOOR(RAND() * 7) DAY;
        ELSEIF v_estatus = 'Cancelada' THEN
            SET v_fecha_programada = NOW() + INTERVAL FLOOR(RAND() * 10 - 5) DAY;
        END IF;

        SET v_fecha_inicio = v_fecha_programada + INTERVAL (30 + FLOOR(RAND() * 15)) MINUTE;
        SET v_fecha_termino = v_fecha_inicio + INTERVAL (60 + FLOOR(RAND() * 15)) MINUTE;

        -- 5. Observaciones
        SET v_observacion = fn_observacion_por_servicio(v_servicio_id, v_tipo_cita);

        -- 6. Insertar
        INSERT INTO tbb_citas_medicas (
            ID,
            Personal_Medico_ID,
            Paciente_ID,
            Servicio_Medico_ID,
            Folio,
            Tipo,
            Espacio_ID,
            Fecha_Programada,
            Fecha_Inicio,
            Fecha_Termino,
            Observaciones,
            Estatus,
            Fecha_Registro,
            Fecha_Actualizacion
        )
        VALUES (
            UUID(),
            v_medico_id,
            v_paciente_id,
            v_servicio_id,
            CONCAT('FOLIO-', LPAD(FLOOR(RAND() * 100000), 5, '0')),
            v_tipo_cita,
            v_espacio_id,
            v_fecha_programada,
            v_fecha_inicio,
            v_fecha_termino,
            v_observacion,
            v_estatus,
            NOW(),
            NOW()
        );

        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_departamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER="root"@"localhost" PROCEDURE "sp_populate_departamentos"()
BEGIN
    DECLARE v_resp_medico CHAR(36) DEFAULT NULL;
    DECLARE v_resp_enfermero CHAR(36) DEFAULT NULL;

    -- 1) Crear tabla temporal con abreviatura
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_departments (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        department_name VARCHAR(100),
        parent_name     VARCHAR(100),
        area_name       VARCHAR(150),
        abreviatura     VARCHAR(20)
    ) ENGINE = InnoDB;

    -- 2) Limpiar tabla temporal
    TRUNCATE tmp_departments;

    -- 3) Insertar jerarquía base con abreviaturas
   INSERT INTO tmp_departments (department_name, parent_name, area_name, abreviatura)
VALUES
    ('Dirección General', NULL, 'Servicios Medico - Administrativos', 'DG'),
    ('Junta de Gobierno', 'Dirección General', 'Servicios Medico - Administrativos', 'JG'),
    ('Departamento de Calidad', 'Dirección General', 'Servicios Medico - Administrativos', 'DC'),
    ('Comité de Transplante', 'Dirección General', 'Servicios Medico - Administrativos', 'CT'),
    ('Sub-Dirección Médica', 'Dirección General', 'Servicios Medico - Administrativos', 'SM'),
    ('Sub-Dirección Administrativa', 'Dirección General', 'Servicios Medico - Administrativos', 'SA'),
    ('Comités Hospitalarios', 'Dirección General', 'Servicios Medico - Administrativos', 'CH'),
    ('Atención a Quejas', 'Dirección General', 'Servicios Medico - Administrativos', 'AQ'),
    ('Seguridad del Paciente', 'Dirección General', 'Servicios Medico - Administrativos', 'SP'),
    ('Comunicación Social', 'Dirección General', 'Servicios Medico - Administrativos', 'CS'),
    ('Relaciones Públicas', 'Dirección General', 'Servicios Medico - Administrativos', 'RP'),
    ('Coordinación de Asuntos Jurídicos y Administrativos', 'Dirección General', 'Servicios Medico - Administrativos', 'CAJAA'),
    ('Violencia Intrafamiliar', 'Dirección General', 'Servicios Medico - Administrativos', 'VI'),
    ('Medicinal Legal', 'Dirección General', 'Servicios Medico - Administrativos', 'ML'),
    ('Trabajo Social', 'Dirección General', 'Servicios Medico - Administrativos', 'TS'),
    ('Unidad de Vigilancia Epidemiológica Hospitalaria', 'Dirección General', 'Servicios Medico - Administrativos', 'UVEH'),
    ('Centro de Investigación de Estudios de la Salud', 'Dirección General', 'Servicios Medico - Administrativos', 'CIES'),
    ('Ética e Investigación', 'Dirección General', 'Servicios Medico - Administrativos', 'EI'),
    ('División de Medicina Interna', 'Sub-Dirección Médica', 'Servicios Médicos', 'DMI'),
    ('División de Cirugía', 'Sub-Dirección Médica', 'Servicios Médicos', 'DCI'),
    ('División de Pediatría', 'Sub-Dirección Médica', 'Servicios Médicos', 'DP'),
    ('Servicio de Urgencias Adultos', 'Sub-Dirección Médica', 'Servicios Médicos', 'SUA'),
    ('Servicio de Urgencias Pediátricas', 'Sub-Dirección Médica', 'Servicios Médicos', 'SUP'),
    ('Terapia Intensiva', 'Sub-Dirección Médica', 'Servicios Médicos', 'TI'),
    ('Terapia Intermedia', 'Sub-Dirección Médica', 'Servicios Médicos', 'TIM'),
    ('Quirófano y Anestesiología', 'Sub-Dirección Médica', 'Servicios Médicos', 'QA'),
    ('Servicio de Traumatología', 'Sub-Dirección Médica', 'Servicios Médicos', 'ST'),
    ('Programación Quirúrgica', 'Sub-Dirección Médica', 'Servicios Médicos', 'PQ'),
    ('Centro de Mezclas', 'Sub-Dirección Médica', 'Servicios Médicos', 'CM'),
    ('Radiología e Imagen', 'Sub-Dirección Médica', 'Servicios Médicos', 'RI'),
    ('Genética', 'Sub-Dirección Médica', 'Servicios Médicos', 'G'),
    ('Laboratorio de Análisis Clínicos', 'Sub-Dirección Médica', 'Servicios Médicos', 'LAC'),
    ('Laboratorio de Histocompatibilidad', 'Sub-Dirección Médica', 'Servicios Médicos', 'LH'),
    ('Hemodialisis', 'Sub-Dirección Médica', 'Servicios Médicos', 'H'),
    ('Laboratorio de Patología', 'Sub-Dirección Médica', 'Servicios Médicos', 'LP'),
    ('Rehabilitación Pulmonar', 'Sub-Dirección Médica', 'Servicios Médicos', 'RPUL'),
    ('Medicina Genómica', 'Sub-Dirección Médica', 'Servicios Médicos', 'MG'),
    ('Banco de Sangre', 'Sub-Dirección Médica', 'Servicios Médicos', 'BS'),
    ('Aféresis', 'Sub-Dirección Médica', 'Servicios Médicos', 'AF'),
    ('Tele-Robótica', 'Sub-Dirección Médica', 'Servicios Médicos', 'TR'),
    ('Jefatura de Enseñanza Médica', 'Sub-Dirección Médica', 'Servicios Médicos', 'JEM'),
    ('Consulta Externa', 'Sub-Dirección Médica', 'Servicios Médicos', 'CE'),
    ('Terapia y Rehabilitación Física', 'Sub-Dirección Médica', 'Servicios Médicos', 'TRF'),
    ('Jefatura de Enfermería', 'Sub-Dirección Médica', 'Servicios de Enfermería', 'JE'),
    ('Subjefatura de Enfermeras', 'Jefatura de Enfermería', 'Servicios de Enfermería', 'SE'),
    ('Coordinación Enseñanza Enfermería', 'Jefatura de Enfermería', 'Servicios de Enfermería', 'CEE'),
    ('Supervisoras de Turno', 'Jefatura de Enfermería', 'Servicios de Enfermería', 'STUR'),
    ('Jefas de Servicio', 'Jefatura de Enfermería', 'Servicios de Enfermería', 'JS'),
    ('Clínicas y Programas', 'Jefatura de Enfermería', 'Servicios de Enfermería', 'CP'),
    ('Recursos Humanos', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'RH'),
    ('Archivo y Correspondencia', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'AC'),
    ('Recursos Financieros', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'RF'),
    ('Departamento Administrativo Hemodinamia', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'DAH'),
    ('Farmacia del Seguro Popular', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'FSP'),
    ('Enlace Administrativo', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'EA'),
    ('Control de Gastos Catastróficos', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'CGC'),
    ('Informática', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'INF'),
    ('Tecnología en la Salud', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'TS'),
    ('Registros Médicos', 'Sub-Dirección Administrativa', 'Departamentos Administrativos', 'RM'),
    ('Biomédica Conservación y Mantenimiento', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'BCM'),
    ('Validación', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'VAL'),
    ('Recursos Materiales', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'RMAT'),
    ('Almacén', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'ALM'),
    ('Insumos Especializados', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'IE'),
    ('Servicios Generales', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'SG'),
    ('Intendencia', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'INT'),
    ('Ropería', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'ROP'),
    ('Vigilancia', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'VIG'),
    ('Dietética', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'DIE'),
    ('Farmacia Intrahospitalaria', 'Sub-Dirección Administrativa', 'Servicios de Apoyo', 'FIH');

    -- 4) Obtener responsables
    SELECT id INTO v_resp_medico
    FROM tbb_personal_medico
    WHERE tipo COLLATE utf8mb4_general_ci IN ('Médico', 'Médico Especialista')
    ORDER BY RAND()
    LIMIT 1;

    SELECT id INTO v_resp_enfermero
    FROM tbb_personal_medico
    WHERE tipo COLLATE utf8mb4_general_ci = 'Enfermero'
    ORDER BY RAND()
    LIMIT 1;

    -- 5) Insertar departamentos
    INSERT INTO tbc_departamentos (
        ID,
        Nombre,
        area_medica_id,
        Estatus,
        Fecha_Registro,
        Fecha_Actualizacion,
        Responsable_ID,
        Abreviatura
    )
    SELECT 
        UUID(),
        tmp.department_name,
        (
            SELECT a.ID 
            FROM tbc_areas_medicas a 
            WHERE a.Nombre = tmp.area_name 
            LIMIT 1
        ),
        b'1',
        NOW(),
        NOW(),
        CASE 
            WHEN tmp.area_name = 'Servicios de Enfermería' THEN v_resp_enfermero
            WHEN tmp.area_name IN ('Departamentos Administrativos', 'Servicios de Apoyo') THEN NULL
            ELSE v_resp_medico
        END,
        tmp.abreviatura
    FROM tmp_departments tmp
    WHERE NOT EXISTS (
        SELECT 1 FROM tbc_departamentos d WHERE d.Nombre = tmp.department_name
    );

    -- 6) Actualizar jerarquía
    UPDATE tbc_departamentos d
    JOIN tmp_departments tmp ON d.Nombre = tmp.department_name
    LEFT JOIN tbc_departamentos d_parent ON d_parent.Nombre = tmp.parent_name
    SET d.departamento_superior_ID = d_parent.ID;

    -- 7) Mostrar resultado
    SELECT * FROM tbc_departamentos ORDER BY departamento_superior_ID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_espacios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_espacios`()
BEGIN
    DECLARE id_espacio_superior_1 CHAR(36);
    DECLARE id_espacio_superior_2 CHAR(36);

    -- Variables para departamentos
    DECLARE dep_dir_gral CHAR(36);
    DECLARE dep_consulta_externa CHAR(36);
    DECLARE dep_quirurgico CHAR(36);
    DECLARE dep_pediatria CHAR(36);
    DECLARE dep_laboratorio CHAR(36);
    DECLARE dep_serv_generales CHAR(36);

    -- Obtener IDs de los departamentos
    SELECT ID INTO dep_dir_gral 
    FROM tbc_departamentos 
    WHERE Nombre = 'Dirección General' LIMIT 1;

    SELECT ID INTO dep_consulta_externa 
    FROM tbc_departamentos 
    WHERE Nombre = 'Consulta Externa' LIMIT 1;

    SELECT ID INTO dep_quirurgico 
    FROM tbc_departamentos 
    WHERE Nombre = 'Quirófano y Anestesiología' LIMIT 1;

    SELECT ID INTO dep_pediatria 
    FROM tbc_departamentos 
    WHERE Nombre = 'División de Pediatría' LIMIT 1;

    SELECT ID INTO dep_laboratorio 
    FROM tbc_departamentos 
    WHERE Nombre = 'Laboratorio de Análisis Clínicos' LIMIT 1;

    SELECT ID INTO dep_serv_generales 
    FROM tbc_departamentos 
    WHERE Nombre = 'Servicios Generales' LIMIT 1;

    -- Validación
    IF dep_dir_gral IS NULL OR dep_consulta_externa IS NULL OR dep_quirurgico IS NULL 
       OR dep_pediatria IS NULL OR dep_laboratorio IS NULL OR dep_serv_generales IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uno o más departamentos requeridos para espacios no existen.';
    END IF;

    -- Edificio principal
    IF NOT EXISTS (SELECT 1 FROM tbc_espacios WHERE Nombre = 'Medicina General') THEN
        SET id_espacio_superior_1 = UUID();
        INSERT INTO tbc_espacios(ID, Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus)
        VALUES (id_espacio_superior_1, 'Edificio', 'Medicina General', dep_dir_gral, NULL, DEFAULT, DEFAULT);
    ELSE
        SELECT ID INTO id_espacio_superior_1 
        FROM tbc_espacios 
        WHERE Nombre = 'Medicina General' 
        LIMIT 1;
    END IF;

    -- Planta Baja
    IF NOT EXISTS (SELECT 1 FROM tbc_espacios WHERE Nombre = 'Planta Baja') THEN
        SET id_espacio_superior_2 = UUID();
        INSERT INTO tbc_espacios(ID, Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus)
        VALUES (id_espacio_superior_2, 'Piso', 'Planta Baja', dep_serv_generales, id_espacio_superior_1, DEFAULT, DEFAULT);
    ELSE
        SELECT ID INTO id_espacio_superior_2 
        FROM tbc_espacios 
        WHERE Nombre = 'Planta Baja' 
        LIMIT 1;
    END IF;

    -- Insertar espacios (planta baja)
    CALL fn_insert_espacio_si_no_existe('A-101', 'Consultorio', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-102', 'Consultorio', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-103', 'Consultorio', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-104', 'Consultorio', dep_pediatria, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-105', 'Consultorio', dep_pediatria, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-106', 'Quirófano', dep_quirurgico, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-107', 'Quirófano', dep_quirurgico, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-108', 'Sala de Espera', dep_quirurgico, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-109', 'Sala de Espera', dep_quirurgico, id_espacio_superior_2);

    -- Planta Alta
    IF NOT EXISTS (SELECT 1 FROM tbc_espacios WHERE Nombre = 'Planta Alta') THEN
        SET id_espacio_superior_2 = UUID();
        INSERT INTO tbc_espacios(ID, Tipo, Nombre, Departamento_ID, Espacio_Superior_ID, Capacidad, Estatus)
        VALUES (id_espacio_superior_2, 'Piso', 'Planta Alta', dep_serv_generales, id_espacio_superior_1, DEFAULT, DEFAULT);
    ELSE
        SELECT ID INTO id_espacio_superior_2 
        FROM tbc_espacios 
        WHERE Nombre = 'Planta Alta' 
        LIMIT 1;
    END IF;

    -- Insertar espacios (planta alta)
    CALL fn_insert_espacio_si_no_existe('A-201', 'Habitación', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-202', 'Habitación', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-203', 'Habitación', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-204', 'Habitación', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-205', 'Habitación', dep_consulta_externa, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A206', 'Laboratorio', dep_laboratorio, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-207', 'Capilla', dep_serv_generales, id_espacio_superior_2);
    CALL fn_insert_espacio_si_no_existe('A-208', 'Recepción', dep_dir_gral, id_espacio_superior_2);

    -- Actualizaciones condicionales
    IF EXISTS (SELECT 1 FROM tbc_espacios WHERE Nombre = 'A-105') THEN
        UPDATE tbc_espacios SET Estatus = 'En remodelación' WHERE Nombre = 'A-105';
    END IF;

    IF EXISTS (SELECT 1 FROM tbc_espacios WHERE Nombre = 'A-109') THEN
        UPDATE tbc_espacios SET Capacidad = 80 WHERE Nombre = 'A-109';
    END IF;

    -- Eliminación condicional
    IF EXISTS (SELECT 1 FROM tbc_espacios WHERE Nombre = 'A-207') THEN
        DELETE FROM tbc_espacios WHERE Nombre = 'A-207';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_medicamentos`()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 100 DO
        INSERT INTO tbc_medicamentos (
            ID,
            Nombre_comercial,
            Nombre_generico,
            Via_administracion,
            Presentacion,
            Tipo,
            Cantidad,
            Volumen,
            Fecha_registro,
            Fecha_actualizacion
        )
        VALUES (
            UUID(),

            -- NOMBRE COMERCIAL (50 elementos)
            ELT(FLOOR(1 + RAND() * 50),
                'Dolocare','Neurovax','Calmex','Fluzen','BioGrip','Alerfast','Cardion','Respiral','Cefamax','Dermosol',
                'Flexiren','Otifen','Colrivin','Glucoryn','Nexocil','Panovix','Sinudex','Virelin','Zynotal','Optirex',
                'Tridazol','Myotrin','Clarigen','Gastrovid','Endozol','Rhinoclear','Dolfenac','Mycosten','Levopril','Thyroplus',
                'Pulmocort','Antioxin','Renalgin','Hepamax','Diurexel','Dermaclin','Neurocalm','Broncolin','Zentran','Fibromed',
                'Inmunocell','Antaliv','Cardiliv','Anxion','Oflaxin','Glicovance','Menozol','Cortimax','Tramalex','Tazocil'),

            -- NOMBRE GENÉRICO (50 elementos)
            ELT(FLOOR(1 + RAND() * 50),
                'Paracetamol','Amoxicilina','Loratadina','Ibuprofeno','Metformina','Omeprazol','Clorfenamina','Salbutamol','Diclofenaco','Cetirizina',
                'Naproxeno','Azitromicina','Sertralina','Fluoxetina','Ranitidina','Acetaminofén','Dexametasona','Ciprofloxacino','Diazepam','Furosemida',
                'Amlodipino','Levotiroxina','Prednisona','Tramadol','Aciclovir','Enalapril','Losartan','Hidroxicloroquina','Hidrocortisona','Alprazolam',
                'Lorazepam','Meloxicam','Mebendazol','Norfloxacino','Clindamicina','Metronidazol','Nitazoxanida','Eritromicina','Gabapentina','Ketorolaco',
                'Valproato','Famotidina','Rosuvastatina','Atorvastatina','Espironolactona','Fluconazol','Domperidona','Risperidona','Levodopa','Montelukast'),

            -- VÍA
            ELT(FLOOR(1 + RAND() * 10), 
                'Oral', 'Intravenoso', 'Rectal', 'Cutaneo', 'Subcutaneo', 
                'Oftalmica', 'Otica', 'Nasal', 'Topica', 'Parental'),

            -- PRESENTACIÓN
            ELT(FLOOR(1 + RAND() * 10), 
                'Comprimidos', 'Grageas', 'Capsulas', 'Jarabes', 'Gotas', 
                'Solucion', 'Pomada', 'Jabon', 'Supositorios', 'Viales'),

            -- TIPO
            ELT(FLOOR(1 + RAND() * 6), 
                'Analgesicos', 'Antibioticos', 'Antidepresivos', 
                'Antihistaminicos', 'Antiinflamatorios', 'Antipsicoticos'),

            FLOOR(5 + RAND() * 100),
            ROUND(5 + (RAND() * 100), 2),
            NOW(),
            NOW()
        );
        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_pacientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_pacientes`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE persona_id_aux CHAR(36);

    -- Cursor para recorrer los Persona_ID con rol de Paciente y no insertados aún
    DECLARE cur CURSOR FOR
        SELECT u.Persona_ID
        FROM tbb_usuarios u
        JOIN tbd_usuarios_roles ur ON ur.Usuario_ID = u.ID
        JOIN tbc_roles r ON r.ID = ur.Rol_ID
        WHERE r.Nombre = 'Paciente'
          AND u.Persona_ID IS NOT NULL
          AND u.Persona_ID NOT IN (SELECT Persona_ID FROM tbb_pacientes);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO persona_id_aux;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO tbb_pacientes (
            Persona_ID, NSS, Tipo_Seguro, Fecha_Ultima_Cita, Estatus_Medico, Estatus_Vida, Estatus, Fecha_Registro, Fecha_Actualizacion
        )
        VALUES (
            persona_id_aux,
            LPAD(FLOOR(RAND() * 999999999999999), 15, '0'),
            (SELECT ELT(FLOOR(1 + (RAND() * 3)), 'IMSS', 'ISSSTE', 'Privado')),
            NOW() - INTERVAL FLOOR(RAND() * 365) DAY,
            (SELECT ELT(FLOOR(1 + (RAND() * 5)), 'Normal', 'Hipertenso', 'Diabético', 'Cardiópata', 'Otra condición médica')),
            'Vivo',
            BINARY 1,
            NOW(),
            NOW()
        );

    END LOOP;

    CLOSE cur;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_personal_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_personal_medico`(
    IN p_cantidad INT
)
BEGIN
    DECLARE v_usuarioID CHAR(36);
    DECLARE v_personaID CHAR(36);
    DECLARE v_role VARCHAR(50);
    DECLARE v_tipo_personal VARCHAR(20);
    DECLARE v_Departamento_ID CHAR(36);
    DECLARE v_Cedula VARCHAR(100);
    DECLARE v_Fecha_Contratacion DATE;
    DECLARE v_Salario DECIMAL(10,2);
    DECLARE v_Especialidad VARCHAR(255);
    DECLARE done INT DEFAULT 0;
    DECLARE inserted_count INT DEFAULT 0;

    -- Cursor: ahora unimos tbb_usuarios con tbb_personas para obtener p.ID como la persona real
    DECLARE cur CURSOR FOR
       SELECT 
           u.ID AS UsuarioID,
           p.ID AS PersonaRealID,
           r.Nombre AS RoleName
       FROM tbb_usuarios u
       JOIN tbb_personas p ON p.ID = u.Persona_ID  -- Asegúrate que esta relación sea la correcta
       JOIN tbd_usuarios_roles ur ON u.ID = ur.Usuario_ID
       JOIN tbc_roles r ON ur.Rol_ID = r.ID
       WHERE r.Nombre IN ('Médico General', 'Médico Especialista', 'Enfermero');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_usuarioID, v_personaID, v_role; 
        -- v_personaID ahora es p.ID (la persona real)
        
        IF done THEN LEAVE read_loop; END IF;
        IF inserted_count >= p_cantidad THEN LEAVE read_loop; END IF;

        -- Determinar el tipo de personal según el rol obtenido
        IF v_role IN ('Médico General', 'Médico Especialista') THEN
            SET v_tipo_personal = 'Médico';
            SET v_Especialidad = ELT(FLOOR(1 + RAND()*4),
              'Cardiología',
              'Pediatría',
              'Gastroenterología',
              'Traumatología'
            );

            SELECT ID INTO v_Departamento_ID
            FROM tbc_departamentos
            WHERE Nombre IN (
              'División de Medicina Interna',
              'División de Cirugía',
              'División de Pediatría',
              'Servicio de Urgencias Adultos',
              'Servicio de Urgencias Pediátricas',
              'Terapia Intensiva',
              'Terapia Intermedia',
              'Quirófano y Anestesiología',
              'Servicio de Traumatología',
              'Programación Quirúrgica',
              'Centro de Mezclas',
              'Radiología e Imagen',
              'Genética',
              'Laboratorio de Análisis Clínicos',
              'Laboratorio de Histocompatibilidad',
              'Hemodialisis',
              'Laboratorio de Patología',
              'Rehabilitación Pulmonar',
              'Medicina Genómica',
              'Banco de Sangre',
              'Aféresis',
              'Tele-Robótica',
              'Jefatura de Enseñanza Médica',
              'Consulta Externa',
              'Terapia y Rehabilitación Física'
            )
            ORDER BY RAND()
            LIMIT 1;

        ELSEIF v_role = 'Enfermero' THEN
            SET v_tipo_personal = 'Enfermero';
            SET v_Especialidad = NULL;
            SELECT ID INTO v_Departamento_ID
            FROM tbc_departamentos
            WHERE Nombre IN (
              'Jefatura de Enfermería',
              'Subjefatura de Enfermeras',
              'Coordinación Enseñanza Enfermería',
              'Supervisoras de Turno',
              'Jefas de Servicio',
              'Clínicas y Programas'
            )
            ORDER BY RAND()
            LIMIT 1;
        ELSE
            SET v_tipo_personal = 'Administrativo';
            SET v_Especialidad = NULL;
            SELECT ID INTO v_Departamento_ID
            FROM tbc_departamentos
            WHERE Nombre LIKE 'localhostAdministrativalocalhost'
               OR Nombre LIKE 'localhostApoyolocalhost'
               OR Nombre LIKE 'localhostRecursoslocalhost'
            ORDER BY RAND()
            LIMIT 1;
        END IF;

        -- Generar cédula, fecha de contratación y salario
        SET v_Cedula = fn_random_cedula();
        SET v_Fecha_Contratacion = fn_random_fecha_contratacion('2010-01-01', CURDATE());
        SET v_Salario = fn_random_salary(v_tipo_personal);

        -- Insertar registro en tbb_personal_medico
        INSERT INTO tbb_personal_medico (
           Persona_ID,
           Departamento_ID,
           Cedula_Profesional,
           Tipo,
           Especialidad,
           Fecha_Contratacion,
           Salario,
           Estatus,
           Fecha_Registro
        )
        VALUES (
           v_personaID,      -- v_personaID ahora es la persona real (p.ID)
           v_Departamento_ID,
           v_Cedula,
           v_tipo_personal,
           v_Especialidad,
           v_Fecha_Contratacion,
           v_Salario,
           'Activo',
           NOW()
        );

        SET inserted_count = inserted_count + 1;
    END LOOP;
    CLOSE cur;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_roles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_roles`()
BEGIN
    -- Insertar roles usando el helper
    CALL fn_insert_rol_si_no_existe('Admin', 'Usuario Administrador del Sistema que permitirá modificar datos críticos');
    CALL fn_insert_rol_si_no_existe('Direccion General', 'Usuario de la Máxima Autoridad del Hospital, que le permitirá acceder a módulos para el control y operación del servicio del Hospital');
    CALL fn_insert_rol_si_no_existe('Paciente', 'Usuario que tendrá acceso a consultar la información médica asociada a su salud');
    CALL fn_insert_rol_si_no_existe('Médico General', 'Usuario que tendrá acceso a consultar y modificar la información de salud de los pacientes y sus citas médicas');
    CALL fn_insert_rol_si_no_existe('Médico Especialista', 'Usuario que tendrá acceso a consultar y modificar la información de salud de los pacientes específicos a una especialidad médica');
    CALL fn_insert_rol_si_no_existe('Enfermero', 'Usuario que apoya en la gestión y desarrollo de los servicios médicos proporcionados a los pacientes.');
    CALL fn_insert_rol_si_no_existe('Familiar del Paciente', 'Usuario que puede consultar y verificar la información de un paciente en caso de que no esté en capacidad o conciencia propia');
    CALL fn_insert_rol_si_no_existe('Paciente IMSS', 'Este usuario es de prueba para testear el borrado en bitácora');
    CALL fn_insert_rol_si_no_existe('Administrativo', 'Empleado que apoya en las actividades de cada departamento');

    -- Actualizaciones y eliminaciones
    IF EXISTS (SELECT 1 FROM tbc_roles WHERE nombre = 'Admin') THEN
        UPDATE tbc_roles SET nombre = 'Administrador' WHERE nombre = 'Admin';
    END IF;

    IF EXISTS (SELECT 1 FROM tbc_roles WHERE nombre = 'Familiar del Paciente') THEN
        UPDATE tbc_roles SET estatus = b'0' WHERE nombre = 'Familiar del Paciente';
    END IF;

    IF EXISTS (SELECT 1 FROM tbc_roles WHERE nombre = 'Paciente IMSS') THEN
        DELETE FROM tbc_roles WHERE nombre = 'Paciente IMSS';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_populate_servicios_medicos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_populate_servicios_medicos`()
BEGIN
    DECLARE v_servicio_id CHAR(36);

    -- CONSULTA MÉDICA GENERAL
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica General') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Consulta Médica General', 
            'Revisión general del paciente por parte de un médico autorizado', 
            'Horario de Atención de 08:00 a 20:00'
        );
    END IF;

    -- CONSULTA MÉDICA ESPECIALIZADA
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica Especializada') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Consulta Médica Especializada', 
            'Revisión médica de especialidad', 
            'Previa cita, asignada después de una revisión general'
        );
    END IF;

    -- CONSULTA A DOMICILIO
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica a Domicilio') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Consulta Médica a Domicilio', 
            'Revisión médica en el domicilio del paciente', 
            'Solo para casos de extrema urgencia'
        );
    END IF;

    -- EXAMEN FÍSICO COMPLETO
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Examen Físico Completo') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Examen Físico Completo', 
            'Examen detallado de salud física del paciente', 
            'Asistir con ropa ligera y 6 a 8 horas de ayuno previo'
        );
    END IF;

    -- EXTRACCIÓN DE SANGRE
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Extracción de Sangre') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Extracción de Sangre', 
            'Toma de muestra para análisis de sangre', 
            'Ayuno previo, muestras antes de las 10:00 a.m.'
        );
    END IF;

    -- PARTO NATURAL
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Parto Natural') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Parto Natural', 
            'Asistencia en el proceso de alumbramiento de un bebé', 
            'Sin observaciones'
        );
    END IF;

    -- ESTUDIO DE DESARROLLO INFANTIL
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Estudio de Desarrollo Infantil') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Estudio de Desarrollo Infantil', 
            'Valoración de Crecimiento del Infante', 
            'Mediciones de Talla, Peso y Nutrición'
        );
    END IF;

    -- TOMA DE SIGNOS VITALES
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Toma de Signos Vitales') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos (ID, nombre, descripcion, observaciones)
        VALUES (
            v_servicio_id, 
            'Toma de Signos Vitales', 
            'Registro de signos vitales del paciente', 
            'Necesarias para cualquier servicio médico'
        );
    END IF;


    -- ELIMINAR SERVICIO: CONSULTA A DOMICILIO
    IF EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica a Domicilio') THEN
        DELETE FROM tbc_servicios_medicos WHERE nombre = 'Consulta Médica a Domicilio';
    END IF;
     -- NUEVOS SERVICIOS -------------------------------
    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Vacunación') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Vacunación', 'Aplicación de vacunas según calendario nacional', 'Llevar cartilla de vacunación', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Ultrasonido Abdominal') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Ultrasonido Abdominal', 'Estudio por ultrasonido del área abdominal', 'Ayuno de al menos 6 horas', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Radiografía de Tórax') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Radiografía de Tórax', 'Estudio radiográfico para evaluación pulmonar y torácica', 'Evitar joyas y prendas metálicas', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Control Prenatal') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Control Prenatal', 'Seguimiento médico durante el embarazo', 'Cita mensual según trimestre', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Atención Ginecológica') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Atención Ginecológica', 'Consulta con especialista en salud femenina', 'Revisión anual recomendada', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Control de Diabetes') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Control de Diabetes', 'Valoración y control de niveles de glucosa', 'Ayuno necesario para análisis', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Electrocardiograma') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Electrocardiograma', 'Estudio para registrar la actividad eléctrica del corazón', 'Evitar consumo de cafeína antes del estudio', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Revisión Oftalmológica') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Revisión Oftalmológica', 'Evaluación de la salud visual y ocular', 'Llevar lentes actuales si se usan', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Terapia Psicológica') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Terapia Psicológica', 'Atención psicológica para apoyo emocional y mental', 'Sesiones de 30 a 60 minutos', NOW(), NULL, b'1');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tbc_servicios_medicos WHERE nombre = 'Evaluación Nutricional') THEN
        SET v_servicio_id = UUID();
        INSERT INTO tbc_servicios_medicos VALUES (v_servicio_id, 'Evaluación Nutricional', 'Valoración del estado nutricional y recomendaciones', 'Ayuno no necesario', NOW(), NULL, b'1');
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_Populate_Usuarios_ConMultiplesRoles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER="root"@"localhost" PROCEDURE "SP_Populate_Usuarios_ConMultiplesRoles"(
    IN cantidad_usuarios INT,
    IN roles_lista TEXT,
    IN edad_minima INT,
    IN edad_maxima INT
)
BEGIN
    DECLARE v_rol_nombre VARCHAR(50);
    DECLARE v_rol_id CHAR(36);
    DECLARE v_persona_id CHAR(36);
    DECLARE v_nombre VARCHAR(80);
    DECLARE v_apellido VARCHAR(80);
    DECLARE v_segundo_apellido VARCHAR(80);
    DECLARE v_fecha_nac DATE;
    DECLARE v_genero VARCHAR(10);
    DECLARE v_curp VARCHAR(20);
    DECLARE v_grupo_sanguineo VARCHAR(5);
    DECLARE v_titulo VARCHAR(20);
    DECLARE v_username VARCHAR(60);
    DECLARE v_email VARCHAR(100);
    DECLARE v_contrasena VARCHAR(40);
    DECLARE v_telefono VARCHAR(20);
    DECLARE v_user_id CHAR(36);
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 1;
    DECLARE total_roles INT;

    SET total_roles = 1 + LENGTH(roles_lista) - LENGTH(REPLACE(roles_lista, ',', ''));

    WHILE i < cantidad_usuarios DO
        -- Generar datos de la persona
        SET v_persona_id = UUID();
        SET v_genero = ELT(FLOOR(1 + RAND() * 3), 'F', 'M', 'N/B');
        SET v_nombre = fn_genera_nombre_simple(v_genero);
        SET v_apellido = fn_genera_apellido(v_genero);
        SET v_segundo_apellido = fn_genera_apellido(v_genero);
		SET v_fecha_nac = fn_genera_fecha_nacimiento(
			DATE_SUB(CURDATE(), INTERVAL edad_maxima YEAR),
			DATE_SUB(CURDATE(), INTERVAL edad_minima YEAR)
		);
        SET v_curp = fn_genera_curp(v_nombre, v_apellido, v_segundo_apellido, v_fecha_nac, v_genero);
        SET v_grupo_sanguineo = fn_genera_grupo_sanguineo();
        SET v_titulo = fn_genera_titulo();

        INSERT INTO tbb_personas (
            ID, titulo, nombre, primer_apellido, segundo_apellido, curp, genero,
            grupo_sanguineo, fecha_nacimiento, estatus, fecha_registro
        ) VALUES (
            v_persona_id, v_titulo, v_nombre, v_apellido, v_segundo_apellido, v_curp, v_genero,
            v_grupo_sanguineo, v_fecha_nac, b'1', NOW()
        );

        -- Generar datos del usuario
        SET v_username = CONCAT(LOWER(v_nombre), '.', LOWER(v_apellido), FLOOR(100 + RAND() * 900));
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Nombre_Usuario = v_username) DO
            SET v_username = CONCAT(LOWER(v_nombre), '.', LOWER(v_apellido), FLOOR(100 + RAND() * 900));
        END WHILE;

        SET v_email = CONCAT(v_username, '@ejemplo.com');
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Correo_Electronico = v_email) DO
            SET v_email = CONCAT(v_username, FLOOR(10 + RAND() * 90), '@ejemplo.com');
        END WHILE;

        SET v_contrasena = SUBSTRING(MD5(RAND()), 1, 8);
        SET v_telefono = fn_genera_numero_telefonico();
        SET v_user_id = UUID();

        START TRANSACTION;

        INSERT INTO tbb_usuarios (
            ID, Persona_ID, Nombre_Usuario, Correo_Electronico, Contrasena,
            numero_telefonico_movil, Estatus, Fecha_Registro
        ) VALUES (
            v_user_id, v_persona_id, v_username, v_email, v_contrasena,
            v_telefono, 'Activo', NOW()
        );

        -- Asignar múltiples roles al usuario
        SET j = 1;
        WHILE j <= total_roles DO
            SET v_rol_nombre = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(roles_lista, ',', j), ',', -1));

            SELECT ID INTO v_rol_id FROM tbc_roles WHERE nombre = v_rol_nombre LIMIT 1;

            IF v_rol_id IS NOT NULL AND NOT EXISTS (
                SELECT 1 FROM tbd_usuarios_roles WHERE Usuario_ID = v_user_id AND Rol_ID = v_rol_id
            ) THEN
                INSERT INTO tbd_usuarios_roles (
                    Usuario_ID, Rol_ID, Estatus, Fecha_Registro
                ) VALUES (
                    v_user_id, v_rol_id, b'1', NOW()
                );
            END IF;

            SET j = j + 1;
        END WHILE;

        COMMIT;
        SET i = i + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_pupulate_persoanas_fijas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER="root"@"localhost" PROCEDURE "SP_pupulate_persoanas_fijas"()
BEGIN
    -- Declaraciones primero
    DECLARE done_custom INT DEFAULT 0;
    DECLARE c_nombre VARCHAR(80);
    DECLARE c_apellido VARCHAR(80);
    DECLARE c_fecha DATE;
    DECLARE c_rol_nombre VARCHAR(50);
    DECLARE c_persona_id CHAR(36);
    DECLARE c_user_id CHAR(36);
    DECLARE c_nombre_usuario VARCHAR(80);
    DECLARE c_correo VARCHAR(100);
    DECLARE c_contra VARCHAR(40);
    DECLARE c_telefono VARCHAR(20);
    DECLARE c_rol_id CHAR(36);

    DECLARE cur_custom CURSOR FOR 
        SELECT nombre, apellido, fecha_nacimiento, rol FROM tmp_fijas;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_custom = 1;

    -- Crear y poblar tabla temporal
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_fijas (
        nombre VARCHAR(80),
        apellido VARCHAR(80),
        fecha_nacimiento DATE,
        rol VARCHAR(50)
    );

    TRUNCATE TABLE tmp_fijas;

    INSERT INTO tmp_fijas (nombre, apellido, fecha_nacimiento, rol) VALUES
        ('Edgar', 'Cruz', '1988-03-12', 'Administrador'),
        ('Crito', 'Arias Reyes', '1990-07-20', 'Médico General'),
         ('Zacek', 'Gutierrez Cruz', '1988-03-12', 'Administrador'),
        ('RauL', 'Reyes Batalla', '1990-07-20', 'Médico General'),
        ('Cahici', 'Me gusta el pipi', '1990-07-20', 'Médico General'),
        ('Mota', 'Yo de doy el pipi', '1990-07-20', 'Médico General');

    --  Procesar cursor
    OPEN cur_custom;
    read_custom: LOOP
        FETCH cur_custom INTO c_nombre, c_apellido, c_fecha, c_rol_nombre;
        IF done_custom THEN LEAVE read_custom; END IF;

        SELECT ID INTO c_rol_id FROM tbc_roles WHERE nombre = c_rol_nombre LIMIT 1;
        IF c_rol_id IS NULL THEN ITERATE read_custom; END IF;

        SET c_persona_id = UUID();
        SET c_user_id = UUID();
        SET c_nombre_usuario = CONCAT(LOWER(c_nombre), '.', LOWER(c_apellido), FLOOR(100 + RAND() * 900));

        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Nombre_Usuario = c_nombre_usuario) DO
            SET c_nombre_usuario = CONCAT(LOWER(c_nombre), '.', LOWER(c_apellido), FLOOR(100 + RAND() * 900));
        END WHILE;

        SET c_correo = CONCAT(c_nombre_usuario, '@ejemplo.com');
        WHILE EXISTS (SELECT 1 FROM tbb_usuarios WHERE Correo_Electronico = c_correo) DO
            SET c_correo = CONCAT(c_nombre_usuario, FLOOR(10 + RAND() * 90), '@ejemplo.com');
        END WHILE;

        SET c_contra = SUBSTRING(MD5(RAND()), 1, 8);
        SET c_telefono = fn_genera_numero_telefonico();

        START TRANSACTION;

INSERT INTO tbb_personas (
    ID, Nombre, Primer_Apellido, Fecha_Nacimiento, Estatus, Fecha_Registro
)
VALUES (
    c_persona_id, c_nombre, c_apellido, c_fecha, 1, NOW()
);

        INSERT INTO tbb_usuarios (
            ID, Persona_ID, Nombre_Usuario, Correo_Electronico, Contrasena,
            numero_telefonico_movil, Estatus, Fecha_Registro
        ) VALUES (
            c_user_id, c_persona_id, c_nombre_usuario, c_correo, c_contra,
            c_telefono, 'Activo', NOW()
        );

        INSERT INTO tbd_usuarios_roles (
            Usuario_ID, Rol_ID, Estatus, Fecha_Registro
        ) VALUES (
            c_user_id, c_rol_id, b'1', NOW()
        );

        COMMIT;
    END LOOP;
    CLOSE cur_custom;

    DROP TEMPORARY TABLE IF EXISTS tmp_fijas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_roles_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_roles_usuario`(v_correo_electronico VARCHAR(60))
BEGIN
   -- Verificamos si el usuario existe
   IF (SELECT COUNT(*) FROM tbb_usuarios WHERE correo_electronico = v_correo_electronico) >0 THEN
	 -- Verificamos si el usuario se encuentra Bloqueado
	 IF (SELECT estatus FROM tbb_usuarios WHERE correo_electronico = v_correo_electronico) = "Bloqueado"  THEN 
       SELECT CONCAT_WS(" ", "El usuario:", v_correo_electronico,"actualmente se encuentrá bloqueado del sistema.") as Mensaje;
	-- Verificamos si el usuario se encuentra Suspendido 
     ELSEIF (SELECT estatus FROM tbb_usuarios WHERE correo_electronico = v_correo_electronico) = "Suspendido"  THEN 
       SELECT CONCAT_WS(" ", "El usuario:", v_correo_electronico," ha sido suspendido del uso del sistema.") as Mensaje;
	 ELSE
		SELECT r.Nombre FROM 
        tbc_roles r 
        JOIN tbd_usuarios_roles ur ON ur.rol_id = r.id
        JOIN tbb_usuarios u ON ur.usuario_id = u.id
        WHERE u.correo_electronico=v_correo_electronico AND ur.estatus = TRUE;
	END IF;
	ELSE 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario especificado no existe';
   END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vista_grupos_sanguineos`
--

/*!50001 DROP VIEW IF EXISTS `vista_grupos_sanguineos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_grupos_sanguineos` AS select `p`.`grupo_sanguineo` AS `Grupo_Sanguineo`,`p`.`genero` AS `Genero`,count(0) AS `cantidad_personas`,round(((count(0) * 100.0) / (select count(0) from `tbb_personas`)),2) AS `porcentaje` from `tbb_personas` `p` group by `p`.`grupo_sanguineo`,`p`.`genero` order by `cantidad_personas` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_roles_usuarios`
--

/*!50001 DROP VIEW IF EXISTS `vista_roles_usuarios`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_roles_usuarios` AS select `r`.`Nombre` AS `Rol`,count(`ur`.`Usuario_ID`) AS `Total_Usuarios`,sum((case when (`p`.`genero` = 'M') then 1 else 0 end)) AS `Total_Hombres`,sum((case when (`p`.`genero` = 'F') then 1 else 0 end)) AS `Total_Mujeres`,sum((case when (`p`.`genero` = 'N/B') then 1 else 0 end)) AS `Total_N/B` from (((`tbc_roles` `r` left join `tbd_usuarios_roles` `ur` on((`r`.`ID` = `ur`.`Rol_ID`))) left join `tbb_usuarios` `u` on((`ur`.`Usuario_ID` = `u`.`id`))) left join `tbb_personas` `p` on((`u`.`persona_id` = `p`.`id`))) group by `r`.`Nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-25 11:31:24
