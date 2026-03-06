
USE sistema_inmobiliario;

-- CONSULTA 1
SELECT 
    a.nombre_agente AS vendedor,
    COUNT(c.id_propiedad) AS total_propiedades_vendidas
FROM Agentes a
JOIN Contratos c ON a.id_agente = c.id_agente
GROUP BY a.nombre_agente;

-- CONSULTA 2
SELECT 
    p.id_propiedad,
    p.direccion,
    p.precio_venta
FROM Propiedades p
WHERE p.precio_venta BETWEEN 150000000 AND 400000000;

-- CONSULTA 3
INSERT INTO Clientes (nombre, apellido, tipo_documento, documento_identidad, email, telefono_principal, telefono_alternativo, direccion_cliente, id_ciudad_cliente, id_tipo_interes, presupuesto_min, presupuesto_max, habitaciones_requeridas, fecha_registro, fecha_requerida, activo, notas) VALUES
('carlos',    'carlos',    'CC', '72223456',  'carloscarlos@musica.com',       '3228845566', NULL,         'Calle 93 #12-21',          2,  2,  800000000,  1200000000, 3, '2026-01-10', '2026-04-10', 1, 'Busca casa en bogota');
INSERT INTO Clientes (nombre, apellido, tipo_documento, documento_identidad, email, telefono_principal, telefono_alternativo, direccion_cliente, id_ciudad_cliente, id_tipo_interes, presupuesto_min, presupuesto_max, habitaciones_requeridas, fecha_registro, fecha_requerida, activo, notas) VALUES
('carlos',    'juan',    'CC', '72223366',  'carlos112@musica.com',       '3456845566', NULL,         'Calle 93 #12-21',          2,  2,  800000000,  1200000000, 3, '2026-01-10', '2026-04-10', 1, 'Busca casa en bogota');

SELECT 
    id_cliente,
    nombre,
    apellido
FROM Clientes
WHERE nombre LIKE '%carlos%';

-- CONSULTA 4
SELECT 
    a.nombre_agente AS vendedor,
    p.id_propiedad,
    p.direccion
FROM Propiedades p
RIGHT JOIN Contratos c ON p.id_propiedad = c.id_propiedad
RIGHT JOIN Agentes a ON c.id_agente = a.id_agente;

-- CONSULTA 5
CREATE OR REPLACE VIEW vista_resumen_ventas AS
SELECT
    a.nombre_agente AS vendedor,
    SUM(p.precio_venta) AS total_vendido,
    COUNT(DISTINCT c.id_cliente) AS numero_clientes
FROM Agentes a
JOIN Contratos c ON a.id_agente = c.id_agente
JOIN Propiedades p ON c.id_propiedad = p.id_propiedad
GROUP BY a.nombre_agente;

select * from vista_resumen_ventas;