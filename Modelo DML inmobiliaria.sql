USE sistema_inmobiliario;

-- Roles
INSERT INTO Roles (nombre_rol, descripcion) VALUES
('Admin',    'Control total del sistema. Gestiona usuarios, configuración y reportes.'),
('Agente',   'Gestiona propiedades, clientes y contratos. Sin acceso a configuración.'),
('Contador', 'Acceso financiero. Gestiona pagos y consulta reportes de cartera.');

-- Tipos de propiedad
INSERT INTO Tipos_Propiedad (nombre_tipo, descripcion_tipo, uso) VALUES
('Casa',           'Vivienda unifamiliar independiente con jardín o patio',        'Residencial'),
('Apartamento',    'Unidad residencial en edificio de propiedad horizontal',        'Residencial'),
('Local Comercial','Espacio destinado a comercio minorista o servicios al público', 'Comercial'),
('Oficina',        'Espacio corporativo o profesional en edificio de oficinas',     'Comercial'),
('Bodega',         'Inmueble industrial para almacenamiento o logística',           'Industrial'),
('Penthouse',      'Vivienda de lujo en último piso con terraza privada',           'Residencial'),
('Apartaestudio',  'Apartamento compacto de un solo ambiente integrado',            'Residencial'),
('Lote/Terreno',   'Espacio sin edificar disponible para construcción futura',      'Mixto'),
('Finca/Rural',    'Propiedad campestre o agropecuaria fuera del perímetro urbano', 'Mixto');

-- Estados de propiedad — enriquecidos con comportamiento
INSERT INTO Estados_Propiedad (nombre_estado, descripcion, permite_oferta, permite_contrato, color_referencia) VALUES
('Disponible',       'Lista para ofrecerse. Sin contrato vigente.',                    1, 1, '#28A745'),
('Arrendada',        'Con contrato de arriendo activo y vigente.',                     0, 0, '#007BFF'),
('Vendida',          'Transferida. Sale del portafolio activo.',                       0, 0, '#6C757D'),
('En Mantenimiento', 'Fuera de oferta por reparaciones o adecuaciones.',              0, 0, '#FD7E14'),
('En Negociación',   'Oferta en curso. Se muestra pero no admite nuevo contrato.',    1, 0, '#FFC107');

-- Estados de contrato
INSERT INTO Estados_Contrato (nombre_estado, descripcion) VALUES
('Activo',    'Contrato vigente y en ejecución.'),
('Cerrado',   'Finalizado correctamente. Compraventa escriturada o arriendo terminado.'),
('Vencido',   'Superó su fecha fin sin renovación ni cierre formal.'),
('Cancelado', 'Anulado antes de término por acuerdo o incumplimiento.');

-- Tipos de contrato
INSERT INTO Tipos_Contrato (nombre_tipo_contrato, descripcion, genera_pagos_periodicos) VALUES
('Compraventa',     'Transferencia de dominio del inmueble al comprador.',              0),
('Arriendo',        'Cesión temporal del uso a cambio de canon mensual.',               1),
('Opción de Compra','Reserva del inmueble con derecho preferente de compra.',           0);

-- Estados de pago — con comportamiento lógico
INSERT INTO Estados_Pago (nombre_estado_pago, descripcion, es_deuda_activa, requiere_gestion) VALUES
('Pendiente', 'Dentro del plazo pero no realizado.',          1, 0),
('Pagado',    'Recibido y confirmado en su totalidad.',        0, 0),
('Vencido',   'No realizado después de la fecha límite.',      1, 1),
('Parcial',   'Realizado pero por monto menor al esperado.',   1, 1);

-- Ciudades con departamento y código DANE
INSERT INTO Ciudades (nombre_ciudad, departamento, codigo_dane) VALUES
('Bogotá',        'Cundinamarca',    '11001'),
('Medellín',      'Antioquia',       '05001'),
('Cali',          'Valle del Cauca', '76001'),
('Cartagena',     'Bolívar',         '13001'),
('Barranquilla',  'Atlántico',       '08001'),
('Santa Marta',   'Magdalena',       '47001'),
('Manizales',     'Caldas',          '17001'),
('Pereira',       'Risaralda',       '66001'),
('Bucaramanga',   'Santander',       '68001'),
('Villavicencio', 'Meta',            '50001');

-- Tipos de interés del cliente
INSERT INTO Tipos_Interes (nombre_interes, descripcion) VALUES
('Compra',            'El cliente busca adquirir el inmueble como propietario.'),
('Arriendo',          'El cliente busca arrendar el inmueble para uso propio.'),
('Compra o Arriendo', 'Flexible entre compra y arriendo según condiciones.'),
('Inversión',         'Busca inmueble como activo de rentabilidad o valorización.');

-- SECCIÓN 2: AGENTES
INSERT INTO Agentes (nombre_agente, apellido_agente, tipo_documento, documento_identidad, email, telefono_principal, telefono_alternativo, id_rol, comision_porcentaje, fecha_ingreso, activo) VALUES
('David',   'Beckham',   'CC', '1023456789', 'd.beckham@inmobiliaria.com',   '3009991122', '3009991133', 2, 5.00, '2022-03-01', 1),  -- 1
('Sofia',   'Vergara',   'CC', '1034567890', 's.vergara@inmobiliaria.com',   '3108882233', NULL,         2, 4.50, '2022-06-15', 1),  -- 2
('James',   'Rodriguez', 'CC', '1045678901', 'j.rodriguez@inmobiliaria.com', '3207773344', '3207773355', 2, 3.80, '2023-01-10', 1),  -- 3
('Karol',   'Giraldo',   'CC', '1056789012', 'k.giraldo@inmobiliaria.com',   '3006664455', NULL,         2, 4.20, '2023-07-20', 1),  -- 4
('Shakira', 'Mebarak',   'CC', '1067890123', 's.mebarak@inmobiliaria.com',   '3155556677', '3155556688', 1, 0.00, '2020-01-01', 1);  -- 5 Admin

-- SECCIÓN 3: CLIENTES
INSERT INTO Clientes (nombre, apellido, tipo_documento, documento_identidad, email, telefono_principal, telefono_alternativo, direccion_cliente, id_ciudad_cliente, id_tipo_interes, presupuesto_min, presupuesto_max, habitaciones_requeridas, fecha_registro, fecha_requerida, activo, notas) VALUES
('Andrés',    'Cepeda',    'CC', '79123456',  'acepeda@musica.com',       '3114445566', NULL,         'Calle 90 #11-20',           1,  1,  800000000,  1200000000, 3, '2026-01-10', '2026-04-01', 1, 'Busca casa o apto de lujo en Bogotá norte'),          -- 1
('Mariana',   'Pajón',     'CC', '43987654',  'mpajon@deporte.com',       '3125556677', '3125556688', 'Pista BMX Medellín',        2,  1,  300000000,   450000000, 2, '2026-01-15', '2026-05-01', 1, 'Interesada en apartamento en El Poblado'),            -- 2
('Egan',      'Bernal',    'CC', '1020304050','ebernal@ciclismo.com',     '3136667788', NULL,         'Vereda Zipaquirá',          1,  4, 1500000000, 2500000000, 0, '2026-01-20', '2026-06-01', 1, 'Busca inversión en finca o lote valorizable'),        -- 3
('Rigoberto', 'Urán',      'CC', '71234567',  'ruran@go-rigo-go.com',     '3147778899', '3147778900', 'Calle del Sol 123',         2,  3,  400000000,   600000000, 3, '2026-01-25', '2026-04-15', 1, 'Abierto a compra o arriendo según oportunidad'),      -- 4
('Maluma',    'Londoño',   'CC', '1000123456','maluma@papi-juancho.com',  '3158889900', NULL,         'Llanogrande',               2,  1, 3000000000, 5000000000, 5, '2026-02-01', '2026-03-15', 1, 'Solo penthouse o casas de lujo. Pago de contado.'),   -- 5
('Greeicy',   'Rendón',    'CC', '31456789',  'grendon@danza.com',        '3169990011', '3169990022', 'Calle 5 Sur #2-10',        3,  2,    2000000,    4500000, 1, '2026-02-05', '2026-03-01', 1, 'Bajo presupuesto, prioriza ubicación y transporte'),  -- 6
('Camilo',    'Echeverry', 'CC', '1002345678','camilo@tribu.com',         '3170001122', NULL,         'La Colmena Etapa 2',        10, 2,    2500000,    3000000, 2, '2026-02-08', '2026-03-01', 1, 'Arriendo en los llanos, clima cálido'),               -- 7
('Evaluna',   'Montaner',  'CE', '987654321', 'evaluna@tribu.com',        '3181112233', '3181112244', 'La Colmena Etapa 3',        10, 2,    2500000,    3200000, 2, '2026-02-08', '2026-03-01', 1, 'Misma propiedad que Camilo Echeverry'),               -- 8
('Falcao',    'García',    'CC', '72345678',  'falcao@tigre.com',         '3192223344', NULL,         'Urbanización Playa Salgar', 6,  1, 2000000000, 3500000000, 4, '2026-02-10', '2026-04-01', 1, 'Busca frente al mar, penthouse o casa con piscina'),  -- 9
('Karol',     'Sevilla',   'CC', '1003456789','ksevilla@tv.com',          '3103334455', '3103334466', 'Transversal 6 #20-15',      1,  2,    1500000,    2000000, 1, '2026-02-12', '2026-03-01', 1, 'Apartaestudio en Bogotá, cerca a Teusaquillo');       -- 10

-- SECCIÓN 4: PROPIEDADES
INSERT INTO Propiedades (
    direccion, id_ciudad, barrio, estrato,
    id_tipo_propiedad, metros_cuadrados, metros_cuadrados_privados,
    piso, total_pisos_edificio, habitaciones, banos, parqueaderos,
    tiene_deposito, tiene_conjunto_cerrado, valor_administracion,
    precio_venta, precio_arriendo, id_estado, ano_construccion,
    descripcion, fecha_disponible, comision_venta_estimada,
    fecha_ingreso_portafolio
) VALUES
-- 1: Apartamento Chapinero Alto, Bogotá
('Cra 7 #72-10 Apt 501',       1, 'Chapinero Alto',       5, 2, 120.0, 110.0, 5,  12, 3, 2, 1, 1, 1,  350000, 480000000,   2800000, 1, 2018,
 'Apartamento moderno con vista a los cerros. Cocina abierta, pisos en madera.',
 '2026-03-01', 19200000, '2026-01-10'),

-- 2: Local comercial zona bancaria, Bogotá
('Calle 100 #15-20 Local 1',   1, 'Santa Bárbara',        6, 3,  30.0,  30.0, 1,   1, 0, 1, 0, 0, 0,       0, 450000000,   6000000, 1, 2005,
 'Local esquinero en primer piso, alto flujo peatonal, zona bancaria Usaquén.',
 '2026-02-15', 18000000, '2025-12-01'),

-- 3: Lote Peñol, Medellín
('Lote El Peñol km 5',         2, 'Vereda La Piedra',     1, 8,2500.0,2500.0,NULL,NULL, 0, 0, 0, 0, 0,       0, 850000000,         0, 1, NULL,
 'Lote con vista directa a la Piedra del Peñol. Acceso por vía pavimentada.',
 '2026-05-20', 34000000, '2026-01-20'),

-- 4: Penthouse exclusivo, Bogotá
('Cra 7 #72-10 Penthouse 1',   1, 'Chapinero Alto',       6, 6, 400.0, 380.0,12,  12, 5, 6, 3, 1, 1,  800000,4500000000, 25000000, 1, 2020,
 'El penthouse más exclusivo de Chapinero. Terraza 80m², jacuzzi, vista 360°.',
 '2026-03-01',180000000, '2026-01-05'),

-- 5: Finca, Villavicencio
('Vereda El Carmen Casa 4',    10,'Vereda El Carmen',     1, 9, 300.0, 280.0, 1,   1, 4, 4, 4, 0, 1,       0, 550000000,   3000000, 1, 2010,
 'Finca de campo en clima cálido llanero. Piscina, zona BBQ, potrero.',
 '2026-04-10', 22000000, '2026-01-25'),

-- 6: Apartaestudio, Cali
('Calle 5 Sur #2-20 Apt 101',  3, 'San Fernando',         3, 7,  45.0,  42.0, 1,   8, 1, 1, 0, 0, 1,  120000, 150000000,   1100000, 1, 2015,
 'Apartaestudio remodelado. Cerca a universidades y Clínica Valle del Lili.',
 '2026-02-28',  6000000, '2026-01-30'),

-- 7: Apartamento Santa Marta — estado Arrendada
('Calle 22 #10-40 Apt 302',    6, 'El Rodadero',          4, 2, 110.0, 100.0, 3,   8, 3, 2, 1, 0, 1,  200000, 380000000,   2500000, 2, 2012,
 'Apartamento a 3 cuadras de la bahía. Vista parcial al mar. Piscina en edificio.',
 '2026-01-01', 15200000, '2025-11-01'),

-- 8: Casa Manizales
('Cra 23 #45-67',              7, 'Chipre',               4, 1, 180.0, 165.0, 1,   2, 4, 3, 2, 0, 0,       0, 420000000,   2200000, 1, 2008,
 'Casa colonial en centro histórico de Manizales. Jardín amplio y garaje doble.',
 '2026-03-15', 16800000, '2026-02-01'),

-- 9: Bodega, Bucaramanga
('Zona Industrial Km 2 Bod 5', 9, 'Zona Industrial Norte',2, 5,1200.0,1200.0, 1,   1, 0, 2, 6, 0, 1,       0,2500000000, 15000000, 1, 2000,
 'Bodega doble altura (8m). Muelles de cargue, oficina administrativa incluida.',
 '2026-04-01',100000000, '2025-10-01'),

-- 10: Penthouse, Pereira
('Calle 15 #11-22 Apt 902',    8, 'Álamos',               5, 6, 200.0, 185.0, 9,   9, 3, 4, 2, 1, 1,  450000, 750000000,   4000000, 1, 2019,
 'Penthouse con jacuzzi privado y terraza. Acabados de lujo, cocina europea.',
 '2026-03-10', 30000000, '2026-01-15');


-- SECCIÓN 5: USUARIOS DEL SISTEMA
INSERT INTO Usuarios (nombre_usuario, password_hash, id_rol, ultimo_login, activo) VALUES
('admin.shakira',  SHA2('AdminPass2026!', 256), 1, '2026-02-28 08:00:00', 1),  -- 1
('agente.beckham', SHA2('AgentePass123!', 256), 2, '2026-02-28 09:30:00', 1),  -- 2
('conta.elena',    SHA2('ContaPass789!',  256), 3, '2026-02-27 14:00:00', 1),  -- 3
('agente.sofia',   SHA2('SofiaPass456!',  256), 2, '2026-02-28 10:15:00', 1),  -- 4
('conta.carlos',   SHA2('CarlosPass321!', 256), 3, '2026-02-26 16:00:00', 1);  -- 5


-- SECCIÓN 6: CONTRATOS
INSERT INTO Contratos (
    id_propiedad, id_cliente, id_agente,
    fecha_inicio, fecha_fin, id_tipo_contrato,
    monto_total, comision_agente, id_estado_contrato,
    valor_arriendo_mensual, dia_pago_mensual,
    fecha_firma, meses_deposito_garantia, valor_deposito_garantia,
    renovacion_automatica, terminos
) VALUES
-- 1: Compraventa CERRADA — local Bogotá vendido a Cepeda, agente Beckham (5%)
(2,  1,  1, '2026-01-15', NULL,         1,
  450000000,  22500000, 2,
  0, NULL, '2026-01-10', 0, 0, 0,
 'Pago de contado. Escritura en 30 días hábiles. Notaría 12 de Bogotá.'),

-- 2: Arriendo ACTIVO — finca a Greeicy, agente Vergara (4.5%)
(5,  6,  2, '2026-03-01', '2027-02-28', 2,
   36000000,   1620000, 1,
   3000000, 1, '2026-02-15', 1, 3000000, 1,
 'Canon $3.000.000/mes. Depósito un mes. Renovación automática con ajuste IPC.'),

-- 3: Arriendo ACTIVO — apartaestudio a Karol Sevilla, agente Rodriguez (3.8%)
(6,  10, 3, '2026-03-01', '2027-02-28', 2,
   13200000,    501600, 1,
   1100000, 5, '2026-02-20', 1, 1100000, 0,
 'Canon $1.100.000 incluye administración. Pago antes del día 5 de cada mes.'),

-- 4: Arriendo ACTIVO — apto Santa Marta a Camilo, agente Giraldo (4.2%)
(7,  7,  4, '2026-01-01', '2026-12-31', 2,
   30000000,   1260000, 1,
   2500000, 5, '2025-12-20', 1, 2500000, 0,
 'Arriendo anual. Depósito equivalente a un mes. Inquilino asume servicios.'),

-- 5: Compraventa ACTIVA en cuotas — penthouse a Maluma, agente Beckham (5%)
(4,  5,  1, '2026-02-01', NULL,         1,
 4500000000, 225000000, 1,
  0, NULL, '2026-01-25', 0, 0, 0,
 'Venta en tres cuotas de $1.500.000.000 c/u. Feb, May y Ago 2026.'),

-- 6: Opción de compra ACTIVA — penthouse Pereira a Falcao, agente Vergara
(10, 9,  2, '2026-03-01', '2026-09-01', 3,
  750000000,          0, 1,
  0, NULL, '2026-02-25', 0, 0, 0,
 'Opción de compra 6 meses. Reserva 10% ($75M). Si no ejecuta, pierde reserva.');


-- SECCIÓN 7: PAGOS
INSERT INTO Pagos (
    id_contrato, id_propiedad, id_cliente,
    fecha_pago, fecha_limite_pago,
    monto_pagado, multa_mora, mes_referencia,
    id_estado_pago, medio_pago, referencia_pago,
    descripcion_pago, id_agente_supervisor
) VALUES
-- Contrato 1: local Bogotá — pago único de contado
(1, 2, 1,  '2026-01-15','2026-01-15', 450000000, 0,       'Enero 2026',   2,'Transferencia','TRF-20260115-001',
 'Pago total de contado. Transferencia desde Bancolombia.', 1),

-- Contrato 2: finca — primer canon
(2, 5, 6,  '2026-03-01','2026-03-01',   3000000, 0,       'Marzo 2026',   2,'Transferencia','TRF-20260301-002',
 'Canon marzo. Pago adelantado al momento de firmar contrato.', 2),

-- Contrato 3: apartaestudio — primer canon
(3, 6, 10, '2026-03-05','2026-03-05',   1100000, 0,       'Marzo 2026',   2,'Transferencia','TRF-20260305-003',
 'Canon marzo incluye administración.', 3),

-- Contrato 4: apto Santa Marta — enero y febrero pagados, marzo vencido
(4, 7, 7,  '2026-01-05','2026-01-05',   2500000, 0,       'Enero 2026',   2,'Transferencia','TRF-20260105-004',
 'Primer mes, pago puntual.', 4),

(4, 7, 7,  '2026-02-05','2026-02-05',   2500000, 0,       'Febrero 2026', 2,'Efectivo',     'EFE-20260205-001',
 'Segundo mes, pago en efectivo en oficina.', 4),

(4, 7, 7,  NULL,        '2026-03-05',         0, 125000,  'Marzo 2026',   3,'Otro',         NULL,
 'Pago vencido. Multa del 5% ($125.000) aplicada. Cobro en gestión.', 4),

-- Contrato 5: penthouse Maluma — primera cuota de tres
(5, 4, 5,  '2026-02-01','2026-02-01',1500000000, 0,       'Cuota 1 de 3', 2,'Transferencia','TRF-20260201-005',
 'Primera cuota penthouse Bogotá. Wire transfer internacional.', 1),

-- Contrato 6: opción compra Falcao — reserva del 10%
(6, 10,9,  '2026-03-01','2026-03-01',  75000000, 0,       'Reserva 10%',  2,'Transferencia','TRF-20260301-006',
 'Reserva inicial opción de compra penthouse Pereira.', 2);

-- SECCIÓN 8: TABLAS INTERMEDIAS
-- Propiedades asignadas a agentes
INSERT INTO Propiedad_Agente (id_propiedad, id_agente) VALUES
(1,  1),   -- Apto Chapinero     -> Beckham
(2,  1),   -- Local bancario     -> Beckham
(3,  5),   -- Lote Peñol         -> Shakira (Admin supervisa)
(4,  1),   -- Penthouse Bogotá   -> Beckham
(5,  2),   -- Finca Llanos       -> Vergara
(6,  3),   -- Apartaestudio Cali -> Rodriguez
(7,  4),   -- Apto Santa Marta   -> Giraldo
(8,  3),   -- Casa Manizales     -> Rodriguez
(9,  1),   -- Bodega Bucaramanga -> Beckham
(10, 2);   -- Penthouse Pereira  -> Vergara

-- Clientes asignados a agentes
INSERT INTO Cliente_Agente (id_cliente, id_agente) VALUES
(1,  1),   -- Cepeda    -> Beckham
(2,  2),   -- Pajón     -> Vergara
(3,  1),   -- Bernal    -> Beckham (inversiones)
(5,  1),   -- Maluma    -> Beckham (penthouse)
(6,  2),   -- Greeicy   -> Vergara
(7,  4),   -- Camilo    -> Giraldo
(9,  2),   -- Falcao    -> Vergara
(10, 3);   -- Sevilla   -> Rodriguez

-- Privilegios por usuario
INSERT INTO Usuario_Privilegio (id_usuario, privilegio) VALUES
(1, 'SUPER_ADMIN'),
(1, 'GESTIONAR_USUARIOS'),
(1, 'VER_REPORTES'),
(2, 'GESTIONAR_PROPIEDADES'),
(2, 'GESTIONAR_CLIENTES'),
(3, 'VER_PAGOS'),
(3, 'VER_REPORTES'),
(4, 'GESTIONAR_PROPIEDADES'),
(4, 'GESTIONAR_CLIENTES'),
(5, 'VER_PAGOS'),
(5, 'VER_REPORTES');

-- SECCIÓN 9: VERIFICACIÓN FINAL
SELECT 'Roles'               AS tabla, COUNT(*) AS total FROM Roles
UNION ALL SELECT 'Tipos_Propiedad',    COUNT(*) FROM Tipos_Propiedad
UNION ALL SELECT 'Estados_Propiedad',  COUNT(*) FROM Estados_Propiedad
UNION ALL SELECT 'Estados_Contrato',   COUNT(*) FROM Estados_Contrato
UNION ALL SELECT 'Tipos_Contrato',     COUNT(*) FROM Tipos_Contrato
UNION ALL SELECT 'Estados_Pago',       COUNT(*) FROM Estados_Pago
UNION ALL SELECT 'Ciudades',           COUNT(*) FROM Ciudades
UNION ALL SELECT 'Tipos_Interes',      COUNT(*) FROM Tipos_Interes
UNION ALL SELECT 'Agentes',            COUNT(*) FROM Agentes
UNION ALL SELECT 'Clientes',           COUNT(*) FROM Clientes
UNION ALL SELECT 'Propiedades',        COUNT(*) FROM Propiedades
UNION ALL SELECT 'Usuarios',           COUNT(*) FROM Usuarios
UNION ALL SELECT 'Contratos',          COUNT(*) FROM Contratos
UNION ALL SELECT 'Pagos',              COUNT(*) FROM Pagos
UNION ALL SELECT 'Propiedad_Agente',   COUNT(*) FROM Propiedad_Agente
UNION ALL SELECT 'Cliente_Agente',     COUNT(*) FROM Cliente_Agente
UNION ALL SELECT 'Usuario_Privilegio', COUNT(*) FROM Usuario_Privilegio;

-- Prueba deuda pendiente por contrato
SELECT c.id_contrato,
       CONCAT(cl.nombre,' ',cl.apellido)  AS cliente,
       c.monto_total                       AS valor_contrato,
       fn_deuda_pendiente(c.id_contrato)   AS deuda_actual
FROM Contratos c
JOIN Clientes cl ON c.id_cliente = cl.id_cliente
ORDER BY deuda_actual DESC;

-- Prueba propiedades disponibles por tipo
SELECT tp.nombre_tipo, fn_total_disponibles_tipo(tp.id_tipo_propiedad) AS disponibles
FROM Tipos_Propiedad tp
WHERE fn_total_disponibles_tipo(tp.id_tipo_propiedad) > 0;

-- Prueba comisión Beckham — contrato penthouse ($4.500M a 5%)
SELECT fn_calcular_comision(4500000000, 1) AS comision_beckham;

-- Vistas
SELECT * FROM vista_portafolio_disponible;
SELECT * FROM vista_cartera_pendiente;
SELECT * FROM vista_resumen_agentes;
