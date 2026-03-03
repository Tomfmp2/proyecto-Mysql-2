DROP DATABASE IF EXISTS sistema_inmobiliario;
CREATE DATABASE sistema_inmobiliario
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE sistema_inmobiliario;



-- Roles del sistema: Admin, Agente, Contador
CREATE TABLE Roles (
    id_rol      INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_rol  VARCHAR(50) NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB;

-- Tipos de inmueble del portafolio
CREATE TABLE Tipos_Propiedad (
    id_tipo_propiedad INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo       VARCHAR(50) NOT NULL,
    descripcion_tipo  TEXT,
    uso               ENUM('Residencial','Comercial','Mixto','Industrial')
                      NOT NULL DEFAULT 'Residencial'
) ENGINE=InnoDB;

-- Estados posibles de un inmueble a lo largo de su ciclo de vida
-- permite_oferta:   controla si la propiedad se muestra a clientes
-- permite_contrato: controla si se puede firmar un contrato nuevo
-- color_referencia: código hex para semáforos visuales en interfaces
CREATE TABLE Estados_Propiedad (
    id_estado_propiedad INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_estado       VARCHAR(50) NOT NULL,
    descripcion         TEXT,
    permite_oferta      TINYINT(1)  NOT NULL DEFAULT 1,
    permite_contrato    TINYINT(1)  NOT NULL DEFAULT 1,
    color_referencia    VARCHAR(7)  DEFAULT '#808080'
) ENGINE=InnoDB;

-- Estados del ciclo de vida de un contrato
CREATE TABLE Estados_Contrato (
    id_estado_contrato INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_estado      VARCHAR(50) NOT NULL,
    descripcion        TEXT
) ENGINE=InnoDB;

-- Modalidades de contrato que maneja la inmobiliaria
-- genera_pagos_periodicos: diferencia arriendos de compraventas
CREATE TABLE Tipos_Contrato (
    id_tipo_contrato        INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo_contrato    VARCHAR(50) NOT NULL,
    descripcion             TEXT,
    genera_pagos_periodicos TINYINT(1)  NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- Estados posibles de un pago registrado
-- es_deuda_activa:  define si cuenta en el cálculo de deuda
-- requiere_gestion: define si aparece en alertas de cartera morosa
CREATE TABLE Estados_Pago (
    id_estado_pago     INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_estado_pago VARCHAR(50) NOT NULL,
    descripcion        TEXT,
    es_deuda_activa    TINYINT(1)  NOT NULL DEFAULT 0,
    requiere_gestion   TINYINT(1)  NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- Ciudades de operación — elimina dependencia transitiva en
-- Propiedades y Clientes para cumplir 3FN
CREATE TABLE Ciudades (
    id_ciudad     INT          AUTO_INCREMENT PRIMARY KEY,
    nombre_ciudad VARCHAR(100) NOT NULL,
    departamento  VARCHAR(100),
    codigo_dane   VARCHAR(10)
) ENGINE=InnoDB;

-- Tipo de interés del cliente — elimina dependencia transitiva
-- en Clientes para cumplir 3FN
CREATE TABLE Tipos_Interes (
    id_tipo_interes INT         AUTO_INCREMENT PRIMARY KEY,
    nombre_interes  VARCHAR(50) NOT NULL,
    descripcion     TEXT
) ENGINE=InnoDB;

-- SECCIÓN 2: ENTIDADES PRINCIPALES (4)
-- Personal de la inmobiliaria que gestiona ventas y arriendos
CREATE TABLE Agentes (
    id_agente             INT          AUTO_INCREMENT PRIMARY KEY,
    nombre_agente         VARCHAR(100) NOT NULL,
    apellido_agente       VARCHAR(100) NOT NULL,
    tipo_documento        ENUM('CC','CE','Pasaporte') NOT NULL DEFAULT 'CC',
    documento_identidad   VARCHAR(50)  UNIQUE NOT NULL,
    email                 VARCHAR(100) UNIQUE NOT NULL,
    telefono_principal    VARCHAR(20),
    telefono_alternativo  VARCHAR(20),
    id_rol                INT,
    comision_porcentaje   DECIMAL(5,2) DEFAULT 0.00,
    fecha_ingreso         DATE         DEFAULT (CURRENT_DATE),
    activo                TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_agente_rol
        FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
) ENGINE=InnoDB;

-- Personas interesadas en comprar o arrendar
CREATE TABLE Clientes (
    id_cliente              INT          AUTO_INCREMENT PRIMARY KEY,
    nombre                  VARCHAR(100) NOT NULL,
    apellido                VARCHAR(100) NOT NULL,
    tipo_documento          ENUM('CC','CE','Pasaporte','NIT') NOT NULL DEFAULT 'CC',
    documento_identidad     VARCHAR(50)  UNIQUE,
    email                   VARCHAR(100) UNIQUE NOT NULL,
    telefono_principal      VARCHAR(20),
    telefono_alternativo    VARCHAR(20),
    direccion_cliente       VARCHAR(255),
    id_ciudad_cliente       INT,
    id_tipo_interes         INT,
    presupuesto_min         DECIMAL(15,2),
    presupuesto_max         DECIMAL(15,2),
    habitaciones_requeridas INT,
    fecha_registro          DATE         DEFAULT (CURRENT_DATE),
    fecha_requerida         DATE,
    activo                  TINYINT(1)   NOT NULL DEFAULT 1,
    notas                   TEXT,
    CONSTRAINT fk_cliente_ciudad
        FOREIGN KEY (id_ciudad_cliente) REFERENCES Ciudades(id_ciudad),
    CONSTRAINT fk_cliente_interes
        FOREIGN KEY (id_tipo_interes)   REFERENCES Tipos_Interes(id_tipo_interes)
) ENGINE=InnoDB;

-- Portafolio de inmuebles de la inmobiliaria
-- Sin id_propietario porque la inmobiliaria es la dueña
CREATE TABLE Propiedades (
    id_propiedad              INT          AUTO_INCREMENT PRIMARY KEY,
    direccion                 VARCHAR(255) NOT NULL,
    id_ciudad                 INT,
    barrio                    VARCHAR(100),
    estrato                   TINYINT      CHECK (estrato BETWEEN 1 AND 6),
    id_tipo_propiedad         INT,
    metros_cuadrados          DECIMAL(10,2),
    metros_cuadrados_privados DECIMAL(10,2),
    piso                      INT,
    total_pisos_edificio      INT,
    habitaciones              INT,
    banos                     INT,
    parqueaderos              INT          DEFAULT 0,
    tiene_deposito            TINYINT(1)   DEFAULT 0,
    tiene_conjunto_cerrado    TINYINT(1)   DEFAULT 0,
    valor_administracion      DECIMAL(10,2) DEFAULT 0,
    precio_venta              DECIMAL(15,2),
    precio_arriendo           DECIMAL(15,2),
    id_estado                 INT,
    ano_construccion          YEAR,
    descripcion               TEXT,
    fecha_disponible          DATE,
    comision_venta_estimada   DECIMAL(15,2),
    fecha_ingreso_portafolio  DATE         DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_prop_ciudad
        FOREIGN KEY (id_ciudad)         REFERENCES Ciudades(id_ciudad),
    CONSTRAINT fk_prop_tipo
        FOREIGN KEY (id_tipo_propiedad) REFERENCES Tipos_Propiedad(id_tipo_propiedad),
    CONSTRAINT fk_prop_estado
        FOREIGN KEY (id_estado)         REFERENCES Estados_Propiedad(id_estado_propiedad)
) ENGINE=InnoDB;

-- Cuentas de acceso al sistema con control por rol
CREATE TABLE Usuarios (
    id_usuario     INT          AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(50)  UNIQUE NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    id_rol         INT,
    ultimo_login   DATETIME,
    activo         TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
) ENGINE=InnoDB;


-- SECCIÓN 3: TRANSACCIONES Y AUDITORÍA (4)
-- Contratos firmados entre clientes y la inmobiliaria
CREATE TABLE Contratos (
    id_contrato             INT          AUTO_INCREMENT PRIMARY KEY,
    id_propiedad            INT,
    id_cliente              INT,
    id_agente               INT,
    fecha_inicio            DATE,
    fecha_fin               DATE,
    id_tipo_contrato        INT,
    monto_total             DECIMAL(15,2),
    comision_agente         DECIMAL(15,2),
    id_estado_contrato      INT,
    valor_arriendo_mensual  DECIMAL(15,2),
    dia_pago_mensual        TINYINT      CHECK (dia_pago_mensual BETWEEN 1 AND 28),
    fecha_firma             DATE,
    meses_deposito_garantia TINYINT      DEFAULT 0,
    valor_deposito_garantia DECIMAL(15,2) DEFAULT 0,
    renovacion_automatica   TINYINT(1)   DEFAULT 0,
    terminos                TEXT,
    CONSTRAINT fk_cont_prop
        FOREIGN KEY (id_propiedad)       REFERENCES Propiedades(id_propiedad),
    CONSTRAINT fk_cont_clie
        FOREIGN KEY (id_cliente)         REFERENCES Clientes(id_cliente),
    CONSTRAINT fk_cont_agen
        FOREIGN KEY (id_agente)          REFERENCES Agentes(id_agente),
    CONSTRAINT fk_cont_tipo
        FOREIGN KEY (id_tipo_contrato)   REFERENCES Tipos_Contrato(id_tipo_contrato),
    CONSTRAINT fk_cont_estado
        FOREIGN KEY (id_estado_contrato) REFERENCES Estados_Contrato(id_estado_contrato)
) ENGINE=InnoDB;

-- Historial de pagos por contrato
CREATE TABLE Pagos (
    id_pago              INT          AUTO_INCREMENT PRIMARY KEY,
    id_contrato          INT,
    id_propiedad         INT,
    id_cliente           INT,
    fecha_pago           DATE,
    fecha_limite_pago    DATE,
    monto_pagado         DECIMAL(15,2),
    multa_mora           DECIMAL(15,2) DEFAULT 0,
    mes_referencia       VARCHAR(20),
    id_estado_pago       INT,
    medio_pago           ENUM('Efectivo','Transferencia','Cheque','Otro')
                         DEFAULT 'Transferencia',
    referencia_pago      VARCHAR(100),
    descripcion_pago     TEXT,
    id_agente_supervisor INT,
    CONSTRAINT fk_pago_cont
        FOREIGN KEY (id_contrato)          REFERENCES Contratos(id_contrato),
    CONSTRAINT fk_pago_prop
        FOREIGN KEY (id_propiedad)         REFERENCES Propiedades(id_propiedad),
    CONSTRAINT fk_pago_clie
        FOREIGN KEY (id_cliente)           REFERENCES Clientes(id_cliente),
    CONSTRAINT fk_pago_estado
        FOREIGN KEY (id_estado_pago)       REFERENCES Estados_Pago(id_estado_pago),
    CONSTRAINT fk_pago_supervisor
        FOREIGN KEY (id_agente_supervisor) REFERENCES Agentes(id_agente)
) ENGINE=InnoDB;

-- Auditoría automática de cambios — alimentada por triggers
CREATE TABLE Historial_Cambios (
    id_historial   INT          AUTO_INCREMENT PRIMARY KEY,
    id_propiedad   INT,
    id_contrato    INT,
    campo_cambiado VARCHAR(100),
    valor_anterior TEXT,
    valor_nuevo    TEXT,
    fecha_cambio   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    id_usuario     INT,
    CONSTRAINT fk_hist_prop
        FOREIGN KEY (id_propiedad) REFERENCES Propiedades(id_propiedad),
    CONSTRAINT fk_hist_cont
        FOREIGN KEY (id_contrato)  REFERENCES Contratos(id_contrato),
    CONSTRAINT fk_hist_user
        FOREIGN KEY (id_usuario)   REFERENCES Usuarios(id_usuario)
) ENGINE=InnoDB;

-- Destino del evento mensual automático de cartera pendiente
CREATE TABLE Reportes_Pendientes (
    id_reporte       INT          AUTO_INCREMENT PRIMARY KEY,
    mes_anio         VARCHAR(20),
    id_propiedad     INT,
    id_contrato      INT,
    deuda_pendiente  DECIMAL(15,2),
    fecha_generacion DATE,
    CONSTRAINT fk_rep_prop
        FOREIGN KEY (id_propiedad) REFERENCES Propiedades(id_propiedad),
    CONSTRAINT fk_rep_cont
        FOREIGN KEY (id_contrato)  REFERENCES Contratos(id_contrato)
) ENGINE=InnoDB;


-- SECCIÓN 4: TABLAS INTERMEDIAS — RELACIONES N:M (3)
-- Una propiedad puede ser gestionada por varios agentes
CREATE TABLE Propiedad_Agente (
    id_propiedad            INT,
    id_agente               INT,
    fecha_asignacion_agente TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_propiedad, id_agente),
    CONSTRAINT fk_pa_prop FOREIGN KEY (id_propiedad) REFERENCES Propiedades(id_propiedad),
    CONSTRAINT fk_pa_agen FOREIGN KEY (id_agente)    REFERENCES Agentes(id_agente)
) ENGINE=InnoDB;

-- Un cliente puede ser atendido por varios agentes
CREATE TABLE Cliente_Agente (
    id_cliente INT,
    id_agente  INT,
    PRIMARY KEY (id_cliente, id_agente),
    CONSTRAINT fk_ca_clie FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT fk_ca_agen FOREIGN KEY (id_agente)  REFERENCES Agentes(id_agente)
) ENGINE=InnoDB;

-- Privilegios granulares por usuario del sistema
CREATE TABLE Usuario_Privilegio (
    id_usuario INT,
    privilegio VARCHAR(100),
    PRIMARY KEY (id_usuario, privilegio),
    CONSTRAINT fk_up_user FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
) ENGINE=InnoDB;

-- SECCIÓN 5: ÍNDICES DE OPTIMIZACIÓN
CREATE INDEX idx_prop_estado   ON Propiedades(id_estado);
CREATE INDEX idx_prop_ciudad   ON Propiedades(id_ciudad);
CREATE INDEX idx_prop_tipo     ON Propiedades(id_tipo_propiedad);
CREATE INDEX idx_prop_estrato  ON Propiedades(estrato);
CREATE INDEX idx_prop_precio_v ON Propiedades(precio_venta);
CREATE INDEX idx_prop_precio_a ON Propiedades(precio_arriendo);
CREATE INDEX idx_cont_estado   ON Contratos(id_estado_contrato);
CREATE INDEX idx_cont_fechas   ON Contratos(fecha_inicio, fecha_fin);
CREATE INDEX idx_pago_contrato ON Pagos(id_contrato);
CREATE INDEX idx_pago_estado   ON Pagos(id_estado_pago);
CREATE INDEX idx_pago_fecha    ON Pagos(fecha_pago);
CREATE INDEX idx_cliente_email ON Clientes(email);
CREATE INDEX idx_agente_email  ON Agentes(email);

-- SECCIÓN 6: FUNCIONES PERSONALIZADAS (UDFs)
DELIMITER //

-- Calcula la comisión de un agente dado un monto de venta
CREATE FUNCTION fn_calcular_comision(p_monto DECIMAL(15,2), p_id_agente INT)
RETURNS DECIMAL(15,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_porcentaje DECIMAL(5,2) DEFAULT 0;
    SELECT comision_porcentaje INTO v_porcentaje
    FROM Agentes WHERE id_agente = p_id_agente;
    RETURN ROUND(p_monto * (v_porcentaje / 100), 2);
END //

-- Calcula la deuda pendiente de un contrato
-- monto_total del contrato menos suma de todos los pagos realizados
CREATE FUNCTION fn_deuda_pendiente(p_id_contrato INT)
RETURNS DECIMAL(15,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_pactado DECIMAL(15,2) DEFAULT 0;
    DECLARE v_pagado  DECIMAL(15,2) DEFAULT 0;
    SELECT monto_total INTO v_pactado
        FROM Contratos WHERE id_contrato = p_id_contrato;
    SELECT IFNULL(SUM(monto_pagado), 0) INTO v_pagado
        FROM Pagos WHERE id_contrato = p_id_contrato;
    RETURN (v_pactado - v_pagado);
END //

-- Retorna el total de propiedades disponibles de un tipo dado
-- id_estado = 1 corresponde a Disponible
CREATE FUNCTION fn_total_disponibles_tipo(p_id_tipo INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_conteo INT DEFAULT 0;
    SELECT COUNT(*) INTO v_conteo
    FROM Propiedades
    WHERE id_tipo_propiedad = p_id_tipo AND id_estado = 1;
    RETURN v_conteo;
END //

DELIMITER ;

-- SECCIÓN 7: TRIGGERS DE AUDITORÍA
DELIMITER //

-- Registra en Historial_Cambios cuando cambia el estado
-- de una propiedad (disponible -> arrendada -> vendida, etc.)
CREATE TRIGGER trg_auditoria_estado_propiedad
AFTER UPDATE ON Propiedades
FOR EACH ROW
BEGIN
    IF OLD.id_estado <> NEW.id_estado THEN
        INSERT INTO Historial_Cambios
            (id_propiedad, campo_cambiado, valor_anterior, valor_nuevo)
        VALUES
            (NEW.id_propiedad,
             'id_estado',
             CAST(OLD.id_estado AS CHAR),
             CAST(NEW.id_estado AS CHAR));
    END IF;
END //

-- Registra en Historial_Cambios cada nuevo contrato creado
CREATE TRIGGER trg_auditoria_nuevo_contrato
AFTER INSERT ON Contratos
FOR EACH ROW
BEGIN
    INSERT INTO Historial_Cambios
        (id_contrato, campo_cambiado, valor_anterior, valor_nuevo)
    VALUES
        (NEW.id_contrato,
         'CREACION_CONTRATO',
         'Sin contrato previo',
         CONCAT('Contrato #', NEW.id_contrato,
                ' — Propiedad #', NEW.id_propiedad,
                ' — Cliente #', NEW.id_cliente));
END //

DELIMITER ;

-- SECCIÓN 8: EVENTO PROGRAMADO MENSUAL
SET GLOBAL event_scheduler = ON;

DELIMITER //

-- Cada mes inserta en Reportes_Pendientes los contratos
-- activos (id_estado_contrato = 1) con deuda mayor a cero
CREATE EVENT evt_reporte_mensual_deudas
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-04-01 00:00:00'
DO
BEGIN
    INSERT INTO Reportes_Pendientes
        (mes_anio, id_propiedad, id_contrato, deuda_pendiente, fecha_generacion)
    SELECT
        DATE_FORMAT(NOW(), '%m-%Y'),
        id_propiedad,
        id_contrato,
        fn_deuda_pendiente(id_contrato),
        CURRENT_DATE
    FROM Contratos
    WHERE id_estado_contrato = 1
      AND fn_deuda_pendiente(id_contrato) > 0;
END //

DELIMITER ;


-- SECCIÓN 9: SEGURIDAD — ROLES Y USUARIOS DE BASE DE DATOS
CREATE ROLE IF NOT EXISTS 'admin_role', 'agente_role', 'contador_role';

-- Administrador: control total del sistema
GRANT ALL PRIVILEGES ON sistema_inmobiliario.* TO 'admin_role';

-- Agente: gestión operativa de propiedades, clientes y contratos
GRANT SELECT, INSERT, UPDATE ON sistema_inmobiliario.Propiedades      TO 'agente_role';
GRANT SELECT, INSERT, UPDATE ON sistema_inmobiliario.Clientes         TO 'agente_role';
GRANT SELECT, INSERT         ON sistema_inmobiliario.Contratos        TO 'agente_role';
GRANT SELECT, INSERT         ON sistema_inmobiliario.Pagos            TO 'agente_role';
GRANT SELECT                 ON sistema_inmobiliario.Ciudades         TO 'agente_role';
GRANT SELECT                 ON sistema_inmobiliario.Tipos_Propiedad  TO 'agente_role';
GRANT SELECT                 ON sistema_inmobiliario.Estados_Propiedad TO 'agente_role';
GRANT SELECT                 ON sistema_inmobiliario.Tipos_Contrato   TO 'agente_role';

-- Contador: acceso financiero — pagos y reportes de cartera
GRANT SELECT, INSERT, UPDATE ON sistema_inmobiliario.Pagos               TO 'contador_role';
GRANT SELECT                 ON sistema_inmobiliario.Contratos           TO 'contador_role';
GRANT SELECT                 ON sistema_inmobiliario.Reportes_Pendientes TO 'contador_role';
GRANT SELECT                 ON sistema_inmobiliario.Clientes            TO 'contador_role';

-- Usuarios físicos del sistema
CREATE USER IF NOT EXISTS 'admin_user'@'localhost'    IDENTIFIED BY 'AdminPass2026!';
CREATE USER IF NOT EXISTS 'agente_carlos'@'localhost' IDENTIFIED BY 'AgentePass123!';
CREATE USER IF NOT EXISTS 'conta_elena'@'localhost'   IDENTIFIED BY 'ContaPass789!';

GRANT 'admin_role'    TO 'admin_user'@'localhost';
GRANT 'agente_role'   TO 'agente_carlos'@'localhost';
GRANT 'contador_role' TO 'conta_elena'@'localhost';

SET DEFAULT ROLE ALL TO
    'admin_user'@'localhost',
    'agente_carlos'@'localhost',
    'conta_elena'@'localhost';

FLUSH PRIVILEGES;

-- SECCIÓN 10: VISTAS
-- Resumen comercial por agente para el Administrador
CREATE OR REPLACE VIEW vista_resumen_agentes AS
SELECT
    CONCAT(a.nombre_agente, ' ', a.apellido_agente)                       AS agente,
    COUNT(c.id_contrato)                                                   AS total_contratos,
    IFNULL(SUM(c.monto_total), 0)                                          AS monto_gestionado,
    IFNULL(SUM(fn_calcular_comision(c.monto_total, a.id_agente)), 0)       AS comisiones_ganadas
FROM Agentes a
LEFT JOIN Contratos c ON a.id_agente = c.id_agente
GROUP BY a.id_agente, a.nombre_agente, a.apellido_agente;

-- Cartera morosa para el Contador
CREATE OR REPLACE VIEW vista_cartera_pendiente AS
SELECT
    CONCAT(cl.nombre, ' ', cl.apellido)  AS cliente,
    cl.telefono_principal                 AS telefono,
    p.direccion                           AS propiedad,
    ci.nombre_ciudad                      AS ciudad,
    c.fecha_fin                           AS vencimiento,
    fn_deuda_pendiente(c.id_contrato)     AS saldo_mora
FROM Contratos c
JOIN Clientes    cl ON c.id_cliente   = cl.id_cliente
JOIN Propiedades p  ON c.id_propiedad = p.id_propiedad
JOIN Ciudades    ci ON p.id_ciudad    = ci.id_ciudad
WHERE fn_deuda_pendiente(c.id_contrato) > 0;

-- Portafolio disponible para los Agentes
CREATE OR REPLACE VIEW vista_portafolio_disponible AS
SELECT
    p.id_propiedad,
    p.direccion,
    p.barrio,
    ci.nombre_ciudad       AS ciudad,
    tp.nombre_tipo         AS tipo,
    tp.uso,
    p.estrato,
    p.metros_cuadrados,
    p.habitaciones,
    p.banos,
    p.parqueaderos,
    p.valor_administracion,
    p.precio_venta,
    p.precio_arriendo,
    p.fecha_disponible
FROM Propiedades p
JOIN Ciudades        ci ON p.id_ciudad         = ci.id_ciudad
JOIN Tipos_Propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
WHERE p.id_estado = 1;