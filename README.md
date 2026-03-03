# Sistema de Gestion Inmobiliaria — Base de Datos MySQL

<img width="861" height="698" alt="image" src="https://github.com/user-attachments/assets/f2bc2a17-3bfc-4826-a7ee-fda99f1f9b31" />

Base de datos normalizada hasta Tercera Forma Normal (3FN) para la gestion del portafolio de propiedades, clientes, contratos y pagos de una inmobiliaria. Incluye funciones personalizadas, triggers de auditoria, seguridad por roles, optimizacion con indices y eventos programados.

---

## Estructura del repositorio

```
sistema-inmobiliario/
|
|-- sql/
|   |-- DDL_sistema_inmobiliario_FINAL.sql   # Creacion de tablas, indices, UDFs, triggers, roles
|   +-- DML_sistema_inmobiliario_FINAL.sql   # Datos de prueba y consultas de verificacion
|
|-- docs/
|   +-- Documentacion_Normalizacion.docx    # Proceso completo de normalizacion 1FN a 3FN
|
+-- README.md
```

---

## Requisitos

| Herramienta     | Version minima |
|-----------------|----------------|
| MySQL Server    | 8.0 o superior |
| MySQL Workbench | 8.0 recomendado |
| Sistema operativo | Windows / macOS / Linux |

---

## Instrucciones de instalacion

### Paso 1 — Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/sistema-inmobiliario.git
cd sistema-inmobiliario
```

### Paso 2 — Verificar que MySQL este corriendo

```bash
# Windows (PowerShell como administrador)
net start MySQL80

# macOS
brew services start mysql

# Linux
sudo systemctl start mysql
```

### Paso 3 — Conectarse a MySQL

```bash
mysql -u root -p
```

### Paso 4 — Ejecutar el DDL (estructura de la base de datos)

```bash
mysql -u root -p < sql/DDL_sistema_inmobiliario_FINAL.sql
```

Desde MySQL Workbench:
1. Abrir MySQL Workbench y conectarse al servidor
2. Ir a File > Open SQL Script
3. Seleccionar `sql/DDL_sistema_inmobiliario_FINAL.sql`
4. Ejecutar con Ctrl + Shift + Enter

### Paso 5 — Ejecutar el DML (datos de prueba)

```bash
mysql -u root -p sistema_inmobiliario < sql/DML_sistema_inmobiliario_FINAL.sql
```

Desde MySQL Workbench:
1. Abrir `sql/DML_sistema_inmobiliario_FINAL.sql`
2. Ejecutar con Ctrl + Shift + Enter

### Paso 6 — Habilitar el Event Scheduler

```sql
SET GLOBAL event_scheduler = ON;

-- Verificar que quedo activo
SHOW VARIABLES LIKE 'event_scheduler';
```

### Paso 7 — Verificar la instalacion

```sql
USE sistema_inmobiliario;

SELECT 'Propiedades' AS tabla, COUNT(*) AS total FROM Propiedades
UNION ALL SELECT 'Clientes',   COUNT(*) FROM Clientes
UNION ALL SELECT 'Contratos',  COUNT(*) FROM Contratos
UNION ALL SELECT 'Pagos',      COUNT(*) FROM Pagos
UNION ALL SELECT 'Agentes',    COUNT(*) FROM Agentes;
```

Resultado esperado: 10 propiedades, 10 clientes, 6 contratos, 8 pagos, 5 agentes.

---

## Modelo de datos

### Resumen del modelo — 16 tablas

| Grupo | Tablas | Proposito |
|---|---|---|
| Catalogos (8) | Roles, Tipos_Propiedad, Estados_Propiedad, Estados_Contrato, Tipos_Contrato, Estados_Pago, Ciudades, Tipos_Interes | Eliminan dependencias transitivas — justifican la 3FN |
| Entidades principales (4) | Agentes, Clientes, Propiedades, Usuarios | Core del negocio inmobiliario |
| Transacciones y auditoria (4) | Contratos, Pagos, Historial_Cambios, Reportes_Pendientes | Operacion y trazabilidad |
| Intermedias N:M (3) | Propiedad_Agente, Cliente_Agente, Usuario_Privilegio | Relaciones de muchos a muchos |

### Relaciones principales

```
Propiedades  -->  Ciudades
Propiedades  -->  Tipos_Propiedad
Propiedades  -->  Estados_Propiedad
Clientes     -->  Ciudades
Clientes     -->  Tipos_Interes
Agentes      -->  Roles
Usuarios     -->  Roles
Contratos    -->  Propiedades, Clientes, Agentes, Tipos_Contrato, Estados_Contrato
Pagos        -->  Contratos, Propiedades, Clientes, Estados_Pago, Agentes
Historial_Cambios   -->  Propiedades, Contratos, Usuarios  [alimentada por triggers]
Reportes_Pendientes -->  Propiedades, Contratos            [alimentada por evento mensual]
Propiedad_Agente    -->  Propiedades, Agentes              [N:M]
Cliente_Agente      -->  Clientes, Agentes                 [N:M]
Usuario_Privilegio  -->  Usuarios                          [N:M]
```

---

## Funciones personalizadas (UDFs)

### fn_calcular_comision(p_monto, p_id_agente)

Calcula la comision de un agente sobre un monto de venta consultando su porcentaje en la tabla Agentes.

```sql
-- Comision del agente 1 (5%) sobre venta de $450.000.000
SELECT fn_calcular_comision(450000000, 1) AS comision;
-- Resultado: 22500000.00
```

### fn_deuda_pendiente(p_id_contrato)

Calcula la deuda vigente de un contrato restando la suma de pagos realizados al monto total pactado.

```sql
-- Deuda del contrato 5 (penthouse, primera cuota de tres pagada)
SELECT fn_deuda_pendiente(5) AS deuda_actual;
-- Resultado: 3000000000.00
```

### fn_total_disponibles_tipo(p_id_tipo)

Retorna el total de propiedades con estado Disponible de un tipo especifico.

```sql
-- Apartamentos disponibles en el portafolio (id_tipo 2 = Apartamento)
SELECT fn_total_disponibles_tipo(2) AS apartamentos_disponibles;
```

---

## Triggers de auditoria

### trg_auditoria_estado_propiedad

Se dispara automaticamente cada vez que cambia el campo id_estado de una propiedad. Registra el valor anterior y el nuevo en Historial_Cambios.

```sql
-- Simular cambio: propiedad 1 pasa de Disponible a Arrendada
UPDATE Propiedades SET id_estado = 2 WHERE id_propiedad = 1;

-- Verificar que el trigger registro el cambio
SELECT * FROM Historial_Cambios WHERE id_propiedad = 1;
```

### trg_auditoria_nuevo_contrato

Se dispara automaticamente al insertar cualquier contrato nuevo. Registra la creacion del contrato con propiedad y cliente asociados.

```sql
-- Verificar registro automatico despues de insertar un contrato
SELECT * FROM Historial_Cambios WHERE campo_cambiado = 'CREACION_CONTRATO';
```

---

## Seguridad — Usuarios y roles

El sistema tiene tres roles con permisos diferenciados:

| Usuario BD    | Rol      | Acceso |
|---------------|----------|--------|
| admin_user    | Admin    | Control total del sistema |
| agente_carlos | Agente   | Gestion de propiedades, clientes y contratos |
| conta_elena   | Contador | Pagos y reportes de cartera |

```bash
# Conectarse como agente
mysql -u agente_carlos -p sistema_inmobiliario

# Conectarse como contador
mysql -u conta_elena -p sistema_inmobiliario
```

Contrasenas de prueba (solo entorno de desarrollo — cambiar antes de produccion):
- admin_user: AdminPass2026!
- agente_carlos: AgentePass123!
- conta_elena: ContaPass789!

---

## Vistas disponibles

### vista_portafolio_disponible

Propiedades con estado Disponible con todos sus datos de ubicacion, tipo y precios.

```sql
SELECT * FROM vista_portafolio_disponible;

-- Filtrar por ciudad
SELECT * FROM vista_portafolio_disponible WHERE ciudad = 'Bogota';

-- Filtrar por rango de arriendo
SELECT * FROM vista_portafolio_disponible
WHERE precio_arriendo BETWEEN 1000000 AND 3000000
ORDER BY precio_arriendo;
```

### vista_cartera_pendiente

Contratos activos con saldo pendiente, telefono del cliente y vencimiento del contrato.

```sql
SELECT * FROM vista_cartera_pendiente ORDER BY saldo_mora DESC;
```

### vista_resumen_agentes

Total de contratos, volumen gestionado y comisiones ganadas por agente.

```sql
SELECT * FROM vista_resumen_agentes ORDER BY comisiones_ganadas DESC;
```

---

## Ejemplos de consultas

### 1. Portafolio disponible por ciudad y tipo

```sql
SELECT
    p.direccion,
    ci.nombre_ciudad                      AS ciudad,
    tp.nombre_tipo                        AS tipo,
    p.estrato,
    p.habitaciones,
    FORMAT(p.precio_arriendo, 0, 'es_CO') AS arriendo
FROM Propiedades p
JOIN Ciudades        ci ON p.id_ciudad         = ci.id_ciudad
JOIN Tipos_Propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
WHERE p.id_estado = 1
ORDER BY ci.nombre_ciudad, p.precio_arriendo;
```

### 2. Contratos activos con deuda vigente

```sql
SELECT
    c.id_contrato,
    CONCAT(cl.nombre, ' ', cl.apellido)  AS cliente,
    cl.telefono_principal,
    p.direccion                           AS propiedad,
    c.valor_arriendo_mensual,
    fn_deuda_pendiente(c.id_contrato)     AS deuda_total
FROM Contratos c
JOIN Clientes    cl ON c.id_cliente   = cl.id_cliente
JOIN Propiedades p  ON c.id_propiedad = p.id_propiedad
WHERE c.id_estado_contrato = 1
  AND fn_deuda_pendiente(c.id_contrato) > 0
ORDER BY deuda_total DESC;
```

### 3. Historial de pagos de un contrato

```sql
SELECT
    p.mes_referencia,
    p.fecha_pago,
    p.fecha_limite_pago,
    FORMAT(p.monto_pagado, 0, 'es_CO') AS pagado,
    FORMAT(p.multa_mora, 0, 'es_CO')    AS mora,
    ep.nombre_estado_pago               AS estado,
    p.medio_pago,
    p.referencia_pago
FROM Pagos p
JOIN Estados_Pago ep ON p.id_estado_pago = ep.id_estado_pago
WHERE p.id_contrato = 4
ORDER BY p.fecha_limite_pago;
```

### 4. Propiedades disponibles por tipo

```sql
SELECT
    tp.nombre_tipo,
    tp.uso,
    fn_total_disponibles_tipo(tp.id_tipo_propiedad) AS disponibles
FROM Tipos_Propiedad tp
WHERE fn_total_disponibles_tipo(tp.id_tipo_propiedad) > 0
ORDER BY disponibles DESC;
```

### 5. Ranking de agentes por comisiones generadas

```sql
SELECT
    CONCAT(a.nombre_agente, ' ', a.apellido_agente)                            AS agente,
    COUNT(c.id_contrato)                                                        AS contratos,
    FORMAT(SUM(c.monto_total), 0, 'es_CO')                                      AS volumen_gestionado,
    FORMAT(SUM(fn_calcular_comision(c.monto_total, a.id_agente)), 0, 'es_CO')  AS comisiones
FROM Agentes a
LEFT JOIN Contratos c ON a.id_agente = c.id_agente
GROUP BY a.id_agente, a.nombre_agente, a.apellido_agente
ORDER BY SUM(fn_calcular_comision(c.monto_total, a.id_agente)) DESC;
```

### 6. Auditoria de cambios de estado en propiedades

```sql
SELECT
    hc.fecha_cambio,
    p.direccion              AS propiedad,
    ep_ant.nombre_estado     AS estado_anterior,
    ep_nue.nombre_estado     AS estado_nuevo
FROM Historial_Cambios hc
JOIN Propiedades       p      ON hc.id_propiedad   = p.id_propiedad
JOIN Estados_Propiedad ep_ant ON hc.valor_anterior = CAST(ep_ant.id_estado_propiedad AS CHAR)
JOIN Estados_Propiedad ep_nue ON hc.valor_nuevo    = CAST(ep_nue.id_estado_propiedad AS CHAR)
WHERE hc.campo_cambiado = 'id_estado'
ORDER BY hc.fecha_cambio DESC;
```

### 7. Reporte mensual de cartera generado por el evento

```sql
SELECT
    rp.mes_anio,
    p.direccion                             AS propiedad,
    CONCAT(cl.nombre, ' ', cl.apellido)    AS cliente,
    FORMAT(rp.deuda_pendiente, 0, 'es_CO') AS deuda
FROM Reportes_Pendientes rp
JOIN Propiedades p  ON rp.id_propiedad = p.id_propiedad
JOIN Contratos   c  ON rp.id_contrato  = c.id_contrato
JOIN Clientes    cl ON c.id_cliente    = cl.id_cliente
ORDER BY rp.fecha_generacion DESC, rp.deuda_pendiente DESC;
```

### 8. Cruce de clientes con propiedades dentro de su presupuesto

```sql
SELECT
    CONCAT(cl.nombre, ' ', cl.apellido)    AS cliente,
    p.direccion                             AS propiedad,
    tp.nombre_tipo                          AS tipo,
    FORMAT(p.precio_arriendo, 0, 'es_CO')  AS arriendo,
    FORMAT(cl.presupuesto_max, 0, 'es_CO') AS presupuesto_cliente
FROM Clientes cl
JOIN Tipos_Interes   ti ON cl.id_tipo_interes  = ti.id_tipo_interes
JOIN Propiedades     p  ON p.precio_arriendo BETWEEN cl.presupuesto_min AND cl.presupuesto_max
JOIN Tipos_Propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
WHERE ti.nombre_interes IN ('Arriendo', 'Compra o Arriendo')
  AND p.id_estado = 1
ORDER BY cl.id_cliente, p.precio_arriendo;
```

---

## Verificacion rapida del sistema

```sql
USE sistema_inmobiliario;

-- Total de tablas creadas (debe retornar 16)
SELECT COUNT(*) AS total_tablas
FROM information_schema.tables
WHERE table_schema = 'sistema_inmobiliario';

-- Probar las 3 UDFs
SELECT fn_calcular_comision(450000000, 1) AS comision_test;
SELECT fn_deuda_pendiente(5)              AS deuda_test;
SELECT fn_total_disponibles_tipo(2)       AS disponibles_test;

-- Verificar triggers creados
SHOW TRIGGERS FROM sistema_inmobiliario;

-- Verificar evento mensual
SHOW EVENTS FROM sistema_inmobiliario;

-- Verificar vistas
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Verificar usuarios de base de datos
SELECT user, host FROM mysql.user
WHERE user IN ('admin_user', 'agente_carlos', 'conta_elena');
```

---

## Cumplimiento del requerimiento

| Punto | Requerimiento | Estado |
|---|---|---|
| 1 | MER normalizado hasta 3FN con explicacion de decisiones | Cumplido |
| 2 | DDL con tablas, claves primarias y foraneas | Cumplido |
| 3 | UDF calcular comision del agente | Cumplido — fn_calcular_comision |
| 3 | UDF calcular deuda pendiente en arriendo | Cumplido — fn_deuda_pendiente |
| 3 | UDF total de propiedades disponibles por tipo | Cumplido — fn_total_disponibles_tipo |
| 4 | Trigger cambio de estado de propiedad | Cumplido — trg_auditoria_estado_propiedad |
| 4 | Trigger registro de nuevo contrato | Cumplido — trg_auditoria_nuevo_contrato |
| 5 | Roles y privilegios diferenciados admin, agente, contador | Cumplido |
| 6 | Indices para optimizacion de consultas | Cumplido — 13 indices |
| 6 | Evento mensual de reportes de pagos pendientes | Cumplido — evt_reporte_mensual_deudas |
| 7 | DML con datos de prueba | Cumplido — 17 tablas con datos |
| 8 | README.md con instrucciones y ejemplos | Cumplido — este archivo |

---

## Tecnologias

- MySQL 8.0 — Motor de base de datos
- InnoDB — Motor de almacenamiento con soporte de claves foraneas y transacciones

---

## Licencia

Proyecto academico — Uso educativo.
